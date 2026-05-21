# Attention, Context, and KB Integration Report

## Attention Window is the Session KB Tree

There is no fixed attention window. The LLM's attention is the session KB tree — structured data under its own management, unlimited in size, exact in precision, learnable at any time.

The LLM doesn't stuff tokens into a flat context buffer and hope the attention mechanism finds the relevant ones. It reads specific facts from specific KB addresses. The "window" is every KB the session can access, queried by address, not attended to by position.

## Session LLM Structure

Each session pre-creates a structured subtree for the LLM's own use:

```
session_root._llm
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
```

`prompt_last` holds what the LLM tracked from the previous prompt cycle. This is the continuity record — what the LLM decided was important enough to carry forward. Read at the start of each new prompt to reconstruct context.

`prompt_next` is where the LLM writes what it wants to track for the next prompt, based on what it's doing in the current prompt. This is continuity and planning — the LLM decides mid-response what state matters going forward.

`prompt_input` is what the client gave us. The raw user request for this cycle. Written by the system, read by the LLM. The LLM doesn't write here.

`prompt_current` is the scratchpad for this current prompt. Working memory for mid-prompt computation — intermediate results, partial plans, candidate responses. Cleared every prompt cycle.

`history` is a bounded queue where the LLM puts cycle history of the session. Oldest items drain when the queue reaches capacity. The LLM decides what summary or record to insert each cycle. Bounded growth by design — the queue capacity is set at session init.

`projects` tracks different projects in sub-KBs. This KB is the tracker of all projects — metadata about how they link, their ordering, whether active or dead, current status. Each project gets its own child KB under this node for its actual data.

`people` tracks people. Will have child KBs per context — different books, movies, organizations, friends of the client. People are important and confusing them or mixing things up causes problems, so they get their own space to track with hierarchy. A person appearing in multiple contexts gets sub-KBs per context under their person KB.

`concepts` tracks topics being discussed. Can reference searches stored in `._llm.search` as background material. The LLM organizes concept relationships here — what connects to what, what depends on what, what contradicts what.

`search` stores search results and background material the LLM has gathered. Referenced by `concepts` and other KBs as source material. Provenance tracks where each search result came from and its confidence level.

`scratchpad` is the whole-session scratchpad. Persists across prompts unlike `prompt_current`. The LLM can delete things here or keep adding. Bounded by the session's arena capacity, and if it grows large enough to be useful, it can be trained to produce a GEMM cache.

## Prompt Processing Flow

1. User input arrives. System writes it to `prompt_input`.
2. Attention phase loads. LLM reads `prompt_last` for continuity from previous cycle. LLM reads `prompt_input` for the current request. LLM reads any other KBs it needs — `history`, `projects`, `people`, `concepts`, whatever is relevant.
3. LLM uses `prompt_current` as scratch for this prompt's working data.
4. LLM writes to `prompt_next` what it wants to carry forward to the next cycle. This is the LLM's own choice — what it considers important for continuity.
5. After the attention phase completes, a builtin automatically copies `prompt_next` to `prompt_last`. This is not the LLM's choice — it always happens as part of the prompt processing structure. The LLM cannot skip or alter this step.
6. `prompt_next` is cleared. `prompt_current` is cleared. Ready for next cycle.

The LLM controls what goes into `prompt_next`. The system controls the structural transitions. The LLM manages everything under `history`, `projects`, `people`, `concepts`, `search`, `scratchpad` freely.

## Three Retrieval Paths

When the LLM needs data from a KB's weights, there are three paths based on what exists:

### Path 1: Full Fact Scan

A new KB with no trained GEMM cache. The system scans all facts in the KB directly at the 48-byte stride. Slow but correct. This is how a freshly populated KB works before anyone trains it — the data is usable immediately without waiting for training.

Test: `kb.weight_refs == null or kb.weight_refs.gemm_cache == null`. If true, full scan.

### Path 2: Group-Assigned GEMM Cache Only

The KB has been trained. A GEMM cache exists for the session's access group. Read the contiguous packed v_data. No fact scanning. This is the hot path during normal inference.

Test: GEMM cache exists and no new facts since last training. If true, use cache directly.

### Path 3: GEMM Cache Plus New Fact Scan

The KB has a GEMM cache from training, but new facts have been added since training. The system reads the GEMM cache first for all trained weights, then scans a short `ArrayListManaged` that tracks fact indices added since the last training run. Each new fact is looked up by its index — O(1) per fact. Slower than pure cache but faster than full scan.

Test: GEMM cache exists and new-facts list is non-empty. If true, read cache then scan new-facts list.

### Implementation

This is an if/else chain to different entry functions:

```
fn resolveWeights(kb: *Kb, group: GroupId) WeightView {
    if (kb.weight_refs == null or kb.weight_refs.gemm_cache == null) {
        return fullFactScan(kb);
    }
    const cache = kb.weight_refs.gemm_cache_for_group(group);
    if (kb.new_facts_since_training.items.len == 0) {
        return cacheOnly(cache);
    }
    return cachePlusNewFacts(cache, kb);
}
```

### New-Facts Tracking

Each KB gets an `ArrayListManaged(i32)` on the KB's arena storing fact indices of items added since the last GEMM training. When training completes, this list is cleared. When a new fact is written, its index is appended. All dynamic arrays in the system use `ArrayListManaged` on an arena — this is an operational rule, not a suggestion.

## Serialization: Byte-Exact Struct Data

No serialization format. No JSON for data (JSON is for config only). No protobuf. The data is structs and we byteslice them to disk.

### Save

Per KB, write the struct data as raw bytes:

```
./data/kb/root_science_physics_qed.dat
```

The dotted path becomes the filename with dots replaced by underscores. The file contains raw bytes of the Kb struct, the facts array, the rules array, the terms, the weight SoA-packed arrays if present, the new-facts-since-training list, and the GEMM cache data if present. Each section is a byte slice of the in-memory struct.

```zig
fn saveKb(kb: *Kb, path: []const u8) !void {
    const file = try std.fs.cwd().createFile(path, .{});
    defer file.close();
    try file.writeAll(std.mem.asBytes(kb));
    const facts_bytes = @as([*]const u8, @ptrCast(facts_ptr))[0..kb.facts_count * @sizeOf(Fact)];
    try file.writeAll(facts_bytes);
    // ... each section as raw byte slice
}
```

### Load

Read bytes from file, cast into structs:

```zig
fn loadKb(path: []const u8, arena: *Arena) ?*Kb {
    const file = std.fs.cwd().openFile(path, .{}) catch return null;
    defer file.close();
    const kb = arena.allocTyped(Kb) orelse return null;
    const kb_bytes = @as([*]u8, @ptrCast(kb))[0..@sizeOf(Kb)];
    _ = file.readAll(kb_bytes) catch return null;
    const facts = arena.allocSlice(Fact, @intCast(kb.facts_count)) orelse return null;
    const facts_bytes = @as([*]u8, @ptrCast(facts.ptr))[0..kb.facts_count * @sizeOf(Fact)];
    _ = file.readAll(facts_bytes) catch return null;
    return kb;
}
```

No parsing. No deserialization. The bytes in the file are the struct. The struct in memory is the bytes. Byte-exact round trip.

The file format is tied to the struct layout. If the struct changes, old files are incompatible. A version field in the Kb struct header catches mismatches on load. Migration is a separate offline tool. x86_64 only, little-endian, fixed struct sizes, no padding ambiguity.

## Integration Summary

| Concern | Solution |
|---------|----------|
| Attention window | Session KB tree, unlimited, structured, precise |
| Context reconstruction | LLM reads `prompt_last` + `prompt_input`, writes `prompt_next` for next cycle |
| Continuity | System copies `prompt_next` → `prompt_last` automatically after each cycle |
| LLM working memory | Pre-structured `_llm.*` subtree with bounded history queue |
| New KB without training | Path 1: full fact scan, usable immediately |
| Trained KB inference | Path 2: group-assigned GEMM cache, fastest |
| Trained KB with new data | Path 3: GEMM cache + new-facts list scan |
| Dynamic arrays | `ArrayListManaged` on arena, always |
| Save to disk | Byte slice of struct data per KB, raw bytes |
| Load from disk | Read bytes, cast to struct, allocate into arena |
| File naming | `./data/kb/root_science_physics_qed.dat` |
| Post-startup allocation | Only temporary training arenas, destroyed after use |