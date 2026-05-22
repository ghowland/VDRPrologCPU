%% ============================================================
%% PHYSICS — DOMAIN PROLOG
%% Connects to core, math foundations, math logic, movement,
%% connections, data structures, algorithms, databases, FSM.
%% Facts from physics.compact
%% ============================================================


%% --- DOMAIN HIERARCHY ---
extends(d5, d1).      % special relativity extends classical mechanics
extends(d6, d5).      % general relativity extends special relativity
extends(d7, d1).      % quantum mechanics extends classical mechanics
extends(d8, d7).      % QFT extends quantum mechanics
extends(d8, d5).      % QFT extends special relativity
extends(d9, d2).      % statistical mechanics extends thermodynamics
extends(d9, d7).      % statistical mechanics extends QM
depends_on(d10, d7).  % nuclear physics depends on QM
depends_on(d10, d8).  % nuclear physics depends on QFT
depends_on(d11, d8).  % particle physics depends on QFT
depends_on(d12, d7).  % condensed matter depends on QM
depends_on(d12, d9).  % condensed matter depends on stat mech
depends_on(d13, d6).  % cosmology depends on GR
depends_on(d13, d8).  % cosmology depends on QFT
depends_on(d14, d10). % astrophysics depends on nuclear
depends_on(d14, d6).  % astrophysics depends on GR
specializes(d4, d3).  % optics specializes electromagnetism


%% --- SYMMETRY → CONSERVATION (NOETHER'S THEOREM) ---
%% The deepest structural pattern in physics.
enables(c49, c16).    % symmetry enables gauge invariance
enables(c49, c17).    % symmetry enables Noether's theorem
enables(c49, c19).    % symmetry enables CPT symmetry
enables(c17, l5).     % Noether enables conservation of energy
enables(c17, l6).     % Noether enables conservation of momentum
enables(c17, l7).     % Noether enables conservation of angular momentum
enables(c17, c6).     % Noether enables charge conservation

%% Conservation laws ARE instances of conserved quantities.
instance_of(l5, c4).  % energy conservation instance of energy
instance_of(l6, c2).  % momentum conservation instance of momentum
instance_of(l7, c3).  % angular momentum conservation instance of angular momentum


%% --- GAUGE INVARIANCE → FORCES ---
%% Symmetry dictates which forces exist and their form.
enables(c16, f2).     % gauge invariance enables EM (U(1))
enables(c16, f3).     % gauge invariance enables weak (SU(2))
enables(c16, f4).     % gauge invariance enables strong (SU(3))


%% --- FORCES AND MEDIATORS ---
determined_by(f1, p18).            % gravity determined by graviton (hypothetical)
determined_by(f2, p13).            % EM determined by photon
determined_by(f3, p14).            % weak determined by W+
determined_by(f3, p15).            % weak determined by W-
determined_by(f3, p16).            % weak determined by Z
determined_by(f4, p17).            % strong determined by gluon
derived_from(f5, f4).              % residual strong derived from strong


%% --- PARTICLE COMPOSITION ---
composed_of(p20, p1). composed_of(p20, p1). composed_of(p20, p2).  % proton = uud
composed_of(p21, p1). composed_of(p21, p2). composed_of(p21, p2).  % neutron = udd
composed_of(p22, p1). composed_of(p22, p2).  % charged pion = ud
part_of(p1, p20). part_of(p2, p20). part_of(p2, p21).

%% Generation structure (heavier generations generalize lighter).
generalizes(p1, p3).  generalizes(p3, p5).   % up → charm → top
generalizes(p2, p4).  generalizes(p4, p6).   % down → strange → bottom
generalizes(p7, p9).  generalizes(p9, p11).  % electron → muon → tau
generalizes(p8, p10). generalizes(p10, p12). % νe → νμ → ντ


%% --- HIGGS MECHANISM ---
%% Spontaneous symmetry breaking gives mass to particles.
enables(c20, p19).    % SSB enables Higgs boson
enables(c20, th2).    % SSB enables electroweak symmetry breaking threshold
enables(p19, p14).    % Higgs gives mass to W+
enables(p19, p15).    % Higgs gives mass to W-
enables(p19, p16).    % Higgs gives mass to Z
enables(p19, p1). enables(p19, p2). enables(p19, p3).  % Higgs gives mass to quarks
enables(p19, p4). enables(p19, p5). enables(p19, p6).
enables(p19, p7). enables(p19, p9). enables(p19, p11). % Higgs gives mass to charged leptons


%% --- QUANTUM PRINCIPLES → PHENOMENA ---
enables(c10, c26).    % wave-particle duality enables photoelectric effect
enables(c10, c27).    % wave-particle duality enables Compton scattering
enables(c11, c12).    % superposition enables entanglement
enables(c11, c40).    % superposition enables decoherence
equivalent_to(c13, l34). % uncertainty principle ≡ Heisenberg uncertainty
equivalent_to(c14, l35). % Pauli exclusion ≡ Pauli exclusion law
enables(c13, c24).    % uncertainty enables tunneling
enables(c14, c23).    % Pauli exclusion enables degeneracy pressure
enables(c14, c46).    % Pauli exclusion enables BEC (bosons don't obey it)
enables(c14, c47).    % Pauli exclusion enables superconductivity (Cooper pairs)
enables(c21, tr17).   % renormalization enables QFT development

%% Strong force internal structure.
enables(c42, c43).    % asymptotic freedom enables confinement understanding
requires(c43, c42).   % confinement requires asymptotic freedom


%% --- LAW DEPENDENCIES ---
%% What each law requires or extends.
requires(l2, c1).       % Newton's 2nd requires inertia concept
specializes(l4, l28).   % Newtonian gravity specializes Einstein field equations
generalizes(l28, l4).   % Einstein field equations generalize Newtonian gravity
derived_from(l29, l28). % Schwarzschild solution derived from EFE
derived_from(l30, l28). % Friedmann equations derived from EFE

%% Maxwell's equations as composition.
composed_of(l18, l14). composed_of(l18, l15).
composed_of(l18, l16). composed_of(l18, l17).
enables(l18, l24).      % Maxwell enables constancy of c (EM waves at c)
requires(l19, l14). requires(l19, l16). % Lorentz force requires Gauss + Faraday

%% Schrödinger equation.
generalizes(l31, l32). % time-dependent generalizes time-independent
extends(l36, l31).     % Dirac extends Schrödinger (relativistic)
requires(l36, l23).    % Dirac requires special relativity postulate 1

%% Blackbody radiation chain.
enables(l37, l40).     % Planck law enables Stefan-Boltzmann
enables(l37, l41).     % Planck law enables Wien's displacement
requires(l38, l37).    % photoelectric requires Planck's law
requires(l39, l37).    % de Broglie requires Planck's law (E=hν)

%% Statistical mechanics chain.
enables(l42, l43).     % Boltzmann entropy enables partition function
enables(l43, l44).     % partition function enables Fermi-Dirac distribution
enables(l43, l45).     % partition function enables Bose-Einstein distribution
requires(l44, c14).    % Fermi-Dirac requires Pauli exclusion
requires(l45, c9).     % Bose-Einstein requires integer spin

%% Kepler from Newton.
derived_from(l49, l4). % Kepler 1st from gravitational law
derived_from(l50, l7). % Kepler 2nd from angular momentum conservation
derived_from(l51, l4). % Kepler 3rd from gravitational law

%% Classical mechanics laws.
specializes(l55, l19). % Ohm's law specializes Lorentz force (bulk)
enables(l58, l62).     % Hooke's law enables wave equation
generalizes(l59, l4).  % Poisson equation generalizes Newton gravity
enables(l60, l61).     % continuity enables Navier-Stokes
derived_from(l62, l2). % wave equation derived from Newton's 2nd

%% Ultraviolet catastrophe: classical Rayleigh-Jeans contradicts Planck.
contradicts(l63, l37). % Rayleigh-Jeans contradicts Planck's law
causes(l63, tr14).     % UV catastrophe causes quantum revolution


%% --- TRANSITION CHAINS ---
%% The historical development of physics as a directed graph.
precedes(tr1, tr2).    % Aristotle → Galileo
precedes(tr2, tr3).    % Galileo → Newton
precedes(tr3, tr4).    % Newton → Lagrange/Hamilton
precedes(tr3, tr12).   % Newton → special relativity
precedes(tr5, tr6).    % caloric → entropy
precedes(tr6, tr7).    % entropy → statistical mechanics
enables(tr9, tr8).     % field theory enables unified EM
enables(tr8, tr11).    % unified EM enables EM wave theory of light
precedes(tr10, tr11).  % wave theory → EM wave theory
enables(tr11, tr12).   % EM wave theory enables special relativity
precedes(tr12, tr13).  % special relativity → general relativity
precedes(tr14, tr15).  % old quantum → full quantum
precedes(tr15, tr16).  % full quantum → relativistic quantum
enables(tr16, tr17).   % relativistic QM enables QFT
precedes(tr17, tr18).  % QFT → electroweak
precedes(tr17, tr19).  % QFT → QCD
enables(tr18, tr20).   % electroweak enables Standard Model
enables(tr19, tr20).   % QCD enables Standard Model
enables(tr20, tr28).   % Standard Model enables Higgs confirmation
precedes(tr21, tr22).  % expanding universe → CMB confirmation
precedes(tr22, tr23).  % CMB → accelerating expansion
precedes(tr24, tr25).  % subatomic → nuclear reactions
enables(tr24, tr26).   % subatomic enables quark model
precedes(tr26, tr27).  % 3 quarks → 6 quarks
contradicts(tr30, tr20). % neutrino oscillation contradicts SM (massless ν)
contradicts(c45, tr20).  % neutrino oscillation contradicts Standard Model

%% Experimental confirmations.
validates(tr31, l25).  % time dilation experiments validate time dilation
validates(tr32, l28).  % gravitational wave detection validates EFE
validates(tr33, c37).  % black hole image validates event horizon
validates(tr34, c47).  % BCS validates superconductivity
validates(tr35, c12).  % Bell tests validate entanglement
validates(tr36, c46).  % BEC creation validates Bose-Einstein condensation
validates(tr28, c20).  % Higgs detection validates spontaneous symmetry breaking


%% --- CONSTANTS → LAWS/THRESHOLDS ---
enables(k1, l24). enables(k1, l27).   % c enables light postulate + E=mc²
enables(k2, l4). enables(k2, l28).    % G enables gravity + EFE
enables(k3, l31). enables(k3, l34).   % ℏ enables Schrödinger + uncertainty
enables(k4, l37). enables(k4, l38). enables(k4, l39). % h enables Planck/photo/deBroglie
enables(k5, l42). enables(k5, l43).   % kB enables Boltzmann entropy + partition
enables(k6, l13). enables(k6, l19).   % e enables Coulomb + Lorentz force
enables(k7, l14).                      % ε₀ enables Gauss's law
enables(k8, l17).                      % μ₀ enables Ampère-Maxwell
determined_by(f2, k11).               % EM coupling determined by fine-structure α
determined_by(f3, k17).               % weak coupling determined by Fermi constant
enables(k18, l30).                     % Λ enables Friedmann equations
determined_by(k19, l30).              % Hubble constant determined by Friedmann

%% Planck scale.
part_of(k21, c39). part_of(k22, c39). % Planck time, length part of Planck scale
part_of(k23, c39). part_of(k24, c39). % Planck mass, energy part of Planck scale


%% --- THRESHOLD DEPENDENCIES ---
requires(th1, k21). requires(th1, k22). requires(th1, k23). % Planck threshold
determined_by(th2, p19).   % electroweak threshold determined by Higgs
determined_by(th3, f4).    % QCD confinement determined by strong force
determined_by(th4, c23).   % Chandrasekhar determined by degeneracy pressure
determined_by(th5, c23).   % TOV determined by degeneracy pressure
derived_from(th6, l29).    % Schwarzschild radius from Schwarzschild solution
determined_by(th7, l37).   % CMB decoupling determined by Planck's law
requires(th8, l47).        % nucleosynthesis requires binding energy relation
determined_by(th9, l11).   % absolute zero determined by third law
equivalent_to(th10, k1).   % speed of light threshold ≡ constant c
derived_from(th11, l32).   % Bohr energy from time-independent Schrödinger
determined_by(th12, l47).  % binding energy peak determined by mass-energy relation


%% --- OPEN PROBLEMS / CONTRADICTIONS ---
contradicts(c31, c32).     % dark matter contradicts dark energy (different unknowns)
contradicts(c45, tr20).    % neutrino oscillation contradicts Standard Model


%% --- CROSS-DOMAIN BRIDGES ---

%% Physics × Math Foundations.
%% Every physics domain uses mathematical structures.
requires(d1, math_st10).    % classical mechanics requires vector spaces
requires(d3, math_st10).    % electromagnetism requires vector spaces
requires(d6, math_st20).    % GR requires smooth manifolds
requires(d6, math_st14).    % GR requires metric spaces (pseudo-Riemannian)
requires(d7, math_st18).    % QM requires Hilbert spaces
requires(d8, math_st12).    % QFT requires algebras over fields
requires(d9, math_st26).    % stat mech requires probability spaces

%% Conservation laws ARE math invariants.
instance_of(l5, math_co35).  % energy conservation is a theorem
instance_of(l6, math_co35).  % momentum conservation is a theorem
instance_of(l7, math_co35).  % angular momentum conservation is a theorem

%% Symmetry groups ARE algebraic groups (math.ST4).
instance_of(f2_gauge, math_st4).  % U(1) is a group
instance_of(f3_gauge, math_st4).  % SU(2) is a group
instance_of(f4_gauge, math_st4).  % SU(3) is a group

%% Number systems used in physics.
requires(d1, math_ns4).   % classical mechanics uses reals
requires(d7, math_ns5).   % quantum mechanics uses complex numbers
requires(d6, math_ns4).   % GR uses reals (tensor fields)


%% Physics × Math Logic.
%% Physical laws ARE logical formulas.
instance_of(l2, logical_formula).     % F=ma is universally quantified
instance_of(l4, logical_formula).     % F=GMm/r² is universally quantified
instance_of(l10, logical_formula).    % second law is universally quantified

%% Experimental validation IS logical validation (logic.MG1 soundness).
implements(experimental_method, logic_mg1).  % experiment validates theory = soundness

%% Theoretical transitions ARE logical theory change.
%% TR3 (Galileo → Newton) = theory extension (logic extends).
%% TR14 (classical → quantum) = paradigm shift (old theory contradicted).
instance_of(tr3, theory_extension).
instance_of(tr14, theory_revolution).

%% Planck's resolution of UV catastrophe IS proof by contradiction.
%% Assume continuous emission (classical), derive catastrophe, conclude quantized.
implements(tr14, proof_by_contradiction).


%% Physics × Movement.
%% Physics formalizes what movement describes informally.
equivalent_to(c1, movement_co22).      % inertia ≡ movement.CO22
equivalent_to(c2, movement_co23).      % momentum ≡ movement.CO23
equivalent_to(l1, movement_sa1_rule).  % Newton 1st ≡ at rest stays at rest
equivalent_to(l2, movement_tr3_rule).  % Newton 2nd ≡ force causes acceleration

%% Physics causality formalizes movement causality.
%% movement.CU1 (necessary cause) = physics: necessary conditions for phenomena.
%% movement.CU2 (sufficient cause) = physics: sufficient conditions.
equivalent_to(c15, movement_equivalence).  % equivalence principle ≡ frame equivalence

%% Physics states map to movement states.
instance_of(thermal_equilibrium, movement_sa1).  % equilibrium = at rest
instance_of(phase_transition, movement_tr6).     % phase transition ≡ movement.TR6
instance_of(c22, movement_tr7).                  % phase transition = threshold crossing

%% Reference frames.
equivalent_to(d5_frame, movement_rf5).  % inertial frame ≡ movement.RF5
equivalent_to(d6_frame, movement_rf6).  % non-inertial frame ≡ movement.RF6

%% Oscillation.
equivalent_to(l62, movement_sm4).  % wave equation ≡ oscillation
equivalent_to(l58, movement_os1).  % Hooke's law ≡ SHM restoring force


%% Physics × Connections.
%% Forces ARE connections (transfer energy/momentum between bodies).
instance_of(f1, connection).   % gravity is a connection
instance_of(f2, connection).   % EM is a connection
instance_of(f3, connection).   % weak is a connection
instance_of(f4, connection).   % strong is a connection

%% Force properties map to connection properties.
composed_of(f1, co5_strength).   % gravity has strength (~10⁻³⁸)
composed_of(f2, co5_strength).   % EM has strength (α ≈ 1/137)
composed_of(f1, co7_latency).    % gravity propagates at c (latency)
composed_of(f2, co7_latency).    % EM propagates at c
composed_of(f3, co8_capacity).   % weak has limited range (capacity)

%% Photon IS a signal (connections.IN7).
instance_of(p13, signal).
%% EM radiation IS a channel (connections.CH4).
instance_of(em_radiation, ch4).
%% Gravitational waves IS a channel (connections.CH9).
instance_of(grav_waves, ch9).

%% Event horizon IS a connection boundary (connections.CO11 interface).
instance_of(c37, connection_boundary).
prevents(c37, signal_escape).  % event horizon prevents signal escape

%% Entanglement IS a connection (connections.CH12 quantum channel).
instance_of(c12, ch12).


%% Physics × FSM.
%% Particle decay IS a state machine.
instance_of(radioactive_decay, mt4).  % Moore: output determined by state (decay products)
evolves_to(unstable_nucleus, decay_products).
determined_by(decay_rate, l46).  % decay rate determined by decay law

%% Phase transitions ARE FSM transitions.
instance_of(c22, fsm_transition).
evolves_to(solid, liquid).    % melting
evolves_to(liquid, gas).      % evaporation
evolves_to(liquid, solid).    % freezing
evolves_to(gas, liquid).      % condensation

%% Stellar evolution IS an FSM.
instance_of(stellar_lifecycle, mt4).
evolves_to(main_sequence, red_giant).
evolves_to(red_giant, white_dwarf).         % below Chandrasekhar
evolves_to(red_giant, neutron_star).        % above Chandrasekhar, below TOV
evolves_to(red_giant, black_hole).          % above TOV
instance_of(black_hole, dead_state).        % no further stellar evolution
requires(white_dwarf_transition, th4).      % requires Chandrasekhar limit
requires(black_hole_transition, th5).       % requires TOV limit

%% Standard Model development IS an FSM.
instance_of(sm_development, mt4).
evolves_to(classical_physics, quantum_physics).     % TR14
evolves_to(quantum_physics, qft).                   % TR17
evolves_to(qft, electroweak_plus_qcd).              % TR18+TR19
evolves_to(electroweak_plus_qcd, standard_model).   % TR20
evolves_to(standard_model, beyond_sm).               % open: neutrino mass, dark matter


%% Physics × Data Structures.
%% Particle generations = tree taxonomy (DS.ST23 hierarchy).
instance_of(particle_generations, tree_taxonomy).

%% Periodic table of elements (extension) would be a sorted structure.
%% Phase diagrams are 2D lookup tables (DS.ST43 matrix variant).
instance_of(phase_diagram, lookup_table).

%% Feynman diagrams are directed graphs (DS.ST42).
instance_of(feynman_diagram, directed_graph).

%% Wavefunction discretization uses arrays (DS.ST1) in computation.
requires(computational_qm, st1_ds).


%% Physics × Algorithms.
%% N-body simulation = O(n²) naive or O(n log n) Barnes-Hut.
instance_of(nbody_naive, cx5).    % O(n²) all-pairs
instance_of(nbody_barneshut, cx4). % O(n log n) tree-based

%% Monte Carlo methods in statistical mechanics.
instance_of(monte_carlo_stat_mech, algo_te6).  % randomization technique

%% Molecular dynamics = numerical integration = algorithms.AL78 (Newton's method variant).
requires(molecular_dynamics, numerical_integration).

%% Finite element method for PDE = algorithms concept.
requires(fem, algo_te1).  % divide and conquer (domain decomposition)

%% FFT (algorithms.AL77) used in signal processing / quantum mechanics.
enables(algo_al77, spectral_analysis).
enables(algo_al77, quantum_fourier_transform).


%% Physics × Databases.
%% Particle Data Group (PDG) IS a database.
instance_of(pdg, db_co1).  % PDG is a database
%% Experimental results stored with provenance = database with metadata.
instance_of(experimental_data, db_co18).  % experimental data has metadata

%% CERN data pipeline IS a database pipeline.
instance_of(cern_pipeline, db_qp_pipeline).


%% Physics × VDR-Prolog System.

%% Q16 exact arithmetic IS relevant to physics computation.
%% Physics normally uses floats. VDR uses exact integers.
%% This means: physics computations in VDR carry remainders.
%% Every force calculation captures its remainder.
%% Every energy calculation is exact to the Q16 frame.
enables(vdr_q16, exact_physics_computation).
prevents(vdr_q16, floating_point_drift).

%% Physical constants stored as Q16 values in KB.
instance_of(physics_constants_kb, vdr_kb).
%% Each constant is a Fact with TAG_VALUE and provenance.
instance_of(k1_fact, vdr_fact).  % speed of light as Q16 fact
instance_of(k2_fact, vdr_fact).  % gravitational constant as Q16 fact

%% Physics laws stored as Prolog rules in KB.
instance_of(l2_rule, vdr_rule).  % F=ma as Prolog rule
instance_of(l4_rule, vdr_rule).  % gravity as Prolog rule

%% Physics transitions stored as typed relations.
instance_of(tr3_relation, vdr_typed_relation).  % Galileo→Newton as relation
instance_of(tr14_relation, vdr_typed_relation). % classical→quantum as relation

%% Physics thresholds are Q16 values with provenance.
instance_of(th4_fact, vdr_fact).  % Chandrasekhar limit as fact
instance_of(th6_fact, vdr_fact).  % Schwarzschild radius as fact

%% The physics domain KB lives at root.science.physics.
%% Subdomain KBs carry their own weights for domain-specific inference.
instance_of(physics_kb, domain_kb_with_weights).
