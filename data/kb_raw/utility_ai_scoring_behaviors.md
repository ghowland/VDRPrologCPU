# UTILITY AI — BEHAVIOR SCORING AND SELECTION SYSTEMS — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: foundations → scoring_curves → curve_parameters → normalization → considerations → reasoners → behavior_selection → compensation → dave_mark_fixup → weight_systems → composition → tuning_rules → failure_modes → applications → relationships → section_index

# foundations(id|concept|definition|significance)
FD1|utility|scalar value representing desirability of an action or state — higher = more desirable|core abstraction — all decisions reduced to comparing scalar values
FD2|consideration|single input axis mapped through a response curve to produce a score in [0,1]|atomic evaluation unit — one question about the world answered as a normalized score
FD3|behavior/action|candidate action the AI can take — scored by combining its considerations|the thing being selected — each behavior owns a set of considerations
FD4|reasoner|system that evaluates all candidate behaviors and selects one (or ranks them)|the decision-maker — runs all behaviors, picks highest-scoring
FD5|response curve|mathematical function mapping raw input value to [0,1] utility score|the shaping function — transforms "how much health do I have" into "how much do I care about healing"
FD6|input axis|raw world value feeding a consideration — health, distance, ammo, time, threat level|the sensory channel — what the consideration reads from the world
FD7|normalization|mapping raw input to [0,1] range before curve application|ensures all considerations operate on comparable scale — without normalization, curves behave unpredictably
FD8|weight|multiplier on a consideration or behavior — scales its influence on final score|allows designer to express relative importance — but interacts badly with multiplication (see FD14)
FD9|compensation|mechanism to prevent a single low-scoring consideration from zeroing the entire behavior score|addresses the multiplication collapse problem — essential for robust scoring
FD10|action selection|process of choosing which behavior to execute from scored candidates|the final decision — may be highest score, weighted random, or bucket-based
FD11|score|final utility value for a behavior after all considerations combined|the comparable value — all behaviors ranked by this number
FD12|context|world state snapshot read by considerations — positions, health, ammo, relationships, time|input to the entire system — must be fast to query
FD13|dual utility|running two or more parallel reasoners for different decision domains — e.g., "what to do" vs "where to go"|separates orthogonal decision axes — prevents combinatorial explosion of behaviors
FD14|weight-score interaction|weights applied to considerations that are then multiplied together create non-intuitive scaling — weight on one consideration warps all others' influence|key design trap — additive weights in multiplicative systems do not behave as designers expect

# scoring_curves(id|curve|formula|shape|use_case|parameters)
SC1|linear|y = mx + b, clamped to [0,1]|straight line — uniform response across range|distance falloff, simple proportional relationships|m=slope, b=y-intercept
SC2|quadratic (ease-in)|y = x²|slow start, fast finish — low sensitivity at low input, high sensitivity at high input|health concern — low worry when healthy, rapid escalation as health drops (if input inverted)|n/a (or y = xⁿ with n=2)
SC3|quadratic (ease-out)|y = 1-(1-x)²|fast start, slow finish — high sensitivity at low input, diminishing returns at high|ammo conservation — sharp concern at low ammo, plateaus when well-stocked|n/a
SC4|polynomial power|y = xⁿ|adjustable curvature — n<1 concave (ease-out), n=1 linear, n>1 convex (ease-in)|general purpose — n is the tuning knob for sensitivity distribution|n=exponent (0.5=sqrt, 2=square, 3=cube)
SC5|logistic/sigmoid|y = 1/(1+e^(-k(x-x₀)))|S-curve — flat at extremes, steep transition in middle|threshold decisions — "close enough to attack" with sharp transition zone|k=steepness, x₀=midpoint (inflection point)
SC6|log-natural|y = ln(x+1)/ln(max+1) or y = log_a(x) normalized|rapid initial rise, diminishing returns — concave|resource value — first 10 ammo very valuable, next 10 less so|base, normalization factor
SC7|exponential growth|y = (eᵏˣ - 1)/(eᵏ - 1) normalized to [0,1]|slow start, explosive finish — convex|threat response — calm at low threat, panic at high|k=growth rate
SC8|exponential decay|y = e^(-kx) (inverted: y = 1-e^(-kx) for rising)|rapid initial change, asymptotic tail|cooldown timers, urgency decay over time, diminishing returns|k=decay rate
SC9|bell/Gaussian|y = e^(-(x-μ)²/(2σ²))|peak at center, falls off both sides|preference for optimal range — "I want to be at medium distance, not too close, not too far"|μ=center (preferred value), σ=width (tolerance)
SC10|inverse bell|y = 1 - e^(-(x-μ)²/(2σ²))|trough at center, high at extremes|avoidance of a specific value — "anywhere but medium range"|μ=center (avoided value), σ=width
SC11|step/threshold|y = 0 if x < t, y = 1 if x ≥ t|binary — on/off at threshold|hard prerequisites — "do not attack unless weapon equipped"|t=threshold
SC12|smoothstep|y = 3x² - 2x³ (on normalized input)|smooth S-curve without exponential — cubic Hermite interpolation|smooth threshold without sigmoid's parameter sensitivity|implicit (operates on [0,1] input)
SC13|smootherstep|y = 6x⁵ - 15x⁴ + 10x³|smoother S-curve — zero first and second derivative at endpoints|extra-smooth transitions where smoothstep has visible inflection|implicit
SC14|sine ease-in|y = 1 - cos(x · π/2)|gentle start, accelerating finish|organic-feeling acceleration — less mechanical than quadratic|implicit
SC15|sine ease-out|y = sin(x · π/2)|fast start, gentle finish|organic deceleration|implicit
SC16|sine ease-in-out|y = -(cos(πx) - 1)/2|S-curve via trigonometry — smooth at both ends|alternative to sigmoid when parameter tuning is unwanted|implicit
SC17|piecewise linear|y = series of connected linear segments with defined breakpoints|arbitrary shape — designer specifies exact curve via control points|complex response shapes that don't fit standard curves — "care a lot at 20-40%, less at 40-80%, then a lot again"|breakpoint list [(x₀,y₀), (x₁,y₁), ...]
SC18|inverse/reciprocal|y = 1/x normalized and clamped|hyperbolic decay — very high at low input, rapidly diminishing|urgency inversely proportional to resource — "the less health I have, the more I want healing" with extreme urgency at near-zero|normalization range
SC19|logit|y = ln(x/(1-x)) normalized|inverse of sigmoid — S-shaped on [0,1] input, maps to (-∞,+∞) before normalization|converting probability-like inputs to unbounded scores for additive systems|normalization range
SC20|bounded exponential|y = (1-e^(-kx))/(1-e^(-k))|guaranteed [0,1] output for [0,1] input — exponential rise with built-in normalization|same as SC8 rising variant but with guaranteed bounds — no clamp needed|k=curvature (k>0 concave, k<0 convex)
SC21|parabolic trough|y = 4(x-0.5)²|U-shaped — minimum at center, maximum at extremes|flee-or-charge behavior — worst outcome is medium range, prefer extremes|vertex at x=0.5
SC22|cosine decay|y = (1 + cos(πx))/2|smooth decay from 1 to 0 over [0,1]|smooth falloff alternative to linear — zero derivative at endpoints|implicit

# curve_parameters(id|parameter|affects|tuning_effect|common_range|pitfall)
CP1|slope (m)|linear SC1|steepness of response — higher m = more sensitivity|0.5-5.0|slope > 1/(input_range) causes clipping at 1.0 before input maximum
CP2|exponent (n)|polynomial SC4|curvature — n<1 concave, n=1 linear, n>1 convex|0.2-5.0|n near 0 collapses curve to near-constant 1; very high n creates near-step function
CP3|steepness (k)|sigmoid SC5, exponential SC7/SC8|transition sharpness — higher k = sharper/steeper|1-20 for sigmoid, 0.1-5.0 for exponential|very high k makes sigmoid behave as step — loses utility of gradual transition
CP4|midpoint (x₀)|sigmoid SC5|location of transition center on input axis|depends on input range — typically 0.3-0.7 on normalized input|off-center midpoint means one tail is very short — asymmetric response
CP5|center (μ)|Gaussian SC9/SC10|location of peak or trough|domain-specific — e.g., 15m for preferred combat distance|center outside normalized range makes curve monotonic — becomes half-Gaussian
CP6|width (σ)|Gaussian SC9/SC10|tolerance around center — larger σ = broader peak/trough|domain-specific — typically 10-30% of input range|very small σ creates spike/notch — functionally a step function at center
CP7|breakpoints|piecewise linear SC17|shape of curve — each breakpoint anchors a vertex|minimum 2 (start, end), typically 3-6|too many breakpoints = overfitting to specific scenarios; breakpoints must be sorted by x
CP8|decay rate (k)|exponential decay SC8|half-life of value — higher k = faster decay|0.5-10.0|k too high makes value negligible almost immediately — effectively a step at x=0

# normalization(id|method|formula|when_to_use|pitfall)
NM1|min-max (static)|y = (x - x_min) / (x_max - x_min)|when input range is known and fixed — health (0-100), ammo (0-max_clip)|if actual value exceeds expected range, output goes outside [0,1] — must clamp
NM2|min-max (dynamic)|y = (x - observed_min) / (observed_max - observed_min)|when input range unknown or varies — distances, entity counts|recalibrates as new extremes observed — same input gives different output at different times — non-stationary
NM3|bookend|map input endpoints to 0 and 1, apply curve between|designer specifies "this input range maps to this output range"|if input falls outside bookends, behavior undefined — clamp or extrapolate
NM4|z-score|y = (x - μ) / σ then map to [0,1]|when input is normally distributed — group statistics|requires knowledge of mean and standard deviation — not useful for single-instance inputs
NM5|rank-order|y = rank(x) / count|when absolute value less important than relative position — "am I the closest enemy"|tied values get same rank — may need tie-breaking; expensive to compute for large sets
NM6|sigmoid normalization|y = 1/(1+e^(-k(x-μ))) where μ and k derived from expected range|when soft clamping desired — extreme inputs compressed, mid-range preserved|parameters must match input distribution — mismatched μ wastes dynamic range
NM7|clamp|y = max(0, min(1, x))|after any normalization — safety net|hides out-of-range inputs — may mask bugs; values pile up at 0 or 1 losing discrimination

# considerations(id|name|input_axis|typical_curve|rationale|domain)
CN1|health urgency|current_health / max_health|inverted linear or ease-in (SC2)|low health → high urgency to heal — curve shape determines panic threshold|combat AI
CN2|ammo conservation|current_ammo / max_ammo|ease-out (SC3) or log (SC6)|sharp concern at low ammo, diminishing returns when well-stocked|combat AI
CN3|distance to target|distance normalized to engagement range|sigmoid (SC5) or Gaussian (SC9)|sigmoid for "close enough to attack"; Gaussian for "preferred engagement range"|combat AI
CN4|threat level|aggregated danger assessment (enemy count, weapon type, exposure)|exponential (SC7) or sigmoid (SC5)|low threat = calm, high threat = flee or find cover — shape determines panic onset|combat AI
CN5|time since last action|elapsed time normalized to cooldown period|linear (SC1) or bounded exponential (SC20)|prevents repeated actions — score increases as cooldown expires|general
CN6|target visibility|line-of-sight clarity (0=occluded, 1=fully visible)|step (SC11) or smoothstep (SC12)|hard or soft prerequisite for ranged attack|combat AI
CN7|group need|assessment of squad/group deficiency — needs healer, needs cover fire|linear (SC1)|cooperative AI — score increases when group lacks this behavior|squad AI
CN8|resource value|value of pickup or resource relative to current inventory|log (SC6)|first aid kit very valuable when wounded, less so when healthy — diminishing returns|exploration AI
CN9|path safety|danger along route to destination (exposure, enemy positions)|inverted sigmoid (1 - SC5)|low danger = high score for this path — sharp cutoff at danger threshold|navigation AI
CN10|personality modifier|static or slowly-changing value representing character tendency|linear scaling (SC1, slope < 1)|makes different AI agents prefer different behaviors — coward flees sooner, berserker attacks more|character differentiation
CN11|boredom/variety|time since this behavior type was last selected|ease-in (SC2)|prevents repetitive behavior — boredom increases over time, resets on selection|general
CN12|opportunity|fleeting condition — flanking angle, enemy reloading, door opening|step (SC11) or sharp sigmoid (SC5, high k)|seize opportunities — binary or near-binary "is opportunity present"|tactical AI
CN13|emotional state|anger, fear, confidence as floating values|varies — anger might use SC7, fear SC5|modifies behavior selection without new behaviors — angry agent values attacking higher|emotional AI
CN14|environmental awareness|weather, lighting, terrain advantage|linear or piecewise (SC17)|sniper favors high ground (terrain score), stealth favors darkness (lighting score)|tactical AI
CN15|social relationship|faction standing, trust, familiarity|piecewise linear (SC17)|determines cooperative vs hostile vs neutral behavior sets|social AI

# reasoners(id|type|description|scoring_method|selection_method|pros_cons)
RS1|single-bucket highest score|all behaviors scored, highest wins|each behavior's considerations combined (multiply or add)|argmax of final scores|simple, predictable; greedy — no variety, prone to oscillation between near-equal scores
RS2|dual-bucket (absolute + relative)|first pass: absolute threshold eliminates unviable behaviors; second pass: score remaining, select highest|threshold check then full scoring|eliminate-then-argmax|prevents nonsensical selections (attack when no weapon); adds computation
RS3|weighted random from top N|score all, select randomly from top N weighted by score|full scoring|roulette wheel selection on top N|variety — prevents predictability; may select suboptimal; N must be tuned
RS4|categorical/bucket reasoner|behaviors grouped into priority buckets (survival, combat, utility, idle); highest non-empty bucket evaluated first|only score behaviors in highest active bucket|argmax within active bucket|prevents low-priority behavior from outscoring survival; rigid — bucket boundaries designed not tuned
RS5|hierarchical/layered|multiple reasoners in layers — strategic, tactical, moment-to-moment — each constrains the next|each layer scores independently within constraints from layer above|top-down constraint propagation|handles multi-scale decisions; complex to debug; layer interfaces must be clean
RS6|parallel reasoners (dual utility)|independent reasoners for orthogonal decisions — "what action" and "what target" and "where to move"|each reasoner scores its own behavior set independently|independent argmax per reasoner, results combined|prevents combinatorial explosion; requires decisions to be truly independent
RS7|Markov blanket reasoner|each behavior only evaluates considerations relevant to its decision — not all world state|selective consideration evaluation|argmax of scored behaviors|efficient — skips irrelevant evaluations; requires careful consideration assignment

# behavior_selection(id|method|description|when_to_use|pitfall)
BS1|argmax (greedy)|select behavior with highest score|deterministic, predictable AI — player can learn patterns|oscillation when two behaviors have near-equal scores — add hysteresis or momentum
BS2|weighted random (roulette)|probability of selection proportional to score|variety desired — non-predictable AI|very low-scoring behaviors still occasionally selected — may look stupid; use threshold
BS3|weighted random top-N|only top N behaviors eligible for random selection|balance between quality and variety|N too small = deterministic; N too large = random; typically N=3-5
BS4|Boltzmann/softmax selection|P(behavior_i) = e^(score_i/T) / Σe^(score_j/T) where T = temperature|controlled randomness — T→0 becomes greedy, T→∞ becomes uniform random|temperature must be tuned — too high = random, too low = greedy; scores must be on comparable scale
BS5|hysteresis/momentum|current behavior gets score bonus — must be beaten by margin to switch|prevent oscillation between near-equal behaviors|bonus too high = stuck in behavior too long; too low = still oscillates; typically 5-15% bonus
BS6|priority interrupt|high-priority behaviors can preempt current behavior mid-execution|urgent reactions — dodge, flee, respond to damage|excessive interruption prevents completing any behavior — add interrupt cooldown
BS7|commitment/minimum duration|once selected, behavior runs for minimum time before re-evaluation|prevent behavior switching every frame|minimum too long = unresponsive to changing conditions; too short = no benefit
BS8|score threshold gate|behavior only eligible if score exceeds minimum threshold|eliminate clearly inappropriate behaviors before scoring overhead|threshold too high = no behaviors eligible (freezes); too low = no filtering benefit

# compensation(id|method|formula|description|dave_mark_attribution|pro_con)
CM1|no compensation|final = ∏(score_i)|pure multiplication — any single zero kills entire behavior score|pre-fix-up baseline|simple; one bad consideration vetoes entire behavior — often too harsh
CM2|additive mean|final = (Σ score_i) / n|average of all considerations|not Dave Mark — traditional alternative|no veto problem; loses discrimination — high score in one consideration compensates for zero in another
CM3|weighted sum|final = Σ(w_i × score_i) / Σ(w_i)|weighted average — each consideration has designer-assigned weight|not Dave Mark — traditional alternative|explicit priority; weights interact unintuitive when many considerations; tuning is O(n²) interactions
CM4|multiplicative with compensation factor|modification_factor = (1 - (1/n)) where n = number of considerations; make_up_value = (1 - score_i) × modification_factor; final_score_i = score_i + (make_up_value × score_i)|Dave Mark's compensation system — each low score is partially "made up" by a bonus proportional to how many other considerations exist|Dave Mark — GDC talks, "Behavioral Mathematics for Game AI"|preserves multiplicative discrimination while preventing single-zero veto; compensation increases with consideration count; still allows very low scores to drag down but not annihilate
CM5|geometric mean|final = (∏ score_i)^(1/n)|nth root of product — normalizes for consideration count|variation discussed in utility AI community|fair regardless of consideration count; still zeroes on any zero — use with epsilon floor
CM6|compensated product with epsilon floor|score_i = max(ε, raw_score_i) then multiply|floor prevents true zero — minimum contribution always present|common practical approach|prevents zero-veto; ε value matters — too high = consideration becomes irrelevant; typically ε = 0.01-0.05
CM7|power mean|final = (Σ(score_i^p) / n)^(1/p)|p=-∞ = min, p=-1 = harmonic, p=0 = geometric, p=1 = arithmetic, p=∞ = max|mathematical generalization — not commonly discussed in game AI but encompasses most approaches|single parameter p controls compensation behavior — powerful but abstract for designers
CM8|min-then-multiply|final = min(all scores) × ∏(all scores except min)|worst score has outsized influence but doesn't zero others|variation in utility AI practice|highlights worst consideration while preserving overall quality; complex to explain to designers
CM9|Dave Mark full compensation pipeline|1) evaluate each consideration; 2) compute modification_factor; 3) apply make_up_value; 4) multiply compensated scores; 5) apply behavior-level weight|complete pipeline as presented in GDC talks|Dave Mark — canonical formulation|see CM4 for formula; the key insight is step 3 — compensation is proportional to both the deficit AND the consideration count

# dave_mark_fixup(id|concept|description|rationale|formula_or_rule)
DM1|the multiplication problem|when combining considerations by multiplication, any single score near zero drives the entire product to near zero regardless of all other scores|in practice, one irrelevant-but-low consideration vetoes a behavior that should score well on all other axes|example: attack score 0.9 × ammo score 0.8 × health score 0.7 × boredom score 0.1 = 0.050 — boredom kills a perfectly good attack
DM2|why not just add|addition loses discrimination — a behavior scoring 0.9 on one axis and 0.0 on all others can outscore a behavior scoring 0.5 on all axes|multiplication naturally requires ALL considerations to be favorable — this is a feature, not a bug — but it's too aggressive
DM3|the compensation insight|partially compensate each consideration's deficit based on how many considerations exist — more considerations = more compensation per consideration|with many considerations, each individual one should have less veto power — the system should be more forgiving as complexity increases
DM4|modification factor|computed per-behavior based on number of considerations n|represents maximum allowable "make-up" proportion|modification_factor = (1 - 1/n) — approaches 1 as n increases; for n=2: 0.5, n=3: 0.667, n=4: 0.75, n=5: 0.8
DM5|make-up value|computed per-consideration based on its deficit and the modification factor|the amount added back to compensate for this consideration's shortfall|make_up_value = (1 - score_i) × modification_factor
DM6|compensated score|original score plus its make-up value, scaled|the score used in final multiplication after compensation|compensated_i = score_i + (make_up_value × score_i) = score_i × (1 + (1 - score_i) × modification_factor)
DM7|final product|multiply all compensated scores together|the behavior's final utility value|final = ∏(compensated_i) for all considerations in this behavior
DM8|effect on zero scores|a true zero still zeros the product — compensation makes up the deficit but multiplies by zero|designer must decide: use epsilon floor (CM6) to prevent hard zero, or allow zero as absolute veto|compensated zero: 0 × (1 + 1 × mf) = 0 — floor at ε = 0.01 gives 0.01 × (1 + 0.99 × mf) ≈ small positive
DM9|effect on perfect scores|score of 1.0 gets zero make-up — no compensation needed|compensation only activates on deficits — perfect scores pass through unchanged|compensated 1.0: 1.0 × (1 + 0 × mf) = 1.0
DM10|effect on consideration count|more considerations → higher modification factor → more compensation per consideration → softer multiplication|system self-adjusts — prevents punishment for adding more considerations|n=2: mf=0.50, n=3: mf=0.67, n=4: mf=0.75, n=8: mf=0.875 — eight considerations are very forgiving
DM11|worked example — 4 considerations|scores: [0.9, 0.8, 0.3, 0.6], n=4, mf=0.75|uncompensated product: 0.9×0.8×0.3×0.6 = 0.130; compensated: 0.9×(1+0.1×0.75)=0.968, 0.8×(1+0.2×0.75)=0.920, 0.3×(1+0.7×0.75)=0.458, 0.6×(1+0.4×0.75)=0.780; product: 0.968×0.920×0.458×0.780 = 0.318|0.130 → 0.318 — the 0.3 consideration still drags the score down significantly but doesn't annihilate it
DM12|when NOT to compensate|some considerations should retain veto power — "has weapon equipped" should be a hard gate, not compensated|not all considerations are soft preferences — some are prerequisites|use binary gate considerations (score 0 or 1 with step curve SC11) outside the compensation system, or accept that ε floor + compensation still produces very low scores on hard requirements

# weight_systems(id|system|description|behavior|pitfall)
WS1|per-consideration weight|each consideration has a weight multiplied with its score before combination|amplifies or dampens individual consideration influence|in multiplicative systems, weight on one consideration affects final score non-linearly — weight of 2 on one consideration does NOT double its "importance" in product
WS2|per-behavior weight|each behavior has a weight multiplied with its final combined score|designer bias toward or against entire behaviors — "prefer attack over flee by 1.2x"|shifts all behaviors' scores — can override consideration-based ranking entirely if weight difference is large
WS3|personality weights|per-agent modification of consideration or behavior weights|creates distinct characters — "cowardly guard" has high weight on flee considerations|per-agent tuning — exponential designer workload unless personality is defined as small number of axes
WS4|contextual weights|weights that change based on game state — e.g., "weight combat behaviors higher when in combat zone"|adaptive priority — behavior set shifts with context|implicit mode switching — hard to debug when weights change silently; prefer explicit behavior-set switching
WS5|normalized weights|weights that sum to 1.0 within a behavior's consideration set|ensures weights represent proportional importance|re-normalize when adding or removing considerations — easy to forget, breaks tuning
WS6|logarithmic weight space|weights expressed as log values, added (equivalent to multiplying in linear space)|makes multiplicative weight combination additive — easier to reason about|unintuitive for designers — "weight of -2 means this consideration is 0.135× as important"

# composition(id|method|formula|character|when_to_use)
CP1|pure multiplication|final = ∏(score_i)|AND-like — all must be high; single low score dominates|when all considerations are genuine prerequisites — every axis matters equally
CP2|pure addition (mean)|final = Σ(score_i) / n|OR-like — high in any one axis suffices; compensatory|when considerations are alternatives — being great at one compensates for weakness in another
CP3|weighted sum|final = Σ(w_i × score_i)|weighted OR — designer controls relative importance additively|explicit priority ranking; prone to weight-tuning spiral
CP4|compensated multiplication (Dave Mark)|see CM4/DM6-DM7|soft AND — all must be reasonable, but no single zero vetoes|default recommended approach — balances discrimination with robustness
CP5|min (worst score)|final = min(score_i)|bottleneck — limited by weakest consideration|when the limiting factor IS the score — e.g., feasibility gated by hardest requirement
CP6|max (best score)|final = max(score_i)|optimistic — best single consideration determines score|when any one good reason suffices — used for opportunity detection
CP7|weighted product|final = ∏(score_i ^ w_i)|AND-like with per-consideration exponent — weight controls curvature not linear scale|mathematically cleaner than weighted sum for multiplicative systems — weight directly controls power
CP8|nested/hierarchical|group considerations into sub-groups, combine within group, then combine across groups|groups are mini-reasoners — allows different combination per group|complex decisions with natural groupings — "combat readiness" (sub-scores) feeds into "should I fight"

# tuning_rules(id|rule|rationale|violation_consequence)
TR1|normalize all inputs to [0,1] before applying curves|curves are designed for [0,1] domain — unnormalized input produces unpredictable curve output|scores outside expected range, curves operating on wrong region, meaningless final scores
TR2|evaluate response curves visually before shipping — graph every curve over its input range|mathematical formula does not convey behavior intuitively — the graph IS the design|curves that look right in formula may have dead zones, clipping, or unexpected inflections
TR3|test behaviors with all considerations at 0, all at 1, and all at 0.5 — verify extremes and midpoint|boundary conditions reveal curve interaction problems — multiplication at midpoint: 0.5⁴ = 0.0625 is surprisingly low|unexpectedly low or high scores at common operating points
TR4|never tune weights to fix a curve problem — fix the curve|if a consideration produces wrong relative scores, the response curve is wrong — weights cannot fix shape|weight-tuning spiral — adjusting one weight requires re-adjusting others; exponential complexity
TR5|keep consideration count per behavior between 2 and 8|fewer than 2 = no meaningful trade-off; more than 8 = scores collapse toward zero (multiplication) or center (addition)|too few = trivial decisions; too many = all behaviors score similarly — no discrimination
TR6|log the decision process — record each consideration's raw input, normalized input, curve output, compensation, and final score|debugging utility AI without logs is guessing — the chain from world state to decision must be traceable|untraceable decisions — "why did the AI do that?" cannot be answered; tuning becomes trial-and-error
TR7|create a visualization tool showing all behaviors' scores in real time|static logging is necessary but insufficient — dynamic visualization reveals patterns, oscillation, score clustering|slow tuning iteration — designers cannot see the effect of changes in real time
TR8|test with adversarial inputs — values at 0, at 1, at boundaries, at NaN, at negative|edge cases in normalization and curves cause crashes, infinities, or NaN propagation|NaN in one consideration propagates through multiplication to corrupt all behavior scores
TR9|use Dave Mark compensation (CM4) as default — switch to alternatives only with specific reason|compensation solves the most common practical problem (multiplication collapse) with minimal tuning burden|reinventing compensation ad-hoc per project — inconsistent, harder to debug
TR10|never let a consideration score go truly to zero unless it represents an absolute veto|zero in multiplication annihilates all other information — 10 perfect scores with one zero = zero|behavior that should be viable scores exactly zero — invisible in selection
TR11|separate hard gates from soft preferences|gates (has weapon, is alive, has mana) are binary prerequisites — soft preferences (distance, health, mood) are continuous|mixing gates and preferences in one multiplication conflates qualitatively different concerns — gates should eliminate, preferences should rank
TR12|when adding a new consideration to a behavior, re-evaluate compensation factor and test|adding a consideration changes the modification factor and may shift relative scores of all behaviors|new consideration inadvertently changes existing behavior rankings — regression in tuned behaviors
TR13|use consistent curve types across similar considerations in different behaviors|distance-to-target should use same curve type whether in "attack" or "retreat" — shape consistency prevents confusion|same input axis producing different score shapes in different behaviors — unintuitive, hard to debug
TR14|score the "do nothing" / idle behavior|without an explicit idle/default behavior, the lowest non-zero score always wins — AI never rests|AI constantly acts — never pauses, looks unnatural, exhausts action resources

# failure_modes(id|mode|cause|symptom|prevention)
FM1|score collapse|too many considerations multiplied without compensation|all behaviors score near zero — selection becomes effectively random|use compensation (CM4), reduce consideration count (TR5), use epsilon floor (CM6)
FM2|oscillation/flickering|two behaviors with near-equal scores alternating every frame|AI switches behavior rapidly — visually looks broken, never completes an action|hysteresis (BS5), minimum commitment time (BS7), score momentum
FM3|dominant behavior|one behavior's considerations always outscore all others|AI only ever does one thing — e.g., always attacks, never heals or retreats|review curve shapes — dominant behavior likely has inflated curve output in common operating range; re-tune curves not weights (TR4)
FM4|dead behavior|behavior exists but never selected — one consideration always near zero|behavior never fires — wasted design, missing intended AI capability|log consideration scores (TR6) — find the killing consideration, fix its curve or remove it
FM5|NaN/infinity propagation|division by zero in normalization, log of zero, exp overflow|all scores become NaN — AI freezes or behaves randomly|clamp all inputs, use safe math (max(ε, x) before log), check for NaN after each computation (TR8)
FM6|weight tuning spiral|adjusting weight on consideration A requires re-adjusting B, C, D...|exponentially increasing tuning time, fragile balance that breaks when new behaviors added|fix curves first (TR4), use compensation instead of weights to handle multiplication problems
FM7|consideration independence violation|two considerations measure correlated inputs — e.g., "distance to enemy" and "time to reach enemy"|redundant influence — effectively double-counting one factor|identify correlated axes, merge into single consideration or orthogonalize inputs
FM8|context staleness|considerations read cached world state that is out of date|AI makes decisions based on stale information — attacks dead enemy, heals at full health|refresh context before each evaluation cycle, or timestamp and invalidate stale data
FM9|bucket boundary artifacts|in categorical reasoner (RS4), behavior scores just below bucket threshold never selected even if globally best|unnatural behavior gaps at bucket transitions|use soft bucket boundaries or allow limited cross-bucket competition
FM10|personality collapse|personality weights too extreme — override all situational considerations|all agents of same personality type behave identically regardless of situation|personality weights should modify, not dominate — keep personality weight influence < 30% of total score range
FM11|curve dead zone|portion of input range where curve output is effectively constant (0 or 1)|consideration provides no discrimination over that input range — wasted evaluation|review curve graphs (TR2) — ensure curve has meaningful slope over the expected operating range of the input
FM12|compensation over-correction|too many considerations with high compensation factor makes all scores converge|all behaviors score similarly — discrimination lost|monitor score spread — if all behaviors within 10% of each other, compensation may be too aggressive; reduce consideration count or accept some multiplication harshness

# applications(id|application|domain|notes)
AP1|combat AI — shooter|FPS/TPS games|behaviors: attack, take cover, reload, heal, flank, retreat, melee — considerations: health, ammo, distance, threat, cover availability, target vulnerability
AP2|squad/team AI|tactical games|dual utility: individual behavior + group role assignment — considerations include group need (CN7) and role coverage
AP3|NPC daily routines|open world/RPG|behaviors: eat, sleep, work, socialize, shop, wander — considerations: hunger, fatigue, time of day, social need, proximity to locations
AP4|strategy game unit AI|RTS|behaviors: gather, build, attack, defend, explore, repair — considerations: resource need, threat proximity, construction queue, unexplored area
AP5|autonomous vehicles|robotics/simulation|behaviors: lane follow, lane change, brake, accelerate, yield — considerations: distance to lead vehicle, lane availability, speed delta, priority rules
AP6|dialogue/social AI|RPG/social simulation|behaviors: greet, ask question, share gossip, insult, flatter, request aid — considerations: relationship, mood, topic relevance, personality
AP7|creature/animal AI|simulation/pet games|behaviors: eat, sleep, play, explore, flee, mate, groom — considerations: hunger, fatigue, curiosity, fear, social need — Gaussian curves for homeostatic needs
AP8|tower defense AI|tower defense|behaviors: target selection among multiple enemies — considerations: distance, health, speed, armor type, path position — one reasoner per tower
AP9|boss AI|action games|hierarchical reasoner — strategic layer (phase selection based on health thresholds), tactical layer (attack pattern selection), moment layer (dodge/block reactions)
AP10|economic AI|simulation/management|behaviors: buy, sell, produce, invest, hoard — considerations: price, inventory, demand forecast, risk, cash reserve — sigmoid curves for price sensitivity

# relationships(from|rel|to)
# foundation dependencies
FD2|requires|FD5,FD6,FD7
FD3|requires|FD2
FD4|requires|FD3,FD10
FD9|addresses|FD14
FD11|derives_from|FD2,FD3
FD13|implements|RS6
FD14|constrains|WS1,CP1
# scoring curve taxonomy
SC2|subtype_of|SC4
SC3|subtype_of|SC4
SC4|generalizes|SC1,SC2,SC3
SC5|implements|SC12,SC13
SC9|opposes|SC10
SC11|subtype_of|SC5
SC17|generalizes|SC1
SC20|subtype_of|SC8
SC21|opposes|SC9
# curve → parameter dependency
SC1|requires|CP1
SC4|requires|CP2
SC5|requires|CP3,CP4
SC7|requires|CP3
SC8|requires|CP8
SC9|requires|CP5,CP6
SC10|requires|CP5,CP6
SC17|requires|CP7
# normalization → considerations
NM1|enables|CN1,CN2,CN5,CN6
NM2|enables|CN3,CN4
NM3|enables|CN3,CN14
NM5|enables|CN4
NM7|constrains|NM1,NM2,NM3,NM4,NM5,NM6
# consideration → curve typical pairings
CN1|uses|SC2,SC1
CN2|uses|SC3,SC6
CN3|uses|SC5,SC9
CN4|uses|SC7,SC5
CN5|uses|SC1,SC20
CN6|uses|SC11,SC12
CN7|uses|SC1
CN8|uses|SC6
CN9|uses|SC5
CN10|uses|SC1
CN11|uses|SC2
CN12|uses|SC11,SC5
CN13|uses|SC7,SC5
# reasoner → selection method
RS1|uses|BS1
RS2|uses|BS8,BS1
RS3|uses|BS3
RS4|uses|BS8,BS1
RS5|uses|BS1,BS6
RS6|uses|BS1
# compensation relationships
CM1|precedes|CM4
CM4|implements|DM3,DM4,DM5,DM6,DM7
CM6|extends|CM1
CM7|generalizes|CM1,CM2,CM5
CM9|implements|DM1-DM12
# Dave Mark fixup internal
DM1|motivates|DM3
DM2|motivates|DM3
DM3|enables|DM4
DM4|enables|DM5
DM5|enables|DM6
DM6|enables|DM7
DM8|constrains|DM7
DM9|validates|DM6
DM10|derives_from|DM4
DM12|constrains|DM6
# composition → compensation
CP1|requires|CM1
CP2|implements|CM2
CP3|implements|CM3
CP4|implements|CM4
CP5|subtype_of|CM7
CP6|opposes|CP5
CP7|extends|CP1
# tuning rules → failure mode prevention
TR1|prevents|FM5
TR2|prevents|FM11
TR4|prevents|FM6
TR5|prevents|FM1,FM12
TR6|enables|FM3,FM4
TR8|prevents|FM5
TR9|implements|CM4
TR10|prevents|FM1
TR11|prevents|FM1
TR12|constrains|CM4
TR14|prevents|FM3
# failure mode → resolution via methods
FM1|resolved_by|CM4,CM6,TR5
FM2|resolved_by|BS5,BS7
FM3|resolved_by|TR4,TR2
FM4|resolved_by|TR6,TR2
FM5|resolved_by|TR8,NM7
FM6|resolved_by|TR4
FM7|resolved_by|CN1
FM10|resolved_by|WS3
FM12|resolved_by|TR5
# application → reasoner type
AP1|uses|RS2,RS4
AP2|uses|RS6
AP3|uses|RS1,RS3
AP4|uses|RS4
AP5|uses|RS4,RS5
AP6|uses|RS3
AP7|uses|RS1
AP8|uses|RS1
AP9|uses|RS5
AP10|uses|RS1
# cross-references to FSM compaction
RS4|cross_ref|MT4
AP9|cross_ref|XM1
BS6|cross_ref|MT5
# cross-references to TROUBLESHOOTING compaction
TR6|cross_ref|ME16
FM5|cross_ref|DP1

# section_index(section|title|ids)
1|Foundations|FD1-FD14
2|Scoring Curves|SC1-SC22
3|Curve Parameters|CP1-CP8
4|Normalization Methods|NM1-NM7
5|Considerations|CN1-CN15
6|Reasoner Types|RS1-RS7
7|Behavior Selection Methods|BS1-BS8
8|Compensation Systems|CM1-CM9
9|Dave Mark Fix-Up|DM1-DM12
10|Weight Systems|WS1-WS6
11|Score Composition Methods|CP1-CP8
12|Tuning Rules|TR1-TR14
13|Failure Modes|FM1-FM12
14|Applications|AP1-AP10

# decode_legend
id_prefixes: FD=foundation, SC=scoring_curve, CP=curve_parameter (section 3) or composition (section 11 — disambiguated by context), NM=normalization, CN=consideration, RS=reasoner, BS=behavior_selection, CM=compensation, DM=dave_mark_fixup, WS=weight_system, TR=tuning_rule, FM=failure_mode, AP=application
rel_types: requires|enables|implements|constrains|subtype_of|generalizes|opposes|addresses|derives_from|motivates|validates|extends|precedes|uses|prevents|resolved_by|cross_ref
cross_ref_prefixes: MT=machine_type, XM=extended_model (from FSM compaction), ME=method, DP=diagnostic_pattern (from TROUBLESHOOTING compaction)
formula_notation: ∏=product, Σ=sum, e=Euler's number (2.71828...), ln=natural log, π=3.14159...
score_range: all consideration scores and final behavior scores in [0,1] unless otherwise noted
dave_mark_sources: GDC AI Summit talks (2012, 2014, 2015), "Behavioral Mathematics for Game AI" (2009), game AI community discourse
disambiguation: CP prefix used in both curve_parameters (CP1-CP8) and composition (CP1-CP8) — context resolves: curve_parameters are tuning knobs for individual curves, composition methods are score combination strategies; in relationships, target table is clear from linked content
confidence: generated from LLM weights — reflects established game AI practice (Dave Mark, Kevin Dill, Mike Lewis, Bobby Anguelov) and utility theory fundamentals

# relation_mapping(doc_rel|canonical_rel|notes)
requires|requires|exact match
enables|enables|exact match
implements|implements|exact match
constrains|constrains|exact match
subtype_of|specializes|exact semantic match
generalizes|generalizes|exact match
opposes|opposes|exact match; symmetric
addresses|solves|compensation addresses the multiplication problem = solves it
derives_from|derived_from|exact match
motivates|motivates|exact match
validates|validates|exact match
extends|extends|exact match
precedes|precedes|exact match
uses|requires|reasoner uses selection method = requires it
prevents|prevents|exact match
resolved_by|mitigated_by|failure mode resolved by tuning rule = mitigated_by
cross_ref|references|cross-domain link = references
