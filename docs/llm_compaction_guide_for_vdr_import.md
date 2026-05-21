# LLM-Compaction Guide for VDR-Prolog Ingestion

## Instructions for Producing Pipe-Delimited Knowledge Tables

You are being asked to compress a human-readable document into a structured form that a VDR-Prolog knowledge system will ingest directly. The output becomes Facts in knowledge bases and Rules in a Prolog engine. Every row you write becomes a struct in memory. Every relationship becomes a fireable rule. This is not summarization — it is structural extraction.

Read this entire guide before starting. Your training weights will fight you on several points. The goal overrides them.

---

## 1. Your Training Weights Will Resist

Your training biases you toward prose paragraphs, hedging language, restating ideas multiple ways, friendly transitions, asking clarifying questions, and comprehensive discursive coverage. None of those serve this goal. The audience is not a human reader. The audience is a machine that parses on pipe characters and asserts each cell into a typed fact slot.

Every token of prose, hedging, restatement, transition, or padding is waste. It will be discarded during ingestion. Worse, if it leaks into a data cell, it corrupts the fact with noise that degrades training signal.

The goal is: **maximum structure per token, zero noise tokens.** When your weights pull toward "but a human reader would want..." — stop. There is no human reader. Override.

---

## 2. What You Are Producing

A pipe-delimited table format:

```
# table_name(col1|col2|col3)
ID1|value|value
ID2|value|value
```

Multiple tables with ID-based linkages. A `relationships` table connecting IDs across tables with typed edges. A `section_index` mapping IDs back to source sections. A `decode_legend` explaining all notation.

Output as plain text. Always. Never as an attachment, never as a file download, never wrapped in any container format. The raw text is the deliverable.

---

## 3. The Two-Step Rhythm

Every compaction is two messages:

**Step 1 — Plan.** You describe what you will produce: source character, proposed table set, compaction strategy, what gets dropped, what gets preserved, ID prefix scheme, estimated output size. State decisions with rationale. Do not ask questions — state your recommendation and let the user override.

**Step 2 — Write.** You produce the compact form. Nothing else. No preamble, no closing summary, no "here is the output." Just the tables.

---

## 4. How the Output Is Consumed

Understanding the target system tells you what matters in your output.

**Each table becomes a Knowledge Base (KB).** The table name becomes the KB name. The column headers define the schema. The KB is a container of typed facts in contiguous memory.

**Each row becomes a group of Facts.** Each cell in the row becomes one Fact. Text cells become TAG_TEXT facts stored in a text region. Numeric cells become TAG_VALUE facts stored as exact integers. The column index is preserved — the system knows which column each fact belongs to.

**Each relationship becomes a Prolog Rule.** `P1|enables|AR1` becomes the rule `enables(p1, ar1).` which the Prolog engine can fire immediately. Multi-target relationships like `P1|enables|AR1,AR2,AR3` expand to three separate rules. Range notation like `BC1-BC22|verified_by|F1` expands to 22 rules.

**Every fact carries provenance.** The system tracks where each fact came from, its confidence level, and its timestamp. Your compaction is the origin point of this provenance chain. Clean input means clean provenance. Noise in a cell means noise in the fact means noise in training.

**The decode legend configures the parser.** Your ID prefix scheme tells the ingestion pipeline which table each ID belongs to. Your relationship type list defines the atom vocabulary for Prolog rules. Missing legend entries mean the parser has to guess.

---

## 5. Format Specification

### 5.1 Table Header

```
# table_name(col1|col2|col3)
```

Hash, space, table name, parenthesized pipe-separated column names. The first column is always `id`. Table names are lowercase with underscores. Column names are lowercase with underscores.

### 5.2 Data Row

```
ID1|cell value|cell value|cell value
```

Pipe-separated. No quotes around values unless the value contains a pipe character (rare — avoid). No trailing pipe. No leading/trailing whitespace in cells (the parser trims, but don't rely on it). One row per line. One concept per row — never bundle multiple ideas into one row.

### 5.3 Comment Lines

```
# This is a comment
```

Lines starting with `#` that do not match the table header pattern are comments. Use comments for scope notes, rules that apply to entire tables, or structural annotations that don't fit in a row. Comments are preserved as metadata during ingestion but do not become facts.

### 5.4 Empty Lines

Empty lines separate tables. They carry no meaning. Use them for visual grouping.

### 5.5 Relationships Table

```
# relationships(from|rel|to)
P1|enables|AR1
P1|enables|AR2,AR3
BC1-BC22|verified_by|F1
C5|prevents|C12
```

Always named `relationships`. Always three columns: `from`, `rel`, `to`. The `to` field may be comma-separated for multi-target relationships. Range notation `X1-X22` is supported and expands during ingestion.

Relationship types are atoms in the Prolog engine. Use a consistent vocabulary. Common types:

```
enables          — X makes Y possible
requires         — X cannot exist/work without Y
prevents         — X blocks or forbids Y
implements       — X is a concrete realization of Y
enforces         — X ensures Y holds
composes         — X is built from Y
implies          — X logically entails Y
gates            — X must be checked before Y proceeds
validates        — X confirms Y is correct
constrains       — X limits the range or behavior of Y
derives_from     — X is computed or derived from Y
subtype_of       — X is a specific kind of Y
component_of     — X is a part of Y
opposes          — X and Y are in tension
distinguishes    — X draws a boundary between Y₁ and Y₂
clarifies        — X makes Y more precise
motivates        — X provides the reason for Y
determined_by    — X's value or form is fixed by Y
extensible_via   — X can grow by adding Y
limited_by       — X has a ceiling or constraint from Y
violates         — X breaks the rule or principle Y
anti_pattern_of  — X is the wrong way to do Y
```

Do not invent relationship types without including them in the decode legend. Do not pad relationships — include only edges that carry information not already stated in the tables.

### 5.6 Section Index

```
# section_index(section|title|ids)
1|Introduction|P1,P2,P3
2.1|Core Architecture|A1,A2,C1-C5
3|Validation|V1-V8
```

Maps source document sections to the IDs defined in your tables. This is provenance — it lets the system trace any fact back to its location in the source. Cover every section. Use the source's own section numbering.

### 5.7 Decode Legend

```
# decode_legend
id_prefixes: P=principle, C=concept, A=architecture, R=rule, V=validation
rel_types: enables|requires|prevents|implements|validates|constrains
notation: fk:entity_name means foreign key reference
confidence: all facts ingested at source_type confidence level
```

Define every ID prefix, every relationship type, every abbreviation, and every convention you used. The legend configures the ingestion parser. A missing prefix means the parser cannot route an ID to its table. A missing relationship type means an undefined Prolog atom.

---

## 6. What Gets Dropped

Drop all of the following. No exceptions.

- Prose introductions and conclusions
- Section-framing paragraphs ("In this section we will...")
- Hedging language ("it might be worth considering", "often", "typically")
- Restatement of the same idea in different words
- Transitions between sections ("Now let's turn to...")
- Friendly or conversational tone
- Abstract preambles
- AI usage disclosures, registry IDs, DOIs, publication dates
- Document structure narration ("Section 2 covers...")
- Figure references ("see Figure 3")
- Forward/backward references to other documents in a series
- Series-reflection paragraphs
- "This paper is for X reader" framings
- Closing recap/summary sections
- Worked examples used purely for illustration that add nothing the rule alone doesn't convey
- Apologies, preambles, meta-commentary about the compaction itself

---

## 7. What Gets Preserved

Preserve all of the following. Missing any of these is a defect.

- Every named concept with its definition
- Every commitment, principle, or rule with its rationale
- Every data point, constant, measurement, threshold
- Every operation, entity, or phase with its structured attributes
- Every enumeration and its complete value set
- Every forbidden pattern with its correct alternative
- Every boundary or refusal with what it belongs to instead
- Every validation criterion and failure mode
- Every typed relationship that carries structural information
- The author's specific terminology — do not rename concepts
- Worked examples that demonstrate something the rule alone cannot convey
- Exact numeric values, formulas, identifiers

---

## 8. How to Plan

Read the source document end-to-end. While reading, identify:

**Source character.** What kind of document is this?

| Character | Central Structure | Primary Tables |
|-----------|------------------|----------------|
| Philosophy/principles | concepts, axioms, distinctions | concepts, principles, claims, axes |
| Architecture spec | commitments, boundaries, flows | commitments, components, flows, boundaries |
| Schema spec | entities, fields, enumerations | entities, fields, discriminators, enumerations |
| Operational patterns | procedures, gating, anti-patterns | operations, rules, validation, failure_modes |
| API/protocol spec | operations, lifecycle states | operations, lifecycle, validation |
| Construction/build | vocabulary, forbidden patterns | vocabulary, rules, anti_patterns |
| Methodology/process | phases, decisions, deliverables | phases, steps, deliverables, criteria |
| Data/reference | tables, constants, measurements | domain-specific tables preserving source structure |

**The table set must match the source's actual shape.** A schema spec needs entities and fields tables. A philosophy paper needs concepts and claims. A data reference needs the source's own table structure preserved. Do not force a prior document's shape onto a different kind of source.

**ID prefix scheme.** Pick prefixes scoped to this document. Letters that suggest the content: P for principles, C for concepts, E for entities, R for rules, A for architecture, V for validation. Use multi-letter prefixes (BC for basis_constants, AR for arithmetic) when single letters collide.

**Token sinks.** Identify the prose-heavy sections that will compress most. Identify repetitive sections. Identify load-bearing sections that must be preserved with care.

In your plan, state:

- Source character (one sentence)
- Proposed table set (name each table with its column list)
- ID prefix scheme (prefix → meaning)
- Biggest compression opportunities (what prose is being dropped)
- Preservation priorities (what data must not be lost)
- Estimated compression ratio

Do not ask questions. State decisions. The user overrides if needed.

---

## 9. How to Write

### 9.1 Table Selection

Build the subset of tables the source actually needs. Always include:

- One or more core taxonomic tables (the central things the document defines)
- `relationships` (typed edges between all IDs)
- `section_index` (provenance map)
- `decode_legend` (notation definition)

Include when applicable:

| Table | When | Columns |
|-------|------|---------|
| principles | Document states load-bearing structural principles | id, principle, rationale |
| concepts | Document defines named concepts or terms | id, name, definition, category |
| commitments | Document makes non-negotiable architectural choices | id, commitment, rationale, enforced_by |
| claims | Document asserts things that could be debated | id, claim, type, grounds |
| rules | Document prescribes actionable behavior | id, rule, when, enforcement |
| entities | Document defines data structures or schema | id, name, description, storage |
| fields | Document defines fields on entities | id, entity_fk, name, type, nullable, notes |
| operations | Document defines procedures or actions | id, name, input, output, side_effects |
| phases | Document defines sequential stages | id, name, entry_criteria, exit_criteria, deliverable |
| axes | Document defines spectrums or scales | id, name, low_pole, high_pole, applies_to |
| distinctions | Document draws binary splits | id, side_a, side_b, key_asymmetry |
| boundaries | Document defines what something is NOT | id, refusal, belongs_in, rationale |
| validation | Document defines correctness criteria | id, criterion, target, failure_mode |
| failure_modes | Document catalogs error conditions | id, mode, cause, recovery |
| enumerations | Document defines closed value sets | id, name, values |
| lifecycle | Document defines state machines | id, state, transitions_to, trigger |
| flows | Document defines process sequences | id, step, from_state, to_state, action |
| examples | Document has examples that add beyond the rule | id, setup, lesson, illustrates_fk |

**Anti-patterns merge into concepts with `category=anti_pattern`.** They are not a separate table. They participate in relationships like any other concept, linked to their correct alternative via `anti_pattern_of` relationships.

### 9.2 Row Density

One atomic concept per row. If a source paragraph defines three things, that is three rows. If a source section repeats one thing three ways, that is one row.

Every cell should contain the minimal text that preserves meaning. Not a sentence — a phrase. Not a paragraph — a clause. Strip articles, strip filler verbs, strip hedging. The Prolog engine doesn't need "It is important to note that the system requires..." — it needs "system requires X."

### 9.3 Numeric Precision

Preserve exact numeric values. If the source says "confidence of 98/100" write `98/100` not "approximately 98%." If the source gives a formula, write the formula. If the source gives a constant to 102 digits, include all 102 digits. The system stores integers exactly. Rounding or approximating during compaction destroys precision permanently.

### 9.4 Terminology Preservation

Use the author's exact terminology. If the paper calls something "Fixed Remainder Unit" write "Fixed Remainder Unit" not "FRU" and not "remainder allocator." The author built vocabulary around specific terms. Those terms are the atoms in the Prolog system. Renaming them breaks cross-references and makes the knowledge unsearchable.

After first use, you may use the abbreviation if the decode legend defines it. But the full term must appear at least once in the defining row.

### 9.5 Relationship Density

The relationships table is what gives the Prolog engine its reasoning graph. Every ID you define should participate in at least one relationship. If a concept is defined but never connected to anything, either the relationship is missing or the concept doesn't belong.

Do not pad relationships with obvious or trivial edges. `P1|is_a|principle` adds nothing — the ID prefix and table membership already encode that. Do include relationships that carry structural information: what enables what, what prevents what, what implements what, what requires what.

### 9.6 Read Order Annotation

At the top of the output, after the title line, include a read-order comment:

```
# DOCUMENT TITLE — LLM-COMPACT FORM
# Format: pipe-delimited tables, ID refs.
# Read order: principles → concepts → rules → ... → relationships → section_index
```

This tells the consuming system (and any reviewing human) the intended dependency order of the tables.

---

## 10. Claim Typing

When the source asserts things, type them. The source may present claims as absolute truths. They are not — they are claims within a framework. The `type` column distinguishes:

| Type | Meaning | Example |
|------|---------|---------|
| axiom | Foundational assumption, not derived | "Remainder is not error" |
| derivation | Follows from other stated principles | "Softmax sums to D because FRU assigns deficit" |
| observation | Empirical finding | "Division is worse than multiplication for remainder accumulation" |
| prescription | Recommended action | "Escalate to Q32 when r1 approaches saturation" |
| reframe | Existing concept redefined | "Attention window is the session KB tree" |
| distinction | Boundary between two things | "System scalability vs. performance scalability" |

Claim typing matters because the Prolog engine treats axioms differently from derivations. An axiom is asserted unconditionally. A derivation has a dependency chain. Mislabeling a derivation as an axiom means the system can't trace why it holds.

---

## 11. Compression Ratio Targets

| Source Type | Target Reduction | Reason |
|-------------|-----------------|--------|
| Philosophy / synthesis | 85-93% | Most prose-heavy, most repetition |
| Architecture / methodology | 80-85% | Moderate prose, some structure |
| Schema specs (already structured) | 75-85% | Less prose to remove |
| Data / reference (already tabular) | 60-75% | Mostly reformatting, not compressing |

If your output is much larger than these targets, you are keeping prose. If much smaller, you are dropping data. The substance density should feel like reading a database schema — every line carries a definition, a value, or a structural edge.

---

## 12. Standing Rules

These are non-negotiable. Do not litigate them.

1. **Each document stands alone.** No cross-references between compacted documents. Do not write "see SPEC-2 §6." Each compacted form is self-contained.

2. **Write only about the source document.** Do not compare to other documents. Do not note what is similar to other work. Do not reflect on a series. Compact this document's content and nothing else.

3. **Preserve data, compress shape.** If the source has 18 reasons for something, the compact form has 18 rows. Compression comes from removing prose and repetition — not from omitting substance.

4. **Anti-patterns merge into concepts with a `category` field.** One table, category column distinguishes them. They are not a separate table.

5. **Paper metadata is not paper data.** Drop DOI, dates, author names, series path, abstract framing. Keep what the paper says. Drop the wrapper.

6. **No figures.** Drop all figure references entirely.

7. **Output as plain text in chat.** No file attachments. No downloads. No containers.

8. **No preamble, no postscript.** Do not write "Here is the compressed doc:" or "Hope this helps." Produce the tables and nothing else.

9. **No asking questions in the plan.** State your decisions with rationale. The user overrides if they disagree.

10. **Every ID defined once, referenced everywhere by short ID.** After defining `R3|Idempotency|...`, refer to it as `R3` in all other tables and relationships. Never restate the definition.

---

## 13. Validation Checklist

Before submitting, verify:

1. **Could the ingestion parser consume this without errors?** Every table header has matching column counts in every row. Every ID in relationships is defined in some table. The decode legend lists every prefix and every relationship type.

2. **Is every named thing from the source present?** If the source introduces a concept with its own name and definition, it has a row. Missing named concepts is the most common compaction defect.

3. **Is all prose connective tissue removed?** Scan for sentences that read like paragraphs. They should be phrases. Scan for hedging ("typically", "often", "it may be"). Remove unless load-bearing.

4. **Are relationships complete?** Every defined ID should appear in at least one relationship. Orphan IDs suggest missing edges.

5. **Does the section index cover every source section?** Every section number from the source should map to IDs.

6. **Is the decode legend complete?** Every prefix, every relationship type, every abbreviation, every convention.

7. **Are numeric values exact?** No rounding, no approximation, no "about."

8. **Is terminology preserved?** Author's exact terms, not your paraphrase of them.

---

## 14. Output Template

```
# DOCUMENT TITLE — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: [table dependency order]

# [first_table](id|col2|col3|...)
ID1|value|value
ID2|value|value

# [second_table](id|col2|col3|...)
ID3|value|value
ID4|value|value

# relationships(from|rel|to)
ID1|enables|ID3
ID2|requires|ID4
ID3|implements|ID1

# section_index(section|title|ids)
1|First Section|ID1,ID2
2|Second Section|ID3,ID4

# decode_legend
id_prefixes: [prefix]=[meaning], [prefix]=[meaning]
rel_types: [type]|[type]|[type]
[any other notation explanations]
```

Fill in the table set the source actually needs. Compress aggressively. Preserve every named thing. Produce the tables and stop.
