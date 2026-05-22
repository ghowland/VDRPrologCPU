Right. The LLM doesn't know what it's doing. It doesn't know the difference between generating a greeting and launching a docker container. It's predicting the next UUID from the previous UUIDs, and the mechanical systems execute whatever that UUID points to.

## The Indifference Principle

The forward pass sees a sequence of i64 values. Some are command tokens. Some are KB addresses. Some are argument values. The embedding layer maps each to a learned vector. The attention layers predict which i64 comes next. The output layer selects from the 8,192 vocabulary.

The LLM doesn't distinguish:

- "emit the UUID for `kb_query`" (reads some facts)
- "emit the UUID for `op_execute`" (launches a process)
- "emit the UUID for `grammar_render`" (formats text)
- "emit the UUID for the greeting template" (says hello)

They're all i64s. The GEMM doesn't care. The softmax doesn't care. The token sampling doesn't care.

The **grant system** cares. The UUID for `op_execute` passes through the grant engine before execution. No execute grant, no execution. The LLM can predict that UUID all day — without the grant, the builtin returns `grant_denied` and the audit log records the attempt.

This is why the security model is structural, not behavioral. You don't tell the LLM "don't launch containers." You don't grant the session `execute` class. The LLM literally cannot tell the difference — it's just predicting the next UUID in the sequence. The system around it enforces what those UUIDs are allowed to do.

## The Hot Path

The most frequently predicted UUIDs — command tokens, common KB addresses, high-use builtins — live in the global hot cache and the GEMM caches of the early KBs (root.system.command_vocab, root.system.builtins). These are the tokens the model predicts most often, so their embeddings are the most trained, their GEMM rows are the most cached, and their structural UUID prefixes are the most recognized by the pre-resolution pipeline.

A rare UUID — line 35 of mpmath's `libmp.py` — lives deep in the tree, accessed infrequently, its GEMM cache cold. But when the query context makes it relevant, the structural UUID navigates there in four array accesses, the per-KB UUID map finds the slot, and the fact is retrieved. The LLM didn't need to "know" about that specific line — the causal chain derivation found it mechanically and presented it as the next relevant UUID in the sequence.

The kernel just does GEMM, picks the winning UUID, and the system executes it. The UUID might say "respond with a polite greeting." It might say "start a docker container." Same computation, same cost, same mechanism. The meaning lives in the KB tree and the grant system, not in the neural network.

---

Exactly. The scratchpad isn't text. It's a sequence of VdrIds — structural addresses into the KB tree.

When the LLM "takes notes" across turns, it's asserting facts into `session_root._llm.scratchpad`. Each fact is a Fact struct — 48 bytes, tag-dispatched, Q16-valued, provenanced. The "note" isn't "user wants to list files in python using pathlib." It's:

```
fact(tag=.reference, value=VdrId(user_goal_entity))
fact(tag=.reference, value=VdrId(pathlib.Path.iterdir))
fact(tag=.reference, value=VdrId(sorted_builtin))
fact(tag=.relation,  value=VdrId(enables_relation_between_them))
```

Four VdrIds. 32 bytes of payload. The entire context of what the user wants, which tools apply, and how they connect — encoded as structural addresses that the Prolog engine can query against on the next cycle.

On the next turn, the LLM doesn't re-read a paragraph of text notes. It reads four i64 values from the scratchpad KB, each of which decodes to a location in the tree. The pre-resolution pipeline can follow those addresses, check if anything changed (new facts asserted, relations updated), and present the current state to the LLM before it runs.

A CLLM's scratchpad is tokens of English text consuming context window budget. VDR-Prolog's scratchpad is pointers into a live knowledge graph consuming 48 bytes per entry. The pointers are queryable, composable, and mechanically traversable. The text is just text.

---

Right. The prompt_input pipeline is: raw text → tokens → spell correction → UUID resolution → structured facts. By the time the LLM sees the input, it's not reading English. It's reading a sequence of VdrIds that encode what the user said as references into the knowledge graph.

## The Pipeline

**Stage 1: Tokenize.** Split input text on whitespace and punctuation. Each token is a candidate for atom table lookup. "list files in order using python" becomes six candidate atoms.

**Stage 2: Spell correction.** Each candidate checks against the atom table. If "pyhton" doesn't match but edit distance 1 yields "python" which does match, consider correcting. But context matters:

- Inside quotes → leave it alone, it might be intentional
- Matches a known atom at distance 1 with no other close matches → correct
- Ambiguous (distance 1 from two different atoms) → leave it, flag uncertainty
- Unknown word with no close match → leave it as a text term, don't force a bad match

The correction confidence feeds into the fact's provenance. A corrected token gets `user_stated` confidence (70%) minus a penalty for the correction. An uncorrected exact match gets full `user_stated`.

**Stage 3: UUID resolution.** Each accepted token resolves against the KB tree. "python" matches the atom for `root.programming.python` — that's a VdrId. "list" matches multiple atoms — the verb concept in the English grammar KB, the Python `list` type, the abstract concept of enumeration. "files" matches filesystem concepts. "order" matches sorting concepts.

This is where the availability surface matters. The system doesn't blindly resolve every possible match. It checks which KBs are accessible to this session, which relation types are populated, which domains have content. "list" in a session with programming grants resolves toward the code domain. "list" in a session scoped to cooking resolves toward ingredient enumeration.

**Stage 4: Disambiguate and compose.** Multiple resolution candidates per token get scored. "list" + "files" together strongly activate the filesystem domain. "order" in the presence of "list" + "files" activates sorting, not purchasing or commanding. The co-occurrence patterns don't need neural inference — they're typed relation checks. Does `list_files` have an `enables` relation to any entity that `ordering` also relates to? If yes, the filesystem+sorting interpretation wins.

**Stage 5: Assert to prompt_current.** The resolved interpretation becomes facts:

```
fact(tag=.reference, value=VdrId(list_files_concept))
fact(tag=.reference, value=VdrId(filesystem_directory))
fact(tag=.reference, value=VdrId(python_language))
fact(tag=.reference, value=VdrId(sorting_ordered))
fact(tag=.text, value="list files in order using python")  // original preserved
```

The original text is preserved as a text fact — the LLM can read it if the structured interpretation is insufficient. But the structured facts are what the pre-resolution pipeline, the Prolog engine, and the UAI scoring operate on. They never see the English. They see UUIDs.

## What This Eliminates

The LLM in a CLLM spends significant capacity on natural language understanding — parsing syntax, resolving ambiguity, identifying intent, mapping words to concepts. That's a large fraction of what layers 1-4 do in a conventional transformer.

VDR-Prolog's input pipeline does this mechanically *before* the LLM runs. By the time the forward pass executes, the input isn't "list files in order using python" — it's four VdrIds pointing to resolved concepts in the knowledge graph. The LLM's job starts at "given these resolved concepts with these typed relations between them, what's the right action sequence?"

That's why 6 layers suffice. The LLM isn't doing NLU. The input pipeline already did it — through atom table lookup, availability surface checking, co-occurrence relation scoring, and disambiguation via typed relation queries. All at L3. All in microseconds. All exact.

---

This is a fundamental design philosophy difference. The system is honest about what it doesn't know.

## The CLLM Failure Mode

A CLLM given "garbaorceuhoerlcheu" will do one of three things, all bad:

- Hallucinate a meaning and proceed confidently
- Ignore it silently and generate the script without it
- Guess it's a misspelling of something and substitute without telling you

All three produce output that doesn't match the spec. The user doesn't know their intent was lost. The error is silent.

## The VDR-Prolog Approach

The input pipeline processes each token. "make", "script", "simulate", "2d", "character", "jumping", "height", "time", "print" — all resolve to VdrIds. The causal chain builds normally for these.

"garbaorceuhoerlcheu" hits the atom table. No match. Edit distance check against all known atoms — nothing within reasonable distance. Spell correction at any confidence setting produces no candidate. The token stays as a raw text term with no VdrId resolution.

The pipeline now has a structured interpretation with a hole:

```
fact(tag=.reference, value=VdrId(script_generation))
fact(tag=.reference, value=VdrId(simulation_2d))
fact(tag=.reference, value=VdrId(character_jumping))
fact(tag=.reference, value=VdrId(height_over_time))
fact(tag=.reference, value=VdrId(print_builtin))
fact(tag=.text, value="garbaorceuhoerlcheu", resolved=false)
```

The causal chain derivation runs. It builds a complete solution for the simulation part. But when it tries to incorporate the unresolved token, there's no relation to follow. No `enables`, no `requires`, no `part_of`. It's a dead end in the knowledge graph.

The system doesn't skip it. The unresolved token is part of the user's spec. The spec is incomplete from the system's perspective. The honest response is to say so.

## The Confidence Tuning

The client session property controls the threshold for spell correction, but it also implicitly controls how aggressively the system tries to resolve ambiguous tokens. At high confidence settings, the system resolves only exact matches and clear corrections. At lower settings, it might attempt fuzzy matching against domain vocabularies.

But no setting causes the system to fabricate a resolution. The options are:

- **Resolved with high confidence:** exact atom match, proceed
- **Resolved with correction:** clear misspelling, note the correction in provenance
- **Ambiguous:** multiple candidates, present options to user or pick best with flagged uncertainty
- **Unresolved:** no match, no close match, report the gap

The fourth case is not a failure. It's correct behavior. The system's integrity depends on never pretending to understand something it doesn't.

## Partial Completion

The system can do both — deliver what it can and report what it can't. The response contains the working simulation script *plus* the explicit gap:

```
prompt_current.completed_chain:
  step(1, import, "none needed", confidence=100%)
  step(2, define, "jump simulation with gravity", confidence=80%)
  step(3, loop, "print height over time", confidence=80%)
  
prompt_current.unresolved:
  token("garbaorceuhoerlcheu", position=last, resolution=none)
  
prompt_current.recommendation:
  action(request_clarification, target=user, reason=unknown_token)
```

The LLM frames this honestly. Here's your simulation script. It works. But your spec included something I couldn't resolve. Please clarify or remove it.

This is what provenance buys you. Every fact in the output traces back to a source. The absence of provenance for "garbaorceuhoerlcheu" is itself information — it means the system has no basis for acting on it. A CLLM can't distinguish "I know this" from "I'm guessing" because everything comes from the same opaque weight matrix. VDR-Prolog can, because knowledge has provenance and absence of knowledge is detectable.

---

Right. The failure mode is completely different.

In a CLLM, low token probability means the softmax distribution is flat — many tokens have similar small probabilities. Float rounding noise can push any of them above the others. The "winner" is essentially random at the precision boundary. You get a hallucinated word, a wrong JSON bracket, a subtly incorrect function name. The error looks confident because it's presented the same way as everything else.

In VDR-Prolog, low token probability means the softmax distribution across 8,192 UUIDs is flat. But the output isn't a character or a word — it's a structural address. And every possible output is a valid UUID pointing to a real entity in the KB tree.

The system can't hallucinate a function that doesn't exist because there's no UUID for a nonexistent function. It can't emit a malformed JSON bracket because JSON brackets aren't in the vocabulary — grammar templates handle formatting. It can't generate a plausible-sounding but wrong API call because every API call in the vocabulary is a reference to a real, provenanced fact.

What it *can* do is pick the wrong UUID. Low confidence in the distribution means the system might select `os.listdir` when it should have selected `pathlib.Path.iterdir`. But both are real functions. Both exist. Both work. The error is a suboptimal choice, not a fabrication.

And the system knows when this is happening. The softmax sums to D=65536 exactly. When the winning token's score is barely above the alternatives — say 890 out of 65536 versus 870 for second place — that's a detectable low-confidence selection. The system can:

- Check whether the selected UUID has typed relations that connect coherently to the preceding UUIDs in the sequence
- Compare the top-N candidates against the causal chain from pre-resolution
- If no candidate connects well, defer to the mechanical systems entirely rather than trusting the neural selection
- If multiple candidates connect equally well, present the ambiguity rather than picking arbitrarily

The error floor is "picked a real but suboptimal entity from the knowledge graph." Not "invented something that doesn't exist and presented it with full confidence." That's a fundamentally different failure mode — one that's detectable, recoverable, and bounded by the contents of the KB tree rather than the unbounded space of possible token sequences.

---

This is where the architecture shows something no CLLM can do. The translation isn't text-to-text. It's structure-to-structure with cultural rules applied mechanically.

## The Decomposition

"I want the key" enters the input pipeline. It resolves to UUIDs:

```
fact(tag=.reference, value=VdrId(speaker_self))
fact(tag=.reference, value=VdrId(desire_action))
fact(tag=.reference, value=VdrId(key_object))
```

But the system doesn't stop at word-level references. The English grammar compact and phrasing compact decompose the sentence structurally:

```
sentence_pattern: SVO (SP2)
subject: first_person_pronoun (WC5/SC23)
verb: want (desire/volition - SF7)
object: definite_noun (the + count_noun - SC3, SC36)
speech_act: request or statement_of_desire (SA3 or SA1)
```

This is language-independent semantic structure. The meaning isn't "these four English words in this order." It's "a speaker expresses desire for a specific known object." That structure is UUIDs in the KB.

## The Cultural Layer

The session has context about the participants. These are facts in session KBs:

```
fact: speaker instance_of student
fact: speaker age 16
fact: listener instance_of teacher  
fact: listener age 45
fact: setting instance_of school
```

Now Prolog rules from a Japanese culture compact fire:

```prolog
% Age and role determine social hierarchy
senpai_kohai(Listener, Speaker) :-
    role_rank(Listener, ListenerRank),
    role_rank(Speaker, SpeakerRank),
    ListenerRank > SpeakerRank.

% Teacher always outranks student
role_rank(Person, 3) :- instance_of(Person, teacher).
role_rank(Person, 1) :- instance_of(Person, student).

% Social hierarchy determines honorific level
honorific_level(Speaker, Listener, teineigo) :-
    senpai_kohai(Listener, Speaker).

% Specific verb forms for politeness levels
verb_form(desire, teineigo, "いただきたいのですが").
verb_form(desire, sonkeigo, "お望みでしょうか").
verb_form(desire, casual, "ほしい").
```

All L3. Typed relation lookups and rule firing. Zero LLM tokens. The system mechanically determined that a 16-year-old student speaking to a 45-year-old teacher requires teineigo (polite form), and selected the appropriate verb conjugation.

## The Grammar Fitting

Japanese grammar templates in the KB handle the structural transformation. English SVO becomes Japanese SOV:

```
english_pattern: Subject Verb Object
japanese_pattern: Subject Object Particle Verb Copula

slot: subject → 私 (watashi, appropriate for teineigo)
slot: object → 鍵 (kagi, from bilingual relation: key equivalent_to kagi)
slot: particle → を (wo, object marker)
slot: verb → いただきたいのですが (itadakitai no desu ga, polite desire + softener)
```

The grammar engine renders: 鍵をいただきたいのですが

The slot selection is entirely mechanical. The bilingual link `key equivalent_to kagi` is a typed relation in the KB. The particle selection is a Prolog rule: object role requires を. The verb form was selected by the honorific rules. The subject is dropped because Japanese grammar rules (also in the KB) say first-person subject is typically omitted in polite speech.

## What the LLM Does

Almost nothing. Maybe 10-15 tokens of judgment:

- Is the softened request form appropriate here, or is this an urgent demand? (Context from conversation FSM state)
- Should 鍵 be preceded by その (that specific key) based on discourse context? (Checking prompt_last for prior reference)
- Is there a more natural phrasing the mechanical output missed?

The LLM's role is polish and judgment on an already-complete mechanical translation. It's not translating — the KB relations and Prolog rules did that. It's checking whether the mechanical output sounds natural.

## Why CLLMs Fail at This

A CLLM translating "I want the key" to Japanese has to simultaneously:

- Parse English syntax from weight patterns
- Map word meanings across languages from weight patterns
- Determine social context from the conversation history in its context window
- Select the right honorific level from training data patterns
- Apply Japanese grammar reordering from learned patterns
- Choose the right verb conjugation from statistical frequency
- Decide whether to drop the subject from pattern matching

Every one of these steps is implicit, opaque, and probabilistic. If the training data had more casual Japanese than polite Japanese, the model defaults casual even when politeness is required. If it saw "want" translated as ほしい more often than いただきたい, it picks the casual form. It has no concept of "this speaker is a student talking to a teacher therefore teineigo is required" — it can only pattern-match against similar scenarios it saw in training.

VDR-Prolog does each step explicitly. The social hierarchy is computed from facts. The honorific level is derived by rule. The verb form is selected by the honorific level. The grammar reordering follows a template. Every step is traceable, every choice is provenanced, and if the honorific is wrong, you fix the rule — not retrain a billion-parameter model.

## The Scaling Property

Add Korean. The semantic structure is the same UUIDs — speaker, desire, object. Korean has its own honorific system (존댓말/반말), its own grammar templates (also SOV), its own particle system, its own cultural rules. New language compacts, new grammar templates, new cultural rules in the KB. The English decomposition is unchanged. The semantic UUIDs are unchanged. The cultural reasoning runs the same Prolog engine with different rules.

A CLLM needs to be trained on English-Korean parallel corpora. VDR-Prolog needs a Korean language compact ingested into the KB tree. One is a billion-dollar training run. The other is a compaction job.

---

Exactly. The cultural rules encode pragmatics, not just grammar.

## The Asymmetry Is Structural

A student asking a teacher for the key:

```prolog
% Student → Teacher: high social distance, lower status speaker
speech_act_realization(request, Speaker, Listener, Form) :-
    senpai_kohai(Listener, Speaker),
    honorific_level(Speaker, Listener, teineigo),
    Form = [
        hesitation_marker("ちょっと"),    % chotto - softener
        pause(beat),                       % pragmatic pause
        attention_request("すみません"),   % sumimasen - excuse me
        object_reference,                  % the actual request
        desire_verb(teineigo),            % polite verb form
        sentence_final_softener("が")     % trailing ga - leaves request open
    ].
```

A teacher asking a student for the key:

```prolog
% Teacher → Student: authority, higher status speaker
speech_act_realization(request, Speaker, Listener, Form) :-
    senpai_kohai(Speaker, Listener),
    Form = [
        object_reference                   % just the noun
    ].
    % No softener, no hesitation, no polite verb
    % Authority implies the request
    % "鍵" alone means "give me the key"
```

Same semantic input: `desire(speaker, key)`. Completely different output based on who's speaking to whom. And the rule generalizes — swap `key` for `homework` or `book` and the same pragmatic rules fire. The teacher still says one noun. The student still hedges with ちょっと and すみません and trailing が.

## The Gesture Layer

The `pause(beat)` and potential gesture annotations are facts in the output chain too. If this system is driving a game character, an animated avatar, or a dialogue system with stage directions, the cultural compact can include:

```prolog
% Physical behavior accompanying high-distance requests
accompanying_gesture(request, Speaker, Listener, Gestures) :-
    senpai_kohai(Listener, Speaker),
    Gestures = [
        slight_bow(before_speech),
        eye_contact(avoid_direct),
        hand_position(clasped_or_side)
    ].

% Teacher requesting from student: minimal ceremony
accompanying_gesture(request, Speaker, Listener, Gestures) :-
    senpai_kohai(Speaker, Listener),
    Gestures = [
        eye_contact(direct),
        hand_position(open_palm_up)       % "hand it over" gesture
    ].
```

These aren't ornamental. They're typed relations in the KB, queryable by the rendering system, applicable whether the output is text, animation data, or stage directions for a visual novel. The gesture facts have provenance from the Japanese culture compact, confidence at `published` (80%) if sourced from anthropological literature, and they compose with the speech act facts through `accompanies` relations.

## What a CLLM Does Here

A CLLM might occasionally produce "ちょっと..." before a polite request because it saw that pattern in training data. But it doesn't know *why*. It can't reliably produce it for student-to-teacher and reliably omit it for teacher-to-student, because the social hierarchy computation isn't explicit — it's a statistical tendency in the training corpus. Change the scenario slightly (coworker to senior manager in a company instead of student to teacher) and the CLLM may or may not transfer the pattern, depending on how much corporate Japanese dialogue was in its training data.

VDR-Prolog transfers it mechanically. The rule fires on `senpai_kohai(Listener, Speaker)`. That relation holds for student→teacher, junior_employee→senior_manager, younger_sibling→older_sibling, new_member→club_president. The cultural behavior is derived from the social hierarchy relation, not from seeing each specific scenario in training data. One rule covers all of them because the abstraction is explicit.

## The KB Structure

```
root.language.japanese
├── grammar (particles, conjugation, sentence patterns)
├── vocabulary (word entries with readings, pitch accent)
├── pragmatics
│   ├── honorific_system (teineigo, sonkeigo, kenjougo, casual)
│   ├── speech_acts (request, refusal, greeting, apology)
│   ├── hesitation_markers (chotto, ano, eto)
│   ├── sentence_final_particles (ne, yo, ga, kedo)
│   └── gendered_speech (wa, kashira, zo, ze)
├── culture
│   ├── social_hierarchy (senpai/kohai, uchi/soto, tate_shakai)
│   ├── gesture (bowing depth, eye contact, personal space)
│   └── context_rules (setting-dependent behavior)
└── bilingual
    ├── english_japanese (equivalent_to relations)
    └── mapping_rules (SVO→SOV, pronoun dropping, topic marking)
```

Every node is a KB with facts, rules, and typed relations. The pragmatics rules reference the culture rules which reference the social hierarchy which references the session's participant facts. The chain is: session context → social computation → honorific selection → speech act realization → grammar fitting → output. All mechanical. All provenanced. All fixable by editing a rule, not retraining a model.

And if someone tells you "actually, a junior employee wouldn't use ちょっと with their direct manager, they'd use あの instead" — you update one fact in the hesitation_markers KB, scoped to the corporate context. Next query picks it up. No retraining. No hoping the correction propagates through weight updates. The fact changed, the rule reads the new fact, the output changes.

---

Right. The LLM becomes a style selector over mechanically-generated candidate sets.

## The Mechanism

The translation pipeline produces the structural output — subject, verb, object, particles, honorifics, all resolved to specific UUIDs. But for content words, instead of emitting one UUID, the system emits a word group: the canonical choice plus thesaurus expansions.

```
canonical: 鍵 (kagi - key)
degree_1: [キー (kii - loanword), 手がかり (tegakari - clue/key metaphorical)]
degree_2: [解決策 (kaiketsusaku - solution, from tegakari's synonyms)]

canonical: いただきたい (itadakitai - would like to receive)
degree_1: [頂戴したい (choudai shitai - want to receive, slightly different register),
           お借りしたい (okari shitai - would like to borrow)]
degree_2: [拝借したい (haishaku shitai - humbly borrow, from okari's formal synonyms)]
```

Each alternative is a real UUID pointing to a real entry in the vocabulary KB. Each has typed relations encoding its register, formality, connotation, frequency, and domain. The thesaurus expansion is itself a typed relation query — `synonym_of`, `similar_to`, `register_variant_of` — running at L3, producing a bounded candidate set.

The LLM gets this as a small GEMM problem. Not "pick the next token from 8,192 possibilities" but "pick the best word from 4-8 candidates, given the surrounding context UUIDs." A tiny attention pass over a tiny candidate set. The LLM's strength — contextual judgment about what sounds right — applied to a curated shortlist instead of an open vocabulary.

## The Two-Degree Boundary

First degree: direct synonyms and register variants of the canonical word. These are safe substitutions — the meaning is preserved, only flavor changes.

Second degree: synonyms of synonyms, still checked for relevance to the original concept. `kagi → tegakari → kaiketsusaku` works if the context is about solving a puzzle. It doesn't work if the context is literally unlocking a door. The relevance check is a typed relation query — does the second-degree candidate still have an `enables` or `equivalent_to` path back to the original concept? If the path breaks, the candidate is excluded.

This boundary prevents drift. Third-degree synonyms would be synonyms of synonyms of synonyms, and by that point you've wandered from "key" to "answer" to "response" to "reaction" — semantically unmoored. Two degrees is the useful range where flavor varies but meaning holds.

## The KB Structure

This is just normal KB work. The thesaurus data lives in:

```
root.language.japanese.vocabulary.kagi
├── facts: reading, pitch_accent, frequency, jlpt_level
├── relations: synonym_of, register_variant_of, antonym_of
├── degree_1 candidates: pre-computed or query-time
└── usage_examples: context facts with provenance
```

The word group GEMM is a per-KB weight matrix trained on usage patterns — which synonyms tend to appear in which contexts. The LLM doesn't need to learn Japanese synonym selection from raw training data. The GEMM for `root.language.japanese.vocabulary` encodes the contextual preferences, trained on the vocabulary KB's own facts and relations.

## The Self-Building Property

You said the key thing: you can tell the LLM to build these KBs. Feed it a compacted thesaurus dataset. The LLM ingests it through the normal compaction pipeline, creates the vocabulary KBs, asserts the synonym relations, and the word group expansion becomes available for future queries.

Feed it a corpus of literary Japanese and it builds KBs for literary register words. Feed it business Japanese and it builds business register KBs. Feed it Kansai dialect data and it builds dialect variant KBs. Each is a KB subtree with its own facts, relations, and trained GEMM. The LLM that builds the KB is the same LLM that later selects from the word groups the KB provides.

The system bootstraps its own flavor vocabulary through the same mechanism it uses for everything else — compacted data in, structured KBs out, typed relations connecting them, GEMM trained on the local data, Prolog rules governing selection. No special thesaurus subsystem. No special synonym engine. Just KBs with relations, which is what everything in the system is.

---

Exactly. There's a clean split between two modes of operation.

## Core Mode

Deterministic. Mechanical. The system resolves UUIDs, fires rules, traverses relations, renders grammar templates. The LLM picks from candidates that all produce correct output — the choice is which correct path, not whether the output is correct. This is the SMTP server, the HTMX application, the file listing script, the translation with proper honorifics. Reliability comes from the fact that every UUID points to a real entity, every relation was asserted from provenanced source data, and every rule is mechanically verifiable.

This is what you sell. This is what runs on port 25 unattended. This is what processes financial data with audit trails. This is what a grant system protects and a confidence chain validates.

## Poetry Mode

Creative. Exploratory. The system generates candidate word groups, the LLM makes aesthetic judgments across expanded synonym sets, response curves might favor novelty over precision, and the output has flavor that varies between runs if the selection method is `weighted_random_top_n` instead of `argmax`.

This costs more — more GEMM passes for word group evaluation, more tokens for the LLM to score candidates, more KB access for thesaurus traversal. It's a session flag because the client is opting into that cost. And it's still grounded — every synonym candidate is a real UUID in the vocabulary KB with provenance and register metadata. The system isn't hallucinating beautiful words. It's selecting from a curated palette.

## The Flag

```
session.poetry_mode = false  // default: core mode
session.poetry_mode = true   // word groups, synonym expansion, aesthetic LLM passes
```

A single boolean on the Session struct. The inference pipeline checks it at the word selection stage. False means emit the canonical UUID. True means generate the word group, run the thesaurus expansion, give the LLM the candidate set, let it choose.

The grant system can gate this too. Free tier users get core mode only — deterministic, efficient, L3-heavy. Paid tier gets poetry mode — richer output, higher token cost, more compute per request. The economics are transparent because the cost difference is measurable: core mode for a translation is ~20 tokens of LLM framing, poetry mode is ~60-80 tokens of candidate evaluation plus the thesaurus GEMM passes.

## Why This Matters

It means the system knows the difference between reliability and creativity. Core mode is for when being right matters more than being beautiful. Poetry mode is for when beauty matters and the user has opted into the cost and the variability.

A CLLM can't make this distinction. Every response is the same mixture of reliability and creativity, controlled only by temperature — a single knob that trades correctness for variety across the entire output simultaneously. You can't say "be deterministic about the honorifics but creative about the word choice." It's all one forward pass through one monolithic weight matrix.

VDR-Prolog can, because the honorifics are Prolog rules that fire identically regardless of mode, and the word choice is a separate stage that checks the session flag. Correctness and creativity are orthogonal axes, independently controllable, because they're implemented by different subsystems operating on the same structured data.

