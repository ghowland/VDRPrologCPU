# VDR-Prolog HTTP Server Flow and Session Management

## Technical Specification

---

## 1. Overview

The HTTP interface is a connector, not a web server. It receives JSON work requests from clients, routes them to NUMA-pinned compute threads via lock-free ring buffers, and returns results. HTTP threads never do compute. Compute threads never touch the network.

Sessions are persistent — they survive HTTP disconnects. A client connects, does work, disconnects, reconnects later, and resumes the same session. Sessions live in per-core arenas and are managed by an LRU that ejects cold sessions when the per-core session limit is reached. The session's data is intact in the KB tree regardless of HTTP connection state.

---

## 2. Thread Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    NON-PINNED THREADS                         │
│                                                               │
│  ┌──────────────┐                                            │
│  │ HTTP Listener │  Port from config (default 1138)          │
│  │ (1 thread)    │  std.net TCP accept loop                  │
│  └──────┬───────┘                                            │
│         │ spawns per connection                               │
│  ┌──────▼───────┐ ┌──────────────┐ ┌──────────────┐         │
│  │ HTTP Handler │ │ HTTP Handler │ │ HTTP Handler │  ...     │
│  │ (non-pinned) │ │ (non-pinned) │ │ (non-pinned) │         │
│  └──────┬───────┘ └──────┬───────┘ └──────┬───────┘         │
│         │                 │                 │                  │
└─────────┼─────────────────┼─────────────────┼────────────────┘
          │ push            │ push            │ push
          ▼                 ▼                 ▼
┌─────────────────────────────────────────────────────────────┐
│                  PER-CORE WORK QUEUES                         │
│                                                               │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐            │
│  │ Core 0 Ring │ │ Core 1 Ring │ │ Core N Ring │            │
│  │ Buffer      │ │ Buffer      │ │ Buffer      │            │
│  └──────┬──────┘ └──────┬──────┘ └──────┬──────┘            │
│         │ pop            │ pop            │ pop               │
└─────────┼────────────────┼────────────────┼──────────────────┘
          ▼                ▼                ▼
┌─────────────────────────────────────────────────────────────┐
│                    PINNED COMPUTE THREADS                     │
│                                                               │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐         │
│  │ Core 0       │ │ Core 1       │ │ Core N       │         │
│  │ Pinned       │ │ Pinned       │ │ Pinned       │         │
│  │ SIMD Compute │ │ SIMD Compute │ │ SIMD Compute │         │
│  └──────────────┘ └──────────────┘ └──────────────┘         │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

Three layers, strictly separated:

**HTTP listener** — one non-pinned thread, runs the TCP accept loop on the configured port. Spawns a handler thread per accepted connection.

**HTTP handlers** — non-pinned threads, one per active connection. Parse the request, resolve the session, build a work item, push it to the correct core's ring buffer, spin-wait on the completion flag, read the result, send the HTTP response, close or keep-alive.

**Pinned compute threads** — one per physical core, NUMA-pinned, spin-waiting on their work queue. Pop work items, execute (inference, Prolog, KB operations), write results into the work item's output region, set the completion flag.

---

## 3. Ring Buffer Design

Each core has one ring buffer in its per-core arena. The ring buffer is the only communication channel between HTTP handlers and compute threads.

```
struct VdrWorkQueue {
    items: [QUEUE_CAPACITY]VdrWorkItem,
    head: std.atomic.Value(i32),    // written by producers (HTTP handlers)
    tail: std.atomic.Value(i32),    // written by consumer (pinned thread)
    capacity: i32,
};
```

**Push (HTTP handler → compute thread):**
```
fn push(queue: *VdrWorkQueue, item: VdrWorkItem) bool {
    const head = queue.head.load(.acquire);
    const next = @mod(head + 1, queue.capacity);
    if (next == queue.tail.load(.acquire)) return false;  // full
    queue.items[@intCast(head)] = item;
    queue.head.store(next, .release);
    return true;
}
```

**Pop (compute thread only):**
```
fn pop(queue: *VdrWorkQueue) ?*VdrWorkItem {
    const tail = queue.tail.load(.acquire);
    if (tail == queue.head.load(.acquire)) return null;  // empty
    const item = &queue.items[@intCast(tail)];
    queue.tail.store(@mod(tail + 1, queue.capacity), .release);
    return item;
}
```

Single producer per push operation (HTTP handlers coordinate via atomic head). Single consumer (the owning pinned thread). No mutex. No syscall. The ring buffer lives in the per-core arena and is cache-line aligned.

If the queue is full, the HTTP handler retries with a brief spin. If the queue stays full beyond a timeout, the handler returns HTTP 503 (service unavailable). This is backpressure — the system does not accept more work than it can process.

---

## 4. Work Item Lifecycle

A work item is the unit of transfer between HTTP and compute:

```
struct VdrWorkItem {
    // Request
    op: VdrWorkOp,
    session_id: VdrId,
    request_offset: i32,       // offset into per-core arena scratch
    request_length: i32,

    // Response
    response_offset: i32,      // offset into per-core arena scratch
    response_length: i32,
    response_status: Status,

    // Signaling
    completion: std.atomic.Value(bool),
};
```

### 4.1 Full Request Flow

```
1. CLIENT sends HTTP POST to /v1/inference
   Body: { "session_id": "...", "client_id": "...", "input": "..." }

2. HTTP LISTENER accepts connection, spawns handler thread.

3. HTTP HANDLER:
   a. Parse JSON request body.
   b. Resolve client: look up root._client.{client_uuid}
      If not found → return 401.
   c. Resolve session: look up root._client.{client_uuid}.sessions.{session_uuid}
      If session_id not provided → create new session (clone from template).
      If session_id provided but not in RAM → load from snapshot if available,
         or return 404.
   d. Determine which core owns this session (session.core_id).
   e. Write request data to the per-core arena scratch region
      (the handler writes into a pre-allocated request slot).
   f. Build VdrWorkItem:
      - op = .inference (or .kb_query, .prolog_query, etc.)
      - session_id = resolved session
      - request_offset/length = where the request data lives
      - completion = false
   g. Push work item to that core's ring buffer.
   h. Spin-wait on completion flag:
      while (!item.completion.load(.acquire)) {
          std.atomic.spinLoopHint();
      }
   i. Read response from response_offset/length in the arena.
   j. Send HTTP response with result JSON.
   k. Close connection (or keep-alive for next request).

4. PINNED COMPUTE THREAD (on the session's core):
   a. Spin-wait loop checks work queue each iteration.
   b. Pop work item from ring buffer.
   c. Read session_id, load session from per-core session table.
   d. Read request data from request_offset.
   e. Execute: run inference cycle, KB operation, Prolog query,
      or whatever the op specifies. All on this one core.
      All reads from global arena (weights, seed KBs) are read-only.
      All writes go to session's region in the per-core arena.
   f. Write response to response_offset in per-core arena.
   g. Set response_status.
   h. Set completion flag: item.completion.store(true, .release).
   i. Return to spin-wait, check for next work item.

5. HTTP HANDLER wakes from spin-wait, reads response, sends to client.
```

### 4.2 Timing

The HTTP handler's spin-wait is bounded. For inference, a typical request completes in 27ms per token × N tokens. For KB queries and Prolog operations, sub-millisecond. The spin-wait uses `std.atomic.spinLoopHint()` (x86 PAUSE instruction) to reduce power consumption and pipeline stalls during the wait.

A configurable request timeout (from SystemConfig) causes the handler to give up and return HTTP 504 if the compute thread hasn't completed within the limit. The work item is marked abandoned — the compute thread will still process it but nobody reads the result.

---

## 5. Client and Organization Tree

### 5.1 Organization Structure

Every VDR-Prolog instance has an organization tree rooted at `root._organization`:

```
root._organization
└── {org_uuid}
    └── clients
        ├── {client_uuid_0}     ← admin owner of this instance
        ├── {client_uuid_1}
        ├── {client_uuid_2}
        └── ...
```

Client 0 (the first client created) is the admin owner of the VDR-Prolog instance. All clients belong to an organization. The organization KB holds org-level configuration, grant policies, and shared resources.

`root._organization.{org_uuid}` is a normal global KB with facts about the organization: name, creation time, configuration overrides, default grant sets, default session resource limits.

`root._organization.{org_uuid}.clients.{client_uuid}` holds per-client metadata: authentication tokens (hashed), grant assignments, session limit overrides, creation time, last active timestamp.

### 5.2 Client Structure

Each client has a KB tree under `root._client`:

```
root._client
└── {client_uuid}
    ├── (client-level facts: preferences, settings, metadata)
    └── sessions
        ├── {session_uuid_0}    ← references a VdrSession in a per-core arena
        ├── {session_uuid_1}
        └── ...
```

`root._client.{client_uuid}` is a global KB holding client-level data: preferences, settings, session history metadata, total resource usage counters.

`root._client.{client_uuid}.sessions.{session_uuid}` is a global KB holding session metadata: the VdrSession ID, which core it's assigned to, creation time, last active timestamp, snapshot reference if the session was ejected from RAM. The actual session data (the `_llm.*` subtree, the ephemeral tree, the KV cache) lives in the per-core arena — this global KB is just the index entry that lets the system find or restore it.

### 5.3 Authentication Flow

```
HTTP request arrives with client_id and auth_token.

1. Look up root._organization.{org_uuid}.clients.{client_id}
   If not found → 401 Unauthorized.

2. Verify auth_token against stored hash in the client's KB.
   If mismatch → 401 Unauthorized.

3. Check client state (active, suspended, etc.).
   If not active → 403 Forbidden.

4. Load client's grant set for the session.
   These grants determine which KBs the session can access,
   which determines the effective model the client sees.
```

---

## 6. Session Lifecycle

### 6.1 Session Creation

When a client requests a new session (no `session_id` in the request, or explicit `"action": "create_session"`):

```
1. Select a core for the new session.
   Strategy: least-loaded (fewest active sessions on that core).
   Ties broken by core ID (deterministic).

2. Check per-core session limit (from config: max_sessions_per_core).
   If at limit → LRU eject the oldest inactive session on that core
   (snapshot it first if it has unsaved state).

3. Clone the session template.
   The template is a pre-built session with the canonical _llm.* subtree
   already created:
     session_root._llm.prompt_last
     session_root._llm.prompt_next
     session_root._llm.prompt_input
     session_root._llm.prompt_current
     session_root._llm.history
     session_root._llm.projects
     session_root._llm.people
     session_root._llm.concepts
     session_root._llm.search
     session_root._llm.scratchpad

   The clone is a COW copy — pages are shared with the template
   until the session writes to them.

4. Assign session resource limits from the client's configuration
   (or org defaults if no client overrides):
     max_kb_count, max_ephemeral_kbs, max_facts_per_kb,
     max_live_memory_bytes, max_turns.

5. Register the session:
   a. Write VdrSession struct to per-core arena session table.
   b. Create global index KB at:
      root._client.{client_uuid}.sessions.{session_uuid}
      with metadata: core_id, creation time, state = active.

6. Return session_uuid to the client in the HTTP response.
```

### 6.2 Session Reconnection

When a client provides a `session_id` in the request:

```
1. Look up root._client.{client_uuid}.sessions.{session_uuid}
   If not found → 404 Session Not Found.

2. Check ownership: does this session belong to this client?
   If not → 403 Forbidden.

3. Check if session is in RAM (on some core's session table):
   a. Read core_id from the session index KB.
   b. Check that core's session table for this session_id.

4. If in RAM → route request to that core. Done.

5. If not in RAM (was LRU-ejected):
   a. Check if a snapshot exists (session index KB has snapshot reference).
   b. If snapshot exists:
      - Select a core (least-loaded).
      - Restore session from snapshot into that core's arena.
      - Update session index KB with new core_id.
      - Route request to that core.
   c. If no snapshot → 410 Session Gone (data was lost).
```

### 6.3 Session Persistence Across Disconnects

HTTP connections are stateless. The session is not tied to the TCP connection. The flow:

```
Client connects    → resolves session → pushes work → gets result → disconnects.
  (session stays in per-core arena, state = active)

Client reconnects  → provides same session_id → resolves same session → continues.
  (session state is exactly where it was left)

Client never comes back → session sits idle → LRU eventually ejects it.
  (snapshot taken before ejection if auto-snapshot is enabled)
```

The session has no concept of "connected" or "disconnected." It has `state` (active, snapshotted, killed, frozen) and `last_active_timestamp` (updated on every request). The HTTP layer manages connections. The session layer manages state. They are decoupled.

### 6.4 LRU Ejection

Each core maintains an LRU list of sessions ordered by `last_active_timestamp`. When a new session needs space and the core is at its `max_sessions_per_core` limit:

```
1. Find the least recently used session on this core.

2. If auto-snapshot is enabled and the session has unsaved changes:
   a. Snapshot the session to disk.
   b. Update the session index KB with the snapshot reference.

3. Reset the session's region in the per-core arena.
   (bump pointer region for this session goes back to its start)

4. Update session index KB: state = snapshotted, core_id = -1
   (not in RAM, but restorable from snapshot).

5. The arena space is now available for the new session.
```

Sessions are not deleted on ejection — they are snapshotted and can be restored. The global index KB at `root._client.{client_uuid}.sessions.{session_uuid}` persists. Only the in-RAM working data is reclaimed. Manual cleanup of old sessions is deferred — an admin or hygiene runner can purge them later.

### 6.5 Session Death

A session is permanently destroyed only when:

- The client explicitly requests it (`"action": "kill_session"`).
- An admin kills it.
- A hygiene runner purges it based on age or inactivity policy.

On kill:

```
1. If session is in RAM: reset its per-core arena region.
2. Delete snapshot files if they exist.
3. Retract the session index KB:
   root._client.{client_uuid}.sessions.{session_uuid}
4. The session_id is never reused (UUIDs don't collide).
```

---

## 7. Request Routing

### 7.1 Core Selection

A session is bound to a core at creation. All requests for that session route to that core. The binding is stored in the session index KB (`core_id` field) and in the VdrSession struct in the per-core arena.

If a session is restored from snapshot, it may land on a different core than originally. The session index KB is updated with the new `core_id`. The session's per-core arena data is rebuilt on the new core. This is transparent to the client — they use the same `session_id`.

### 7.2 Request Types

The HTTP handler determines the work operation from the request:

| HTTP Endpoint | VdrWorkOp | Description |
|---------------|-----------|-------------|
| POST /v1/inference | .inference | Full inference cycle (prompt → generate → response) |
| POST /v1/kb/query | .kb_query | Direct KB fact query |
| POST /v1/kb/assert | .kb_assert | Assert a fact to a KB |
| POST /v1/prolog/query | .prolog_query | Run a Prolog query |
| POST /v1/session/create | .session_create | Create a new session |
| POST /v1/session/snapshot | .session_snapshot | Snapshot current session |
| GET /health | (handled inline) | Returns 200 OK, no compute thread involved |

Health checks are handled directly by the HTTP handler — they never touch the ring buffer or compute threads. Everything else goes through the ring buffer.

### 7.3 Multiple Requests Per Session

Requests to the same session are serialized. The session's core processes them in FIFO order from its ring buffer. If client A and client B both send requests to the same session (shared session scenario), the requests queue on the core's ring buffer and execute one at a time. No concurrent access to the same session's state.

If a client sends a second request while the first is still processing, the second request queues behind the first on the ring buffer. The HTTP handler for the second request spin-waits until its work item completes. There is no request cancellation — once a work item is on the ring buffer, it will be processed.

---

## 8. Error Handling

### 8.1 HTTP-Level Errors

| Condition | HTTP Status | Description |
|-----------|-------------|-------------|
| Client not found | 401 | Unknown client_uuid |
| Auth failed | 401 | Invalid auth_token |
| Client suspended | 403 | Client account not active |
| Session not owned | 403 | Session belongs to a different client |
| Session not found | 404 | No session with this UUID |
| Session gone | 410 | Session was ejected and no snapshot exists |
| Queue full | 503 | Core's ring buffer is at capacity |
| Request timeout | 504 | Compute thread didn't complete in time |
| Malformed request | 400 | JSON parse error or missing required fields |

### 8.2 Compute-Level Errors

Errors during compute (arena exhaustion, KB access denied, Prolog depth exceeded, etc.) are written to the work item's `response_status` field. The HTTP handler reads this and translates it to an appropriate HTTP response with the Status struct serialized as JSON in the body.

The compute thread never crashes on an error. Every error is caught, written to the work item, and the thread returns to its spin-wait loop for the next item. The session state may or may not be modified depending on where the error occurred — the Status `detail` field carries enough information for the client to understand what happened.

---

## 9. Configuration

Relevant fields from `VdrSystemConfig`:

```
http_port: i32 = 1138,                  // listener port
max_sessions_per_core: i32 = 500,       // LRU ejection threshold
auto_snapshot_interval: i32 = 100,       // snapshot every N turns
default_max_turns: i32 = 0,             // 0 = unlimited
max_ephemeral_kbs_per_session: i32 = 1000,
max_facts_per_session_kb: i32 = 10000,
```

The ring buffer capacity is derived from `max_sessions_per_core` — sized to handle a burst of one request per active session on that core. Typical capacity: 512 or 1024 entries, rounded to a power of two for efficient modular arithmetic.

---

## 10. Global KB Layout

The complete client/organization/session tree:

```
root
├── _organization
│   └── {org_uuid}
│       ├── (org metadata: name, config overrides, default grants)
│       └── clients
│           ├── {client_uuid_0}   ← admin owner, always client 0
│           │   └── (auth hash, grants, default session limits)
│           ├── {client_uuid_1}
│           └── ...
│
├── _client
│   ├── {client_uuid_0}
│   │   ├── (client preferences, settings, usage counters)
│   │   └── sessions
│   │       ├── {session_uuid_a}  ← core_id, state, snapshot_ref, timestamps
│   │       └── {session_uuid_b}
│   ├── {client_uuid_1}
│   │   └── sessions
│   │       └── ...
│   └── ...
│
├── system
│   ├── oso
│   ├── confidence
│   ├── builtins
│   ├── command_vocab
│   ├── hygiene
│   ├── embedding
│   └── output
│
├── templates
│   ├── sentences
│   └── formats
│
└── (domain KBs with their own weights)
```

`root._organization` and `root._client` are normal global KBs, grant-gated like everything else. The admin client (client 0) has grants to everything. Other clients have grants assigned by the admin, which control:

- Which domain KBs they can access (determines their effective model).
- Session resource limits (how many KBs, facts, turns).
- Operational grants (filesystem, compile, execute, network, process).

The `_organization` prefix groups org-level structure. The `_client` prefix groups client-level structure. The underscore prefix is a convention indicating system-managed KBs — the LLM and clients can read them but typically don't write to them directly (the HTTP handler and session manager write the metadata).

---

## 11. Session Template and Clone

### 11.1 The Template

A session template is a pre-built, frozen session KB tree with the canonical `_llm.*` structure and empty data. It lives in the global arena:

```
root.system.session_template
    _llm.prompt_last       (empty)
    _llm.prompt_next       (empty)
    _llm.prompt_input      (empty)
    _llm.prompt_current    (empty)
    _llm.history           (empty bounded queue, capacity from config)
    _llm.projects          (empty)
    _llm.people            (empty)
    _llm.concepts          (empty)
    _llm.search            (empty)
    _llm.scratchpad        (empty)
```

This template is created once at startup and never modified. Every new session is a clone of this template.

### 11.2 Clone Mechanics

Cloning uses COW (copy-on-write) at the page level:

```
1. Allocate a CowPageTable in the per-core arena.
   - parent_session_id = template session ID
   - clone_session_id = new session's ID (negative, ephemeral)
   - n_pages = number of pages in the template's arena region
   - dirty_bits = bitmap, all zeros (nothing modified yet)

2. The clone's ephemeral tree root points to the template's structure.
   Reading any _llm.* KB reads from the template's pages (shared).

3. On first write to any page:
   a. CowPageTable.isDirty(page) returns false.
   b. Copy the page from template to clone's private region.
   c. CowPageTable.markDirty(page) sets the bit.
   d. Subsequent reads/writes to that page go to the private copy.

4. Pages never written are never copied.
   A fresh session that hasn't done anything yet uses almost zero
   private memory — it's all shared with the template.
```

This makes session creation nearly instant. The cost is deferred to the first write to each page. Since the template is empty, most pages are written on first use anyway — the COW overhead is minimal.

### 11.3 Session Independence

After cloning, the session is fully independent. Changes to the template (which shouldn't happen — it's frozen) don't affect existing sessions. Changes to one session don't affect others. The COW sharing is an implementation optimization, not a semantic dependency.

The session's ephemeral IDs start at -2 (session root is -1, first child is -2, then -3, -4, etc.). These IDs are local to the session and cannot collide with any other session's IDs or with global IDs.