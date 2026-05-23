# VDR-Prolog Grammar Evidence System — Technical Specification v0.1

## Purpose and Scope

This specification describes the complete pipeline for extracting grammar evidence from Project Gutenberg texts, storing it as typed relations between grammar entities in the VDR-Prolog KB tree, and using that evidence to inform output rendering when the system expresses structural knowledge as natural language. The system does not extract knowledge content from Gutenberg — that role belongs to the 500 base domain compacts. Instead it mines observed linguistic behavior: how authors actually express relationships, transition between ideas, modulate register, and construct sentences. The output is a dense relation graph in the grammar subtree that the grammar engine and LLM draw on during the rendering phase of every inference cycle.

This spec assumes familiarity with the VDR-Prolog Technical Specification v0.5 and the VdrId-to-VdrId Relation System report. All references use the established ID prefix system (PR, SU, DT, RT, etc.).

---

## Part One: Grammar KB Architecture

### Grammar Entity Types

The grammar subtree lives under `root.language` with per-language children. English is `root.language.english` with its own children for grammar, vocabulary, register, and transitions. Every item in these KBs is a VdrId-addressed entity following the standard structural UUID layout (SU1-SU5).

Grammar entities fall into seven categories, each stored as KBData entries with appropriate FactTags in their host KBs.

**Constructions** are sentence-level structural patterns. A construction encodes the skeletal shape of a sentence independent of content — active causative ("X causes Y"), passive result ("Y is caused by X"), conditional enablement ("if X then Y"), nominalized process ("the causing of Y by X"). Each construction is a KBData entry with a VdrId, a text column holding the pattern template with argument slots, and a FactTag of TAG_TEXT for the template plus TAG_REFERENCE entries pointing to the argument-type entities that fill its slots. A construction does not specify vocabulary — it specifies structure. The distinction matters because the same construction renders differently in different registers.

**Clause types** are sub-sentence structural units. Main clauses, subordinate clauses, relative clauses, participial phrases, appositives — each is a KBData entry. Constructions relate to clause types via `composed_of` relations: a complex construction might be composed_of a main clause and a subordinate clause. This decomposition lets the grammar engine build compound sentences by composing clause-type entities through typed relations rather than storing every possible combination as a separate construction.

**Transitions** are inter-sentence connective patterns. When a text moves from expressing an `enables` relation to expressing a `requires` relation, the transition between those two sentences has observable structure — conjunctive adverbs ("however", "moreover", "consequently"), paragraph breaks, bridging phrases ("building on this", "this in turn demands"). Each transition pattern is a KBData entry. Transitions relate to the relation-type pair they bridge: a transition entity connects via `applies_to` relations to two relation-type entities, expressing "this transition pattern is observed between sentences that render enables and sentences that render requires."

**Register markers** are vocabulary and construction modifiers that signal formality level, domain context, and audience assumptions. Scientific register, conversational register, literary register, technical documentation register — each is a KBData entry. Register markers relate to constructions via `constrains` relations: scientific register constrains which constructions are appropriate (nominalized forms preferred over active voice for process descriptions, for instance). They also relate to vocabulary entries via `scoped_to` relations, indicating which word choices belong to which register.

**Vocabulary groups** are clusters of words that can fill the same argument slot in a construction with similar semantic effect but different register, connotation, or rhythm. "Causes", "produces", "gives rise to", "engenders", "results in" — these form a vocabulary group for the causative argument slot. Each group is a KBData entry containing references to individual vocabulary entries. The group relates to its construction's argument slot via `fills` (a domain-registered relation type). Individual vocabulary entries within the group relate to register markers via `scoped_to`, enabling register-appropriate selection.

**Prosodic patterns** describe rhythm and flow at the sentence and paragraph level. Sentence length variation, clause rhythm, emphasis placement — these are observable in Gutenberg texts and affect output naturalness. Each prosodic pattern is a KBData entry relating to constructions via `modifies` relations. This is the least structured category and accumulates evidence slowly, but it addresses the difference between mechanically correct output and output that reads naturally.

**Rhetorical moves** are discourse-level patterns that span multiple sentences. Claim-evidence-conclusion, problem-solution, comparison-contrast, narrative arc — each is a KBData entry. Rhetorical moves relate to sequences of constructions via `composed_of` and to transitions via `requires`, expressing "this rhetorical move requires these transition patterns between its component constructions."

### KB Tree Layout

The grammar subtree extends the existing KB tree (KT1-KT16) under a new branch. The layout for English is representative; other languages follow the same pattern with language-specific content.

`root.language` is the parent KB for all language-related data. Its children are per-language KBs. `root.language.english` contains language-level metadata — character set properties, basic word-order parameters (SVO), morphological type markers. Its children are the functional KBs.

`root.language.english.grammar` holds construction entities, clause type entities, and their structural relations. This is the core grammar KB. Its RelationIndex (DT12) tracks `composed_of`, `generates`, `specializes`, and `extends` relations densely — these are the primary structural relations among grammar entities.

`root.language.english.vocabulary` holds vocabulary group entities and individual word entries. Each word entry carries register tags, frequency data as Q16 strength values, and `synonym_of`/`similar_to`/`register_variant_of` relations to other entries. This KB is large — potentially tens of thousands of entries — and lazy-loads per PS7.

`root.language.english.register` holds register marker entities and their constraining relations to constructions and vocabulary. Relatively small (dozens of register categories) but densely connected.

`root.language.english.transitions` holds transition pattern entities and their `applies_to` relations to relation-type pairs. This KB grows significantly from Gutenberg evidence — observed transitions are the primary output of the parsing pipeline for inter-sentence patterns.

`root.language.english.rhetoric` holds rhetorical move entities. This KB is small at ship and grows through Gutenberg evidence and user feedback.

`root.language.english.evidence` is the Gutenberg-specific evidence KB. This is where raw observation records land before being processed into relations in the functional KBs above. It serves as a staging area and provenance anchor — every grammar relation derived from Gutenberg evidence traces back through its provenance chain to an entry in this KB, which in turn carries the Gutenberg source identifier. This KB can be large and is a candidate for aggressive lazy loading.

All of these KBs get standard VdrIds via the structural UUID system. A construction entity in `root.language.english.grammar` has a VdrId encoding its full tree path: sign=0 (global), L1=language index, L2=english index, L3=grammar index, L4=entity index within grammar, plus 20 random bits for collision avoidance per SU3.

### Relation Types for Grammar

The grammar system uses a mix of existing system relation types (RT1-RT26) and domain-registered types in the 64-127 slot range (RT27) or the domain-registerable range starting at 1,000,000.

Existing system types that apply directly: `composed_of` (RT26) connects constructions to clause types, rhetorical moves to construction sequences. `specializes` (RT15) and `generalizes` (RT16) connect construction variants — passive causative specializes causative. `contains` (RT18) connects vocabulary groups to individual entries. `scoped_to` (RT22) connects vocabulary and constructions to register markers. `enables` (RT1) and `requires` (RT2) connect rhetorical moves to transition requirements. `follows` (RT19) and `precedes` (RT20) connect clause types within construction order. `equivalent_to` (RT13) connects constructions that express identical structural meaning in different surface forms.

Domain-registered types needed for grammar: `renders_as` connects a relation type VdrId (like the VdrId for the `enables` concept in `root.system.relation_types`) to a construction VdrId in the grammar KB — "the enables relation renders as this causative construction." `fills` connects a vocabulary group to a construction argument slot — "this group of words fills the agent slot in this construction." `observed_with` connects two grammar entities that co-occur in Gutenberg evidence — "this transition pattern is observed with this construction in scientific texts." `modulates` connects prosodic patterns to constructions. `bridges` connects transition patterns to the relation-type pairs they connect.

These domain types register through the standard mechanism (IN17, first-come in slots 64-127 or 1,000,000+). Each carries its own inverse, symmetry, and transitivity declarations. `renders_as` has inverse `rendered_by`, is not symmetric, is not transitive. `fills` has inverse `filled_by`, is not symmetric, is not transitive. `observed_with` is symmetric (if A is observed with B, B is observed with A), not transitive. `bridges` is not symmetric, not transitive. `modulates` has inverse `modulated_by`, is not symmetric, is not transitive.

---

## Part Two: Gutenberg Parsing Pipeline

### Source Selection and Preprocessing

Project Gutenberg texts are UTF-8 plain text files with a standard header and footer boilerplate. The preprocessing stage strips this boilerplate — it follows a consistent pattern starting with "*** START OF THE PROJECT GUTENBERG EBOOK" and ending with "*** END OF THE PROJECT GUTENBERG EBOOK". Everything outside these markers is metadata (title, author, language, subject classification, LoC category) that becomes provenance data, not grammar evidence.

Not all Gutenberg texts are equally valuable for grammar evidence. The selection criteria prioritize texts that exhibit diverse, well-formed prose across multiple registers. Scientific treatises, philosophical works, technical manuals, essays, and literary fiction each contribute different construction patterns and register evidence. Poetry is excluded from grammar parsing — its syntactic patterns are intentionally irregular and would introduce noise into construction frequency data. Poetry texts are valuable for the poetry mode system (PO1-PO6) but route to a different ingestion path focused on vocabulary and prosodic relations rather than grammatical constructions.

Texts are tagged with their Gutenberg metadata before entering the pipeline. The LoC classification becomes a domain hint that informs register assignment during parsing — a text classified under "QC Physics" is expected to exhibit scientific register, which weights the register associations of observed constructions. This metadata flows into the provenance (DT7) of every grammar relation produced from that text, with source_type set to CF7 (published, 80/100).

### External Compaction: The Grammar Parse

The existing ingestion pipeline (IG1-IG6) expects `.compact` files as input, with an external LLM performing the initial compaction (IG1). For grammar evidence, the external LLM's task is fundamentally different from domain knowledge compaction. It is not extracting "what the text says" but "how the text says it."

The grammar-focused compaction prompt instructs the external LLM to analyze each sentence and produce three outputs per sentence.

First, the structural relation expressed. If the sentence "Increased temperature accelerates the Maillard reaction" expresses a `causes` relation, the compaction output identifies `causes` as the structural relation. If the sentence is purely descriptive with no inter-entity relation ("The sky was overcast"), the output marks it as `descriptive` with no relation type. If the sentence expresses a relation not in the system's type inventory, the output marks it as `unknown_relation` with the closest approximation noted. The external LLM is not asked to identify the domain entities (temperature, Maillard reaction) — that's the job of the domain compacts. It identifies only the relation type.

Second, the grammatical construction used. The LLM identifies the sentence's structural pattern: active causative, passive result, conditional, nominalized, existential, comparative, and so forth. The construction vocabulary used in the compaction output maps to the construction entities already defined in `root.language.english.grammar`. If the observed construction doesn't match an existing entity, the compaction output describes it structurally and flags it as `new_construction` for human review during the ingestion validation stage (IG2).

Third, contextual annotations. The register (scientific, literary, conversational, technical), the transition from the preceding sentence (if any — conjunctive adverb, paragraph break, bridging phrase, no explicit transition), and any notable prosodic features (unusually long sentence, parallel structure, rhetorical question). These annotations become the basis for register, transition, and prosodic relations.

The output format is pipe-delimited `.compact` tables, consistent with the existing ingestion format. Each sentence produces one row in a `grammar_observations` table. The table columns are: observation_id (unique within the file), source_text_id (Gutenberg catalog number), sentence_position (integer offset within the text), relation_type (system RelationType name or "descriptive" or "unknown_relation"), construction_id (existing construction entity name or "new_construction" with description), register (register marker name), transition_from_previous (transition pattern name or "none" or "paragraph_break"), and prosodic_notes (free text, may be empty).

A companion `construction_candidates` table captures any `new_construction` entries with their structural descriptions, proposed argument slots, and the example sentence. These enter the ingestion pipeline as provisional entities requiring validation.

### Ingestion of Grammar Evidence

The `.compact` files from grammar-focused compaction enter the standard ingestion pipeline (IG1-IG6) but route to the grammar subtree rather than domain KBs.

At IG2 (validation), the pipeline checks that every `construction_id` in the observations table resolves to an existing entity VdrId in `root.language.english.grammar` or is flagged as `new_construction`. Every `relation_type` must resolve to a valid RelationType enum value or the reserved descriptive/unknown markers. Every `register` must resolve to an existing register marker entity or be flagged for creation. Validation failures don't reject the file — they flag individual observations as unresolved, consistent with PR16 (unresolved tokens never silently dropped, IN39).

At IG3 (KB creation), no new KBs are needed per file — the grammar subtree already exists. New construction candidates from the `construction_candidates` table create new KBData entries in `root.language.english.grammar` if they pass human review. If review is pending, they land in `root.language.english.evidence` as provisional entries with reduced confidence.

At IG4 (fact assertion), each grammar observation becomes a set of facts in `root.language.english.evidence`. The observation entity gets a VdrId, and its fields become TAG_TEXT (source sentence position reference), TAG_VALUE (sentence position as Q16 integer), and TAG_REFERENCE (pointing to the source text identifier entity).

At IG5 (relation and rule assertion), this is where the grammar evidence becomes structurally useful. Each observation generates TypedRelations.

The primary relation is `renders_as` connecting the relation type's VdrId (in `root.system.relation_types`) to the construction's VdrId (in `root.language.english.grammar`). If this relation already exists from a previous observation, the existing relation's strength (Q16) is incremented — it represents observed frequency. If it's new, the relation is created with an initial strength of Q16{v=1, r0=0, r1=0}. The provenance points to the observation entity in the evidence KB.

Secondary relations capture context. An `observed_with` relation connects the construction to the register marker. A `bridges` relation connects any observed transition pattern to the pair of relation types it bridges (the current sentence's relation type and the preceding sentence's relation type). A `modulates` relation connects any noted prosodic pattern to the construction.

Each of these relations carries provenance at CF7 (published, 80/100) chained with the compaction step, so the effective confidence is min(CF7, CF10) = CF10 (30/100) per CF15 (ingestion weakest link). This is intentionally conservative — grammar evidence from a single observation is low confidence. But the strength field accumulates across observations. A `renders_as` relation with strength Q16{v=2100, r0=0, r1=0} means "observed 2,100 times across all parsed texts" while still carrying 30/100 confidence for any individual observation. The distinction between confidence (how much you trust the source) and strength (how often you've seen it) is critical. Strength is a Q16 counter. Confidence is a provenance property.

At IG6 (profile and freeze), the CompactionProfile (DT17) records the Gutenberg text's catalog number, the observation count, the relation types produced, and the compression ratio (sentences scanned vs. relations produced). The evidence KB entries freeze. The functional grammar KBs (`root.language.english.grammar`, `.vocabulary`, `.register`, `.transitions`) do not freeze — they accumulate relations from multiple Gutenberg texts over time.

### Batch Processing and Scale

Project Gutenberg contains approximately 70,000 texts. Not all are suitable for English grammar evidence — many are in other languages (which feed their respective language subtrees), many are poetry (routed to poetry mode), many are very short. A realistic English prose corpus from Gutenberg is roughly 30,000-40,000 texts.

Processing at scale means the external LLM compaction (IG1) is the bottleneck. Each text averages roughly 5,000-10,000 sentences. At 40,000 texts, that's 200-400 million sentence-level observations. The compaction can run incrementally — texts processed in batches, each batch producing `.compact` files that ingest independently. No ordering dependency between batches.

The grammar KBs grow as batches ingest. The `renders_as` relation strengths accumulate monotonically. The RelationIndex (DT12) rebuilds are eventually consistent (IN19) — the by_type_counts array updates as relations are added, and the index rebuilds periodically to maintain scan efficiency.

Memory impact is manageable. Each TypedRelation is 48 bytes (DT11). If the grammar subtree accumulates 500,000 relations (a reasonable upper bound after full Gutenberg processing — most sentences produce 2-3 relations but many deduplicate into strength increments on existing relations), that's 24 MB of relation data. The evidence KB is larger because it stores per-observation entities, but it lazy-loads (PS7, IN24) and is primarily a provenance anchor rather than a query-time resource. The functional grammar KBs — grammar, vocabulary, register, transitions — are the hot path and stay resident.

### Provenance Chain

Every grammar relation traces back through a complete provenance chain. A `renders_as` relation between `causes` and `active_causative_construction` carries provenance with source_type=CF10 (llm_generated, 30/100 — because the external LLM identified the construction), source_kb_id pointing to the evidence KB, source_slot_id pointing to the observation entity, and derivation_rule_id pointing to the ingestion rule that produced the relation. The observation entity in the evidence KB carries its own provenance with source_type=CF7 (published, 80/100) and a reference to the Gutenberg catalog entry. The chain is: grammar relation → observation entity → Gutenberg source. Two hops, fully inspectable, editable via the provenance editing system (PD2, FB6).

---

## Part Three: Rendering Integration

### How the Grammar Engine Uses Evidence

The rendering phase occurs at the end of every inference cycle (PX5-PX8). The causal chain engine (CC1-CC5) has produced an ordered sequence of structural relations — VdrId pairs connected by typed relations, each with provenance and confidence. The grammar engine's job is to transform this sequence of structural addresses into natural language output.

The rendering pipeline has four stages: construction selection, argument filling, transition insertion, and register application.

**Construction selection** starts from the relation type. The causal chain contains a step like `enables(photosynthesis_VdrId, plant_growth_VdrId)`. The grammar engine queries: "What constructions render the `enables` relation type?" This is a direct relation lookup — scan the grammar KB's RelationIndex for `renders_as` relations where `from_id` is the `enables` relation type's VdrId. The result is a set of construction VdrIds, each with a strength value reflecting observed frequency from Gutenberg evidence.

Multiple constructions will match. "X enables Y" (active), "Y is enabled by X" (passive), "because of X, Y" (causal subordinate), "X, which enables Y" (relative clause), and others. The selection among these candidates is where the LLM's ~20 framing tokens operate (IF1, IF2). The LLM sees the candidate construction VdrIds, their strength values, and their register associations, and selects one. The GEMM weights for the grammar KB (DT14-DT16) are informed by the frequency data — constructions with higher observed strength in the relevant register have higher weight. The LLM is not generating text — it is selecting a UUID from a vocabulary of valid construction VdrIds (LI1).

If no `renders_as` relation exists for a given relation type (possible early in the system's life before much Gutenberg evidence has been ingested), the grammar engine falls back to a default construction defined in the grammar KB's seed data. Every relation type has at least one seed construction — these are hand-authored during initial system setup and serve as the floor. Gutenberg evidence enriches the options above this floor; it never removes the floor.

**Argument filling** takes the selected construction's template and fills its argument slots with content from the structural entities. The construction "X enables Y" has two argument slots. The grammar engine resolves the `from_id` (photosynthesis) and `to_id` (plant_growth) through the standard tree walk, retrieves their display-name text from their host KBs, and fills the slots. Vocabulary group selection applies here — if the construction's argument slot has a `fills` relation to a vocabulary group, the engine selects from that group based on register constraints. "Enables", "facilitates", "supports", "allows" — the vocabulary group provides options, register narrows them, the LLM picks (or the highest-strength option is used at L3 without LLM involvement).

**Transition insertion** handles the connections between consecutive rendered sentences. If the causal chain has steps `enables(A, B)` followed by `requires(B, C)`, the transition between those two rendered sentences needs connective tissue. The grammar engine queries the transitions KB: "What transition patterns bridge `enables` followed by `requires`?" This is a `bridges` relation lookup — scan for `bridges` relations where the transition pattern connects the two relation types. The result is a set of transition pattern VdrIds with strength values. Selection follows the same pattern as construction selection — candidates presented, LLM or strength-based selection picks one. "This in turn requires...", "Building on this, ...", "Furthermore, ..." — all observed transition patterns with provenance back to Gutenberg evidence.

If the causal chain has only one step, no transition is needed. If consecutive steps express the same relation type, the transition engine also handles variation — it avoids repeating the same construction by consulting the `observed_with` relations to find constructions that co-occur naturally with the one just used.

**Register application** is a filter that runs throughout the other three stages. The session (DT23) carries context that determines register — the user's interaction style, the domain being discussed, explicit register requests. Register marker entities in the register KB have `constrains` relations to constructions and `scoped_to` relations from vocabulary entries. These relations act as structural constraints in exactly the way described in the relation system report — Prolog rules over register relations prune the candidate space before selection. If the session context indicates scientific register, constructions and vocabulary without `scoped_to` relations to the scientific register marker are deprioritized (their effective strength is reduced, not eliminated — register is a preference, not a hard gate, unless the user explicitly requests strict register adherence as a session fact).

### Construction Selection as Prolog Query

The construction selection process is a Prolog query over grammar relations, following the priority chain (PL1-PL6).

At PL1 (typed relation fast path), the engine scans for `renders_as` relations matching the target relation type. This is a RelationIndex lookup — sub-microsecond, L3. The result is a candidate set of construction VdrIds with strengths.

At PL5 (structural inheritance), if the relation type `specializes` another (e.g., a domain-specific relation type specializing `enables`), the engine follows the `specializes` chain upward and includes constructions that render the parent type. This broadens the candidate set for specialized relation types that may not have their own dedicated constructions yet. The inherited constructions carry reduced strength (the specialization distance attenuates strength multiplicatively via Q16 arithmetic) to prefer specific constructions when available while ensuring a fallback path always exists.

At PL7 (fire_and_commit), rules in the grammar KB fire automatically on query. A rule like `preferred_construction(C) :- renders_as(RelType, C), observed_with(C, Register), scoped_to(Register, CurrentSession)` composes three relation lookups into a derived fact asserted at prolog_derivation confidence (CF2, 100/100 for the derivation step, chained with the weakest input). These derived facts accumulate over the session's lifetime, so repeated rendering queries benefit from previously derived preferences.

The total cost of construction selection is L3 for the common case — typed relation scans, no LLM tokens. The LLM enters only when the candidate set has multiple similarly-weighted options and the session context doesn't disambiguate (L2 — LLM selects from candidates, ~18 tokens per IF2). For the majority of rendering decisions, Gutenberg evidence strength plus register constraints narrow to a single best candidate without LLM involvement.

### Cross-Domain Grammar

The grammar evidence system inherits the cross-domain mechanics described in the relation system report. A causal chain that spans physics and cooking (the "why does meat brown" example) traverses three domain KBs for structural content but hits the same grammar KBs for rendering. The grammar engine doesn't know or care that the `enables` relation it's rendering connects entities in different domain subtrees. It sees the relation type, queries constructions, selects, fills arguments with display names from wherever the entities live, and renders.

This means grammar evidence from Gutenberg physics texts benefits chemistry rendering, and grammar evidence from Gutenberg novels benefits technical documentation. A transition pattern observed between `causes` and `requires` in a Victorian-era chemistry textbook is available when rendering a modern programming dependency chain, if the register is compatible. The structural relation types are the bridge — they are domain-independent, and the grammar constructions that render them are domain-independent. Only the argument content (the display names filling the slots) is domain-specific.

GEMM scoping (SU6, XD2-XD3) for rendering queries includes both the domain subtrees (for argument resolution) and the grammar subtree (for construction selection). The structural prefix check (SU5) ensures only relevant subtrees participate. A rendering query for a physics-only causal chain scopes to `root.edu.physics` for content and `root.language.english` for grammar — two L1 subtrees, everything else eliminated.

### Poetry Mode Integration

Poetry mode (PO1-PO6) interacts with the grammar evidence system at the vocabulary group level. When poetry_mode is true on the session (DT23), the vocabulary selection within argument filling expands from direct group members to first-degree and second-degree synonyms (PO2-PO3). The grammar constructions themselves don't change — poetry mode doesn't alter sentence structure, it enriches word choice within the same structural slots.

The Gutenberg evidence contributes to poetry mode indirectly. Literary texts parsed for grammar evidence also populate vocabulary groups with register-marked entries tagged as "literary" register. When poetry mode activates and synonym expansion runs, these literary-register vocabulary entries become available as candidates. The `register_variant_of` relations between a standard vocabulary entry ("causes") and its literary variant ("engenders") are exactly the kind of evidence Gutenberg literary texts provide densely.

The invariant IN40 (poetry mode doesn't affect mechanical correctness) is preserved because construction selection and argument structure remain unchanged. Only the vocabulary filling step expands its candidate set. The construction still has the same number of argument slots, the same clause structure, the same relation-type rendering. The words inside the slots change.

### Translation System Integration

The translation architecture (TL1-TL6) connects to grammar evidence through the language-independent structural layer. The structural relation types and constructions exist independently of any surface language. When the rendering target is Japanese rather than English, the grammar engine queries `root.language.japanese.grammar` instead of `root.language.english.grammar` for constructions that render each relation type.

Gutenberg texts in Japanese (or any other language) feed the same grammar evidence pipeline into their respective language subtrees. The `.compact` format is identical — relation type, construction ID, register, transition — but the construction entities and vocabulary groups are language-specific. A `renders_as` relation between `enables` and a Japanese causative construction lives in the Japanese grammar KB with the same structure as its English counterpart.

The cultural rules system (TL2) overlays on grammar evidence. Japanese grammar evidence from Gutenberg includes register markers that map to keigo (honorific) levels, and the cultural rules Prolog facts (senpai_kohai, age-based hierarchy) constrain which register-marked constructions are valid for a given session's participant configuration. The Gutenberg evidence provides the construction options; the cultural rules prune them.

Adding a new language (TL6) means creating a new language subtree under `root.language`, populating it with seed constructions, and then running the Gutenberg grammar pipeline against texts in that language. No retraining — the grammar evidence ingests as relations, the per-KB GEMM weights for the new grammar KBs train through normal weight update (CO14), and the rendering engine queries the new subtree when the session's target language matches.

---

## Part Four: Feedback and Evolution

### User Feedback on Grammar

The feedback system (FB1-FB6) applies directly to grammar rendering. When a user gives thumbs-down on a rendered output, the provenance chain traces from the output through the construction selection back to the `renders_as` relation and ultimately to the Gutenberg evidence. The review queue (FB2) presents the construction, its strength, the register context, and the source evidence.

A fix (FB3) might edit the construction template — adjusting argument order, modifying a clause structure. This edit is live immediately (IN46 — UI edits trigger GEMM cache dirty), and future rendering using that construction reflects the change without retraining.

A demote (FB5) decrements the `renders_as` relation's strength, letting natural scoring deprioritize the construction. Over time, constructions that produce bad output sink below alternatives. The strength value is a Q16 integer counter — decrementing is exact, not approximate.

A delete (FB4) retracts the `renders_as` relation entirely, removing that construction as an option for that relation type. The grammar engine falls back to remaining constructions or the seed default.

### Self-Extending Grammar

The Prolog fire_and_commit mechanism (PL7) enables the grammar system to discover new patterns automatically. Rules in the grammar KB can derive new relations from existing evidence. For example, a rule that detects when two constructions are always observed in the same register contexts and never in different ones might assert an `equivalent_to` relation between them, indicating they're interchangeable within that register. Another rule might detect that a transition pattern is observed bridging three different relation-type pairs and generalize it to a broader applicability assertion.

These derived relations carry prolog_derivation confidence (CF2, 100/100 for the derivation, but chained with their input confidence per CF12). They run on the standard fire_and_commit schedule — scan rules, fire satisfied ones, assert derived facts. Idempotent. The grammar graph grows mechanically over time as more Gutenberg evidence is ingested and more cross-pattern rules fire.

### Grammar Evidence as Competitive Advantage

The density of grammar evidence determines output quality at the margin. Two VDR-Prolog systems with identical domain compacts but different grammar evidence densities will produce structurally identical causal chains but differ in how naturally those chains read when rendered. The system with denser grammar evidence — more observed constructions, more transition patterns, more register-appropriate vocabulary options — produces output that sounds like it was written by someone who has read widely, because in a meaningful sense it was. The Gutenberg corpus is the reading.

This density is also what makes the system resistant to the "robotic output" problem that afflicts template-based generation. With sparse grammar evidence, the engine has few construction options per relation type and outputs become repetitive. With dense evidence — thousands of observed constructions across dozens of registers from centuries of published prose — the candidate space is rich enough that register-appropriate variation emerges naturally from the scoring system without explicit randomization. The LLM's selection among well-weighted candidates produces varied output for the same structural content, because the grammar evidence provides genuine variety to select from.

---

## Part Five: Performance and Scale Characteristics

### Memory Budget

The grammar subtree's memory footprint fits within the existing global arena (AM1) allocation. Construction entities are KBData entries at 48 bytes each. A mature grammar KB might hold 2,000-3,000 construction entities (144 KB). Vocabulary groups and entries are larger — 20,000-30,000 entries at 48 bytes each (1.4 MB). Register markers are negligible (a few hundred entries). Transition patterns number in the thousands (48-96 KB). Relations are the dominant cost: 500,000 TypedRelations at 48 bytes each is 24 MB. The evidence KB can grow large (millions of observation entities) but lazy-loads and is not on the rendering hot path.

Total grammar subtree per language: roughly 30-50 MB resident, with the evidence KB adding potentially hundreds of MB on disk that loads on demand. For eight languages at ship, that's 240-400 MB — fitting within the global arena's headroom above the domain compact allocation.

### Rendering Performance

Construction selection is an L3 operation — typed relation scan, sub-microsecond per PF11. Argument filling is a tree walk per argument (50-200 ns per LK3) plus a vocabulary group scan if applicable. Transition lookup is another L3 relation scan. Register filtering is a constraint check during selection, not a separate pass.

Total rendering cost per causal chain step: roughly 1-3 microseconds at L3 if the candidate set narrows to one, or ~18 additional tokens (~5 ms wall time) at L2 if LLM selection is needed. For a typical causal chain of 3-5 steps, rendering adds 5-15 microseconds at L3 or 15-25 ms at L2. This is dominated by the LLM forward pass if L1 was needed for the structural reasoning — rendering at L3 is effectively free relative to LLM inference time (PF6).

### Ingestion Throughput

The bottleneck is external LLM compaction (IG1), not internal ingestion. Once `.compact` files are produced, the ingestion pipeline processes grammar observations at the same rate as domain knowledge — validation, KB creation, fact assertion, and relation assertion are all integer operations on contiguous arrays. A single Gutenberg text producing 5,000 observations generates roughly 10,000-15,000 TypedRelations (2-3 per observation), which ingest in milliseconds. The 40,000-text English corpus produces roughly 400-600 million relations before deduplication into strength increments, compressing to perhaps 500,000-2,000,000 distinct relations. Total ingestion time for the internal pipeline is minutes; the external compaction takes weeks or months depending on LLM throughput allocation.

---

## Invariants

This system introduces no new invariants beyond those established in the main specification. All grammar entities are VdrId-addressed per IS1-IS6 and SU1-SU8. All relations are TypedRelations per DT11. All arithmetic is Q16 per PR1 and DT1. All memory is arena-allocated per PR4. Rendering follows the inference pipeline (PX1-PX9). Provenance chains are complete per DT7. Unresolved grammar entities are flagged, not dropped, per PR16 and IN39. Poetry mode doesn't affect mechanical correctness per IN40. GEMM cache dirty checks propagate grammar edits per IN46.

The grammar evidence system is a data population strategy for existing architectural components, not a new architectural component. It uses the relation system, the Prolog engine, the grammar engine, the ingestion pipeline, the feedback system, and the rendering pipeline exactly as specified. What it adds is density — observed evidence from 70,000 texts populating the grammar subtree with the connective tissue that makes structural knowledge readable.
