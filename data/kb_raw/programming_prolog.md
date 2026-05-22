# PROLOG PROGRAMMING LANGUAGE — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: concepts → syntax → data_types → built_ins → control → unification → search → meta → io → modules → techniques → libraries → failure_modes → distinctions → relationships → decode_legend

# concepts(id|name|definition|category)
CO1|Logic Programming|programming paradigm based on formal logic; program = set of logical statements; computation = proof search; Prolog is primary language|foundation
CO2|Declarative Programming|specifying what to compute rather than how; Prolog programmer declares facts and rules; execution engine derives answers|foundation
CO3|Horn Clause|restricted form of first-order logic clause with at most one positive literal; Head :- Body; Prolog programs are sets of Horn clauses|foundation
CO4|Fact|Horn clause with no body; unconditionally true assertion; parent(tom, bob).|foundation
CO5|Rule|Horn clause with head and body; Head :- Body; head true if all body goals true; ancestor(X,Y) :- parent(X,Y).|foundation
CO6|Query (Goal)|question posed to Prolog system; ?- ancestor(tom, X). triggers proof search; may succeed with bindings or fail|foundation
CO7|Predicate|named relation defined by set of clauses (facts and rules) with same functor and arity; parent/2 is a predicate with functor parent and arity 2|foundation
CO8|Functor|name of a compound term or predicate; in f(a,b), f is functor; in parent(tom,bob), parent is functor|foundation
CO9|Arity|number of arguments of a predicate or compound term; parent/2 has arity 2; f(a,b,c) has arity 3; same functor different arity = different predicate|foundation
CO10|Clause|single fact or rule; unit of Prolog program; clauses with same functor/arity grouped together define a predicate|foundation
CO11|Unification|process of making two terms identical by finding a substitution (binding) for variables; fundamental operation; X = f(Y) succeeds with X bound to f(Y)|foundation
CO12|Substitution|mapping from variables to terms; result of successful unification; {X/tom, Y/bob}; applied to both sides simultaneously|foundation
CO13|Most General Unifier (MGU)|substitution that unifies two terms with minimum commitment; does not bind variables unnecessarily; unique up to variable renaming|foundation
CO14|Occurs Check|test during unification that variable does not occur in term it is being unified with; X = f(X) should fail with occurs check; SWI default: disabled for performance (use unify_with_occurs_check/2 when needed)|foundation
CO15|Resolution|inference rule: from (A :- B,C) and (B :- D), derive (A :- D,C); SLD resolution is Prolog's proof procedure|foundation
CO16|SLD Resolution|Selective Linear Definite clause resolution; selects leftmost goal, resolves with first matching clause, continues; Prolog's execution model|foundation
CO17|Proof Tree|tree of goals generated during SLD resolution; root = query; branches = clause choices; leaves = success (empty goal) or failure|foundation
CO18|Backtracking|when a goal fails, Prolog undoes bindings and tries next clause for most recent choice point; depth-first search with chronological backtracking|foundation
CO19|Choice Point|marker in execution where multiple clauses match a goal; Prolog tries first; on failure, backtracks to most recent choice point and tries next clause|foundation
CO20|Cut (!)|control predicate that succeeds once and removes all choice points created since the parent goal was called; prevents backtracking past cut; green cut (preserves correctness) vs red cut (changes meaning)|control
CO21|Closed World Assumption (CWA)|what cannot be proved true is assumed false; Prolog's negation-as-failure semantics; not provable ≠ logically false|foundation
CO22|Negation as Failure (NAF)|\+ Goal succeeds if Goal fails; implements CWA; sound only when Goal is ground (fully instantiated); floundering if Goal contains variables|foundation
CO23|Logical Variable|placeholder that can be bound to any term exactly once during computation; unbound = free; bound = instantiated; single assignment|foundation
CO24|Anonymous Variable (_)|variable whose binding is not needed; each _ is independent; used for don't-care positions; parent(X, _) matches any second argument|syntax
CO25|Scope of Variables|variables are local to a clause; same variable name in different clauses are unrelated; scope = single clause|syntax
CO26|Tail Recursion Optimization (TRO)|last call optimization; if last goal in clause is recursive call, stack frame reused; enables constant-space recursion; requires accumulator pattern typically|optimization
CO27|Warren Abstract Machine (WAM)|standard abstract machine for executing Prolog; register-based; heap for terms; stack for environments and choice points; trail for undo on backtrack; most Prolog implementations compile to WAM instructions|implementation
CO28|First-Argument Indexing|Prolog indexes clauses by first argument; constant or functor in first argument → direct jump to matching clauses; variable first argument → must try all clauses; improves determinism|optimization
CO29|Determinism|goal has exactly one solution; no choice points remain after success; indexed goals and cuts can achieve determinism; deterministic code avoids unnecessary backtracking|optimization
CO30|Green Cut|cut that does not change the set of solutions; purely optimization; program correct with or without it|control
CO31|Red Cut|cut that changes the set of solutions; program gives different answers without it; makes code dependent on clause order; fragile|control
CO32|Steadfastness|predicate works correctly regardless of which arguments are instantiated at call time; robust bidirectional use|property
CO33|Mode|calling pattern of predicate; + = input (must be instantiated); - = output (will be bound); ? = either; documented as predicate(+Input, -Output)|documentation
CO34|Completeness|search strategy finds all solutions if they exist; Prolog's depth-first search is incomplete (may loop on infinite branches); iterative deepening is complete|property
CO35|Soundness|every answer found is a logical consequence of the program; Prolog is sound (if it answers, the answer is correct); unsound uses: assert, cut, var/nonvar tests|property
CO36|Monotonicity|adding clauses never removes solutions; pure Prolog is monotonic; cut, assert/retract, and negation break monotonicity|property
CO37|Constraint Logic Programming (CLP)|extension where variables have domains and constraints; solver prunes domains during search; CLP(FD) for integers, CLP(R) for reals, CLP(B) for booleans|extension
CO38|Tabling (Memoization)|storing computed answers for reuse; avoids recomputation and infinite loops on left-recursive predicates; SWI-Prolog: :- table predicate/arity.|extension
CO39|Module System|namespace mechanism; predicates exported from module, others hidden; import/export declarations; SWI-Prolog and SICStus have different module systems|extension
CO40|Definite Clause Grammar (DCG)|syntactic sugar for writing parsers and generators; --> operator; nonterminal(Args) --> body; compiled to difference lists|extension
CO41|Meta-Programming|programs that manipulate programs as data; Prolog terms represent Prolog code (homoiconicity); assert, retract, clause, functor, =.., call|technique
CO42|Higher-Order Programming|passing predicates as arguments; call/N, maplist, foldl; not true higher-order (no lambda) but achieves similar patterns|technique

# syntax(id|name|form|meaning|examples)
SY1|Atom|lowercase start or single-quoted; symbolic constants|named constant; ground term; predicate name|tom, 'Hello World', +, is, []
SY2|Number|integer or float literal|numeric constant; integer arbitrary precision (SWI)|42, -7, 3.14, 0xff, 0b1010, 0o77
SY3|Variable|uppercase start or underscore start|logical variable; placeholder for term|X, Parent, _temp, _
SY4|Anonymous Variable|single underscore _|independent unnamed variable; each occurrence distinct|parent(X, _) — second arg ignored
SY5|Compound Term|functor(arg1, arg2, ...)|structured data; tree; functor/arity identifies structure|f(a, b), point(3, 4), node(left, 1, right)
SY6|List|[Head\|Tail] or [a, b, c]|linked list; sugar for ./2 terms; [a,b,c] = .(a,.(b,.(c,[])))|[1,2,3], [H\|T], [a,b\|Rest], []
SY7|String (atom chars)|"text" or atom|SWI-Prolog default: "text" = string object; traditional: list of character codes; configurable via flags|"hello", atom_string(hello, S)
SY8|Clause (fact)|head.|unconditional assertion; fact in database|parent(tom, bob).
SY9|Clause (rule)|head :- body.|conditional assertion; head true if body true|ancestor(X,Y) :- parent(X,Y).
SY10|Clause (rule, conjunction)|head :- goal1, goal2.|comma = conjunction (AND); all goals must succeed|grandparent(X,Z) :- parent(X,Y), parent(Y,Z).
SY11|Clause (rule, disjunction)|head :- (goal1 ; goal2).|semicolon = disjunction (OR); try goal1, if fails try goal2|sibling(X,Y) :- (parent(Z,X), parent(Z,Y)), X \= Y.
SY12|If-Then-Else|(Cond -> Then ; Else)|soft cut; if Cond succeeds, commit to Then; else Else|max(X,Y,M) :- (X >= Y -> M = X ; M = Y).
SY13|Query|?- goal.|interactive query to Prolog top-level; triggers proof search|?- parent(tom, X).
SY14|Directive|:- directive.|executed at load time; not a query; side effects|:- use_module(library(lists)).
SY15|Operator Declaration|:- op(Prec, Type, Name).|define infix/prefix/postfix operator; precedence 1-1200; type: xfx, xfy, yfx, etc.|:- op(700, xfx, <>).
SY16|Comment (line)|% text|single-line comment to end of line|% this is a comment
SY17|Comment (block)|/* text */|multi-line block comment|/* multi-line */
SY18|DCG Rule|head --> body.|definite clause grammar rule; compiled to difference list predicate|sentence --> noun_phrase, verb_phrase.
SY19|List Comprehension (via findall)|findall(Template, Goal, List)|collect all solutions into list; like list comprehension|findall(X, member(X,[1,2,3]), Xs)
SY20|Partial List|[a, b \| T]|list with uninstantiated tail; open list; useful in difference lists|append uses [H\|T] pattern
SY21|Operator (arithmetic)|+, -, *, /, //, mod, ^, **|arithmetic operators; evaluated only within is/2, =:=, etc.; not auto-evaluated|X is 3 + 4 * 2.
SY22|Operator (comparison)|=:=, =\=, <, >, =<, >=|arithmetic comparison; both sides must be evaluable expressions|X > 0, 3 =:= 1+2.
SY23|Operator (unification)|=, \=|= attempts unification; \= succeeds if unification fails|X = f(Y), a \= b.
SY24|Operator (identity)|==, \==|structural identity without unification; X == Y succeeds only if already identical|X == Y fails if X and Y are unbound distinct variables
SY25|Neck Operator (:-)|head :- body|"if" connector; head is true if body is provable|parent(X,Y) :- father(X,Y).

# data_types(id|name|description|unification_behavior|operations|notes)
DT1|Atom|named constant; lowercase or quoted|unifies only with identical atom or unbound variable|atom_chars/2, atom_length/2, atom_concat/3, atom_string/2|atoms are interned (stored once, compared by pointer); immutable
DT2|Integer|arbitrary precision integer (SWI)|unifies with identical integer or unbound variable|arithmetic via is/2; comparison =:=, <, >, etc.; succ/2, plus/3|SWI: arbitrary precision; SICStus: also arbitrary; ISO: implementation-defined
DT3|Float|IEEE 754 double precision (typically)|unifies with identical float or unbound variable|arithmetic via is/2; 1.0 =\= 1 (integer ≠ float in unification)|avoid unification for float comparison; use =:= for arithmetic equality
DT4|Compound Term|functor(args); tree structure|unifies if same functor/arity and all args unify|functor/3, arg/3, =../2 (univ), copy_term/2|primary data structure; everything except atoms and numbers is compound
DT5|List|compound term using ./2; [H\|T] = .(H,T)|unifies element-by-element; [H\|T] matches non-empty list|member/2, append/3, length/2, nth0/3, msort/2, maplist/2-5|most common data structure; empty list [] is atom; [a] = .(a,[])
DT6|String|SWI: distinct string type; ISO: list of char codes|SWI strings unify with identical strings; not atoms|string_concat/3, string_code/3, string_length/2, split_string/4|SWI double-quoted = string by default; set_prolog_flag(double_quotes, atom) for traditional behavior
DT7|Dict (SWI extension)|tag{key:value, ...}; associative structure|unifies if tag and all present key-value pairs unify; partial matching|get_dict/3, put_dict/4, dict_keys/2, dict_pairs/3|SWI-Prolog extension; not ISO; efficient key lookup; pattern matching in head
DT8|Rational Number (SWI)|ratio of two integers; 1 rdiv 3|exact arithmetic; no floating-point rounding|arithmetic via is/2; rational/3 for decomposition|use_module(library(arithmetic)) or enabled by default in recent SWI
DT9|Char (atom of length 1)|single-character atom; 'a', 'Z'|unifies as normal atom|char_code/2, char_type/2|char_type(X, alpha) for character classification
DT10|Empty List ([])|atom representing end of list|unifies with [] only; does not unify with [_\|_]|used as base case in list recursion|[] is an atom, not a compound term

# built_ins(id|name|signature|description|mode|determinism|category)
BI1|unification|=/2|unify two terms; X = Y|?(X), ?(Y)|det (single MGU)|unification
BI2|unify_with_occurs_check|unify_with_occurs_check/2|unification with occurs check; fails on X = f(X)|?(X), ?(Y)|det|unification
BI3|not unifiable|\=/2|succeeds if X and Y do not unify|?(X), ?(Y)|semidet|unification
BI4|is|is/2|evaluate arithmetic expression and unify result; X is 3+4|-(Result), +(Expr)|det|arithmetic
BI5|arithmetic equal|=:=/2|true if both sides evaluate to same number|+(E1), +(E2)|semidet|arithmetic
BI6|arithmetic not equal|=\=/2|true if both sides evaluate to different numbers|+(E1), +(E2)|semidet|arithmetic
BI7|less than|</2|arithmetic less than|+(E1), +(E2)|semidet|arithmetic
BI8|greater than|>/2|arithmetic greater than|+(E1), +(E2)|semidet|arithmetic
BI9|less or equal|=</2|arithmetic less or equal|+(E1), +(E2)|semidet|arithmetic
BI10|greater or equal|>=/2|arithmetic greater or equal|+(E1), +(E2)|semidet|arithmetic
BI11|succ|succ/2|successor relation on natural numbers; succ(0,1); bidirectional|?(X), ?(Y)|semidet|arithmetic
BI12|plus|plus/3|plus(X,Y,Z) iff X+Y=Z; bidirectional when two of three known|?(X), ?(Y), ?(Z)|semidet|arithmetic
BI13|var|var/1|true if argument is unbound variable|?(X)|semidet|meta
BI14|nonvar|nonvar/1|true if argument is not an unbound variable|?(X)|semidet|meta
BI15|atom|atom/1|true if argument is an atom|?(X)|semidet|type_check
BI16|number|number/1|true if argument is a number|?(X)|semidet|type_check
BI17|integer|integer/1|true if argument is an integer|?(X)|semidet|type_check
BI18|float|float/1|true if argument is a float|?(X)|semidet|type_check
BI19|compound|compound/1|true if argument is a compound term (not atom, not number, not var)|?(X)|semidet|type_check
BI20|is_list|is_list/1|true if argument is a proper list (terminates with [])|+(X)|semidet|type_check
BI21|callable|callable/1|true if argument is atom or compound (can be called as goal)|?(X)|semidet|type_check
BI22|ground|ground/1|true if argument contains no unbound variables|?(X)|semidet|type_check
BI23|functor|functor/3|functor(Term, Name, Arity); decompose or construct term|?(T), ?(N), ?(A)|det|term_manip
BI24|arg|arg/3|arg(N, Term, Arg); access Nth argument of compound term (1-based)|+(N), +(T), -(A)|det|term_manip
BI25|=..|=../2|univ; Term =.. [Functor\|Args]; convert between term and list|?(T), ?(L)|det|term_manip
BI26|copy_term|copy_term/2|copy term with fresh variables replacing originals; preserves structure|+(In), -(Out)|det|term_manip
BI27|assert|assert/1|add clause to database at end (assertz) or beginning (asserta)|+(Clause)|det|database
BI28|asserta|asserta/1|add clause at beginning of predicate|+(Clause)|det|database
BI29|assertz|assertz/1|add clause at end of predicate|+(Clause)|det|database
BI30|retract|retract/1|remove first clause unifying with argument|+(Clause)|nondet|database
BI31|retractall|retractall/1|remove all clauses whose head unifies with argument|+(Head)|det|database
BI32|abolish|abolish/1|completely remove predicate definition|+(Functor/Arity)|det|database
BI33|clause|clause/2|retrieve clause from database; clause(Head, Body)|+(Head), -(Body)|nondet|database
BI34|findall|findall/3|collect all solutions of Goal into List; findall(Template, Goal, List)|+(Template), +(Goal), -(List)|det|all_solutions
BI35|bagof|bagof/3|like findall but fails if no solutions; respects variable quantification (^)|+(T), +(G), -(L)|nondet|all_solutions
BI36|setof|setof/3|like bagof but result sorted and deduplicated|+(T), +(G), -(L)|nondet|all_solutions
BI37|aggregate_all|aggregate_all/3|SWI: aggregate solutions; count, sum, max, min, bag, set|+(Template), +(Goal), -(Result)|det|all_solutions
BI38|forall|forall/2|true if for every solution of Cond, Action succeeds|+(Cond), +(Action)|semidet|all_solutions
BI39|call|call/1-8|invoke goal; call(Goal); call(Pred, Arg1, ...); higher-order|+(Goal), ?(Args...)|varies|meta
BI40|apply|apply/2|SWI: apply(Pred, ArgList); equivalent to =.. then call|+(Pred), +(Args)|varies|meta
BI41|assert/retract (dynamic)|:- dynamic pred/arity.|declaration allowing runtime modification of predicate|declaration|—|database
BI42|not|\+/1|negation as failure; \+ Goal succeeds if Goal fails|+(Goal)|semidet|control
BI43|true|true/0|always succeeds|—|det|control
BI44|fail|fail/0|always fails; forces backtracking|—|failure|control
BI45|halt|halt/0 or halt/1|exit Prolog; optional exit code|?(Code)|det|system
BI46|between|between/3|generate integers in range; between(Low, High, X)|+(Low), +(High), ?(X)|nondet|arithmetic
BI47|succ_clp|#=/2, #</2, etc. (CLP(FD))|constraint arithmetic; X #= Y + 1; bidirectional|?(X), ?(Y)|varies|clp
BI48|msort|msort/2|sort list; does not remove duplicates|+(List), -(Sorted)|det|list
BI49|sort|sort/2|sort and remove duplicates|+(List), -(Sorted)|det|list
BI50|sort/4|sort(+Key, +Order, +List, -Sorted)|sort by key and order (@<, @>, @=<, @>=); SWI|+(K), +(O), +(L), -(S)|det|list
BI51|write|write/1|write term to current output stream; no quoting|+(Term)|det|io
BI52|writeln|writeln/1|write term followed by newline|+(Term)|det|io
BI53|read|read/1|read term from current input stream; must end with period|-(Term)|det|io
BI54|print_message|print_message/2|SWI: formatted message output; print_message(Kind, Term)|+(Kind), +(Term)|det|io
BI55|format|format/2|formatted output; format("~w is ~d~n", [hello, 42])|+(Format), +(Args)|det|io
BI56|with_output_to|with_output_to/2|capture output to atom, string, or codes|+(Target), +(Goal)|det|io
BI57|number_vars|numbervars/3|bind free variables to terms '$VAR'(N) for pretty printing|+(Term), +(Start), -(End)|det|term_manip
BI58|term_to_atom|term_to_atom/2|convert between term and atom representation|?(Term), ?(Atom)|det|term_manip
BI59|atom_chars|atom_chars/2|decompose atom into list of character atoms|?(Atom), ?(Chars)|det|atom_manip
BI60|atom_codes|atom_codes/2|decompose atom into list of character codes|?(Atom), ?(Codes)|det|atom_manip
BI61|atom_concat|atom_concat/3|concatenate two atoms|?(A), ?(B), ?(C)|det or nondet|atom_manip
BI62|sub_atom|sub_atom/5|search/extract sub-atoms; sub_atom(Atom, Before, Length, After, Sub)|?(Atom), ?(B), ?(L), ?(A), ?(Sub)|nondet|atom_manip
BI63|char_code|char_code/2|convert between character atom and integer code|?(Char), ?(Code)|det|atom_manip
BI64|number_chars|number_chars/2|convert between number and list of character atoms|?(Number), ?(Chars)|det|atom_manip
BI65|catch|catch/3|catch(Goal, Catcher, Recovery); exception handling|+(Goal), ?(Catcher), +(Recovery)|varies|control
BI66|throw|throw/1|throw exception; caught by catch/3|+(Exception)|—|control
BI67|length|length/2|length of list; bidirectional (can generate list of length N)|?(List), ?(Length)|det or nondet|list
BI68|append|append/3|append two lists; bidirectional; generates splits on backtrack|?(A), ?(B), ?(C)|nondet|list
BI69|member|member/2|member(X, List); true if X is element of List; generates on backtrack|?(X), +(List)|nondet|list
BI70|last|last/2|last element of list|+(List), ?(Last)|det|list
BI71|nth0|nth0/3|0-based index into list|?(Index), ?(List), ?(Elem)|nondet|list
BI72|nth1|nth1/3|1-based index into list|?(Index), ?(List), ?(Elem)|nondet|list
BI73|reverse|reverse/2|reverse list|+(List), -(Rev)|det|list
BI74|flatten|flatten/2|flatten nested lists into single list|+(Nested), -(Flat)|det|list
BI75|msort|msort/2|merge sort; stable; does not remove duplicates|+(In), -(Out)|det|list
BI76|permutation|permutation/2|generate permutations of list on backtracking|+(List), -(Perm)|nondet|list
BI77|select|select/3|select(Elem, List, Rest); remove one element|?(E), ?(L), ?(R)|nondet|list
BI78|maplist|maplist/2-5|apply predicate to each element(s) of list(s)|+(Pred), +(Lists...)|semidet or det|higher_order
BI79|include|include/3|filter list keeping elements satisfying predicate|+(Pred), +(List), -(Included)|det|higher_order
BI80|exclude|exclude/3|filter list removing elements satisfying predicate|+(Pred), +(List), -(Excluded)|det|higher_order
BI81|foldl|foldl/4-6|fold list left with accumulator|+(Pred), +(List), +(V0), -(V)|det|higher_order
BI82|predsort|predsort/3|sort with user-defined comparison predicate|+(Comp), +(List), -(Sorted)|det|higher_order

# control(id|name|syntax|behavior|use_case|caution)
CT1|Conjunction (AND)|Goal1, Goal2|prove Goal1, then prove Goal2; both must succeed; bindings from Goal1 visible to Goal2|combining conditions; sequencing computations|left-to-right evaluation; order matters for efficiency and termination
CT2|Disjunction (OR)|Goal1 ; Goal2|try Goal1; if fails, try Goal2; creates choice point|alternative computations; equivalent to separate clauses|prefer separate clauses over semicolon for clarity; parenthesize when nested
CT3|Cut|!|succeeds once; removes all choice points since parent goal was called; prevents backtracking past cut|commit to first solution; efficiency; preventing unwanted alternatives|red cuts change semantics; green cuts only optimize; overuse harms readability and logical purity
CT4|If-Then-Else|( Cond -> Then ; Else )|soft cut; if Cond succeeds, commit to Then and skip Else; if Cond fails, execute Else; only first solution of Cond used|conditional branching; replaces cut+fail patterns; cleaner than explicit cut|Cond committed to first solution only (unlike full disjunction); parentheses required for correct parsing
CT5|If-Then|( Cond -> Then )|Cond succeeds → execute Then; Cond fails → entire construct fails (no Else)|conditional execution where failure is acceptable|fails silently if Cond fails; usually want If-Then-Else with explicit Else
CT6|Negation as Failure|\+ Goal|succeeds if Goal fails; implements closed world assumption|checking absence; inequality; constraint negation|unsound if Goal contains unbound variables (floundering); Goal bindings discarded even if Goal succeeds
CT7|Once|once(Goal)|prove Goal but commit to first solution only; like adding cut after first success|deterministic execution of potentially nondeterministic goal|loses completeness; all alternative solutions discarded
CT8|Ignore|ignore(Goal)|like once but succeeds even if Goal fails; equivalent to (Goal -> true ; true)|optional goals; side effects that may fail|swallows failure; use cautiously
CT9|Catch/Throw|catch(Goal, Catcher, Recovery)|structured exception handling; throw(Error) in Goal caught if Error unifies with Catcher; Recovery executed|error handling; resource cleanup; unexpected conditions|catch-all patterns catch too much; use specific error terms; ISO: error(Type, Context)
CT10|Forall|forall(Cond, Action)|true if for every solution of Cond, Action also succeeds; implemented as \+ (Cond, \+ Action)|universal quantification; checking properties of all solutions|negation-based implementation; does not bind variables; check-only, not generate
CT11|Aggregate|aggregate_all(Template, Goal, Result)|collect aggregated result over all solutions; count, sum, max, min, bag, set|statistical queries; counting solutions; collecting results|SWI-Prolog specific; more general than findall for aggregation
CT12|Between|between(Low, High, X)|generate or test integers in range [Low, High]|iterating over integer ranges; bounded search|both bounds must be integers; infinite range: use lazy generation or CLP(FD)

# unification(id|topic|description|example|notes)
UN1|Simple Unification|two atoms unify iff identical; variable unifies with any term|a = a succeeds; X = hello binds X to hello|most fundamental operation
UN2|Compound Unification|f(A1,...,An) = f(B1,...,Bn) iff same functor/arity and all Ai = Bi|point(X,3) = point(1,Y) → X=1, Y=3|recursive; structural matching
UN3|List Unification|[H\|T] = [1,2,3] → H=1, T=[2,3]|[A,B\|C] = [x,y,z] → A=x, B=y, C=[z]|list = nested ./2 compound terms
UN4|Occurs Check Failure|X = f(X) creates infinite term without occurs check|SWI default: succeeds (creates cyclic term); with occurs check: fails|use unify_with_occurs_check/2 for safety; rational tree unification in SWI
UN5|One-Way Matching|in head of clause, unification acts as pattern matching; more restrictive patterns match fewer goals|parent(tom, X) in head: matches query parent(tom, bob) with X=bob|first-argument indexing exploits this for efficiency
UN6|Difference from Assignment|X = 3 does not assign; it constrains X to be 3; if X already bound to 4, X = 3 fails|X = 3, X = 3 succeeds; X = 3, X = 4 fails|single-assignment semantics; not imperative assignment

# search(id|name|description|properties|implementation_notes)
SR1|Depth-First Search (default)|Prolog explores leftmost goal, tries first matching clause; on failure, backtracks to most recent choice point|incomplete (may loop on infinite branches); space-efficient (linear in depth); finds first solution fast|WAM stack-based implementation; clause ordering determines search order
SR2|Iterative Deepening|depth-limited search with increasing depth limit; complete and optimal for unit-cost goals|complete; finds shortest proof; time overhead ~d/(d-1) where d=branching factor; space O(d)|call_with_depth_limit/3 or library(bounds); not default behavior
SR3|Breadth-First Search|explore all goals at depth n before depth n+1; complete; finds shortest proof; exponential space|complete; optimal; impractical for large search spaces due to memory|not built into standard Prolog; implemented via agenda (queue of goals)
SR4|Branch and Bound|search with pruning: maintain best-known bound; prune branches worse than current best|optimal for optimization problems; requires monotonic cost function|library(bounds) or manual implementation with assert/nb_setval
SR5|Tabling (Memoization)|store answers for tabled predicates; reuse on subsequent calls; detects loops (avoids infinite recursion on left-recursive rules)|complete for bounded programs; avoids recomputation; fixed-point semantics for recursive predicates|SWI: :- table pred/arity.; XSB Prolog native; SLG resolution replaces SLD for tabled predicates
SR6|CLP(FD) Search|labeling/2 assigns values to constrained variables; search strategy: leftmost, ff (first-fail), bisect, enum; variable and value ordering heuristics|complete within domain bounds; constraint propagation prunes before search; first-fail often best heuristic|use_module(library(clpfd)); label only after posting all constraints; indomain vs labeling options

# meta(id|name|description|signature|use_case|notes)
ME1|clause/2|retrieve clause from database|clause(+Head, -Body)|meta-interpreters; program analysis; reflection|only works on dynamic predicates or with source-accessible modules
ME2|assert/retract|modify program at runtime|asserta/1, assertz/1, retract/1, retractall/1|memoization (assert computed results); global state; learning|breaks monotonicity and referential transparency; requires :- dynamic declaration; use sparingly
ME3|functor/3|decompose or construct term by functor and arity|functor(?Term, ?Name, ?Arity)|generic term processing; meta-interpreters|functor(f(a,b), F, A) → F=f, A=2; functor(T, f, 2) → T=f(_,_)
ME4|=.. (univ)|convert between term and list [Functor\|Args]|?Term =.. ?List|generic term construction/deconstruction; calling predicates by computed name|f(a,b) =.. [f,a,b]; T =.. [g,1,2] → T=g(1,2)
ME5|arg/3|access Nth argument of term|arg(+N, +Term, -Arg)|indexed argument access without deconstructing entire term|1-based; arg(2, f(a,b,c), X) → X=b
ME6|copy_term/2|copy term with fresh variables|copy_term(+Original, -Copy)|creating independent copies for constraint propagation; avoiding variable capture|copy_term(f(X,X), Y) → Y=f(_A,_A) (same fresh var in both positions)
ME7|call/N|call predicate with additional arguments|call(+Pred, ?Arg1, ..., ?ArgN)|higher-order programming; maplist implementation; partial application|call(succ, 3, X) → X=4; enables passing predicates as arguments
ME8|meta_predicate declaration|:- meta_predicate pred(:, +, -).|SWI: declare arguments that are goals or module-qualified|module-aware meta-predicates; proper resolution of predicates across modules|colon (:) marks goal arguments; ensures correct module resolution
ME9|term_variables/2|extract all variables from term|term_variables(+Term, -Vars)|constraint posting; variable collection; debugging|term_variables(f(X,g(Y,X)), Vs) → Vs=[X,Y]
ME10|numbervars/3|bind free variables to '$VAR'(N) terms|numbervars(+Term, +Start, -End)|pretty-printing terms with named variables; serialization|numbervars(f(X,Y), 0, _) → X='$VAR'(0), Y='$VAR'(1)

# io(id|name|description|signature|notes)
IO1|write/1|write term; operators in functional notation; no quoting|write(+Term)|atoms with special chars not quoted; variables written as names
IO2|writeq/1|write term in Prolog-readable form; atoms quoted as needed|writeq(+Term)|output can be read back with read/1; round-trip safe
IO3|write_canonical/1|canonical form; always parseable; no operator sugar|write_canonical(+Term)|most reliable for serialization
IO4|print/1|write using portray/1 hook if defined; else like write|print(+Term)|customizable output via user-defined portray/1
IO5|read/1|read one Prolog term from input; term must end with period (.)|read(-Term)|blocks until complete term received; raises error on syntax error
IO6|read_term/2|read with options; variable names, term position, etc.|read_term(-Term, +Options)|options: variable_names(Bindings), syntax_errors(error\|fail\|quiet)
IO7|format/2|formatted output; ~w=write, ~d=integer, ~a=atom, ~n=newline, ~`c=fill char|format(+Format, +Args)|format("~w has ~d items~n", [bob, 3])
IO8|format/3|formatted output to stream|format(+Stream, +Format, +Args)|format(user_error, "Error: ~w~n", [Msg])
IO9|open/4|open file as stream|open(+File, +Mode, -Stream, +Options)|Mode: read, write, append; Options: encoding, type
IO10|close/1|close stream|close(+Stream)|always close streams; use setup_call_cleanup for safety
IO11|stream_to_list|read all terms or characters from stream|read_term_from_atom, stream_to_lazy_list (SWI)|various approaches; library(pure_input) for lazy reading
IO12|with_output_to/2|capture output of goal to atom/string/codes|with_output_to(atom(A), write(hello))|A = hello; useful for string building via write predicates
IO13|phrase_from_file/2|SWI: apply DCG to file contents lazily|phrase_from_file(Grammar, File)|efficient file parsing with DCGs; library(pio)

# modules(id|name|description|syntax|notes)
MO1|Module Declaration|:- module(Name, ExportList).|first directive in file; defines module name and exported predicates|:- module(my_module, [my_pred/2, other/3]).
MO2|Use Module|:- use_module(library(lists)).|import predicates from module (library or file)|:- use_module(library(clpfd)). for constraint programming
MO3|Import Specific|:- use_module(library(lists), [member/2]).|import only listed predicates; prevents namespace pollution|explicit imports document dependencies
MO4|Reexport|:- reexport(library(lists)).|export predicates from imported module as if defined locally|used in wrapper/facade modules
MO5|Module-Qualified Call|module:predicate(Args)|explicitly call predicate in specific module|lists:member(X, L); overrides import resolution
MO6|Dynamic in Module|:- dynamic module:pred/arity.|declare dynamic predicate in another module|needed for modifying predicates across module boundaries
MO7|Meta-Predicate|:- meta_predicate pred(:).|declare arguments that are goals; ensures module-correct resolution|: means goal argument; 0-9 means goal with N additional args; + and - are non-goal

# techniques(id|name|description|pattern|when_used|example)
TE1|Accumulator Pattern|carry partial result through recursion; tail-recursive; final result bound when base case reached|pred(In, Out) :- pred_acc(In, InitAcc, Out). pred_acc([], Acc, Acc). pred_acc([H\|T], Acc0, Acc) :- NewAcc = ..., pred_acc(T, NewAcc, Acc).|building results iteratively; enabling TRO; reverse-then-return|sum_list([], 0). → sum_list_acc([], Acc, Acc). sum_list_acc([H\|T], Acc0, Sum) :- Acc1 is Acc0 + H, sum_list_acc(T, Acc1, Sum).
TE2|Difference Lists|list represented as pair (List-Hole); append in O(1) by unifying hole with new elements|dl_append(X-Y, Y-Z, X-Z).|efficient list building; DCG implementation; avoiding quadratic append|open-ended list [a,b\|Hole] with Hole unbound; unify Hole=[c\|NewHole]
TE3|Generate and Test|generate candidates via nondeterminism; test with constraints; backtrack on failure|solve(X) :- generate(X), test(X).|brute-force search; constraint satisfaction; puzzle solving|permutation(List, Perm), is_sorted(Perm) — but prefer constraints
TE4|Constraint-Then-Generate|post constraints first; then label/generate; solver prunes search space before enumeration|solve(Vars) :- post_constraints(Vars), label(Vars).|CLP(FD) problems; scheduling; Sudoku; much more efficient than generate-and-test|Vars ins 1..9, all_different(Vars), ..., label(Vars).
TE5|Meta-Interpreter|Prolog interpreter written in Prolog; exploits homoiconicity; can add tracing, probabilities, explanations|solve(true). solve((A,B)) :- solve(A), solve(B). solve(Goal) :- clause(Goal, Body), solve(Body).|custom execution strategies; debugging; explanation systems; probabilistic logic|extend basic interpreter with cut handling, negation, or custom search
TE6|Definite Clause Grammar (DCG)|grammar rules compiled to difference-list predicates; --> for rules; {} for inline Prolog goals|sentence --> noun_phrase, verb_phrase. noun_phrase --> [the], noun.|parsing; natural language processing; serialization; sequence generation|phrase(sentence, [the,cat,sat], []) tests if input parses; phrase(sentence, X) generates
TE7|Assert-Based Memoization|assert computed results as facts; subsequent calls match without recomputation|:- dynamic fib_cache/2. fib(N, F) :- fib_cache(N, F), !. fib(N, F) :- compute..., assertz(fib_cache(N, F)).|expensive computations; dynamic programming where tabling not available|impure; breaks logical semantics; prefer tabling (:- table fib/2.) when available; requires cleanup on program restart
TE8|Failure-Driven Loop|use fail to force backtracking through all solutions; side effects in loop body|print_all(X) :- member(X, List), write(X), nl, fail. print_all(_).|I/O; side effects over all solutions; imperative-style iteration|impure; prefer forall/2 or maplist for cleaner code; second clause catches final failure
TE9|Partial Evaluation|specializing a general predicate for known arguments at compile time; unfold calls|:- use_module(library(apply_macros)).|optimization; constant folding; meta-programming|SWI apply_macros: compile-time expansion of maplist, etc.
TE10|Constraint Handling Rules (CHR)|multi-headed rules for constraint propagation and simplification; user-defined constraint solvers|:- chr_constraint leq/2. reflexivity @ leq(X,X) <=> true.|building custom constraint solvers; domain-specific reasoning|SWI: library(chr); CHR rules fire when constraints posted; simplification (<=>), propagation (==>), simpagation
TE11|Global State (nb_setval/nb_getval)|mutable global variables using non-backtrackable assignment|nb_setval(counter, 0), nb_getval(counter, V), V1 is V+1, nb_setval(counter, V1)|counters; global accumulators; performance-critical state|non-backtrackable: value persists across backtracking; use with extreme caution; breaks logical semantics
TE12|Tabling for Fixed Point|:- table pred/arity as subsumptive or variant.|compute fixed point of recursive definitions; datalog-style reasoning|transitive closure; reachability; program analysis; deductive databases|SWI tabling: variant (default) or subsumptive; handles left-recursion; avoids infinite loops
TE13|Attributed Variables|attach attributes (constraints) to variables; trigger wakeup when unified|put_attr(X, Module, Value), attr_unify_hook(Value, Term)|CLP implementation; custom constraint solvers; delayed goals|foundation for CLP(FD), CLP(R), etc.; verify_attributes called on unification

# libraries(id|name|module_path|key_predicates|purpose)
LI1|lists|library(lists)|member/2, append/3, length/2, nth0/3, nth1/3, last/2, msort/2, permutation/2, flatten/2, select/3, subtract/3, intersection/3, union/3|core list operations; auto-loaded in SWI
LI2|apply|library(apply)|maplist/2-5, include/3, exclude/3, foldl/4-6, convolution/4|higher-order list operations; functional-style programming
LI3|clpfd|library(clpfd)|in/2, ins/2, #=/2, #</2, #>/2, all_different/1, all_distinct/1, label/1, labeling/2, tuples_in/2, serialized/2, sum/3|constraint logic programming over finite domains (integers)
LI4|clpr|library(clpr)|{Constraints}; maximizes, minimizes|constraint logic programming over reals; linear arithmetic constraints
LI5|clpb|library(clpb)|sat/1, taut/2, labeling/1|constraint logic programming over booleans; SAT solving
LI6|aggregate|library(aggregate)|aggregate_all/3, aggregate/4, foreach/2|aggregation operations: count, sum, max, min, bag, set over solutions
LI7|ordsets|library(ordsets)|ord_subtract/3, ord_intersection/3, ord_union/3, ord_memberchk/2|set operations on sorted lists without duplicates; O(n) operations
LI8|assoc|library(assoc)|assoc_to_keys/2, assoc_to_values/2, get_assoc/3, put_assoc/4, assoc_to_list/2|AVL-tree-based association lists; O(log n) lookup and insert
LI9|rbtrees|library(rbtrees)|rb_insert/4, rb_lookup/3, rb_delete/4, rb_visit/2|red-black tree maps; O(log n); alternative to library(assoc)
LI10|dcg/basics|library(dcg/basics)|string/3, integer/3, float/3, whites/2, blanks/2, nonblanks/2|basic DCG utilities for parsing; tokenization helpers
LI11|pio|library(pio)|phrase_from_file/2, phrase_from_stream/2|pure I/O: apply DCG to file/stream contents; lazy reading
LI12|chr|library(chr)|chr_constraint/1 declaration; simplex solver; custom constraint rules|Constraint Handling Rules; user-defined constraint solvers
LI13|persistency|library(persistency)|:- persistent declaration; db_attach/2; db_sync/1|simple persistent storage; assert-based with file backing; survives restart
LI14|http|library(http/...)|http_server/2, http_handler/3, http_reply/2, http_open/3|HTTP server and client; web applications; REST APIs; SWI web framework
LI15|pengines|library(pengines)|pengine_create/1, pengine_ask/3, pengine_next/2|sandboxed remote Prolog query execution; used by SWISH (web IDE)
LI16|plunit|library(plunit)|:- begin_tests(Name). test(Name) :- ... :- end_tests(Name).|unit testing framework; test cases with expected outcomes; run_tests/0
LI17|debug|library(debug)|debug/3, assertion/1, spy/1, trace/0, guitracer|debugging utilities; conditional debug output; spy points; graphical tracer
LI18|option|library(option)|option/2, option/3, merge_options/3|option list processing; named parameters pattern
LI19|csv|library(csv)|csv_read_file/3, csv_write_file/3, csv_read_row/3|CSV file reading and writing; row-at-a-time or bulk
LI20|pairs|library(pairs)|pairs_keys/2, pairs_values/2, pairs_keys_values/3, msort/2 with Key-Value pairs|key-value pair operations; Key-Value terms; group_by pattern
LI21|solution_sequences|library(solution_sequences)|distinct/2, limit/2, offset/3, order_by/2, group_by/4|SQL-like solution modifiers; deduplication; pagination; ordering
LI22|settings|library(settings)|:- setting(Name, Type, Default, Help).; set_setting/2, setting/2|application configuration; typed settings with defaults

# failure_modes(id|topic|mode|cause|consequence|prevention)
FL1|search|infinite loop|left-recursive predicate without tabling; unbounded search depth; mutual recursion without base case|query never terminates; stack overflow|use tabling for left-recursive predicates; ensure base cases; iterative deepening; depth limits
FL2|search|incomplete search|depth-first search misses solutions on deep/infinite branches; clause ordering puts infinite branch first|solutions exist but are never found|reorder clauses; use iterative deepening; use tabling; BFS for completeness-critical applications
FL3|unification|unexpected success|missing occurs check; X = f(X) succeeds creating cyclic term (SWI default)|circular data structures; unexpected answers; infinite printing|use unify_with_occurs_check/2 when structural safety matters; enable occurs_check flag
FL4|unification|unexpected failure|terms differ in arity or functor; number type mismatch (1 vs 1.0); atom vs string|goal fails silently; no error message; hard to debug|check term structure with functor/3; use =:= for numeric comparison; consistent use of types
FL5|negation|floundering|\+ Goal where Goal contains unbound variables; NAF only sound for ground goals|incorrect answers; goals that should fail succeed or vice versa|ensure arguments ground before negation; use when/2 or constraints to delay; or use CLP constraints instead
FL6|cut|lost solutions|red cut prunes valid search branches; cut too early in clause|correct answers missing from result set; incomplete predicate|prefer if-then-else over raw cut; use green cuts only; test predicate with findall to verify all solutions present
FL7|performance|quadratic append|building list by appending to end in each recursive call; append/3 is O(n)|O(n²) list construction; slow on large lists|use accumulator pattern (prepend + reverse at end); or difference lists for O(1) append
FL8|performance|space leak|choice points preventing garbage collection of stack frames; backtrackable state retained unnecessarily|excessive memory use; eventual out-of-memory|use cut or once/1 to remove unnecessary choice points; use first-argument indexing; deterministic predicates should be deterministic
FL9|database|inconsistent state|assert/retract during backtracking; backtracking undoes bindings but not assert/retract side effects|database modifications persist even after failure; surprising state|use transaction-like patterns; nb_setval for non-backtrackable state; or redesign to avoid dynamic predicates
FL10|modules|predicate not found|missing use_module; wrong arity; typo in predicate name; private (unexported) predicate|existence_error at runtime|check imports; use make/0 to reload; verify exports in module declaration; compiler warnings
FL11|io|read failure|input not terminated with period (.); unexpected end of stream; syntax error in input|exception or hang waiting for more input|validate input; use catch for error handling; read_term with syntax_errors option; prompt user for period
FL12|arithmetic|instantiation error|is/2 with unbound variables on right side; X is Y + 1 where Y is unbound|instantiation_error exception|use CLP(FD) for arithmetic with unknowns: Y + 1 #= X; or ensure arguments instantiated before is/2
FL13|types|wrong term type|passing atom where compound expected; passing list where atom expected; silent unification failure|goal fails with no error; logic error|use must_be/2 for argument validation; type-checking predicates (atom/1, compound/1, is_list/1); assertion/1 for debugging

# distinctions(id|side_a|side_b|key_asymmetry)
DI1|Unification (=)|Assignment (=, :=)|unification: symmetric, bidirectional, single-assignment, may fail; assignment: directional, destructive update, always succeeds (in imperative languages); Prolog = is unification, not assignment
DI2|Facts|Rules|facts: unconditional truths, no body; rules: conditional truths, body must be proven; both are clauses; facts are rules with body true
DI3|Deterministic|Nondeterministic|deterministic: exactly one solution, no choice points; nondeterministic: multiple solutions via backtracking, choice points remain; deterministic = efficient, no wasted search
DI4|Green Cut|Red Cut|green: optimization only, program correct without it; red: changes meaning, program gives wrong answers without it; green cuts are safe; red cuts are dangerous
DI5|Depth-First|Breadth-First|DFS: Prolog default; incomplete but space-efficient; finds first solution fast; BFS: complete, optimal, but exponential space; not default in any Prolog
DI6|Generate and Test|Constrain and Generate|generate-test: enumerate then filter, exponential; constrain-generate: post constraints then label, solver prunes search space, much faster; CLP(FD) enables constrain-generate
DI7|findall|bagof/setof|findall: never fails (returns [] if no solutions), ignores variable scoping; bagof: fails if no solutions, respects existential quantification (^); setof: like bagof but sorted and deduplicated
DI8|assert/retract|Pure Logic|assert/retract: side effects, non-monotonic, not undone on backtracking; pure logic: declarative, monotonic, backtracking-safe; prefer pure logic; use assert only when necessary
DI9|ISO Prolog|SWI-Prolog Extensions|ISO: core standard (1995), portable, limited; SWI extensions: dicts, tabling, strings, modules, HTTP, pengines, constraint solvers; most real programs use extensions
DI10|SLD Resolution|SLDNF Resolution|SLD: pure Horn clauses, no negation; SLDNF: adds negation as failure; Prolog uses SLDNF; sound for stratified programs
DI11|Backtrackable|Non-Backtrackable|backtrackable: undone on backtracking (variable bindings); non-backtrackable: persists across backtracking (assert, nb_setval, I/O side effects); understanding this distinction critical for correctness
DI12|Atom|String (SWI)|atom: interned, compared by pointer, immutable, unifies with =; string: SWI-specific, not interned, double-quoted by default, separate type; set double_quotes flag to control
DI13|Variant Tabling|Subsumptive Tabling|variant: cache answer per unique variable pattern; call-variant must match exactly; subsumptive: more general call subsumes specific; fewer recomputations; subsumptive more powerful but more complex
DI14|Prolog|Datalog|Prolog: full Horn clauses, function symbols, Turing-complete, may not terminate; Datalog: restricted to predicate symbols without function symbols, always terminates, decidable, database-oriented; tabled Prolog approximates Datalog

# relationships(from|rel|to)
# Foundation → execution
CO1|implemented_by|CO16
CO2|characterizes|CO1
CO3|basis_of|CO4,CO5,CO6
CO4|specializes|CO3
CO5|specializes|CO3
CO6|triggers|CO16
CO7|composed_of|CO4,CO5
CO7|identified_by|CO8,CO9
CO10|instance_of|CO3

# Execution model
CO11|fundamental_to|CO16
CO12|produced_by|CO11
CO13|specializes|CO12
CO14|validates|CO11
CO15|implements|CO16
CO16|produces|CO17
CO17|traversed_by|CO18
CO18|requires|CO19
CO19|created_by|CO7

# Control
CO20|modifies|CO17
CO20|removes|CO19
CO21|implements|CO22
CO22|requires|CO21
CO30|specializes|CO20
CO31|specializes|CO20

# Properties
CO26|optimizes|CO18
CO27|executes|CO3
CO28|optimizes|CO19
CO29|reduces|CO19
CO32|ensures|CO7
CO34|lacking_in|CO16
CO35|characterizes|CO16
CO36|broken_by|CO20,CO22,BI27

# Extensions
CO37|extends|CO1
CO38|extends|CO16
CO39|extends|CO7
CO40|extends|CO3
CO41|leverages|CO3
CO42|extends|CO1

# Syntax → concepts
SY1|instance_of|DT1
SY2|instance_of|DT2
SY3|instance_of|CO23
SY4|specializes|SY3
SY5|instance_of|DT4
SY6|instance_of|DT5
SY8|instance_of|CO4
SY9|instance_of|CO5
SY12|implements|CT4
SY13|instance_of|CO6
SY18|instance_of|CO40
SY21|used_by|BI4

# Built-in categories
BI1|implements|CO11
BI2|implements|CO11,CO14
BI4|implements|SY21
BI13|tests|CO23
BI14|tests|CO23
BI27|implements|ME2
BI33|implements|ME1
BI34|implements|BI35
BI35|extends|BI34
BI36|extends|BI35
BI39|implements|CO42
BI42|implements|CO22
BI65|implements|CT9
BI78|implements|CO42

# Control → concepts
CT1|implements|CO15
CT2|creates|CO19
CT3|implements|CO20
CT4|extends|CT3
CT6|implements|CO22
CT7|implements|CO29

# Search strategies
SR1|default_for|CO16
SR2|improves|SR1
SR2|achieves|CO34
SR3|achieves|CO34
SR5|implements|CO38
SR6|requires|LI3

# Technique → concept
TE1|enables|CO26
TE2|optimizes|BI68
TE3|pattern_of|CO16
TE4|improves|TE3
TE4|requires|CO37
TE5|leverages|CO41
TE6|implements|CO40
TE7|implements|CO38
TE7|uses|BI27
TE8|uses|BI44,CO18
TE10|extends|CO37
TE11|breaks|CO36
TE12|implements|CO38
TE13|enables|CO37

# Library → technique/concept
LI1|provides|BI67,BI68,BI69,BI70,BI73,BI74,BI76,BI77
LI2|provides|BI78,BI79,BI80,BI81
LI3|implements|CO37
LI4|implements|CO37
LI5|implements|CO37
LI6|provides|BI37
LI7|implements|DT5
LI8|provides|DT4
LI9|provides|DT4
LI10|supports|CO40
LI11|supports|CO40
LI12|implements|TE10
LI16|enables|CO32
LI17|supports|CO17

# Failure → concept
FL1|caused_by|SR1
FL2|caused_by|SR1
FL3|caused_by|CO14
FL4|caused_by|CO11
FL5|caused_by|CO22
FL6|caused_by|CO20
FL7|caused_by|BI68
FL8|caused_by|CO19
FL9|caused_by|BI27,BI30
FL12|caused_by|BI4

# Distinction mappings
DI1|distinguishes|CO11
DI2|distinguishes|CO4,CO5
DI3|distinguishes|CO29,CO19
DI4|distinguishes|CO30,CO31
DI5|distinguishes|SR1,SR3
DI6|distinguishes|TE3,TE4
DI7|distinguishes|BI34,BI35
DI8|distinguishes|BI27,CO36
DI9|distinguishes|CO16,CO37
DI10|distinguishes|CO16,CO22
DI11|distinguishes|CO12,BI27
DI12|distinguishes|DT1,DT6
DI13|distinguishes|CO38
DI14|distinguishes|CO1,CO38

# decode_legend
# id_prefixes: CO=concept, SY=syntax, DT=data_type, BI=built_in, CT=control, UN=unification, SR=search, ME=meta, IO=io, MO=module, TE=technique, LI=library, FL=failure_mode, DI=distinction
# rel_types: implemented_by|characterizes|basis_of|specializes|triggers|composed_of|identified_by|instance_of|fundamental_to|produced_by|validates|implements|produces|traversed_by|requires|created_by|modifies|removes|ensures|lacking_in|broken_by|extends|leverages|used_by|tests|creates|default_for|improves|achieves|pattern_of|uses|breaks|enables|provides|supports|caused_by|optimizes|reduces|distinguishes
# mode notation: + = input (must be instantiated at call); - = output (will be bound by call); ? = either direction; : = module-qualified goal
# determinism: det = exactly one solution; semidet = zero or one solutions; nondet = zero or more solutions; failure = always fails
# SWI-specific: features marked as SWI are SWI-Prolog specific and may not be available in other Prolog implementations (SICStus, GNU Prolog, XSB, etc.)
# ISO compliance: predicates marked ISO are defined in ISO/IEC 13211-1:1995; many practical predicates are extensions
# confidence: synthetic domain knowledge — not extracted from a single source document

# relation_mapping(doc_rel|canonical_rel|notes)
implements|implements|exact match
specializes|specializes|exact match
extends|extends|exact match
requires|requires|exact match
enables|enables|exact match
instance_of|instance_of|exact match
composed_of|composed_of|exact match
validates|validates|exact match
modifies|modifies|no canon — flagged in prior doc
removes|removes|exact match
distinguishes|distinguishes|exact match
characterizes|characterizes|no canon — flagged in prior docs
implemented_by|implements|reverse query direction
traversed_by|traverses|reverse query direction; "X traversed_by Y" → "Y traverses X"
produced_by|produces|reverse query direction; "X produced_by Y" → "Y produces X"
caused_by|causes|reverse query direction; "X caused_by Y" → "Y causes X"
broken_by|disrupts|reverse query direction; "X broken_by Y" → "Y disrupts X"
used_by|input_to|"X used_by Y" → "Y input_to X" or reverse; loose fit
identified_by|determined_by|"X identified_by Y" → "X determined_by Y"
created_by|produces|"X created_by Y" → "Y produces X"
default_for|favors|loose fit; "X default_for Y" ≈ "X favors Y"
basis_of|foundation_for|"X basis_of Y" → "X foundation_for Y"
fundamental_to|foundation_for|"X fundamental_to Y" → "X foundation_for Y"
produces|produces|exact match
triggers|activates|"triggers" not in canon; closest is "activates"
tests|validates|"tests" ≈ "validates"; checking correctness
provides|contains|loose fit; "library provides predicate" ≈ "contains"
supports|enables|loose fit; "X supports Y" ≈ "X enables Y"
optimizes|simplifies|"X optimizes Y" ≈ "X simplifies Y"
reduces|simplifies|"X reduces Y" ≈ "X simplifies Y"
improves|simplifies|"X improves Y" ≈ "X simplifies Y"
achieves|solves|"X achieves Y" ≈ "X solves Y"
leverages|depends_on|"X leverages Y" → "X depends_on Y"
pattern_of|instance_of|"X pattern_of Y" → "X instance_of Y"
breaks|disrupts|"X breaks Y" → "X disrupts Y"
creates|produces|"X creates Y" → "X produces Y"
uses|depends_on|"X uses Y" → "X depends_on Y"
lacking_in|limits|"X lacking_in Y" → "X limits Y"; property Y doesn't have
ensures|validates|"X ensures Y" ≈ "X validates Y"
