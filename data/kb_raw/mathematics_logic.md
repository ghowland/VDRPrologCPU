# MATHEMATICS OF LOGIC: FOUNDATIONS AND FORMAL SYSTEMS — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: domains → propositional_logic → predicate_logic → set_theory → relations → functions → proof_theory → model_theory → computability → modal_logic → type_theory → category_logic → paradoxes → metalogic → axiom_systems → inference_rules → logical_identities → normal_forms → decidability → concepts → relationships → section_index → decode_legend

# domains(id|name|definition)
DM1|propositional logic (sentential)|logic of truth-functional connectives operating on propositions (atomic sentences with no internal structure); decidable; complete; sound; Boolean algebra is its algebraic semantics
DM2|first-order predicate logic (FOL)|logic with quantifiers (∀, ∃), variables, predicates, functions, and constants over a domain of discourse; complete (Gödel 1930); undecidable (Church-Turing 1936); most important formal logic
DM3|second-order logic (SOL)|extends FOL with quantification over predicates and functions (not just individuals); full SOL: not completable (no effective proof system captures all valid formulas); Henkin semantics: completable but equivalent to many-sorted FOL
DM4|set theory|foundational framework: objects (sets) and membership (∈); ZFC axioms; encodes all mathematics; provides semantic domains for logic; closely intertwined with predicate logic
DM5|proof theory|study of formal proofs as mathematical objects; syntactic approach; Hilbert-style, natural deduction, sequent calculus; cut elimination; proof normalization; consistency proofs; ordinal analysis
DM6|model theory|study of relationships between formal languages and their interpretations (structures/models); semantic approach; satisfaction, truth, elementary equivalence, compactness, Löwenheim-Skolem; ultraproducts
DM7|computability theory (recursion theory)|study of what can be computed in principle; Turing machines, recursive functions, lambda calculus; Church-Turing thesis; decidability and semi-decidability of logical theories
DM8|modal logic|logic of necessity (□) and possibility (◇); Kripke semantics (possible worlds + accessibility relation); extensions: deontic, epistemic, temporal, doxastic
DM9|intuitionistic logic|constructive logic rejecting law of excluded middle (LEM) as axiom; proof = construction; BHK interpretation; Heyting algebras; Curry-Howard correspondence with typed lambda calculus
DM10|type theory|foundational alternative to set theory; terms carry types; prevents paradoxes by stratification; simple type theory (Church), Martin-Löf dependent type theory, homotopy type theory (HoTT)
DM11|many-valued logic|logics with more than two truth values; Łukasiewicz (3-valued, n-valued, infinite-valued), Kleene (strong/weak), fuzzy logic (truth in [0,1]); Post logics
DM12|category-theoretic logic|categorical semantics for logic; topoi as generalized models; internal logic of a topos is intuitionistic; subobject classifier; adjunctions model quantifiers; Lawvere-Tierney topologies
DM13|metalogic|study of properties of logical systems themselves: soundness, completeness, decidability, compactness, expressiveness, categoricity; theorems about logics rather than within logics

# propositional_logic(id|name|symbol|type|definition|truth_table_or_rule|notes)
PL1|proposition|p, q, r, ...|atomic|declarative sentence that is either true or false; no internal structure in propositional logic|truth value: T or F|propositional variables; also called sentence letters or atoms
PL2|negation|¬|unary connective|reversal of truth value|¬T = F; ¬F = T|also written ~, !, NOT; self-inverse: ¬¬p ≡ p (classical)
PL3|conjunction|∧|binary connective|true iff both operands true|T∧T=T; T∧F=F; F∧T=F; F∧F=F|also written &, ·, AND; commutative, associative, idempotent
PL4|disjunction|∨|binary connective|true iff at least one operand true (inclusive or)|T∨T=T; T∨F=T; F∨T=T; F∨F=F|also written +, OR; commutative, associative, idempotent
PL5|material conditional (implication)|→|binary connective|false only when antecedent true and consequent false|T→T=T; T→F=F; F→T=T; F→F=T|also written ⊃, ⇒; NOT equivalent to causal or counterfactual; F→anything = T (paradoxes of material implication); equivalent to ¬p ∨ q
PL6|biconditional|↔|binary connective|true iff both operands have same truth value|T↔T=T; T↔F=F; F↔T=F; F↔F=T|also written ≡, ⇔, iff; equivalent to (p→q) ∧ (q→p); XNOR
PL7|exclusive or|⊕|binary connective|true iff exactly one operand true|T⊕T=F; T⊕F=T; F⊕T=T; F⊕F=F|also written XOR; equivalent to (p∨q) ∧ ¬(p∧q); equivalent to ¬(p↔q); forms abelian group on {T,F}
PL8|NAND (Sheffer stroke)|↑ or \||binary connective|false only when both operands true; negation of conjunction|T↑T=F; T↑F=T; F↑T=T; F↑F=T|functionally complete alone: every truth function expressible using only NAND; ¬p ≡ p↑p; p∧q ≡ (p↑q)↑(p↑q)
PL9|NOR (Peirce arrow)|↓|binary connective|true only when both operands false; negation of disjunction|T↓T=F; T↓F=F; F↓T=F; F↓F=T|functionally complete alone; dual of NAND; ¬p ≡ p↓p; p∨q ≡ (p↓q)↓(p↓q)
PL10|tautology|⊤|constant|proposition that is true under every valuation|always T|also called logical truth; example: p ∨ ¬p (LEM); valid formula
PL11|contradiction|⊥|constant|proposition that is false under every valuation|always F|also called absurdity; example: p ∧ ¬p; unsatisfiable formula
PL12|contingency|—|classification|proposition that is true under some valuations and false under others|mixed T/F|most propositions are contingencies; neither tautology nor contradiction
PL13|logical equivalence|≡|metalogical relation|two formulas have same truth value under every valuation|p ≡ q iff (p ↔ q) is a tautology|notation: ≡ is metalogical (about formulas); ↔ is object-language connective
PL14|logical consequence (entailment)|⊨|semantic relation|q is a logical consequence of Γ (a set of premises) iff every valuation making all premises in Γ true also makes q true|Γ ⊨ q|semantic notion; corresponds to syntactic derivability (⊢) in sound and complete systems
PL15|functional completeness|—|property|a set of connectives is functionally complete iff every truth function can be expressed using only connectives from that set|—|complete sets: {¬, ∧}, {¬, ∨}, {¬, →}, {↑} alone, {↓} alone; {∧, ∨} is NOT complete (cannot express negation); Post's characterization: 5 closure properties determine completeness

# predicate_logic(id|name|symbol|type|definition|scope|notes)
FO1|individual variable|x, y, z, ...|term|ranges over elements of the domain of discourse|bound by quantifiers or free|free variables: formula is open (not a sentence); bound: closed by quantifier
FO2|individual constant|a, b, c, ...|term|denotes a specific fixed element of the domain|global (refers to same element in all contexts within a model)|interpreted as elements of domain D in a structure
FO3|predicate (relation symbol)|P, Q, R, ...|non-logical symbol|n-ary relation on the domain; P(x₁,...,xₙ) is atomic formula; interpreted as subset of Dⁿ|—|arity determines number of arguments; unary predicate = property; binary = relation; P(a) is ground atomic formula
FO4|function symbol|f, g, h, ...|non-logical symbol|maps n elements of domain to one element; f(x₁,...,xₙ) is a term (not a formula)|—|0-ary function = constant; successor function s(x) in Peano arithmetic; composition of functions produces terms
FO5|equality|=|logical symbol (in FOL with equality)|identity relation; x = y iff x and y denote the same element of the domain|—|reflexive, symmetric, transitive; substitutivity: x = y → (φ(x) ↔ φ(y)); most standard presentations of FOL include equality
FO6|universal quantifier|∀|quantifier|∀x φ(x): φ holds for every element in the domain|binds variable x in φ|∀x P(x) = conjunction over domain (if domain finite: P(a₁) ∧ P(a₂) ∧ ... ∧ P(aₙ)); over infinite domain: not equivalent to any finite conjunction
FO7|existential quantifier|∃|quantifier|∃x φ(x): there exists at least one element in the domain for which φ holds|binds variable x in φ|∃x P(x) = disjunction over domain (if finite); definable from ∀: ∃x φ(x) ≡ ¬∀x ¬φ(x) (classical); in intuitionistic logic: existence requires witness
FO8|unique existential quantifier|∃!|quantifier (definable)|∃!x φ(x): there exists exactly one element satisfying φ|—|∃!x φ(x) ≡ ∃x (φ(x) ∧ ∀y (φ(y) → y = x)); definable in FOL with equality; not primitive
FO9|structure (model)|M = (D, I)|semantic|domain D (non-empty set) + interpretation I mapping constants to elements, function symbols to functions, predicate symbols to relations|—|also called interpretation or L-structure for language L; truth is defined relative to a structure and variable assignment
FO10|satisfaction|M ⊨ φ[s]|semantic relation|structure M satisfies formula φ under assignment s iff φ evaluates to true in M when variables assigned by s|—|recursive definition following structure of φ: atomic (check interpretation), ¬ (negate), ∧ (both), ∨ (either), → (conditional), ∀ (all d in D), ∃ (some d in D)
FO11|validity|⊨ φ|semantic property|φ is valid iff M ⊨ φ for every structure M and every assignment|—|also called logically valid; tautologies of FOL; examples: ∀x (P(x) → P(x)); ∀x x = x
FO12|satisfiability|—|semantic property|φ is satisfiable iff there exists some structure M and assignment s such that M ⊨ φ[s]|—|φ is satisfiable iff ¬φ is not valid; connection: Γ ⊨ φ iff Γ ∪ {¬φ} is unsatisfiable
FO13|prenex normal form|—|normal form|formula equivalent where all quantifiers are at the front (prefix) followed by a quantifier-free matrix|—|every FOL formula has a logically equivalent prenex form (using classical equivalences for quantifier movement); quantifier prefix classifies complexity (Σₙ, Πₙ hierarchy)
FO14|Skolem normal form|—|normal form|prenex formula with all existential quantifiers eliminated by introducing Skolem functions; resulting formula is universally quantified; equisatisfiable (not equivalent) to original|—|∃y ∀x P(x,y) → ∀x P(x,c) (Skolem constant); ∀x ∃y P(x,y) → ∀x P(x,f(x)) (Skolem function); used in resolution theorem proving
FO15|Herbrand universe|—|semantic construction|set of all ground terms (variable-free terms) constructible from constants and function symbols in the language; Herbrand structure: domain is Herbrand universe; terms interpreted as themselves|—|Herbrand's theorem: a set of clauses is unsatisfiable iff a finite set of ground instances is propositionally unsatisfiable; basis of automated theorem proving
FO16|substitution|φ[t/x]|syntactic operation|replace all free occurrences of variable x in φ with term t; must avoid variable capture (t must be free for x in φ)|—|if t contains variables that would become bound in φ, rename bound variables first (alpha-conversion); fundamental operation in proof theory
FO17|bound variable renaming (alpha-conversion)|—|syntactic equivalence|renaming of bound variables preserves meaning; ∀x P(x) ≡ ∀y P(y); formulas that differ only in bound variable names are alpha-equivalent|—|convention: choose variable names to avoid clash; essential for correct substitution

# set_theory(id|name|symbol|definition|axiom_or_theorem|notes)
ST1|membership|∈|fundamental relation: x ∈ A iff x is an element of set A|primitive (undefined in ZFC; axiomatized)|only primitive relation in set theory; all other concepts defined from ∈
ST2|empty set|∅ or {}|set with no elements; ∀x (x ∉ ∅)|axiom of empty set (or derived from separation)|unique; subset of every set; cardinality 0
ST3|subset|⊆|A ⊆ B iff ∀x (x ∈ A → x ∈ B)|definition|reflexive (A ⊆ A); transitive; antisymmetric with ⊇ (gives partial order); proper subset: A ⊂ B iff A ⊆ B and A ≠ B
ST4|power set|℘(A) or 2^A|set of all subsets of A; ℘(A) = {B : B ⊆ A}|axiom of power set|if |A| = n then |℘(A)| = 2ⁿ; Cantor's theorem: |℘(A)| > |A| for all A (including infinite)
ST5|union|A ∪ B|{x : x ∈ A ∨ x ∈ B}|axiom of union (generalized: ∪𝒞 for family 𝒞)|commutative, associative, idempotent; A ∪ ∅ = A; A ∪ U = U
ST6|intersection|A ∩ B|{x : x ∈ A ∧ x ∈ B}|defined from separation|commutative, associative, idempotent; A ∩ ∅ = ∅; A ∩ U = A
ST7|complement|A^c or A'|{x ∈ U : x ∉ A} (relative to universe U)|defined from separation|A ∪ A^c = U; A ∩ A^c = ∅; (A^c)^c = A; De Morgan: (A ∪ B)^c = A^c ∩ B^c
ST8|set difference|A \ B or A − B|{x : x ∈ A ∧ x ∉ B}|defined from separation|A \ B = A ∩ B^c; not commutative; A \ ∅ = A; A \ A = ∅
ST9|symmetric difference|A △ B|{x : (x ∈ A ∧ x ∉ B) ∨ (x ∈ B ∧ x ∉ A)}|defined|(A ∪ B) \ (A ∩ B); commutative; associative; A △ ∅ = A; A △ A = ∅; forms abelian group; corresponds to XOR
ST10|Cartesian product|A × B|{(a, b) : a ∈ A ∧ b ∈ B}|defined (Kuratowski pair: (a,b) = {{a}, {a,b}})|not commutative (unless A = B); |A × B| = |A| · |B|; n-ary product: A₁ × ... × Aₙ
ST11|axiom of extensionality|—|∀A ∀B (∀x (x ∈ A ↔ x ∈ B) → A = B)|ZFC axiom|sets are determined entirely by their elements; no intensional distinction
ST12|axiom of separation (comprehension)|—|∀A ∃B ∀x (x ∈ B ↔ (x ∈ A ∧ φ(x)))|ZFC axiom schema (one instance per formula φ)|restricted comprehension: B must be subset of existing set A; prevents Russell's paradox (unrestricted comprehension is contradictory)
ST13|axiom of replacement|—|if F is a definable function and A is a set, then {F(x) : x ∈ A} is a set|ZFC axiom schema|image of a set under a definable function is a set; stronger than separation; needed for transfinite recursion
ST14|axiom of infinity|—|there exists an inductive set (set containing ∅ and closed under successor: x ↦ x ∪ {x})|ZFC axiom|guarantees existence of infinite set; the inductive set is (a superset of) ω, the set of natural numbers; without this axiom, all provably existing sets are finite
ST15|axiom of choice (AC)|—|for every collection of non-empty sets, there exists a choice function selecting one element from each|ZFC axiom (independent of ZF)|equivalent to: Zorn's lemma, well-ordering theorem, every vector space has a basis, Tychonoff's theorem; independent of ZF (Gödel 1938: consistent; Cohen 1963: negation consistent); non-constructive
ST16|axiom of regularity (foundation)|—|every non-empty set A contains an element disjoint from A; equivalently: no infinite descending ∈-chain|ZFC axiom|prevents x ∈ x; implies well-foundedness of ∈-relation; rules out pathological sets; not needed for most mathematics but simplifies set-theoretic reasoning

# relations(id|name|definition|properties|notation|examples)
RL1|binary relation on A|subset of A × A; R ⊆ A × A; xRy iff (x,y) ∈ R|—|R, ≤, ∼, ≡|R = {(1,2), (2,3)} on {1,2,3}
RL2|reflexive|∀x ∈ A: xRx|every element related to itself|—|=, ≤, ≥, ⊆, divides
RL3|irreflexive|∀x ∈ A: ¬(xRx)|no element related to itself|—|<, >, ≠, proper subset ⊂
RL4|symmetric|∀x,y: xRy → yRx|direction doesn't matter|—|=, ≠, "is sibling of", ≡ (equivalence)
RL5|antisymmetric|∀x,y: (xRy ∧ yRx) → x = y|mutual relation implies identity|—|≤, ≥, ⊆, divides (on positive integers)
RL6|asymmetric|∀x,y: xRy → ¬(yRx)|one-way only (implies irreflexive)|—|<, >, proper subset ⊂
RL7|transitive|∀x,y,z: (xRy ∧ yRz) → xRz|relation chains|—|=, <, ≤, ⊆, divides, ancestor-of
RL8|equivalence relation|reflexive + symmetric + transitive|partitions domain into equivalence classes; A/∼ = quotient set|∼ or ≡|equality, congruence mod n, isomorphism, logical equivalence
RL9|partial order|reflexive + antisymmetric + transitive|(A, ≤) = partially ordered set (poset); not all elements comparable|≤ or ⊑|⊆ on ℘(A), ≤ on ℝ, divides on ℤ⁺, prefix ordering on strings
RL10|strict partial order|irreflexive + asymmetric + transitive|derived from partial order: x < y iff x ≤ y ∧ x ≠ y|<|< on ℝ, ⊂ on ℘(A)
RL11|total (linear) order|partial order where ∀x,y: xRy ∨ yRx ∨ x = y|all elements comparable; chain|≤|≤ on ℝ, ≤ on ℤ, lexicographic order on strings
RL12|well-order|total order where every non-empty subset has a least element|foundation for transfinite induction; every well-order is total; ≤ on ℕ is a well-order; ≤ on ℤ is NOT (no minimum)|—|ℕ with usual ≤; ordinal numbers; by AC every set can be well-ordered
RL13|equivalence class|[a]_∼ = {x ∈ A : x ∼ a}|the set of all elements equivalent to a; equivalence classes partition A; [a] ∩ [b] = ∅ or [a] = [b]|[a] or ā|[0]_mod3 = {...,−6,−3,0,3,6,...}; [triangle]_similarity = all similar triangles

# functions(id|name|definition|notation|properties|examples)
FN1|function (total)|relation f ⊆ A × B such that ∀a ∈ A ∃!b ∈ B: (a,b) ∈ f; each input maps to exactly one output|f: A → B; f(a) = b|A = domain; B = codomain; f(A) = range (image); range ⊆ codomain|f(x) = x², f: ℝ → ℝ
FN2|injective (one-to-one)|f(a₁) = f(a₂) → a₁ = a₂; distinct inputs produce distinct outputs|f: A ↣ B|preserves distinctness; left-cancellable; has left inverse iff injective (given AC for infinite)|f(x) = 2x; f(x) = eˣ
FN3|surjective (onto)|∀b ∈ B ∃a ∈ A: f(a) = b; every element of codomain is hit|f: A ↠ B|range = codomain; right-cancellable; has right inverse (given AC)|f: ℝ → ℝ, f(x) = x³; f: ℤ → ℤ/nℤ (mod n)
FN4|bijective|injective and surjective; one-to-one correspondence|f: A ↔ B or f: A ≅ B|invertible; f⁻¹ exists; |A| = |B| iff bijection exists (defines cardinality for finite; Cantor's definition for infinite)|f(x) = 2x+1 on ℤ; identity function
FN5|composition|given f: A → B and g: B → C, g ∘ f: A → C defined by (g ∘ f)(a) = g(f(a))|g ∘ f|associative: h ∘ (g ∘ f) = (h ∘ g) ∘ f; not commutative; identity: id_A ∘ f = f = f ∘ id_B|sin ∘ cos; square ∘ successor
FN6|inverse function|if f: A → B is bijective, f⁻¹: B → A where f⁻¹(b) = a iff f(a) = b|f⁻¹|f⁻¹ ∘ f = id_A; f ∘ f⁻¹ = id_B; (g ∘ f)⁻¹ = f⁻¹ ∘ g⁻¹|exp⁻¹ = ln; rotation inverse = rotation by negative angle
FN7|partial function|f: A ⇀ B; defined on subset dom(f) ⊆ A; not every element of A need have an image|f: A ⇀ B|central in computability: Turing machines compute partial functions; total if dom(f) = A|division (undefined at 0); Turing machine computation (may not halt)
FN8|characteristic function (indicator)|χ_A: U → {0,1}; χ_A(x) = 1 if x ∈ A, 0 if x ∉ A|χ_A or 1_A|bijection between subsets of U and functions U → {0,1}; |℘(U)| = 2^|U||χ_{evens}(4) = 1; χ_{evens}(3) = 0

# proof_theory(id|name|type|components|key_properties|examples_or_rules)
PT1|Hilbert-style system|axiomatic|axiom schemas (many) + single inference rule (modus ponens, occasionally generalization)|compact axiom set; proofs often long and unintuitive; historically important; metamathematically convenient|axioms for propositional: (φ→(ψ→φ)), ((φ→(ψ→χ))→((φ→ψ)→(φ→χ))), ((¬ψ→¬φ)→(φ→ψ)); inference: from φ and φ→ψ derive ψ
PT2|natural deduction (Gentzen)|inference rules|introduction and elimination rules for each connective; no axioms; assumptions discharged by rules|corresponds closely to informal mathematical reasoning; Curry-Howard: proofs = lambda terms; normal form proofs correspond to cut-free sequent proofs|∧-intro: from φ and ψ derive φ∧ψ; ∧-elim: from φ∧ψ derive φ (or ψ); →-intro: assume φ, derive ψ, discharge assumption, conclude φ→ψ; →-elim: from φ and φ→ψ derive ψ (MP)
PT3|sequent calculus (Gentzen LK/LJ)|sequents|Γ ⊢ Δ (classically: sequent = "from Γ infer Δ"); left and right rules for each connective; structural rules (weakening, contraction, exchange, cut)|cut-elimination theorem (Hauptsatz): every proof in LK/LJ can be transformed to cut-free proof; subformula property of cut-free proofs (every formula in proof is subformula of conclusion); decidability proofs|LK: classical (multiple conclusions); LJ: intuitionistic (single conclusion on right); cut rule: from Γ⊢Δ,φ and φ,Σ⊢Π derive Γ,Σ⊢Δ,Π
PT4|resolution|refutation method|clausal form (CNF); single rule: resolve complementary literals; refutation-complete for propositional and FOL (with unification)|basis of automated theorem proving; to prove Γ ⊨ φ: negate φ, convert Γ∪{¬φ} to CNF, resolve until empty clause (⊥); if empty clause derived → φ is consequence|from {A, B} and {¬A, C} resolve on A: derive {B, C}; ground resolution + factoring = complete for propositional; first-order: add unification (Robinson 1965)
PT5|formal proof (derivation)|syntactic object|finite sequence of formulas, each either an axiom or follows from previous by inference rule|proof of φ from Γ: Γ ⊢ φ; theorem: ⊢ φ (proof from empty premises)|Γ ⊢ φ iff there exists a derivation; syntactic analogue of semantic entailment Γ ⊨ φ
PT6|deduction theorem|metatheorem|if Γ ∪ {φ} ⊢ ψ then Γ ⊢ φ → ψ (and converse)|connects assumption-based reasoning to implication; holds for most standard systems; proof by induction on derivation length|allows moving between "assuming φ, derive ψ" and "derive φ → ψ" without assumption
PT7|cut elimination (Hauptsatz)|metatheorem|every proof in sequent calculus can be transformed into a cut-free proof|subformula property: in cut-free proof, every formula is subformula of the end-sequent; implies consistency (cannot derive ⊥ from no premises: no subformula of ⊥ is ⊥ except ⊥ itself, and no rule introduces ⊥); may increase proof length super-exponentially|Gentzen 1935 (LK, LJ); extended by many: Girard (linear logic), Tait (classical logic)
PT8|Curry-Howard correspondence|isomorphism|proofs ↔ programs; propositions ↔ types; proof normalization ↔ program execution (β-reduction)|intuitionistic natural deduction ≅ simply typed lambda calculus; →-intro = lambda abstraction; →-elim = function application; proof of A→B is function from proofs of A to proofs of B|extends: sequent calculus ↔ abstract machines; classical logic ↔ control operators (callcc); linear logic ↔ resource-aware computation; dependent types ↔ Martin-Löf type theory

# model_theory(id|name|type|definition|significance|key_results)
MT1|structure (L-structure)|semantic|M = (D, I) where D is non-empty set (domain/universe) and I interprets each symbol of language L: constants → elements of D, n-ary functions → functions Dⁿ→D, n-ary predicates → subsets of Dⁿ|provides meaning to formal language; truth is relative to structure|examples: (ℕ, 0, S, +, ·) for arithmetic; (ℝ, 0, 1, +, ·, <) for ordered fields
MT2|elementary equivalence|semantic relation|M ≡ N iff M and N satisfy exactly the same first-order sentences; M ≡ N does not imply M ≅ N (isomorphism)|structures can be "indistinguishable" by FOL yet structurally different; FOL cannot distinguish countable from uncountable models of certain theories|ℚ ≡ ℝ as dense linear orders without endpoints (Cantor's theorem on DLO); any two algebraically closed fields of same characteristic and same uncountable cardinality are isomorphic (Steinitz)
MT3|elementary substructure|semantic relation|M ≼ N iff M ⊆ N (substructure) and for every sentence φ with parameters from M: M ⊨ φ iff N ⊨ φ|stronger than substructure (preserves all first-order properties, not just quantifier-free)|Tarski-Vaught test: M ⊆ N is elementary iff for every formula φ(x,ā) with parameters ā from M: if N ⊨ ∃x φ(x,ā) then there exists b ∈ M with N ⊨ φ(b,ā)
MT4|compactness theorem|fundamental theorem|a set of first-order sentences Γ has a model iff every finite subset of Γ has a model|equivalent to: ultrafilter lemma (weak AC); consequence of completeness (Gödel) or ultraproduct construction; does NOT hold for second-order logic or many infinitary logics|applications: non-standard models (non-standard analysis: *ℝ); every infinite graph k-colorable iff every finite subgraph is; transfer principle for hyperreals
MT5|Löwenheim-Skolem theorem (downward)|fundamental theorem|if Γ has a model of cardinality κ ≥ |L| (where |L| = cardinality of the language), then Γ has a model of every cardinality λ with |L| ≤ λ ≤ κ|in particular: if countable theory has infinite model, it has countable model; Skolem's paradox: ZFC (if consistent) has countable model yet proves uncountable sets exist (resolved: "uncountable" is relative to model)|proof uses Skolem functions and downward closure
MT6|Löwenheim-Skolem theorem (upward)|fundamental theorem|if Γ has an infinite model, then Γ has models of arbitrarily large cardinality|no first-order theory with infinite models has a unique model up to isomorphism (FOL cannot pin down cardinality)|consequence of compactness: add κ-many new constant symbols + axioms saying they're distinct; every finite subset satisfiable → whole set satisfiable by compactness
MT7|categoricity|semantic property|a theory T is κ-categorical if all models of T of cardinality κ are isomorphic|Morley's theorem: if countable complete theory is categorical in some uncountable κ, then categorical in all uncountable κ; ω-categoricity: Ryll-Nardzewski theorem (equivalent to finitely many n-types for each n)|DLO (dense linear order without endpoints) is ω-categorical (all countable DLOs ≅ ℚ) but not uncountably categorical (ℚ ≇ ℝ as DLOs, same theory)
MT8|type (complete type)|semantic|a complete n-type over A is a maximal consistent set of formulas in n free variables with parameters from A|types describe "what an element looks like" from the perspective of FOL; Stone space of types is compact Hausdorff; stability theory classifies theories by their type-counting behavior|isolated type: realized in every model of T; non-isolated: may be omitted; omitting types theorem: countable complete T, non-isolated type → model omitting it exists
MT9|ultraproduct|construction|given structures (Mᵢ)ᵢ∈I and ultrafilter U on I: ∏ᵢMᵢ/U is the ultraproduct; elements are equivalence classes of sequences under U-agreement|Łoś's theorem: ∏Mᵢ/U ⊨ φ iff {i : Mᵢ ⊨ φ} ∈ U; reproves compactness theorem; constructs non-standard models; powerful tool in model theory and algebra|ultrapower: all Mᵢ = M; M* = Mᴵ/U; elementary extension of M (M ≼ M*); non-standard analysis: *ℝ is ultrapower of ℝ
MT10|definability|semantic|a subset S ⊆ Dⁿ is definable in structure M iff there exists a formula φ(x₁,...,xₙ) (possibly with parameters from D) such that S = {ā ∈ Dⁿ : M ⊨ φ(ā)}|Beth's theorem: implicit definability implies explicit definability; Svenonius theorem; Craig interpolation implies Beth's theorem|in (ℝ, +, ·, <): ℚ is not definable (follows from quantifier elimination of real closed fields); in (ℕ, +, ·): every recursive set is definable (but not uniformly)

# computability(id|name|type|definition|key_result|significance)
CO1|Turing machine|computational model|abstract machine: infinite tape + read/write head + finite state control + transition function; input on tape; halts in accept or reject state, or runs forever|Church-Turing thesis: any effectively computable function is Turing-computable; multiple equivalent formulations (lambda calculus, recursive functions, register machines)|defines the boundary of computability; universal model; all standard programming languages are Turing-equivalent
CO2|decidable (recursive) set|computability class|set A is decidable iff there exists a Turing machine that halts on every input and correctly accepts elements of A and rejects non-elements|A is decidable iff both A and Aᶜ are recursively enumerable|propositional logic validity: decidable (truth tables); FOL validity: undecidable (Church 1936); Presburger arithmetic (ℕ,+): decidable; Peano arithmetic (ℕ,+,·): undecidable
CO3|semi-decidable (recursively enumerable) set|computability class|set A is r.e. iff there exists a Turing machine that halts and accepts on elements of A (may run forever on non-elements)|A is r.e. iff A is the domain of some partial recursive function; A is r.e. iff A is the range of some total recursive function (or empty)|FOL theorems: r.e. (enumerate all proofs); FOL non-theorems: NOT r.e. (consequence of undecidability); halting set K = {(M,x) : M halts on x}: r.e. but not decidable
CO4|halting problem|undecidable problem|given Turing machine M and input x, determine whether M halts on x|undecidable (Turing 1936); proof by diagonalization: assume decider H exists → construct machine that contradicts H on itself|first and most fundamental undecidability result; reduces to many other problems (reduction: A ≤ₘ B means decidability of B implies decidability of A)
CO5|many-one reducibility|comparison|A ≤ₘ B iff there exists computable f such that x ∈ A iff f(x) ∈ B|if A ≤ₘ B and B is decidable then A is decidable; contrapositive: if A undecidable and A ≤ₘ B then B undecidable|standard tool for proving undecidability; reduces known undecidable problem to target problem
CO6|recursive function (total)|computability class|function f: ℕⁿ → ℕ computable by a Turing machine that halts on every input|equivalently: built from zero, successor, projection by composition, primitive recursion, and minimization (where minimization always terminates)|addition, multiplication, exponentiation, primality testing are recursive; Ackermann function: total recursive but not primitive recursive
CO7|primitive recursive function|computability class|function built from zero, successor, projection by composition and primitive recursion (no unbounded search)|every primitive recursive function is total; proper subset of total recursive functions (Ackermann is not PR); all common arithmetic functions are PR|addition, multiplication, exponentiation, factorial, predecessor, bounded quantification, bounded minimization are all PR; PR functions are provably total in Peano arithmetic
CO8|Church-Turing thesis|thesis (not theorem)|any function computable by an effective procedure (algorithm) is computable by a Turing machine|not provable (philosophical claim about informal notion of "computable"); strongly supported by equivalence of all proposed models (TM, lambda calculus, recursive functions, register machines, cellular automata)|provides rigorous foundation for statements like "X is not computable" — without this thesis, undecidability results would be relative to a particular formalism

# modal_logic(id|name|symbol_or_system|type|semantics|axioms|characterization)
ML1|necessity|□|modal operator|Kripke: □φ is true at world w iff φ is true at all worlds accessible from w|—|"φ must be the case"; "it is necessarily true that φ"
ML2|possibility|◇|modal operator|Kripke: ◇φ is true at world w iff φ is true at some world accessible from w|◇φ ≡ ¬□¬φ (dual)|"φ might be the case"; "it is possibly true that φ"
ML3|Kripke frame|F = (W, R)|semantic structure|W = set of possible worlds; R ⊆ W × W = accessibility relation; model: M = (W, R, V) with valuation V: Prop → ℘(W)|—|different properties of R yield different logics: reflexive → T; transitive → K4; reflexive+transitive → S4; equivalence → S5
ML4|system K|K|minimal normal modal logic|all Kripke frames (no constraint on R)|K: □(φ→ψ) → (□φ→□ψ) (distribution); inference: from φ derive □φ (necessitation)|weakest normal modal logic; other systems add axioms constraining R
ML5|system T|T|modal logic|reflexive frames (R is reflexive: every world accesses itself)|T: □φ → φ (reflexivity: what is necessary is actual)|"truth" axiom; necessity implies truth; knowledge logic (what is known is true)
ML6|system S4|S4|modal logic|preorder frames (R is reflexive + transitive)|T + 4: □φ → □□φ (transitivity: necessity is necessarily necessary)|topological semantics: □ = interior operator; S4 = logic of topological spaces; provability interpretation (partial)
ML7|system S5|S5|modal logic|equivalence relation frames (R is reflexive + symmetric + transitive)|T + 5: ◇φ → □◇φ (if possible, necessarily possible)|all worlds access all worlds (single equivalence class = "everything is accessible"); simplest modal logic; iterated modalities collapse (□□φ ≡ □φ; ◇□φ ≡ □φ); logical possibility
ML8|system GL (Gödel-Löb)|GL|provability logic|finite, transitive, irreflexive frames (converse well-founded)|K + GL: □(□φ→φ) → □φ (Löb's axiom)|soundness and completeness for Peano arithmetic provability: □φ interpreted as "PA proves φ"; Solovay's completeness theorem (1976)
ML9|epistemic logic|—|applied modal logic|Kripke: worlds = epistemic alternatives; K_a φ: agent a knows φ; R = indistinguishability|K_a φ → φ (truth); K_a φ → K_a K_a φ (positive introspection); ¬K_a φ → K_a ¬K_a φ (negative introspection, S5)|multi-agent: K_a, K_b; common knowledge: C_G φ = everyone knows that everyone knows that ... ad infinitum; Aumann's agreement theorem
ML10|temporal logic (LTL)|—|applied modal logic|Kripke: worlds = time points; R = temporal succession|G φ (always in future); F φ (eventually); X φ (next); φ U ψ (φ until ψ)|linear time: total order; branching time (CTL): tree; used in program verification; model checking is decidable

# type_theory(id|name|type|definition|key_features|significance)
TT1|simple type theory (Church)|foundational|types built from base types (ι: individuals, o: propositions) by function type constructor (→); terms are typed lambda calculus|prevents Russell's paradox by type stratification; higher-order logic (quantify over predicates of any finite type); decidable fragments|Church 1940; basis of HOL proof assistants; standard semantics: full type hierarchy over set-theoretic domains
TT2|Martin-Löf type theory (MLTT)|foundational|dependent types: type of output depends on value of input; Π-types (dependent functions), Σ-types (dependent pairs), identity types, inductive types|constructive: proofs are programs (extended Curry-Howard); no excluded middle as axiom; univalence (HoTT); basis of Coq, Agda, Lean proof assistants|propositions-as-types; universes of types (Type₀ : Type₁ : Type₂ ...); intensional vs extensional identity; eliminates need for separate set theory foundation
TT3|homotopy type theory (HoTT)|foundational extension|MLTT + univalence axiom (equivalent types are equal) + higher inductive types|identity types have non-trivial structure (paths, higher paths); types are spaces; equality is path; mathematics becomes synthetic homotopy theory|Voevodsky 2006+; HoTT book 2013; unifies logic, type theory, and homotopy theory; computational interpretation via cubical type theory
TT4|polymorphic type theory (System F)|typed lambda calculus|universal quantification over types: Λα. t : ∀α. T; allows generic programming|type abstraction and application; parametric polymorphism; Reynolds's abstraction theorem; strongly normalizing (all programs terminate)|Girard 1972, Reynolds 1974; basis of ML and Haskell type systems; proves consistency of second-order arithmetic; System Fω adds type operators

# category_logic(id|name|type|definition|logical_significance|key_result)
CL1|topos|category|category with finite limits, exponentials, and subobject classifier Ω|internal logic of every topos is intuitionistic higher-order logic; Set is the classical topos; sheaf topoi provide models for intuitionistic set theory|Lawvere-Tierney: topoi generalize both set theory and topology; forcing in set theory = sheaf construction on topos
CL2|subobject classifier|categorical structure|object Ω with morphism true: 1 → Ω such that every monic (subobject) is a pullback of true along a unique characteristic morphism|generalizes characteristic function χ_A: X → {0,1} to non-Boolean settings; in Set: Ω = {0,1}; in sheaf topos: Ω = sheaf of open sets (multi-valued truth)|Ω determines the internal logic: if Ω is Boolean algebra → classical logic; if Heyting algebra → intuitionistic logic; Ω carries the truth values of the topos
CL3|adjunction (quantifier interpretation)|categorical structure|left adjoint to pullback functor = ∃ (existential quantification); right adjoint = ∀ (universal quantification); ∃_f ⊣ f* ⊣ ∀_f|quantifiers arise naturally from adjunctions between slice categories; no ad hoc axioms for quantifiers needed|Lawvere 1969; hyperdoctrines; unifies logical quantifiers with mathematical operations (e.g., direct/inverse image of sheaves)
CL4|Curry-Howard-Lambek correspondence|three-way isomorphism|proofs ↔ programs ↔ morphisms in cartesian closed categories; propositions ↔ types ↔ objects; logical rules ↔ typing rules ↔ categorical constructions|unifies proof theory, type theory, and category theory; conjunction = product; implication = exponential; disjunction = coproduct; absurdity = initial object|CCC (cartesian closed category) provides denotational semantics for typed lambda calculus; extends to topoi for higher-order logic

# paradoxes(id|name|type|statement|resolution|significance)
PX1|Russell's paradox|set-theoretic|let R = {x : x ∉ x}; is R ∈ R? if yes → R ∉ R; if no → R ∈ R; contradiction|ZFC: axiom of separation restricts comprehension (no unrestricted {x : φ(x)}); type theory: stratification prevents self-reference; NBG: proper classes (too big to be sets)|destroyed naive set theory (Frege's system); motivated axiomatic set theory and type theory; 1901
PX2|liar paradox|semantic|"This sentence is false." If true → false; if false → true|Tarski: truth predicate for language L cannot be defined in L (truth is always in metalanguage); dialetheism (Priest): accept true contradictions; hierarchical typing of truth predicates|motivates Tarski's undefinability theorem; Gödel's technique adapts this structure via arithmetization
PX3|Berry's paradox|semantic-definability|"the smallest positive integer not definable in fewer than twenty words" — this phrase defines the number in fewer than twenty words|informal notion of "definable in English" is not well-defined; formalized: definability in a formal language is well-defined and this paradox does not arise|illustrates dangers of mixing formal and informal languages; related to Kolmogorov complexity
PX4|Banach-Tarski paradox|set-theoretic (ZFC+AC)|a solid ball in ℝ³ can be decomposed into finitely many pieces (5 suffices) and reassembled into two balls identical to original|not a paradox of logic but of axiom of choice + non-measurable sets; pieces are not Lebesgue measurable; depends essentially on AC|demonstrates that AC implies existence of non-measurable sets; pieces cannot be constructed explicitly; motivates study of constructive mathematics and alternatives to AC
PX5|Skolem's paradox|model-theoretic|ZFC (if consistent) has a countable model (by downward Löwenheim-Skolem), yet ZFC proves existence of uncountable sets|not a genuine paradox: "uncountable" inside the model means "no bijection exists within the model"; the countable model lacks the bijection, so internally the set is uncountable|demonstrates that cardinality is not absolute but relative to the ambient model; illustrates limitation of FOL's expressive power
PX6|Curry's paradox|logical|in naive set theory or with unrestricted comprehension + contraction: any sentence is provable; uses self-referential conditional: "If this sentence is true, then φ" — for any φ|restricted comprehension (ZFC); restricted contraction (linear logic, substructural logics); careful handling of self-reference|pure logic version: no negation needed (unlike Russell's or liar's); shows inconsistency arises from self-reference + contraction, not negation; motivates substructural logics

# metalogic(id|name|type|statement|system|proof_method|significance)
MG1|soundness theorem (propositional)|metatheorem|if Γ ⊢ φ then Γ ⊨ φ; every provable formula is valid; no false formula is provable|propositional calculus; FOL|induction on proof length: show each axiom is valid and each rule preserves validity|minimum requirement for a useful logical system; ensures proof system doesn't prove falsehoods
MG2|completeness theorem (propositional)|metatheorem|if Γ ⊨ φ then Γ ⊢ φ; every valid formula is provable|propositional calculus|truth table method; or: show every consistent set of formulas is satisfiable (model existence)|proof system captures all semantic truths; decidability of propositional logic follows (finite truth table check)
MG3|Gödel's completeness theorem (FOL)|metatheorem|if Γ ⊨ φ then Γ ⊢ φ; first-order logic is complete|first-order predicate logic|Gödel 1930; Henkin's proof (1949): extend consistent set to maximally consistent + witness property → construct term model|most important theorem in mathematical logic; FOL is the "right" logic in the sense of being both complete and having useful expressive power; does NOT hold for second-order logic (full semantics)
MG4|compactness theorem (FOL)|metatheorem|Γ has a model iff every finite subset of Γ has a model|FOL|follows from completeness (proof is finite → uses finitely many premises); or ultraproduct proof (Łoś)|see MT4; consequence of completeness; powerful tool in model theory; fails for second-order logic, Lω₁ω, and most stronger logics
MG5|Gödel's first incompleteness theorem|metatheorem|any consistent, recursively axiomatizable theory T containing basic arithmetic is incomplete: there exists a sentence G such that T ⊬ G and T ⊬ ¬G|Peano arithmetic; any sufficiently strong consistent theory (Robinson's Q suffices)|arithmetization of syntax (Gödel numbering); construction of self-referential sentence G ≡ "G is not provable in T"; if T proves G → T proves falsehood → T inconsistent; if T proves ¬G → ω-inconsistent (or just incomplete if T is sound)|1931; most famous result in mathematical logic; true arithmetic is not recursively axiomatizable; no consistent computable extension of PA can be complete; G is true (in standard model) but unprovable
MG6|Gödel's second incompleteness theorem|metatheorem|if T is consistent and satisfies conditions of first theorem, then T cannot prove its own consistency: T ⊬ Con(T)|same as MG5|formalize the proof of first theorem within T; the formalized proof shows: if T proves Con(T) then T proves G; but T does not prove G (by first theorem); so T does not prove Con(T)|Hilbert's program (prove consistency of mathematics by finitary methods) is impossible for sufficiently strong theories; consistency must be proved in stronger system; every consistency proof requires resources beyond the system being proved consistent
MG7|Tarski's undefinability theorem|metatheorem|no sufficiently expressive consistent theory can define its own truth predicate; there is no formula True(x) in the language of arithmetic such that for every sentence φ: True(⌈φ⌉) ↔ φ|any theory interpreting arithmetic|diagonal lemma (fixed-point lemma): for any formula ψ(x) there exists sentence σ such that T ⊢ σ ↔ ψ(⌈σ⌉); apply to ψ(x) = ¬True(x) → liar-like contradiction|truth about natural numbers cannot be defined within arithmetic itself; truth is always one level up (in metalanguage); Tarski's hierarchy of metalanguages
MG8|Löwenheim-Skolem theorems|metatheorem|downward: see MT5; upward: see MT6|FOL|see MT5, MT6|FOL cannot fix the cardinality of infinite models; categoricity results require additional tools (second-order, infinitary, or categoricity in specific cardinalities)
MG9|Craig's interpolation theorem|metatheorem|if ⊨ φ → ψ (where φ and ψ share at least one predicate symbol), then there exists θ (the interpolant) in the common language of φ and ψ such that ⊨ φ → θ and ⊨ θ → ψ|FOL|proof via cut-elimination or model-theoretic methods|the "reason" connecting φ to ψ can be expressed in their shared vocabulary; implies Beth's definability theorem; important in database theory, verification
MG10|Lindström's theorem|metatheorem|first-order logic is the strongest logic satisfying both compactness and downward Löwenheim-Skolem|characterizes FOL among abstract logics (Lindström 1969)|abstract model theory; shows any proper extension of FOL (e.g., adding generalized quantifiers beyond ∃,∀ or infinitary features) must lose compactness or Löwenheim-Skolem|FOL occupies a unique position: maximum expressive power while retaining both compactness and Löwenheim-Skolem; justifies FOL's central role in logic
MG11|deduction theorem (FOL)|metatheorem|Γ ∪ {φ} ⊢ ψ iff Γ ⊢ φ → ψ|FOL (with standard axiomatizations)|induction on derivation; requires careful handling of generalization rule (∀-intro): restriction: variable in generalization must not be free in undischarged assumption φ|essential for natural reasoning; in some non-standard systems (e.g., with unrestricted generalization) the deduction theorem fails

# axiom_systems(id|name|type|language|axioms_summary|consistency|completeness|decidability|notes)
AX1|propositional calculus (classical)|logical|propositional connectives + variables|Hilbert: 3 axiom schemas + modus ponens; or natural deduction rules for ¬,∧,∨,→,↔|consistent (trivially: T is a model)|complete (soundness + completeness; every tautology provable)|decidable (truth tables: 2ⁿ rows for n variables)|functionally complete with {¬,∧} or {¬,∨} or {↑} alone
AX2|first-order logic (classical)|logical|propositional connectives + ∀,∃ + variables + predicate/function/constant symbols + equality|AX1 axioms + ∀-instantiation + ∀-generalization + equality axioms|consistent|complete (Gödel 1930)|undecidable (Church 1936; Turing 1936); semi-decidable (enumerate theorems)|most important formal logic; Lindström theorem: maximum expressiveness with compactness + LS
AX3|Peano arithmetic (PA)|mathematical|FOL + 0, S (successor), +, ·|1: ∀x ¬(S(x) = 0); 2: ∀x∀y (S(x) = S(y) → x = y); 3–4: recursive definitions of + and ·; 5: induction schema (for each formula)|consistent (if ℕ exists; not provable within PA by Gödel 2nd)|incomplete (Gödel 1st: true but unprovable sentences exist; e.g., Con(PA), Goodstein's theorem, Paris-Harrington)|undecidable (Church 1936; reduces from halting problem)|standard axiomatization of natural number arithmetic; all computable functions are representable
AX4|Robinson's Q|mathematical|same language as PA|PA axioms 1–4 + minimal axioms replacing induction: ∀x (x = 0 ∨ ∃y (x = S(y))); ∀x (x ≠ 0 → ∃y (x = S(y)))|consistent (if ℕ exists)|incomplete (satisfies Gödel's conditions: can represent all recursive functions)|undecidable (essentially undecidable: every consistent extension is undecidable)|weakest theory sufficient for Gödel's theorems; finitely axiomatizable (unlike PA which has axiom schema)
AX5|ZFC (Zermelo-Fraenkel with Choice)|set-theoretic foundation|FOL with ∈ as sole non-logical symbol|extensionality, empty set, pairing, union, power set, infinity, separation schema, replacement schema, regularity, choice|cannot prove own consistency (Gödel 2nd; if consistent)|incomplete (CH is independent: Gödel showed Con(ZFC) → Con(ZFC+CH); Cohen showed Con(ZFC) → Con(ZFC+¬CH))|undecidable (interprets PA)|standard foundation for mathematics; large cardinal axioms extend ZFC; forcing technique produces independence results
AX6|Presburger arithmetic|mathematical|FOL + 0, S, +|axioms for 0, S, + (no multiplication)|consistent|complete (every sentence or its negation provable; Presburger 1929)|decidable (but super-exponential: at least 2^2^cn complexity)|addition without multiplication is decidable and complete; adding multiplication (→ PA) makes it undecidable and incomplete; shows multiplication is the source of complexity in arithmetic
AX7|theory of real closed fields (RCF)|mathematical|FOL + 0, 1, +, ·, <|axioms of ordered field + every positive element has square root + every odd-degree polynomial has root|consistent (ℝ is a model)|complete (Tarski; quantifier elimination)|decidable (Tarski 1948; quantifier elimination yields decision procedure; doubly-exponential complexity; CAD algorithm: Collins 1975)|elementary geometry is decidable; unlike PA: multiplication does not add undecidability when combined with ordering and field axioms; key: no way to define ℤ within RCF
AX8|Heyting arithmetic (HA)|mathematical (intuitionistic)|same language as PA|same as PA but with intuitionistic logic (no LEM; no double negation elimination); induction schema retained|consistent|incomplete (same as PA + more: many classical theorems unprovable without LEM)|undecidable|every theorem of HA is a theorem of PA (but not vice versa); PA is conservative over HA for Π₂ sentences (Friedman's translation)
AX9|second-order arithmetic (Z₂)|mathematical|FOL + set variables + ∈ (for numbers-in-sets)|comprehension axioms for sets of natural numbers (full second-order: every formula defines a set); induction|consistent (if sufficient large cardinals)|incomplete (Gödel still applies)|undecidable|full Z₂: not completable (no effective axiomatization captures all consequences); subsystems (RCA₀, WKL₀, ACA₀, ATR₀, Π¹₁-CA₀) form the framework of reverse mathematics

# inference_rules(id|name|symbol|form|direction|system|notes)
IR1|modus ponens (→-elimination)|MP|from φ and φ → ψ, derive ψ|forward (from premises to conclusion)|all standard systems|most fundamental inference rule; sole rule in many Hilbert systems (with axiom schemas); sound: preserves truth
IR2|modus tollens|MT|from ¬ψ and φ → ψ, derive ¬φ|forward|derived in most systems|contrapositive of MP; derivable from MP + double negation elimination (classical); uses ¬
IR3|hypothetical syllogism|HS|from φ → ψ and ψ → χ, derive φ → χ|forward|derived|transitivity of implication; chaining conditionals
IR4|disjunctive syllogism|DS|from φ ∨ ψ and ¬φ, derive ψ|forward|derived (classical)|requires LEM or equivalent; in intuitionistic logic: not generally derivable without constructive elimination
IR5|conjunction introduction (∧-intro)|∧I|from φ and ψ, derive φ ∧ ψ|forward|natural deduction|pairs two proven statements
IR6|conjunction elimination (∧-elim)|∧E|from φ ∧ ψ, derive φ (or ψ)|forward|natural deduction|projects from pair; two forms: left and right
IR7|disjunction introduction (∨-intro)|∨I|from φ, derive φ ∨ ψ (for any ψ)|forward|natural deduction|weakening: adds unproven disjunct; constructively: must indicate which disjunct
IR8|disjunction elimination (∨-elim)|∨E|from φ ∨ ψ, φ → χ, and ψ → χ, derive χ|forward|natural deduction|proof by cases; constructive: both cases must produce witness
IR9|conditional introduction (→-intro)|→I|assume φ; derive ψ; discharge assumption; conclude φ → ψ|forward (discharges assumption)|natural deduction|Curry-Howard: lambda abstraction; deduction theorem is the metatheoretic version
IR10|negation introduction (¬-intro)|¬I|assume φ; derive ⊥; discharge assumption; conclude ¬φ|forward|natural deduction|proof by contradiction (weak form): assume φ, derive contradiction, conclude ¬φ; valid intuitionistically
IR11|negation elimination (¬-elim, ex falso)|EFQ|from ⊥, derive φ (anything)|forward|natural deduction; intuitionistic + classical|ex falso quodlibet: from contradiction anything follows; also called explosion; valid in both classical and intuitionistic logic
IR12|double negation elimination (DNE)|DNE|from ¬¬φ, derive φ|forward|classical only (not intuitionistic)|classical but NOT intuitionistically valid; equivalent to LEM (in intuitionistic logic + DNE → LEM); key dividing line between classical and constructive logic
IR13|universal generalization (∀-intro)|∀I|from φ(a) where a is arbitrary (not free in assumptions), derive ∀x φ(x)|forward|FOL natural deduction|restriction: a must not appear free in any undischarged assumption; ensures conclusion holds for all elements, not just the specific a
IR14|universal instantiation (∀-elim)|∀E|from ∀x φ(x), derive φ(t) for any term t free for x|forward|FOL natural deduction|substitute any term for quantified variable; t must be free for x in φ (no variable capture)
IR15|existential introduction (∃-intro)|∃I|from φ(t), derive ∃x φ(x)|forward|FOL natural deduction|witnesses existence by exhibiting a term t satisfying φ
IR16|existential elimination (∃-elim)|∃E|from ∃x φ(x); assume φ(a) for fresh a; derive ψ (where a not in ψ); conclude ψ|forward (discharges assumption)|FOL natural deduction|introduces temporary name for witness; name must not leak into conclusion; Curry-Howard: dependent sum elimination
IR17|reductio ad absurdum (RAA)|RAA|assume ¬φ; derive ⊥; discharge assumption; conclude φ|forward|classical natural deduction|proof by contradiction (strong form): assume ¬φ, derive ⊥, conclude φ; NOT valid intuitionistically (uses DNE implicitly); distinguish from ¬-intro which concludes ¬φ
IR18|resolution rule|Res|from clause {L₁,...,Lₘ, A} and clause {M₁,...,Mₙ, ¬A}, derive resolvent {L₁,...,Lₘ, M₁,...,Mₙ}|forward (refutation)|resolution calculus|resolve on complementary literal A/¬A; with factoring: refutation-complete for FOL; basis of Prolog, SAT solvers, automated theorem provers

# logical_identities(id|name|identity|category|notes)
LI1|double negation|¬¬p ≡ p|negation|classical only; intuitionistically: p → ¬¬p holds but ¬¬p → p does not
LI2|De Morgan (conjunction)|¬(p ∧ q) ≡ ¬p ∨ ¬q|De Morgan|dual: ¬(p ∨ q) ≡ ¬p ∧ ¬q; both classical and intuitionistic (for finite cases)
LI3|De Morgan (disjunction)|¬(p ∨ q) ≡ ¬p ∧ ¬q|De Morgan|both directions valid in intuitionistic logic
LI4|De Morgan (quantifier, universal)|¬∀x φ(x) ≡ ∃x ¬φ(x)|De Morgan (quantified)|classical only; intuitionistically: ∃x ¬φ(x) → ¬∀x φ(x) holds; converse requires LEM
LI5|De Morgan (quantifier, existential)|¬∃x φ(x) ≡ ∀x ¬φ(x)|De Morgan (quantified)|valid in both classical and intuitionistic logic (both directions)
LI6|contraposition|p → q ≡ ¬q → ¬p|conditional|classical; intuitionistically: p → q implies ¬q → ¬p but not converse
LI7|exportation (currying)|p ∧ q → r ≡ p → (q → r)|conditional|logical version of currying; valid in both classical and intuitionistic logic; Curry-Howard: uncurry/curry
LI8|distribution (∧ over ∨)|p ∧ (q ∨ r) ≡ (p ∧ q) ∨ (p ∧ r)|distribution|dual: p ∨ (q ∧ r) ≡ (p ∨ q) ∧ (p ∨ r); both valid classically and intuitionistically
LI9|absorption|p ∧ (p ∨ q) ≡ p; p ∨ (p ∧ q) ≡ p|absorption|both valid; useful in simplification
LI10|idempotence|p ∧ p ≡ p; p ∨ p ≡ p|idempotence|conjunction and disjunction are idempotent
LI11|commutativity|p ∧ q ≡ q ∧ p; p ∨ q ≡ q ∨ p|commutativity|also: p ↔ q ≡ q ↔ p; p ⊕ q ≡ q ⊕ p; NOTE: p → q ≢ q → p
LI12|associativity|p ∧ (q ∧ r) ≡ (p ∧ q) ∧ r; p ∨ (q ∨ r) ≡ (p ∨ q) ∨ r|associativity|allows dropping parentheses in chains
LI13|identity|p ∧ ⊤ ≡ p; p ∨ ⊥ ≡ p|identity|⊤ is identity for ∧; ⊥ is identity for ∨
LI14|annihilation|p ∧ ⊥ ≡ ⊥; p ∨ ⊤ ≡ ⊤|annihilation|⊥ annihilates ∧; ⊤ annihilates ∨
LI15|complement|p ∧ ¬p ≡ ⊥; p ∨ ¬p ≡ ⊤|complement|second identity (LEM) is classical only; not valid intuitionistically
LI16|material conditional equivalence|p → q ≡ ¬p ∨ q|conditional|classical only; defines → in terms of ¬ and ∨; intuitionistically: implication is primitive, not reducible to disjunction + negation
LI17|biconditional expansion|p ↔ q ≡ (p → q) ∧ (q → p)|biconditional|definition of biconditional; also ≡ (p ∧ q) ∨ (¬p ∧ ¬q)
LI18|quantifier distribution (∀ over ∧)|∀x (φ(x) ∧ ψ(x)) ≡ ∀x φ(x) ∧ ∀x ψ(x)|quantifier|valid; ∀ distributes over ∧
LI19|quantifier distribution (∃ over ∨)|∃x (φ(x) ∨ ψ(x)) ≡ ∃x φ(x) ∨ ∃x ψ(x)|quantifier|valid; ∃ distributes over ∨
LI20|quantifier non-distribution|∀x (φ(x) ∨ ψ(x)) does NOT imply ∀x φ(x) ∨ ∀x ψ(x)|quantifier|∀ does NOT distribute over ∨; common error; similarly ∃ does NOT distribute over ∧
LI21|vacuous quantification|∀x φ ≡ φ (when x not free in φ); ∃x φ ≡ φ (when x not free in φ)|quantifier|quantifier over non-occurring variable is vacuous; can be added or removed freely

# normal_forms(id|name|domain|form|construction|properties|uses)
NF1|conjunctive normal form (CNF)|propositional|conjunction of disjunctions of literals: (L₁∨...∨Lₖ) ∧ ... ∧ (L₁∨...∨Lₘ)|apply De Morgan, distribute ∨ over ∧, eliminate double negations|every propositional formula has equivalent CNF; may be exponentially larger; clause = disjunction of literals|SAT solvers (DPLL, CDCL); resolution theorem proving; hardware verification
NF2|disjunctive normal form (DNF)|propositional|disjunction of conjunctions of literals: (L₁∧...∧Lₖ) ∨ ... ∨ (L₁∧...∧Lₘ)|apply De Morgan, distribute ∧ over ∨|every propositional formula has equivalent DNF; may be exponentially larger; minterm = conjunction with every variable exactly once|truth table → DNF (each true row = minterm; disjoin all minterms); circuit design; Karnaugh maps minimize
NF3|negation normal form (NNF)|propositional|negation appears only on atoms (literals); connectives: ∧, ∨, ¬(atom only)|push negation inward using De Morgan and double negation|linear size transformation; preserves structure; every formula has equivalent NNF|preprocessing for CNF/DNF conversion; BDD construction; model counting
NF4|prenex normal form|FOL|Q₁x₁ Q₂x₂ ... Qₙxₙ φ where Qᵢ ∈ {∀,∃} and φ is quantifier-free (matrix)|move quantifiers outward using equivalences (may require variable renaming to avoid capture)|every FOL formula has equivalent prenex form (classically); quantifier prefix determines complexity class (Σₙ, Πₙ arithmetic hierarchy)|classification of formulas by quantifier complexity; Skolemization; automated theorem proving
NF5|Skolem normal form|FOL|prenex + all ∃ removed by Skolem functions; universally quantified|Skolemize: replace each ∃xᵢ with Skolem function fᵢ depending on preceding ∀-variables|equisatisfiable (not logically equivalent) to original; may add new function symbols|resolution theorem proving (requires Skolemization); Herbrand's theorem; automated reasoning; model construction
NF6|clausal form (clause set)|FOL|set of clauses; each clause = set of literals; universal quantification implicit; Skolemized|from prenex → Skolemize → distribute to CNF → drop universal quantifiers (implicit) → represent as set of sets|standard input format for resolution-based provers; first-order clauses may contain variables (universally quantified implicitly)|Prolog (Horn clauses); SAT/SMT; automated theorem proving; logic programming

# decidability(id|theory|decidable|complexity|proof_method|notes)
DC1|propositional logic (validity)|yes|coNP-complete (SAT is NP-complete; validity = co-SAT)|truth tables (2ⁿ; brute force); DPLL/CDCL (practical for SAT); resolution (refutation-complete)|decidable and complete; most practical decision problem in logic; SAT solvers handle millions of variables
DC2|monadic first-order logic|yes|NEXPTIME-complete|finite model property: if satisfiable, satisfiable in finite model of bounded size; reduce to propositional|only unary predicates; no function symbols; Löwenheim 1915; historical first decidability result for FOL fragment
DC3|FOL validity (general)|no (undecidable)|—|Church 1936, Turing 1936: reduction from halting problem|semi-decidable: enumerate proofs (complete); cannot enumerate non-theorems; valid sentences = r.e. but not recursive
DC4|FOL satisfiability (general)|no (undecidable)|—|dual of validity: Γ is satisfiable iff ¬(conjunction of Γ) is not valid|co-r.e.: if unsatisfiable, eventually discover (refutation-complete); if satisfiable, may search forever
DC5|Peano arithmetic|no|—|Gödel 1st; Church 1936|essentially undecidable: every consistent extension is also undecidable; not even satisfiability of Diophantine equations is decidable (Matiyasevich 1970: Hilbert's 10th problem)
DC6|Presburger arithmetic (ℕ, +)|yes|at least triply exponential (Fischer-Rabin 1974: lower bound 2^2^cn)|quantifier elimination; automata-theoretic methods|complete and decidable; multiplication makes it undecidable (PA); important decidable fragment
DC7|theory of real closed fields|yes|doubly exponential (upper bound); exponential space|Tarski's quantifier elimination (1948); cylindrical algebraic decomposition (Collins 1975)|elementary geometry decidable; multiplication + ordering + completeness does not yield undecidability (unlike ℕ); ℤ is not definable in RCF
DC8|S1S (monadic second-order theory of successor)|yes|non-elementary|Büchi 1960: equivalence with finite automata on infinite words (ω-automata)|much more expressive than FOL of successor; LTL model checking reduces to S1S; important in verification
DC9|WS1S (weak S1S: quantify over finite sets)|yes|non-elementary (tower of exponentials)|MONA tool implements decision procedure; automata-based|used in program verification; hardware verification; string constraints; decidable but worst-case impractical
DC10|S2S (monadic second-order theory of two successors)|yes|non-elementary|Rabin 1969: equivalence with tree automata|most powerful known decidable theory; subsumes S1S, Presburger, propositional modal logics, CTL*; tree automata on infinite trees
DC11|first-order theory of (ℤ, +, <)|yes|at least doubly exponential|quantifier elimination (Presburger + order)|integers with addition and order; useful in program analysis and verification
DC12|first-order theory of (ℝ, +, ·, <, 0, 1)|yes|same as DC7 (real closed fields)|Tarski 1948|the theory of the real numbers is decidable; remarkable contrast with ℕ

# concepts(id|name|definition|category)
LC1|syntax|formal language: alphabet of symbols + formation rules (grammar) defining well-formed formulas; no reference to meaning; purely structural|foundation
LC2|semantics|assignment of meaning to syntactic expressions; interpretation function mapping symbols to mathematical objects; truth defined relative to structure/model|foundation
LC3|soundness|every provable formula is valid (⊢ implies ⊨); the proof system does not prove falsehoods; minimum requirement|metatheoretic property
LC4|completeness|every valid formula is provable (⊨ implies ⊢); the proof system captures all semantic truths|metatheoretic property
LC5|decidability|there exists an algorithm (Turing machine) that determines in finite time whether any formula belongs to a given set (e.g., the set of valid formulas, or theorems of a theory)|metatheoretic property
LC6|compactness|a set of formulas has a model iff every finite subset has a model; equivalently: if Γ ⊨ φ then some finite subset Γ₀ ⊆ Γ already entails φ|metatheoretic property
LC7|expressiveness|what can be said in a logic; more expressive logics can define more classes of structures; tradeoff: expressiveness vs decidability/completeness (Lindström)|metatheoretic property
LC8|consistency|a theory T is consistent iff T ⊬ ⊥ (no contradiction derivable); equivalently (classical): there exists a sentence φ such that T ⊬ φ; Gödel 2nd: sufficiently strong consistent T cannot prove Con(T)|metatheoretic property
LC9|independence|a sentence φ is independent of theory T iff T ⊬ φ and T ⊬ ¬φ; φ is undecidable by T; CH is independent of ZFC; Con(PA) is independent of PA (if PA consistent)|metatheoretic property
LC10|conservative extension|theory T₂ is a conservative extension of T₁ iff every sentence in the language of T₁ provable in T₂ is already provable in T₁; T₂ may add new symbols and axioms but proves nothing new about old language|metatheoretic property
LC11|categoricity|theory T is categorical iff all models of T are isomorphic; propositional: trivially; FOL: no complete theory with infinite models is categorical (Löwenheim-Skolem); κ-categoricity: all models of cardinality κ are isomorphic|metatheoretic property
LC12|quantifier elimination|theory T has QE iff every formula is equivalent (in T) to a quantifier-free formula; implies decidability (reduce to checking quantifier-free sentences); examples: DLO, RCF, algebraically closed fields, Presburger|metatheoretic property
LC13|interpolation|Craig interpolation: if ⊨ φ→ψ then there exists interpolant θ in shared language; captures "common content"; fails for some non-classical logics|metatheoretic property
LC14|definability (Beth)|implicit definition implies explicit definition: if theory T implicitly defines symbol R (any two models agreeing on everything else agree on R), then T contains explicit definition of R in terms of other symbols|metatheoretic property
LC15|Boolean algebra|algebraic structure (B, ∧, ∨, ¬, ⊤, ⊥) satisfying: associativity, commutativity, distribution, identity, complement; Lindenbaum-Tarski algebra of classical propositional logic is Boolean algebra; Stone's theorem: every Boolean algebra is isomorphic to a field of sets|algebraic semantics
LC16|Heyting algebra|algebraic structure generalizing Boolean algebra; (H, ∧, ∨, →, ⊤, ⊥) where → is relative pseudo-complement (a → b = largest c such that a ∧ c ≤ b); models intuitionistic logic; not every element has complement; ¬a = a → ⊥|algebraic semantics
LC17|Lindenbaum-Tarski algebra|construction|quotient algebra of formulas modulo logical equivalence; [φ] = {ψ : ⊢ φ ↔ ψ}; classical propositional logic → Boolean algebra; intuitionistic → Heyting algebra; modal → modal algebra|algebraic semantics
LC18|fixed-point (diagonal) lemma|metatheorem|for any formula ψ(x) in the language of arithmetic, there exists a sentence σ such that T ⊢ σ ↔ ψ(⌈σ⌉); σ "says of itself" that it has property ψ|technical tool: self-reference formalized; used in proofs of Gödel's incompleteness, Tarski's undefinability, Löb's theorem, Rogers's fixed-point theorem|key technical lemma
LC19|Gödel numbering|encoding|bijective mapping from syntactic objects (symbols, terms, formulas, proofs) to natural numbers; encodes syntax within arithmetic; allows arithmetic to "talk about" its own proofs|enables: diagonal lemma, incompleteness theorems, undefinability theorem, representability of syntactic operations as recursive functions|encoding

# relationships(from|rel|to)
# domain hierarchy
DM1|specializes|DM2
DM2|enables|DM4
DM2|enables|DM5
DM2|enables|DM6
DM2|enables|DM7
DM3|extends|DM2
DM8|extends|DM1
DM9|specializes|DM1
DM9|specializes|DM2
DM10|extends|DM2
DM11|extends|DM1
DM12|extends|DM2
DM13|enables|DM1,DM2,DM5,DM6,DM7
# propositional logic structure
PL2|enables|PL3,PL4,PL5
PL3|enables|PL8
PL4|enables|PL9
PL5|composed_of|PL2,PL4
PL6|composed_of|PL5
PL7|composed_of|PL4,PL3,PL2
PL8|enables|PL15
PL9|enables|PL15
PL10|prevents|PL11
PL13|requires|PL10
PL14|requires|PL10
# FOL extends propositional
FO6|extends|PL3
FO7|extends|PL4
FO6|enables|FO13
FO7|enables|FO13
FO14|requires|FO7,FO4
FO15|requires|FO14
FO9|enables|FO10
FO10|enables|FO11,FO12
FO16|requires|FO1
FO17|enables|FO16
# set theory foundations
ST1|enables|ST2,ST3,ST4,ST5,ST6,ST7,ST8,ST9,ST10
ST11|enables|ST1
ST12|prevents|PX1
ST14|enables|ST4
ST15|enables|RL12
ST4|requires|ST3
ST10|requires|ST1
# relations hierarchy
RL2|enables|RL8,RL9
RL4|enables|RL8
RL5|enables|RL9
RL7|enables|RL8,RL9,RL10
RL8|enables|RL13
RL9|specializes|RL11
RL11|specializes|RL12
# functions hierarchy
FN1|requires|RL1
FN2|specializes|FN1
FN3|specializes|FN1
FN4|composed_of|FN2,FN3
FN4|enables|FN6
FN5|requires|FN1
FN7|generalizes|FN1
FN8|enables|ST4
# proof theory structure
PT1|enables|PT5
PT2|enables|PT5
PT3|enables|PT7
PT2|enables|PT8
PT4|requires|NF6
PT6|requires|IR9
PT7|enables|MG9
PT8|requires|DM9
# model theory
MT1|enables|FO10
MT4|derived_from|MG3
MT4|enables|MT6
MT5|requires|MT1
MT9|enables|MT4
MT7|requires|MT1
MT8|requires|MT1
MT10|requires|FO10
MT2|requires|FO10
MT3|specializes|MT2
# computability
CO1|enables|CO2,CO3,CO4,CO7
CO2|specializes|CO3
CO4|enables|CO5
CO5|enables|DC3,DC5
CO6|specializes|CO7
CO7|specializes|CO6
CO8|enables|CO1,CO4
# modal logic
ML1|enables|ML2
ML4|specializes|ML5
ML5|specializes|ML6
ML6|specializes|ML7
ML3|enables|ML4,ML5,ML6,ML7,ML8
ML8|requires|MG5,MG6
ML9|extends|ML7
ML10|extends|ML4
# type theory
TT1|enables|DM10
TT2|extends|TT1
TT3|extends|TT2
TT4|extends|TT1
PT8|enables|TT1,TT2,TT4
# category logic
CL1|enables|DM12
CL2|enables|CL1
CL3|enables|FO6,FO7
CL4|composed_of|PT8,TT1,CL1
# paradoxes → resolutions
PX1|enables|ST12
PX1|enables|TT1
PX2|enables|MG7
PX5|enables|MT5
PX6|enables|DM9
# metalogic chains
MG1|requires|PT5,FO10
MG3|requires|MG1
MG3|enables|MT4
MG5|requires|LC18,LC19,AX3
MG6|requires|MG5
MG7|requires|LC18
MG10|requires|MT4,MT5
MG9|requires|PT7
# axiom system relationships
AX1|specializes|AX2
AX3|extends|AX2
AX4|specializes|AX3
AX5|extends|AX2
AX6|specializes|AX3
AX7|extends|AX2
AX8|specializes|AX3
AX9|extends|AX3
# decidability connections
DC1|instance_of|AX1
DC3|instance_of|AX2
DC5|instance_of|AX3
DC6|instance_of|AX6
DC7|instance_of|AX7
# inference rules → proof systems
IR1|part_of|PT1,PT2
IR5|part_of|PT2
IR6|part_of|PT2
IR7|part_of|PT2
IR8|part_of|PT2
IR9|part_of|PT2
IR10|part_of|PT2
IR11|part_of|PT2
IR12|part_of|PT2
IR13|part_of|PT2
IR14|part_of|PT2
IR15|part_of|PT2
IR16|part_of|PT2
IR17|part_of|PT2
IR18|part_of|PT4
# normal form dependencies
NF1|requires|LI2,LI3,LI8
NF2|requires|LI2,LI3,LI8
NF3|requires|LI2,LI3,LI1
NF4|requires|FO6,FO7,FO17
NF5|requires|NF4,FO4
NF6|requires|NF5,NF1
# identity classifications
LI1|part_of|DM1
LI2|part_of|DM1
LI8|part_of|DM1
LI4|part_of|DM2
LI5|part_of|DM2
LI18|part_of|DM2
LI19|part_of|DM2
# concept → domain
LC1|enables|LC2
LC1|enables|DM5
LC2|enables|DM6
LC3|requires|LC1,LC2
LC4|requires|LC1,LC2
LC5|requires|CO1
LC6|requires|DM6
LC7|enables|MG10
LC8|requires|LC3
LC9|requires|MG5
LC10|requires|LC4
LC11|requires|DM6
LC12|enables|LC5
LC15|enables|DM1
LC16|enables|DM9
LC17|requires|LC15,LC16
LC18|requires|LC19,AX3
LC19|requires|FN4

# section_index(section|title|ids)
1|Domains|DM1-DM13
2|Propositional Logic|PL1-PL15
3|Predicate Logic (FOL)|FO1-FO17
4|Set Theory|ST1-ST16
5|Relations|RL1-RL13
6|Functions|FN1-FN8
7|Proof Theory|PT1-PT8
8|Model Theory|MT1-MT10
9|Computability Theory|CO1-CO8
10|Modal Logic|ML1-ML10
11|Type Theory|TT1-TT4
12|Category-Theoretic Logic|CL1-CL4
13|Paradoxes|PX1-PX6
14|Metalogic|MG1-MG11
15|Axiom Systems|AX1-AX9
16|Inference Rules|IR1-IR18
17|Logical Identities|LI1-LI21
18|Normal Forms|NF1-NF6
19|Decidability|DC1-DC12
20|Core Concepts|LC1-LC19
21|Relationships|all

# decode_legend
id_prefixes: DM=domain, PL=propositional_logic, FO=first_order, ST=set_theory, RL=relation, FN=function, PT=proof_theory, MT=model_theory, CO=computability, ML=modal_logic, TT=type_theory, CL=category_logic, PX=paradox, MG=metalogic, AX=axiom_system, IR=inference_rule, LI=logical_identity, NF=normal_form, DC=decidability, LC=concept
rel_types: enables|requires|prevents|specializes|generalizes|part_of|contains|follows|precedes|instance_of|determined_by|equivalent_to|extends|derived_from|composed_of
notation: ¬=negation (NOT); ∧=conjunction (AND); ∨=disjunction (OR); →=material conditional (IF...THEN); ↔=biconditional (IFF); ⊕=exclusive or (XOR); ↑=NAND (Sheffer stroke); ↓=NOR (Peirce arrow); ∀=universal quantifier (for all); ∃=existential quantifier (there exists); ∃!=unique existential; □=necessity (modal); ◇=possibility (modal); ⊤=tautology/truth/top; ⊥=contradiction/falsity/bottom; ⊨=semantic entailment (models/satisfies); ⊢=syntactic derivability (proves); ≡=logical equivalence (metalogical); ≅=isomorphism; ∈=set membership; ⊆=subset; ⊂=proper subset; ∅=empty set; ℘=power set; ∪=union; ∩=intersection; \=set difference; △=symmetric difference; ×=Cartesian product; ∘=function composition; ℕ=natural numbers; ℤ=integers; ℚ=rationals; ℝ=reals; ω=first infinite ordinal (=ℕ as set); κ,λ=cardinal numbers; Γ,Δ,Σ,Π=sets of formulas/sequent sides; φ,ψ,χ,σ,θ=formulas; L=formal language; M,N=structures/models; D=domain/universe of structure; I=interpretation function; R=relation; f,g,h=functions; s=variable assignment; ⌈φ⌉=Gödel number of φ; T=formal theory; Con(T)="T is consistent" (formalized); PA=Peano arithmetic; ZFC=Zermelo-Fraenkel with Choice; ZF=Zermelo-Fraenkel without Choice; CH=continuum hypothesis; AC=axiom of choice; LEM=law of excluded middle; DNE=double negation elimination; BHK=Brouwer-Heyting-Kolmogorov (interpretation); CCC=cartesian closed category; HoTT=homotopy type theory; MLTT=Martin-Löf type theory; DLO=dense linear order without endpoints; RCF=real closed field; SAT=Boolean satisfiability; CNF=conjunctive normal form; DNF=disjunctive normal form; NNF=negation normal form; LK=sequent calculus (classical); LJ=sequent calculus (intuitionistic); MP=modus ponens; r.e.=recursively enumerable; PR=primitive recursive; NP=nondeterministic polynomial time; coNP=complement of NP; NEXPTIME=nondeterministic exponential time; LTL=linear temporal logic; CTL=computation tree logic; S1S/S2S/WS1S=monadic second-order theories of successor(s); Σₙ,Πₙ=arithmetic/analytical hierarchy levels; DPLL=Davis-Putnam-Logemann-Loveland (SAT algorithm); CDCL=conflict-driven clause learning; BDD=binary decision diagram; CAD=cylindrical algebraic decomposition
confidence: all definitions, theorems, and results from standard references (Enderton 2001, Mendelson 2015, Shoenfield 1967, Marker 2002, Soare 2016, Blackburn et al. 2001, Troelstra & van Dalen 1988, Awodey 2010, Kunen 2011); all facts at reference_mathematical_logic confidence level
scope: mathematical logic covering propositional and predicate logic, set theory, proof theory, model theory, computability theory, modal logic, intuitionistic logic, type theory, and category-theoretic logic; includes syntax, semantics, metatheory, decidability, and algebraic semantics; excludes: detailed recursion theory beyond basics (degrees, priority arguments), descriptive set theory, large cardinal theory beyond mention, detailed proof complexity, and applications to specific mathematical theories (algebra, analysis) beyond illustrative examples
