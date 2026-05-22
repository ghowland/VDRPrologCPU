# FINITE STATE MACHINES — COMPLETE DEEP DIVE — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: foundations → components → machine_types → hierarchy → closure_properties → operations → construction_algorithms → equivalences → minimization → pumping_lemmas → theorems → regular_expressions → implementation_patterns → extended_models → applications → design_rules → failure_modes → relationships → section_index

# foundations(id|concept|definition|formal_notation|significance)
FO1|alphabet|finite non-empty set of symbols|Σ|input domain — all machines read from an alphabet
FO2|symbol|single atomic element of an alphabet|a, b, c ∈ Σ|indivisible input unit
FO3|string/word|finite sequence of symbols from an alphabet|w ∈ Σ*|input to machine — zero or more symbols concatenated
FO4|empty string|string of length zero|ε (epsilon)|identity element for concatenation — every language contains or excludes it
FO5|language|set of strings over an alphabet|L ⊆ Σ*|the thing machines recognize — may be finite or infinite
FO6|state|configuration of machine at a point in computation|q ∈ Q|memory of machine — encodes everything relevant about input processed so far
FO7|transition|rule mapping (current state, input symbol) to next state(s)|δ(q, a) = q′ or δ(q, a) ⊆ Q|computation step — the machine's program
FO8|start state|designated initial state before any input processed|q₀ ∈ Q|unique — computation begins here
FO9|accept/final state|state(s) indicating input string is in the language|F ⊆ Q|membership test — string accepted iff machine ends in accept state after reading all input
FO10|reject|machine finishes in non-accept state after reading all input|q_final ∉ F|complement of acceptance — string not in language
FO11|dead/trap state|non-accept state with all transitions looping to itself|∀a ∈ Σ: δ(q_dead, a) = q_dead|absorbs all remaining input — machine will never accept once entered
FO12|computation|sequence of configurations from start to halt on given input|q₀w ⊢ q₁w′ ⊢ ... ⊢ q_f|trace of machine execution — determines accept/reject
FO13|configuration|complete description of machine state at one instant|(q, w) where q = current state, w = remaining input|snapshot of computation
FO14|Kleene star|set of all strings over alphabet including ε|Σ* = {ε} ∪ Σ ∪ Σ² ∪ Σ³ ∪ ...|universal language over Σ — always infinite (unless Σ = ∅)
FO15|Kleene plus|set of all non-empty strings over alphabet|Σ⁺ = Σ ∪ Σ² ∪ Σ³ ∪ ...|Σ* minus ε
FO16|power of alphabet|set of all strings of exactly length n|Σⁿ|Σ⁰ = {ε}, Σ¹ = Σ, Σ² = all length-2 strings
FO17|string length|number of symbols in string|&#124;w&#124;|&#124;ε&#124; = 0, &#124;abc&#124; = 3
FO18|concatenation (strings)|appending one string after another|w₁ · w₂ or w₁w₂|associative, identity element ε, not commutative
FO19|prefix|leading substring|x is prefix of w iff ∃y: w = xy|includes ε and w itself
FO20|suffix|trailing substring|x is suffix of w iff ∃y: w = yx|includes ε and w itself
FO21|substring|contiguous sub-sequence|x is substring of w iff ∃y,z: w = yxz|includes ε, all prefixes, all suffixes
FO22|reversal|string read backwards|wᴿ — if w = abc then wᴿ = cba|language reversal: Lᴿ = {wᴿ : w ∈ L}
FO23|complement (language)|all strings not in L|L̄ = Σ* \ L|swapping accept and reject states in DFA
FO24|homomorphism|function mapping each symbol to a string|h: Σ → Δ*, extended to h(a₁a₂...aₙ) = h(a₁)h(a₂)...h(aₙ)|regular languages closed under homomorphism and inverse homomorphism

# components(id|component|symbol|definition|role|constraints)
CM1|state set|Q|finite non-empty set of states|all possible configurations|must be finite — finiteness is the defining limitation of FSMs
CM2|input alphabet|Σ|finite non-empty set of input symbols|defines legal input|disjoint from any auxiliary alphabets (Γ in PDA)
CM3|transition function (deterministic)|δ|δ: Q × Σ → Q|maps (state, symbol) to exactly one next state|total function — defined for every (q, a) pair — no ambiguity
CM4|transition function (nondeterministic)|δ|δ: Q × Σ → P(Q) or δ: Q × (Σ ∪ {ε}) → P(Q)|maps (state, symbol) to set of possible next states|may return empty set (dead end), multiple states (branching), includes ε-transitions in ε-NFA
CM5|start state|q₀|distinguished element of Q|computation origin|exactly one — never a set
CM6|accept states|F|subset of Q (may be empty)|determine acceptance|F = ∅ means no string accepted — machine recognizes empty language ∅
CM7|output alphabet (transducers)|Λ|finite set of output symbols|defines legal outputs for Mealy/Moore machines|separate from input alphabet Σ
CM8|output function (Moore)|G|G: Q → Λ|output determined by state alone|output changes only on state change — one clock cycle delay relative to input
CM9|output function (Mealy)|G|G: Q × Σ → Λ|output determined by state and current input|output responds immediately to input — no delay
CM10|stack alphabet (PDA)|Γ|finite set of stack symbols|defines what PDA can push/pop|includes Z₀ (initial stack symbol), may overlap with Σ
CM11|initial stack symbol (PDA)|Z₀|distinguished element of Γ, initially on stack|stack start marker|exactly one — stack begins with only Z₀

# machine_types(id|type|formal_definition|determinism|output_model|power|equivalences)
MT1|DFA (Deterministic Finite Automaton)|M = (Q, Σ, δ, q₀, F) where δ: Q × Σ → Q|deterministic — exactly one transition per (state, symbol)|accept/reject only|recognizes exactly the regular languages|equivalent to NFA, ε-NFA, regular expressions, right-linear grammars
MT2|NFA (Nondeterministic Finite Automaton)|M = (Q, Σ, δ, q₀, F) where δ: Q × Σ → P(Q)|nondeterministic — zero or more transitions per (state, symbol)|accept/reject only|recognizes exactly the regular languages|equivalent to DFA (subset construction), may have exponentially fewer states
MT3|ε-NFA|M = (Q, Σ, δ, q₀, F) where δ: Q × (Σ ∪ {ε}) → P(Q)|nondeterministic with spontaneous transitions|accept/reject only|recognizes exactly the regular languages|equivalent to NFA (ε-closure elimination), convenient for construction algorithms
MT4|Moore machine|M = (Q, Σ, Λ, δ, G, q₀) where G: Q → Λ|deterministic|output per state — output string length = input string length + 1 (includes initial state output)|transducer — transforms input to output, does not accept/reject|equivalent to Mealy (may need +1 states)
MT5|Mealy machine|M = (Q, Σ, Λ, δ, G, q₀) where G: Q × Σ → Λ|deterministic|output per transition — output string length = input string length|transducer — transforms input to output, does not accept/reject|equivalent to Moore (may need fewer states)
MT6|PDA (Pushdown Automaton)|M = (Q, Σ, Γ, δ, q₀, Z₀, F) where δ: Q × (Σ ∪ {ε}) × Γ → P(Q × Γ*)|nondeterministic|accept by final state or by empty stack|recognizes exactly the context-free languages|nondeterministic PDA > deterministic PDA (DPDA recognizes strict subset)
MT7|DPDA (Deterministic Pushdown Automaton)|M = (Q, Σ, Γ, δ, q₀, Z₀, F) where δ is deterministic|deterministic|accept by final state|recognizes deterministic context-free languages (strict subset of CFLs)|less powerful than nondeterministic PDA — LR(k) parsable languages
MT8|Turing Machine (reference)|M = (Q, Σ, Γ, δ, q₀, q_accept, q_reject)|deterministic or nondeterministic (equivalent)|accept/reject/loop|recognizes recursively enumerable languages — universal computation|upper bound of Chomsky hierarchy — FSM with unbounded read-write tape
MT9|two-way DFA|M = (Q, Σ, δ, q₀, F) where δ: Q × Σ → Q × {L, R}|deterministic with bidirectional head|accept/reject|recognizes exactly the regular languages — no additional power over one-way DFA|equivalent to DFA — proved by Shepherdson (1959)
MT10|finite state transducer (FST)|M = (Q, Σ, Λ, δ, G, q₀, F)|deterministic or nondeterministic|maps input strings to output strings|computes regular relations (rational transductions)|generalizes Mealy and Moore — adds accept states to transducer

# hierarchy(id|class|recognizer|grammar|example_language|limitations)
HI1|Type 3 — Regular|DFA / NFA / ε-NFA|right-linear or left-linear grammar (A → aB or A → a)|a*b*, (ab)*, strings with even number of 0s|cannot count unboundedly — no matching, no nesting, no cross-serial dependencies
HI2|Type 2 — Context-Free|nondeterministic PDA|context-free grammar (A → α where α ∈ (V ∪ Σ)*)|aⁿbⁿ, balanced parentheses, palindromes|cannot enforce multiple dependencies — aⁿbⁿcⁿ is not context-free
HI3|Type 1 — Context-Sensitive|linear bounded automaton (LBA)|context-sensitive grammar (αAβ → αγβ where &#124;γ&#124; ≥ 1)|aⁿbⁿcⁿ, {ww : w ∈ Σ*}|decidable but exponential space — impractical for most applications
HI4|Type 0 — Recursively Enumerable|Turing machine|unrestricted grammar (α → β)|halting problem complement is not r.e.|may not halt on all inputs — semi-decidable only
HI5|Decidable (recursive)|Turing machine that halts on all inputs|unrestricted grammar with halting guarantee|all context-sensitive languages, most practical problems|cannot solve halting problem, Post correspondence problem, etc.

# closure_properties(id|class|operation|closed|notes)
CL1|regular|union|yes|construct product automaton or NFA with new start state
CL2|regular|concatenation|yes|connect accept states of first to start state of second via ε-transitions
CL3|regular|Kleene star|yes|add new start/accept state, ε-transitions from accept to old start
CL4|regular|complement|yes|swap accept and non-accept states in complete DFA
CL5|regular|intersection|yes|product construction — states are pairs (q₁, q₂), accept when both accept
CL6|regular|difference|yes|L₁ \ L₂ = L₁ ∩ L̄₂ — by closure under intersection and complement
CL7|regular|reversal|yes|reverse all transitions, swap start and accept states (may need NFA)
CL8|regular|homomorphism|yes|replace each transition label a with string h(a)
CL9|regular|inverse homomorphism|yes|for each state and input a, simulate machine on h(a)
CL10|regular|Kleene plus|yes|Σ⁺ = Σ · Σ* — by closure under concatenation and Kleene star
CL11|context-free|union|yes|new start symbol S → S₁ &#124; S₂
CL12|context-free|concatenation|yes|new start symbol S → S₁S₂
CL13|context-free|Kleene star|yes|new start symbol S → SS₁ &#124; ε
CL14|context-free|complement|no|classic result — CFLs not closed under complement
CL15|context-free|intersection|no|aⁿbⁿcⁿ = {aⁿbⁿc*} ∩ {a*bⁿcⁿ} — intersection of two CFLs is not CF
CL16|context-free|intersection with regular|yes|product construction with PDA and DFA — PDA tracks stack, product tracks DFA state
CL17|context-free|homomorphism|yes|apply h to each terminal in grammar productions
CL18|context-free|inverse homomorphism|yes|construct new PDA simulating original on h(a) for each input a
CL19|context-free|reversal|yes|reverse right-hand sides of all grammar productions
CL20|context-free|difference|no|if closed under difference then closed under complement (L̄ = Σ* \ L) — contradiction with CL14

# operations(id|operation|input|output|description|closure_properties)
OP1|union|L₁, L₂|L₁ ∪ L₂ = {w : w ∈ L₁ or w ∈ L₂}|all strings in either language|CL1, CL11
OP2|concatenation|L₁, L₂|L₁ · L₂ = {xy : x ∈ L₁, y ∈ L₂}|all strings formed by joining one from each|CL2, CL12
OP3|Kleene star|L|L* = {ε} ∪ L ∪ LL ∪ LLL ∪ ...|zero or more concatenations of strings from L|CL3, CL13
OP4|complement|L|L̄ = Σ* \ L|all strings NOT in L|CL4, not CL14
OP5|intersection|L₁, L₂|L₁ ∩ L₂ = {w : w ∈ L₁ and w ∈ L₂}|all strings in both languages|CL5, not CL15, CL16
OP6|difference|L₁, L₂|L₁ \ L₂ = {w : w ∈ L₁ and w ∉ L₂}|strings in first but not second|CL6, not CL20
OP7|reversal|L|Lᴿ = {wᴿ : w ∈ L}|all strings reversed|CL7, CL19
OP8|homomorphism|L, h|h(L) = {h(w) : w ∈ L}|symbol-by-symbol transformation|CL8, CL17
OP9|inverse homomorphism|L, h|h⁻¹(L) = {w : h(w) ∈ L}|preimage under h|CL9, CL18
OP10|Kleene plus|L|L⁺ = L · L*|one or more concatenations|CL10

# construction_algorithms(id|algorithm|input|output|complexity|description)
CA1|subset construction (Rabin-Scott)|NFA N = (Q_N, Σ, δ_N, q₀, F_N)|equivalent DFA D = (P(Q_N), Σ, δ_D, {q₀}, F_D)|worst case O(2ⁿ) states where n = &#124;Q_N&#124;, often much smaller in practice|each DFA state is a set of NFA states — δ_D(S, a) = ∪{δ_N(q, a) : q ∈ S} — accept if any member is in F_N
CA2|ε-closure elimination|ε-NFA|NFA without ε-transitions|O(n²) for ε-closure computation|compute ε-closure of each state (all states reachable by ε-transitions), incorporate into transition function
CA3|Thompson's construction|regular expression r|ε-NFA N with L(N) = L(r)|O(&#124;r&#124;) states and transitions|recursive — base cases for ∅, ε, symbol; inductive cases for union, concatenation, star — each produces small NFA fragment
CA4|Brzozowski's algorithm|DFA (possibly non-minimal)|minimal DFA|two reversals and two subset constructions — O(2ⁿ) worst case|reverse → determinize → reverse → determinize = minimal DFA — elegant but exponential worst case
CA5|Hopcroft's minimization|complete DFA D|minimal DFA D_min with L(D_min) = L(D)|O(n log n) where n = &#124;Q&#124;|partition refinement — start with {F, Q\F}, split partitions where states in same block transition to different blocks
CA6|Moore's minimization|complete DFA D|minimal DFA D_min|O(n²) where n = &#124;Q&#124;|iterative — mark distinguishable pairs starting from (accept, non-accept), propagate until no new marks
CA7|product construction|DFA D₁, DFA D₂|DFA for L₁ ∩ L₂ (or L₁ ∪ L₂)|O(&#124;Q₁&#124; × &#124;Q₂&#124;) states|states are pairs (q₁, q₂), transitions simulated in parallel — accept condition determines operation (both accept = intersection, either accepts = union)
CA8|complement construction|complete DFA D|DFA for L̄|O(1) — no new states|swap accept and non-accept states — requires DFA to be complete (total transition function)
CA9|NFA to regex (state elimination)|NFA N|regular expression r with L(r) = L(N)|O(n³ · 4ⁿ) worst case for expression size|eliminate states one by one, replacing with regex-labeled transitions — each elimination combines incoming and outgoing edges
CA10|Myhill-Nerode construction|language L|minimal DFA for L (if regular)|depends on number of equivalence classes|define x ≡_L y iff ∀z: xz ∈ L ↔ yz ∈ L — each equivalence class becomes a state — number of classes = number of states in minimal DFA
CA11|powerset construction for PDA intersection with DFA|PDA P, DFA D|PDA for L(P) ∩ L(D)|O(&#124;Q_P&#124; × &#124;Q_D&#124;) PDA states|track DFA state alongside PDA state — push/pop unchanged — proves CL16
CA12|McNaughton-Yamada algorithm|regular expression r|DFA directly (no intermediate NFA)|O(2ⁿ) states worst case|computes followpos, firstpos, lastpos on syntax tree — positions become NFA states

# equivalences(id|equivalence|between|proof_method|significance)
EQ1|DFA ≡ NFA|DFA and NFA recognize same language class|subset construction (CA1) converts any NFA to DFA; every DFA is trivially an NFA|nondeterminism does not add power to finite automata — but may allow exponentially fewer states
EQ2|NFA ≡ ε-NFA|NFA and ε-NFA recognize same language class|ε-closure elimination (CA2) removes ε-transitions|ε-transitions are convenience — do not add recognition power
EQ3|DFA ≡ regular expression|DFAs and regular expressions define same language class|Thompson (CA3) converts regex to NFA, then CA1 to DFA; CA9 converts NFA to regex|two completely different formalisms describe exactly the same languages
EQ4|DFA ≡ right-linear grammar|DFAs and right-linear grammars define same language class|states become nonterminals, transitions become productions A → aB, accept states produce A → a|connects automata theory to formal grammar theory
EQ5|Moore ≡ Mealy|Moore and Mealy machines compute same class of transductions (with minor output length difference)|convert Moore to Mealy by moving output from state to incoming transitions; convert Mealy to Moore by splitting states per output|output model choice is engineering preference, not computational distinction
EQ6|NPDA > DPDA|nondeterministic PDA strictly more powerful than deterministic PDA|language {wwᴿ} is CFL (accepted by NPDA) but not deterministic CFL|nondeterminism DOES add power at PDA level — unlike finite automata
EQ7|minimal DFA is unique|for any regular language L, there is exactly one minimal DFA (up to isomorphism)|Myhill-Nerode theorem — states biject with equivalence classes of ≡_L|canonical representation exists — two DFAs can be compared by minimizing both
EQ8|two-way DFA ≡ DFA|two-way DFAs and one-way DFAs recognize same language class|Shepherdson (1959) — simulate head reversals with state encoding|bidirectional reading does not add power to finite automata

# minimization(id|step|description|rationale)
MN1|remove unreachable states|BFS/DFS from q₀ — delete any state not reachable|unreachable states cannot affect acceptance — dead weight
MN2|complete the DFA|add dead/trap state for any undefined transitions|minimization algorithms require total transition function — every (q, a) pair must have a target
MN3|initial partition|split Q into two blocks: P₀ = {F, Q \ F}|accept and non-accept states are distinguishable by definition (ε distinguishes them)
MN4|refinement step|for each block B and each symbol a ∈ Σ: if states in B transition on a to different blocks, split B|states that transition to distinguishable states are themselves distinguishable
MN5|iterate until stable|repeat MN4 until no block can be split|fixed point — all remaining states in same block are indistinguishable by any string
MN6|construct minimal DFA|each final block becomes one state, transitions between blocks, start state = block containing q₀, accept = blocks containing F members|quotient automaton — minimal DFA is Q/≡ where ≡ is the indistinguishability relation
MN7|verify|check L(D_min) = L(D_original) on test cases — formal guarantee from algorithm but implementation bugs exist|correctness check — minimize should never change the recognized language

# pumping_lemmas(id|lemma|applies_to|statement|use|limitations)
PL1|pumping lemma for regular languages|regular languages (Type 3)|if L is regular then ∃p ≥ 1 (pumping length) such that ∀w ∈ L with &#124;w&#124; ≥ p: w = xyz where &#124;xy&#124; ≤ p, &#124;y&#124; ≥ 1, and ∀i ≥ 0: xyⁱz ∈ L|proving a language is NOT regular — choose w, show no valid split xyz satisfies all three conditions for all i|necessary condition, not sufficient — some non-regular languages satisfy the pumping lemma (Myhill-Nerode is necessary and sufficient)
PL2|pumping lemma for context-free languages|context-free languages (Type 2)|if L is CF then ∃p ≥ 1 such that ∀w ∈ L with &#124;w&#124; ≥ p: w = uvxyz where &#124;vxy&#124; ≤ p, &#124;vy&#124; ≥ 1, and ∀i ≥ 0: uvⁱxyⁱz ∈ L|proving a language is NOT context-free — two pumpable sections v and y must pump together|same limitation — necessary not sufficient; Ogden's lemma is stronger variant

# theorems(id|theorem|statement|significance|proof_sketch)
TH1|Kleene's theorem|a language is regular iff it is recognized by some finite automaton iff it is described by some regular expression|establishes equivalence of three formalisms — automata, regex, grammars|Thompson (regex → NFA), subset construction (NFA → DFA), state elimination (DFA → regex)
TH2|Myhill-Nerode theorem|L is regular iff the equivalence relation ≡_L has finitely many equivalence classes; the number of classes equals the number of states in the minimal DFA|provides necessary AND sufficient condition for regularity — stronger than pumping lemma; gives minimal DFA size|define ≡_L, show finite index ↔ finite automaton, show classes biject with minimal DFA states
TH3|pumping lemma (regular)|stated in PL1|necessary condition for regularity — primary tool for proving non-regularity|if DFA has p states, any string of length ≥ p must revisit a state (pigeonhole) — the revisited loop is pumpable
TH4|DFA minimization uniqueness|the minimal DFA for any regular language is unique up to state renaming (isomorphism)|canonical form exists — enables comparison, equivalence checking|follows from Myhill-Nerode — states biject with equivalence classes, which are uniquely determined by L
TH5|subset construction exponential blowup|there exist NFAs with n states whose equivalent minimal DFA requires exactly 2ⁿ states|NFA-to-DFA conversion has unavoidable exponential worst case|language Lₙ = {w ∈ {0,1}* : the n-th symbol from the end is 1} — NFA needs n+1 states, minimal DFA needs 2ⁿ states
TH6|closure theorem (regular)|regular languages are closed under union, concatenation, Kleene star, complement, intersection, difference, reversal, homomorphism, inverse homomorphism|regular languages form a Boolean algebra and are robust under all common operations|individual constructions for each operation — product, Thompson, complement swap, etc.
TH7|decidability of regular language properties|emptiness, universality, equivalence, membership, finiteness of regular languages are all decidable|all fundamental questions about regular languages can be answered algorithmically|emptiness: check reachability of accept states; equivalence: minimize and compare; membership: simulate DFA
TH8|non-regularity of aⁿbⁿ|L = {aⁿbⁿ : n ≥ 0} is not regular|canonical example separating regular from context-free|pumping lemma: pump y in aaa...bbb — cannot maintain equal count — or Myhill-Nerode: infinitely many classes [aⁿ] since aⁿ and aᵐ are distinguishable by bⁿ
TH9|equivalence of acceptance modes (PDA)|acceptance by final state and acceptance by empty stack define the same class of languages for nondeterministic PDA|PDA design can use whichever acceptance mode is convenient|convert final-state PDA to empty-stack by adding ε-transitions from accept states that clear stack; reverse construction adds bottom marker
TH10|deterministic CF ⊊ CF|the class of deterministic context-free languages (recognized by DPDA) is a strict subset of context-free languages|nondeterminism genuinely adds power at the PDA level — unlike FSM level|{wwᴿ} is CF but not deterministic CF — DPDA cannot guess the middle of w
TH11|Rice's theorem (context for FSM)|every non-trivial property of the language of a Turing machine is undecidable|places upper bound on what can be decided — FSM properties are decidable because FSMs are weaker than TMs|reduction from halting problem — if property P is non-trivial, can construct TM whose language has P iff another TM halts

# regular_expressions(id|operator|meaning|fsm_equivalent|precedence)
RX1|a (literal)|matches single symbol a|single-state transition on a|highest (atom)
RX2|ε (empty string)|matches empty string|start state = accept state, no transitions|highest (atom)
RX3|∅ (empty set)|matches nothing|no accept states|highest (atom)
RX4|RS (concatenation)|matches string in L(R) followed by string in L(S)|connect accept states of R via ε to start state of S|second (after atoms, before union)
RX5|R&#124;S (union/alternation)|matches string in L(R) or L(S)|new start with ε-transitions to start states of R and S|lowest
RX6|R* (Kleene star)|matches zero or more repetitions of L(R)|ε-transition from accept back to start, new start/accept for ε case|third (after concatenation)
RX7|R⁺ (Kleene plus)|matches one or more repetitions — R⁺ = RR*|same as star but without ε-acceptance from start|third (same as star)
RX8|R? (optional)|matches zero or one of L(R) — R? = R&#124;ε|add ε-transition from start to accept|third (same as star)
RX9|[abc] (character class)|matches any single symbol in set — shorthand for a&#124;b&#124;c|parallel transitions from one state on each symbol|highest (atom-level shorthand)
RX10|. (wildcard)|matches any single symbol in Σ|transitions on every symbol in Σ from one state|highest (atom-level shorthand)
RX11|R{n} (exact count)|matches exactly n repetitions of L(R)|n copies concatenated|third
RX12|R{n,m} (bounded count)|matches n to m repetitions of L(R)|n required copies + (m-n) optional copies|third

# implementation_patterns(id|pattern|description|data_structure|when_to_use|language_agnostic_example)
IP1|transition table (2D array)|states as rows, symbols as columns, cells contain next state|array[num_states][num_symbols] → state_id|when alphabet and state count are known at compile time, maximum speed|table[LOCKED][COIN] = UNLOCKED; table[UNLOCKED][PUSH] = LOCKED
IP2|transition map (dictionary)|map from (state, symbol) to next state|HashMap<(State, Symbol), State>|when state/symbol space is sparse or dynamic|transitions.get((current, input)) → next_state
IP3|switch-case / if-else|nested switch on state then on input symbol|code itself (no separate data structure)|small FSMs, hand-written, when behavior per transition varies significantly|switch(state) { case LOCKED: switch(input) { case COIN: state = UNLOCKED; } }
IP4|state pattern (OOP)|each state is an object/class with handle(input) method — transitions return new state object|state interface + concrete state classes|when states have complex behavior beyond simple transitions, open-closed principle desired|interface State { State handle(Input i); } class Locked implements State { ... }
IP5|coroutine / generator|FSM expressed as sequential code with yield/await at each input consumption point|language coroutine / generator mechanism|when FSM has mostly linear flow with occasional branches — avoids state variable entirely|while true { yield; if input == COIN { yield; if input == PUSH { dispense() } } }
IP6|state register + ROM (hardware)|current state in flip-flop register, transition table in ROM/PLA, next state fed back|D flip-flops + combinational logic (ROM / PLA)|digital hardware — FPGA, ASIC, controller design|register holds state bits, ROM addressed by (state, input), outputs next state + Moore outputs
IP7|interpreter loop|generic FSM engine reads transition table from data — same engine runs any FSM|engine function + data table (JSON, CSV, binary)|when FSMs are data-driven — config files, protocol specs, user-defined workflows|engine(table, initial_state, input_stream) → final_state
IP8|regex engine (backtracking)|NFA simulated by recursive backtracking — try each path, backtrack on failure|call stack (implicit NFA)|simple implementation, most programming language regex engines|match(pattern, string) — exponential worst case on pathological patterns
IP9|regex engine (Thompson NFA)|NFA simulated by tracking set of current states — advance all states simultaneously|set of active states (explicit NFA simulation)|guaranteed O(nm) time — no backtracking — used in RE2, grep|step(active_states, input_symbol) → new_active_states
IP10|statechart runtime|hierarchical/concurrent state machine with history — requires runtime tracking substates, active regions, event queues|state tree + event queue + history maps|complex embedded systems, UI frameworks, protocol stacks|runtime.dispatch(event) → handles entry/exit/transition actions across hierarchy

# extended_models(id|model|extension_over|added_capability|formalism|applications)
XM1|statecharts (Harel)|flat FSM|hierarchy (nested states), concurrency (orthogonal regions), history (memory of last substate), guarded transitions, entry/exit actions|visual formalism with formal semantics — UML state machine diagrams derive from this|complex embedded systems, UI, protocol modeling — addresses state explosion
XM2|timed automata (Alur-Dill)|DFA/NFA|real-valued clocks, clock constraints on transitions and locations, clock resets|M = (Q, Σ, C, δ, q₀, F) where C = set of clocks, δ includes clock guards and resets|real-time systems verification, protocol timing, scheduling — UPPAAL tool
XM3|probabilistic finite automaton (PFA)|DFA|transitions have probabilities — δ: Q × Σ → probability distribution over Q|accepts string if probability of reaching accept state exceeds threshold|speech recognition, biological sequence analysis, stochastic modeling
XM4|weighted finite automaton (WFA)|DFA/NFA|transitions carry weights from a semiring — generalizes probability, cost, etc.|M = (Q, Σ, W, δ, λ, ρ) where W = semiring, λ = initial weights, ρ = final weights|natural language processing, speech recognition, image compression, shortest path
XM5|Büchi automaton|DFA/NFA|accepts infinite strings (ω-words) — acceptance requires visiting accept states infinitely often|M = (Q, Σ, δ, q₀, F) operating on infinite input strings|model checking, verification of reactive systems — LTL to Büchi conversion
XM6|Rabin/Streett/Muller automata|Büchi automaton|alternative acceptance conditions for ω-words — more expressive acceptance specifications|various acceptance conditions on infinite runs|verification, ω-regular language theory — some conditions more natural for certain properties
XM7|quantum finite automaton (QFA)|DFA|states are quantum superpositions, transitions are unitary operators, measurement determines acceptance|M = (Q, Σ, {Uₐ}, q₀, F) where Uₐ are unitary matrices|theoretical — some languages recognized with less states, some with bounded error only
XM8|alternating finite automaton (AFA)|NFA|transitions specify universal (∀) or existential (∃) branching — accept requires all branches accept (universal) or any branch (existential)|δ: Q × Σ → Boolean formula over Q|complexity theory, model checking — can be exponentially more succinct than NFA
XM9|register automaton|DFA/NFA|finite set of registers storing data values — can compare input with stored values|M = (Q, Σ_infinite, R, δ, q₀, F) where R = registers|processing data over infinite alphabets — database queries, XML processing
XM10|visibly pushdown automaton (VPA)|DPDA|push/pop determined by input symbol type (call/return/internal) — not by state|partition Σ into Σ_call, Σ_return, Σ_internal — stack operation fixed by symbol type|nested word processing, XML validation, structured program analysis — closed under all Boolean operations unlike general CFLs

# applications(id|application|domain|fsm_type_used|description)
AP1|lexical analysis (lexer/scanner)|compilers|DFA (from regex via Thompson + subset construction)|tokenizes source code — each token type is a regex, combined into single DFA — runs in O(n) on input length
AP2|regular expression matching|text processing|NFA or DFA|pattern search in strings — Thompson NFA guarantees linear time, backtracking NFA risks exponential
AP3|network protocol state machines|networking|Moore/Mealy/statechart|TCP connection states (LISTEN, SYN_SENT, ESTABLISHED, FIN_WAIT, etc.), HTTP request lifecycle, TLS handshake
AP4|digital circuit controllers|hardware|Moore (registered outputs) or Mealy (combinational outputs)|traffic light controllers, elevator controllers, vending machines, CPU control units, bus arbiters
AP5|game AI|game development|hierarchical FSM or statechart|NPC behavior — states like IDLE, PATROL, CHASE, ATTACK, FLEE — transitions on game events
AP6|UI navigation / dialog flow|user interface|statechart (for hierarchy and concurrency)|screen states, modal dialogs, wizard flows, form validation — entry/exit actions manage UI setup/teardown
AP7|communication protocol validation|formal verification|Büchi automaton / timed automaton|model checking — verify protocol never deadlocks, always eventually responds, respects timing constraints
AP8|biological sequence analysis|bioinformatics|HMM (probabilistic FSM variant)|gene finding, protein structure prediction, sequence alignment — Viterbi algorithm finds most probable state sequence
AP9|natural language processing|NLP|weighted FST|morphological analysis, phonological rules, speech recognition — composition of transducers models pipeline
AP10|control systems|embedded/industrial|Mealy/Moore/statechart|PLC ladder logic, SCADA states, automotive ECU modes, avionics mode logic
AP11|workflow engines|business process|statechart or Petri net (related)|order processing, approval chains, ticket lifecycle — states are workflow stages, transitions are actions/events
AP12|hardware design (HDL)|FPGA/ASIC|Moore or Mealy (coded in Verilog/VHDL)|state machines synthesized to flip-flops and combinational logic — backbone of digital design
AP13|string search algorithms|algorithms|DFA|Aho-Corasick multi-pattern search — trie with failure links forms DFA — O(n + m + z) where z = number of matches
AP14|model checking|formal verification|Büchi/timed/alternating automata|verify temporal logic properties of systems — system × ¬property = empty iff property holds
AP15|input validation|security/web|DFA|validate email addresses, phone numbers, credit card formats, input sanitization — reject malformed input
AP16|elevator controller|embedded systems|Moore machine|states: IDLE, MOVING_UP, MOVING_DOWN, DOOR_OPEN, DOOR_CLOSING — outputs: motor direction, door actuator, floor display
AP17|vending machine|embedded/teaching|Mealy machine|states track accumulated payment — transitions on coin insertion and product selection — output: dispense product, return change
AP18|traffic light controller|embedded systems|Moore machine with timer|states: NS_GREEN, NS_YELLOW, EW_GREEN, EW_YELLOW — outputs: light signals — transitions on timer expiry and sensor input
AP19|USB protocol|hardware/firmware|hierarchical FSM|device states: ATTACHED, POWERED, DEFAULT, ADDRESS, CONFIGURED, SUSPENDED — enumeration sequence
AP20|regex denial of service (ReDoS)|security|NFA (backtracking)|pathological regex + crafted input causes exponential backtracking in naive NFA engine — mitigated by Thompson NFA (IP9)

# design_rules(id|rule|rationale|violation_consequence)
DR1|every state must be reachable from start state|unreachable states waste resources and indicate design error|dead code — unreachable states may mask missing transitions or misunderstood requirements
DR2|every non-accept state must have path to at least one accept state (unless intentional trap)|states from which acceptance is impossible are usable only as explicit reject/dead states|unintentional trap — machine silently fails to accept valid input
DR3|transition function must be total for DFA|undefined transitions cause runtime errors or undefined behavior|crash, hang, or unpredictable behavior on unexpected input
DR4|avoid state explosion — use hierarchy, decomposition, or encoding|flat FSM with n binary variables has 2ⁿ states — composition multiplies state spaces|intractable number of states — unimplementable, unverifable, unmaintainable
DR5|every event must be handled in every state (explicit ignore if not relevant)|unhandled events cause undefined behavior or silent drops|lost input, inconsistent state, hard-to-reproduce bugs
DR6|entry and exit actions must be idempotent or guarded|re-entry to a state (self-transition or loop) re-executes entry action|resource leaks, duplicate initialization, corrupted state
DR7|guard conditions must be mutually exclusive and collectively exhaustive on each event|overlapping guards create nondeterminism in intended-deterministic machine; missing guards create unhandled cases|ambiguous behavior (overlapping) or unhandled input (gaps)
DR8|minimize state count — merge equivalent states|equivalent states waste memory, complicate maintenance, obscure intent|bloated design — harder to verify, debug, and document
DR9|separate concerns — one FSM per independent behavior axis, compose via statechart orthogonal regions|single flat FSM for multiple independent behaviors multiplies state space unnecessarily|state explosion — n states × m states for two independent axes instead of n + m
DR10|name states by meaning, not by number|state names document intent — numbers require lookup|unmaintainable — "what does state 7 mean?" — errors from misidentifying states
DR11|define explicit error/fault states and recovery transitions|systems encounter invalid input, timeouts, hardware faults — must handle gracefully|undefined behavior on error — machine hangs, crashes, or enters inconsistent state
DR12|self-transitions must be deliberate — not artifacts of incomplete transition function|self-transition means "consume input, stay in same state" — must be intended behavior|silent input consumption — machine appears to accept input but does nothing
DR13|use hierarchical states (statecharts) when multiple states share transition sets|repeated identical transitions across many states indicate missing superstate|maintenance burden — changing shared transition requires updating every copy
DR14|separate data path from control path — FSM handles control, not data processing|FSM states encode control mode, not data values — storing data in state names causes explosion|state space encodes data combinatorially — e.g., "counter_at_7" instead of state + counter variable
DR15|deadlock freedom — from every reachable state, there must exist a valid execution continuation (unless in a terminal/accept state)|deadlocked machine cannot make progress — user/system hangs|system freeze — requires external reset, violates liveness

# failure_modes(id|mode|cause|symptom|prevention)
FM1|state explosion|flat composition of independent behaviors, encoding data in states|state count becomes intractable — thousands or millions of states|use statecharts (XM1), orthogonal regions (DR9), separate data from control (DR14)
FM2|deadlock|circular wait — states waiting for each other, or no valid transition|machine stops processing, no output, system hangs|ensure all states have valid exit transitions or are explicitly terminal (DR15)
FM3|livelock|machine transitions continuously but makes no progress toward acceptance or useful output|machine runs but produces no result, cycles through same states repeatedly|add progress counters, timeout transitions, or fairness constraints
FM4|unreachable states|design error — states that no input sequence can reach|wasted resources, possibly missing intended behavior that should reach those states|verify reachability (DR1) — BFS/DFS from start state
FM5|unintentional nondeterminism|overlapping guard conditions, ambiguous transition priorities|unpredictable state selection, different behavior on different runs or implementations|mutual exclusion of guards (DR7), explicit priority ordering if intentional
FM6|missing transitions|incomplete transition function — some (state, input) pairs undefined|crash, undefined behavior, or silent input drop|total transition function (DR3, DR5) — explicit dead state if needed
FM7|state encoding error (hardware)|insufficient flip-flops, transient bit flip, metastability|machine enters illegal state — output undefined, behavior unpredictable|use one-hot encoding with error detection or safe encoding with illegal state detection and recovery
FM8|race condition (hardware)|multiple inputs change simultaneously, combinational feedback|momentary illegal state, glitched output (Mealy), metastability|synchronize inputs to clock, register all outputs (Moore preferred over Mealy for glitch freedom)
FM9|backtracking explosion (regex)|pathological regex pattern with nested quantifiers on overlapping patterns|exponential time — ReDoS (AP20)|use Thompson NFA simulation (IP9), avoid (a+)+ patterns, set match timeout
FM10|history state corruption|statechart history pseudostate records wrong substate after interrupted transition|wrong substate entered on history recall — behavior depends on previous interruption|validate history on entry, use deep vs shallow history deliberately, test interrupt scenarios
FM11|phantom state (implementation)|code path creates de facto state not in design — extra boolean flag, mode variable, or unintended code branch|behavior diverges from specification — shadow FSM exists in code|audit implementation against state diagram — every code-level state must correspond to design state
FM12|transition action side effects|actions during transition modify shared state, causing interference with concurrent FSMs or future transitions|order-dependent bugs, non-reproducible failures, violated invariants|minimize transition action scope, make actions idempotent where possible, avoid shared mutable state

# relationships(from|rel|to)
# component composition of machine types
CM1|component_of|MT1,MT2,MT3,MT4,MT5,MT6,MT7
CM2|component_of|MT1,MT2,MT3,MT4,MT5,MT6,MT7
CM3|component_of|MT1,MT4,MT5
CM4|component_of|MT2,MT3,MT6
CM5|component_of|MT1,MT2,MT3,MT4,MT5,MT6,MT7
CM6|component_of|MT1,MT2,MT3,MT6,MT7,MT10
CM7|component_of|MT4,MT5,MT10
CM8|component_of|MT4
CM9|component_of|MT5
CM10|component_of|MT6,MT7
CM11|component_of|MT6,MT7
# hierarchy containment
HI1|subtype_of|HI2
HI2|subtype_of|HI3
HI3|subtype_of|HI4
HI5|subtype_of|HI4
MT1|implements|HI1
MT2|implements|HI1
MT3|implements|HI1
MT6|implements|HI2
MT7|implements|HI2
MT8|implements|HI4
# machine type equivalences
MT1|equivalent_to|MT2
MT2|equivalent_to|MT3
MT4|equivalent_to|MT5
MT1|equivalent_to|MT9
# construction algorithm connections
CA1|converts|MT2,MT1
CA2|converts|MT3,MT2
CA3|converts|RX1-RX12,MT3
CA4|produces|MT1
CA5|produces|MT1
CA6|produces|MT1
CA7|requires|MT1,MT1
CA8|requires|MT1
CA9|converts|MT2,RX1-RX12
CA10|produces|MT1
CA11|requires|MT6,MT1
CA12|converts|RX1-RX12,MT1
# minimization sequence
MN1|enables|MN2
MN2|enables|MN3
MN3|enables|MN4
MN4|enables|MN5
MN5|enables|MN6
MN6|enables|MN7
# operations → closure properties
OP1|determined_by|CL1,CL11
OP2|determined_by|CL2,CL12
OP3|determined_by|CL3,CL13
OP4|determined_by|CL4,CL14
OP5|determined_by|CL5,CL15,CL16
OP6|determined_by|CL6,CL20
OP7|determined_by|CL7,CL19
OP8|determined_by|CL8,CL17
OP9|determined_by|CL9,CL18
OP10|determined_by|CL10
# theorems → concepts they establish
TH1|establishes|EQ3
TH2|establishes|EQ7,CA10
TH3|implements|PL1
TH4|establishes|EQ7
TH5|constrains|CA1
TH6|establishes|CL1-CL10
TH7|enables|DR1,DR2,DR8
TH8|distinguishes|HI1,HI2
TH10|distinguishes|MT6,MT7
# extended models → base models
XM1|extends|MT4,MT5
XM2|extends|MT1,MT2
XM3|extends|MT1
XM4|extends|MT1,MT2
XM5|extends|MT2
XM6|extends|XM5
XM7|extends|MT1
XM8|extends|MT2
XM9|extends|MT1
XM10|extends|MT7
# applications → machine types and implementation patterns
AP1|requires|MT1,CA1,CA3,IP1
AP2|requires|MT2,IP8,IP9
AP3|requires|MT4,MT5,XM1,IP3,IP10
AP4|requires|MT4,MT5,IP6
AP5|requires|XM1,IP4,IP10
AP6|requires|XM1,IP10
AP7|requires|XM2,XM5,IP10
AP8|requires|XM3
AP9|requires|XM4,MT10
AP10|requires|MT4,MT5,XM1,IP6
AP11|requires|XM1
AP12|requires|MT4,MT5,IP6
AP13|requires|MT1,IP1
AP14|requires|XM5,XM2
AP15|requires|MT1,IP1,IP7
AP16|requires|MT4,IP6
AP17|requires|MT5,IP3,IP6
AP18|requires|MT4,IP6,XM2
AP20|derives_from|IP8
AP20|prevented_by|IP9
# design rules → failure modes they prevent
DR1|prevents|FM4
DR3|prevents|FM6
DR4|prevents|FM1
DR5|prevents|FM6
DR7|prevents|FM5
DR8|implements|CA5,CA6
DR9|prevents|FM1
DR14|prevents|FM1
DR15|prevents|FM2
# failure modes → troubleshooting cross-reference
FM2|cross_ref|DP1
FM3|cross_ref|DP3
FM6|cross_ref|DP1,DP6
FM9|cross_ref|DP4
# foundations interdependencies
FO3|derives_from|FO1,FO2
FO4|subtype_of|FO3
FO5|derives_from|FO3
FO14|derives_from|FO1
FO15|derives_from|FO14
FO16|derives_from|FO1
FO18|operates_on|FO3
FO19|subtype_of|FO21
FO20|subtype_of|FO21
FO22|operates_on|FO3
FO23|operates_on|FO5
FO24|operates_on|FO1,FO5
# pumping lemmas → hierarchy levels
PL1|constrains|HI1
PL2|constrains|HI2
# equivalences → theorems
EQ1|established_by|TH1,CA1
EQ3|established_by|TH1
EQ7|established_by|TH2,TH4
EQ6|established_by|TH10

# section_index(section|title|ids)
1|Foundations — Alphabet, Strings, Languages|FO1-FO24
2|Machine Components|CM1-CM11
3|Machine Types|MT1-MT10
4|Chomsky Hierarchy|HI1-HI5
5|Closure Properties|CL1-CL20
6|Language Operations|OP1-OP10
7|Construction Algorithms|CA1-CA12
8|Equivalence Results|EQ1-EQ8
9|DFA Minimization|MN1-MN7
10|Pumping Lemmas|PL1-PL2
11|Key Theorems|TH1-TH11
12|Regular Expression Operators|RX1-RX12
13|Implementation Patterns|IP1-IP10
14|Extended Models|XM1-XM10
15|Applications|AP1-AP20
16|Design Rules|DR1-DR15
17|Failure Modes|FM1-FM12

# decode_legend
id_prefixes: FO=foundation, MT=machine_type, CM=component, OP=operation, CA=construction_algorithm, EQ=equivalence, CL=closure_property, PL=pumping_lemma, HI=hierarchy, IP=implementation_pattern, AP=application, DR=design_rule, FM=failure_mode, MN=minimization, RX=regular_expression, XM=extended_model, TH=theorem
rel_types: enables|requires|implements|constrains|component_of|subtype_of|equivalent_to|converts|produces|extends|derives_from|operates_on|determined_by|establishes|distinguishes|prevents|prevented_by|cross_ref|established_by
cross_ref_prefixes: DP=diagnostic_pattern (from TROUBLESHOOTING compaction)
hierarchy_notation: HI1 ⊂ HI2 ⊂ HI3 ⊂ HI4 means each language class is strict subset of the next
equivalence_notation: MT1 equivalent_to MT2 means they recognize the same class of languages (not the same machine)
closure_notation: closed=yes means applying operation to languages in class produces language still in class
complexity_notation: O(f(n)) is worst-case time or space as function of input size n or state count
formal_symbols: Σ=input alphabet, Q=states, δ=transition function, q₀=start state, F=accept states, Γ=stack/tape alphabet, Z₀=initial stack symbol, Λ=output alphabet, ε=empty string, P(Q)=powerset of Q, ∅=empty set/language
confidence: generated from LLM weights — reflects standard automata theory (Hopcroft/Ullman/Motwani, Sipser) — formal definitions verified against canonical textbook formulations

# relation_mapping(doc_rel|canonical_rel|notes)
enables|enables|exact match
requires|requires|exact match
implements|implements|exact match
constrains|constrains|exact match
component_of|part_of|exact semantic match
subtype_of|specializes|exact semantic match
equivalent_to|equivalent_to|exact match; symmetric
converts|transforms_to|algorithm converts NFA to DFA = transforms NFA to DFA form
produces|produces|exact match
extends|extends|exact match
derives_from|derived_from|exact match
operates_on|input_to|concatenation operates on strings = strings are input_to operation
determined_by|determined_by|exact match
establishes|founded|theorem establishes equivalence result = founded that result
distinguishes|distinguishes|exact match
prevents|prevents|exact match
prevented_by|mitigated_by|ReDoS prevented by Thompson NFA = mitigated_by
cross_ref|references|cross-domain link = references
established_by|result_of|equivalence established by theorem = result_of that theorem
