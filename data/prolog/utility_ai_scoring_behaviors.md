%% ============================================================
%% UTILITY AI — BEHAVIOR SCORING AND SELECTION — DOMAIN PROLOG
%% Connects to core, math, logic, FSM, data structures,
%% algorithms, movement, physics, connections, philosophy.
%% Facts from utility_ai.compact
%% ============================================================


%% --- FOUNDATION DEPENDENCIES ---
requires(fd2, fd5).   % consideration requires response curve
requires(fd2, fd6).   % consideration requires input axis
requires(fd2, fd7).   % consideration requires normalization
requires(fd3, fd2).   % behavior requires considerations
requires(fd4, fd3).   % reasoner requires behaviors
requires(fd4, fd10).  % reasoner requires action selection
solves(fd9, fd14).    % compensation solves weight-score interaction problem
derived_from(fd11, fd2). derived_from(fd11, fd3). % score derives from consideration + behavior
implements(fd13, rs6).  % dual utility implements parallel reasoners
constrains(fd14, ws1). constrains(fd14, comp_cp1). % weight-score interaction constrains weights + multiplication


%% --- SCORING CURVE TAXONOMY ---
generalizes(sc4, sc1).    % polynomial generalizes linear (n=1 case)
specializes(sc2, sc4).    % quadratic ease-in specializes polynomial (n=2)
specializes(sc3, sc4).    % quadratic ease-out specializes polynomial
generalizes(sc17, sc1).   % piecewise linear generalizes linear (single segment case)
specializes(sc11, sc5).   % step specializes sigmoid (k→∞)
specializes(sc20, sc8).   % bounded exponential specializes decay
opposes(sc9, sc10).       % bell opposes inverse bell
opposes(sc21, sc9).       % parabolic trough opposes bell

%% Curve → parameter dependencies.
requires(sc1, cp1).                 % linear requires slope
requires(sc4, cp2).                 % polynomial requires exponent
requires(sc5, cp3). requires(sc5, cp4). % sigmoid requires steepness + midpoint
requires(sc7, cp3).                 % exponential growth requires rate
requires(sc8, cp8).                 % exponential decay requires decay rate
requires(sc9, cp5). requires(sc9, cp6). % Gaussian requires center + width
requires(sc10, cp5). requires(sc10, cp6). % inverse bell requires center + width
requires(sc17, cp7).                % piecewise requires breakpoints


%% --- NORMALIZATION → CONSIDERATION ENABLEMENT ---
enables(nm1, cn1). enables(nm1, cn2). enables(nm1, cn5). enables(nm1, cn6).
enables(nm2, cn3). enables(nm2, cn4).
enables(nm3, cn3). enables(nm3, cn14).
enables(nm5, cn4).
constrains(nm7, nm1). constrains(nm7, nm2). constrains(nm7, nm3).
constrains(nm7, nm4). constrains(nm7, nm5). constrains(nm7, nm6).
%% Clamp constrains all normalizations (safety net).


%% --- CONSIDERATION → CURVE PAIRINGS ---
%% Which curves each consideration typically uses.
requires(cn1, sc2).   requires(cn1, sc1).    % health urgency: ease-in or linear
requires(cn2, sc3).   requires(cn2, sc6).    % ammo: ease-out or log
requires(cn3, sc5).   requires(cn3, sc9).    % distance: sigmoid or Gaussian
requires(cn4, sc7).   requires(cn4, sc5).    % threat: exponential or sigmoid
requires(cn5, sc1).   requires(cn5, sc20).   % cooldown: linear or bounded exponential
requires(cn6, sc11).  requires(cn6, sc12).   % visibility: step or smoothstep
requires(cn7, sc1).                          % group need: linear
requires(cn8, sc6).                          % resource value: log
requires(cn9, sc5).                          % path safety: inverted sigmoid
requires(cn11, sc2).                         % boredom: ease-in
requires(cn12, sc11). requires(cn12, sc5).   % opportunity: step or sharp sigmoid


%% --- REASONER → SELECTION METHOD ---
requires(rs1, bs1).              % single-bucket uses argmax
requires(rs2, bs8). requires(rs2, bs1). % dual-bucket uses threshold then argmax
requires(rs3, bs3).              % weighted random uses top-N
requires(rs4, bs8). requires(rs4, bs1). % categorical uses threshold then argmax
requires(rs5, bs1). requires(rs5, bs6). % hierarchical uses argmax + priority interrupt
requires(rs6, bs1).              % parallel uses independent argmax


%% --- COMPENSATION CHAIN (DAVE MARK) ---
%% The core insight chain.
motivates(dm1, dm3).   % multiplication problem motivates compensation insight
motivates(dm2, dm3).   % why-not-add motivates compensation insight
enables(dm3, dm4).     % insight enables modification factor
enables(dm4, dm5).     % modification factor enables make-up value
enables(dm5, dm6).     % make-up value enables compensated score
enables(dm6, dm7).     % compensated score enables final product
constrains(dm8, dm7).  % zero-score effect constrains final product
validates(dm9, dm6).   % perfect-score effect validates compensated score formula
derived_from(dm10, dm4). % consideration count effect derives from modification factor
constrains(dm12, dm6).  % veto considerations constrain compensation

%% Compensation methods hierarchy.
precedes(cm1, cm4).       % pure multiplication precedes compensated
implements(cm4, dm3).     % CM4 implements Dave Mark compensation insight
implements(cm4, dm4). implements(cm4, dm5). implements(cm4, dm6). implements(cm4, dm7).
extends(cm6, cm1).        % epsilon floor extends pure multiplication
generalizes(cm7, cm1). generalizes(cm7, cm2). generalizes(cm7, cm5).
%% Power mean generalizes product, sum, and geometric mean.
implements(cm9, dm1). implements(cm9, dm2). implements(cm9, dm3).
implements(cm9, dm4). implements(cm9, dm5). implements(cm9, dm6).
implements(cm9, dm7). implements(cm9, dm8). implements(cm9, dm9).
implements(cm9, dm10). implements(cm9, dm11). implements(cm9, dm12).
%% CM9 is the full Dave Mark pipeline.


%% --- COMPOSITION METHODS ---
requires(comp_cp1, cm1).       % pure multiplication requires no-compensation
implements(comp_cp2, cm2).     % pure addition implements additive mean
implements(comp_cp3, cm3).     % weighted sum implements weighted sum compensation
implements(comp_cp4, cm4).     % compensated multiplication implements Dave Mark
specializes(comp_cp5, cm7).    % min specializes power mean (p→-∞)
opposes(comp_cp6, comp_cp5).   % max opposes min
extends(comp_cp7, comp_cp1).   % weighted product extends pure multiplication


%% --- TUNING RULES → FAILURE MODE PREVENTION ---
prevents(tr1, fm5).    % normalize inputs prevents NaN
prevents(tr2, fm11).   % visual curve review prevents dead zones
prevents(tr4, fm6).    % fix curves not weights prevents tuning spiral
prevents(tr5, fm1).    % consideration count limit prevents score collapse
prevents(tr5, fm12).   % also prevents over-correction
prevents(tr8, fm5).    % adversarial testing prevents NaN
prevents(tr10, fm1).   % no-true-zero prevents score collapse
prevents(tr11, fm1).   % separate gates prevents inappropriate collapse
prevents(tr14, fm3).   % score idle prevents dominant behavior
implements(tr9, cm4).  % use Dave Mark as default implements CM4
enables(tr6, fm3). enables(tr6, fm4). % logging enables detecting dominant + dead behaviors
constrains(tr12, cm4). % re-evaluate on new consideration constrains compensation


%% --- FAILURE MODE → RESOLUTION ---
mitigated_by(fm1, cm4). mitigated_by(fm1, cm6). mitigated_by(fm1, tr5).
mitigated_by(fm2, bs5). mitigated_by(fm2, bs7).
mitigated_by(fm3, tr4). mitigated_by(fm3, tr2).
mitigated_by(fm4, tr6). mitigated_by(fm4, tr2).
mitigated_by(fm5, tr8). mitigated_by(fm5, nm7).
mitigated_by(fm6, tr4).
mitigated_by(fm10, ws3).
mitigated_by(fm12, tr5).


%% --- APPLICATION → REASONER TYPE ---
requires(ap1, rs2). requires(ap1, rs4).   % combat AI: dual-bucket or categorical
requires(ap2, rs6).                        % squad AI: parallel reasoners
requires(ap3, rs1). requires(ap3, rs3).    % NPC routines: simple or weighted random
requires(ap4, rs4).                        % strategy: categorical
requires(ap5, rs4). requires(ap5, rs5).    % autonomous vehicles: categorical + hierarchical
requires(ap6, rs3).                        % dialogue: weighted random
requires(ap7, rs1).                        % creature: simple highest
requires(ap8, rs1).                        % tower defense: per-tower simple
requires(ap9, rs5).                        % boss AI: hierarchical
requires(ap10, rs1).                       % economic: simple highest


%% --- CROSS-DOMAIN BRIDGES ---

%% Utility AI × Math Foundations.
%% Response curves ARE mathematical functions (math.CO6).
instance_of(fd5, math_co6).    % response curve is a function f:[0,1]→[0,1]
%% Scoring IS a function composition chain: normalize → curve → compensate → combine.
instance_of(utility_pipeline, math_fn5).  % utility pipeline is function composition

%% Specific curves map to mathematical functions.
instance_of(sc5, logistic_function).     % sigmoid is logistic function
instance_of(sc9, gaussian_function).     % bell is Gaussian
instance_of(sc4, polynomial_function).   % polynomial power is polynomial
instance_of(sc6, logarithmic_function).  % log curve is logarithm
instance_of(sc7, exponential_function).  % exponential growth is exponential

%% Normalization IS a function (math.CO6) mapping domain to [0,1].
instance_of(fd7, math_co6).

%% Power mean (CM7) IS a parameterized mathematical structure.
%% p=-∞ → min, p=-1 → harmonic, p=0 → geometric, p=1 → arithmetic, p=∞ → max.
%% This IS a total order (math.CO20) on aggregation methods.
instance_of(cm7, math_co20).  % power mean parameter orders aggregation methods

%% Compensation factor (1-1/n) approaches 1 as n→∞.
%% This IS a limit (math.CO26).
instance_of(dm4_limit, math_co26).  % modification factor has limit behavior


%% Utility AI × Math Logic.
%% Considerations ARE logical predicates evaluated on world state.
instance_of(fd2, logical_predicate).  % consideration is predicate over context
%% A behavior's consideration set IS a conjunction (logic.PL3).
%% Multiplicative combination: all must be high = logical AND.
equivalent_to(comp_cp1, logical_conjunction).  % multiplication ≡ AND
%% Additive combination: any one high suffices = logical OR.
equivalent_to(comp_cp2, logical_disjunction).  % addition ≡ OR
%% Step curve (SC11) IS a logical predicate: true/false.
equivalent_to(sc11, logical_predicate_binary).
%% Threshold gate (BS8) IS logical implication: if score > threshold then eligible.
instance_of(bs8, logical_conditional).

%% Dave Mark compensation softens AND toward weighted AND.
%% Pure AND (multiplication) → compensated AND → weighted OR (addition).
%% Compensation IS a point on the spectrum between AND and OR.
connects_to(comp_cp1, comp_cp4). connects_to(comp_cp4, comp_cp2).
%% AND ←compensation→ OR


%% Utility AI × Physics.
%% Response curves use the same mathematical functions as physics laws.
%% Exponential decay (SC8) ≡ radioactive decay law (physics.L46): N(t) = N₀e^(-λt).
equivalent_to(sc8, physics_l46_shape).
%% Sigmoid (SC5) ≡ Fermi-Dirac distribution (physics.L44) shape.
equivalent_to(sc5, physics_l44_shape).
%% Gaussian (SC9) ≡ Boltzmann distribution shape.
parallel_to(sc9, physics_boltzmann_shape).
%% Boltzmann selection (BS4) IS Boltzmann distribution from statistical mechanics.
equivalent_to(bs4, physics_l43).  % softmax ≡ partition function selection

%% Temperature parameter in Boltzmann selection ≡ physics temperature.
%% T→0: system freezes to ground state (greedy). T→∞: all states equally likely (random).
equivalent_to(bs4_temperature, physics_k5_temperature).


%% Utility AI × Movement.
%% Behavior selection IS a state transition decision.
%% Current behavior = current state (movement.SA). Selected behavior = next state.
instance_of(fd10, movement_tr_general).  % action selection is a transition

%% Oscillation (FM2) IS movement.SM4 (oscillation about equilibrium).
equivalent_to(fm2, movement_sm4).
%% Hysteresis (BS5) IS movement.CN4 (inertia as constraint on transition).
equivalent_to(bs5, movement_cn4).  % hysteresis ≡ inertia resisting change
%% Commitment (BS7) IS movement.SA9 (suspended: cannot transition for duration).
equivalent_to(bs7, movement_sa9).

%% Considerations read world state = movement.CO5 (state snapshot).
equivalent_to(fd12, movement_co5).

%% Boredom (CN11) IS movement.TR8 (gradual change) over time.
instance_of(cn11, movement_tr8).


%% Utility AI × FSM.
%% Utility AI IS an alternative to FSM for behavior control.
%% FSM: explicit states + transitions. Utility: implicit states via scoring.
alternative_to(utility_ai_system, fsm_behavior_system).

%% But they compose: categorical reasoner (RS4) ≡ FSM with scoring within states.
%% Priority buckets ARE FSM states. Bucket selection IS state transition.
equivalent_to(rs4, fsm_mt4_variant).  % categorical reasoner ≡ Moore-like FSM

%% Hierarchical reasoner (RS5) ≡ statechart (FSM.XM1).
equivalent_to(rs5, fsm_xm1).  % hierarchical reasoner ≡ statechart

%% Priority interrupt (BS6) ≡ FSM.MT5 Mealy output on event.
equivalent_to(bs6, fsm_mt5).  % priority interrupt ≡ Mealy transition

%% Boss AI (AP9) uses hierarchical = statechart. Cross-reference confirmed.
references(ap9, fsm_xm1).

%% Design rule: score idle behavior (TR14) = FSM.FO11 (dead state awareness).
%% Without idle, system has no rest state.
parallel_to(tr14, fsm_fo11).


%% Utility AI × Data Structures.
%% Behavior set IS a collection scored and sorted.
%% Selection = find max = DS.OP (heap extract_max or linear scan).
requires(bs1, max_finding).   % argmax requires finding maximum
%% For small behavior counts (<20): linear scan O(n) suffices.
%% For large: priority queue (DS.ST11) sorts candidates.
requires(bs3, sorting).       % top-N requires partial sort
%% Boltzmann selection requires exponentiation over all scores.
requires(bs4, exp_computation).

%% Piecewise linear curve (SC17) IS a sorted array of breakpoints.
instance_of(sc17, st1_sorted_array).  % breakpoints = sorted static array
%% Lookup on piecewise = binary search (algorithms.AL16).
requires(sc17_eval, al16).

%% Logging (TR6) requires ring buffer or append-only log.
requires(tr6, st5_circular_buffer).  % logging requires circular buffer


%% Utility AI × Algorithms.
%% Normalization IS preprocessing (algorithms concept).
instance_of(fd7, preprocessing_step).

%% Curve evaluation IS function evaluation = O(1) per consideration.
instance_of(curve_eval, cx1).  % constant time per evaluation

%% Full reasoner pass = O(behaviors × considerations) = O(n×m).
instance_of(reasoner_pass, cx5_variant).  % quadratic in total evaluations

%% Weighted random (BS3) IS algorithms.AL80 (reservoir sampling variant).
parallel_to(bs3, algo_al80).

%% Softmax/Boltzmann (BS4) uses exp + sum = O(n).
instance_of(bs4_computation, cx3).  % linear in behavior count


%% Utility AI × Connections.
%% Considerations ARE connections between world state and decision.
%% Input axis = connection channel (connections.CH*).
%% Response curve = connection impedance transform (connections.CO9).
instance_of(fd6, connection_channel).
instance_of(fd5, impedance_transform).

%% Score IS a signal (connections.IN7) flowing through the evaluation pipeline.
instance_of(fd11, signal).

%% Reasoner IS a hub node (connections.NE1 star topology).
%% All behaviors connect to reasoner; reasoner selects one.
instance_of(fd4, hub_node).

%% Dual utility (FD13) = parallel channels (connections.CO12 multiplexing).
equivalent_to(fd13, connections_co12).


%% Utility AI × Databases.
%% Context (FD12) IS a queryable data snapshot = database view (db.CO21).
equivalent_to(fd12, db_co21).  % context ≡ database view

%% Stale context (FM8) IS stale cache = database staleness problem.
equivalent_to(fm8, db_stale_cache).

%% Logging decision chain (TR6) IS audit log (db audit concept).
instance_of(tr6_log, db_audit_log).


%% Utility AI × Philosophy.
%% Utility theory originates from philosophy (Bentham, Mill utilitarianism).
%% Utility = quantified desirability ≡ philosophical concept of the Good.
derived_from(fd1, utilitarian_ethics).

%% Eudaimonia (philosophy.CO30) = maximizing utility over complete life.
%% Utility AI maximizes per-decision. Philosophy asks about the whole.
parallel_to(fd1, philosophy_co30).

%% Practical wisdom (philosophy.CO32 phronesis) = the reasoner's judgment.
%% Reasoner selects best action given situation = phronesis applied.
parallel_to(fd4, philosophy_co32).

%% Doctrine of the mean (philosophy.CO33) = Gaussian curve (SC9).
%% Virtue as intermediate = peak at center, falling off at extremes.
equivalent_to(sc9, philosophy_co33).  % Gaussian curve ≡ doctrine of the mean

%% Stoic apatheia (philosophy.CO35) = high threshold gate on emotional considerations.
%% Freedom from passions = emotional considerations gated out of decision.
parallel_to(fsm_emotion_gate, philosophy_co35).


%% --- UTILITY AI SELECTION RULES ---
%% Domain-specific: given requirements, select scoring approach. L3.

select_composition(comp_cp4, Requirements) :-
    member(robust_scoring, Requirements),
    member(multiple_considerations, Requirements).
%% Dave Mark compensated multiplication: default for robust multi-consideration.

select_composition(comp_cp1, Requirements) :-
    member(all_prerequisite, Requirements),
    \+ member(soft_preference, Requirements).
%% Pure multiplication: when every consideration is a hard requirement.

select_composition(comp_cp2, Requirements) :-
    member(compensatory, Requirements).
%% Addition: when one strong axis compensates for weak others.

select_composition(comp_cp5, Requirements) :-
    member(bottleneck_limited, Requirements).
%% Min: when worst consideration IS the score.

select_curve(sc5, Input) :-
    has_property(Input, threshold_transition).
%% Sigmoid: for sharp transition zones.

select_curve(sc9, Input) :-
    has_property(Input, preferred_value).
%% Gaussian: for optimal range preferences.

select_curve(sc6, Input) :-
    has_property(Input, diminishing_returns).
%% Log: for resources with decreasing marginal value.

select_curve(sc11, Input) :-
    has_property(Input, binary_prerequisite).
%% Step: for hard gates.

select_curve(sc4, Input) :-
    has_property(Input, adjustable_sensitivity),
    \+ has_property(Input, threshold_transition).
%% Polynomial: general purpose with tunable exponent.


%% --- VDR-PROLOG SYSTEM BRIDGES ---

%% VDR-Prolog L1/L2/L3 selection IS utility-like scoring.
%% L3 query → score: coverage completeness (does index cover query?).
%% L2 query → score: rule match depth (how many rules fire?).
%% L1 query → score: novelty (how unfamiliar is the query?).
%% The system selects execution level by scoring coverage.
parallel_to(vdr_level_selection, utility_ai_system).

%% VDR-Prolog confidence table IS a scoring curve.
%% Source type → confidence score in [0, 65536].
%% This is a step function (SC11 variant) with 11 discrete levels.
instance_of(vdr_confidence, sc11_discrete_variant).

%% VDR-Prolog session LRU IS utility scoring for eviction.
%% LRU = consideration based on last access time (CN5 time-based).
%% Eviction = selecting behavior "evict" when score exceeds threshold.
instance_of(vdr_lru_eviction, utility_selection).
requires(vdr_lru_eviction, cn5).  % time since last access

%% VDR-Prolog ingestion confidence assignment IS a scoring pipeline.
%% Source document confidence × compaction stage confidence → combined.
%% min(source, compaction) = composition method CP5 (min/bottleneck).
implements(vdr_ingestion_confidence, comp_cp5).

%% Q16 exact arithmetic prevents FM5 (NaN/infinity).
%% No float = no NaN. No division by zero without explicit check.
%% VDR-Prolog's integer arithmetic structurally prevents the most
%% dangerous utility AI failure mode.
prevents(vdr_q16, fm5).

%% Dave Mark's compensation formula can be computed exactly in Q16.
%% modification_factor = (1 - 1/n): integer division captures remainder.
%% make_up_value = (1 - score) × mf: Q16 multiplication with remainder.
%% No precision loss in the compensation pipeline.
enables(vdr_q16, exact_compensation).
