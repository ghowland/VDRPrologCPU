# PROGRAMMING FOUNDATIONS (C, PYTHON, ZIG) — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: concepts → type_systems → types → memory_models → control_flow → data_structures → paradigms → error_handling → toolchains → idioms → distinctions → relationships → decode_legend

# concepts(id|name|definition|category)
CO1|Variable|named storage location binding an identifier to a value or memory address|foundation
CO2|Expression|combination of values, variables, operators yielding a result|foundation
CO3|Statement|unit of execution; may have side effects; does not necessarily yield a value|foundation
CO4|Function|named callable unit: takes parameters, executes body, optionally returns value|foundation
CO5|Scope|region of source where a binding is visible; lexical (static) or dynamic|foundation
CO6|Lifetime|duration a value or allocation remains valid; static, stack, or heap|foundation
CO7|Type|classification constraining values and operations on a datum|foundation
CO8|Literal|value written directly in source code (42, "hello", 3.14)|foundation
CO9|Operator|symbol or keyword performing computation on operands (+, *, ==, and)|foundation
CO10|Identifier|name referring to a variable, function, type, or module|foundation
CO11|Assignment|binding a value to a variable; may be initialization or mutation|foundation
CO12|Declaration|introducing a name and its type/properties without necessarily defining|foundation
CO13|Definition|providing the body or value for a declared name|foundation
CO14|Compilation Unit|single source file processed as a unit by the compiler|foundation
CO15|Translation|process of converting source to executable form (compilation, interpretation, JIT)|foundation
CO16|Undefined Behavior (UB)|program state where language spec imposes no requirements; compiler may assume it never happens|C
CO17|Implementation-Defined Behavior|behavior where compiler chooses a consistent approach and documents it|C
CO18|Unspecified Behavior|behavior where spec allows multiple options; compiler need not document choice|C
CO19|Sequence Point|point in execution where all prior side effects are complete|C
CO20|ABI (Application Binary Interface)|binary-level calling convention, layout, and linking rules|foundation
CO21|Calling Convention|rules for how arguments, return values, and stack are managed across function calls|foundation
CO22|Linkage|visibility of symbol across compilation units: external, internal, none|C
CO23|Header File|file containing declarations shared across compilation units; #include'd|C
CO24|Module|encapsulation unit grouping related definitions; Python module=file; Zig has explicit module system|foundation
CO25|Package|collection of modules distributed as a unit; Python package=directory with __init__.py; Zig package=root source file|foundation
CO26|Namespace|named scope preventing identifier collision|foundation
CO27|Import|mechanism to access names from another module/package|foundation
CO28|Closure|function capturing variables from its enclosing scope|foundation
CO29|Iterator|object producing a sequence of values on demand via protocol (next/sentinel)|foundation
CO30|Generator|function yielding values lazily via yield; Python-specific coroutine form|Python
CO31|Decorator|@-prefixed callable wrapping a function or class at definition time|Python
CO32|Descriptor|object defining __get__, __set__, or __delete__; controls attribute access on classes|Python
CO33|Metaclass|class of a class; controls class creation (default: type)|Python
CO34|Protocol (Python)|structural subtyping interface; duck-type contract formalized via typing.Protocol|Python
CO35|Dunder Method|double-underscore special method (__init__, __repr__, __add__); Python data model hooks|Python
CO36|GIL (Global Interpreter Lock)|mutex preventing concurrent execution of Python bytecodes in CPython|Python
CO37|Comptime|Zig compile-time execution: any expression or function callable at compile time if inputs are comptime-known|Zig
CO38|Allocator (Zig)|explicit memory allocation interface passed as parameter; no global allocator|Zig
CO39|Error Union|Zig type combining error set with payload type: ErrorSet!PayloadType|Zig
CO40|Optional|Zig type: ?T; value is either T or null; explicit null handling|Zig
CO41|Sentinel-Terminated|Zig slice/pointer with known terminator value (e.g., [:0]u8 for null-terminated string)|Zig
CO42|Packed Struct|Zig struct with guaranteed exact memory layout, no padding|Zig
CO43|Extern Struct|Zig struct with C ABI-compatible layout|Zig
CO44|Builtin Function|Zig @-prefixed compiler intrinsic (@intCast, @memcpy, @TypeOf)|Zig
CO45|Test Block|Zig first-class test declaration: test "name" { ... }; run by build system|Zig
CO46|Preprocessor|C textual macro expansion phase before compilation (#define, #include, #ifdef)|C
CO47|Pointer|variable storing a memory address; typed in C/Zig, absent in Python surface layer|foundation
CO48|Reference Counting|memory management tracking count of references to each object; CPython primary GC mechanism|Python
CO49|Tracing GC|garbage collector traversing object graph to find unreachable objects; CPython cycle detector|Python
CO50|Inline Assembly|embedding architecture-specific assembly within source; C via asm/\_\_asm\_\_; Zig via asm keyword|foundation
CO51|Bit Manipulation|operations on individual bits: &, |, ^, ~, <<, >>|foundation
CO52|Volatile|C qualifier preventing compiler from optimizing away reads/writes to a variable; hardware/MMIO use|C
CO53|Restrict|C qualifier asserting pointer is sole access path to its target; enables optimization|C
CO54|Const|qualifier marking a value as immutable after initialization; C const, Zig const|foundation
CO55|Comptime Parameter|Zig function parameter known at compile time; enables generic programming without runtime cost|Zig
CO56|Duck Typing|type compatibility determined by presence of methods/attributes, not declared inheritance|Python
CO57|List Comprehension|[expr for x in iterable if cond]; concise list construction|Python
CO58|Context Manager|object implementing __enter__ and __exit__; used with `with` statement|Python
CO59|f-string|f"...{expr}..."; formatted string literal with embedded expressions|Python
CO60|Sentinel Value|special value marking end of data (NULL in C, null/0 sentinel in Zig, None in Python)|foundation
CO61|Zero-Cost Abstraction|abstraction that compiles to code as efficient as hand-written equivalent|foundation
CO62|Compile-Time Reflection|inspecting types and declarations at compile time; Zig @typeInfo, @hasField|Zig
CO63|Undefined Behavior (anti-pattern)|relying on UB for "working" code; compiler may optimize away safety checks|anti_pattern
CO64|Global Mutable State (anti-pattern)|shared mutable state accessible from anywhere; breaks locality and testability|anti_pattern
CO65|Magic Numbers (anti-pattern)|unnamed numeric literals scattered in code; obscures intent|anti_pattern
CO66|Callback Hell (anti-pattern)|deeply nested callbacks making control flow unreadable|anti_pattern
CO67|Buffer Overflow (anti-pattern)|writing past allocated memory bounds; primary C vulnerability class|anti_pattern
CO68|Use After Free (anti-pattern)|accessing memory after deallocation; undefined behavior in C, prevented by Zig safety|anti_pattern
CO69|Double Free (anti-pattern)|freeing same allocation twice; heap corruption in C|anti_pattern
CO70|Dangling Pointer (anti-pattern)|pointer to deallocated or out-of-scope memory|anti_pattern
CO71|Data Race (anti-pattern)|unsynchronized concurrent access where at least one is a write|anti_pattern
CO72|Mutable Default Argument (anti-pattern)|Python def f(x=[]); default shared across calls; silent mutation bug|anti_pattern
CO73|Bare Except (anti-pattern)|Python except: catching all exceptions including SystemExit, KeyboardInterrupt|anti_pattern

# type_systems(id|name|classification|features|language)
TS1|C Type System|static, weak, manifest|implicit conversions between numeric types; void* erases type; no generics (macros simulate); no bounds checking|C
TS2|Python Type System|dynamic, strong, duck-typed|types checked at runtime; no implicit numeric coercion (int+str → TypeError); optional type hints (PEP 484); typing module for generics|Python
TS3|Zig Type System|static, strong, manifest with inference|comptime generics; no implicit conversions; explicit @intCast/@floatCast; comptime type parameters; error unions as types; optional types|Zig

# types(id|name|size_bytes|category|language|notes)
TY1|char|1|integer|C|signed or unsigned implementation-defined
TY2|signed char|1|integer|C|guaranteed signed
TY3|unsigned char|1|integer|C|guaranteed unsigned; byte access
TY4|short|≥2|integer|C|at least 16 bits
TY5|int|≥2|integer|C|at least 16 bits; usually 32
TY6|long|≥4|integer|C|at least 32 bits
TY7|long long|≥8|integer|C|at least 64 bits (C99+)
TY8|float|4|floating|C|IEEE 754 single precision (typically)
TY9|double|8|floating|C|IEEE 754 double precision (typically)
TY10|long double|≥8|floating|C|extended precision; size varies (8,10,12,16)
TY11|_Bool|≥1|integer|C|C99; stores 0 or 1
TY12|void|0|special|C|incomplete type; no objects; return type for no-return-value
TY13|void*|pointer-sized|pointer|C|generic pointer; implicit conversion to/from any object pointer
TY14|size_t|platform|unsigned|C|unsigned type for sizeof results and array indexing
TY15|ptrdiff_t|platform|signed|C|signed type for pointer arithmetic differences
TY16|int8_t|1|exact_integer|C|C99 stdint.h; exactly 8 bits signed
TY17|int16_t|2|exact_integer|C|exactly 16 bits signed
TY18|int32_t|4|exact_integer|C|exactly 32 bits signed
TY19|int64_t|8|exact_integer|C|exactly 64 bits signed
TY20|uint8_t|1|exact_integer|C|exactly 8 bits unsigned
TY21|uint16_t|2|exact_integer|C|exactly 16 bits unsigned
TY22|uint32_t|4|exact_integer|C|exactly 32 bits unsigned
TY23|uint64_t|8|exact_integer|C|exactly 64 bits unsigned
TY24|int|arbitrary|integer|Python|arbitrary precision; no overflow
TY25|float|8|floating|Python|C double internally (IEEE 754 64-bit)
TY26|complex|16|floating|Python|real + imaginary, both C doubles
TY27|bool|28|integer|Python|subclass of int; True=1, False=0; object overhead
TY28|str|variable|sequence|Python|immutable Unicode (UTF-8 internal since 3.12); indexed by code point
TY29|bytes|variable|sequence|Python|immutable byte sequence
TY30|bytearray|variable|sequence|Python|mutable byte sequence
TY31|list|variable|sequence|Python|mutable dynamic array of arbitrary objects
TY32|tuple|variable|sequence|Python|immutable sequence of arbitrary objects
TY33|dict|variable|mapping|Python|hash map; insertion-ordered since 3.7; O(1) avg lookup
TY34|set|variable|collection|Python|unordered unique elements; hash-based; O(1) avg membership
TY35|frozenset|variable|collection|Python|immutable set; hashable
TY36|NoneType|16|singleton|Python|single value None; null equivalent
TY37|i8|1|integer|Zig|signed 8-bit
TY38|i16|2|integer|Zig|signed 16-bit
TY39|i32|4|integer|Zig|signed 32-bit
TY40|i64|8|integer|Zig|signed 64-bit
TY41|i128|16|integer|Zig|signed 128-bit
TY42|u8|1|integer|Zig|unsigned 8-bit
TY43|u16|2|integer|Zig|unsigned 16-bit
TY44|u32|4|integer|Zig|unsigned 32-bit
TY45|u64|8|integer|Zig|unsigned 64-bit
TY46|u128|16|integer|Zig|unsigned 128-bit
TY47|usize|platform|integer|Zig|pointer-sized unsigned; indexing type
TY48|f16|2|floating|Zig|IEEE 754 half precision
TY49|f32|4|floating|Zig|IEEE 754 single precision
TY50|f64|8|floating|Zig|IEEE 754 double precision
TY51|f128|16|floating|Zig|IEEE 754 quad precision
TY52|bool|1|boolean|Zig|true or false
TY53|void|0|special|Zig|zero-sized type; used for generic programming and unused returns
TY54|noreturn|0|special|Zig|function never returns (unreachable, infinite loop, exit)
TY55|comptime_int|0|comptime|Zig|arbitrary-precision integer at compile time; must resolve to fixed type at runtime
TY56|comptime_float|0|comptime|Zig|arbitrary-precision float at compile time
TY57|type|0|comptime|Zig|the type of types; only exists at comptime
TY58|[]T|variable|slice|Zig|fat pointer: pointer + length; bounds-checked
TY59|[N]T|N*sizeof(T)|array|Zig|fixed-size; stack-allocated; comptime-known length
TY60|*T|platform|pointer|Zig|single-item pointer; non-nullable
TY61|[*]T|platform|pointer|Zig|many-item pointer; C-like pointer arithmetic
TY62|?T|sizeof(T)+1 or platform|optional|Zig|value or null; forced explicit handling
TY63|E!T|variable|error_union|Zig|error set E or payload T; forced explicit handling
TY64|anyopaque|platform|pointer|Zig|type-erased pointer; Zig equivalent of void*
TY65|enum|varies|enumeration|C|named integer constants; underlying type is int by default
TY66|struct|varies|composite|C|aggregate of heterogeneous fields; layout implementation-defined unless packed/attributed
TY67|union|varies|composite|C|overlapping fields sharing same memory; size = largest member
TY68|enum|varies|enumeration|Zig|compile-time-known tag set; can have methods; exhaustive switching required
TY69|struct|varies|composite|Zig|product type; default unspecified layout; can be packed or extern
TY70|union|varies|composite|Zig|tagged union by default; safety-checked active field access
TY71|error_set|varies|error|Zig|set of error values; combinable with merge operator (||)

# memory_models(id|name|mechanism|ownership|language)
MM1|C Stack Allocation|automatic storage duration; deallocated on scope exit|compiler-managed; no runtime overhead|C
MM2|C Heap Allocation|malloc/calloc/realloc return void*; free deallocates; manual lifecycle|programmer-managed; must pair every allocation with exactly one free|C
MM3|C Static Allocation|static/global storage duration; exists for program lifetime|compiler-managed; initialized before main|C
MM4|Python Reference Counting|each object tracks reference count; deallocated when count reaches 0|runtime-managed; CPython implementation detail|Python
MM5|Python Cycle Collector|tracing GC detecting reference cycles among container objects|runtime-managed; supplements reference counting|Python
MM6|Python Memory Pools|pymalloc arena-based allocator for small objects (≤512 bytes)|runtime-managed; reduces malloc overhead|Python
MM7|Zig Allocator Interface|std.mem.Allocator; alloc/free/resize; passed explicitly as parameter|caller-managed; allocator choice is architectural decision|Zig
MM8|Zig Stack Allocation|default for local variables; no allocator needed|compiler-managed; deterministic lifetime|Zig
MM9|Zig Arena Allocator|bulk allocation; single free of entire arena|caller-managed; ideal for phase-bounded lifetimes|Zig
MM10|Zig General Purpose Allocator|debug-friendly; detects leaks, double-free, use-after-free in safe builds|caller-managed; recommended for development|Zig
MM11|Zig Fixed Buffer Allocator|allocates from a fixed-size buffer; no heap; no fragmentation|caller-managed; embedded/constrained environments|Zig
MM12|Zig Page Allocator|thin wrapper over OS mmap/VirtualAlloc|caller-managed; large allocations|Zig

# control_flow(id|name|syntax_pattern|semantics|language)
CF1|if/else|if (cond) { } else { }|conditional branch; C and Zig; Zig condition must be bool (no implicit truthiness)|all
CF2|Python if/elif/else|if cond: / elif cond: / else:|conditional branch; truthy/falsy evaluation|Python
CF3|while|while (cond) { }|loop while condition true|all
CF4|for (C)|for (init; cond; step) { }|three-part loop; any part may be empty|C
CF5|for (Python)|for x in iterable:|iterator protocol loop; calls __iter__ then __next__ until StopIteration|Python
CF6|for (Zig)|for (slice) |item| { }|iterate over slices and ranges; captures item and optional index|Zig
CF7|while (Zig) with capture|while (optional) |val| { }|unwrap optional; loop while non-null|Zig
CF8|switch (C)|switch (expr) { case N: ... break; }|integer/enum dispatch; fallthrough by default|C
CF9|switch (Zig)|switch (expr) { .tag => { }, }|exhaustive matching; no fallthrough; supports ranges and capture|Zig
CF10|match (Python)|match expr: case pattern:|structural pattern matching (3.10+); irrefutable/refutable patterns|Python
CF11|break|break;|exit innermost loop|all
CF12|continue|continue;|skip to next iteration|all
CF13|return|return expr;|exit function with value|all
CF14|goto|goto label;|unconditional jump to label in same function|C
CF15|try (Python)|try: ... except E as e: ... else: ... finally:|exception handling; catch by type; else on no exception; finally always runs|Python
CF16|try (Zig)|try expr|try on error union; returns error if error, unwraps payload if success|Zig
CF17|catch (Zig)|expr catch |err| { }|handle error from error union; provides error value for inspection|Zig
CF18|errdefer (Zig)|errdefer expr;|execute expression on scope exit only if function returns error|Zig
CF19|defer (Zig)|defer expr;|execute expression on scope exit unconditionally; LIFO order|Zig
CF20|defer (C)|— (absent)|not available; cleanup requires manual goto-chain or wrapper patterns|C
CF21|with (Python)|with ctx_mgr as x:|context manager protocol; __enter__ on entry, __exit__ on exit (even on exception)|Python
CF22|yield (Python)|yield expr|suspend generator; produce value to caller; resume on next()|Python
CF23|async/await (Python)|async def f(): await coro|coroutine-based concurrency; event loop drives execution|Python
CF24|async (Zig)|async fn call|stackless coroutine; frame stored in caller-provided memory|Zig
CF25|unreachable (Zig)|unreachable;|assert control flow never reaches this point; UB in unsafe, panic in safe|Zig
CF26|comptime block (Zig)|comptime { }|force compile-time evaluation of enclosed block|Zig
CF27|inline for (Zig)|inline for (slice) |item| { }|unroll loop at compile time; body specialized per element|Zig
CF28|orelse (Zig)|optional orelse default|unwrap optional or provide fallback value|Zig

# data_structures(id|name|definition|time_complexity|language)
DS1|Array (C)|contiguous fixed-size block of same-type elements|access O(1); search O(n); no resize|C
DS2|Dynamically Allocated Array (C)|malloc'd contiguous block; manual realloc for growth|access O(1); append amortized O(1) with realloc strategy|C
DS3|Linked List (C)|nodes with data + pointer to next; manually allocated|access O(n); insert at known position O(1); search O(n)|C
DS4|Struct (C)|named aggregate of typed fields; value semantics|field access O(1)|C
DS5|Union (C)|overlapping storage; one active member at a time; unchecked|member access O(1); no safety check on active member|C
DS6|list (Python)|dynamic array of PyObject pointers|access O(1); append amortized O(1); insert O(n); membership O(n)|Python
DS7|tuple (Python)|immutable fixed-length sequence of PyObject pointers|access O(1); membership O(n); hashable if all elements hashable|Python
DS8|dict (Python)|open-addressing hash table; insertion-ordered|get/set/delete avg O(1); worst O(n); iteration O(n)|Python
DS9|set (Python)|hash table of unique elements|add/remove/membership avg O(1); worst O(n)|Python
DS10|deque (Python)|collections.deque; doubly-linked list of blocks|append/pop both ends O(1); indexed access O(n)|Python
DS11|defaultdict (Python)|dict subclass with factory for missing keys|same as dict; avoids KeyError on first access|Python
DS12|Counter (Python)|dict subclass mapping elements to counts|construction O(n); most_common O(n log k)|Python
DS13|namedtuple (Python)|tuple subclass with named fields; immutable|same as tuple; field access by name O(1)|Python
DS14|dataclass (Python)|decorator generating __init__, __repr__, __eq__ etc. from field annotations|access O(1); mutable by default; frozen option for immutability|Python
DS15|Array (Zig)|[N]T; fixed-size; stack or comptime; length comptime-known|access O(1); no resize|Zig
DS16|Slice (Zig)|[]T; fat pointer (ptr + len); bounds-checked in safe mode|access O(1); no ownership; view into array or allocation|Zig
DS17|ArrayList (Zig)|std.ArrayList(T); dynamic array backed by allocator|access O(1); append amortized O(1); requires allocator|Zig
DS18|HashMap (Zig)|std.HashMap; open-addressing; requires allocator|get/put avg O(1); requires hash and eql functions|Zig
DS19|ArrayHashMap (Zig)|std.ArrayHashMap; preserves insertion order; array-backed|get/put avg O(1); ordered iteration; better cache locality|Zig
DS20|BoundedArray (Zig)|std.BoundedArray(T, max); stack-allocated dynamic array with capacity limit|access O(1); append O(1) up to max; no allocator needed|Zig
DS21|Tagged Union (Zig)|union(enum) { }; active field tracked by tag; safety-checked access|field access O(1); switch on tag exhaustive|Zig
DS22|MultiArrayList (Zig)|std.MultiArrayList; struct-of-arrays layout from array-of-structs type|access O(1); cache-friendly iteration per field|Zig
DS23|Bit-field struct (C)|struct fields with specified bit widths|field access O(1); packing implementation-defined; not portable|C

# paradigms(id|name|definition|supported_by)
PA1|Imperative|sequential statements mutating state|C, Python, Zig
PA2|Procedural|imperative + functions as primary abstraction|C, Python, Zig
PA3|Object-Oriented|encapsulation, inheritance, polymorphism via classes/objects|Python
PA4|Functional|functions as first-class values; immutability preference; composition|Python (partial), Zig (partial: comptime functions)
PA5|Generic Programming|type-parameterized code; instantiated per type|Zig (comptime), C (macros/void*), Python (duck typing)
PA6|Metaprogramming|code that generates or transforms code|Python (decorators, metaclasses), Zig (comptime), C (preprocessor)
PA7|Data-Oriented Design|organize data by access pattern, not object hierarchy; struct-of-arrays; cache efficiency|Zig (MultiArrayList), C (manual)
PA8|Structured Programming|control flow via sequence, selection, iteration; no goto|Python, Zig; C supports but does not enforce
PA9|Concurrent Programming|multiple execution contexts; shared or message-passing coordination|Python (threading, asyncio, multiprocessing), C (pthreads), Zig (async, std.Thread)

# error_handling(id|name|mechanism|language)
EH1|Return Codes|function returns integer; 0=success, nonzero=error; caller must check|C
EH2|errno|global thread-local variable set on error by libc functions; caller checks after call|C
EH3|NULL Return|return NULL pointer on allocation or lookup failure; caller must check|C
EH4|setjmp/longjmp|non-local jump for error recovery; fragile; bypasses stack unwinding|C
EH5|Exceptions|try/except/finally; raise to throw; exception hierarchy rooted at BaseException|Python
EH6|Error Unions|E!T; function returns error or payload; caller must handle via try/catch/if|Zig
EH7|Error Sets|named set of error values; can merge with ||; exhaustive switch|Zig
EH8|Optional Return|?T; return null on failure; caller handles with orelse/if/while|Zig
EH9|unreachable|assert impossible state; panic in safe mode; UB in unsafe|Zig
EH10|@panic|Zig runtime panic; prints message and stack trace; aborts|Zig
EH11|errdefer Cleanup|defer that runs only on error return; resource cleanup on failure path|Zig
EH12|assert (C)|assert(expr); aborts with message if expr is false; disabled by NDEBUG|C
EH13|assert (Python)|assert expr, msg; raises AssertionError; disabled by -O flag|Python
EH14|std.debug.assert (Zig)|panic if condition false; not disabled in release; safety check|Zig

# toolchains(id|name|components|language)
TC1|GCC|preprocessor (cpp) → compiler (cc1) → assembler (as) → linker (ld); output: ELF/Mach-O/PE|C
TC2|Clang/LLVM|preprocessor → Clang frontend → LLVM IR → optimizer → backend codegen → linker|C
TC3|MSVC|cl.exe preprocessor+compiler → link.exe linker; Windows-native; PDB debug info|C
TC4|CPython|tokenizer → parser → AST → compiler → bytecode (.pyc) → PVM (stack-based VM)|Python
TC5|PyPy|RPython toolchain → tracing JIT compiler; compatible with CPython C API (mostly)|Python
TC6|pip/PyPI|package manager (pip) → package index (PyPI) → installs into site-packages|Python
TC7|venv|lightweight virtual environment isolating packages per project; stdlib since 3.3|Python
TC8|Zig Build System|build.zig (declarative Zig code) → zig build → compile + link; cross-compilation built-in|Zig
TC9|Zig Compiler|tokenizer → parser → AST → AIR → semantic analysis → LLVM IR or self-hosted backend → machine code|Zig
TC10|Zig Test Runner|zig test file.zig; discovers and runs test blocks; reports pass/fail/skip|Zig
TC11|Zig Package Manager|build.zig.zon declares dependencies; zig fetch retrieves; content-addressed|Zig
TC12|Make|rule-based build automation; Makefile defines targets, dependencies, recipes|C
TC13|CMake|meta-build system generating Makefiles or IDE projects from CMakeLists.txt|C
TC14|GDB|GNU debugger; breakpoints, stepping, memory inspection, watchpoints|C
TC15|LLDB|LLVM debugger; similar to GDB; native for Clang-built binaries|C
TC16|Valgrind|dynamic analysis tool: memory leak detection (memcheck), profiling, thread checking|C
TC17|AddressSanitizer (ASan)|compile-time instrumentation detecting buffer overflows, use-after-free, leaks|C
TC18|pdb|Python debugger; breakpoints, stepping, inspection; stdlib|Python
TC19|mypy|static type checker for Python type hints; runs before execution|Python
TC20|pytest|Python test framework; auto-discovery, fixtures, parametrize, assertion introspection|Python

# idioms(id|name|pattern|rationale|language)
ID1|RAII-via-goto|allocate → check → use → cleanup: label with free() chain|structured cleanup in C without exceptions; single exit point|C
ID2|Opaque Pointer|typedef struct Impl *Handle; expose only via functions|encapsulation in C; hide struct layout from callers|C
ID3|Callback Function Pointer|typedef int (*callback_fn)(void *ctx, int arg);|generic extensibility; caller provides behavior + context pointer|C
ID4|Container Of|macro: (type*)((char*)ptr - offsetof(type, member))|recover enclosing struct from pointer to member; Linux kernel pattern|C
ID5|X-Macro|#define LIST X(a) X(b) X(c); redefine X per use|generate parallel enums, strings, tables from single list|C
ID6|Sentinel Array|null-terminated or -1-terminated array; iterate until sentinel|variable-length data without separate count|C
ID7|Pythonic Iteration|for x in collection: (not for i in range(len(collection)))|direct iteration; clearer intent; fewer off-by-one errors|Python
ID8|EAFP|try/except rather than if/check-then-act|easier to ask forgiveness than permission; Pythonic error handling|Python
ID9|LBYL|if key in dict: val = dict[key]|look before you leap; appropriate when check is cheap and exception expensive|Python
ID10|Context Manager Pattern|with open(f) as fh: ...|guaranteed cleanup; replaces try/finally for resource management|Python
ID11|Dunder Protocol|define __len__, __getitem__ etc. for custom container behavior|duck-typing integration with builtins (len(), indexing, iteration)|Python
ID12|Allocator Passing|fn init(allocator: std.mem.Allocator) !Self|explicit allocation; no hidden heap access; testable with different allocators|Zig
ID13|Error Propagation with try|const val = try riskyFunction();|propagate error to caller if error; unwrap payload if success; one keyword|Zig
ID14|Defer for Cleanup|defer allocator.free(buf);|deterministic cleanup at scope exit; replaces RAII pattern|Zig
ID15|Comptime Generics|fn List(comptime T: type) type { return struct { items: []T }; }|generic types via compile-time type parameters; no runtime cost|Zig
ID16|Exhaustive Switch|switch (tag) { .a => {}, .b => {} }|compiler error on missing case; no default needed if exhaustive|Zig
ID17|Sentinel Slices|[:0]const u8 for null-terminated strings|C interop; length-tracked + sentinel for C APIs|Zig
ID18|Test-Adjacent Code|test "description" { ... } in same file as implementation|tests co-located with code; run via zig test; stripped from production builds|Zig
ID19|String Formatting via fmt|std.fmt.allocPrint(allocator, "x={d}", .{x})|type-safe format strings; comptime format validation|Zig
ID20|Tagged Union Dispatch|switch (val) { .field => |payload| { ... } }|safe access to union payload; compiler-enforced exhaustiveness|Zig
ID21|Guard Clause|if (ptr == NULL) return ERROR;|early return on invalid input; reduces nesting|C
ID22|Static Assert (C)|_Static_assert(sizeof(int)==4, "need 32-bit int");|compile-time invariant checking; C11+|C
ID23|slots|\_\_slots\_\_ = ('x', 'y') in class body|reduce per-instance memory; prevent arbitrary attribute creation|Python
ID24|Walrus Operator|if (n := len(data)) > 10:|assignment expression; avoid redundant computation in conditions (3.8+)|Python

# distinctions(id|side_a|side_b|key_asymmetry)
DI1|Compiled|Interpreted|compiled: source → machine code before execution; interpreted: source → bytecode/AST executed by VM at runtime
DI2|Static Typing|Dynamic Typing|static: types checked at compile time, errors before execution; dynamic: types checked at runtime, more flexible but late errors
DI3|Manual Memory|Garbage Collection|manual: programmer controls allocation/deallocation (C); GC: runtime reclaims unreachable memory (Python)
DI4|Value Semantics|Reference Semantics|value: variable holds data directly, copy duplicates data (C structs, Zig); reference: variable holds pointer to shared object (Python objects)
DI5|Stack Allocation|Heap Allocation|stack: fast, automatic, scoped lifetime, fixed size; heap: flexible size, manual or GC lifetime, slower allocation
DI6|Null Safety|Nullable by Default|null-safe: compiler forces explicit handling of absence (?T in Zig); nullable: any pointer may be null, no compiler enforcement (C)
DI7|Error as Value|Error as Exception|error-as-value: errors are return types, checked at call site (C return codes, Zig error unions); exception: errors unwind stack, caught by handler (Python)
DI8|Compile-Time Execution|Runtime Execution|comptime: evaluated during compilation, zero runtime cost, must be deterministic (Zig comptime); runtime: evaluated during program execution, full flexibility
DI9|Fat Pointer|Thin Pointer|fat: pointer + metadata (length, vtable) (Zig slices, Python references); thin: raw address only (C pointers)
DI10|Defined Behavior|Undefined Behavior|defined: spec mandates exact outcome; undefined: spec imposes no requirements, compiler may assume it never happens (C UB)
DI11|Inclusive Allocator|Hidden Allocator|inclusive: allocation strategy explicit in API (Zig); hidden: runtime manages allocation invisibly (Python) or global malloc (C)
DI12|Structural Typing|Nominal Typing|structural: compatibility by shape/interface (Python Protocols, Zig comptime); nominal: compatibility by declared name/inheritance
DI13|Safe Mode|Unsafe Mode|safe: bounds checks, null checks, UB detection at runtime (Zig ReleaseSafe); unsafe: checks removed for performance (Zig ReleaseFast, C always)
DI14|Zero-Initialized|Undefined-Initialized|zero: memory set to 0 on allocation (calloc, Zig std.mem.zeroes); undefined: memory contains arbitrary bits (Zig undefined, C uninitialized locals)
DI15|Bound Check|No Bound Check|bound-checked: array/slice access validated at runtime (Zig safe, Python); unchecked: out-of-bounds is UB (C)

# relationships(from|rel|to)
# Type system relationships
TS1|characterizes|TY1,TY2,TY3,TY4,TY5,TY6,TY7,TY8,TY9,TY10,TY11,TY12,TY13,TY65,TY66,TY67
TS2|characterizes|TY24,TY25,TY26,TY27,TY28,TY29,TY30,TY31,TY32,TY33,TY34,TY35,TY36
TS3|characterizes|TY37,TY38,TY39,TY40,TY41,TY42,TY43,TY44,TY45,TY46,TY47,TY48,TY49,TY50,TY51,TY52,TY53,TY54,TY55,TY56,TY57,TY58,TY59,TY60,TY61,TY62,TY63,TY64,TY68,TY69,TY70,TY71

# Memory model language bindings
MM1|part_of|TS1
MM2|part_of|TS1
MM3|part_of|TS1
MM4|part_of|TS2
MM5|part_of|TS2
MM6|part_of|TS2
MM7|part_of|TS3
MM8|part_of|TS3
MM9|specializes|MM7
MM10|specializes|MM7
MM11|specializes|MM7
MM12|specializes|MM7

# Error handling language bindings
EH1|part_of|TS1
EH2|part_of|TS1
EH3|part_of|TS1
EH4|part_of|TS1
EH5|part_of|TS2
EH6|part_of|TS3
EH7|part_of|TS3
EH8|part_of|TS3
EH9|part_of|TS3
EH10|part_of|TS3
EH11|requires|EH6

# Control flow cross-language
CF1|equivalent_to|CF2
CF4|equivalent_to|CF5,CF6
CF8|equivalent_to|CF9,CF10
CF15|equivalent_to|CF16,CF17
CF18|specializes|CF19
CF19|equivalent_to|ID1
CF16|requires|TY63
CF17|requires|TY63
CF28|requires|TY62

# Data structure relationships
DS2|extends|DS1
DS6|equivalent_to|DS2
DS17|equivalent_to|DS2,DS6
DS8|equivalent_to|DS18,DS19
DS9|equivalent_to|DS18
DS15|equivalent_to|DS1
DS16|derived_from|DS15
DS21|extends|TY70
DS22|specializes|DS17

# Concept dependencies
CO28|requires|CO4,CO5
CO29|requires|CO4
CO30|requires|CO22
CO31|requires|CO4
CO32|requires|CO4,CO7
CO33|requires|CO32
CO37|enables|CO55,CO62,CO15
CO38|enables|MM7,MM9,MM10,MM11,MM12
CO39|implements|EH6
CO40|implements|EH8
CO41|enables|ID17
CO44|implements|CO46
CO47|part_of|TS1
CO48|implements|MM4
CO49|implements|MM5
CO52|prevents|CO61
CO53|enables|CO61
CO56|enables|CO34
CO57|specializes|CO29
CO58|enables|CF21

# Paradigm relationships
PA1|generalizes|PA2
PA2|implemented_by|TS1,TS2,TS3
PA3|implemented_by|TS2
PA4|requires|CO28
PA5|implemented_by|CO37,CO46,CO56
PA6|implemented_by|CO31,CO33,CO37,CO46
PA7|implemented_by|DS22
PA8|generalizes|PA1

# Idiom relationships
ID1|prevents|CO68,CO69
ID2|enables|CO26
ID3|enables|PA4
ID4|requires|TY66
ID7|anti_pattern_of|CO65
ID8|requires|EH5
ID10|requires|CO58
ID12|requires|CO38
ID13|requires|CO39
ID14|equivalent_to|CF19
ID15|requires|CO37
ID16|requires|TY68,TY70
ID18|requires|CO45
ID20|requires|DS21

# Anti-pattern relationships
CO63|anti_pattern_of|CO16
CO64|anti_pattern_of|CO5
CO65|anti_pattern_of|CO54
CO66|anti_pattern_of|CF23
CO67|anti_pattern_of|DS1,DS16
CO68|anti_pattern_of|MM2,MM7
CO69|anti_pattern_of|MM2
CO70|anti_pattern_of|CO47
CO71|anti_pattern_of|PA9
CO72|anti_pattern_of|CO4
CO73|anti_pattern_of|EH5

# Toolchain relationships
TC1|implements|CO15
TC2|implements|CO15
TC3|implements|CO15
TC4|implements|CO15
TC5|extends|TC4
TC6|manages|CO25
TC7|isolates|CO25
TC8|implements|CO15
TC9|implements|CO15
TC10|requires|CO45
TC11|manages|CO25
TC12|orchestrates|TC1,TC2,TC3
TC13|generates|TC12
TC14|inspects|MM1,MM2,MM3
TC16|validates|MM2
TC17|validates|MM2
TC19|validates|TS2

# Distinction mappings
DI1|distinguishes|TC1,TC4
DI2|distinguishes|TS1,TS2
DI3|distinguishes|MM2,MM4
DI4|distinguishes|TY66,TY31
DI5|distinguishes|MM1,MM2
DI6|distinguishes|TY62,TY13
DI7|distinguishes|EH6,EH5
DI8|distinguishes|CO37,CO15
DI9|distinguishes|TY58,TY60
DI10|distinguishes|CO16
DI11|distinguishes|MM7,MM2
DI12|distinguishes|CO34,PA3
DI13|distinguishes|EH14,EH9
DI14|distinguishes|CO54,CO16
DI15|distinguishes|TY58,DS1

# decode_legend
# id_prefixes: CO=concept, TS=type_system, TY=type, MM=memory_model, CF=control_flow, DS=data_structure, PA=paradigm, EH=error_handling, TC=toolchain, ID=idiom, DI=distinction
# rel_types: characterizes|part_of|specializes|generalizes|equivalent_to|extends|derived_from|requires|enables|implements|implemented_by|prevents|anti_pattern_of|manages|isolates|orchestrates|generates|inspects|validates|distinguishes
# language_values: C|Python|Zig|all
# notation: fk references use raw ID; comma-separated targets expand to individual Prolog rules
# anti_patterns: merged into concepts table with category=anti_pattern; linked via anti_pattern_of relationships
# confidence: synthetic domain knowledge — not extracted from a single source document

# relation_mapping(doc_rel|canonical_rel|notes)
characterizes|characterizes|no canon match — see below
part_of|part_of|exact match
specializes|specializes|exact match
equivalent_to|equivalent_to|exact match
extends|extends|exact match
derived_from|derived_from|exact match
requires|requires|exact match
enables|enables|exact match
implements|implements|exact match
implemented_by|implements|inverse query direction
prevents|prevents|exact match
anti_pattern_of|anti_pattern_of|exact match
manages|manages|exact match
isolates|isolates|exact match
orchestrates|orchestrates|exact match
generates|generates|exact match
inspects|inspects|exact match
validates|validates|exact match
distinguishes|distinguishes|exact match
generalizes|generalizes|exact match

