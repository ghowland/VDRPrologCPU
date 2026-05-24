## SNK (Structured Neural Knowledge) — Technical Specification v0.8

---

# PART A: CURRENT IMPLEMENTATION

### System Overview

SNK is an exact integer knowledge system with typed relation queries and a single-block transformer, written in Zig 0.15.1, targeting x86_64. CPU only. No floats. No GPU. No malloc after init. Arena-only memory. The system loads structured knowledge from pipe-delimited compact files, stores it in a tree of knowledge bases addressable by structural 64-bit integer IDs, queries knowledge through typed relation operations, trains and runs inference through an integer transformer over the KB vocabulary, and serves queries over HTTP.

### Architecture

16 source files, approximately 6,300 lines:

| File | Role | Lines |
|------|------|-------|
| vdr_types.zig | All type definitions, Q16 arithmetic, VdrId addressing, KB structs | ~1900 |
| root.zig | Main entry, KB loading, data population, verification, test orchestration | ~550 |
| vdr_prolog.zig | Typed relation queries: direct, reverse, inverse, symmetric, transitive closure | ~300 |
| vdr_gemm.zig | Single-block Q16 transformer: create, forward, backward, SGD, inference | ~750 |
| vdr_gemm_test.zig | Contrastive embedding: build, train, infer over GemmCache | ~350 |
| vdr_compact_loader.zig | Parses .md compact files into arena structures | ~450 |
| vdr_kb_config.zig | Loads/saves kb.json mapping dotted paths to files | ~200 |
| vdr_config.zig | Loads config.json into SystemConfig | ~130 |
| vdr_arena.zig | Creates/destroys page-allocated arenas | ~35 |
| resetable_memory.zig | Scratch arena with reset and std.mem.Allocator vtable | ~70 |
| vdr_http.zig | HTTP listener, connection handling, response writing | ~200 |
| vdr_http_accepter.zig | Connection ring buffer, handler thread pool | ~100 |
| vdr_http_handler.zig | Route dispatch, runner submission | ~60 |
| vdr_runner_pool.zig | Per-core work rings, runner threads | ~150 |
| text_big.zig | 100KB fixed-size text buffer | ~500 |
| text_small.zig | 64-byte fixed-size text buffer | ~500 |
| time_deep.zig | DeepTime u64 millisecond timestamps | ~40 |

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
11. Run contrastive embedding test (vdr_gemm_test.zig)
12. Run transformer test (vdr_gemm.zig)
13. Run typed relation query test (vdr_prolog.zig)
14. Spawn HTTP server on port 1138 with 4 handler threads and 4 runner threads
15. Wait for shutdown signal
16. Join all threads, free arenas, exit

### Addressing: VdrId

Signed 64-bit integer with structural bit encoding:

```
bit 63:     scope (0=global, 1=session)
bits 62-59: entry_type (u4, 16 types)
bits 58-52: L1 (u7, 127 usable, 127=sentinel)
bits 51-44: L2 (u8, 255 usable, 255=sentinel)
bits 43-36: L3 (u8, 255 usable, 255=sentinel)
bits 35-28: L4 (u8, 255 usable, 255=sentinel)
bits 27-20: L5 (u8, 255 usable, 255=sentinel)
bits 19-0:  item_id (u20, 1,048,575 per type per KB)
```

Zero-cost bitcast between VdrId (i64 wrapper) and VdrStructuralId (packed struct). Methods: `structural()`, `makeKb()`, `makeItem()`, `makeChildKb()`, `depth()`, `sameSubtreeL1/L2/L3()`, `entryType()`, `lookupId()`.

Positive = global (persistent). Negative = session (ephemeral). Zero = NONE.

### Entry Types

16 types occupying all u4 slots:

**Storage:** kb (0), data (1), data_q335 (2), fact (3), rule (4), constraint (5), grammar (6)

**Computation:** lru (7), counter (8), lock (9), queue (10), stack (11), ring (12), bitset (13)

**Structure:** iose (14), relation (15)

### Arithmetic: Q16

```zig
Q16 { v: i32, r0: u16, r1: u16 }
```

D = 65536 (2^16), implicit, never stored. r0 and r1 are unsigned — remainders from @mod by D are always non-negative (range 0..65535). Changed from i16 to u16 in v0.7 to eliminate sign overflow during carry propagation.

Operations: add (r1→r0→v carry chain), sub (borrow chain), mul (i64 widening, divTrunc/mod, cross-term r1), div (widened numerator, divTrunc/mod), compare (lexicographic v→r0→r1), eql. Q32 and Q335 exist for escalation.

Remainder is exact unresolved structure, not error. Every divTrunc captures its mod.

### KB Tree and Data

59 KBs loaded from compact files. Each KB gets a structural VdrId from its dotted path. L1/L2/L3 indices assigned by first-seen segment order.

Each KB holds nullable Managed array lists for all 16 entry types, KbLookup with per-type AutoHashMaps, and monotonic LookupId counters. KBData entries are direct-indexed by item_id.

KBData holds 4 Q16 numeric slots, 9 nullable text/value columns (TextSmall, 64 bytes each), and optional DeepTime timestamps.

### Compact Loading

Parses .md files with pipe-delimited tables. Recognizes table headers with column definitions, relationship sections with comma-separated targets, relation mapping sections for per-file canonical type aliases, and decode_legend sections (skipped).

130+ named relation types resolved through `nameToRelationType()` plus per-file mapping fallback.

### Relation Types

120+ types in 7 categories: structural (1000+), identity (2000+), knowledge (3000+), agency (4000+), logic (5000+), grammar (6000+), toolchain (7000+), plus domain-registerable slots at 1,000,000+.

Each type declares `inverse()`, `isSymmetric()` (16 symmetric types), `isTransitive()` (15 transitive types).

### VdrValue Resolution

`getVdrValue(config, id)` resolves a VdrId to a VdrValue with typed pointer. Current implementation: linear scan of config entries matching L1-L5 fields, dispatch on entry_type for direct indexing (.data, .data_q335) or hashmap lookup (.fact, .relation).

### Typed Relation Query Engine (vdr_prolog.zig)

L3 operations over loaded KB data. Zero arena allocation. All results stack-allocated (fixed capacity 64).

**Operations:**

| Function | Description | Mechanism |
|----------|-------------|-----------|
| queryRelation | "What does X enable?" | Linear scan, match from_id + rel_type |
| queryRelationReverse | "What requires Y?" | Linear scan, match to_id + rel_type |
| queryRelationInverse | "What depends_on X?" | Calls inverse() on rel_type, queries reversed direction |
| queryRelationSymmetric | "Does A prevent B?" | Checks both (A,B) and (B,A) if rel_type.isSymmetric() |
| queryTransitiveClosure | "What does X transitively enable?" | BFS over relation graph, visited set, max 256 entities |
| queryAllRelations | "Everything about X" | Scans all relations where entity appears as from or to |

**Entity description lookup:** resolves entity IDs to human-readable text via KBData text_column_0 through getVdrValue resolution chain.

**Verified results on root.engineering.mechanical (279 entries, 176 relations), 8/8 tests passed:**

- Direct: EC4 (electric motor) enables PM5-PM9 (5 motor types) ✓
- Reverse: HS2, HS3 require PU6 (piston pump) ✓
- Inverse: depends_on PM5 rewrites to PM5 enables PU1, CP2, CP3 ✓
- Transitive: EC4 → PM5 → PU1/CP2/CP3, EC4 → PM8 → AC6 (9 entities, 2 chain levels) ✓
- Symmetric: FM7 prevents PU1 = PU1 prevents FM7 ✓
- All relations: HS5 has 6 relations (3 requires, 3 inbound enables) ✓
- Specialization: VL18 → VL17 → VL16 (2 transitive steps) ✓
- Part_of: GR1, GR2, GR7 part_of DM2 (power transmission) ✓

### Contrastive Embedding Test (vdr_gemm_test.zig)

Per-KB embedding cache with contrastive training from typed relations.

**GemmCache:** v_packed (entry_count × d_model i32 values) + ids (entry_count VdrIds), parallel arrays. d_model=32 for test.

**Training:** For each relation pair, proportional pull toward each other, half-rate push away from random negative sample. LCG PRNG. 50 epochs.

**Inference:** Average prompt embeddings into query vector, dot product against all entries, top-N selection.

**Verified on root.engineering.mechanical:** EC4 query finds 4/5 of PM5-PM9 in top 10. HS5 query finds 3/3 of VL18, SN13, CT6 in top 10.

### Transformer (vdr_gemm.zig)

Single-block transformer over VdrId vocabulary. Q16 integer arithmetic throughout. Arena-allocated.

**Architecture:** token embedding + positional embedding → Q/K/V projection → causal attention → softmax (FRU, exact sum to D) → attention mix → Wo projection → residual → FFN (linear → ReLU → linear) → residual → output projection → logits over vocab.

**Backward pass:** full backpropagation through all layers. Gradient clipping at ±32767. SGD weight update.

**Softmax:** Quadratic surrogate with adaptive right-shift to prevent i64 overflow. FRU assigns deficit to last element. Sum = D exactly, verified on all test inputs.

**Training windows:** Generated from typed relations. Three windows per relation: half-padded forward, half-padded reverse, interleaved.

**Inference:** Autoregressive greedy generation. Forward pass, softmax, argmax, append, repeat.

**Verified on root.engineering.mechanical (279 vocab, d_model=32, seq_len=4, ffn_dim=64):**

- Model creates from real KB data ✓
- Forward pass completes without overflow ✓
- Backward pass completes, gradients accumulate ✓
- SGD updates weights ✓
- Softmax sums to D=65536 exactly ✓
- Inference produces token sequences resolved to entity IDs ✓
- Loss decreases with appropriate hyperparameters ✓
- Training convergence not achieved — expected without real sequence training data

### HTTP Server

Port 1138. Non-blocking accept via posix.poll. 4 handler threads, 4 runner threads. Atomic ring buffers for connection dispatch and work submission. Currently echoes input as JSON.

Routes: `/run` → runner pool, `/shutdown` → clean shutdown, else 404.

### Memory

Global arena: 1 GB. After full load + GEMM + transformer: ~223 MB used, ~850 MB free. Resetable scratch: 1 MB. Arena allocator via vtable: alloc = bump pointer, resize = false, remap = null, free = no-op.

### Current Data

59 compact files, ~3.5 MB source markdown, 12,526 facts, 11,969 typed relations, 12,526 KBData entries. All entries verified round-trip through getVdrValue. Domains: sciences, programming, engineering, trades, language, literature, business, system.

### Verified Working

- Config, arena, compact loading, relation resolution, KB tree, fact/relation population
- KBData column population, VdrId construction/extraction, getVdrValue resolution
- Full round-trip: VdrId → getVdrValue → VdrValue.data → id match (12,526/12,526)
- Q16 arithmetic with u16 remainders
- Typed relation queries: direct, reverse, inverse, symmetric, transitive closure (8/8)
- Entity description resolution through VdrId → KBData → text_column_0
- Contrastive embedding: build, train, infer with entity resolution
- Transformer: create, forward, backward, SGD, softmax exact, greedy inference
- HTTP with handler/runner thread pools, clean shutdown

---

# PART B: REMAINING WORK

### Training Data Pipeline

**Status:** Not started. This is the primary remaining work.

**What's needed:** Real text corpora processed into VdrId training sequences.

**Pipeline:**
1. Acquire training texts (books, manuals, documentation, conversation logs)
2. Prolog builtin strips each text to nouns, verbs, modifiers — removes articles, prepositions, conjunctions, punctuation, formatting
3. Surviving words resolve to VdrIds through prompt pipeline (atom table lookup, spell correction, disambiguation)
4. Source material metadata tags which KB groups the text belongs to (e.g., blacksmithing manual → root.trades.blacksmithing)
5. Per KB group, filter sequences to include only VdrIds present in that group's KBs
6. Filtered sequences become training windows for the transformer

**Training data format:** sequences of VdrId indices with source KB tagging and confidence levels from the source material type.

**Current gap:** No text stripping builtin exists. No atom table for word→VdrId resolution. No source tagging pipeline. The transformer training loop works mechanically but has no real sequence data to train on.

### Transformer Convergence

**Status:** Forward/backward pass verified. Loss decreases with tuned hyperparameters. Convergence not achieved on 279-vocab KB with synthetic training windows from typed relations.

**What's needed:**
1. Real sequence training data (from training pipeline above)
2. Hyperparameter tuning: learning rate, initialization scale, d_model, ffn_dim, seq_len for production vocab sizes
3. Possible loss function change — MSE against one-hot scales poorly to large vocabularies; cross-entropy equivalent in integer arithmetic, or direct logit margin loss
4. Multi-epoch training with convergence monitoring and early stopping

**Expected resolution:** Once real training sequences exist, the mechanical pipeline is proven. Tuning is iteration, not architecture.

### Dimension Selection

**Status:** d_model=32 used for test. Production value unknown.

**What's needed:** Empirical testing with real training data to determine minimum d_model that produces useful predictions for different KB sizes. 32 may be sufficient for 200-entry KBs but insufficient for 2000-entry KBs. The spec targets d_model=2048 for the full system but smaller values may work given that the vocabulary is rich tokens, not text fragments.

**Memory constraint:** d_model × vocab_size × 8 bytes per KB for embeddings alone. At d_model=128, a 500-entry KB costs 512 KB. At d_model=2048, it costs 8 MB. Per-KB GEMM scoping means only active KBs are loaded, so total memory depends on concurrent scope, not total KB count.

### Prompt Pipeline

**Status:** Not started. Defined in v0.5 spec as 7 stages.

**Stages:**
1. Content detection — pattern matchers scan raw input for JSON, YAML, code, CSV, XML
2. Code pattern matching — structural patterns via Prolog grammars
3. Tokenization — whitespace/punctuation boundary splitting
4. Spell correction — check against atom table, configurable aggressiveness
5. UUID resolution — tokens resolve via disambiguation map against KB tree
6. Disambiguation — typed relation co-occurrence narrows multiple candidates
7. Assertion to prompt_current — resolved tokens become VdrId reference facts

**Dependency:** Requires atom table (word→VdrId mapping) which does not yet exist.

### Atom Table

**Status:** Not started. KbStore has placeholder fields (atom_table_offset, atom_count, atom_capacity).

**What's needed:** A string→i32 mapping for all known words across all KBs. Each entity's text_column_0 name becomes one or more atoms. "AC induction motor" becomes atoms for "AC", "induction", "motor". The atom table enables prompt pipeline word resolution and Prolog functor matching.

### Prolog Engine (Full)

**Status:** Typed relation queries working (PL1-PL4 from spec). Full Prolog not started.

**What's remaining:**
- Unification — matching terms against rule heads with variable binding
- Backtracking — explicit search stack with rollback on failure
- Rule firing — scan rules, fire satisfied, assert derived facts
- Full depth-first search with configurable max depth
- Functor index for fast rule head lookup

**What works now:** The 4 typed relation fast paths that the spec says handle the vast majority of L3 queries. Direct scan, inverse rewrite, symmetric check, transitive BFS.

### Session System

**Status:** Session struct defined in vdr_types.zig. Not implemented.

**What's needed:** Per-core session arenas, ephemeral VdrId assignment, session lifecycle (create/snapshot/kill/restore), _llm.* subtree for prompt state, session-scoped KB shadows.

### Grant/Security System

**Status:** Grant struct defined. Not implemented.

**What's needed:** Grant CRUD, per-session access checks, audit logging. The structural security model — GEMM can predict any VdrId but execution requires grant — depends on this.

### GEMM Scoping

**Status:** Single-KB caches working. Cross-KB scoping not implemented.

**What's needed:** Given a prompt context, extract structural prefixes from VdrIds, find all KB subtrees that match, build a GemmScope of active caches. The spec describes this as SU6: one AND + one CMP per cache eliminates irrelevant subtrees.

### Persistence

**Status:** Compact file loading only. No save/restore.

**What's needed:** .kb serialization (KB + facts + relations + UUID maps), .wt weight files, .snap session snapshots, manifest.dat, lazy loading of unaccessed KBs.

### Grammar Engine

**Status:** GrammarRule struct defined. Not implemented.

**What's needed:** Sentence template compilation, slot filling from VdrId resolution, paragraph template matching from concept signatures, register-scoped vocabulary selection. This is the presentation layer that turns VdrId arrays into readable output.

### Scoring Engine

**Status:** ResponseCurve, Consideration, Behavior, BehaviorSet structs defined. Not implemented.

**What's needed:** Dave Mark utility AI scoring — curves, compensation, selection methods. This drives behavior selection when multiple actions are available.

### FSM Engine

**Status:** Fsm struct defined. Not implemented.

**What's needed:** State management, transition evaluation via Prolog rules, behavior set binding per state.

### SIMD Operations

**Status:** All arithmetic is scalar. AVX2 not implemented.

**What's needed:** 8-wide i32 GEMM, SIMD softmax, SIMD RMSNorm, SIMD attention. The spec requires SIMD and scalar to produce bit-identical results (IN11).

### Multi-Head Attention

**Status:** Single head in current transformer. 

**What's needed:** Split d_model into n_heads × d_head, parallel attention computation per head, concatenate and project. The spec targets 12 heads × 170 d_head.

### Model Scaling

**Status:** Test model is 279 vocab, d_model=32, 1 layer, 1 head. 

**What's needed:** Scale to spec targets: N vocab (all VdrIds), d_model=2048, 6 layers, 12 heads, 170 d_head, 2048 mlp_dim. ~143M parameters. The arithmetic and memory patterns are proven at small scale; scaling is engineering.
