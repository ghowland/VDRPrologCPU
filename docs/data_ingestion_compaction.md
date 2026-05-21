# VDR-Prolog Data Ingestion via LLM-Compaction

## Technical Specification

---

## 1. Overview

The system needs training data. Raw documents — papers, specs, manuals, knowledge bases — are prose-heavy. Prose is noise for training. Connective tissue, hedging, repetition, transitions, framing — none of it carries signal. A 50-page paper might have 3 pages of actual structure buried in 47 pages of wrapper.

LLM-compaction solves this. A conventional LLM (external, not VDR-Prolog itself) reads the raw document and produces a pipe-delimited table format that preserves every named concept, relationship, rule, and data point while discarding all prose wrapper. The compacted form is 75-93% smaller than the source and is pure signal.

The compacted form maps directly into VDR-Prolog's type system: tables become KBs, rows become Facts, typed relationships become Prolog rules, ID references become VdrId cross-references. The pipe-delimited format is trivially parseable — no JSON overhead, no XML nesting, no ambiguous whitespace. Split on pipes, map to structs, assert to KBs.

This means training data arrives pre-structured, pre-denoised, and pre-linked. The GEMM sees signal, not filler. The Prolog engine gets rules it can fire immediately. The confidence system knows the provenance chain: raw document → external LLM compaction → ingestion → training.

---

## 2. The Compaction Format

### 2.1 Structure

A compacted document is a sequence of named tables with typed columns, followed by a relationship table and a decode legend:

```
# table_name(col1|col2|col3)
ID1|value|value|value
ID2|value|value|value

# relationships(from|rel|to)
ID1|enables|ID2
ID3|requires|ID1

# decode_legend
id_prefixes: P=principle, C=concept, R=rule
rel_types: enables|requires|prevents|implements
```

Tables are pipe-delimited. One row per atomic concept. IDs are short prefixed strings (P1, BC3, AR5). Relationships are typed edges between IDs. The decode legend defines all notation.

### 2.2 Why This Format

Pipe-delimited tables are ~30% fewer tokens than equivalent JSON. They parse in a single pass — split line on pipes, map positionally to column names from the header. No recursive descent, no escape handling beyond the rare pipe-in-value case. The format is designed for LLM production (an external LLM writes it) and machine consumption (VDR-Prolog reads it).

Every row is self-contained. Every relationship is an explicit typed edge. Every ID is defined exactly once and referenced by short string. There is no implicit structure — everything is stated.

### 2.3 What Gets Preserved vs. Dropped

**Preserved:** Every named concept with its definition. Every commitment, principle, rule with its enforcement and rationale. Every data point, constant, measurement. Every typed relationship. Every enumeration. Every constraint. Author-specific terminology.

**Dropped:** Prose introductions and conclusions. Section framing ("In this section we will..."). Hedging language. Restatement of the same idea in different words. Figure references. Metadata (DOIs, dates, authorship). Transitions between sections. Worked examples that add nothing beyond the rule they illustrate.

The compaction guide estimates: philosophy papers compress 85-93%, architecture specs 80-85%, schema specs 75-85%. The compression comes from removing prose, not from removing data.

---

## 3. Mapping Compacted Tables to VDR-Prolog Types

### 3.1 Core Mapping

Each table in a compacted document becomes a KB. Each row becomes a Fact (or a set of Facts for multi-valued rows). Each relationship becomes a Prolog Rule. The document itself becomes a parent KB containing all its tables as children.

```
Compacted document: "MATH-4 Universal Power-of-Two Basis"
    → KB: root.knowledge.math.math_4           (parent)
        → KB: root.knowledge.math.math_4.principles     (table)
        → KB: root.knowledge.math.math_4.basis_constants (table)
        → KB: root.knowledge.math.math_4.arithmetic      (table)
        → KB: root.knowledge.math.math_4.relationships   (rules)
```

### 3.2 Table Row → Facts

A table row like:

```
# principles(id|principle|rationale)
P1|Shared power-of-two denominator|all 22 constants as single integers over 2³³⁵; addition reduces to integer add/sub
```

Maps to Facts in the `principles` KB:

```
facts[0] = {
    tag: .value,
    value: Q16.fromParts(row_index, 0, 0),
    provenance: {
        source_type: published,           // from a paper
        source_kb_id: math_4_kb_id,       // parent document KB
        confidence: 52428,                // published = 80/100
        timestamp: ingestion_time,
        derivation_rule_id: -1,           // not derived, directly ingested
    }
}
```

But a single Fact holds one Q16 value. A table row has multiple columns of text. The mapping needs a richer structure.

### 3.3 The Ingestion Fact Layout

Each row produces a group of Facts in the table's KB. The row ID (P1, BC3, etc.) becomes a local identifier within the KB. Each column value becomes a separate Fact:

```
Row P1 in principles KB:
    facts[0] = TAG_TEXT, value.v = 0 (column index: id),
               text_offset → "P1"
    facts[1] = TAG_TEXT, value.v = 1 (column index: principle),
               text_offset → "Shared power-of-two denominator"
    facts[2] = TAG_TEXT, value.v = 2 (column index: rationale),
               text_offset → "all 22 constants as single integers over 2³³⁵..."
```

The `value.v` field encodes the column index. The text content lives in the text store, referenced by offset. The row grouping is implicit in the sequential fact layout: facts 0-2 are row 0, facts 3-5 are row 1, etc. The column count is fixed per table (from the header).

### 3.4 Numeric Values

When a column contains a numeric value, the Fact uses TAG_VALUE instead of TAG_TEXT:

```
# basis_constants(id|name|numerator_over_2_335|p_digits|p_bits)
BC3|ln(2)|485147735...|101|335
```

```
facts[9]  = TAG_TEXT,  value.v = 0, text → "BC3"
facts[10] = TAG_TEXT,  value.v = 1, text → "ln(2)"
facts[11] = TAG_TEXT,  value.v = 2, text → "485147735..."  // too large for Q16
facts[12] = TAG_VALUE, value = Q16.fromParts(101, 0, 0)     // p_digits
facts[13] = TAG_VALUE, value = Q16.fromParts(335, 0, 0)     // p_bits
```

Small integers map directly to Q16 (value.v = the integer, r0 = 0, r1 = 0). Large integers (like the 102-digit numerators in the MATH-4 example) stay as text references — they exceed Q16/Q32 range and would need Q335 representation for computation. The ingestion pipeline detects numeric columns and uses TAG_VALUE where the value fits in i32 range.

### 3.5 Relationships → Prolog Rules

The relationship table is the structural backbone. Each row becomes a Prolog Rule in the document's relationships KB:

```
# relationships(from|rel|to)
P1|enables|AR1,AR2,AR3
BC6|equals_approx|BC18
QA4|validates|P2,F2
```

Each edge becomes a Rule that, when fired, can derive new facts:

```
// P1 enables AR1
Rule {
    id: rule_uuid,
    head: term_offset → enables(P1, AR1)
    body_offset: 0,
    body_count: 0,        // unconditional — this is a stated relationship
    action_offset: ...,
    action_count: 0,       // no side effects — pure knowledge
}
```

The relationship types (`enables`, `requires`, `prevents`, `implements`, `validates`, etc.) become atoms in the Prolog term store. The row IDs (P1, AR1, BC6) become atoms that reference specific facts in specific table KBs.

Multi-target relationships like `P1|enables|AR1,AR2,AR3` expand to three rules:

```
enables(P1, AR1).
enables(P1, AR2).
enables(P1, AR3).
```

### 3.6 The Decode Legend → KB Metadata

The decode legend defines notation used throughout the document. It maps to metadata facts in the parent document KB:

```
# decode_legend
id_prefixes: P=principle, CF=cf_convergent, BC=basis_constant
rel_types: enables|clarifies|motivates|validates
precision: 100 decimal digits; rounding error ≤ 2⁻³³⁶
```

Each legend entry becomes a TAG_TEXT fact in the document KB with a reserved provenance type indicating it is schema metadata, not content data. The ingestion pipeline reads the legend to configure its parsing — the prefix mapping tells it which KB each ID belongs to.

---

## 4. Ingestion Pipeline

### 4.1 Pipeline Stages

```
Stage 1: EXTERNAL LLM COMPACTION (outside VDR-Prolog)
    Raw document → conventional LLM → pipe-delimited compacted form
    Input: PDF, markdown, HTML, plain text
    Output: .compact file (pipe-delimited tables + relationships + legend)
    Trust level: llm_generated (confidence: 30/100)

Stage 2: VALIDATION (inside VDR-Prolog or preprocessing)
    Parse the .compact file
    Verify: all IDs defined before referenced,
            all relationship targets exist,
            all table headers match row column counts,
            no duplicate IDs within a document
    Output: validated parse tree or rejection with specific errors

Stage 3: KB CREATION
    Create parent document KB
    Create child KB per table
    Allocate fact capacity per KB from row counts

Stage 4: FACT ASSERTION
    For each table row, assert facts into the table KB
    Text values → text store, TAG_TEXT facts with offsets
    Numeric values → TAG_VALUE facts with Q16 values
    Provenance on every fact: source_type=published (or llm_generated),
    source_kb_id=document_kb, timestamp=ingestion_time

Stage 5: RULE ASSERTION
    For each relationship row, assert Prolog rules
    Expand multi-target relationships to individual rules
    Atom registration for relationship types and row IDs

Stage 6: GEMM CACHE PREP (optional, post-training)
    After training incorporates the ingested data,
    rebuild GEMM caches for affected KBs
```

### 4.2 Parser

The parser for pipe-delimited tables is simple enough to run without an LLM:

```
fn parseCompactFile(input: []const u8, arena: *Arena) ?*CompactDocument {
    var doc = arena.allocTyped(CompactDocument) orelse return null;
    var line_iter = std.mem.splitScalar(u8, input, '\n');

    var current_table: ?*CompactTable = null;

    while (line_iter.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");
        if (trimmed.len == 0) continue;

        if (trimmed[0] == '#') {
            if (std.mem.indexOf(u8, trimmed, "(")) |paren_start| {
                // Table header: # table_name(col1|col2|col3)
                current_table = parseTableHeader(trimmed, doc, arena);
            }
            // else: comment line, skip
            continue;
        }

        if (current_table) |table| {
            // Data row: ID|value|value|value
            const row = parseRow(trimmed, table, arena) orelse continue;
            table.addRow(row);
        }
    }

    return doc;
}

fn parseRow(line: []const u8, table: *CompactTable, arena: *Arena) ?*CompactRow {
    var row = arena.allocTyped(CompactRow) orelse return null;
    var col_iter = std.mem.splitScalar(u8, line, '|');
    var col_index: i32 = 0;

    while (col_iter.next()) |cell| {
        if (col_index >= table.column_count) break;
        const trimmed = std.mem.trim(u8, cell, " ");

        row.cells[@intCast(col_index)] = CompactCell{
            .text_offset = storeText(trimmed, arena),
            .text_length = @intCast(trimmed.len),
            .is_numeric = isNumeric(trimmed),
            .numeric_value = if (isNumeric(trimmed)) parseInt(trimmed) else 0,
        };
        col_index += 1;
    }

    if (col_index != table.column_count) return null; // column count mismatch
    row.column_count = col_index;
    return row;
}
```

### 4.3 Validation Rules

Before any data enters the KB store, the parsed document is validated:

```
fn validateCompactDocument(doc: *CompactDocument) ValidationResult {
    var result = ValidationResult{};

    // 1. All IDs unique within the document
    var id_set = IdSet{};
    for (doc.tables) |table| {
        for (table.rows) |row| {
            const id = row.cells[0]; // first column is always ID
            if (id_set.contains(id)) {
                result.addError(.duplicate_id, id);
            }
            id_set.insert(id);
        }
    }

    // 2. All relationship targets exist
    if (doc.relationships) |rels| {
        for (rels.rows) |row| {
            const from = row.cells[0];
            const to_field = row.cells[2];
            // to_field may be comma-separated: "AR1,AR2,AR3"
            var targets = std.mem.splitScalar(u8, to_field, ',');
            while (targets.next()) |target| {
                const trimmed = std.mem.trim(u8, target, " ");
                if (!id_set.contains(trimmed)) {
                    // Check for range notation: "BC1-BC22"
                    if (!isValidRange(trimmed, id_set)) {
                        result.addError(.undefined_reference, trimmed);
                    }
                }
            }
        }
    }

    // 3. Column counts match headers
    for (doc.tables) |table| {
        for (table.rows) |row| {
            if (row.column_count != table.column_count) {
                result.addError(.column_mismatch, row.cells[0]);
            }
        }
    }

    // 4. Decode legend exists
    if (doc.decode_legend == null) {
        result.addWarning(.missing_legend);
    }

    return result;
}
```

---

## 5. Ingestion Structs

### 5.1 Parse-Time Structs

These structs exist only during ingestion. They live in a temporary arena and are destroyed after facts and rules are asserted to KBs.

```zig
pub const CompactCell = struct {
    text_offset: i32 = 0,
    text_length: i16 = 0,
    is_numeric: bool = false,
    numeric_value: i64 = 0,
};

pub const CompactRow = struct {
    cells: [MAX_COLUMNS]CompactCell = [_]CompactCell{.{}} ** MAX_COLUMNS,
    column_count: i32 = 0,
    row_index: i32 = 0,

    pub fn getId(self: *CompactRow) CompactCell {
        return self.cells[0]; // first column is always ID
    }
};

pub const CompactColumn = struct {
    name_offset: i32 = 0,
    name_length: i16 = 0,
    column_index: i32 = 0,
    detected_type: ColumnType = .text,
};

pub const ColumnType = enum(i8) {
    text = 0,
    integer = 1,
    q16_value = 2,
    id_ref = 3,        // references another row's ID
    id_list = 4,       // comma-separated ID references
};

pub const MAX_COLUMNS: usize = 32;

pub const CompactTable = struct {
    name_offset: i32 = 0,
    name_length: i16 = 0,
    columns: [MAX_COLUMNS]CompactColumn = [_]CompactColumn{.{}} ** MAX_COLUMNS,
    column_count: i32 = 0,
    rows_offset: i32 = 0,       // offset into row array
    row_count: i32 = 0,
    row_capacity: i32 = 0,

    pub fn addRow(self: *CompactTable, row: *CompactRow) void {
        row.row_index = self.row_count;
        self.row_count += 1;
    }
};

pub const CompactRelationship = struct {
    from_offset: i32 = 0,       // text: source ID
    from_length: i16 = 0,
    rel_offset: i32 = 0,        // text: relationship type
    rel_length: i16 = 0,
    to_offset: i32 = 0,         // text: target ID(s), may be comma-separated
    to_length: i16 = 0,
};

pub const CompactLegendEntry = struct {
    key_offset: i32 = 0,
    key_length: i16 = 0,
    value_offset: i32 = 0,
    value_length: i16 = 0,
};

pub const CompactDocument = struct {
    // Identity
    name_offset: i32 = 0,
    name_length: i16 = 0,

    // Tables
    tables: [MAX_TABLES]CompactTable = [_]CompactTable{.{}} ** MAX_TABLES,
    table_count: i32 = 0,

    // Relationships (special table)
    relationships: [MAX_RELATIONSHIPS]CompactRelationship =
        [_]CompactRelationship{.{}} ** MAX_RELATIONSHIPS,
    relationship_count: i32 = 0,

    // Decode legend
    legend_entries: [MAX_LEGEND]CompactLegendEntry =
        [_]CompactLegendEntry{.{}} ** MAX_LEGEND,
    legend_count: i32 = 0,

    // Section index (provenance)
    section_entries: [MAX_SECTIONS]CompactSectionEntry =
        [_]CompactSectionEntry{.{}} ** MAX_SECTIONS,
    section_count: i32 = 0,

    // Text store for all string data
    text_store: []u8 = &.{},
    text_cursor: i32 = 0,
};

pub const MAX_TABLES: usize = 64;
pub const MAX_RELATIONSHIPS: usize = 1024;
pub const MAX_LEGEND: usize = 64;
pub const MAX_SECTIONS: usize = 128;

pub const CompactSectionEntry = struct {
    section_id_offset: i32 = 0,
    section_id_length: i16 = 0,
    title_offset: i32 = 0,
    title_length: i16 = 0,
    ids_offset: i32 = 0,        // comma-separated referenced IDs
    ids_length: i16 = 0,
};

pub const ValidationError = struct {
    error_type: ValidationErrorType = .duplicate_id,
    context_offset: i32 = 0,
    context_length: i16 = 0,
};

pub const ValidationErrorType = enum(i8) {
    duplicate_id = 0,
    undefined_reference = 1,
    column_mismatch = 2,
    missing_legend = 3,
    invalid_table_header = 4,
    empty_document = 5,
};

pub const ValidationResult = struct {
    errors: [MAX_VALIDATION_ERRORS]ValidationError =
        [_]ValidationError{.{}} ** MAX_VALIDATION_ERRORS,
    error_count: i32 = 0,
    warning_count: i32 = 0,
    valid: bool = true,

    pub fn addError(self: *ValidationResult, err_type: ValidationErrorType, context: []const u8) void {
        if (self.error_count >= MAX_VALIDATION_ERRORS) return;
        self.errors[@intCast(self.error_count)] = .{
            .error_type = err_type,
        };
        self.error_count += 1;
        self.valid = false;
    }
};

pub const MAX_VALIDATION_ERRORS: usize = 256;
```

### 5.2 Ingestion Config

```zig
pub const IngestionConfig = struct {
    // Where to mount the document in the KB tree
    target_path: [256]u8 = [_]u8{0} ** 256,
    target_path_length: i32 = 0,

    // Trust level
    source_type: SourceType = .published,

    // Whether relationships should generate Prolog rules
    generate_rules: bool = true,

    // Whether to detect and use numeric types for columns
    detect_numeric: bool = true,

    // Maximum facts per table KB
    max_facts_per_table: i32 = 10000,

    // Whether to freeze the KBs after ingestion (immutable source data)
    freeze_after_ingest: bool = true,
};
```

---

## 6. KB Assertion Flow

### 6.1 Document → KB Tree

```
fn ingestDocument(
    doc: *CompactDocument,
    config: *IngestionConfig,
    store: *KbStore,
    arena: *Arena,
) Status {
    // 1. Create parent document KB
    const doc_kb = store.createKb(.{
        .name = getDocName(doc),
        .path = config.target_path[0..@intCast(config.target_path_length)],
        .parent_id = resolveParentFromPath(config, store),
        .visibility = 1, // internal
    }, arena) orelse return Status.err(.memory, .arena_exhausted, 0);

    // 2. Assert legend as metadata facts in parent KB
    assertLegend(doc, doc_kb, store, arena);

    // 3. Assert section index as metadata facts in parent KB
    assertSectionIndex(doc, doc_kb, store, arena);

    const now = currentTimestamp();

    // 4. Create child KB per table, assert facts
    var table_idx: i32 = 0;
    while (table_idx < doc.table_count) : (table_idx += 1) {
        const table = &doc.tables[@intCast(table_idx)];
        const table_name = getTableName(table, doc);

        const table_kb = store.createKb(.{
            .name = table_name,
            .parent_id = doc_kb.id,
            .max_facts = config.max_facts_per_table,
            .visibility = 1,
        }, arena) orelse return Status.err(.memory, .arena_exhausted, 1);

        // Assert column schema as first facts
        assertColumnSchema(table, table_kb, doc, store, arena, now);

        // Assert each row
        var row_idx: i32 = 0;
        while (row_idx < table.row_count) : (row_idx += 1) {
            const row = getRow(table, row_idx);
            assertRow(row, table, table_kb, doc, config, store, arena, now);
        }

        if (config.freeze_after_ingest) {
            table_kb.frozen = 1;
        }
    }

    // 5. Assert relationships as Prolog rules
    if (config.generate_rules) {
        assertRelationships(doc, doc_kb, store, arena, now);
    }

    if (config.freeze_after_ingest) {
        doc_kb.frozen = 1;
    }

    return Status.ok();
}
```

### 6.2 Row → Facts

```
fn assertRow(
    row: *CompactRow,
    table: *CompactTable,
    kb: *KB,
    doc: *CompactDocument,
    config: *IngestionConfig,
    store: *KbStore,
    arena: *Arena,
    now: i32,
) void {
    var col: i32 = 0;
    while (col < row.column_count) : (col += 1) {
        const cell = &row.cells[@intCast(col)];
        const column_def = &table.columns[@intCast(col)];

        var fact = Fact{};

        if (cell.is_numeric and config.detect_numeric and
            cell.numeric_value >= std.math.minInt(i32) and
            cell.numeric_value <= std.math.maxInt(i32))
        {
            // Numeric value fits in Q16.v
            fact.tag = .value;
            fact.value = Q16.fromParts(@intCast(cell.numeric_value), 0, 0);
        } else {
            // Text value
            fact.tag = .text;
            // Store text in KB's text region, get offset
            const text = getTextFromDoc(cell, doc);
            const offset = storeTextInKb(text, kb, arena);
            // Encode offset and length in the Q16 fields
            fact.value.v = offset;
            fact.value.r0 = @intCast(cell.text_length);
            fact.value.r1 = @intCast(col); // column index for reconstruction
        }

        fact.provenance = Provenance.direct(
            config.source_type,
            kb.id,
            kb.facts_count,
            now,
        );

        store.assertFact(kb, fact, arena);
    }
}
```

### 6.3 Relationships → Prolog Rules

```
fn assertRelationships(
    doc: *CompactDocument,
    doc_kb: *KB,
    store: *KbStore,
    arena: *Arena,
    now: i32,
) void {
    // Create a relationships child KB for the rules
    const rel_kb = store.createKb(.{
        .name = "relationships",
        .parent_id = doc_kb.id,
        .max_rules = @intCast(doc.relationship_count * 3), // expansion for multi-target
        .visibility = 1,
    }, arena) orelse return;

    var i: i32 = 0;
    while (i < doc.relationship_count) : (i += 1) {
        const rel = &doc.relationships[@intCast(i)];
        const from_text = getTextSlice(doc, rel.from_offset, rel.from_length);
        const rel_type = getTextSlice(doc, rel.rel_offset, rel.rel_length);
        const to_text = getTextSlice(doc, rel.to_offset, rel.to_length);

        // Register atoms
        const from_atom = store.registerAtom(from_text, arena);
        const rel_atom = store.registerAtom(rel_type, arena);

        // Expand comma-separated and range targets
        var targets = std.mem.splitScalar(u8, to_text, ',');
        while (targets.next()) |target| {
            const trimmed = std.mem.trim(u8, target, " ");

            if (std.mem.indexOf(u8, trimmed, "-")) |dash| {
                // Range: "BC1-BC22" → expand to individual rules
                expandRange(trimmed, dash, from_atom, rel_atom, rel_kb, store, arena, now);
            } else {
                // Single target
                const to_atom = store.registerAtom(trimmed, arena);

                // Build: rel_type(from, to).
                // Head term: compound(rel_atom, [from_atom, to_atom])
                const head_term = Term.compound(
                    rel_atom,
                    store.allocTermPair(
                        Term.atom(from_atom),
                        Term.atom(to_atom),
                        arena,
                    ),
                    2,
                );

                const rule = Rule{
                    .id = store.nextGlobalId(),
                    .head = store.storeTerm(head_term, arena),
                    .body_offset = 0,
                    .body_count = 0,   // unconditional fact
                    .created_at = now,
                    .creator_session_id = .{}, // system ingestion
                };

                store.assertRule(rel_kb, rule, arena);
            }
        }
    }
}
```

---

## 7. Concrete Example: MATH-4 Ingestion

### 7.1 Source Compact Form (Fragment)

```
# principles(id|principle|rationale)
P1|Shared power-of-two denominator|all 22 constants as single integers over 2³³⁵
P2|Representation change not new math|same constants, same precision as MATH-2
P5|Minimal universal exponent|n=335 is minimal: at n=334 Catalan G fails

# basis_constants(id|name|numerator_over_2_335|p_digits|p_bits)
BC1|π|219886425873...|102|337
BC3|ln(2)|48514773537...|101|335
BC22|Catalan G|64110285111...|101|335

# relationships(from|rel|to)
P1|enables|AR1,AR2,AR3
P5|determined_by|BC1-BC22
BC1-BC22|verified_by|F1
```

### 7.2 Resulting KB Tree

```
root.knowledge.math.math_4                    (document KB)
    facts[0] = TAG_TEXT: decode_legend.id_prefixes → "P=principle, BC=basis_constant..."
    facts[1] = TAG_TEXT: decode_legend.rel_types → "enables|clarifies|motivates..."
    facts[2] = TAG_TEXT: section_index.I → "Abstract|P1,P2,P3"

root.knowledge.math.math_4.principles         (table KB)
    # Column schema:
    facts[0] = TAG_TEXT: col_0 → "id"
    facts[1] = TAG_TEXT: col_1 → "principle"
    facts[2] = TAG_TEXT: col_2 → "rationale"
    # Row P1:
    facts[3] = TAG_TEXT: v=text_offset, r0=2("P1".len), r1=0(col 0)
    facts[4] = TAG_TEXT: v=text_offset, r0=33, r1=1(col 1)
    facts[5] = TAG_TEXT: v=text_offset, r0=56, r1=2(col 2)
    # Row P2:
    facts[6] = TAG_TEXT: v=text_offset, r0=2, r1=0
    facts[7] = TAG_TEXT: v=text_offset, r0=33, r1=1
    facts[8] = TAG_TEXT: v=text_offset, r0=44, r1=2
    # Row P5:
    facts[9]  = TAG_TEXT: v=text_offset, r0=2, r1=0
    facts[10] = TAG_TEXT: v=text_offset, r0=25, r1=1
    facts[11] = TAG_TEXT: v=text_offset, r0=52, r1=2

root.knowledge.math.math_4.basis_constants    (table KB)
    # Column schema:
    facts[0-4] = column definitions
    # Row BC1:
    facts[5] = TAG_TEXT: "BC1"
    facts[6] = TAG_TEXT: "π"
    facts[7] = TAG_TEXT: "219886425873..."  (102-digit numerator, stays as text)
    facts[8] = TAG_VALUE: Q16{.v=102, .r0=0, .r1=0}  (p_digits)
    facts[9] = TAG_VALUE: Q16{.v=337, .r0=0, .r1=0}  (p_bits)
    # Row BC3:
    facts[10-14] = ...
    # Row BC22:
    facts[15-19] = ...

root.knowledge.math.math_4.relationships      (rules KB)
    # P1 enables AR1:
    rule[0] = enables(p1, ar1).
    # P1 enables AR2:
    rule[1] = enables(p1, ar2).
    # P1 enables AR3:
    rule[2] = enables(p1, ar3).
    # P5 determined_by BC1:
    rule[3] = determined_by(p5, bc1).
    # P5 determined_by BC2:
    rule[4] = determined_by(p5, bc2).
    # ... (expanded for BC1 through BC22)
    # BC1 verified_by F1:
    rule[25] = verified_by(bc1, f1).
    # ... (expanded for all 22)
```

### 7.3 What Training Sees

After ingestion, the GEMM and Prolog engine operate on structured data. When training runs on the `basis_constants` KB:

- The weight update sees clean, aligned facts: BC1 is π, 102 digits, 337 bits. BC3 is ln(2), 101 digits, 335 bits. No prose wrapper. No "In this section we present the basis constants..." filler.

- The Prolog engine can fire queries immediately: "What does P1 enable?" → `enables(p1, X)` → binds X to ar1, ar2, ar3. "What are all basis constants verified by F1?" → `verified_by(X, f1)` → binds X to bc1 through bc22.

- The confidence system knows the provenance chain: published paper → external LLM compaction (confidence override to published since the source was published, but with a derivation note that compaction was llm_generated) → ingestion → training.

### 7.4 Signal Density Comparison

The MATH-4 paper fragment above contains three principles, three basis constants, and three relationships — roughly 12 lines of compacted data.

The equivalent raw paper text for the same content would be approximately 3-4 pages of prose: an introduction explaining the power-of-two basis concept, a section motivating why 335 is the minimal exponent with a proof sketch, a table of basis constants with surrounding explanation, discussion of verification methodology, and relationship discussion in prose paragraphs.

The compacted form is ~500 bytes. The raw prose would be ~8,000-12,000 bytes. The signal (named concepts, exact values, typed relationships) is identical. The noise (prose, transitions, restatement, framing) is gone.

---

## 8. Provenance Chain

### 8.1 Two-Stage Confidence

The ingestion has a two-stage provenance chain:

**Stage 1:** The raw source document has its own confidence level. A peer-reviewed paper is `published` (80/100 = 52428). A web page is `web_search` (50/100 = 32768). A user statement is `user_stated` (70/100 = 45875).

**Stage 2:** The compaction itself is `llm_generated` (30/100 = 19660). An external LLM could hallucinate structure that isn't in the source.

The combined confidence is the minimum of the two stages:

```
fn ingestionConfidence(source: SourceType) Q16 {
    const source_conf = confidence_table[@intFromEnum(source)];
    const compaction_conf = confidence_table[@intFromEnum(SourceType.llm_generated)];

    // Take the minimum — chain is only as strong as weakest link
    if (Q16.compare(source_conf, compaction_conf) < 0) {
        return source_conf;
    }
    return compaction_conf;
}
```

For a published paper compacted by an external LLM, the ingested facts get confidence 30/100 (limited by the compaction stage). This is correct — the system doesn't trust that the LLM compacted accurately until the data is verified.

### 8.2 Confidence Promotion

After human review or automated verification confirms the compacted form matches the source, the confidence can be promoted:

```
CMD_KB_UPDATE root.knowledge.math.math_4.principles
    SET provenance.source_type = published
    WHERE provenance.source_type = llm_generated
```

This raises all facts in the KB from `llm_generated` (30/100) to `published` (80/100). The promotion is an explicit act — never automatic.

After training on the promoted data, the trained weights get `vdr_computation` confidence (100/100) with derivation provenance pointing back to the ingested facts.

---

## 9. Grammar Templates for Compacted Format

### 9.1 Table Grammar

The compacted format itself can be described as a VDR-Prolog grammar. This means the system can learn to produce and parse the format:

```
root.system.grammars.compact_table
    template: "# {table_name}({column_list})\n{rows}"
    slots:
        table_name: SLOT_TEXT
        column_list: SLOT_TEXT (pipe-separated column names)
        rows: SLOT_GRAMMAR (references compact_row grammar, repeated)

root.system.grammars.compact_row
    template: "{cell_0}|{cell_1}|{cell_2}|..."
    slots:
        cell_N: SLOT_TEXT or SLOT_VDR_VALUE or SLOT_KB_REF

root.system.grammars.compact_relationship
    template: "{from}|{rel_type}|{to}"
    slots:
        from: SLOT_KB_REF
        rel_type: SLOT_ENUM (enables|requires|prevents|...)
        to: SLOT_TEXT (may be comma-separated IDs)
```

These grammars serve two purposes. First, the system can validate incoming compacted documents against the grammar — a row that doesn't match the table's column structure is rejected. Second, the system can eventually generate compacted output from its own knowledge, using the grammar to ensure structural correctness.

### 9.2 Grammar Evolution

At L1 (full LLM), the system uses the grammar templates to validate and constrain its compaction output. At L2, the system invokes stored Prolog rules that implement specific compaction transforms (drop prose transitions, extract relationships, normalize column types). At L3, the compaction is fully rule-driven — the Prolog engine maps input facts to compacted output facts without invoking the LLM.

The grammar and rules for compaction are themselves trainable. As the system ingests more documents and the admin reviews the quality, the compaction rules improve. The L3 ratio for data ingestion can approach the same 93% target as general operations.

---

## 10. Batch Ingestion

### 10.1 Processing Queue

A batch ingestion runner processes a queue of compacted files:

```
root.ops.ingestion.queue
    facts[0] = TAG_TEXT: "/data/incoming/math_4.compact" (pending)
    facts[1] = TAG_TEXT: "/data/incoming/phys_5.compact" (pending)
    facts[2] = TAG_TEXT: "/data/incoming/ops_2.compact"  (completed)
```

The batch runner pops items from the queue, validates, ingests, and marks complete. Failed ingestions are marked with the specific validation error for admin review.

### 10.2 Idempotent Ingestion

Ingesting the same document twice should not create duplicates. The document KB's path is deterministic from the document name and target path. If the KB already exists at that path:

```
fn ingestDocument(doc, config, store, arena) Status {
    const existing = store.resolveByPath(config.target_path);
    if (existing) |kb| {
        if (kb.isFrozen()) {
            // Already ingested and frozen — skip
            return Status.ok();
        }
        // Exists but not frozen — re-ingest (overwrite)
        store.clearKb(kb, arena);
    }
    // ... proceed with ingestion
}
```

### 10.3 Incremental Updates

When a source document is updated and re-compacted, the new compacted form replaces the old one. The KB is unfrozen, cleared, re-ingested, and re-frozen. Training that incorporated the old data will be retrained on the next training cycle. The provenance chain tracks the update: new `timestamp`, same `source_kb_id`, updated facts.

---

## 11. Integration with Training

### 11.1 What Training Gets

After ingestion, a domain KB contains clean, structured facts with typed columns and Prolog rules for relationships. When `train(kb_id)` runs on this KB:

- **The v fields of TAG_VALUE facts** feed directly into the GEMM as weight-like structured data. Integer values (102, 337, 335 from the basis_constants example) become part of the KB's numeric signature.

- **The text facts** contribute to the KB's conceptual weight through their embeddings. The text "Shared power-of-two denominator" is a compact, meaningful string — not a paragraph of prose about why power-of-two denominators are useful.

- **The Prolog rules** are already usable without training. `enables(p1, ar1)` fires at L3 immediately. Training improves the GEMM cache for hybrid L2 operations where the LLM needs to reason about which rules to invoke.

### 11.2 Signal-to-Noise Before and After

| Metric | Raw Document | Compacted Form |
|--------|-------------|----------------|
| Size | 50,000 bytes | 5,000 bytes |
| Named concepts | 22 (buried in prose) | 22 (one per row) |
| Typed relationships | 0 (implicit in text) | 47 (explicit rules) |
| Noise tokens | ~4,000 | ~0 |
| Structure | Paragraphs | Typed tables |
| Parseable without LLM | No | Yes (pipe split) |
| Training signal density | ~5% | ~95% |

The GEMM trains on 10× less data to learn the same structure. The Prolog engine starts with 47 immediately-fireable rules instead of zero. The confidence system has explicit provenance instead of "somewhere in this 50-page document."

---

## 12. File Format for Compacted Documents

### 12.1 .compact File

The compacted document is stored as a plain text file with `.compact` extension. UTF-8 encoding. Unix line endings. The format is the pipe-delimited table format described in Section 2. No binary. No compression. The file is human-readable and diffable.

```
data/
├── incoming/           ← compacted files waiting for ingestion
│   ├── math_4.compact
│   ├── phys_5.compact
│   └── ops_2.compact
├── ingested/           ← compacted files after successful ingestion (archive)
│   └── math_4.compact
├── failed/             ← compacted files that failed validation
│   └── bad_format.compact
├── kb/                 ← persisted KB data (byte-sliced structs)
├── weights/            ← persisted weight data
├── manifest.dat
└── snapshots/
```

After successful ingestion, the `.compact` file is moved to `ingested/` for archival. The data now lives in KBs. The `.compact` file is the source artifact — it can be re-ingested if the KBs are lost, or diffed against a new version of the same document to see what changed.
