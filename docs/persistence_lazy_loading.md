# VDR-Prolog KB Persistence and Lazy Loading

## Technical Specification

---

## 1. Overview

KBs are saved as raw byte slices of their in-memory structs. No serialization format. No JSON for data. No protobuf. No schema evolution in the file — the bytes in the file are the struct, the struct in memory is the bytes.

KBs are loaded lazily. At startup, the system reads a manifest of what exists on disk but does not load KB data into arena memory until something actually accesses it. A KB that attention never reaches is never loaded. A KB accessed once stays resident until arena pressure forces eviction.

If the struct layout changes between versions, a separate offline converter tool reads old-version files and writes new-version files. The runtime only handles the current version. This keeps the hot path free of version-checking branches and migration logic.

---

## 2. File Layout

### 2.1 Directory Structure

```
data/
├── manifest.dat           — KB index: what exists, where, what version
├── kb/
│   ├── 0000000001.kb      — root (id: +1)
│   ├── 0000000002.kb      — root.system (id: +2)
│   ├── 0000000003.kb      — root.system.oso (id: +3)
│   ├── 0000000008.kb      — root.system.embedding (id: +8)
│   └── ...
├── weights/
│   ├── 0000000008_m0.wt   — embedding matrix_refs[0]
│   ├── 0000000009_m0.wt   — output matrix_refs[0]
│   ├── 0000000009_v0.wt   — output vector_refs[0] (final norm)
│   └── ...
└── snapshots/
    ├── {session_uuid}.snap
    └── ...
```

Filenames are the VdrId value zero-padded to 10 digits. Positive IDs only — session-local (negative) KBs are never persisted individually (they live in session snapshots). Weight files are suffixed with `_m{index}` for matrices and `_v{index}` for vectors, keyed to the KB ID that owns them.

### 2.2 KB File Format

A `.kb` file is a sequence of byte regions, each a direct byteslice of an in-memory array:

```
┌──────────────────────────────────────────┐
│ KbFileHeader (fixed size)                │
├──────────────────────────────────────────┤
│ KB struct (256 bytes, padded)            │
├──────────────────────────────────────────┤
│ Facts array (facts_count × 48 bytes)     │
├──────────────────────────────────────────┤
│ Rules array (rules_count × 48 bytes)     │
├──────────────────────────────────────────┤
│ Terms array (terms_count × 24 bytes)     │
├──────────────────────────────────────────┤
│ Children ID array (children_count × 8)   │
├──────────────────────────────────────────┤
│ Text blob (raw bytes, variable length)   │
├──────────────────────────────────────────┤
│ KbWeightRefs struct (if present)         │
├──────────────────────────────────────────┤
│ New-facts-since-training indices         │
│   (new_facts_count × 4 bytes)            │
└──────────────────────────────────────────┘
```

### 2.3 File Header

```
const KB_FILE_MAGIC = [4]u8{ 'V', 'D', 'K', 'B' };
const KB_FILE_VERSION: i32 = 1;

const KbFileHeader = struct {
    magic: [4]u8 = KB_FILE_MAGIC,
    version: i32 = KB_FILE_VERSION,
    kb_id: VdrId = .{},
    kb_struct_size: i32 = @sizeOf(KB),     // 256
    fact_struct_size: i32 = @sizeOf(Fact),  // 48
    rule_struct_size: i32 = @sizeOf(Rule),  // 48
    term_struct_size: i32 = @sizeOf(Term),  // 24

    facts_count: i32 = 0,
    rules_count: i32 = 0,
    terms_count: i32 = 0,
    children_count: i16 = 0,
    text_length: i32 = 0,
    has_weight_refs: bool = false,
    new_facts_count: i32 = 0,

    // Byte offsets from start of file for each region
    kb_offset: i64 = 0,
    facts_offset: i64 = 0,
    rules_offset: i64 = 0,
    terms_offset: i64 = 0,
    children_offset: i64 = 0,
    text_offset: i64 = 0,
    weight_refs_offset: i64 = 0,
    new_facts_offset: i64 = 0,

    total_size: i64 = 0,
    checksum: u32 = 0,  // CRC32 over everything after the header
};
```

The header stores struct sizes so the version check is immediate: if `kb_struct_size != @sizeOf(KB)`, the file was written by a different struct version. Reject and tell the user to run the converter. No attempt to parse mismatched structs at runtime.

### 2.4 Weight File Format

Weight data is stored separately from the KB file because weight arrays are large and benefit from independent loading. A weight file is:

```
┌──────────────────────────────────────────┐
│ WeightFileHeader (fixed size)            │
├──────────────────────────────────────────┤
│ v array (count × 4 bytes, i32)           │
├──────────────────────────────────────────┤
│ r0 array (count × 2 bytes, i16)          │
├──────────────────────────────────────────┤
│ r1 array (count × 2 bytes, i16)          │
└──────────────────────────────────────────┘
```

```
const WEIGHT_FILE_MAGIC = [4]u8{ 'V', 'D', 'W', 'T' };
const WEIGHT_FILE_VERSION: i32 = 1;

const WeightFileHeader = struct {
    magic: [4]u8 = WEIGHT_FILE_MAGIC,
    version: i32 = WEIGHT_FILE_VERSION,
    kb_id: VdrId = .{},
    ref_type: i8 = 0,        // 0 = matrix, 1 = vector
    ref_index: i32 = 0,      // index in matrix_refs or vector_refs
    rows: i32 = 0,           // matrix only
    cols: i32 = 0,           // matrix only
    length: i32 = 0,         // vector only (or rows*cols for matrix)
    element_count: i64 = 0,
    v_offset: i64 = 0,
    r0_offset: i64 = 0,
    r1_offset: i64 = 0,
    total_size: i64 = 0,
    checksum: u32 = 0,
};
```

Weight files can be tens or hundreds of megabytes. Keeping them separate means the KB struct and its facts/rules can load in microseconds. The weight data loads only when the inference engine actually needs it.

---

## 3. Save

### 3.1 Saving a KB

```
fn saveKb(kb: *KB, global_arena: *Arena, data_dir: []const u8) Status {
    // Build filename: data/kb/0000000001.kb
    var path_buf: [256]u8 = undefined;
    const path = formatKbPath(kb.id, data_dir, &path_buf);

    // Open file
    const file = std.fs.cwd().createFile(path, .{}) catch {
        return Status.err(.system, .init_failed, 0);
    };
    defer file.close();

    // Build header
    var header = KbFileHeader{};
    header.kb_id = kb.id;
    header.facts_count = kb.facts_count;
    header.rules_count = kb.rules_count;
    header.terms_count = getTermsCount(kb, global_arena);
    header.children_count = kb.children_count;
    header.text_length = getTextLength(kb, global_arena);
    header.has_weight_refs = (kb.weight_refs_offset != -1);
    header.new_facts_count = kb.new_facts_since_training_count;

    // Calculate offsets (sequential, no gaps)
    var offset: i64 = @sizeOf(KbFileHeader);
    header.kb_offset = offset;
    offset += @sizeOf(KB);
    header.facts_offset = offset;
    offset += @as(i64, header.facts_count) * @sizeOf(Fact);
    header.rules_offset = offset;
    offset += @as(i64, header.rules_count) * @sizeOf(Rule);
    header.terms_offset = offset;
    offset += @as(i64, header.terms_count) * @sizeOf(Term);
    header.children_offset = offset;
    offset += @as(i64, header.children_count) * @sizeOf(VdrId);
    header.text_offset = offset;
    offset += @as(i64, header.text_length);
    if (header.has_weight_refs) {
        header.weight_refs_offset = offset;
        offset += @sizeOf(KbWeightRefs);
    }
    header.new_facts_offset = offset;
    offset += @as(i64, header.new_facts_count) * 4;
    header.total_size = offset;

    // Write header (checksum filled after all data written)
    file.writeAll(std.mem.asBytes(&header)) catch return Status.err(.system, .init_failed, 1);

    // Write KB struct — direct byteslice
    file.writeAll(std.mem.asBytes(kb)) catch return Status.err(.system, .init_failed, 2);

    // Write facts array — contiguous byteslice from arena
    const facts = getFactSlice(kb, global_arena);
    file.writeAll(std.mem.sliceAsBytes(facts)) catch return Status.err(.system, .init_failed, 3);

    // Write rules array
    const rules = getRuleSlice(kb, global_arena);
    file.writeAll(std.mem.sliceAsBytes(rules)) catch return Status.err(.system, .init_failed, 4);

    // Write terms array
    const terms = getTermSlice(kb, global_arena);
    file.writeAll(std.mem.sliceAsBytes(terms)) catch return Status.err(.system, .init_failed, 5);

    // Write children ID array
    const children = getChildrenSlice(kb, global_arena);
    file.writeAll(std.mem.sliceAsBytes(children)) catch return Status.err(.system, .init_failed, 6);

    // Write text blob
    const text = getTextSlice(kb, global_arena);
    file.writeAll(text) catch return Status.err(.system, .init_failed, 7);

    // Write KbWeightRefs if present
    if (header.has_weight_refs) {
        const wrefs = getWeightRefs(kb, global_arena);
        file.writeAll(std.mem.asBytes(wrefs)) catch return Status.err(.system, .init_failed, 8);
    }

    // Write new-facts-since-training indices
    const new_facts = getNewFactIndices(kb, global_arena);
    file.writeAll(std.mem.sliceAsBytes(new_facts.items)) catch return Status.err(.system, .init_failed, 9);

    // Seek back and write checksum
    const crc = computeFileCrc(file, @sizeOf(KbFileHeader), header.total_size);
    header.checksum = crc;
    file.seekTo(0) catch return Status.err(.system, .init_failed, 10);
    file.writeAll(std.mem.asBytes(&header)) catch return Status.err(.system, .init_failed, 11);

    return Status.ok();
}
```

### 3.2 Saving Weight Files

Weight data is saved separately per matrix/vector:

```
fn saveWeights(kb: *KB, global_arena: *Arena, data_dir: []const u8) Status {
    const wrefs = getWeightRefs(kb, global_arena);
    if (wrefs == null) return Status.ok(); // no weights to save

    // Save each matrix
    var mi: i32 = 0;
    while (mi < wrefs.matrix_count) : (mi += 1) {
        const matrix = &wrefs.matrix_refs[@intCast(mi)];
        const status = saveWeightMatrix(kb.id, mi, matrix, data_dir);
        if (status.isErr()) return status;
    }

    // Save each vector
    var vi: i32 = 0;
    while (vi < wrefs.vector_count) : (vi += 1) {
        const vector = &wrefs.vector_refs[@intCast(vi)];
        const status = saveWeightVector(kb.id, vi, vector, data_dir);
        if (status.isErr()) return status;
    }

    return Status.ok();
}

fn saveWeightMatrix(kb_id: VdrId, index: i32, matrix: *WeightMatrix, data_dir: []const u8) Status {
    var path_buf: [256]u8 = undefined;
    const path = formatWeightPath(kb_id, 'm', index, data_dir, &path_buf);

    const file = std.fs.cwd().createFile(path, .{}) catch {
        return Status.err(.system, .init_failed, 0);
    };
    defer file.close();

    const N: usize = @intCast(@as(i64, matrix.rows) * @as(i64, matrix.cols));

    var header = WeightFileHeader{};
    header.kb_id = kb_id;
    header.ref_type = 0; // matrix
    header.ref_index = index;
    header.rows = matrix.rows;
    header.cols = matrix.cols;
    header.element_count = @intCast(N);

    var offset: i64 = @sizeOf(WeightFileHeader);
    header.v_offset = offset;
    offset += @as(i64, @intCast(N)) * 4;
    header.r0_offset = offset;
    offset += @as(i64, @intCast(N)) * 2;
    header.r1_offset = offset;
    offset += @as(i64, @intCast(N)) * 2;
    header.total_size = offset;

    // Write header
    file.writeAll(std.mem.asBytes(&header)) catch return Status.err(.system, .init_failed, 1);

    // Write v array — direct byteslice, contiguous i32
    const v_bytes = @as([*]const u8, @ptrCast(matrix.v.ptr))[0 .. N * 4];
    file.writeAll(v_bytes) catch return Status.err(.system, .init_failed, 2);

    // Write r0 array — contiguous i16
    const r0_bytes = @as([*]const u8, @ptrCast(matrix.r0.ptr))[0 .. N * 2];
    file.writeAll(r0_bytes) catch return Status.err(.system, .init_failed, 3);

    // Write r1 array — contiguous i16
    const r1_bytes = @as([*]const u8, @ptrCast(matrix.r1.ptr))[0 .. N * 2];
    file.writeAll(r1_bytes) catch return Status.err(.system, .init_failed, 4);

    // Checksum
    const crc = computeFileCrc(file, @sizeOf(WeightFileHeader), header.total_size);
    header.checksum = crc;
    file.seekTo(0) catch return Status.err(.system, .init_failed, 5);
    file.writeAll(std.mem.asBytes(&header)) catch return Status.err(.system, .init_failed, 6);

    return Status.ok();
}
```

### 3.3 When Save Happens

KBs are saved:

- **After training.** When `train()` completes and writes updated weights back to the global arena, the KB and its weight files are saved.
- **On explicit save command.** The admin or a runner can issue a save command for specific KBs or all dirty KBs.
- **On shutdown.** Clean shutdown saves all modified KBs.
- **On periodic checkpoint.** A hygiene runner can periodically save KBs whose `last_modified` exceeds their last save timestamp.

Session-local KBs (negative IDs) are never saved individually. They persist only within session snapshots.

### 3.4 Dirty Tracking

Each KB's `last_modified` timestamp is compared against the manifest's `last_saved` timestamp to determine if a KB needs saving:

```
fn isDirty(kb: *KB, manifest: *Manifest) bool {
    const entry = manifest.lookup(kb.id) orelse return true; // not in manifest = needs save
    return kb.last_modified > entry.last_saved;
}
```

No separate dirty flag. The timestamps are the truth.

---

## 4. Manifest

### 4.1 Purpose

The manifest is the system's index of all persisted KBs. At startup, the manifest is the only file that must be read. It tells the system what KBs exist, their IDs, their paths, their parent relationships, and what version they were saved with — without loading any KB data.

### 4.2 Manifest Format

```
const MANIFEST_MAGIC = [4]u8{ 'V', 'D', 'M', 'F' };
const MANIFEST_VERSION: i32 = 1;

const ManifestHeader = struct {
    magic: [4]u8 = MANIFEST_MAGIC,
    version: i32 = MANIFEST_VERSION,
    entry_count: i32 = 0,
    entry_struct_size: i32 = @sizeOf(ManifestEntry),
    last_written: i32 = 0,
    checksum: u32 = 0,
};

const ManifestEntry = struct {
    kb_id: VdrId = .{},
    parent_id: VdrId = .{},
    path_hash: u32 = 0,         // hash of dotted path for quick lookup
    name_offset: i32 = 0,       // offset into manifest text section
    name_length: i16 = 0,
    path_offset: i32 = 0,       // offset into manifest text section
    path_length: i16 = 0,
    kb_file_version: i32 = 0,   // KB_FILE_VERSION at save time
    has_weights: bool = false,
    weight_matrix_count: i32 = 0,
    weight_vector_count: i32 = 0,
    facts_count: i32 = 0,
    children_count: i16 = 0,
    frozen: bool = false,
    last_saved: i32 = 0,        // timestamp of last save
    file_size: i64 = 0,         // total .kb file size in bytes
    loaded: bool = false,        // runtime flag, not persisted (always false on disk)
};
```

The manifest file:

```
┌──────────────────────────────────────────┐
│ ManifestHeader                           │
├──────────────────────────────────────────┤
│ ManifestEntry[0]                         │
│ ManifestEntry[1]                         │
│ ...                                      │
│ ManifestEntry[entry_count - 1]           │
├──────────────────────────────────────────┤
│ Text section (names and paths, packed)   │
└──────────────────────────────────────────┘
```

### 4.3 Manifest Loading at Startup

The manifest is the first thing read after arena allocation:

```
fn loadManifest(global_arena: *Arena, data_dir: []const u8) ?*Manifest {
    var path_buf: [256]u8 = undefined;
    const path = formatManifestPath(data_dir, &path_buf);

    const file = std.fs.cwd().openFile(path, .{}) catch return null;
    defer file.close();

    // Read header
    var header: ManifestHeader = undefined;
    const header_bytes = @as([*]u8, @ptrCast(&header))[0..@sizeOf(ManifestHeader)];
    _ = file.readAll(header_bytes) catch return null;

    // Validate
    if (!std.mem.eql(u8, &header.magic, &MANIFEST_MAGIC)) return null;
    if (header.version != MANIFEST_VERSION) return null;
    if (header.entry_struct_size != @sizeOf(ManifestEntry)) return null;

    // Allocate manifest in global arena
    const manifest = global_arena.allocTyped(Manifest) orelse return null;
    manifest.entries = global_arena.allocSlice(ManifestEntry, @intCast(header.entry_count)) orelse return null;
    manifest.count = header.entry_count;

    // Read all entries — direct byteslice into arena memory
    const entries_bytes = @as([*]u8, @ptrCast(manifest.entries.ptr))[0 .. @as(usize, @intCast(header.entry_count)) * @sizeOf(ManifestEntry)];
    _ = file.readAll(entries_bytes) catch return null;

    // Read text section
    const text_size = file.getEndPos() catch return null;
    const text_offset = @sizeOf(ManifestHeader) + @as(usize, @intCast(header.entry_count)) * @sizeOf(ManifestEntry);
    const text_length = text_size - text_offset;
    manifest.text = global_arena.allocSlice(u8, text_length) orelse return null;
    _ = file.readAll(manifest.text) catch return null;

    // Clear all loaded flags (runtime state, not persisted)
    for (manifest.entries) |*entry| {
        entry.loaded = false;
    }

    // Build path_hash → entry index lookup table for O(1) access
    manifest.buildIndex(global_arena);

    return manifest;
}
```

After loading the manifest, the system knows:
- Every KB that exists on disk.
- Their IDs, paths, parent relationships.
- Which ones have weight files.
- Their fact/rule/children counts.
- Whether they are frozen.

No KB data is in memory yet. The manifest entries are ~100 bytes each. For 100K KBs, the manifest is ~10 MB. This fits easily in the global arena.

### 4.4 Manifest Save

The manifest is rewritten whenever KBs are saved:

```
fn saveManifest(manifest: *Manifest, data_dir: []const u8) Status {
    var path_buf: [256]u8 = undefined;
    const path = formatManifestPath(data_dir, &path_buf);

    // Write to a temp file, then rename for atomicity
    var tmp_path_buf: [256]u8 = undefined;
    const tmp_path = formatManifestTmpPath(data_dir, &tmp_path_buf);

    const file = std.fs.cwd().createFile(tmp_path, .{}) catch {
        return Status.err(.system, .init_failed, 0);
    };
    defer file.close();

    var header = ManifestHeader{};
    header.entry_count = manifest.count;
    header.last_written = currentTimestamp();

    file.writeAll(std.mem.asBytes(&header)) catch return Status.err(.system, .init_failed, 1);

    // Clear runtime flags before writing
    for (manifest.entries) |*entry| {
        entry.loaded = false;  // don't persist runtime state
    }

    file.writeAll(std.mem.sliceAsBytes(manifest.entries)) catch return Status.err(.system, .init_failed, 2);
    file.writeAll(manifest.text) catch return Status.err(.system, .init_failed, 3);

    // Checksum, write back header
    const crc = computeFileCrc(file, @sizeOf(ManifestHeader), file.getEndPos() catch 0);
    header.checksum = crc;
    file.seekTo(0) catch return Status.err(.system, .init_failed, 4);
    file.writeAll(std.mem.asBytes(&header)) catch return Status.err(.system, .init_failed, 5);

    // Atomic rename
    std.fs.cwd().rename(tmp_path, path) catch return Status.err(.system, .init_failed, 6);

    return Status.ok();
}
```

The temp-file-then-rename pattern ensures the manifest is never half-written. If the system crashes during save, the old manifest is intact.

---

## 5. Lazy Loading

### 5.1 Principle

At startup, only the manifest is loaded. KBs are loaded on first access. A KB that is never accessed is never loaded. This means startup time is proportional to the manifest size (fast), not the total data size (slow).

### 5.2 Load States

A KB can be in one of three states relative to memory:

```
UNLOADED    — Exists in manifest. No data in arena. File on disk.
LOADED      — Manifest entry + full data in global arena. Ready for use.
STUB        — Manifest entry + KB struct only (no facts/rules/terms/weights).
              Enough to traverse the tree and check metadata.
              Promoted to LOADED on first data access.
```

The stub state exists because tree traversal needs to walk parent-child relationships without loading every KB along the path. The KB struct (256 bytes) is enough to know the children list, the path, and the identity. Loading 256 bytes per KB for the tree skeleton is cheap. Loading 50MB of physics weight data to traverse past `root.science.physics` on the way to `root.science.chemistry` is wasteful.

### 5.3 Loading Flow

```
fn resolveKb(id: VdrId, store: *KbStore) ?*KB {
    // Check 1: Already loaded in arena?
    if (store.loaded_lut.get(id)) |kb| {
        return kb;
    }

    // Check 2: In manifest?
    const entry = store.manifest.lookup(id) orelse return null;

    // Load from disk
    const kb = loadKbFromDisk(id, entry, store) orelse return null;
    store.loaded_lut.put(id, kb);
    entry.loaded = true;

    return kb;
}

fn loadKbFromDisk(id: VdrId, entry: *ManifestEntry, store: *KbStore) ?*KB {
    var path_buf: [256]u8 = undefined;
    const path = formatKbPath(id, store.data_dir, &path_buf);

    const file = std.fs.cwd().openFile(path, .{}) catch return null;
    defer file.close();

    // Read and validate header
    var header: KbFileHeader = undefined;
    const header_bytes = @as([*]u8, @ptrCast(&header))[0..@sizeOf(KbFileHeader)];
    _ = file.readAll(header_bytes) catch return null;

    if (!std.mem.eql(u8, &header.magic, &KB_FILE_MAGIC)) return null;
    if (header.version != KB_FILE_VERSION) return null;
    if (header.kb_struct_size != @sizeOf(KB)) return null;
    if (header.fact_struct_size != @sizeOf(Fact)) return null;

    // Verify checksum
    const crc = computeFileCrc(file, @sizeOf(KbFileHeader), header.total_size);
    if (crc != header.checksum) return null;

    const arena = store.global_arena;

    // Allocate KB struct in arena
    const kb = arena.allocTyped(KB) orelse return null;

    // Read KB struct — direct byteslice cast
    const kb_bytes = @as([*]u8, @ptrCast(kb))[0..@sizeOf(KB)];
    file.seekTo(@intCast(header.kb_offset)) catch return null;
    _ = file.readAll(kb_bytes) catch return null;

    // Allocate and read facts
    if (header.facts_count > 0) {
        const facts = arena.allocSlice(Fact, @intCast(header.facts_count)) orelse return null;
        const facts_bytes = std.mem.sliceAsBytes(facts);
        file.seekTo(@intCast(header.facts_offset)) catch return null;
        _ = file.readAll(facts_bytes) catch return null;

        // Patch the KB's facts_offset to point to the new arena location
        kb.facts_offset = arenaOffset(arena, @ptrCast(facts.ptr));
    }

    // Allocate and read rules
    if (header.rules_count > 0) {
        const rules = arena.allocSlice(Rule, @intCast(header.rules_count)) orelse return null;
        const rules_bytes = std.mem.sliceAsBytes(rules);
        file.seekTo(@intCast(header.rules_offset)) catch return null;
        _ = file.readAll(rules_bytes) catch return null;

        kb.rules_offset = arenaOffset(arena, @ptrCast(rules.ptr));
    }

    // Allocate and read terms
    if (header.terms_count > 0) {
        const terms = arena.allocSlice(Term, @intCast(header.terms_count)) orelse return null;
        const terms_bytes = std.mem.sliceAsBytes(terms);
        file.seekTo(@intCast(header.terms_offset)) catch return null;
        _ = file.readAll(terms_bytes) catch return null;

        // Patch term offsets in rules (they reference term positions)
        // Terms are stored contiguously, so a base offset shift works
    }

    // Allocate and read children IDs
    if (header.children_count > 0) {
        const children = arena.allocSlice(VdrId, @intCast(header.children_count)) orelse return null;
        const children_bytes = std.mem.sliceAsBytes(children);
        file.seekTo(@intCast(header.children_offset)) catch return null;
        _ = file.readAll(children_bytes) catch return null;

        kb.children_offset = arenaOffset(arena, @ptrCast(children.ptr));
    }

    // Allocate and read text blob
    if (header.text_length > 0) {
        const text = arena.allocSlice(u8, @intCast(header.text_length)) orelse return null;
        file.seekTo(@intCast(header.text_offset)) catch return null;
        _ = file.readAll(text) catch return null;

        kb.name_offset = arenaOffset(arena, text.ptr) + kb.name_offset; // patch
        kb.path_offset = arenaOffset(arena, text.ptr) + kb.path_offset; // patch
    }

    // Read KbWeightRefs struct (but NOT the actual weight data yet)
    if (header.has_weight_refs) {
        const wrefs = arena.allocTyped(KbWeightRefs) orelse return null;
        const wrefs_bytes = @as([*]u8, @ptrCast(wrefs))[0..@sizeOf(KbWeightRefs)];
        file.seekTo(@intCast(header.weight_refs_offset)) catch return null;
        _ = file.readAll(wrefs_bytes) catch return null;

        kb.weight_refs_offset = arenaOffset(arena, @ptrCast(wrefs));

        // Weight matrix/vector data is NOT loaded here.
        // The v/r0/r1 slice pointers in WeightMatrix/WeightVector are stale
        // (they pointed into the arena of the process that saved them).
        // They are nulled and loaded on first GEMM access.
        for (wrefs.matrix_refs[0..@intCast(wrefs.matrix_count)]) |*matrix| {
            matrix.v = &.{};
            matrix.r0 = &.{};
            matrix.r1 = &.{};
        }
        for (wrefs.vector_refs[0..@intCast(wrefs.vector_count)]) |*vector| {
            vector.v = &.{};
            vector.r0 = &.{};
            vector.r1 = &.{};
        }
    }

    // Read new-facts-since-training indices
    if (header.new_facts_count > 0) {
        const indices = arena.allocSlice(i32, @intCast(header.new_facts_count)) orelse return null;
        const indices_bytes = std.mem.sliceAsBytes(indices);
        file.seekTo(@intCast(header.new_facts_offset)) catch return null;
        _ = file.readAll(indices_bytes) catch return null;

        kb.new_facts_since_training_offset = arenaOffset(arena, @ptrCast(indices.ptr));
        kb.new_facts_since_training_count = header.new_facts_count;
    }

    return kb;
}
```

### 5.4 Lazy Weight Loading

Weight data is the largest component and loads separately from the KB. When the inference engine calls `resolveWeights` and finds empty `v`/`r0`/`r1` slices in a WeightMatrix, it triggers weight loading:

```
fn ensureWeightsLoaded(matrix: *WeightMatrix, kb_id: VdrId, ref_index: i32, store: *KbStore) bool {
    // Already loaded?
    if (matrix.v.len > 0) return true;

    // Load from disk
    return loadWeightMatrix(matrix, kb_id, ref_index, store);
}

fn loadWeightMatrix(matrix: *WeightMatrix, kb_id: VdrId, ref_index: i32, store: *KbStore) bool {
    var path_buf: [256]u8 = undefined;
    const path = formatWeightPath(kb_id, 'm', ref_index, store.data_dir, &path_buf);

    const file = std.fs.cwd().openFile(path, .{}) catch return false;
    defer file.close();

    // Read header
    var header: WeightFileHeader = undefined;
    const header_bytes = @as([*]u8, @ptrCast(&header))[0..@sizeOf(WeightFileHeader)];
    _ = file.readAll(header_bytes) catch return false;

    // Validate
    if (!std.mem.eql(u8, &header.magic, &WEIGHT_FILE_MAGIC)) return false;
    if (header.version != WEIGHT_FILE_VERSION) return false;

    // Verify checksum
    const crc = computeFileCrc(file, @sizeOf(WeightFileHeader), header.total_size);
    if (crc != header.checksum) return false;

    const N: usize = @intCast(header.element_count);
    const arena = store.global_arena;

    // Allocate arrays in global arena, cache-line aligned
    const v = arena.allocSlice(i32, N) orelse return false;
    const r0 = arena.allocSlice(i16, N) orelse return false;
    const r1 = arena.allocSlice(i16, N) orelse return false;

    // Read directly into arena memory
    file.seekTo(@intCast(header.v_offset)) catch return false;
    _ = file.readAll(std.mem.sliceAsBytes(v)) catch return false;

    file.seekTo(@intCast(header.r0_offset)) catch return false;
    _ = file.readAll(std.mem.sliceAsBytes(r0)) catch return false;

    file.seekTo(@intCast(header.r1_offset)) catch return false;
    _ = file.readAll(std.mem.sliceAsBytes(r1)) catch return false;

    // Patch the WeightMatrix to point to the loaded data
    matrix.v = v;
    matrix.r0 = r0;
    matrix.r1 = r1;
    matrix.rows = header.rows;
    matrix.cols = header.cols;

    return true;
}
```

This means the first inference request that touches a domain KB pays the cost of loading its weights from disk. Subsequent requests on any session read from the global arena. The cost is paid once per KB, not per session.

### 5.5 Loading Flow Summary

```
Startup:
    1. Allocate arenas (global + per-core).
    2. Load manifest.dat into global arena.
    3. Build path_hash → manifest_entry index.
    4. Done. No KB data loaded. Startup is fast.

First access to a KB (e.g., tree traversal):
    1. resolveKb(id) → not in loaded_lut.
    2. manifest.lookup(id) → found entry.
    3. loadKbFromDisk() → read .kb file, allocate in arena, patch offsets.
    4. Weight slice pointers are empty (not loaded yet).
    5. KB is now in loaded_lut. Subsequent resolveKb is O(1).

First inference needing weights from that KB:
    1. resolveWeights(kb) → calls ensureWeightsLoaded().
    2. matrix.v.len == 0 → trigger loadWeightMatrix().
    3. Read .wt file, allocate SoA arrays in arena, patch pointers.
    4. Weights are now in global arena. All sessions share them.
    5. Subsequent weight reads are arena pointer dereference.

Never accessed:
    1. Manifest entry exists. File on disk.
    2. Zero arena memory used. Zero disk I/O.
```

---

## 6. Offset Patching

### 6.1 The Problem

When a KB is saved, its offset fields (facts_offset, rules_offset, text offsets, etc.) point into the arena of the process that saved them. When loaded into a new process, the arena base address is different. The offsets are wrong.

### 6.2 The Solution

On load, every offset in the KB struct is patched to point into the new arena location where the data was just read:

```
fn arenaOffset(arena: *Arena, ptr: [*]const u8) i32 {
    const base = @intFromPtr(arena.base);
    const target = @intFromPtr(ptr);
    return @intCast(target - base);
}
```

After reading the facts array into the arena at some location, the KB's `facts_offset` is patched to the new arena offset of that location. Same for rules, terms, children, text, weight refs.

This is a one-time cost at load. After patching, all offsets are valid for the current arena layout. The hot path (fact reads, GEMM, Prolog queries) never checks or patches offsets — they are correct after load.

### 6.3 Self-Referencing Offsets Within Arrays

Facts, rules, and terms can contain offsets that reference other items in the same file. For example, a rule's `body_offset` references terms in the term array. A compound term's `secondary_offset` references other terms.

These internal offsets are stored as array indices (not arena offsets) in the file. At load time, the base address of the term array is known, so converting an index to an arena offset is:

```
arena_offset = term_array_base_offset + (index * @sizeOf(Term))
```

This conversion is done once during load for each rule and compound term. After that, offsets are arena-relative and ready for use.

---

## 7. Version Mismatch and Conversion

### 7.1 Detection

Every file header stores the struct sizes at save time:

```
header.kb_struct_size = @sizeOf(KB)     // 256 at current version
header.fact_struct_size = @sizeOf(Fact)  // 48 at current version
header.rule_struct_size = @sizeOf(Rule)  // 48 at current version
header.term_struct_size = @sizeOf(Term)  // 24 at current version
```

On load, if any struct size doesn't match the current binary's struct size, the file is incompatible:

```
if (header.kb_struct_size != @sizeOf(KB)) {
    std.debug.print(
        "KB file version mismatch: file has KB size {d}, current binary has {d}. " ++
        "Run vdr-convert to migrate.\n",
        .{ header.kb_struct_size, @sizeOf(KB) },
    );
    return null;
}
```

No attempt to parse. No field-by-field migration. No backward-compatibility branches in the hot path. Print the error, tell the user to convert, return null.

### 7.2 Offline Converter

A separate binary (`vdr-convert`) handles version migration:

```
vdr-convert --from-version 1 --to-version 2 --data-dir ./data
```

The converter:

1. Reads the old-version manifest.
2. For each KB file, reads using the old struct layout (compiled with old struct definitions).
3. Constructs the new struct from old fields, with defaults for new fields.
4. Writes the new-version file.
5. Writes a new manifest.

The converter is compiled with both old and new struct definitions (e.g., `KbV1` and `KbV2`) and has explicit field mapping between them. This is simple, verifiable, and runs offline — it doesn't affect the running system.

### 7.3 Why Not In-Process Migration

In-process migration means every file read has to check the version and potentially run migration code. This adds branches to the hot path, increases code complexity, and introduces a class of bugs where partially-migrated data is used by accident. The offline converter is simpler, safer, and keeps the runtime clean.

---

## 8. Checksum Verification

### 8.1 CRC32

Every file has a CRC32 checksum in its header covering all bytes after the header:

```
fn computeFileCrc(file: std.fs.File, start: usize, end: i64) u32 {
    var crc: u32 = 0xFFFFFFFF;
    var buf: [4096]u8 = undefined;

    file.seekTo(start) catch return 0;
    var remaining: i64 = end - @as(i64, @intCast(start));

    while (remaining > 0) {
        const to_read = @min(@as(usize, @intCast(remaining)), buf.len);
        const n = file.readAll(buf[0..to_read]) catch return 0;
        if (n == 0) break;

        for (buf[0..n]) |byte| {
            crc = crc32_table[(crc ^ byte) & 0xFF] ^ (crc >> 8);
        }
        remaining -= @intCast(n);
    }

    return crc ^ 0xFFFFFFFF;
}
```

### 8.2 When Checksums Are Verified

- **On every load.** Both KB files and weight files have their checksum verified before the data is used. A checksum mismatch means the file is corrupt — return null, log the error. The system continues without that KB. It can be restored from a backup or re-created.

- **Not on save.** The save path computes the checksum and writes it. No verification after write — the filesystem is trusted for immediate consistency. Verification happens on the next load.

### 8.3 Corrupt File Recovery

If a file fails checksum verification:

```
1. Log the corruption: KB ID, file path, expected vs. actual CRC.
2. Return null from the load function.
3. The manifest entry stays (the file exists) but loaded = false.
4. Subsequent access attempts will retry the load and fail again.
5. Admin intervention: restore from backup, re-save from a running
   system that has the KB in memory, or delete the corrupt file
   and rebuild the KB from its sources.
```

No automatic repair. Corrupt data is not guessed at. The system operates without the corrupt KB until it is fixed.

---

## 9. Arena Memory Pressure

### 9.1 The Problem

Lazy loading means arena usage grows over time as more KBs are accessed. The global arena has a fixed size. If every KB is eventually accessed, the arena fills up.

### 9.2 Arena Exhaustion Response

When `arena.alloc` returns null during a KB load:

```
1. The load fails. resolveKb returns null.
2. The caller (inference engine, Prolog query, KB store operation)
   gets a null KB and returns Status.err(.memory, .arena_exhausted, arena_id).
3. The error propagates to the HTTP handler, which returns 503.
```

### 9.3 Weight Eviction

Weight data is the largest consumer. A single 2048×2048 matrix is 32 MB. The global arena can hold roughly 80 such matrices in its weight budget (~2.65 GB total, with ~2 GB for weights).

When arena pressure is high and a new weight load is needed, the system can evict weight data from KBs that haven't been used recently:

```
fn evictColdWeights(store: *KbStore, needed_bytes: usize) bool {
    // Find loaded KBs with weights, sorted by last access time
    // (tracked via a lightweight LRU counter per loaded KB)

    var freed: usize = 0;
    for (store.loaded_kbs_by_lru()) |kb| {
        if (freed >= needed_bytes) break;

        const wrefs = getWeightRefs(kb, store.global_arena);
        if (wrefs == null) continue;

        // Null out weight slice pointers — next access will reload from disk
        for (wrefs.matrix_refs[0..@intCast(wrefs.matrix_count)]) |*matrix| {
            freed += @intCast(matrix.bytesTotal());
            matrix.v = &.{};
            matrix.r0 = &.{};
            matrix.r1 = &.{};
        }
        for (wrefs.vector_refs[0..@intCast(wrefs.vector_count)]) |*vector| {
            freed += @intCast(vector.bytes());
            vector.v = &.{};
            vector.r0 = &.{};
            vector.r1 = &.{};
        }

        // Invalidate GEMM cache too
        wrefs.gemm_cache = null;
    }

    // Note: the arena memory is not actually freed (bump allocator).
    // But the system tracks logical usage and the evicted KB's weight
    // region can be overwritten by the next allocation if the arena
    // implements a free list for large blocks, or the arena is
    // compacted during a maintenance window.

    return freed >= needed_bytes;
}
```

Weight eviction does not recover arena bytes in a pure bump allocator — the memory is still consumed. However, eviction prevents the system from trying to load more weight data than the arena can hold by tracking logical usage. Arena compaction (resetting and reloading only what's needed) is a maintenance operation that runs during low-traffic periods.

For the laptop target with ~2 GB of weight budget and a 1B parameter model using ~2 GB total, the full model fits. Weight eviction is primarily relevant for systems with more domain KBs than arena capacity, where the working set rotates.

---

## 10. Startup Sequence

```
1. Allocate global arena and per-core arenas from page_allocator.
2. Load config.json into SystemConfig.
3. Load manifest.dat into global arena.
   - If no manifest exists → fresh start. Create empty manifest.
4. Build path_hash index from manifest entries.
5. Load seed KBs (root.system.*, root.templates.*).
   - These are always needed. Loaded eagerly, not lazily.
   - Seed KBs are frozen — they never change after init.
   - Seed weight files (embedding, output) loaded eagerly too.
6. Register seed KBs in the loaded_lut and path index.
7. All other KBs remain unloaded. Manifest entries exist.
   Files on disk. Zero arena usage until first access.
8. Spawn pinned compute threads.
9. Start HTTP listener.
10. System is ready. First client request triggers lazy loading
    of whatever KBs the request needs.
```

### 10.1 Fresh Start

If no `data/manifest.dat` exists:

```
1. Create data/ directory structure.
2. Create seed KBs in arena from compiled-in seed data.
3. Save all seed KBs to disk.
4. Write initial manifest with seed entries.
5. Continue startup as normal.
```

### 10.2 Seed KB Eager Loading

Seed KBs (`root.system.oso`, `root.system.confidence`, `root.system.builtins`, `root.system.command_vocab`, `root.system.hygiene`, `root.system.embedding`, `root.system.output`, `root.templates.*`) are loaded eagerly because every session needs them. The embedding and output weights are large but universally required — loading them lazily would just shift the cost to the first inference request.

After eager seed loading, the global arena has:
- ~2 GB of embedding + output weights
- ~2 MB of seed KB data
- ~10 MB of manifest

The remaining ~600 MB of global arena is available for domain KBs loaded on demand.
