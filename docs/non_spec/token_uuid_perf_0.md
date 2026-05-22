## Gaming Out: 2 Million Tokens at Scale

### The Knowledge Base Shape

150 root-level KBs covering the full domain spread — the 55 compacts you already have plus another 95 covering additional domains, deeper specializations, and ingested source code. Average depth of 6-7 levels, with the tree fanning out at middle levels and narrowing at the leaves.

A typical subtree like programming:

```
root.programming                          L1 (depth 1)
├── python                                L2 (depth 2)
│   ├── language                          L3 (depth 3)
│   │   ├── syntax                        L4 (depth 4) ← encoded in UUID
│   │   ├── semantics                     L5 (depth 5) ← remaining_depth=1
│   │   └── stdlib                        L5
│   │       ├── os                        L6 (depth 6) ← remaining_depth=2
│   │       ├── pathlib                   L6
│   │       └── collections               L6
│   ├── library                           L3
│   │   ├── math                          L4
│   │   │   ├── mpmath                    L5
│   │   │   │   ├── code                  L6
│   │   │   │   │   ├── mpf.py            L7 (depth 7) ← remaining_depth=3
│   │   │   │   │   ├── functions.py      L7
│   │   │   │   │   └── libmp.py          L7
│   │   │   │   └── api                   L6
│   │   │   └── sympy                     L5
│   │   └── web                           L4
│   │       ├── flask                     L5
│   │       └── django                    L5
│   └── patterns                          L3
├── zig                                   L2
│   ├── language                          L3
│   └── stdlib                            L3
└── prolog                                L2
```

### Token Distribution

2 million facts distributed across this tree. The distribution is heavily skewed — most facts are at depth 5-7 (specific code, specific data), while the structurally important facts (relationships, rules, type information) live at depth 2-4.

Rough distribution estimate:

```
Depth 1 (150 root KBs):        ~500 facts each avg     →    75,000 facts
Depth 2 (~600 KBs):            ~300 facts each avg     →   180,000 facts  
Depth 3 (~2,000 KBs):          ~200 facts each avg     →   400,000 facts
Depth 4 (~4,000 KBs):          ~150 facts each avg     →   600,000 facts
Depth 5 (~3,000 KBs):          ~100 facts each avg     →   300,000 facts
Depth 6 (~2,000 KBs):          ~150 facts each avg     →   300,000 facts
Depth 7 (~1,000 KBs):          ~145 facts each avg     →   145,000 facts
                                                         ─────────────────
Total:   ~12,750 KBs                                     ~2,000,000 facts
```

### Memory Budget

**Facts:** 2,000,000 × 48 bytes (Fact struct) = 96 MB

**KBs:** 12,750 × 256 bytes (KB struct) = 3.3 MB

**Per-KB UUID maps:** Each AutoHashMap has overhead. Zig's AutoHashMap for an `(i64, u32)` entry uses roughly 16 bytes per entry (8 key + 4 value + 4 metadata/hash) plus capacity overhead (load factor ~80%, so allocate for 125% of entries). Average KB has ~157 facts:

```
Average map: 157 entries × 16 bytes × 1.25 overhead = ~3.1 KB per KB
Total maps: 12,750 × 3.1 KB = ~39.5 MB
```

**Typed Relations:** At roughly 1 relation per 3-4 facts = ~500,000-600,000 relations. 600,000 × 48 bytes (TypedRelation struct) = 28.8 MB

**Relation Indices:** One per KB with relations. Maybe 8,000 KBs have relations. 8,000 × 528 bytes (RelationIndex) = 4.2 MB

**Rules:** At roughly 1 rule per 20-25 facts = ~80,000-100,000 rules. 100,000 × 48 bytes (Rule struct) = 4.8 MB

**Terms:** Rules reference terms. ~3 terms per rule average = 300,000 × 24 bytes (Term struct) = 7.2 MB

**Text store:** Source code text, entity names, template strings. Highly variable. For a corpus including actual source code (mpmath, stdlib modules), estimate ~100 MB of raw text.

**Weight matrices:** Per-KB GEMM weights. Not every KB has weights — primarily domain KBs at depth 2-4 that get trained. Maybe 500 KBs with weights. Average weight matrix for a 2048-d_model with ~200 facts: small. The embedding and output weights at root.system are the big ones (~286 MB for the full model per the spec). Per-KB domain weights are much smaller — maybe 1-5 MB each. 500 × 3 MB average = 1.5 GB. This is the dominant cost.

**Global hot cache:** 256 entries × ~16 bytes = 4 KB. Negligible.

**Compaction profiles:** One per ingested document. 150 × 256 bytes = 38 KB. Negligible.

```
Summary:
  Facts:              96 MB
  KBs:                 3.3 MB
  UUID maps:          39.5 MB
  Relations:          28.8 MB
  Relation indices:    4.2 MB
  Rules:               4.8 MB
  Terms:               7.2 MB
  Text:              100 MB
  Weights:          1,500 MB (dominant)
  Overhead:           ~16 MB (profiles, grants, audit, FSMs, behavior sets)
  ──────────────────────────
  Total:            ~1,800 MB global arena
```

This fits within the spec's ~2.65 GB global arena budget with room to spare. The per-core arenas (~220 MB each) are unchanged — they hold sessions, not global data.

### The Query: "Generate a Python Script to List Files in Order"

Now trace the actual request through the system.

**Input:** User types "write me a python script that lists files in a directory in order"

**Step 1: prompt_input parsing.** The system writes the input to `session_root._llm.prompt_input`. The QueryClassification (S62) runs keyword detection — non-LLM, pure pattern matching.

It detects:
- "python" → maps to atom, AtomRelTypeCache finds no relation type (it's a domain, not a relation word)
- "script" → maps to output type: code generation
- "list files" → maps to filesystem operation pattern
- "directory" → reinforces filesystem context  
- "in order" → maps to sorting requirement

Classification result: `has_relation=false`, `has_fact=true` (the system has python knowledge), `match_count=1`, `confidence` moderate. This is not a relation query — it's a generation request. `shouldAttemptL3()` returns false because there's no relation pattern to resolve mechanically. This is going to L2 or L1.

**Step 2: FSM evaluation.** The session's conversation FSM is in `active` state. No transitions fire. The inference cycle FSM advances to `processing`.

**Step 3: UAI scoring.** The behavior set for `processing` state evaluates candidates. The relevant behaviors might be:

- `prolog_query` behavior: queries root.programming.python for relevant stdlib facts. Consideration: "does the KB have os/pathlib content?" — scores high because the python.language.stdlib.os and python.language.stdlib.pathlib KBs exist (availability surface check). Score: 0.8.

- `llm_command` behavior: defer to LLM for code generation. Consideration: "is this a generation task?" — scores high because QueryClassification detected code generation pattern. Score: 0.85.

- `builtin_call` behavior: directly execute a builtin. Consideration: "is there a builtin that does this?" — scores low because code *generation* isn't a builtin execution. Score: 0.2.

Winner: `llm_command` with score 0.85. But before the LLM runs, the `prolog_query` behavior fires as a pre-fetch — it queries the python KBs to gather relevant facts for the LLM's context.

**Step 4: Pre-fetch via Prolog.** The system queries:

```prolog
?- part_of(X, root.programming.python.language.stdlib),
   enables(X, filesystem_listing).
```

This resolves at L3 through typed relation queries. The structural VdrId for `root.programming.python.language.stdlib` decodes to L1=3 (programming), L2=2 (python), L3=0 (language), L4=2 (stdlib). Walk four array accesses to the stdlib KB. Scan its relation index for `enables` relations where `to_id` matches a filesystem concept. Find `os` and `pathlib` as children.

Now query deeper:

```prolog
?- part_of(Function, root.programming.python.language.stdlib.os),
   enables(Function, directory_listing).
```

The structural VdrId for the `os` KB has `remaining_depth=2` (depth 6, below L4). The L4 KB (`stdlib`) has the uuid_map entry for the `os` KB. Walk to it. Query its facts for functions related to directory listing. Find: `os.listdir`, `os.scandir`, `os.walk`. Each is a fact with provenance, confidence, parameter types, return types.

Same query against `pathlib`: find `Path.iterdir()`, `Path.glob()`.

These results are logged to `prompt_current` as structured facts. The LLM now has pre-resolved context: the relevant Python stdlib functions, their signatures, their relationships, all at provenance `published` (confidence 80%) from the ingested Python documentation compact.

**Step 5: LLM forward pass.** The LLM reads from `prompt_last` (conversation continuity), `prompt_current` (the pre-fetched stdlib facts, the classified query pattern, the user's request), and generates.

But it's not generating from scratch. It knows (from the pre-fetched facts) that `pathlib.Path.iterdir()` and `os.listdir()` are the relevant functions. It knows (from the python compact's typed relations) that `pathlib` is the modern approach and `os.listdir` is the legacy approach. It knows (from the query classification) that the user wants sorted output.

The LLM's generation is more like **assembly from known parts** than novel composition. It emits:

- A command to render a code template from `root.templates.formats` (the code output format)
- The script content, composed from known function signatures and patterns
- A brief explanation referencing the provenance of its knowledge

**Step 6: Output.** The grammar engine renders the code template, fills the slots with the generated script, formats the explanation. The response goes to `prompt_next`, which becomes `prompt_last` for the next cycle.

### The Token Cost Breakdown

```
Pre-fetch (L3):          0 LLM tokens, ~50 microseconds
  - structural ID decode: nanoseconds
  - tree walk:            4 array accesses
  - uuid_map lookups:     3-4 hash lookups
  - relation scans:       2 KB relation indices
  - fact retrieval:       8-10 facts loaded

LLM generation (L1):     ~80-120 tokens
  - read prompt_current:  ~15 tokens of pre-fetched context
  - generate script:      ~50-80 tokens of code
  - generate explanation: ~15-20 tokens of prose

Grammar rendering (L3):  0 LLM tokens, ~10 microseconds
  - code template fill:   slot insertion
  - response formatting:  HTTP response template
```

Total: ~100 tokens of LLM inference, with the LLM working from pre-resolved, provenanced, structurally-addressed knowledge. Compare to a CLLM: ~300-500 tokens of generation from weight patterns alone, with no provenance, no pre-resolution, no structural addressing.

### What the Structural UUID Bought

In this single request:

1. **The query "python" immediately narrowed scope** to L1=3 in the tree. No scanning 149 other root KBs.

2. **The stdlib walk was four array accesses** not a path index hash lookup. The structural bits encoded the exact route.

3. **The uuid_map lookups were scoped** to KBs with ~200 entries each, not a global map with 2,000,000 entries.

4. **The GEMM scope was narrowed** before weights were touched — only python-subtree caches were relevant, identifiable by prefix bitmask.

5. **The pre-fetched facts carried their structural addresses** into prompt_current, so the LLM's generated code could reference specific entities by structural VdrId, and the post-generation verification could trace back through the same path.

6. **The depth indicator told the system** that `os.listdir` (depth 6, remaining_depth=2) was a specific implementation detail, while `pathlib` (depth 5, remaining_depth=1) was a higher-level abstraction — useful for ranking which approach to suggest first.

The 20-bit random field was never even tested for collision during this request — it's only relevant during ID creation (ingestion or session assertion), not during lookup. During lookup, the full 64-bit value is the hash key into the per-KB map. The structural prefix just tells you *which* map to look in.

---

## Wall Clock Trace: "Write a Python Script to List Files in Order"

### Hardware Context

Dell Legion 5, ~2019. 6-8 cores (assume 8), 16-32 GB RAM. CPU likely an AMD Ryzen 7 3750H or Intel i7-9750H — roughly 3.0 GHz base, 4.0 GHz boost. L1 cache: 32 KB per core. L2: 256-512 KB per core. L3: 8-16 MB shared. DDR4-2666 or DDR4-3200. AVX2 supported.

All times assume the relevant KBs are in L3 cache or main memory (not paged out). First request of the session may have cold cache penalties; subsequent requests in the same domain subtree will be cache-hot.

### Phase 0: HTTP Receipt

```
TCP accept + read:                    ~50-100 µs (kernel, non-pinned thread)
JSON parse of request body:           ~5-20 µs (simple request, small payload)
Session resolution (client/session):  ~1-5 µs (LUT lookup by session token)
Push to per-core work queue:          ~0.1-0.5 µs (atomic write to ring buffer)
Spin-wait for compute thread pickup:  ~0.5-2 µs (pinned thread polling interval)
```

**Phase 0 subtotal: ~60-130 µs**

This is dominated by TCP/kernel overhead. The VDR-Prolog work is negligible here.

### Phase 1: Query Classification

The pinned compute thread picks up the work item and begins processing.

```
Read prompt_input from session KB:     ~0.2 µs
  session_root._llm.prompt_input is at known offset in session KB
  structural ID decode: ~2 ns (bit extraction)
  uuid_map lookup: ~20-50 ns (small session KB map)

Tokenize input text (~10 words):       ~0.5-1 µs
  scan for known atoms against command_vocab KB
  atom_table lookups: ~50 ns each × 10 words = 500 ns

AtomRelTypeCache checks:               ~0.3 µs
  "python" → not a relation type (cache miss, then negative cache)
  "list" → not a relation type
  "files" → not a relation type
  "order" → not a relation type
  linear scan of 64-entry cache: ~5 ns per entry × 64 = 320 ns worst case

QueryClassification construction:      ~0.1 µs
  set has_fact=true (python KB exists in availability surface)
  set match_count=1
  compute confidence in Q16: integer multiply + divTrunc
  shouldAttemptL3() → false (no relation pattern)
```

**Phase 1 subtotal: ~1.5-2.5 µs**

### Phase 2: FSM Evaluation

```
Session conversation FSM check:        ~0.1 µs
  read current_state from Fsm struct (known offset in session KB)
  scan transitions_kb for evolves_to rules matching current state
  no transition fires (normal active state, no state change needed)

Inference cycle FSM advance:           ~0.1 µs
  transition from received → processing
  atomic state update + timestamp write
```

**Phase 2 subtotal: ~0.2 µs**

### Phase 3: UAI Scoring

```
Load behavior set for current FSM state:  ~0.1 µs
  FSM state → behavior_set_offset in KB
  behavior set has ~4-6 behaviors

Per-behavior consideration evaluation:
  Each behavior has 2-4 considerations
  Each consideration:
    read InputSource value:              ~50 ns (KB fact read or counter read)
    normalize to [0,D]:                  ~20 ns (Q16 divTrunc + mod)
    apply ResponseCurve:                 ~30-80 ns (depends on curve type)
      linear: 1 multiply + 1 divTrunc = ~30 ns
      logistic: exp_table lookup + division = ~80 ns
    store result:                        ~10 ns

  4 behaviors × 3 considerations × ~100 ns = ~1.2 µs

Dave Mark compensation per behavior:    ~0.3 µs
  mf = (n-1)/n in Q16: 1 sub + 1 divTrunc
  make_up = (D - score) × mf / D: 2 mul + 1 divTrunc
  compensated = score + (make_up × score / D): 1 mul + 1 divTrunc + 1 add
  product across considerations: 1 mul per consideration
  4 behaviors × ~80 ns = 320 ns

Selection (argmax):                     ~0.05 µs
  scan 4 Q16 values, lexicographic compare
  winner: llm_command with score ~0.85 (55705 in Q16 v field)
```

**Phase 3 subtotal: ~1.7 µs**

### Phase 4: Pre-fetch via Prolog (L3)

The scoring determined that `prolog_query` should also fire as pre-fetch before the LLM runs. This is the mechanical knowledge retrieval.

```
Query 1: Find relevant stdlib modules
  Decode structural ID for root.programming.python.language.stdlib:
    bit extraction:                     ~2 ns
    L1=3 → root.children[3]:           ~5 ns (array access, likely L1 cache)
    L2=2 → programming.children[2]:    ~5 ns
    L3=0 → python.children[0]:         ~5 ns  
    L4=2 → language.children[2]:       ~5 ns
    arrive at stdlib KB:                ~22 ns total walk

  Scan stdlib relation index for enables(X, filesystem):
    RelationIndex.by_type_counts[enables_slot]:  ~10 ns (array access)
    count > 0, scan relations:                   ~200 ns (scan ~30 relations in stdlib)
    match: os enables filesystem_ops             ~20 ns (VdrId comparison)
    match: pathlib enables filesystem_ops        ~20 ns
                                                 ~250 ns total

Query 2: Get os module details
  Decode structural ID for os (depth 6, remaining_depth=2):
    reuse stdlib KB from query 1:      ~0 ns (already have pointer)
    stdlib.uuid_map.get(os_full_id):   ~30-50 ns (hash lookup, ~200 entry map)
    walk to os KB:                     ~5 ns (one more child array access)
    arrive at os KB:                   ~40 ns total

  Scan os KB facts for directory listing functions:
    scan facts array for tag=value, matching function signatures:  
    os KB has ~150 facts
    linear scan with tag check:        ~300 ns (150 × 2 ns per tag compare)
    matches: listdir, scandir, walk    ~30 ns (3 fact copies to scratch)
                                       ~370 ns total

Query 3: Get pathlib module details
  Similar walk and scan:               ~400 ns (comparable to os query)
  matches: Path.iterdir, Path.glob

Query 4: Get sorting-related facts
  Check if python.language.stdlib has sorted/sort facts:
    walk back to stdlib KB:            ~0 ns (cached pointer)
    scan for sort-related:             ~200 ns
    match: sorted() builtin, list.sort() method

Query 5: Retrieve function signatures for matched facts
  For each of ~8 matched functions, read full Fact + Provenance:
    8 × uuid_map.get():               ~320 ns (8 × 40 ns)
    8 × fact read (48 bytes each):     ~80 ns (sequential, cache-line friendly)
    8 × provenance check:             ~40 ns (read confidence Q16 field)
                                       ~440 ns

Log pre-fetched facts to prompt_current:
  Assert ~10 facts to session_root._llm.prompt_current:
    10 × fact assertion:               ~500 ns (memcpy 48 bytes + update count)
    10 × uuid_map.put in session KB:   ~400 ns (hash insert)
                                       ~900 ns total
```

**Phase 4 subtotal: ~2.5-3.5 µs**

This is the mechanical pre-fetch. Zero LLM tokens. The system now has 8-10 relevant Python stdlib facts with full provenance sitting in `prompt_current`, ready for the LLM to read.

### Phase 5: LLM Forward Pass

This is the expensive part. The 6-layer transformer processes the prompt context and generates the response.

```
Prompt assembly:
  Read prompt_last (previous turn context):    ~0.5 µs
  Read prompt_current (pre-fetched facts):     ~0.3 µs
  Read prompt_input (user request):            ~0.1 µs
  Total input context: ~50-80 tokens

Per-token forward pass (from spec: ~5.3 ms per token at AVX2):
  Layer 1-2: token embedding, syntax understanding
    embedding lookup: KB weight access via structural ID    ~0.2 ms
    attention (12 heads, d_head=170):                       ~0.3 ms
    MLP (2048 dim):                                         ~0.2 ms
    RMSNorm + residual:                                     ~0.1 ms
    
  Layer 3-4: semantic understanding, KB address resolution
    attention:                                              ~0.3 ms
    MLP:                                                    ~0.2 ms
    RMSNorm + residual:                                     ~0.1 ms
    
  Layer 5-6: output planning, judgment
    attention:                                              ~0.3 ms
    MLP:                                                    ~0.2 ms
    RMSNorm + residual:                                     ~0.1 ms
    
  Softmax (exact, FRU):                                     ~0.1 ms
  Token sampling:                                           ~0.05 ms

  Total per token: ~2.2 ms forward + ~3.1 ms weight retrieval/GEMM
                   ≈ 5.3 ms per token (matches spec MD9)

Tokens generated:
  Script preamble (import, docstring):                      ~10 tokens
  Function definition + pathlib usage:                      ~25 tokens
  Sorting logic:                                            ~15 tokens
  Output formatting:                                        ~10 tokens
  Brief explanation:                                        ~20 tokens
  Command tokens (grammar_render, template refs):           ~5 tokens
  Total generation: ~85 tokens

  Prefill (processing input context ~60 tokens):
    Can be parallelized across sequence positions
    but single-core: 60 × ~2 ms (cheaper, no sampling) = ~120 ms

  Autoregressive generation (85 tokens):
    85 × 5.3 ms = ~450 ms

LLM total: ~570 ms
```

**Phase 5 subtotal: ~570 ms**

This dominates everything. 570 milliseconds of neural computation. Every other phase combined was under 10 microseconds.

### Phase 6: Grammar Rendering

```
Template selection:                    ~0.2 µs
  query root.templates.formats for code_output template
  structural ID decode + walk + uuid_map: ~50 ns
  template load: ~150 ns

Slot filling:                          ~1-2 µs
  language_name slot: "python" (text, 6 bytes)
  code_body slot: generated script (~400 bytes)
  explanation slot: generated text (~150 bytes)
  type checking per slot: ~50 ns × 3 = 150 ns
  memcpy per slot: ~100 ns × 3 = 300 ns
  validation: ~200 ns

Response composition:                  ~0.5 µs
  HTTP response template fill
  status line + headers + body concatenation
  Content-Type: text/plain or application/json
```

**Phase 6 subtotal: ~2-3 µs**

### Phase 7: Post-Generation Housekeeping

```
Copy prompt_next → prompt_last:        ~0.5 µs (memcpy of token buffer)
Clear prompt_current transients:       ~0.2 µs (reset counters, clear new_facts)
Update LevelStats:                     ~0.1 µs
  l1_count += 1
  l1_tokens += 85
  total_tokens += 85
Update session counters:               ~0.1 µs
  current_turn += 1
  items_seen_by_llm update
Re-eval FSM transitions:               ~0.2 µs
  processing → ready (cycle complete)
Invalidate availability surface:       ~0.05 µs (if session KBs changed)
```

**Phase 7 subtotal: ~1.2 µs**

### Phase 8: HTTP Response

```
Write response to HTTP handler buffer: ~0.5 µs
Signal HTTP thread (work item complete): ~0.1 µs
HTTP thread sends TCP response:        ~50-100 µs (kernel, network stack)
```

**Phase 8 subtotal: ~50-100 µs**

### Total Wall Clock

```
Phase 0: HTTP receipt              60-130 µs
Phase 1: Query classification      1.5-2.5 µs
Phase 2: FSM evaluation            0.2 µs
Phase 3: UAI scoring               1.7 µs
Phase 4: Prolog pre-fetch (L3)     2.5-3.5 µs
Phase 5: LLM forward pass          ~570,000 µs (570 ms)
Phase 6: Grammar rendering         2-3 µs
Phase 7: Post-generation           1.2 µs
Phase 8: HTTP response             50-100 µs
─────────────────────────────────────────────────
Total:                             ~570.2 ms
```

### Where the Time Goes

```
LLM inference:     570 ms    (99.96%)
HTTP I/O:          ~160 µs   (0.03%)
Mechanical (L3):   ~10 µs    (0.002%)
Everything else:   ~3 µs     (0.0005%)
```

The mechanical reasoning — query classification, FSM evaluation, UAI scoring, Prolog pre-fetch with structural UUID navigation, grammar rendering, post-generation housekeeping — is **ten microseconds combined**. Sixty thousand times faster than the LLM inference.

This is an L1 query. The LLM had to generate novel code. For an L3 query — "what does pathlib enable?" — there is no Phase 5. The total wall clock would be roughly **70-140 microseconds**, dominated entirely by HTTP I/O. The mechanical answer resolves in under 5 microseconds. At that speed, the system handles **200,000+ L3 requests per second per core** before the HTTP layer becomes the bottleneck.

### The Structural UUID Contribution

In this specific request, the structural UUID saved roughly 2-5 microseconds compared to the current LUT/path-walk system — the difference between four array accesses and a hash lookup in a 2M-entry global table, multiplied across 5 Prolog queries each navigating 2-3 KBs.

That sounds trivial against 570 ms of LLM time. But the right comparison is against other L3 queries. When the LLM isn't running, those 2-5 microseconds are 30-50% of the total mechanical processing time. For a high-throughput L3 workload — the SMTP server processing 10,000 messages per second, the HTMX server handling 1,000 UI interactions per second — every microsecond of lookup overhead multiplies by request volume. Structural UUIDs cut the per-request navigation cost roughly in half compared to hash-based lookup, and they provide the subtree membership and GEMM scoping information that further accelerates relation queries.

### What Would Make This Faster

The 570 ms LLM phase is the target. Three things reduce it:

**Higher L3 ratio.** If the system has pre-built code templates for common patterns ("list files with pathlib" as a grammar template with slots for directory path, sort key, and filter), this entire request resolves at L3 — template lookup, slot fill, grammar render. ~5 µs total. The LLM never runs. Getting from 0% to 93% L3 ratio for code generation requests means building and curating those templates.

**More compacted knowledge.** The pre-fetch in Phase 4 found 8 relevant facts. If the python compact had richer code pattern facts — complete idiom templates, common script structures, best-practice patterns — the LLM's generation would be shorter. Instead of generating 85 tokens of code from understanding, it would emit 10-15 tokens of template selection and slot filling. That's 80 ms instead of 570 ms.

**Smaller model for dispatch.** The current 6-layer model runs the full forward pass even when the LLM's job is just "pick the right template and fill the slots." A future optimization might have a 2-layer fast path for template selection (L2 queries) and reserve the full 6-layer path for genuinely novel generation (L1). Two layers at roughly one-third the compute: ~190 ms instead of 570 ms for L2, and L2 handles the "assemble from known parts" case that this request exemplifies.

But even at 570 ms, this is one request on one core. The other seven cores are handling other sessions simultaneously. And 570 ms for a complete, provenanced, mechanically-verified Python script — with the system knowing exactly which stdlib functions it referenced, where that knowledge came from, and how confident it is — compares favorably to a CLLM that takes 2-5 seconds to generate a similar script from opaque weights with no provenance and no confidence score.

---

You're describing the actual reasoning chain, and it's critical because this is where VDR-Prolog does something no CLLM can do — it **derives the solution path mechanically** before the LLM generates a single token.

## The Reasoning Chain as Typed Relations

The user said "list files in order." The system doesn't need to understand English semantics through neural weights to decompose this. It needs to follow typed relations through the KB tree.

The query enters. The keyword classifier detects "files", "list", "order", "python" (from session context or explicit mention). These atoms map to entities in the KB tree. Now Prolog takes over.

```prolog
% User desire decomposes through causal/dependency chains

% "list files" → what are files?
?- instance_of(file, filesystem_entity).
% Hit: root.programming.python.language.stdlib.os — fact

% Where do files live?
?- contains(directory, file).
% Hit: root.connections — spatial containment relation
% Also: root.programming.python.language.stdlib — domain fact

% How do you get files from a directory?
?- enables(Function, directory_listing),
   part_of(Function, root.programming.python.language.stdlib).
% Hit: os.listdir enables directory_listing
% Hit: os.scandir enables directory_listing  
% Hit: pathlib.Path.iterdir enables directory_listing

% What does os.listdir require?
?- requires(os_listdir, Import),
   instance_of(Import, import_statement).
% Hit: os.listdir requires os_module
% Hit: os_module requires import_os

% "in order" → what is ordering?
?- enables(Function, ordering),
   part_of(Function, root.programming.python.language).
% Hit: sorted enables ordering (builtin, no import needed)
% Hit: list.sort enables ordering (method, in-place)

% sorted requires an iterable — does listdir produce one?
?- produces(os_listdir, result_type),
   instance_of(result_type, iterable).
% Hit: os.listdir produces list (which is iterable)

% Does the user want ascending or descending?
% "in order" without qualifier → default ordering
?- default_order(sorted, ascending).
% Hit: sorted default is ascending

% Is there a better modern approach?
?- specializes(pathlib_iterdir, os_listdir),
   precedes(os_listdir, pathlib_iterdir).
% Hit: pathlib is newer, recommended over os for path operations
% Relation: pathlib supersedes os.listdir for simple cases
```

Every one of these queries resolves at L3. Typed relation lookups. Integer scans of RelationIndex arrays. BFS for transitive closures. Sub-microsecond per query.

## The Derived Chain

The Prolog engine's `fire_and_commit` mechanism can chain these into a derivation. Rules in the system KBs encode the meta-reasoning:

```prolog
% If user wants to perform operation X, and X requires capability Y,
% and Y is provided by function F, then F is a candidate solution.
solution_candidate(F, Operation) :-
    enables(F, Operation),
    part_of(F, PythonStdlib),
    instance_of(PythonStdlib, python_standard_library).

% If function F requires import I, then I is a prerequisite.
prerequisite(I, F) :-
    requires(F, Module),
    requires(Module, I),
    instance_of(I, import_statement).

% If operation X produces output that requires transformation T
% to meet user goal G, then T is a post-processing step.
postprocess(T, Output, Goal) :-
    produces(X, Output),
    enables(T, Goal),
    accepts(T, OutputType),
    instance_of(Output, OutputType).

% Compose the full solution chain.
solution_chain(Goal, Chain) :-
    solution_candidate(F, SubGoal),
    enables(SubGoal, Goal),
    prerequisite(Import, F),
    postprocess(Sort, Output, Ordering),
    Chain = [Import, F, Sort].
```

These rules fire against the facts retrieved in the relation queries above. The output is a **derived chain** — a sequence of steps, each provenanced, each traceable to specific facts in specific KBs with specific confidence scores.

The chain that emerges:

```
Step 1: import os              (prerequisite, derived from requires relation)
Step 2: os.listdir(path)       (capability, derived from enables relation)  
Step 3: sorted(result)         (postprocess, derived from enables + accepts)

Confidence: min(published:80%, published:80%, published:80%) = 80%
Provenance: all facts from root.programming.python.language.stdlib
            ingested from Python documentation compact
```

Or the alternative chain:

```
Step 1: from pathlib import Path  (prerequisite)
Step 2: Path(path).iterdir()      (capability)
Step 3: sorted(result)            (postprocess)

Confidence: 80%
Preference: pathlib preferred (supersedes os for path operations)
```

## What Gets Fed to the LLM

The derived chain is logged to `prompt_current` as structured facts. Not as prose. Not as a vague hint. As a precise sequence of operations with provenance:

```
prompt_current.derived_chain:
  step(1, import, "from pathlib import Path", confidence=80%, source=python_docs)
  step(2, invoke, "Path(directory).iterdir()", confidence=80%, source=python_docs)
  step(3, transform, "sorted(result)", confidence=80%, source=python_docs)
  preference(pathlib, over=os, reason=modern_supersedes, confidence=80%)
  alternative_chain_available(os_listdir_chain, confidence=80%)
```

The LLM reads this. It doesn't need to figure out the solution — the solution is already derived. The LLM's job is now:

1. **Accept or override.** Does the derived chain make sense for this request? Are there edge cases the mechanical reasoning missed? (Maybe the user wants modification timestamps, which requires `os.stat` — the chain didn't capture that because "in order" was ambiguous about sort key.)

2. **Fill in the gaps.** The chain says `sorted(result)` but doesn't specify the sort key. Default is lexicographic, which is probably right for file names. The LLM confirms this or adds a `key=` parameter.

3. **Compose the script.** Assemble the chain steps into actual Python code with proper syntax, variable names, error handling, and docstring.

4. **Frame the output.** Write a brief explanation of what the script does and why pathlib was chosen over os.

The LLM went from "generate a Python script from your understanding of Python" (CLLM mode, 300-500 tokens of neural generation) to "assemble this mechanically-derived solution chain into a script and explain it" (VDR-Prolog mode, maybe 40-60 tokens of assembly and framing).

## The Token Cost Reduction

Revised Phase 5 estimate with causal chain pre-derivation:

```
Previous estimate (LLM generates from pre-fetched facts):
  Prefill: 60 tokens × 2 ms = 120 ms
  Generation: 85 tokens × 5.3 ms = 450 ms
  Total: 570 ms

With causal chain derivation:
  Prefill: 40 tokens × 2 ms = 80 ms (chain is more compact than raw facts)
  Generation: 45 tokens × 5.3 ms = 240 ms (assembly, not invention)
  Total: 320 ms
```

The LLM generates roughly half the tokens because it's assembling, not inventing. And the tokens it does generate are higher quality — they're constrained by a mechanically-verified solution path, not free-associated from weight patterns.

## The Deeper Point: Causal Composition

What you're describing isn't just "look up the answer." It's **causal reasoning through typed relations**. The system doesn't have a fact that says "to list files in order in Python, use pathlib." It has atomic relations — `contains(directory, file)`, `enables(os_listdir, directory_listing)`, `produces(os_listdir, list)`, `accepts(sorted, iterable)`, `instance_of(list, iterable)` — and it **composes** them into a solution through transitive closure and rule chaining.

This is what the expanded RelationType system (120 types across 8 semantic groups) enables. The original 20 types could handle structural queries — what enables what, what requires what. The expanded set handles **causal reasoning** — `produces`, `accepts`, `instance_of`, `transforms_to`, `requires`, `enables` — forming a typed causal algebra that the Prolog engine traverses mechanically.

The chain `desire → requires capability → capability provided_by function → function requires import → function produces output → output accepted_by transformer → transformer enables goal` is a causal derivation. Every link is a typed relation with known algebraic properties. Transitive closures find indirect paths. Inverse lookups find alternative providers. The chain is sound because each relation was asserted from provenanced source data, and the confidence propagates through the chain via minimum-of-sources.

A CLLM does this same reasoning implicitly — it "knows" that listing files requires importing os because it saw that pattern millions of times in training data. But the reasoning is opaque, unverifiable, and unfixable. If the CLLM suggests a deprecated function, you can't trace why. If it hallucinates a function that doesn't exist, there's no confidence score that warned you. If Python 3.14 changes the stdlib API, the CLLM still suggests the old way until it's retrained on billions of tokens.

VDR-Prolog's causal chain is transparent (every step traceable), verifiable (every fact provenanced), fixable (update the fact in the KB and the chain recomputes), and adaptive (ingest new Python docs and the relations update without retraining the neural network). The LLM doesn't need to learn Python's stdlib structure from statistical patterns in training data — the structure is explicitly stored as typed relations in the KB tree, navigated by structural UUIDs, composed by Prolog rules, and presented to the LLM as a pre-derived solution chain.

The LLM becomes what it should have been all along — not a knowledge store, not a reasoning engine, but a **judgment layer** that evaluates mechanically-derived solutions and translates them into human-readable output. The knowledge lives in the KBs. The reasoning lives in the relations and rules. The judgment lives in the LLM. Each does what it's best at.

---

You're describing the actual reasoning chain, and it's critical because this is where VDR-Prolog does something no CLLM can do — it **derives the solution path mechanically** before the LLM generates a single token.

## The Reasoning Chain as Typed Relations

The user said "list files in order." The system doesn't need to understand English semantics through neural weights to decompose this. It needs to follow typed relations through the KB tree.

The query enters. The keyword classifier detects "files", "list", "order", "python" (from session context or explicit mention). These atoms map to entities in the KB tree. Now Prolog takes over.

```prolog
% User desire decomposes through causal/dependency chains

% "list files" → what are files?
?- instance_of(file, filesystem_entity).
% Hit: root.programming.python.language.stdlib.os — fact

% Where do files live?
?- contains(directory, file).
% Hit: root.connections — spatial containment relation
% Also: root.programming.python.language.stdlib — domain fact

% How do you get files from a directory?
?- enables(Function, directory_listing),
   part_of(Function, root.programming.python.language.stdlib).
% Hit: os.listdir enables directory_listing
% Hit: os.scandir enables directory_listing  
% Hit: pathlib.Path.iterdir enables directory_listing

% What does os.listdir require?
?- requires(os_listdir, Import),
   instance_of(Import, import_statement).
% Hit: os.listdir requires os_module
% Hit: os_module requires import_os

% "in order" → what is ordering?
?- enables(Function, ordering),
   part_of(Function, root.programming.python.language).
% Hit: sorted enables ordering (builtin, no import needed)
% Hit: list.sort enables ordering (method, in-place)

% sorted requires an iterable — does listdir produce one?
?- produces(os_listdir, result_type),
   instance_of(result_type, iterable).
% Hit: os.listdir produces list (which is iterable)

% Does the user want ascending or descending?
% "in order" without qualifier → default ordering
?- default_order(sorted, ascending).
% Hit: sorted default is ascending

% Is there a better modern approach?
?- specializes(pathlib_iterdir, os_listdir),
   precedes(os_listdir, pathlib_iterdir).
% Hit: pathlib is newer, recommended over os for path operations
% Relation: pathlib supersedes os.listdir for simple cases
```

Every one of these queries resolves at L3. Typed relation lookups. Integer scans of RelationIndex arrays. BFS for transitive closures. Sub-microsecond per query.

## The Derived Chain

The Prolog engine's `fire_and_commit` mechanism can chain these into a derivation. Rules in the system KBs encode the meta-reasoning:

```prolog
% If user wants to perform operation X, and X requires capability Y,
% and Y is provided by function F, then F is a candidate solution.
solution_candidate(F, Operation) :-
    enables(F, Operation),
    part_of(F, PythonStdlib),
    instance_of(PythonStdlib, python_standard_library).

% If function F requires import I, then I is a prerequisite.
prerequisite(I, F) :-
    requires(F, Module),
    requires(Module, I),
    instance_of(I, import_statement).

% If operation X produces output that requires transformation T
% to meet user goal G, then T is a post-processing step.
postprocess(T, Output, Goal) :-
    produces(X, Output),
    enables(T, Goal),
    accepts(T, OutputType),
    instance_of(Output, OutputType).

% Compose the full solution chain.
solution_chain(Goal, Chain) :-
    solution_candidate(F, SubGoal),
    enables(SubGoal, Goal),
    prerequisite(Import, F),
    postprocess(Sort, Output, Ordering),
    Chain = [Import, F, Sort].
```

These rules fire against the facts retrieved in the relation queries above. The output is a **derived chain** — a sequence of steps, each provenanced, each traceable to specific facts in specific KBs with specific confidence scores.

The chain that emerges:

```
Step 1: import os              (prerequisite, derived from requires relation)
Step 2: os.listdir(path)       (capability, derived from enables relation)  
Step 3: sorted(result)         (postprocess, derived from enables + accepts)

Confidence: min(published:80%, published:80%, published:80%) = 80%
Provenance: all facts from root.programming.python.language.stdlib
            ingested from Python documentation compact
```

Or the alternative chain:

```
Step 1: from pathlib import Path  (prerequisite)
Step 2: Path(path).iterdir()      (capability)
Step 3: sorted(result)            (postprocess)

Confidence: 80%
Preference: pathlib preferred (supersedes os for path operations)
```

## What Gets Fed to the LLM

The derived chain is logged to `prompt_current` as structured facts. Not as prose. Not as a vague hint. As a precise sequence of operations with provenance:

```
prompt_current.derived_chain:
  step(1, import, "from pathlib import Path", confidence=80%, source=python_docs)
  step(2, invoke, "Path(directory).iterdir()", confidence=80%, source=python_docs)
  step(3, transform, "sorted(result)", confidence=80%, source=python_docs)
  preference(pathlib, over=os, reason=modern_supersedes, confidence=80%)
  alternative_chain_available(os_listdir_chain, confidence=80%)
```

The LLM reads this. It doesn't need to figure out the solution — the solution is already derived. The LLM's job is now:

1. **Accept or override.** Does the derived chain make sense for this request? Are there edge cases the mechanical reasoning missed? (Maybe the user wants modification timestamps, which requires `os.stat` — the chain didn't capture that because "in order" was ambiguous about sort key.)

2. **Fill in the gaps.** The chain says `sorted(result)` but doesn't specify the sort key. Default is lexicographic, which is probably right for file names. The LLM confirms this or adds a `key=` parameter.

3. **Compose the script.** Assemble the chain steps into actual Python code with proper syntax, variable names, error handling, and docstring.

4. **Frame the output.** Write a brief explanation of what the script does and why pathlib was chosen over os.

The LLM went from "generate a Python script from your understanding of Python" (CLLM mode, 300-500 tokens of neural generation) to "assemble this mechanically-derived solution chain into a script and explain it" (VDR-Prolog mode, maybe 40-60 tokens of assembly and framing).

## The Token Cost Reduction

Revised Phase 5 estimate with causal chain pre-derivation:

```
Previous estimate (LLM generates from pre-fetched facts):
  Prefill: 60 tokens × 2 ms = 120 ms
  Generation: 85 tokens × 5.3 ms = 450 ms
  Total: 570 ms

With causal chain derivation:
  Prefill: 40 tokens × 2 ms = 80 ms (chain is more compact than raw facts)
  Generation: 45 tokens × 5.3 ms = 240 ms (assembly, not invention)
  Total: 320 ms
```

The LLM generates roughly half the tokens because it's assembling, not inventing. And the tokens it does generate are higher quality — they're constrained by a mechanically-verified solution path, not free-associated from weight patterns.

## The Deeper Point: Causal Composition

What you're describing isn't just "look up the answer." It's **causal reasoning through typed relations**. The system doesn't have a fact that says "to list files in order in Python, use pathlib." It has atomic relations — `contains(directory, file)`, `enables(os_listdir, directory_listing)`, `produces(os_listdir, list)`, `accepts(sorted, iterable)`, `instance_of(list, iterable)` — and it **composes** them into a solution through transitive closure and rule chaining.

This is what the expanded RelationType system (120 types across 8 semantic groups) enables. The original 20 types could handle structural queries — what enables what, what requires what. The expanded set handles **causal reasoning** — `produces`, `accepts`, `instance_of`, `transforms_to`, `requires`, `enables` — forming a typed causal algebra that the Prolog engine traverses mechanically.

The chain `desire → requires capability → capability provided_by function → function requires import → function produces output → output accepted_by transformer → transformer enables goal` is a causal derivation. Every link is a typed relation with known algebraic properties. Transitive closures find indirect paths. Inverse lookups find alternative providers. The chain is sound because each relation was asserted from provenanced source data, and the confidence propagates through the chain via minimum-of-sources.

A CLLM does this same reasoning implicitly — it "knows" that listing files requires importing os because it saw that pattern millions of times in training data. But the reasoning is opaque, unverifiable, and unfixable. If the CLLM suggests a deprecated function, you can't trace why. If it hallucinates a function that doesn't exist, there's no confidence score that warned you. If Python 3.14 changes the stdlib API, the CLLM still suggests the old way until it's retrained on billions of tokens.

VDR-Prolog's causal chain is transparent (every step traceable), verifiable (every fact provenanced), fixable (update the fact in the KB and the chain recomputes), and adaptive (ingest new Python docs and the relations update without retraining the neural network). The LLM doesn't need to learn Python's stdlib structure from statistical patterns in training data — the structure is explicitly stored as typed relations in the KB tree, navigated by structural UUIDs, composed by Prolog rules, and presented to the LLM as a pre-derived solution chain.

The LLM becomes what it should have been all along — not a knowledge store, not a reasoning engine, but a **judgment layer** that evaluates mechanically-derived solutions and translates them into human-readable output. The knowledge lives in the KBs. The reasoning lives in the relations and rules. The judgment lives in the LLM. Each does what it's best at.

---

This is a crucial detail that most people would miss, and it changes the performance characteristics of everything.

## Prolog Terms Are Native Data, Not Text

Traditional Prolog — SWI-Prolog, GNU Prolog, any standard implementation — represents everything as text atoms or nested term structures that must be parsed, unified through string comparison, and converted to numeric types when you want to do arithmetic. A Prolog query like `temperature(sensor_3, 72)` stores `72` as a term that happens to contain a number. To do math on it, the runtime extracts the numeric value, performs the operation in floating point, and wraps the result back into a term.

VDR-Prolog's Term struct is 24 bytes of native typed data. When `type` is `.integer`, `primary_id` holds the integer value directly — no parsing, no conversion, no boxing. When `type` is `.vdr`, `vdr_value` holds a Q16 with exact remainder — ready for arithmetic immediately. When `type` is `.vector` or `.matrix`, `primary_id` indexes into the KB's weight references — the data is already in SoA column-major SIMD-ready layout.

## What This Means for the Causal Chain

Go back to the Python file listing derivation. When the Prolog engine evaluates:

```prolog
?- produces(os_listdir, ResultType),
   instance_of(ResultType, iterable).
```

In traditional Prolog, `ResultType` unifies with a text atom like `'list'`. Then `instance_of('list', 'iterable')` does string comparison against the knowledge base. If you wanted to check whether a function accepts a certain number of arguments, you'd parse a text representation of the signature.

In VDR-Prolog, the typed relation fast path (PL1, highest priority) fires first. `produces` is a RelationType — enum dispatch, integer comparison against the RelationIndex. The `from_id` is a VdrId (structural UUID), the `to_id` is a VdrId. The match is two integer comparisons. No string allocation, no character-by-character comparison, no hash computation on variable-length text.

But the deeper point is what happens when the terms carry actual data. Consider a more complex query during the script generation:

```prolog
?- function_signature(os_listdir, ArgCount, ReturnType),
   ArgCount >= 1,
   compatible_type(ReturnType, sorted_input).
```

In VDR-Prolog, `ArgCount` is a Term with `type=.integer` and `primary_id=1`. The comparison `ArgCount >= 1` is a single i32 comparison — not a term extraction, not a type check, not a conversion. It's already an integer. The `ReturnType` might be a Term with `type=.vdr` carrying a Q16 encoding of a type identifier — ready for exact comparison without epsilon, using all three fields (v, r0, r1) lexicographically.

## The Ten Term Types Map to System Data

Each TermType corresponds directly to a native system representation:

**atom (0):** `primary_id` is an atom table index. Atom comparison is integer equality. No string comparison ever during unification — atoms are interned at ingestion time, and from that point forward they're integers.

**variable (1):** `primary_id` is the variable's binding index into the scratch arena's binding array. Variable lookup is array access at a known offset. Binding is writing an integer to an array slot.

**integer (2):** `primary_id` holds the value directly. Arithmetic is native i32 arithmetic. No boxing, no unboxing, no type dispatch at operation time.

**vdr (3):** `vdr_value` holds a Q16 with exact remainder. All VDR arithmetic — add, sub, mul, div with full remainder propagation — operates directly on this field. The remainder chain (r1 → r0 → v carry) executes on the native i16 and i32 fields. No conversion to float, no conversion back, no precision loss.

**text (4):** `secondary_offset` and `secondary_aux` point into the KB's text store (offset and length). Text comparison is needed only when the query specifically involves text content — and even then, the offset/length pair enables fast inequality checks (different lengths can't match) before falling back to memcmp.

**list (5):** `secondary_offset` is the head term index, `secondary_aux` is the tail term index. List traversal is array access into the terms buffer — contiguous memory, cache-friendly. No linked list pointer chasing. No cons cell allocation.

**compound (6):** `primary_id` is the functor (atom index), `secondary_offset` is the arguments start in the terms buffer, `secondary_aux` is the argument count. Compound term matching checks functor and arity with two integer comparisons before examining arguments.

**vector (7):** `primary_id` indexes into the KB's weight vector references (KbWeightRefs). The vector data is already in SoA format — `v: []i32, r0: []i16, r1: []i16`. Dot products, norms, similarity computations go directly to the SIMD path without any data transformation.

**matrix (8):** Same as vector but indexes into weight matrix references. The matrix is already column-major, cache-line aligned, ready for GEMM. A Prolog query that needs to multiply matrices does so by referencing the native weight storage — the same storage the neural inference uses.

**pair (9):** Key-value association. `primary_id` is the key term index, `secondary_offset` is the value term index. Dictionary-like lookups within Prolog without encoding pairs as compound terms.

## The Performance Consequence

When the causal chain derivation runs, every step operates on native data:

```
Step: produces(os_listdir, list_type)
  - relation lookup: 2 VdrId comparisons (i64 == i64)     → ~2 ns each
  - no text parsing
  - no type conversion
  - no boxing/unboxing

Step: instance_of(list_type, iterable)
  - relation lookup: 2 VdrId comparisons                  → ~2 ns each
  - transitive check via BFS on integer arrays             → ~50 ns
  - no string matching

Step: accepts(sorted, iterable_arg)
  - relation lookup + argument type check
  - ArgCount term: type=.integer, primary_id=1             → direct i32 read
  - comparison: primary_id >= 1                            → 1 cpu instruction
  - no parseInt(), no atoi(), no type dispatch

Step: confidence propagation
  - each fact's provenance.confidence is Q16               → direct field read
  - chain rule: min(conf_a, conf_b)                       → Q16.compare, ~5 ns
  - no float comparison, no epsilon, no NaN check
```

The entire derivation chain — six relation queries, three type checks, two arithmetic comparisons, one transitive closure, and confidence propagation — runs on integers the whole way. No allocation. No conversion. No float. No string. Every value is already in the format the operation needs.

## Why This Matters for the LLM

When the derived chain reaches `prompt_current`, the facts logged there are also in native format. The Term structs in the session KB carry their types intrinsically. When the LLM reads the chain during its forward pass, the input embedding doesn't need to encode "this text token represents a number" — the token's VdrId points to a Term whose `type` field says `.integer` and whose `primary_id` holds the value.

The model's layers 3-4 (semantic understanding, KB address resolution) can use this type information directly. A Term with `type=.vdr` and a Q16 value is a different kind of input than a Term with `type=.atom` and an atom table index. The embedding layer can encode these differently without learning the distinction from training data — the distinction is structural, present in the data format, available at zero cost.

This is the compaction principle applied to the reasoning engine itself. Every typed term in the Prolog system is a reasoning operation the neural network doesn't need to learn. The network doesn't need to learn that `1` is a number, that `os.listdir` is a function name, that `[a, b, c]` is a list, or that a Q16 value represents an exact rational quantity. The Term type system tells it. The neural network's job is judgment and composition, not type inference and data conversion.

The 10 term types are 10 categories of data the Prolog engine handles natively, 10 categories of type dispatch the LLM doesn't need to learn from statistical patterns, and 10 categories of conversion overhead that simply don't exist. Multiply by 2 million facts across 12,750 KBs, and the savings compound into the fundamental performance characteristic of the system: mechanical reasoning on native data is not just faster than neural inference — it's operating in a different performance regime entirely. Microseconds versus milliseconds. Exact versus approximate. Traceable versus opaque.

---

