## VdrId Structural Addressing — Technical Specification

### Overview

A VdrId is a signed 64-bit integer that encodes both the identity and the tree location of every addressable entity in the system. Rather than serving as an opaque handle requiring hash lookup, a VdrId contains the complete routing path from root to item. Any VdrId can be resolved to its target through bit extraction and array indexing alone, with no string parsing, no hash computation, and no pointer chasing beyond the tree walk itself.

### Bit Layout

The 64 bits divide into eight fields packed from the most significant bit downward. Bit 63 is the scope bit, where zero indicates the global tree rooted at root and one indicates the session tree rooted at session_root. Bits 62 through 59 are the entry type, a 4-bit field encoding which kind of data this VdrId addresses. Bits 58 through 52 are the level 1 index, a 7-bit field providing 128 slots for top-level KBs directly beneath root or session_root. Bits 51 through 44 are the level 2 index, an 8-bit field providing 256 slots beneath each level 1 KB. Bits 43 through 36 are the level 3 index, 8 bits for 256 slots. Bits 35 through 28 are the level 4 index, 8 bits for 256 slots. Bits 27 through 20 are the level 5 index, 8 bits for 256 slots. Bits 19 through 0 are the LookupId, a 20-bit monotonic counter providing 1,048,575 addressable entries per entry type per host KB.

### Sentinel Convention

Any level field set to the maximum value for its bit width indicates that level is unused. Level 1 uses 127 as its sentinel because its field is 7 bits wide. Levels 2 through 5 use 255 as their sentinel because their fields are 8 bits wide. The tree walk terminates at the deepest level whose field is not the sentinel value. A VdrId with L1=3, L2=12, L3=5, L4=255, L5=255 addresses an item hosted by the level 3 KB at path root.children[3].children[12].children[5]. Zero is a valid index at every level, which is why sentinels use the maximum value rather than zero.

### Scope Partitioning

The scope bit structurally prevents collision between global and session identifiers. Every VdrId with bit 63 clear routes through the global tree, which persists across sessions and holds all permanent knowledge. Every VdrId with bit 63 set routes through the session tree, which is ephemeral and dies when the session's arena resets. The sign of the i64 value directly reflects scope: non-negative values are global, negative values are session-local, and zero is the reserved none sentinel indicating no entity.

### Entry Type

The entry type field identifies what kind of object the VdrId points to before the tree walk begins. The 4-bit field maps to the KBEntryType enumeration: kb (0) for knowledge base nodes themselves, fact (1), rule (2), constraint (3), grammar (4), lru (5), counter (6), lock (7), queue (8), stack (9), ring (10), bitset (11), iose (12), relation (13), and domain_relation (14). The system can dispatch on type by extracting four bits, with no need to load the target object first. Heterogeneous collections of VdrIds are self-describing without requiring parallel type arrays or tagged unions.

### Tree Structure and KB Responsibilities

The KB tree has a maximum depth of five levels. Each level serves a different role.

Layers 1 through 4 are navigational. A KB at any of these layers stores only its own identity, metadata, and a children array. The children array is direct-indexed by the next level's value from the VdrId. Slot 12 holds the child whose level field is 12. Empty slots hold a sentinel offset of -1. These KBs do not store facts, rules, relations, or any other entity data. Their sole purpose is routing the tree walk one level deeper.

Layer 5 is the terminal host. A KB at layer 5 stores everything: facts, rules, relations, constraints, grammars, and all live-state data structures. All the existing offset and count fields on the KB struct serve layer 5 KBs. There is no layer 6. Any conceptual depth beyond five levels is represented as items within the layer 5 KB, addressed by LookupId.

A KB at any layer can also serve as a terminal host if no deeper levels are populated. A VdrId with L1=3, L2=12, L3=255, L4=255, L5=255 terminates at layer 2, and that layer 2 KB is the host for the item. The rule is simple: the deepest KB reached by the tree walk is the host.

### LookupId and Per-Type Monotonic Counters

The final 20 bits of a VdrId are the LookupId, typed as u20. Each KB maintains a separate monotonic counter per entry type: next_fact_id, next_rule_id, next_constraint_id, next_grammar_id, next_relation_id, next_domain_relation_id, next_lru_id, next_counter_id, next_lock_id, next_queue_id, next_stack_id, next_ring_id, next_bitset_id, and next_iose_id. When a new item is created, the host KB's counter for that entry type provides the LookupId and increments. The counter never decrements and never reuses values within a KB's lifetime.

Because each entry type has its own counter, a fact with LookupId=3 and a rule with LookupId=3 within the same host KB are distinct items. The entry type field in the VdrId disambiguates them. This means each host KB supports up to 1,048,575 items per entry type, and the total addressable items per host KB is 1,048,575 multiplied by the number of entry types.

### Tree Walk

Resolution of a VdrId to its target proceeds through a fixed sequence. The scope bit selects the starting node: root for global, session_root for session. The level 1 field indexes into the starting node's children array, yielding the level 1 KB. The level 2 field indexes into the level 1 KB's children array, yielding the level 2 KB. This repeats for levels 3, 4, and 5. At any step, if the level field equals its sentinel value, the walk stops and the current KB is the host. The worst case is five array dereferences, roughly 25 nanoseconds.

Once the host KB is reached, the entry type field selects which typed array to look in, and the LookupId indexes into it. For entry_type=fact, the host KB's facts array is accessed. For entry_type=rule, the rules array. For entry_type=relation, the relations array. Every entry type maps to exactly one storage array on the host KB. Resolution from VdrId to actual data is one array index operation after the tree walk completes.

### Item Resolution at Host

The host KB resolves a LookupId to the actual item through its typed arrays. The facts array is indexed when entry_type is fact. The rules array when entry_type is rule. The relations array when entry_type is relation. The same pattern applies for every entry type in the enumeration. The LookupId serves as the array index for the relevant typed array. Because LookupIds are assigned monotonically and never reused, the array index is always valid for the lifetime of the KB. If a LookupId exceeds the current count for that type, the item does not exist yet or has been addressed incorrectly.

### Subtree Operations

Because the tree path is encoded in the VdrId bits, subtree membership testing is a mask and compare operation. To test whether two VdrIds share the same level 1 and level 2 ancestor, extract bits 58 through 44 from both and compare. If they match, the entities are in the same subtree. This costs one AND and one CMP instruction. This property drives GEMM scope narrowing: before touching any weight data, the system extracts the upper level bits from query VdrIds and eliminates GEMM caches belonging to irrelevant subtrees. In a system with 150 domain subtrees loaded, a typical query touches 3 to 7, and the remaining subtrees are excluded by bitmask without accessing their data.

### Reparenting

Moving a KB to a different parent requires recomputing the VdrId for the moved KB and all items it hosts, because the level fields must match actual tree position and every LookupId-bearing VdrId embeds the host KB's level path. This is intentionally expensive. The structural encoding enforces tree stability by making reparenting a bulk operation that touches every affected VdrId, every lookup map entry, and every reference from other entities. This is a design choice: the tree structure is load-bearing for addressing, so changing it must be a deliberate operation with visible cost.

### Construction

When a new entity is created, its VdrId is constructed by combining the host KB's level path with the entry type and a freshly minted LookupId. The host KB calls mintLookupId with the appropriate entry type, which returns the next available u20 value for that type and increments the counter. The VdrId is then assembled by packing the scope bit, entry type, the host KB's level indices, and the new LookupId into the 64-bit field. For entry_type=kb (a new child KB), the LookupId is zero and the child's level index at the appropriate depth is set to its position in the parent's children array.

Collision is impossible within a single host because each entry type's counter is monotonic. Collision across hosts is impossible because the level fields differ. Collision across entry types is impossible because the entry type field differs.

### Relationship to GEMM

The embedding matrix for a host KB is indexed by LookupId. Each row in the matrix corresponds to one item's LookupId within that KB. When a query arrives, the system extracts level bits from the query's VdrIds, identifies which host KBs are relevant via subtree masking, and loads only their GEMM caches. The entry type further narrows scope: a query about relations need not load fact embedding caches. The GEMM operates over the LookupId space of the relevant host KBs, producing scores that map back to VdrIds through the same structural encoding. The output of inference is a VdrId, not text. The VdrId routes back through the tree walk to the actual fact, rule, or relation that the model selected.

### Capacity

The addressing space is large but sparsely populated. Level 1 provides 127 usable top-level KBs. Level 2 provides 255 usable children per level 1 KB. Levels 3, 4, and 5 follow the same pattern at 255 each. The theoretical maximum tree size exceeds 500 billion KBs, but in practice the tree contains hundreds to low thousands with the addressing space providing growth room without restructuring. Each host KB supports 1,048,575 items per entry type. A domain KB holding a few hundred facts and a few dozen rules uses a tiny fraction of this capacity. The 20-bit LookupId was chosen to balance per-KB capacity against the 64-bit budget, and one million items per type per host KB is sufficient for any single domain's data.

---

```zig
// ============================================================
// VdrId Structural Addressing — Code Reference
// ============================================================

// ---- Bit Layout Constants ----

pub const SCOPE_BIT: u6 = 63;
pub const ENTRY_TYPE_SHIFT: u6 = 59;
pub const ENTRY_TYPE_MASK: u64 = 0xF;
pub const L1_SHIFT: u6 = 52;
pub const L1_MASK: u64 = 0x7F;
pub const L2_SHIFT: u6 = 44;
pub const L2_MASK: u64 = 0xFF;
pub const L3_SHIFT: u6 = 36;
pub const L3_MASK: u64 = 0xFF;
pub const L4_SHIFT: u6 = 28;
pub const L4_MASK: u64 = 0xFF;
pub const L5_SHIFT: u6 = 20;
pub const L5_MASK: u64 = 0xFF;
pub const ITEM_ID_MASK: u64 = 0xFFFFF;

pub const L1_SENTINEL: u7 = 127;
pub const LEVEL_SENTINEL: u8 = 255;

// ---- Entry Type ----

pub const KBEntryType = enum(u4) {
    kb = 0,
    fact,
    rule,
    constraint,
    grammar,
    lru,
    counter,
    lock,
    queue,
    stack,
    ring,
    bitset,
    iose,
    relation,
    domain_relation,
};

// ---- LookupId ----

pub const LookupId = u20;
pub const LOOKUP_ID_MAX: LookupId = std.math.maxInt(u20);

// ---- Packed Structural ID ----

pub const VdrStructuralId = packed struct(u64) {
    item_id: u20 = 0,
    l5: u8 = LEVEL_SENTINEL,
    l4: u8 = LEVEL_SENTINEL,
    l3: u8 = LEVEL_SENTINEL,
    l2: u8 = LEVEL_SENTINEL,
    l1: u7 = L1_SENTINEL,
    entry_type: u4 = 0,
    scope: u1 = 0,
};

// ---- VdrId with Structural Access ----

pub const VdrId = struct {
    v: i64 = 0,

    pub const NONE: VdrId = .{ .v = 0 };

    pub fn isGlobal(self: VdrId) bool {
        return self.v >= 0;
    }

    pub fn isEphemeral(self: VdrId) bool {
        return self.v < 0;
    }

    pub fn isNone(self: VdrId) bool {
        return self.v == 0;
    }

    pub fn eql(a: VdrId, b: VdrId) bool {
        return a.v == b.v;
    }

    // -- Structural access --

    fn bits(self: VdrId) u64 {
        return @bitCast(self.v);
    }

    pub fn structural(self: VdrId) VdrStructuralId {
        return @bitCast(self.bits());
    }

    pub fn fromStructural(s: VdrStructuralId) VdrId {
        const raw: u64 = @bitCast(s);
        return .{ .v = @bitCast(raw) };
    }

    pub fn entryType(self: VdrId) KBEntryType {
        return @enumFromInt(self.structural().entry_type);
    }

    pub fn lookupId(self: VdrId) LookupId {
        return self.structural().item_id;
    }

    // -- Depth detection --

    pub fn depth(self: VdrId) u3 {
        const s = self.structural();
        if (s.l1 == L1_SENTINEL) return 0;
        if (s.l2 == LEVEL_SENTINEL) return 1;
        if (s.l3 == LEVEL_SENTINEL) return 2;
        if (s.l4 == LEVEL_SENTINEL) return 3;
        if (s.l5 == LEVEL_SENTINEL) return 4;
        return 5;
    }

    // -- Subtree membership --

    pub fn sameSubtreeL1(a: VdrId, b: VdrId) bool {
        const mask = L1_MASK << L1_SHIFT;
        return (a.bits() & mask) == (b.bits() & mask);
    }

    pub fn sameSubtreeL2(a: VdrId, b: VdrId) bool {
        const mask = (L1_MASK << L1_SHIFT) | (L2_MASK << L2_SHIFT);
        return (a.bits() & mask) == (b.bits() & mask);
    }

    pub fn sameSubtreeL3(a: VdrId, b: VdrId) bool {
        const mask = (L1_MASK << L1_SHIFT) | (L2_MASK << L2_SHIFT) | (L3_MASK << L3_SHIFT);
        return (a.bits() & mask) == (b.bits() & mask);
    }

    // -- Construction --

    pub fn makeKb(scope_val: u1, l1_val: u7, l2_val: u8, l3_val: u8, l4_val: u8, l5_val: u8) VdrId {
        return fromStructural(.{
            .scope = scope_val,
            .entry_type = @intFromEnum(KBEntryType.kb),
            .l1 = l1_val,
            .l2 = l2_val,
            .l3 = l3_val,
            .l4 = l4_val,
            .l5 = l5_val,
            .item_id = 0,
        });
    }

    pub fn makeItem(scope_val: u1, entry: KBEntryType, l1_val: u7, l2_val: u8, l3_val: u8, l4_val: u8, l5_val: u8, lid: LookupId) VdrId {
        return fromStructural(.{
            .scope = scope_val,
            .entry_type = @intFromEnum(entry),
            .l1 = l1_val,
            .l2 = l2_val,
            .l3 = l3_val,
            .l4 = l4_val,
            .l5 = l5_val,
            .item_id = lid,
        });
    }
};

// ---- Tree Walk ----

pub const ResolveResult = struct {
    host_kb: ?*KB = null,
    entry_type: KBEntryType = .kb,
    lookup_id: LookupId = 0,
    ok: bool = false,
};

pub fn resolveVdrId(root_kb: *KB, session_root_kb: ?*KB, id: VdrId) ResolveResult {
    if (id.isNone()) return .{};

    const s = id.structural();

    var current: *KB = if (s.scope == 0)
        root_kb
    else
        (session_root_kb orelse return .{});

    // Walk each level — stop at sentinel
    const levels = [5]u8{ s.l1, s.l2, s.l3, s.l4, s.l5 };
    const sentinels = [5]u8{ L1_SENTINEL, LEVEL_SENTINEL, LEVEL_SENTINEL, LEVEL_SENTINEL, LEVEL_SENTINEL };

    for (0..5) |i| {
        if (levels[i] == sentinels[i]) break;
        const child = getChild(current, levels[i]) orelse return .{};
        current = child;
    }

    // current is the host KB. entry_type + lookup_id resolve the item.
    return .{
        .host_kb = current,
        .entry_type = @enumFromInt(s.entry_type),
        .lookup_id = s.item_id,
        .ok = true,
    };
}

fn getChild(kb: *KB, index: u8) ?*KB {
    if (kb.children_offset == -1) return null;
    if (index >= kb.children_count) return null;
    // children array is direct-indexed: slot N holds child at level index N
    // implementation accesses arena memory at children_offset
    // placeholder — actual implementation uses arena base + offset
    _ = kb;
    _ = index;
    return null;
}

// ---- Minting Items ----

// Create a new fact in a host KB and get its VdrId.
// The host KB's own VdrId provides the level path.
// mintLookupId provides the unique 20-bit item_id.
//
//   const host_id = qed_kb.id;
//   const lid = qed_kb.mintLookupId(.fact) orelse return null;
//   const s = host_id.structural();
//   const fact_id = VdrId.makeItem(s.scope, .fact, s.l1, s.l2, s.l3, s.l4, s.l5, lid);
//   // fact_id now routes: root -> L1 -> L2 -> L3 -> L4 -> L5 -> facts[lid]

// ---- Usage Examples ----

// root.edu — L1 KB, global, edu is child index 3 under root
const edu_id = VdrId.makeKb(0, 3, LEVEL_SENTINEL, LEVEL_SENTINEL, LEVEL_SENTINEL, LEVEL_SENTINEL);

// root.edu.physics — L2 KB, physics is child index 12 under edu
const physics_id = VdrId.makeKb(0, 3, 12, LEVEL_SENTINEL, LEVEL_SENTINEL, LEVEL_SENTINEL);

// root.edu.physics.quantum — L3 KB
const quantum_id = VdrId.makeKb(0, 3, 12, 5, LEVEL_SENTINEL, LEVEL_SENTINEL);

// root.edu.physics.quantum.qed — L4 KB
const qed_id = VdrId.makeKb(0, 3, 12, 5, 0, LEVEL_SENTINEL);

// Fact #42 inside qed (assuming qed is terminal host at L4)
const fact_42 = VdrId.makeItem(0, .fact, 3, 12, 5, 0, LEVEL_SENTINEL, 42);

// Relation #7 inside qed
const rel_7 = VdrId.makeItem(0, .relation, 3, 12, 5, 0, LEVEL_SENTINEL, 7);

// Both in same L2 subtree (edu.physics)?
const same_domain = VdrId.sameSubtreeL2(fact_42, rel_7); // true

// Resolve fact_42 to its host and item
// const result = resolveVdrId(&root, null, fact_42);
// result.host_kb -> qed KB
// result.entry_type -> .fact
// result.lookup_id -> 42
// Access: qed.facts[42]

// Mint a new fact in qed at runtime:
// const lid = qed_kb.mintLookupId(.fact) orelse return null; // returns 0, then 1, then 2...
// const s = qed_kb.id.structural();
// const new_fact_id = VdrId.makeItem(s.scope, .fact, s.l1, s.l2, s.l3, s.l4, s.l5, lid);
```

