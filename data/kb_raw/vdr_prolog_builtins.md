# VDR-PROLOG PYTHON PROTOTYPE — STAGE 5 CUMULATIVE API — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: modules → functions → data_structures → categories → relationships → section_index

# modules(id|module|path|description|function_count)
MO1|types|core/types.py|VDRFraction promotion, arithmetic dispatch, type predicates|5
MO2|errors|core/errors.py|VDRError + Result type|2
MO3|knowledge_base|kb/knowledge_base.py|KB CRUD|3
MO4|fact_store|kb/fact_store.py|fact assert/retract/query|4
MO5|rule_engine|kb/rule_engine.py|unification, substitution, rule query with backtracking|5
MO6|working_data|kb/working_data.py|key-value bindings with scope inheritance|5
MO7|constraint_engine|kb/constraint_engine.py|constraint check/enforce/manage|6
MO8|scope_resolver|kb/scope_resolver.py|scope chain construction and scoped queries|5
MO9|registry|path/registry.py|PathRegistry: dotted path ↔ ID mapping|5
MO10|resolver|path/resolver.py|path navigation: parent, children, ancestors, depth, common ancestor|6
MO11|mount|path/mount.py|KB mount/unmount with cycle detection|4
MO12|parser|command/parser.py|CMD: token parsing from mixed text|2
MO13|executor|command/executor.py|command dispatch and chain execution|2
MO14|scratchpad|command/scratchpad.py|ring buffer workspace|3
MO15|iose_registry|iose/registry.py|BuiltinRegistry: ID/name → BuiltinDef mapping|6
MO16|principles|iose/principles.py|OSO principles, knowability, priority|4
MO17|validator|iose/validator.py|type compatibility, side effect preview, contract verification|3
MO18|arithmetic|primitives/arithmetic.py|VDR fraction arithmetic: add, sub, mul, div, neg, abs, pow, reciprocal|8
MO19|comparison|primitives/comparison.py|VDR comparison: compare, equal, less, min, max, sign, zero/pos/neg tests|10
MO20|rounding|primitives/rounding.py|floor, ceil, round, truncate, numerator, denominator, simplify|7
MO21|list_aggregates|primitives/list_aggregates.py|sum, product, mean, dot product, weighted sum, harmonic, alternating|8
MO22|text|primitives/text.py|string operations: concat, join, split, slice, contains, replace, etc.|17
MO23|collections|primitives/collections.py|list operations: append, head, tail, map, filter, sort, group, zip, etc.|36
MO24|sets|primitives/sets.py|set operations: union, intersection, difference, power set, subset tests|14
MO25|mappings|primitives/mappings.py|dict operations: get, set, merge, keys, values, filter, invert|15
MO26|conversion|primitives/conversion.py|type conversion: to_string, to_number, JSON, CSV, fraction formatting|14
MO27|logic|primitives/logic.py|control flow: if/else, case, for_each, while, try/catch, findall, aggregate|11
MO28|integer_ops|primitives/integer_ops.py|integer arithmetic + bitwise: add through popcount|22
MO29|active_arithmetic|primitives/active_arithmetic.py|remainder-aware active fraction operations|5
MO30|structure_ops|primitives/structure_ops.py|lift, rebase, scalar projection|3
MO31|number_theory|primitives/number_theory.py|gcd, lcm, mod_pow, mod_inv, prime test, factorial, binomial, fibonacci, totient, CRT|13
MO32|linalg|primitives/linalg_builtins.py|vector + matrix: new, add, mul, dot, det, inv, solve, rank, gram-schmidt|26
MO33|statistics|primitives/statistics.py|mean, variance, median, mode, percentile, Bayes, softmax, entropy, CDF, joint/marginal/conditional|16
MO34|time_ops|primitives/time_ops.py|date from YMD, diff, day-of-week, leap year, time from HMS|10
MO35|identity|primitives/identity.py|hash, base64, hex, CRC32, UUID from seed|8
MO36|graphs|primitives/graphs.py|BFS, DFS, shortest path, components, topo sort, cycle detect, MST, pagerank|13
MO37|qbasis|primitives/qbasis.py|QBasis arithmetic, to/from fraction, constants, precision|7
MO38|functional|primitives/functional.py|transcendentals: sqrt, exp, log, sin, cos via Newton/Taylor + remainder constructors|8
MO39|discrete_calculus|primitives/discrete_calculus.py|finite differences, Riemann, trapezoidal, Richardson extrapolation|6
MO40|denom_mgmt|primitives/denom_mgmt.py|denominator bits/digits, reproject, budget check, precision state|5
MO41|polynomial|primitives/polynomial.py|poly eval, add, mul, div, GCD, derivative, integral, Lagrange interpolation|8
MO42|finite_field|primitives/finite_field.py|GF(p) add, mul, inv, pow|4
MO43|markov|primitives/markov.py|steady state, step, n-step|3
MO44|graph_math|primitives/graph_math.py|adjacency matrix power, exact pagerank|2
MO45|counter|data_primitives/counter.py|bounded counter: create, inc, dec, add, get, reset, set|7
MO46|lock|data_primitives/lock.py|named lock: create, acquire, release, check, holder, force_release|6
MO47|queue|data_primitives/queue.py|bounded FIFO: create, push, pop, peek, size, empty, full, clear, to_list|9
MO48|stack|data_primitives/stack.py|bounded LIFO: create, push, pop, peek, size, empty, clear, to_list|8
MO49|lru|data_primitives/lru.py|LRU cache: create, push, get, peek, contains, size, clear, evict|8
MO50|ring_buffer|data_primitives/ring_buffer.py|ring buffer: create, write, read_all, read_last, size, clear|6
MO51|bitset|data_primitives/bitset.py|fixed-width bitset: create, set, clear, test, count, all, any, reset, to_list|9
MO52|snapshot|session/snapshot.py|capture live state, create/restore snapshot|3
MO53|clone|session/clone.py|clone/kill session|2
MO54|lifecycle|session/lifecycle.py|reset, list, diff, info|4
MO55|notebook|inference/notebook.py|create inference notebook, from template|2
MO56|loop|inference/loop.py|assess, formalize, execute_step, store_result, run_loop|5
MO57|confidence|inference/confidence.py|deductive/inductive/abductive/analogical confidence, chain propagation|5
MO58|provenance|inference/provenance.py|record evidence/conclusion, trace derivation, challenge conclusion|4
MO59|modes|inference/modes.py|run deductive/inductive/abductive/analogical inference|4
MO60|env_base|env/base.py|EnvironmentInterface: exec, upload, download, file R/W, process mgmt|10
MO61|env_local|env/local.py|LocalEnvironment — subprocess/os delegation|10
MO62|env_docker|env/docker.py|DockerEnvironment + container lifecycle|14
MO63|env_ssh|env/ssh.py|SSHEnvironment — SSH delegation|10
MO64|env_vm|env/vm.py|VMEnvironment — VM provider delegation|10
MO65|grants|ops/grants.py|GrantStore: add, verify, use, list effective|4
MO66|filesystem|ops/filesystem.py|grant-gated file operations: read, write, append, exists, list, mkdir, delete, move, copy, size, modified, glob, tree, diff, checksum|15
MO67|execution|ops/execution.py|grant-gated execution: python, shell, zig test, pytest, script|5
MO68|network|ops/network.py|grant-gated network: download, fetch, post, ping, DNS|5
MO69|process|ops/process.py|grant-gated process: start, poll, wait, kill, stdout, stderr, list|7
MO70|compilation|ops/compilation.py|grant-gated compile: python check, zig, C, rust|4
MO71|linting|ops/linting.py|grant-gated lint/analyze: python, zig, JSON, markdown, imports, complexity, dependencies, LOC|8
MO72|data_pipeline|lifecycle/data_pipeline.py|register source, prepare corpus, tokenize|3
MO73|training|lifecycle/training.py|initialize model, train step, checkpoint, restore|4
MO74|evaluation|lifecycle/evaluation.py|benchmark, eval suite, compare checkpoints|3
MO75|feedback|lifecycle/feedback.py|feedback round, pairwise judgment, agreement, reward model, DPO|5
MO76|deployment|lifecycle/deployment.py|deploy, canary, promote, rollback, retire|5
MO77|monitoring|lifecycle/monitoring.py|create monitoring, add/check watches, record metric, detect drift|5

# functions(id|module_ref|name|signature|purity|partiality|side_effects|notes)
# — core/types
FN1|MO1|promote_integer|(value:int) → VDRFraction|pure|total|none|v=value, d=1, r=0
FN2|MO1|promote_qbasis|(qb:QBasis) → VDRFraction|pure|total|none|v=qb.numerator, d=2^qb.exponent, r=0
FN3|MO1|dispatch_arithmetic|(left,right,operation:str) → (tag,VDRFraction,VDRFraction)|pure|total|none|determine path tag, promote operands
FN4|MO1|is_closed|(frac) → bool|pure|total|none|r==0
FN5|MO1|is_integer|(frac) → bool|pure|total|none|d==1 and r==0
# — core/errors
FN6|MO2|VDRError|(code,message,context)|—|—|none|base error type
FN7|MO2|Result|(value,error,ok)|—|—|none|unwrap(), unwrap_or(default), map(fn)
# — kb/knowledge_base
FN8|MO3|create_kb|(name,path,parent_id,owner) → KB|impure|total|KB store modified|assign ID
FN9|MO3|get_kb|(id\|str) → ?KB|pure|partial|none|by ID or path
FN10|MO3|delete_kb|(kb_id) → bool|impure|total|store modified, ID retired|detach from parent
# — kb/fact_store
FN11|MO4|assert_fact|(kb,fact) → bool|impure|total|kb.facts modified|skip if duplicate
FN12|MO4|retract_fact|(kb,predicate,args) → bool|impure|total|kb.facts modified|idempotent
FN13|MO4|query_facts|(kb,predicate,args) → [Fact]|pure|total|none|None wildcards
FN14|MO4|fact_exists|(kb,fact) → bool|pure|total|none|structural equality
# — kb/rule_engine
FN15|MO5|Binding|(bindings:Dict)|—|—|none|get(), bind(), merge()
FN16|MO5|unify|(term_a,term_b,bindings) → ?Binding|pure|partial|none|return updated bindings or None
FN17|MO5|substitute|(term,bindings) → term|pure|total|none|replace bound vars
FN18|MO5|query_rules|(kb,goal,max_depth=100) → [Binding]|pure|total|none|DFS with backtracking
FN19|MO5|query_rules_first|(kb,goal,max_depth) → ?Binding|pure|partial|none|first satisfying (cut)
# — kb/working_data
FN20|MO6|set_binding|(kb,key,value,turn)|impure|total|kb modified|—
FN21|MO6|get_binding|(kb,key,kb_store) → ?Any|pure|partial|none|walk parent chain
FN22|MO6|get_binding_local|(kb,key) → ?Any|pure|partial|none|local only
FN23|MO6|delete_binding|(kb,key) → bool|impure|total|kb modified|—
FN24|MO6|list_visible_bindings|(kb,kb_store) → Dict|pure|total|none|including inherited, local shadows
# — kb/constraint_engine
FN25|MO7|check_constraint|(kb,constraint,kb_store) → bool|pure|total|none|evaluate via rule engine
FN26|MO7|check_all_constraints|(kb,kb_store) → [Constraint]|pure|total|none|return violations
FN27|MO7|enforce_constraint|(constraint,kb) → str|impure|total|may log/block/raise|execute on_violation
FN28|MO7|add_constraint|(kb,constraint)|impure|total|kb.constraints modified|—
FN29|MO7|remove_constraint|(kb,name)|impure|total|kb.constraints modified|idempotent
FN30|MO7|enable_constraint|(kb,name)|impure|total|status→active|idempotent
FN31|MO7|suspend_constraint|(kb,name)|impure|total|status→suspended|idempotent
# — kb/scope_resolver
FN32|MO8|ScopeChain|(chain:[int],secondary:[int])|—|—|none|ordered KB IDs root-ward
FN33|MO8|build_scope_chain|(active_kb_id,kb_store) → ScopeChain|pure|total|none|walk parent_id links
FN34|MO8|scoped_query|(scope_chain,pred,args,kb_store) → [Fact]|pure|total|none|first-match-wins
FN35|MO8|scoped_query_all|(pred,args,kb_store) → [(str,Fact)]|pure|total|none|all KBs, tagged
FN36|MO8|resolve_binding_scoped|(scope_chain,key,kb_store) → ?Any|pure|partial|none|working data through chain
# — path/registry
FN37|MO9|PathRegistry|(path_to_id,id_to_path,next_id)|—|—|none|retired IDs never reused
FN38|MO9|register_path|(path) → int|impure|total|registry modified|assign if new
FN39|MO9|resolve|(path) → Result[int]|pure|partial|none|lookup ID
FN40|MO9|from_id|(id) → Result[str]|pure|partial|none|lookup path
FN41|MO9|exists|(path) → bool|pure|total|none|check registration
# — path/resolver
FN42|MO10|resolve_dotted_path|(path,registry) → Result[int]|pure|partial|none|absolute path → ID
FN43|MO10|path_parent|(path) → Result[str]|pure|partial|none|fails on "root"
FN44|MO10|path_children|(path,registry) → [str]|pure|total|none|direct children
FN45|MO10|path_ancestors|(path) → [str]|pure|total|none|parent to root
FN46|MO10|path_depth|(path) → int|pure|total|none|root=0
FN47|MO10|path_common_ancestor|(a,b) → str|pure|total|none|nearest shared
# — path/mount
FN48|MO11|create_mount|(mount_path,source_path,mode,registry,kb_store) → Result[Mount]|impure|total|mount added, path registered|—
FN49|MO11|remove_mount|(mount_path,kb_store)|impure|total|mount removed|idempotent
FN50|MO11|check_mount_cycle|(source,target,kb_store) → bool|pure|total|none|true=safe
FN51|MO11|resolve_through_mount|(mount,pred,args,kb_store) → [Fact]|pure|total|none|respects mode
# — command
FN52|MO12|parse_command_stream|(raw) → [str\|CommandToken]|pure|total|none|mixed text+CMD:
FN53|MO12|parse_single_command|(line) → Result[CommandToken]|pure|partial|none|one CMD: line
FN54|MO13|execute_command|(token,registry,path_reg,kb_store,scope) → Result[Any]|impure|total|depends on command|dispatch
FN55|MO13|execute_chain|(tokens,...) → Result[[Any]]|impure|total|union of steps|type validation
# — scratchpad
FN56|MO14|Scratchpad|(buffer:RingBuffer,path:str)|—|—|none|—
FN57|MO14|write_entry|(type,content,turn)|impure|total|entry written|—
FN58|MO14|read_recent|(count) → [Dict]|pure|total|none|—
FN59|MO14|clear|()|impure|total|buffer cleared|—
# — iose/registry
FN60|MO15|BuiltinRegistry|()|—|—|none|global ID/name → BuiltinDef
FN61|MO15|register|(builtin_def)|impure|total|entry added|—
FN62|MO15|get_by_id|(id) → ?BuiltinDef|pure|partial|none|—
FN63|MO15|get_by_name|(name) → ?BuiltinDef|pure|partial|none|—
FN64|MO15|all_in_category|(cat) → [BuiltinDef]|pure|total|none|—
FN65|MO15|register_builtin|(id,name,cat,...,impl)|impure|total|registered|convenience wrapper
# — iose/principles
FN66|MO16|load_oso_principles|(kb_store) → KB|impure|total|KB created|~176 Prolog terms
FN67|MO16|get_knowability|(source_type) → VDRFraction|pure|total|none|—
FN68|MO16|get_priority|(concern,domain) → VDRFraction|pure|total|none|—
FN69|MO16|priority_winner|(a,b,domain) → str|pure|total|none|"a","b","tradeoff_required"
# — iose/validator
FN70|MO17|validate_type_compatibility|(chain) → [str]|pure|total|none|output/input matching
FN71|MO17|preview_side_effects|(chain) → [str]|pure|total|none|before execution
FN72|MO17|verify_contract|(def,declared,observed) → [str]|pure|total|none|declared vs observed
# — primitives/arithmetic (8 functions)
FN73|MO18|vdr_add|(a,b) → VDRFraction|pure|total|none|commutative, associative
FN74|MO18|vdr_sub|(a,b) → VDRFraction|pure|total|none|—
FN75|MO18|vdr_mul|(a,b) → VDRFraction|pure|total|none|commutative, associative
FN76|MO18|vdr_div|(a,b) → Result[VDRFraction]|pure|partial|none|b.v=0
FN77|MO18|vdr_neg|(a) → VDRFraction|pure|total|none|invertible
FN78|MO18|vdr_abs|(a) → VDRFraction|pure|total|none|idempotent
FN79|MO18|vdr_pow|(a,n:int) → VDRFraction|pure|total|none|—
FN80|MO18|vdr_reciprocal|(a) → Result[VDRFraction]|pure|partial|none|a.v=0; invertible
# — primitives/comparison (10)
FN81|MO19|vdr_compare|(a,b) → str|pure|total|none|"less","equal","greater"
FN82|MO19|vdr_equal|(a,b) → bool|pure|total|none|commutative
FN83|MO19|vdr_less_than|(a,b) → bool|pure|total|none|—
FN84|MO19|vdr_less_equal|(a,b) → bool|pure|total|none|—
FN85|MO19|vdr_min|(a,b) → VDRFraction|pure|total|none|commutative, associative, idempotent
FN86|MO19|vdr_max|(a,b) → VDRFraction|pure|total|none|commutative, associative, idempotent
FN87|MO19|vdr_sign|(a) → int|pure|total|none|-1,0,1
FN88|MO19|vdr_is_zero|(a) → bool|pure|total|none|—
FN89|MO19|vdr_is_positive|(a) → bool|pure|total|none|—
FN90|MO19|vdr_is_negative|(a) → bool|pure|total|none|—
# — primitives/rounding (7)
FN91|MO20|vdr_floor|(a) → int|pure|total|none|—
FN92|MO20|vdr_ceil|(a) → int|pure|total|none|—
FN93|MO20|vdr_round|(a) → int|pure|total|none|half-up
FN94|MO20|vdr_truncate|(a) → int|pure|total|none|toward zero
FN95|MO20|vdr_numerator|(a) → int|pure|total|none|after normalization
FN96|MO20|vdr_denominator|(a) → int|pure|total|none|after normalization
FN97|MO20|vdr_simplify|(a) → VDRFraction|pure|total|none|idempotent
# — primitives/list_aggregates (8)
FN98|MO21|vdr_sum|(items) → VDRFraction|pure|total|none|empty→[0,1,0]; commutative, associative
FN99|MO21|vdr_product|(items) → VDRFraction|pure|total|none|empty→[1,1,0]; commutative, associative
FN100|MO21|vdr_mean|(items) → Result[VDRFraction]|pure|partial|none|empty
FN101|MO21|vdr_dot_product|(a,b) → Result[VDRFraction]|pure|partial|none|length mismatch; commutative
FN102|MO21|vdr_sum_of_squares|(items) → VDRFraction|pure|total|none|—
FN103|MO21|vdr_weighted_sum|(weights,values) → Result[VDRFraction]|pure|partial|none|length mismatch
FN104|MO21|vdr_harmonic_sum|(n:int) → VDRFraction|pure|total|none|H_n
FN105|MO21|vdr_alternating_sum|(items) → VDRFraction|pure|total|none|—
# — primitives/text (17)
FN106|MO22|string_concat|(a,b) → str|pure|total|none|—
FN107|MO22|string_join|(items,delim) → str|pure|total|none|—
FN108|MO22|string_pad_left|(s,width,fill) → str|pure|total|none|—
FN109|MO22|chars_to_string|(chars) → str|pure|total|none|—
FN110|MO22|string_split|(s,delim) → [str]|pure|total|none|—
FN111|MO22|string_slice|(s,start,end) → str|pure|total|none|—
FN112|MO22|string_char_at|(s,idx) → Result[str]|pure|partial|none|out of bounds
FN113|MO22|string_to_chars|(s) → [str]|pure|total|none|—
FN114|MO22|string_length|(s) → int|pure|total|none|—
FN115|MO22|string_contains|(s,sub) → bool|pure|total|none|—
FN116|MO22|string_starts_with|(s,prefix) → bool|pure|total|none|—
FN117|MO22|string_ends_with|(s,suffix) → bool|pure|total|none|—
FN118|MO22|string_reverse|(s) → str|pure|total|none|—
FN119|MO22|string_upper|(s) → str|pure|total|none|—
FN120|MO22|string_lower|(s) → str|pure|total|none|—
FN121|MO22|string_trim|(s) → str|pure|total|none|—
FN122|MO22|string_replace|(s,old,new) → str|pure|total|none|—
# — primitives/collections (36)
FN123|MO23|list_append|(lst,item) → list|pure|total|none|—
FN124|MO23|list_prepend|(item,lst) → list|pure|total|none|—
FN125|MO23|list_concat|(a,b) → list|pure|total|none|—
FN126|MO23|list_enumerate|(lst) → [(idx,item)]|pure|total|none|—
FN127|MO23|list_length|(lst) → int|pure|total|none|—
FN128|MO23|list_head|(lst) → Result[Any]|pure|partial|none|empty
FN129|MO23|list_tail|(lst) → Result[list]|pure|partial|none|empty
FN130|MO23|list_last|(lst) → Result[Any]|pure|partial|none|empty
FN131|MO23|list_init|(lst) → Result[list]|pure|partial|none|empty
FN132|MO23|list_nth|(lst,n) → Result[Any]|pure|partial|none|out of bounds
FN133|MO23|list_take|(lst,n) → list|pure|total|none|—
FN134|MO23|list_drop|(lst,n) → list|pure|total|none|—
FN135|MO23|list_slice|(lst,start,end) → list|pure|total|none|—
FN136|MO23|list_reverse|(lst) → list|pure|total|none|—
FN137|MO23|list_map|(lst,fn) → list|pure|total|none|—
FN138|MO23|list_flatten|(lst) → list|pure|total|none|—
FN139|MO23|list_unique|(lst) → list|pure|total|none|—
FN140|MO23|list_chunk|(lst,n) → [list]|pure|total|none|—
FN141|MO23|list_interleave|(a,b) → list|pure|total|none|—
FN142|MO23|list_contains|(lst,item) → bool|pure|total|none|—
FN143|MO23|list_index_of|(lst,item) → Result[int]|pure|partial|none|not found
FN144|MO23|list_filter|(lst,pred) → list|pure|total|none|—
FN145|MO23|list_any|(lst,pred) → bool|pure|total|none|—
FN146|MO23|list_all|(lst,pred) → bool|pure|total|none|—
FN147|MO23|list_count|(lst,pred) → int|pure|total|none|—
FN148|MO23|list_sort|(lst,key_fn) → list|pure|total|none|—
FN149|MO23|list_sort_reverse|(lst,key_fn) → list|pure|total|none|—
FN150|MO23|list_sort_by_key|(lst,key_fn) → list|pure|total|none|—
FN151|MO23|list_min|(lst) → Result[Any]|pure|partial|none|empty
FN152|MO23|list_max|(lst) → Result[Any]|pure|partial|none|empty
FN153|MO23|list_partition|(lst,pred) → (list,list)|pure|total|none|—
FN154|MO23|list_group_by|(lst,key_fn) → Dict|pure|total|none|—
FN155|MO23|list_frequencies|(lst) → Dict|pure|total|none|—
FN156|MO23|list_reduce|(lst,fn,init) → Any|pure|total|none|—
FN157|MO23|list_zip|(a,b) → [(Any,Any)]|pure|total|none|—
FN158|MO23|list_unzip|(pairs) → (list,list)|pure|total|none|—
# — primitives/sets (14)
FN159|MO24|set_from_list|(lst) → set|pure|total|none|—
FN160|MO24|set_to_list|(s) → list|pure|total|none|—
FN161|MO24|set_add|(s,item) → set|pure|total|none|—
FN162|MO24|set_remove|(s,item) → set|pure|total|none|—
FN163|MO24|set_contains|(s,item) → bool|pure|total|none|—
FN164|MO24|set_size|(s) → int|pure|total|none|—
FN165|MO24|set_union|(a,b) → set|pure|total|none|—
FN166|MO24|set_intersection|(a,b) → set|pure|total|none|—
FN167|MO24|set_difference|(a,b) → set|pure|total|none|—
FN168|MO24|set_symmetric_diff|(a,b) → set|pure|total|none|—
FN169|MO24|set_power|(s) → set|pure|total|none|power set
FN170|MO24|set_is_subset|(a,b) → bool|pure|total|none|—
FN171|MO24|set_is_superset|(a,b) → bool|pure|total|none|—
FN172|MO24|set_is_disjoint|(a,b) → bool|pure|total|none|—
# — primitives/mappings (15)
FN173|MO25|dict_new|() → dict|pure|total|none|—
FN174|MO25|dict_from_pairs|(pairs) → dict|pure|total|none|—
FN175|MO25|dict_get|(d,key) → Result[Any]|pure|partial|none|missing key
FN176|MO25|dict_get_or|(d,key,default) → Any|pure|total|none|—
FN177|MO25|dict_contains_key|(d,key) → bool|pure|total|none|—
FN178|MO25|dict_size|(d) → int|pure|total|none|—
FN179|MO25|dict_set|(d,key,val) → dict|pure|total|none|—
FN180|MO25|dict_remove|(d,key) → dict|pure|total|none|—
FN181|MO25|dict_merge|(a,b) → dict|pure|total|none|—
FN182|MO25|dict_keys|(d) → list|pure|total|none|—
FN183|MO25|dict_values|(d) → list|pure|total|none|—
FN184|MO25|dict_pairs|(d) → [(key,val)]|pure|total|none|—
FN185|MO25|dict_filter_keys|(d,pred) → dict|pure|total|none|—
FN186|MO25|dict_map_values|(d,fn) → dict|pure|total|none|—
FN187|MO25|dict_invert|(d) → Result[dict]|pure|partial|none|non-unique values
# — primitives/conversion (14)
FN188|MO26|to_string|(value) → str|pure|total|none|—
FN189|MO26|to_number|(s) → Result[int]|pure|partial|none|—
FN190|MO26|to_fraction|(s) → Result[VDRFraction]|pure|partial|none|primary conversion boundary
FN191|MO26|format_json|(d) → str|pure|total|none|—
FN192|MO26|parse_json|(s) → Result[dict]|pure|partial|none|—
FN193|MO26|format_csv|(rows,delim) → str|pure|total|none|—
FN194|MO26|parse_csv|(s,delim) → [[str]]|pure|total|none|—
FN195|MO26|format_table|(rows) → str|pure|total|none|—
FN196|MO26|format_fraction|(f) → str|pure|total|none|lossless
FN197|MO26|fraction_to_decimal|(f,digits) → str|pure|total|none|lossy
FN198|MO26|format_percentage|(f,places) → str|pure|total|none|lossy
FN199|MO26|format_scientific|(f,sig_digits) → str|pure|total|none|lossy
FN200|MO26|vdr_from_decimal_string|(s) → Result[VDRFraction]|pure|partial|none|exact for terminating
FN201|MO26|vdr_from_ratio_string|(s) → Result[VDRFraction]|pure|partial|none|exact, lossless
# — primitives/logic (11)
FN202|MO27|if_then_else|(cond,true_fn,false_fn) → Any|pure|total|none|—
FN203|MO27|case_match|(value,cases) → Result[Any]|pure|partial|none|no match
FN204|MO27|for_each|(items,fn)|pure|total|none|—
FN205|MO27|repeat_n|(n,fn) → list|pure|total|none|—
FN206|MO27|while_loop|(pred,fn,state) → Any|pure|total|none|—
FN207|MO27|try_catch|(fn,handler) → Any|pure|total|none|—
FN208|MO27|assert_that|(cond,msg) → Result[None]|pure|partial|none|—
FN209|MO27|type_check|(value,type_str) → bool|pure|total|none|—
FN210|MO27|is_bound|(var,bindings) → bool|pure|total|none|—
FN211|MO27|findall|(kb,goal) → [Binding]|pure|total|none|delegates to query_rules
FN212|MO27|aggregate|(kb,goal,fn,init) → Any|pure|total|none|over query results
# — primitives/integer_ops (22)
FN213|MO28|int_add through int_clamp|11 basic integer operations|pure|total (int_div,int_mod partial)|none|add,sub,mul,div,mod,pow,abs,sign,min,max,clamp
FN214|MO28|int_range, int_range_step|range generators|pure|total|none|—
FN215|MO28|bit_and through bit_width|10 bitwise operations|pure|total|none|and,or,xor,not,shl,shr,popcount,width
# — primitives/active_arithmetic (5)
FN216|MO29|vdr_active_add_same_d|(a,b) → VDRFraction|pure|total|none|same denominator
FN217|MO29|vdr_active_add_diff_d|(a,b) → VDRFraction|pure|total|none|different denominator
FN218|MO29|vdr_active_mul|(a,b) → VDRFraction|pure|total|none|—
FN219|MO29|vdr_active_div_by_closed|(a,b) → Result[VDRFraction]|pure|partial|none|—
FN220|MO29|vdr_active_div_by_active|(a,b) → Result[VDRFraction]|pure|partial|none|lossy (divisor remainder lost)
# — primitives/structure_ops (3)
FN221|MO30|vdr_lift|(remainder,k) → Any|pure|total|none|lift by k
FN222|MO30|vdr_rebase|(frac,target_d) → VDRFraction|pure|total|none|—
FN223|MO30|vdr_scalar_projection|(frac) → Result[VDRFraction]|pure|partial|none|project to closed
# — primitives/number_theory (13)
FN224|MO31|vdr_gcd|(a,b) → int|pure|total|none|commutative, associative
FN225|MO31|vdr_lcm|(a,b) → int|pure|total|none|commutative, associative
FN226|MO31|vdr_mod|(a,b) → Result[int]|pure|partial|none|b=0
FN227|MO31|vdr_div_exact|(a,b) → Result[int]|pure|partial|none|not evenly divisible
FN228|MO31|vdr_mod_pow|(base,exp,mod) → int|pure|total|none|binary exponentiation
FN229|MO31|vdr_mod_inv|(a,m) → Result[int]|pure|partial|none|gcd≠1
FN230|MO31|vdr_extended_gcd|(a,b) → (g,x,y)|pure|total|none|ax+by=g
FN231|MO31|vdr_is_prime|(n) → bool|pure|total|none|—
FN232|MO31|vdr_factorial|(n) → Result[int]|pure|partial|none|n<0
FN233|MO31|vdr_binomial|(n,k) → int|pure|total|none|—
FN234|MO31|vdr_fibonacci|(n) → int|pure|total|none|matrix power
FN235|MO31|vdr_euler_totient|(n) → int|pure|total|none|—
FN236|MO31|vdr_chinese_remainder|(rems,mods) → Result[int]|pure|partial|none|not pairwise coprime
# — primitives/linalg (26)
FN237|MO32|vdr_vec_new through vdr_vec_neg|9 vector operations|pure|total (get partial)|none|new,dim,get,add,sub,scale,dot,norm_sq,neg
FN238|MO32|vdr_mat_new through vdr_mat_pow|17 matrix operations|pure|total (get,inv,solve,gram_schmidt partial)|none|new,dims,get,add,mul,scale,transpose,matvec,det,inv,solve,rank,identity,trace,pow,gram_schmidt
# — primitives/statistics (16)
FN239|MO33|vdr_stat_mean through vdr_stat_percentile|5 descriptive stats|pure|partial (empty)|none|mean,variance,median,mode,percentile
FN240|MO33|vdr_prob_normalize through vdr_softmax_surrogate|11 probability functions|pure|partial (some)|none|normalize,is_valid,bayes,expected,cdf,joint,marginal,conditional,entropy_terms,softmax,softmax_surrogate
# — primitives/time_ops (10)
FN241|MO34|date_from_ymd through date_days_in_month|7 date functions|pure|total|none|day count based
FN242|MO34|time_from_hms through duration_between|3 time functions|pure|total|none|seconds based
# — primitives/identity (8)
FN243|MO35|hash_string|(s) → int|pure|total|none|deterministic
FN244|MO35|hash_combine|(a,b) → int|pure|total|none|deterministic
FN245|MO35|base64_encode/decode|encoding pair|pure|partial (decode)|none|—
FN246|MO35|hex_encode/decode|encoding pair|pure|partial (decode)|none|—
FN247|MO35|crc32|(s) → int|pure|total|none|—
FN248|MO35|uuid_from_seed|(seed) → str|pure|total|none|deterministic
# — primitives/graphs (13)
FN249|MO36|graph_from_edges|(edges) → Dict|pure|total|none|adjacency list
FN250|MO36|graph_neighbors|(graph,node) → [Any]|pure|total|none|—
FN251|MO36|graph_bfs/dfs|(graph,start) → [Any]|pure|total|none|traversal
FN252|MO36|graph_shortest_path|(graph,start,end) → Result[[Any]]|pure|partial|none|no path
FN253|MO36|graph_shortest_path_weighted|same + cost|pure|partial|none|—
FN254|MO36|graph_connected_components|(graph) → [[Any]]|pure|total|none|—
FN255|MO36|graph_is_connected|(graph) → bool|pure|total|none|—
FN256|MO36|graph_topological_sort|(graph) → Result[[Any]]|pure|partial|none|cycle
FN257|MO36|graph_cycle_detect|(graph) → bool|pure|total|none|—
FN258|MO36|graph_degree|(graph,node) → int|pure|total|none|—
FN259|MO36|graph_mst|(graph) → [edge]|pure|total|none|—
FN260|MO36|graph_pagerank|(graph,damping) → [VDRFraction]|pure|total|none|—
# — primitives/qbasis (7)
FN261|MO37|qbasis_add/sub|(a,b) → QBasis|pure|total|none|align exponents first if different
FN262|MO37|qbasis_mul|(a,b) → (QBasis,VDRFraction)|pure|total|none|reprojected + error bound
FN263|MO37|qbasis_scalar_mul|(scalar,qb) → QBasis|pure|total|none|—
FN264|MO37|qbasis_to_fraction|(qb) → VDRFraction|pure|total|none|lossless
FN265|MO37|qbasis_get_constant|(name) → Result[QBasis]|pure|partial|none|unknown name
FN266|MO37|qbasis_precision_bits|(qb) → int|pure|total|none|—
# — primitives/functional (8)
FN267|MO38|fn_sqrt|(value,depth) → VDRFraction|pure|total|none|Newton-Raphson
FN268|MO38|fn_exp|(value,depth) → VDRFraction|pure|total|none|truncated Taylor
FN269|MO38|fn_log|(value,depth) → Result[VDRFraction]|pure|partial|none|value≤0
FN270|MO38|fn_sin/cos|(value,depth) → VDRFraction|pure|total|none|Taylor series
FN271|MO38|fn_resolve|(fn_remainder,depth) → VDRFraction|pure|total|none|evaluate callable
FN272|MO38|fn_make_newton/series|(name,fn) → FnRemainder|pure|total|none|remainder constructors
# — primitives/discrete_calculus (6)
FN273|MO39|vdr_discrete_derivative|(f,x,h) → VDRFraction|pure|total|none|—
FN274|MO39|vdr_discrete_derivative_n|(f,x,h,n) → VDRFraction|pure|total|none|nth
FN275|MO39|vdr_left_riemann|(f,a,b,n) → VDRFraction|pure|total|none|—
FN276|MO39|vdr_trapezoidal|(f,a,b,n) → VDRFraction|pure|total|none|—
FN277|MO39|vdr_finite_difference_table|(values) → [[VDRFraction]]|pure|total|none|—
FN278|MO39|vdr_richardson_extrapolation|(f,a,b,n1,n2) → VDRFraction|pure|total|none|—
# — primitives/denom_mgmt (5)
FN279|MO40|vdr_denom_bits/digits|(frac) → int|pure|total|none|—
FN280|MO40|vdr_reproject_qbasis|(frac,exp) → (VDRFraction,VDRFraction)|pure|total|none|reprojected + error
FN281|MO40|vdr_denom_budget_check|(frac,budget) → bool|pure|total|none|true=over budget
FN282|MO40|vdr_precision_state|(frac) → Dict|pure|total|none|full precision report
# — primitives/polynomial (8)
FN283|MO41|poly_eval|(coeffs,x) → VDRFraction|pure|total|none|—
FN284|MO41|poly_add/mul|(a,b) → [VDRFraction]|pure|total|none|—
FN285|MO41|poly_div|(a,b) → Result[(quo,rem)]|pure|partial|none|—
FN286|MO41|poly_gcd|(a,b) → [VDRFraction]|pure|total|none|—
FN287|MO41|poly_derivative/integral|(coeffs) → [VDRFraction]|pure|total|none|—
FN288|MO41|poly_lagrange_interpolation|(xs,ys) → Result[[VDRFraction]]|pure|partial|none|—
# — primitives/finite_field (4)
FN289|MO42|gf_add/mul|(a,b,p) → int|pure|total|none|GF(p)
FN290|MO42|gf_inv|(a,p) → Result[int]|pure|partial|none|—
FN291|MO42|gf_pow|(a,b,p) → int|pure|total|none|—
# — primitives/markov (3)
FN292|MO43|markov_steady_state|(matrix) → Result[Vec]|pure|partial|none|—
FN293|MO43|markov_step|(matrix,state) → Vec|pure|total|none|—
FN294|MO43|markov_n_steps|(matrix,state,n) → Vec|pure|total|none|—
# — primitives/graph_math (2)
FN295|MO44|adjacency_matrix_power|(adj,n) → Mat|pure|total|none|—
FN296|MO44|pagerank_exact|(adj,damping) → Vec|pure|total|none|—
# — data_primitives/counter (7)
FN297|MO45|counter_create|(kb,name,min,max)|impure|total|created|bounded
FN298|MO45|counter_inc/dec/add|(kb,name,[delta]) → Result[int]|impure|partial|mutated|bounded check
FN299|MO45|counter_get|(kb,name) → Result[int]|pure|partial|none|—
FN300|MO45|counter_reset/set|(kb,name,[value])|impure|total|mutated|idempotent
# — data_primitives/lock (6)
FN301|MO46|lock_create|(kb,name)|impure|total|created|—
FN302|MO46|lock_acquire|(kb,name,holder,notes) → bool|impure|total|state changed|—
FN303|MO46|lock_release/force_release|(kb,name)|impure|total|state changed|idempotent
FN304|MO46|lock_check|(kb,name) → bool|pure|total|none|—
FN305|MO46|lock_holder|(kb,name) → Result[str]|pure|partial|none|—
# — data_primitives/queue (9)
FN306|MO47|queue_create|(kb,name,capacity)|impure|total|created|—
FN307|MO47|queue_push|(kb,name,item) → bool|impure|total|mutated|false if full
FN308|MO47|queue_pop|(kb,name) → Result[Any]|impure|partial|mutated|empty
FN309|MO47|queue_peek|(kb,name) → Result[Any]|pure|partial|none|empty
FN310|MO47|queue_size/is_empty/is_full|(kb,name)|pure|total|none|—
FN311|MO47|queue_clear|(kb,name)|impure|total|cleared|idempotent
FN312|MO47|queue_to_list|(kb,name) → [Any]|pure|total|none|—
# — data_primitives/stack (8)
FN313|MO48|stack_create|(kb,name,capacity)|impure|total|created|—
FN314|MO48|stack_push|(kb,name,item) → bool|impure|total|mutated|false if full
FN315|MO48|stack_pop|(kb,name) → Result[Any]|impure|partial|mutated|empty
FN316|MO48|stack_peek|(kb,name) → Result[Any]|pure|partial|none|empty
FN317|MO48|stack_size/is_empty|(kb,name)|pure|total|none|—
FN318|MO48|stack_clear|(kb,name)|impure|total|cleared|idempotent
FN319|MO48|stack_to_list|(kb,name) → [Any]|pure|total|none|top-to-bottom
# — data_primitives/lru (8)
FN320|MO49|lru_create|(kb,name,capacity)|impure|total|created|—
FN321|MO49|lru_push|(kb,name,key,value)|impure|total|mutated|evicts oldest if full
FN322|MO49|lru_get|(kb,name,key) → Result[Any]|impure|partial|access time updated|—
FN323|MO49|lru_peek|(kb,name,count) → [(key,val)]|pure|total|none|no access update
FN324|MO49|lru_contains/size|(kb,name)|pure|total|none|—
FN325|MO49|lru_clear/evict|(kb,name,[key])|impure|total|mutated|idempotent
# — data_primitives/ring_buffer (6)
FN326|MO50|ring_create|(kb,name,capacity)|impure|total|created|—
FN327|MO50|ring_write|(kb,name,item)|impure|total|mutated|overwrites oldest if full
FN328|MO50|ring_read_all/read_last|(kb,name,[count]) → [Any]|pure|total|none|chronological
FN329|MO50|ring_size|(kb,name) → int|pure|total|none|—
FN330|MO50|ring_clear|(kb,name)|impure|total|reset|idempotent
# — data_primitives/bitset (9)
FN331|MO51|bitset_create|(kb,name,width)|impure|total|created|—
FN332|MO51|bitset_set/clear_bit|(kb,name,index)|impure|total|bit changed|idempotent
FN333|MO51|bitset_test|(kb,name,index) → bool|pure|total|none|—
FN334|MO51|bitset_count|(kb,name) → int|pure|total|none|popcount
FN335|MO51|bitset_all_set/any_set|(kb,name) → bool|pure|total|none|—
FN336|MO51|bitset_reset|(kb,name)|impure|total|all cleared|idempotent
FN337|MO51|bitset_to_list|(kb,name) → [int]|pure|total|none|sorted set bit indices
# — session (9)
FN338|MO52|capture_live_state|(scope,kb_store) → Dict|pure|total|none|deep copy
FN339|MO52|create_snapshot|(name,scope,kb_store,scratch,turn,notes) → Snapshot|impure|total|snapshot KB created|—
FN340|MO52|restore_snapshot|(snapshot,kb_store)|impure|total|live state overwritten|—
FN341|MO53|clone_session|(source,clone,snapshot_store,kb_store)|impure|total|new snapshot created|deep copy live state
FN342|MO53|kill_clone|(clone,snapshot_store,kb_store)|impure|total|live state cleared|—
FN343|MO54|session_reset|(scope,kb_store)|impure|total|all primitives reset|—
FN344|MO54|session_list|(snapshot_store) → [str]|pure|total|none|—
FN345|MO54|session_diff|(a,b,snapshot_store) → Dict|pure|total|none|added/removed/changed
FN346|MO54|session_info|(name,snapshot_store) → Result[Dict]|pure|partial|none|—
# — inference (20)
FN347|MO55|create_inference_notebook|(path,problem,mode,goal,max_steps,max_queries,kb_store,registry) → Notebook|impure|total|KB+primitives created|—
FN348|MO55|notebook_from_template|(template,path,problem,kb_store,registry) → Notebook|impure|total|same|template schema
FN349|MO56|assess|(notebook,kb_store) → LoopPhase|impure|total|counters incremented|check budget/stall/goal
FN350|MO56|formalize|(notebook,action_fn) → Any|impure|total|artifacts may be asserted|LLM hook
FN351|MO56|execute_step|(artifact,notebook,kb_store,registry,executor) → Result[Any]|impure|total|per artifact|—
FN352|MO56|store_result|(result,notebook,turn)|impure|total|facts+counters+bitset/LRU|—
FN353|MO56|run_loop|(notebook,action_fn,...,max_iter) → Notebook|impure|total|accumulated|full cycle
FN354|MO57|compute_deductive_confidence|(premises) → VDRFraction|pure|total|none|min(inputs)
FN355|MO57|compute_inductive_confidence|(coverage,mean_conf) → VDRFraction|pure|total|none|coverage×mean
FN356|MO57|compute_abductive_confidence|(explained,min_evidence) → VDRFraction|pure|total|none|—
FN357|MO57|compute_analogical_confidence|(strength,source) → VDRFraction|pure|total|none|strength×source
FN358|MO57|propagate_through_chain|(chain) → VDRFraction|pure|total|none|overall chain
FN359|MO58|record_evidence|(fact,source_type,conf,notebook,turn) → Dict|impure|total|evidence asserted|—
FN360|MO58|record_conclusion|(statement,mode,conf,...,notebook) → Conclusion|impure|total|conclusion asserted|—
FN361|MO58|trace_derivation|(conclusion_id,notebook) → [Dict]|pure|total|none|walk chain
FN362|MO58|challenge_conclusion|(counter_fact,conclusion_id,notebook,kb_store) → Dict|impure|total|may retract/downgrade|—
FN363|MO59|run_deductive|(notebook,premises,rules,goal,kb_store) → [Binding]|impure|total|premises+rules asserted|—
FN364|MO59|run_inductive|(notebook,evidence,scoring_rules,kb_store) → [(str,VDRFraction)]|impure|total|evidence+rules asserted|—
FN365|MO59|run_abductive|(notebook,observations,causal_rules,kb_store) → [str]|impure|total|observations+rules asserted|—
FN366|MO59|run_analogical|(notebook,source,target,mapping_rules,kb_store) → [(Fact,VDRFraction)]|impure|total|all asserted|—
# — env (base + 4 implementations)
FN367|MO60|exec_command|(cmd,args) → ExecResult|impure|total|process executed|—
FN368|MO60|upload|(content,remote_path) → bool|impure|total|file created|—
FN369|MO60|download|(remote_path) → Result[str]|pure|partial|none|—
FN370|MO60|file_read/write|(path,[content]) → Result[str]\|bool|impure (write)|partial (read)|file I/O|—
FN371|MO60|list_dir|(path) → [str]|pure|total|none|—
FN372|MO60|start_process|(cmd,args) → task_id|impure|total|process started|—
FN373|MO60|poll_process|(task_id) → TaskStatus|pure|total|none|—
FN374|MO60|get_output|(task_id) → (stdout,stderr)|pure|total|none|—
FN375|MO62|create/start/stop/destroy_container|Docker lifecycle|impure|total|container managed|DockerEnvironment only
# — ops (grants + operational)
FN376|MO65|add_grant|(grant)|impure|total|grant stored|—
FN377|MO65|verify_grant|(class,type,location,user) → Result[Grant]|pure|total|none|—
FN378|MO65|use_grant|(grant)|impure|total|uses decremented|—
FN379|MO65|list_effective_grants|(user,kb_store) → [Grant]|pure|total|none|—
FN380|MO66|fs_read through fs_checksum|15 filesystem ops|impure|total|file I/O|all grant-gated
FN381|MO67|exec_python through exec_script|5 execution ops|impure|total|process executed|all grant-gated
FN382|MO68|net_download through net_dns_resolve|5 network ops|impure|total|network I/O|all grant-gated
FN383|MO69|proc_start through proc_list|7 process ops|impure (start,wait,kill)|total|process managed|grant-gated where mutating
FN384|MO70|compile_python_check through compile_rust|4 compilation ops|impure|total|process executed|all grant-gated
FN385|MO71|lint_python through count_lines|8 lint/analysis ops|impure|total|process executed|all grant-gated (read-only operational)
# — lifecycle
FN386|MO72|register_data_source|(name,url,license,type,kb_store) → KB|impure|total|source KB created|under root.sources
FN387|MO72|prepare_corpus|(source_kb,filters,split_ratios,kb_store) → KB|impure|total|corpus KB created|transformation log
FN388|MO72|tokenize_corpus|(corpus_kb,vocab_size,kb_store) → KB|impure|total|vocab KB (frozen) + tokenized KB|—
FN389|MO73|initialize_model|(arch_config,seed,kb_store) → KB|impure|total|arch + init KBs|—
FN390|MO73|train_step|(model_kb,train_kb,batch,lr) → VDRFraction|impure|total|weights updated|returns loss
FN391|MO73|create_checkpoint|(model_kb,train_kb,step,kb_store) → KB|impure|total|checkpoint KB|—
FN392|MO73|restore_checkpoint|(checkpoint_kb,model_kb)|impure|total|weights overwritten|idempotent
FN393|MO74|run_benchmark|(checkpoint_kb,name,data,env,kb_store) → Dict|impure|total|eval KB created|metrics
FN394|MO74|run_eval_suite|(checkpoint_kb,suite,data_map,env,kb_store) → KB|impure|total|eval result KBs|—
FN395|MO74|compare_checkpoints|(eval_a,eval_b) → Dict|pure|total|none|—
FN396|MO75|create_feedback_round|(version,annotator_count,kb_store) → KB|impure|total|feedback KB|—
FN397|MO75|add_pairwise_judgment|(feedback_kb,...)|impure|total|judgment asserted|—
FN398|MO75|compute_agreement|(feedback_kb) → VDRFraction|pure|total|none|Cohen's kappa
FN399|MO75|train_reward_model|(feedback_kb,base_checkpoint,config,kb_store) → KB|impure|total|reward model KB|—
FN400|MO75|run_dpo|(feedback_kb,base_checkpoint,config,kb_store) → KB|impure|total|aligned checkpoint|—
FN401|MO76|create_deployment|(checkpoint_kb,env,config,kb_store) → KB|impure|total|deployment KB, model loaded|—
FN402|MO76|create_canary|(deployment_kb,pct,hours,criteria,kb_store) → KB|impure|total|canary KB, traffic split|—
FN403|MO76|promote_canary|(canary_kb,kb_store)|impure|total|promoted, old deactivated|—
FN404|MO76|rollback|(deployment_kb,target_checkpoint,kb_store)|impure|total|current deactivated, target loaded|—
FN405|MO76|retire_model|(model_kb,reason,successor,kb_store)|impure|total|retirement KB, archived+frozen|—
FN406|MO77|create_monitoring|(deployment_kb,kb_store) → KB|impure|total|monitoring KB + default watches|—
FN407|MO77|add_watch|(monitoring_kb,name,condition,action)|impure|total|watch fact asserted|—
FN408|MO77|check_watches|(monitoring_kb,kb_store) → [Dict]|impure|total|triggered watch facts|—
FN409|MO77|record_metric|(monitoring_kb,name,value,timestamp)|impure|total|metric fact asserted|—
FN410|MO77|detect_drift|(monitoring_kb,baseline,current) → [Dict]|impure|total|drift events if detected|—

# categories(id|category|modules|function_count|purity|grant_required)
CA1|core types + errors|MO1-MO2|7|pure (except Result container)|no
CA2|KB operations|MO3-MO8|28|mixed — queries pure, mutations impure|no
CA3|path management|MO9-MO11|15|mixed — registry mutations impure|no
CA4|command system|MO12-MO14|7|mixed — execution impure|no
CA5|IOSE framework|MO15-MO17|13|mixed — registration impure|no
CA6|closed arithmetic|MO18-MO20|25|pure|no
CA7|list/set/dict/conversion|MO21-MO26|104|pure|no
CA8|logic + control flow|MO27|11|pure|no
CA9|integer + bitwise|MO28|22|pure|no
CA10|active arithmetic|MO29|5|pure|no
CA11|structure ops|MO30|3|pure|no
CA12|number theory|MO31|13|pure|no
CA13|linear algebra|MO32|26|pure|no
CA14|statistics + probability|MO33|16|pure|no
CA15|time|MO34|10|pure|no
CA16|identity/hashing|MO35|8|pure|no
CA17|graphs|MO36|13|pure|no
CA18|QBasis|MO37|7|pure|no
CA19|transcendentals|MO38|8|pure|no
CA20|discrete calculus|MO39|6|pure|no
CA21|denominator management|MO40|5|pure|no
CA22|polynomial|MO41|8|pure|no
CA23|finite field|MO42|4|pure|no
CA24|Markov + graph math|MO43-MO44|5|pure|no
CA25|data primitives|MO45-MO51|53|impure (mutations)|no
CA26|session management|MO52-MO54|9|impure|no
CA27|inference engine|MO55-MO59|20|impure|no
CA28|environment interfaces|MO60-MO64|~44|impure|yes (operational)
CA29|grants|MO65|4|mixed|no
CA30|filesystem ops|MO66|15|impure|yes (filesystem)
CA31|execution ops|MO67|5|impure|yes (execute)
CA32|network ops|MO68|5|impure|yes (network)
CA33|process ops|MO69|7|impure|yes (process)
CA34|compilation ops|MO70|4|impure|yes (compile)
CA35|linting ops|MO71|8|impure|yes (lint)
CA36|lifecycle — data pipeline|MO72|3|impure|no
CA37|lifecycle — training|MO73|4|impure|no
CA38|lifecycle — evaluation|MO74|3|mixed|no
CA39|lifecycle — feedback|MO75|5|mixed|no
CA40|lifecycle — deployment|MO76|5|impure|no
CA41|lifecycle — monitoring|MO77|5|impure|no

# data_structures(id|structure|module|operations|notes)
DS1|VDRFraction|MO1|v, d, r fields — exact rational with remainder|primary numeric type
DS2|Result|MO2|unwrap(), unwrap_or(default), map(fn)|Rust-style error handling
DS3|KnowledgeBase|MO3|facts, rules, constraints, working_data, counters, locks, queues, stacks, LRUs, rings, bitsets|tree-structured container
DS4|Fact|MO4|predicate + args, structural equality|atomic knowledge unit
DS5|Binding|MO5|Dict[str,Any] — get(), bind(), merge()|variable binding set
DS6|ScopeChain|MO8|chain:[int], secondary:[int]|ordered KB IDs for scoped resolution
DS7|PathRegistry|MO9|bidirectional path↔ID, retired IDs never reused|global path management
DS8|CommandToken|MO12|parsed CMD: instruction|command representation
DS9|Scratchpad|MO14|RingBuffer-based workspace|internal working memory
DS10|BuiltinDef|MO15|id, name, category, inputs, outputs, side_effects, properties, impl|builtin declaration
DS11|Constraint|MO7|name, condition, on_violation, status|KB constraint
DS12|Mount|MO11|mount_path, source_path, mode|KB mount record
DS13|Vec|MO32|[VDRFraction] elements|vector type
DS14|Mat|MO32|[Vec] rows|matrix type
DS15|QBasis|MO37|numerator, exponent — value = numerator/2^exponent|power-of-two basis
DS16|FnRemainder|MO38|callable remainder for iterative approximation|Newton/Taylor wrapper
DS17|InferenceNotebook|MO55|KB + data primitives for structured reasoning|inference container
DS18|InferenceConclusion|MO58|statement, mode, confidence, derivation chain|reasoned output
DS19|Grant|MO65|class, type, location, user, uses_remaining, status|authorization token
DS20|ExecResult|MO60|exit_code, stdout, stderr, runtime_ms|process execution result
DS21|SessionSnapshot|MO52|live state capture at point in time|session persistence

# relationships(from|rel|to)
# module dependencies
MO3|requires|MO9
MO4|requires|MO3
MO5|requires|MO4
MO6|requires|MO3
MO7|requires|MO5,MO3
MO8|requires|MO4,MO6,MO3
MO11|requires|MO9,MO4
MO13|requires|MO15,MO9,MO8
MO14|requires|MO50
MO16|requires|MO3
MO17|requires|MO15
MO52|requires|MO8,MO45-MO51
MO53|requires|MO52
MO54|requires|MO8,MO45-MO51
MO55|requires|MO3,MO45-MO51,MO15
MO56|requires|MO55,MO13
MO57|requires|MO18
MO58|requires|MO4,MO55
MO59|requires|MO5,MO4,MO55
MO65|requires|MO3
MO66|requires|MO60,MO65
MO67|requires|MO60,MO65
MO68|requires|MO65
MO69|requires|MO60,MO65
MO70|requires|MO60,MO65
MO71|requires|MO60,MO65
MO72|requires|MO3,MO4
MO73|requires|MO3,MO72
MO74|requires|MO73,MO60
MO75|requires|MO74,MO73
MO76|requires|MO73,MO60
MO77|requires|MO76
# category composition
CA6|contains|MO18,MO19,MO20
CA7|contains|MO21,MO22,MO23,MO24,MO25,MO26
CA25|contains|MO45,MO46,MO47,MO48,MO49,MO50,MO51
CA27|contains|MO55,MO56,MO57,MO58,MO59
CA28|contains|MO60,MO61,MO62,MO63,MO64
# data structure → module
DS1|defined_in|MO1
DS3|defined_in|MO3
DS5|defined_in|MO5
DS6|defined_in|MO8
DS7|defined_in|MO9
DS13|defined_in|MO32
DS14|defined_in|MO32
DS15|defined_in|MO37
DS17|defined_in|MO55
DS19|defined_in|MO65
# lifecycle pipeline
MO72|enables|MO73
MO73|enables|MO74
MO74|enables|MO75,MO76
MO75|enables|MO73
MO76|enables|MO77
# purity classification
CA1|classified_as|pure
CA6|classified_as|pure
CA7|classified_as|pure
CA8|classified_as|pure
CA9|classified_as|pure
CA10|classified_as|pure
CA12|classified_as|pure
CA13|classified_as|pure
CA14|classified_as|pure
CA25|classified_as|impure
CA30-CA35|classified_as|grant_required

# section_index(section|title|ids)
1|Modules|MO1-MO77
2|Functions — Core|FN1-FN7
3|Functions — KB|FN8-FN36
4|Functions — Path|FN37-FN51
5|Functions — Command|FN52-FN59
6|Functions — IOSE|FN60-FN72
7|Functions — Arithmetic/Comparison/Rounding|FN73-FN97
8|Functions — Collections/Text/Conversion|FN98-FN201
9|Functions — Logic/Integer|FN202-FN215
10|Functions — Active/Structure/NumberTheory|FN216-FN236
11|Functions — LinAlg/Stats/Time/Identity|FN237-FN248
12|Functions — Graphs/QBasis/Functional|FN249-FN272
13|Functions — Calculus/Denom/Poly/FiniteField/Markov|FN273-FN296
14|Functions — Data Primitives|FN297-FN337
15|Functions — Session|FN338-FN346
16|Functions — Inference|FN347-FN366
17|Functions — Environment|FN367-FN375
18|Functions — Ops|FN376-FN385
19|Functions — Lifecycle|FN386-FN410
20|Categories|CA1-CA41
21|Data Structures|DS1-DS21

# decode_legend
id_prefixes: MO=module, FN=function, CA=category, DS=data_structure
rel_types: requires|contains|defined_in|enables|classified_as
purity_values: pure=no side effects+deterministic; impure=has side effects; mixed=contains both
partiality_values: total=defined for all valid inputs; partial=may fail on some inputs (returns Result or None)
grant_classes: filesystem, compile, execute, lint, network, process
function_count_total: ~410 functions across 77 modules
language: Python (prototype — production target is Zig 0.15.1)
stage: Stage 5 cumulative (all stages 1-5 inclusive)
confidence: compacted from source API listing — all function signatures, purity annotations, partiality notes, and side effect declarations preserved exactly

# relation_mapping(doc_rel|canonical_rel|notes)
requires|requires|exact match
contains|contains|exact match
defined_in|scoped_to|data structure defined in module = scoped_to that module
enables|enables|exact match
classified_as|instance_of|category classified as pure/impure = instance_of that purity class
