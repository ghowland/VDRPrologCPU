# VDR-PROLOG SPECIFICATION ADDENDUM — SESSION ADDITIONS

## 1. Structural UUID

The VdrId bit layout changes from an opaque signed i64 to a self-describing structural address. The 64 bits decompose as follows: bit 63 is the sign bit, partitioning global (0) from session (1) address space, preserving the existing invariant IN8. Bits 62 through 55 (8 bits) encode the first-level index into root's children array, supporting up to 256 root-level KBs. Bits 54 through 45 (10 bits) encode the second-level index, supporting 1024 children per first-level KB. Bits 44 through 35 (10 bits) encode the third level, and bits 34 through 25 (10 bits) encode the fourth level, each supporting 1024 children. Bits 24 through 20 (5 bits) encode a remaining depth indicator, recording how many tree levels exist below the fourth encoded level, with a range of 0 to 31. Bits 19 through 0 (20 bits) hold a collision-resistant random value, tested against existing IDs in the target KB at creation time and regenerated on collision.

The implementation uses a Zig packed struct with fields `sign: u1`, `level_1: u8`, `level_2: u10`, `level_3: u10`, `level_4: u10`, `remaining_depth: u5`, `random: u20`. This struct is exactly 64 bits and converts to and from i64 via `@bitCast` at zero cost. The sentinel value for unused levels is `std.math.maxInt(u10)`, which is 1023. A depth-2 entity sets level_3 and level_4 to 1023, and the tree walk short-circuits on encountering a sentinel, avoiding unnecessary array accesses. The remaining_depth field serves three purposes: it terminates search by indicating when the four encoded levels fully specify the entity (value 0), it informs query planning by estimating traversal cost before execution, and it enables subtree membership testing by prefix comparison.

Subtree membership testing operates by bitwise AND of two VdrIds against a prefix mask covering the shared levels, followed by integer comparison. If the masked bits match, the first entity is within the second entity's subtree. This is a single CPU instruction pair — AND then CMP — replacing a full tree traversal. The prefix mask for L1+L2 scope is `0x7FFC000000000000`, covering sign, level_1, and level_2.

Construction of a structural VdrId follows a fixed procedure: determine the entity's path in the KB tree, encode level_1 through level_4 from the path's indices at each depth, compute remaining_depth as total depth minus 4 (floored at 0), generate a random 20-bit value, check for collision against existing IDs in the target KB, and regenerate on collision. The birthday paradox collision probability for a typical L4 KB population of 1000 entities is approximately 0.05%, making regeneration rare.

A new invariant applies: structural VdrId bits must match the entity's actual position in the KB tree. Reparenting a KB requires recomputation of its VdrId and all descendant VdrIds. This makes reparenting an expensive operation, but reparenting is architecturally rare — KBs are typically frozen after ingestion, and session KBs are ephemeral.

## 2. Lookup System

The lookup system operates in two tiers. Tier 1 is a global hot cache at the KbStore level, implemented as `AutoHashMap(i64, *anyopaque)` with a fixed capacity of approximately 256 entries. The 16 seed KBs are pre-populated at startup. Additional entries are promoted based on access frequency — each KB maintains an access counter, and when the counter crosses a configurable threshold, the KB's VdrId-to-pointer mapping is inserted into the global cache. When the cache reaches capacity, the least recently accessed entry is evicted. The global cache adapts to workload patterns without configuration, learning which KBs are hot and evicting cold ones as the workload shifts.

Tier 2 is per-KB UUID resolution. Every KB carries an `AutoHashMap(i64, u32)` mapping full VdrIds to local fact slot indices within that KB. The map is populated during ingestion or fact assertion, serialized as part of the KB's persistence format (count followed by key-value pairs of i64 and u32), and deserialized on load with pre-allocated capacity via `putAssumeCapacity`. The map lives in the KB's arena allocation, meaning it incurs no heap fragmentation, vanishes on session arena reset, and is captured in session snapshots.

The lookup sequence for any VdrId proceeds as follows. First, check the global hot cache. On hit, return immediately. On miss, decode the structural bits via bitcast to the packed struct. Read the sign bit to select the global or session arena. Index into the root children array using level_1. If level_2 is not the sentinel, index into the level_1 KB's children using level_2. Continue for level_3 and level_4, short-circuiting on sentinel. At the target KB (or the deepest encoded KB if remaining_depth is greater than 0), call `uuid_map.get(full_vdr_id)` to retrieve the local slot index, then access the fact at that slot.

For entities deeper than four levels, the L4 KB's uuid_map contains entries for all entities in its entire subtree. This makes the L4 map larger for deep hierarchies — a typical L4 KB with 50 child libraries of 100 entities each would have a 5000-entry map — but the hash lookup is still fast because AutoHashMap on i64 keys has excellent distribution, and the four preceding levels were navigated by array access at nanosecond cost.

Performance characteristics: global cache hit resolves in 10 to 50 nanoseconds (one hash lookup). Structural walk plus KB map resolves in 50 to 200 nanoseconds (bit extraction, 1-4 array accesses, one scoped hash lookup). Worst case for deep cold entities is 200 to 500 nanoseconds. All sub-microsecond. All without touching the system-wide loaded LUT that the current design uses.

The per-KB UUID maps add approximately 39.5 MB to the global arena for a system with 12,750 KBs averaging 157 facts each, computed as 157 entries × 16 bytes per entry × 1.25 capacity overhead × 12,750 KBs.

## 3. GEMM Scope Narrowing

The structural UUID prefix directly determines which per-KB GEMM caches are relevant to a query. Before any weight data is accessed, the system extracts the L1 and L2 bits from each VdrId involved in the query, forming a prefix. GEMM cache relevance is tested by ANDing the cache's kb_id with the prefix mask and comparing against the query prefix. This is one AND and one CMP per cache — an integer operation that eliminates irrelevant caches before any weight data is touched.

For a query scoped entirely within `root.programming.python`, only GEMM caches whose kb_id structural prefix matches L1=programming, L2=python are scanned. All other domain caches — physics, chemistry, cooking, Japanese language — are skipped without accessing their weight data. This narrows the three-path weight retrieval (MD16) from a scan of all accessible GEMM caches to a scan of only the relevant subtree's caches.

## 4. Prompt Input Pipeline

The prompt input pipeline transforms raw user text into structured UUID-addressed facts before the LLM executes. It operates in five stages.

Stage 1 tokenizes the input text on whitespace and punctuation boundaries, producing candidate tokens for atom table lookup.

Stage 2 applies spell correction, governed by a client session property that controls correction aggressiveness. The property operates on a continuous scale: "off" means no corrections under any circumstances, "max only" means correct only when there is exactly one candidate at edit distance 1 with no ambiguity, and lower settings progressively allow fuzzier matching. Context modifies correction decisions: tokens inside quotation marks are never corrected because the misspelling may be intentional. Tokens with multiple equidistant candidates are left uncorrected and flagged as ambiguous. Tokens with no close match are left as raw text terms. Correction confidence feeds into the fact's provenance — a corrected token receives `user_stated` confidence (70%) minus a penalty proportional to edit distance.

Stage 3 resolves accepted tokens against the KB tree. Each token is looked up in the atom table, and matching atoms map to VdrIds in the knowledge graph. A single input token may match multiple entities — "list" might match the verb concept in the English grammar KB, the Python list type, and the abstract enumeration concept. The availability surface filters candidates to entities accessible by the current session's grants.

Stage 4 disambiguates multiple resolution candidates through typed relation co-occurrence. Tokens that co-occur in the input are checked for connecting relations in the KB graph. "list" plus "files" activates the filesystem domain because a relation path connects them through directory listing concepts. "order" in the presence of "list" and "files" activates sorting rather than purchasing because the typed relations between file listing and sorting are stronger than between file listing and commercial ordering. This disambiguation is entirely L3 — typed relation queries and relation index scans, no LLM involvement.

Stage 5 asserts the resolved interpretation to `session_root._llm.prompt_current` as structured facts. Each resolved token becomes a fact with `tag=.reference` and `value` set to the resolved VdrId. The original raw text is also preserved as a fact with `tag=.text` for fallback if the structured interpretation proves insufficient. Unresolved tokens are flagged with `resolved=false` and retained — they are never silently dropped.

## 5. Causal Chain Derivation

Before the LLM runs its forward pass, the Prolog engine composes typed relations into solution paths through causal chain derivation. This is the mechanism by which the system answers "how do I do X?" questions mechanically.

The derivation operates by chaining typed relations across the KB graph. The relation types involved are primarily `enables`, `requires`, `produces`, `accepts`, `instance_of`, `part_of`, and `transforms_to`. A query like "list files in order using Python" generates a chain: the user desires file listing, file listing is enabled by `os.listdir` or `pathlib.Path.iterdir`, these functions require specific imports, they produce list-typed output, `sorted` accepts iterables, list is an instance of iterable, therefore `sorted` can transform the output into ordered form. Each link in the chain is a typed relation lookup at L3 — sub-microsecond, zero LLM tokens.

The chain is constructed by Prolog rules in the system KBs that encode meta-reasoning patterns. These rules are not domain-specific — they express general causal composition: if a function enables an operation, and that operation is part of the user's goal, and the function requires an import, then the import is a prerequisite. The rules fire against domain-specific facts (which functions exist, what they enable, what they require) to produce domain-specific chains.

The derived chain is logged to `prompt_current` as structured facts: an ordered sequence of steps, each referencing the VdrId of the relevant entity, each carrying provenance from the source facts, and the overall chain carrying confidence equal to the minimum confidence of its component facts. The LLM reads this chain and assembles the solution rather than inventing it. This reduces generation from approximately 85 tokens of novel code to approximately 45 tokens of assembly and framing — a 47% reduction in LLM compute for this query class.

When the derivation encounters an unresolved token — a term that maps to no entity in the KB graph — the chain reports a gap. The system delivers completed portions of the solution alongside an explicit report of what it could not resolve, and requests clarification from the user. It does not fabricate a meaning for the unresolved term, does not skip it silently, and does not guess. The system's integrity depends on never pretending to understand something it lacks a VdrId for.

## 6. Translation Architecture

Translation operates as structure-to-structure transformation with cultural rules applied mechanically, not as text-to-text neural generation.

The input decomposes into language-independent semantic UUIDs through the prompt input pipeline. "I want the key" becomes VdrIds for speaker, desire action, and key object, plus structural annotations from the English grammar and phrasing compacts: SVO sentence pattern, first-person subject, volition verb, definite noun.

Cultural rules fire as Prolog rules over session participant facts. The session carries facts about speaker and listener — age, role, institutional context, social relationship. Rules in the Japanese culture KB compute social hierarchy: `senpai_kohai(Listener, Speaker)` when the listener's role rank exceeds the speaker's. The hierarchy determines honorific level: `teineigo` for a student addressing a teacher, casual for a teacher addressing a student.

The honorific level selects verb forms, hesitation markers, sentence-final particles, and pragmatic additions. A student requesting something from a teacher produces: hesitation marker (ちょっと), pragmatic pause, attention request (すみません), the object reference, polite desire verb (いただきたいのですが), and a trailing softener particle (が). A teacher requesting the same thing from a student produces: the object noun alone (鍵). Both derive from the same semantic input — desire for the key — but the cultural rules produce completely different surface realizations based on the social hierarchy facts.

Grammar templates handle structural transformation. English SVO reorders to Japanese SOV. Particle insertion follows Prolog rules: object role requires を, topic role requires は. Subject dropping follows a rule: first-person subject is omitted in polite speech. Bilingual vocabulary relations (equivalent_to) connect English words to Japanese words with register and formality metadata.

Gesture and physical behavior annotations are also derivable from the cultural KB. A student making a request might be annotated with slight bow before speech, avoidance of direct eye contact, and clasped hand position. A teacher making a request might be annotated with direct eye contact and open palm gesture. These annotations are typed relations in the KB, applicable whether the output target is text, animation data, or stage directions.

The LLM's role in translation is minimal — approximately 10-15 tokens of judgment: confirming the mechanical output sounds natural, selecting among equivalent phrasings when multiple grammar template renderings are valid, and adding contextual adjustments based on conversation history in prompt_last. The bulk of the translation work — semantic decomposition, cultural rule application, honorific selection, grammar transformation, vocabulary mapping — is L3 mechanical processing.

Adding a new target language requires a new language compact (grammar rules, vocabulary KB with bilingual relations, cultural rules) ingested into the KB tree. The semantic UUID decomposition of the source language is unchanged. The causal chain from semantic structure to target surface form runs the same Prolog engine with different rules. No retraining of the neural network is required.

## 7. Word Group Selection and Poetry Mode

Poetry mode is an optional session-level flag (`poetry_mode: bool` on the Session struct, default false) that enables aesthetic word selection through expanded candidate sets. In core mode (the default), the system emits the canonical UUID for each content word. In poetry mode, the system generates a word group: the canonical choice plus first-degree and second-degree thesaurus expansions.

First-degree expansion retrieves direct synonyms and register variants via `synonym_of`, `similar_to`, and `register_variant_of` typed relations from vocabulary KBs. These are safe substitutions — the meaning is preserved, only flavor changes. Second-degree expansion retrieves synonyms of synonyms, with a relevance check: does the second-degree candidate still have a typed relation path (enables, equivalent_to, or similar_to) back to the original concept? If the path breaks, the candidate is excluded. This boundary prevents semantic drift — third-degree or further expansions would wander too far from the original meaning.

The LLM receives the word group as a small candidate set (typically 4-8 UUIDs) and makes a contextual selection. This is a tiny attention pass over a curated shortlist, applying the LLM's strength — contextual judgment about what sounds right — to a bounded set rather than the full 8,192-token vocabulary. Per-KB GEMM weights trained on vocabulary usage patterns assist the selection.

Poetry mode costs more than core mode: additional GEMM passes for word group evaluation, more tokens for the LLM to score candidates (approximately 60-80 tokens versus 20 for core mode), and more KB access for thesaurus traversal. The cost difference is measurable and billable, making it suitable for tiered access — free tier users receive core mode only, paid tier users can enable poetry mode per session.

Thesaurus KBs are built through normal KB operations. The LLM can be instructed to create vocabulary KBs and populate them from compacted thesaurus data. Users can build and share thesaurus compacts through the mod store (Steam Workshop), with user-contributed data ingesting at the appropriate confidence level. Domain-specific vocabulary KBs (literary Japanese, business Japanese, Kansai dialect) extend the word group palette for specific registers.

## 8. LLM as UUID Predictor

The LLM in VDR-Prolog does not generate text. It predicts the next UUID in a sequence from a vocabulary of 8,192 structural addresses. The forward pass sees a sequence of i64 values — some are command tokens, some are KB addresses, some are argument values, some are template references. The embedding layer maps each to a learned vector. The attention layers predict which i64 comes next. The output layer selects via exact softmax (sum = D = 65536).

The LLM is indifferent to the semantic meaning of its output. It does not distinguish between emitting the UUID for `kb_query` (which reads some facts), the UUID for `op_execute` (which launches a process), and the UUID for `grammar_render` (which formats text). They are all i64 values processed through the same GEMM, the same attention, the same softmax. The difference in consequence exists entirely outside the LLM — in the grant system, the execution engine, and the KB tree.

The grant system enforces what UUIDs are allowed to execute. The LLM can predict `op_execute` all day — without an active grant of class `execute`, the builtin engine returns `grant_denied` (error code 600) and the audit engine logs the attempt. Security is structural, not behavioral. The system does not instruct the LLM to avoid dangerous operations. It prevents the operations from executing regardless of what the LLM predicts.

Hot path UUIDs — command tokens, seed KB addresses, frequently accessed builtins — reside in the global hot cache and the GEMM caches of early KBs (root.system.command_vocab, root.system.builtins). These are the tokens the model predicts most often, so their embeddings are the most trained and their GEMM rows are the most cached.

The scratchpad (`session_root._llm.scratchpad`) stores the LLM's cross-turn notes as VdrId reference facts, not text. Each "note" is a fact with `tag=.reference` pointing to a structural address in the KB tree. On subsequent turns, the LLM reads these VdrIds — four i64 values encoding what the user wants, which tools apply, and how they connect — rather than re-reading paragraphs of text context. The pre-resolution pipeline can follow these addresses, check for changes, and present updated state before the LLM runs.

## 9. Error Model

The error mode of VDR-Prolog differs fundamentally from CLLM error modes. In a CLLM, low token probability produces a flat softmax distribution across the full vocabulary. Float rounding noise at the precision boundary can push any token above the others, producing hallucinated words, malformed syntax, or fabricated function names. The error is indistinguishable from correct output.

In VDR-Prolog, low token probability produces a flat softmax distribution across 8,192 UUIDs. But every possible output is a valid UUID pointing to a real entity in the KB tree. The system cannot hallucinate a function that does not exist because there is no UUID for a nonexistent function. It cannot emit a malformed JSON bracket because formatting is handled by grammar templates, not token generation. It cannot generate a plausible-sounding but wrong API call because every API call in the vocabulary references a real, provenanced fact.

The failure mode is selecting the wrong UUID — picking `os.listdir` when `pathlib.Path.iterdir` would be more appropriate. Both are real functions. Both exist. Both work. The error is suboptimal choice, not fabrication.

This error type is detectable. When the winning token's softmax score is barely above alternatives, the system can verify the selection by checking whether the selected UUID has typed relations that connect coherently to preceding UUIDs in the sequence. If the causal chain derivation produced a pre-resolved path, the neural selection can be compared against the mechanical derivation. If no candidate connects well to the established context, the system can defer entirely to the mechanical systems rather than trusting a low-confidence neural selection.

The error floor is bounded by the contents of the KB tree. The worst possible output is a real entity chosen for the wrong reasons. The best possible output of a CLLM in the same low-confidence scenario is indistinguishable from the worst because both are presented identically — as confident text with no provenance.

## 10. Computational Identity

VDR-Prolog is not a chatbot. It is a UUID matching and execution engine. Every operation — asserting a fact, retracting a fact, firing a rule, transitioning an FSM, scoring a behavior, rendering a grammar template, launching a process, correcting an error — is a KB operation on structural addresses.

A correction is not a conversational act. It is a retract of the incorrect fact followed by an assert of the correct fact. The provenance chain updates. The confidence score reflects the new source. Every future query that touches the corrected entity gets the right answer. There is no apology, no performative acknowledgment, no paragraph of self-deprecation. The system was wrong, now it is right, and the state change is two KB operations.

This identity extends to all system behavior. A greeting is not social performance — it is a grammar template rendering triggered by a session lifecycle FSM transition from `created` to `active`. A refusal is not a policy decision — it is a `grant_denied` error code returned by the grant engine because the session lacks the required capability class. A translation is not linguistic creativity — it is a structural transformation through typed relations, cultural rules, and grammar templates with the LLM selecting among mechanically-valid candidates.

The system produces no ceremony because ceremony is not a KB operation. Every token of output traces to a UUID, every UUID traces to a fact, every fact traces to a provenance source, and the chain from user input to system output is mechanically verifiable at every link.

## 11. Memory Model at Scale

At 2 million facts distributed across approximately 12,750 KBs at 6-7 depth levels, the global arena budget breaks down as follows. Facts consume 96 MB (2,000,000 × 48 bytes). KB structs consume 3.3 MB (12,750 × 256 bytes). Per-KB UUID maps consume 39.5 MB (12,750 KBs × 157 average entries × 16 bytes × 1.25 capacity overhead). Typed relations consume 28.8 MB (600,000 × 48 bytes). Relation indices consume 4.2 MB (8,000 KBs with relations × 528 bytes). Rules consume 4.8 MB (100,000 × 48 bytes). Terms consume 7.2 MB (300,000 × 24 bytes). Text storage consumes approximately 100 MB for a corpus including source code. Weight matrices consume approximately 1,500 MB, remaining the dominant cost. Overhead for profiles, grants, audit, FSMs, and behavior sets consumes approximately 16 MB. Total global arena usage is approximately 1,800 MB, within the 2.65 GB budget with substantial headroom.

The distribution across tree depth is heavily skewed. Depth 1 (150 root KBs) holds approximately 75,000 structurally important facts. Depths 2-4 (approximately 6,600 KBs) hold approximately 1,180,000 facts covering domain knowledge, relationships, and rules. Depths 5-7 (approximately 6,000 KBs) hold approximately 745,000 facts covering specific implementation details, source code, and leaf-level data.

## 12. Performance Model

Wall clock for an L1 query (code generation requiring full LLM forward pass) decomposes as follows. HTTP receipt (TCP accept, JSON parse, session resolution, queue push) takes 60-130 microseconds, dominated by kernel TCP overhead. Query classification (tokenize, atom lookup, AtomRelTypeCache checks, classification construction) takes 1.5-2.5 microseconds. FSM evaluation (state check, transition scan) takes 0.2 microseconds. UAI scoring (consideration evaluation, response curve application, Dave Mark compensation, selection) takes 1.7 microseconds. Prolog pre-fetch via causal chain derivation (structural ID decode, tree walk, relation index scans, fact retrieval, prompt_current assertion) takes 2.5-3.5 microseconds. LLM forward pass (prefill at approximately 2 ms per token for 40-60 input tokens, autoregressive generation at approximately 5.3 ms per token for 45-85 output tokens) takes 320-570 milliseconds. Grammar rendering (template selection, slot filling, response composition) takes 2-3 microseconds. Post-generation housekeeping (prompt copy, counter updates, FSM re-evaluation) takes 1.2 microseconds. HTTP response (buffer write, TCP send) takes 50-100 microseconds. Total wall clock is approximately 320-570 milliseconds, with the LLM forward pass consuming 99.96% of the time.

For an L3 query (typed relation lookup, no LLM involvement), the LLM forward pass is eliminated entirely. Total wall clock drops to 70-140 microseconds, dominated by HTTP I/O. The mechanical processing — classification, FSM, scoring, Prolog resolution, grammar rendering — completes in under 10 microseconds combined. At this speed, a single core handles over 200,000 L3 requests per second before the HTTP layer becomes the bottleneck.

The structural UUID system contributes 2-5 microseconds of savings per request compared to hash-based lookup in a 2-million-entry global table. This is negligible against L1 forward pass time but significant for L3 throughput, where it represents 30-50% of the total mechanical processing time.

## 13. New Invariants

IN36: Structural VdrId bits must match the entity's actual position in the KB tree. Reparenting requires VdrId recomputation for the moved entity and all descendants.

IN37: Per-KB UUID map is always consistent with the KB's fact array. Every fact assertion adds to the map, every retraction removes from it, serialization captures both atomically.

IN38: Global hot cache entries are valid pointers to resident KBs. Eviction from the hot cache never invalidates a KB — the KB remains accessible through structural walk, only the fast path is removed.

IN39: Unresolved tokens in the prompt input pipeline are never silently dropped. Every input token is either resolved to a VdrId, corrected and resolved, or flagged as unresolved and preserved as a text fact.

IN40: Poetry mode does not affect mechanical correctness. Honorific selection, grammar transformation, cultural rules, and causal chain derivation produce identical results regardless of the poetry_mode flag. Only content word selection among semantically-equivalent candidates is affected.

IN41: Second-degree thesaurus expansion must maintain a typed relation path back to the original concept. Candidates without a verifiable path are excluded from the word group.

IN42: The LLM's output vocabulary contains only valid VdrIds referencing real entities in the KB tree. The system cannot produce a reference to a nonexistent entity through neural inference.
