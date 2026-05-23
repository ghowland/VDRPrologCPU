# VDR_TYPES.ZIG v2 — COMPLETE TYPE DEFINITIONS — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: constants → structural_id → enums → structs → struct_fields → methods → seed_ids → confidence_table → recovery_dispatch → relationships → section_index
# Changes from v1: VdrStructuralId packed struct added, KBEntryType enum (15 entry types), KbLookup per-type AutoHashMap, per-entry-type LookupId counters on KB, Arena.allocator() vtable, std import

# constants(id|name|value|type|notes)
K1|D16|65536|i32|Q16 denominator, 2^16
K2|D32|4294967296|i64|Q32 denominator, 2^32
K3|CACHE_LINE|64|usize|alignment target
K4|SNAPSHOT_MAGIC|'V','D','R','S'|[4]u8|snapshot file magic
K5|SNAPSHOT_VERSION|4|i32|relation fields in KB
K6|COW_PAGE_SIZE|4096|i32|clone page size
K7|MAX_CORES|16|i32|max supported cores
K8|RELATION_TYPE_SLOTS|128|usize|index slot count
K9|ATOM_REL_CACHE_SIZE|64|usize|per-session cache
K10|FUNCTOR_INDEX_THRESHOLD|64|i32|rule count trigger
K11|FUNCTOR_INDEX_BUCKETS|64|usize|hash buckets
K12|exp_table|[65536,24109,8874,3263,1201,442,162,60,22,8,3]|[11]i32|integer exp lookup
K13|LOOKUP_ID_MAX|std.math.maxInt(u20) = 1048575|u20|max items per entry type per KB

# structural_id(id|field|type|bits|range|notes)
SI1|scope|u1|bit 63|0=global, 1=session|sign-bit partition
SI2|entry_type|u4|bits 62-59|0-15|KBEntryType enum — selects which lookup map and counter
SI3|l1|u7|bits 58-52|0-126 valid, 127=sentinel|root's children (128 max)
SI4|l2|u8|bits 51-44|0-254 valid, 255=sentinel|L1 KB's children (256 max)
SI5|l3|u8|bits 43-36|0-254 valid, 255=sentinel|L2 KB's children
SI6|l4|u8|bits 35-28|0-254 valid, 255=sentinel|L3 KB's children
SI7|l5|u8|bits 27-20|0-254 valid, 255=sentinel|L4 KB's children — 5 depth levels
SI8|item_id|u20|bits 19-0|0-1048575|LookupId — per-entry-type monotonic counter from owning KB

# enums(id|name|backing_type|values|notes)
EN1|FactTag|i32|value=0, text=1, reference=2, timestamp=3, enum_tag=4, boolean=5, vector=6, matrix=7, provenance_tag=8, rule_ref=9, grammar_ref=10, counter=11, relation=12, column_schema=13, empty=255|15 tags
EN2|SourceType|i32|vdr_computation=0 through unknown=10|11 types, indexes confidence_table
EN3|TermType|i8|atom=0 through pair=9|10 types
EN4|SessionState|i8|active=0, snapshotted=1, killed=2, frozen=3|4 states
EN5|RunnerType|i8|poller=0, processor=1, internal=2, batch=3|4 types
EN6|RunnerState|i8|stopped=0, running=1, err=2, recycling=3|4 states
EN7|GrantClass|i8|filesystem=0 through process=5|6 classes
EN8|GrantState|i8|active=0, expired=1, exhausted=2, revoked=3|4 states
EN9|CommandType|i8|kb_assert=0 through session_clone=14|15 types
EN10|AuditAction|i8|fact_assert=0 through access_denied=14|15 actions
EN11|ErrorCategory|i8|none=0 through system=9|10 categories
EN12|ErrorCode|i32|ok=0, division_by_zero=100 through seed_load_failed=902|32 codes
EN13|RecoveryAction|i32|none=0 through restore_from_snapshot=9|10 actions
EN14|SlotType|i8|vdr_value=0 through grammar=5|6 types
EN15|WorkOp|i32|idle=0 through dot_product=5|6 ops
EN16|SamplingMode|i32|greedy=0 through temperature=3|4 modes
EN17|ArenaId|i32|global=0, core_0=1 through core_15=16|17 values
EN18|BuiltinCategory|i32|text_ops=0 through scoring=22|23 categories
EN19|DiffRegion|i32|kb=0 through ephemeral_fact=9|10 regions
EN20|MergePolicy|i32|ours=0, theirs=1, fail_on_conflict=2|3 policies
EN21|FsmType|i8|moore=0, mealy=1, dfa=2, statechart=3|4 types
EN22|ResolutionType|i8|none=0 through fact_read=6|7 types
EN23|KBEntryType|u4|kb=0, fact=1, rule=2, constraint=3, grammar=4, lru=5, counter=6, lock=7, queue=8, stack=9, ring=10, bitset=11, iose=12, relation=13, domain_relation=14|15 types — selects VdrId entry_type bits and per-KB lookup map + counter
EN24|RelationType|i32|structural 1000+ (~80 types), identity 2000+ (~12), knowledge 3000+ (~15), agency 4000+ (10), logic 5000+ (10), grammar 6000+ (10), toolchain 7000+ (5), domain 1000000+, unknown=-1|~120 relation types, inverse/isSymmetric/isTransitive methods

# structs(id|name|key_fields|notes)
S1|VdrStructuralId|packed struct(u64): item_id:u20, l5:u8, l4:u8, l3:u8, l2:u8, l1:u7, entry_type:u4, scope:u1|NEW — @bitCast to/from u64 at zero cost; sentinels: l1=127, l2-l5=255
S2|VdrId|v:i64|structural() returns VdrStructuralId via @bitCast; fromStructural() reverses; depth() counts non-sentinel levels (0-5)
S3|Q16|v:i32, r0:i16, r1:i16|D=65536; add/sub/mul/div/compare/eql; fromParts always 3 args
S4|Q32|v:i64, r0:i32, r1:i32|D=2^32; fromQ16/toQ16 conversion
S5|Q335|v/r0/r1/r2/r3 each [6]i64|D=2^335, 4 remainder slots
S6|Fact|tag:FactTag, value:Q16, provenance:Provenance|48 bytes
S7|Provenance|source_type:i32, source_kb_id:VdrId, source_slot_id:i32, confidence:Q16, timestamp:i32, derivation_rule_id:i32, capability_level:i32|36 bytes; direct() and derived() factory methods
S8|GemmCache|v_packed:[]i32, fact_count, kb_id, kb_last_modified, generation|isDirty() method
S9|WeightMatrix|v:[]i32, r0:[]i16, r1:[]i16, rows, cols|SoA, column-major, 8 bytes/param
S10|WeightVector|v:[]i32, r0:[]i16, r1:[]i16, length|1D SoA
S11|KbWeightRefs|matrix_refs/count/capacity, vector_refs/count/capacity, gemm_cache:?GemmCache|per-KB weight refs
S12|KbLookup|15 optional AutoHashMap(LookupId, i32): facts, rules, constraints, grammars, relations, domain_relations, lru, counters, locks, queues, stacks, rings, bitsets, iose, children|NEW — per-entry-type lookup maps; LookupId=u20 from VdrId item_id bits
S13|KB|~70 fields: id, parent_id, name/path, lookup:KbLookup, stores (facts/rules/constraints/connections/grammars/iose), weight_refs, relations, domain_rel_defs, compaction, live state, new_facts, children, training, metadata, functor_index, fsm, behavior_set, 14× next_{type}_id:LookupId|256 bytes; NEW: lookup field, 14 per-entry-type LookupId counters, mintLookupId() method
S14|Term|type:TermType, primary_id:i32, secondary_offset:i32, secondary_aux:i32, vdr_value:Q16|24 bytes; factory methods: atom/variable/integer/vdr/compound/list/textRef
S15|Rule|id:VdrId, head, body, action, fire/success/failure counts, creator|48 bytes; successRate() method
S16|Binding|var_id:i32, bound_term_offset:i32|8 bytes
S17|UnificationResult|unified:bool, bindings_offset:i32, bindings_count:i16|success/failure factories
S18|PrologAction|is_assert:bool, target_kb_id, target_slot_id, fact|—
S19|GrammarSlot|name_offset/length, type:SlotType, enum_values, kb_id, kb_slot_id|—
S20|Grammar|id, template_offset/length, slots_offset/count, validated, created_at, creator|isValid() method
S21|GrammarFill|slot_index, fill_type, vdr_value, text_offset/length, int_value, enum_index|—
S22|GrammarKBMapping|slot_index, kb_id, slot_id|—
S23|Session|~30 fields: id, user_id, roots, ephemeral_next_id, state, core/arena, limits (5), counters (~10), snapshot/clone, atom_rel_cache, surface tracking|invalidateSurface/isActive/isClone/hasSnapshot/nextEphemeralId/turnsRemaining methods
S24|Runner|id, type, state, session_id, interval, recycle/error limits, counters|shouldRecycle/shouldStop methods
S25|Grant|id, class, state, holder, target_pattern, uses, expires, created/revoked|isActive/isUnlimited/isExpired/isExhausted/consumeUse methods
S26|Command|type, target_kb_id, target_slot_id, builtin_id, args, grant_required|requiresGrant/grantClass/isOperational methods
S27|CommandResult|status, output_kb_id, output_slot_id, output_bytes, output_text:?[]const u8|—
S28|AuditEntry|timestamp, session_id, user_id, action, target_kb_id, target_slot_id, grant_id, result, detail_offset|allowed/denied factory methods
S29|Status|category:ErrorCategory, code:ErrorCode, detail:i32|ok/err/isOk/isErr methods
S30|LevelStats|l1/l2/l3 counts+tokens, relation/transitive/inverse counts, pre_resolution tracking|preResolutionHitRate/totalCount/autoTriageNum+Den/avgTokensPerInteraction/l3RelationRatio methods
S31|Arena|base:[*]u8, size:usize, cursor:usize|alloc/allocTyped/allocSlice/reset/usedBytes/freeBytes + NEW: allocator() returns std.mem.Allocator via vtable
S32|WorkItem|op, a/b/c_ptr, m/n/k, seq_len/n_heads/d_head/scale_v, completion, pre_resolution_offset, classification_offset|—
S33|ModelConfig|n_layers, d_model, n_heads, d_head, vocab_size, mlp_dim, max_seq_len, checkpoint, activation|totalParams/weightBytes methods
S34|SamplingConfig|mode, temperature_v, top_k, top_p_v|—
S35|KvCacheConfig|max_seq_len, n_layers, n_heads, d_head|totalElements/totalBytes methods
S36|BuiltinArgs|input_kb_id, input_slot_ids, output_kb_id, output_slot_id, extra_params, input_array_length|—
S37|BuiltinResult|status, output_kb_id, output_slot_id, output_count|success/fail factories
S38|SearchResult|facts, kb_ids, slot_ids, count|—
S39|QueryResult|bindings, binding_count, result_count, depth_reached, depth_exceeded, status, resolution_priority|—
S40|FireResult|firing_rule_ids, firing_count, status|—
S41|SnapshotHeader|timestamp, session/user ids, region sizes (8), ephemeral sizes, counts (6), session_metadata, checksum, total_size|—
S42|DiffEntry|region, offset, size, a_hash, b_hash|—
S43|DiffResult|entries, count, identical|—
S44|CowPageTable|parent/clone session ids, n_pages, dirty_bits, offsets|isDirty/markDirty methods
S45|PathEntry|path_hash, id, occupied|—
S46|AuditFilter|optional: session_id, user_id, action, target_kb_id, min/max_timestamp, result|matchesEntry method
S47|GrantResult|granted, grant_id, remaining_uses|allowed/deny factories
S48|MergeConflict|kb_id, slot_id, parent/child timestamps|—
S49|MergeResult|status, merged_count, conflict_count, conflicts|—
S50|SessionConfig|user_id, kb_root_id, visibility, limits, auto_snapshot_interval|—
S51|CloneConfig|fresh_live, inherit_rules|—
S52|KBCreateConfig|name, path, parent_id, max_facts, max_rules, visibility, owner_id|—
S53|ScopedSearchConfig|start_kb_id, tag, max_depth, max_results|—
S54|PrologConfig|max_depth, max_bindings, max_results, max_inheritance_depth|—
S55|ContextConfig|system_prompt_kb_id, scope_kb_id, max_scratchpad/context_tokens|—
S56|OutputBuffer|data, length, capacity|append/reset/contents methods
S57|ScratchpadEntry|command_index, result:CommandResult|—
S58|TypedRelation|rel_type, from_id, to_id, provenance, strength:Q16, scope_kb_id|48 bytes; isBinary/isWeighted/matchesFrom/matchesTo methods
S59|DomainRelationDef|slot, name, is_symmetric, is_transitive, inverse_slot, source_document_id, registered_at|32 bytes
S60|RelationIndex|by_type_counts:[128]i32, by_from/to offsets, total_relations, last_rebuilt|~528 bytes; countForType/hasType/isDirty methods
S61|CompactionProfile|source_document_id, counts, relation_types_used:[128]bool, compression_ratio:Q16|256 bytes; totalEntities/relationTypeCount methods
S62|ModelReductionConfig|base vs reduced (layers/mlp/heads/vocab), compaction metrics, use_i16_weights|estimatedWeightBytes method
S63|QueryClassification|has_relation/transitive/fact/aggregation, types, hints, confidence, match_count|shouldAttemptL3/isUnambiguous methods
S64|RelationPattern|rel_type, from/to ids, match_confidence, keyword_offset/length|ephemeral
S65|RuleCandidate|rule_offset, kb_id, head_term_offset, success_rate, fire_count, relevance|ephemeral
S66|AtomRelTypeCacheEntry|atom_id, rel_type|8 bytes
S67|AtomRelTypeCache|entries:[64]AtomRelTypeCacheEntry, count|lookup/insert/reset methods
S68|KbSummary|kb_id, facts/rules/relations counts, has_weights, from_compaction, path_hash|availability surface
S69|RelationSurfaceEntry|rel_type_slot, total_count, kb_count, is_transitive/symmetric, has_inverse|—
S70|RuleSurfaceEntry|functor_id, arity, total_count, avg_success_rate, total_fire_count, functor_name|—
S71|FunctorIndexEntry|functor_id, arity, first_rule_index, rule_count|—
S72|FunctorIndex|buckets:[64]i32, entries/chains offsets, entries_count, last_rebuilt|lookup/isBuilt methods; getEntries/getChains private
S73|L3PreResolution|resolved, resolution_type, result_count, results_offset, confidence, time_us|shouldFrame method
S74|PrologEngine|store, scratch, session, global_arena, atom_rel_cache, level_stats, config|one per session
S75|SearchFrame|goal, kb_id, rule_index, binding_mark|explicit stack
S76|MatchResult|rule, next_rule_index, new_bindings, new_binding_count|ephemeral
S77|KbStore|global_arena, path_index, loaded_lut, manifest, next_global_id(=17), atom_table, text_store, data_dir|nextGlobalId method
S78|Fsm|id, fsm_type, current/previous/initial_state, states, transitions_kb_id, outputs_kb_id, parent, children, transition_count, is_terminal|isInitial/isNested/hasConcurrentRegions methods
S79|PollerConfig|session, interval_ms, max_errors, kb_id|—
S80|ProcessorConfig|session, source_url, recycle/error/backoff limits|—
S81|InternalConfig|session, interval_ms(daily), compute_kb_id|—
S82|BatchConfig|session, task_queue_kb/slot, max_concurrent|—
S83|IoSe|builtin_id, category, name, inputs, output_type, side_effects, grant_class, bounded, deterministic|requiresGrant/isPure methods
S84|SystemConfig|n_cores, model, model_reduction, arenas, limits, http_port(1138), ingestion, configs|top-level
S85|IngestionConfig|target_path, source_type, generation flags, limits|—
S86|SystemStatus|initialized, counts, arena usage|—
S87|SeedConfig|snapshot_path, create_fresh|—
S88|SessionHandle/SnapshotHandle/RunnerHandle|id:VdrId, index:i32|opaque refs

# key_changes_from_v1(id|change|description|impact)
CH1|VdrStructuralId packed struct|NEW packed struct(u64) with scope(u1), entry_type(u4), l1(u7), l2-l5(u8 each), item_id(u20)|replaces opaque i64 interior — 5 depth levels instead of 4; entry_type selects lookup map
CH2|KBEntryType enum|NEW u4 enum with 15 values: kb, fact, rule, constraint, grammar, lru, counter, lock, queue, stack, ring, bitset, iose, relation, domain_relation|encoded in VdrId bits 62-59; only 1 slot remaining (15 of 16 used)
CH3|LookupId type|NEW u20 alias, max 1048575|per-entry-type item counter, stored in VdrId bits 19-0
CH4|KbLookup struct|NEW — 15 optional AutoHashMap(LookupId, i32) fields, one per KBEntryType|replaces single uuid_map from addendum; per-type lookup maps
CH5|KB per-type counters|14 new fields: next_fact_id through next_iose_id, all LookupId=u20|mintLookupId() method returns next ID or null if max exceeded
CH6|KB.mintLookupId|NEW method: selects correct counter by KBEntryType, increments, returns LookupId or null|KB entry types don't mint from parent (kb type returns null)
CH7|VdrId.makeKb/makeItem/makeChildKb|NEW factory methods constructing structural VdrIds from components|makeChildKb returns null if all 5 depth levels exhausted
CH8|VdrId.entryType/lookupId|NEW accessor methods returning KBEntryType and LookupId from structural bits|zero-cost bit extraction
CH9|VdrId.depth|NEW method counting non-sentinel levels (0-5)|5 levels instead of v1's 4
CH10|VdrId.sameSubtreeL1/L2/L3|NEW subtree membership tests comparing structural level fields|direct field comparison, not bitmask
CH11|Arena.allocator|NEW method returning std.mem.Allocator via vtable (arena_vtable)|enables Arena to back std.AutoHashMap and other std containers
CH12|arena vtable functions|NEW: arenaVtableAlloc/Resize/Remap/Free — alloc delegates to Arena.alloc, others no-op/return false/null|required for std.mem.Allocator interface
CH13|l1 field width|u7 (128 max root children) vs v1's u8 (256)|lost 1 bit to entry_type field gaining u4

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

# recovery_dispatch(id|error_code|recovery)
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
SD17|SEED_KB_COUNT|16|total

# relationships(from|rel|to)
# structural ID composition
S1|component_of|S2
SI1-SI8|component_of|S1
EN23|encoded_in|SI2
K13|constrains|SI8
# lookup system
S12|component_of|S13
EN23|indexes|S12
S2|contains|EN23
# KB entry type → lookup
EN23|enables|S12,S13
S13|contains|S12
# struct containment
S6|contains|EN1,S3,S7
S7|contains|EN2,S2,S3
S13|contains|S2,S6,S15,S14,S58,S60,S59,S61,S11,S78,S12
S14|contains|EN3,S3
S15|contains|S2,S3
S58|contains|EN24,S2,S7,S3
S60|contains|EN24
S78|contains|S2,EN21
S23|contains|S2,EN4,S67
S24|contains|S2,EN5,EN6
S25|contains|S2,EN7,EN8
S26|contains|S2,EN9
S28|contains|S2,EN10
S29|contains|EN11,EN12
S30|contains|S3
S31|contains|EN17
S32|contains|EN15
S74|contains|S77,S31,S23,S67,S30,S54
S77|contains|S31
S84|contains|S33,S62,S85,S87,S34,S54,S55
# new dependencies
S31|enables|S12
S2|requires|S1
S12|requires|S31
S13|requires|S12,S2
# seed tree
SD1|contains|SD2,SD10
SD2|contains|SD3-SD9,SD13-SD16
SD10|contains|SD11,SD12

# section_index(section|title|ids)
1|Constants|K1-K13
2|Structural VdrId|S1,SI1-SI8
3|Enums|EN1-EN24
4|Key Changes from v1|CH1-CH13
5|Structs|S1-S88
6|Confidence Table|CT1-CT11
7|Recovery Dispatch|RD1-RD9
8|Seed IDs|SD1-SD17

# decode_legend
id_prefixes: K=constant, SI=structural_id_field, EN=enum, S=struct, CH=change, CT=confidence, RD=recovery, SD=seed_id
rel_types: component_of|contains|encoded_in|indexes|enables|constrains|requires|cross_ref
structural_id_note: VdrStructuralId is packed struct(u64) — @bitCast converts to/from i64 at zero runtime cost; sentinel values (127 for l1, 255 for l2-l5) indicate unused levels; depth() counts non-sentinel levels
entry_type_note: KBEntryType occupies 4 bits (u4) allowing 16 values — 15 currently used, 1 remaining; each type has its own AutoHashMap in KbLookup and its own LookupId counter in KB
lookup_note: KbLookup maps use std.AutoHashMap backed by Arena.allocator() vtable — no heap allocation; each map is optional (null if KB has no entries of that type)
vtable_note: Arena implements std.mem.Allocator interface via arena_vtable — alloc delegates to Arena.alloc, resize/remap return false/null, free is no-op — enables std.AutoHashMap to allocate from arena
changes_from_v1: VdrStructuralId redesigned (5 levels instead of 4, entry_type u4 added, l1 reduced to u7); KBEntryType enum added (15 types); KbLookup struct with 15 per-type maps replaces single uuid_map; KB gains 14 per-type LookupId counters + mintLookupId(); Arena gains allocator() vtable for std container compatibility; VdrId gains factory methods (makeKb, makeItem, makeChildKb) and accessors (entryType, lookupId, depth, sameSubtreeL1/L2/L3)
zig_version: 0.15.1, x86_64 only
confidence: compacted from source vdr_types.zig v2 — all enum values, struct fields, method signatures, constants, and structural ID bit layout preserved exactly

# relation_mapping(doc_rel|canonical_rel|notes)
component_of|part_of|exact semantic match
contains|contains|exact match
encoded_in|scoped_to|entry type encoded in structural ID field = scoped_to that bit range
indexes|enables|enum indexes lookup struct = enables lookup by type
enables|enables|exact match
constrains|constrains|exact match
requires|requires|exact match
cross_ref|references|cross-domain link = references
