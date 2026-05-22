# SNK: Structured Neural Knowledge

## What This Document Covers

This document introduces SNK — a new architecture for machine intelligence that differs fundamentally from Large Language Models (LLMs) and other machine learning systems. It assumes no prior knowledge of the VDR-Prolog system that implements SNK. Concepts are introduced incrementally, each building on the last.

## The Problem With Current AI

Modern AI assistants are built on Large Language Models. An LLM is a neural network with billions of parameters trained on trillions of words of text. It encodes everything it knows — facts, reasoning patterns, language rules, domain expertise — into a single massive matrix of floating-point numbers. When you ask it a question, it predicts the most probable next word, then the next, then the next, until it has generated a complete response.

This works surprisingly well. It also has fundamental problems that cannot be fixed by making the model bigger.

**Precision loss.** Every computation uses floating-point arithmetic, which rounds at every step. Across millions of operations per response, these rounding errors accumulate. The model corrects for this by using more layers — some layers exist partly to compensate for drift introduced by earlier layers. This is waste built into the architecture.

**No provenance.** When an LLM states a fact, there is no way to trace where that fact came from, how confident the system is, or whether it was learned from a reliable source or an internet comment. The model cannot distinguish between knowledge and pattern-matched plausible nonsense. This is why LLMs hallucinate — fabrication and retrieval are the same operation internally.

**Context limits.** An LLM holds its working memory in a fixed-size token window. Everything it needs to consider for a response must fit in this window. Exceed it and information is lost. There is no external memory, no persistent state, no ability to set something aside and come back to it.

**Frozen knowledge.** An LLM knows what was in its training data. New information requires retraining — a process costing millions of dollars and weeks of compute time. There is no way to correct a single wrong fact without retraining the entire model.

**No verification.** The model's output cannot be checked against its sources because the sources no longer exist in the running system. They were consumed during training and compressed into weight patterns. You cannot ask the model to show its work because it has no work to show — only statistical patterns.

**Every query costs the same.** Whether you ask "what is 2+2" or "explain quantum chromodynamics," the model runs the same full forward pass through all its layers. Simple factual lookups cost as much as complex reasoning. There is no fast path for easy questions.

These are not bugs. They are consequences of the architecture — encoding all knowledge into one undifferentiated weight matrix and retrieving it through probabilistic token prediction. SNK is designed from the ground up to eliminate these problems structurally, not patch them.

## What SNK Is

SNK — Structured Neural Knowledge — is an architecture where knowledge is stored as structured data, reasoning is performed by mechanical systems, and a small neural network provides judgment and orchestration. The neural component is not the system. It is one component inside a system that includes a knowledge base, a logic engine, a state machine framework, a scoring system, a grammar engine, and a security model.

The key insight: if the data is what makes LLMs effective, then extracting that data from the weights and storing it explicitly — as structured facts with provenance — should work at least as well. And then it should work better, because you eliminate the lossy encoding while preserving what actually matters.

## How Knowledge Is Stored

In an LLM, the fact "Python's os.listdir function lists directory contents" is encoded somewhere across billions of weight parameters, entangled with everything else the model learned, inaccessible to any query except a full forward pass through the entire network.

In SNK, this fact is stored explicitly in a knowledge base:

```
Fact: os.listdir enables directory_listing
Location: root.programming.python.language.stdlib.os
Provenance: Python documentation, published confidence (80%)
Timestamp: when it was ingested
```

The fact has an address — a structural identifier that encodes its location in a hierarchical knowledge tree. It has provenance — where it came from and how confident the system is. It has typed relations connecting it to other facts — `os.listdir requires import_os`, `os.listdir produces list_type`, `list_type instance_of iterable`. These relations have known algebraic properties: `requires` is transitive, `enables` chains forward, `prevents` blocks paths.

Knowledge bases are organized in a tree. `root.programming.python` contains Python knowledge. `root.science.physics` contains physics knowledge. `root.language.japanese.culture` contains Japanese cultural rules. Each node in the tree can hold facts, reasoning rules, typed relations, and neural network weights specific to that domain. A query about Python touches Python's branch of the tree. Physics weights are never loaded. Cooking knowledge is never scanned. The system accesses only what's relevant.

## How Reasoning Works

In an LLM, reasoning is implicit. The model appears to reason because it generates tokens that look like reasoning — but it is actually predicting what reasoning-like text looks like based on training data patterns. It cannot verify its own reasoning chains. It cannot explain why it reached a conclusion beyond generating more plausible-sounding text.

In SNK, reasoning is explicit. The system includes a logic engine (based on Prolog) that traverses typed relations between facts to derive conclusions mechanically:

```
User asks: "How do I list files in order in Python?"

Logic engine derives:
  file_listing enabled_by os.listdir
  os.listdir requires import_os
  os.listdir produces list
  ordering enabled_by sorted
  sorted accepts iterable
  list instance_of iterable
  therefore: import os, call os.listdir, pass result to sorted

Each step: a typed relation lookup. Sub-microsecond. Zero neural computation.
```

This chain is exact, traceable, and verifiable. Every link points to a specific fact in a specific knowledge base with a specific provenance. If the chain is wrong, you can walk it backward and find the incorrect or missing link. If a fact changes, the chain recomputes automatically.

The logic engine handles the majority of queries — approximately 93% at system maturity — without involving the neural network at all. The system classifies incoming queries and routes them to the cheapest mechanism that can handle them:

**Level 3 (zero neural tokens):** The query resolves entirely through typed relation lookups, transitive closures, and rule matching. "What does force enable?" is an integer scan of a relation index. Sub-microsecond. This handles factual lookups, structural queries, and multi-hop reasoning that follows established relations.

**Level 2 (minimal neural tokens):** The logic engine finds multiple valid paths and needs the neural network to choose between them. The network selects from a small candidate set (~18 tokens of neural computation) rather than generating from scratch.

**Level 1 (full neural computation):** No mechanical path exists. The query requires novel judgment, ambiguity resolution, or creative composition. The neural network runs a full forward pass — but even here, it works from pre-resolved context provided by the mechanical systems, not from a blank slate.

## How Arithmetic Works

LLMs use floating-point arithmetic — the IEEE 754 standard that represents numbers as approximations. Every multiplication introduces a tiny rounding error. Chain millions of multiplications together (as neural network inference does) and these errors accumulate. The model's 16+ layers exist partly to compensate for precision drift from earlier layers.

SNK uses exact integer arithmetic. The core numeric type, called Q16, is a triple of integers: a value (v), a first remainder (r0), and a second remainder (r1), with an implicit denominator of 65536 (2^16). When you divide and get a remainder, conventional floating-point silently rounds it away. Q16 captures it explicitly. The remainder is not an error — it is exact unresolved structure that propagates through subsequent operations.

This means: addition has a full carry chain from r1 through r0 into v with zero loss. Multiplication captures cross-term remainders. The softmax function (which produces probability distributions in neural networks) sums to exactly 65536 every time, enforced by a Fixed Remainder Unit that assigns any deficit to the element with the largest truncation loss. No epsilon comparisons. No "close enough." Equal means all three fields match.

The practical consequence: six layers of exact arithmetic carry the information fidelity that would require twelve to sixteen layers of floating-point arithmetic. The neural network in SNK has 143 million parameters and 6 layers. A comparable LLM has over a billion parameters and 16+ layers. The 85% parameter reduction is possible because exact arithmetic doesn't accumulate the drift that deeper networks must correct.

## How the Neural Network Operates

In an LLM, the neural network generates text — predicting the next word from a vocabulary of 32,000 to 128,000 text tokens. Every parameter in every layer is trained to produce probable word sequences. The network IS the system.

In SNK, the neural network predicts the next structural address from a vocabulary of 8,192 identifiers. These identifiers are not words — they are addresses pointing to entities in the knowledge tree. Some are command tokens ("query this knowledge base," "render this template," "assert this fact"). Some are knowledge base addresses ("root.programming.python.library.pathlib"). Some are argument values. Some are template references.

The neural network does not know what it is doing. It does not distinguish between predicting a command that reads a fact and a command that launches a process. They are all integers processed through the same computation. The meaning of the prediction exists entirely outside the network — in the knowledge bases, the execution engine, and the security system.

This is why the network can be small. It doesn't need to encode knowledge (that's in the knowledge bases), perform reasoning (that's the logic engine), manage state (that's the state machines), format output (that's the grammar engine), or enforce security (that's the grant system). It needs only to make judgment calls at branch points: which of two valid approaches is better for this context? Should the system use this library or that one? Is the mechanical answer sufficient or does the response need additional framing?

## How Input Is Processed

When a user types a message, it does not go directly to the neural network. It passes through a mechanical pipeline that transforms raw text into structured knowledge base addresses before the network sees anything.

**Content detection** scans for embedded structured data — JSON, code blocks, YAML, CSV. These are parsed into native numeric and structured representations, not treated as text. A number in JSON becomes an exact integer in the system, not a sequence of digit characters for the network to interpret.

**Spell correction** checks each word against the system's vocabulary, with correction aggressiveness configurable per session. Corrections carry reduced confidence in their provenance. Uncorrectable words are flagged, never silently dropped.

**Knowledge resolution** maps each word to entities in the knowledge tree. "Python" might map to the programming language, the snake, or the Monty Python comedy group. A disambiguation system uses the co-occurrence of other words in the input to filter candidates — "python" alongside "import" and "function" filters to the programming language; alongside "habitat" and "species" filters to the reptile.

**Structured assertion** writes the resolved interpretation into the session's working memory as typed facts — knowledge base addresses, not English words. By the time the neural network receives the input, it is reading a sequence of structural addresses, not natural language. Natural language understanding has already been performed mechanically.

## How Output Is Generated

The neural network predicts a sequence of structural addresses. The system executes each one. A command address triggers a knowledge base operation. A pattern address invokes a code or text template. A template reference triggers the grammar engine to produce formatted output.

For code generation, the system uses bidirectional patterns. Each code pattern (a for-loop, a function definition, an import statement) exists as a structural description that can be traversed in two directions: `matches` (parsing code into structure) and `generates` (producing code from structure). The neural network selects which patterns to compose. The grammar engine renders them into syntactically correct code with proper indentation, variable names, and formatting — all determined by the structural description, not generated character by character.

For natural language output, the grammar engine uses templates with typed slots, drawing from vocabulary knowledge bases that encode word frequency, etymology, register appropriateness, and semantic field membership. The neural network selects which template and which words from a curated candidate set. The grammar engine ensures syntactic correctness, proper agreement, and appropriate register.

The result: a 30-identifier sequence from the neural network produces a complete, syntactically correct, structurally verified Python script in about 160 milliseconds. A comparable LLM generates 300-400 text tokens in 10-20 seconds, with no structural verification and no guarantee of syntactic correctness.

## How Memory Works

An LLM's memory is its context window — a fixed-size buffer of recent tokens. Everything the model needs to consider must fit in this window. Cross-turn memory is simulated by restating context in text, consuming the same limited budget. There is no external memory, no persistent state, no ability to store something and retrieve it later by address.

SNK has actual software data structures:

**Knowledge bases** persist across turns, sessions, and system restarts. A fact asserted in the first interaction is addressable in the ten-thousandth.

**Counters** are exact integers that increment and decrement mechanically. The system tracks how many items it has processed, how many queries resolved at each level, how many times each rule fired — not through text tokens but through integer fields on data structures.

**Queues** are real FIFO buffers for processing sequences of items, not simulated through token generation.

**State machines** track session state, conversation phase, task progress, and domain-specific workflows through defined states and mechanical transitions, not through the network restating "we are currently in step 3 of 5."

**LRU caches** manage session memory mechanically, evicting the least recently accessed data when space is needed, not through attention decay over token distance.

Cross-turn context is stored as structural addresses — four 8-byte values encoding what the user wants, which tools apply, and how they connect. This is 32 bytes replacing thousands of context window tokens in an LLM.

## How Security Works

An LLM's security is behavioral — you instruct the model not to do dangerous things and hope it complies. Jailbreaks work because the security is in the prompt, not in the architecture. The model has access to everything in its weights at all times for all users.

SNK's security is structural. The system has a grant mechanism — capability tokens that authorize specific operations. A session without a "network" grant cannot make network calls regardless of what the neural network predicts. A session without a "filesystem" grant cannot read or write files. The grant check happens before execution, not after generation. The neural network can predict the address for "launch a process" with maximum confidence — without the corresponding grant, the execution engine rejects it and the audit system logs the attempt.

Knowledge access is also grant-gated. Knowledge bases live in a hierarchical tree with organization and client scoping. A user in one organization cannot see another organization's knowledge — not because the system filters the output, but because those knowledge bases are never loaded into the computation path. A user without finance department access has no finance weights in their forward pass. The data doesn't exist in their session's address space.

Every security-relevant action — fact assertion, rule firing, grant check, session creation, operation execution, access denial — is recorded in an audit log with timestamp, session identifier, and result. The audit trail is structural, not reconstructed from conversation text.

## How Errors Work

An LLM hallucinates because fabrication and retrieval are the same operation — predicting probable token sequences. There is no signal in the output distinguishing "I retrieved this fact from training data" from "I generated this plausible-sounding claim from statistical patterns." Confidence is unrelated to accuracy.

SNK cannot hallucinate in the mechanical path. The logic engine can only return facts that exist in knowledge bases with provenance and confidence scores. If a fact isn't there, the query returns nothing — it doesn't generate a substitute.

The neural network can make errors — selecting the wrong address when multiple candidates are similarly scored. But every possible output is a valid address pointing to a real entity in the knowledge tree. The system cannot reference something that doesn't exist. The error mode is "chose a real but suboptimal entity" not "invented a convincing fiction."

Low-confidence selections are detectable. When the probability distribution is flat (many candidates scored similarly), the system can compare the neural selection against the mechanical derivation, verify that the selected entity has coherent typed relations to the surrounding context, or present the ambiguity to the user rather than guessing.

When the system encounters input it cannot resolve — a word that maps to no entity in the knowledge tree — it reports the gap explicitly. It does not fabricate a meaning. It does not skip the unresolved element silently. It delivers what it can resolve and tells the user what it cannot, requesting clarification.

## How the System Improves

An LLM improves through retraining — feeding more data through gradient descent to update billions of parameters over weeks of GPU computation. Improving one capability may degrade another (catastrophic forgetting). Correcting a single wrong fact requires retraining the entire model.

SNK improves by adding facts. A missing piece of knowledge is a missing entry in a knowledge base. Adding it is one operation — assert the fact with its provenance and confidence. The fact is immediately available to every future query. No retraining. No risk of degrading other capabilities. The improvement is targeted, verifiable, and instant.

Users contribute directly. The system provides thumbs-up and thumbs-down feedback on every output element. Thumbs-down pushes the producing pattern into a review queue. The user (or an automated review process) can inspect the pattern, trace its provenance chain, and fix it (edit the source fact), delete it (the system falls back to alternatives), or let it naturally deprioritize (success/failure counts lower its ranking relative to better patterns).

Direct editing through the user interface allows clicking on any output element, viewing the provenance chain that produced it, navigating to the source fact, and editing it in place. The correction is live immediately — no recompilation, no retraining, no waiting for the next model version. A typo in an import path that would persist in an LLM's weights until the next billion-dollar training run is fixed in two seconds.

The knowledge base is also extensible through compacted data files. A domain expert compacts their knowledge into a structured format — pipe-delimited tables of facts, relations, and rules with explicit provenance. The system ingests it into the knowledge tree, and the domain becomes available. Five hundred such compacts ship with the system, covering civilization-scale breadth: every major science, programming language, trade skill, language, and domain of practical knowledge. Users create and share additional compacts through a mod store.

## How It Runs

SNK runs on a single CPU. No GPU required. The implementation is approximately 28,000 lines of Zig (a systems programming language) targeting x86_64 with AVX2 SIMD instructions. It runs on a commodity laptop.

All memory is allocated at startup into fixed arenas — contiguous blocks of memory with bump-pointer allocation. There is no dynamic memory allocation during operation, no garbage collection, no allocation latency spikes. Session termination is resetting an integer (the arena cursor) to zero — all session data vanishes instantly with no traversal.

Eight CPU cores support eight concurrent sessions at approximately 190 tokens per second each. But because 93% of queries resolve mechanically without the neural network, effective throughput is much higher — over 200,000 requests per second per core for mechanical queries. A single laptop can serve thousands of users if most queries resolve through the knowledge base rather than neural inference.

Sessions can operate autonomously. A configured session — with knowledge bases populated, rules defined, state machines set up, and grants assigned — can be snapshotted and bound to a network port. It then handles incoming requests (HTTP, SMTP, or any protocol the grammar engine can parse and generate) without human interaction. The system is not a chatbot. It is a runtime for building and deploying structured knowledge applications.

## Summary

| Aspect | LLM | SNK |
|---|---|---|
| Knowledge storage | Encoded in billions of weight parameters | Stored as structured facts with provenance |
| Reasoning | Implicit in token prediction | Explicit logic engine with typed relations |
| Arithmetic | Floating-point with cumulative rounding | Exact integer with remainder capture |
| Model size | Billions of parameters | 143 million parameters |
| Query cost | Full forward pass for every query | 93% resolve mechanically at near-zero cost |
| Memory | Fixed context window, no persistence | Persistent knowledge bases, real data structures |
| Security | Behavioral (prompt-based) | Structural (grant-gated, audited) |
| Error mode | Fabrication indistinguishable from retrieval | Wrong real entity, detectable and recoverable |
| Improvement | Retrain entire model (weeks, millions of dollars) | Add a fact (microseconds, free) |
| Hardware | GPU required | CPU only, commodity laptop |
| Traceability | None | Full provenance chain on every fact |
| Output verification | Impossible | Every output traces to source facts |

SNK is not a larger or smaller LLM. It is a different kind of system — one where the neural network is the smallest component, not the defining one. The knowledge is structured. The reasoning is mechanical. The neural network dispatches. The name reflects the architecture: Structured first. Neural second. Knowledge throughout.
