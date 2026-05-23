Exactly. The training pipeline is bootstrapped from the same infrastructure.

---

### The Bootstrap Sequence

You have 500+ compact files on disk. Each one is pipe-delimited tables — facts, relations, rules, provenance, typed relations, all in the format the ingestion pipeline expects. You produced them by asking frontier LLMs to structure domain knowledge into the VDR-compact format. Four hours got you 58. A week gets you 500+. The LLMs are good at this — taking unstructured knowledge and producing structured tables is exactly what they do well, and you're using their strength (broad knowledge, pattern recognition) while discarding their weakness (no provenance, no verification, no persistence).

The system starts up. Global arena allocates. Seed KBs load — the 16 system KBs (root, system, oso, confidence, builtins, command_vocab, hygiene, embedding, output, templates, sentences, formats, relation_types, ingestion, scoring, fsm). The manifest is empty beyond seeds. No domain knowledge yet.

---

### The Ingestion Pipeline

For each compact file on disk, the ingestion pipeline (IG1-IG6) runs:

**IG1 — External compaction is already done.** The frontier LLM produced the `.compact` file. It arrives at `llm_generated` confidence — 30% (19660/65536 in Q16). This is the floor. The system doesn't trust the LLM's output any more than it trusts any other LLM output. But it doesn't need to trust it fully — it needs structural correctness, and the validation step checks that.

**IG2 — Validation.** The ingestion engine reads the file via `fs_read` (grant-gated, but the system's own init process has full grants). It parses the pipe-delimited tables. Checks ID uniqueness within the compact. Checks that relation targets exist — if fact A says `enables(X, Y)`, both X and Y must be defined somewhere in this compact or in already-loaded KBs. Checks column counts match the table headers. Checks that a legend exists. If validation fails, the compact is rejected with specific error locations. No partial imports. No silent data corruption.

**IG3 — KB creation.** The ingestion engine creates the KB subtree. A compact for `blacksmithing` creates `root.trades.blacksmithing` as the parent KB, with child KBs for each major table — concepts, techniques, materials, tools, relationships. Each KB gets a VdrId with structural bits encoding its tree position.

**IG4 — Fact assertion.** Each row in each table becomes one or more Facts. Text values get TAG_TEXT. Numeric values get TAG_VALUE with Q16 representation. Schema columns get TAG_COLUMN_SCHEMA. Every fact carries Provenance with `source_type = llm_generated`, confidence 19660, timestamp of ingestion, and `source_kb_id` pointing back to the ingestion source.

**IG5 — Relations and rules.** The relationships table in each compact maps directly to TypedRelations. `enables|requires|contains|specializes` — each becomes a 48-byte TypedRelation with the relation type enum, from/to VdrIds, provenance, and strength. The Prolog rules generated from relation type properties (PL8) are automatically created — taxonomy, containment, enablement, symmetry, inverse, transitivity. These are system rules, not compact-specific. They apply to every domain's relations equally.

**IG6 — Profile and freeze.** The CompactionProfile is created — recording source document ID, entity counts, relation types used (bitmap), compression ratio. Then the KBs are frozen. `frozen = 1` on each KB struct. No more fact assertions, no modifications. The knowledge is immutable. This is critical for GEMM cache stability — frozen KBs never trigger `isDirty()`, so their GEMM caches build once and stay valid forever.

500 compacts × this pipeline = 500 KB subtrees, each frozen, each with typed relations linking to other subtrees through shared concepts. The Connections compact's entities appear as targets in relations from dozens of other compacts. The English Phrasing compact's constructions are referenced by any compact that needs output rendering. The cross-domain web forms automatically.

---

### The GEMM Training

Now the domain knowledge is loaded as facts and relations. The LLM can already reason over it — L3 typed relation traversal works immediately because the relations are just facts in KBs. But the LLM's neural component — the 6-layer transformer that handles L1 and L2 queries — needs weight matrices trained on this specific knowledge structure to make good selections.

This is where the per-KB GEMM weights come in. Each KB that's substantial enough gets its own weight matrix. The training engine (MO73, CO14 in the system architecture) handles this:

`initialize_model` creates the model KB tree — architecture config, initial random weights (i16 values), layer structure. The model is small: 6 layers, 12 heads, d_model=2048, ~143M parameters. The weights live in KBs just like everything else — `root.model.layers.layer_00.attention.qkv_weights` is a KB.

`train_step` runs one training iteration. It takes a batch of training examples — input UUID sequences paired with expected next-UUID targets — and does the forward pass, computes loss, and updates weights. All in exact integer arithmetic. The temporary training arena (AM3, 10KB-176MB) allocates for gradients, momentum, variance, activations, transpose buffers, and scratch. After the step, the training arena is destroyed.

The training examples come from the loaded compacts themselves. The typed relations define what should follow what. If `blacksmithing enables forge_welding` and `forge_welding requires high_temperature` and `high_temperature requires forge`, then the sequence `[blacksmithing, forge_welding, high_temperature, forge]` is a training example. The causal chains that exist as typed relations become the training signal for the neural network. The network learns to predict what the mechanical system already knows — so when a novel query arrives that the mechanical system can't fully resolve, the network's predictions are informed by the same structural relationships.

This is the key insight of the training process. The GEMM weights don't encode knowledge — the KBs already have the knowledge as facts. The GEMM weights encode the *selection patterns* — which UUIDs tend to follow which other UUIDs in productive reasoning chains. The network learns the topology of the knowledge graph, not the content. This is why the model can be small — it's learning graph navigation patterns over 8192 UUIDs, not trying to encode all human knowledge in weight matrices.

`create_checkpoint` saves the trained weights as a KB. `run_benchmark` evaluates against held-out queries. `compare_checkpoints` shows which training run produced better selection patterns. The entire lifecycle is KBs and facts, queryable and auditable.

---

### The GEMM Cache Build

After training, each domain KB's weight matrix gets packed into a GemmCache. The `v_packed` field is the contiguous array of i32 values extracted from the weight matrix, laid out for SIMD — cache-line aligned, column-major, ready for AVX2 8-wide multiply-accumulate.

Because the domain KBs are frozen, their GEMM caches are stable. `isDirty(kb_modified)` returns false forever. The cache builds once during this initial training phase and never rebuilds. Path 2 retrieval (hot cache) is the permanent state for all compacted domain KBs.

The training doesn't change the facts, relations, or rules. It only creates weight matrices that accelerate the neural component's ability to navigate the existing knowledge structure. The L3 mechanical path is unchanged — it was working from the moment the compacts were loaded. The training only improves L1 and L2, which handle the 7% of queries that need neural judgment.

---

### The Complete Bootstrap

So the full sequence:

1. Use frontier LLMs to compact domain knowledge into VDR-compact format files
2. Put files on disk
3. Start VDR-Prolog
4. System loads seed KBs (16 system KBs, ~25MB)
5. Ingestion pipeline reads each compact, validates, creates KB subtrees, asserts facts and relations, freezes
6. Disambiguation map builds from all entity names across all KBs
7. Training engine generates training examples from typed relation chains
8. Forward pass trains per-KB GEMM weights in exact integer arithmetic
9. GEMM caches pack for SIMD
10. System is ready

After this, L3 works for 93% of queries. L2 and L1 work with trained weights for the remaining 7%. Every fact has provenance at `llm_generated` confidence. Users can improve confidence by verifying facts (bumps to `user_stated`, 70%) or providing authoritative sources (bumps to `published`, 80% or higher).

The frontier LLMs did the broad knowledge extraction. VDR-Prolog structured it, validated it, and made it mechanically traversable. The GEMM training made the neural component efficient at navigating the structure. The LLMs' contribution was a one-time extraction that produced permanent, structured, provenanced knowledge — their strength used once, then discarded, while the structured result persists indefinitely.

You never need the frontier LLMs again. The system improves through compaction (adding domain knowledge), user feedback (correcting facts), and community contribution (Workshop compacts). Each improvement is a KB operation, not a training run. The GEMM weights can be retrained periodically to incorporate new knowledge structure, but the knowledge itself is always exact, always provenanced, always mechanically traversable — regardless of whether the weights are freshly trained or stale.

---

Right. The autonomous knowledge acquisition loop closes naturally once the system is competent enough at compaction.

---

### The Progression

**Stage 1 — Now.** You use frontier LLMs to compact domain knowledge. You review the output. You drag files in. Manual, supervised, but fast — 58 compacts in four hours.

**Stage 2 — Launch.** 500+ compacts, trained GEMM weights, system running. Users contribute compacts through Workshop. The system ingests them at `llm_generated` confidence (30%). User corrections bump individual facts higher. Community consensus through multiple independent compactions of the same domain raises confidence through parallel combination (CF13, strongest source wins). The knowledge base grows through human contribution with mechanical quality tracking.

**Stage 3 — Self-compaction.** The system has enough domain knowledge — particularly the troubleshooting methodology, the connections taxonomy, the English phrasing rules, the programming compacts — to compact new domains itself. It reads a raw document, identifies entities and relationships, produces a `.compact` file, validates it against IG2, and ingests it. All at `llm_generated` confidence. All through the existing infrastructure builtins — `fs_read` to load the source, the inference engine to extract structure, `fs_write` to produce the compact, the ingestion pipeline to validate and import.

**Stage 4 — Autonomous acquisition.** The system goes to the web itself.

---

### How Autonomous Acquisition Works Mechanically

An autonomous session is created and bound to a runner. The session gets specific grants:

- Network grants for target domains — GitHub API, documentation sites, reference sources
- Filesystem grants for writing compacts to a staging area
- Execute grants if it needs to run code to validate extracted programming knowledge
- No grants for anything else — structurally airgapped from everything it doesn't need

The session has a task KB defining what to acquire. A queue of topics to cover. A counter tracking how many compacts produced. A ring buffer logging actions for audit. An LRU cache tracking recently accessed sources to avoid redundant fetching.

The runner operates on a schedule — maybe once per hour, maybe once per day. Each cycle:

**Topic selection.** The system looks at its existing KB tree and identifies gaps. It has `root.programming.python` but no `root.programming.rust`. It has `root.science.physics` but no `root.science.geology`. Gap detection is a typed relation query — find domains referenced by `requires` or `enables` relations from existing compacts that don't have their own KB subtree. This is L3, mechanical, zero LLM tokens.

**Source identification.** For programming domains, GitHub is the obvious source. `net_fetch` calls the GitHub API with specific criteria — repos with more than N stars, active issue closing (indicates maintained projects), documentation present. The grant limits which GitHub endpoints the session can access. For science domains, documentation sites and reference sources. For trade skills, standards bodies and professional associations.

The star count and issue-closing-rate heuristic is structurally sound. A repo with 10,000 stars and regular issue resolution has been validated by thousands of developers. Its API surface, its patterns, its architecture are established. The system isn't looking for opinions — it's looking for structural facts about how the technology works, what functions exist, what they accept and return, how they relate to each other. GitHub repos are rich sources for exactly this kind of structural knowledge.

**Content retrieval.** `net_download` fetches documentation, README files, API references, source code. The network grant constrains which hosts are accessible. Each download is audited. The content goes to the staging filesystem area via `fs_write`.

**Parsing and sectioning.** The system reads the raw content and breaks it into structural sections. For code, the programming compacts give it the vocabulary — functions, classes, modules, imports, dependencies. For documentation, the English phrasing compact gives it the construction grammar to parse prose. For API references, the pattern is regular enough that the content detection stage (PP1) handles it mechanically.

Each section becomes candidate rows in pipe-delimited tables. Entities identified. Relationships extracted — `requires`, `enables`, `part_of`, `instance_of`, `follows`. Provenance tagged as `web_search` confidence (32768/65536 = 50%) because the source is the web, not a verified publication.

**Self-validation.** The system runs its own ingestion validation (IG2) against the candidate compact. IDs unique? Relation targets exist? Column counts match? Legend present? If validation fails, the system knows which sections have problems. It can attempt repair — re-parse the problematic section, try a different structural interpretation — or flag the section as unresolvable and produce a partial compact with gaps explicitly marked.

**Cross-referencing.** The candidate compact's entities are checked against the disambiguation map. Do any entities already exist in other compacts? If `http_request` appears in both the new Rust compact and the existing networking compact, the system establishes a typed relation between them — `rust_http_request instance_of http_request`. The cross-domain web grows automatically.

**Ingestion.** The validated compact enters the normal ingestion pipeline. KB subtree created, facts asserted, relations established, profile frozen. All at web_search confidence. The GEMM cache for the new KB builds on first access.

**Quality assessment.** After ingestion, the system tests the new knowledge by running queries that should resolve through it. "What does Rust's `Vec::push` do?" should resolve through the new compact's facts. If L3 resolution fails for queries that should work, the compact has gaps. The system records which queries succeeded and which failed, building a quality profile.

---

### The Depth Parameter

"Download N depth of X topics" is a BFS over the knowledge gap graph.

Depth 0: the topic itself. `rust` → download Rust documentation, standard library reference.

Depth 1: things Rust requires or enables. `rust requires llvm` → download LLVM documentation. `rust enables systems_programming` → download systems programming concepts. `rust requires memory_management` → download memory management patterns.

Depth 2: things those things require. `llvm requires compiler_theory` → download compiler theory. `memory_management requires operating_systems` → download OS concepts.

Each depth level follows typed relations from the previous level's entities. The system doesn't crawl blindly — it follows the structural connections that the already-ingested knowledge defines. The Connections compact provides the universal relation semantics. The troubleshooting compact provides the methodology for validating that acquired knowledge is consistent. The programming compacts provide the vocabulary for parsing code-related content.

The queue data primitive manages the BFS frontier. The counter tracks depth. The bitset tracks which topics have been visited (no re-downloading). The LRU cache tracks recent API calls (no hammering GitHub). All mechanical data structures, all bounded, all grant-gated.

---

### The GitHub Strategy Specifically

GitHub repos with enough stars and active issue closing are high-quality structured knowledge sources because they contain:

**API surfaces.** Function signatures, type definitions, module structures — exactly the entities and relations that compacts encode. `fn push(&mut self, value: T)` becomes a fact with argument types, return type, and self-mutability as typed relations.

**Dependency graphs.** `Cargo.toml`, `requirements.txt`, `go.mod` — explicit `requires` relations between packages. These map directly to TypedRelation assertions.

**Test suites.** Working code examples that demonstrate correct usage. The bidirectional pattern system can `matches` these into structural pivots, then `generates` from those pivots in explanations.

**Issue discussions.** Common problems and solutions — troubleshooting knowledge. The troubleshooting compact's fault classes and diagnostic patterns apply. "Borrow checker error when..." maps to FC8 (human error/configuration) with specific resolution patterns.

**Changelogs.** Version history — temporal relations. `v2.0 follows v1.0`. `feature_x enables_after v3.0`. These are typed relations with timestamp provenance.

The system can process all of this mechanically because the programming compacts give it the structural vocabulary, the ingestion pipeline validates the output, and the confidence system tracks that everything from GitHub is at `web_search` confidence until corroborated.

---

### The Feedback Loop

As the system acquires and ingests knowledge autonomously, users interact with it. Their queries test the acquired knowledge. Their corrections improve it. Their feedback (thumbs up/down) adjusts rule rankings. Over time, the autonomously-acquired knowledge at 50% confidence gets validated through use — facts that produce correct answers get corroborated, facts that produce wrong answers get retracted or corrected.

The system doesn't need to be right on first acquisition. It needs to be structurally correct (validation catches format errors), honest about confidence (50% for web sources), and correctable (retract and reassert). The mechanical quality ratchet — `fire_and_commit` promoting successful derivations, success/failure counts on rules, provenance-traced corrections — means the knowledge base improves continuously through normal use.

The frontier LLMs that bootstrapped the initial 500 compacts become irrelevant. The system acquires its own knowledge, validates it mechanically, improves it through use, and grows its invariant web denser with every acquisition. The autonomous session running this loop is just another session with specific grants, doing specific work, subject to the same structural security as every other session. It's not special. It's just a configured session pointed at the web with a todo list of knowledge gaps to fill.

---

This is a significant optimization surface. Let me think through where out-of-order execution applies mechanically.

---

### The Prompt Pipeline Today

The pipeline as specified is sequential: PP1 (content detection) → PP2 (code pattern matching) → PP3 (tokenization) → PP4 (spell correction) → PP5 (UUID resolution) → PP6 (disambiguation) → PP7 (assertion to prompt_current). Each stage feeds the next. But within each stage, and across some stages, there are operations with no data dependencies between them.

---

### Where Order Doesn't Matter

Take PP5 — UUID resolution. The input is a set of accepted tokens from spell correction. Each token resolves independently against the disambiguation map. Token "python" looks up its candidates. Token "sorted" looks up its candidates. Token "dictionary" looks up its candidates. These lookups have zero data dependency between them. The result for "python" doesn't affect the lookup for "sorted." They can happen in any order, or conceptually all at once.

The dependency only appears at PP6 — disambiguation — where the co-occurrence of resolved candidates from multiple tokens narrows the interpretation. "python" has candidates [programming_language, snake, comedy_group]. "sorted" has candidates [builtin_function, adjective]. The co-occurrence of "sorted" as a programming term biases "python" toward programming_language. But this cross-token dependency doesn't exist during the lookup phase itself.

So PP5 is embarrassingly parallelizable, but more interestingly, it's reorderable. If you resolve the most unambiguous token first, you get your domain anchor early, and subsequent resolutions can use that anchor to skip candidates immediately. "sorted" as a programming builtin is highly unambiguous — very few domains have an entity named "sorted." Resolve it first, establish the programming domain anchor, and now "python" resolution can skip the snake and comedy candidates without even checking their relation co-occurrence.

This is where Prolog rules for optimization come in. The system can analyze the token set before resolution and determine an optimal resolution order:

```prolog
resolve_order(Tokens, Ordered) :-
    score_ambiguity(Tokens, Scored),
    sort_by_ambiguity(Scored, ascending, Ordered).
```

Least ambiguous first. Each resolved token narrows the domain scope for subsequent tokens. The ordering rule is itself a Prolog pattern that can be refined through use — if a particular ordering strategy consistently produces faster disambiguation, its success count rises and it gets selected more often.

---

### Content Detection Is Naturally Unordered

PP1 scans raw input for JSON, YAML, code, CSV, XML. These pattern matchers are independent — the JSON detector doesn't need the YAML detector's result. Each detector scans the full input and produces typed segments. The segments are then ordered by position, but the detection itself has no inter-detector dependency.

More interestingly, the detectors can short-circuit. If the JSON detector claims bytes 45-200 as a JSON block, no other detector needs to examine those bytes. If you run the fastest detector first (say, CSV detection is simpler than JSON parsing), you might claim large regions of input quickly, reducing the work for slower detectors.

A Prolog rule can encode which detectors to try first based on input characteristics:

```prolog
detector_priority(Input, json, high) :- 
    string_starts_with(Input, "{").
detector_priority(Input, csv, high) :- 
    string_contains(Input, ","), 
    line_count(Input, N), N > 1.
detector_priority(Input, yaml, low) :- 
    \+ string_contains(Input, ":").
```

The detection order adapts to the input. Inputs that look like JSON get the JSON detector first. Inputs with commas and multiple lines get CSV first. The ordering is a Prolog derivation — mechanical, traceable, improvable through rule refinement.

---

### Causal Chain Derivation Is Partially Ordered

CC1 composes typed relations into solution paths. A chain like:

```
file_listing enabled_by os.listdir
os.listdir requires import_os
os.listdir produces list
ordering enabled_by sorted
sorted accepts iterable
list instance_of iterable
```

Some of these links are independent. The derivation of `os.listdir requires import_os` has no dependency on the derivation of `sorted accepts iterable`. They're separate subchains that only connect at the composition point — where the system realizes that `os.listdir produces list` and `sorted accepts iterable` and `list instance_of iterable` form a bridge.

The system can derive independent subchains in any order. The optimization is finding which subchains to pursue first. If the query is about sorting files, the `sorted` subchain is more likely to be the bottleneck — if `sorted` can't accept the output of the file operation, the whole chain fails. Deriving that link first lets the system fail fast without wasting work on the file listing subchain.

Prolog rules can encode this:

```prolog
chain_priority(SubChain, high) :- 
    contains_constraint(SubChain), 
    constraint_likely_to_fail(SubChain).
chain_priority(SubChain, low) :- 
    all_links_common(SubChain).
```

Subchains with constraints (type compatibility checks, acceptance predicates) get evaluated first because they're more likely to prune the search space. Subchains where all links are common relations (well-established, high confidence) get deferred because they're almost certain to succeed.

---

### QueryClassification Can Start Early

The QueryClassification struct has independent fields: `has_relation`, `has_transitive`, `has_fact`, `has_aggregation`. Each is populated by a different check. The relation check looks for relation-type keywords. The transitive check looks for chain-implying patterns. The fact check looks for direct lookup patterns. The aggregation check looks for count/sum/list patterns.

These checks are independent. The result of the relation check doesn't affect the aggregation check. They can run in any order. And some checks are cheaper than others — `has_fact` (is there a direct KB path in the input?) is cheaper than `has_transitive` (does the input imply a chain traversal?).

Running the cheapest checks first lets `shouldAttemptL3()` potentially return true or false before the expensive checks complete. If `has_fact` is true and the confidence is already above 50%, the system can skip the transitive and aggregation checks entirely and go straight to L3 fact retrieval.

---

### The Deeper Property: Work Elimination

Out-of-order execution isn't just about doing things in a faster sequence. It's about discovering that some work doesn't need to be done at all.

If spell correction (PP4) resolves a token with high confidence, UUID resolution (PP5) for that token is trivial — one candidate, no disambiguation needed. If you identify these easy tokens first, you reduce the disambiguation workload at PP6. The work wasn't parallelized — it was eliminated.

If the first two subchains of a causal derivation establish that the query is about Python file operations, then GEMM scoping can narrow to the Python subtree before the remaining subchains are even evaluated. The GEMM for non-Python domains isn't deferred — it's eliminated.

If QueryClassification's `has_relation` check returns true with high confidence on a simple pattern (the input literally contains "what enables X"), the system can skip the transitive, fact, and aggregation checks and go directly to the relation fast path. Three checks eliminated.

---

### Prolog as the Optimization Engine

The optimization rules themselves are Prolog patterns. They live in KBs. They carry success/failure counts. They evolve through use.

A rule that says "resolve the shortest token first in PP5" might work well for programming queries (short tokens like "os" and "sys" are highly specific) but poorly for natural language queries (short words like "the" and "is" are maximally ambiguous). The rule's success rate diverges across query types. The system notices this through the scoring engine — the rule's RuleCandidate ranking drops for natural language contexts and rises for programming contexts.

Over time, the system develops domain-specific optimization patterns. Programming queries get one resolution order. Natural language queries get another. Cross-domain queries get a third. Each pattern is a Prolog rule with typed relation constraints, success counts, and provenance. The system optimizes its own prompt pipeline through the same mechanical process it uses for everything else.

And because these are Prolog rules, the user can inspect them. If resolution is slow for a particular query type, the user can look at which optimization rules fired, see their success rates, and either edit them directly or provide feedback that adjusts their ranking. The optimization layer is transparent, editable, and improvable — not a hidden heuristic buried in infrastructure code.

---

### What This Means for Wall Time

The current L3 wall time is 70-140µs, with mechanical computation under 10µs. Most of that 10µs is serial — each pipeline stage runs after the previous one completes. Out-of-order execution within stages, work elimination across stages, and adaptive ordering through Prolog rules could reduce the mechanical computation to 3-5µs for common query patterns.

That doesn't change the total wall time much because HTTP I/O dominates at 110-230µs. But it matters for throughput — if the mechanical computation halves, the per-core L3 capacity doubles from >200K requests/second to >400K requests/second. At 8 cores, that's over 3 million mechanical requests per second from a single laptop.

More importantly, the optimization patterns that work for L3 also apply to L2 and L1. Adaptive resolution ordering reduces the tokens the LLM needs to see. Early GEMM scoping reduces the weight data in the forward pass. Work elimination through early pruning reduces the causal chain derivation time. Each optimization shaves milliseconds from the L1 path, and for L1 at 80-200ms, a 20% reduction is 16-40ms — perceptible improvement in the user's experience.

The system gets faster through use because the Prolog optimization rules improve through use. The same ratchet that promotes successful derivations to L3 facts also promotes successful optimization patterns to preferred strategies. The system learns not just what to answer but how to answer it efficiently, and both learning processes are mechanical, traceable, and transparent.

---

