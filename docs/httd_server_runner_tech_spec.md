## VDR-Prolog Kernel — Current Implementation Spec

### Overview

An HTTP server with a layered thread architecture. Accepts POST and GET requests, routes work through handler threads to pinned runner threads via atomic ring buffers, returns responses. Written in Zig 0.15.1, x86_64, linked against libc.

### Files

| File | Role |
|---|---|
| `root.zig` | Entry point. Loads config, creates global arena, creates resetable memory, spawns HTTP thread, waits for shutdown |
| `vdr_config.zig` | Reads `config.json`, parses JSON into `SystemConfig`, strict validation, exits 1 on failure |
| `vdr_types.zig` | All type definitions for the full system (Q16, VdrId, KB, Fact, Arena, Session, etc.) |
| `vdr_arena.zig` | Arena lifecycle: `create(size) -> *Arena`, `destroy(*Arena)`. Backed by `page_allocator` |
| `resetable_memory.zig` | Module-level singleton arena for temporary allocations (HTTP response formatting). Create/destroy/reset/lock. Exposes `std.mem.Allocator` interface via vtable |
| `text_big.zig` | `TextBig` — 100KB fixed stack buffer with length tracking. No allocator for the buffer itself. String operations: init, append, slice, replace, trim, split, escape, format. Formatting helpers use an external allocator |
| `vdr_http.zig` | HTTP listener. Binds to configured port, polls with 100ms timeout (non-blocking shutdown), accepts connections, dispatches to accepter. Parses HTTP requests when called by handler threads. Writes HTTP responses |
| `vdr_http_accepter.zig` | Connection dispatch layer. Owns handler thread pool and connection ring buffer. Accepts connections from listener, distributes to handler threads via atomic ring buffer with CAS. Inits and stops the runner pool |
| `vdr_http_handler.zig` | Request routing. Receives method, path, body. Routes `/shutdown` directly (sets shutdown flag). Routes `/run` to runner pool (submit + spin-wait poll). Returns 404 for unknown paths |
| `vdr_runner_pool.zig` | Pinned runner threads. Receives work requests via per-core incoming atomic ring buffer. Does the compute work (currently echo with JSON escaping). Pushes responses to per-core outgoing atomic ring buffer |
| `config.json` | 4 cores, port 1138, 1GB global arena, ~224MB per-core arena, default limits |
| `build.zig` | Builds executable `vdr`. Named modules for `vdr_types` and `vdr_config`. Links libc |

### Thread Architecture

**1 listener thread** (unpinned) — spawned from `root.zig`. Runs `vdr_http.run()`. Polls for incoming connections, pushes accepted sockets to the accepter's connection ring. Never reads, parses, or processes requests.

**4 handler threads** (unpinned) — spawned by `vdr_http_accepter.init()`. Pop connections from the accepter ring using atomic CAS. Call `vdr_http.handle_connection()` to parse HTTP. Call `vdr_http_handler.handle()` to route. For `/run`, submit to runner and spin-wait for response. Write HTTP response. Close socket.

**4 runner threads** (unpinned currently, will be pinned) — spawned by `vdr_runner_pool.init()`. Pop work requests from per-core incoming ring. Execute work. Push responses to per-core outgoing ring. Currently do echo with JSON escaping.

### Ring Buffers

Three sets of atomic ring buffers, all 64 slots:

**Accepter ring** — single ring, connections from listener to handler threads. Atomic `head` (listener writes) and `tail` (handlers CAS to pop). Single-producer, multi-consumer.

**Runner incoming rings** — one per core. Handler threads push `WorkRequest` (request_id + body). Runner thread pops. Single-consumer per ring.

**Runner outgoing rings** — one per core. Runner thread pushes `WorkResponse` (request_id + body). Handler thread polls by request_id. Single-producer per ring.

All use `std.atomic.Value(usize)` with acquire/release ordering.

### Memory Model

**Global arena** — 1GB, allocated at startup via `page_allocator`. Currently unused (no KBs, facts, or weights loaded). Destroyed on shutdown.

**Resetable memory** — 1MB singleton, allocated at startup. Used by `vdr_http.handle_connection()` for `std.fmt.allocPrint` when formatting HTTP response headers. Exposed as `std.mem.Allocator` via vtable. Currently reset is called but shared across handler threads without per-thread isolation.

**Stack memory** — `TextBig` (100KB) structs live on each handler/runner thread's stack. No heap allocation for request/response bodies. HTTP raw bytes read into a `TextBig`, body parsed into a `TextBig`, response built into a `TextBig`.

**No malloc after init** — global arena, resetable memory, and page-backed arenas all allocated during startup. Runtime uses only stack and pre-allocated arenas.

### HTTP Protocol

Listens on `127.0.0.1:1138`. Accepts GET and POST. POST requires `Content-Length` header. GET works with or without `Content-Length`. Response always includes `Connection: close`. Maximum header size 64KB. Body limited by `TextBig` capacity (100KB).

### Request Flow

```
client -> listener (accept) -> accepter ring -> handler thread (parse HTTP)
    -> handler checks path:
        /shutdown -> sets shutdown flag, returns JSON, closes socket
        /run      -> submit to runner ring -> runner does work -> response ring -> handler writes response, closes socket
        other     -> 404, closes socket
```

### Current Work Payload

Echo with JSON escaping. Runner receives body, wraps in `{"echo":"..."}` with escaped special characters, returns as response body. Content-type `application/json`, status 200.

### Shutdown

GET or POST to `/shutdown`. Handler sets `vdr_http.shutdown = true`. Listener poll loop sees flag within 100ms, exits. Accepter joins handler threads, then stops runner pool. Runner threads see shutdown flag, exit. Root joins HTTP thread, destroys resetable memory and global arena, prints shutdown message.

### Config

```json
{
    "n_cores": 4,
    "http_port": 1138,
    "global_arena_bytes": 1073741824,
    "per_core_arena_bytes": 234881024
}
```

Plus limits for KBs, facts, rules, terms, sessions, runners, audit, visibility, relation index rebuild interval. Model, sampling, prolog, and context sub-configs use defaults.

### Known Issues

- Resetable memory is shared across handler threads without per-thread isolation. Concurrent `allocPrint` calls could corrupt each other.
- Runner threads are not yet pinned to cores.
- No per-core arenas allocated for runners (struct field exists but unused).
- `TextBig` is copied by value into `WorkRequest`/`WorkResponse` — 100KB per copy through the ring buffer. Works but heavy.
