## VDR-Prolog Addressing System — Complete Report

### The Address

A VdrId is a signed 64-bit integer. Its bits encode the complete route from root to item. Given any VdrId, resolution is mechanical — extract bits, walk arrays, index into storage. No hash, no search, no ambiguity.

The 64 bits pack eight fields:

- **scope** (u1, bit 63): 0 = global tree, 1 = session tree. The sign of the i64 reflects this directly.
- **entry_type** (u4, bits 62-59): which kind of thing — kb, data, fact, rule, constraint, grammar, lru, counter, lock, queue, stack, ring, bitset, iose, relation, domain_relation. 15 of 16 slots used.
- **L1** (u7, bits 58-52): 127 usable top-level slots. 127 = sentinel (unused).
- **L2** (u8, bits 51-44): 255 usable slots per L1 KB. 255 = sentinel.
- **L3** (u8, bits 43-36): 255 usable slots per L2 KB.
- **L4** (u8, bits 35-28): 255 usable slots per L3 KB.
- **L5** (u8, bits 27-20): 255 usable slots per L4 KB.
- **item_id** (u20, bits 19-0): 1,048,575 addressable items per entry type per host KB. Monotonic, never reused.

Before touching any memory, you know: global or session, what type of thing, how deep in the tree, and which slot.

### Resolution

**Step 1 — Bitcast.** `.structural()` converts the i64 to a `VdrStructuralId` packed struct. Zero runtime cost.

**Step 2 — Tree walk.** Scope bit selects the starting node (root or session_root). L1 indexes into its children array, yielding the L1 KB. L2 indexes into the L1 KB's children array. Repeat for L3, L4, L5. Stop at the first sentinel. The KB you land on is the host. Five array dereferences worst case, ~25 nanoseconds.

**Step 3 — Dispatch on entry type.** The 4-bit entry_type tells you which storage. For `.data`, the item_id is a direct array index into `kb.data[item_id]` — no hashmap. For `.fact`, `.rule`, `.relation`, and other types, the KbLookup hashmaps map item_id to array slot.

**Step 4 — Item in hand.** The result is a `VdrValue` struct carrying the VdrId, the entry type, and a typed pointer to the resolved item. Exactly one pointer field is non-null. The rest are null.

Total cost: one bitcast, up to five array dereferences, one array index or hash lookup. Sub-100 nanoseconds for any entity in the system regardless of total system size.

### KBData — The Primary Data Record

KBData is the raw ingested content. It is what the compacted tables produce. Every row from every table in every compact file becomes one KBData entry in its host KB's `data` array, indexed directly by item_id.

```
KBData {
    id: VdrId           — self-referencing address
    v_0..v_3: Q16       — up to 4 extracted numeric values
    v_0_column..v_3_column: i8  — which text column each was parsed from (-1 = unused)
    text_column_0..14   — up to 15 data columns, each ?KBDataValue
    timestamp           — ?DeepTime, millisecond resolution
    timestamp_duration  — ?DeepTime, how long the event lasted
    timestamp_scope     — KBDataDurationScope, rendering granularity
}
```

**Self-referencing.** Every KBData carries its own VdrId in `.id`. Given a KBData pointer from anywhere — returned from a function, stored in a list, passed across threads — read `.id` and resolve back through the tree walk. The data is never orphaned. Update-in-place works without the caller tracking the address.

**15 text columns.** Each is a nullable `KBDataValue`, which is either a Q16 numeric value or a TextSmall (up to 1KB of text). `isText()` / `isValue()` discriminate. Null means that column wasn't populated for this row. A row from the physics constants table uses 5 columns. A row from the particles table uses 8. The remaining slots stay null, which is cheap.

**4 numeric value slots with column back-references.** When the ingestion pipeline parses a text column and extracts a number, the Q16 goes into `v_0` through `v_3` and the `v_N_column` field records which text column it came from.

For a physics constant: `K1|c|speed of light in vacuum|299,792,458|m/s|exact by definition`

- `text_column_0` → "c"
- `text_column_1` → "speed of light in vacuum"
- `text_column_2` → "299,792,458" (original text preserved)
- `text_column_3` → "m/s"
- `text_column_4` → "exact by definition (SI 2019)"
- `v_0` → Q16 of 299792458, `v_0_column = 2`

For a particle: `P5|top quark|t|quark|1/2|+2/3|~172.69 GeV/c²|3|strong, EM, weak`

- `v_0` → Q16 of 1/2 (spin), `v_0_column = 3`
- `v_1` → Q16 of +2/3 (charge), `v_1_column = 4`
- `v_2` → Q16 of 172.69 (mass), `v_2_column = 5`
- `v_3` → Q16 of 3 (generation), `v_3_column = 6`

The back-references make the parse reversible. If `v_0` holds a Q16 and `v_0_column = 2`, read `text_column_2` to get the original string. You can verify the Q16 against the text, or render the original representation on output.

**Temporal data.** Three fields cover all combinations of time:

- `timestamp` set, `duration` null → point in time. "Discovered in 1905."
- `timestamp` set, `duration` set → time range. "World War II, 1939-1945." Timestamp marks the start, duration is the span in milliseconds.
- `timestamp` null, `duration` set → pure duration. "Takes 6 weeks." No anchor point.
- Both null → no temporal data for this entry.

`timestamp_scope` records the intended granularity: millisecond, second, minute, hour, day, week, month, year, decade, century, millennium, or million_year. The raw milliseconds are precise, but the scope says "this was expressed in years" or "this was expressed in decades." When the original compact said "~3.2 decades", the system stores the exact millisecond equivalent but remembers the rendering scale.

DeepTime is a u64 in milliseconds, anchored 100 million years before CE. This covers geological time, historical dates, system timestamps, and ~484 million years into the future at millisecond precision. The Big Bang at 13.8 billion years doesn't fit at millisecond resolution, which is an accepted tradeoff — astrophysical deep time beyond 100 million years falls outside the range.

### KBDataValue — Column-Level Dual Type

Each text column holds an optional KBDataValue:

```
KBDataValue {
    v: Q16          — numeric value
    text: ?TextSmall — if non-null, this column is text; if null, it's numeric
}
```

The discrimination is structural. `isText()` returns `self.text != null`. `isValue()` returns `self.text == null`. No tag field, no union — the presence of text determines the type.

TextSmall is a fixed 1KB buffer. No variable-length allocation. The KBData array is a flat array of fixed-size structs, arena-allocated once, indexed by item_id. This trades memory efficiency (columns with 10-byte strings still use 1KB) for allocation simplicity (no second indirection to a text store, no fragmentation, no per-entry malloc).

### VdrValue — The Resolution Return Type

When you resolve a VdrId through `getVdrValue`, you get back:

```
VdrValue {
    id: VdrId               — the VdrId you resolved (stays with the data)
    entry_type: KBEntryType  — which field is populated
    ok: bool                 — whether resolution succeeded
    
    kb: ?*KB                 — populated if entry_type = .kb
    fact: ?*Fact             — populated if entry_type = .fact
    rule: ?*Rule             — populated if entry_type = .rule
    constraint: ?*Fact       — populated if entry_type = .constraint
    grammar: ?*Grammar       — populated if entry_type = .grammar
    lru: ?*Fact              — populated if entry_type = .lru
    counter_entry: ?*Fact    — populated if entry_type = .counter
    lock: ?*Fact             — populated if entry_type = .lock
    queue: ?*Fact            — populated if entry_type = .queue
    stack: ?*Fact             — populated if entry_type = .stack
    ring: ?*Fact             — populated if entry_type = .ring
    bitset: ?*Fact           — populated if entry_type = .bitset
    iose: ?*IoSe             — populated if entry_type = .iose
    relation: ?*TypedRelation — populated if entry_type = .relation
    domain_relation: ?*TypedRelation — populated if entry_type = .domain_relation
}
```

The VdrId stays with the result. The `entry_type` field is the discriminant — tells you which pointer to read without checking all 15. Factory methods (`fromFact`, `fromRule`, `fromKb`, etc.) enforce the invariant that exactly one pointer is set, and every factory takes the VdrId as its first argument.

Note: `.data` entry types resolve directly to `kb.data[item_id]` and would return a KBData pointer. VdrValue currently doesn't have a `data: ?*KBData` field — that needs adding.

### The Provenance Chain

A Fact has provenance. Provenance has `source_id: VdrId`. For ingested facts, that source_id points to a KBData entry (entry_type = .data) in the same or a different KB. Follow the VdrId and you get the full original row — all 15 text columns, all 4 numeric values with their column back-references, the timestamp with duration and scope.

The chain: Fact → `provenance.source_id` → tree walk → host KB → `data[item_id]` → original compacted content. Every fact traces back to what produced it.

For derived facts (produced by Prolog rule firing), `provenance.derivation_rule_id` is a VdrId pointing to the Rule that created it (entry_type = .rule). Follow that and you get the rule's head, body, action, and performance statistics.

### Subtree Operations

VdrId structural bits enable membership testing and scope narrowing without traversal:

- `sameSubtreeL1(a, b)` — same top-level domain? Compares L1 fields. One AND, one CMP.
- `sameSubtreeL2(a, b)` — same sub-domain? Compares L1+L2.
- `sameSubtreeL3(a, b)` — same sub-sub-domain? Compares L1+L2+L3.
- `depth()` — counts non-sentinel levels (0-5).
- `entryType()` — 4-bit extraction, what kind of thing before touching memory.

For GEMM scoping: extract L1+L2 from query VdrIds, compare against each loaded GEMM cache's KB id. In a system with hundreds of KBs, a typical query narrows to 3-7 relevant subtrees. The rest are eliminated by bit comparison without touching their weight data. Entry type narrows further — a query expecting facts doesn't load rule embedding caches.

### Addressing Arithmetic

Collision is impossible by construction:

- Different scopes have different scope bits.
- Different entry types have different entry_type bits.
- Different host KBs have different L1-L5 paths.
- Different items within a host KB have different item_ids from monotonic counters that never decrement.

No UUID generation algorithm. No collision checking. The address space geometry prevents it.

Reparenting (moving a KB to a different parent) requires recomputing every VdrId for that KB and all its contents, because the level bits must match actual tree position. This is intentionally expensive — tree stability is load-bearing for addressing.

### Scale

The current system: 59 KBs, 12,756 facts, 12,082 relations, ~180 MB arena usage out of 1 GB. Each host KB averages ~216 facts. The addressing space supports 127 × 255⁴ × 1,048,575 × 15 entities — trillions — with the current system using a tiny fraction. Growth means allocating new tree slots, not redesigning the addressing.

The KBData sizing at 15 columns with TextSmall (1KB each): worst case per entry with all columns populated is ~15KB. With 12,756 entries all fully populated, that's ~190MB. In practice most rows use 5-8 columns, and many columns are Q16 values (8 bytes, no TextSmall), so actual usage is substantially less.
