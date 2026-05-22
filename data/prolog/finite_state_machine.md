%% ============================================================
%% FINITE STATE MACHINES — DOMAIN PROLOG
%% Connects to core prolog, math logic, data structures, algorithms.
%% Facts from fsm.compact
%% ============================================================


%% --- CHOMSKY HIERARCHY ---
%% Type 3 ⊂ Type 2 ⊂ Type 1 ⊂ Type 0. Decidable ⊂ Type 0.
specializes(hi1, hi2).   % regular ⊂ context-free
specializes(hi2, hi3).   % context-free ⊂ context-sensitive
specializes(hi3, hi4).   % context-sensitive ⊂ recursively enumerable
specializes(hi5, hi4).   % decidable ⊂ recursively enumerable

%% Machines that recognize each level.
implements(mt1, hi1).    % DFA implements regular
implements(mt2, hi1).    % NFA implements regular
implements(mt3, hi1).    % ε-NFA implements regular
implements(mt6, hi2).    % PDA implements context-free
implements(mt7, hi2).    % DPDA implements context-free (subset)
implements(mt8, hi4).    % Turing machine implements r.e.


%% --- MACHINE TYPE EQUIVALENCES ---
%% Same recognition power, different formalism.
equivalent_to(mt1, mt2).   % DFA ≡ NFA
equivalent_to(mt2, mt3).   % NFA ≡ ε-NFA
equivalent_to(mt4, mt5).   % Moore ≡ Mealy
equivalent_to(mt1, mt9).   % DFA ≡ two-way DFA

%% NPDA strictly more powerful than DPDA.
%% This is NOT equivalence — specializes, not equivalent_to.
generalizes(mt6, mt7).     % NPDA generalizes DPDA


%% --- MACHINE COMPONENTS ---
%% What each machine type is composed of.
part_of(cm1, mt1). part_of(cm1, mt2). part_of(cm1, mt3).
part_of(cm1, mt4). part_of(cm1, mt5). part_of(cm1, mt6). part_of(cm1, mt7).
part_of(cm2, mt1). part_of(cm2, mt2). part_of(cm2, mt3).
part_of(cm2, mt4). part_of(cm2, mt5). part_of(cm2, mt6). part_of(cm2, mt7).
part_of(cm3, mt1). part_of(cm3, mt4). part_of(cm3, mt5).
part_of(cm4, mt2). part_of(cm4, mt3). part_of(cm4, mt6).
part_of(cm5, mt1). part_of(cm5, mt2). part_of(cm5, mt3).
part_of(cm5, mt4). part_of(cm5, mt5). part_of(cm5, mt6). part_of(cm5, mt7).
part_of(cm6, mt1). part_of(cm6, mt2). part_of(cm6, mt3).
part_of(cm6, mt6). part_of(cm6, mt7). part_of(cm6, mt10).
part_of(cm7, mt4). part_of(cm7, mt5). part_of(cm7, mt10).
part_of(cm8, mt4).   % Moore output function
part_of(cm9, mt5).   % Mealy output function
part_of(cm10, mt6). part_of(cm10, mt7).  % PDA stack alphabet
part_of(cm11, mt6). part_of(cm11, mt7).  % PDA initial stack symbol


%% --- FOUNDATION DEPENDENCIES ---
%% How foundational concepts build on each other.
derived_from(fo3, fo1).   % string derives from alphabet
derived_from(fo3, fo2).   % string derives from symbols
specializes(fo4, fo3).    % empty string specializes string
derived_from(fo5, fo3).   % language derives from string
derived_from(fo14, fo1).  % Kleene star derives from alphabet
derived_from(fo15, fo14). % Kleene plus derives from Kleene star
derived_from(fo16, fo1).  % alphabet power derives from alphabet
specializes(fo19, fo21).  % prefix specializes substring
specializes(fo20, fo21).  % suffix specializes substring
input_to(fo18, fo3).      % concatenation operates on strings
input_to(fo24, fo1).      % homomorphism operates on alphabet
input_to(fo24, fo5).      % homomorphism operates on language


%% --- CLOSURE PROPERTIES ---
%% Regular languages: closed under everything.
enables(hi1, cl1).   % regular closed under union
enables(hi1, cl2).   % regular closed under concatenation
enables(hi1, cl3).   % regular closed under Kleene star
enables(hi1, cl4).   % regular closed under complement
enables(hi1, cl5).   % regular closed under intersection
enables(hi1, cl6).   % regular closed under difference
enables(hi1, cl7).   % regular closed under reversal
enables(hi1, cl8).   % regular closed under homomorphism
enables(hi1, cl9).   % regular closed under inverse homomorphism

%% Context-free: closed under union, concat, star; NOT complement, intersection.
enables(hi2, cl11).  % CF closed under union
enables(hi2, cl12).  % CF closed under concatenation
enables(hi2, cl13).  % CF closed under Kleene star
enables(hi2, cl16).  % CF closed under intersection with regular
enables(hi2, cl17).  % CF closed under homomorphism
enables(hi2, cl18).  % CF closed under inverse homomorphism
enables(hi2, cl19).  % CF closed under reversal
prevents(hi2, cl14). % CF NOT closed under complement
prevents(hi2, cl15). % CF NOT closed under intersection
prevents(hi2, cl20). % CF NOT closed under difference

%% Operations link to closure properties.
determined_by(op1, cl1).  determined_by(op1, cl11).   % union
determined_by(op2, cl2).  determined_by(op2, cl12).   % concatenation
determined_by(op3, cl3).  determined_by(op3, cl13).   % Kleene star
determined_by(op4, cl4).  determined_by(op4, cl14).   % complement
determined_by(op5, cl5).  determined_by(op5, cl15).   % intersection
determined_by(op5, cl16).                              % intersection with regular
determined_by(op6, cl6).  determined_by(op6, cl20).   % difference
determined_by(op7, cl7).  determined_by(op7, cl19).   % reversal
determined_by(op8, cl8).  determined_by(op8, cl17).   % homomorphism
determined_by(op9, cl9).  determined_by(op9, cl18).   % inverse homomorphism


%% --- CONSTRUCTION ALGORITHMS ---
%% Transforms between equivalent formalisms.
transforms_to(ca1, mt2, mt1).    % subset construction: NFA → DFA
transforms_to(ca2, mt3, mt2).    % ε-closure elimination: ε-NFA → NFA
transforms_to(ca3, regex, mt3).  % Thompson: regex → ε-NFA
transforms_to(ca9, mt2, regex).  % state elimination: NFA → regex
transforms_to(ca12, regex, mt1). % McNaughton-Yamada: regex → DFA

%% Minimization algorithms produce minimal DFA.
produces(ca4, minimal_dfa).   % Brzozowski
produces(ca5, minimal_dfa).   % Hopcroft
produces(ca6, minimal_dfa).   % Moore's minimization
produces(ca10, minimal_dfa).  % Myhill-Nerode construction

%% Product construction for intersection/union.
requires(ca7, mt1).   % product construction requires two DFAs
requires(ca8, mt1).   % complement construction requires complete DFA

%% PDA × DFA intersection.
requires(ca11, mt6).  % PDA intersection requires PDA
requires(ca11, mt1).  % PDA intersection requires DFA


%% --- MINIMIZATION SEQUENCE ---
%% Steps follow strict order: each enables the next.
enables(mn1, mn2).   % remove unreachable → complete DFA
enables(mn2, mn3).   % complete → initial partition
enables(mn3, mn4).   % initial partition → refinement
enables(mn4, mn5).   % refinement → iterate until stable
enables(mn5, mn6).   % stable → construct minimal DFA
enables(mn6, mn7).   % construct → verify

%% Minimization is a pipeline = movement.FU13 (pipeline concept).
instance_of(dfa_minimization, pipeline).


%% --- PUMPING LEMMAS ---
%% Constrain what languages can belong to each class.
constrains(pl1, hi1).  % pumping lemma constrains regular
constrains(pl2, hi2).  % pumping lemma constrains context-free


%% --- KEY THEOREMS ---
%% What each theorem establishes.
founded(th1, eq3).     % Kleene's theorem establishes DFA ≡ regex
founded(th2, eq7).     % Myhill-Nerode establishes minimal DFA uniqueness
founded(th2, ca10).    % Myhill-Nerode establishes construction
implements(th3, pl1).  % pumping lemma theorem implements PL1
founded(th4, eq7).     % minimization uniqueness
constrains(th5, ca1).  % exponential blowup constrains subset construction
founded(th6, cl1).     % closure theorem establishes all regular closures
enables(th7, dr1).     % decidability enables reachability check
enables(th7, dr2).     % decidability enables dead-state check
enables(th7, dr8).     % decidability enables minimization rule
distinguishes(th8, hi1, hi2).   % aⁿbⁿ distinguishes regular from CF
distinguishes(th10, mt6, mt7).  % wwᴿ distinguishes NPDA from DPDA

%% Equivalence results trace to theorems.
result_of(eq1, th1).   result_of(eq1, ca1).
result_of(eq3, th1).
result_of(eq7, th2).   result_of(eq7, th4).
result_of(eq6, th10).


%% --- EXTENDED MODELS ---
%% Each extends a base machine type with added capability.
extends(xm1, mt4).   extends(xm1, mt5).    % statecharts extend Moore/Mealy
extends(xm2, mt1).   extends(xm2, mt2).    % timed automata extend DFA/NFA
extends(xm3, mt1).                          % probabilistic extends DFA
extends(xm4, mt1).   extends(xm4, mt2).    % weighted extends DFA/NFA
extends(xm5, mt2).                          % Büchi extends NFA (infinite words)
extends(xm6, xm5).                          % Rabin/Streett extend Büchi
extends(xm7, mt1).                          % quantum extends DFA
extends(xm8, mt2).                          % alternating extends NFA
extends(xm9, mt1).                          % register extends DFA
extends(xm10, mt7).                         % visibly pushdown extends DPDA


%% --- REGULAR EXPRESSION → CONSTRUCTION ---
%% Each regex operator has a corresponding FSM construction.
%% Thompson's construction (CA3) builds ε-NFA fragments per operator.
enables(rx1, ca3).   % literal → single transition
enables(rx2, ca3).   % ε → trivial accept
enables(rx3, ca3).   % ∅ → no accept
enables(rx4, ca3).   % concatenation → connect fragments
enables(rx5, ca3).   % union → parallel fragments
enables(rx6, ca3).   % star → loop fragment


%% --- APPLICATIONS → REQUIREMENTS ---
%% What machine type and implementation each application needs.
requires(ap1, mt1).   requires(ap1, ca1).  requires(ap1, ca3). requires(ap1, ip1).
requires(ap2, mt2).   requires(ap2, ip8).  requires(ap2, ip9).
requires(ap3, mt4).   requires(ap3, mt5).  requires(ap3, xm1). requires(ap3, ip3).
requires(ap4, mt4).   requires(ap4, mt5).  requires(ap4, ip6).
requires(ap5, xm1).   requires(ap5, ip4).
requires(ap6, xm1).   requires(ap6, ip10).
requires(ap7, xm2).   requires(ap7, xm5).
requires(ap8, xm3).
requires(ap9, xm4).   requires(ap9, mt10).
requires(ap10, mt4).  requires(ap10, mt5). requires(ap10, xm1). requires(ap10, ip6).
requires(ap11, xm1).
requires(ap12, mt4).  requires(ap12, mt5). requires(ap12, ip6).
requires(ap13, mt1).  requires(ap13, ip1).
requires(ap14, xm5).  requires(ap14, xm2).
requires(ap15, mt1).  requires(ap15, ip1). requires(ap15, ip7).
requires(ap16, mt4).  requires(ap16, ip6).
requires(ap17, mt5).  requires(ap17, ip3).
requires(ap18, mt4).  requires(ap18, ip6). requires(ap18, xm2).
requires(ap20, ip8).
mitigated_by(ap20, ip9).  % ReDoS mitigated by Thompson NFA


%% --- DESIGN RULES → FAILURE MODE PREVENTION ---
prevents(dr1, fm4).    % reachability check prevents unreachable states
prevents(dr3, fm6).    % total transition prevents missing transitions
prevents(dr4, fm1).    % hierarchy prevents state explosion
prevents(dr5, fm6).    % handle all events prevents missing transitions
prevents(dr7, fm5).    % mutual exclusion prevents unintentional nondeterminism
prevents(dr9, fm1).    % orthogonal decomposition prevents state explosion
prevents(dr14, fm1).   % separate data from control prevents state explosion
prevents(dr15, fm2).   % deadlock freedom prevents deadlock


%% --- IMPLEMENTATION PATTERN SELECTION ---
%% Domain-specific: given requirements, select pattern. L3.

select_implementation(ip1, Requirements) :-
    member(compile_time_known, Requirements),
    member(max_speed, Requirements).
%% Transition table: fixed size, fastest lookup.

select_implementation(ip2, Requirements) :-
    member(dynamic_states, Requirements).
%% Hash map: when states/symbols change at runtime.

select_implementation(ip3, Requirements) :-
    member(small_fsm, Requirements),
    member(varying_behavior, Requirements).
%% Switch-case: hand-written, few states, complex per-state logic.

select_implementation(ip4, Requirements) :-
    member(complex_state_behavior, Requirements),
    member(extensible, Requirements).
%% State pattern (OOP): open-closed, complex behavior per state.

select_implementation(ip6, Requirements) :-
    member(hardware, Requirements).
%% State register + ROM: FPGA/ASIC synthesis.

select_implementation(ip7, Requirements) :-
    member(data_driven, Requirements),
    member(configurable, Requirements).
%% Interpreter loop: FSM from config/data, generic engine.

select_implementation(ip9, Requirements) :-
    member(regex_matching, Requirements),
    member(guaranteed_linear, Requirements).
%% Thompson NFA: O(nm) guaranteed, no backtracking.

select_implementation(ip10, Requirements) :-
    member(hierarchical, Requirements),
    member(concurrent_regions, Requirements).
%% Statechart runtime: hierarchy, concurrency, history.


%% --- MACHINE TYPE SELECTION ---
%% Given problem, select machine type. L3.

select_machine(mt1, Problem) :-
    instance_of(Problem, hi1),         % regular language
    requires(Problem, deterministic).  % need deterministic
%% DFA: regular, deterministic, O(n) recognition.

select_machine(mt2, Problem) :-
    instance_of(Problem, hi1),
    requires(Problem, compact_representation).
%% NFA: regular, potentially fewer states.

select_machine(mt4, Problem) :-
    requires(Problem, output),
    requires(Problem, output_per_state).
%% Moore: output determined by state alone.

select_machine(mt5, Problem) :-
    requires(Problem, output),
    requires(Problem, immediate_output).
%% Mealy: output responds to input immediately.

select_machine(mt6, Problem) :-
    instance_of(Problem, hi2),
    \+ instance_of(Problem, hi1).      % CF but not regular
%% PDA: context-free language needing stack.

select_machine(xm1, Problem) :-
    requires(Problem, hierarchy),
    requires(Problem, concurrency).
%% Statechart: complex systems with nested/parallel states.

select_machine(xm2, Problem) :-
    requires(Problem, timing_constraints).
%% Timed automaton: real-time verification.


%% --- CROSS-DOMAIN BRIDGES ---

%% FSM × Math Logic.
%% DFA acceptance = logical satisfaction (FO10).
%% M ⊨ w iff DFA ends in accept state after reading w.
equivalent_to(fsm_acceptance, logical_satisfaction).

%% Closure under complement = swapping accept/reject = negation (PL2).
equivalent_to(cl4, logical_negation).

%% Closure under intersection = product construction = conjunction (PL3).
equivalent_to(cl5, logical_conjunction).

%% Closure under union = NFA construction = disjunction (PL4).
equivalent_to(cl1, logical_disjunction).

%% Pumping lemma = proof by contradiction (IR10 ¬-intro).
%% Assume L is regular, derive contradiction → L not regular.
implements(pl1, proof_by_contradiction).

%% Decidability of FSM properties (TH7) contrasts with
%% undecidability of TM properties (Rice's theorem, TH11).
%% FSMs are weak enough that everything is decidable.
distinguishes(th7, hi1, hi4).  % FSM decidable, TM not

%% Myhill-Nerode = equivalence relation (RL8) with finite index.
instance_of(myhill_nerode_relation, equivalence_relation).
requires(myhill_nerode_relation, rl2).  % reflexive
requires(myhill_nerode_relation, rl4).  % symmetric
requires(myhill_nerode_relation, rl7).  % transitive


%% FSM × Data Structures.
%% Transition table = ST1 (static array) 2D.
instance_of(ip1, st1).    % transition table is static array
%% Transition map = ST18 (hash table).
instance_of(ip2, st18).   % transition map is hash table
%% NFA simulation tracks set of active states.
requires(ip9, set_data_structure).
%% Subset construction produces ST4-like powerset enumeration.
requires(ca1, powerset_enumeration).

%% Trie (ST31) is an FSM: edges are characters, paths are strings.
equivalent_to(st31, mt1).  % trie is DFA over string keys

%% Suffix tree (ST34) is built from FSM constructions.
derived_from(st34, mt1).

%% Aho-Corasick (AL62) builds DFA from trie + failure links.
requires(al62, mt1).
requires(al62, st31).


%% FSM × Algorithms.
%% Lexer (AP1) uses Thompson (CA3) → subset construction (CA1).
%% This is the algorithms.AL62 pipeline.
enables(ca3, ca1).        % Thompson feeds subset construction
enables(ca1, ap1).        % subset construction feeds lexer

%% Hopcroft minimization (CA5) is O(n log n) = CX4 complexity.
instance_of(ca5, cx4).    % Hopcroft is linearithmic

%% BFS (AL23) used in minimization step MN1 (reachability).
requires(mn1, al23).      % reachability check uses BFS

%% Topological sort on computation DAG.
instance_of(fsm_computation, dag_traversal).


%% FSM × Connections.
%% FSM IS a directed graph. States = nodes. Transitions = edges.
instance_of(mt1, directed_graph).
instance_of(mt2, directed_graph).
specializes(cm1, node_set).        % state set specializes node set
specializes(fo7, edge).            % transition specializes edge

%% Topology: DFA is typically sparse graph (each state has |Σ| edges).
instance_of(mt1_topology, sparse_graph).

%% Protocol state machines (AP3) are connection protocols (PR6-PR8).
instance_of(ap3, protocol_state_machine).
%% TCP states map to connections.PR5 (transport protocol).
requires(tcp_fsm, transport_protocol).

%% Network topology itself is a graph; FSMs control traversal.
enables(mt1, routing_control).     % DFA can control packet routing


%% FSM × Movement.
%% FSM states ARE movement.SA states.
%% FSM transitions ARE movement.TR transitions.
equivalent_to(fo6, movement_state).      % FSM state ≡ movement state
equivalent_to(fo7, movement_transition). % FSM transition ≡ movement transition

%% Accept = arrived (SA3). Reject = SA8 (dissolved/dead end).
equivalent_to(fo9, sa3).   % accept state ≡ arrived
equivalent_to(fo11, sa8).  % dead/trap state ≡ dissolved (no recovery)

%% Start state = origin (CO13). Accept state = destination (CO14).
equivalent_to(fo8, movement_origin).
equivalent_to(fo9, movement_destination).

%% Computation = path through state space.
equivalent_to(fo12, movement_path).

%% Dead state = absorbing constraint (movement.CN5 barrier variant).
instance_of(fo11, absorbing_barrier).

%% Nondeterminism = bifurcation (movement.TR10).
%% NFA branching = movement bifurcation (multiple possible paths).
equivalent_to(nfa_branching, tr10).

%% Minimization = convergence (movement.TR11).
%% Merging equivalent states = converging to fewer states.
instance_of(dfa_minimization_step, tr11).

%% State explosion = movement.FM (failure from exponential growth).
instance_of(fm1, exponential_growth_failure).


%% FSM × English Grammar.
%% English grammar IS a formal grammar. Chomsky hierarchy applies.
%% Regular grammar (HI1) = right-linear grammar = grammar.WC rules subset.
%% Context-free grammar (HI2) = grammar for most natural language syntax.
%% The grammar compact's rules (R1-R24) are constraint rules on a CF grammar.
instance_of(english_grammar, hi2).  % English is (approximately) context-free
%% Regular expressions match word-level patterns in vocabulary.
enables(hi1, lexical_pattern_matching).

%% Lexer (AP1) tokenizes text using DFA from regex.
%% This connects directly to vocabulary token classification.
enables(ap1, token_classification).


%% FSM × VDR-Prolog System.

%% Session lifecycle IS an FSM.
%% States: created, active, suspended, ejected, killed.
instance_of(vdr_session_lifecycle, mt4).  % Moore machine (output per state)
evolves_to(session_created, session_active).
evolves_to(session_active, session_suspended).
evolves_to(session_suspended, session_active).    % resume
evolves_to(session_active, session_ejected).      % LRU eviction
evolves_to(session_ejected, session_active).      % restore from snapshot
evolves_to(session_active, session_killed).       % explicit kill
instance_of(session_killed, dead_state).          % no recovery

%% HTTP request lifecycle IS an FSM.
instance_of(vdr_http_lifecycle, mt5).  % Mealy (output per transition)
evolves_to(http_received, http_parsed).
evolves_to(http_parsed, http_queued).
evolves_to(http_queued, http_processing).
evolves_to(http_processing, http_responded).
evolves_to(http_parsed, http_error_400).       % malformed
evolves_to(http_queued, http_error_503).        % queue full

%% Inference cycle IS an FSM.
instance_of(vdr_inference_cycle, mt4).  % Moore (output per state)
evolves_to(phase_input, phase_read).
evolves_to(phase_read, phase_resolve_weights).
evolves_to(phase_resolve_weights, phase_forward).
evolves_to(phase_forward, phase_generate).
evolves_to(phase_generate, phase_postprocess).
evolves_to(phase_postprocess, phase_snapshot_check).
evolves_to(phase_snapshot_check, phase_input).  % cycle

%% L1/L2/L3 execution level selection IS an FSM.
instance_of(vdr_level_selection, mt1).  % DFA on query classification
evolves_to(query_received, classify_l3).
evolves_to(classify_l3, execute_l3).           % typed relation hit
evolves_to(classify_l3, classify_l2).          % no L3 coverage
evolves_to(classify_l2, execute_l2).           % prolog rule hit
evolves_to(classify_l2, execute_l1).           % no L2 coverage
%% execute_l3, execute_l2, execute_l1 are terminal per query.

%% KB state lifecycle IS an FSM.
instance_of(vdr_kb_lifecycle, mt4).
evolves_to(kb_unloaded, kb_loading).        % lazy load triggered
evolves_to(kb_loading, kb_loaded).          % load complete
evolves_to(kb_loaded, kb_frozen).           % freeze after init
evolves_to(kb_loaded, kb_training).         % training lock acquired
evolves_to(kb_training, kb_loaded).         % training complete, lock released
evolves_to(kb_loaded, kb_saving).           % persistence
evolves_to(kb_saving, kb_loaded).           % save complete

%% Design rules apply to all VDR FSMs.
validates(dr1, vdr_session_lifecycle).   % all states reachable
validates(dr3, vdr_http_lifecycle).      % total transition function
validates(dr11, vdr_http_lifecycle).     % explicit error states
validates(dr15, vdr_inference_cycle).    % deadlock freedom (cycle always returns)
