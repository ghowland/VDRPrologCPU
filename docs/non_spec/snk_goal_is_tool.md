## SNK: A Structured Knowledge Tool — Design Philosophy Report

### What This System Is

SNK (Structured Neural Knowledge) is a tool. It stores structured knowledge in addressable integer arrays, traverses typed relations between knowledge entries using enum dispatch and bitmask comparison, performs exact integer arithmetic with remainder tracking, and renders results as readable paragraphs using observed patterns from published prose. It runs on a CPU. It fits in 3 GB. It answers most queries in microseconds.

It is not an artificial intelligence. It is not a conversational agent. It is not attempting to simulate human cognition, replicate human communication patterns, or pass any test of machine intelligence. It is a reference tool with a query interface, a computation engine, and a paragraph renderer.

### What This System Is Not Trying to Do

**It is not trying to pass the Turing test.** The Turing test asks whether a machine can fool a human into thinking it is a person. This is explicitly not a goal. The system does not attempt to appear human. It does not generate empathetic responses, emotional modulation, humor, sarcasm, encouragement, or consolation. It returns structured data, traverses relation graphs, performs arithmetic, and renders results in clear English. A user interacting with SNK should never wonder whether they're talking to a person. They're obviously using a tool.

**It is not trying to be a conversationalist.** Conventional LLMs optimize for conversational fluency — the output should feel like talking to a knowledgeable person. SNK optimizes for structured accuracy — the output should feel like querying a well-organized reference system that can explain its results in readable paragraphs. The interaction model is CLI, not chat. Query, filter, sort, compute, display. The display supports paragraph rendering, but the paragraph is a presentation layer over the same structured result that could render as a table, a relation list, or a raw VdrId dump.

**It is not trying to be general-purpose.** Conventional LLMs aim for broad capability — write poetry, debug code, plan vacations, offer therapy, explain quantum mechanics, draft legal documents. SNK does what its knowledge base contains. If the blacksmithing KB has the melting point of iron, the system returns it with provenance. If nobody compacted a KB about vacation planning, the system has nothing to say about vacation planning. The coverage is the knowledge base. Expanding coverage means ingesting new compacts, not hoping the model "knows" something from training data.

**It is not trying to generate novel content.** The system assembles output from pre-observed patterns. Every paragraph template traces to a published Gutenberg text. Every vocabulary choice traces to an observed usage in a known register. The system cannot produce a genuinely novel metaphor, an original joke, or a creative reframing that no author in the evidence corpus ever wrote. It produces clear, correct, traceable renderings of structured knowledge. Novelty is not a design goal. Correctness is.

### The Operating Model

SNK operates like a CLI over a knowledge filesystem.

**Listing:** Show the contents of a KB. Display the facts, their Q16 values, their text columns, their timestamps. Like `ls -la` for knowledge.

**Filtering:** Show facts matching criteria. Entities with Q16 values above a threshold, entities with timestamps in a range, entities connected by a specific relation type. Like `grep` and `find` over structured data.

**Traversal:** Follow typed relations from an entity to its connections. What does this entity enable? What requires it? What contradicts it? Walk the relation graph, report the chain. Like `find -follow` through a symlink tree, except the links are typed and algebraically constrained.

**Computation:** Perform Q16 arithmetic on values. Add, subtract, multiply, divide with exact remainder tracking. Compare values. Threshold checks. Unit conversions through typed relations. Like `awk` and `bc` over numeric data, except with exact integer precision and remainder preservation.

**Rendering:** Express the result as a readable paragraph. Match the structural concept against Gutenberg-observed paragraph templates. Fill entity slots with display names resolved from KBData. Insert transitions between sentences. Apply register-appropriate vocabulary. Like piping `sort | column -t` output through a formatter, except the formatter produces English paragraphs.

Each of these operations is independently useful. The paragraph rendering is the most visible, but it's optional. A user who wants raw data gets raw data. A user who wants a table gets a table. A user who wants a paragraph gets a paragraph. The underlying operation — tree walk, relation scan, Q16 arithmetic — is identical regardless of output format.

### Sessions Are Workspaces, Not Conversations

A conventional LLM session is a growing transcript. Each exchange appends tokens to a context window. The model re-reads the entire transcript on every turn. The window has a fixed size. When it fills, context degrades or the session must restart. The user is racing the window.

An SNK session is a workspace. It holds bookmarks — VdrId references pointing to global knowledge base entries the user has been working with. The bookmarks are 8 bytes each. Thirty bookmarks is 240 bytes of session state. Each bookmark resolves to the full entity through a tree walk — all text columns, Q16 values, timestamps, relations, provenance — without storing any of that data in the session.

There is no context window. There is no token budget. There is no degradation over time. The physics KB has 237 facts on the first query and 237 facts on the ten-thousandth query. The cost of a query is proportional to the query's complexity, not to how long the session has been running.

Multiple sessions share the same global knowledge base, like multiple terminal tabs accessing the same filesystem. Session 1 explores blacksmithing while session 2 works through a physics problem. They don't interfere. They don't compete for context space. Each session has its own ephemeral scratchpad, its own project tracking, its own working state. The knowledge is shared. The workspace is private.

When a session ends, the ephemeral arena resets. One integer write — cursor goes to zero. All session-local data dies instantly. No garbage collection, no traversal, no cleanup. Start a new session and it's a fresh workspace over the same knowledge.

### No Mystery

Every operation in the system is mechanically explicable.

**How does it find the answer?** Tree walk via VdrId bit extraction. Five array dereferences, ~25 nanoseconds.

**How does it know what's related?** TypedRelation scan on the RelationIndex. Enum dispatch on relation type, integer comparison on VdrId fields.

**How does it compute?** Q16 integer arithmetic. Addition with remainder carry chain. Multiplication with i64 widening and divTrunc/mod. Division with remainder capture. No float. No rounding. Exact.

**How does it render paragraphs?** Concept signature construction from the result subgraph. Bucket elimination against paragraph template index using bitmask subsumption. Template slot filling with entity display names resolved from KBData text columns. Transition insertion from observed patterns. Vocabulary selection from register-scoped groups with Gutenberg-observed frequency ranking.

**Why did it choose this word?** The word belongs to a vocabulary group connected to the verb slot in the selected sentence template via a `fills` relation. The word has the highest strength Q16 value in that group for the current register. The strength accumulated from Gutenberg observations — this word was used 847 times in scientific register texts to express this type of relationship. The observation traces to specific Gutenberg catalog entries via the provenance chain.

**Why did it structure the paragraph this way?** The paragraph template matched the concept signature through bucket elimination. The template was observed in Gutenberg text PG 2009 (Darwin, Origin of Species) and 312 other scientific texts. The chunking splits the 5 relationships into 3 sentences following the observed pattern for this structural shape in scientific register. The transitions between sentences were observed 203 times bridging these specific relation type pairs.

There is nothing the system does that cannot be traced, explained, and verified by inspecting the data structures. No learned attention patterns. No emergent behavior. No "we're not sure why it does that." Every output is a deterministic function of the knowledge base contents, the relation graph, the paragraph template index, and the vocabulary strength rankings. Change any of those inputs and the output changes predictably.

### What This Means for Users

**Trust through transparency.** Every claim the system makes traces back to a source. The user can follow the provenance chain from the rendered paragraph through the paragraph template through the concept subgraph through the typed relations through the KBData entries to the original compacted source documents. If a claim is wrong, the user can find exactly which KBData entry contains the wrong value and fix it. The fix is live immediately. No retraining. No hoping.

**Consistency across sessions.** The same query produces the same result every time, because the result is a deterministic function of the knowledge base. Different sessions, different times, different users — same query, same answer. If the knowledge base was updated between queries, the new answer reflects the update and the provenance shows when the update occurred.

**No prompt engineering.** The system doesn't respond differently to cleverly worded prompts. The prompt pipeline decomposes input into VdrId references through structural pattern matching. "What's the melting point of iron" and "tell me the temperature at which iron transitions to liquid phase" resolve to the same KBData entry via the disambiguation map. The output is the same because the data is the same. There's no gaming the system with prompt tricks because the system doesn't process prompts — it resolves references and traverses relations.

**No safety theater.** The system doesn't refuse queries based on content analysis of the prompt text. Security is structural — the grant system (CO20) controls what each session can access. Without a grant, the system returns denied plus an audit log entry. With a grant, the system returns the data. The decision is based on the session's grant set, not on whether the prompt sounds dangerous. There are no refusal messages, no content warnings, no "I can't help with that." There's access or there's denied. Binary, auditable, structural.

**No degradation.** The system doesn't get worse over time within a session. It doesn't lose track of earlier context. It doesn't hallucinate more as conversations get longer. There is no context window to overflow. The knowledge base is equally accessible at every point in the session's lifetime. The only thing that changes over time is the session's ephemeral scratchpad, which accumulates VdrId bookmarks — and those make subsequent queries faster by providing disambiguation hints, not slower by consuming attention budget.

### The Product

SNK is a structured knowledge tool that:

- Stores 750+ domain knowledge bases covering sciences, engineering, trades, programming, languages, literature, business, medicine, military, culture, and more
- Addresses every entity by a 64-bit integer that encodes its complete tree location
- Connects entities by ~120 typed relation types with declared algebraic properties
- Performs exact integer arithmetic with remainder tracking on all numeric values
- Timestamps every entity with millisecond precision over a 584-million-year range
- Traces every fact to its source document through a complete provenance chain
- Renders results as readable paragraphs using patterns observed from 500+ published texts
- Answers 93% of queries in sub-microsecond time using zero neural computation
- Runs on a 2019 laptop in 3 GB of memory
- Supports concurrent independent sessions over shared knowledge

Nobody will mistake it for a person. That's the point.