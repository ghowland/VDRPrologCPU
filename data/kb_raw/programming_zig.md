# ZIG 0.15.1: LANGUAGE SPECIFICATION AND RUNTIME — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: domains → type_system → primitive_types → aggregate_types → pointer_types → optional_error → operators → control_flow → functions → comptime → memory → allocators → slices_arrays → strings → structs → enums → unions → error_handling → async → builtin_functions → safety → testing → build_system → c_interop → concepts → antipatterns → relationships → section_index → decode_legend

# domains(id|name|definition)
DM1|type system|static, strong, structural; types are first-class comptime values; no implicit coercions except safe widenings; no type erasure; generic programming via comptime parameters (not templates, not generics syntax); every value has exactly one type known at compile time; runtime types available via @TypeOf and @typeInfo
DM2|memory model|manual memory management; no garbage collector; no runtime allocator by default; allocator passed explicitly as parameter; stack allocation by default; heap via allocator interface; MMIO and volatile access for embedded; extern memory layout control; packed structs for bit-level layout
DM3|comptime|compile-time evaluation: any expression can be evaluated at compile time if all inputs are comptime-known; comptime functions, comptime parameters, comptime blocks; enables generic programming, code generation, and static assertions without separate macro language or preprocessor
DM4|safety|debug builds: safety checks enabled (undefined behavior detected at runtime: out-of-bounds, integer overflow, null pointer dereference, use-after-free via stack, alignment); ReleaseSafe: optimized + safety; ReleaseFast: no safety checks (maximum performance); ReleaseSmall: optimize for size
DM5|error handling|errors are values (not exceptions, not return codes): error union type (E!T); errors must be handled explicitly (compile error if ignored); errdefer for cleanup on error path; error sets are types; try operator unwraps or returns error; catch provides fallback
DM6|build system|build.zig is Zig code (not a separate DSL); cross-compilation built-in; targets any of ~80+ architectures; links with C libraries seamlessly; incremental compilation; caching; parallel compilation
DM7|C interop|@cImport reads C headers at compile time; translates C types to Zig types; can call C functions directly; can export Zig functions with C ABI (export keyword); links with C object files and libraries; Zig ships with musl libc and glibc headers for cross-compilation

# type_system(id|name|type|definition|size|alignment|comptime_known|notes)
TS1|type|metatype|type of all types; only valid at comptime; a value of type `type` represents any Zig type|0 (no runtime representation)|n/a|yes (always)|fn generic(comptime T: type) T { ... } — T is a comptime type parameter; @TypeOf(expr) returns type; @typeInfo(T) returns comptime struct describing T
TS2|comptime_int|numeric|arbitrary-precision integer available only at comptime; result of integer literal without explicit type; coerces to any integer type that can represent the value|0 (no runtime representation)|n/a|yes (always)|const x = 42; — x is comptime_int; coerces to i32, u8, etc. when assigned to runtime variable of specific type; allows compile-time arithmetic without overflow
TS3|comptime_float|numeric|arbitrary-precision float at comptime; result of float literal without explicit type|0|n/a|yes|const x = 3.14; — x is comptime_float; coerces to f32 or f64 when assigned to runtime variable
TS4|void|unit|zero-sized type; exactly one value: {}; used for functions that return nothing meaningful; used as value type in hash maps to create sets|0|1|yes|fn doSomething() void { ... }; field of void type in struct occupies 0 bytes; pointer to void is valid (but pointee is zero-sized); useful for type erasure: *anyopaque
TS5|noreturn|bottom|type of expressions that never produce a value: unreachable, while(true){} without break, functions that always call @panic or exit; coerces to any type|0|n/a|yes|fn abort() noreturn { @panic("fatal"); }; noreturn coerces to any type: const x: i32 = if (cond) value else unreachable; — unreachable is noreturn, coerces to i32
TS6|anyopaque|opaque pointer target|opaque type for type-erased pointers; *anyopaque is equivalent to C void*; must be cast back to concrete pointer type before use|unknown (opaque)|unknown|no|used for: C interop (void*), type-erased interfaces (vtable patterns), passing context through callbacks; @ptrCast to convert; alignment information carried by pointer type, not anyopaque
TS7|bool|boolean|true or false; 1 bit logical, stored as u8 (1 byte) unless packed|1 byte (8 bits) when standalone; 1 bit in packed struct|1|can be|if (b) ...; while (b) ...; and, or, not operators; as u1 integer in packed struct
TS8|undefined|sentinel|marker indicating uninitialized memory; assigning to variable: var x: i32 = undefined; reading undefined is safety-checked UB in debug/ReleaseSafe (detected at runtime); in ReleaseFast: true UB|same as target type|same as target type|no|purpose: skip initialization cost when you will overwrite before read; debug mode: fills with 0xAA pattern; any use before assignment in debug mode → safety panic; enables: stack allocation without zero-initialization (performance critical)

# primitive_types(id|name|type|size_bits|range_or_values|literal_syntax|notes)
PT1|i8, i16, i32, i64, i128|signed integer|8, 16, 32, 64, 128|−2^(n−1) to 2^(n−1)−1|42, −7, 0xFF, 0o77, 0b1010, 1_000_000|overflow is safety-checked UB in debug/ReleaseSafe → panic; wrapping arithmetic: +%, -%, *% (defined wrapping); saturating: +\|, -\|, *\|; Zig has arbitrary-width integers: i7, u3, i1, u49 all valid (any bit width 0–65535)
PT2|u8, u16, u32, u64, u128|unsigned integer|8, 16, 32, 64, 128|0 to 2^n − 1|same as signed; u8 is also the element type of []const u8 (byte strings)|u8 is the most common small type; []const u8 is the string type; usize is pointer-sized unsigned (equivalent to C size_t)
PT3|usize, isize|pointer-sized integer|platform-dependent: 32 or 64|full range of pointer-width integer|same as other integers|usize: index type for slices and arrays; isize: signed pointer difference; size matches target pointer width; always use usize for indexing (compile error if using i32 to index)
PT4|f16, f32, f64, f128|floating point|16, 32, 64, 128|IEEE 754 semantics; f32: ~7 decimal digits; f64: ~15 decimal digits|3.14, 1.0e10, 0x1.0p10 (hex float), inf, -inf, nan|f80: x86 extended precision also available; float operations can be performed at comptime with arbitrary precision; @floatCast for conversion; no implicit float widening in expressions
PT5|c_int, c_uint, c_long, c_ulong, c_longlong, c_char, c_short, etc.|C-compatible integers|platform-dependent (matches C ABI)|matches C type on target platform|same as integer literals|used for C interop; ensures correct size on each platform; c_int may be i16 or i32 depending on target; always use for calling C functions; @intCast to convert to/from Zig integer types

# aggregate_types(id|name|type|definition|memory_layout|size|notes)
AG1|array|fixed-size homogeneous sequence|[N]T: N elements of type T; length known at comptime; bounds-checked at runtime (debug)|contiguous; elements at offsets 0, @sizeOf(T), 2*@sizeOf(T), ...; no padding between elements (unless T has alignment padding)|N * @sizeOf(T)|const arr = [5]i32{ 1, 2, 3, 4, 5 }; const arr2 = [_]i32{ 1, 2, 3 }; — [_] infers length; array is value type (passed by value: copied unless pointer); arr[i] is bounds-checked in safe modes; arr.len is comptime-known
AG2|sentinel-terminated array|array with sentinel|[N:S]T: N elements of type T followed by sentinel value S; total N+1 elements in memory|same as array plus one extra element (the sentinel)|( N + 1 ) * @sizeOf(T)|[*:0]u8 is C-style null-terminated string; const s: [:0]const u8 = "hello"; — string literals are null-terminated arrays; sentinel is accessible at arr[arr.len]; used for C interop (C expects null-terminated strings)
AG3|struct|product type (record)|struct { field: type, ... }; nominal (each struct definition creates a unique type); fields have defined order (declaration order by default; extern: C ABI order; packed: bit-packed)|extern struct: C-compatible layout (may have padding for alignment); packed struct: bit-packed (no padding; fields can be sub-byte; backed by integer); default struct: Zig-optimized layout (compiler may reorder fields for better alignment/size)|sum of field sizes + padding (extern); exact bit sum (packed); compiler-determined (default)|const Point = struct { x: f32, y: f32 }; const p = Point{ .x = 1.0, .y = 2.0 }; methods: functions declared inside struct with self parameter; struct can have comptime fields, default values, declarations
AG4|tuple|anonymous struct with numbered fields|struct { comptime field0: type, field1: type, ... } or .{ val1, val2 }|same as struct|same as struct|const t = .{ 42, "hello", true }; t[0] == 42; t.@"0" == 42; tuples used for: multi-return, comptime type lists, inline-for iteration; .{} is empty tuple (zero-sized)
AG5|packed struct|bit-level layout|packed struct { a: u3, b: u5, c: bool, ... }|bit-packed: fields occupy exactly their bit width; backed by underlying integer type; no padding|sum of field bit widths (rounded up to alignment of backing integer)|packed struct { a: u3, b: u5 } — total 8 bits = u8 backing; taking address of non-byte-aligned field: not allowed (returns a special packed pointer); used for: hardware registers, binary protocols, bit-fields; @bitCast between packed struct and backing integer
AG6|extern struct|C-ABI-compatible layout|extern struct { a: c_int, b: c_long, ... }|C struct layout rules: natural alignment; padding inserted between fields for alignment; size rounded to alignment of most-aligned field|matches C sizeof/alignof on target platform|used for: C interop (passing structs to/from C functions); @cImport translates C structs to extern struct; field order matches declaration; explicit padding fields may be needed for matching specific C layouts

# pointer_types(id|name|type|definition|nullability|arithmetic|notes)
PR1|*T (single-item pointer)|pointer to one T|points to exactly one value of type T; dereferenced with ptr.*|non-null (guaranteed by type system; null is compile error for *T)|no arithmetic (single item)|const ptr: *i32 = &x; ptr.* = 42; method call syntax: if T is struct with fn method(self: *T), then ptr.method(); coercion: *T coerces to *const T; *[N]T coerces to [*]T and []T
PR2|[*]T (many-item pointer)|pointer to unknown number of T|points to first element of a sequence of T with unknown length; C-style pointer|non-null|arithmetic allowed: ptr + 1, ptr − 1 (advances by @sizeOf(T))|result of @ptrCast or C interop; convert to slice for safe access: ptr[0..n] creates []T with bounds checking; [*]T has no length information (like C pointer: dangerous without external length info)
PR3|[*:S]T (sentinel-terminated many-pointer)|many-pointer with sentinel|points to sequence terminated by sentinel value S|non-null|arithmetic allowed|[*:0]u8 is C null-terminated string pointer; can convert to slice by finding sentinel: std.mem.sliceTo(ptr, 0)
PR4|?*T (optional pointer)|nullable pointer|either a valid *T or null; null is a valid value|nullable (null is valid)|no|?*T equivalent to C pointer (nullable); optional pointer is guaranteed to be pointer-sized (null = 0; same representation as C: no wrapping overhead); if (opt_ptr) \|ptr\| { ... } unwraps; orelse provides default
PR5|*align(A) T|aligned pointer|pointer with explicit alignment guarantee; alignment A must be power of 2|non-null|depends on underlying pointer kind|used for: SIMD (align(16) or align(32)), hardware registers, performance optimization; @alignCast to assert alignment at runtime; alignment checked in safe modes
PR6|*volatile T|volatile pointer|read/write not optimized away by compiler; order preserved; used for memory-mapped I/O|non-null|depends on underlying pointer kind|const reg = @as(*volatile u32, @ptrFromInt(0x4000_0000)); reg.* = 1; — writes to hardware register; volatile prevents: reordering, elision, combining; not atomic (use @atomicLoad/@atomicStore for atomics)
PR7|*allowzero T|zero-address pointer|allows pointer value of address 0 (normally illegal)|non-null semantically (but address can be 0)|depends on underlying kind|used for: embedded systems where address 0 is valid memory-mapped register; kernel code; not the same as optional (still non-null in type system: address 0 is valid, not null)

# optional_error(id|name|type|definition|unwrap|null_error_value|notes)
OE1|?T (optional)|sum type|either a value of type T or null; used when value may be absent|if (opt) \|val\| { use val } else { handle null }; orelse: const v = opt orelse default; .? unwrap: opt.? panics if null in safe mode|null|?T is one-word if T is pointer type (null = 0, no overhead); otherwise: T + 1 byte flag; optionals nest: ??T is valid (can be null, or ?T which itself can be null); @as(?i32, null) explicitly creates null optional; optional pointers have zero overhead (null pointer representation)
OE2|E!T (error union)|sum type|either a value of type T or an error from error set E; used for fallible operations|try: const val = try fallible(); — returns error if error, unwraps if ok; catch: const val = fallible() catch \|err\| { handle err }; catch \|err\| return err (equivalent to try)|error value from set E|error union is i32-sized tag + T (or just T if T is pointer: error stored in unused bits); error set: enum of error codes; anyerror is the global error set (all errors); functions returning !T use inferred error set; errdefer executes only on error return path (cleanup)
OE3|error set|enum-like|set of named error values; declared explicitly or inferred from function body|not unwrapped (it's the error half)|error values are u16 globally unique across compilation|error { OutOfMemory, InvalidArgument, Overflow } creates an error set; anyerror is union of all error sets in compilation; error set values are unique integers (global deduplication); error sets are types: can be used as function parameters and struct fields
OE4|E!?T or ?(E!T)|combined|error union of optional, or optional error union; different semantics: E!?T: error or (value or null); ?(E!T): null or (error or value)|try unwraps error; orelse/if unwraps optional; order determines what is handled first|error or null depending on nesting|E!?T is idiomatic for functions that can fail (error) or have no result (null); e.g., iterator: fn next() !?Item — returns error on failure, null on end-of-iteration, Item on success

# operators(id|name|symbol|type|operand_types|result|notes)
OP1|addition|+|arithmetic|integers, floats|same type as operands (no implicit widening)|integer overflow: safety-checked UB in debug/ReleaseSafe → panic at runtime; compile error if comptime overflow detected; wrapping: +% (wraps on overflow, defined behavior); saturating: +\| (clamps to max/min)
OP2|subtraction|−|arithmetic|integers, floats|same type|same overflow rules as addition; wrapping: -%; saturating: -\|
OP3|multiplication|*|arithmetic|integers, floats|same type|wrapping: *%; saturating: *\|; also pointer dereference: ptr.* (not *ptr)
OP4|division|/|arithmetic|integers: truncating toward zero; floats: IEEE 754|same type|integer division by zero: safety-checked UB in debug → panic; @divFloor: floor division; @divTrunc: truncating division; @divExact: exact (panic if remainder); @rem: remainder (sign of dividend); @mod: modulus (sign of divisor)
OP5|bit shift left|<<|bitwise|integers|same type as left operand; right operand: comptime-known u6 (or log2 bit width)|shift amount must be comptime-known OR result of @intCast from smaller type; shifting by >= bit width: compile error if comptime, safety-checked UB at runtime
OP6|bit shift right|>>|bitwise|integers|same type|arithmetic shift for signed (sign-extended); logical shift for unsigned (zero-extended); same shift amount constraints as <<
OP7|bitwise and|&|bitwise|integers|same type|also used for pointer-related: ptr & mask (not typical; use @intFromPtr then bitwise)
OP8|bitwise or|\||bitwise|integers|same type|—
OP9|bitwise xor|^|bitwise|integers|same type|—
OP10|equality|==, !=|comparison|same type; optional (compares to null); error union|bool|structural equality for most types; pointer equality for pointers (address comparison; does not dereference); can compare optional to null: if (x == null); std.mem.eql for slice content equality (== on slices compares pointer and length, NOT content)
OP11|ordering|<, >, <=, >=|comparison|integers, floats, enum (by tag value)|bool|no operator overloading (Zig principle: no hidden control flow, no hidden allocations); for custom comparison: write explicit function
OP12|boolean|and, or, not|logical|bool|bool|and and or are short-circuit (second operand not evaluated if result determined by first); not inverts; these are keywords, not symbols (&& and \|\| do not exist)
OP13|concatenation|++|array/slice concat|comptime-known arrays/slices|array of combined length|comptime only: const ab = a ++ b; concatenates two arrays or slices at compile time; not available at runtime (use std.mem.concat or manual copy); also works for string literals: "hello" ++ " " ++ "world"
OP14|repetition|**|array repeat|comptime-known array, comptime count|array of length * count|comptime only: const zeros = [1]u8{0} ** 100; creates [100]u8 of all zeros; "ha" ** 3 = "hahaha"
OP15|orelse|orelse|optional unwrap with default|?T on left; T on right|T|const val = optional orelse default_value; short-circuit: default not evaluated if optional has value; also chains: a orelse b orelse c; right operand can be noreturn: opt orelse unreachable, opt orelse return error.Missing
OP16|try|try|error union unwrap or return|E!T|T (if success) or returns E from enclosing function|const val = try fallible_call(); equivalent to: fallible_call() catch \|err\| return err; enclosing function must return compatible error union; most common error handling pattern in Zig
OP17|catch|catch|error union unwrap with error handler|E!T on left; block or expression on right receives error|T|const val = expr catch \|err\| { handle(err); return err; }; const val = expr catch default; catch without capture: expr catch { fallback }; right side can be noreturn: expr catch unreachable

# control_flow(id|name|syntax|behavior|notes)
CF1|if|if (cond) \|capture\| { ... } else \|capture\| { ... }|conditional; capture syntax for optionals and error unions: if (opt) \|val\| { use val } else { null case }; if (err_union) \|val\| { ok } else \|err\| { error }|if is an expression (returns value): const x = if (cond) a else b; comptime if: if (comptime condition) ... — evaluated at compile time; dead branch not compiled (enables conditional compilation without preprocessor)
CF2|while|while (cond) : (continue_expr) { ... } else { ... }|loop; continue expression evaluated on each continue and normal loop end (useful for counter increment); else block executes on normal completion (not on break); optional unwrap: while (opt_iter.next()) \|item\| { ... }|while with optional: while (it.next()) \|val\| { ... } else { ... } — loops while not null; while with error union: while (it.next()) \|val\| { ... } else \|err\| { ... }; break can return value: const x = while (cond) { break value; } else default;
CF3|for|for (slices_or_ranges) \|captures\| { ... } else { ... }|iterates over slices, arrays, and ranges (comptime or runtime); multi-object iteration: for (a, b) \|x, y\| { ... } — iterates a and b in lockstep; index capture: for (slice, 0..) \|item, idx\| { ... }|for is the primary iteration construct; always bounded (safe); no C-style for(init;cond;incr); ranges: 0..n (exclusive end), 0..n+1 or use usize counter; for over tuples at comptime: inline for
CF4|switch|switch (value) { pattern => expr, ... }|exhaustive pattern match on integers, enums, bools; must cover all cases or have else branch; switch is an expression (returns value)|captures: .tag => \|*val\| { ... } for tagged unions; ranges: 'a'...'z' => ...; multiple values: 1, 2, 3 => ...; else => ...; comptime switch: switch on types, comptime values; no fallthrough (each arm is independent)
CF5|break|break :label value|exits loop or labeled block; can return value from loop: const result = while (cond) { break value; };|labeled blocks: const x = blk: { break :blk 42; }; break from nested loops: use labels
CF6|continue|continue :label|skips to next iteration of loop; can target labeled outer loop|continue expression in while evaluated on continue: while (cond) : (i += 1) { continue; } — i still incremented
CF7|unreachable|unreachable|asserts that code path is never reached; in debug: panics; in ReleaseFast: undefined behavior (compiler optimization hint)|use for: switch default when all cases handled but type system can't prove it; after noreturn function calls; in array/slice indexing that is provably in-bounds but compiler can't verify; in unsafe pointer arithmetic; unreachable is noreturn type
CF8|defer|defer expr;|executes expr at scope exit (regardless of how scope exits: normal, return, break, error); LIFO order (last defer executes first)|multiple defers in scope: execute in reverse order; common use: defer allocator.free(ptr); defer file.close(); unlike C++ RAII: explicit; unlike Go defer: executes at scope exit, not function exit
CF9|errdefer|errdefer \|err\| expr;|like defer but only executes if scope exits due to error being returned; capture error value with \|err\||critical for error-handling cleanup: allocate resource → errdefer free resource → do work that might fail; if work succeeds, errdefer doesn't run; if work fails, errdefer frees resource before error propagates; captures error: errdefer \|err\| log.err("failed: {}", .{err});
CF10|inline for / inline while|inline for/while|loop unrolled at comptime; body instantiated once per iteration; captures are comptime-known|inline for (.{i32, f32, u8}) \|T\| { test_type(T); } — generates 3 copies of body, one for each type; inline while for comptime-known bounds; used for: type-generic programming, SIMD, lookup tables, code generation

# functions(id|name|type|definition|calling_convention|notes)
FN1|function declaration|fn|fn name(params) return_type { body }|default: Zig calling convention (may differ from C); callconv(.c): C calling convention; callconv(.@"interrupt"): platform interrupt ABI|functions are values of type fn(...) return_type; can be stored in variables, passed as parameters, returned from functions; function pointers: *const fn(i32) i32
FN2|method syntax|fn|fn methodName(self: *Self, ...) ret { ... }; called as value.methodName(args)|same as FN1; self is explicit (not implicit like Python/Rust/etc.); Self = @This() gets enclosing struct type|methods are just functions declared inside struct/union/enum namespace; obj.method(args) desugars to Type.method(&obj, args) or Type.method(obj, args) depending on self parameter type (*Self vs Self)
FN3|comptime parameter|fn|fn generic(comptime T: type, n: T) T { ... }|Zig ABI (comptime params erased at codegen)|comptime parameters must be comptime-known at call site; function body is instantiated (monomorphized) for each unique combination of comptime arguments; this is Zig's generics mechanism; no type erasure: full type information available in body
FN4|inline function|fn|inline fn or noinline fn; or pub inline fn|forced inline / prevented inline|inline: function body inlined at every call site (useful for: comptime branching, performance-critical paths, SIMD); noinline: never inlined (useful for: debugging, code size, preventing optimization); default: compiler decides
FN5|extern function|fn|extern "c" fn name(args) ret; or extern fn name(args) ret;|C calling convention (extern "c"); or other ABI|declares function implemented elsewhere (C library, assembly); linked at link time; extern functions cannot be generic (no comptime params); used with @cImport or manual declaration
FN6|export function|fn|export fn name(args) callconv(.c) ret { ... }|C calling convention required for export|makes Zig function callable from C or other languages; appears in symbol table with C-compatible name and ABI; used for: creating shared libraries (.so/.dll), FFI, kernel modules, WASM exports
FN7|function pointer|type|*const fn(args) ret or *fn(args) ret|stored calling convention|function pointers can point to any function with matching signature; *const fn: immutable (most common); *fn: mutable (rarely used); can be null if optional: ?*const fn(...) ret; calling function pointer: ptr(args)
FN8|anytype parameter|fn|fn f(x: anytype) @TypeOf(x) { ... }|Zig ABI|anytype: type inferred from argument at call site; function body must be valid for all types actually passed; more constrained than true dynamic typing: still monomorphized and type-checked per instantiation; similar to C++ auto or Rust impl Trait in function position; use @TypeOf(x) to refer to the inferred type

# comptime(id|name|type|definition|evaluation|notes)
CT1|comptime variable|comptime|comptime var x: i32 = 0; or comptime const x = expr;|evaluated at compile time; not available at runtime; no runtime storage|comptime var: mutable at comptime only (can be modified during comptime evaluation, e.g., in inline for); comptime const: immutable comptime value; all values exist only during compilation
CT2|comptime block|comptime|comptime { ... }|entire block evaluated at compile time; can contain loops, conditionals, function calls|used for: static assertions (comptime { assert(condition); }), compile-time computation, type validation; if block has side effects visible at runtime → compile error
CT3|comptime function execution|comptime|any function called with all-comptime arguments is evaluated at comptime|function body executes at compile time; result is a comptime value; recursion, loops, conditionals all work at comptime|comptime function execution has limits: no calling extern functions; no inline assembly; no accessing runtime memory; stack depth limit; infinite loop detection (compiler detects and errors)
CT4|comptime branching|conditional compilation|if (comptime cond) { ... } else { ... }|dead branch not analyzed or compiled; no code generated for false branch|replaces #ifdef from C; comptime if on @import("builtin").os.tag == .linux for OS-specific code; comptime switch on type for generic specialization; unreachable branches can contain type errors (not compiled)
CT5|type reflection|comptime|@typeInfo(T) returns std.builtin.Type; @TypeOf(expr) returns type|fully available at comptime; @typeInfo returns tagged union describing every aspect of any type|@typeInfo(.@"struct") returns field names, types, defaults; @typeInfo(.@"enum") returns field names, values; enables: serialization, format printing, JSON parsing, generic containers, compile-time interface verification; std.meta provides helper functions for reflection
CT6|comptime allocation|comptime|comptime values can be arrays, slices, structs; allocated during compilation|no heap allocation at comptime (all on compiler's internal allocator); results embedded in binary as static data|comptime-built lookup tables, string processing, parsing: all done at compile time, result baked into binary; comptime strings are []const u8 slices that become static data in the binary

# memory(id|name|type|definition|lifetime|safety|notes)
ME1|stack allocation|automatic|local variables allocated on stack frame; freed automatically when scope exits|scope-bounded (function/block lifetime)|safe (lifetime managed by compiler; cannot outlive scope; returning pointer to stack local: compile error in safe patterns)|default allocation method; no allocator needed; fixed size (known at compile time); stack overflow: detected on some platforms (guard page); typical stack size: 1–8 MB
ME2|heap allocation|dynamic|allocated via allocator interface; freed explicitly by calling allocator.free()|manual (programmer controls lifetime); must free to avoid leak|use-after-free: detected in debug builds (GeneralPurposeAllocator detects); double-free: detected; leak detection: GeneralPurposeAllocator reports leaks in deinit()|no implicit heap allocation anywhere in language or std (every allocation is explicit and visible); allocator passed as parameter: fn create(allocator: std.mem.Allocator) !*Thing
ME3|static/global|static|global variables: var or const at file scope; persist for program lifetime; initialized before main|program lifetime|thread safety: globals are shared; concurrent access requires synchronization (std.Thread.Mutex, @atomicLoad, @atomicStore)|const at file scope: comptime-evaluated, immutable, safe; var at file scope: mutable, requires careful synchronization; threadlocal var: per-thread storage; export var: visible to C linker
ME4|comptime memory|compile-time|values computed at compile time exist only during compilation; results embedded as constants in binary|compile time only|always safe (compiler-managed)|comptime strings, arrays, structs: embedded in .rodata or .data section; no runtime cost for comptime computation (just binary size)
ME5|extern memory|foreign|memory managed by external code (C library, OS, hardware)|external (not managed by Zig runtime)|no safety guarantees (Zig safety checks don't apply to foreign memory)|@ptrFromInt for MMIO; @cImport types for C structures; must follow external code's ownership rules; Zig can still detect misaligned access and null dereference at pointer creation

# allocators(id|name|type|source|thread_safe|features|use_case|notes)
AL1|page_allocator|std.heap.page_allocator|OS (mmap/VirtualAlloc/sbrk)|yes|allocates whole pages (4096 bytes minimum); no metadata overhead on allocation; slow for small allocations|backing allocator for other allocators; large allocations; when simplicity matters more than efficiency; testing|returns page-aligned memory; minimum granularity: one page; @import("std").heap.page_allocator
AL2|GeneralPurposeAllocator (GPA)|std.heap.GeneralPurposeAllocator(.{})|configured backing allocator (default: page_allocator)|configurable (default: yes)|safety features: use-after-free detection, double-free detection, memory leak reporting (on deinit); configurable: stack traces on allocation, safety checks|development, testing, applications where safety > performance|var gpa = std.heap.GeneralPurposeAllocator(.{}){}; defer { const check = gpa.deinit(); if (check == .leak) @panic("leak"); } const allocator = gpa.allocator();
AL3|FixedBufferAllocator|std.heap.FixedBufferAllocator|pre-allocated buffer (stack or static)|depends on buffer source|allocates from fixed buffer; no OS calls; no fragmentation (bump allocator); fast; deterministic|embedded systems (no OS); real-time (deterministic timing); when maximum memory usage is known|var buf: [4096]u8 = undefined; var fba = std.heap.FixedBufferAllocator.init(&buf); const allocator = fba.allocator(); — allocs from buf until exhausted; free is no-op (or reclaims from top in stack fashion)
AL4|ArenaAllocator|std.heap.ArenaAllocator|configured backing allocator|same as backing|bulk free: free everything at once (reset or deinit); individual free is no-op; very fast allocation (bump pointer); no fragmentation during use|request processing (allocate during request, free all at end); compilers (allocate AST nodes, free all after compilation); games (per-frame allocation)|var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator); defer arena.deinit(); const allocator = arena.allocator(); — all allocations freed on arena.deinit(); arena.reset() frees all but retains underlying pages for reuse
AL5|c_allocator|std.heap.c_allocator|C runtime (malloc/free)|depends on C runtime (usually yes)|compatible with C libraries that expect malloc'd memory; no safety features|C interop (when C library takes ownership of memory); or when using C library that requires malloc'd buffers|only available if linking libc; @import("std").heap.c_allocator; memory freed with C free() or Zig allocator.free() (same underlying allocator)
AL6|testing.allocator|std.testing.allocator|test framework|yes|leak detection: test fails if any allocation not freed; use-after-free detection; double-free detection|all tests should use std.testing.allocator (not page_allocator or GPA) to catch leaks|automatically available in test blocks: test "name" { const allocator = std.testing.allocator; ... }; test fails with error message identifying leaked allocation including stack trace

# slices_arrays(id|name|type|definition|bounds_checking|notes)
SA1|[]T (slice)|fat pointer|pointer + length; runtime-known length; created from arrays or allocations|yes (safety-checked in debug/ReleaseSafe: index >= len → panic)|slice is a fat pointer: struct { ptr: [*]T, len: usize }; 2 words (16 bytes on 64-bit); slicing syntax: arr[start..end] (exclusive end); arr[start..] (to end); arr[0..arr.len] (full); slice of slice: s[a..b]; slice has no capacity (unlike Rust Vec or Go slice)
SA2|[]const T (const slice)|immutable fat pointer|pointer to immutable data + length; most common string type: []const u8|yes|[]const u8 is the string type; string literals are *const [N:0]u8 which coerce to []const u8; cannot modify contents through const slice; can still re-assign the slice variable itself (it's the pointee that's const, not the pointer/length)
SA3|[N]T (array)|value type|fixed-size array; N is comptime-known; entire array is a value (copied on assignment/parameter passing)|yes|arr.len is comptime-known; &arr coerces to *[N]T; &arr coerces to []T (slice of full array); arr[0..n] creates []T slice; array initialization: [N]T{ val, val, ... } or [_]T{ ... } for inferred length; [N]T{ val } ** N for fill
SA4|[*]T (many-pointer)|C-style pointer|pointer to unknown number of T; no length information|no (no length to check against)|dangerous without external length; immediately convert to slice when possible: ptr[0..known_len]; result of: @ptrCast, C interop, pointer arithmetic; avoid keeping as [*]T — convert to []T ASAP
SA5|sentinel-terminated slice|[:S]T|slice with sentinel value S after last element|yes (slice portion); sentinel accessible at s[s.len]|[:0]const u8: null-terminated string slice (has both length AND null terminator); std.mem.span(c_string_ptr) converts [*:0]u8 to [:0]u8; useful for C interop: have safe slice + C-compatible null termination

# strings(id|name|type|representation|operations|notes)
SR1|string literal|comptime|*const [N:0]u8; null-terminated array of bytes; stored in binary .rodata section|coerces to: []const u8, [*:0]const u8, [*]const u8; "hello".len == 5; "hello"[5] == 0 (sentinel)|string literals are always UTF-8 encoded; multi-line: \\\\ (line begins with \\); escape sequences: \n, \t, \\, \", \xNN (hex byte), \u{NNNN} (Unicode codepoint); raw: no escape processing in embedded literals
SR2|[]const u8|runtime string|fat pointer to byte sequence; no null terminator (unless [:0]const u8); length is runtime-known|std.mem.eql(u8, a, b) for equality; std.mem.indexOf(u8, haystack, needle); std.fmt.bufPrint for formatting; concatenation: not built-in at runtime (use std.mem.concat or allocator + copy)|Zig strings are just byte slices; no special string type; UTF-8 is convention not enforcement; std.unicode provides UTF-8 iteration: std.unicode.Utf8Iterator; comparison: std.mem.order(u8, a, b)
SR3|[:0]const u8|null-terminated string slice|slice with null terminator at s[s.len]; has both length and C compatibility|can be passed to C functions expecting null-terminated string; can be used as Zig slice (has .len)|bridges Zig and C worlds: Zig code uses .len for bounds; C code sees null terminator; std.mem.span converts [*:0]u8 to [:0]u8
SR4|std.fmt (formatting)|stdlib|std.fmt.bufPrint(&buf, "x={d}, s={s}", .{ x, s }); std.fmt.allocPrint(allocator, ...); std.debug.print("...", .{ args })|format specifiers: {d} decimal int, {s} string/bytes, {x} hex, {b} binary, {e} scientific float, {any} debug format, {} default; custom format: implement pub fn format(self, comptime fmt, options, writer) for struct|std.debug.print writes to stderr; std.io.getStdOut().writer() for stdout; format strings checked at comptime (wrong specifier or argument count: compile error)

# structs(id|name|type|definition|features|notes)
SU1|named struct|type|const Point = struct { x: f32, y: f32 };|fields, methods (fn with self), associated constants (const), declarations, default field values, comptime fields|struct is the primary composite type; methods: fn inside struct with self parameter → called with dot syntax; default values: field: type = default_value; methods can take *Self (mutable), Self (by value), or *const Self (immutable)
SU2|anonymous struct|literal|.{ .x = 1.0, .y = 2.0 }; or .{ 42, "hello" } (tuple)|anonymous struct has structural typing: coerces to compatible named struct; tuple form has indexed fields: t[0], t[1]|used for: function arguments (avoids naming intermediate type), comptime type lists, multi-return via destructuring; const result: Point = .{ .x = 1.0, .y = 2.0 }; — anonymous coerces to Point
SU3|extern struct|C-compatible|extern struct { field: c_type, ... }|C ABI layout; guaranteed field order; padding for alignment matches C compiler|used for @cImport translated types and manual C struct declarations; @offsetOf verifies field positions; @sizeOf matches C sizeof
SU4|packed struct|bit-packed|packed struct { a: u3, b: bool, c: u4 }|backed by integer type; fields are bit-contiguous; no padding; @bitCast to/from backing integer|used for: hardware registers, binary protocols, network packets, bitfields; pointers to fields of non-byte-aligned size return special packed pointer type; @bitOffsetOf gives bit offset
SU5|struct with methods|OOP-like|const List = struct { items: []i32, pub fn append(self: *List, item: i32) !void { ... } pub fn init(allocator: Allocator) List { ... } pub fn deinit(self: *List, allocator: Allocator) void { ... } };|init/deinit pattern (not constructor/destructor: explicit, no magic); methods are namespaced functions; no inheritance (use composition); no virtual dispatch (use function pointers or tagged unions)|Zig OOP: struct + methods + interfaces via function pointers or comptime duck typing; no this keyword (self is explicit parameter with explicit type); @This() returns the enclosing type; pattern: pub fn init() Self, pub fn deinit(self: *Self) void

# enums(id|name|type|definition|features|notes)
EN1|enum|nominal type|const Color = enum { red, green, blue };|tag values: auto-assigned (0, 1, 2) or explicit: enum(u8) { red = 1, green = 2 }; switch must be exhaustive (all cases or else); @enumFromInt, @intFromEnum for conversion|methods: fn inside enum (like struct methods); enums are types: can be function parameters, struct fields; namespace for constants and functions; non-exhaustive: enum(u8) { a, b, _ } — allows values not listed (for forward compatibility, C interop)
EN2|extern enum|C-compatible|const CEnum = extern enum(c_int) { a = 0, b = 1, ... };|layout matches C enum; tag type is c_int by default|used for C interop; values match C enum values; non-exhaustive by default (C enums can have unlisted values)

# unions(id|name|type|definition|features|notes)
UN1|tagged union|sum type (discriminated)|const Value = union(enum) { int: i64, float: f64, string: []const u8, none: void };|tag tracks active variant; switch on union requires exhaustive cases; access inactive variant: safety-checked UB in debug → panic; .tag field accessible; @as for construction|tagged unions are Zig's algebraic data type (ADT); most important type for modeling alternatives; switch (val) { .int => \|i\| ..., .float => \|f\| ..., .string => \|s\| ..., .none => ... }; captures are by reference with \|*ptr\|
UN2|untagged union|C-style union|const U = union { a: i32, b: f32 };|no tag; accessing wrong field is UB (not safety-checked); size = max field size; all fields at same address|used for: C interop, memory reinterpretation, specific low-level patterns; prefer tagged union unless C interop requires untagged; @ptrCast between *Union and *FieldType is defined behavior
UN3|extern union|C-ABI union|const CUnion = extern union { a: c_int, b: c_float };|C-compatible layout; no tag; same as C union|used with @cImport or manual C interop; sizeof matches C; field access same as untagged

# error_handling(id|name|type|definition|pattern|notes)
EH1|error set declaration|type|const MyError = error { OutOfMemory, InvalidArgument, Overflow };|declare once; use as return type: fn f() MyError!i32 { ... }|error values are global u16; unique across entire compilation; can merge error sets: const Combined = ErrorA \|\| ErrorB; anyerror is the set of all errors
EH2|error union return|return type|fn read(buf: []u8) !usize { ... }|! without explicit error set: inferred from function body; E!T with explicit error set: MyError!usize|inferred error sets: compiler determines possible errors from all return-error paths; explicit sets: documents API contract; anyerror!T: returns any possible error (avoid: too broad)
EH3|try|unwrap operator|const n = try reader.read(buf);|if reader.read returns error → try returns that error from current function; if ok → unwraps value; current function must return compatible error union|most common error handling pattern; chains naturally: const data = try (try file.open("path")).readAll(allocator); each try propagates errors upward
EH4|catch|fallback operator|const n = reader.read(buf) catch \|err\| { log.err("{}", .{err}); return err; };|explicit error handling; capture error value; provide alternative value or return; catch without capture: expr catch fallback_value|catch 0 or catch default: provide fallback value on error; catch \|err\| switch (err) { ... }: handle specific errors differently; catch unreachable: assert no error (panic if wrong)
EH5|errdefer|cleanup on error|errdefer allocator.free(buf);|executes ONLY when function returns an error; reverse declaration order (LIFO); captures error: errdefer \|err\| log.err("{}", .{err});|critical pattern: allocate → errdefer free → do fallible work; if work fails: errdefer runs, frees allocation, error propagates; if work succeeds: errdefer doesn't run, caller owns allocation; solves the "cleanup on error" problem without exceptions or try/finally
EH6|error return trace|debug feature|in debug builds: when error propagates through multiple try statements, Zig maintains a trace of all return points|automatic in debug/ReleaseSafe; printed on unhandled error reaching main; shows call stack of error propagation path|vastly better than errno or error codes: you see the entire path an error took through the call stack; no runtime cost in ReleaseFast/ReleaseSmall

# builtin_functions(id|name|signature|purpose|comptime|notes)
BF1|@intCast|@intCast(value) → target_type|converts between integer types; safety-checked: panics if value doesn't fit in target type|evaluable at comptime|target type inferred from result type context: const x: u8 = @intCast(big_int); if big_int > 255 → panic in safe modes; replaces @truncate for safe narrowing
BF2|@floatCast|@floatCast(value) → target_type|converts between float types|evaluable at comptime|const x: f32 = @floatCast(f64_val); narrowing: may lose precision; no panic (float narrowing is defined behavior: rounds)
BF3|@ptrCast|@ptrCast(ptr) → target_ptr_type|reinterprets pointer type; does not change address; alignment checked in safe modes|evaluable at comptime|most common pointer cast; used for: *anyopaque → *T, *align(4) T → *T, [*]u8 → [*]MyStruct; alignment violation: safety panic in debug
BF4|@intFromPtr|@intFromPtr(ptr) → usize|converts pointer to integer (address)|yes|used for: address arithmetic, MMIO register calculation, debug printing; reverse: @ptrFromInt(usize) → *T; @ptrFromInt(0) is UB unless *allowzero
BF5|@ptrFromInt|@ptrFromInt(addr) → *T|converts integer to pointer|yes|target type inferred from context; used for: MMIO, hardware registers; safety: alignment checked; address 0: requires *allowzero T
BF6|@bitCast|@bitCast(value) → target_type|reinterprets bit pattern as different type; sizes must match exactly|yes|const f: f32 = @bitCast(@as(u32, 0x3F800000)); — reinterprets u32 bits as f32 (= 1.0); zero-cost; no conversion; just reinterpretation; packed struct ↔ integer: @bitCast
BF7|@sizeOf|@sizeOf(T) → comptime usize|returns size of type T in bytes including padding|comptime only|@sizeOf(extern struct { a: u8, b: u32 }) may be 8 (with padding); @sizeOf(packed struct { a: u3, b: u5 }) is 1; @sizeOf(void) is 0; @sizeOf(bool) is 1
BF8|@alignOf|@alignOf(T) → comptime usize|returns alignment requirement of type T in bytes|comptime only|@alignOf(u32) is 4; @alignOf(u8) is 1; @alignOf(extern struct { a: u8, b: u32 }) is 4 (highest field alignment)
BF9|@typeInfo|@typeInfo(T) → std.builtin.Type|returns compile-time struct describing type: fields, declarations, layout, tag values, etc.|comptime only|enables compile-time reflection: iterate fields, check types, generate code; @typeInfo(Point).@"struct".fields returns array of field descriptors; combined with inline for: iterate all fields of any struct at comptime
BF10|@TypeOf|@TypeOf(expr) → type|returns the type of any expression|comptime only|fn f(x: anytype) @TypeOf(x) { ... } — return type matches input type; @TypeOf(42) is comptime_int; @TypeOf(@as(i32, 42)) is i32
BF11|@import|@import("module") → struct type|imports Zig module (file) or package; returns struct type whose declarations are the module's top-level declarations|comptime only|@import("std") returns std library struct; @import("builtin") returns build-time configuration; @import("file.zig") imports relative file; result is comptime struct value: const std = @import("std");
BF12|@cImport|@cImport(cImport_body) → struct type|translates C headers to Zig types at compile time|comptime only|const c = @cImport(@cInclude("stdio.h")); c.printf("hello\n"); — calls C printf; translates: types, functions, macros, constants; limitations: some C macros cannot be translated (Zig provides @cDefine for simple macros)
BF13|@as|@as(T, value) → T|explicit type coercion; used when type inference is ambiguous or to force specific type|yes|const x = @as(u32, 42); — forces comptime_int 42 to u32; @as(*anyopaque, ptr) for type erasure; @as(?i32, null) for typed null optional
BF14|@atomicLoad|@atomicLoad(ptr, ordering) → T|atomic load from memory location|no (runtime only)|orderings: .monotonic, .acquire, .seq_cst, .unordered; used for lock-free programming and inter-thread communication; no GIL in Zig: true shared memory concurrency
BF15|@atomicStore|@atomicStore(ptr, value, ordering) → void|atomic store to memory location|no|same orderings as @atomicLoad; used with @atomicLoad for lock-free patterns; std.atomic.Value provides higher-level atomic wrapper
BF16|@memcpy|@memcpy(dest, src)|copies memory from src slice to dest slice; lengths must match; must not overlap|no|replacement for C memcpy; safer: length checked (must match); no overlap (use @memcpy cannot handle overlapping; use std.mem.copyBackwards or std.mem.copyForwards for overlapping); operates on slices: @memcpy(dest[0..n], src[0..n])
BF17|@memset|@memset(dest, value)|fills memory with value|no|@memset(buf[0..n], 0); fills with zeros; @memset(buf, undefined); marks as uninitialized (debug: 0xAA pattern)
BF18|@panic|@panic(msg)|terminates program with error message; in debug: prints stack trace; in ReleaseFast: calls abort|no|noreturn function; used for: unrecoverable errors, assertion failures, safety check failures; @panic("message"); std.debug.panic("fmt {}", .{arg}) for formatted panic

# safety(id|name|type|checked_in|behavior_on_violation|cost|notes)
SF1|integer overflow|arithmetic|debug, ReleaseSafe|panic with "integer overflow" message + stack trace|zero in ReleaseFast (overflow is UB: compiler optimizes assuming no overflow)|wrapping operators (+%, -%, *%) for defined wrapping behavior; saturating (+\|, -\|, *\|) for clamping; use these when overflow is intentional (hash functions, DSP, wrapping counters)
SF2|bounds checking|array/slice access|debug, ReleaseSafe|panic with "index out of bounds" message|zero in ReleaseFast|every array and slice access is checked: arr[i] with i >= arr.len → panic; pointer arithmetic on [*]T is NOT checked (no length info); always prefer slices over many-pointers for safety
SF3|null pointer dereference|pointer access|debug, ReleaseSafe|panic|zero in ReleaseFast|optional pointers (?*T) must be unwrapped before use: if (ptr) \|p\| p.* — guaranteed non-null in body; .? unwrap: panics if null; orelse: provide default; non-optional *T: guaranteed non-null by type system (cannot be null)
SF4|alignment check|pointer cast|debug, ReleaseSafe|panic on misaligned access|zero in ReleaseFast|@ptrCast checks alignment; @alignCast explicitly asserts alignment; misaligned access: undefined behavior on many architectures (ARM: bus error; x86: performance penalty or SIGBUS for SSE); packed struct pointers: special handling (no alignment guarantee)
SF5|use-after-free|memory access|GeneralPurposeAllocator (debug)|GPA detects and reports; stack use-after-free: returning pointer to local is compile error for safe patterns|zero in release (GPA not used in release)|GPA: fills freed memory with 0xAA; subsequent access detects 0xAA pattern; also: double-free detection; leak detection; stack: compiler prevents returning &local_var (pointer to stack would dangle)
SF6|unreachable|control flow|debug, ReleaseSafe|panic ("reached unreachable")|UB in ReleaseFast (compiler assumes never reached → optimizes accordingly)|unreachable is the programmer's assertion that code path is impossible; in debug: verified (panic if wrong); in release: trusted (UB if wrong → miscompilation possible); use sparingly and only when truly unreachable

# testing(id|name|type|definition|execution|notes)
TE1|test block|declaration|test "description" { ... }|executed by zig test file.zig; test blocks are top-level declarations alongside functions and types; not compiled in non-test builds|test blocks can use: std.testing.expect(cond), std.testing.expectEqual(expected, actual), std.testing.expectError(expected_error, result), std.testing.expectEqualStrings(expected, actual); test failure: returns error → test runner reports
TE2|std.testing.allocator|allocator|testing allocator with leak detection|automatically fails test if any allocation not freed; detects double-free and use-after-free|always use in tests: const allocator = std.testing.allocator; ensures all allocations are paired with frees; test cleanup: errdefer allocator.free(buf)
TE3|std.testing.expect|assertion|try std.testing.expect(condition);|returns error if condition false → test fails with file/line info|for boolean conditions; std.testing.expectEqual for value comparison (better error messages: shows expected vs actual); std.testing.expectFmt for formatted string comparison
TE4|std.testing.refAllDecls|coverage|std.testing.refAllDecls(@This());|references all declarations in current struct/file to ensure they compile; does not execute them; catches compile errors in untested code|place at end of file to ensure all code at least compiles: test { std.testing.refAllDecls(@This()); }; catches: type errors, missing imports, syntax errors in unused functions

# build_system(id|name|type|definition|features|notes)
BS1|build.zig|build configuration|Zig source file that defines build steps; executed by Zig build system at build time; not a separate language|const std = @import("std"); pub fn build(b: *std.Build) void { const exe = b.addExecutable(.{ .name = "app", .root_source_file = b.path("src/main.zig"), .target = b.standardTargetOptions(.{}), .optimize = b.standardOptimizeOption(.{}) }); b.installArtifact(exe); }|replaces Makefile, CMake, etc.; cross-compilation: change target; link C libraries: exe.linkSystemLibrary("c"); exe.addCSourceFiles(.{ .files = &.{"foo.c"} }); add tests: b.addTest(.{ ... }); add run step: b.addRunArtifact(exe)
BS2|optimization modes|build option|.Debug (safety + no optimization), .ReleaseSafe (safety + optimization), .ReleaseFast (no safety + max optimization), .ReleaseSmall (no safety + size optimization)|selected at build time: zig build -Doptimize=ReleaseFast; or in build.zig: .optimize = .ReleaseFast|Debug: default; best for development; all safety checks; no optimization; fast compile; ReleaseSafe: production with safety (recommended for most deployed code); ReleaseFast: maximum performance (safety checks removed: UB possible); ReleaseSmall: embedded, WASM (minimize binary size)
BS3|cross-compilation|build feature|any target from any host; Zig ships with libc headers for all supported targets|exe.target = b.resolveTargetQuery(.{ .cpu_arch = .aarch64, .os_tag = .linux }); — cross-compile to aarch64-linux from any host|~80+ target architectures; no separate cross-compilation toolchain needed; includes: musl libc, glibc stubs, MinGW headers; C cross-compilation also works: zig cc is a drop-in C cross-compiler
BS4|caching and incremental|build feature|Zig build system caches compilation artifacts; incremental: only recompiles changed files and dependencies|automatic; cache in zig-cache/ directory (or .zig-cache/ in 0.14+); cache key: source content hash + flags + target|dramatically faster than clean build for large projects; invalidation: automatic (source hash changes); clean: delete cache directory

# c_interop(id|name|type|definition|mechanism|notes)
CI1|@cImport / @cInclude|import C headers|const c = @cImport(@cInclude("header.h"));|Zig compiler invokes C preprocessor and translates C declarations to Zig types at compile time; result is a Zig struct type whose fields are the C declarations|supports: functions, types (struct, union, enum, typedef), macros (simple constant macros; function-like macros: limited), global variables; limitations: complex macros, inline functions, C++ headers not supported; @cDefine, @cUndef for preprocessor definitions
CI2|extern function declaration|manual C binding|extern "c" fn printf(fmt: [*:0]const u8, ...) callconv(.c) c_int;|declares function implemented in C library; linked at link time|manual alternative to @cImport; useful when: C header is problematic, only need few functions, or want more control over types; must match C signature exactly
CI3|export|Zig → C|export fn add(a: i32, b: i32) i32 { return a + b; }|makes Zig function callable from C with C-compatible name and ABI|function name exported as-is (no mangling); must use C-compatible parameter and return types; callconv(.c) is implicit with export; used for: shared libraries, WASM exports, kernel modules, FFI
CI4|C pointer types|type mapping|C void* → *anyopaque; C int* → *c_int; C const char* → [*:0]const u8; C NULL → null|Zig maps C types to Zig equivalents; optional pointers (?*T) for nullable C pointers|[*c]T: C pointer type (nullable, allows pointer arithmetic, compatible with C calling conventions); coerces from/to many Zig pointer types; used in @cImport-generated code; in user code: prefer explicit Zig pointer types and convert at boundary
CI5|linking|build system|exe.linkSystemLibrary("ssl"); exe.addObjectFile("lib.o"); exe.linkLibC();|links C libraries at build time; static or dynamic; cross-platform|linkLibC(): links platform libc; linkSystemLibrary: searches pkg-config and system paths; addCSourceFiles: compiles C source files with Zig's built-in C compiler (Clang-based); addIncludePath: adds C header search path

# concepts(id|name|definition|category)
ZC1|no hidden control flow|function calls are visible; no operator overloading (no hidden function calls from + or [] syntax); no hidden allocations; no hidden copies; no exceptions (no invisible stack unwinding); only explicit control flow: if, while, for, switch, break, continue, return|philosophy
ZC2|no hidden allocations|every memory allocation is explicit and visible: allocator passed as parameter; Zig standard library never allocates behind your back; you always see the allocator parameter; enables: embedded systems, real-time, deterministic behavior|philosophy
ZC3|no null references|pointers (*T) are non-nullable by type system; nullable pointers are explicit: ?*T; must unwrap optional before use; eliminates billion-dollar mistake at compile time; null is only valid for optional types|safety
ZC4|errors are values|errors are not exceptions (no stack unwinding, no hidden control flow); errors are not integers (no forgetting to check errno); errors are typed, named, and must be handled (compile error if ignored); error propagation is explicit (try) and visible|philosophy
ZC5|comptime generics|generic programming via comptime type parameters; fn sort(comptime T: type, items: []T) void; no angle brackets, no template syntax, no separate generic system; just functions that take types as comptime parameters; full type information available in function body|generics
ZC6|allocator interface|std.mem.Allocator: struct with function pointers for alloc, resize, free; passed as parameter to any function that needs heap allocation; enables: custom allocators, testing allocators, arena allocators, stack allocators; no global allocator; dependency injection for memory|memory
ZC7|RAII via defer/errdefer|resource cleanup via defer (always) and errdefer (on error only); explicit, ordered, visible; no implicit destructors; no hidden cleanup; defer runs at scope exit in reverse declaration order; replaces C++ RAII, Go defer, Python with/finally|resource_management
ZC8|zero-cost abstractions|language features (slices, optionals, error unions, tagged unions) compile to the same machine code as hand-written C equivalents; no runtime overhead; no vtable unless explicitly created; generics monomorphized (no boxing, no type erasure, no dynamic dispatch)|performance
ZC9|stage2 self-hosted compiler|Zig compiler is written in Zig (self-hosted since 0.10); compiles Zig and C (built-in Clang/LLVM backend; also x86_64 and aarch64 native backends); is also a C compiler: zig cc; is also a linker: zig ld|toolchain
ZC10|result location semantics|Zig passes the address where a function's result will be stored as a hidden pointer parameter; enables: constructing results directly in the caller's memory (no copy); large struct return without copy; enables named return value optimization|optimization
ZC11|comptime string formatting|std.fmt.comptimePrint("x={d}", .{42}) returns comptime []const u8; format strings checked at compile time; wrong specifier or argument mismatch: compile error; no runtime format string parsing overhead|comptime
ZC12|lazy evaluation of comptime|unreferenced declarations are not analyzed; comptime branches that are not taken are not compiled; enables: platform-specific code without #ifdef; code paths that don't compile on current platform are ignored if not referenced|comptime

# antipatterns(id|name|type|code_pattern|problem|correct_pattern|notes)
AP1|ignoring error|error handling|_ = fallibleFn();|compile error in Zig: error union return values cannot be discarded with _ unless explicitly: fallibleFn() catch \|err\| { ... }; or const _ = fallibleFn() catch unreachable;|handle the error: try, catch, or explicit discard with catch unreachable (asserts no error)|Zig forces error handling; you can't accidentally ignore errors; explicit discard with catch unreachable is intentional and visible
AP2|using global allocator|memory|var gpa = ... at file scope; functions use global|hidden dependency; not testable; not composable; threading issues|pass allocator as parameter: fn create(allocator: Allocator) !*Thing|Zig stdlib never uses global allocators; follow the pattern; dependency injection for allocators enables testing with std.testing.allocator
AP3|returning pointer to stack local|memory|fn f() *i32 { var x: i32 = 42; return &x; }|compile error: pointer to local would dangle after function returns|allocate on heap (allocator.create()), or have caller provide buffer, or return by value|Zig compiler detects many forms of this; some complex cases may not be caught at compile time but will be caught by runtime safety in debug
AP4|not using errdefer after allocation|error handling|const buf = try allocator.alloc(u8, n); try doFallibleWork(); — if doFallibleWork fails, buf leaks|memory leak on error path; buf never freed|const buf = try allocator.alloc(u8, n); errdefer allocator.free(buf); try doFallibleWork(); — buf freed if doFallibleWork fails|most common Zig bug: allocate → do fallible work → forget errdefer; always add errdefer immediately after successful allocation
AP5|using anytype when concrete type works|generics|fn add(a: anytype, b: anytype) @TypeOf(a) { return a + b; }|error messages are confusing (instantiated at call site, not definition); API contract is unclear; documentation is poor|fn add(a: i32, b: i32) i32 { return a + b; } — use concrete types unless genuine genericity is needed|anytype is Zig's equivalent of C++ templates; powerful but use only when you need polymorphism; for a function that only ever handles i32: use i32, not anytype
AP6|packed struct for non-hardware use|types|packed struct for regular data (not hardware registers or binary protocols)|packed struct has restrictions: can't take address of non-byte-aligned fields; slower access (bit manipulation); counterintuitive alignment|use default struct (compiler optimizes layout) or extern struct (if C-compatible layout needed)|packed struct is for: MMIO registers, network protocol headers, binary file formats; not for general data modeling
AP7|using [*]T when []T works|pointers|using many-pointer [*]T for data with known length|no bounds checking; no length information; easy to read out of bounds|convert to slice immediately: const slice = ptr[0..len]; use []T (slice) throughout|[*]T is for C interop boundaries only; convert to []T at the earliest opportunity; []T carries length and provides safety

# relationships(from|rel|to)
# domain foundations
DM1|enables|DM3,DM5,DM7
DM2|enables|DM4,DM7
DM3|enables|DM1,DM6
DM4|requires|DM1,DM2
DM5|requires|DM1
DM6|requires|DM3
DM7|requires|DM1,DM6
# type system
TS1|enables|CT1,CT5,FN3
TS2|enables|PT1,PT2
TS3|enables|PT4
TS4|enables|AG3,UN1
TS5|enables|CF7
TS6|enables|PR1,CI4
TS7|enables|CF1,CF2
TS8|enables|ME1
# primitive → aggregate
PT1|enables|AG1,AG5
PT2|enables|AG1,SA1,SR2
PT3|enables|SA1
PT4|enables|AG3
PT5|enables|AG6,CI2
# aggregate hierarchy
AG1|enables|SA1,SA3
AG2|specializes|AG1
AG3|enables|SU1,SU3,SU4
AG4|specializes|AG3
AG5|specializes|AG3
AG6|specializes|AG3
# pointer types
PR1|enables|ME2
PR2|enables|SA4
PR3|specializes|PR2
PR4|enables|OE1
PR5|extends|PR1
PR6|extends|PR1
PR7|extends|PR1
# optional/error
OE1|enables|DM5
OE2|enables|DM5
OE3|enables|OE2
OE4|composed_of|OE1,OE2
# operators → types
OP1|requires|PT1,PT2,PT4
OP10|requires|PT1,PT2,TS7,OE1
OP13|enables|CF1
OP15|requires|OE1
OP16|requires|OE2
OP17|requires|OE2
# control flow → types
CF1|requires|TS7,OE1
CF2|requires|TS7,OE1
CF3|requires|SA1,AG1
CF4|requires|EN1,UN1,PT1,TS7
CF8|enables|ZC7
CF9|specializes|CF8
CF10|requires|DM3
# functions
FN1|enables|DM4
FN2|requires|SU1,SU5
FN3|requires|DM3,TS1
FN4|extends|FN1
FN5|enables|DM7,CI2
FN6|enables|CI3
FN7|enables|FN1
FN8|requires|TS1,BF10
# comptime
CT1|enables|DM3
CT2|enables|DM3
CT3|enables|DM3,FN3
CT4|enables|DM3,ZC12
CT5|enables|DM3
CT6|enables|DM3
# memory → allocator
ME1|enables|DM2
ME2|requires|AL1,AL2,AL3,AL4,AL5
ME3|enables|DM2
ME4|enables|DM3
ME5|enables|DM7
# allocators
AL1|enables|AL2,AL4
AL2|enables|SF5
AL3|enables|ME2
AL4|enables|ME2
AL5|enables|CI5
AL6|enables|TE1,TE2
# slices/arrays → strings
SA1|enables|SR2
SA2|specializes|SA1
SA3|enables|SA1
SA4|enables|CI4
SA5|specializes|SA1
SR1|enables|SR2,SR3
# struct hierarchy
SU1|enables|FN2,SU5
SU2|enables|SU1
SU3|specializes|SU1
SU4|specializes|SU1
SU5|requires|SU1,FN2
# enum/union
EN1|enables|UN1,CF4
EN2|specializes|EN1
UN1|enables|CF4,OE2
UN2|enables|CI4
UN3|specializes|UN2
# error handling chain
EH1|enables|EH2
EH2|enables|EH3,EH4
EH3|requires|OE2
EH4|requires|OE2
EH5|requires|CF8
EH6|requires|EH3
# builtins
BF1|enables|PT1,PT2,PT3
BF3|enables|PR1,PR2
BF6|enables|AG5
BF9|enables|CT5
BF10|enables|FN8
BF11|enables|DM6
BF12|enables|DM7,CI1
BF13|enables|OE1,PT1
BF14|enables|CO1
BF18|enables|SF6
# safety
SF1|requires|OP1,OP2,OP3,OP4
SF2|requires|SA1,AG1
SF3|requires|PR4,OE1
SF4|requires|PR5
SF5|requires|AL2
SF6|requires|CF7
# testing
TE1|enables|DM4
TE2|specializes|AL2
TE3|enables|TE1
TE4|enables|TE1
# build system
BS1|enables|DM6
BS2|enables|DM4
BS3|enables|DM6,DM7
BS4|enables|BS1
# C interop
CI1|enables|DM7
CI2|enables|DM7
CI3|enables|DM7
CI4|enables|DM7
CI5|enables|DM7,BS1
# concepts
ZC1|enables|DM4
ZC2|enables|DM2
ZC3|requires|OE1,PR1
ZC4|requires|OE2,EH1
ZC5|requires|DM3,FN3
ZC6|requires|AL1,AL2,AL3,AL4
ZC7|requires|CF8,CF9
ZC8|requires|SA1,OE1,OE2,UN1
ZC9|enables|DM6,DM7
ZC10|enables|ZC8
ZC11|requires|DM3,SR4
ZC12|requires|DM3
# antipatterns
AP1|prevents|EH3,EH4
AP2|prevents|ZC2
AP3|prevents|ME1
AP4|prevents|EH5
AP5|prevents|FN3
AP6|prevents|AG5
AP7|prevents|SA1

# section_index(section|title|ids)
1|Domains|DM1-DM7
2|Type System|TS1-TS8
3|Primitive Types|PT1-PT5
4|Aggregate Types|AG1-AG6
5|Pointer Types|PR1-PR7
6|Optional and Error Types|OE1-OE4
7|Operators|OP1-OP17
8|Control Flow|CF1-CF10
9|Functions|FN1-FN8
10|Comptime|CT1-CT6
11|Memory Model|ME1-ME5
12|Allocators|AL1-AL6
13|Slices and Arrays|SA1-SA5
14|Strings|SR1-SR4
15|Structs|SU1-SU5
16|Enums|EN1-EN2
17|Unions|UN1-UN3
18|Error Handling|EH1-EH6
19|Builtin Functions|BF1-BF18
20|Safety|SF1-SF6
21|Testing|TE1-TE4
22|Build System|BS1-BS4
23|C Interop|CI1-CI5
24|Core Concepts|ZC1-ZC12
25|Antipatterns|AP1-AP7
26|Relationships|all

# decode_legend
id_prefixes: DM=domain, TS=type_system, PT=primitive_type, AG=aggregate_type, PR=pointer_type, OE=optional_error, OP=operator, CF=control_flow, FN=function, CT=comptime, ME=memory, AL=allocator, SA=slice_array, SR=string, SU=struct, EN=enum, UN=union, EH=error_handling, BF=builtin_function, SF=safety, TE=testing, BS=build_system, CI=c_interop, ZC=concept, AP=antipattern
rel_types: enables|requires|prevents|specializes|generalizes|part_of|contains|follows|precedes|instance_of|determined_by|equivalent_to|extends|derived_from|composed_of
notation: _fk=foreign key; ~=approximate; *T=single-item pointer to T; [*]T=many-item pointer; []T=slice of T; [N]T=array of N elements of type T; ?T=optional T; E!T=error union (E is error set, T is payload); comptime=compile-time evaluated; fn=function; i32/u32/f32=signed/unsigned 32-bit integer, 32-bit float; usize=pointer-width unsigned integer; isize=pointer-width signed integer; ABI=application binary interface; LLVM=Low Level Virtual Machine (compiler backend); SIMD=single instruction multiple data; MMIO=memory-mapped I/O; UB=undefined behavior; RAII=resource acquisition is initialization; GPA=GeneralPurposeAllocator; FBA=FixedBufferAllocator; MRO=method resolution order (not applicable to Zig); FFI=foreign function interface; WASM=WebAssembly; GIL=global interpreter lock (Zig has no GIL: true concurrency); DSL=domain-specific language; OOP=object-oriented programming; ADT=algebraic data type; C3=C3 linearization (Python/Zig has no inheritance MRO); LIFO=last in first out; @This()=returns enclosing type; Self=conventional alias for @This(); callconv=calling convention; .c=C calling convention; packed=bit-level layout with no padding; extern=C-ABI-compatible layout; inline=force inlining; noinline=prevent inlining; comptime_int=arbitrary-precision compile-time integer; comptime_float=arbitrary-precision compile-time float
version: Zig 0.15.1 (specification as of May 2025); self-hosted compiler (stage2/stage3); LLVM 20 backend + x86_64/aarch64 native backends; language is pre-1.0 (API stability not yet guaranteed; breaking changes possible between minor versions)
confidence: all specifications from official Zig language reference (ziglang.org/documentation), standard library source (github.com/ziglang/zig/tree/master/lib/std), and release notes; implementation details specific to 0.14/0.15 series; some features are evolving (async removed in 0.11, may return; build system API stabilizing); all facts at reference_zig confidence level
scope: Zig 0.15.1 language specification, type system, memory model, error handling, comptime, standard library core patterns, build system, C interop, safety model, and testing; excludes: exhaustive standard library coverage (std.net, std.crypto, std.compress, etc.), detailed LLVM/backend internals, async/coroutine (removed in 0.11, status TBD), detailed OS-specific APIs, and third-party package ecosystem; focused on language mechanics, idioms, and the mental model for writing correct Zig code

# relation_mapping(doc_rel|canonical_rel|notes)
enables|enables|exact match
requires|requires|exact match
prevents|prevents|exact match
specializes|specializes|exact match
generalizes|generalizes|exact match
part_of|part_of|exact match
contains|contains|exact match
follows|follows|exact match
precedes|precedes|exact match
instance_of|instance_of|exact match
determined_by|determined_by|exact match
equivalent_to|equivalent_to|exact match
extends|extends|exact match
derived_from|derived_from|exact match
composed_of|composed_of|exact match
