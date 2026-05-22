%% ============================================================
%% VDR-PROLOG CORE RULES — ENGLISH + CONNECTIONS + MOVEMENT + LOGIC
%% All rules domain-agnostic unless marked. Facts populate per-domain.
%% Every rule fires at L3 (zero tokens) unless noted.
%% ============================================================

%% --- TAXONOMY (specializes/generalizes) ---
%% Transitive inheritance. If X is a kind of Y, and Y is a kind of Z,
%% then X is a kind of Z. Inverse: generalizes.
specializes(X, Z) :- specializes(X, Y), specializes(Y, Z).
generalizes(Y, X) :- specializes(X, Y).

%% Specialization inherits all constraints from parent.
requires(X, T) :- specializes(X, Y), requires(Y, T).
prevents(X, T) :- specializes(X, Y), prevents(Y, T).
contains(X, T) :- specializes(X, Y), contains(Y, T).

%% --- CONTAINMENT (contains/part_of) ---
%% Transitive composition. If X contains Y and Y contains Z,
%% then Z is accessible within X. Inverse: part_of.
contains(X, Z) :- contains(X, Y), contains(Y, Z).
part_of(Y, X) :- contains(X, Y).
part_of(X, Z) :- part_of(X, Y), part_of(Y, Z).

%% --- ENABLEMENT (enables/depends_on) ---
%% Transitive causal possibility. If X enables Y and Y enables Z,
%% then X transitively enables Z. Inverse: depends_on.
enables(X, Z) :- enables(X, Y), enables(Y, Z).
depends_on(Y, X) :- enables(X, Y).

%% If X enables Y, removing X invalidates Y.
invalid_without(Y, X) :- enables(X, Y).

%% --- REQUIREMENT (requires) ---
%% Transitive hard precondition. Non-negotiable.
requires(X, Z) :- requires(X, Y), requires(Y, Z).

%% --- PREVENTION (prevents) ---
%% Symmetric mutual exclusion. Non-transitive.
prevents(Y, X) :- prevents(X, Y).

%% --- OPPOSITION (opposes) ---
%% Symmetric. Non-transitive. Antithetical pairs.
opposes(Y, X) :- opposes(X, Y).

%% --- DETERMINATION (determined_by) ---
%% Controller-target. Y governs the form of X.
controlled_by(X, Y) :- determined_by(X, Y).

%% --- VALIDATION (validates/verified_by) ---
%% Mechanism confirms rule. Inverse pair.
verified_by(Y, X) :- validates(X, Y).
validates(Y, X) :- verified_by(X, Y).

%% Validation chain: controller → mechanism → rule.
%% Subject determines agreement, agreement validates rule.
validation_chain(Controller, Mechanism, Rule) :-
    determined_by(Mechanism, Controller),
    validates(Mechanism, Rule).

%% --- INSTANCE BINDING (instance_of) ---
%% Token inherits all constraints from type.
requires(Instance, T) :- instance_of(Instance, Type), requires(Type, T).
contains(Instance, T) :- instance_of(Instance, Type), contains(Type, T).
prevents(Instance, T) :- instance_of(Instance, Type), prevents(Type, T).

%% --- EQUIVALENCE (equivalent_to) ---
%% Symmetric. Substitutable in either direction.
equivalent_to(Y, X) :- equivalent_to(X, Y).
substitute(X, Y) :- equivalent_to(X, Y).

%% --- COMPOSITION (composed_of/decomposes_to) ---
%% X is built from parts Y. Inverse: decomposes_to.
decomposes_to(X, Y) :- composed_of(X, Y).
composed_of(Y, X) :- decomposes_to(X, Y).

%% --- DERIVATION (derived_from) ---
%% Historical/causal origin. Transitive.
derived_from(X, Z) :- derived_from(X, Y), derived_from(Y, Z).

%% --- EXTENSION (extends) ---
%% Augmentation. Transitive. X adds to Y without replacing.
extends(X, Z) :- extends(X, Y), extends(Y, Z).

%% Extended thing inherits base constraints.
requires(X, T) :- extends(X, Y), requires(Y, T).

%% --- SEQUENCE (follows/precedes) ---
%% Transitive temporal ordering.
follows(X, Z) :- follows(X, Y), follows(Y, Z).
precedes(X, Z) :- precedes(X, Y), precedes(Y, Z).
precedes(Y, X) :- follows(X, Y).
follows(Y, X) :- precedes(X, Y).

%% --- TRANSFORMS_TO (state change) ---
%% X becomes Y through defined process. Chains for multi-step.
transforms_to(X, Z) :- transforms_to(X, Y), transforms_to(Y, Z).

%% --- FLOW (flows_to) ---
%% Directed transfer. Transitive for pipe/channel chains.
flows_to(X, Z) :- flows_to(X, Y), flows_to(Y, Z).

%% --- SCOPED_TO ---
%% X valid only within scope Y. Constrains visibility.
visible_in(X, Scope) :- scoped_to(X, Scope).
visible_in(X, OuterScope) :- scoped_to(X, Scope), part_of(Scope, OuterScope).

%% --- CONTRASTS (symmetric, non-transitive) ---
contrasts(Y, X) :- contrasts(X, Y).

%% --- PARALLEL_TO (symmetric, non-transitive) ---
parallel_to(Y, X) :- parallel_to(X, Y).


%% ============================================================
%% CROSS-DOCUMENT: ENGLISH GRAMMAR RULES
%% Grammar facts + phrasing constraints + vocabulary bindings.
%% ============================================================

%% --- TOKEN CLASSIFICATION ---
%% Word resolves to word class via vocabulary → grammar bridge.
word_class(Word, Class) :- instance_of(Word, Class).
word_class(Word, ParentClass) :-
    instance_of(Word, Subclass),
    specializes(Subclass, ParentClass).

%% --- SENTENCE PATTERN VALIDATION ---
%% Pattern is well-formed if all required elements present.
pattern_valid(Pattern, Elements) :-
    requires(Pattern, Required),
    member(Required, Elements).

%% Pattern inherits clause type constraints.
clause_constraint(Pattern, Constraint) :-
    instance_of(Pattern, ClauseType),
    requires(ClauseType, Constraint).

%% --- AGREEMENT CHECKING ---
%% Feature match between controller and target.
agreement_holds(Mechanism, Controller, Target) :-
    determined_by(Mechanism, Controller),
    feature(Controller, Feature, Value),
    feature(Target, Feature, Value).

agreement_fails(Mechanism, Controller, Target, Rule) :-
    determined_by(Mechanism, Controller),
    feature(Controller, Feature, V1),
    feature(Target, Feature, V2),
    V1 \= V2,
    validates(Mechanism, Rule).

%% --- ANTI-PATTERN DETECTION ---
%% Grammar-specific: anti-pattern → violated rule.
grammar_violation(AntiPattern, Rule) :-
    prevents(AntiPattern, Rule).

%% --- MORPHOLOGICAL DECOMPOSITION ---
%% Unknown word → prefix + stem + suffix → derived POS + meaning.
derived_word(Word, StemId, POS, Modification) :-
    affix_decompose(Word, Prefix, Stem, Suffix),
    instance_of(StemId, StemClass),
    transforms_pos(Suffix, StemClass, POS),
    affix_meaning(Prefix, Modification).

%% --- TENSE SELECTION FROM TEMPORAL POSITION ---
%% Mechanical tense mapping. No stylistic choice.
tense_for(present_simple, Entity) :- current_state(Entity, _).
tense_for(past_simple, Entity) :- past_state(Entity, _), \+ current_state(Entity, _).
tense_for(present_perfect, Transition) :- completed(Transition).
tense_for(present_progressive, Transition) :- in_progress(Transition).
tense_for(future_simple, Entity) :- pending_state(Entity, _).


%% ============================================================
%% CROSS-DOCUMENT: PHRASING CONSTRAINTS
%% Construction slot satisfaction, register, speech acts.
%% ============================================================

%% --- SLOT SATISFACTION ---
%% Construction slot filled if filler matches required class
%% and does not match prohibited class.
slot_satisfied(Construction, Slot, Filler) :-
    contains(Construction, SlotConstraint),
    slot_def(SlotConstraint, Slot, RequiredClass, ProhibitedClass),
    semantic_class(Filler, FillerClass),
    member(FillerClass, RequiredClass),
    \+ member(FillerClass, ProhibitedClass).

slot_violated(Construction, Slot, Filler) :-
    contains(Construction, SlotConstraint),
    slot_def(SlotConstraint, Slot, _, ProhibitedClass),
    semantic_class(Filler, FillerClass),
    member(FillerClass, ProhibitedClass).

%% --- CONSTRUCTION RECOGNITION ---
%% If literal parse fails, try construction-level interpretation.
construction_match(Tokens, Construction) :-
    form_match(Tokens, Construction),
    forall(
        contains(Construction, SlotConstraint),
        slot_satisfied(Construction, _, _)
    ).

%% --- REGISTER FILTERING ---
%% Word valid in register if its register range includes target.
valid_register(Word, Register) :-
    register_range(Word, Low, High),
    register_level(Register, Level),
    Level >= Low, Level =< High.

%% --- SPEECH ACT RESOLUTION ---
%% Default: surface form determines act. Override for indirect.
speech_act(Tokens, Act) :-
    surface_form(Tokens, Form),
    literal_act(Form, Act),
    \+ indirect_override(Tokens, _).
speech_act(Tokens, Act) :-
    indirect_override(Tokens, Act).

%% --- COLLOCATION CHECKING ---
%% Light verb + deverbal noun must be a known pair.
collocation_valid(Verb, Noun) :-
    instance_of(Pair, CX11),  % light verb construction
    collocation(Pair, Verb, Noun).

%% --- METAPHOR GROUNDING ---
%% Metaphorical expression valid if source→target mapping exists.
metaphor_valid(Expression, SourceDomain, TargetDomain) :-
    metaphor_frame(Frame, SourceDomain, TargetDomain, _),
    maps_to(Expression, Frame).


%% ============================================================
%% CROSS-DOCUMENT: CONNECTIONS
%% Edge properties, failure prediction, distinction resolution.
%% ============================================================

%% --- CONNECTION PROPERTY INHERITANCE ---
%% Every connection instance inherits base connection properties.
has_property(Instance, Property) :-
    instance_of(Instance, CO1),
    composed_of(CO1, Property).
has_property(Instance, Property) :-
    specializes(Instance, Parent),
    has_property(Parent, Property).

%% --- FAILURE PREDICTION ---
%% If system exhibits cause of failure mode, flag risk.
risk(System, FailureMode) :-
    causes(Cause, FailureMode),
    exhibits(System, Cause).

%% Cascade risk from tight coupling.
cascade_risk(System) :-
    coupling(System, tight),
    risk(System, cascade_failure).

%% --- CHANNEL SELECTION ---
%% Channel valid for signal type if it implements the signal category.
valid_channel(Channel, SignalType) :-
    implements(Channel, SignalType).

%% --- PROTOCOL GOVERNANCE ---
%% Protocol governs channel behavior.
governed_by(Channel, Protocol) :- governs(Protocol, Channel).

%% --- DISTINCTION APPLICATION ---
%% Disambiguation: which category does entity belong to?
disambiguate(Entity, CategoryA, CategoryB, Distinction) :-
    distinguishes(Distinction, CategoryA),
    distinguishes(Distinction, CategoryB),
    instance_of(Entity, CategoryA),
    \+ instance_of(Entity, CategoryB).


%% ============================================================
%% CROSS-DOCUMENT: MOVEMENT & STATE
%% State machines, causality, constraints, navigation.
%% ============================================================

%% --- STATE MACHINE ---
%% Entity in state, transitions possible via evolves_to.
can_transition(Entity, FromState, ToState) :-
    current_state(Entity, FromState),
    evolves_to(FromState, ToState),
    \+ blocked(Entity, ToState).

%% Transition blocked if constraint prevents it.
blocked(Entity, ToState) :-
    requires(Transition, Requirement),
    transforms_to(_, ToState),
    enables(Transition, ToState),
    \+ satisfied(Entity, Requirement).

%% Terminal state: no outgoing transitions.
terminal_state(State) :-
    \+ evolves_to(State, _).

%% --- CAUSALITY CLASSIFICATION ---
%% Necessary: without A, no B. B requires A.
necessary_cause(A, B) :- requires(B, A).

%% Sufficient: A alone guarantees B. A enables B.
sufficient_cause(A, B) :- enables(A, B), \+ requires(B, _additional).

%% Necessary and sufficient: biconditional.
necessary_and_sufficient(A, B) :- equivalent_to(A, B).

%% Causal chain: transitive. A causes B causes C → A causes C.
causal_chain(A, C) :- causes(A, B), causes(B, C).
causal_chain(A, C) :- causes(A, B), causal_chain(B, C).

%% --- CONSTRAINT CHECKING ---
%% Motion constrained if opposing force active.
motion_constrained(Entity, Constraint) :-
    opposes(Constraint, MotionType),
    current_motion(Entity, MotionType).

%% Energy sufficiency for transition.
energy_sufficient(Entity, Transition) :-
    requires(Transition, energy_threshold),
    available_energy(Entity, E),
    threshold(Transition, T),
    E >= T.

%% --- DIRECTION RESOLUTION ---
%% Opposing directions cancel.
net_zero(Dir1, Dir2) :- opposes(Dir1, Dir2).

%% Direction relative to reference frame.
direction_in_frame(Entity, Direction, Frame) :-
    reference_frame(Entity, Frame),
    heading(Entity, Direction).

%% --- PATH ANALYSIS ---
%% Closed path: returns to origin.
closed_path(Path) :- connects_to(Path, Origin), source_of(Origin, Path).

%% Irreversible path: no return.
irreversible(Path) :- instance_of(Path, one_way_path).


%% ============================================================
%% CROSS-DOCUMENT: MATH LOGIC
%% Inference validation, identity application, decidability.
%% ============================================================

%% --- INFERENCE VALIDATION ---
%% Modus ponens: from P and P→Q derive Q.
%% This IS what rule firing does. Made explicit for self-description.
modus_ponens(P, Q) :- holds(P), implies(P, Q).

%% Hypothetical syllogism: (P→Q) ∧ (Q→R) → (P→R).
%% This IS transitive closure. Made explicit.
syllogism(P, R) :- implies(P, Q), implies(Q, R).

%% Contraposition: (P→Q) ≡ (¬Q→¬P).
contrapositive(NotQ, NotP) :- implies(P, Q), negation(P, NotP), negation(Q, NotQ).

%% --- LOGICAL IDENTITY APPLICATION ---
%% De Morgan: ¬(P∧Q) ≡ ¬P∨¬Q. Query rewrite.
demorgan_and(NotPQ, NotP, NotQ) :-
    negation(conjunction(P, Q), NotPQ),
    negation(P, NotP), negation(Q, NotQ).

%% Double negation: ¬¬P ≡ P. Simplification.
simplify(double_neg(P), P).

%% Identity: P∧⊤ ≡ P. Drop trivial conjunct.
simplify(conjunction(P, true), P).

%% Annihilation: P∧⊥ ≡ ⊥. Short-circuit.
simplify(conjunction(_, false), false).

%% --- RELATION PROPERTY CHECKING ---
%% Verify relation properties from RL definitions.
is_equivalence(R) :-
    reflexive(R), symmetric(R), transitive(R).

is_partial_order(R) :-
    reflexive(R), antisymmetric(R), transitive(R).

is_total_order(R) :-
    is_partial_order(R), total(R).

%% --- SOUNDNESS GUARANTEE ---
%% Every L3 result is derived from asserted facts via sound rules.
%% If the system derives it, it follows from the KB.
%% This is MG1 (soundness) applied to the VDR-Prolog engine.
sound_derivation(Conclusion) :-
    derived_from_facts(Conclusion, Facts),
    all_asserted(Facts).

%% --- COMPLETENESS BOUNDARY ---
%% L3 is complete for indexed typed relations.
%% L3 is incomplete for: novel entities, ambiguous queries, judgment.
%% When L3 fails, escalate to L2 (rule selection) or L1 (forward pass).
escalate(Query, l2) :-
    \+ typed_relation_covers(Query),
    prolog_rule_covers(Query).
escalate(Query, l1) :-
    \+ typed_relation_covers(Query),
    \+ prolog_rule_covers(Query).

%% --- DECIDABILITY CLASSIFICATION ---
%% Classify query by decidability to select execution level.
decidable(Query) :- finite_index_scan(Query).       % L3: always terminates
semi_decidable(Query) :- depth_bounded_search(Query). % L2: terminates by bound
undecidable(Query) :- requires_judgment(Query).       % L1: LLM forward pass


%% ============================================================
%% UNIVERSAL QUERY PATTERNS
%% Domain-agnostic queries that work on any ingested KB.
%% ============================================================

%% What is X? → type hierarchy lookup.
what_is(X, Type) :- instance_of(X, Type).
what_is(X, Type) :- specializes(X, Type).

%% What does X need? → requirement chain.
needs(X, Y) :- requires(X, Y).
needs(X, Y) :- requires(X, Z), needs(Z, Y).

%% What enables X? → enablement chain (inverse).
enabled_by(X, Y) :- enables(Y, X).
enabled_by(X, Y) :- enables(Y, Z), enabled_by(X, Z).

%% What contains X? → containment chain (inverse).
contained_in(X, Y) :- contains(Y, X).
contained_in(X, Y) :- contains(Y, Z), contained_in(X, Z).

%% What conflicts with X? → prevention + opposition.
conflicts_with(X, Y) :- prevents(X, Y).
conflicts_with(X, Y) :- opposes(X, Y).
conflicts_with(X, Y) :- prevents(Y, X).

%% What changed to become X? → transformation chain (inverse).
originated_from(X, Y) :- transforms_to(Y, X).
originated_from(X, Y) :- transforms_to(Z, X), originated_from(Z, Y).

%% Full dependency tree for X.
all_dependencies(X, Deps) :-
    findall(D, needs(X, D), Deps).

%% Full enablement tree for X.
all_enablers(X, Enablers) :-
    findall(E, enabled_by(X, E), Enablers).

%% Reachability: can we get from X to Y via any typed relation?
reachable(X, Y) :- enables(X, Y).
reachable(X, Y) :- requires(X, Y).
reachable(X, Y) :- contains(X, Y).
reachable(X, Y) :- specializes(X, Y).
reachable(X, Y) :- follows(X, Y).
reachable(X, Y) :- transforms_to(X, Y).
reachable(X, Y) :- flows_to(X, Y).
reachable(X, Y) :- composed_of(X, Y).
reachable(X, Y) :- reachable(X, Z), reachable(Z, Y).

%% Path between two entities: collect intermediate nodes.
path(X, Y, [X, Y]) :- reachable(X, Y).
path(X, Y, [X | Rest]) :- reachable(X, Z), Z \= Y, path(Z, Y, Rest).


%% ============================================================
%% OUTPUT CONSTRUCTION
%% Mechanical sentence generation from KB data.
%% Seven patterns. One register. No poetry.
%% ============================================================

%% SVC: "X is a Y."
render(is_a(X, Y), Sentence) :-
    name(X, XN), name(Y, YN),
    concat([XN, " is a ", YN, "."], Sentence).

%% SVO: "X enables Y."
render(relation(X, Rel, Y), Sentence) :-
    name(X, XN), name(Y, YN), verb_form(Rel, V),
    concat([XN, " ", V, " ", YN, "."], Sentence).

%% SVO + list: "X enables Y, Z, and W."
render(relation(X, Rel, List), Sentence) :-
    is_list(List),
    name(X, XN), verb_form(Rel, V),
    render_list(List, ListStr),
    concat([XN, " ", V, " ", ListStr, "."], Sentence).

%% Conditional: "If X, then Y."
render(conditional(X, Y), Sentence) :-
    render(X, XS), render(Y, YS),
    concat(["If ", XS, ", then ", YS], Sentence).

%% Causal: "X because Y."
render(because(X, Y), Sentence) :-
    render(X, XS), render(Y, YS),
    concat([XS, " because ", YS], Sentence).

%% Negation: "X does not enable Y."
render(negation(relation(X, Rel, Y)), Sentence) :-
    name(X, XN), name(Y, YN), verb_form(Rel, V),
    concat([XN, " does not ", V, " ", YN, "."], Sentence).

%% Conjunction: "X enables Y and Z requires W."
render(conjunction(A, B), Sentence) :-
    render(A, AS), render(B, BS),
    concat([AS, " and ", BS], Sentence).

    