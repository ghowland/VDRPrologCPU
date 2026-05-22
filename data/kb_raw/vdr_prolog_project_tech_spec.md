# VDR-PROLOG TECHNICAL SPECIFICATION v0.5 + ADDENDUM — MERGED COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: principles → id_system → structural_uuid → lookup → data_types → arithmetic → arenas → kb_tree → components → http → compute → model → prolog → ingestion → confidence → scoring → fsm → pipeline → prompt_pipeline → llm_identity → causal_chain → error_model → translation → poetry → patterns → feedback → cross_domain → inference → persistence → config → errors → invariants → performance → scale → product → build_stages → impl_stages → files → relationships → section_index

# principles(id|principle|rationale|enforced_by)
PR1|no float anywhere|integer in, integer through, integer out — not in arithmetic, HTTP, timing, logging, scoring, translation|IN6
PR2|no malloc after init|one exception: temporary training arenas, destroyed after use|IN12
PR3|remainder is not error|every divTrunc captures its mod — discarding remainder is the bug float normalized|IN1
PR4|arena-only memory|fixed-size contiguous blocks, bump pointer, no free, no reuse until reset|AM1-AM4
PR5|no coordination on hot path|per-thread GEMM, no row splitting, no barrier, no mutex|IN23
PR6|sign-bit partitions address space|bit 63=0 global, bit 63=1 session|IN8
PR7|session data dies with session|arena reset = instant death, no traversal|IN9
PR8|weights live where they serve|domain KBs carry weights alongside facts and rules|MD16
PR9|typed relations bypass unification|enum dispatch, integer scans — sub-microsecond|IN20
PR10|compaction reduces model size|every typed relation = reasoning op NN doesn't need|IG1-IG6
PR11|SIMD and scalar bit-identical|AVX2 and scalar produce identical bytes|IN11
PR12|model weights are i16|2 bytes v + 2 bytes r0 + 2 bytes r1 = 8 bytes per param|DT14
PR13|system scalability via per-core isolation|adding cores adds sessions linearly|CM1
PR14|FSM and scoring are KB data structures|FSM lives in KB like LRU/queue — not a type of KB; behavior set likewise|DT19,DT26
PR15|LLM predicts UUIDs not text|forward pass selects next i64 from 8192 structural addresses — indifferent to semantic meaning|LI1-LI4
PR16|unresolved tokens never silently dropped|every input token either resolved, corrected, or flagged as unresolved with text preserved|IN39
PR17|security is structural not behavioral|grant system prevents execution regardless of LLM prediction — no instruction-based safety|LI2
PR18|structural VdrId encodes tree position|bits encode path — navigation by extraction, membership by mask|SU1-SU5

# id_system(id|concept|description|notes)
IS1|VdrId|i64 with sign-bit partition — 0=none, positive=global, negative=session|external interface: isGlobal/isEphemeral/isNone/eql; internal: packed struct with tree position
IS2|UUID addressing|signed i64, O(1) via hot cache or structural walk|canonical identifier
IS3|dotted path|hierarchical walk from root|root.science.physics.qed (global), session_root._llm.prompt_last (session)
IS4|local index|array slot within KB|facts[0] within specific KB
IS5|resolution order|session first (negative), then global (positive)|promotion explicit
IS6|org/client tree|root._organization.{org}.clients.{client}, root._client.{client}.sessions.{session}|sessions persist across HTTP disconnects

# structural_uuid(id|concept|description|notes)
SU1|bit layout|bit63:sign(u1), bits62-55:level_1(u8), bits54-45:level_2(u10), bits44-35:level_3(u10), bits34-25:level_4(u10), bits24-20:remaining_depth(u5), bits19-0:random(u20)|packed struct, @bitCast to/from i64, zero runtime cost
SU2|sentinel value|std.math.maxInt(u10) = 1023 for unused levels|tree walk short-circuits on encountering sentinel
SU3|construction|determine tree path → encode L1-L4 from indices → compute remaining_depth = max(0, total_depth-4) → generate 20-bit random → test collision → regenerate on collision|birthday paradox: ~0.05% collision rate at 1000 entities per L4 KB
SU4|tree navigation|read L1-L4 bits → direct children-array access at each level — 4 array dereferences = ~20ns to any KB within 4 levels of root|no hash computation, no path string parsing
SU5|subtree membership|two VdrIds sharing prefix (after mask to desired depth) are in same subtree — one AND + one CMP|replaces full tree traversal; L1+L2 mask: 0x7FFC000000000000
SU6|GEMM scope narrowing|extract L1+L2 bits from query VdrIds → determines relevant per-KB GEMM caches before weight data touched|one AND + one CMP per cache eliminates irrelevant subtrees
SU7|query cost estimation|remaining_depth field indicates depth below L4 — pre-resolution can estimate traversal cost|informs L3 vs L1 decision
SU8|reparenting constraint|structural bits must match actual position — reparenting requires VdrId recomputation for entity + all descendants|intentionally expensive — enforces tree stability (IN36)

# lookup(id|component|description|notes)
LK1|per-KB UUID map|AutoHashMap(i64, u32) per KB — maps full VdrId to local fact slot index|size proportional to KB population not system population; serialized with KB; lives in arena
LK2|global hot cache|AutoHashMap(i64, *anyopaque) at KbStore level, ~256 entries fixed capacity|16 seed KBs pre-populated; LRU eviction; adapts to workload
LK3|lookup sequence|1) hot cache (10-50ns) → 2) bitcast to StructuralId → 3) walk tree via L1-L4 array access (~5ns each) → 4) uuid_map.get(full_id) (30-50ns) → 5) kb.facts[slot_index]|total: 50-200ns common case, all sub-microsecond
LK4|disambiguation map|AutoHashMap(i64, []VdrId) at KbStore — atom IDs → all entities sharing that name across KB tree|narrows via domain filtering + relation co-occurrence; enables multi-domain GEMM scoping
LK5|deep entities (depth > 4)|L4 KB's UUID map contains entries for entire subtree|4 preceding levels navigated by array access; hash lookup only for residual depth

# data_types(id|type|size_bytes|key_fields|purpose)
DT1|Q16|8|v:i32, r0:i16, r1:i16|primary arithmetic, D=65536 implicit
DT2|Q32|16|v:i64, r0:i32, r1:i32|Newton-Raphson, escalated, D=2^32
DT3|Q335|240|v/r0/r1/r2/r3 each [6]i64|physics/transcendentals, D=2^335
DT4|VdrId|8|v:i64 (packed struct internally: sign+L1+L2+L3+L4+remaining_depth+random)|sign-bit partitioned, tree-position-encoded entity ID
DT5|Fact|48|tag:FactTag, value:Q16, provenance:Provenance|atomic knowledge unit — 15 tag types
DT6|FactTag|enum i32|value,text,reference,timestamp,enum_tag,boolean,vector,matrix,provenance_tag,rule_ref,grammar_ref,counter,relation,column_schema,empty(255)|determines Fact.value interpretation
DT7|Provenance|36|source_type:i32, source_kb_id:VdrId, source_slot_id:i32, confidence:Q16, timestamp:i32, derivation_rule_id:i32, capability_level:i32|every Fact carries full provenance
DT8|KB|256|~60 fields + uuid_map:AutoHashMap(i64,u32) + fsm_offset + behavior_set_offset + functor_index_offset|4 cache lines, tree node, per-KB UUID map for local entity lookup
DT9|Term|24|type:TermType(i8), primary_id:i32, secondary_offset:i32, secondary_aux:i32, vdr_value:Q16|Prolog term — 10 types
DT10|Rule|48|id:VdrId, head, body, action, fire/success/failure counts, creator|carries own statistics
DT11|TypedRelation|48|rel_type:RelationType(i16), from_id:VdrId, to_id:VdrId, provenance, strength:Q16, scope_kb_id|first-class typed edge
DT12|RelationIndex|~528|by_type_counts:[128]i32, by_from/to, total_relations, last_rebuilt|eventually consistent acceleration structure
DT13|DomainRelationDef|32|slot, name, is_symmetric, is_transitive, inverse_slot, source_document_id, registered_at|domain relation properties
DT14|WeightMatrix|~32|v:[]i32, r0:[]i16, r1:[]i16, rows, cols|SoA, column-major, cache-line aligned
DT15|KbWeightRefs|~48|matrix/vector refs + optional GemmCache|per-KB weight reference table
DT16|GemmCache|~32|v_packed, fact_count, kb_id, kb_last_modified, generation|packed v for GEMM hot path
DT17|CompactionProfile|256|source_document_id, counts, relation_types_used:[128]bool, compression_ratio:Q16|immutable after creation
DT18|Fsm|~64|id, fsm_type, current/previous/initial_state, states, transitions_kb_id, outputs_kb_id, parent, children, transition_count|per-KB state machine
DT19|ResponseCurve|~28|curve_type(14 types), param_a/b/c:Q16, inverted, breakpoints|scoring curve definition
DT20|Consideration|~40|input:InputSource(10 types), curve, weight:Q16, floor:Q16, is_gate, last_score/raw|atomic scoring unit
DT21|Behavior|~48|id, name, action:BehaviorAction(7 types), considerations, compensation, weight, floor, selection_count|candidate action
DT22|BehaviorSet|~48|id, behaviors, selection:SelectionMethod(5 types), top_n, temperature, hysteresis_bonus, threshold, current_behavior_id|scored set with selection method
DT23|Session|~256|id, user_id, kb roots, ephemeral_next_id, state, core/arena, limits, counters, snapshot/clone, atom_rel_cache, surface_dirty, poetry_mode:bool, spell_correction_level|isolation boundary + addendum fields
DT24|KbStore|~320+|global_arena, path_index, loaded_lut, manifest, next_global_id(=17), atom_table, text_store, data_dir, disambiguation_map:AutoHashMap(i64,[]VdrId), global_hot_cache:AutoHashMap(i64,*anyopaque)|single instance + addendum fields
DT25|RelationType|enum i16|system 0-25 (enables through composed_of) + domain 64-127 + unknown=-1|inverse/isSymmetric/isTransitive methods
DT26|QueryClassification|~56|has_relation/transitive/fact/aggregation, rel_type, from/to hints, confidence, match_count|pre-LLM pattern detection
DT27|L3PreResolution|~24|resolved, resolution_type(7 types), result_count, results_offset, confidence, time_us|pre-resolution result
DT28|PrologEngine|~64|store, scratch, session, global_arena, atom_rel_cache, level_stats, config|one per session
DT29|LevelStats|~96|l1/l2/l3 counts+tokens, relation/transitive/inverse counts, pre_resolution tracking|execution level statistics
DT30|ModelConfig|~288|n_layers, d_model, n_heads, d_head, vocab_size, mlp_dim, max_seq_len, checkpoint, activation|totalParams/weightBytes methods
DT31|SystemConfig|~512|n_cores, model, model_reduction, arenas, limits, http_port(1138), ingestion, configs|top-level JSON

# arithmetic(id|operation|formula|remainder|escalation)
AR1|Q16 addition|r1 sum → carry r0 → carry v|full chain, no loss|—
AR2|Q16 multiplication|i64(a.v×b.v), v=divTrunc/D, r0=mod, r1=cross-terms|captured|—
AR3|Q16 division|widened=a.v×D, divTrunc/mod by b.v, r1=r0×D/b.v|worse than mul for non-D-factor divisors|r1 near ±32767 → Q32
AR4|Q16 comparison|lexicographic v→r0→r1, no epsilon|equal = all three match|—
AR5|Dave Mark compensation|mf=(n-1)/n, make_up=(D-score)×mf/D, compensated=score+(make_up×score/D), final=∏(compensated_i)|all Q16, floor v=655≈1%|gates excluded

# arenas(id|arena|size|contents|reset)
AM1|global|~1.27-1.8 GB|weights ~572MB, KBs ~25MB, facts ~480MB, relations ~50MB, indices ~10MB, rules/terms/text ~93MB, grants/audit ~33MB, compaction ~2MB, UUID maps ~40MB, hot cache ~8KB|never
AM2|per-core|~220 MB each|sessions, session KBs/facts, KV cache, scratch, bindings, render, work queue|session death
AM3|training temp|10KB-176MB|gradients+r0/r1, momentum, variance, activations, transpose, scratch|destroyed after use
AM4|system total (8 cores)|~3.03 GB|fits 8GB|—

# kb_tree(id|path|seed_id|content|frozen)
KT1|root|+1|tree root|no
KT2|root.system|+2|system parent|yes
KT3|root.system.oso|+3|15 engineering principles|yes
KT4|root.system.confidence|+4|11-entry confidence table|yes
KT5|root.system.builtins|+5|448 IOSE declarations, 24 categories|yes
KT6|root.system.command_vocab|+6|~300 command tokens|yes
KT7|root.system.hygiene|+7|~50 self-maintenance rules|yes
KT8|root.system.embedding|+8|vocab embedding 8192×2048|yes
KT9|root.system.output|+9|lm_head + final norm|yes
KT10|root.system.relation_types|+13|system frozen + domain appendable|no
KT11|root.system.ingestion|+14|queue + CompactionProfiles|no
KT12|root.system.scoring|+15|system behavior sets|no
KT13|root.system.fsm|+16|system FSM definitions|no
KT14|root.templates|+10|template parent|yes
KT15|root.templates.sentences|+11|~100 sentence grammars|yes
KT16|root.templates.formats|+12|~50 output format grammars|yes

# components(id|component|file|role)
CO1|arena allocator|vdr_arena.zig|ArenaSet, bump pointer
CO2|config loader|vdr_config.zig|JSON → SystemConfig
CO3|thread pool|vdr_thread_pool.zig|NUMA-pinned, spin-wait
CO4|HTTP listener|vdr_http.zig|non-pinned, handlers
CO5|work queue|vdr_work_queue.zig|per-core atomic ring buffer
CO6|KB store|vdr_kb_store.zig|CRUD, path index, UUID maps, disambiguation map, hot cache
CO7|SIMD ops|vdr_ops.zig|AVX2 GEMM, softmax, RMSNorm, attention, SiLU
CO8|model engine|vdr_model.zig|three-path retrieval, forward pass, GEMM scoping
CO9|Prolog engine|vdr_prolog.zig|unification, query, backtracking, fire_and_commit
CO10|relation engine|vdr_relation.zig|RelationIndex, typed queries, transitive closure, inverse
CO11|grammar engine|vdr_grammar.zig|template compile, render, inherit
CO12|inference engine|vdr_inference.zig|full loop, prompt cycle, L1/L2/L3
CO13|ingestion engine|vdr_ingestion.zig|parser, validator, assertion
CO14|training engine|vdr_training.zig|canTrain, train, temp arenas
CO15|persistence|vdr_persist.zig|save/load, manifest, lazy loading
CO16|snapshot engine|vdr_snapshot.zig|session snapshots, CRC32
CO17|scoring engine|vdr_scoring.zig|curves, compensation, selection
CO18|FSM engine|vdr_fsm.zig|state management, transitions
CO19|access engine|vdr_access.zig|visibility, resolution, weight access
CO20|grant engine|vdr_grant.zig|grant CRUD
CO21|audit engine|vdr_audit.zig|ring buffer, query
CO22|confidence engine|vdr_confidence.zig|assign, combine, chain
CO23|seed engine|vdr_seed.zig|seed layer init
CO24|builtin engine|vdr_builtin.zig|448 builtins, 24 categories
CO25|command engine|vdr_command.zig|parser, executor
CO26|session engine|vdr_session.zig|lifecycle, _llm.*, clone/merge
CO27|system engine|vdr_system.zig|top-level init
CO28|test suite|vdr_test.zig|all tests

# http(id|component|description|threading)
HT1|listener|port from config (default 1138)|non-pinned
HT2|handler|JSON parse → resolve → queue → spin-wait → respond|non-pinned
HT3|work queue|atomic ring buffer, full = 503|bridge
HT4|session binding|bound to core at creation|per-core
HT5|session persistence|COW clone, LRU eject with snapshot, restore on reconnect|per-core
HT6|separation|pinned=compute, HTTP=I/O, queue=only bridge|invariant

# compute(id|operation|description|remainder|invariant)
CM1|GEMM|8×i32 widen-madd i64, divTrunc/D, per-thread no coordination|r0 from divTrunc|IN1,IN5,IN23
CM2|softmax|integer exp, division, FRU assigns deficit to largest-remainder|sum=D=65536 exactly|IN3
CM3|RMSNorm|Newton-Raphson 4 iter i64|r0 from divTrunc|IN7
CM4|attention|per-head Q·K, causal mask, exact softmax, weighted V|r0 carried|IN5
CM5|SiLU|scalar piecewise integer|r0 per element|—
CM6|residual add|8×i32 with r1→r0→v carry|no loss|IN2

# model(id|concept|value|notes)
MD1|d_model|2048|unchanged
MD2|n_layers|6|from 16
MD3|n_heads|12|from 16
MD4|d_head|170|from 128
MD5|mlp_dim|2048|from 5632
MD6|vocab_size|8192|structural UUIDs, not text tokens
MD7|total_params|~143M|85.7% reduction
MD8|weight_memory|~286 MB v, ~572 MB total|i16
MD9|per_token_MACs|~126M|~5.3ms at AVX2
MD10|single_core_tok_s|~190|—
MD11|system_8core_tok_s|~1520|8 concurrent sessions
MD12|effective_req_s_93pct_l3|~21700|1520/0.07
MD13|layer 1-2|token embedding, syntax|understanding input (UUIDs, not English)
MD14|layer 3-4|semantic understanding, KB address resolution|deciding what to do
MD15|layer 5-6|output planning, judgment|deciding how to respond
MD16|three-path retrieval|P1: fact scan, P2: GEMM cache (hot), P3: cache+new_facts|per-group caches, GEMM scoping via structural prefix

# prolog(id|concept|description|priority|cost)
PL1|typed relation fast path|functor matches RelationType → RelationIndex scan|1|sub-µs, L3
PL2|transitive closure|BFS over contiguous arrays for transitive types|2|zero tokens, L3
PL3|inverse lookup|rewrite depends_on(X,t) → enables(t,X)|3|L3
PL4|symmetric swap|auto-query with from/to swapped|4|L3
PL5|structural inheritance|ancestors via specializes/instance_of, inherited requires/prevents/contains|5|L3
PL6|general Prolog|full unification, depth-first, explicit backtracking|6|L1/L2
PL7|fire_and_commit|scan rules, fire satisfied, assert derived facts at prolog_derivation confidence|—|L3 automatic
PL8|core rules|generated from RelationType properties: taxonomy, containment, enablement, requirement, symmetry, inverse, sequence, scope|—|domain docs add only facts

# relation_types(id|slot|name|inverse|symmetric|transitive)
RT1|0|enables|depends_on|no|yes
RT2|1|requires|enables|no|yes
RT3|2|prevents|prevents|yes|no
RT4|3|implements|unknown|no|no
RT5|4|extends|generalizes|no|yes
RT6|5|overrides|unknown|no|no
RT7|6|validates|verified_by|no|no
RT8|7|verified_by|validates|no|no
RT9|8|contradicts|contradicts|yes|no
RT10|9|causes|determined_by|no|no
RT11|10|determined_by|causes|no|no
RT12|11|depends_on|enables|no|yes
RT13|12|equivalent_to|equivalent_to|yes|no
RT14|13|approximates|approximates|yes|no
RT15|14|specializes|generalizes|no|yes
RT16|15|generalizes|specializes|no|yes
RT17|16|part_of|contains|no|yes
RT18|17|contains|part_of|no|yes
RT19|18|follows|precedes|no|yes
RT20|19|precedes|follows|no|yes
RT21|20|instance_of|unknown|no|no
RT22|21|scoped_to|unknown|no|yes
RT23|22|flows_to|unknown|no|yes
RT24|23|transforms_to|unknown|no|yes
RT25|24|derived_from|unknown|no|yes
RT26|25|composed_of|unknown|no|yes
RT27|64-127|domain slots|per-registration|per-reg|per-reg

# ingestion(id|stage|description|output)
IG1|external compaction|raw → LLM → .compact (pipe-delimited)|.compact at llm_generated (30/100)
IG2|validation|IDs unique, targets exist, columns match, legend present|validated
IG3|KB creation|parent + child per table|KB subtree
IG4|fact assertion|text→TAG_TEXT, numeric→TAG_VALUE, schema→TAG_COLUMN_SCHEMA|populated facts
IG5|relation + rule|relationships→TypedRelation + Prolog rules, domain types registered|TypedRelation + Rule
IG6|profile + freeze|CompactionProfile recorded, KBs frozen|immutable profile

# confidence(id|source_type|q16_v|fraction)
CF1|vdr_computation|65536|1/1
CF2|prolog_derivation|65536|1/1
CF3|database|64225|98/100
CF4|prometheus|62259|95/100
CF5|script|62259|95/100
CF6|rest_api|55705|85/100
CF7|published|52428|80/100
CF8|user_stated|45875|70/100
CF9|web_search|32768|50/100
CF10|llm_generated|19660|30/100
CF11|unknown|0|0/1
CF12|chain|min(inputs)|weakest link
CF13|parallel|max(sources)|strongest source
CF14|contradiction|0|sources disagree
CF15|ingestion|min(source_type, compaction_stage)|compaction weakest link

# scoring(id|concept|description|notes)
SC1|response curve|14 types mapping [0,1]→[0,1]|linear, polynomial, logistic, gaussian, step, smoothstep, piecewise, etc.
SC2|consideration|input(10 sources) → normalize → curve → score|kb_fact, session_counter, relation_count, confidence, time, arena, builtin, constant, level_stats, resource_ratio
SC3|behavior|candidate scored by considerations|action: prolog_query, builtin_call, llm_command, kb_assert, nested_set, rule_fire, grammar_render
SC4|behavior set|collection valid in current FSM state|selection: argmax, weighted_random_top_n, boltzmann, argmax_with_hysteresis, threshold_then_argmax
SC5|compensation|Dave Mark: mf=(n-1)/n, final=∏(compensated_i)|Q16, floor v=655, gates excluded
SC6|items counter|items_seen_by_llm vs items_total|reset at cycle boundary

# fsm(id|concept|description|notes)
FS1|FSM in KB|kb.fsm_offset, same pattern as LRU/queue|states=atoms, transitions=rules in child KB, outputs=facts in child KB
FS2|Moore|behavior set per state|session lifecycle, KB lifecycle, inference cycle
FS3|Mealy|action per transition|HTTP request lifecycle
FS4|DFA|accepts/rejects|level selection (L3/L2/L1)
FS5|statechart|nested + concurrent|complex domain AI
FS6|transition eval|Prolog rules, evolves_to(Current,Next) :- conditions|first match fires
FS7|system FSMs|session lifecycle, HTTP lifecycle, inference cycle, level selection, KB lifecycle|root.system.fsm
FS8|session-local FSMs|conversation phase, task tracker, domain-specific|ephemeral, die with session

# prompt_pipeline(id|stage|description|notes)
PP1|content detection (stage 0)|pattern matchers scan raw input for JSON, YAML, code, CSV, XML — produces typed segment array|JSON parsed to native terms (integers as i32, floats→Q16 with remainder); broken content tagged not dropped (IN39,IN44)
PP2|code pattern matching (stage 0.5)|structural pattern matching via Prolog-integrated grammars — matches/generates duality on shared pivot UUID|bidirectional: parse produces structural pivot, generate consumes it; round-trip testable (IN43)
PP3|tokenization (stage 1)|prose segments tokenize on whitespace/punctuation boundaries|candidate tokens for atom table lookup
PP4|spell correction (stage 2)|check against atom table, configurable aggressiveness (off → max_only → progressive)|quoted tokens never corrected; correction penalty on confidence; multiple equidistant = left uncorrected
PP5|UUID resolution (stage 3)|accepted tokens resolve via disambiguation map against KB tree|availability surface filters candidates to session's grants
PP6|disambiguation (stage 4)|typed relation co-occurrence narrows multiple candidates|domain anchor = most unambiguous token; other tokens filter against anchor; all L3
PP7|assertion to prompt_current (stage 5)|resolved tokens→reference facts, structural annotations, GEMM scope markers, unresolved→flagged text, original raw text preserved|nothing silently dropped

# llm_identity(id|concept|description|significance)
LI1|UUID predictor|LLM predicts next i64 from vocabulary of 8192 structural addresses — not text generation|embedding maps i64 to vector, attention predicts next i64, softmax selects
LI2|security structural|grant system prevents execution regardless of LLM prediction — LLM can predict op_execute with max probability, without grant it returns denied + audit log|no instruction-based safety needed
LI3|scratchpad as UUID sequence|cross-turn notes stored as VdrId reference facts — 4 VdrId facts (32 bytes) encode context that would consume thousands of text tokens|pre-resolution follows addresses, checks KB modification timestamps
LI4|computational identity|VDR-Prolog is UUID matching and execution engine — correction is retract+assert, not conversation; no ceremony because ceremony is not a KB operation|every output token traces to UUID → fact → provenance source

# causal_chain(id|concept|description|notes)
CC1|mechanism|Prolog composes typed relations (enables, requires, produces, accepts, instance_of, part_of, transforms_to) into solution paths before LLM forward pass|each link is L3 typed relation lookup, sub-µs, zero LLM tokens
CC2|meta-reasoning rules|system KB rules encode general causal composition — solution_candidate, prerequisite, postprocess — fire against domain facts|same rules produce different chains for different domains
CC3|chain output|logged to prompt_current as ordered steps, each with VdrId + provenance|overall confidence = min of component facts (CF12)
CC4|gap handling|unresolved token at any position produces gap flag — system reports completed portions + explicit gap, requests clarification|never fabricates meaning for unresolved terms
CC5|token reduction|with pre-derivation: ~30-45 UUIDs instead of ~85-120 for typical code generation — 40-50% reduction in L1 wall time|LLM assembles from mechanically-verified scaffold

# error_model(id|concept|description|notes)
EM1|CLLM failure|flat softmax + float rounding → any token can win → hallucinated functions, malformed syntax, fabricated facts|error indistinguishable from correct output
EM2|VDR failure|flat softmax across 8192 UUIDs — every possible output is valid UUID pointing to real entity|cannot hallucinate nonexistent function (no UUID for it); cannot malform syntax (grammar templates handle formatting)
EM3|failure mode|selecting wrong UUID — os.listdir when pathlib.Path.iterdir better — both real, both work|suboptimal choice, not fabrication
EM4|detection|low-confidence: check typed relation coherence with preceding UUIDs, compare top-N against causal chain, defer if no candidate connects well|ambiguity presented to user, not silently resolved
EM5|error floor|worst output = real entity chosen for wrong reasons — detectable (provenance doesn't support), recoverable (retract+re-derive), bounded (entity exists with known properties)|vs CLLM: worst output = arbitrarily convincing fabrication

# translation(id|concept|description|notes)
TL1|structure-to-structure|input decomposes to language-independent semantic UUIDs via prompt pipeline; output composed via target language grammar rules|not text-to-text neural generation
TL2|cultural rules|Prolog rules over session participant facts (age, role, relationship) compute social hierarchy → honorific level → verb forms, particles, pragmatic additions|mechanical: senpai_kohai rule produces different output for same semantic input
TL3|pragmatic additions|cultural compacts include gesture/behavior annotations as typed relations|applies to text, animation data, or stage directions
TL4|grammar transformation|templates handle SVO→SOV reorder, particle insertion, subject dropping|style configuration as session facts
TL5|LLM role|~10-15 tokens of judgment: confirming naturalness, selecting among equivalent phrasings|minimal neural involvement
TL6|adding languages|new language compact (grammar + vocabulary + cultural rules) ingested into KB tree — no retraining|same semantic UUIDs, different generates rules

# poetry(id|concept|description|notes)
PO1|session flag|poetry_mode:bool on Session (default false)|core mode: canonical UUID; poetry mode: word groups
PO2|first-degree expansion|direct synonyms via synonym_of, similar_to, register_variant_of relations|safe substitutions preserving meaning
PO3|second-degree expansion|synonyms of synonyms with mandatory relevance check — typed relation path back to original required (IN41)|prevents semantic drift; third-degree+ prohibited
PO4|LLM selection|word group (4-8 UUIDs) presented, LLM selects via small attention pass|per-KB GEMM weights for vocabulary usage patterns
PO5|cost model|~60-80 tokens vs ~20 for core mode — measurable, billable|suitable for tiered access
PO6|self-building vocabulary|thesaurus KBs built through normal KB ops, user-contributed via Workshop|domain-specific palettes (literary Japanese, business Japanese, etc.)

# patterns(id|concept|description|notes)
PT1|matches/generates duality|every code pattern has structural description traversable in two directions — shared pivot UUID|parse: matches(Line, Pattern); generate: generates(Pattern, Line); same UUID both directions (IN43)
PT2|composability|patterns nest via typed relations: for_each.contains→function_call, conditional_guard.contains→logging_call|generates by recursive descent with indentation depth parameter
PT3|cross-language|structural pivot is language-independent — parse Python → get UUIDs → generate Zig|different generates rules, same structural pivot
PT4|round-trip verification|matches(Line, P), generates(P, Out), Line == Out — failure = bug in matcher or generator|tested in standard test suite
PT5|style configuration|tabs/spaces, indent width, brace style as session facts — change fact, regenerate, get differently-formatted identical code|not hardcoded

# feedback(id|concept|description|notes)
FB1|thumbs up/down|UI buttons on each output element — increments success_count or failure_count on producing pattern/rule|pushed to review queue with session context
FB2|review processing|queue in session or global KB — presents VdrId, direction, provenance, context|user or autonomous runner processes
FB3|fix|edit fact or generates rule directly through UI — live immediately, GEMM cache dirty check triggers rebuild (IN46)|—
FB4|delete|retract pattern fact — system falls back to alternatives or L1|future compact may re-introduce corrected version
FB5|demote|leave pattern, let success_rate (Q16) naturally deprioritize via RuleCandidate ranking|low-rated patterns sink below alternatives
FB6|live editing|UI context menu on any output → provenance chain → navigate to source fact → edit → save|audit logged, revertible, no retraining needed

# cross_domain(id|concept|description|notes)
XD1|composition principle|queries traverse multiple compacted domains via shared typed relations simultaneously|disambiguation determines relevant domains; GEMM scope includes all surviving subtrees
XD2|single-domain scoping|all query VdrIds share structural prefix → only matching GEMM caches included|one AND + one CMP per cache
XD3|multi-domain scoping|disambiguation survivors across multiple domains → GEMM scope = union of surviving subtrees|typical query: 3-7 subtrees active, 143-147 excluded
XD4|PM integration|user request maps against PM foundations: scope(FD2), assumptions(FD10), WBS(FD12), critical path(FD13), acceptance criteria(FD18), risk(RK1-RK8)|mechanical decomposition through part_of/requires relations
XD5|narrative integration|story request maps against dramatic writing: character roles, plot mechanics, themes, structure selection|biology for animal behaviors, tactics for military, connections for networking — all compose
XD6|language rendering|final output passes through English grammar/phrasing/vocabulary compacts regardless of domain|sentence pattern → construction → argument fill → register-appropriate words → coherence relations

# pipeline(id|step|description|level)
PX1|input|system writes user input to prompt_input + runs prompt pipeline (PP1-PP7)|—
PX2|pre-resolution|classify query pattern, attempt L3, causal chain derivation (CC1-CC5)|L3
PX3|FSM evaluation|check transitions, update state, resolve behavior set|L3
PX4|UAI scoring|gates → soft scoring → compensation → selection|L3
PX5|execution — L3|pre-resolution answered → LLM frames (~20 tokens)|L3+framing
PX6|execution — action|UAI winner action → execute → LLM frames|L2-L3
PX7|execution — defer|score below threshold → full forward pass|L1
PX8|LLM generation|read prompt_last + prompt_current, accept/override/augment, write prompt_next|L1/L2
PX9|post-generation|re-eval transitions, copy prompt_next→prompt_last, clear, reset|L3

# inference(id|level|tokens|cost|description)
IF1|L3|0 LLM (+~20 framing)|0%|typed relation, transitive, inverse, FSM, UAI, rule fire — 93% at maturity
IF2|L2|~18|~3%|LLM selects from candidates, Prolog executes — ~38 total
IF3|L1|50-500|100%|full forward pass — novel queries, judgment; with causal chain: ~30-45 UUIDs (40-50% reduction)

# llm_tree(id|path|purpose)
LT1|session_root._llm.prompt_last|continuity
LT2|session_root._llm.prompt_next|carry forward
LT3|session_root._llm.prompt_input|current request (system writes)
LT4|session_root._llm.prompt_current|scratch + logged results (cleared each cycle)
LT5|session_root._llm.history|bounded cycle history
LT6|session_root._llm.projects|project tracking
LT7|session_root._llm.people|people tracking
LT8|session_root._llm.concepts|topics + availability surface
LT9|session_root._llm.search|search results
LT10|session_root._llm.scratchpad|persistent cross-prompt scratch (UUID reference facts)

# persistence(id|format|contents|notes)
PS1|.kb (VDKB v1)|KB + facts + rules + terms + children + text + weight_refs + relations + RelationIndex + new_facts + CompactionProfile + UUID map|raw struct bytes, CRC32; UUID map serialized as count + key-value pairs
PS2|.wt (VDWT v1)|v(i32) + r0(i16) + r1(i16) SoA|CRC32
PS3|.snap (VDRS v4)|regions + counts + Session + checksum|bit-identical restore
PS4|manifest.dat (VDMF v1)|all persisted KBs (~100 bytes/entry)|only file at startup
PS5|.compact|pipe-delimited tables|ingestion input
PS6|config.json|SystemConfig|hard-mapped, strict errors
PS7|lazy loading|manifest + seed KBs only at startup|unaccessed = zero memory; weights load on first GEMM need

# errors(id|category|codes|recovery)
ER1|arithmetic|division_by_zero(100), overflow(101)|log
ER2|kb|not_found(200), full(201), frozen(202), access_denied(203), slot_range(204), slot_empty(205)|compact/log/deny
ER3|prolog|depth(300), no_rule(301), unification(302), bindings(303)|simplify/log
ER4|grammar|template(400), type_mismatch(401), capacity(402)|log
ER5|session|limit(500), snapshot(501), corrupt(502), clone(503), merge(504)|kill/retry/restore
ER6|grant|denied(600), expired(601), exhausted(602), revoked(603), admin(604)|deny
ER7|runner|errors(700), connection(701)|recycle/reconnect
ER8|memory|arena_exhausted(800), not_found(801)|kill_oldest
ER9|system|init(900), corrupt(901), seed(902)|restore

# invariants(id|number|statement|enforced_in)
IN1|1|remainder never discarded|vdr_ops.zig
IN2|2|r0 and r1 carry exact meaning|vdr_ops/types
IN3|3|softmax sums to D exactly|vdr_ops (FRU)
IN4|4|comparison uses all three Q16 fields|vdr_types
IN5|5|all multiplications widen to i64|vdr_ops
IN6|6|no float anywhere|all files
IN7|7|r1 near ±32767 = escalate Q32|vdr_ops/training
IN8|8|session IDs never collide with global|vdr_types
IN9|9|session data dies with session|vdr_session
IN10|10|arena exhaustion never silent|vdr_arena
IN11|11|SIMD == scalar|vdr_test
IN12|12|training arenas only post-init alloc|vdr_training
IN13|13|_llm.* subtree fixed|vdr_session
IN14|14|dynamic arrays use ArrayListManaged|all
IN15|15|fromParts always three args|vdr_types
IN16|16|RelationType 0-25 frozen|vdr_types
IN17|17|domain slots 64-127 first-come|vdr_relation
IN18|18|every TypedRelation has TAG_RELATION Fact|vdr_relation
IN19|19|RelationIndex eventually consistent|vdr_relation
IN20|20|typed queries bypass unification|vdr_relation
IN21|21|model reduction advisory|vdr_config
IN22|22|compaction profiles immutable|vdr_ingestion
IN23|23|GEMM per-thread no coordination|vdr_ops
IN24|24|KBs lazy-load, unaccessed = zero|vdr_persist
IN25|25|FSM current_state valid atom|vdr_fsm
IN26|26|transitions fire only from current|vdr_fsm
IN27|27|state maps to one behavior set or none|vdr_fsm
IN28|28|UAI never NaN/infinity|vdr_scoring
IN29|29|compensation (1-1/n) in Q16 exact|vdr_scoring
IN30|30|gates excluded from compensation|vdr_scoring
IN31|31|items_seen ≤ items_total|vdr_scoring
IN32|32|prompt_current counters reset at clear|vdr_session
IN33|33|session FSMs die with session|vdr_fsm
IN34|34|eval+scoring on pinned thread|vdr_fsm/scoring
IN35|35|argmax deterministic, random uses PRNG|vdr_scoring
IN36|36|structural VdrId bits match actual tree position — reparenting requires recomputation|vdr_types
IN37|37|per-KB UUID map consistent with fact array — assert adds, retract removes|vdr_kb_store
IN38|38|hot cache entries are valid pointers — eviction removes fast path not KB|vdr_kb_store
IN39|39|unresolved tokens never silently dropped — resolved, corrected, or flagged|prompt pipeline
IN40|40|poetry mode doesn't affect mechanical correctness|vdr_scoring
IN41|41|second-degree expansion requires typed relation path back to original|vdr_scoring
IN42|42|LLM output vocabulary contains only valid VdrIds — cannot reference nonexistent entity|vdr_inference
IN43|43|every matches rule has corresponding generates on same pivot — round-trip tested|vdr_test
IN44|44|content detection never discards malformed input — broken content tagged and preserved|prompt pipeline
IN45|45|thumbs counters are exact Q16 integers|vdr_scoring
IN46|46|UI edits trigger GEMM cache dirty — corrected data visible next access without retraining|vdr_kb_store
IN47|47|disambiguation map contains every entity name — absent atom = unresolved|vdr_kb_store

# performance(id|phase|l1_time|l3_time|notes)
PF1|HTTP receipt|60-130 µs|60-130 µs|TCP, JSON, session resolve, queue push
PF2|query classification|1.5-2.5 µs|1.5-2.5 µs|tokenize, atom lookup, cache
PF3|FSM evaluation|0.2 µs|0.2 µs|state check, transition scan
PF4|UAI scoring|1.7 µs|1.7 µs|considerations, curves, compensation
PF5|causal chain|2.5-3.5 µs|2.5-3.5 µs|relation traversal
PF6|LLM forward pass|320-570 ms|0 (eliminated)|99.96% of L1 time
PF7|grammar rendering|2-3 µs|2-3 µs|template, slot fill
PF8|post-generation|1.2 µs|1.2 µs|copy, counters, FSM re-eval
PF9|HTTP response|50-100 µs|50-100 µs|buffer, TCP
PF10|total L1|~320-570 ms|—|LLM dominates
PF11|total L3|—|70-140 µs|HTTP I/O dominates; mechanical <10 µs
PF12|L3 per-core throughput|—|>200K req/s|before HTTP bottleneck
PF13|structural UUID savings|—|2-5 µs/req|30-50% of L3 mechanical time
PF14|causal chain token reduction|40-50% fewer tokens|—|~30-45 UUIDs vs ~85-120

# scale(id|component|calculation|size)
SK1|facts (2M)|2,000,000 × 48|96 MB
SK2|KB structs (12.75K)|12,750 × 256|3.3 MB
SK3|per-KB UUID maps|12,750 × ~157 entries × 16 × 1.25|39.5 MB
SK4|typed relations (600K)|600,000 × 48|28.8 MB
SK5|relation indices (8K)|8,000 × 528|4.2 MB
SK6|rules (100K)|100,000 × 48|4.8 MB
SK7|terms (300K)|300,000 × 24|7.2 MB
SK8|text storage|code, names, templates|~100 MB
SK9|weight matrices|per-KB GEMM dominant|~1500 MB
SK10|overhead|profiles, grants, audit, FSMs, behavior sets|~16 MB
SK11|total|—|~1800 MB
SK12|depth distribution|D1: 150 root KBs ~75K facts; D2-4: ~6600 KBs ~1.18M facts; D5-7: ~6000 KBs ~745K facts|fits global arena with headroom

# product(id|concept|description|notes)
PD1|frontend|game engine UI — sprites, text input, sounds; SQLite local persistence|display layer for VDR-Prolog
PD2|provenance editing|context menu on output → provenance chain → navigate → edit in place → live immediately|audit logged, revertible
PD3|feedback loop|thumbs up/down → review queue → fix/delete/demote → success_rate scoring|natural deprioritization of bad patterns
PD4|distribution|Steam consumer
PD5|knowledge base|~500 compacted domains at ship: all sciences, programming languages, trades, languages, philosophy, math, history|users extend via Workshop
PD6|autonomous operation|sessions bound to runners: SMTP server, HTTP/HTMX server, data pipeline, monitoring agent|8 cores = 8 concurrent, hundreds suspended via LRU

# build_stages(id|stage|validation)
BS1|kernel + arena|compiles, allocates, prints, exits 0
BS2|config|parsed, bad JSON exits 1
BS3|arena set|prints layout matching config
BS4|pinned threads|N spawn, pin, touch, join
BS5|HTTP|curl health → ok, clean shutdown
BS6|work passing|response from pinned core

# impl_stages(id|stage|lines|files)
IM1|foundation|~5000|types, arena, config, threads, http, queue, kb_store, access, ops(scalar)
IM2|intelligence|~6000|prolog, grammar, builtin, session, grant, audit, confidence, command
IM3|compute|~4000|ops(AVX2), model, inference
IM4|ingestion+relations|~3000|ingestion, relation
IM4b|scoring+FSM|~3000|scoring, fsm
IM5|training+ops|~4000|training, runner, seed, system
IM6|persistence|~2000|persist, snapshot
IM7|testing|~1000|test
IM8|total|~28000|31 files

# relationships(from|rel|to)
# principles → enforcement
PR1|constrains|DT1-DT3,DT5,DT7,DT14,AR1-AR5,TL1
PR6|constrains|IS1,SU1
PR15|constrains|LI1,MD6
PR16|constrains|PP7,IN39
PR17|constrains|LI2,CO20
PR18|constrains|SU1-SU8,LK1-LK5
# structural UUID → lookup
SU1|enables|SU4,SU5,SU6,SU7
SU4|enables|LK3
SU5|enables|XD2,XD3
SU6|enables|MD16
SU8|constrains|SU1
# lookup → components
LK1|component_of|DT8
LK2|component_of|DT24
LK3|requires|LK1,LK2,SU4
LK4|component_of|DT24
LK4|enables|PP5,PP6,XD3
LK5|requires|LK1
# prompt pipeline sequence
PP1|enables|PP2
PP2|enables|PP3
PP3|enables|PP4
PP4|enables|PP5
PP5|enables|PP6
PP6|enables|PP7
PP7|enables|PX2
# prompt pipeline → LLM identity
PP7|enables|LI1
LI1|requires|MD6,CM1,CM2
LI2|requires|CO20
LI3|requires|LT10
# causal chain
CC1|requires|PL1-PL5,RT1-RT26
CC2|requires|CC1
CC3|requires|CC2
CC4|implements|PR16
CC5|derives_from|CC3
CC5|enables|IF3
# error model
EM1|opposes|EM2
EM2|requires|LI1,IN42
EM3|subtype_of|EM2
EM4|requires|CC3,EM2
EM5|derives_from|EM2
# translation
TL1|requires|PP1-PP7
TL2|requires|PL6,DT23
TL4|requires|CO11
TL5|requires|LI1
TL6|requires|IG1-IG6
# poetry
PO1|extends|DT23
PO2|requires|RT13,RT14
PO3|requires|PO2,IN41
PO4|requires|LI1,PO2,PO3
# patterns
PT1|implements|IN43
PT2|requires|PT1,RT18
PT3|requires|PT1,TL4
PT4|requires|PT1,CO28
# feedback
FB1|produces|FB2
FB2|enables|FB3,FB4,FB5
FB3|implements|IN46
FB6|requires|FB1,DT7
# cross-domain
XD1|requires|LK4,SU5
XD2|requires|SU6
XD3|requires|LK4,SU5
XD4|requires|IG1-IG6
XD5|requires|IG1-IG6,CO11
XD6|requires|CO11
# pipeline → inference
PX1|enables|PX2
PX2|enables|PX3
PX3|enables|PX4
PX4|enables|PX5,PX6,PX7
PX8|requires|IF3
PX9|enables|PX1
# prolog priority
PL1|precedes|PL2
PL2|precedes|PL3
PL3|precedes|PL4
PL4|precedes|PL5
PL5|precedes|PL6
# build/impl
BS1|enables|BS2
BS2|enables|BS3
BS3|enables|BS4
BS4|enables|BS5
BS5|enables|BS6
IM1|enables|IM2
IM2|enables|IM3
IM3|enables|IM4
IM4|enables|IM4b
IM4b|enables|IM5
IM5|enables|IM6
IM6|enables|IM7
# ingestion
IG1|enables|IG2
IG2|enables|IG3
IG3|enables|IG4
IG4|enables|IG5
IG5|enables|IG6
# relation type algebra
RT1|inverse_of|RT12
RT5|inverse_of|RT16
RT7|inverse_of|RT8
RT10|inverse_of|RT11
RT15|inverse_of|RT16
RT17|inverse_of|RT18
RT19|inverse_of|RT20
# confidence
CF12|constrains|CC3,PL2

# section_index(section|title|ids)
1|Scope and Principles|PR1-PR18
2|System Architecture|CO1-CO28
3|ID System|IS1-IS6
3.1|Structural UUID|SU1-SU8
3.2|Two-Tier Lookup|LK1-LK5
4|Core Data Types|DT1-DT31
5|Arithmetic|AR1-AR5
6|Memory|AM1-AM4
7|KB Tree|KT1-KT16
8|HTTP|HT1-HT6
9|Compute|CM1-CM6
10|Model|MD1-MD16
11|Prolog Engine|PL1-PL8,RT1-RT27
12|Ingestion|IG1-IG6
13|Confidence|CF1-CF15
14|Scoring|SC1-SC6
15|FSM|FS1-FS8
16|Prompt Input Pipeline|PP1-PP7
17|LLM as UUID Predictor|LI1-LI4
18|Causal Chain Derivation|CC1-CC5
19|Error Model|EM1-EM5
20|Translation|TL1-TL6
21|Poetry Mode|PO1-PO6
22|Bidirectional Patterns|PT1-PT5
23|User Feedback|FB1-FB6
24|Cross-Domain Composition|XD1-XD6
25|Unified Pipeline|PX1-PX9
26|Inference Levels|IF1-IF3
27|LLM Tree|LT1-LT10
28|Persistence|PS1-PS7
29|Errors|ER1-ER9
30|Invariants|IN1-IN47
31|Performance|PF1-PF14
32|Scale Model|SK1-SK12
33|Product|PD1-PD6
34|Build|BS1-BS6
35|Implementation|IM1-IM8

# decode_legend
id_prefixes: PR=principle, IS=id_system, SU=structural_uuid, LK=lookup, DT=data_type, AR=arithmetic, AM=arena, KT=kb_tree, CO=component, HT=http, CM=compute, MD=model, PL=prolog, RT=relation_type, IG=ingestion, CF=confidence, SC=scoring, FS=fsm, PP=prompt_pipeline, LI=llm_identity, CC=causal_chain, EM=error_model, TL=translation, PO=poetry, PT=pattern, FB=feedback, XD=cross_domain, PX=pipeline, IF=inference, LT=llm_tree, PS=persistence, ER=error, IN=invariant, PF=performance, SK=scale, PD=product, BS=build_stage, IM=impl_stage
rel_types: constrains|enables|requires|implements|derives_from|component_of|precedes|opposes|subtype_of|extends|inverse_of|produces|cross_ref
source: merged from VDR-Prolog Technical Specification v0.5 (main) + Session Design Extensions Addendum + SNK summary
changes_from_v04: system RelationType 0-25 (was 0-19); Prolog 6-level priority chain; FSM+scoring as KB data structures; 24 builtin categories; structural UUID bit layout; two-tier lookup; prompt input pipeline (6 stages); LLM-as-UUID-predictor; causal chain derivation; error model; translation architecture; poetry mode; bidirectional patterns; user feedback; cross-domain GEMM scoping; product architecture; 47 invariants (was 35); ~28K lines (was ~25K); 31 files (was 27+4)
zig_version: 0.15.1, x86_64 only
target: Dell Legion 5 (~2019), 6-8 cores, 16-32GB RAM, AVX2
confidence: compacted from v0.5 spec + addendum — all values, types, invariants, formulas, and architectural decisions preserved exactly