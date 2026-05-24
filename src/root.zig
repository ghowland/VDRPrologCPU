const std = @import("std");
const config_mod = @import("vdr_config.zig");
const types = @import("vdr_types.zig");

const vdr_arena = @import("vdr_arena.zig");
const resetable_memory = @import("resetable_memory.zig");
const vdr_http = @import("vdr_http.zig");
const compact_loader = @import("vdr_compact_loader.zig");
const kb_config = @import("vdr_kb_config.zig");
const vdr_gemm = @import("vdr_gemm.zig");

// Types
const TextBig = @import("text_big.zig").TextBig;
const text_small = @import("text_small.zig");
const TextSmall = text_small.TextSmall;

pub fn main() void {
    std.debug.print("VDR-Prolog kernel starting\n", .{});

    const result = config_mod.loadConfig("config.json");

    if (result.error_code != .ok) {
        std.debug.print("config: fatal error code {}\n", .{@intFromEnum(result.error_code)});
        std.process.exit(1);
    }

    const cfg = result.config;

    std.debug.print("=== SystemConfig ===\n", .{});
    std.debug.print("  n_cores:                        {}\n", .{cfg.n_cores});
    std.debug.print("  http_port:                      {}\n", .{cfg.http_port});
    std.debug.print("  global_arena_bytes:             {}\n", .{cfg.global_arena_bytes});
    std.debug.print("  per_core_arena_bytes:           {}\n", .{cfg.per_core_arena_bytes});
    std.debug.print("  max_total_kbs:                  {}\n", .{cfg.max_total_kbs});
    std.debug.print("  max_total_facts:                {}\n", .{cfg.max_total_facts});
    std.debug.print("  max_total_rules:                {}\n", .{cfg.max_total_rules});
    std.debug.print("  max_total_terms:                {}\n", .{cfg.max_total_terms});
    std.debug.print("  max_sessions_per_core:          {}\n", .{cfg.max_sessions_per_core});
    std.debug.print("  max_ephemeral_kbs_per_session:  {}\n", .{cfg.max_ephemeral_kbs_per_session});
    std.debug.print("  max_facts_per_session_kb:       {}\n", .{cfg.max_facts_per_session_kb});
    std.debug.print("  default_max_turns:              {}\n", .{cfg.default_max_turns});
    std.debug.print("  auto_snapshot_interval:         {}\n", .{cfg.auto_snapshot_interval});
    std.debug.print("  max_runners:                    {}\n", .{cfg.max_runners});
    std.debug.print("  audit_ring_capacity:            {}\n", .{cfg.audit_ring_capacity});
    std.debug.print("  default_visibility:             {}\n", .{cfg.default_visibility});
    std.debug.print("  relation_index_rebuild_interval:{}\n", .{cfg.relation_index_rebuild_interval});

    // Model config
    std.debug.print("  model.n_layers:                 {}\n", .{cfg.model.n_layers});
    std.debug.print("  model.d_model:                  {}\n", .{cfg.model.d_model});
    std.debug.print("  model.n_heads:                  {}\n", .{cfg.model.n_heads});
    std.debug.print("  model.d_head:                   {}\n", .{cfg.model.d_head});
    std.debug.print("  model.vocab_size:               {}\n", .{cfg.model.vocab_size});
    std.debug.print("  model.mlp_dim:                  {}\n", .{cfg.model.mlp_dim});
    std.debug.print("  model.max_seq_len:              {}\n", .{cfg.model.max_seq_len});
    std.debug.print("  model.totalParams:              {}\n", .{cfg.model.totalParams()});
    std.debug.print("  model.weightBytes:              {}\n", .{cfg.model.weightBytes()});

    // Sampling config
    std.debug.print("  sampling.mode:                  {}\n", .{@intFromEnum(cfg.sampling.mode)});
    std.debug.print("  sampling.temperature_v:         {}\n", .{cfg.sampling.temperature_v});
    std.debug.print("  sampling.top_k:                 {}\n", .{cfg.sampling.top_k});
    std.debug.print("  sampling.top_p_v:               {}\n", .{cfg.sampling.top_p_v});

    // Prolog config
    std.debug.print("  prolog.max_depth:               {}\n", .{cfg.prolog.max_depth});
    std.debug.print("  prolog.max_bindings:            {}\n", .{cfg.prolog.max_bindings});
    std.debug.print("  prolog.max_results:             {}\n", .{cfg.prolog.max_results});
    std.debug.print("  prolog.max_inheritance_depth:   {}\n", .{cfg.prolog.max_inheritance_depth});

    // Create global arena (PR4: arena-only memory, AM1: global arena)
    const global_arena = vdr_arena.create(@intCast(cfg.global_arena_bytes)) orelse {
        std.debug.print("fatal: cannot allocate global arena ({} bytes)\n", .{cfg.global_arena_bytes});
        std.process.exit(1);
    };

    std.debug.print("=== Global Arena ===\n", .{});
    std.debug.print("  size:  {} bytes\n", .{global_arena.size});
    std.debug.print("  used:  {} bytes\n", .{global_arena.usedBytes()});
    std.debug.print("  free:  {} bytes\n", .{global_arena.freeBytes()});

    // Create resetable scratch memory for Text formatting (1MB)
    if (!resetable_memory.create(1024 * 1024)) {
        std.debug.print("fatal: cannot allocate resetable memory\n", .{});
        std.process.exit(1);
    }

    std.debug.print("=== Resetable Memory ===\n", .{});
    if (resetable_memory.getArena()) |scratch| {
        std.debug.print("  size:  {} bytes\n", .{scratch.size});
        std.debug.print("  used:  {} bytes\n", .{scratch.usedBytes()});
        std.debug.print("  free:  {} bytes\n", .{scratch.freeBytes()});
    }

    std.debug.print("=== config loaded OK ===\n", .{});
    std.debug.print("VDR-Prolog kernel ready\n", .{});

    // Load KB Test
    const config = load_kbs(global_arena) orelse return;

    // Create and Populate tree
    create_kb_tree(global_arena, config);
    populate_kb_data(global_arena, config);

    // Populate KBData columns and verify
    populate_kb_data_columns(global_arena, config);
    verify_kb_data_lookup(config);

    print_sample_data_entry(config);

    // // Test the GEMM
    // vdr_gemm_test.testGemm(global_arena, config);

    // More Real
    vdr_gemm.testGemm(global_arena, config);

    // Start HTTP server on unpinned thread (HT1: non-pinned)
    const http_port: u16 = @intCast(cfg.http_port);
    const http_thread = std.Thread.spawn(.{}, vdr_http.run, .{http_port}) catch {
        std.debug.print("fatal: cannot spawn HTTP thread\n", .{});
        std.process.exit(1);
    };

    std.debug.print("http: server thread spawned on port {}\n", .{http_port});

    // Wait for HTTP thread (blocks until shutdown)
    http_thread.join();

    // Cleanup
    resetable_memory.destroy();
    vdr_arena.destroy(global_arena);
    std.debug.print("VDR-Prolog kernel shutdown\n", .{});
}

fn load_kbs(global_arena: *types.Arena) ?*kb_config.KbConfig {
    std.debug.print("\n=== Loading KB config ===\n", .{});

    // Load or create kb.json mapping
    const config = kb_config.loadKbConfig(global_arena) orelse {
        std.debug.print("fatal: cannot allocate kb config\n", .{});
        return null;
    };

    std.debug.print("\n=== Loading compact files ===\n", .{});

    const dir_path = "data/kb_raw";
    var dir = std.fs.cwd().openDir(dir_path, .{ .iterate = true }) catch {
        std.debug.print("compact_loader: cannot open directory '{s}'\n", .{dir_path});
        return null;
    };
    defer dir.close();

    var total_tables: usize = 0;
    var total_rows: usize = 0;
    var total_rels: usize = 0;
    var total_bytes: usize = 0;
    var files_loaded: usize = 0;
    var files_skipped: usize = 0;
    var new_entries: usize = 0;

    var loaded_results: [256]?*compact_loader.LoadResult = [_]?*compact_loader.LoadResult{null} ** 256;

    var iter = dir.iterate();
    while (iter.next() catch null) |entry| {
        if (entry.kind != .file) continue;

        const name = entry.name;
        if (name.len < 4) continue;
        if (!std.mem.eql(u8, name[name.len - 3 ..], ".md")) continue;

        // Build full path
        var path_buf: [512]u8 = undefined;
        const prefix = dir_path ++ "/";
        if (prefix.len + name.len > 512) continue;
        @memcpy(path_buf[0..prefix.len], prefix);
        @memcpy(path_buf[prefix.len .. prefix.len + name.len], name);
        const full_path = path_buf[0 .. prefix.len + name.len];

        // Check if this file has a mount point in kb.json
        if (config.dottedPathFor(full_path)) |dotted| {
            std.debug.print("kb_config: {s} -> {s}\n", .{ full_path, dotted });
        } else {
            // New file — assign root.N placeholder
            _ = config.addUnmapped(full_path);
            new_entries += 1;
            std.debug.print("kb_config: NEW {s} -> root.{}\n", .{ full_path, config.next_unmapped - 1 });
        }

        if (compact_loader.loadCompactFile(global_arena, full_path)) |result| {
            compact_loader.printLoadStats(result);
            if (config.findByFile(full_path)) |idx| {
                config.entries[idx].load_result = result;
            }
            if (files_loaded < 256) {
                loaded_results[files_loaded] = result;
            }
            total_tables += result.table_count;
            total_rows += result.total_rows;
            total_rels += result.relationship_count;
            total_bytes += result.file_bytes;
            files_loaded += 1;
        } else {
            std.debug.print("compact_loader: FAILED to load '{s}'\n", .{full_path});
            files_skipped += 1;
        }
    }

    // Save updated kb.json if we added new entries
    if (new_entries > 0) {
        kb_config.saveKbConfig(config);
        std.debug.print("kb_config: added {} new entries to kb.json\n", .{new_entries});
    }

    std.debug.print("\n=== Compact Loading Summary ===\n", .{});
    std.debug.print("  files loaded:     {}\n", .{files_loaded});
    std.debug.print("  files skipped:    {}\n", .{files_skipped});
    std.debug.print("  total tables:     {}\n", .{total_tables});
    std.debug.print("  total rows:       {}\n", .{total_rows});
    std.debug.print("  total relations:  {}\n", .{total_rels});
    std.debug.print("  total file bytes: {}\n", .{total_bytes});
    std.debug.print("  arena used:       {} bytes\n", .{global_arena.usedBytes()});
    std.debug.print("  arena free:       {} bytes\n", .{global_arena.freeBytes()});

    // Print KB hierarchy from config
    std.debug.print("\n=== KB Hierarchy ===\n", .{});
    for (0..config.count) |i| {
        const dotted = config.entries[i].dottedSlice();
        const file = config.entries[i].fileSlice();

        // Count depth by counting dots
        var dot_count: usize = 0;
        for (dotted) |c| {
            if (c == '.') dot_count += 1;
        }

        // Indent by depth (root.X = 1 dot = L1, root.X.Y = 2 dots = L2, etc.)
        for (0..dot_count) |_| {
            std.debug.print("  ", .{});
        }

        // Find the matching LoadResult for this file
        var found = false;
        for (0..files_loaded) |f| {
            if (loaded_results[f]) |result| {
                if (std.mem.eql(u8, result.pathSlice(), file)) {
                    std.debug.print("{s}: {d} tables, {d} rows, {d} rels\n", .{
                        dotted,
                        result.table_count,
                        result.total_rows,
                        result.relationship_count,
                    });
                    found = true;
                    break;
                }
            }
        }
        if (!found) {
            std.debug.print("{s}: (not loaded)\n", .{dotted});
        }
    }

    return config;
}

fn create_kb_tree(global_arena: *types.Arena, config: *kb_config.KbConfig) void {
    std.debug.print("\n=== Creating KB Tree ===\n", .{});

    const alloc = global_arena.allocator();
    var kbs_created: usize = 0;

    // Track unique segments at each level to assign consistent indices
    // L1 segments (after "root."): edu, programming, engineering, trades, etc.
    // L2 segments: physics, chemistry, algorithms, etc.
    // L3 segments: foundation, logic, human, military_tactics, etc.
    var l1_names: [127][MAX_SEG]u8 = undefined;
    var l1_lens: [127]usize = [_]usize{0} ** 127;
    var l1_count: u7 = 0;

    var l2_names: [127][255][MAX_SEG]u8 = undefined;
    var l2_lens: [127][255]usize = undefined;
    var l2_counts: [127]u8 = [_]u8{0} ** 127;

    // Initialize l2 tracking
    for (0..127) |x| {
        for (0..255) |y| {
            l2_lens[x][y] = 0;
        }
    }

    for (0..config.count) |i| {
        const kb = global_arena.allocTyped(types.KB) orelse {
            std.debug.print("kb_tree: arena full\n", .{});
            return;
        };
        kb.* = types.KB{};
        kb.lookup.facts = std.AutoHashMap(types.LookupId, i32).init(alloc);
        kb.lookup.relations = std.AutoHashMap(types.LookupId, i32).init(alloc);

        // Parse dotted path into segments and assign VdrId
        const dotted = config.entries[i].dottedSlice();
        var segments: [6][MAX_SEG]u8 = undefined;
        var seg_lens: [6]usize = [_]usize{0} ** 6;
        var seg_count: usize = 0;
        var spos: usize = 0;

        // Split on '.'
        while (spos < dotted.len and seg_count < 6) {
            const dot = std.mem.indexOfScalarPos(u8, dotted, spos, '.');
            const end = dot orelse dotted.len;
            const seg = dotted[spos..end];
            if (seg.len > 0 and seg.len <= MAX_SEG) {
                @memcpy(segments[seg_count][0..seg.len], seg);
                seg_lens[seg_count] = seg.len;
                seg_count += 1;
            }
            if (dot) |d| {
                spos = d + 1;
            } else break;
        }

        // segments[0] = "root" (skip), segments[1] = L1, segments[2] = L2, segments[3] = L3
        var l1_idx: u7 = 127; // sentinel
        var l2_idx: u8 = 255; // sentinel
        var l3_idx: u8 = 255; // sentinel

        // Assign L1
        if (seg_count > 1) {
            l1_idx = findOrAddSegment(&l1_names, &l1_lens, &l1_count, segments[1][0..seg_lens[1]]);
        }

        // Assign L2
        if (seg_count > 2 and l1_idx != 127) {
            l2_idx = findOrAddL2(&l2_names, &l2_lens, &l2_counts, l1_idx, segments[2][0..seg_lens[2]]);
        }

        // Assign L3
        // For simplicity, L3 uses a per-KB counter since we don't have many L3 entries
        if (seg_count > 3 and l2_idx != 255) {
            // Count how many KBs we've already seen with same L1+L2 and have L3
            var l3_counter: u8 = 0;
            for (0..i) |prev| {
                const prev_dotted = config.entries[prev].dottedSlice();
                const prev_kb = config.entries[prev].kb orelse continue;
                const prev_s = prev_kb.id.structural();
                if (prev_s.l1 == l1_idx and prev_s.l2 == l2_idx and prev_s.l3 != 255) {
                    l3_counter += 1;
                }
                _ = prev_dotted;
            }
            l3_idx = l3_counter;
        }

        kb.id = types.VdrId.makeKb(0, l1_idx, l2_idx, l3_idx, 255, 255);
        config.entries[i].kb = kb;
        kbs_created += 1;
    }

    std.debug.print("  KBs created: {}\n", .{kbs_created});
    std.debug.print("  arena used:  {} bytes\n", .{global_arena.usedBytes()});
    std.debug.print("  arena free:  {} bytes\n", .{global_arena.freeBytes()});
}

const MAX_SEG: usize = 64;

fn findOrAddSegment(names: *[127][MAX_SEG]u8, lens: *[127]usize, count: *u7, seg: []const u8) u7 {
    // Check if segment already exists
    for (0..count.*) |idx| {
        if (lens.*[idx] == seg.len and std.mem.eql(u8, names.*[idx][0..lens.*[idx]], seg)) {
            return @intCast(idx);
        }
    }
    // Add new
    if (count.* >= 127) return 127; // sentinel, full
    const idx = count.*;
    @memcpy(names.*[idx][0..seg.len], seg);
    lens.*[idx] = seg.len;
    count.* += 1;
    return idx;
}

fn findOrAddL2(names: *[127][255][MAX_SEG]u8, lens: *[127][255]usize, counts: *[127]u8, l1: u7, seg: []const u8) u8 {
    const l1i: usize = @intCast(l1);
    // Check if segment already exists under this L1
    for (0..counts.*[l1i]) |idx| {
        if (lens.*[l1i][idx] == seg.len and std.mem.eql(u8, names.*[l1i][idx][0..lens.*[l1i][idx]], seg)) {
            return @intCast(idx);
        }
    }
    // Add new
    if (counts.*[l1i] >= 255) return 255; // sentinel, full
    const idx = counts.*[l1i];
    @memcpy(names.*[l1i][idx][0..seg.len], seg);
    lens.*[l1i][idx] = seg.len;
    counts.*[l1i] += 1;
    return idx;
}

fn populate_kb_data(global_arena: *types.Arena, config: *kb_config.KbConfig) void {
    std.debug.print("\n=== Populating KB Data ===\n", .{});
    _ = global_arena;

    var total_facts: usize = 0;
    var total_rels: usize = 0;

    for (0..config.count) |i| {
        const entry = &config.entries[i];
        const result = entry.load_result orelse continue;
        const kb = entry.kb orelse continue;

        var kb_facts: usize = 0;
        var kb_rels: usize = 0;

        for (0..result.table_count) |ti| {
            const table = &result.tables[ti];
            for (0..table.row_count) |ri| {
                const lid = kb.mintLookupId(.fact) orelse break;
                if (kb.lookup.facts) |*m| {
                    m.put(lid, @intCast(ri)) catch {};
                }
                kb_facts += 1;
                // _ = ri;
            }
        }

        for (0..result.relationship_count) |ri| {
            if (result.relationships[ri].canonical_type == .unknown) continue;
            const lid = kb.mintLookupId(.relation) orelse break;
            if (kb.lookup.relations) |*m| {
                m.put(lid, @intCast(ri)) catch {};
            }
            kb_rels += 1;
        }

        std.debug.print("  {s}: {d} facts, {d} rels\n", .{ entry.dottedSlice(), kb_facts, kb_rels });
        total_facts += kb_facts;
        total_rels += kb_rels;
    }

    std.debug.print("\n  total facts:     {}\n", .{total_facts});
    std.debug.print("  total relations: {}\n", .{total_rels});
}

fn populate_kb_data_columns(global_arena: *types.Arena, config: *kb_config.KbConfig) void {
    std.debug.print("\n=== Populating KBData Columns ===\n", .{});

    const alloc = global_arena.allocator();
    var total_data_entries: usize = 0;

    for (0..config.count) |i| {
        const entry = &config.entries[i];
        const result = entry.load_result orelse continue;
        const kb = entry.kb orelse continue;

        if (kb.data == null) {
            kb.data = std.array_list.Managed(types.KBData).init(alloc);
        }

        var kb_data_count: usize = 0;

        for (0..result.table_count) |ti| {
            const table = &result.tables[ti];

            for (0..table.row_count) |ri| {
                const row_text = table.rowText(ri, global_arena.base);
                if (row_text.len == 0) continue;

                const lid = kb.mintLookupId(.data) orelse break;
                const data_id = types.VdrId.makeItem(kb.id, .data, lid);

                var kbdata = types.KBData{};
                kbdata.id = data_id;

                // Split row_text by '|' and fill text columns, skipping column 0 (entity ID)
                var col_index: usize = 0;
                var data_col: usize = 0;
                var pos: usize = 0;

                while (pos <= row_text.len) {
                    const pipe = std.mem.indexOfScalarPos(u8, row_text, pos, '|');
                    const end = pipe orelse row_text.len;
                    const col_text = std.mem.trim(u8, row_text[pos..end], " ");

                    if (col_index > 0) { // skip column 0 (entity ID)
                        if (data_col <= 8 and col_text.len > 0) {
                            var value = types.KBDataValue{};
                            var small = TextSmall{};
                            const copy_len = @min(col_text.len, text_small.TEXT_LEN_MAX);
                            @memcpy(small.text[0..copy_len], col_text[0..copy_len]);
                            small.len = copy_len;
                            value.text = small;
                            setTextColumn(&kbdata, data_col, value);
                        }
                        data_col += 1;
                    }

                    col_index += 1;
                    if (pipe) |p| {
                        pos = p + 1;
                    } else break;
                }

                kb.data.?.append(kbdata) catch {
                    std.debug.print("  {s}: append failed at row {}\n", .{ entry.dottedSlice(), ri });
                    break;
                };

                kb_data_count += 1;
            }
        }

        std.debug.print("  {s}: {d} data entries\n", .{ entry.dottedSlice(), kb_data_count });
        total_data_entries += kb_data_count;
    }

    std.debug.print("\n  total data entries: {}\n", .{total_data_entries});
    std.debug.print("  arena used:        {} bytes\n", .{global_arena.usedBytes()});
    std.debug.print("  arena free:        {} bytes\n", .{global_arena.freeBytes()});
}

fn setTextColumn(kbdata: *types.KBData, col_index: usize, value: types.KBDataValue) void {
    switch (col_index) {
        0 => kbdata.text_column_0 = value,
        1 => kbdata.text_column_1 = value,
        2 => kbdata.text_column_2 = value,
        3 => kbdata.text_column_3 = value,
        4 => kbdata.text_column_4 = value,
        5 => kbdata.text_column_5 = value,
        6 => kbdata.text_column_6 = value,
        7 => kbdata.text_column_7 = value,
        8 => kbdata.text_column_8 = value,
        else => {},
    }
}

fn getVdrValue(config: *kb_config.KbConfig, id: types.VdrId) types.VdrValue {
    if (id.isNone()) return types.VdrValue.failed();

    const s = id.structural();
    const entry_type: types.KBEntryType = @enumFromInt(s.entry_type);

    // Find host KB by matching structural path
    var host_kb: ?*types.KB = null;
    for (0..config.count) |i| {
        const kb = config.entries[i].kb orelse continue;
        const kb_s = kb.id.structural();
        if (kb_s.l1 == s.l1 and kb_s.l2 == s.l2 and kb_s.l3 == s.l3 and
            kb_s.l4 == s.l4 and kb_s.l5 == s.l5)
        {
            host_kb = kb;
            break;
        }
    }

    const kb = host_kb orelse return types.VdrValue.failed();
    const item_id = s.item_id;

    switch (entry_type) {
        .kb => return types.VdrValue.fromKb(id, kb),

        .data => {
            if (kb.data) |data_list| {
                if (item_id < data_list.items.len) {
                    return types.VdrValue.fromData(id, &data_list.items[item_id]);
                }
            }
            return types.VdrValue.failed();
        },

        .data_q335 => {
            if (kb.data_q335) |data_list| {
                if (item_id < data_list.items.len) {
                    return types.VdrValue.fromDataQ335(id, &data_list.items[item_id]);
                }
            }
            return types.VdrValue.failed();
        },

        .fact => {
            if (kb.lookup.facts) |facts_map| {
                if (facts_map.get(item_id)) |_| {
                    return types.VdrValue{ .id = id, .entry_type = .fact, .ok = true };
                }
            }
            return types.VdrValue.failed();
        },

        .relation => {
            if (kb.lookup.relations) |relations_map| {
                if (relations_map.get(item_id)) |_| {
                    return types.VdrValue{ .id = id, .entry_type = .relation, .ok = true };
                }
            }
            return types.VdrValue.failed();
        },

        else => return types.VdrValue.failed(),
    }
}

fn verify_kb_data_lookup(config: *kb_config.KbConfig) void {
    std.debug.print("\n=== Verifying KBData Lookup ===\n", .{});

    var total_checked: usize = 0;
    var total_ok: usize = 0;
    var total_failed: usize = 0;
    var total_col0_present: usize = 0;

    for (0..config.count) |i| {
        const entry = &config.entries[i];
        const kb = entry.kb orelse continue;

        const data_list = kb.data orelse continue;

        var kb_ok: usize = 0;
        var kb_failed: usize = 0;

        for (data_list.items) |*kbdata| {
            const val = getVdrValue(config, kbdata.id);

            if (val.ok and val.entry_type == .data and val.data != null) {
                if (val.data.?.id.eql(kbdata.id)) {
                    kb_ok += 1;
                    if (val.data.?.text_column_0 != null) {
                        total_col0_present += 1;
                    }
                } else {
                    kb_failed += 1;
                }
            } else {
                kb_failed += 1;
            }

            total_checked += 1;
        }

        if (kb_failed > 0) {
            std.debug.print("  {s}: {d} ok, {d} FAILED\n", .{ entry.dottedSlice(), kb_ok, kb_failed });
        }

        total_ok += kb_ok;
        total_failed += kb_failed;
    }

    std.debug.print("\n  total checked:     {}\n", .{total_checked});
    std.debug.print("  total ok:          {}\n", .{total_ok});
    std.debug.print("  total failed:      {}\n", .{total_failed});
    std.debug.print("  total with col_0:  {}\n", .{total_col0_present});

    if (total_failed == 0 and total_checked > 0) {
        std.debug.print("  PASS: all {} data entries round-trip through getVdrValue\n", .{total_checked});
    } else if (total_failed > 0) {
        std.debug.print("  FAIL: {} entries failed lookup\n", .{total_failed});
    }
}

fn print_sample_data_entry(config: *kb_config.KbConfig) void {
    std.debug.print("\n=== Sample KBData Entry ===\n", .{});

    // Find root.edu.physics, pick row 0 (should be first entry like K1 or D1)
    for (0..config.count) |i| {
        const entry = &config.entries[i];
        if (!std.mem.eql(u8, entry.dottedSlice(), "root.edu.physics")) continue;

        const kb = entry.kb orelse return;
        const data_list = kb.data orelse return;
        if (data_list.items.len == 0) return;

        // Lookup via getVdrValue to prove the round-trip
        const first_id = data_list.items[0].id;
        const val = getVdrValue(config, first_id);

        if (!val.ok or val.data == null) {
            std.debug.print("  getVdrValue FAILED for first entry\n", .{});
            return;
        }

        const d = val.data.?;
        const s = d.id.structural();

        std.debug.print("  KB:         {s}\n", .{entry.dottedSlice()});
        std.debug.print("  VdrId:      {}\n", .{d.id.v});
        std.debug.print("  scope:      {}\n", .{s.scope});
        std.debug.print("  entry_type: {}\n", .{s.entry_type});
        std.debug.print("  L1:         {}\n", .{s.l1});
        std.debug.print("  L2:         {}\n", .{s.l2});
        std.debug.print("  L3:         {}\n", .{s.l3});
        std.debug.print("  L4:         {}\n", .{s.l4});
        std.debug.print("  L5:         {}\n", .{s.l5});
        std.debug.print("  item_id:    {}\n", .{s.item_id});

        std.debug.print("  --- columns ---\n", .{});
        printCol("  col_0", d.text_column_0);
        printCol("  col_1", d.text_column_1);
        printCol("  col_2", d.text_column_2);
        printCol("  col_3", d.text_column_3);
        printCol("  col_4", d.text_column_4);
        printCol("  col_5", d.text_column_5);
        printCol("  col_6", d.text_column_6);
        printCol("  col_7", d.text_column_7);
        printCol("  col_8", d.text_column_8);

        std.debug.print("  --- values ---\n", .{});
        std.debug.print("  v_0: {}, col: {}\n", .{ d.v_0.v, d.v_0_column });
        std.debug.print("  v_1: {}, col: {}\n", .{ d.v_1.v, d.v_1_column });
        std.debug.print("  v_2: {}, col: {}\n", .{ d.v_2.v, d.v_2_column });
        std.debug.print("  v_3: {}, col: {}\n", .{ d.v_3.v, d.v_3_column });

        // Print a few more entries to show variety
        std.debug.print("\n  --- first 5 entries ---\n", .{});
        const show = @min(data_list.items.len, 5);
        for (0..show) |idx| {
            const item = &data_list.items[idx];
            std.debug.print("  [{d}] ", .{idx});
            if (item.text_column_0) |c0| {
                if (c0.text) |t| {
                    std.debug.print("col_0=\"{s}\"", .{t.text[0..t.len]});
                }
            }
            if (item.text_column_1) |c1| {
                if (c1.text) |t| {
                    std.debug.print(" col_1=\"{s}\"", .{t.text[0..t.len]});
                }
            }
            if (item.text_column_2) |c2| {
                if (c2.text) |t| {
                    std.debug.print(" col_2=\"{s}\"", .{t.text[0..t.len]});
                }
            }
            std.debug.print("\n", .{});
        }

        return;
    }

    std.debug.print("  root.edu.physics not found\n", .{});
}

fn printCol(label: []const u8, col: ?types.KBDataValue) void {
    if (col) |c| {
        if (c.text) |t| {
            std.debug.print("{s}: \"{s}\"\n", .{ label, t.text[0..t.len] });
        } else {
            std.debug.print("{s}: (value only) v={}\n", .{ label, c.v.v });
        }
    } else {
        std.debug.print("{s}: null\n", .{label});
    }
}
