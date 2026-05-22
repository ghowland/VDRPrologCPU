# VDR-Prolog Engine Implementation

## Technical Specification

---

## 1. Overview

The Prolog engine is the reasoning core. It operates on three data sources: TypedRelation arrays in KBs (indexed by RelationIndex), Rule arrays in KBs (matched by head functor), and Fact arrays in KBs (ground data). Every query enters the engine through a single dispatch function that tries typed relation fast path first, then structural rule application, then general unification with backtracking.

The engine runs entirely on a single pinned compute thread. No cross-core coordination. All working memory (binding stacks, search stacks, result buffers) lives in per-core scratch arena. All reads from the global arena (facts, rules, relations) are read-only. Session-local data is checked first, then global.

No floating point. No heap allocation. No recursion in the implementation — all recursive logic is iterative with explicit stacks in arena scratch.

---

## 2. Entry Point

Every Prolog operation enters through one of three functions:

```zig
/// Query: find all bindings that satisfy the goal.
/// Returns results in scratch arena. Caller reads and discards.
pub fn query(
    engine: *PrologEngine,
    goal: *Term,
    scope_kb_id: VdrId,
    config: PrologConfig,
) QueryResult

/// Fire and commit: scan rules against facts in a KB,
/// fire all satisfied rules, assert derived facts.
/// Returns count of rules fired.
pub fn fireAndCommit(
    engine: *PrologEngine,
    kb_id: VdrId,
) FireResult

/// Unify: test whether two terms unify and produce bindings.
/// Pure — no side effects, no KB writes.
pub fn unify(
    engine: *PrologEngine,
    a: *Term,
    b: *Term,
) UnificationResult
```

`query` is what the LLM invokes at L2 and what the pre-resolution system invokes at L3. `fireAndCommit` is what hygiene runners and ingestion invoke to propagate derived facts. `unify` is the primitive used internally by both, but also exposed for direct term matching.

---

## 3. The PrologEngine Struct

```zig
pub const PrologEngine = struct {
    /// KB store for fact/rule/relation access
    store: *KbStore,

    /// Per-core scratch arena for all working memory
    scratch: *Arena,

    /// Session for scope resolution (session tree first, then global)
    session: *Session,

    /// Global arena for read-only access to global KBs
    global_arena: *Arena,

    /// Atom-to-RelationType cache for fast dispatch
    atom_rel_cache: *AtomRelTypeCache,

    /// Statistics tracking
    level_stats: *LevelStats,

    /// Config limits
    config: PrologConfig,
};
```

The engine holds no mutable state between queries. All per-query state lives in scratch arena allocations that are implicitly freed when the arena resets. The engine struct is per-session — each session on a core has its own engine instance pointing to the same store and global arena but different scratch regions and session references.

---

## 4. Query Dispatch — The Priority Chain

Every query passes through a priority chain. Each level is strictly faster than the next. The chain short-circuits at the first level that produces results.

```zig
pub fn query(
    engine: *PrologEngine,
    goal: *Term,
    scope_kb_id: VdrId,
    config: PrologConfig,
) QueryResult {
    // Save scratch cursor for cleanup after query
    const scratch_mark = engine.scratch.cursor;
    defer engine.scratch.cursor = scratch_mark;

    // Priority 1: Typed relation fast path
    if (goal.isCompound()) {
        if (engine.tryTypedRelationQuery(goal, scope_kb_id)) |result| {
            engine.level_stats.l3_count += 1;
            engine.level_stats.l3_relation_queries += 1;
            return result;
        }
    }

    // Priority 2: Transitive closure for transitive types
    if (goal.isCompound()) {
        if (engine.tryTransitiveClosure(goal, scope_kb_id)) |result| {
            engine.level_stats.l3_count += 1;
            engine.level_stats.l3_transitive_closures += 1;
            return result;
        }
    }

    // Priority 3: Inverse lookup
    if (goal.isCompound()) {
        if (engine.tryInverseLookup(goal, scope_kb_id)) |result| {
            engine.level_stats.l3_count += 1;
            engine.level_stats.l3_inverse_lookups += 1;
            return result;
        }
    }

    // Priority 4: Symmetric swap
    if (goal.isCompound()) {
        if (engine.trySymmetricSwap(goal, scope_kb_id)) |result| {
            engine.level_stats.l3_count += 1;
            engine.level_stats.l3_relation_queries += 1;
            return result;
        }
    }

    // Priority 5: Structural inheritance rules
    if (goal.isCompound()) {
        if (engine.tryInheritanceRules(goal, scope_kb_id)) |result| {
            engine.level_stats.l3_count += 1;
            return result;
        }
    }

    // Priority 6: General Prolog unification with backtracking
    const result = engine.generalQuery(goal, scope_kb_id, config);
    if (result.result_count > 0) {
        engine.level_stats.l2_count += 1;
    }
    return result;
}
```

---

## 5. Typed Relation Fast Path (Priority 1)

### 5.1 Detection

The fast path fires when the query goal is a compound term whose functor matches a known RelationType:

```zig
fn tryTypedRelationQuery(
    engine: *PrologEngine,
    goal: *Term,
    scope_kb_id: VdrId,
) ?QueryResult {
    // Extract functor atom ID from compound term
    const functor_id = goal.primary_id;
    const arity = @as(i16, @intCast(goal.secondary_aux));
    if (arity != 2) return null; // all relation types are binary (from, to)

    // Resolve functor to RelationType
    const rel_type = engine.resolveRelationType(functor_id) orelse return null;

    // Extract from and to arguments
    const args = engine.getCompoundArgs(goal);
    const from_term = &args[0];
    const to_term = &args[1];

    // Convert arguments to VdrId if they are ground (atoms or VDR values)
    // Variables remain null — meaning wildcard
    const from_id: ?VdrId = if (from_term.isVariable()) null else engine.termToVdrId(from_term);
    const to_id: ?VdrId = if (to_term.isVariable()) null else engine.termToVdrId(to_term);

    // Scan accessible KBs for matching typed relations
    return engine.scanTypedRelations(rel_type, from_id, to_id, from_term, to_term, scope_kb_id);
}
```

### 5.2 Scan

```zig
fn scanTypedRelations(
    engine: *PrologEngine,
    rel_type: RelationType,
    from_id: ?VdrId,
    to_id: ?VdrId,
    from_term: *Term,
    to_term: *Term,
    scope_kb_id: VdrId,
) ?QueryResult {
    var result = QueryResult{ .status = Status.ok() };
    const max_results = engine.config.max_results;

    // Allocate result bindings in scratch
    var bindings_buf = engine.scratch.allocSlice(Binding, @intCast(max_results)) orelse return null;
    var count: i32 = 0;

    const kbs = engine.getAccessibleKbs(scope_kb_id);

    for (kbs) |kb| {
        if (!kb.hasRelations()) continue;

        // O(1): check if this KB has any relations of this type
        if (kb.hasRelationIndex()) {
            const index = engine.getRelationIndex(kb);
            if (!index.hasType(rel_type)) continue;
        }

        // Get relations of this type from the KB
        const relations = engine.getRelationsForType(kb, rel_type);

        for (relations) |*rel| {
            // Filter by from_id if specified
            if (from_id) |fid| {
                if (!rel.from_id.eql(fid)) continue;
            }
            // Filter by to_id if specified
            if (to_id) |tid| {
                if (!rel.to_id.eql(tid)) continue;
            }

            // Match found. Build binding for the variable argument(s).
            if (from_term.isVariable()) {
                if (count < max_results) {
                    bindings_buf[@intCast(count)] = Binding{
                        .var_id = from_term.primary_id,
                        .bound_term_offset = engine.storeVdrIdAsTerm(rel.from_id),
                    };
                    count += 1;
                }
            }
            if (to_term.isVariable()) {
                if (count < max_results) {
                    bindings_buf[@intCast(count)] = Binding{
                        .var_id = to_term.primary_id,
                        .bound_term_offset = engine.storeVdrIdAsTerm(rel.to_id),
                    };
                    count += 1;
                }
            }
            // If both are ground, this is a boolean check — match found
            if (!from_term.isVariable() and !to_term.isVariable()) {
                result.result_count = 1;
                return result;
            }
        }
    }

    if (count == 0) return null; // no matches, let next priority try

    result.bindings = bindings_buf;
    result.binding_count = count;
    result.result_count = count;
    return result;
}
```

### 5.3 Cost

For a system with 50 accessible KBs and 2000 total typed relations of which 200 are `enables`:

- 50 `hasType()` checks = 50 i32 reads
- ~200 relation scans = 200 VdrId comparisons
- Total: sub-microsecond

---

## 6. Transitive Closure (Priority 2)

### 6.1 Detection and Execution

```zig
fn tryTransitiveClosure(
    engine: *PrologEngine,
    goal: *Term,
    scope_kb_id: VdrId,
) ?QueryResult {
    const functor_id = goal.primary_id;
    const arity = @as(i16, @intCast(goal.secondary_aux));
    if (arity != 2) return null;

    const rel_type = engine.resolveRelationType(functor_id) orelse return null;
    if (!rel_type.isTransitive()) return null;

    const args = engine.getCompoundArgs(goal);
    const from_term = &args[0];
    const to_term = &args[1];

    // Transitive closure needs at least one ground argument
    const from_id: ?VdrId = if (from_term.isVariable()) null else engine.termToVdrId(from_term);
    const to_id: ?VdrId = if (to_term.isVariable()) null else engine.termToVdrId(to_term);

    if (from_id == null and to_id == null) return null; // both variables, can't BFS

    // Forward closure: from_id is ground, find all reachable to_ids
    if (from_id != null and to_id == null) {
        return engine.forwardClosure(rel_type, from_id.?, to_term, scope_kb_id);
    }

    // Backward closure: to_id is ground, find all from_ids that reach it
    if (from_id == null and to_id != null) {
        // Use inverse if available, otherwise reverse-scan
        const inv = rel_type.inverse();
        if (inv != .unknown) {
            return engine.forwardClosure(inv, to_id.?, from_term, scope_kb_id);
        }
        return engine.backwardClosure(rel_type, to_id.?, from_term, scope_kb_id);
    }

    // Both ground: check if to_id is reachable from from_id
    return engine.reachabilityCheck(rel_type, from_id.?, to_id.?, scope_kb_id);
}
```

### 6.2 BFS Implementation

```zig
fn forwardClosure(
    engine: *PrologEngine,
    rel_type: RelationType,
    start: VdrId,
    bind_term: *Term,
    scope_kb_id: VdrId,
) ?QueryResult {
    const max_visited = engine.config.max_results * 4; // BFS can visit more than it returns
    const max_results = engine.config.max_results;

    // BFS working memory in scratch
    var visited = engine.scratch.allocSlice(VdrId, @intCast(max_visited)) orelse return null;
    var visited_count: i32 = 0;

    var frontier = engine.scratch.allocSlice(VdrId, @intCast(max_visited)) orelse return null;
    var frontier_count: i32 = 0;
    var next_frontier = engine.scratch.allocSlice(VdrId, @intCast(max_visited)) orelse return null;
    var next_count: i32 = 0;

    // Seed frontier with start
    frontier[0] = start;
    frontier_count = 1;

    const kbs = engine.getAccessibleKbs(scope_kb_id);

    while (frontier_count > 0) {
        next_count = 0;

        var fi: i32 = 0;
        while (fi < frontier_count) : (fi += 1) {
            const current = frontier[@intCast(fi)];

            // Skip if already visited
            if (engine.idInSlice(current, visited[0..@intCast(visited_count)])) continue;

            // Mark visited
            if (visited_count < max_visited) {
                visited[@intCast(visited_count)] = current;
                visited_count += 1;
            }

            // Find all direct edges from current
            for (kbs) |kb| {
                if (!kb.hasRelations()) continue;
                if (kb.hasRelationIndex()) {
                    const index = engine.getRelationIndex(kb);
                    if (!index.hasType(rel_type)) continue;
                }

                const relations = engine.getRelationsForType(kb, rel_type);
                for (relations) |*rel| {
                    if (!rel.from_id.eql(current)) continue;

                    // Add to_id to next frontier if not visited
                    if (!engine.idInSlice(rel.to_id, visited[0..@intCast(visited_count)])) {
                        if (next_count < max_visited) {
                            next_frontier[@intCast(next_count)] = rel.to_id;
                            next_count += 1;
                        }
                    }
                }
            }
        }

        // Swap frontiers
        const tmp = frontier;
        frontier = next_frontier;
        next_frontier = tmp;
        frontier_count = next_count;
    }

    // Build result: all visited nodes except start are transitive targets
    if (visited_count <= 1) return null; // only start itself

    var bindings_buf = engine.scratch.allocSlice(Binding, @intCast(max_results)) orelse return null;
    var count: i32 = 0;

    // Skip index 0 (start itself)
    var vi: i32 = 1;
    while (vi < visited_count and count < max_results) : (vi += 1) {
        bindings_buf[@intCast(count)] = Binding{
            .var_id = bind_term.primary_id,
            .bound_term_offset = engine.storeVdrIdAsTerm(visited[@intCast(vi)]),
        };
        count += 1;
    }

    return QueryResult{
        .bindings = bindings_buf,
        .binding_count = count,
        .result_count = count,
        .depth_reached = @intCast(visited_count),
        .status = Status.ok(),
    };
}
```

### 6.3 Reachability Check

```zig
fn reachabilityCheck(
    engine: *PrologEngine,
    rel_type: RelationType,
    from: VdrId,
    to: VdrId,
    scope_kb_id: VdrId,
) ?QueryResult {
    // Same BFS as forwardClosure but early-exit on finding target
    const max_visited = engine.config.max_results * 4;

    var visited = engine.scratch.allocSlice(VdrId, @intCast(max_visited)) orelse return null;
    var visited_count: i32 = 0;

    var frontier = engine.scratch.allocSlice(VdrId, @intCast(max_visited)) orelse return null;
    var frontier_count: i32 = 0;
    var next_frontier = engine.scratch.allocSlice(VdrId, @intCast(max_visited)) orelse return null;
    var next_count: i32 = 0;

    frontier[0] = from;
    frontier_count = 1;

    const kbs = engine.getAccessibleKbs(scope_kb_id);

    while (frontier_count > 0) {
        next_count = 0;

        var fi: i32 = 0;
        while (fi < frontier_count) : (fi += 1) {
            const current = frontier[@intCast(fi)];
            if (engine.idInSlice(current, visited[0..@intCast(visited_count)])) continue;

            if (visited_count < max_visited) {
                visited[@intCast(visited_count)] = current;
                visited_count += 1;
            }

            for (kbs) |kb| {
                if (!kb.hasRelations()) continue;
                if (kb.hasRelationIndex()) {
                    const index = engine.getRelationIndex(kb);
                    if (!index.hasType(rel_type)) continue;
                }

                const relations = engine.getRelationsForType(kb, rel_type);
                for (relations) |*rel| {
                    if (!rel.from_id.eql(current)) continue;

                    // Early exit: target found
                    if (rel.to_id.eql(to)) {
                        return QueryResult{
                            .result_count = 1,
                            .depth_reached = visited_count,
                            .status = Status.ok(),
                        };
                    }

                    if (!engine.idInSlice(rel.to_id, visited[0..@intCast(visited_count)])) {
                        if (next_count < max_visited) {
                            next_frontier[@intCast(next_count)] = rel.to_id;
                            next_count += 1;
                        }
                    }
                }
            }
        }

        const tmp = frontier;
        frontier = next_frontier;
        next_frontier = tmp;
        frontier_count = next_count;
    }

    return null; // not reachable
}
```

---

## 7. Inverse Lookup (Priority 3)

```zig
fn tryInverseLookup(
    engine: *PrologEngine,
    goal: *Term,
    scope_kb_id: VdrId,
) ?QueryResult {
    const functor_id = goal.primary_id;
    const rel_type = engine.resolveRelationType(functor_id) orelse return null;

    const inv = rel_type.inverse();
    if (inv == .unknown or inv == rel_type) return null; // no inverse or self-inverse (symmetric)

    // Rewrite query: swap from and to, change functor to inverse type
    const args = engine.getCompoundArgs(goal);
    const from_term = &args[0]; // original from
    const to_term = &args[1]; // original to

    // Query inverse(to, from) — arguments swapped
    const inv_from: ?VdrId = if (to_term.isVariable()) null else engine.termToVdrId(to_term);
    const inv_to: ?VdrId = if (from_term.isVariable()) null else engine.termToVdrId(from_term);

    // Scan for the inverse type with swapped arguments
    return engine.scanTypedRelations(inv, inv_from, inv_to, to_term, from_term, scope_kb_id);
}
```

Example: query `depends_on(X, physics_force)` rewrites to scan `enables(physics_force, X)`. One index serves both directions.

---

## 8. Symmetric Swap (Priority 4)

```zig
fn trySymmetricSwap(
    engine: *PrologEngine,
    goal: *Term,
    scope_kb_id: VdrId,
) ?QueryResult {
    const functor_id = goal.primary_id;
    const rel_type = engine.resolveRelationType(functor_id) orelse return null;

    if (!rel_type.isSymmetric()) return null;

    const args = engine.getCompoundArgs(goal);
    const from_term = &args[0];
    const to_term = &args[1];

    // Priority 1 already tried the forward direction.
    // Try the swapped direction: scan(rel_type, to, from)
    const swap_from: ?VdrId = if (to_term.isVariable()) null else engine.termToVdrId(to_term);
    const swap_to: ?VdrId = if (from_term.isVariable()) null else engine.termToVdrId(from_term);

    return engine.scanTypedRelations(rel_type, swap_from, swap_to, to_term, from_term, scope_kb_id);
}
```

Example: `prevents(X, deadlock)` finds no forward match, but `prevents(deadlock, X)` exists in the KB. Because prevents is symmetric, the swapped result is valid.

---

## 9. Structural Inheritance Rules (Priority 5)

### 9.1 Detection

Inheritance fires when the query type is `requires`, `prevents`, or `contains` and the subject entity has `specializes` or `instance_of` edges:

```zig
fn tryInheritanceRules(
    engine: *PrologEngine,
    goal: *Term,
    scope_kb_id: VdrId,
) ?QueryResult {
    const functor_id = goal.primary_id;
    const rel_type = engine.resolveRelationType(functor_id) orelse return null;

    // Inheritance applies to: requires, prevents, contains
    const inheritable = switch (rel_type) {
        .requires, .prevents, .contains => true,
        else => false,
    };
    if (!inheritable) return null;

    const args = engine.getCompoundArgs(goal);
    const from_term = &args[0];
    if (from_term.isVariable()) return null; // need a ground subject

    const subject_id = engine.termToVdrId(from_term) orelse return null;

    // Find all ancestors via specializes + instance_of transitive closure
    var ancestors = engine.scratch.allocSlice(VdrId, @intCast(engine.config.max_results * 2)) orelse return null;
    var ancestor_count: i32 = 0;

    // Collect specializes ancestors
    engine.collectAncestors(.specializes, subject_id, ancestors, &ancestor_count, scope_kb_id);

    // Collect instance_of ancestors
    engine.collectAncestors(.instance_of, subject_id, ancestors, &ancestor_count, scope_kb_id);

    if (ancestor_count == 0) return null;

    // For each ancestor, collect the inherited relation
    const to_term = &args[1];
    var result_bindings = engine.scratch.allocSlice(Binding, @intCast(engine.config.max_results)) orelse return null;
    var count: i32 = 0;

    var ai: i32 = 0;
    while (ai < ancestor_count) : (ai += 1) {
        const ancestor = ancestors[@intCast(ai)];

        // Query rel_type(ancestor, ?) directly
        const kbs = engine.getAccessibleKbs(scope_kb_id);
        for (kbs) |kb| {
            if (!kb.hasRelations()) continue;
            if (kb.hasRelationIndex()) {
                const index = engine.getRelationIndex(kb);
                if (!index.hasType(rel_type)) continue;
            }

            const relations = engine.getRelationsForType(kb, rel_type);
            for (relations) |*rel| {
                if (!rel.from_id.eql(ancestor)) continue;

                // Check to_id against to_term
                if (!to_term.isVariable()) {
                    const target = engine.termToVdrId(to_term) orelse continue;
                    if (!rel.to_id.eql(target)) continue;
                }

                if (to_term.isVariable() and count < engine.config.max_results) {
                    result_bindings[@intCast(count)] = Binding{
                        .var_id = to_term.primary_id,
                        .bound_term_offset = engine.storeVdrIdAsTerm(rel.to_id),
                    };
                    count += 1;
                } else if (!to_term.isVariable()) {
                    // Ground check — match found
                    return QueryResult{
                        .result_count = 1,
                        .status = Status.ok(),
                    };
                }
            }
        }
    }

    if (count == 0) return null;

    return QueryResult{
        .bindings = result_bindings,
        .binding_count = count,
        .result_count = count,
        .status = Status.ok(),
    };
}

fn collectAncestors(
    engine: *PrologEngine,
    rel_type: RelationType,
    start: VdrId,
    out: []VdrId,
    out_count: *i32,
    scope_kb_id: VdrId,
) void {
    // BFS over the given relation type from start, collecting all targets
    const kbs = engine.getAccessibleKbs(scope_kb_id);
    var frontier_buf = engine.scratch.allocSlice(VdrId, 256) orelse return;
    frontier_buf[0] = start;
    var frontier_count: i32 = 1;

    while (frontier_count > 0) {
        const current = frontier_buf[@intCast(frontier_count - 1)];
        frontier_count -= 1;

        for (kbs) |kb| {
            if (!kb.hasRelations()) continue;
            if (kb.hasRelationIndex()) {
                const index = engine.getRelationIndex(kb);
                if (!index.hasType(rel_type)) continue;
            }
            const relations = engine.getRelationsForType(kb, rel_type);
            for (relations) |*rel| {
                if (!rel.from_id.eql(current)) continue;
                if (engine.idInSlice(rel.to_id, out[0..@intCast(out_count.*)])) continue;

                if (out_count.* < out.len) {
                    out[@intCast(out_count.*)] = rel.to_id;
                    out_count.* += 1;
                }

                // Continue BFS from this ancestor (transitive)
                if (frontier_count < frontier_buf.len) {
                    frontier_buf[@intCast(frontier_count)] = rel.to_id;
                    frontier_count += 1;
                }
            }
        }
    }
}
```

### 9.2 What This Covers

The inheritance rules from the Knowledge Composition spec (Section 8.1) are implemented mechanically here:

```
requires(X, T) :- specializes(X, Y), requires(Y, T).
prevents(X, T) :- specializes(X, Y), prevents(Y, T).
contains(X, T) :- specializes(X, Y), contains(Y, T).
requires(X, T) :- instance_of(X, Y), requires(Y, T).
prevents(X, T) :- instance_of(X, Y), prevents(Y, T).
contains(X, T) :- instance_of(X, Y), contains(Y, T).
```

All six rules are implemented by `tryInheritanceRules` with two `collectAncestors` calls (one for `specializes`, one for `instance_of`) followed by a scan for the target relation type on each ancestor.

---

## 10. General Prolog Query (Priority 6)

### 10.1 Depth-First Search with Backtracking

When priorities 1-5 fail, the engine falls back to general Prolog resolution. This handles arbitrary compound terms, conjunctions, negation-as-failure, and rules with complex bodies.

```zig
fn generalQuery(
    engine: *PrologEngine,
    goal: *Term,
    scope_kb_id: VdrId,
    config: PrologConfig,
) QueryResult {
    var result = QueryResult{ .status = Status.ok() };
    const max_depth = config.max_depth;
    const max_bindings = config.max_bindings;
    const max_results = config.max_results;

    // Explicit search stack in scratch arena
    var stack = engine.scratch.allocSlice(SearchFrame, @intCast(max_depth)) orelse {
        return QueryResult{
            .status = Status.err(.memory, .arena_exhausted, 0),
        };
    };
    var stack_depth: i32 = 0;

    // Binding environment in scratch arena
    var bindings = engine.scratch.allocSlice(Binding, @intCast(max_bindings)) orelse {
        return QueryResult{
            .status = Status.err(.memory, .arena_exhausted, 0),
        };
    };
    var binding_count: i32 = 0;

    // Result collection in scratch arena
    var results = engine.scratch.allocSlice(Binding, @intCast(max_results)) orelse {
        return QueryResult{
            .status = Status.err(.memory, .arena_exhausted, 0),
        };
    };
    var result_count: i32 = 0;

    // Push initial goal
    stack[0] = SearchFrame{
        .goal = goal,
        .kb_id = scope_kb_id,
        .rule_index = 0,
        .binding_mark = 0,
    };
    stack_depth = 1;

    while (stack_depth > 0) {
        if (stack_depth > max_depth) {
            result.depth_exceeded = true;
            break;
        }

        var frame = &stack[@intCast(stack_depth - 1)];

        // Try to match frame.goal against rules in accessible KBs
        const match = engine.findNextMatch(
            frame.goal,
            frame.kb_id,
            frame.rule_index,
            bindings[0..@intCast(binding_count)],
        );

        if (match) |m| {
            // Record where we are for backtracking
            frame.rule_index = m.next_rule_index;
            const binding_before = binding_count;

            // Apply bindings from unification
            var bi: i32 = 0;
            while (bi < m.new_binding_count and binding_count < max_bindings) : (bi += 1) {
                bindings[@intCast(binding_count)] = m.new_bindings[@intCast(bi)];
                binding_count += 1;
            }

            if (m.rule.body_count == 0) {
                // Fact or rule with empty body — goal satisfied
                if (stack_depth == 1) {
                    // Top-level goal satisfied — collect result
                    if (result_count < max_results) {
                        engine.collectResultBindings(
                            goal,
                            bindings[0..@intCast(binding_count)],
                            results,
                            &result_count,
                        );
                    }
                    // Backtrack to find more solutions
                    binding_count = binding_before;
                } else {
                    // Sub-goal satisfied — pop and continue parent
                    stack_depth -= 1;
                }
            } else {
                // Rule has body — push sub-goals
                var gi: i16 = 0;
                while (gi < m.rule.body_count and stack_depth < max_depth) : (gi += 1) {
                    const sub_goal = engine.getBodyTerm(m.rule, gi);
                    const instantiated = engine.instantiate(sub_goal, bindings[0..@intCast(binding_count)]);
                    stack[@intCast(stack_depth)] = SearchFrame{
                        .goal = instantiated,
                        .kb_id = frame.kb_id,
                        .rule_index = 0,
                        .binding_mark = binding_count,
                    };
                    stack_depth += 1;
                }
            }
        } else {
            // No more matches for this goal — backtrack
            binding_count = frame.binding_mark;
            stack_depth -= 1;
        }
    }

    result.bindings = results;
    result.binding_count = result_count;
    result.result_count = result_count;
    result.depth_reached = stack_depth;
    return result;
}
```

### 10.2 Search Frame

```zig
const SearchFrame = struct {
    /// the goal term to resolve at this depth
    goal: *Term,
    /// KB scope for this frame
    kb_id: VdrId = .{},
    /// index into the matching rules — incremented on backtrack to try next rule
    rule_index: i32 = 0,
    /// binding stack mark for rollback on backtrack
    binding_mark: i32 = 0,
};
```

### 10.3 Match Finding

```zig
const MatchResult = struct {
    rule: *Rule,
    next_rule_index: i32,
    new_bindings: []Binding,
    new_binding_count: i32,
};

fn findNextMatch(
    engine: *PrologEngine,
    goal: *Term,
    scope_kb_id: VdrId,
    start_index: i32,
    current_bindings: []Binding,
) ?MatchResult {
    const kbs = engine.getAccessibleKbs(scope_kb_id);
    var global_rule_index: i32 = 0;

    for (kbs) |kb| {
        if (kb.rules_count == 0) continue;

        const rules = engine.getRuleSlice(kb);

        for (rules, 0..) |*rule, ri| {
            if (global_rule_index < start_index) {
                global_rule_index += 1;
                continue;
            }

            // Check if rule head unifies with goal
            const head = engine.getTerm(rule.head);

            // Allocate temporary bindings for this unification attempt
            var temp_bindings = engine.scratch.allocSlice(Binding, 64) orelse return null;
            var temp_count: i32 = 0;

            const goal_instantiated = engine.instantiate(goal, current_bindings);

            if (engine.unifyTerms(goal_instantiated, head, temp_bindings, &temp_count)) {
                rule.fire_count += 1;

                return MatchResult{
                    .rule = rule,
                    .next_rule_index = global_rule_index + 1,
                    .new_bindings = temp_bindings,
                    .new_binding_count = temp_count,
                };
            }

            global_rule_index += 1;
        }
    }

    return null;
}
```

---

## 11. Unification

### 11.1 Core Algorithm

```zig
pub fn unifyTerms(
    engine: *PrologEngine,
    a: *Term,
    b: *Term,
    bindings: []Binding,
    count: *i32,
) bool {
    // Variable-anything: bind
    if (a.isVariable()) {
        return engine.bindVariable(a.primary_id, b, bindings, count);
    }
    if (b.isVariable()) {
        return engine.bindVariable(b.primary_id, a, bindings, count);
    }

    // Atom-atom: ID match
    if (a.isAtom() and b.isAtom()) {
        return a.primary_id == b.primary_id;
    }

    // Integer-integer: value match
    if (a.type == .integer and b.type == .integer) {
        return a.primary_id == b.primary_id;
    }

    // VDR-VDR: all three Q16 fields must match exactly
    if (a.type == .vdr and b.type == .vdr) {
        return Q16.eql(a.vdr_value, b.vdr_value);
    }

    // Compound-compound: functor match + recursive arg unification
    if (a.isCompound() and b.isCompound()) {
        if (a.primary_id != b.primary_id) return false; // different functors
        if (a.secondary_aux != b.secondary_aux) return false; // different arity

        const a_args = engine.getCompoundArgs(a);
        const b_args = engine.getCompoundArgs(b);

        var i: i32 = 0;
        while (i < a.secondary_aux) : (i += 1) {
            if (!engine.unifyTerms(&a_args[@intCast(i)], &b_args[@intCast(i)], bindings, count)) {
                return false;
            }
        }
        return true;
    }

    // List-list: head + tail recursive unification
    if (a.type == .list and b.type == .list) {
        const a_head = engine.getTerm(a.secondary_offset);
        const b_head = engine.getTerm(b.secondary_offset);
        if (!engine.unifyTerms(a_head, b_head, bindings, count)) return false;

        const a_tail = engine.getTerm(a.secondary_aux);
        const b_tail = engine.getTerm(b.secondary_aux);
        return engine.unifyTerms(a_tail, b_tail, bindings, count);
    }

    // Text-text: offset and length match (same text in text store)
    if (a.type == .text and b.type == .text) {
        return a.secondary_offset == b.secondary_offset and
            a.secondary_aux == b.secondary_aux;
    }

    // Type mismatch
    return false;
}
```

### 11.2 Variable Binding

```zig
fn bindVariable(
    engine: *PrologEngine,
    var_id: i32,
    term: *Term,
    bindings: []Binding,
    count: *i32,
) bool {
    // Check if already bound
    var i: i32 = 0;
    while (i < count.*) : (i += 1) {
        if (bindings[@intCast(i)].var_id == var_id) {
            // Already bound — unify bound value with new term
            const bound = engine.getTerm(bindings[@intCast(i)].bound_term_offset);
            return engine.unifyTerms(bound, term, bindings, count);
        }
    }

    // Not bound — create new binding
    if (count.* >= bindings.len) return false; // binding overflow
    bindings[@intCast(count.*)] = Binding{
        .var_id = var_id,
        .bound_term_offset = engine.storeTermInScratch(term),
    };
    count.* += 1;
    return true;
}
```

### 11.3 Instantiation

Replaces variables in a term with their bound values:

```zig
fn instantiate(
    engine: *PrologEngine,
    term: *Term,
    bindings: []Binding,
) *Term {
    if (term.isVariable()) {
        for (bindings) |binding| {
            if (binding.var_id == term.primary_id) {
                return engine.getTerm(binding.bound_term_offset);
            }
        }
        return term; // unbound variable stays as-is
    }

    if (term.isCompound()) {
        // Recursively instantiate arguments
        const args = engine.getCompoundArgs(term);
        var new_args = engine.scratch.allocSlice(Term, @intCast(term.secondary_aux)) orelse return term;

        var i: i32 = 0;
        while (i < term.secondary_aux) : (i += 1) {
            new_args[@intCast(i)] = engine.instantiate(&args[@intCast(i)], bindings).*;
        }

        // Build new compound with instantiated args
        var new_term = engine.scratch.allocTyped(Term) orelse return term;
        new_term.* = term.*;
        new_term.secondary_offset = engine.storeTermSliceInScratch(new_args);
        return new_term;
    }

    // Atoms, integers, VDR values: no variables to substitute
    return term;
}
```

---

## 12. Fire and Commit

Scans rules against facts, fires all satisfied rules, asserts derived facts:

```zig
pub fn fireAndCommit(
    engine: *PrologEngine,
    kb_id: VdrId,
) FireResult {
    var result = FireResult{ .status = Status.ok() };

    const kb = engine.store.resolveKb(kb_id) orelse {
        result.status = Status.err(.kb, .kb_not_found, @intCast(kb_id.v));
        return result;
    };

    if (kb.isFrozen()) return result; // frozen KBs don't fire rules
    if (kb.rules_count == 0) return result;

    const rules = engine.getRuleSlice(kb);
    const now = @as(i32, @intCast(std.time.timestamp()));

    for (rules) |*rule| {
        if (rule.body_count == 0) continue; // unconditional facts, already asserted

        // Try to satisfy the body
        var bindings = engine.scratch.allocSlice(Binding, 64) orelse continue;
        var binding_count: i32 = 0;

        var body_satisfied = true;
        var bi: i16 = 0;
        while (bi < rule.body_count) : (bi += 1) {
            const body_term = engine.getBodyTerm(rule, bi);
            const instantiated = engine.instantiate(body_term, bindings[0..@intCast(binding_count)]);

            // Try to resolve this body term
            const sub_result = engine.query(instantiated, kb_id, engine.config);

            if (sub_result.result_count == 0) {
                body_satisfied = false;
                break;
            }

            // Add bindings from sub-query
            var si: i32 = 0;
            while (si < sub_result.binding_count and binding_count < 64) : (si += 1) {
                bindings[@intCast(binding_count)] = sub_result.bindings[@intCast(si)];
                binding_count += 1;
            }
        }

        if (body_satisfied and rule.action_count > 0) {
            // Fire: execute actions with current bindings
            var ai: i16 = 0;
            while (ai < rule.action_count) : (ai += 1) {
                const action = engine.getAction(rule, ai);
                engine.executeAction(action, bindings[0..@intCast(binding_count)], kb, now);
            }

            rule.fire_count += 1;
            rule.last_fired = now;
            rule.success_count += 1;
            result.firing_count += 1;
        }
    }

    return result;
}

fn executeAction(
    engine: *PrologEngine,
    action: *PrologAction,
    bindings: []Binding,
    default_kb: *KB,
    now: i32,
) void {
    var fact = action.fact;

    // Instantiate any variables in the fact's value
    // (the action may reference variables from the rule body)

    // Determine target KB
    const target_kb = if (action.target_kb_id.isNone())
        default_kb
    else
        engine.store.resolveKb(action.target_kb_id) orelse default_kb;

    if (target_kb.isFrozen()) return;

    // Set provenance
    fact.provenance = Provenance.derived(
        -1, // rule ID could be stored here
        target_kb.id,
        target_kb.facts_count,
        Q16.one(), // prolog_derivation confidence = 1/1
        now,
    );

    if (action.is_assert) {
        engine.store.assertFact(target_kb, fact, engine.global_arena) catch return;
    } else {
        engine.store.retractFact(target_kb, action.target_slot_id) catch return;
    }
}
```

---

## 13. Scope Resolution

### 13.1 Session-First, Then Global

```zig
fn getAccessibleKbs(
    engine: *PrologEngine,
    scope_kb_id: VdrId,
) []const *KB {
    var kbs_buf = engine.scratch.allocSlice(*KB, 256) orelse return &.{};
    var count: i32 = 0;

    // If scope is specified, start there and walk up
    if (!scope_kb_id.isNone()) {
        // Session tree first (negative IDs)
        if (scope_kb_id.isEphemeral()) {
            engine.collectKbChain(scope_kb_id, kbs_buf, &count);
            // Cross to global at session's junction point
            const junction = engine.session.kb_root_id;
            engine.collectKbChain(junction, kbs_buf, &count);
        } else {
            engine.collectKbChain(scope_kb_id, kbs_buf, &count);
        }
    } else {
        // No scope — walk all accessible KBs
        // Session tree
        engine.collectKbChain(engine.session.ephemeral_root_id, kbs_buf, &count);
        // Global tree from root
        engine.collectKbChain(VdrId.ROOT, kbs_buf, &count);
    }

    return kbs_buf[0..@intCast(count)];
}

fn collectKbChain(
    engine: *PrologEngine,
    start_id: VdrId,
    out: []*KB,
    count: *i32,
) void {
    var current_id = start_id;
    while (!current_id.isNone()) {
        const kb = engine.store.resolveKb(current_id) orelse break;

        // Check grant access
        if (!engine.hasAccess(kb)) {
            current_id = kb.parent_id;
            continue;
        }

        if (count.* < out.len) {
            out[@intCast(count.*)] = kb;
            count.* += 1;
        }

        // Also collect children
        engine.collectChildren(kb, out, count);

        current_id = kb.parent_id;
    }
}
```

---

## 14. Helper Functions

### 14.1 Atom-to-RelationType Resolution

```zig
fn resolveRelationType(engine: *PrologEngine, atom_id: i32) ?RelationType {
    // Check cache first
    if (engine.atom_rel_cache.lookup(atom_id)) |cached| {
        return cached;
    }

    // Check system-defined types
    for (RELATION_KEYWORDS) |kw| {
        if (engine.store.atomId(kw.name) == atom_id) {
            engine.atom_rel_cache.insert(atom_id, kw.rel_type);
            return kw.rel_type;
        }
    }

    // Check domain-registered types
    const rel_types_kb = engine.store.resolveKb(SEED.RELATION_TYPES) orelse return null;
    if (rel_types_kb.hasDomainRelDefs()) {
        const defs = engine.getDomainRelDefs(rel_types_kb);
        for (defs) |*def| {
            const name = engine.getTextSlice(def.name_offset, def.name_length);
            if (engine.store.atomId(name) == atom_id) {
                const rel_type: RelationType = @enumFromInt(def.slot);
                engine.atom_rel_cache.insert(atom_id, rel_type);
                return rel_type;
            }
        }
    }

    return null;
}
```

### 14.2 Relation Array Access

```zig
fn getRelationsForType(
    engine: *PrologEngine,
    kb: *KB,
    rel_type: RelationType,
) []TypedRelation {
    if (!kb.hasRelations()) return &.{};

    const all_relations = engine.getRelationSlice(kb);
    const type_slot = @intFromEnum(rel_type);

    // If index exists, use grouped offset for this type
    if (kb.hasRelationIndex()) {
        const index = engine.getRelationIndex(kb);
        if (type_slot < 0 or type_slot >= RELATION_TYPE_SLOTS) return &.{};
        const count = index.by_type_counts[@intCast(type_slot)];
        if (count == 0) return &.{};

        // Relations are grouped by type in contiguous blocks
        // Calculate offset into the grouped array
        var offset: i32 = 0;
        var s: i32 = 0;
        while (s < type_slot) : (s += 1) {
            offset += index.by_type_counts[@intCast(s)];
        }
        return all_relations[@intCast(offset)..@intCast(offset + count)];
    }

    // No index — linear scan filtering by type
    var filtered = engine.scratch.allocSlice(TypedRelation, @intCast(kb.relations_count)) orelse return &.{};
    var count: i32 = 0;
    for (all_relations) |*rel| {
        if (rel.rel_type == rel_type) {
            if (count < kb.relations_count) {
                filtered[@intCast(count)] = rel.*;
                count += 1;
            }
        }
    }
    return filtered[0..@intCast(count)];
}
```

### 14.3 VdrId Membership Check

```zig
fn idInSlice(engine: *PrologEngine, id: VdrId, slice: []VdrId) bool {
    _ = engine;
    for (slice) |item| {
        if (item.eql(id)) return true;
    }
    return false;
}
```

### 14.4 Term Storage in Scratch

```zig
fn storeVdrIdAsTerm(engine: *PrologEngine, id: VdrId) i32 {
    const term = engine.scratch.allocTyped(Term) orelse return -1;
    term.* = Term.atom(@intCast(id.v)); // store VdrId as atom with id as primary_id
    const offset = @intFromPtr(term) - @intFromPtr(engine.scratch.base);
    return @intCast(offset);
}

fn storeTermInScratch(engine: *PrologEngine, term: *Term) i32 {
    const copy = engine.scratch.allocTyped(Term) orelse return -1;
    copy.* = term.*;
    const offset = @intFromPtr(copy) - @intFromPtr(engine.scratch.base);
    return @intCast(offset);
}

fn storeTermSliceInScratch(engine: *PrologEngine, terms: []Term) i32 {
    const copy = engine.scratch.allocSlice(Term, terms.len) orelse return -1;
    @memcpy(copy, terms);
    const offset = @intFromPtr(copy.ptr) - @intFromPtr(engine.scratch.base);
    return @intCast(offset);
}
```

---

## 15. Confidence Propagation

### 15.1 Chain Rule

When deriving a fact from multiple inputs, confidence is the minimum:

```zig
fn chainConfidence(inputs: []const Provenance) Q16 {
    if (inputs.len == 0) return Q16.zero();
    var min_conf = inputs[0].confidence;
    for (inputs[1..]) |prov| {
        if (Q16.compare(prov.confidence, min_conf) < 0) {
            min_conf = prov.confidence;
        }
    }
    return min_conf;
}
```

### 15.2 Parallel Agreement

When multiple independent sources agree, confidence is the maximum:

```zig
fn parallelConfidence(sources: []const Provenance) Q16 {
    if (sources.len == 0) return Q16.zero();
    var max_conf = sources[0].confidence;
    for (sources[1..]) |prov| {
        if (Q16.compare(prov.confidence, max_conf) > 0) {
            max_conf = prov.confidence;
        }
    }
    return max_conf;
}
```

### 15.3 Contradiction

When sources disagree, confidence drops to zero:

```zig
fn contradictionConfidence() Q16 {
    return Q16.zero();
}
```

---

## 16. RelationIndex Rebuild

```zig
pub fn rebuildRelationIndex(
    kb: *KB,
    arena: *Arena,
) void {
    if (!kb.hasRelations() or kb.relations_count == 0) return;

    // Allocate or reuse index
    var index: *RelationIndex = undefined;
    if (kb.hasRelationIndex()) {
        index = getRelationIndex(kb, arena);
    } else {
        index = arena.allocTyped(RelationIndex) orelse return;
        kb.relation_index_offset = arenaOffset(arena, @ptrCast(index));
    }

    // Zero all counts
    @memset(&index.by_type_counts, 0);
    index.total_relations = kb.relations_count;

    // Count per type
    const relations = getRelationSlice(kb, arena);
    for (relations) |*rel| {
        const slot = @intFromEnum(rel.rel_type);
        if (slot >= 0 and slot < RELATION_TYPE_SLOTS) {
            index.by_type_counts[@intCast(slot)] += 1;
        }
    }

    // Sort relations by type for contiguous grouping
    // Simple counting sort: we know the counts, place each relation in its group
    var sorted = arena.allocSlice(TypedRelation, @intCast(kb.relations_count)) orelse return;

    // Compute group offsets (prefix sum of counts)
    var offsets: [RELATION_TYPE_SLOTS]i32 = [_]i32{0} ** RELATION_TYPE_SLOTS;
    var running: i32 = 0;
    for (0..RELATION_TYPE_SLOTS) |s| {
        offsets[s] = running;
        running += index.by_type_counts[s];
    }

    // Place each relation into its group
    var cursors: [RELATION_TYPE_SLOTS]i32 = offsets;
    for (relations) |*rel| {
        const slot = @intFromEnum(rel.rel_type);
        if (slot >= 0 and slot < RELATION_TYPE_SLOTS) {
            const pos = cursors[@intCast(slot)];
            sorted[@intCast(pos)] = rel.*;
            cursors[@intCast(slot)] += 1;
        }
    }

    // Copy sorted back over original relations array
    @memcpy(relations, sorted);

    index.last_rebuilt = @intCast(std.time.timestamp());
}
```

---

## 17. Domain Relation Type Resolution for Queries

When the Prolog engine encounters a domain-registered relation type, it needs the same structural properties that system types have:

```zig
fn getDomainRelationProperties(
    engine: *PrologEngine,
    rel_type: RelationType,
) struct { is_transitive: bool, is_symmetric: bool, inverse: RelationType } {
    if (rel_type.isSystemDefined()) {
        return .{
            .is_transitive = rel_type.isTransitive(),
            .is_symmetric = rel_type.isSymmetric(),
            .inverse = rel_type.inverse(),
        };
    }

    if (!rel_type.isDomain()) {
        return .{ .is_transitive = false, .is_symmetric = false, .inverse = .unknown };
    }

    // Look up DomainRelationDef
    const rel_types_kb = engine.store.resolveKb(SEED.RELATION_TYPES) orelse
        return .{ .is_transitive = false, .is_symmetric = false, .inverse = .unknown };

    if (rel_types_kb.hasDomainRelDefs()) {
        const defs = engine.getDomainRelDefs(rel_types_kb);
        for (defs) |*def| {
            if (def.slot == @intFromEnum(rel_type)) {
                return .{
                    .is_transitive = def.is_transitive,
                    .is_symmetric = def.is_symmetric,
                    .inverse = if (def.inverse_slot >= 0) @enumFromInt(def.inverse_slot) else .unknown,
                };
            }
        }
    }

    return .{ .is_transitive = false, .is_symmetric = false, .inverse = .unknown };
}
```

This means the priority chain (transitive closure, inverse lookup, symmetric swap) works identically for domain types as for system types — the properties are just looked up at runtime instead of compile-time.

---

## 18. New and Modified Structs

### New: PrologEngine

```zig
/// The Prolog engine instance. One per session, holds no mutable state between queries.
/// All per-query state lives in scratch arena allocations.
pub const PrologEngine = struct {
    /// KB store for fact/rule/relation access (shared, read-only for global)
    store: *KbStore = undefined,
    /// per-core scratch arena for all working memory
    scratch: *Arena = undefined,
    /// session for scope resolution
    session: *Session = undefined,
    /// global arena for read-only access
    global_arena: *Arena = undefined,
    /// atom-to-RelationType cache
    atom_rel_cache: *AtomRelTypeCache = undefined,
    /// statistics tracking (written per-query)
    level_stats: *LevelStats = undefined,
    /// config limits (max_depth, max_bindings, max_results)
    config: PrologConfig = .{},
};
```

### New: SearchFrame

```zig
/// A frame on the explicit search stack for depth-first Prolog resolution.
/// Lives in per-core scratch. Destroyed on query completion.
pub const SearchFrame = struct {
    /// the goal term to resolve at this depth
    goal: *Term = undefined,
    /// KB scope for rule search at this frame
    kb_id: VdrId = .{},
    /// index into matching rules — incremented on backtrack to try next candidate
    rule_index: i32 = 0,
    /// binding stack mark for rollback on backtrack
    binding_mark: i32 = 0,
};
```

### New: MatchResult

```zig
/// Result of finding a rule whose head unifies with the current goal.
/// Ephemeral — used within the search loop, not stored.
pub const MatchResult = struct {
    /// the matched rule
    rule: *Rule = undefined,
    /// where to resume searching on backtrack (next rule after this one)
    next_rule_index: i32 = 0,
    /// bindings produced by the unification
    new_bindings: []Binding = &.{},
    /// count of new bindings
    new_binding_count: i32 = 0,
};
```

### Modified: RelationType — add instance_of

The Knowledge Composition spec uses `instance_of` extensively for inheritance. This needs a system-defined slot. Adding at slot 20 (first available after the original 0-19):

```zig
pub const RelationType = enum(i16) {
    // existing 0-19 ...
    instance_of = 20,  // X is a specific instance of type Y
    scoped_to = 21,    // X is visible/valid within scope Y
    flows_to = 22,     // X sends data/control/energy to Y
    transforms_to = 23, // X becomes Y through some process
    derived_from = 24,  // X was produced from Y
    composed_of = 25,   // X is built from Y (structural)
    // ... remaining system slots 26-63 reserved
    // domain slots 64-127 unchanged
    unknown = -1,
};
```

The `inverse()`, `isTransitive()`, and `isSymmetric()` methods need corresponding entries:

- `instance_of`: not transitive (A instance_of B, B instance_of C does NOT mean A instance_of C), not symmetric, inverse = unknown
- `scoped_to`: transitive (scoped to inner means scoped to outer), not symmetric, inverse = unknown
- `flows_to`: transitive, not symmetric, inverse = unknown
- `transforms_to`: transitive, not symmetric, inverse = unknown
- `derived_from`: transitive, not symmetric, inverse = unknown
- `composed_of`: not transitive (composition is not recursive by default — use `contains` for recursive), not symmetric, inverse = unknown

### Modified: PrologConfig — add inheritance depth limit

```zig
pub const PrologConfig = struct {
    max_depth: i32 = 100,
    max_bindings: i32 = 1000,
    max_results: i32 = 100,
    /// maximum ancestor chain depth for inheritance rules
    /// prevents runaway specializes/instance_of chains
    max_inheritance_depth: i32 = 32,
};
```

### Modified: QueryResult — add resolution metadata

```zig
pub const QueryResult = struct {
    bindings: []Binding = &.{},
    binding_count: i32 = 0,
    result_count: i32 = 0,
    depth_reached: i32 = 0,
    depth_exceeded: bool = false,
    status: Status = .{},
    /// which priority level resolved this query (for statistics)
    resolution_priority: i8 = 6, // default = general Prolog (priority 6)
};
```
