const std = @import("std");
const config_mod = @import("vdr_config.zig");
const types = @import("vdr_types.zig");

const vdr_arena = @import("vdr_arena.zig");
const resetable_memory = @import("resetable_memory.zig");
const vdr_http = @import("vdr_http.zig");
const compact_loader = @import("vdr_compact_loader.zig");
const kb_config = @import("vdr_kb_config.zig");

// Types
const Text = @import("text_big.zig").Text;

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

    std.debug.print("VDR-Prolog kernel ready\n", .{});

    // Load KB Test
    load_kbs(global_arena);

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

fn load_kbs(global_arena: *types.Arena) void {
    std.debug.print("\n=== Loading KB config ===\n", .{});

    // Load or create kb.json mapping
    const config = kb_config.loadKbConfig(global_arena) orelse {
        std.debug.print("fatal: cannot allocate kb config\n", .{});
        return;
    };

    std.debug.print("\n=== Loading compact files ===\n", .{});

    const dir_path = "data/kb_raw";
    var dir = std.fs.cwd().openDir(dir_path, .{ .iterate = true }) catch {
        std.debug.print("compact_loader: cannot open directory '{s}'\n", .{dir_path});
        return;
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
}
