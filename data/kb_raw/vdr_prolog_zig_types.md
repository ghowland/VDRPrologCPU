# VDR_TYPES.ZIG — COMPLETE TYPE DEFINITIONS — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: constants → enums → structs → struct_fields → methods → seed_ids → relationships → section_index

# constants(id|name|value|type|notes)
K1|D16|65536|i32|Q16 denominator, 2^16, implicit, never stored
K2|D32|4294967296|i64|Q32 denominator, 2^32
K3|CACHE_LINE|64|usize|cache line alignment target
K4|SNAPSHOT_MAGIC|'V','D','R','S'|[4]u8|snapshot file magic bytes
K5|SNAPSHOT_VERSION|4|i32|bumped for relation fields in KB
K6|COW_PAGE_SIZE|4096|i32|clone session page size
K7|MAX_CORES|16|i32|maximum supported cores
K8|RELATION_TYPE_SLOTS|128|usize|total relation type slots in index
K9|ATOM_REL_CACHE_SIZE|64|usize|per-session atom→RelationType cache
K10|FUNCTOR_INDEX_THRESHOLD|64|i32|rule count to trigger functor index build
K11|FUNCTOR_INDEX_BUCKETS|64|usize|hash buckets in functor index
K12|exp_table|[65536,24109,8874,3263,1201,442,162,60,22,8,3]|[11]i32|integer exp lookup

# enums(id|name|backing_type|values|notes)
EN1|FactTag|i32|value=0, text=1, reference=2, timestamp=3, enum_tag=4, boolean=5, vector=6, matrix=7, provenance_tag=8, rule_ref=9, grammar_ref=10, counter=11, relation=12, column_schema=13, empty=255|determines Fact.value interpretation
EN2|SourceType|i32|vdr_computation=0, prolog_derivation=1, database=2, prometheus=3, script=4, rest_api=5, published=6, user_stated=7, web_search=8, llm_generated=9, unknown=10|indexes confidence_table
EN3|TermType|i8|atom=0, variable=1, integer=2, vdr=3, text=4, list=5, compound=6, vector=7, matrix=8, pair=9|Prolog term discriminator
EN4|SessionState|i8|active=0, snapshotted=1, killed=2, frozen=3|session lifecycle states
EN5|RunnerType|i8|poller=0, processor=1, internal=2, batch=3|autonomous agent types
EN6|RunnerState|i8|stopped=0, running=1, err=2, recycling=3|runner lifecycle states
EN7|GrantClass|i8|filesystem=0, compile=1, execute=2, lint=3, network=4, process=5|grant permission categories
EN8|GrantState|i8|active=0, expired=1, exhausted=2, revoked=3|grant lifecycle states
EN9|CommandType|i8|kb_assert=0, kb_query=1, kb_retract=2, prolog_query=3, prolog_assert_rule=4, builtin_call=5, grammar_render=6, direct_output=7, op_filesystem=8, op_compile=9, op_execute=10, op_network=11, op_process=12, session_snapshot=13, session_clone=14|LLM→system commands (15 types)
EN10|AuditAction|i8|fact_assert=0, fact_retract=1, fact_query=2, rule_fire=3, rule_assert=4, rule_retract=5, grant_check=6, grant_create=7, grant_revoke=8, session_create=9, session_kill=10, snapshot=11, clone=12, op_execute=13, access_denied=14|security-relevant actions (15 types)
EN11|ErrorCategory|i8|none=0, arithmetic=1, kb=2, prolog=3, grammar=4, session=5, grant=6, runner=7, memory=8, system=9|error classification
EN12|ErrorCode|i32|ok=0, division_by_zero=100, overflow=101, kb_not_found=200, kb_full=201, kb_frozen=202, kb_access_denied=203, slot_out_of_range=204, slot_empty=205, depth_exceeded=300, no_matching_rule=301, unification_failed=302, max_bindings_exceeded=303, invalid_template=400, slot_type_mismatch=401, render_capacity_exceeded=402, session_limit=500, snapshot_failed=501, snapshot_corrupt=502, clone_failed=503, merge_conflict=504, grant_denied=600, grant_expired=601, grant_exhausted=602, grant_revoked=603, grant_admin_required=604, runner_error_threshold=700, runner_connection_lost=701, arena_exhausted=800, arena_not_found=801, init_failed=900, corrupt_state=901, seed_load_failed=902|32 error codes
EN13|RecoveryAction|i32|none=0, compact=1, log_and_continue=2, simplify_query=3, retry_snapshot=4, log_and_deny=5, reconnect_with_backoff=6, recycle_runner=7, kill_oldest_clone=8, restore_from_snapshot=9|error recovery dispatch
EN14|SlotType|i8|vdr_value=0, text=1, integer=2, enum_val=3, kb_ref=4, grammar=5|grammar slot discriminator
EN15|WorkOp|i32|idle=0, gemm=1, softmax=2, rmsnorm=3, attention=4, dot_product=5|work queue operation types
EN16|SamplingMode|i32|greedy=0, top_k=1, top_p=2, temperature=3|token sampling strategies
EN17|ArenaId|i32|global=0, core_0=1 through core_15=16|arena identifiers (17 values)
EN18|BuiltinCategory|i32|text_ops=0, collections=1, sets=2, mappings=3, closed_arithmetic=4, comparison=5, rounding=6, integer_bit_ops=7, linear_algebra=8, statistics=9, active_arithmetic=10, structure_ops=11, number_theory=12, polynomial=13, finite_field=14, discrete_calculus=15, op_filesystem=16, op_compile=17, op_execute=18, op_lint=19, op_network=20, op_process=21, scoring=22|23 builtin categories (0-15 pure, 16-21 grant-gated, 22 scoring)
EN19|DiffRegion|i32|kb=0, fact=1, rule=2, term=3, text=4, grammar=5, live_state=6, grant=7, ephemeral_kb=8, ephemeral_fact=9|snapshot diff regions
EN20|MergePolicy|i32|ours=0, theirs=1, fail_on_conflict=2|clone merge strategies
EN21|FsmType|i8|moore=0, mealy=1, dfa=2, statechart=3|FSM classification
EN22|ResolutionType|i8|none=0, relation_index=1, transitive_closure=2, inverse_lookup=3, symmetric_swap=4, prolog_rule=5, fact_read=6|L3 pre-resolution method
EN23|RelationType|i32|enables=1000..input_to, instance_of=2000..constructed_from, knowledge_base=3000..anti_pattern_of, agent_of=4000..time_of, if_then=5000..less_than, governs=6000..distributes_as, manages=7000..inspects, domain_0=1000000..domain_2, unknown=-1|~120 relation types across 8 semantic groups + domain slots

# relation_type_groups(id|group|start_value|end_approx|count|description)
RG1|structural|1000|—|~80|general enabling, preventing, causal, compositional, spatial, temporal, domain-specific
RG2|identity_binding|2000|—|~12|instance_of, has_type, named, aliases, references, assigns, binds_to, returns, accepts, emits, complement_of, constructed_from
RG3|knowledge_structure|3000|—|~15|knowledge_base, domain, scoped_to, context_of, defined_in, documented_by, example_of, derived_from, composed_of, decomposes_to, transforms_to, measured_by, studies, distinguishes, anti_pattern_of
RG4|agency_action|4000|—|10|agent_of, object_of, instrument_of, location_of, destination_of, source_of, purpose_of, result_of, manner_of, time_of
RG5|condition_logic|5000|—|10|if_then, unless, while_true, for_each, exists, not_exists, and_also, or_else, greater_than, less_than
RG6|grammar_language|6000|—|10|governs, applies_to, violates, agrees_with, selects, modifies, heads, complements_grammar, subcategorizes, distributes_as
RG7|toolchain_ops|7000|—|5|manages, isolates, orchestrates, generates, inspects
RG8|domain_registerable|1000000|—|3+|domain_0, domain_1, domain_2 (extensible)

# relation_type_properties(id|name|inverse|symmetric|transitive|notes)
RP1|enables|depends_on|no|yes|—
RP2|requires|enables|no|yes|—
RP3|prevents|prevents|yes|no|—
RP4|implements|unknown|no|no|—
RP5|extends|generalizes|no|yes|—
RP6|overrides|unknown|no|no|—
RP7|validates|verified_by|no|no|—
RP8|verified_by|validates|no|no|—
RP9|contradicts|contradicts|yes|no|—
RP10|causes|result_of|no|no|—
RP11|determined_by|unknown|no|no|—
RP12|depends_on|enables|no|yes|—
RP13|equivalent_to|equivalent_to|yes|no|—
RP14|approximates|approximates|yes|no|—
RP15|specializes|generalizes|no|yes|—
RP16|generalizes|specializes|no|yes|—
RP17|part_of|contains|no|yes|—
RP18|contains|part_of|no|yes|—
RP19|follows|precedes|no|yes|—
RP20|precedes|follows|no|yes|—
RP21|borders|borders|yes|no|—
RP22|aliases|aliases|yes|no|—
RP23|complement_of|complement_of|yes|no|—
RP24|agrees_with|agrees_with|yes|no|—
RP25|and_also|and_also|yes|no|—
RP26|or_else|or_else|yes|no|—
RP27|complements|complements|yes|no|—
RP28|parallel_to|parallel_to|yes|no|—
RP29|opposes|opposes|yes|no|typically mutual
RP30|connects_to|connects_to|yes|no|—
RP31|alternative_to|alternative_to|yes|no|—
RP32|contrasts|contrasts|yes|no|—
RP33|scoped_to|—|no|yes|transitive
RP34|flows_to|—|no|yes|transitive
RP35|derived_from|—|no|yes|transitive
RP36|transforms_to|—|no|yes|transitive
RP37|composed_of|—|no|yes|transitive
RP38|protects↔threatens|mutual inverse|no|no|—
RP39|instance_of↔has_type|mutual inverse|no|no|—
RP40|destination_of↔source_of|mutual inverse|no|no|—
RP41|greater_than↔less_than|mutual inverse|no|no|—
RP42|foundation_for↔constructed_from|mutual inverse|no|no|—
RP43|composed_of↔decomposes_to|mutual inverse|no|no|—
RP44|causes↔result_of|mutual inverse|no|no|—
RP45|evolves_to|derived_from|no|no|—
RP46|controls|determined_by|no|no|—
RP47|generates|derived_from|no|no|—
RP48|unifies|part_of|no|no|weak inverse

# structs(id|name|size_bytes|alignment|fields_ref|methods_ref|notes)
S1|VdrId|8|8|SF1|SM1|sign-bit partitioned i64, NONE/ROOT/EPHEMERAL_ROOT constants
S2|Q16|8|4|SF2|SM2|exact rational, D=65536 implicit, three-field comparison
S3|Q32|16|8|SF3|SM3|escalated precision, D=2^32
S4|Q335|240|8|SF4|SM4|physics/transcendentals, D=2^335, 4 remainder slots
S5|Fact|48|8|SF5|SM5|atomic knowledge unit, tag-dispatched value
S6|Provenance|36|8|SF6|SM6|source tracking on every Fact, capability_level for access control
S7|GemmCache|~32|8|SF7|SM7|per-KB packed v fields for GEMM hot path
S8|WeightMatrix|~32|8|SF8|SM8|SoA layout: v(i32) + r0(i16) + r1(i16), column-major
S9|WeightVector|~24|8|SF9|SM9|1D version of WeightMatrix
S10|KbWeightRefs|~48|8|SF10|—|per-KB matrix/vector ref tables + optional GEMM cache
S11|KB|256|8|SF11|SM11|4 cache lines, tree node, all stores + relations + FSM + behavior set
S12|Term|24|4|SF12|SM12|Prolog term, tag-dispatched via TermType
S13|Rule|48|8|SF13|SM13|Prolog rule with fire/success/failure statistics
S14|Binding|8|4|SF14|—|variable→term binding
S15|UnificationResult|8|4|SF15|SM15|unified:bool + bindings offset/count
S16|PrologAction|~64|8|SF16|—|assert/retract action from rule firing
S17|GrammarSlot|~24|8|SF17|—|named typed slot in grammar template
S18|Grammar|~32|8|SF18|SM18|template + slots + validation state
S19|GrammarFill|~20|4|SF19|—|fill data for one grammar slot
S20|GrammarKBMapping|~16|8|SF20|—|slot→KB fact binding
S21|Session|~200 (pad 256)|8|SF21|SM21|isolation boundary, resource limits, counters, clone lineage, surface tracking
S22|Runner|~80|8|SF22|SM22|autonomous agent with interval, error tracking, recycle logic
S23|Grant|~80|8|SF23|SM23|authorization token with uses/expiry/revocation
S24|Command|~24|4|SF24|SM24|parsed LLM command, 15 types, optional grant
S25|CommandResult|~32|8|SF25|—|status + output location + optional text
S26|AuditEntry|~44|8|SF26|SM26|timestamped security action record
S27|Status|~12|4|SF27|SM27|category + code + detail, isOk/isErr
S28|LevelStats|~96|8|SF28|SM28|L1/L2/L3 counts, tokens, relation stats, pre-resolution tracking
S29|Arena|~24|8|SF29|SM29|bump pointer allocator, alloc/allocTyped/allocSlice/reset
S30|WorkItem|~64|4|SF30|—|SIMD work queue entry with pre-resolution/classification offsets
S31|ModelConfig|~288|4|SF31|SM31|layer/head/vocab/MLP dims + checkpoint path
S32|SamplingConfig|~16|4|SF32|—|mode + temperature + top_k + top_p
S33|KvCacheConfig|~16|4|SF33|SM33|seq_len × layers × heads × d_head, totalBytes()
S34|SessionConfig|~48|8|SF34|—|session creation parameters
S35|CloneConfig|8|4|SF35|—|fresh_live + inherit_rules
S36|KBCreateConfig|~48|8|SF36|—|name/path/parent/max_facts/rules/visibility
S37|ScopedSearchConfig|~24|8|SF37|—|start KB + tag + depth/result limits
S38|PrologConfig|~16|4|SF38|—|max depth/bindings/results/inheritance_depth
S39|ContextConfig|~24|8|SF39|—|system prompt + scope + token limits
S40|OutputBuffer|~16|8|SF40|SM40|append-only byte buffer with capacity
S41|ScratchpadEntry|~40|8|SF41|—|command index + CommandResult
S42|TypedRelation|48|8|SF42|SM42|first-class typed edge with provenance + strength + scope
S43|DomainRelationDef|32|8|SF43|—|domain-registered relation type properties
S44|RelationIndex|528|4|SF44|SM44|128-slot type counts + from/to indices + rebuild timestamp
S45|CompactionProfile|256|4|SF45|SM45|ingestion provenance, immutable, type usage bitmap
S46|ModelReductionConfig|~64|4|SF46|SM46|base vs reduced architecture + compaction metrics
S47|SnapshotHeader|~200|8|SF47|—|region sizes, entity counts, session metadata, checksum
S48|DiffEntry|~24|4|SF48|—|region + offset + size + hashes
S49|DiffResult|~16|4|SF49|—|entries + count + identical flag
S50|CowPageTable|~40|8|SF50|SM50|dirty bit tracking for clone sessions
S51|PathEntry|~16|4|SF51|—|path_hash → VdrId, occupied flag
S52|AuditFilter|~48|8|SF52|SM52|optional fields for audit log query
S53|GrantResult|~16|8|SF53|SM53|granted + grant_id + remaining_uses
S54|MergeConflict|~16|8|SF54|—|kb_id + slot_id + timestamps
S55|MergeResult|~24|8|SF55|—|status + merged/conflict counts + conflicts slice
S56|SearchResult|~24|8|SF56|—|facts + kb_ids + slot_ids + count
S57|QueryResult|~32|8|SF57|—|bindings + counts + depth + status + resolution_priority
S58|FireResult|~16|8|SF58|—|firing rule IDs + count + status
S59|SessionHandle|~12|8|SF59|—|id + index
S60|SnapshotHandle|~12|8|SF60|—|id + index
S61|RunnerHandle|~12|8|SF61|—|id + index
S62|QueryClassification|~56|4|SF62|SM62|pre-LLM pattern detection result — relation/transitive/fact/aggregation patterns
S63|RelationPattern|~24|8|SF63|—|detected relation type + from/to + confidence + keyword location
S64|RuleCandidate|~32|8|SF64|—|matched rule offset/KB + success rate + fire count + relevance
S65|AtomRelTypeCacheEntry|8|4|SF65|—|atom_id → RelationType single mapping
S66|AtomRelTypeCache|~520|4|SF66|SM66|fixed-size [64] cache with lookup/insert/reset
S67|KbSummary|~24|8|SF67|—|KB content summary for availability surface
S68|RelationSurfaceEntry|~16|4|SF68|—|per-RelationType slot availability summary
S69|RuleSurfaceEntry|~28|4|SF69|—|per-functor/arity rule availability summary
S70|FunctorIndexEntry|~16|4|SF70|—|functor_id + arity + first_rule_index + rule_count
S71|FunctorIndex|~280|4|SF71|SM71|hash buckets + entries/chains offsets + lookup()
S72|L3PreResolution|~24|4|SF72|SM72|pre-resolution result for prompt_current
S73|PrologEngine|~64|8|SF73|—|per-session engine with store/scratch/session/cache/stats refs
S74|SearchFrame|~24|8|SF74|—|explicit stack frame for depth-first Prolog search
S75|MatchResult|~24|8|SF75|—|matched rule + next index + new bindings
S76|KbStore|~320|8|SF76|SM76|runtime KB manager — path index, loaded LUT, atom table, text store, manifest
S77|Fsm|~64|8|SF77|SM77|per-KB state machine — type, states, transitions KB, outputs KB, statechart nesting
S78|PollerConfig|~24|8|SF78|—|session + interval + error limit + KB
S79|ProcessorConfig|~540|8|SF79|—|session + source URL + recycle/error/backoff limits
S80|InternalConfig|~24|8|SF80|—|session + interval + compute KB
S81|BatchConfig|~24|8|SF81|—|session + task queue KB/slot + max concurrent
S82|IoSe|~96|4|SF82|SM82|builtin IOSE declaration — inputs/output/side-effects/grants
S83|SystemConfig|~512|8|SF83|—|top-level: cores, model, arenas, limits, HTTP, ingestion, seed, sampling, prolog, context
S84|IngestionConfig|~280|4|SF84|—|target path + source type + generation flags + limits
S85|SystemStatus|~320|8|SF85|—|runtime status: counts, arena usage, initialization flag
S86|SeedConfig|~16|8|SF86|—|snapshot path + create fresh flag
S87|BuiltinArgs|~40|8|SF87|—|input/output KB+slot + extra params + array length
S88|BuiltinResult|~20|8|SF88|SM88|status + output KB/slot/count

# struct_fields(id|struct_ref|field|type|default|notes)
# — VdrId
SF1|S1|v|i64|0|sign bit partitions global/ephemeral
# — Q16
SF2|S2|v|i32|0|numerator (value / D)
SF2|S2|r0|i16|0|remainder level 0
SF2|S2|r1|i16|0|remainder level 1
# — Q32
SF3|S3|v|i64|0|—
SF3|S3|r0|i32|0|—
SF3|S3|r1|i32|0|—
# — Q335
SF4|S4|v|[6]i64|all 0|—
SF4|S4|r0|[6]i64|all 0|—
SF4|S4|r1|[6]i64|all 0|—
SF4|S4|r2|[6]i64|all 0|—
SF4|S4|r3|[6]i64|all 0|—
# — Fact
SF5|S5|tag|FactTag|.empty|determines value interpretation
SF5|S5|value|Q16|zero|for matrix/vector: v=index into KB refs, r0=0, r1=0
SF5|S5|provenance|Provenance|default|every fact carries provenance
# — Provenance
SF6|S6|source_type|i32|unknown (10)|indexes confidence_table
SF6|S6|source_kb_id|VdrId|NONE|origin KB
SF6|S6|source_slot_id|i32|-1|origin slot
SF6|S6|confidence|Q16|zero|from confidence_table or derived
SF6|S6|timestamp|i32|0|creation time
SF6|S6|derivation_rule_id|i32|-1|rule that produced this fact
SF6|S6|capability_level|i32|0|per-weight access control
# — GemmCache
SF7|S7|v_packed|[]i32|empty|contiguous v fields, SIMD-ready
SF7|S7|fact_count|i32|0|entries in cache
SF7|S7|kb_id|VdrId|NONE|source KB
SF7|S7|kb_last_modified|i32|0|timestamp at rebuild
SF7|S7|generation|i32|0|increments on rebuild
# — WeightMatrix
SF8|S8|v|[]i32|empty|GEMM-ready, cache-line aligned, column-major
SF8|S8|r0|[]i16|empty|remainder level 0
SF8|S8|r1|[]i16|empty|remainder level 1
SF8|S8|rows|i32|0|—
SF8|S8|cols|i32|0|—
# — KB (key fields only — full struct has ~60 fields)
SF11|S11|id|VdrId|NONE|—
SF11|S11|parent_id|VdrId|-1|root KB has parent -1
SF11|S11|facts_offset/count/capacity|i32|0|fact store region
SF11|S11|rules_offset/count/capacity|i32|0|rule store region
SF11|S11|relations_offset/count/capacity|i32|-1/0/0|typed relation store
SF11|S11|relation_index_offset|i32|-1|RelationIndex location
SF11|S11|domain_rel_defs_offset/count|i32|-1/0|domain relation definitions
SF11|S11|compaction_profile_offset|i32|-1|ingestion provenance
SF11|S11|weight_refs_offset|i32|-1|KbWeightRefs location
SF11|S11|functor_index_offset|i32|-1|lazy-built rule head lookup
SF11|S11|fsm_offset|i32|-1|per-KB FSM if present
SF11|S11|behavior_set_offset|i32|-1|per-KB behavior set if present
SF11|S11|training_lock|bool|false|prevents concurrent training
SF11|S11|training_arena|?*Arena|null|only nullable pointer in system
SF11|S11|frozen|i8|0|immutable when nonzero
SF11|S11|visibility|i8|1|0=public, 1=internal
SF11|S11|new_facts_since_training_offset/count|i32|-1/0|facts added after last training
# — Term
SF12|S12|type|TermType|.atom|discriminator
SF12|S12|primary_id|i32|0|atom/variable/integer ID or functor ID
SF12|S12|secondary_offset|i32|0|args offset (compound), head (list), text offset
SF12|S12|secondary_aux|i32|0|args count (compound), tail (list), text length
SF12|S12|vdr_value|Q16|zero|Q16 value for vdr type
# — Rule
SF13|S13|id|VdrId|NONE|—
SF13|S13|head|i32|0|term offset for rule head
SF13|S13|body_offset/count|i32/i16|0/0|body goals
SF13|S13|action_offset/count|i32/i16|0/0|post-fire actions
SF13|S13|fire_count|i32|0|total firings
SF13|S13|last_fired|i32|0|timestamp
SF13|S13|success_count/failure_count|i32|0/0|outcome tracking
SF13|S13|created_at|i32|0|—
SF13|S13|creator_session_id|VdrId|NONE|—
# — Session (key fields)
SF21|S21|id|VdrId|NONE|—
SF21|S21|ephemeral_next_id|i64|-2|decrements for each new session ID
SF21|S21|core_id/arena_id|i32|0/0|binding
SF21|S21|max_kb_count/ephemeral_kbs/facts_per_kb|i32|100/1000/10000|resource limits
SF21|S21|current_turn|i32|0|—
SF21|S21|atom_rel_cache_offset|i32|-1|per-session cache
SF21|S21|surface_dirty|bool|true|availability surface needs rebuild
# — TypedRelation
SF42|S42|rel_type|RelationType|.unknown|—
SF42|S42|from_id|VdrId|NONE|source entity
SF42|S42|to_id|VdrId|NONE|target entity
SF42|S42|provenance|Provenance|default|—
SF42|S42|strength|Q16|zero|zero=binary, nonzero=weighted
SF42|S42|scope_kb_id|VdrId|NONE|scoping KB
# — RelationIndex
SF44|S44|by_type_counts|[128]i32|all 0|count per RelationType slot
SF44|S44|by_from_offset/count|i32|-1/0|sorted from-index
SF44|S44|by_to_offset/count|i32|-1/0|sorted to-index
SF44|S44|total_relations|i32|0|—
SF44|S44|last_rebuilt|i32|0|—
# — Fsm
SF77|S77|id|VdrId|NONE|—
SF77|S77|fsm_type|FsmType|.moore|—
SF77|S77|current_state/previous_state/initial_state|i32|0/0/0|atom IDs
SF77|S77|states_offset/count|i32/i16|-1/0|valid state atoms
SF77|S77|transitions_kb_id|VdrId|NONE|child KB with evolves_to/2 rules
SF77|S77|outputs_kb_id|VdrId|NONE|child KB with state→behavior_set facts
SF77|S77|parent_fsm_id|VdrId|NONE|statechart parent
SF77|S77|children_offset/count|i32/i16|-1/0|statechart concurrent regions
SF77|S77|last_transition_time|i32|0|—
SF77|S77|transition_count|i32|0|—
SF77|S77|is_terminal|bool|false|—
# — QueryClassification
SF62|S62|has_relation|bool|false|—
SF62|S62|rel_type|RelationType|.unknown|detected relation
SF62|S62|from_hint/to_hint|VdrId|NONE/NONE|source/target entity hints
SF62|S62|has_transitive|bool|false|—
SF62|S62|transitive_type|RelationType|.unknown|—
SF62|S62|transitive_root|VdrId|NONE|—
SF62|S62|has_fact|bool|false|—
SF62|S62|fact_path_hash|u32|0|—
SF62|S62|fact_slot_hint|i32|-1|—
SF62|S62|has_aggregation|bool|false|—
SF62|S62|agg_type|i32|0|0=count, 1=sum, 2=list
SF62|S62|agg_target|i32|0|—
SF62|S62|confidence|Q16|zero|overall classification confidence
SF62|S62|match_count|i32|0|0=no structural match
# — KbStore
SF76|S76|global_arena|*Arena|undefined|—
SF76|S76|path_index_offset/capacity|i32|-1/0|path hash LUT
SF76|S76|loaded_lut_offset/capacity/count|i32|-1/0/0|VdrId→*KB LUT
SF76|S76|manifest_offset/count|i32|-1/0|persisted KB index
SF76|S76|next_global_id|i64|17|after 16 seed KBs
SF76|S76|atom_table_offset/count/capacity|i32|-1/0/0|string→atom_id
SF76|S76|text_store_offset/cursor/capacity|i32|-1/0/0|shared text data

# methods(id|struct_ref|name|signature|description)
# — VdrId
SM1|S1|isGlobal|() bool|v >= 0
SM1|S1|isEphemeral|() bool|v < 0
SM1|S1|isNone|() bool|v == 0
SM1|S1|eql|(a, b) bool|a.v == b.v
# — Q16
SM2|S2|zero|() Q16|all fields 0
SM2|S2|one|() Q16|v=D16, r0=0, r1=0
SM2|S2|fromParts|(v, r0, r1) Q16|direct construction — always 3 args (IN15)
SM2|S2|add|(a, b) Q16|r1 sums first → carries r0 → carries v
SM2|S2|sub|(a, b) Q16|r1 diff with borrow → r0 borrow → v
SM2|S2|mul|(a, b) Q16|product in i64, divTrunc/mod by D, cross-terms in r1
SM2|S2|div|(a, b) Q16|widened by D, divTrunc/mod by b.v, r1 from r0×D/b.v
SM2|S2|compare|(a, b) i32|lexicographic v→r0→r1, no epsilon
SM2|S2|eql|(a, b) bool|all three fields match
# — Q32
SM3|S3|fromQ16|(q) Q32|scaled v, preserved r0
SM3|S3|toQ16|(self) Q16|scaled back with mod capture
# — Fact
SM5|S5|isEmpty|() bool|tag == .empty
SM5|S5|isMatrix/isVector|() bool|tag checks
SM5|S5|matrixRefIndex|() i32|value.v as index
# — Provenance
SM6|S6|direct|(source, kb, slot, time) Provenance|lookup confidence from table
SM6|S6|derived|(rule_id, kb, slot, conf, time) Provenance|prolog_derivation source
# — GemmCache
SM7|S7|isDirty|(kb_modified) bool|kb_modified > self.kb_last_modified
# — WeightMatrix
SM8|S8|elementCount|() i64|rows × cols
SM8|S8|bytesV/bytesTotal|() i64|elements × 4 / elements × 8
# — KB
SM11|S11|isPublic/Internal/Frozen/Root/Ephemeral/Training|() bool|visibility/frozen/parent/id/lock checks
SM11|S11|hasRelations/RelationIndex/DomainRelDefs|() bool|offset != -1 checks
SM11|S11|isFromCompaction/isBehaviorSet/hasFsm|() bool|profile/behavior/fsm offset checks
SM11|S11|hasFunctorIndex/needsFunctorIndex|() bool|functor index presence/threshold check
# — Term
SM12|S12|atom/variable/integer/vdr/compound/list/textRef|constructors|static factory methods
SM12|S12|isAtom/isVariable/isCompound|() bool|type checks
# — Rule
SM13|S13|successRate|() Q16|success/(success+failure) in Q16
# — Session
SM21|S21|isActive/isClone/hasSnapshot|() bool|state/parent/snapshot checks
SM21|S21|nextEphemeralId|(*self) VdrId|decrements ephemeral_next_id
SM21|S21|turnsRemaining|() i32|-1 if unlimited
SM21|S21|invalidateSurface|(*self) void|sets surface_dirty = true
# — Runner
SM22|S22|shouldRecycle/shouldStop|() bool|iteration/error threshold checks
# — Grant
SM23|S23|isActive/isUnlimited/isExpired/isExhausted|() bool|state/uses/time checks
SM23|S23|consumeUse|(*self) bool|decrements remaining, transitions to exhausted
# — Command
SM24|S24|requiresGrant|() bool|grant_required >= 0
SM24|S24|grantClass|() ?GrantClass|enum cast or null
SM24|S24|isOperational|() bool|op_filesystem..op_process
# — AuditEntry
SM26|S26|allowed/denied|constructors|factory methods with result=1/0
# — Status
SM27|S27|ok/err|constructors|—
SM27|S27|isOk/isErr|() bool|category check
# — LevelStats
SM28|S28|totalCount|() i64|l1+l2+l3
SM28|S28|autoTriageNum/Den|() i64|l3_count / totalCount
SM28|S28|avgTokensPerInteraction|() Q16|total_tokens × D / total_ops
SM28|S28|l3RelationRatio|() Q16|(relation+transitive+inverse) × D / l3_count
SM28|S28|preResolutionHitRate|() Q16|(l3_pre + l2_assisted) × D / total_attempts
# — Arena
SM29|S29|alloc|(bytes, alignment) ?[*]u8|bump pointer with alignment, null on exhaustion
SM29|S29|allocTyped|(T) ?*T|typed single allocation
SM29|S29|allocSlice|(T, count) ?[]T|typed array allocation
SM29|S29|reset|() void|cursor = 0
SM29|S29|usedBytes/freeBytes|() usize|cursor / size-cursor
# — OutputBuffer
SM40|S40|append|(bytes) void|copies up to capacity
SM40|S40|reset|() void|length = 0
SM40|S40|contents|() []const u8|data[0..length]
# — TypedRelation
SM42|S42|isBinary/isWeighted|() bool|strength zero check
SM42|S42|matchesFrom/matchesTo|(id) bool|from_id/to_id equality
# — RelationIndex
SM44|S44|countForType|(rel_type) i32|slot lookup in by_type_counts
SM44|S44|hasType|(rel_type) bool|count > 0
SM44|S44|isDirty|(kb_count) bool|total != kb count
# — CompactionProfile
SM45|S45|totalEntities|() i32|facts + relations + rules
SM45|S45|relationTypeCount|() i32|count of true in relation_types_used
# — ModelReductionConfig
SM46|S46|estimatedWeightBytes|() i64|computes from reduced dims + bytes_per_param
# — ModelConfig
SM31|S31|totalParams|() i64|emb + per_layer×n_layers + head
SM31|S31|weightBytes|() i64|totalParams × 2 (i16)
# — CowPageTable
SM50|S50|isDirty/markDirty|(page) bool/void|bit manipulation in dirty_bits
# — AuditFilter
SM52|S52|matchesEntry|(entry) bool|optional field filtering
# — QueryClassification
SM62|S62|shouldAttemptL3|() bool|match_count > 0 and confidence >= 32768 (50%)
SM62|S62|isUnambiguous|() bool|match_count == 1 and confidence >= 52428 (80%)
# — AtomRelTypeCache
SM66|S66|lookup|(atom_id) ?RelationType|linear scan of entries
SM66|S66|insert|(atom_id, rel_type) void|append, drop if full
SM66|S66|reset|() void|count = 0
# — FunctorIndex
SM71|S71|lookup|(functor_id, arity, arena) ?*FunctorIndexEntry|hash → chain walk
SM71|S71|isBuilt|() bool|entries_offset != -1
# — L3PreResolution
SM72|S72|shouldFrame|() bool|resolved and result_count > 0
# — Fsm
SM77|S77|isInitial|() bool|current == initial and transition_count == 0
SM77|S77|isNested|() bool|parent_fsm_id != NONE
SM77|S77|hasConcurrentRegions|() bool|children_count > 0
# — KbStore
SM76|S76|nextGlobalId|(*self) VdrId|increments next_global_id
# — IoSe
SM82|S82|requiresGrant|() bool|grant_class >= 0
SM82|S82|isPure|() bool|no side_effects and deterministic

# confidence_table(id|index|source_type|q16_v|fraction)
CT1|0|vdr_computation|65536|1/1
CT2|1|prolog_derivation|65536|1/1
CT3|2|database|64225|98/100
CT4|3|prometheus|62259|95/100
CT5|4|script|62259|95/100
CT6|5|rest_api|55705|85/100
CT7|6|published|52428|80/100
CT8|7|user_stated|45875|70/100
CT9|8|web_search|32768|50/100
CT10|9|llm_generated|19660|30/100
CT11|10|unknown|0|0/1

# recovery_dispatch(id|error_code|recovery_action)
RD1|kb_full|compact
RD2|kb_access_denied|log_and_continue
RD3|depth_exceeded|simplify_query
RD4|snapshot_failed|retry_snapshot
RD5|grant_denied/expired/exhausted/revoked|log_and_deny
RD6|runner_connection_lost|reconnect_with_backoff
RD7|runner_error_threshold|recycle_runner
RD8|arena_exhausted|kill_oldest_clone
RD9|corrupt_state|restore_from_snapshot

# seed_ids(id|name|value|path)
SD1|ROOT|1|root
SD2|SYSTEM|2|root.system
SD3|OSO|3|root.system.oso
SD4|CONFIDENCE|4|root.system.confidence
SD5|BUILTINS|5|root.system.builtins
SD6|COMMAND_VOCAB|6|root.system.command_vocab
SD7|HYGIENE|7|root.system.hygiene
SD8|EMBEDDING|8|root.system.embedding
SD9|OUTPUT|9|root.system.output
SD10|TEMPLATES|10|root.templates
SD11|SENTENCES|11|root.templates.sentences
SD12|FORMATS|12|root.templates.formats
SD13|RELATION_TYPES|13|root.system.relation_types
SD14|INGESTION|14|root.system.ingestion
SD15|SCORING|15|root.system.scoring
SD16|FSM|16|root.system.fsm
SD17|SEED_KB_COUNT|16|total seed KBs

# relationships(from|rel|to)
# struct containment
S5|contains|EN1,S2,S6
S6|contains|EN2,S1,S2
S11|contains|S1,S5,S13,S12,S42,S44,S43,S45,S10,S77,EN1
S12|contains|EN3,S2
S13|contains|S1,S2
S42|contains|EN23,S1,S6,S2
S44|contains|EN23
S77|contains|S1,EN21
S21|contains|S1,EN4,S66
S22|contains|S1,EN5,EN6
S23|contains|S1,EN7,EN8
S24|contains|S1,EN9
S26|contains|S1,EN10
S27|contains|EN11,EN12
S28|contains|S2
S29|contains|EN17
S30|contains|EN15
S7|contains|S1
S8|contains|S2
S10|contains|S8,S9,S7
S62|contains|EN23,S1,S2
S71|contains|S70
S73|contains|S76,S29,S21,S66,S28,S38
S76|contains|S29
S83|contains|S31,S46,S84,S86,S32,S38,S39
# enum → struct usage
EN1|used_by|S5
EN2|used_by|S6
EN3|used_by|S12
EN4|used_by|S21
EN5|used_by|S22
EN6|used_by|S22
EN7|used_by|S23
EN8|used_by|S23
EN9|used_by|S24
EN10|used_by|S26
EN11|used_by|S27
EN12|used_by|S27
EN13|used_by|S27
EN14|used_by|S17,S19
EN15|used_by|S30
EN16|used_by|S32
EN17|used_by|S29
EN18|used_by|S82
EN19|used_by|S48
EN20|used_by|S55
EN21|used_by|S77
EN22|used_by|S72
EN23|used_by|S42,S43,S44,S62,S63,S66
# struct → struct dependencies
S5|requires|S2,S6
S6|requires|S1,S2
S7|requires|S1
S8|requires|S2
S10|requires|S8,S9,S7
S11|requires|S1,S5,S13,S42,S44,S77,S29
S13|requires|S1,S2
S21|requires|S1
S22|requires|S1
S23|requires|S1
S24|requires|S1
S26|requires|S1
S42|requires|S1,S6,S2
S44|requires|EN23
S45|requires|S1,S2
S47|requires|S1,S21
S50|requires|S1
S52|requires|S1
S53|requires|S1
S57|requires|S14,S27
S62|requires|S1,S2,EN23
S64|requires|S1,S2
S66|requires|EN23
S71|requires|S70,S29
S72|requires|S2,EN22
S73|requires|S76,S29,S21,S66,S28,S38
S76|requires|S29
S77|requires|S1,EN21
S82|requires|EN18,EN3
# seed IDs → KB structure
SD1|enables|SD2,SD10
SD2|enables|SD3,SD4,SD5,SD6,SD7,SD8,SD9,SD13,SD14,SD15,SD16
SD10|enables|SD11,SD12
# constants → structs
K1|used_by|S2,SM2
K2|used_by|S3
K3|used_by|S8
K4|used_by|S47
K5|used_by|S47
K6|used_by|S50
K7|used_by|S85
K8|used_by|S44,S45
K9|used_by|S66
K10|used_by|S11,S71
K11|used_by|S71
K12|used_by|S2
# relation type properties → engine behavior
RP1-RP5|enables|PL3
RP12|enables|PL3
RP15-RP20|enables|PL3
RP33-RP37|enables|PL3
RP3|enables|PL5
RP9|enables|PL5
RP13-RP14|enables|PL5
RP21-RP32|enables|PL5
# confidence table → provenance
CT1-CT11|implements|S6

# section_index(section|title|ids)
1|Constants|K1-K12
2|Enums|EN1-EN23
3|Relation Type Groups|RG1-RG8
4|Relation Type Properties|RP1-RP48
5|Structs|S1-S88
6|Struct Fields|SF1-SF77
7|Methods|SM1-SM82
8|Confidence Table|CT1-CT11
9|Recovery Dispatch|RD1-RD9
10|Seed IDs|SD1-SD17

# decode_legend
id_prefixes: K=constant, EN=enum, RG=relation_type_group, RP=relation_type_property, S=struct, SF=struct_fields, SM=struct_methods, CT=confidence_table, RD=recovery_dispatch, SD=seed_id
rel_types: contains|used_by|requires|enables|implements
cross_ref_prefixes: PL=prolog (from VDR-PROLOG SPEC compaction), IN=invariant (from VDR-PROLOG SPEC compaction)
struct_field_notation: SF entries share id with parent struct — multiple rows per struct, disambiguated by field name
method_notation: SM entries share id with parent struct — multiple rows per struct, disambiguated by method name
enum_values: comma-separated name=value pairs; continuous ranges abbreviated with ..
size_notation: ~ prefix means approximate (depends on padding); exact where known
type_notation: []T = slice, [N]T = fixed array, ?T = optional, *T = pointer
zig_version: 0.15.1, x86_64 only
confidence: compacted from source vdr_types.zig — all enum values, struct fields, method signatures, and constants preserved exactly

# relation_mapping(doc_rel|canonical_rel|notes)
contains|contains|exact match
used_by|input_to|enum used by struct = enum is input_to struct's definition
requires|requires|exact match
enables|enables|exact match
implements|implements|exact match
inverse_of|complement_of|relation type is inverse of another; symmetric
composes_with|enables|transitive relation composes with itself = enables chained inference
