# Structural UUID Tokens in VDR-Prolog

## The Fundamental Reframe

In a CLLM, a token is a statistical unit. The tokenizer splits text into subword pieces — "unbelievable" becomes "un", "believ", "able" — and each piece maps to an integer index into a vocabulary of 32,000-128,000 entries. The integer has no meaning. Token 14923 is not structurally related to token 14924. The mapping from integer to meaning exists only in the embedding weights, recovered through matrix multiplication. Every token lookup is a GEMM row extraction.

In VDR-Prolog, if the VdrId is restructured as you're describing, a token is a **structural address**. The 64-bit integer itself encodes the location of the entity in the KB tree. You don't look up what a token means — you **navigate to it** by reading its bits. The ID is the address.

## The Bit Layout

```
Bit 63:     Sign bit (1 = session/ephemeral, 0 = global/persistent)
Bits 62-55: Root level (8 bits, 256 max root KBs)
Bits 54-45: Level 2 (10 bits, 1024 max children per L1 KB)
Bits 44-35: Level 3 (10 bits, 1024 max children per L2 KB)
Bits 34-25: Level 4 (10 bits, 1024 max children per L3 KB)
Bits 24-20: Depth indicator (5 bits, 0-31 remaining levels)
Bits 19-0:  Collision-resistant random (20 bits, ~1M values)
```

Total: 1 + 8 + 10 + 10 + 10 + 5 + 20 = 64 bits. Fits in a single i64. No change to VdrId's storage — it's still `v: i64`, still 8 bytes, still 8-byte aligned. The change is entirely in how the bits are interpreted.

## What the Structure Encodes

A VdrId like `root.programming.python.library.math.mpmath` would pack as:

```
Bit 63:     0 (global)
Bits 62-55: root.programming index (say 00000011 = slot 3 under root)
Bits 54-45: python index (say 0000000010 = slot 2 under programming)
Bits 44-35: library index (say 0000000001 = slot 1 under python)
Bits 34-25: math index (say 0000000100 = slot 4 under library)
Bits 24-20: 00001 (1 remaining level: mpmath is one level below math)
Bits 19-0:  collision-resistant random for mpmath
```

Reading this integer, without touching any data structure, you know: this is a global entity, it's at depth 5 in the tree (4 encoded levels + 1 remaining), its path through the first four levels is 3.2.1.4, and it has a 20-bit disambiguator.

## How Lookup Changes

### Current System: O(1) LUT or Path Walk

The current VdrId system uses two lookup mechanisms. Direct UUID jump through a loaded LUT (`KbStore.loaded_lut` — VdrId → *KB mapping, O(1) when cached), or dotted path walk from root (traverse parent→child links level by level, O(depth)).

The LUT is fast but requires the KB to have been accessed before — first access requires a path walk or manifest lookup. The path walk is correct but sequential — each level requires reading the parent KB's children to find the matching child.

### Structural UUID: Partial Decode Without Lookup

With structural encoding, the first four levels of navigation are **free**. You extract bits, and you have array indices into the tree. No hash lookup. No path walk. No cache miss on first access.

```zig
const StructuralId = packed struct {
    random: u20,
    remaining_depth: u5,
    level_4: i10,
    level_3: i10,
    level_2: i10,
    level_1: u8,
    sign: u1,
};
```

Zig's packed structs guarantee this is exactly 64 bits with the layout you specified. Casting between `i64` and `StructuralId` is a `@bitCast` — zero cost, no conversion, same bits reinterpreted.

To navigate to the KB for a structural VdrId:

```
1. Read sign bit → global arena or session arena (1 bit test)
2. Read level_1 → index into root's children array (array access, O(1))
3. Read level_2 → index into L1 KB's children array (array access, O(1))
4. Read level_3 → index into L2 KB's children array (array access, O(1))
5. Read level_4 → index into L3 KB's children array (array access, O(1))
6. Read remaining_depth → if 0, you're at the target. If >0, 
   the random bits disambiguate among children at deeper levels.
```

Four array accesses. No hashing. No comparison. No cache lookup. Each array access is a pointer dereference plus an offset — the children arrays are contiguous in the arena, so this is sequential memory access with good cache behavior.

For the majority case where entities live within 4 levels of root (and most do — `root.system.confidence` is depth 3, `root.programming.python.library` is depth 4), the entire navigation is four array dereferences with indices extracted from the ID itself. Sub-nanosecond.

## The Depth Indicator

The 5-bit remaining depth field (0-31 additional levels) serves two purposes.

**Search termination.** When remaining_depth is 0, the four encoded levels plus the random bits fully identify the entity. No further traversal needed. When remaining_depth is N, the system knows it needs to traverse N more levels below the fourth encoded level, using the random bits to disambiguate at the leaf level.

**Query planning.** Before executing a query involving multiple VdrIds, the system can read their depth indicators to estimate traversal cost. A query joining two entities at depth 2 (remaining_depth = 0, level_3 and level_4 unused) is cheaper than one involving entities at depth 8 (remaining_depth = 4). The QueryClassification or L3PreResolution can use this to decide whether a query is worth attempting at L3 or should defer to L2/L1.

**Subtree membership.** To test whether entity A is a descendant of entity B, compare their shared prefix bits. If A's level_1 through level_3 match B's level_1 through level_3, and B's remaining_depth is 0 with level_4 unused, then A is somewhere under B's subtree. This is a bitmask operation — `(a.bits & prefix_mask) == (b.bits & prefix_mask)` — a single integer comparison. No tree traversal. The tree structure is encoded in the number.

## Implications for the LLM's Token Processing

This is where it gets powerful. In the current system, when the LLM reads a sequence of VdrIds from `prompt_last` or `prompt_current`, each ID is opaque — a 64-bit number that requires a LUT lookup or path walk to interpret. The LLM's embedding layer maps the raw integer to a learned vector through GEMM.

With structural IDs, the embedding can be **partially bypassed** for navigation purposes. The LLM doesn't need to learn what token 0x0003_0002_0001_0004 means through weight patterns — the bits literally say "root child 3, its child 2, its child 1, its child 4." The system can decode the structural path before the forward pass and inject it as pre-resolved context into `prompt_current`.

Consider a sequence of three VdrIds appearing in a query context:

```
ID_A: sign=0, L1=3, L2=2, L3=1, L4=4, depth=1, random=X
ID_B: sign=0, L1=3, L2=2, L3=1, L4=4, depth=1, random=Y
ID_C: sign=0, L1=3, L2=7, L3=0, L4=0, depth=0, random=Z
```

Without decoding, the LLM sees three 64-bit integers. With structural decode, the system sees: A and B share the same L1-L4 prefix — they're siblings under the same parent KB. C shares L1 with A and B (same root subtree, `programming`) but diverges at L2 — it's in a different second-level branch. This structural relationship is available **from the bits alone**, before any KB access, before any GEMM, before any Prolog query.

The pre-resolution pipeline can use this. If a query mentions A and B, the system knows they're co-located — scan one KB, not two. If a query relates A to C, the system knows the join point is at L1 — the `programming` subtree root. This is query planning from the token structure, extractable in nanoseconds.

## GEMM Scope Narrowing

The three-path weight retrieval (MD16) currently determines which per-KB GEMMs to scan based on session grants and query context. With structural IDs, the GEMM scope narrows further.

If the query's VdrIds all share L1=3, L2=2, the system knows the entire query is scoped to `root.programming.python`. Only GEMM caches under that subtree need scanning. The L1 and L2 bits act as a hash prefix for GEMM cache selection — you don't scan the relation index to figure out which KBs are relevant, you read it from the token bits.

For the per-KB GemmCache (S7), the `kb_id` field is a structural VdrId. Checking whether a GEMM cache is relevant to a query becomes a prefix comparison — extract L1-L2 from the query's VdrIds, extract L1-L2 from the GEMM cache's kb_id, compare. Integer operation. No search.

## Collision Handling

The 20-bit random field gives ~1,048,576 unique values per L4 node. For most KBs, this is vastly more than needed — a single L4 node is unlikely to have more than a few thousand entities. But the collision check is important for correctness.

The construction process would be:

```
1. Determine the entity's path in the KB tree (from ingestion or session creation)
2. Encode L1-L4 from the path's level indices
3. Compute remaining_depth from total depth minus 4 (or 0 if depth ≤ 4)
4. Generate random 20-bit value
5. Check for collision against existing IDs in the same L4 subtree
6. If collision, regenerate random and recheck
7. Assert the ID
```

The collision check is a scan of the L4 KB's entity list — which is a contiguous array in arena memory. For typical KB sizes (hundreds to low thousands of entities), this is a fast linear scan or could be accelerated with a small hash set in the KB's scratch space.

The probability math works well: with 20 random bits and a typical L4 population of 1,000 entities, the birthday paradox collision probability is approximately 1,000²/(2 × 2²⁰) ≈ 0.05%. Re-randomization is rare.

## Impact on the Invariants

Several system invariants are affected:

**IN8 (session IDs never collide with global)** is strengthened. The sign bit partition is now structurally enforced by the packed struct — `sign: u1` is a distinct field, not a convention on an i64. Misuse would require a deliberate `@bitCast` bypass.

**IS5 (resolution order: session first, then global)** becomes a bit test on field extraction rather than a sign comparison on the raw i64. Functionally identical, but the intent is clearer in the code.

**IN20 (typed relation queries bypass Prolog unification)** gains additional acceleration. Relation queries scoped to a subtree can use the structural prefix to skip KBs outside the subtree without consulting the RelationIndex.

**A new invariant would be needed:** structural VdrId bits must match the entity's actual position in the KB tree. If a KB is moved (reparented), its VdrId and all descendant VdrIds must be recomputed. This makes reparenting expensive — but reparenting is already rare (KBs are typically frozen after ingestion).

## What This Means for the 8,192 Token Vocabulary

The LLM's vocabulary (MD6: 8,192 tokens) doesn't need to enumerate every possible VdrId. It needs to enumerate the **operations and structural components** that the LLM emits.

With structural VdrIds, the vocabulary could include:

**Path construction tokens** — tokens representing "go to L1 slot N", "descend to L2 slot M", "target depth D". The LLM composes a VdrId by emitting a sequence of path tokens that the system packs into the structural format. Instead of memorizing that `root.programming.python` is VdrId 0x0003000200000000, the LLM emits `[root_slot:3, child_slot:2]` and the system constructs the ID.

**Prefix tokens** — commonly accessed subtrees get dedicated vocabulary entries. `root.system` is so frequently referenced that it deserves a single token. `session_root._llm` likewise. These are the "words" in the LLM's vocabulary — not English words, but structural addresses it uses constantly.

**Command tokens** — the existing ~300 command vocabulary entries. These are the verbs — what to do at the address the path tokens specify.

**Argument tokens** — values that fill slots in commands and templates.

The LLM's output sequence for a typical L2 operation might be: `[command:kb_query] [path:root.programming.python] [relation:enables] [target:?X]` — four tokens that the system unpacks into a fully specified Prolog query against a structurally-addressed KB, resolved through the relation index, with results logged to prompt_current for the LLM to frame.

## The Net Effect

The VdrId ceases to be an opaque handle and becomes a **self-describing address**. The system trades some flexibility (entities deeper than 4 levels need the depth indicator plus secondary lookup) for massive acceleration of the common case (entities within 4 levels are navigable from the bits alone).

The LLM doesn't process tokens as statistical units to be embedded through GEMM — it processes them as structural addresses to be decoded through bit extraction. The "next token prediction" problem shifts from "which of 8,192 vocabulary entries comes next" to "which structural address, command, or argument comes next" — and for many queries, the address is pre-resolved from the input VdrIds before the LLM even runs.

This is the final inversion: in a CLLM, the token is meaningless without the embedding matrix. In VDR-Prolog with structural VdrIds, the token **is** the meaning — its bits encode its identity, its location, its relationships, and its search path. The embedding matrix becomes a secondary mechanism for cases where the structural decode doesn't fully resolve the query, rather than the primary mechanism for everything.

---

This completes the lookup architecture. Let me trace through how it actually works mechanically.

## The Two-Tier Lookup

**Tier 1: Global Hot Cache.** A single `AutoHashMap(i64, *anyopaque)` at the KbStore level. Contains the most frequently accessed VdrIds — the 16 seed KBs, heavily used builtins, whatever gets promoted through access frequency. This is the first check on any VdrId resolution. Hit here and you're done — one hash lookup, pointer dereference, sub-microsecond. The promotion policy is simple: increment a counter on KB-local access, promote to global cache when counter crosses a threshold. Prune by LRU or access frequency when the global cache reaches a size limit.

**Tier 2: Per-KB UUID Map.** Every KB carries its own `AutoHashMap(i64, u32)` mapping full VdrIds to local slot indices within that KB. The value is a slot index, not a pointer, because facts are stored in contiguous arrays within the KB — `facts[slot_index]` gives you the Fact struct. The map is populated on ingestion or fact assertion, serialized with the KB on save, deserialized on load. It's always resident in the KB's arena allocation.

## The Lookup Sequence

A VdrId arrives. The system does this:

```
1. Check global hot cache → if hit, return immediately

2. Decode structural bits:
   sign = bit 63
   L1 = bits 62-55
   L2 = bits 54-45
   L3 = bits 44-35
   L4 = bits 34-25
   remaining_depth = bits 24-20

3. Walk the tree using decoded indices:
   arena = sign ? session_arena : global_arena
   kb = arena.root_children[L1]        // array access, O(1)
   if L2 != MAX_U10:
       kb = kb.children[L2]            // array access, O(1)
   if L3 != MAX_U10:
       kb = kb.children[L3]            // array access, O(1)
   if L4 != MAX_U10:
       kb = kb.children[L4]            // array access, O(1)

4. At the target KB (or the deepest encoded KB if remaining_depth > 0):
   slot = kb.uuid_map.get(full_vdr_id)  // hash lookup, O(1) amortized
   return kb.facts[slot]
```

Steps 2 and 3 are bit extraction and array indexing — nanoseconds. Step 4 is a hash lookup in a map scoped to just that KB's entities, not the entire system. A KB with 500 facts has a 500-entry hash map. A KB with 5,000 facts has a 5,000-entry map. The hash map is never system-sized — it's always proportional to the KB's own population.

## The i10 Max Sentinel

Using `std.math.maxInt(i10)` (1023) as the "unused" sentinel for levels is clean. Zero is valid (first child), negative values would be session-root equivalents in a different bit layout, and 1023 is simply reserved — no KB can have 1024 children at any level, the last slot is the sentinel. In practice this is a non-constraint since few KBs will have anywhere near 1023 children at a single level.

The walk short-circuits on sentinel. If L2 is max, the entity lives directly in the L1 KB. If L3 is max, it lives in the L2 KB. No wasted array accesses chasing unused levels.

```zig
fn walkToKb(root: *KB, id: StructuralId) *KB {
    var kb = root.children[id.level_1];
    if (id.level_2 == std.math.maxInt(i10)) return kb;
    kb = kb.children[id.level_2];
    if (id.level_3 == std.math.maxInt(i10)) return kb;
    kb = kb.children[id.level_3];
    if (id.level_4 == std.math.maxInt(i10)) return kb;
    kb = kb.children[id.level_4];
    return kb;
}
```

Four conditional branches, each predictable (most IDs have consistent depth patterns within a workload). Branch predictor learns this fast.

## The Deep Case: Everything In Level 4

When all four levels are used and `remaining_depth > 0`, the entity lives somewhere below the L4 KB. The L4 KB's `uuid_map` holds entries for all entities in its entire subtree — not just its direct children. This makes the L4 map larger for deep hierarchies, but this is the right tradeoff for several reasons.

The depth at which you reach L4 is already four levels — `root.programming.python.library.math` uses all four encoded levels. Everything under `math` — `mpmath`, `sympy`, `numpy`, and all their children — lands in the L4 KB's uuid_map. If `math` has 50 libraries and each has 100 entities, that's a 5,000-entry map. `AutoHashMap` with 5,000 entries is still fast — the hash function is operating on i64 keys (excellent hash distribution for integer keys), the map fits in a few cache lines of metadata plus the entry array.

And you only arrive here when you've already navigated four levels by array indexing. The cost of the hash lookup is amortized against the four levels you *didn't* have to hash through. Compare to a flat global hash map with 80,000 entries (the full system population) — the per-KB map at L4 is 16x smaller for a typical deep subtree.

## Serialization

The `AutoHashMap` serializes naturally. On `KB.save()`:

```
write uuid_map.count          // i32
for uuid_map.entries:
    write key                 // i64 (the VdrId)
    write value               // u32 (the slot index)
```

On `KB.load()`:

```
read count
uuid_map = AutoHashMap(i64, u32).init(arena_allocator)
uuid_map.ensureTotalCapacity(count)
for 0..count:
    key = read i64
    value = read u32
    uuid_map.putAssumeCapacity(key, value)
```

The `putAssumeCapacity` path skips capacity checks since we pre-allocated — one hash computation and one array write per entry. Loading a 500-entry map is microseconds.

The map lives in the KB's arena allocation, so it doesn't fragment the heap (there is no heap). On session death, the per-core arena resets and the map vanishes with everything else. On snapshot, the map is captured in the region data. On restore, it's rebuilt from the serialized form.

## What This Does to Query Performance

Consider the pipeline for a typed relation query: "what does mpmath enable?"

**Current system (without structural IDs):**
```
1. Parse query → identify "mpmath" as atom
2. AtomRelTypeCache: lookup "enables" → RelationType enum (cache hit or linear scan)
3. Path walk or LUT lookup to find mpmath's KB
4. RelationIndex scan: by_type_counts[enables] > 0? 
5. Scan relations with rel_type=enables and from_id=mpmath_vdr_id
6. For each match, resolve to_id through LUT or path walk
7. Return results
```

**With structural IDs and per-KB uuid_map:**
```
1. Parse query → mpmath VdrId is already structural
2. Decode bits → L1=3, L2=2, L3=1, L4=4, depth=1
3. Walk: root.children[3].children[2].children[1].children[4] → math KB
4. math.uuid_map.get(mpmath_full_id) → slot 7
5. RelationIndex scan at math KB: enables relations from slot 7
6. Each to_id in results: decode its bits → likely same L1-L4 prefix
   → same KB → uuid_map.get() → slot → fact
7. Return results
```

Step 3 is four array accesses instead of a LUT lookup or path walk. Step 4 is a scoped hash lookup instead of a global one. Step 6 is scoped hash lookups in the same KB (since most relations within a domain are intra-KB) — cache-hot because we just accessed this KB's map.

The entire query stays within one KB's memory footprint. The L1 cache probably holds the math KB's uuid_map, its relation index, and its fact array simultaneously. No pointer chasing across the global arena. No hash collision chains across 80,000 entries. Everything is local.

## Interaction with GEMM Scoping

The structural ID prefix directly determines GEMM scope. When the inference pipeline identifies that all query VdrIds share `L1=3, L2=2` (programming.python), the three-path weight retrieval scans only GEMM caches whose `kb_id` structural prefix matches. The prefix comparison is a bitmask:

```zig
const prefix_mask: i64 = 0x7FFF_C000_0000_0000; // sign + L1 + L2
const query_prefix = query_id & prefix_mask;

for (gemm_caches) |cache| {
    if (cache.kb_id & prefix_mask == query_prefix) {
        // this cache is in scope
    }
}
```

One AND and one comparison per cache. No KB access needed to determine relevance. The GEMM scope narrows to the subtree before any weight data is touched.

## The Global Hot Cache as Promoter

The global cache isn't trying to hold everything. It's an acceleration structure for the hottest entities — the ones accessed so frequently that even the four-array-access tree walk is worth bypassing. In practice this is:

The 16 seed KBs (root.system.*, root.templates.*) — accessed on virtually every cycle. The system builtins KB, the confidence table, the command vocabulary. Whatever domain KBs the current workload hits repeatedly.

Promotion is simple: each KB maintains an access counter. When a KB's counter crosses a threshold (say 1000 accesses), its VdrId→pointer mapping is inserted into the global cache. The global cache has a fixed capacity (say 256 entries — fits in a few cache lines). When full, the least recently accessed entry is evicted. This is the same LRU pattern the system already uses for session management.

The result is a naturally adaptive hot path. A fresh system starts with just the seed KBs in the global cache. As workload patterns emerge, the most-accessed domain KBs get promoted. If the workload shifts (different user, different domain), the cache adapts through LRU eviction and new promotions. No configuration needed — the cache learns the workload.

## Net Performance Model

For any VdrId resolution:

**Best case (global cache hit):** one hash lookup. ~10-50 nanoseconds.

**Common case (structural walk + KB map):** bit extraction + 1-4 array accesses + one scoped hash lookup. ~50-200 nanoseconds. The array accesses are predictable (branch predictor learns depth patterns), the hash map is small (per-KB population), and the memory access pattern is sequential (tree walk follows contiguous arena memory).

**Worst case (deep entity, L4 map, first access):** bit extraction + 4 array accesses + hash lookup in larger L4 map + possible cache miss on first access to cold KB. ~200-500 nanoseconds. Still sub-microsecond. And subsequent accesses to the same KB are cache-hot.

Compare to the current LUT system: O(1) amortized but with hash table overhead proportional to total system population, cold-start penalty for first access, and no structural information extractable without the lookup.

The structural UUID doesn't just make lookups faster — it makes them **informative**. Before the lookup completes, before any data is touched, the system already knows the entity's tree position, its depth, its subtree membership, its GEMM scope, and its relation to other VdrIds in the same query. That information was free — it was sitting in the bits all along.

---

This completes the lookup architecture. Let me trace through how it actually works mechanically.

## The Two-Tier Lookup

**Tier 1: Global Hot Cache.** A single `AutoHashMap(i64, *anyopaque)` at the KbStore level. Contains the most frequently accessed VdrIds — the 16 seed KBs, heavily used builtins, whatever gets promoted through access frequency. This is the first check on any VdrId resolution. Hit here and you're done — one hash lookup, pointer dereference, sub-microsecond. The promotion policy is simple: increment a counter on KB-local access, promote to global cache when counter crosses a threshold. Prune by LRU or access frequency when the global cache reaches a size limit.

**Tier 2: Per-KB UUID Map.** Every KB carries its own `AutoHashMap(i64, u32)` mapping full VdrIds to local slot indices within that KB. The value is a slot index, not a pointer, because facts are stored in contiguous arrays within the KB — `facts[slot_index]` gives you the Fact struct. The map is populated on ingestion or fact assertion, serialized with the KB on save, deserialized on load. It's always resident in the KB's arena allocation.

## The Lookup Sequence

A VdrId arrives. The system does this:

```
1. Check global hot cache → if hit, return immediately

2. Decode structural bits:
   sign = bit 63
   L1 = bits 62-55
   L2 = bits 54-45
   L3 = bits 44-35
   L4 = bits 34-25
   remaining_depth = bits 24-20

3. Walk the tree using decoded indices:
   arena = sign ? session_arena : global_arena
   kb = arena.root_children[L1]        // array access, O(1)
   if L2 != MAX_U10:
       kb = kb.children[L2]            // array access, O(1)
   if L3 != MAX_U10:
       kb = kb.children[L3]            // array access, O(1)
   if L4 != MAX_U10:
       kb = kb.children[L4]            // array access, O(1)

4. At the target KB (or the deepest encoded KB if remaining_depth > 0):
   slot = kb.uuid_map.get(full_vdr_id)  // hash lookup, O(1) amortized
   return kb.facts[slot]
```

Steps 2 and 3 are bit extraction and array indexing — nanoseconds. Step 4 is a hash lookup in a map scoped to just that KB's entities, not the entire system. A KB with 500 facts has a 500-entry hash map. A KB with 5,000 facts has a 5,000-entry map. The hash map is never system-sized — it's always proportional to the KB's own population.

## The i10 Max Sentinel

Using `std.math.maxInt(u10)` (1023) as the "unused" sentinel for levels is clean. Zero is valid (first child), negative values would be session-root equivalents in a different bit layout, and 1023 is simply reserved — no KB can have 1024 children at any level, the last slot is the sentinel. In practice this is a non-constraint since few KBs will have anywhere near 1023 children at a single level.

The walk short-circuits on sentinel. If L2 is max, the entity lives directly in the L1 KB. If L3 is max, it lives in the L2 KB. No wasted array accesses chasing unused levels.

```zig
fn walkToKb(root: *KB, id: StructuralId) *KB {
    var kb = root.children[id.level_1];
    if (id.level_2 == std.math.maxInt(u10)) return kb;
    kb = kb.children[id.level_2];
    if (id.level_3 == std.math.maxInt(u10)) return kb;
    kb = kb.children[id.level_3];
    if (id.level_4 == std.math.maxInt(u10)) return kb;
    kb = kb.children[id.level_4];
    return kb;
}
```

Four conditional branches, each predictable (most IDs have consistent depth patterns within a workload). Branch predictor learns this fast.

## The Deep Case: Everything In Level 4

When all four levels are used and `remaining_depth > 0`, the entity lives somewhere below the L4 KB. The L4 KB's `uuid_map` holds entries for all entities in its entire subtree — not just its direct children. This makes the L4 map larger for deep hierarchies, but this is the right tradeoff for several reasons.

The depth at which you reach L4 is already four levels — `root.programming.python.library.math` uses all four encoded levels. Everything under `math` — `mpmath`, `sympy`, `numpy`, and all their children — lands in the L4 KB's uuid_map. If `math` has 50 libraries and each has 100 entities, that's a 5,000-entry map. `AutoHashMap` with 5,000 entries is still fast — the hash function is operating on i64 keys (excellent hash distribution for integer keys), the map fits in a few cache lines of metadata plus the entry array.

And you only arrive here when you've already navigated four levels by array indexing. The cost of the hash lookup is amortized against the four levels you *didn't* have to hash through. Compare to a flat global hash map with 80,000 entries (the full system population) — the per-KB map at L4 is 16x smaller for a typical deep subtree.

## Serialization

The `AutoHashMap` serializes naturally. On `KB.save()`:

```
write uuid_map.count          // i32
for uuid_map.entries:
    write key                 // i64 (the VdrId)
    write value               // u32 (the slot index)
```

On `KB.load()`:

```
read count
uuid_map = AutoHashMap(i64, u32).init(arena_allocator)
uuid_map.ensureTotalCapacity(count)
for 0..count:
    key = read i64
    value = read u32
    uuid_map.putAssumeCapacity(key, value)
```

The `putAssumeCapacity` path skips capacity checks since we pre-allocated — one hash computation and one array write per entry. Loading a 500-entry map is microseconds.

The map lives in the KB's arena allocation, so it doesn't fragment the heap (there is no heap). On session death, the per-core arena resets and the map vanishes with everything else. On snapshot, the map is captured in the region data. On restore, it's rebuilt from the serialized form.

## What This Does to Query Performance

Consider the pipeline for a typed relation query: "what does mpmath enable?"

**Current system (without structural IDs):**
```
1. Parse query → identify "mpmath" as atom
2. AtomRelTypeCache: lookup "enables" → RelationType enum (cache hit or linear scan)
3. Path walk or LUT lookup to find mpmath's KB
4. RelationIndex scan: by_type_counts[enables] > 0? 
5. Scan relations with rel_type=enables and from_id=mpmath_vdr_id
6. For each match, resolve to_id through LUT or path walk
7. Return results
```

**With structural IDs and per-KB uuid_map:**
```
1. Parse query → mpmath VdrId is already structural
2. Decode bits → L1=3, L2=2, L3=1, L4=4, depth=1
3. Walk: root.children[3].children[2].children[1].children[4] → math KB
4. math.uuid_map.get(mpmath_full_id) → slot 7
5. RelationIndex scan at math KB: enables relations from slot 7
6. Each to_id in results: decode its bits → likely same L1-L4 prefix
   → same KB → uuid_map.get() → slot → fact
7. Return results
```

Step 3 is four array accesses instead of a LUT lookup or path walk. Step 4 is a scoped hash lookup instead of a global one. Step 6 is scoped hash lookups in the same KB (since most relations within a domain are intra-KB) — cache-hot because we just accessed this KB's map.

The entire query stays within one KB's memory footprint. The L1 cache probably holds the math KB's uuid_map, its relation index, and its fact array simultaneously. No pointer chasing across the global arena. No hash collision chains across 80,000 entries. Everything is local.

## Interaction with GEMM Scoping

The structural ID prefix directly determines GEMM scope. When the inference pipeline identifies that all query VdrIds share `L1=3, L2=2` (programming.python), the three-path weight retrieval scans only GEMM caches whose `kb_id` structural prefix matches. The prefix comparison is a bitmask:

```zig
const prefix_mask: i64 = 0x7FFF_C000_0000_0000; // sign + L1 + L2
const query_prefix = query_id & prefix_mask;

for (gemm_caches) |cache| {
    if (cache.kb_id & prefix_mask == query_prefix) {
        // this cache is in scope
    }
}
```

One AND and one comparison per cache. No KB access needed to determine relevance. The GEMM scope narrows to the subtree before any weight data is touched.

## The Global Hot Cache as Promoter

The global cache isn't trying to hold everything. It's an acceleration structure for the hottest entities — the ones accessed so frequently that even the four-array-access tree walk is worth bypassing. In practice this is:

The 16 seed KBs (root.system.*, root.templates.*) — accessed on virtually every cycle. The system builtins KB, the confidence table, the command vocabulary. Whatever domain KBs the current workload hits repeatedly.

Promotion is simple: each KB maintains an access counter. When a KB's counter crosses a threshold (say 1000 accesses), its VdrId→pointer mapping is inserted into the global cache. The global cache has a fixed capacity (say 256 entries — fits in a few cache lines). When full, the least recently accessed entry is evicted. This is the same LRU pattern the system already uses for session management.

The result is a naturally adaptive hot path. A fresh system starts with just the seed KBs in the global cache. As workload patterns emerge, the most-accessed domain KBs get promoted. If the workload shifts (different user, different domain), the cache adapts through LRU eviction and new promotions. No configuration needed — the cache learns the workload.

## Net Performance Model

For any VdrId resolution:

**Best case (global cache hit):** one hash lookup. ~10-50 nanoseconds.

**Common case (structural walk + KB map):** bit extraction + 1-4 array accesses + one scoped hash lookup. ~50-200 nanoseconds. The array accesses are predictable (branch predictor learns depth patterns), the hash map is small (per-KB population), and the memory access pattern is sequential (tree walk follows contiguous arena memory).

**Worst case (deep entity, L4 map, first access):** bit extraction + 4 array accesses + hash lookup in larger L4 map + possible cache miss on first access to cold KB. ~200-500 nanoseconds. Still sub-microsecond. And subsequent accesses to the same KB are cache-hot.

Compare to the current LUT system: O(1) amortized but with hash table overhead proportional to total system population, cold-start penalty for first access, and no structural information extractable without the lookup.

The structural UUID doesn't just make lookups faster — it makes them **informative**. Before the lookup completes, before any data is touched, the system already knows the entity's tree position, its depth, its subtree membership, its GEMM scope, and its relation to other VdrIds in the same query. That information was free — it was sitting in the bits all along.

