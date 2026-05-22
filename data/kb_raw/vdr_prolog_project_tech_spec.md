**Step 1 — Plan**

**Source character:** Architecture spec + schema spec + operational patterns. Central structures are commitments, components, data types, flows, boundaries, invariants, and configuration. Heavily structured source with appendices containing reference tables already in near-tabular form.

**Proposed table set:**

- `principles(id|principle|rationale|enforced_by)` — system commitments (no float, no malloc, arenas only, etc.)
- `components(id|component|description|file|role)` — system components and engines
- `data_types(id|type|fields|size_bytes|alignment|purpose)` — Q16, Q32, Fact, KB, Term, Rule, TypedRelation, etc.
- `arithmetic(id|operation|formula|remainder_handling|escalation)` — Q16/Q32 operations
- `arenas(id|arena|size|contents|reset_policy)` — memory architecture
- `id_system(id|concept|description|resolution)` — VdrId, sign-bit, three-level addressing
- `kb_tree(id|path|seed_id|content|frozen)` — seed KB tree structure
- `http_system(id|component|description|threading|notes)` — HTTP, work queue, session lifecycle
- `compute(id|operation|simd_path|scalar_path|remainder|invariant)` — GEMM, softmax, RMSNorm, attention, SiLU
- `model(id|concept|description|value|notes)` — model architecture, weight storage, three-path retrieval
- `inference(id|phase|description|level|token_cost)` — inference loop, execution levels
- `prolog(id|component|description|mechanism|cost)` — unification, typed relation fast path, transitive closure
- `relation_types(id|slot|name|inverse|symmetric|transitive|usage)` — system-defined relation properties
- `ingestion(id|stage|description|input|output)` — compaction pipeline stages
- `confidence(id|source_type|fraction|q16_v|notes)` — confidence table
- `persistence(id|component|format|contents|notes)` — file formats, lazy loading, snapshots
- `config(id|field|type|default|notes)` — key config fields
- `errors(id|code|value|category|recovery)` — error codes
- `invariants(id|number|statement|enforced_in)` — all 35 invariants
- `build_stages(id|stage|files|validation)` — build order
- `impl_stages(id|stage|lines|files|description)` — implementation stages
- `files(id|file|sections|description)` — implementation files
- `fsm(id|concept|description|representation|notes)` — FSM integration
- `scoring(id|concept|description|formula|notes)` — UAI scoring integration
- `pipeline(id|step|description|level|notes)` — unified decision pipeline
- `structs(id|struct|size|alignment|cache_lines|notes)` — struct sizes
- `test_vectors(id|operation|inputs|expected|notes)` — Q16 test vectors
- `relationships(from|rel|to)`
- `section_index(section|title|ids)`
- `decode_legend`

**ID prefixes:** PR=principle, CO=component, DT=data_type, AR=arithmetic, AM=arena/memory, IS=id_system, KT=kb_tree, HT=http_system, CM=compute, MD=model, IF=inference, PL=prolog, RT=relation_type, IG=ingestion, CF=confidence, PS=persistence, CG=config, ER=error, IN=invariant, BS=build_stage, IM=impl_stage, FI=file, FS=fsm, SC=scoring, PX=pipeline, ST=struct, TV=test_vector

**Compression strategy:** The appendices are already near-tabular — these compress by reformatting, not by removing content. The prose sections (1, 2, 9.3, A1, A2, A6, A10) compress heavily. All numeric values preserved exactly. All struct fields preserved. All invariants preserved verbatim.

**Estimated compression:** ~75-80% — this is a schema/architecture spec, already fairly structured.

Ready to write — proceeding immediately per standing agreement.

# VDR-PROLOG TECHNICAL SPECIFICATION v0.4 + ADDENDUM — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: principles → id_system → data_types → arithmetic → arenas → kb_tree → components → http_system → compute → model → inference → prolog → relation_types → ingestion → confidence → scoring → fsm → pipeline → persistence → config → errors → invariants → structs → test_vectors → build_stages → impl_stages → files → relationships → section_index

# principles(id|principle|rationale|enforced_by)
PR1|no float anywhere|integer in, integer through, integer out — no f32/f64 in arithmetic, HTTP, timing, logging|IN6, build.zig
PR2|no malloc after init|one bounded exception: temporary training arenas, destroyed after use|IN12, vdr_training.zig
PR3|remainder is not error|every divTrunc captures its mod — discarding remainder is the bug float normalized|IN1, vdr_ops.zig
PR4|arena-only memory|fixed-size contiguous blocks, bump pointer, no free, no reuse until reset|vdr_arena.zig
PR5|no coordination on hot path|per-thread GEMM, no row splitting, no barrier, no mutex, no IPC|IN23, vdr_ops.zig
PR6|sign-bit partitions address space|bit 63 = 0: global (positive, persistent); bit 63 = 1: session (negative, ephemeral)|IN8, vdr_types.zig
PR7|session data dies with session|arena reset → all session data gone instantly, no traversal, no fragmentation|IN9, vdr_session.zig
PR8|weights live where they serve|no separate model tree — weights in domain KBs alongside facts and rules|vdr_model.zig
PR9|typed relations bypass unification|enum dispatch, not term construction — sub-microsecond integer scans|IN20, vdr_relation.zig
PR10|compaction reduces model size|every typed relation ingested is a reasoning op the NN does not need to learn|spec §9.3
PR11|SIMD and scalar bit-identical|AVX2 and scalar paths produce identical output bytes|IN11, vdr_test.zig
PR12|model weights are i16|2 bytes per param for v, plus 2 bytes r0, 2 bytes r1 = 8 bytes per param total|vdr_types.zig (WeightMatrix)
PR13|system scalability via per-core isolation|adding cores adds concurrent sessions linearly with zero coordination|spec §7.2

# id_system(id|concept|description|resolution)
IS1|VdrId|i64 with sign-bit partitioning — 0 is none|isGlobal (v≥0), isEphemeral (v<0), isNone (v==0), eql (a.v==b.v)
IS2|global ID|bit 63=0, positive, persistent, shared across sessions|UUID with bit 63 cleared, generated from counter + hash
IS3|session ID|bit 63=1, negative, session-local, dies with session|decrement from -1 within each session, never collide
IS4|UUID addressing|signed i64, O(1) lookup table|canonical identifier
IS5|dotted path addressing|hierarchical walk from root|root.science.physics.qed.alpha_em (global), session_root._llm.prompt_last (session)
IS6|local index addressing|array slot within a KB|facts[0] within specific KB
IS7|resolution order|session first, then global|session data shadows global at junction point
IS8|promotion|session → global is explicit|session data never leaks to global implicitly

# data_types(id|type|fields|size_bytes|alignment|purpose)
DT1|Q16|v:i32, r0:i16, r1:i16|8|4|primary arithmetic type, D=65536 (2^16) implicit
DT2|Q32|v:i64, r0:i32, r1:i32|16|8|Newton-Raphson, escalated computations, D=2^32
DT3|Q335|v:[6]i64, r0:[6]i64, r1:[6]i64, r2:[6]i64, r3:[6]i64|240|8|physics, transcendentals, D=2^335, 4 remainder slots
DT4|VdrId|v:i64|8|8|universal entity identifier with sign-bit partitioning
DT5|Fact|tag:FactTag, value:Q16, provenance:Provenance|48|8|atomic unit of knowledge, padded for alignment
DT6|FactTag|enum|—|—|empty, value, text, reference, timestamp, enum, boolean, vector, matrix, provenance, rule_ref, grammar_ref, counter, relation, column_schema
DT7|Provenance|source_type:i32, source_kb_id:VdrId, source_slot_id:i32, confidence:Q16, timestamp:i32, derivation_rule_id:i32, capability_level:i32|36|8|every Fact carries full provenance, capability_level for per-weight access control
DT8|KB|identity + persistent stores + weight refs + typed relations + domain rel defs + compaction provenance + live state + children + training + metadata|256|8|exactly 4 cache lines, tree node, holds facts/rules/weights/grammars/relations
DT9|Term|type:TermType, primary_id:i32, secondary_offset:i32, secondary_aux:i32, vdr_value:Q16|24|4|Prolog term — atom, variable, integer, vdr, text, list, compound, vector, matrix, pair
DT10|Rule|id:VdrId, head:i32, body_offset:i32, body_count:i16, action_offset:i32, action_count:i16, fire_count:i32, last_fired:i32, success_count:i32, failure_count:i32, created_at:i32, creator_session_id:VdrId|48|8|Prolog rule with own statistics
DT11|TypedRelation|rel_type:RelationType(i16), from_id:VdrId, to_id:VdrId, provenance:Provenance, strength:Q16, scope_kb_id:VdrId|48|8|first-class typed edge between entities
DT12|RelationIndex|by_type_counts:[128]i32 + sorted indices by_from and by_to|528|4|acceleration structure — count per type is single i32 read
DT13|DomainRelationDef|slot:i16, name_offset:i32, name_length:i16, is_symmetric:bool, is_transitive:bool, inverse_slot:i16, registered_by:VdrId, registered_at:i32|32|8|domain relation type registered during ingestion
DT14|CompactionProfile|source_tables:[128]bool + 12 integer metrics + estimated_l3_coverage:Q16|256|4|ingestion provenance, immutable after creation
DT15|WeightMatrix|v:[]i32, r0:[]i16, r1:[]i16, rows:i32, cols:i32|~32|8|SoA layout, v is GEMM-ready cache-line aligned, column-major
DT16|Arena|base:[*]u8, size:usize, cursor:usize|—|—|fixed-size contiguous block, bump pointer, alloc/reset
DT17|Session|~25 fields: identity, core binding, resource limits, counters, snapshot/clone lineage|~200 (padded to 256)|8|persistent across HTTP disconnects, LRU ejectable
DT18|Grant|~12 fields: authorization token with usage limits and expiry|~80|8|per-command access control
DT19|AuditEntry|~9 fields: security-relevant action record|~44|8|ring buffer entries
DT20|Command|~7 fields: parsed LLM command (15 types) with grant requirements|~24|4|LLM command dispatch
DT21|GemmCache|slice + 4 fields|~32|8|packed v_data for fast GEMM path
DT22|KbWeightRefs|weight_refs_offset|—|—|links KB to its WeightMatrix structs

# arithmetic(id|operation|formula|remainder_handling|escalation)
AR1|Q16 addition|r1 sums first, carries into r0, r0 carries into v|no information lost — full carry chain|n/a
AR2|Q16 multiplication|product = i64(a.v × b.v), v = divTrunc(product, D), r0 = mod(product, D), r1 from cross-terms a.r0×b.v + b.r0×a.v|cross-terms captured in r1|n/a
AR3|Q16 division|widened = a.v × D, v = divTrunc(widened, b.v), r0 = mod(widened, b.v), r1 from r0×D/b.v|worse than multiplication for remainder accumulation — divisors not factoring into D push r1 toward saturation|r1 near ±32767 → escalate to Q32
AR4|Q16 comparison|lexicographic across v, r0, r1|no epsilon — equal means all three fields match|n/a
AR5|precision sentinel|r1 near ±32767|indicates remainder saturation|escalate to Q32 for that computation path
AR6|i64 accumulation|all multiplications widen to i64 before computing|prevents overflow in GEMM dot products (K=2048)|IN5

# arenas(id|arena|size|contents|reset_policy)
AM1|global arena|~1.27 GB|model weights (~572 MB v+r0+r1), seed KBs (~2 MB), KB store (~25 MB), fact store (~480 MB), typed relations (~50 MB), relation indices (~10 MB), rules/terms/text (~93 MB), grants/audit (~33 MB), compaction profiles (~2 MB), confidence table (88 bytes)|never reset — persistent for process lifetime
AM2|per-core arena|~220 MB each (×N cores)|session table, session KBs, session facts, KV cache, scratch buffers, binding buffers, render buffers, work queue|region reset on session death — cursor=0
AM3|temporary training arena|sized per-KB (10 KB to ~176 MB)|gradients with r0/r1, optimizer state (momentum, variance), activations, transposed weights, scratch|destroyed after training, pointer nulled, lock released
AM4|system total (8 cores)|~3.03 GB (1.27 + 8×220 MB)|fits in 8 GB with room for OS, 16 GB laptop has 13 GB free|n/a

# kb_tree(id|path|seed_id|content|frozen)
KT1|root|+1|tree root|no
KT2|root.system|+2|system KB parent|yes
KT3|root.system.oso|+3|15 engineering principles|yes
KT4|root.system.confidence|+4|confidence table as facts (11 entries)|yes
KT5|root.system.builtins|+5|448 IOSE declarations across 22 categories|yes
KT6|root.system.command_vocab|+6|~300 command token definitions|yes
KT7|root.system.hygiene|+7|~50 self-maintenance Prolog rules|yes
KT8|root.system.embedding|+8|vocab embedding WeightMatrix (8192×2048)|yes
KT9|root.system.output|+9|lm_head WeightMatrix + final norm WeightVector|yes
KT10|root.templates|+10|template parent|yes
KT11|root.templates.sentences|+11|~100 sentence-level grammar templates|yes
KT12|root.templates.formats|+12|~50 output format templates|yes
KT13|root.system.relation_types|+13|system-defined (frozen) + domain-registered (appendable)|no (appendable)
KT14|root.system.ingestion|+14|ingestion queue + CompactionProfile records|no
KT15|root.system.scoring|+15|behavior sets for system decisions|no
KT16|root.system.fsm|+16|system-level FSM definitions|no

# components(id|component|description|file|role)
CO1|arena allocator|fixed-size contiguous blocks, bump pointer, ArenaSet|vdr_arena.zig|memory foundation
CO2|config loader|JSON → SystemConfig, strict errors, no silent defaults|vdr_config.zig|configuration
CO3|thread pool|NUMA-pinned compute threads, spin-wait, first-touch|vdr_thread_pool.zig|compute isolation
CO4|HTTP listener|non-pinned thread, accepts connections, spawns handlers|vdr_http.zig|I/O boundary
CO5|work queue|per-core atomic ring buffer, lock-free, push/pop|vdr_work_queue.zig|I/O→compute bridge
CO6|KB store|KB CRUD, fact/rule/term stores, path index, session resolution|vdr_kb_store.zig|data storage
CO7|SIMD ops|AVX2 GEMM, dot, softmax, RMSNorm, attention, SiLU|vdr_ops.zig|hot-path compute
CO8|model engine|KB-distributed weights, three-path retrieval, forward pass|vdr_model.zig|weight management
CO9|Prolog engine|unification, query, rule firing, backtracking, typed relation fast path|vdr_prolog.zig|reasoning
CO10|relation engine|RelationIndex, typed queries, transitive closure, inverse, domain registration|vdr_relation.zig|structural reasoning
CO11|grammar engine|template compile, render, inherit|vdr_grammar.zig|output formatting
CO12|inference engine|full inference loop, prompt cycle, L1/L2/L3|vdr_inference.zig|orchestration
CO13|ingestion engine|parser, validator, KB assertion, relation assertion, domain type registration|vdr_ingestion.zig|data intake
CO14|training engine|canTrain, train, temporary arenas, weight update, provenance|vdr_training.zig|learning
CO15|persistence engine|save/load KB/weight files, manifest, lazy loading|vdr_persist.zig|durability
CO16|snapshot engine|session snapshots, save/restore, CRC32|vdr_snapshot.zig|session durability
CO17|scoring engine|response curves, considerations, behaviors, compensation, selection|vdr_scoring.zig|utility AI
CO18|FSM engine|state management, transition evaluation, state→behavior_set|vdr_fsm.zig|state machines
CO19|access engine|visibility, session/global resolution, per-group weight access|vdr_access.zig|authorization
CO20|grant engine|grant CRUD, check, cleanup|vdr_grant.zig|authorization tokens
CO21|audit engine|ring buffer, query, filter|vdr_audit.zig|security logging
CO22|confidence engine|assign, combine, chain, propagate|vdr_confidence.zig|trust tracking
CO23|seed engine|seed layer init, domain weight KB creation|vdr_seed.zig|bootstrap
CO24|builtin engine|448 builtins, IOSE validation, dispatch|vdr_builtin.zig|operations
CO25|command engine|command parser, executor, dispatch|vdr_command.zig|LLM command interface
CO26|session engine|session lifecycle, _llm.* subtree, clone/merge/kill|vdr_session.zig|session management
CO27|system engine|top-level init, wire everything|vdr_system.zig|orchestration

# http_system(id|component|description|threading|notes)
HT1|listener|one non-pinned thread on configurable port (default 1138)|non-pinned|spawns handler threads per connection
HT2|handler|parse JSON, resolve client/session, build work item, push to per-core queue, spin-wait on completion|non-pinned|never does SIMD — compute threads never touch network
HT3|work queue|VdrWorkQueue: items[QUEUE_CAPACITY], atomic head/tail, lock-free ring|bridging|queue full → HTTP 503 (backpressure)
HT4|session binding|session bound to core at creation, all requests route to that core|per-core|sessions persist across HTTP disconnects
HT5|session lifecycle|creation clones from template with _llm.* subtree (COW), LRU ejects coldest on limit, snapshot before eject|per-core|reconnection restores from snapshot, dies on explicit kill/admin/hygiene purge
HT6|_llm.* canonical subtree|prompt_last, prompt_next, prompt_input, prompt_current, history, projects, people, concepts, search, scratchpad|fixed structure|LLM does not create new top-level KBs here — data goes inside as children

# compute(id|operation|simd_path|scalar_path|remainder|invariant)
CM1|GEMM dot product|8×i32 → 2×4×i64 widen-madd-accumulate, tail elements scalar|same logic|r0 from final divTrunc by D, r1=0|IN1, IN5, IN11
CM2|GEMM output|single divTrunc of i64 accumulator|same|r0 = mod(sum, D)|IN1
CM3|softmax max scan|8×i32 horizontal max, tail scalar|same|no remainder (integer max)|n/a
CM4|softmax exp|scalar table lookup|same|per-element exact|n/a
CM5|softmax prob|scalar integer division|same|per-element r0 = mod(exp×D, total)|IN3
CM6|softmax FRU|scalar: find max remainder, assign deficit to it|same|deficit = D - sum(probs), assigned to element with largest truncation loss|IN3 — sum == D == 65536 exactly, every time
CM7|RMSNorm variance|8×i32 square + accumulate in i64, tail scalar|same|r0 on mean|IN5
CM8|RMSNorm inv_sqrt|scalar Newton-Raphson in Q32, 4 iterations|same|Q32 → Q16 conversion captures r0|IN7 check
CM9|RMSNorm scale|8×i32 multiply (input × inv_rms × gamma), tail scalar|same|r0 from final divTrunc|IN1
CM10|SiLU activation|scalar piecewise integer approximation|same|r0 on each element|n/a
CM11|residual add|8×i32 add, tail scalar|same|full r1→r0→v carry chain per element|IN2
CM12|attention Q·K dot|8×i32 widen-madd, tail scalar|same|r0 on final result|IN5
CM13|attention weighted V sum|8×i32 multiply + accumulate, tail scalar|same|r0 on final result|IN5

# model(id|concept|description|value|notes)
MD1|d_model|embedding dimension|2048|unchanged from conventional
MD2|n_layers|transformer layers|6|reduced from 16 — multi-hop → Prolog transitive closure
MD3|n_heads|attention heads|12|reduced from 16 — typed relation enum dispatch replaces some
MD4|d_head|per-head dimension|170|increased from 128 — fewer heads, each wider
MD5|mlp_dim|MLP hidden dimension|2048|reduced from 5632 — facts in KBs, not weight patterns
MD6|vocab_size|vocabulary size|8192|reduced from 32000 — grammar rendering replaces token generation
MD7|total_params|parameter count|~143M|reduced from ~1B (85.7% reduction)
MD8|weight_memory|i16 weight storage|~286 MB|v=i16 (2 bytes) per param, plus r0=i16, r1=i16
MD9|per_token_MACs|compute per token|~126M|reduced from ~640M
MD10|single_core_tok_s|throughput one core|~190|at AVX2 ~24 GMAC/s, ~5.3ms per token
MD11|system_tok_s_8core|system throughput|~1520|8 cores × ~190, 8 concurrent sessions
MD12|effective_req_s|with 93% L3|~21700|~1520 / 0.07 — most requests never invoke forward pass
MD13|three-path retrieval|weight access methods|path 1: full fact scan (slow, new KB); path 2: GEMM cache only (hot path); path 3: cache + new facts|per-group GEMM copies for access tiers
MD14|layer 1-2 role|token embedding, positional encoding, basic syntactic patterns|understanding what was said|reads embedding from root.system.embedding
MD15|layer 3-4 role|semantic understanding, intent classification, KB address resolution, command recognition|deciding what to do about it|resolves which KBs and rules are relevant
MD16|layer 5-6 role|output planning, response strategy, judgment calls, ambiguity|deciding how to respond|handles what L3 cannot

# inference(id|phase|description|level|token_cost)
IF1|write input|system writes user input to prompt_input|—|0
IF2|read context|LLM reads prompt_last + prompt_input + other KBs|—|0
IF3|resolve weights|resolve visible model weights (grant-gated)|—|0
IF4|forward pass|single core SIMD GEMM per layer|L1|—
IF5|generation loop|command tokens → execute; direct output → KB read + grammar render; prose tokens → output buffer; end-of-turn → break|L1/L2/L3|variable
IF6|copy continuity|system copies prompt_next → prompt_last, clears transients|—|0
IF7|post-processing|turn counter, token counter|—|0
IF8|auto-snapshot|snapshot if interval reached|—|0
IF9|L1 — full forward pass|no stored rule covers it|L1|50-500 tokens
IF10|L2 — LLM invokes stored rule|LLM selects, Prolog executes|L2|~18 tokens (~3% of L1)
IF11|L3 — automatic Prolog/relation firing|typed relation queries, transitive closure, inverse lookup, grammar render|L3|0 tokens (93% of ops at maturity)

# prolog(id|component|description|mechanism|cost)
PL1|general unification|atom-atom by ID match, variable-anything creates binding, VDR-VDR all three Q16 fields match, compound recursive|direct function calls into arena memory, depth-first backtracking via explicit stack in per-core scratch|L1 or L2
PL2|typed relation fast path|queries matching rel_type(from, to) bypass unification|check by_type_counts → if 0, skip KB → scan contiguous TypedRelation array → filter by from/to|L3 — sub-microsecond integer scan, no term construction, no binding stack
PL3|transitive closure|BFS over contiguous integer arrays for transitive types|enables, requires, specializes, generalizes, part_of, contains, follows, precedes, depends_on, extends|L3 — zero tokens
PL4|inverse dispatch|switch on enum — compile-time known|querying enables(X, target) automatically also queries depends_on(target, X)|L3
PL5|symmetry dispatch|symmetric types auto-query with from/to swapped|prevents, contradicts, equivalent_to, approximates|L3
PL6|session-first search|session tree searched first, then global|scoped search walks parent chain — session shadows global at junction|L3

# relation_types(id|slot|name|inverse|symmetric|transitive|usage)
RT1|0|enables|depends_on|no|yes|X makes Y possible
RT2|1|requires|enables|no|yes|X cannot exist/work without Y
RT3|2|prevents|prevents|yes|no|X blocks/forbids Y
RT4|3|implements|unknown|no|no|X is concrete realization of Y
RT5|4|extends|generalizes|no|yes|X adds capability to Y
RT6|5|overrides|unknown|no|no|X replaces Y's behavior in scope
RT7|6|validates|verified_by|no|no|X confirms Y correct
RT8|7|verified_by|validates|no|no|Y confirmed by X
RT9|8|contradicts|contradicts|yes|no|X and Y cannot both hold
RT10|9|causes|determined_by|no|no|X directly produces Y
RT11|10|determined_by|causes|no|no|Y's value fixed by X
RT12|11|depends_on|enables|no|yes|X needs Y to function
RT13|12|equivalent_to|equivalent_to|yes|no|X and Y interchangeable
RT14|13|approximates|approximates|yes|no|X and Y close but not identical
RT15|14|specializes|generalizes|no|yes|X is more specific form of Y
RT16|15|generalizes|specializes|no|yes|X is more general form of Y
RT17|16|part_of|contains|no|yes|X is component inside Y
RT18|17|contains|part_of|no|yes|Y is component inside X
RT19|18|follows|precedes|no|yes|X comes after Y
RT20|19|precedes|follows|no|yes|X comes before Y
RT21|64-127|domain slots|per-registration|per-registration|per-registration|first-come, never reassigned, properties declared at registration

# ingestion(id|stage|description|input|output)
IG1|external LLM compaction|raw document → LLM → .compact file (pipe-delimited tables)|raw document|.compact file at llm_generated trust (30/100)
IG2|validation|all IDs unique, all relationship targets exist, column counts match headers, decode legend present|.compact file|validated structure
IG3|KB creation|parent document KB + child KB per table|validated structure|KB subtree
IG4|fact assertion|text cells → TAG_TEXT facts, numeric cells → TAG_VALUE facts, column schema facts mark table structure|KBs|populated facts
IG5|relation and rule assertion|relationships → TypedRelation structs + Prolog rules, multi-target and range notation expanded, domain relation types registered|relationships table|TypedRelation + Rule records
IG6|profile and freeze|CompactionProfile recorded, KBs frozen if configured|completed ingestion|immutable profile

# confidence(id|source_type|fraction|q16_v|notes)
CF1|vdr_computation|1/1|65536|system computed, no external dependency
CF2|prolog_derivation|1/1|65536|derived from rules with 1/1 inputs
CF3|database|98/100|64225|structured, schema-validated, occasionally stale
CF4|prometheus|95/100|62259|metrics pipeline, sampling granularity
CF5|script|95/100|62259|deterministic authored code, bugs possible
CF6|rest_api|85/100|55705|external service, versioning, schema drift
CF7|published|80/100|52428|peer reviewed, still human error
CF8|user_stated|70/100|45875|human assertion, no verification
CF9|web_search|50/100|32768|unverified internet, SEO manipulation
CF10|llm_generated|30/100|19660|hallucination risk, no ground truth
CF11|unknown|0/1|0|no provenance, no trust
CF12|chain rule|min(a, b)|—|weakest link in derivation chain
CF13|parallel agree|max(a, b)|—|strongest supporting source wins
CF14|contradiction|0|—|sources disagree → zero confidence
CF15|derivation|min(inputs) if rule confidence=1/1|—|Prolog derivation inherits minimum
CF16|promotion|direct_set|—|admin verifies → higher level
CF17|ingestion combined|min(source_type, compaction_stage)|—|compaction always weakest link until verified

# scoring(id|concept|description|formula|notes)
SC1|response curve|mathematical function mapping raw input [0,1] → [0,1] utility score|linear, quadratic, polynomial, sigmoid, log, exp, Gaussian, step, smoothstep, piecewise, etc.|shape determines sensitivity distribution across input range
SC2|consideration|single input axis mapped through response curve to produce score|input_axis → normalize → curve → [0,1] score|atomic evaluation unit
SC3|behavior|candidate action scored by combining its considerations|set of considerations + weight + action|the thing being selected
SC4|behavior set|collection of behaviors valid in current FSM state|state → behavior set mapping|evaluated by reasoner
SC5|reasoner|evaluates all behaviors in set, selects winner|single-bucket, dual-bucket, weighted random, categorical, hierarchical, parallel|the decision-maker
SC6|compensation (Dave Mark)|modification_factor = (1-1/n), make_up = (D-score_i) × mf / D, compensated_i = score_i + (make_up × score_i / D), final = ∏(compensated_i)|prevents single low score from zeroing entire behavior via multiplication|computed in Q16, epsilon floor (v=655 ≈ 1%) prevents true-zero veto
SC7|gate consideration|binary pass/fail prerequisite|score 0 or 1 via step curve|evaluated separately from soft preferences, does not participate in compensation
SC8|selection methods|argmax (greedy), weighted random, top-N, Boltzmann/softmax, hysteresis/momentum, priority interrupt, commitment/minimum duration, threshold gate|selection after scoring|argmax is deterministic, weighted random uses session PRNG seeded from session ID + turn count
SC9|items_seen_by_llm counter|tracks how many prompt_current items LLM has read|items_total - items_seen_by_llm = unread count|two i32 facts, reset to 0 when prompt_current cleared at cycle boundary

# fsm(id|concept|description|representation|notes)
FS1|FSM as KB subtree|machine definition, states, transitions, outputs are facts and rules|root.system.fsm.{name} with children: transitions (rules KB), outputs (state→behavior_set facts)|current_state is mutable TAG_VALUE fact
FS2|Moore (output per state)|state determines behavior set — doesn't change until state changes|session lifecycle, KB lifecycle, inference cycle|most common system FSM type
FS3|Mealy (output per transition)|transition determines action — fires during transition|HTTP request lifecycle|action executes immediately on transition
FS4|DFA (recognition)|accepts or rejects input patterns|query classification (L3/L2/L1 level selection)|terminal states classify query
FS5|statechart (hierarchical + concurrent)|nested states with parallel regions|complex domain AI (boss AI with strategic/tactical/moment)|uses extends relation on base Moore/Mealy
FS6|transition evaluation|Prolog rules checked on every cycle — rule head: evolves_to(CurrentState, NextState), body: conditions|evaluateTransitions scans rules, checks from_state match, satisfies body|fires first matching transition
FS7|state update|previous_state ← current_state, current_state ← new, timestamp updated, count incremented, logged to prompt_current|atomic within pinned compute thread|Mealy: output action fires immediately; new behavior set active next cycle
FS8|session lifecycle FSM|created → active ↔ suspended → ejected ↔ active → killed|root.system.fsm.session_lifecycle|transitions fire on session counters, timestamps, arena pressure
FS9|HTTP request lifecycle FSM|received → parsed → queued → processing → responded (+ error states)|root.system.fsm.http_lifecycle|Mealy — actions per transition
FS10|inference cycle FSM|input → read → resolve_weights → forward → generate → postprocess → snapshot_check → cycle|root.system.fsm.inference_cycle|Moore — engine function per state
FS11|level selection FSM|query_received → classify_l3 → (execute_l3 &#124; classify_l2) → (execute_l2 &#124; execute_l1)|root.system.fsm.level_selection|DFA — classifies query to execution level
FS12|KB lifecycle FSM|unloaded → loading → loaded ↔ training → loaded → frozen, loaded ↔ saving → loaded|root.system.fsm.kb_lifecycle|Moore — valid operations per state
FS13|session-local FSMs|conversation phase, task tracker, domain-specific|session_root._llm.fsm.{name}|die with session (negative IDs), snapshotted/restored

# pipeline(id|step|description|level|notes)
PX1|pre-resolution|classify query pattern, attempt typed relation query / Prolog rule if L3 candidate|L3 if match|log result to prompt_current
PX2|FSM evaluation|check transition rules for all active FSMs, update state if fires|L3|resolve current behavior set from current state
PX3|UAI scoring|evaluate behavior set, select winner via compensated multiplication + selection method|L3|log scores and winner to prompt_current
PX4|execution — L3 complete|pre-resolution answered query → LLM frames response|L3|~20 tokens framing
PX5|execution — direct action|UAI winner has Prolog query, builtin call, or KB assert → execute, log, LLM frames|L2-L3|action at L3, framing ~20 tokens
PX6|execution — defer to LLM|UAI winner is defer_to_llm or score below threshold|L1|50-500 tokens
PX7|LLM generation|reads prompt_last + prompt_current (new items), generates response, writes prompt_next|L1/L2|can accept, override, augment, or escalate mechanical result
PX8|post-generation|re-evaluate FSM transitions, copy prompt_next → prompt_last, clear transients|L3|counters reset

# persistence(id|component|format|contents|notes)
PS1|KB file (.kb)|raw struct bytes, VDKB magic, version 1, CRC32|header + KB struct + facts + rules + terms + children + text + weight_refs + new_facts + TypedRelations + RelationIndex + CompactionProfile|no serialization — bytes in file ARE the struct
PS2|weight file (.wt)|raw struct bytes, VDWT magic, version 1, CRC32|header + v array (i32) + r0 array (i16) + r1 array (i16)|SoA layout preserved on disk
PS3|snapshot (.snap)|binary, VDRS magic, version 4, CRC32|header + region sizes + entity counts + full Session struct|restore is bit-identical, session IDs preserved
PS4|manifest (manifest.dat)|VDMF magic, version 1|index of all persisted KBs: ID, path, parent, version, sizes, flags (~100 bytes/entry)|only file read at startup
PS5|compact file (.compact)|pipe-delimited text, no magic|tables with headers, relationships, section_index, decode_legend|input to ingestion pipeline
PS6|config (config.json)|JSON|SystemConfig — all fields hard-mapped, unknown fields error|single source of truth
PS7|lazy loading|manifest only at startup|all other KBs load on first access — unaccessed = zero arena memory, zero disk I/O|weights load separately from KB data
PS8|version mismatch|struct sizes in header|mismatch → reject, tell user to run vdr-convert|offline converter, no in-process migration

# errors(id|code|value|category|recovery)
ER1|division_by_zero|100|arithmetic|log_and_continue
ER2|overflow|101|arithmetic|log_and_continue
ER3|kb_not_found|200|kb|log_and_continue
ER4|kb_full|201|kb|compact
ER5|kb_frozen|202|kb|log_and_continue
ER6|kb_access_denied|203|kb|log_and_deny
ER7|slot_out_of_range|204|kb|log_and_continue
ER8|slot_empty|205|kb|log_and_continue
ER9|depth_exceeded|300|prolog|simplify_query
ER10|no_matching_rule|301|prolog|log_and_continue
ER11|unification_failed|302|prolog|log_and_continue
ER12|max_bindings_exceeded|303|prolog|simplify_query
ER13|invalid_template|400|grammar|log_and_continue
ER14|slot_type_mismatch|401|grammar|log_and_continue
ER15|render_capacity_exceeded|402|grammar|log_and_continue
ER16|session_limit|500|session|kill_oldest_clone
ER17|snapshot_failed|501|session|retry_snapshot
ER18|snapshot_corrupt|502|session|restore_from_snapshot
ER19|clone_failed|503|session|log_and_continue
ER20|merge_conflict|504|session|log_and_continue
ER21|grant_denied|600|grant|log_and_deny
ER22|grant_expired|601|grant|log_and_deny
ER23|grant_exhausted|602|grant|log_and_deny
ER24|grant_revoked|603|grant|log_and_deny
ER25|grant_admin_required|604|grant|log_and_deny
ER26|runner_error_threshold|700|runner|recycle_runner
ER27|runner_connection_lost|701|runner|reconnect_with_backoff
ER28|arena_exhausted|800|memory|kill_oldest_clone
ER29|arena_not_found|801|memory|log_and_continue
ER30|init_failed|900|system|restore_from_snapshot
ER31|corrupt_state|901|system|restore_from_snapshot
ER32|seed_load_failed|902|system|restore_from_snapshot

# invariants(id|number|statement|enforced_in)
IN1|1|remainder is never discarded — every divTrunc captures its mod|vdr_ops.zig
IN2|2|r0 and r1 are never padding — both carry exact meaning|vdr_ops.zig, vdr_types.zig
IN3|3|softmax sums to D (65536) exactly — every time|vdr_ops.zig (softmax FRU)
IN4|4|comparison uses all three Q16 fields — no epsilon|vdr_types.zig (Q16.compare)
IN5|5|all multiplications widen to i64 before computing|vdr_ops.zig (GEMM, dot)
IN6|6|no float anywhere — integer in, integer through, integer out|build.zig, all files
IN7|7|r1 near ±32767 means escalate to Q32 for that path|vdr_ops.zig, vdr_training.zig
IN8|8|session IDs (negative) never collide with global IDs (positive)|vdr_types.zig (VdrId)
IN9|9|session data dies with its session — arena reset, gone|vdr_session.zig
IN10|10|arena exhaustion is never silent — always returns error|vdr_arena.zig
IN11|11|SIMD and scalar paths produce bit-identical results|vdr_test.zig
IN12|12|temporary training arenas are the only post-startup allocation|vdr_training.zig
IN13|13|the _llm.* canonical subtree structure is fixed|vdr_session.zig
IN14|14|all dynamic arrays use ArrayListManaged on an arena|all files
IN15|15|fromParts always takes three arguments (v, r0, r1)|vdr_types.zig
IN16|16|RelationType slots 0-19 are system-defined and frozen|vdr_types.zig
IN17|17|domain relation slots 64-127 are first-come, never reassigned|vdr_relation.zig
IN18|18|every TypedRelation has a TAG_RELATION Fact for provenance|vdr_relation.zig, vdr_kb_store.zig
IN19|19|RelationIndex is eventually consistent — rebuilt periodically|vdr_relation.zig
IN20|20|typed relation queries bypass general Prolog unification|vdr_relation.zig
IN21|21|model reduction config is advisory — admin sets, system estimates|vdr_config.zig
IN22|22|compaction profiles are immutable after ingestion|vdr_ingestion.zig
IN23|23|GEMM executes per-thread with no cross-core coordination|vdr_ops.zig
IN24|24|KBs lazy-load from manifest — unaccessed KBs use zero arena memory|vdr_persist.zig
IN25|25|FSM current_state is always a valid atom in machine's state set|vdr_fsm.zig
IN26|26|FSM transitions fire only from current state|vdr_fsm.zig
IN27|27|every FSM state maps to exactly one behavior set (or none for terminal)|vdr_fsm.zig
IN28|28|UAI scoring never produces NaN or infinity — Q16 prevents structurally|vdr_scoring.zig
IN29|29|Dave Mark compensation factor (1-1/n) computed in Q16 with exact remainder|vdr_scoring.zig
IN30|30|gate considerations do not participate in compensation|vdr_scoring.zig
IN31|31|items_seen_by_llm counter never exceeds items_total|vdr_scoring.zig
IN32|32|prompt_current counters reset to 0 when KB cleared at cycle boundary|vdr_session.zig
IN33|33|session-local FSMs die with session — states do not leak to global|vdr_fsm.zig
IN34|34|transition evaluation and UAI scoring both run on pinned compute thread|vdr_fsm.zig, vdr_scoring.zig
IN35|35|BehaviorSet evaluation is deterministic for argmax — weighted random uses session PRNG|vdr_scoring.zig

# structs(id|struct|size|alignment|cache_lines|notes)
ST1|Q16|8|4|0.125|v:4 + r0:2 + r1:2, no padding
ST2|Q32|16|8|0.25|v:8 + r0:4 + r1:4
ST3|Q335|240|8|3.75|5 arrays × 6 × i64
ST4|VdrId|8|8|0.125|single i64
ST5|Fact|48|8|0.75|tag + Q16 + Provenance, padded
ST6|Provenance|36|8|0.5625|7 fields, i32/i64 mix with capability_level
ST7|KB|256|8|4.0|exactly 4 cache lines
ST8|Term|24|4|0.375|type + 3×i32 + Q16
ST9|Rule|48|8|0.75|id + 10 fields + creator
ST10|TypedRelation|48|8|0.75|rel + 2×VdrId + Prov + Q16 + VdrId, padded
ST11|RelationIndex|528|4|8.25|128×i32 + 6 fields
ST12|DomainRelationDef|32|8|0.5|slot + offset + length + bools + inverse + VdrId + time
ST13|CompactionProfile|256|4|4.0|128×bool + metrics + Q16
ST14|WeightMatrix|~32|8|0.5|3 slices + 2×i32
ST15|GemmCache|~32|8|0.5|slice + 4 fields
ST16|Session|~200|8|~3.1|~25 fields, fits in 256 padded
ST17|Grant|~80|8|1.25|12 fields
ST18|AuditEntry|~44|8|0.6875|9 fields
ST19|Command|~24|4|0.375|7 fields
ST20|i32 (GEMM operand)|4|4|16 per cache line|hot path — 8192 elements per 32KB L1

# test_vectors(id|operation|inputs|expected|notes)
TV1|Q16 add clean|65536,0,0 + 65536,0,0|131072,0,0|1.0 + 1.0 = 2.0
TV2|Q16 add r0 carry|32768,16384,0 + 32768,16384,0|65537,0,0|0.5+0.25 + 0.5+0.25, r0 carry into v
TV3|Q16 add r1 below carry|100,100,16000 + 200,200,16000|300,301,32000|r1 sum below threshold
TV4|Q16 add r1 carry|100,100,16384 + 200,200,16384|300,301,0|r1 hits 32768, carries to r0
TV5|Q16 add near-max carry|1,32767,16383 + 1,32767,16383|3,32766,32766|near-max r0 carry chain
TV6|Q16 add cancellation|-1,0,0 + 1,0,0|0,0,0|exact zero
TV7|Q16 mul unity|65536,0,0 × 65536,0,0|65536,0,0|1.0 × 1.0 = 1.0
TV8|Q16 mul half|32768,0,0 × 32768,0,0|16384,0,0|0.5 × 0.5 = 0.25
TV9|Q16 mul cross-term|65536,100,0 × 65536,200,0|65536,0,300|cross-term in r1
TV10|Q16 mul small|2,0,0 × 3,0,0|0,6,0|below 1/D, lives in r0
TV11|Q16 div thirds|65536 / 3|21845,21845,—|1.0 / 3, r1 stable
TV12|Q16 div sevens|65536 / 7|9362,9362,—|1.0 / 7, clean
TV13|Q16 div unity|65536 / 65536|65536,0,never|1.0 / 1.0, exact
TV14|Q16 div prime chain|65536 / 127|516,4,saturates after 8 chains|worst case for remainder
TV15|Q16 div power-of-two|65536 / 256|256,0,never|factors of D always clean
TV16|softmax uniform 3|[0,0,0]|[21846,21845,21845]|sum=65536, deficit=1 assigned to largest r
TV17|softmax dominant|[10,0,0,0]|[65131,135,135,135]|sum=65536, deficit=0
TV18|softmax 3-element|[3,1,1]|[47644,8946,8946]|sum=65536, deficit=561 assigned to element 0

# build_stages(id|stage|files|validation)
BS1|kernel boot + arena|build.zig, root.zig, vdr_arena.zig, vdr_types.zig|compiles, allocates arena, prints diagnostics, exits 0
BS2|config loader|vdr_config.zig, config.json|parsed values printed, bad JSON exits 1 with field name
BS3|arena set from config|vdr_arena.zig (ArenaSet)|prints layout matching config totals
BS4|NUMA-pinned threads|vdr_thread_pool.zig|N threads spawn, pin, touch memory, join cleanly
BS5|HTTP listener|vdr_http.zig|curl health → {"status":"ok"}, clean shutdown on SIGTERM
BS6|HTTP-to-NUMA work passing|vdr_work_queue.zig|response from pinned core, concurrent requests distribute

# impl_stages(id|stage|lines|files|description)
IM1|foundation|~5000|vdr_types, vdr_arena, vdr_config, vdr_thread_pool, vdr_http, vdr_work_queue, vdr_kb_store, vdr_access, vdr_ops (scalar only)|basic session with _llm.* subtree
IM2|intelligence|~6000|vdr_prolog, vdr_grammar, vdr_builtin, vdr_session, vdr_grant, vdr_audit, vdr_confidence, vdr_command|reasoning, authorization, security
IM3|compute|~4000|vdr_ops (AVX2), vdr_model, vdr_inference|SIMD, weight retrieval, full inference loop
IM4|ingestion + relations|~3000|vdr_ingestion, vdr_relation|parser, validator, relation index, typed queries, transitive closure, domain registration
IM4b|scoring + FSM|~3000|vdr_scoring, vdr_fsm|response curves, compensation, behavior selection, state machines, transition evaluation
IM5|training + operations|~4000|vdr_training, vdr_runner, vdr_seed, vdr_system|training arenas, weight update, runners, bootstrap
IM6|persistence|~2000|vdr_persist, vdr_snapshot|save/load, manifest, lazy loading, snapshots
IM7|testing|~1000|vdr_test|determinism, SIMD correctness, snapshot roundtrip, session isolation, softmax unity, remainder chains, relation queries, compaction roundtrip

# files(id|file|sections|description)
FI1|vdr_types.zig|§4, §4.7|all persistent structs and enums
FI2|vdr_ingestion.zig|§9|parse-time structs, parser, validator
FI3|vdr_arena.zig|§5|arena allocator, ArenaSet
FI4|vdr_config.zig|§18|JSON config loading
FI5|vdr_thread_pool.zig|§6.1, §7|pinned threads, lifecycle
FI6|vdr_work_queue.zig|§6.2|atomic ring buffer
FI7|vdr_http.zig|§6|HTTP listener and handlers
FI8|vdr_ops.zig|§7|SIMD operations
FI9|vdr_model.zig|§8|weight retrieval, forward pass
FI10|vdr_kb_store.zig|§14|KB CRUD, path index
FI11|vdr_relation.zig|§4.7, §13.2-13.4|relation index, typed queries
FI12|vdr_prolog.zig|§13|unification, query, backtracking
FI13|vdr_grammar.zig|§4.5|template compile, render
FI14|vdr_session.zig|§6.3, §11|session lifecycle, _llm.* subtree
FI15|vdr_persist.zig|§15|save/load KB and weight files, manifest
FI16|vdr_snapshot.zig|§16|session snapshots
FI17|vdr_training.zig|§10|training arenas, weight update
FI18|vdr_runner.zig|K.1|poller, processor, internal, batch runners
FI19|vdr_inference.zig|§12|inference loop, prompt cycle
FI20|vdr_command.zig|§4.8|command parser, executor
FI21|vdr_access.zig|§8.3, §14|visibility, group weight access
FI22|vdr_grant.zig|§4.8|grant CRUD
FI23|vdr_audit.zig|§4.8|ring buffer, query
FI24|vdr_confidence.zig|§4.9, App B|confidence operations
FI25|vdr_seed.zig|§17|seed layer init
FI26|vdr_builtin.zig|App K.2|448 builtins, 22+2 categories
FI27|vdr_system.zig|§23|top-level init
FI28|vdr_test.zig|§24|test suite
FI29|vdr_scoring.zig|Addendum|response curves, compensation, scoring builtins (cat 22)
FI30|vdr_fsm.zig|Addendum|FSM state management, transition eval, FSM builtins (cat 23)
FI31|build.zig|—|single native x86_64 target

# relationships(from|rel|to)
# principles → data types
PR1|constrains|DT1,DT2,DT3,DT5,DT7,DT15
PR3|constrains|AR1,AR2,AR3
PR4|constrains|AM1,AM2,AM3
PR5|constrains|CM1,CM2,CM12,CM13
PR6|constrains|IS1,IS2,IS3
PR8|constrains|MD13,DT15
PR9|constrains|PL2,RT1-RT20
PR10|constrains|IG1-IG6,MD2,MD3,MD5,MD6
PR12|constrains|DT15,MD8
# id system
IS1|implements|PR6
IS2|subtype_of|IS1
IS3|subtype_of|IS1
IS4|implements|IS1
IS5|implements|IS1
IS6|implements|IS1
IS7|requires|IS2,IS3
IS8|constrains|IS3
# data type dependencies
DT5|contains|DT6,DT1,DT7
DT8|contains|DT5,DT10,DT11,DT15
DT9|component_of|DT10
DT11|contains|DT7,DT1,DT4
DT12|enables|PL2
DT13|extends|RT21
DT14|component_of|IG6
DT15|contains|DT1
DT21|enables|MD13
# arithmetic → compute
AR1|implements|CM11
AR2|implements|CM1,CM9,CM12,CM13
AR3|implements|CM5
AR4|implements|CM3
AR5|enables|DT2
AR6|constrains|CM1,CM7,CM12
# arenas
AM1|contains|DT15,DT8,DT5,DT11,DT12
AM2|contains|DT17,DT8,DT5
AM3|requires|CO14
AM4|derives_from|AM1,AM2
# KB tree → components
KT1|contains|KT2,KT10,KT15,KT16
KT2|contains|KT3,KT4,KT5,KT6,KT7,KT8,KT9,KT13,KT14
KT3|implements|PR1-PR13
KT5|contains|CO24
KT8|enables|MD14
KT9|enables|MD16
KT13|enables|RT1-RT21
KT15|enables|SC4
KT16|enables|FS8-FS12
# components → files
CO1|implemented_in|FI3
CO2|implemented_in|FI4
CO3|implemented_in|FI5
CO4|implemented_in|FI7
CO5|implemented_in|FI6
CO6|implemented_in|FI10
CO7|implemented_in|FI8
CO8|implemented_in|FI9
CO9|implemented_in|FI12
CO10|implemented_in|FI11
CO11|implemented_in|FI13
CO12|implemented_in|FI19
CO13|implemented_in|FI2
CO14|implemented_in|FI17
CO15|implemented_in|FI15
CO16|implemented_in|FI16
CO17|implemented_in|FI29
CO18|implemented_in|FI30
CO19|implemented_in|FI21
CO20|implemented_in|FI22
CO21|implemented_in|FI23
CO22|implemented_in|FI24
CO23|implemented_in|FI25
CO24|implemented_in|FI26
CO25|implemented_in|FI20
CO26|implemented_in|FI14
CO27|implemented_in|FI27
# HTTP system
HT1|enables|HT2
HT2|enables|HT3
HT3|enables|CO3
HT4|requires|HT3
HT5|requires|CO16
HT6|constrains|CO26
# compute → model
CM1|enables|MD9
CM6|implements|IN3
CM8|requires|DT2
# model architecture
MD1|constrains|MD4,MD5
MD2|derives_from|PR10
MD3|derives_from|PR10
MD5|derives_from|PR10
MD6|derives_from|PR10
MD7|derives_from|MD1,MD2,MD3,MD5,MD6
MD8|derives_from|MD7,PR12
MD10|derives_from|MD9,CM1
MD11|derives_from|MD10
MD12|derives_from|MD11,IF11
MD13|requires|DT15,DT21
MD14|requires|KT8
MD16|requires|KT9
# inference → components
IF1|enables|IF2
IF2|enables|IF3
IF3|enables|IF4
IF4|enables|IF5
IF5|enables|IF6
IF6|enables|IF7
IF7|enables|IF8
IF9|requires|CO7,CO8
IF10|requires|CO9,CO12
IF11|requires|CO10,PL2,PL3,PL4
# prolog → relation types
PL2|requires|DT12,RT1-RT20
PL3|requires|RT1,RT2,RT5,RT12,RT15,RT16,RT17,RT18,RT19,RT20
PL4|requires|RT1,RT7,RT8,RT9,RT10,RT11,RT12,RT15,RT16,RT17,RT18,RT19,RT20
PL5|requires|RT3,RT9,RT13,RT14
# ingestion pipeline
IG1|enables|IG2
IG2|enables|IG3
IG3|enables|IG4
IG4|enables|IG5
IG5|enables|IG6
IG5|produces|DT11,DT10
IG6|produces|DT14
# confidence chain
CF1|enables|CF2
CF12|constrains|CF1-CF11
CF17|derives_from|CF12
# scoring → FSM → pipeline
SC4|requires|FS1
SC6|requires|DT1,AR2
SC8|requires|SC6
FS1|enables|SC4
FS6|requires|CO9
FS7|enables|PX2
PX1|enables|PX2
PX2|enables|PX3
PX3|enables|PX4,PX5,PX6
PX4|requires|IF11
PX5|requires|IF10,IF11
PX6|requires|IF9
PX7|requires|IF4,IF5
PX8|enables|PX1
# persistence
PS1|persists|DT8,DT5,DT10,DT9,DT11,DT12,DT14
PS2|persists|DT15
PS3|persists|DT17
PS4|enables|PS7
PS5|enables|IG1
PS7|implements|IN24
# errors → categories
ER1|category|arithmetic
ER3|category|kb
ER9|category|prolog
ER13|category|grammar
ER16|category|session
ER21|category|grant
ER26|category|runner
ER28|category|memory
ER30|category|system
# invariants → enforcement
IN1|enforced_by|CO7
IN3|enforced_by|CM6
IN6|enforced_by|FI31
IN8|enforced_by|IS1
IN9|enforced_by|CO26
IN11|enforced_by|FI28
IN12|enforced_by|CO14
IN20|enforced_by|CO10
IN23|enforced_by|CO7
IN24|enforced_by|CO15
IN25|enforced_by|CO18
IN28|enforced_by|CO17
IN35|enforced_by|CO17
# build stages
BS1|enables|BS2
BS2|enables|BS3
BS3|enables|BS4
BS4|enables|BS5
BS5|enables|BS6
# impl stages
IM1|enables|IM2
IM2|enables|IM3
IM3|enables|IM4
IM4|enables|IM4b
IM4b|enables|IM5
IM5|enables|IM6
IM6|enables|IM7
# relation type algebra
RT1|inverse_of|RT12
RT2|inverse_of|RT1
RT5|inverse_of|RT16
RT7|inverse_of|RT8
RT9|inverse_of|RT10
RT10|inverse_of|RT11
RT14|inverse_of|RT15
RT15|inverse_of|RT16
RT17|inverse_of|RT18
RT19|inverse_of|RT20
# transitive closure composition
RT1|composes_with|RT1
RT2|composes_with|RT2
RT5|composes_with|RT5
RT12|composes_with|RT12
RT15|composes_with|RT15
RT16|composes_with|RT16
RT17|composes_with|RT17
RT18|composes_with|RT18
RT19|composes_with|RT19
RT20|composes_with|RT20
# cross-domain knowledge composition
PL3|enables|MD12
IG5|enables|PL3
SC2|requires|PL2,PL6
CF12|constrains|PL3
# L3 maturity curve
IG5|enables|IF11
IF11|enables|MD12

# section_index(section|title|ids)
1|Scope|PR1-PR13
2|System Architecture|CO1-CO27
3|ID System|IS1-IS8
4|Core Data Types|DT1-DT22
4.1|Q16 Arithmetic|AR1-AR6
4.7|Typed Relation System|RT1-RT21,DT11-DT13
5|Memory Architecture|AM1-AM4
6|HTTP Interface|HT1-HT6
7|Compute Model|CM1-CM13
8|Model Weights|MD1-MD16
9|Compaction Ingestion|IG1-IG6
10|Live Training|AM3,CO14
11|Attention and Session LLM Tree|HT6
12|Inference Loop|IF1-IF11
13|Prolog Engine|PL1-PL6
14|KB Store|CO6
15|Persistence|PS1-PS8
16|Serialization|PS3
17|Seed Layer|KT1-KT16
18|Configuration|PS6
19|Performance Estimates|MD7-MD12
20|Error Handling|ER1-ER32
21|Invariants|IN1-IN35
22|Struct Sizes|ST1-ST20
A|Q16 Test Vectors|TV1-TV18
B|Confidence|CF1-CF17
D|Relation Properties|RT1-RT21
E|Error Codes|ER1-ER32
F|Struct Alignment|ST1-ST20
G|SIMD Coverage|CM1-CM13
H|Execution Levels|IF9-IF11,PX1-PX8
I|File Formats|PS1-PS6
J|Compaction Format|IG1-IG6
K|Seed KBs|KT1-KT16
L|Model Comparison|MD1-MD16
M|Build Validation|BS1-BS6
N|Cross-References|FI1-FI31
A1|Addendum Purpose|PX1-PX8
A2|Unified Pipeline|PX1-PX8
A3|FSM as State Manager|FS1-FS13
A4|State-to-BehaviorSet|SC4,FS1,FS2
A5|UAI Scoring|SC1-SC9
A6|Logging|SC9
A7|Full Decision Loop|PX1-PX8
A8|System FSMs|FS8-FS13
A9|Domain-Agnostic Rules|PL1-PL6
A10|Cross-Domain Composition|RT1-RT21,PL3
A11|Confidence Propagation|CF12-CF17
A12|Addendum Invariants|IN25-IN35
24|Implementation|IM1-IM7,FI1-FI31,BS1-BS6

# decode_legend
id_prefixes: PR=principle, CO=component, DT=data_type, AR=arithmetic, AM=arena/memory, IS=id_system, KT=kb_tree, HT=http_system, CM=compute, MD=model, IF=inference, PL=prolog, RT=relation_type, IG=ingestion, CF=confidence, SC=scoring, FS=fsm, PX=pipeline, PS=persistence, ER=error, IN=invariant, ST=struct, TV=test_vector, BS=build_stage, IM=impl_stage, FI=file
rel_types: constrains|contains|implements|implemented_in|enables|requires|derives_from|subtype_of|component_of|extends|produces|persists|enforced_by|inverse_of|composes_with|category
notation: §N refers to spec section number; D=65536 (Q16 denominator); all Q16 values are v/D where v is the i32 field
constants: D=65536 (2^16), Q32_D=4294967296 (2^32), Q335_D=2^335
units: bytes for sizes, cache lines = 64 bytes, MACs = multiply-accumulate operations, tok/s = tokens per second
zig_version: 0.15.1
target: x86_64, AVX2, Dell Legion 5 (~2019), 6-8 cores, 16-32GB RAM
total_lines: ~25000 estimated across 27+4 files
confidence: compacted from source specification v0.4 + addendum — all numeric values, struct fields, invariants, and formulas preserved exactly

# relation_mapping(doc_rel|canonical_rel|notes)
constrains|constrains|exact match
contains|contains|exact match
implements|implements|exact match
implemented_in|scoped_to|component implemented in file = scoped_to that file
enables|enables|exact match
requires|requires|exact match
derives_from|derived_from|exact match
subtype_of|specializes|exact semantic match
component_of|part_of|exact semantic match
extends|extends|exact match
produces|produces|exact match
persists|maintains|persistence engine persists data type = maintains across restarts
enforced_by|validated|inverse; invariant enforced by component = component validates invariant
inverse_of|complement_of|relation type is inverse of another = complement; symmetric
composes_with|enables|transitive relation composes with itself = enables chained inference
category|instance_of|error has category = instance_of that category
