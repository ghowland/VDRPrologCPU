// ============================================================
// vdr_compact_loader.zig
// Parses .md VDR-COMPACT files into arena-allocated structures.
// All storage in arena. Parsing via cursor over one TextBig.
// ============================================================

const std = @import("std");
const types = @import("vdr_types.zig");

const Arena = types.Arena;
const RelationType = types.RelationType;

// ============================================================
// Constants
// ============================================================

const MAX_TABLES: usize = 64;
const MAX_COLUMNS: usize = 32;
const MAX_ROWS: usize = 4096;
const MAX_RELATIONSHIPS: usize = 8192;
const MAX_RELATION_MAPPINGS: usize = 128;
const MAX_NAME: usize = 64;

// ============================================================
// Types
// ============================================================

pub const TableInfo = struct {
    name: [MAX_NAME]u8 = [_]u8{0} ** MAX_NAME,
    name_len: usize = 0,

    col_names: [MAX_COLUMNS][MAX_NAME]u8 = undefined,
    col_name_lens: [MAX_COLUMNS]usize = [_]usize{0} ** MAX_COLUMNS,
    col_count: usize = 0,

    row_offsets: []i32 = &.{},
    row_lens: []i32 = &.{},
    eid_offsets: []i32 = &.{},
    eid_lens: []i32 = &.{},
    row_count: usize = 0,

    pub fn nameSlice(self: *const TableInfo) []const u8 {
        return self.name[0..self.name_len];
    }

    pub fn colName(self: *const TableInfo, col: usize) []const u8 {
        if (col >= self.col_count) return "";
        return self.col_names[col][0..self.col_name_lens[col]];
    }

    pub fn rowText(self: *const TableInfo, row: usize, base: [*]u8) []const u8 {
        if (row >= self.row_count) return "";
        const off: usize = @intCast(self.row_offsets[row]);
        const len: usize = @intCast(self.row_lens[row]);
        return (base + off)[0..len];
    }

    pub fn entityId(self: *const TableInfo, row: usize, base: [*]u8) []const u8 {
        if (row >= self.row_count) return "";
        const off: usize = @intCast(self.eid_offsets[row]);
        const len: usize = @intCast(self.eid_lens[row]);
        return (base + off)[0..len];
    }
};

pub const RawRelationship = struct {
    from: [MAX_NAME]u8 = [_]u8{0} ** MAX_NAME,
    from_len: usize = 0,
    rel_name: [MAX_NAME]u8 = [_]u8{0} ** MAX_NAME,
    rel_name_len: usize = 0,
    to: [MAX_NAME]u8 = [_]u8{0} ** MAX_NAME,
    to_len: usize = 0,
    canonical_type: RelationType = .unknown,

    pub fn fromSlice(self: *const RawRelationship) []const u8 {
        return self.from[0..self.from_len];
    }
    pub fn relSlice(self: *const RawRelationship) []const u8 {
        return self.rel_name[0..self.rel_name_len];
    }
    pub fn toSlice(self: *const RawRelationship) []const u8 {
        return self.to[0..self.to_len];
    }
};

pub const RelationMapping = struct {
    doc_name: [MAX_NAME]u8 = [_]u8{0} ** MAX_NAME,
    doc_name_len: usize = 0,
    canonical_name: [MAX_NAME]u8 = [_]u8{0} ** MAX_NAME,
    canonical_name_len: usize = 0,
    canonical_type: RelationType = .unknown,

    pub fn docSlice(self: *const RelationMapping) []const u8 {
        return self.doc_name[0..self.doc_name_len];
    }
};

pub const LoadResult = struct {
    tables: []TableInfo = &.{},
    table_count: usize = 0,

    relationships: []RawRelationship = &.{},
    relationship_count: usize = 0,

    mappings: []RelationMapping = &.{},
    mapping_count: usize = 0,

    text_store_start: usize = 0,
    text_store_used: usize = 0,

    total_rows: usize = 0,
    skipped_rows: usize = 0,
    file_bytes: usize = 0,
    file_path: [256]u8 = [_]u8{0} ** 256,
    file_path_len: usize = 0,

    ok: bool = false,

    pub fn pathSlice(self: *const LoadResult) []const u8 {
        return self.file_path[0..self.file_path_len];
    }
};

// ============================================================
// Public API
// ============================================================

pub fn loadCompactFile(arena: *Arena, path: []const u8) ?*LoadResult {
    // Allocate result in arena
    const result = arena.allocTyped(LoadResult) orelse return null;
    result.* = LoadResult{};

    const plen = @min(path.len, 256);
    @memcpy(result.file_path[0..plen], path[0..plen]);
    result.file_path_len = plen;

    // Allocate backing arrays in arena
    result.tables = arena.allocSlice(TableInfo, MAX_TABLES) orelse return null;
    for (0..MAX_TABLES) |i| {
        result.tables[i] = TableInfo{};
        for (0..MAX_COLUMNS) |c| {
            result.tables[i].col_names[c] = [_]u8{0} ** MAX_NAME;
        }
    }

    result.relationships = arena.allocSlice(RawRelationship, MAX_RELATIONSHIPS) orelse return null;
    for (0..MAX_RELATIONSHIPS) |i| {
        result.relationships[i] = RawRelationship{};
    }

    result.mappings = arena.allocSlice(RelationMapping, MAX_RELATION_MAPPINGS) orelse return null;
    for (0..MAX_RELATION_MAPPINGS) |i| {
        result.mappings[i] = RelationMapping{};
    }

    // Read file
    const file = std.fs.cwd().openFile(path, .{}) catch |err| {
        std.debug.print("compact_loader: open failed '{s}': {}\n", .{ path, err });
        return null;
    };
    defer file.close();

    const stat = file.stat() catch return null;
    if (stat.size == 0 or stat.size > 100 * 1024) {
        std.debug.print("compact_loader: file size {} out of range\n", .{stat.size});
        return null;
    }

    // Read into a stack buffer — file is <=100KB
    var buf: [100 * 1024]u8 = undefined;
    const n = file.readAll(&buf) catch return null;
    if (n == 0) return null;

    const content = buf[0..n];
    result.file_bytes = n;
    result.text_store_start = arena.cursor;

    // Parse — cursor walks content
    var pos: usize = 0;
    var current_table: ?usize = null;
    var in_decode_legend: bool = false;
    var in_relationships: bool = false;
    var in_relation_mapping: bool = false;

    while (pos < content.len) {
        // Find end of line
        const rest = content[pos..];
        const nl = std.mem.indexOfScalar(u8, rest, '\n');
        const line_len = nl orelse rest.len;
        var line = rest[0..line_len];

        // Advance past newline
        pos += line_len;
        if (nl != null) pos += 1;

        // Strip \r
        if (line.len > 0 and line[line.len - 1] == '\r') {
            line = line[0 .. line.len - 1];
        }

        if (line.len == 0) continue;

        // Header line: # something
        if (line.len > 2 and line[0] == '#' and line[1] == ' ') {
            const htext = std.mem.trimLeft(u8, line[2..], " ");

            // decode_legend — skip until next header
            if (htext.len >= 13 and std.mem.startsWith(u8, htext, "decode_legend")) {
                in_decode_legend = true;
                in_relationships = false;
                in_relation_mapping = false;
                current_table = null;
                continue;
            }

            // Try table header: name(col|col|col)
            const paren_open = std.mem.indexOfScalar(u8, htext, '(');
            const paren_close = std.mem.lastIndexOfScalar(u8, htext, ')');

            if (paren_open != null and paren_close != null and paren_close.? > paren_open.?) {
                in_decode_legend = false;
                const tname = std.mem.trim(u8, htext[0..paren_open.?], " ");
                const cols_text = htext[paren_open.? + 1 .. paren_close.?];

                // Check special sections
                if (std.mem.eql(u8, tname, "relationships")) {
                    in_relationships = true;
                    in_relation_mapping = false;
                    current_table = null;
                    continue;
                }
                if (std.mem.eql(u8, tname, "relation_mapping")) {
                    in_relation_mapping = true;
                    in_relationships = false;
                    current_table = null;
                    continue;
                }

                in_relationships = false;
                in_relation_mapping = false;

                if (result.table_count >= MAX_TABLES) {
                    current_table = null;
                    continue;
                }

                const tidx = result.table_count;
                var tbl = &result.tables[tidx];

                // Store table name
                const nlen = @min(tname.len, MAX_NAME);
                @memcpy(tbl.name[0..nlen], tname[0..nlen]);
                tbl.name_len = nlen;

                // Parse column names
                tbl.col_count = 0;
                var cpos: usize = 0;
                while (cpos < cols_text.len and tbl.col_count < MAX_COLUMNS) {
                    const cpipe = std.mem.indexOfScalarPos(u8, cols_text, cpos, '|');
                    const cend = cpipe orelse cols_text.len;
                    const cname = std.mem.trim(u8, cols_text[cpos..cend], " ");

                    if (cname.len > 0) {
                        const cl = @min(cname.len, MAX_NAME);
                        @memcpy(tbl.col_names[tbl.col_count][0..cl], cname[0..cl]);
                        tbl.col_name_lens[tbl.col_count] = cl;
                        tbl.col_count += 1;
                    }

                    if (cpipe) |cp| {
                        cpos = cp + 1;
                    } else break;
                }

                // Allocate per-table row arrays in arena
                tbl.row_offsets = arena.allocSlice(i32, MAX_ROWS) orelse {
                    current_table = null;
                    continue;
                };
                tbl.row_lens = arena.allocSlice(i32, MAX_ROWS) orelse {
                    current_table = null;
                    continue;
                };
                tbl.eid_offsets = arena.allocSlice(i32, MAX_ROWS) orelse {
                    current_table = null;
                    continue;
                };
                tbl.eid_lens = arena.allocSlice(i32, MAX_ROWS) orelse {
                    current_table = null;
                    continue;
                };

                current_table = tidx;
                result.table_count += 1;
            }
            // else: plain comment, skip
            continue;
        }

        // Skip decode_legend body
        if (in_decode_legend) continue;

        // Data rows must have a pipe
        if (std.mem.indexOfScalar(u8, line, '|') == null) continue;

        // Relationship mapping rows
        if (in_relation_mapping) {
            if (line[0] == '#') continue;
            parseRelMappingLine(line, result);
            continue;
        }

        // Relationship rows
        if (in_relationships) {
            if (line[0] == '#') continue;
            parseRelLine(line, result);
            continue;
        }

        // Data row for current table
        if (current_table) |tidx| {
            storeDataRow(line, &result.tables[tidx], arena, result);
        }
    }

    // Resolve canonical types on relationships
    resolveRelationTypes(result);

    result.text_store_used = arena.cursor - result.text_store_start;
    result.ok = true;
    return result;
}

// ============================================================
// Data row storage
// ============================================================

fn storeDataRow(line: []const u8, tbl: *TableInfo, arena: *Arena, result: *LoadResult) void {
    if (tbl.row_count >= MAX_ROWS) {
        result.skipped_rows += 1;
        return;
    }

    // Copy line text into arena
    const text = arena.allocSlice(u8, line.len) orelse {
        result.skipped_rows += 1;
        return;
    };
    @memcpy(text, line);

    const ri = tbl.row_count;
    tbl.row_offsets[ri] = @intCast(@intFromPtr(text.ptr) - @intFromPtr(arena.base));
    tbl.row_lens[ri] = @intCast(line.len);

    // Extract entity ID — text before first pipe
    const pipe = std.mem.indexOfScalar(u8, line, '|') orelse {
        result.skipped_rows += 1;
        return;
    };
    const eid = std.mem.trim(u8, line[0..pipe], " ");
    const eid_bytes = arena.allocSlice(u8, eid.len) orelse {
        result.skipped_rows += 1;
        return;
    };
    @memcpy(eid_bytes, eid);

    tbl.eid_offsets[ri] = @intCast(@intFromPtr(eid_bytes.ptr) - @intFromPtr(arena.base));
    tbl.eid_lens[ri] = @intCast(eid.len);

    tbl.row_count += 1;
    result.total_rows += 1;
}

// ============================================================
// Relationship line parsing
// ============================================================

fn parseRelLine(line: []const u8, result: *LoadResult) void {
    // from|rel|to  — to can be comma-separated
    const p1 = std.mem.indexOfScalar(u8, line, '|') orelse return;
    const after1 = line[p1 + 1 ..];
    const p2 = std.mem.indexOfScalar(u8, after1, '|') orelse return;

    const from = std.mem.trim(u8, line[0..p1], " ");
    const rel = std.mem.trim(u8, after1[0..p2], " ");
    const to_full = std.mem.trim(u8, after1[p2 + 1 ..], " ");

    if (from.len == 0 or rel.len == 0 or to_full.len == 0) return;

    // Expand comma-separated targets
    var tpos: usize = 0;
    while (tpos < to_full.len) {
        const comma = std.mem.indexOfScalarPos(u8, to_full, tpos, ',');
        const tend = comma orelse to_full.len;
        const single = std.mem.trim(u8, to_full[tpos..tend], " ");

        if (single.len > 0 and result.relationship_count < MAX_RELATIONSHIPS) {
            var r = &result.relationships[result.relationship_count];
            r.* = RawRelationship{};

            const fl = @min(from.len, MAX_NAME);
            @memcpy(r.from[0..fl], from[0..fl]);
            r.from_len = fl;

            const rl = @min(rel.len, MAX_NAME);
            @memcpy(r.rel_name[0..rl], rel[0..rl]);
            r.rel_name_len = rl;

            const tl = @min(single.len, MAX_NAME);
            @memcpy(r.to[0..tl], single[0..tl]);
            r.to_len = tl;

            result.relationship_count += 1;
        }

        if (comma) |c| {
            tpos = c + 1;
        } else break;
    }
}

// ============================================================
// Relation mapping line parsing
// ============================================================

fn parseRelMappingLine(line: []const u8, result: *LoadResult) void {
    // doc_rel|canonical_rel|notes
    const p1 = std.mem.indexOfScalar(u8, line, '|') orelse return;
    const after1 = line[p1 + 1 ..];
    const p2 = std.mem.indexOfScalar(u8, after1, '|');
    const canon_end = p2 orelse after1.len;

    const doc = std.mem.trim(u8, line[0..p1], " ");
    const canon = std.mem.trim(u8, after1[0..canon_end], " ");

    if (doc.len == 0 or canon.len == 0) return;
    if (result.mapping_count >= MAX_RELATION_MAPPINGS) return;

    var m = &result.mappings[result.mapping_count];
    m.* = RelationMapping{};

    const dl = @min(doc.len, MAX_NAME);
    @memcpy(m.doc_name[0..dl], doc[0..dl]);
    m.doc_name_len = dl;

    const cl = @min(canon.len, MAX_NAME);
    @memcpy(m.canonical_name[0..cl], canon[0..cl]);
    m.canonical_name_len = cl;

    m.canonical_type = nameToRelationType(canon);

    result.mapping_count += 1;
}

// ============================================================
// Resolve relationship types
// ============================================================

fn resolveRelationTypes(result: *LoadResult) void {
    for (0..result.relationship_count) |i| {
        const rname = result.relationships[i].relSlice();
        var resolved = nameToRelationType(rname);

        if (resolved == .unknown) {
            // Try via mapping table
            for (0..result.mapping_count) |m| {
                if (std.mem.eql(u8, result.mappings[m].docSlice(), rname)) {
                    resolved = result.mappings[m].canonical_type;
                    break;
                }
            }
        }

        result.relationships[i].canonical_type = resolved;
    }
}

fn nameToRelationType(name: []const u8) RelationType {
    const map = .{
        .{ "enables", RelationType.enables },
        .{ "requires", RelationType.requires },
        .{ "prevents", RelationType.prevents },
        .{ "implements", RelationType.implements },
        .{ "extends", RelationType.extends },
        .{ "overrides", RelationType.overrides },
        .{ "validates", RelationType.validates },
        .{ "verified_by", RelationType.verified_by },
        .{ "contradicts", RelationType.contradicts },
        .{ "causes", RelationType.causes },
        .{ "determined_by", RelationType.determined_by },
        .{ "depends_on", RelationType.depends_on },
        .{ "equivalent_to", RelationType.equivalent_to },
        .{ "approximates", RelationType.approximates },
        .{ "specializes", RelationType.specializes },
        .{ "generalizes", RelationType.generalizes },
        .{ "part_of", RelationType.part_of },
        .{ "contains", RelationType.contains },
        .{ "follows", RelationType.follows },
        .{ "precedes", RelationType.precedes },
        .{ "forces", RelationType.forces },
        .{ "overcomes", RelationType.overcomes },
        .{ "triggered_by", RelationType.triggered_by },
        .{ "explains", RelationType.explains },
        .{ "replaces", RelationType.replaces },
        .{ "motivates", RelationType.motivates },
        .{ "limits", RelationType.limits },
        .{ "confers", RelationType.confers },
        .{ "unifies", RelationType.unifies },
        .{ "foundation_for", RelationType.foundation_for },
        .{ "constrains", RelationType.constrains },
        .{ "produces", RelationType.produces },
        .{ "spans", RelationType.spans },
        .{ "borders", RelationType.borders },
        .{ "influences", RelationType.influences },
        .{ "amplifies", RelationType.amplifies },
        .{ "regulates", RelationType.regulates },
        .{ "supplies", RelationType.supplies },
        .{ "flows_to", RelationType.flows_to },
        .{ "activates", RelationType.activates },
        .{ "encoded_by", RelationType.encoded_by },
        .{ "mediates", RelationType.mediates },
        .{ "mitigated_by", RelationType.mitigated_by },
        .{ "degrades", RelationType.degrades },
        .{ "favors", RelationType.favors },
        .{ "solves", RelationType.solves },
        .{ "bounded_by", RelationType.bounded_by },
        .{ "simplifies", RelationType.simplifies },
        .{ "maintains", RelationType.maintains },
        .{ "reverses", RelationType.reverses },
        .{ "alternative_to", RelationType.alternative_to },
        .{ "hazard_of", RelationType.hazard_of },
        .{ "indicates", RelationType.indicates },
        .{ "develops", RelationType.develops },
        .{ "complements", RelationType.complements },
        .{ "models", RelationType.models },
        .{ "founded", RelationType.founded },
        .{ "opposes", RelationType.opposes },
        .{ "responds_to", RelationType.responds_to },
        .{ "critiques", RelationType.critiques },
        .{ "synthesizes", RelationType.synthesizes },
        .{ "transmits", RelationType.transmits },
        .{ "parallel_to", RelationType.parallel_to },
        .{ "traverses", RelationType.traverses },
        .{ "removes", RelationType.removes },
        .{ "protects", RelationType.protects },
        .{ "threatens", RelationType.threatens },
        .{ "evolves_to", RelationType.evolves_to },
        .{ "connects_to", RelationType.connects_to },
        .{ "propagates_via", RelationType.propagates_via },
        .{ "contrasts", RelationType.contrasts },
        .{ "disrupts", RelationType.disrupts },
        .{ "frames", RelationType.frames },
        .{ "organizes", RelationType.organizes },
        .{ "controls", RelationType.controls },
        .{ "input_to", RelationType.input_to },
        .{ "instance_of", RelationType.instance_of },
        .{ "has_type", RelationType.has_type },
        .{ "named", RelationType.named },
        .{ "aliases", RelationType.aliases },
        .{ "references", RelationType.references },
        .{ "assigns", RelationType.assigns },
        .{ "binds_to", RelationType.binds_to },
        .{ "returns", RelationType.returns },
        .{ "accepts", RelationType.accepts },
        .{ "emits", RelationType.emits },
        .{ "complement_of", RelationType.complement_of },
        .{ "constructed_from", RelationType.constructed_from },
        .{ "knowledge_base", RelationType.knowledge_base },
        .{ "domain", RelationType.domain },
        .{ "scoped_to", RelationType.scoped_to },
        .{ "context_of", RelationType.context_of },
        .{ "defined_in", RelationType.defined_in },
        .{ "documented_by", RelationType.documented_by },
        .{ "example_of", RelationType.example_of },
        .{ "derived_from", RelationType.derived_from },
        .{ "composed_of", RelationType.composed_of },
        .{ "decomposes_to", RelationType.decomposes_to },
        .{ "transforms_to", RelationType.transforms_to },
        .{ "measured_by", RelationType.measured_by },
        .{ "studies", RelationType.studies },
        .{ "distinguishes", RelationType.distinguishes },
        .{ "anti_pattern_of", RelationType.anti_pattern_of },
        .{ "agent_of", RelationType.agent_of },
        .{ "object_of", RelationType.object_of },
        .{ "instrument_of", RelationType.instrument_of },
        .{ "location_of", RelationType.location_of },
        .{ "destination_of", RelationType.destination_of },
        .{ "source_of", RelationType.source_of },
        .{ "purpose_of", RelationType.purpose_of },
        .{ "result_of", RelationType.result_of },
        .{ "manner_of", RelationType.manner_of },
        .{ "time_of", RelationType.time_of },
        .{ "if_then", RelationType.if_then },
        .{ "unless", RelationType.unless },
        .{ "while_true", RelationType.while_true },
        .{ "for_each", RelationType.for_each },
        .{ "exists", RelationType.exists },
        .{ "not_exists", RelationType.not_exists },
        .{ "and_also", RelationType.and_also },
        .{ "or_else", RelationType.or_else },
        .{ "greater_than", RelationType.greater_than },
        .{ "less_than", RelationType.less_than },
        .{ "governs", RelationType.governs },
        .{ "applies_to", RelationType.applies_to },
        .{ "violates", RelationType.violates },
        .{ "agrees_with", RelationType.agrees_with },
        .{ "selects", RelationType.selects },
        .{ "modifies", RelationType.modifies },
        .{ "heads", RelationType.heads },
        .{ "complements_grammar", RelationType.complements_grammar },
        .{ "subcategorizes", RelationType.subcategorizes },
        .{ "distributes_as", RelationType.distributes_as },
        .{ "manages", RelationType.manages },
        .{ "isolates", RelationType.isolates },
        .{ "orchestrates", RelationType.orchestrates },
        .{ "generates", RelationType.generates },
        .{ "inspects", RelationType.inspects },
        // common doc-local aliases
        .{ "composes", RelationType.composed_of },
        .{ "derives_from", RelationType.derived_from },
        .{ "inverse_of", RelationType.complement_of },
        .{ "subtype_of", RelationType.specializes },
        .{ "cross_ref", RelationType.references },
        .{ "component_of", RelationType.part_of },
    };

    inline for (map) |entry| {
        if (std.mem.eql(u8, name, entry[0])) return entry[1];
    }

    return .unknown;
}

// ============================================================
// Printing
// ============================================================

pub fn printLoadStats(result: *const LoadResult) void {
    std.debug.print("\n=== Compact Load: {s} ===\n", .{result.pathSlice()});
    std.debug.print("  file size:       {} bytes\n", .{result.file_bytes});
    std.debug.print("  tables:          {}\n", .{result.table_count});
    std.debug.print("  total rows:      {}\n", .{result.total_rows});
    std.debug.print("  skipped rows:    {}\n", .{result.skipped_rows});
    std.debug.print("  relationships:   {}\n", .{result.relationship_count});
    std.debug.print("  rel mappings:    {}\n", .{result.mapping_count});
    std.debug.print("  arena text used: {} bytes\n", .{result.text_store_used});

    for (0..result.table_count) |i| {
        const t = &result.tables[i];
        std.debug.print("  table '{s}': {} cols, {} rows\n", .{
            t.nameSlice(),
            t.col_count,
            t.row_count,
        });
    }

    var resolved: usize = 0;
    var unresolved: usize = 0;
    for (0..result.relationship_count) |i| {
        if (result.relationships[i].canonical_type != .unknown) {
            resolved += 1;
        } else {
            unresolved += 1;
        }
    }
    std.debug.print("  relations resolved: {}, unresolved: {}\n", .{ resolved, unresolved });

    if (unresolved > 0) {
        var printed: usize = 0;
        for (0..result.relationship_count) |i| {
            if (result.relationships[i].canonical_type == .unknown and printed < 5) {
                std.debug.print("    unresolved: '{s}' ({s} -> {s})\n", .{
                    result.relationships[i].relSlice(),
                    result.relationships[i].fromSlice(),
                    result.relationships[i].toSlice(),
                });
                printed += 1;
            }
        }
        if (unresolved > 5) {
            std.debug.print("    ... and {} more\n", .{unresolved - 5});
        }
    }
}

pub fn printSampleRows(result: *const LoadResult, arena: *const Arena, max_tables: usize, max_rows: usize) void {
    const show_tables = @min(result.table_count, max_tables);
    for (0..show_tables) |ti| {
        const t = &result.tables[ti];
        std.debug.print("\n  --- {s} ({} cols: ", .{ t.nameSlice(), t.col_count });
        for (0..t.col_count) |c| {
            if (c > 0) std.debug.print(", ", .{});
            std.debug.print("{s}", .{t.colName(c)});
        }
        std.debug.print(") ---\n", .{});

        const show_rows = @min(t.row_count, max_rows);
        for (0..show_rows) |ri| {
            std.debug.print("    [{s}] {s}\n", .{
                t.entityId(ri, arena.base),
                t.rowText(ri, arena.base),
            });
        }
        if (t.row_count > max_rows) {
            std.debug.print("    ... {} more rows\n", .{t.row_count - max_rows});
        }
    }
}
