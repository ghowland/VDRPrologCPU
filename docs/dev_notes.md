## Additional Context for New Developer Sessions

### Zig 0.15.1 Specifics

- Use `std.debug.print` for all output. No `std.io.getStdOut()`.
- Build API uses `.root_module = b.createModule(...)` pattern for `addObject`/`addExecutable`. Verify against 0.15.1 — the API changed across versions.
- `linkLibC()` and `linkSystemLibrary()` may be on the module, not the compile step. Check 0.15.1 docs.
- Integer timestamps only. `std.time.timestamp()` returns epoch seconds, truncate to i32. `std.time.nanoTimestamp()` for benchmarks as i64. Never convert to float.

### Q16 Arithmetic

Q16 has three fields: `v: i32, r0: i16, r1: i16`. D=65536, implicit. `r1` is the second remainder slot — not padding. Every `fromParts` call takes three arguments: `fromParts(v, r0, r1)`. Two-argument calls are bugs.

Softmax reaching exact unity (sum = 65536 every time) is proven in a CPU toy model benchmark. Not theoretical — it ran, passed, 20 epochs, zero violations.

### VdrId Sign-Bit Partitioning

Positive i64 = global (persistent, shared). Negative i64 = session (session-local, dies with session). This is the sign bit of the value itself, not a flag in a struct. `VdrId.isGlobal()` checks `v >= 0`. Session IDs decrement from -1. They cannot collide with global IDs. When resolving a path, session tree is checked first, then global. Session shadows global at the same path position.

### Model Weights Live in KBs

The model is a tree of KBs. `root.model.layers.layer_00.attention.qkv_weights` is a KB. Access to model weight KBs is grant-gated. A user without grants to certain layers literally cannot use them. The forward pass checks access per layer. Different users see different models.

### Execution Levels Drive Real-World Cost

L1 (full LLM, 50-500 tokens) → L2 (LLM invokes stored rule, ~18 tokens) → L3 (Prolog fires automatically, 0 tokens). At maturity, 93% of operations are L3. Forward pass tok/s is not the only performance metric — the L3 ratio determines actual cost. A system running 93% L3 on a laptop outperforms 100% L1 on a GPU cluster.

### HTTP is a Connector, Not a Web Server

The HTTP listener receives JSON work requests and passes them to NUMA-pinned threads. Non-pinned threads handle HTTP so they never disturb SIMD compute threads. Pinned threads only do compute — they never touch the network.

### Arena Reset is the Garbage Collector

No free. No GC. When a session dies, its session arena region resets (cursor = 0). All session data gone. Global arena data is never freed during operation. Arena exhaustion returns `ErrorCode.arena_exhausted`, never silent corruption.

### The Config is Not Optional

JSON config loaded at startup drives everything: core count, arena sizes, model dimensions, session limits. No hardcoded fallback. If config can't load and parse into `SystemConfig`, print the error and exit. Silent defaults hide misconfiguration.

### File Prefix

All source files use `vdr_` prefix (not `vdr_`). The project was renamed from TensorProlog to VDR-Prolog. VDR = Value, Denominator, Remainder.

### No Floating Point

Anywhere. Ever. Not in HTTP parsing, not in timing, not in logging, not in arithmetic. Every number in the system is an integer.

---

### Global/Session ID System

Every entity gets a 64-bit ID (`VdrId`). The sign bit (bit 63) partitions the address space:

- **Positive (bit 63 = 0):** Global. Persistent. Shared across sessions.
- **Negative (bit 63 = 1):** Session. Session-local. Dies with session.

Every KB has **dual addressing** — reachable two ways:

**Walk path** (sequential tree position IDs):
```
root.science.physics.qed.alpha_em = 0.12.17.13.25
```

root = 0.
session_root = -1.

**Direct UUID** (hash-based, one hop):
```
alpha_em has its own UUID as a positive number
qed has its own UUID
physics has its own UUID
```

Both resolve to the same KB. Walk traverses the tree. Direct jumps by UUID. The kernel can specify exactly a KB or a fact within it either way.

**Session tree per session:**

Each session gets an session root at -1. IDs monotonically decrement:

```
session_root = -1
session_root.science.physics.qed.alpha_em = -1.-2.-3.-4.-5
```

Each new session KB also gets its own UUID, but the UUID is negative, so it's still session.

**Writing new data:**

The LLM can write a new fact that locally becomes `qed.alpha_strong` as walk ID -6 in the session's session tree, and it gets its own negative UUID. The session can write data that is session and marked in negatives — these will never collide with global data because global data traverses positive numbers and global UUIDs are positive numbers.

**Promotion:**

When the LLM decides session data is worth keeping, it explicitly asserts to a global KB path. The data crosses from negative to positive address space. Session data never leaks to global implicitly.

**Resolution order:**

When the LLM queries a path, session is checked first:
1. Check session's session tree for that path
2. If not found, check global tree
3. Session shadows global at the same path position

---

### Global/Session ID System

Every entity gets a signed 64-bit UUID (`VdrId`) for direct access from a lookup table:

- **Positive UUID:** Global. Persistent. Shared across sessions.
- **Negative UUID:** Session. Session-local. Dies with session.

#### Three Levels of Addressing

**1. UUID** — signed 64-bit, globally unique. Stored in a LUT for O(1) direct access. KBs, facts, rules, grammars — everything gets a UUID. Positive for global, negative for session.

**2. Dotted path** — hierarchical mount path from root. Global paths start from `root` (ID 0). Session paths start from `session_root` (ID -1). Used for tree traversal and human-readable references.

**3. Local index** — array slot within a KB for a given data type. This is just the position in the KB's array. First fact is 0, second is 1, etc.

#### Example — Building a Global KB Tree

```
root                    UUID: 0
root.science            UUID: +4827      local index: 0 (first child of root)
root.science.physics    UUID: +9153      local index: 0 (first child of science)
root.science.chemistry  UUID: +9154      local index: 1 (second child of science)
```

`root.science` in dotted numbers is `0.0` — root is 1, science is local index 0 within root.

`root.science.physics` in dotted numbers is `0.0.0` — physics is local index 0 within science.

You can reach physics by walking `0.0.0` or by jumping directly to UUID `+9153`. Both resolve to the same KB.

Within the physics KB, individual entries (facts, rules, etc.) have their own local indices. The first fact in physics is slot 0, the second is slot 1. Each also gets its own positive UUID for direct access.

#### Session Data — Shadowing Global

When a session wants to work with `root.science.physics.qed`, it creates session KBs that mirror the path up to the mount point:

```
session_root                           UUID: -1
session_root.science                   UUID: -2     local index: 0
session_root.science.physics           UUID: -3     local index: 0
session_root.science.physics.qed       UUID: -4     local index: 0
```

These session KBs copy the structure of the global path. From the mount point, the session starts adding its own data with negative UUIDs:

```
session_root.science.physics.qed.alpha_strong    UUID: -5    local index: 0 (first entry in session's qed)
session_root.science.physics.qed.notes           UUID: -6    local index: 1
```

Session UUIDs are always negative. Global UUIDs are always positive. They never collide.

#### Why This Works

The session can use both global and session data on a given topic. When querying `root.science.physics.qed`:

1. Check session tree at `session_root.science.physics.qed` — find session-local data
2. Check global tree at `root.science.physics.qed` — find shared data
3. Both are available with full provenance tracking
4. No collision possible — different sign, different UUID space

The session can read global `alpha_em` (positive UUID) and its own `alpha_strong` (negative UUID) side by side. The provenance on each fact records which space it came from.

#### Promotion

When session data is worth keeping globally, the LLM explicitly asserts it to a global KB path. It gets a new positive UUID. The session version can be left to die or retracted. Session data never leaks to global implicitly.

#### Local Index Within a KB

Inside any KB (global or session), entries are just array slots:

```
root.science.physics (UUID: +9153)
    facts[0] = mass_electron     (also has UUID: +20481)
    facts[1] = charge_electron   (also has UUID: +20482)
    facts[2] = speed_of_light    (also has UUID: +20483)
    rules[0] = derive_energy     (also has UUID: +20484)
```

Local index 0/1/2 is meaningful only within this KB. The UUID is meaningful everywhere. Both are valid ways to reference the same data.

---

