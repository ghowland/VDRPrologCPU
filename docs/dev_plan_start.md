# VDR-Prolog CPU — Development Plan

## Context for the Developer

You are building a CPU-only exact integer LLM inference system in Zig 0.15.1, targeting x86_64 AVX2. The full architecture spec and type definitions already exist. Read `vdr_types.zig` for all structs. Read the README for the full system design. This document covers the build order.

All memory is arena-allocated at startup. No malloc after init. No floating point anywhere. Q16 rational arithmetic with two remainder slots (v: i32, r0: i16, r1: i16). D=65536, implicit.

## Build Order

The system is built bottom-up. Each step must compile, run, and exit clean before the next step starts. No skipping ahead.

### Step 1: Kernel Boot + Arena Memory

**Goal:** Zig project compiles on 0.15.1, allocates a core arena, prints diagnostics, exits.

**Files:**
- `build.zig` — Single native x86_64 target. Nothing else.
- `src/root.zig` — Entry point. Creates the core arena (general, not pinned). Prints arena size and cursor position. Exits cleanly.
- `src/arena_memory.zig` — Arena allocator module. Two arena types: **general** (any thread can use, used for the core/global arena) and **pinned** (NUMA-locked to a specific core, used later for SIMD processing threads). Both are bump-pointer, fixed-size, allocated from `std.heap.page_allocator`. Same struct, different init path. Pinned arenas will have their pages touched from the pinned thread to ensure first-touch NUMA placement — but that wiring comes in a later step. For now, pinned arenas just allocate and record which core they're intended for.
- `src/vdr_types.zig` — Already written. All structs with defaults.

**Validation:** `zig build && ./zig-out/bin/vdr-prolog-cpu` prints arena info and exits with code 0.

### Step 2: Config Loader

**Goal:** Load a JSON config file into `SystemConfig` struct at startup. Hard-mapped — every JSON field maps to a struct field. Unknown fields are errors. Missing required fields are errors. Show the exact error and exit. No loose JSON parsing, no dynamic keys, no runtime field discovery.

**Files:**
- `src/config.zig` — Reads a JSON file path from command line args. Parses JSON using Zig's `std.json`. Maps directly into `SystemConfig` from `vdr_types.zig`. On any parse failure, prints the field name and expected type, then exits with code 1.
- `config.json` — Default config file with sane defaults for a Dell Legion 5 (8 cores, 256MB per-core arenas, 3GB global arena).

**Validation:** `zig build && ./zig-out/bin/vdr-prolog-cpu config.json` loads config, prints parsed values, exits. Bad JSON prints specific error and exits with code 1. Missing file prints usage and exits.

**Important:** The config specifies `n_cores` (0 = auto-detect), all arena sizes, model parameters, session limits, and sampling defaults. This is the single source of truth for system sizing. Everything downstream reads from the parsed `SystemConfig`.

### Step 3: Core Arena + N Pinned Core Arenas

**Goal:** Based on loaded config, allocate the global arena (general) and N per-core arenas (pinned). N comes from config. Each per-core arena is sized from config. No threads yet — just the memory.

**Files:**
- Update `src/root.zig` — After loading config, allocate global arena and N per-core arenas. Print summary: N arenas, sizes, total memory committed.
- Update `src/arena_memory.zig` — Add `ArenaSet` struct that holds the global arena plus an array of per-core arenas. Single init call creates everything. Single deinit frees everything.

**Validation:** Prints arena layout matching config. Total memory matches expected sum. Exits clean.

### Step 4: NUMA-Pinned Processing Threads

**Goal:** Spawn N threads (one per core from config), pin each to its physical core, have each thread touch its arena pages (first-touch NUMA placement), then park waiting for work. Main thread can signal shutdown. Clean join on exit.

**Files:**
- `src/thread_pool.zig` — Spawns N threads. Each thread: sets CPU affinity to its core ID, touches all pages in its per-core arena (sequential write of zeros), then enters a spin-wait loop on an atomic work flag. Shutdown sets a done flag, all threads exit, main joins them.
- Update `src/root.zig` — After arena init, start thread pool. Print per-thread status (core ID, arena size, pinned status). Wait 100ms. Signal shutdown. Join. Exit.

**Validation:** All N threads spawn, pin, touch memory, and join cleanly. No hangs, no crashes. Print confirms each thread ran on its intended core.

### Step 5: HTTP Listener (Non-Pinned)

**Goal:** Launch a non-blocking HTTP listener on a non-pinned thread. It accepts connections and spawns a non-pinned handler thread per connection. Handler threads do not do SIMD work — they are connectors that will pass work items to the NUMA-pinned processing threads. For now, handlers just read the request, print it, send a 200 OK response, and close.

**Files:**
- `src/http_listener.zig` — Listens on a configurable port (from config, default 1138). Uses `std.net` for TCP accept. Each accepted connection spawns a new non-pinned thread that reads the HTTP request, logs it, responds with `200 OK` and a JSON body `{"status": "ok"}`, then closes. The listener thread itself is non-pinned and non-blocking on the main processing path.
- Update `src/root.zig` — After thread pool init, start HTTP listener. Main thread waits for SIGINT/SIGTERM (or just sleeps and checks a flag). On shutdown: stop listener, stop thread pool, free arenas, exit.

**Validation:** `curl http://localhost:1138/health` returns `{"status": "ok"}`. Multiple concurrent curls work. Ctrl+C shuts down cleanly. No pinned threads are disturbed by HTTP traffic.

### Step 6: HTTP-to-NUMA Work Passing

**Goal:** HTTP handler threads can submit work items to the NUMA-pinned processing threads and wait for results. This is the bridge between the outside world and the SIMD compute cores. Each pinned thread has an atomic work queue (simple ring buffer in its arena). HTTP handlers push work, pinned threads pop and execute, results returned via atomic flag.

**Files:**
- `src/work_queue.zig` — Per-core atomic work queue. Fixed-size ring buffer. Push from any thread (HTTP handler), pop from the owning pinned thread only. Atomic head/tail pointers. No mutex.
- Update `src/thread_pool.zig` — Pinned threads check their work queue each spin iteration. When a work item arrives, execute it (for now: echo the input back as output). Signal completion via atomic flag on the work item.
- Update `src/http_listener.zig` — HTTP handlers parse a simple JSON request body, create a work item, push to a selected core's queue (round-robin or least-loaded), wait for completion, send result as HTTP response.

**Validation:** `curl -X POST http://localhost:1138/compute -d '{"echo": "hello"}'` returns `{"result": "hello"}`. The work was executed on a pinned NUMA thread, not the HTTP thread. Concurrent requests distribute across cores.

### After Step 6

The kernel infrastructure is done. You have:
- Arena memory (general + pinned)
- Config-driven sizing
- NUMA-pinned processing threads with work queues
- Non-pinned HTTP interface that bridges to the compute threads
- Clean startup and shutdown

Everything after this builds on top:
- KB store operations running on pinned threads
- Prolog engine running on pinned threads
- SIMD GEMM for LLM forward pass running on pinned threads
- The full inference loop from the spec

But none of that matters if the kernel doesn't work. Steps 1-6 are the foundation. Get them solid.

## Key Constraints

- **Zig 0.15.1.** Not 0.16.0. API differences exist. Test that `std.json`, `std.net`, `std.Thread` work as expected on 0.15.1.
- **No malloc after init.** All arenas sized from config at startup. If an arena is exhausted, crash. Never call a general-purpose allocator during operation.
- **No floating point.** Anywhere. Ever. Not in HTTP parsing, not in timing, not in logging. Use integer nanoseconds for timestamps.  Floats are converted to VDR where the decimal precision converts to denominator, or they are kept as strings.  No active floats in the entire system.
- **x86_64 only.** No ARM, no WASM, no cross-compilation concerns.
- **All types in `vdr_types.zig`.** Modules import types from there. Don't duplicate struct definitions.

## File Reference

- `vdr_types.zig` — All structs. Already complete. Read this first.
- `README.md` — Full architecture description. Read this for the big picture.
- The CPU tech spec (if provided separately) has detailed memory sizing, SIMD throughput calculations, and the full inference loop pseudocode.
