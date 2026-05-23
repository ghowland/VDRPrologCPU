## VDR-Prolog Addressing System — Complete Report

### The Address

A VdrId is a signed 64-bit integer. Its bits encode the complete route from root to item. Given any VdrId, resolution is mechanical — extract bits, walk arrays, index into storage. No hash, no search, no ambiguity.

The 64 bits pack eight fields:

- **scope** (u1, bit 63): 0 = global tree, 1 = session tree. The sign of the i64 reflects this directly.
- **entry_type** (u4, bits 62-59): which kind of thing. All 16 slots used.
- **L1** (u7, bits 58-52): 127 usable top-level slots. 127 = sentinel (unused).
- **L2** (u8, bits 51-44): 255 usable slots per L1 KB. 255 = sentinel.
- **L3** (u8, bits 43-36): 255 usable slots per L2 KB.
- **L4** (u8, bits 35-28): 255 usable slots per L3 KB.
- **L5** (u8, bits 27-20): 255 usable slots per L4 KB.
- **item_id** (u20, bits 19-0): 1,048,575 addressable items per entry type per host KB. Monotonic counter, never reused.

The 16 entry types divide into three categories:

**Storage:** kb (0), data (1), data_q335 (2), fact (3), rule (4), constraint (5), grammar (6)

**Computation:** lru (7), counter (8), lock (9), queue (10), stack (11), ring (12), bitset (13)

**Structure:** iose (14), relation (15)

Before touching any memory, a VdrId tells you: global or session, what type of thing, how deep in the tree, and which slot. All 16 entry type slots are occupied — no room for additions without widening the field or cutting an existing type.

### Resolution

**Step 1 — Bitcast.** `.structural()` converts the i64 to a `VdrStructuralId` packed struct via `@bitCast`. Zero runtime cost.

**Step 2 — Tree walk.** Scope bit selects the starting node (root or session_root). L1 indexes into its children array, yielding the L1 KB. L2 indexes into the L1 KB's children array. Repeat for L3, L4, L5. Stop at the first sentinel. The KB you land on is the host. Five array dereferences worst case, ~25 nanoseconds.

**Step 3 — Dispatch on entry type.** The 4-bit entry_type determines which storage to access. For `.data`, the item_id is a direct array index into `kb.data[item_id]` — no hashmap needed. For `.data_q335`, direct index into `kb.data_q335[item_id]`. For `.fact`, `.rule`, `.relation`, and other types, the KbLookup hashmaps map item_id to array slot.

**Step 4 — Item in hand.** Total cost: one bitcast, up to five array dereferences, one array index or hash lookup. Sub-100 nanoseconds for any entity regardless of total system size.

### KBData — The Primary Data Record

KBData is the raw ingested content. Every row from every compacted table becomes one KBData entry in its host KB's `data` array, indexed directly by item_id.

```zig
pub const KBData = struct {
    id: VdrId,
    v_0: Q16,  v_0_column: i8,    // extracted numeric value + source column (-1 = unused)
    v_1: Q16,  v_1_column: i8,
    v_2: Q16,  v_2_column: i8,
    v_3: Q16,  v_3_column: i8,
    text_column_0..8: ?KBDataValue, // 9 text/value columns
    timestamp: ?DeepTime,
    timestamp_duration: ?DeepTime,
    timestamp_scope: KBDataDurationScope,
};
```

**Self-referencing.** Every KBData carries its own VdrId in `.id`. Given a KBData pointer from anywhere — returned from a function, stored in a list, passed across threads — read `.id` and resolve back through the tree walk to the host KB. The data is never orphaned. Update-in-place works without the caller tracking the address.

**9 text columns.** Each is a nullable `KBDataValue`, which is either a Q16 numeric value or a TextSmall (64-byte fixed buffer with length). `isText()` returns `self.text != null`. `isValue()` returns `self.text == null`. Null means the column wasn't populated for this row.

**4 numeric value slots with column back-references.** When the ingestion pipeline parses a column and extracts a number, the Q16 goes into v_0 through v_3 and the `v_N_column` field records which original column it came from. This makes the parse reversible — if `v_0` holds a Q16 and `v_0_column = 2`, read `text_column_2` to get the original string representation.

For tables with more than 9 total columns, purely numeric columns get pushed into the v_0-v_3 slots and don't consume a text column. With 4 Q16 absorbing numeric columns, a table needs 14+ columns (9 text + 4 numeric + ID) before running out. The column back-references preserve the original column position regardless of how values are distributed.

Example — physics constant: `K1|c|speed of light in vacuum|299,792,458|m/s|exact by definition`

- `text_column_0` → "c" (symbol)
- `text_column_1` → "speed of light in vacuum"
- `text_column_2` → "299,792,458" (original text preserved)
- `text_column_3` → "m/s"
- `text_column_4` → "exact by definition (SI 2019)"
- `v_0` → Q16 of 299792458, `v_0_column = 2`

Example — particle: `P5|top quark|t|quark|1/2|+2/3|~172.69 GeV/c²|3|strong, EM, weak`

- `v_0` → Q16 of 1/2 (spin), `v_0_column = 3`
- `v_1` → Q16 of +2/3 (charge), `v_1_column = 4`
- `v_2` → Q16 of 172.69 (mass), `v_2_column = 5`
- `v_3` → Q16 of 3 (generation), `v_3_column = 6`
- Text columns hold name, symbol, type, mass unit, interactions

### KBDataQ335 — High-Precision Data Record

For values exceeding Q16's i32 range (±2.147 billion), KBDataQ335 uses Q335 value slots instead. Q335 has 5 components of [6]i64 each (240 bytes per value), covering numbers up to 2³³⁵ with 4 remainder slots for physics-level precision.

The structure mirrors KBData exactly — same 9 text columns, same timestamp fields, same self-referencing VdrId — but v_0 through v_3 are Q335 instead of Q16. Entry type is `.data_q335`, stored in `kb.data_q335[item_id]`.

Primary targets: fundamental constants like Avogadro's number (6.022 × 10²³), Planck constant (6.626 × 10⁻³⁴), gravitational constant (6.674 × 10⁻¹¹). These overflow Q16's i32 range by many orders of magnitude.

Most KBs never allocate a `data_q335` array. Only domains with extreme-precision values need it. The physics constants table produces ~24 entries. Chemistry might add some. The other 50+ domains use KBData exclusively.

### KBDataValue — Column-Level Dual Type

Each text column holds an optional KBDataValue:

```zig
pub const KBDataValue = struct {
    v: Q16 = .{},
    text: ?TextSmall = null,
};
```

TextSmall is a fixed 64-byte buffer with a length field:

```zig
pub const TextSmall = struct {
    text: [64]u8 = [_]u8{0} ** 64,
    len: usize = 0,
};
```

64 bytes covers most compact table fields: identifiers, names, units, short descriptions. Longer descriptive text (law statements, multi-clause definitions) truncates at 64 bytes.

### Temporal Data

Three fields on KBData and KBDataQ335 cover all combinations of time:

- `timestamp` set, `duration` null → point in time. "Discovered in 1905."
- `timestamp` set, `duration` set → time range. "World War II, 1939-1945." Timestamp marks the start, duration is the span.
- `timestamp` null, `duration` set → pure duration. "Takes 6 weeks." No anchor point.
- Both null → no temporal data.

DeepTime is u64 milliseconds, anchored 100 million years before CE. Covers geological time, historical dates, and system timestamps at millisecond precision, with ~484 million years of future range. The Big Bang at 13.8 billion years doesn't fit at millisecond resolution — an accepted tradeoff for millisecond precision within the covered range.

`timestamp_scope` records the intended rendering granularity via KBDataDurationScope: millisecond, second, minute, hour, day, week, month, year, decade, century, millennium, or million_year. The raw milliseconds are precise, but the scope preserves how the value was originally expressed. "~3.2 decades" stores the exact millisecond equivalent but remembers the scale was decades. "49 months" stores months. The scope drives output formatting without losing precision in the stored value.

### VdrValue — Resolution Return Type

When you resolve a VdrId, you get back a VdrValue carrying the VdrId, entry type, and a typed pointer to the resolved item. Exactly one pointer is non-null on success.

```zig
pub const VdrValue = struct {
    id: VdrId = VdrId.NONE,
    entry_type: KBEntryType = .kb,
    ok: bool = false,

    kb: ?*KB = null,
    fact: ?*Fact = null,
    rule: ?*Rule = null,
    constraint: ?*Fact = null,
    grammar: ?*Grammar = null,
    lru: ?*Fact = null,
    counter_entry: ?*Fact = null,
    lock: ?*Fact = null,
    queue: ?*Fact = null,
    stack: ?*Fact = null,
    ring: ?*Fact = null,
    bitset: ?*Fact = null,
    iose: ?*IoSe = null,
    relation: ?*TypedRelation = null,
};
```

The VdrId stays with the result — data and address travel together. The `entry_type` field is the discriminant, telling you which pointer to read without checking all fields. Factory methods enforce the invariant: every factory takes the VdrId as its first argument and sets exactly one pointer.

```zig
pub fn fromFact(id: VdrId, f: *Fact) VdrValue { ... }
pub fn fromRule(id: VdrId, r: *Rule) VdrValue { ... }
pub fn fromKb(id: VdrId, k: *KB) VdrValue { ... }
// ... one factory per entry type
```

Types without dedicated structs (lru, counter, lock, queue, stack, ring, bitset) use `*Fact` as storage. If any later get promoted to their own struct, the pointer type changes in VdrValue and the factory — nothing else moves.

### The Provenance Chain

A Fact has provenance:

```zig
pub const Provenance = struct {
    source_type: i32,
    source_id: VdrId,
    confidence: Q16,
    timestamp: i32,
    derivation_rule_id: VdrId,
    capability_level: i32,
};
```

For ingested facts, `source_id` is a VdrId with `entry_type = .data` (or `.data_q335`), pointing to the KBData entry that produced the fact. Follow the VdrId: tree walk → host KB → `data[item_id]` → original compacted row with all columns, numeric values with column back-references, and temporal data.

For derived facts (produced by Prolog rule firing), `derivation_rule_id` is a VdrId with `entry_type = .rule`, pointing to the Rule that created it. Follow that VdrId and you get the rule's head, body, action, and performance statistics (fire_count, success_count, failure_count).

Both `source_id` and `derivation_rule_id` are full VdrIds — they resolve through the same tree walk as any other address. The old two-field scheme (separate KB id + slot index) is replaced by a single VdrId per reference.

### Subtree Operations

VdrId structural bits enable membership testing and scope narrowing without traversal:

- `sameSubtreeL1(a, b)` — same top-level domain? Compares L1 fields. One AND, one CMP.
- `sameSubtreeL2(a, b)` — same sub-domain? Compares L1+L2.
- `sameSubtreeL3(a, b)` — same sub-sub-domain? Compares L1+L2+L3.
- `depth()` — counts non-sentinel levels (0-5).
- `entryType()` — 4-bit extraction, what kind of thing before touching memory.

For GEMM scoping: extract L1+L2 from query VdrIds, compare against each loaded GEMM cache's KB id. In a system with hundreds of KBs, a typical query narrows to 3-7 relevant subtrees in nanoseconds. The rest are eliminated by bit comparison without touching their weight data. Entry type narrows further — a query expecting facts doesn't load rule embedding caches.

### Addressing Arithmetic

Collision is impossible by construction:

- Different scopes have different scope bits.
- Different entry types have different entry_type bits.
- Different host KBs have different L1-L5 paths.
- Different items within a host KB have different item_ids from monotonic counters that never decrement or reuse.

No UUID generation algorithm. No collision checking. The address space geometry prevents it.

Reparenting (moving a KB to a different parent) requires recomputing every VdrId for that KB and all its contents, because the level bits must match actual tree position. This is intentionally expensive — tree stability is load-bearing for addressing.

### Memory Usage

**KBData** — ~880 bytes per entry:

- VdrId + 4×Q16 + 4×i8 column refs: ~44 bytes
- 9 × ?KBDataValue (each ~88 bytes: Q16 + ?TextSmall at 72 bytes + padding): ~792 bytes
- Timestamp fields: ~33 bytes, padded to ~44

| KBData Entries | Memory |
|----------------|--------|
| 12,756 (current system) | ~11 MB |
| 50,000 | ~43 MB |
| 100,000 | ~86 MB |
| 200,000 | ~172 MB |
| 500,000 | ~430 MB |

**KBDataQ335** — ~1,800 bytes per entry:

- VdrId + 4×Q335 (240 bytes each) + 4×i8 column refs: ~972 bytes
- 9 × ?KBDataValue: ~792 bytes
- Timestamp fields: ~44 bytes

Most KBs never allocate a data_q335 array. The physics constants table produces ~24 entries at ~43 KB total. Negligible at system scale.

**Current system total:** 59 KBs, 12,756 facts, 12,082 relations, ~180 MB arena usage out of 1 GB global arena, 894 MB free. KBData for all current entries would add ~11 MB.

### Scale

The addressing space supports 127 × 255⁴ × 1,048,575 × 16 entries — trillions of addressable entities. The current system uses a tiny fraction. Growth means allocating new tree slots, not redesigning addressing.

At 100K KBData entries (86 MB) plus KBs, relations, indices, and weight references, the system fits within the 1 GB global arena. At 500K entries (430 MB), it still fits but leaves less headroom for weights and indices. The 64-byte TextSmall buffer is the primary per-column cost — shorter buffers save memory linearly, longer ones consume it linearly.

GEMM scoping cost scales with the number of loaded KBs (one AND + one CMP per cache), not with the number of entities. Going from 59 to 500 KBs adds ~500 nanoseconds of elimination work per query. The GEMM computation avoided would have taken milliseconds. The ratio improves as the system grows.
