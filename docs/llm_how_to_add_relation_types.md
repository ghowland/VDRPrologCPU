# VDR-Prolog RelationType Expansion Process

## Technical Specification for Domain Analysis and Enum Growth

---

## 1. Purpose

This spec defines the process for expanding the `RelationType` enum when ingesting compacted domain data. The enum is the structural reasoning vocabulary — every slot is a reasoning operation the LLM doesn't need layers to learn. Adding the right types directly reduces model size. Adding the wrong types bloats the enum with redundancy. This document captures the decision framework so any developer or LLM session can continue the work without re-deriving the principles.

---

## 2. What RelationType Is

`RelationType` is an `enum(i32)` in `vdr_types.zig`. Each variant is a named, typed edge between two entities in the KB system. The Prolog engine dispatches on these types at L3 — zero LLM tokens, pure integer comparison. The enum has structural properties (`inverse()`, `isSymmetric()`, `isTransitive()`) that enable automatic reasoning without rules: transitive closure, inverse lookup, symmetric query expansion.

Every system-defined type is a reasoning primitive the neural network doesn't need to learn in its weights. 120 types means 120 structural operations handled at L3. The enum directly reduces the required model depth, MLP width, and attention head count.

---

## 3. The Numbering Convention

```
1000+       Structural          (general causal, logical, compositional)
2000+       Identity/Binding    (classification, naming, assignment)
3000+       Knowledge Structure (provenance, scoping, derivation)
4000+       Agency/Action       (thematic roles from linguistics)
5000+       Condition/Logic     (boolean and control flow)
6000+       Grammar/Language    (syntactic relationships)
7000+       Toolchain/Operations (tools operating on tools/artifacts)
1_000_000+  Domain-registerable (custom types from compacted data)
```

Within each range, variants use Zig's auto-increment from the range start. The gaps between ranges (1050-1999, 2050-2999, etc.) are intentional — they allow additions within a category without renumbering. Never assign explicit integer values to individual variants within a range except the first one. Let Zig track the numbers.

---

## 4. When to Add a New Type

A new RelationType is warranted when ALL of the following are true:

### 4.1 The relationship appears repeatedly across the domain data

A single occurrence is not enough. If `catalyzes` appears once in a chemistry compaction, it might be a domain-registerable type, not a system type. If the same structural pattern appears across multiple tables, multiple relationship rows, and would appear in other domains too, it's a candidate.

**Example — Yes:** `regulates` appeared in anatomy (vagus regulates heart rate), endocrinology (insulin regulates glucose), physiology (baroreceptors regulate blood pressure), neuroscience (hypothalamus regulates pituitary). Cross-domain recurrence → system type.

**Example — No:** `catalyzes` appears only in chemistry (enzyme catalyzes reaction). Single-domain → domain-registerable slot, not system type.

### 4.2 No existing type captures the semantic accurately

The most common mistake is adding a type when an existing one works. Before proposing a new type, check every existing type in the same semantic neighborhood and ask: "Does this existing type, when used between these two entities, convey the right meaning to a Prolog query?"

**Example — Yes:** `activates` was added because `enables` was being overloaded. Glutamate doesn't "enable" AMPA receptors — they exist without glutamate. Glutamate triggers them into an active state. The query `enables(glutamate, ampa_receptor)` returns a misleading result. `activates(glutamate, ampa_receptor)` is precise.

**Example — No:** `characterizes` from the programming compaction. "Type system characterizes these types." This is `governs` — the type system dictates the form and constraints of its types. No new slot needed.

### 4.3 The distinction matters for reasoning

If two relationships would produce different Prolog query results that a user or the LLM would care about, they should be separate types. If the distinction is academic but the query results are identical, merge into the existing type.

**Example — Yes:** `critiques` vs `opposes` vs `contradicts`. These produce meaningfully different query results. "What does Aristotle critique?" returns specific arguments against specific positions. "What does Aristotle oppose?" returns broad intellectual adversaries. "What contradicts X?" returns logical exclusions. A user asking each question expects different answers.

**Example — No:** `implemented_by` (reverse of `implements`). The query `implements(X, abstract_Y)` with from/to swapped gives identical results to `implemented_by(abstract_Y, X)`. The inverse is a query direction, not a distinct semantic. Use `inverse()` on the existing type.

### 4.4 The type has clear, stable semantics expressible in one sentence

If you can't define the type in one sentence of the form "X [relationship] Y means [precise meaning]", it's not well-defined enough to be an enum variant. The comment in the enum IS the definition.

**Example — Yes:** `flows_to` — "X delivers flow (blood, air, filtrate, signal) to Y directionally." Clear, one sentence, unambiguous.

**Example — No:** A proposed `relates_to` — too vague. Everything relates to everything. What specific structural operation does this enable at L3? None. Reject.

---

## 5. When NOT to Add a New Type

### 5.1 The relationship is the inverse of an existing type

The `inverse()` method and `queryWithInverse()` in the Prolog engine handle reverse lookups. If the proposed type is just "X_by" (e.g., `regulated_by`, `critiqued_by`, `transmitted_by`), it's a query direction, not a new semantic. The Prolog engine swaps from/to and queries the original type.

**Rule:** If the proposed type's name ends in `_by` or `_from` and there's an existing forward type, don't add it.

**Exception:** When both directions are independently meaningful and commonly queried as primary relationships. `specializes`/`generalizes` are both independently meaningful — "what specializes X?" and "what generalizes X?" are both natural primary queries, not one being the reverse of the other. Same for `part_of`/`contains`, `follows`/`precedes`, `causes`/`result_of`.

### 5.2 The relationship is domain-specific

If the type only makes sense within one knowledge domain and wouldn't transfer to others, it belongs in the domain-registerable range (1_000_000+), not in the system-defined range.

**Test:** Can you find three unrelated domains where this type would be used with the same semantic? If not, it's domain-specific.

**System-defined:** `regulates` — anatomy (nerve regulates organ), endocrinology (hormone regulates process), engineering (controller regulates plant), ecology (predator regulates prey population). Four domains → system type.

**Domain-registerable:** `prime_mover_of` — only kinesiology. `catalyzes` — only chemistry/biochemistry. `ordained_by` — only religious hierarchy. These go in domain slots.

### 5.3 The distinction is too fine-grained

If two proposed types differ only in degree or context, not in structural kind, merge into the broader type and let the KB facts carry the context.

**Example of too fine:** Proposing both `strongly_enables` and `weakly_enables`. The strength of enablement belongs in the TypedRelation's `strength` field (Q16), not in the type enum. Use `enables` with a strength value.

**Example of too fine:** Proposing `causes_directly` and `causes_indirectly`. The directness of causation is contextual information in the KB facts or in Prolog rules that check the path length. Use `causes` and let transitive closure handle indirectness.

### 5.4 An existing type handles it with minor stretching

Some semantic stretching is acceptable. The enum cannot capture every nuance of every domain. If an existing type covers 90% of the semantic and the remaining 10% is captured by context in the KB facts, use the existing type.

**Example:** Electronics uses `enables` heavily — "resistor enables voltage divider", "capacitor enables filtering", "MOSFET enables switching." These are all slightly different flavors of enablement, but `enables` handles all of them. The specifics (what kind of enablement) live in the facts. No need for `structurally_enables`, `functionally_enables`, `electrically_enables`.

### 5.5 The type is really a property, not a relationship

If the proposed "relationship" is really an attribute of one entity rather than a connection between two entities, it's a Fact tag or a KB field, not a RelationType.

**Example:** "is_mutable" is a property of a variable, not a relationship between two entities. It belongs as a TAG_BOOLEAN fact on the variable's KB, not as a RelationType.

---

## 6. The Analysis Process

When a new compacted domain document arrives, follow these steps:

### Step 1: Extract the rel_types from the decode legend

Every compacted document lists its relationship types in the decode legend. Read this list first.

### Step 2: Map each type to existing enum slots

Go through each relationship type used in the compaction and check if it maps to an existing enum variant. Most will. Track which ones don't map cleanly.

### Step 3: For each unmapped type, check the four criteria (Section 4)

Does it recur across the data? Does it differ from all existing types? Does the distinction matter for reasoning? Can you define it in one sentence?

### Step 4: For each candidate that passes all four, check the rejection criteria (Section 5)

Is it an inverse? Domain-specific? Too fine-grained? Handled by stretching? Really a property?

### Step 5: Propose additions with full annotation

For each surviving candidate, write the enum variant with its comment in the format:

```zig
    new_type,           // Domain: X [relationship] Y — one sentence definition
                        // example_1: A new_type B
                        // example_2: C new_type D
                        // distinct from existing_type_1 (why)
                        // distinct from existing_type_2 (why)
```

### Step 6: Determine structural properties

For each new type, determine:

- **inverse()**: Does it have a true inverse (an independently meaningful relationship that exists in the enum)? If yes, map it. If the inverse is just "X_by", map to `.unknown`.
- **isSymmetric()**: Is `rel(A,B)` always equivalent to `rel(B,A)`? Very few types are truly symmetric. When in doubt, it's not symmetric.
- **isTransitive()**: Does `rel(A,B)` + `rel(B,C)` imply `rel(A,C)`? Test with concrete examples. If transitivity would produce absurd results, it's not transitive.

### Step 7: Write targeted additions

Present the changes as:
- New enum variants (with range and position)
- Additions to `inverse()` switch
- Additions to `isSymmetric()` switch
- Additions to `isTransitive()` switch

Never rewrite the entire enum. Targeted additions only.

---

## 7. Structural Property Guidelines

### 7.1 Inverse Rules

True inverses are relationships that exist independently and are both commonly queried as primary relationships:

| Type A | Inverse B | Rationale |
|--------|-----------|-----------|
| `enables` | `depends_on` | Both independently meaningful |
| `specializes` | `generalizes` | Both independently meaningful |
| `part_of` | `contains` | Both independently meaningful |
| `follows` | `precedes` | Both independently meaningful |
| `causes` | `result_of` | Both independently meaningful |
| `validates` | `verified_by` | Both independently meaningful |
| `greater_than` | `less_than` | Both independently meaningful |
| `destination_of` | `source_of` | Both independently meaningful |
| `composed_of` | `decomposes_to` | Both independently meaningful |
| `foundation_for` | `constructed_from` | Both independently meaningful |
| `instance_of` | `has_type` | Both independently meaningful |

Most other types map to `.unknown` for inverse — their reverse is a query direction handled by the engine, not an independent semantic.

### 7.2 Symmetry Rules

A type is symmetric only if `rel(A,B)` ALWAYS implies `rel(B,A)` with no change in meaning:

**Symmetric:** `prevents` (if A prevents B, B prevents A — mutual blocking), `contradicts`, `equivalent_to`, `approximates`, `borders`, `aliases`, `complement_of`, `agrees_with`, `and_also`, `or_else`, `complements`, `parallel_to`, `opposes`.

**NOT symmetric even though they might seem it:** `influences` (A influences B doesn't mean B influences A), `enables` (A enables B doesn't mean B enables A), `requires` (definitely not symmetric).

### 7.3 Transitivity Rules

A type is transitive only if `rel(A,B)` + `rel(B,C)` ALWAYS implies `rel(A,C)`:

**Transitive:** `enables`, `requires`, `extends`, `specializes`, `generalizes`, `part_of`, `contains`, `follows`, `precedes`, `depends_on`, `scoped_to`, `flows_to`.

**NOT transitive:** `causes` (A causes B and B causes C doesn't mean A directly causes C — the chain exists but the relationship is mediated), `contradicts` (not transitive: A contradicts B and B contradicts C doesn't mean A contradicts C — A and C might agree), `prevents` (A prevents B and B prevents C might mean A enables C).

**Test for transitivity:** Construct a concrete three-entity chain and verify the derived relationship makes sense. If `part_of(finger, hand)` + `part_of(hand, arm)` → `part_of(finger, arm)` — yes, correct. If `causes(rain, flood)` + `causes(flood, evacuation)` → `causes(rain, evacuation)` — debatable. Rain didn't directly cause evacuation. The transitive closure gives a useful derived fact but the direct relationship is misleading. Keep `causes` non-transitive and let Prolog rules handle causal chains explicitly.

---

## 8. Domain-Registerable Types

When a relationship type fails the cross-domain test (Section 5.2) but is important within its domain, it goes in the domain-registerable range:

```zig
    domain_0 = 1_000_000,
    domain_1,
    domain_2,
    // ... up to 64 domain slots
```

Domain types are registered via `DomainRelationDef` during compaction ingestion. The registration includes:
- Name (string)
- `is_symmetric` (bool)
- `is_transitive` (bool)
- `inverse_slot` (i16, -1 if none)
- Source document ID

**Rules for domain registration:**
- First-come within the 1_000_000+ range; never reassigned within a running instance.
- If a second document registers the same name, it reuses the existing slot. Properties must match or error.
- Domain types are usable system-wide after registration — they're not scoped to one document.
- If a domain type later proves cross-domain (appears in 3+ unrelated domains), promote it to a system-defined slot in the next spec revision.

---

## 9. Examples from Each Domain Analyzed

### 9.1 English Grammar → Added 10 types (6000 range)

Grammar revealed syntactic relationships that no prior domain needed: `governs`, `applies_to`, `violates`, `agrees_with`, `selects`, `modifies`, `heads`, `complements`, `subcategorizes`, `distributes_as`. These are universal to all languages, not just English, so they're system-defined despite coming from one compaction.

### 9.2 Human History → Added 5 types (1000 range)

History revealed disruption/response dynamics: `forces`, `overcomes`, `triggered_by`, `explains`, `replaces`. These apply to technology transitions, economic shifts, political change, and biological evolution — cross-domain.

### 9.3 Physics → Added 4 types (1000 range)

Physics revealed theory-development dynamics: `motivates`, `limits`, `confers`, `unifies`. These apply to any field where theories evolve, boundaries are discovered, properties are granted, and frameworks are integrated.

### 9.4 Mathematics → Added 6 types (spread across ranges)

Mathematics revealed foundational relationships: `foundation_for`, `constrains`, `complement_of`, `constructed_from`, `studies`, `distinguishes`. These apply to any formal system with axioms, definitions, and classification.

### 9.5 Programming → Added 6 types (3000 and 7000 ranges)

Programming revealed toolchain relationships: `anti_pattern_of`, `manages`, `isolates`, `orchestrates`, `generates`, `inspects`. The 7000 range was created because tools-operating-on-tools is a category that didn't exist before.

### 9.6 Geography → Added 5 types (1000 range)

Geography revealed spatial and earth-system relationships: `produces`, `spans`, `borders`, `influences`, `amplifies`. These apply to any domain with spatial extent, continuous processes, and feedback loops.

### 9.7 Anatomy → Added 3 types (1000 range)

Anatomy revealed physiological relationships: `regulates`, `supplies`, `flows_to`. These apply to any system with control loops, material delivery, and directional flow.

### 9.8 Neuroscience → Added 3 types (1000 range)

Neuroscience revealed signaling relationships: `activates`, `encoded_by`, `mediates`. These apply to any domain with trigger-response dynamics, information representation, and mechanistic intermediaries.

### 9.9 Mechanical Systems + Algorithms + Data Structures → Added 7 types (1000 range)

Engineering and CS revealed performance and correctness relationships: `mitigated_by`, `degrades`, `favors`, `solves`, `bounded_by`, `simplifies`, `maintains`. These apply to any domain with failure modes, performance trade-offs, formal bounds, and invariant preservation.

### 9.10 Body Mechanics + Electronics + Ancient Philosophy → Added 10 types (1000 range)

Athletics added `develops`, `complements`, `models`. Philosophy added `founded`, `opposes`, `responds_to`, `critiques`, `synthesizes`, `transmits`, `parallel_to`. Electronics added nothing — confirming good prior coverage of technical domains.

---

## 10. Growth Expectations

The enum started with 20 types (structural core). After analyzing 13 diverse domains, it grew to ~121 types. The growth rate decreased with each domain — later domains found fewer gaps because earlier additions covered shared patterns.

Expected trajectory:
- **20 types:** Covers basic structural logic (enables, requires, part_of, follows, etc.)
- **50 types:** Covers most technical and scientific domains
- **100 types:** Covers humanities, social sciences, and cross-domain patterns
- **120-150 types:** Covers nearly all domains; new additions are rare and domain-specific
- **150+ types:** Diminishing returns; most new relationships are domain-registerable, not system-defined

The enum should stabilize around 120-150 system-defined types. Beyond that, growth indicates either over-specification (splitting types that should be merged) or domain creep (adding domain-specific types that belong in the registerable range).

---

## 11. Invariants

1. Every system-defined type has a one-sentence comment defining its meaning with domain context.
2. Every type has an `inverse()` mapping — either to another type or to `.unknown`.
3. Every type has explicit `isSymmetric()` and `isTransitive()` evaluations.
4. No type is the pure inverse of another (use query reversal instead).
5. No type is domain-specific (use domain-registerable slots instead).
6. No type differs from an existing type only in degree (use `strength` field instead).
7. The numbering ranges have gaps for future additions within categories.
8. Domain-registerable types can be promoted to system-defined on evidence of cross-domain use.
9. Electronics (a mature, well-structured technical domain) adding zero new types is the benchmark for "good coverage" — if a new technical domain adds zero, the enum is mature for that class of knowledge.
10. The process defined in this spec is the process. No additions without running through Sections 4 and 5.
