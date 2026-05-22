# VDR-PROLOG TECHNICAL SPECIFICATION v0.5 — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: principles → id_system → data_types → arithmetic → arenas → kb_tree → components → http → compute → model → prolog → ingestion → confidence → scoring → fsm → pipeline → inference → persistence → config → errors → invariants → performance → build_stages → impl_stages → files → relationships → section_index

# principles(id|principle|rationale|enforced_by)
PR1|no float anywhere|integer in, integer through, integer out — not in arithmetic, HTTP, timing, logging, scoring curves|IN6, build.zig
PR2|no malloc after init|one bounded exception: temporary training arenas, destroyed after use|IN12
PR3|remainder is not error|every divTrunc captures its mod — discarding remainder is the bug float normalized|IN1
PR4|arena-only memory|fixed-size contiguous blocks, bump pointer, no free, no reuse until reset|vdr_arena.zig
PR5|no coordination on hot path|per-thread GEMM, no row splitting, no barrier, no mutex, no IPC|IN23
PR6|sign-bit partitions address space|bit 63=0 global (positive, persistent), bit 63=1 session (negative, ephemeral)|IN8
PR7|session data dies with session|arena reset → all data gone instantly, no traversal, no fragmentation|IN9
PR8|weights live where they serve|no separate model tree — weights in domain KBs alongside facts and rules|vdr_model.zig
PR9|typed relations bypass unification|enum dispatch, integer scans — sub-microsecond|IN20
PR10|compaction reduces model size|every typed relation is a reasoning op the NN does not need to learn|§9.2
PR11|SIMD and scalar bit-identical|AVX2 and scalar paths produce identical output bytes|IN11
PR12|model weights are i16|2 bytes v + 2 bytes r0 + 2 bytes r1 = 8 bytes per param total|WeightMatrix
PR13|system scalability via per-core isolation|adding cores adds concurrent sessions linearly|§7.1
PR14|FSM and scoring are KB data structures|FSM lives in KB like LRU/queue — not a type of KB; behavior set likewise|§4.3, §4.7, §4.8

# id_system(id|concept|description|notes)
IS1|VdrId|i64 with sign-bit partition — 0=none, positive=global, negative=session|isGlobal/isEphemeral/isNone/eql methods
IS2|UUID addressing|signed i64, O(1) lookup table|canonical identifier
IS3|dotted path|hierarchical walk from root|root.science.physics.qed (global), session_root._llm.prompt_last (session)
IS4|local index|array slot within KB|facts[0] within specific KB
IS5|resolution order|session first (negative), then global (positive)|session shadows global, promotion explicit
IS6|org/client tree|root._organization.{org}.clients.{client}, root._client.{client}.sessions.{session}|sessions persist across HTTP disconnects

# data_types(id|type|size_bytes|alignment|key_fields|purpose)
DT1|Q16|8|4|v:i32, r0:i16, r1:i16|primary arithmetic, D=65536 implicit
DT2|Q32|16|8|v:i64, r0:i32, r1:i32|Newton-Raphson, escalated, D=2^32
DT3|Q335|240|8|v/r0/r1/r2/r3 each [6]i64|physics/transcendentals, D=2^335
DT4|VdrId|8|8|v:i64|sign-bit partitioned entity ID
DT5|Fact|48|8|tag:FactTag, value:Q16, provenance:Provenance|atomic knowledge unit — 15 tag types
DT6|FactTag|enum i32|—|value,text,reference,timestamp,enum_tag,boolean,vector,matrix,provenance_tag,rule_ref,grammar_ref,counter,relation,column_schema,empty(255)|determines Fact.value interpretation
DT7|Provenance|36|8|source_type:i32, source_kb_id:VdrId, source_slot_id:i32, confidence:Q16, timestamp:i32, derivation_rule_id:i32, capability_level:i32|every Fact carries full provenance
DT8|KB|256|8|~60 fields: identity, stores, weights, relations, domain_rel_defs, compaction, live state, fsm_offset, behavior_set_offset, new_facts, children, training, metadata, functor_index|4 cache lines, tree node, training_arena only nullable pointer
DT9|Term|24|4|type:TermType(i8), primary_id:i32, secondary_offset:i32, secondary_aux:i32, vdr_value:Q16|Prolog term — 10 types
DT10|Rule|48|8|id:VdrId, head:i32, body_offset/count, action_offset/count, fire/success/failure counts, created_at, creator_session_id|carries own statistics
DT11|TypedRelation|48|8|rel_type:RelationType(i16), from_id:VdrId, to_id:VdrId, provenance:Provenance, strength:Q16, scope_kb_id:VdrId|first-class typed edge, binary or weighted
DT12|RelationIndex|~528|4|by_type_counts:[128]i32, by_from/to offsets, total_relations, last_rebuilt|eventually consistent acceleration structure
DT13|DomainRelationDef|32|8|slot:i16, name_offset/length, is_symmetric:bool, is_transitive:bool, inverse_slot:i16, source_document_id:VdrId, registered_at:i32|domain relation properties
DT14|WeightMatrix|~32|8|v:[]i32, r0:[]i16, r1:[]i16, rows:i32, cols:i32|SoA, column-major, cache-line aligned
DT15|KbWeightRefs|~48|8|matrix_refs/count/capacity, vector_refs/count/capacity, gemm_cache:?GemmCache|per-KB weight reference table
DT16|GemmCache|~32|8|v_packed:[]i32, fact_count, kb_id, kb_last_modified, generation|packed v fields for GEMM hot path
DT17|WeightVector|~24|8|v:[]i32, r0:[]i16, r1:[]i16, length:i32|1D SoA weight storage
DT18|CompactionProfile|256|4|source_document_id, tables/rows/facts/relations/rules counts, relation_types_used:[128]bool, domain_types_registered, text/numeric counts, compression_ratio:Q16, timestamp, validation_errors|immutable after creation
DT19|Fsm|~64|8|id, fsm_type:FsmType(i8), current/previous/initial_state:i32, states_offset/count, transitions_kb_id, outputs_kb_id, parent_fsm_id, children_offset/count, last_transition_time, transition_count, is_terminal|per-KB state machine
DT20|FsmType|enum i8|—|moore=0, mealy=1, dfa=2, statechart=3|FSM classification
DT21|ResponseCurve|~28|4|curve_type:CurveType, param_a/b/c:Q16, inverted:bool, breakpoints_offset/count|14 curve types: linear, polynomial, logistic, gaussian, step, smoothstep, piecewise, etc.
DT22|Consideration|~40|4|input:InputSource, curve:ResponseCurve, weight:Q16, floor:Q16, is_gate:bool, last_score:Q16, last_raw_input:Q16|atomic scoring unit — 10 input source types
DT23|InputSource|enum|—|kb_fact, session_counter, relation_count, confidence, time_elapsed, arena_usage, builtin_result, constant, level_stats, resource_ratio|where considerations read from
DT24|Behavior|~48|8|id:VdrId, name, action:BehaviorAction, considerations_offset/count, compensation:CompensationConfig, weight:Q16, floor:Q16, selection_count, last_selected|candidate action with scoring
DT25|BehaviorAction|enum|—|prolog_query, builtin_call, llm_command, kb_assert, nested_set, rule_fire, grammar_render|what winner does
DT26|BehaviorSet|~48|8|id:VdrId, behaviors_offset/count, selection:SelectionMethod, top_n, temperature:Q16, hysteresis_bonus:Q16, eligibility_threshold:Q16, current_behavior_id, owner_kb_id, evaluation_count, last_evaluated|scored set with selection method
DT27|SelectionMethod|enum|—|argmax, weighted_random_top_n, boltzmann, argmax_with_hysteresis, threshold_then_argmax|5 selection strategies
DT28|Session|~256|8|id, user_id, kb roots, ephemeral_next_id, state, core/arena binding, resource limits (5), counters (~15), snapshot/clone lineage, atom_rel_cache_offset, surface_dirty|isolation boundary
DT29|KbStore|~320|8|global_arena, path_index, loaded_lut, manifest, next_global_id(=17), atom_table, text_store, data_dir|single instance, all engines hold pointer
DT30|RelationType|enum i16|—|system 0-25: enables,requires,prevents,implements,extends,overrides,validates,verified_by,contradicts,causes,determined_by,depends_on,equivalent_to,approximates,specializes,generalizes,part_of,contains,follows,precedes,instance_of,scoped_to,flows_to,transforms_to,derived_from,composed_of; domain 64-127; unknown=-1|inverse/isSymmetric/isTransitive methods
DT31|QueryClassification|~56|4|has_relation, rel_type, from/to hints, has_transitive, transitive_type/root, has_fact, path_hash/slot, has_aggregation, agg_type/target, confidence:Q16, match_count|pre-LLM pattern detection
DT32|L3PreResolution|~24|4|resolved:bool, resolution_type:ResolutionType, result_count, results_offset, classification_confidence:Q16, resolution_time_us|pre-resolution result for prompt_current
DT33|ResolutionType|enum i8|—|none=0, relation_index=1, transitive_closure=2, inverse_lookup=3, symmetric_swap=4, prolog_rule=5, fact_read=6|L3 resolution method
DT34|PrologEngine|~64|8|store, scratch, session, global_arena, atom_rel_cache, level_stats, config|one per session, no mutable state between queries
DT35|FunctorIndex|~280|4|buckets:[64]i32, entries/chains offsets, entries_count, last_rebuilt|hash index for fast rule head lookup, built when rules > 64
DT36|AtomRelTypeCache|~520|4|entries:[64]AtomRelTypeCacheEntry, count|per-session atom→RelationType, reset on grant change
DT37|LevelStats|~96|8|l1/l2/l3 counts+tokens, l3 relation/transitive/inverse counts, pre_resolution tracking (hits/assists/misses)|execution level statistics
DT38|ModelConfig|~288|4|n_layers, d_model, n_heads, d_head, vocab_size, mlp_dim, max_seq_len, checkpoint_path, activation_type|totalParams/weightBytes methods
DT39|ModelReductionConfig|~64|4|base (16/5632/16/32000) vs reduced (6/2048/12/8192), compaction metrics, use_i16_weights|advisory — admin sets, system estimates
DT40|SystemConfig|~512|8|n_cores, model, model_reduction, arena sizes, all limits, http_port(1138), ingestion, relation_index_rebuild_interval, seed/sampling/prolog/context configs|top-level, JSON loaded at startup

# arithmetic(id|operation|formula|remainder_handling|escalation)
AR1|Q16 addition|r1 sum → carry r0 → carry v|full chain, no loss|—
AR2|Q16 multiplication|product=i64(a.v×b.v), v=divTrunc(product,D), r0=mod(product,D), r1 from cross-terms|cross-terms captured|—
AR3|Q16 division|widened=a.v×D, v=divTrunc(widened,b.v), r0=mod(widened,b.v), r1=r0×D/b.v|worse than mul — non-D-factor divisors push r1 toward saturation|r1 near ±32767 → Q32
AR4|Q16 comparison|lexicographic v→r0→r1|no epsilon, equal = all three match|—
AR5|Dave Mark compensation|mf=(n-1)/n, make_up=(D-score)×mf/D, compensated=score+(make_up×score/D), final=∏(compensated_i)|all Q16, epsilon floor v=655 ≈ 1%|gates excluded

# arenas(id|arena|size|contents|reset_policy)
AM1|global|~1.27 GB|weights ~572MB, KBs ~25MB, facts ~480MB, relations ~50MB, indices ~10MB, rules/terms/text ~93MB, grants/audit ~33MB, compaction ~2MB, confidence 88B|never reset
AM2|per-core|~220 MB each ×N|sessions, session KBs/facts, KV cache, scratch, bindings, render, work queue|region reset on session death
AM3|training temp|sized per-KB (10KB–176MB)|gradients+r0/r1, momentum, variance, activations, transpose, scratch|destroyed after use, pointer nulled
AM4|system total (8 cores)|~3.03 GB|fits 8GB with room for OS|—

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
KT10|root.system.relation_types|+13|system (frozen) + domain (appendable)|no (appendable)
KT11|root.system.ingestion|+14|queue + CompactionProfile records|no
KT12|root.system.scoring|+15|system behavior sets|no
KT13|root.system.fsm|+16|system FSM definitions|no
KT14|root.templates|+10|template parent|yes
KT15|root.templates.sentences|+11|~100 sentence grammars|yes
KT16|root.templates.formats|+12|~50 output format grammars|yes

# components(id|component|file|role)
CO1|arena allocator|vdr_arena.zig|memory foundation — ArenaSet, bump pointer
CO2|config loader|vdr_config.zig|JSON → SystemConfig, strict errors
CO3|thread pool|vdr_thread_pool.zig|NUMA-pinned compute threads, spin-wait
CO4|HTTP listener|vdr_http.zig|non-pinned, accepts, spawns handlers
CO5|work queue|vdr_work_queue.zig|per-core atomic ring buffer, lock-free
CO6|KB store|vdr_kb_store.zig|KB CRUD, path index, session resolution
CO7|SIMD ops|vdr_ops.zig|AVX2 GEMM, softmax, RMSNorm, attention, SiLU
CO8|model engine|vdr_model.zig|three-path weight retrieval, forward pass
CO9|Prolog engine|vdr_prolog.zig|unification, query, backtracking, fire_and_commit
CO10|relation engine|vdr_relation.zig|RelationIndex, typed queries, transitive closure, inverse
CO11|grammar engine|vdr_grammar.zig|template compile, render, inherit
CO12|inference engine|vdr_inference.zig|full loop, prompt cycle, L1/L2/L3
CO13|ingestion engine|vdr_ingestion.zig|parser, validator, KB/fact/relation assertion
CO14|training engine|vdr_training.zig|canTrain, train, temp arenas, weight update
CO15|persistence|vdr_persist.zig|save/load KB/weight files, manifest, lazy loading
CO16|snapshot engine|vdr_snapshot.zig|session snapshots, CRC32
CO17|scoring engine|vdr_scoring.zig|response curves, compensation, behavior selection
CO18|FSM engine|vdr_fsm.zig|state management, transition eval, state→behavior_set
CO19|access engine|vdr_access.zig|visibility, session/global resolution, weight access
CO20|grant engine|vdr_grant.zig|grant CRUD, check, cleanup
CO21|audit engine|vdr_audit.zig|ring buffer, query, filter
CO22|confidence engine|vdr_confidence.zig|assign, combine, chain, propagate
CO23|seed engine|vdr_seed.zig|seed layer init, domain weight KB creation
CO24|builtin engine|vdr_builtin.zig|448 builtins, 24 categories
CO25|command engine|vdr_command.zig|parser, executor, dispatch
CO26|session engine|vdr_session.zig|lifecycle, _llm.* subtree, clone/merge/kill
CO27|system engine|vdr_system.zig|top-level init, wire everything
CO28|test suite|vdr_test.zig|determinism, SIMD, snapshots, relations, compaction

# http(id|component|description|threading)
HT1|listener|port from config (default 1138)|non-pinned
HT2|handler|parse JSON → resolve client/session → push to per-core queue → spin-wait → respond|non-pinned
HT3|work queue|atomic ring buffer, queue full = HTTP 503|bridge I/O→compute
HT4|session binding|bound to core at creation, all requests routed there|per-core
HT5|session persistence|creation clones template (COW), LRU ejects coldest with snapshot, restore on reconnect|per-core
HT6|separation rule|pinned threads only compute, HTTP threads only I/O, work queue is only bridge|architectural invariant

# compute(id|operation|description|remainder|invariant)
CM1|GEMM|8×i32 widen-madd in i64, divTrunc by D at end, per-thread no coordination|r0 from final divTrunc|IN1, IN5, IN23
CM2|softmax|integer exp, integer division, per-element remainder, FRU assigns deficit to largest-remainder element|sum = D = 65536 exactly every time|IN3
CM3|RMSNorm|Newton-Raphson 4 iterations in i64 for inv_sqrt, scale via i32 multiply|r0 from divTrunc|IN7 escalation
CM4|attention|per-head Q·K dot, causal mask, exact softmax, weighted V sum|r0 carried through|IN5
CM5|SiLU|scalar piecewise integer approximation|r0 per element|—
CM6|residual add|8×i32 add with full r1→r0→v carry chain|no loss|IN2

# model(id|concept|value|notes)
MD1|d_model|2048|unchanged
MD2|n_layers|6|reduced from 16
MD3|n_heads|12|reduced from 16
MD4|d_head|170|increased from 128 (fewer wider heads)
MD5|mlp_dim|2048|reduced from 5632
MD6|vocab_size|8192|reduced from 32000
MD7|total_params|~143M|85.7% reduction from ~1B
MD8|weight_memory|~286 MB v, ~572 MB total with r0/r1|i16 per param
MD9|per_token_MACs|~126M|~5.3ms at AVX2
MD10|single_core_tok_s|~190|—
MD11|system_8core_tok_s|~1520|8 concurrent sessions
MD12|effective_req_s_93pct_l3|~21700|1520/0.07
MD13|layer 1-2|token embedding, syntax|understanding input
MD14|layer 3-4|semantic understanding, KB address resolution|deciding what to do
MD15|layer 5-6|output planning, judgment|deciding how to respond
MD16|three-path retrieval|P1: fact scan (new), P2: GEMM cache (hot), P3: cache+new_facts|per-group caches for access tiers

# prolog(id|concept|description|priority|cost)
PL1|typed relation fast path|functor matches RelationType → RelationIndex scan, integer comparison|1 (highest)|sub-microsecond, L3
PL2|transitive closure|BFS over contiguous integer arrays for transitive types (10+)|2|zero tokens, L3
PL3|inverse lookup|rewrite depends_on(X,target) → enables(target,X), one index both directions|3|L3
PL4|symmetric swap|auto-query with from/to swapped for symmetric types|4|L3
PL5|structural inheritance|ancestors via specializes/instance_of closure, scan inherited requires/prevents/contains|5|L3
PL6|general Prolog|full unification, depth-first, explicit backtracking stack in scratch|6 (lowest)|L1 or L2
PL7|fire_and_commit|scan rules against facts, fire satisfied, assert derived facts at prolog_derivation confidence|—|L3 automatic derivation
PL8|core rules|generated from RelationType properties — taxonomy, containment, enablement, requirement, symmetry, inverse, sequence, scope|—|no domain document adds structural rules, only facts

# prolog_core_rules(id|category|types|mechanism)
PC1|taxonomy|specializes (transitive), instance_of inheritance of requires/prevents/contains|BFS + inherited fact scan
PC2|containment|contains/part_of transitive closure, mutual inverse|BFS + inverse dispatch
PC3|enablement|enables transitive closure, depends_on inverse|BFS + inverse
PC4|requirement|requires transitive closure, inheritance through extends|BFS + inheritance scan
PC5|symmetry|prevents, contradicts, equivalent_to, approximates|auto-swap from/to
PC6|inverse pairs|enables↔depends_on, specializes↔generalizes, part_of↔contains, follows↔precedes, validates↔verified_by, causes↔determined_by, + 4 more|compile-time switch
PC7|sequence|follows/precedes transitive closure, mutual inverse|BFS + inverse
PC8|scope|scoped_to transitive through part_of|BFS chain

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
RT27|64-127|domain slots|per-registration|per-registration|per-registration

# ingestion(id|stage|description|input|output)
IG1|external compaction|raw document → LLM → .compact file (pipe-delimited tables)|raw document|.compact at llm_generated (30/100)
IG2|validation|IDs unique, relationship targets exist, column counts match, decode legend present|.compact|validated
IG3|KB creation|parent document KB + child KB per table|validated|KB subtree
IG4|fact assertion|text→TAG_TEXT, numeric→TAG_VALUE, column schema→TAG_COLUMN_SCHEMA|KBs|populated facts
IG5|relation + rule assertion|relationships→TypedRelation + Prolog rules, multi-target/range expanded, domain types registered|relationships|TypedRelation + Rule records
IG6|profile + freeze|CompactionProfile recorded, KBs frozen if configured|completed|immutable profile

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

# confidence_rules(id|operation|formula)
CR1|chain|min(inputs)
CR2|parallel agree|max(sources)
CR3|contradiction|0
CR4|ingestion|min(source_type, compaction_stage)

# scoring(id|concept|description|notes)
SC1|response curve|14 types: linear, polynomial, logistic, gaussian, step, smoothstep, piecewise, etc.|maps raw input [0,1] → utility [0,1]
SC2|consideration|input source → normalize → curve → [0,1] score|10 input sources: kb_fact, session_counter, relation_count, confidence, time_elapsed, arena_usage, builtin_result, constant, level_stats, resource_ratio
SC3|behavior|candidate action scored by combining considerations|action types: prolog_query, builtin_call, llm_command, kb_assert, nested_set, rule_fire, grammar_render
SC4|behavior set|collection valid in current FSM state, with selection method|5 methods: argmax, weighted_random_top_n, boltzmann, argmax_with_hysteresis, threshold_then_argmax
SC5|compensation|Dave Mark: mf=(n-1)/n, compensated=score+(make_up×score/D), final=∏(compensated_i)|all Q16, epsilon floor v=655, gates excluded
SC6|items counter|prompt_current.items_seen_by_llm vs items_total|unread = total - seen, reset at cycle boundary

# fsm(id|concept|description|notes)
FS1|FSM in KB|lives at kb.fsm_offset, same pattern as LRU/queue — data structure, not KB type|states are atoms, transitions are rules in child KB, outputs are facts in child KB
FS2|Moore|output per state — behavior set doesn't change until state changes|session lifecycle, KB lifecycle, inference cycle
FS3|Mealy|output per transition — action fires during transition|HTTP request lifecycle
FS4|DFA|accepts/rejects — query classification|level selection (L3/L2/L1)
FS5|statechart|nested states + concurrent regions|complex domain AI, parent_fsm_id + children
FS6|transition eval|Prolog rules checked each cycle, evolves_to(Current,Next) :- conditions|first match fires, atomic state update + log
FS7|session lifecycle FSM|created → active ↔ suspended → ejected ↔ active → killed|root.system.fsm
FS8|session-local FSMs|conversation phase, task tracker, domain-specific|ephemeral, die with session, snapshotted

# pipeline(id|step|description|level)
PX1|input|system writes user input to prompt_input|—
PX2|pre-resolution|classify query pattern (keyword, not LLM), attempt L3 typed relation / rule fire|L3
PX3|FSM evaluation|check transitions for all active FSMs, update state, resolve behavior set|L3
PX4|UAI scoring|gate checks → soft scoring → Dave Mark compensation → selection method|L3
PX5|execution — L3 complete|pre-resolution answered → LLM frames (~20 tokens)|L3+framing
PX6|execution — action|UAI winner has direct action → execute → LLM frames|L2-L3
PX7|execution — defer|score below threshold or defer_to_llm → full forward pass|L1
PX8|LLM generation|read prompt_last + prompt_current new items, accept/override/augment, write prompt_next|L1/L2
PX9|post-generation|re-eval FSM transitions, copy prompt_next→prompt_last, clear transients, reset counters|L3

# inference(id|level|tokens|cost_ratio|description)
IF1|L3|0 LLM (+ ~20 framing)|0%|typed relation, transitive, inverse, FSM transition, UAI scoring, rule fire — 93% at maturity
IF2|L2|~18|~3%|LLM selects from candidates, emits command, Prolog executes — ~38 total
IF3|L1|50-500|100%|full forward pass — novel queries, ambiguity, judgment

# llm_tree(id|path|purpose)
LT1|session_root._llm.prompt_last|continuity from previous cycle
LT2|session_root._llm.prompt_next|what to carry forward
LT3|session_root._llm.prompt_input|current user request (system writes)
LT4|session_root._llm.prompt_current|working scratch + logged results (cleared each cycle)
LT5|session_root._llm.history|bounded queue of cycle history
LT6|session_root._llm.projects|project tracking
LT7|session_root._llm.people|people tracking per context
LT8|session_root._llm.concepts|topic relationships + availability surface
LT9|session_root._llm.search|search results and background
LT10|session_root._llm.scratchpad|persistent cross-prompt scratch

# persistence(id|format|magic|contents|notes)
PS1|.kb|VDKB v1|header + KB + facts + rules + terms + children + text + weight_refs + relations + RelationIndex + new_facts + CompactionProfile|raw struct bytes, CRC32
PS2|.wt|VDWT v1|header + v(i32) + r0(i16) + r1(i16) SoA|CRC32
PS3|.snap|VDRS v4|header + regions + counts + Session + checksum|bit-identical restore
PS4|manifest.dat|VDMF v1|index of all persisted KBs (~100 bytes/entry)|only file at startup
PS5|.compact|—|pipe-delimited tables|ingestion input
PS6|config.json|—|SystemConfig|hard-mapped, strict errors

# errors(id|category|codes|recovery)
ER1|arithmetic|division_by_zero(100), overflow(101)|log_and_continue
ER2|kb|not_found(200), full(201), frozen(202), access_denied(203), slot_out_of_range(204), slot_empty(205)|compact / log / deny
ER3|prolog|depth_exceeded(300), no_matching_rule(301), unification_failed(302), max_bindings(303)|simplify / log
ER4|grammar|invalid_template(400), type_mismatch(401), capacity_exceeded(402)|log
ER5|session|limit(500), snapshot_failed(501), corrupt(502), clone_failed(503), merge_conflict(504)|kill_oldest / retry / restore
ER6|grant|denied(600), expired(601), exhausted(602), revoked(603), admin_required(604)|deny
ER7|runner|error_threshold(700), connection_lost(701)|recycle / reconnect
ER8|memory|arena_exhausted(800), not_found(801)|kill_oldest
ER9|system|init_failed(900), corrupt_state(901), seed_load_failed(902)|restore

# invariants(id|number|statement|enforced_in)
IN1|1|remainder never discarded — every divTrunc captures mod|vdr_ops.zig
IN2|2|r0 and r1 carry exact meaning, never padding|vdr_ops.zig, vdr_types.zig
IN3|3|softmax sums to D exactly, every time|vdr_ops.zig (FRU)
IN4|4|comparison uses all three Q16 fields, no epsilon|vdr_types.zig
IN5|5|all multiplications widen to i64|vdr_ops.zig
IN6|6|no float anywhere|build.zig, all files
IN7|7|r1 near ±32767 = escalate to Q32|vdr_ops.zig, vdr_training.zig
IN8|8|session IDs (negative) never collide with global (positive)|vdr_types.zig
IN9|9|session data dies with session, arena reset|vdr_session.zig
IN10|10|arena exhaustion never silent|vdr_arena.zig
IN11|11|SIMD and scalar bit-identical|vdr_test.zig
IN12|12|training arenas only post-startup allocation|vdr_training.zig
IN13|13|_llm.* subtree structure fixed|vdr_session.zig
IN14|14|all dynamic arrays use ArrayListManaged on arena|all files
IN15|15|fromParts always three arguments (v, r0, r1)|vdr_types.zig
IN16|16|RelationType slots 0-25 system-defined, frozen|vdr_types.zig
IN17|17|domain slots 64-127 first-come, never reassigned|vdr_relation.zig
IN18|18|every TypedRelation has TAG_RELATION Fact for provenance|vdr_relation.zig
IN19|19|RelationIndex eventually consistent, rebuilt periodically|vdr_relation.zig
IN20|20|typed relation queries bypass Prolog unification|vdr_relation.zig
IN21|21|model reduction config advisory|vdr_config.zig
IN22|22|compaction profiles immutable after ingestion|vdr_ingestion.zig
IN23|23|GEMM per-thread, no cross-core coordination|vdr_ops.zig
IN24|24|KBs lazy-load, unaccessed = zero memory|vdr_persist.zig
IN25|25|FSM current_state always valid atom|vdr_fsm.zig
IN26|26|FSM transitions fire only from current state|vdr_fsm.zig
IN27|27|every FSM state maps to exactly one behavior set or none (terminal)|vdr_fsm.zig
IN28|28|UAI scoring never NaN or infinity — Q16 prevents|vdr_scoring.zig
IN29|29|Dave Mark compensation (1-1/n) in Q16 with exact remainder|vdr_scoring.zig
IN30|30|gate considerations excluded from compensation|vdr_scoring.zig
IN31|31|items_seen_by_llm never exceeds items_total|vdr_scoring.zig
IN32|32|prompt_current counters reset to 0 when cleared|vdr_session.zig
IN33|33|session-local FSMs die with session|vdr_fsm.zig
IN34|34|transition eval and UAI scoring on pinned compute thread|vdr_fsm.zig, vdr_scoring.zig
IN35|35|BehaviorSet argmax deterministic, weighted random uses session PRNG|vdr_scoring.zig

# build_stages(id|stage|files|validation)
BS1|kernel + arena|build.zig, root.zig, vdr_arena.zig, vdr_types.zig|compiles, allocates, prints diagnostics, exits 0
BS2|config|vdr_config.zig|parsed values printed, bad JSON exits 1
BS3|arena set|vdr_arena.zig|prints layout matching config
BS4|pinned threads|vdr_thread_pool.zig|N threads spawn, pin, touch, join
BS5|HTTP|vdr_http.zig|curl health → ok, clean shutdown
BS6|work passing|vdr_work_queue.zig|response from pinned core, concurrent distribution

# impl_stages(id|stage|lines|files|description)
IM1|foundation|~5000|vdr_types, vdr_arena, vdr_config, vdr_thread_pool, vdr_http, vdr_work_queue, vdr_kb_store, vdr_access, vdr_ops (scalar)|basic session + _llm.* subtree
IM2|intelligence|~6000|vdr_prolog, vdr_grammar, vdr_builtin, vdr_session, vdr_grant, vdr_audit, vdr_confidence, vdr_command|reasoning, auth, security
IM3|compute|~4000|vdr_ops (AVX2), vdr_model, vdr_inference|SIMD, weights, inference loop
IM4|ingestion + relations|~3000|vdr_ingestion, vdr_relation|parser, validator, relation index, typed queries
IM4b|scoring + FSM|~3000|vdr_scoring, vdr_fsm|curves, compensation, state machines
IM5|training + ops|~4000|vdr_training, vdr_runner, vdr_seed, vdr_system|training arenas, runners, bootstrap
IM6|persistence|~2000|vdr_persist, vdr_snapshot|save/load, manifest, lazy loading
IM7|testing|~1000|vdr_test|full test suite
IM8|total|~28000|31 files|—

# files(id|file|description)
FI1|vdr_types.zig|all persistent structs, enums, constants, KbStore
FI2|vdr_ingestion.zig|parse-time structs, parser, validator
FI3|vdr_arena.zig|arena allocator, ArenaSet
FI4|vdr_config.zig|JSON config loading
FI5|vdr_thread_pool.zig|pinned threads, lifecycle
FI6|vdr_work_queue.zig|per-core atomic ring buffer
FI7|vdr_http.zig|non-pinned HTTP listener/handlers
FI8|vdr_ops.zig|SIMD: gemm, dot, softmax, rmsnorm, attention, silu
FI9|vdr_model.zig|KB-distributed weights, three-path retrieval
FI10|vdr_kb_store.zig|KB CRUD, path index, session resolution
FI11|vdr_relation.zig|RelationIndex, typed queries, transitive closure, inverse
FI12|vdr_prolog.zig|unification, query, backtracking, fire_and_commit
FI13|vdr_grammar.zig|template compile, render, inherit
FI14|vdr_session.zig|session lifecycle, _llm.* subtree, clone/merge/kill
FI15|vdr_persist.zig|save/load KB/weight files, manifest, lazy loading
FI16|vdr_snapshot.zig|session snapshots, CRC32
FI17|vdr_training.zig|canTrain, train, temp arenas, weight update
FI18|vdr_runner.zig|poller, processor, internal, batch
FI19|vdr_inference.zig|full inference loop, prompt cycle
FI20|vdr_command.zig|command parser, executor
FI21|vdr_access.zig|visibility, resolution, weight access
FI22|vdr_grant.zig|grant CRUD
FI23|vdr_audit.zig|ring buffer, query
FI24|vdr_confidence.zig|assign, combine, chain, propagate
FI25|vdr_seed.zig|seed layer init
FI26|vdr_builtin.zig|448 builtins, 24 categories
FI27|vdr_system.zig|top-level init
FI28|vdr_scoring.zig|response curves, compensation, behavior selection
FI29|vdr_fsm.zig|FSM state management, transition eval
FI30|vdr_test.zig|full test suite
FI31|build.zig|single native x86_64 target

# relationships(from|rel|to)
# principles → enforcement
PR1|constrains|DT1,DT2,DT3,DT5,DT7,DT14,AR1-AR5
PR2|constrains|AM3
PR3|constrains|AR1,AR2,AR3,CM1,CM2,CM3
PR4|constrains|AM1,AM2,AM3
PR5|constrains|CM1,CM4
PR6|constrains|IS1,IS5
PR8|constrains|MD16,DT14
PR9|constrains|PL1,RT1-RT26
PR10|constrains|IG1-IG6,MD2,MD3,MD5,MD6
PR14|constrains|DT19,DT26
# data type containment
DT5|contains|DT6,DT1,DT7
DT8|contains|DT5,DT10,DT11,DT12,DT13,DT14,DT15,DT18,DT19,DT26,DT35
DT11|contains|DT30,DT4,DT7,DT1
DT12|contains|DT30
DT19|contains|DT20,DT4
DT22|contains|DT21,DT23,DT1
DT24|contains|DT22,DT25,DT1
DT26|contains|DT24,DT27,DT4,DT1
DT28|contains|DT4,DT36
DT29|contains|DT4
DT31|contains|DT30,DT4,DT1
DT34|contains|DT29,DT36,DT28,DT37
DT37|contains|DT1
DT40|contains|DT38,DT39
# prolog priority chain
PL1|precedes|PL2
PL2|precedes|PL3
PL3|precedes|PL4
PL4|precedes|PL5
PL5|precedes|PL6
# prolog → relation types
PL1|requires|DT12,RT1-RT26
PL2|requires|RT1,RT2,RT5,RT12,RT15-RT20,RT22-RT26
PL3|requires|RT1,RT7-RT11,RT15-RT20
PL4|requires|RT3,RT9,RT13,RT14
PL5|requires|RT15,RT21
# scoring → FSM → pipeline
SC4|requires|FS1
FS1|enables|SC4
FS6|requires|CO9
PX2|enables|PX3
PX3|enables|PX4
PX4|enables|PX5,PX6,PX7
PX8|requires|IF3
PX9|enables|PX1
# ingestion pipeline
IG1|enables|IG2
IG2|enables|IG3
IG3|enables|IG4
IG4|enables|IG5
IG5|enables|IG6
IG5|produces|DT11,DT10
# model reduction chain
PR10|enables|MD2,MD3,MD5,MD6,MD7
MD7|derives_from|MD1,MD2,MD3,MD5,MD6
MD8|derives_from|MD7,PR12
MD12|derives_from|MD11,IF1
# build/impl sequence
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
CO17|implemented_in|FI28
CO18|implemented_in|FI29
CO19|implemented_in|FI21
CO20|implemented_in|FI22
CO21|implemented_in|FI23
CO22|implemented_in|FI24
CO23|implemented_in|FI25
CO24|implemented_in|FI26
CO25|implemented_in|FI20
CO26|implemented_in|FI14
CO27|implemented_in|FI27
CO28|implemented_in|FI30
# KB tree
KT1|contains|KT2,KT14
KT2|contains|KT3,KT4,KT5,KT6,KT7,KT8,KT9,KT10,KT11,KT12,KT13
KT14|contains|KT15,KT16
# relation type algebra
RT1|inverse_of|RT12
RT2|inverse_of|RT1
RT5|inverse_of|RT16
RT7|inverse_of|RT8
RT10|inverse_of|RT11
RT15|inverse_of|RT16
RT17|inverse_of|RT18
RT19|inverse_of|RT20
# confidence → provenance
CF1-CF11|implements|DT7
CR1|constrains|CF1-CF11
# cross-references between compactions
PL1|cross_ref|ME4
SC5|cross_ref|DM4
FS1|cross_ref|MT4
DT31|cross_ref|DP1

# section_index(section|title|ids)
1|Scope|PR1-PR14
2|System Architecture|CO1-CO28
3|ID System|IS1-IS6
4.1|Q16 Arithmetic|DT1-DT3,AR1-AR5
4.2-4.4|Fact, Provenance, KB, Prolog Types|DT4-DT10
4.5|Typed Relation System|DT11-DT13,DT30,RT1-RT27
4.6|Weight Storage|DT14-DT17
4.7|FSM|DT19-DT20,FS1-FS8
4.8|Utility AI Scoring|DT21-DT27,SC1-SC6
4.9|Session|DT28
4.10|Confidence|CF1-CF11,CR1-CR4
4.11|KbStore|DT29
5|Memory Architecture|AM1-AM4
6|HTTP Interface|HT1-HT6
7|Compute Model|CM1-CM6,MD1-MD16
8|Model Weights|MD8,MD16
9|Ingestion|IG1-IG6
10|Prolog Engine|PL1-PL8,PC1-PC8,DT31-DT36
11|Unified Decision Pipeline|PX1-PX9
12|Attention and Session LLM Tree|LT1-LT10,SC6
13|Training|AM3
14|Persistence|PS1-PS6
15|Seed Layer|KT1-KT16
16|Configuration|DT38-DT40
17|Performance|MD7-MD12
18|Errors|ER1-ER9
19|Invariants|IN1-IN35
20|Zig 0.15.1|—
21|Build Order|BS1-BS6
22|Implementation|IM1-IM8,FI1-FI31
IF|Execution Levels|IF1-IF3

# decode_legend
id_prefixes: PR=principle, IS=id_system, DT=data_type, AR=arithmetic, AM=arena, KT=kb_tree, CO=component, HT=http, CM=compute, MD=model, PL=prolog, PC=prolog_core_rule, RT=relation_type, IG=ingestion, CF=confidence, CR=confidence_rule, SC=scoring, FS=fsm, PX=pipeline, IF=inference_level, LT=llm_tree, PS=persistence, ER=error, IN=invariant, BS=build_stage, IM=impl_stage, FI=file
rel_types: constrains|contains|requires|enables|derives_from|produces|implemented_in|inverse_of|implements|precedes|cross_ref
cross_ref_prefixes: ME=method (TROUBLESHOOTING), DM=dave_mark_fixup (UTILITY AI), MT=machine_type (FSM), DP=diagnostic_pattern (TROUBLESHOOTING)
spec_version: 0.5
changes_from_v04: system RelationType slots expanded 0-25 (was 0-19, added instance_of, scoped_to, flows_to, transforms_to, derived_from, composed_of); Prolog priority chain formalized (6 levels); prolog core rules generated from RelationType properties; FSM and scoring integrated as KB data structures (not separate subsystems); builtin categories expanded to 24 (was 22+); structural inheritance added as priority 5; total lines ~28K (was ~25K); files 31 (was 27+4)
zig_version: 0.15.1, x86_64 only
target: Dell Legion 5 (~2019), 6-8 cores, 16-32GB RAM, AVX2
confidence: compacted from v0.5 source spec — all values, types, invariants, and formulas preserved exactly

# relation_mapping(doc_rel|canonical_rel|notes)
constrains|constrains|exact match
contains|contains|exact match
requires|requires|exact match
enables|enables|exact match
derives_from|derived_from|exact match
produces|produces|exact match
implemented_in|scoped_to|component implemented in file = scoped_to that file
inverse_of|complement_of|relation type is inverse of another; symmetric
implements|implements|exact match
precedes|precedes|exact match
cross_ref|references|cross-domain link = references
