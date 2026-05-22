# PYTHON 3: LANGUAGE SPECIFICATION AND RUNTIME — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: domains → data_model → builtin_types → operators → control_flow → functions → classes → modules → exceptions → iterators_generators → comprehensions → decorators → context_managers → concurrency → type_hints → string_formatting → io → stdlib_core → stdlib_data → stdlib_functional → stdlib_os → stdlib_net → stdlib_test → memory_model → cpython_internals → magic_methods → descriptor_protocol → metaclasses → packaging → idioms → antipatterns → concepts → relationships → section_index → decode_legend

# domains(id|name|definition)
DM1|data model|Python's object system: every value is an object; every object has identity (id()), type (type()), and value; objects are either mutable or immutable; reference semantics (variables are names bound to objects, not containers)
DM2|type system|dynamic typing at runtime; optional static type hints (PEP 484); duck typing (if it quacks...); structural subtyping (Protocol); nominal subtyping (isinstance); type erasure at runtime (hints are not enforced by interpreter)
DM3|control flow|execution order: sequential, conditional (if/elif/else), loops (for/while), exception handling (try/except/finally), pattern matching (match/case: 3.10+), comprehensions, generators (lazy evaluation)
DM4|functions|first-class objects: can be assigned, passed, returned; closures; decorators; *args/**kwargs; positional-only (/), keyword-only (*); lambda; recursion limit (~1000 default)
DM5|classes and OOP|class-based OOP: single inheritance + multiple inheritance (C3 MRO); everything is an object (including classes: type is the metaclass); descriptors; properties; slots; dataclasses; abstract base classes (ABCs)
DM6|modules and packages|code organization: module = .py file; package = directory with __init__.py (or implicit namespace package); import system: finder → loader → module object; relative and absolute imports
DM7|concurrency|threading (GIL-limited: CPython; one thread executes Python bytecode at a time); multiprocessing (separate interpreter processes; true parallelism); asyncio (cooperative multitasking: single thread, event loop, coroutines); subinterpreters (3.12+); free-threading (3.13+ experimental: no GIL)
DM8|memory management|reference counting (primary) + cyclic garbage collector (secondary: handles reference cycles); everything on heap (no stack-allocated objects); object creation: __new__ → __init__; small integer cache (−5 to 256); string interning
DM9|C extension interface|CPython C API: extend Python with C; embed Python in C applications; ctypes, cffi, Cython, pybind11; stable ABI (abi3); limited API for forward-compatible extensions
DM10|packaging and distribution|pip, setuptools, wheel, pyproject.toml (PEP 517/518/621); virtual environments (venv); PyPI; dependency resolution; editable installs; build backends (setuptools, flit, hatchling, maturin, pdm-backend)

# data_model(id|name|type|definition|identity|mutability|notes)
DO1|object|base|fundamental unit: every value in Python is an object; has identity (id()), type (type()), and value|id() returns unique integer (CPython: memory address); identity comparison: is/is not|depends on type (immutable: int, str, tuple, frozenset, bytes; mutable: list, dict, set, bytearray)|even None, True, False, functions, classes, modules are objects; type of an object is itself an object (type); type(type) is type (self-referential root)
DO2|name binding|reference|variable = name bound to object in namespace; assignment creates or rebinds name; does NOT copy object; multiple names can reference same object|names have no type; objects have types; del unbinds name from namespace (doesn't necessarily delete object)|n/a (names are not objects)|a = [1,2,3]; b = a → both point to same list; b.append(4) → a is [1,2,3,4]; this surprises newcomers; immutable objects avoid this (rebinding, not mutation)
DO3|namespace|dict|mapping from names (str) to objects; implemented as dict; each scope has its own namespace|module namespace = module.__dict__; class namespace = class.__dict__ (actually mappingproxy); function local namespace: optimized (not dict in CPython: LOAD_FAST bytecode)|mutable|LEGB rule: Local → Enclosing → Global → Builtin; global statement: binds name in module namespace; nonlocal statement: binds name in enclosing function namespace
DO4|scope|resolution|region of code where a namespace is directly accessible; determines which names are visible|determined at compile time (not runtime) for local variables; unbound local error if referenced before assignment in scope where it appears as target of assignment|n/a|gotcha: x = 10; def f(): print(x); x = 20 → UnboundLocalError (x is local because assigned in f, but print occurs before assignment); fix: nonlocal x (if enclosing) or global x (if module)

# builtin_types(id|name|type|mutable|literal_syntax|common_operations|memory|notes)
BT1|int|numeric (integer)|immutable|42, 0xFF, 0o77, 0b1010, 1_000_000|+, −, *, //, %, **, divmod(), abs(), bit_length(), to_bytes(), int.from_bytes(); unlimited precision (arbitrary length)|CPython: small int cache −5 to 256 (singleton); larger ints allocated on heap; variable-length (28 bytes base + 4 bytes per 30-bit digit)|no overflow (arbitrary precision); // is floor division (always integer result); / is true division (always float result); 3 / 2 = 1.5 (Python 3); int('ff', 16) = 255 (base conversion)
BT2|float|numeric (IEEE 754 double)|immutable|3.14, 2.5e10, float('inf'), float('nan'), float('-inf')|+, −, *, /, //, %, **, round(), math.floor(), math.ceil(), .is_integer(), .hex(), .as_integer_ratio()|64-bit IEEE 754 double precision: 53-bit mantissa (~15–17 significant decimal digits); range ~±1.8×10³⁰⁸|0.1 + 0.2 != 0.3 (IEEE 754 representation error); use decimal.Decimal for exact decimal arithmetic (financial); use math.isclose(a, b) for comparison; float('inf') > any number; float('nan') != float('nan') (NaN is not equal to anything, including itself)
BT3|complex|numeric|immutable|3+4j, complex(3,4)|.real, .imag, abs() (magnitude), +, −, *, /, **; cmath module for complex math|16 bytes (two doubles: real + imag)|j is imaginary unit (not i); used in scientific computing, signal processing; no ordering (<, > not defined for complex)
BT4|bool|numeric (subclass of int)|immutable|True (==1), False (==0)|and, or, not; bool(x) → truthiness; subclass of int: True + True = 2; False * 10 = 0|singleton (True and False are cached)|falsy values: None, False, 0, 0.0, 0j, '', [], (), {}, set(), frozenset(), b'', bytearray(), range(0), objects with __bool__() returning False or __len__() returning 0; everything else is truthy
BT5|str|sequence (text)|immutable|'hello', "hello", '''multi\nline''', """multi""", f"x={x}", r"\n" (raw), b"bytes" is bytes not str|indexing s[0], slicing s[1:3], +, *, .join(), .split(), .strip(), .replace(), .find(), .startswith(), .endswith(), .upper(), .lower(), .format(), f-strings, .encode()|UTF-8 internally (CPython 3.12+: PEP 393 compact representation: Latin-1/UCS-2/UCS-4 depending on max codepoint)|strings are sequences of Unicode codepoints; not bytes; encode() → bytes; len() returns codepoint count (not bytes); single char = str of length 1 (no char type); immutable: every operation returns new string; string interning: CPython interns some strings (identifiers, small strings) for performance
BT6|bytes|sequence (binary)|immutable|b'hello', b'\x00\xff', bytes([72,101,108,108,111]), bytes.fromhex('48656c6c6f')|same as str but for bytes; .decode() → str; indexing returns int (b'abc'[0] = 97); no .format() or f-string|raw byte sequence|bytes ≠ str; must explicitly encode/decode; encoding: 'utf-8' (default), 'ascii', 'latin-1', etc.; common error: mixing str and bytes operations
BT7|bytearray|sequence (binary)|mutable|bytearray(b'hello'), bytearray(10), bytearray([72,101])|same as bytes but mutable: ba[0] = 65; .append(), .extend(), .pop(), .insert()|mutable byte buffer|useful for: building binary data incrementally, in-place modification, network/IO buffers; memoryview can reference bytearray without copying
BT8|list|sequence|mutable|[1, 2, 3], [], list('abc') → ['a','b','c']|indexing l[0], slicing l[1:3], +, *, .append(), .extend(), .insert(), .pop(), .remove(), .sort(), .reverse(), .index(), .count(), .copy(), .clear()|dynamic array: over-allocates to amortize append cost (amortized O(1) append); CPython: array of pointers to objects (each element is a pointer, not the object itself)|most-used mutable sequence; heterogeneous (any types mixable but rarely good practice); list * n: creates n references to same objects (for mutable elements: same object repeated, not copies); deep copy: copy.deepcopy(l); list comprehension: [expr for x in iterable if cond] — preferred over map/filter
BT9|tuple|sequence|immutable|(1, 2, 3), (), (42,) ← trailing comma needed for single-element|indexing t[0], slicing, +, *, .count(), .index(); namedtuple for labeled fields; tuple unpacking: a, b = (1, 2)|immutable: hashable if all elements hashable → can be dict key or set element; CPython: small tuple cache (empty tuple is singleton; tuples of length 1–20 with only None, True, False, ints, or small strings may be cached)|fixed-length immutable sequence; used for: function return values (multiple return), dict keys (hashable), packing/unpacking, named tuples; tuple ≠ list: tuple is structurally typed (position determines meaning), list is homogeneous collection
BT10|dict|mapping|mutable|{'a': 1, 'b': 2}, {}, dict(a=1, b=2), dict(zip(keys, vals))|d[key], d.get(key, default), d.keys(), d.values(), d.items(), d.update(), d.pop(), d.setdefault(), d \| d2 (merge: 3.9+), d \|= d2 (update: 3.9+), **d (unpacking)|hash table: O(1) average lookup/insert/delete; CPython 3.6+: insertion-ordered (guaranteed in 3.7+ per language spec); compact dict (PEP 412: key-sharing for instances)|most important data structure; keys must be hashable (immutable: str, int, tuple of hashables, frozenset); values: anything; dict comprehension: {k: v for k, v in iterable}; missing key: d[key] → KeyError; d.get(key) → None; defaultdict(factory) auto-creates missing keys
BT11|set|collection|mutable|{1, 2, 3}, set() (not {} — that's empty dict), set([1,2,3])|.add(), .remove(), .discard(), .pop(), .union(\|), .intersection(&), .difference(−), .symmetric_difference(^), .issubset(<=), .issuperset(>=)|hash table (like dict without values); O(1) membership test; unordered (no indexing)|elements must be hashable; mathematical set operations; excellent for: membership testing, deduplication (list(set(L))), set arithmetic; frozenset: immutable set (hashable: can be dict key or element of another set)
BT12|frozenset|collection|immutable|frozenset({1,2,3}), frozenset([1,2,3])|same operations as set except mutating ones|same as set|hashable (can be dict key or set element); used when set must be immutable (e.g., dict key, element of another set)
BT13|NoneType|singleton|immutable|None|is None (identity check — preferred); == None (equality — works but not idiomatic); bool(None) is False|singleton (only one None object exists)|used for: no return value (functions without return → None); optional parameters (default None); sentinel value; never use == for None comparison — always use is None
BT14|range|sequence (lazy)|immutable|range(10), range(1, 10), range(0, 10, 2), range(10, 0, −1)|indexing r[5], slicing, len(), in (O(1) membership test), iteration|does NOT store all values in memory (lazy: calculates on demand); O(1) space regardless of range size; O(1) membership test (arithmetic check)|range is not a generator (it's a lazy sequence: supports indexing, len, and repeated iteration); range(10) creates range object immediately but doesn't compute all values; use list(range(10)) to materialize
BT15|memoryview|buffer protocol|depends on source|memoryview(b'hello'), memoryview(bytearray(10))|indexing, slicing (without copy), .tobytes(), .tolist(), .cast(format)|provides zero-copy access to memory of bytes-like objects (bytes, bytearray, array.array); avoids copying when slicing large buffers|critical for performance with large binary data: networking, file I/O, image processing, scientific computing; slice of memoryview shares underlying buffer (no copy); struct module + memoryview for binary protocol parsing

# operators(id|name|symbol|type|precedence_rank|notes)
OP1|exponentiation|**|arithmetic|1 (highest)|right-associative: 2**3**2 = 2**(3**2) = 512 not (2**3)**2 = 64; returns int if both operands int (unless negative exponent → float)
OP2|unary +, −, ~|+x, −x, ~x|unary|2|~ is bitwise NOT: ~n = −(n+1); +x usually identity but calls __pos__
OP3|multiplication, division, floor div, modulo|*, /, //, %, @|arithmetic|3|/ always returns float; // returns int if both operands int, else float; % follows sign of divisor (Python) not dividend (C); @ is matrix multiply (PEP 465: numpy)
OP4|addition, subtraction|+, −|arithmetic|4|+ also concatenates sequences (str, list, tuple); overloadable via __add__, __radd__
OP5|bitwise shift|<<, >>|bitwise|5|left shift = multiply by 2ⁿ; right shift = floor divide by 2ⁿ; no arithmetic/logical distinction (Python ints are arbitrary precision: no fixed bit width)
OP6|bitwise AND|&|bitwise|6|also set intersection: {1,2,3} & {2,3,4} = {2,3}; dict merge (not &): d1 \| d2 (3.9+)
OP7|bitwise XOR|^|bitwise|7|also set symmetric difference: {1,2,3} ^ {2,3,4} = {1,4}
OP8|bitwise OR|\||bitwise|8|also set union; dict merge: d1 \| d2 (3.9+: PEP 584)
OP9|comparison|==, !=, <, >, <=, >=, is, is not, in, not in|comparison|9|chaining: a < b < c means a < b and b < c (evaluated once); is tests identity (same object); == tests equality (__eq__); in tests membership (__contains__ or iteration)
OP10|boolean NOT|not|boolean|10|returns True or False (never other types); not has lower precedence than comparison
OP11|boolean AND|and|boolean|11|short-circuit: returns first falsy operand or last operand; does NOT necessarily return bool: 0 and 'hello' → 0; 'hello' and 42 → 42
OP12|boolean OR|or|boolean|12|short-circuit: returns first truthy operand or last operand; 'hello' or 0 → 'hello'; '' or 0 or None → None
OP13|conditional expression (ternary)|x if cond else y|conditional|13 (lowest expression)|lazy: only evaluates the selected branch; value = x if condition else y
OP14|walrus operator|:=|assignment expression|14|PEP 572 (3.8+); assigns and returns value in expression context; if (n := len(a)) > 10: print(n); while chunk := f.read(8192): process(chunk); CANNOT be used in top-level assignment statement
OP15|unpacking|*, **|syntactic|n/a (not operator per se)|* in assignment: a, *rest = [1,2,3,4] → a=1, rest=[2,3,4]; * in call: f(*args); ** in call: f(**kwargs); * in def: def f(*args, **kwargs); PEP 448 (3.5+): {**d1, **d2} for dict merge; [*a, *b] for list merge

# control_flow(id|name|syntax|behavior|notes)
CF1|if / elif / else|if cond: ... elif cond: ... else: ...|first true condition's block executes; else if none true; no switch statement (use match/case 3.10+ or dict dispatch)|truthy/falsy evaluation (see BT4); no braces: indentation IS the block structure (IndentationError if wrong)
CF2|for loop|for x in iterable: ... else: ...|iterates over any iterable (list, tuple, dict, set, str, range, generator, file, etc.); else block executes if loop completes without break|for loop calls iter() → iterator → next() until StopIteration; for x in dict: iterates over keys; for k, v in dict.items(): key-value; enumerate(iterable, start=0) for index+value; zip(a, b) for parallel iteration
CF3|while loop|while cond: ... else: ...|repeats while condition truthy; else block if loop completes without break|infinite loop: while True: ... break; no do-while in Python (use while True with break); while/else is rarely used but valid
CF4|break|break|exits innermost for or while loop immediately; skips else clause of loop|no labeled break in Python (can't break out of nested loops directly: use flag variable, function+return, or exception); else clause on loop: executes only if loop completed without break → useful for search patterns
CF5|continue|continue|skips rest of current iteration; proceeds to next iteration of innermost loop|—
CF6|pass|pass|null statement; does nothing; placeholder for syntactically required block|use in: empty function/class body, empty except clause (bad practice but sometimes needed), stub implementations; semantically equivalent to Ellipsis (...) in some contexts but pass is conventional
CF7|match / case (structural pattern matching)|match subject: case pattern: ...|PEP 634/635/636 (3.10+); matches subject against patterns; first matching case executes; patterns: literal, capture, sequence, mapping, class, OR (\|), guard (if)|NOT a switch statement: it's destructuring/pattern matching; capture variable: case x: binds x (always matches); literal: case 42; sequence: case [a, b, *rest]; mapping: case {"key": value}; class: case Point(x=0, y=y); wildcard: case _: (default); guard: case x if x > 0
CF8|try / except / else / finally|try: ... except ExcType as e: ... else: ... finally: ...|try: attempt; except: handle specific exceptions; else: runs if no exception raised; finally: always runs (cleanup)|except catches exception and subclasses: except ValueError catches ValueError and subclasses; bare except: catches everything (bad practice: catches SystemExit, KeyboardInterrupt); except (A, B): catches multiple types; except* (ExceptionGroup: 3.11+); finally: runs even if return in try/except; else: runs only if no exception → useful for code that should not be protected by except

# functions(id|name|type|definition|behavior|notes)
FU1|def statement|definition|def name(params): ... return value|creates function object and binds name in current namespace; function body not executed until call; default arguments evaluated ONCE at definition time (mutable default gotcha)|def f(x, y=[]): ← y=[] is shared across all calls without explicit y argument → BUG; fix: def f(x, y=None): y = y if y is not None else []
FU2|lambda|anonymous function|lambda params: expression|single expression only (no statements, no assignment, no multiple lines); returns result of expression|limited: use for simple callbacks, key functions (sorted(L, key=lambda x: x[1])); for anything complex: use def
FU3|*args|positional variadic|def f(*args): ...|collects extra positional arguments into tuple; f(1,2,3) → args = (1,2,3)|*args must follow regular positional parameters; can be combined with **kwargs: def f(a, b, *args, **kwargs)
FU4|**kwargs|keyword variadic|def f(**kwargs): ...|collects extra keyword arguments into dict; f(a=1, b=2) → kwargs = {'a': 1, 'b': 2}|must be last parameter; keys are always strings; combined: def f(*args, **kwargs) accepts everything
FU5|positional-only (/)|parameter restriction (3.8+)|def f(a, b, /, c, d): ...|parameters before / can only be passed positionally (not by keyword); f(1, 2, c=3, d=4) OK; f(a=1) → TypeError|purpose: allows parameter names to be changed without breaking callers; enables **kwargs to use parameter names: def f(name, /, **kwargs) → kwargs can contain 'name' key
FU6|keyword-only (*)|parameter restriction|def f(a, *, b, c): ...|parameters after bare * can only be passed by keyword; f(1, b=2, c=3) OK; f(1, 2, 3) → TypeError|purpose: force explicit naming for clarity; common: def f(*, verbose=False, timeout=None); combined: def f(pos_only, /, normal, *, kw_only)
FU7|closure|lexical scoping|inner function captures variables from enclosing scope by reference (not by value)|def outer(): x = 10; def inner(): return x; return inner; f = outer(); f() → 10; x is captured by reference: if outer modifies x before inner is called, inner sees new value|late binding: closures over loop variables capture the variable, not the value → common gotcha: [lambda: i for i in range(5)] all return 4; fix: [lambda i=i: i for i in range(5)]
FU8|decorator|function transformation|@decorator def f(): ... ≡ f = decorator(f)|decorator is any callable that takes a function and returns a callable; can be stacked (@d1 @d2 def f: applied bottom-up: f = d1(d2(f))); functools.wraps(func) preserves original function's __name__, __doc__, __qualname__|common decorators: @staticmethod, @classmethod, @property, @functools.cache, @functools.lru_cache, @dataclasses.dataclass, @contextlib.contextmanager; parameterized decorator: @decorator(arg) def f: → decorator(arg) returns actual decorator that takes f
FU9|generator function|lazy producer|def f(): ... yield value ...|calling f() returns generator iterator (does not execute body); each next() executes until next yield; yield suspends execution and sends value; StopIteration when function returns|yield expression: value = yield item (send protocol: gen.send(value) resumes and becomes value of yield expression); yield from iterable: delegates to sub-generator (PEP 380); generator is both iterator and iterable (iter(gen) returns gen itself)
FU10|recursion|self-referencing call|function calls itself|default recursion limit: sys.getrecursionlimit() → 1000 (adjustable via sys.setrecursionlimit(n)); CPython: no tail-call optimization (deep recursion → stack overflow)|Python's recursion limit exists because CPython uses C stack for Python calls; for deep recursion: convert to iteration (explicit stack); or use sys.setrecursionlimit (risky: can crash interpreter if C stack overflows)

# classes(id|name|type|definition|behavior|notes)
CL1|class definition|type creation|class Name(Base1, Base2): ... |creates class object (instance of type metaclass) and binds name; class body executes immediately at definition (not at instantiation); class attributes defined in body; instance attributes defined in __init__|all classes implicitly inherit from object; class itself is an object (instance of type); type(MyClass) → <class 'type'>
CL2|__init__|initializer|def __init__(self, args): self.attr = value|called after __new__ creates instance; initializes instance attributes; must not return anything (returns None implicitly)|__init__ is NOT a constructor; __new__ creates the instance (allocates memory, returns new object); __init__ receives the new object as self and initializes it; for immutable types (str, int, tuple): override __new__ instead
CL3|self|convention|first parameter of instance methods; receives the instance|NOT a keyword (just convention); must be explicitly declared; methods called on instance: obj.method() → Type.method(obj)|forgetting self in method definition → TypeError on call (wrong argument count); class methods use cls instead
CL4|class method|method type|@classmethod def method(cls, args): ...|receives class (not instance) as first argument; can be called on class or instance; commonly used for: alternative constructors, factory methods|cls.attr accesses class attribute; cls() creates new instance of the class (or subclass if inherited); dict.fromkeys() is a class method example
CL5|static method|method type|@staticmethod def method(args): ...|no implicit first argument (no self, no cls); just a function that lives in the class namespace|use when method logically belongs to class but doesn't need access to instance or class state; could be a module-level function but grouped in class for organization
CL6|property|descriptor|@property def attr(self): return self._attr; @attr.setter def attr(self, value): self._attr = value|creates managed attribute: getter/setter/deleter; accessed like attribute (obj.attr) but executes function; encapsulation without breaking API|Pythonic alternative to getX()/setX() methods; use for: validation, computed attributes, lazy loading, API compatibility; don't use for simple attributes (YAGNI: just use plain attributes until you need behavior)
CL7|inheritance|class hierarchy|class Child(Parent): ...|Child inherits all attributes and methods of Parent; can override; super() accesses parent class methods (follows MRO)|single inheritance: simple chain; multiple inheritance: C3 linearization (MRO) determines method resolution order; diamond problem: resolved by C3 (each class appears once in MRO, preserving order); mro = ClassName.__mro__ or ClassName.mro()
CL8|MRO (method resolution order)|resolution|C3 linearization algorithm determines order in which base classes are searched for methods|computed at class creation; accessible via ClassName.__mro__; super() follows MRO (not just immediate parent)|C3 properties: monotonic (parent order preserved), consistent (no contradictory ordering), local precedence (left-to-right base class order preserved); TypeError if inconsistent hierarchy
CL9|__slots__|memory optimization|class C: __slots__ = ('x', 'y')|instances don't get __dict__; attributes limited to listed names; saves ~40–50% memory per instance for small objects; slightly faster attribute access|tradeoffs: no dynamic attributes (can't add attrs not in __slots__); no multiple inheritance with conflicting __slots__; no weak references unless '__weakref__' in __slots__; use for: large number of instances with fixed attributes (data objects, ORM rows)
CL10|dataclass|boilerplate reduction|@dataclass class Point: x: float; y: float|auto-generates: __init__, __repr__, __eq__; optional: __hash__ (if frozen=True), __lt__/__le__/__gt__/__ge__ (if order=True), __post_init__; field() for defaults, default_factory, metadata|PEP 557 (3.7+); replaces namedtuple for many uses; supports: frozen=True (immutable), slots=True (3.10+: combines with __slots__), kw_only=True (3.10+); field types: ClassVar (class-level), InitVar (init-only); __post_init__ for derived attributes
CL11|abstract base class (ABC)|interface contract|from abc import ABC, abstractmethod; class Base(ABC): @abstractmethod def method(self): ...|cannot instantiate ABC directly; subclasses must implement all abstract methods; isinstance() and issubclass() work with ABCs|use ABCs sparingly (duck typing is preferred unless you need explicit interface contract); collections.abc provides standard ABCs: Iterable, Iterator, Sequence, Mapping, MutableMapping, etc.; register() allows virtual subclassing (class passes isinstance check without actual inheritance)

# iterators_generators(id|name|type|protocol|creation|behavior|notes)
IG1|iterable|protocol|object with __iter__() that returns iterator; or object with __getitem__() for legacy sequence protocol|any collection (list, dict, set, str, tuple, range, file); custom: implement __iter__()|for loop calls iter(obj) → gets iterator → calls next(iterator) until StopIteration|iterable ≠ iterator: iterable can be iterated multiple times (each iter() call returns fresh iterator); iterator is consumed (one pass only); list is iterable but not iterator; iter(list) returns list_iterator
IG2|iterator|protocol|object with __iter__() returning self and __next__() returning next value or raising StopIteration|iter(iterable) returns iterator; custom: implement __iter__ and __next__|one-pass only: once exhausted, stays exhausted; calling iter(iterator) returns same iterator (self)|every iterator is also iterable (because __iter__ returns self); but not every iterable is iterator; generators are iterators
IG3|generator function|lazy producer|def gen(): yield value; yield value2; return final|calling gen() returns generator object (iterator); each next() runs to next yield; yield suspends state; return raises StopIteration(final) (return value available as exception .value)|most Pythonic way to create iterators; memory-efficient for large sequences; can be infinite (produce values forever, consumed lazily); generator pipelines: compose generators for stream processing: lines = (line.strip() for line in f); filtered = (l for l in lines if l)
IG4|generator expression|lazy producer|genexpr = (expr for x in iterable if cond)|creates generator object; parentheses; NOT brackets (that's list comprehension); lazy: values computed on demand|use when you need single-pass iteration without materializing entire sequence; can be passed directly to functions that consume iterables: sum(x**2 for x in range(10)); vs list comp: [x**2 for x in range(10)] allocates all at once
IG5|yield from|delegation (3.3+)|yield from iterable|delegates iteration to sub-iterable; transparent: send(), throw(), close() pass through to sub-generator; return value of sub-generator becomes value of yield from expression|PEP 380; enables: refactoring generators into sub-generators; coroutine composition; recursive generators; simpler than manual loop: yield from gen() replaces for item in gen(): yield item, but also handles send/throw/close correctly
IG6|itertools module|stdlib|import itertools|chain, islice, zip_longest, product, permutations, combinations, groupby, count, cycle, repeat, accumulate, starmap, filterfalse, tee, pairwise (3.10+)|essential for generator-based programming; infinite iterators: count(), cycle(), repeat(); combinatoric: product(), permutations(), combinations(); all return lazy iterators; recipes in documentation extend capability

# comprehensions(id|name|syntax|produces|equivalent|notes)
CP1|list comprehension|[expr for x in iterable if cond]|list|list(map(lambda x: expr, filter(lambda x: cond, iterable))) but more readable|most-used comprehension; can nest: [expr for x in A for y in B] (outer loop first); for x in A is evaluated first, then for y in B for each x; include guard clause (if) for filtering
CP2|dict comprehension|{key: value for x in iterable if cond}|dict|dict((key, value) for x in iterable if cond)|useful for: inverting dicts ({v: k for k, v in d.items()}), filtering dicts, transforming keys/values
CP3|set comprehension|{expr for x in iterable if cond}|set|set(expr for x in iterable if cond)|same syntax as dict comp but without colon (just expression, not key:value pair)
CP4|generator expression|(expr for x in iterable if cond)|generator iterator|equivalent lazy form of list comprehension|parentheses distinguish from list comp; when passed as sole argument to function, outer parens can be omitted: sum(x**2 for x in range(10)) instead of sum((x**2 for x in range(10)))

# decorators(id|name|type|target|purpose|implementation|notes)
DC1|@staticmethod|builtin|method|makes method callable without instance or class argument|descriptor that wraps function; staticmethod(f)|rarely needed in Python (module-level function usually better); use when logically grouping with class
DC2|@classmethod|builtin|method|passes class as first arg (cls) instead of instance (self)|descriptor that wraps function; classmethod(f)|common use: alternative constructors (cls() creates instance of actual class, not hardcoded class → works with inheritance): dict.fromkeys(), datetime.fromtimestamp()
DC3|@property|builtin|method|creates managed attribute with getter (and optional setter/deleter)|descriptor protocol: __get__, __set__, __delete__|see CL6; pythonic attribute access: obj.attr calls getter; obj.attr = val calls setter
DC4|@functools.cache|stdlib (3.9+)|function|memoization: caches all results indefinitely; unlimited cache size|equivalent to @lru_cache(maxsize=None); dictionary-based caching; arguments must be hashable|use for: pure functions with expensive computation and repeated arguments; recursive functions (Fibonacci: O(n) instead of O(2ⁿ)); careful with memory: cache grows unboundedly; @lru_cache(maxsize=128): bounded cache (LRU eviction)
DC5|@functools.wraps(wrapped)|stdlib|decorator|preserves __name__, __doc__, __qualname__, __module__, __dict__, __wrapped__ of original function when writing custom decorators|applied to wrapper function inside decorator: def decorator(func): @wraps(func) def wrapper(*args, **kwargs): ...|always use when writing decorators; without it: decorated function loses its name, docstring, and introspection attributes; the standard decorator boilerplate
DC6|@dataclasses.dataclass|stdlib (3.7+)|class|auto-generates __init__, __repr__, __eq__, and optionally __hash__, comparison, __slots__|class decorator; analyzes class body for annotated attributes; generates methods based on field definitions and decorator parameters|see CL10; most impactful decorator for reducing class boilerplate; options: frozen, order, slots, kw_only, match_args, eq, repr, hash
DC7|@abc.abstractmethod|stdlib|method|marks method as abstract: subclasses must implement|used with ABC base class; class cannot be instantiated if it has unresolved abstract methods|can decorate: methods, class methods, static methods, properties; stack: @abstractmethod under @classmethod/@property
DC8|@contextlib.contextmanager|stdlib|generator function|converts generator function to context manager (with statement); yield is the enter/exit split point|def ctx(): setup; try: yield value; finally: cleanup; with ctx() as v: ... → setup runs, v gets yielded value, body runs, cleanup runs in finally|simplest way to create context managers without writing __enter__/__exit__; try/finally around yield ensures cleanup even on exception

# context_managers(id|name|type|protocol|creation|behavior|notes)
CM1|with statement|resource management|with expr as var: ...; calls __enter__() on entry, __exit__() on exit (even if exception)|class with __enter__ and __exit__; or generator with @contextmanager; or contextlib utilities|__enter__ returns value (bound to as var); __exit__(self, exc_type, exc_val, exc_tb) called on exit: return True suppresses exception; return False propagates|most important resource management pattern; use for: files (auto-close), locks (auto-release), database transactions (auto-commit/rollback), temporary state changes; ALWAYS use with for files: with open('f') as f: ... → file closed even on exception
CM2|contextlib.suppress|stdlib utility|from contextlib import suppress; with suppress(FileNotFoundError): os.remove('f')|suppresses specified exception types; equivalent to try: ... except FileNotFoundError: pass but cleaner|use sparingly: suppressing exceptions hides errors; only suppress expected, benign exceptions
CM3|contextlib.ExitStack|stdlib utility|stack = ExitStack(); stack.enter_context(ctx1); stack.enter_context(ctx2)|manages dynamic number of context managers; cleanup in LIFO order; also: stack.callback(func) for arbitrary cleanup functions|use when number of context managers is dynamic (opening N files where N determined at runtime); with ExitStack() as stack: files = [stack.enter_context(open(f)) for f in filenames]

# concurrency(id|name|type|parallelism|use_case|api|limitations|notes)
CO1|threading|OS threads|no CPU parallelism (GIL: Global Interpreter Lock prevents multiple threads from executing Python bytecode simultaneously; only one thread runs Python at a time)|I/O-bound tasks: network requests, file I/O, database queries; GIL released during I/O operations → true I/O concurrency|import threading; t = threading.Thread(target=func, args=()); t.start(); t.join(); Lock, RLock, Semaphore, Event, Condition, Barrier for synchronization|GIL prevents CPU parallelism; race conditions still possible (GIL doesn't make Python thread-safe: dict operations are atomic but compound operations are not); GIL released in: I/O, time.sleep, many C extensions (NumPy releases GIL)|free-threading mode (PEP 703, 3.13+): experimental no-GIL build; per-object locking replaces GIL; opt-in; not yet default; will fundamentally change Python concurrency if adopted
CO2|multiprocessing|OS processes|true CPU parallelism (separate interpreter per process; each has own GIL)|CPU-bound tasks: numerical computation, data processing, image processing, anything that needs multiple cores|import multiprocessing; p = Process(target=func, args=()); p.start(); p.join(); Pool for worker pools; Queue, Pipe, Value, Array for IPC|process startup cost (fork/spawn: 50–200ms); IPC overhead (serialization: pickle); memory overhead (each process has full interpreter copy; ~30 MB baseline); shared state is complex (Manager, shared memory)|process pool: with Pool(4) as p: results = p.map(func, data); ProcessPoolExecutor (concurrent.futures): simpler API; shared memory (3.8+): multiprocessing.shared_memory avoids pickling for large arrays
CO3|asyncio|cooperative coroutines|no CPU parallelism (single thread; concurrency via event loop; coroutines yield control at await points)|I/O-bound with many concurrent connections: web servers, web scraping, database connection pools, chat systems, microservices|import asyncio; async def coro(): await asyncio.sleep(1); asyncio.run(main()); await, async for, async with; gather(), TaskGroup (3.11+), create_task()|single thread: CPU-bound work blocks entire event loop; mixing sync and async code is complex (loop.run_in_executor() for sync calls from async); library ecosystem must be async-compatible (aiohttp, asyncpg, etc.)|event loop runs coroutines cooperatively: coroutine runs until it hits await → suspends → event loop runs another ready coroutine; await = yield control to event loop; TaskGroup (3.11+): structured concurrency (all tasks complete or all are cancelled on exception: replaces gather for most uses)
CO4|concurrent.futures|high-level API|depends on executor (Thread or Process)|unified API for both thread-based and process-based parallelism|from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor; with ThreadPoolExecutor(max_workers=4) as ex: futures = [ex.submit(func, arg) for arg in args]; for f in as_completed(futures): result = f.result()|same limitations as underlying threading or multiprocessing|simplest parallel execution API; Future object represents pending result; executor.map(func, iterable) for simple parallel map; as_completed() for results as they finish (not in submission order); recommended entry point for simple parallelism

# type_hints(id|name|syntax|purpose|checked_by|notes)
TH1|variable annotation|x: int = 5; name: str|annotates variable type; no runtime effect; informational|mypy, pyright, pytype (static type checkers)|annotations stored in __annotations__ dict of module/class; not enforced at runtime; PEP 526 (3.6+)
TH2|function annotation|def f(x: int, y: str = 'hi') -> bool: ...|annotates parameter and return types|static type checkers; IDE autocompletion|PEP 3107 (annotations), PEP 484 (type hints); return type → after arrow; no runtime enforcement; annotations are expressions evaluated at function definition (or from __future__ import annotations for lazy evaluation PEP 563: strings, deferred)
TH3|generic types|list[int], dict[str, int], tuple[int, ...], set[str], Optional[int], Union[int, str]|parameterized container types|static type checkers|PEP 585 (3.9+): builtin generics (list[int] instead of typing.List[int]); PEP 604 (3.10+): X \| Y instead of Union[X, Y]; Optional[X] = X \| None; tuple[int, ...] = homogeneous variable-length tuple; tuple[int, str] = fixed two-element
TH4|TypeVar|T = TypeVar('T'); def f(x: T) -> T: ...|type variable for generic functions; output type related to input type|static type checkers|constrained TypeVar: T = TypeVar('T', int, float); bound TypeVar: T = TypeVar('T', bound=Comparable); PEP 695 (3.12+): def f[T](x: T) -> T: ... (new syntax, no explicit TypeVar creation)
TH5|Protocol|class Drawable(Protocol): def draw(self) -> None: ...|structural subtyping: any class implementing the required methods satisfies the Protocol without explicit inheritance|mypy, pyright|PEP 544 (3.8+); duck typing with static type checking; runtime_checkable decorator enables isinstance() checks (checks method existence, not signatures); preferred over ABCs when you want structural (not nominal) subtyping
TH6|TypeAlias / type statement|Vector = list[float] (3.9); type Vector = list[float] (3.12+)|creates type alias for readability|static type checkers|PEP 613 (TypeAlias annotation, 3.10); PEP 695 (type statement, 3.12): type Vector = list[float]; cleaner than assignment-based alias; forward references resolved lazily

# magic_methods(id|name|signature|purpose|invoked_by|notes)
MM1|__init__|__init__(self, ...)|instance initialization|object creation: obj = Class(...); after __new__ creates instance|must not return value; mutable default argument gotcha applies
MM2|__new__|__new__(cls, ...)|instance creation (class method)|called before __init__; returns new instance; override for immutable types or singleton|rarely overridden; __new__ must return instance (usually super().__new__(cls)); if returns different type, __init__ not called
MM3|__repr__|__repr__(self) -> str|developer-friendly string representation; should be unambiguous; ideally eval-able|repr(obj), interactive interpreter display, debugger|convention: return string that could recreate object: f'{self.__class__.__name__}({self.x!r}, {self.y!r})'; if impossible, use <ClassName details> format
MM4|__str__|__str__(self) -> str|user-friendly string representation; human-readable|str(obj), print(obj), f'{obj}'|if __str__ not defined, falls back to __repr__; define both: __repr__ for debugging, __str__ for display
MM5|__eq__|__eq__(self, other) -> bool|equality comparison|==; also affects hashing (if __eq__ defined without __hash__, class becomes unhashable)|default: identity comparison (same as is); if you define __eq__, define __hash__ too (or set __hash__ = None to make unhashable explicitly); dataclass auto-generates both
MM6|__hash__|__hash__(self) -> int|hash value for use in dicts and sets|hash(obj); dict key lookup; set membership|must be consistent with __eq__: objects that compare equal MUST have same hash; unhashable objects: set __hash__ = None; mutable objects should generally not be hashable
MM7|__lt__, __le__, __gt__, __ge__|__lt__(self, other) -> bool (etc.)|ordering comparisons|<, <=, >, >=; sorted(), min(), max()|@functools.total_ordering: define __eq__ and one ordering method → rest auto-generated; not auto-generated by default; return NotImplemented if comparison not supported (allows reflected operation on other operand)
MM8|__add__, __radd__, __iadd__|__add__(self, other)|addition; reverse addition; in-place addition|+; reflected: other + self when other's __add__ returns NotImplemented; +=|pattern: try __add__; if NotImplemented → try other.__radd__; __iadd__ for mutable types (list: extends in place); for immutable: __iadd__ not defined → += creates new object via __add__
MM9|__len__|__len__(self) -> int|length|len(obj); bool(obj) if __bool__ not defined (truthy if len > 0)|must return non-negative integer; defines truthiness if __bool__ not defined
MM10|__getitem__, __setitem__, __delitem__|__getitem__(self, key)|subscription (indexing/slicing)|obj[key]; obj[key] = value; del obj[key]|key can be: int (index), slice (slice object), str (mapping), tuple (multi-dimensional: numpy); if __getitem__ defined, object is iterable (fallback iteration protocol: calls __getitem__ with 0, 1, 2, ... until IndexError)
MM11|__iter__, __next__|__iter__(self) -> iterator; __next__(self) -> value|iteration protocol|for x in obj; iter(obj); next(obj)|see IG1, IG2; __iter__ returns iterator (often self for iterator classes); __next__ returns next value or raises StopIteration
MM12|__contains__|__contains__(self, item) -> bool|membership test|item in obj|if not defined: falls back to iteration (__iter__); O(1) for dict/set (hash-based); O(n) for list (linear scan)
MM13|__call__|__call__(self, *args, **kwargs)|makes instance callable like a function|obj(args)|callable(obj) returns True; used for: functor objects, stateful functions, factory patterns, decorator classes
MM14|__enter__, __exit__|__enter__(self); __exit__(self, exc_type, exc_val, exc_tb)|context manager protocol|with obj as var: ...|see CM1; __enter__ returns value for as var; __exit__ return True to suppress exception
MM15|__getattr__, __getattribute__|__getattr__(self, name); __getattribute__(self, name)|attribute access customization|obj.attr|__getattribute__: called on EVERY attribute access (including existing); __getattr__: called only when normal lookup fails (fallback); don't confuse: __getattr__ = fallback (safe); __getattribute__ = intercept all (dangerous: easy to cause infinite recursion)
MM16|__class_getitem__|__class_getitem__(cls, item)|class subscription|Class[item] (e.g., list[int], dict[str, int])|PEP 560 (3.7+); enables generic type hint syntax on classes: class MyList: def __class_getitem__(cls, item): ...

# exceptions(id|name|parent|when_raised|common_cause|notes)
EX1|BaseException|—|base of all exceptions|never caught directly in normal code|hierarchy: BaseException → Exception (catch-all for normal errors) + SystemExit, KeyboardInterrupt, GeneratorExit (should NOT be caught by except Exception)
EX2|Exception|BaseException|base of all non-system-exiting exceptions|catching Exception catches all normal errors but not SystemExit, KeyboardInterrupt|custom exceptions should inherit from Exception (or a subclass), not BaseException
EX3|ValueError|Exception|operation receives correct type but inappropriate value|int('abc'), math.sqrt(−1)|often confused with TypeError; ValueError = right type, wrong value; TypeError = wrong type
EX4|TypeError|Exception|operation on inappropriate type|1 + 'a', len(42), calling non-callable|most common beginner error; also raised by wrong number of function arguments
EX5|KeyError|LookupError|dict key not found|d['missing_key']|use d.get(key, default) to avoid; or check key in d first; or use defaultdict
EX6|IndexError|LookupError|sequence index out of range|l[100] when len(l) < 101|negative indexing: l[−1] = last element; l[−100] raises IndexError if len < 100
EX7|AttributeError|Exception|attribute not found on object|obj.nonexistent_method()|often caused by None (NoneType has no method X); use hasattr(obj, 'attr') or try/except; getattr(obj, 'attr', default)
EX8|ImportError / ModuleNotFoundError|Exception|module or name cannot be imported|import nonexistent; from module import nonexistent_name|ModuleNotFoundError (3.6+) is subclass of ImportError; check: module installed (pip list), virtual environment activated, __init__.py exists (packages), sys.path correct
EX9|StopIteration|Exception|iterator exhausted|next(iterator) when no more items; for loop handles this automatically|raised by __next__; caught automatically by for loop; don't catch manually in normal code; generator return value is StopIteration.value
EX10|FileNotFoundError|OSError|file does not exist|open('nonexistent.txt')|subclass of OSError (3.3+); other file OSError subclasses: PermissionError, IsADirectoryError, FileExistsError
EX11|RuntimeError|Exception|generic runtime error; also: coroutine/generator misuse|send to unstarted generator; await outside coroutine; recursion limit (RecursionError subclass of RuntimeError)|catch-all when no more specific exception fits; try to use more specific exceptions

# stdlib_core(id|name|module|purpose|key_functions|notes)
SL1|os|os|operating system interface: file/dir operations, environment variables, process management|os.path.join(), os.listdir(), os.makedirs(), os.environ, os.getcwd(), os.getpid(), os.walk()|use pathlib (SL2) for most path operations (more Pythonic); os still needed for: environment, process, low-level fd operations
SL2|pathlib|pathlib|object-oriented filesystem paths|Path('dir') / 'file.txt', p.exists(), p.is_file(), p.read_text(), p.write_text(), p.mkdir(), p.glob('*.py'), p.stem, p.suffix, p.parent|PEP 428 (3.4+); preferred over os.path for path manipulation; / operator joins paths; most stdlib functions accept Path objects (3.6+)
SL3|sys|sys|interpreter interaction: argv, path, stdin/stdout/stderr, exit, version, platform, recursion limit|sys.argv, sys.path, sys.stdin, sys.stdout, sys.exit(), sys.getrecursionlimit(), sys.getsizeof(), sys.version_info, sys.platform|sys.path: list of directories searched for modules; sys.argv[0]: script name; sys.exit(0): clean exit; sys.exit(1): error exit
SL4|json|json|JSON encoding/decoding|json.dumps(obj), json.loads(s), json.dump(obj, f), json.load(f)|serializes: dict, list, str, int, float, bool, None; does NOT serialize: set, tuple (becomes list), datetime, custom objects (need default= or custom encoder); indent=2 for pretty printing; ensure_ascii=False for Unicode
SL5|re|re|regular expressions|re.search(pattern, string), re.match(), re.findall(), re.sub(), re.compile(), re.split()|raw strings for patterns: r'\d+'; match: beginning only; search: anywhere; findall: all non-overlapping matches; groups: (?P<name>pattern) for named groups; re.VERBOSE flag for readable patterns
SL6|datetime|datetime|date and time manipulation|datetime.now(), datetime.utcnow(), timedelta(days=1), datetime.strftime('%Y-%m-%d'), datetime.strptime(s, fmt), date, time, timezone|aware vs naive: naive datetime has no timezone (dangerous: ambiguous); always use aware datetimes: datetime.now(timezone.utc); third-party: pendulum, arrow, python-dateutil for easier timezone handling; PEP 615 (3.9+): zoneinfo module replaces pytz
SL7|logging|logging|structured logging (not print debugging)|logging.basicConfig(level=logging.INFO); logger = logging.getLogger(__name__); logger.info(), logger.warning(), logger.error(), logger.exception()|hierarchy: DEBUG < INFO < WARNING < ERROR < CRITICAL; handlers: StreamHandler (console), FileHandler (file), RotatingFileHandler (size-limited); formatters: control output format; always use logging instead of print for any code that might run in production
SL8|collections|collections|specialized container types|defaultdict(factory), Counter(iterable), OrderedDict (less needed since dict is ordered 3.7+), deque(iterable), namedtuple('Name', fields), ChainMap|defaultdict: auto-creates missing keys with factory; Counter: frequency counting (Counter('abracadabra') → {'a': 5, 'b': 2, ...}); deque: O(1) append/pop both ends (vs list: O(n) at left end); namedtuple: lightweight immutable record (largely replaced by dataclass but still useful for simple cases)

# packaging(id|name|type|purpose|configuration|notes)
PK1|pip|package manager|installs packages from PyPI and other sources|pip install package; pip install -r requirements.txt; pip install -e . (editable); pip freeze > requirements.txt|default package installer; use with virtual environment always; pip install --upgrade pip; pip cache purge; pip install package==1.2.3 (pin version)
PK2|venv|virtual environment|creates isolated Python environment with own site-packages|python -m venv .venv; source .venv/bin/activate (Linux/Mac); .venv\Scripts\activate (Windows)|always use virtual environments (never install into system Python); .venv is conventional directory name; .gitignore should exclude .venv; deactivate to exit
PK3|pyproject.toml|project configuration (PEP 621)|single configuration file for project metadata, dependencies, build system, and tool configuration|[project] name, version, dependencies, requires-python; [build-system] requires, build-backend; [tool.mypy], [tool.pytest], [tool.ruff] etc.|replaces setup.py, setup.cfg, MANIFEST.in for most projects; PEP 517/518 (build system), PEP 621 (metadata); build backends: setuptools, flit, hatchling, maturin (Rust extensions), pdm-backend
PK4|wheel|distribution format|pre-built binary distribution; faster install (no compilation); .whl file|pip install builds wheel from sdist if no wheel available; pip wheel . creates wheel|.whl is zip file with specific naming convention; pure-Python: universal wheel (py3-none-any); C extension: platform-specific wheel (cp312-cp312-linux_x86_64); bdist_wheel target

# antipatterns(id|name|type|code_pattern|problem|correct_pattern|notes)
AP1|mutable default argument|function definition|def f(x, items=[]): items.append(x); return items|default list shared across all calls: f(1) → [1]; f(2) → [1, 2] (not [2])|def f(x, items=None): items = items if items is not None else []; ...|default value evaluated ONCE at definition time; mutable objects (list, dict, set) are shared; None sentinel + conditional initialization is the standard fix
AP2|bare except|exception handling|try: ... except: ...|catches EVERYTHING: including SystemExit (sys.exit()), KeyboardInterrupt (Ctrl+C), and GeneratorExit; makes debugging nearly impossible|try: ... except Exception as e: ... (catches normal errors, not system exits)|at minimum use except Exception; better: catch specific exception types; except BaseException is equally bad; PEP 8: never use bare except
AP3|using == for None|comparison|if x == None:|calls __eq__; may return unexpected results for objects with custom __eq__; None is singleton|if x is None: / if x is not None:|is checks identity (correct for singletons: None, True, False); == checks equality (can be overridden); PEP 8: always use is/is not for None
AP4|from module import *|imports|from os import *; from math import *|namespace pollution; name collisions; unreadable (can't tell where name comes from); breaks static analysis tools|from os import path, environ (import specific names); or import os (use os.path, os.environ)|acceptable only in interactive interpreter or __init__.py for careful package API re-export; __all__ in module controls what * exports but still bad practice for consumers
AP5|using list as stack with index 0|data structure misuse|stack = []; stack.insert(0, item); stack.pop(0)|O(n) for insert(0)/pop(0) because all elements shift|use collections.deque for O(1) appendleft/popleft; or use list as stack from right end: append/pop (O(1))|list: O(1) at right end (append/pop); O(n) at left end (insert(0)/pop(0)); deque: O(1) at both ends
AP6|string concatenation in loop|performance|result = ''; for s in strings: result += s|creates new string object each iteration: O(n²) total for n strings (each += copies entire string)|result = ''.join(strings) → O(n) total|str is immutable: += creates new str each time; ''.join() allocates once; for small n: doesn't matter; for large n (thousands of strings): dramatic difference; also: use list + join for building strings: parts = []; parts.append(s); ''.join(parts)
AP7|catching exception and passing silently|error hiding|try: ... except SomeError: pass|error is silently swallowed; bugs become invisible; program continues with corrupt state|at minimum log the error: except SomeError: logger.exception('...'); or re-raise with additional context: except SomeError as e: raise RuntimeError('context') from e|acceptable only for truly expected and benign exceptions (e.g., file not found when file is optional → contextlib.suppress(FileNotFoundError))
AP8|global state mutation|design|global_list = []; def f(): global_list.append(item)|hidden dependencies; non-reentrant; testing nightmare; concurrency bugs|pass state as arguments; return results; use classes to encapsulate state; dependency injection|global keyword needed only for reassignment (global x; x = 5); mutation doesn't require global keyword (global_list.append() works without global declaration — the NAME is not rebound, the OBJECT is mutated)

# concepts(id|name|definition|category)
PC1|duck typing|if it walks like a duck and quacks like a duck, it's a duck; check behavior (methods/attributes) not type; don't check isinstance: just call the method and handle AttributeError (or let it propagate)|philosophy
PC2|EAFP (easier to ask forgiveness than permission)|try the operation and handle the exception rather than checking preconditions first; try: d[key] except KeyError: ... rather than if key in d: d[key]|philosophy
PC3|LBYL (look before you leap)|check preconditions before operating: if key in d: d[key]; opposite of EAFP; sometimes appropriate (when exception is expensive or when checking is cheaper)|philosophy
PC4|Pythonic|code that follows Python idioms and conventions; uses language features as intended; readable by experienced Python developers; follows PEP 8 style guide; prefers comprehensions over map/filter; uses context managers; is explicit rather than implicit|philosophy
PC5|PEP 8|style guide: 4-space indentation; 79-char line length (99 for code, 72 for docstrings); snake_case for functions/variables; PascalCase for classes; UPPER_CASE for constants; two blank lines between top-level definitions; one between methods; imports at top (stdlib, third-party, local)|style
PC6|Zen of Python|import this; guiding principles: Beautiful is better than ugly; Explicit is better than implicit; Simple is better than complex; Complex is better than complicated; Flat is better than nested; Readability counts; Errors should never pass silently; There should be one obvious way to do it|philosophy
PC7|GIL (Global Interpreter Lock)|CPython mutex that protects access to Python objects, preventing multiple threads from executing Python bytecode simultaneously; exists because CPython's memory management (reference counting) is not thread-safe; released during I/O and C extensions; PEP 703 (3.13+): free-threading builds remove GIL experimentally|runtime
PC8|reference counting|CPython primary GC: each object tracks how many references point to it (ob_refcnt); when count reaches 0, object is deallocated immediately; deterministic deallocation (unlike tracing GC); supplemented by cyclic GC for reference cycles (objects referencing each other)|runtime
PC9|descriptor protocol|objects that define __get__, __set__, __delete__ control attribute access on the class that owns them; descriptors enable: property, classmethod, staticmethod, __slots__, method binding; data descriptor (has __set__ or __delete__): takes precedence over instance __dict__; non-data descriptor (only __get__): instance __dict__ takes precedence|data_model
PC10|metaclass|class of a class; default metaclass is type; custom metaclass: class Meta(type): ...; class MyClass(metaclass=Meta): ...; __init_subclass__ (3.6+: simpler alternative for many metaclass uses); metaclass controls class creation: __new__ creates class object, __init__ initializes it|data_model
PC11|import system|finding and loading modules: sys.meta_path contains finders (PathFinder, etc.); finder returns loader (or spec); loader creates module object, executes module code, and installs in sys.modules; __import__ is the builtin; importlib is the stdlib interface; relative imports (.module) vs absolute; circular imports: possible but fragile (import at function level to break cycles)|runtime
PC12|virtual environment|isolated Python installation with own site-packages directory; created by venv or virtualenv; allows project-specific dependency versions; avoids conflicts between projects; activated by modifying PATH; pip installs into active venv's site-packages|packaging

# relationships(from|rel|to)
# data model foundations
DO1|enables|DM1,DM2
DO2|requires|DO1
DO3|requires|DO2
DO4|requires|DO3
# type hierarchy
BT4|specializes|BT1
BT1|part_of|DM1
BT2|part_of|DM1
BT5|part_of|DM1
BT8|part_of|DM1
BT9|part_of|DM1
BT10|part_of|DM1
BT11|part_of|DM1
BT13|part_of|DM1
BT14|part_of|DM1
# operator → type
OP1|requires|BT1,BT2
OP4|requires|BT1,BT2,BT5,BT8
OP6|enables|BT11
OP8|enables|BT11,BT10
OP9|requires|MM5,MM7
OP11|requires|BT4
OP12|requires|BT4
# control flow → iteration
CF2|requires|IG1
CF7|requires|DM3
CF8|requires|EX2
# function features
FU1|enables|DM4
FU2|specializes|FU1
FU3|extends|FU1
FU4|extends|FU1
FU5|extends|FU1
FU6|extends|FU1
FU7|requires|DO4
FU8|requires|FU1,MM13
FU9|enables|IG3
FU10|requires|FU1
# class features
CL1|enables|DM5
CL2|part_of|CL1
CL3|requires|CL1
CL4|requires|DC2
CL5|requires|DC1
CL6|requires|DC3,PC9
CL7|enables|CL8
CL9|enables|DM8
CL10|requires|DC6
CL11|requires|DC7
# iterator/generator chain
IG1|enables|CF2,CP1,CP2,CP3,CP4
IG2|specializes|IG1
IG3|specializes|IG2
IG4|specializes|IG3
IG5|extends|IG3
IG6|extends|IG3
# comprehension → type
CP1|enables|BT8
CP2|enables|BT10
CP3|enables|BT11
CP4|enables|IG3
# decorator → target
DC1|enables|CL5
DC2|enables|CL4
DC3|enables|CL6
DC4|enables|FU1
DC5|enables|FU8
DC6|enables|CL10
DC7|enables|CL11
DC8|enables|CM1
# context manager
CM1|requires|MM14
CM2|specializes|CM1
CM3|extends|CM1
# concurrency
CO1|part_of|DM7
CO2|part_of|DM7
CO3|part_of|DM7
CO4|enables|CO1,CO2
PC7|prevents|CO1
CO2|prevents|PC7
# type hints
TH1|part_of|DM2
TH2|part_of|DM2
TH3|extends|TH1,TH2
TH4|enables|TH3
TH5|enables|PC1
TH6|extends|TH3
# magic methods → protocol
MM1|enables|CL2
MM3|enables|BT5
MM4|enables|BT5
MM5|enables|OP9
MM6|enables|BT10,BT11
MM8|enables|OP4
MM9|enables|BT8,BT10
MM10|enables|BT8,BT10
MM11|enables|IG1,IG2
MM12|enables|OP9
MM13|enables|FU8
MM14|enables|CM1
MM15|enables|DO2
# exception hierarchy
EX1|generalizes|EX2
EX2|generalizes|EX3,EX4,EX5,EX6,EX7,EX8,EX11
EX5|specializes|EX2
EX6|specializes|EX2
EX9|enables|IG2
EX10|specializes|EX2
# packaging
PK1|requires|PK2
PK3|enables|PK1,PK4
PK2|enables|PC12
# antipattern → concept
AP1|prevents|FU1
AP2|prevents|CF8
AP3|prevents|BT13
AP4|prevents|DO3
AP6|prevents|BT5
AP8|prevents|FU1
# concept foundations
PC1|enables|DM2
PC2|enables|CF8
PC4|requires|PC5,PC6
PC7|part_of|DM7,DM8
PC8|part_of|DM8
PC9|enables|DC1,DC2,DC3,CL6
PC10|enables|CL1
PC11|enables|DM6
PC12|enables|PK2

# section_index(section|title|ids)
1|Domains|DM1-DM10
2|Data Model|DO1-DO4
3|Builtin Types|BT1-BT15
4|Operators|OP1-OP15
5|Control Flow|CF1-CF8
6|Functions|FU1-FU10
7|Classes and OOP|CL1-CL11
8|Iterators and Generators|IG1-IG6
9|Comprehensions|CP1-CP4
10|Decorators|DC1-DC8
11|Context Managers|CM1-CM3
12|Concurrency|CO1-CO4
13|Type Hints|TH1-TH6
14|Magic Methods|MM1-MM16
15|Exceptions|EX1-EX11
16|Standard Library (Core)|SL1-SL8
17|Packaging|PK1-PK4
18|Antipatterns|AP1-AP8
19|Core Concepts|PC1-PC12
20|Relationships|all

# decode_legend
id_prefixes: DM=domain, DO=data_model, BT=builtin_type, OP=operator, CF=control_flow, FU=function, CL=class, IG=iterator_generator, CP=comprehension, DC=decorator, CM=context_manager, CO=concurrency, TH=type_hint, MM=magic_method, EX=exception, SL=stdlib, PK=packaging, AP=antipattern, PC=concept
rel_types: enables|requires|prevents|specializes|generalizes|part_of|contains|follows|precedes|instance_of|determined_by|equivalent_to|extends|derived_from|composed_of
notation: _fk=foreign key; ~=approximate; PEP=Python Enhancement Proposal; CPython=reference implementation (C); GIL=Global Interpreter Lock; MRO=method resolution order; ABC=abstract base class; LEGB=Local-Enclosing-Global-Builtin (scope resolution); EAFP=easier to ask forgiveness than permission; LBYL=look before you leap; YAGNI=you ain't gonna need it; OOP=object-oriented programming; API=application programming interface; I/O=input/output; IPC=inter-process communication; FIFO=first in first out; LIFO=last in first out; LRU=least recently used; O(1)=constant time; O(n)=linear time; O(n²)=quadratic time; IEEE 754=floating-point standard; UTF-8=Unicode Transformation Format 8-bit; UCS=Universal Character Set; JSON=JavaScript Object Notation; CSV=comma-separated values; SQL=Structured Query Language; HTTP=Hypertext Transfer Protocol; TCP=Transmission Control Protocol; UDP=User Datagram Protocol; SSL/TLS=Secure Sockets Layer/Transport Layer Security; PyPI=Python Package Index; pip=package installer for Python; venv=virtual environment module; REPL=read-eval-print loop; AST=abstract syntax tree; f-string=formatted string literal; NaN=not a number; inf=infinity; regex=regular expression; PEP 8=style guide; PEP 20=Zen of Python; PEP 484=type hints; PEP 526=variable annotations; PEP 557=dataclasses; PEP 572=walrus operator; PEP 585=builtin generics; PEP 604=union types X|Y; PEP 612=ParamSpec; PEP 621=pyproject.toml metadata; PEP 634=structural pattern matching; PEP 695=type parameter syntax; PEP 703=free-threading
confidence: all specifications from official Python documentation (docs.python.org) for Python 3.12/3.13; CPython implementation details noted where relevant; behavioral descriptions verified against CPython reference implementation; all facts at reference_python confidence level
scope: Python 3 language specification and standard library core; covers data model, types, operators, control flow, functions, classes, iterators, generators, decorators, context managers, concurrency, type hints, exceptions, packaging, and key standard library modules; CPython implementation details noted where they affect practical usage; excludes: exhaustive standard library coverage (200+ modules), third-party package details (numpy, pandas, django, flask, etc.), Python 2 compatibility, detailed C API, and GUI frameworks; focused on language mechanics and idiomatic usage patterns

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
