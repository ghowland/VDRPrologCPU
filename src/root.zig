const std = @import("std");
const config_mod = @import("vdr_config");
const types = @import("vdr_types");

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

    std.debug.print("=== config loaded OK ===\n", .{});
    std.debug.print("VDR-Prolog kernel ready\n", .{});
}
