## SNK (Structured Neural Knowledge) — Technical Specification v0.7

### System Overview

SNK is an exact integer knowledge system with a single-block transformer, written in Zig 0.15.1, targeting x86_64. CPU only. No floats. No GPU. No malloc after init. Arena-only memory. The system loads structured knowledge from pipe-delimited compact files, stores it in a tree of knowledge bases addressable by structural 64-bit integer IDs, trains and runs inference through an integer transformer over the KB vocabulary, and serves queries over HTTP.

### Architecture

The system consists of 15 source files:

| File | Role | Lines (approx) |
|------|------|---------|
| vdr_types.zig | All type definitions | ~1900 |
| root.zig | Main entry, KB loading, data population, verification, test orchestration | ~550 |
| vdr_gemm.zig | Single-block Q16 transformer: model creation, forward, backward, SGD, inference | ~750 |
| vdr_gemm_test.zig | Contrastive embedding test: build, train, infer over GemmCache | ~350 |
| vdr_compact_loader.zig | Parses .md compact files into arena structures | ~450 |
| vdr_kb_config.zig | Loads/saves kb.json mapping dotted paths to files | ~200 |
| vdr_config.zig | Loads config.json into SystemConfig | ~130 |
| vdr_arena.zig | Creates/destroys page-allocated arenas | ~35 |
| resetable_memory.zig | Scratch arena with reset capability and std.mem.Allocator vtable | ~70 |
| vdr_http.zig | HTTP listener, connection handling, response writing | ~200 |
| vdr_http_accepter.zig | Connection ring buffer, handler thread pool | ~100 |
| vdr_http_handler.zig | Route dispatch, runner submission | ~60 |
| vdr_runner_pool.zig | Per-core work rings, runner threads | ~150 |
| text_big.zig | 100KB fixed-size text buffer with string operations | ~500 |
| text_small.zig | 64-byte fixed-size text buffer with string operations | ~500 |
| time_deep.zig | DeepTime u64 millisecond timestamps, 100M year anchor | ~40 |

Total: approximately 5,985 lines.

### Boot Sequence

1. Load `config.json` into SystemConfig
2. Allocate global arena from page_allocator (default 1 GB)
3. Allocate resetable scratch memory (1 MB)
4. Load `kb.json` mapping (dotted paths → compact file paths)
5. Scan `data/kb_raw/` directory, load all .md compact files into arena
6. Create KB tree with structural VdrIds assigned from dotted paths
7. Populate facts and relations into KB lookup hashmaps
8. Populate KBData columns from compact row text
9. Verify all KBData entries round-trip through getVdrValue
10. Print sample data entry
11. Run GEMM contrastive embedding test against root.engineering.mechanical
12. Run GEMM transformer test against root.engineering.mechanical
13. Spawn HTTP server on port 1138 with 4 handler threads and 4 runner threads
14. Wait for shutdown signal (GET /shutdown)
15. Join all threads, free arenas, exit

### Addressing: VdrId

Every addressable entity has a VdrId — a signed 64-bit integer whose bits encode the complete routing path:

```
bit 63:     scope (0=global, 1=session)
bits 62-59: entry_type (u4, 16 types)
bits 58-52: L1 (u7, 127 usable slots, 127=sentinel)
bits 51-44: L2 (u8, 255 usable, 255=sentinel)
bits 43-36: L3 (u8, 255 usable, 255=sentinel)
bits 35-28: L4 (u8, 255 usable, 255=sentinel)
bits 27-20: L5 (u8, 255 usable, 255=sentinel)
bits 19-0:  item_id (u20, 1,048,575 per type per KB)
```

VdrId is a struct wrapping i64 with methods: `structural()` bitcasts to VdrStructuralId packed struct at zero cost. `makeKb()` and `makeItem()` construct VdrIds from components. `makeChildKb()` produces child KB ids. `depth()` counts non-sentinel levels (0-5). `sameSubtreeL1/L2/L3()` test subtree membership by field comparison. `entryType()` and `lookupId()` extract fields.

Non-negative values are global (persistent). Negative values are session (ephemeral). Zero is NONE sentinel.

### Entry Types

All 16 u4 slots are occupied:

**Storage:** kb (0), data (1), data_q335 (2), fact (3), rule (4), constraint (5), grammar (6)

**Computation:** lru (7), counter (8), lock (9), queue (10), stack (11), ring (12), bitset (13)

**Structure:** iose (14), relation (15)

### Arithmetic: Q16

Primary arithmetic type. D = 65536, implicit, never stored.

```zig
Q16 { v: i32, r0: u16, r1: u16 }
```

- v: integer value scaled by D
- r0: exact remainder from divTrunc by D (unsigned, range 0..65535)
- r1: sub-remainder from cross-terms (unsigned, range 0..65535)

Remainder is exact unresolved structure, not error. Implemented operations: add (with r1→r0→v carry chain), sub (with borrow chain), mul (i64 widening, divTrunc/mod, cross-term r1), div (widened numerator, divTrunc/mod, r1 from r0 widening), compare (lexicographic v→r0→r1), eql (all three fields).

r0 and r1 changed from i16 to u16 in v0.7. Remainders from @mod by D are always non-negative. This eliminates sign-related overflow when remainder values exceed 32767 during carry propagation.

Q32 (i64/i32/i32, D=2³²) and Q335 ([6]i64 × 5 components) exist for escalation and physics precision.

### KB Tree

KBs are allocated in the global arena. Each KB gets a structural VdrId derived from its dotted path. L1 indices are assigned by first-seen order of the segment after "root." (edu=0, programming=1, engineering=2, etc.). L2 indices are per-L1, assigned by first-seen order. L3 indices are per-L1+L2 pair.

Segment tracking uses stack-allocated arrays (127 L1 slots × 64-byte names, 127×255 L2 slots × 64-byte names).

### KB Structure

Each KB struct holds nullable Managed array lists for all 16 entry types, a KbLookup struct with per-entry-type AutoHashMap(LookupId, i32) for non-direct-indexed types, and per-entry-type monotonic LookupId counters via `mintLookupId()`.

KBData entries are direct-indexed: `kb.data.?.items[item_id]`. The VdrId's item_id IS the array index.

### Compact Loading Pipeline

The compact loader parses .md files containing pipe-delimited tables. It recognizes table headers with column definitions, relationship sections with comma-separated targets, relation mapping sections for per-file canonical type aliases, and decode_legend sections (skipped). Relationships resolve canonical types through `nameToRelationType()` covering 130+ named types plus per-file mapping fallback.

Output: LoadResult with tables, relationships, mappings, counts, and arena text usage.

### Relation Types

120+ relation types in the RelationType enum, organized into 7 categories: structural (1000+), identity (2000+), knowledge (3000+), agency (4000+), logic (5000+), grammar (6000+), toolchain (7000+), plus domain-registerable slots at 1,000,000+.

Each type declares algebraic properties via methods: `inverse()` returns the reverse relation type, `isSymmetric()` returns true for 16 symmetric types, `isTransitive()` returns true for 15 transitive types.

TypedRelation struct: rel_type, from_id (VdrId), to_id (VdrId), provenance, strength (Q16), scope_kb_id.

### VdrValue Resolution

Resolving a VdrId produces a VdrValue carrying the original VdrId, entry type, success flag, and exactly one non-null typed pointer. Current implementation: linear scan of config entries matching L1-L5 fields, then dispatch on entry_type for direct indexing (.data, .data_q335) or hashmap lookup (.fact, .relation).

### GEMM Contrastive Embedding Test (vdr_gemm_test.zig)

A per-KB embedding cache with contrastive training from typed relations.

**GemmCache structure:**
```zig
GemmCache {
    v_packed: []i32,    // entry_count × d_model, contiguous
    ids: []VdrId,       // entry_count, parallel to v_packed
    entry_count: i32,
    d_model: i32,
    kb_id: VdrId,
    kb_last_modified: i32,
    generation: i32,
}
```

**Operations:**
- `buildGemmCache`: allocates v_packed and ids arrays, initializes embeddings from deterministic hash of VdrId per dimension
- `trainFromRelationsWithArena`: contrastive training — for each relation pair, pulls from/to embeddings toward each other (proportional step), pushes from embedding away from a random negative sample (half-rate step). LCG PRNG for negative sampling. 50 epochs.
- `infer`: averages prompt token embeddings into query vector, computes dot product against all entries, returns top-N scored VdrIds with entity ID resolution

**Verified results on root.engineering.mechanical (279 entries, 176 relations, d_model=32):**
- EC4 (electric motor) query: 4/5 expected PM5-PM9 found in top 10
- HS5 (electrohydraulic servo system) query: 3/3 expected VL18, SN13, CT6 found in top 10
- Non-target results are structurally related entries sharing relation neighborhoods
- Cache memory: 35,712 bytes v_packed + 2,232 bytes ids = ~38 KB

### GEMM Transformer (vdr_gemm.zig)

A single-block transformer operating over VdrId vocabulary from KB data. All arithmetic in Q16 integer. Arena-allocated. No floats.

**GemmModel structure:**
```zig
GemmModel {
    vocab_size: i32,     // from KB data entry count
    d_model: i32,        // embedding dimensions (32 for test)
    seq_len: i32,        // context window (4 for test)
    ffn_dim: i32,        // feedforward hidden dim (64 for test)
    vocab_ids: []VdrId,  // index → VdrId mapping
    
    // Q16 weight matrices (arena-allocated slices)
    token_emb, pos_emb,              // embeddings
    wq, wk, wv, wo + biases,        // attention
    ffn1, ffn2 + biases,             // feedforward
    out_w, out_b,                    // output projection
    
    // i32 gradient accumulators (same shapes)
    wq_g, wk_g, wv_g, wo_g,
    ffn1_g, ffn2_g, out_g + bias grads,
    
    cache: *GemmForwardCache,        // reused per forward pass
}
```

**GemmForwardCache:** arena-allocated slices for all intermediate activations — embedded, Q/K/V projections, attention scores, softmax weights, attention output, residual sums, FFN pre/post ReLU, final logits. Indexed as flat arrays with stride-based 2D access.

**Forward pass pipeline:**
1. Token embedding + positional embedding (Q16 add with carry)
2. Q, K, V linear projections (i64 accumulator, divTrunc by D, remainder capture)
3. Attention scores (Q·K dot product per position pair, causal mask)
4. Softmax (quadratic surrogate with FRU — sums to D=65536 exactly)
5. Attention mix (weighted sum of V by softmax weights)
6. Wo output projection
7. Residual connection (embedding + attention output)
8. FFN layer 1 (linear, d_model → ffn_dim)
9. ReLU activation
10. FFN layer 2 (linear, ffn_dim → d_model)
11. Residual connection (post-attention + FFN output)
12. Output projection (linear, d_model → vocab_size)

All linear operations use i64 accumulator with divTrunc by D and remainder capture. All additions use Q16.add with r1→r0→v carry chain.

**Softmax (FRU):** Shifts inputs by minimum value. Computes squared shifted values with adaptive right-shift to prevent i64 overflow (shift amount computed from max value and count). First N-1 probabilities via divTrunc. Last probability = D minus sum of first N-1. Sum is exactly D regardless of precision loss from shifting.

**Backward pass:** Backpropagation from last position through all layers. Gradients flow through output projection, FFN (with ReLU backward), residual connections, attention mix, softmax backward, attention scores, Q/K/V projections. Weight gradients accumulated in i32 arrays. Gradient clipping at ±32767 before SGD update.

**SGD update:** `weight.v -= divTrunc(lr * clipped_gradient, D)` per weight element.

**Training windows:** Generated from typed relations. Each relation produces three windows:
- Half-padded forward: `[0, 0, from, from] → to`
- Half-padded reverse: `[0, 0, to, to] → from`
- Interleaved: `[from, to, from, to] → to`

**Inference:** Autoregressive greedy generation. Builds context window from last seq_len tokens. Forward pass produces logits. Softmax over vocab. Argmax selects next token index. Token index maps to VdrId via vocab_ids array. Repeat for max_tokens steps.

**Verified on root.engineering.mechanical (279 vocab, d_model=32, seq_len=4, ffn_dim=64):**
- Model creates and allocates successfully from real KB data
- Forward pass completes without arithmetic overflow
- Softmax sums to D=65536 exactly on all tested inputs
- Backward pass completes, gradients accumulate
- SGD updates weights
- Loss decreases with appropriate learning rate (LR=4096, init scale=512)
- Inference produces token sequences resolved to entity IDs
- Training convergence not achieved at current scale — expected without real training data (relations provide structural data, not sequence training data)

**Model memory for test configuration:**
- Embeddings: (279 + 4) × 32 × 8 = ~72 KB
- Attention weights: 4 × 32 × 32 × 8 = ~32 KB
- FFN weights: (64×32 + 32×64) × 8 = ~32 KB
- Output projection: 279 × 32 × 8 = ~71 KB
- Gradients: ~120 KB
- Forward cache: ~50 KB
- Total: ~377 KB

### HTTP Server

Listens on port 1138 (configurable). Non-blocking accept via `posix.poll` with 100ms timeout. Connection dispatch via atomic ring buffer to 4 handler threads. Handlers parse HTTP/1.1 requests, dispatch to handler module. Runner pool (4 runners) processes work via per-core atomic ring buffers. Currently echoes input as JSON.

Routes: `/run` submits to runner pool, `/shutdown` signals clean shutdown, all others return 404.

### Memory Layout

Global arena: 1 GB default. After loading 59 KBs with all data, GEMM caches, and transformer model: ~223 MB used, ~850 MB free.

Resetable scratch: 1 MB for TextBig formatting and Managed operations in HTTP path.

Arena allocator exposes `std.mem.Allocator` interface via vtable: alloc delegates to bump pointer, resize returns false, remap returns null, free is no-op.

### Current Data

59 compact files loaded from `data/kb_raw/`, totaling ~3.5 MB of source markdown across domains: physics, chemistry, biology, astronomy, climate, geography, zoology, neuroscience, anatomy, homeostasis, body mechanics, mathematics (foundation + logic), economics, philosophy, history (human + military tactics), law, cognition, movement, algorithms, data structures, zig, python, prolog, sqlite, c/python/zig interop, databases, FSMs, electronics, power grid, radio/cellular, mechanical engineering, construction, architecture, blacksmithing, masonry, fabrication, animal husbandry, gardening, forestry, cooking, camping, english grammar/phrasing/vocabulary, connections, classical literature, fantasy, heroic adventure, dramatic writing, art, accounting, project management, troubleshooting, scoring, builtins, spec, types.

Total loaded: 12,526 facts, 11,969 typed relations, 12,526 KBData entries. All 12,526 KBData entries verified to round-trip through getVdrValue.

### Verified Working

- Config loading from JSON
- Arena allocation and allocator vtable
- Compact file parsing (tables, rows, relationships, relation mappings)
- Relation type resolution (120+ types with per-file mapping fallback)
- KB tree creation with structural VdrId assignment from dotted paths
- Fact and relation LookupId minting and hashmap population
- KBData column population from pipe-delimited row text
- VdrId construction via makeItem, makeKb, makeChildKb
- VdrId structural field extraction via bitcast
- getVdrValue resolution for .kb, .data, .data_q335, .fact, .relation entry types
- Full round-trip verification: VdrId → getVdrValue → VdrValue.data → id match
- Q16 arithmetic with u16 remainders (add, sub, mul, div, compare, eql)
- GemmCache contrastive embedding: build, train from relations, infer with entity ID resolution
- GemmModel transformer: create from KB, forward pass, backward pass, SGD, softmax exact, greedy inference
- Softmax FRU summing to D=65536 exactly with overflow-safe adaptive shifting
- HTTP server with handler/runner thread pools
- Clean shutdown via /shutdown endpoint
