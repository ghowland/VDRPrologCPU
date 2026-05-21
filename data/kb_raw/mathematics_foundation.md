# FOUNDATIONS OF MATHEMATICS — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: axiom_systems → logic → concepts → structures → number_systems → proof_methods → branches → distinctions → relationships → decode_legend

# axiom_systems(id|name|axioms_summary|foundation_for)
AX1|Zermelo-Fraenkel with Choice (ZFC)|extensionality; regularity; schema of specification; pairing; union; schema of replacement; infinity; power set; choice|standard set-theoretic foundation for all mathematics
AX2|Peano Axioms|0 is natural; successor is injective; 0 is not a successor; induction schema|natural numbers and arithmetic
AX3|Propositional Logic Axioms|identity (p→p); non-contradiction ¬(p∧¬p); excluded middle (p∨¬p); modus ponens as inference rule|deductive reasoning base
AX4|First-Order Predicate Logic|propositional axioms + universal instantiation; existential generalization; variable binding rules|quantified reasoning over domains
AX5|Lambda Calculus|variable reference; abstraction (λx.M); application (M N); alpha-equivalence; beta-reduction; eta-conversion|computation and type theory foundation
AX6|Category Theory Axioms|objects; morphisms; identity morphism per object; associative composition of morphisms|structural foundation across mathematical domains
AX7|Hilbert's Axioms for Geometry|incidence (8 axioms); order (4); congruence (6); continuity (2: Archimedes, completeness); parallels (1)|Euclidean geometry
AX8|Kolmogorov Axioms|sample space Ω; event σ-algebra F; P(Ω)=1; P(A)≥0; countable additivity for disjoint events|probability theory
AX9|Field Axioms|additive closure, associativity, commutativity, identity (0), inverses; multiplicative closure, associativity, commutativity, identity (1), inverses for nonzero; distributivity|algebraic field structures

# logic(id|name|definition|role)
LG1|Propositional Logic|formal system over truth-valued propositions with connectives ¬∧∨→↔|base deductive layer
LG2|Predicate Logic (First-Order)|extends propositional with quantifiers ∀∃ over variable-bound domains|standard mathematical reasoning
LG3|Second-Order Logic|quantification over predicates and relations, not just individuals|stronger expressiveness, used in some foundations
LG4|Modal Logic|extends propositional with necessity □ and possibility ◇ operators|reasoning about possibility, necessity, provability
LG5|Intuitionistic Logic|rejects law of excluded middle; proof = construction|constructive mathematics foundation
LG6|Classical Logic|accepts excluded middle and double negation elimination|standard mathematical logic
LG7|Modus Ponens|from P and P→Q, derive Q|fundamental inference rule
LG8|Modus Tollens|from ¬Q and P→Q, derive ¬P|contrapositive inference
LG9|Universal Instantiation|from ∀x.P(x), derive P(a) for any a in domain|predicate logic elimination rule
LG10|Existential Generalization|from P(a), derive ∃x.P(x)|predicate logic introduction rule
LG11|Completeness (Gödel)|every valid first-order formula is provable|first-order logic is semantically complete
LG12|Incompleteness (Gödel 1st)|any consistent system containing arithmetic has true unprovable statements|fundamental limitation on formal systems
LG13|Incompleteness (Gödel 2nd)|no consistent system containing arithmetic can prove its own consistency|self-reference limitation
LG14|Soundness|if provable then true in all models|proof system correctness criterion
LG15|Decidability|existence of algorithm to determine truth of any formula in the system|propositional logic decidable; first-order logic undecidable (Church-Turing)

# concepts(id|name|definition|category)
CO1|Set|collection of distinct objects considered as a whole|foundation
CO2|Element|object belonging to a set, x∈S|foundation
CO3|Subset|A⊆B iff every element of A is in B|foundation
CO4|Power Set|P(S) = set of all subsets of S|foundation
CO5|Empty Set|∅, set with no elements; exists by ZFC|foundation
CO6|Function|relation f:A→B assigning exactly one output per input|foundation
CO7|Relation|subset of cartesian product A×B|foundation
CO8|Bijection|function that is both injective (one-to-one) and surjective (onto)|foundation
CO9|Cardinality|measure of set size; |S|; extends to infinite sets via bijection|foundation
CO10|Countable|set with cardinality ≤ |ℕ|; admits injection into ℕ|foundation
CO11|Uncountable|set with cardinality > |ℕ|; proved for ℝ by Cantor's diagonal argument|foundation
CO12|Ordinal|equivalence class of well-ordered sets under order isomorphism|set_theory
CO13|Cardinal|ordinal not in bijection with any smaller ordinal|set_theory
CO14|Axiom of Choice|for any collection of nonempty sets, there exists a choice function selecting one element from each|set_theory
CO15|Well-Ordering|every nonempty subset has a least element; equivalent to axiom of choice|set_theory
CO16|Zorn's Lemma|if every chain in a partially ordered set has an upper bound, the set has a maximal element; equivalent to choice|set_theory
CO17|Infinity|existence of an inductive set (set containing ∅ and closed under successor); ZFC axiom|set_theory
CO18|Equivalence Relation|reflexive, symmetric, transitive relation; partitions domain into equivalence classes|foundation
CO19|Partial Order|reflexive, antisymmetric, transitive relation|foundation
CO20|Total Order|partial order where every pair is comparable|foundation
CO21|Well-Order|total order where every nonempty subset has a minimum|foundation
CO22|Isomorphism|structure-preserving bijection between two algebraic structures|algebra
CO23|Homomorphism|structure-preserving map between algebraic structures (need not be bijective)|algebra
CO24|Kernel|preimage of identity element under homomorphism; measures non-injectivity|algebra
CO25|Quotient Structure|structure formed by collapsing an equivalence relation (or normal subgroup, ideal)|algebra
CO26|Limit|value that a sequence or function approaches; ε-δ definition or net convergence|analysis
CO27|Continuity|f continuous at a iff lim(x→a) f(x) = f(a); preimage of open sets is open|analysis
CO28|Compactness|every open cover has a finite subcover; generalizes closed-and-bounded|topology
CO29|Connectedness|space cannot be partitioned into two nonempty open sets|topology
CO30|Completeness (metric)|every Cauchy sequence converges within the space|analysis
CO31|Topology|collection of open sets on X closed under arbitrary union and finite intersection, containing ∅ and X|topology
CO32|Metric|distance function d:X×X→[0,∞) satisfying identity of indiscernibles, symmetry, triangle inequality|topology
CO33|Measure|function μ:σ-algebra→[0,∞] with μ(∅)=0 and countable additivity|analysis
CO34|σ-algebra|collection of subsets closed under complement and countable union, containing ∅|analysis
CO35|Proof|finite sequence of statements each following from axioms or prior statements by inference rules|logic
CO36|Theorem|statement proved true from axioms within a formal system|logic
CO37|Lemma|theorem proved primarily as a stepping stone to a larger result|logic
CO38|Conjecture|statement believed true but not yet proved|logic
CO39|Infinity (concept)|property of sets equinumerous with a proper subset (Dedekind); or not in bijection with any finite ordinal|set_theory
CO40|Constructibility|property of being definable from simpler objects by allowed operations; Gödel's L|set_theory
CO41|Category|collection of objects with morphisms between them satisfying identity and composition|category_theory
CO42|Functor|structure-preserving map between categories; maps objects to objects and morphisms to morphisms|category_theory
CO43|Natural Transformation|morphism between functors; family of morphisms commuting with functor maps|category_theory
CO44|Continuum Hypothesis|no cardinality strictly between |ℕ| and |ℝ|; independent of ZFC (Cohen/Gödel)|set_theory
CO45|Boolean Algebra|complemented distributive lattice; models classical propositional logic|algebra
CO46|Lattice|partially ordered set where every pair has a meet (inf) and join (sup)|algebra

# structures(id|name|definition|carrier|operations|axioms|category)
ST1|Magma|set with a binary operation|set S|one binary op ∗|closure|algebra
ST2|Semigroup|magma with associativity|set S|one binary op ∗|closure, associativity|algebra
ST3|Monoid|semigroup with identity element|set S|one binary op ∗, identity e|closure, associativity, identity|algebra
ST4|Group|monoid with inverses|set G|one binary op ∗, identity e, inverse ⁻¹|closure, associativity, identity, inverses|algebra
ST5|Abelian Group|group with commutativity|set G|one binary op +, identity 0, inverse −|group axioms + commutativity|algebra
ST6|Ring|abelian group (S,+) with second associative operation ∗ distributing over +|set R|(+, ∗)|abelian group under +; closure, associativity under ∗; distributivity|algebra
ST7|Commutative Ring|ring with commutative multiplication|set R|(+, ∗)|ring axioms + multiplicative commutativity|algebra
ST8|Integral Domain|commutative ring with unity and no zero divisors|set R|(+, ∗, 1)|commutative ring + unity + if ab=0 then a=0 or b=0|algebra
ST9|Field|commutative ring where every nonzero element has multiplicative inverse|set F|(+, ∗, 0, 1, ⁻¹)|ring axioms + multiplicative inverses for F\{0}|algebra
ST10|Vector Space|abelian group (V,+) with scalar multiplication over field F|set V over field F|(+, scalar ∗)|8 axioms: additive group + scalar associativity, distributivity (2), scalar identity|linear_algebra
ST11|Module|vector space generalized to scalars from a ring instead of field|set M over ring R|(+, scalar ∗)|same form as vector space but over ring|algebra
ST12|Algebra (over field)|vector space with compatible bilinear multiplication|set A over field F|(+, scalar ∗, bilinear ∗)|vector space + bilinear product|algebra
ST13|Topological Space|set X with topology τ (collection of open sets)|set X|open set operations (∪, ∩)|τ contains ∅,X; closed under arbitrary ∪ and finite ∩|topology
ST14|Metric Space|set X with distance function d|set X|metric d|identity of indiscernibles; symmetry; triangle inequality|topology
ST15|Normed Space|vector space with norm ‖·‖ inducing metric d(x,y)=‖x−y‖|vector space V|norm ‖·‖|positivity; homogeneity; triangle inequality|analysis
ST16|Banach Space|complete normed vector space|vector space V|norm ‖·‖|normed space + every Cauchy sequence converges|analysis
ST17|Inner Product Space|vector space with inner product ⟨·,·⟩|vector space V|inner product ⟨·,·⟩|conjugate symmetry; linearity in first argument; positive definiteness|analysis
ST18|Hilbert Space|complete inner product space|vector space V|inner product ⟨·,·⟩|inner product space + Cauchy completeness|analysis
ST19|Manifold|topological space locally homeomorphic to ℝⁿ|topological space M|charts, atlas|Hausdorff; second-countable; locally Euclidean|geometry
ST20|Smooth Manifold|manifold with C∞ transition maps between charts|manifold M|smooth atlas|manifold + smooth compatibility of charts|geometry
ST21|Lie Group|smooth manifold that is also a group with smooth group operations|smooth manifold G|group op, smooth structure|group axioms + smooth multiplication and inversion maps|geometry
ST22|Poset|set with partial order relation ≤|set P|relation ≤|reflexivity; antisymmetry; transitivity|order_theory
ST23|Boolean Algebra (structure)|complemented distributive lattice|set B|(∧, ∨, ¬, 0, 1)|lattice axioms + distributivity + complementation|algebra
ST24|Sigma-Algebra|collection of subsets of X closed under complement and countable union|power set of X|(complement, countable ∪)|contains ∅; closed under complement; closed under countable union|measure_theory
ST25|Measure Space|set X with σ-algebra Σ and measure μ|triple (X, Σ, μ)|measure μ|μ(∅)=0; countable additivity; non-negativity|measure_theory
ST26|Probability Space|measure space with μ(X)=1|triple (Ω, F, P)|probability measure P|measure space axioms + P(Ω)=1|probability

# number_systems(id|name|set_symbol|properties|constructed_from)
NS1|Natural Numbers|ℕ|well-ordered; closed under +,∗; not under −,÷|Peano axioms or von Neumann ordinals (0=∅, n+1=n∪{n})
NS2|Integers|ℤ|ring; closed under +,−,∗; not under ÷; well-ordered on ℕ|equivalence classes of pairs (a,b) from ℕ×ℕ where (a,b)~(c,d) iff a+d=b+c
NS3|Rationals|ℚ|field; dense; countable; ordered; not complete|equivalence classes of pairs (p,q) from ℤ×(ℤ\{0}) where (p,q)~(r,s) iff ps=qr
NS4|Real Numbers|ℝ|complete ordered field; uncountable; connected|Dedekind cuts of ℚ or equivalence classes of Cauchy sequences in ℚ
NS5|Complex Numbers|ℂ|algebraically closed field; not ordered; ℝ²-structure|ℝ×ℝ with (a,b)+(c,d)=(a+c,b+d) and (a,b)(c,d)=(ac−bd,ad+bc)
NS6|Quaternions|ℍ|division ring (non-commutative); 4-dimensional over ℝ|ℝ⁴ with basis {1,i,j,k} where i²=j²=k²=ijk=−1
NS7|Algebraic Numbers|𝔸|countable; field; contains all roots of polynomials over ℚ|roots of nonzero polynomials with rational coefficients
NS8|Transcendental Numbers|ℝ\𝔸|uncountable; not closed under any operation|reals that are not algebraic (e, π are transcendental)
NS9|p-adic Numbers|ℚₚ|complete w.r.t. p-adic metric; totally disconnected; local field|completion of ℚ under p-adic absolute value |x|ₚ = p^(−vₚ(x))
NS10|Ordinal Numbers|Ord|well-ordered by ∈; not a set (proper class); transfinite arithmetic|transitive sets well-ordered by ∈
NS11|Cardinal Numbers|Card|measure set size; arithmetic: ℵ₀+ℵ₀=ℵ₀; ℵ₀·ℵ₀=ℵ₀; 2^ℵ₀=|ℝ||equivalence classes of sets under bijection; initial ordinals under AC

# proof_methods(id|name|mechanism|when_used)
PM1|Direct Proof|assume hypothesis, derive conclusion through logical steps|default method; conclusion follows from known results
PM2|Proof by Contradiction|assume ¬P, derive contradiction, conclude P|when direct construction is difficult; existence proofs
PM3|Proof by Contrapositive|prove ¬Q→¬P instead of P→Q|when negation of conclusion yields tractable hypothesis
PM4|Mathematical Induction|prove P(0); prove P(n)→P(n+1); conclude ∀n.P(n)|statements indexed by natural numbers
PM5|Strong Induction|prove P(n) assuming P(k) for all k<n|when inductive step needs multiple predecessors
PM6|Transfinite Induction|extend induction to well-ordered sets beyond ℕ; base, successor, limit cases|statements indexed by ordinals
PM7|Structural Induction|induction on recursive structure definition|recursively defined objects (trees, formulas, terms)
PM8|Proof by Exhaustion|check all finite cases|finite case space; no general pattern available
PM9|Constructive Proof|exhibit explicit witness or algorithm|when existence must be demonstrated concretely
PM10|Non-Constructive Proof|prove existence without exhibiting witness (often via contradiction or choice)|when construction is unknown or impossible
PM11|Diagonalization|construct object differing from every element of a list in at least one position|uncountability proofs; undecidability; fixed-point arguments
PM12|Pigeonhole Principle|if n+1 objects placed in n boxes, some box has ≥2|combinatorial existence arguments
PM13|Counting Argument|compare cardinalities to establish existence or impossibility|combinatorics; lower/upper bounds
PM14|Compactness Argument|extract finite substructure from infinite configuration|model theory; topology; combinatorics

# branches(id|name|core_objects|core_problems|parent_branch)
BR1|Foundations/Logic|formal systems, axioms, proofs, models|consistency, completeness, decidability, independence|—
BR2|Set Theory|sets, ordinals, cardinals, forcing models|continuum hypothesis, large cardinal axioms, determinacy|BR1
BR3|Category Theory|categories, functors, natural transformations, adjunctions|universal properties, representability, topos theory|BR1
BR4|Algebra|groups, rings, fields, modules|classification of structures, representation, decomposition|—
BR5|Linear Algebra|vector spaces, matrices, linear maps, eigenvalues|solving linear systems, spectral decomposition, dimensionality|BR4
BR6|Group Theory|groups, subgroups, homomorphisms, actions|classification of finite simple groups, representation theory|BR4
BR7|Ring Theory|rings, ideals, modules, algebras|factorization, ideal structure, Noetherian conditions|BR4
BR8|Field Theory|field extensions, Galois groups, algebraic closures|solvability by radicals, transcendence, algebraic closure|BR4
BR9|Commutative Algebra|commutative rings, ideals, localizations, completions|prime spectrum, dimension theory, homological methods|BR7
BR10|Number Theory|integers, primes, Diophantine equations, L-functions|prime distribution, Riemann hypothesis, Diophantine solvability|—
BR11|Algebraic Number Theory|number fields, rings of integers, ideals, class groups|unique factorization failure/recovery, class number, reciprocity laws|BR10
BR12|Analytic Number Theory|Dirichlet series, L-functions, sieve methods|prime counting (π(x)~x/ln x), gaps between primes, additive problems|BR10
BR13|Analysis|limits, continuity, derivatives, integrals, series|convergence, approximation, existence/uniqueness of solutions|—
BR14|Real Analysis|real-valued functions, Lebesgue measure, convergence|characterizing function spaces, measure theory, integration theory|BR13
BR15|Complex Analysis|holomorphic functions, contour integrals, residues|analytic continuation, conformal mapping, value distribution|BR13
BR16|Functional Analysis|Banach/Hilbert spaces, operators, spectra|spectral theory, operator algebras, distribution theory|BR13
BR17|Harmonic Analysis|Fourier transforms, group representations, wavelets|convergence of Fourier series, uncertainty principles|BR16
BR18|Topology|open sets, continuous maps, homeomorphisms, homotopy|classification of spaces, invariants, fixed points|—
BR19|Point-Set Topology|topological spaces, compactness, connectedness, separation axioms|metrization, compactification, dimension|BR18
BR20|Algebraic Topology|fundamental groups, homology, cohomology, homotopy groups|computing invariants, classification of manifolds|BR18
BR21|Differential Topology|smooth manifolds, smooth maps, tangent bundles|cobordism, surgery, exotic structures|BR18
BR22|Geometry|points, lines, surfaces, curvature, distance|measurement, classification of spaces, symmetry|—
BR23|Euclidean Geometry|points, lines, planes, circles, angles|construction, congruence, similarity, area/volume|BR22
BR24|Differential Geometry|smooth manifolds, Riemannian metrics, curvature tensors|geodesics, curvature-topology relations, geometric flows|BR22
BR25|Algebraic Geometry|varieties, schemes, sheaves, cohomology|classification of varieties, intersection theory, moduli|BR22
BR26|Combinatorics|finite sets, graphs, permutations, partitions|enumeration, extremal problems, Ramsey theory|—
BR27|Graph Theory|graphs, vertices, edges, connectivity, coloring|planarity, chromatic number, network flows, Ramsey numbers|BR26
BR28|Probability Theory|sample spaces, random variables, distributions, expectation|limit theorems, concentration, stochastic processes|—
BR29|Measure Theory|measurable spaces, measures, integration, convergence|construction of measures, decomposition theorems, Fubini|BR13
BR30|Differential Equations (ODE)|functions, derivatives, initial value problems|existence/uniqueness (Picard-Lindelöf), stability, qualitative behavior|BR13
BR31|Partial Differential Equations (PDE)|multivariate functions, partial derivatives, boundary conditions|existence, uniqueness, regularity, well-posedness|BR13
BR32|Dynamical Systems|state spaces, flows, orbits, attractors|stability, chaos, bifurcation, ergodicity|BR13
BR33|Numerical Analysis|approximation algorithms, error bounds, convergence rates|accuracy, stability, efficiency of computational methods|BR13
BR34|Optimization|feasible sets, objective functions, constraints|existence of optima, duality, algorithmic convergence|—
BR35|Mathematical Logic|formal languages, proof systems, models, computability|consistency strength hierarchy, decidability boundaries|BR1

# distinctions(id|side_a|side_b|key_asymmetry)
DI1|Constructive proof|Non-constructive proof|constructive provides witness; non-constructive proves existence without exhibiting one
DI2|Finite|Infinite|finite sets have cardinality in ℕ; infinite sets are equinumerous with a proper subset
DI3|Countable|Uncountable|countable admits injection to ℕ; uncountable does not (Cantor diagonal)
DI4|Discrete|Continuous|discrete structures have isolated points; continuous structures have limit behavior at every point
DI5|Algebraic|Transcendental|algebraic numbers are polynomial roots over ℚ; transcendental are not
DI6|Pure|Applied|pure mathematics studies structure for its own sake; applied targets external problem domains
DI7|Syntax|Semantics|syntax = formal symbol manipulation; semantics = interpretation in models
DI8|Decidable|Undecidable|decidable: algorithm exists to determine all instances; undecidable: no such algorithm exists
DI9|Consistent|Inconsistent|consistent: no derivable contradiction; inconsistent: derives P∧¬P for some P
DI10|Complete|Incomplete|complete: every statement or its negation is provable; incomplete: some statements are neither
DI11|Commutative|Non-commutative|commutative: a∗b=b∗a for all a,b; non-commutative: order of operation matters
DI12|Linear|Nonlinear|linear: f(ax+by)=af(x)+bf(y); nonlinear: this fails; qualitative behavior differs fundamentally
DI13|Pointwise|Uniform|pointwise: property holds at each point independently; uniform: single bound works across all points simultaneously
DI14|Local|Global|local: property holds in neighborhoods; global: property holds across entire space
DI15|Abstract|Concrete|abstract: defined by axioms satisfied by many models; concrete: specific construction or representation

# relationships(from|rel|to)
# Axiom system foundations
AX1|foundation_for|CO1,CO2,CO3,CO4,CO5,CO6,CO7
AX2|foundation_for|NS1
AX3|foundation_for|LG1
AX4|extends|AX3
AX4|foundation_for|LG2
AX5|foundation_for|CO6
AX6|foundation_for|CO41,CO42,CO43
AX7|foundation_for|BR23
AX8|foundation_for|ST26
AX9|foundation_for|ST9

# Logic dependencies
LG2|extends|LG1
LG3|extends|LG2
LG4|extends|LG1
LG5|specializes|LG6
LG6|implements|AX3,AX4
LG7|part_of|LG1
LG8|part_of|LG1
LG9|part_of|LG2
LG10|part_of|LG2
LG11|validates|LG2
LG12|constrains|AX2,LG2
LG13|constrains|AX2,LG2
LG14|validates|CO35
LG15|distinguishes|LG2,LG1

# Concept relationships
CO1|contains|CO2
CO3|specializes|CO7
CO4|derived_from|CO1
CO6|specializes|CO7
CO8|specializes|CO6
CO9|measured_by|CO8
CO10|specializes|CO9
CO11|specializes|CO9
CO11|contradicts|CO10
CO12|generalizes|NS1
CO13|derived_from|CO12
CO14|equivalent_to|CO15,CO16
CO18|specializes|CO7
CO19|specializes|CO7
CO20|specializes|CO19
CO21|specializes|CO20
CO22|specializes|CO23
CO24|derived_from|CO23
CO25|derived_from|CO18
CO26|foundation_for|CO27
CO28|requires|CO31
CO29|requires|CO31
CO31|generalizes|CO32
CO33|requires|CO34
CO34|specializes|CO4

# Structure hierarchy (algebraic chain)
ST1|generalizes|ST2
ST2|generalizes|ST3
ST3|generalizes|ST4
ST4|generalizes|ST5
ST5|part_of|ST6
ST6|generalizes|ST7
ST7|generalizes|ST8
ST8|generalizes|ST9

# Structure hierarchy (topological/analytic chain)
ST13|generalizes|ST14
ST14|specializes|ST15
ST15|generalizes|ST16
ST17|generalizes|ST18
ST13|generalizes|ST19
ST19|generalizes|ST20
ST20|requires|ST13
ST21|implements|ST4,ST20

# Structure hierarchy (order/measure)
ST22|implements|CO19
ST23|implements|CO45
ST24|implements|CO34
ST25|requires|ST24
ST26|specializes|ST25

# Vector space / module
ST10|specializes|ST5
ST10|requires|ST9
ST11|generalizes|ST10
ST12|specializes|ST10

# Number system construction chain
NS1|constructed_from|AX2
NS2|extends|NS1
NS3|extends|NS2
NS4|extends|NS3
NS5|extends|NS4
NS6|extends|NS4
NS7|specializes|NS5
NS8|complement_of|NS7
NS9|extends|NS3

# Number system structure links
NS1|implements|ST3
NS2|implements|ST6
NS3|implements|ST9
NS4|implements|ST9
NS4|instance_of|CO30
NS5|implements|ST9
NS6|implements|ST4

# Proof method relationships
PM1|foundation_for|PM2,PM3
PM4|requires|NS1
PM5|generalizes|PM4
PM6|generalizes|PM5
PM6|requires|CO21
PM7|specializes|PM4
PM11|implements|PM2

# Branch taxonomy
BR2|specializes|BR1
BR3|specializes|BR1
BR35|specializes|BR1
BR5|specializes|BR4
BR6|specializes|BR4
BR7|specializes|BR4
BR8|specializes|BR4
BR9|specializes|BR7
BR11|specializes|BR10
BR12|specializes|BR10
BR14|specializes|BR13
BR15|specializes|BR13
BR16|specializes|BR13
BR17|specializes|BR16
BR19|specializes|BR18
BR20|specializes|BR18
BR21|specializes|BR18
BR23|specializes|BR22
BR24|specializes|BR22
BR25|specializes|BR22
BR27|specializes|BR26
BR29|specializes|BR13
BR30|specializes|BR13
BR31|specializes|BR13
BR32|specializes|BR13
BR33|specializes|BR13

# Branch-structure links
BR4|studies|ST1,ST2,ST3,ST4,ST5,ST6,ST7,ST8,ST9
BR5|studies|ST10
BR6|studies|ST4,ST5
BR7|studies|ST6,ST7,ST8
BR8|studies|ST9
BR10|studies|NS1,NS2,NS3,NS7
BR13|studies|CO26,CO27,CO30
BR14|studies|ST25,CO33
BR16|studies|ST16,ST18
BR18|studies|ST13,CO28,CO29
BR19|studies|ST13,ST14
BR22|studies|ST19,ST20
BR24|studies|ST20,ST21
BR28|studies|ST26
BR29|studies|ST25

# Cross-branch connections
BR25|requires|BR4,BR18
BR20|requires|BR4,BR18
BR11|requires|BR4,BR10
BR24|requires|BR13,BR22
BR17|requires|BR4,BR13

# Distinction links
DI1|distinguishes|PM9,PM10
DI2|distinguishes|CO9,CO39
DI3|distinguishes|CO10,CO11
DI5|distinguishes|NS7,NS8
DI7|distinguishes|LG1,LG11
DI8|distinguishes|LG15
DI9|distinguishes|LG14
DI10|distinguishes|LG12
DI11|distinguishes|ST4,ST5
DI12|distinguishes|ST10,BR31
DI13|distinguishes|CO27
DI14|distinguishes|CO28,CO29

# decode_legend
# id_prefixes: AX=axiom_system, LG=logic, CO=concept, ST=structure, NS=number_system, PM=proof_method, BR=branch, DI=distinction
# rel_types: foundation_for|extends|specializes|generalizes|implements|requires|constrains|validates|part_of|derived_from|contains|equivalent_to|contradicts|distinguishes|complement_of|constructed_from|instance_of|measured_by|studies
# notation: fk references use raw ID; comma-separated targets expand to individual rules; — in parent_branch means root-level branch
# confidence: synthetic domain knowledge — not extracted from a single source document
