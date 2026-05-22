# COGNITION — UNDERSTANDING, THINKING, AWARENESS — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: foundations → processes → awareness_types → memory_systems → attention → reasoning → understanding → mental_models → metacognition → biases → development → disorders → measurement → embodied → social_cognition → comparative → rules → relationships → section_index

# foundations(id|concept|definition|significance)
FD1|cognition|all mental processes by which sensory input is transformed, reduced, elaborated, stored, recovered, and used|umbrella term — includes perception, attention, memory, reasoning, language, decision-making
FD2|representation|internal encoding of external reality — symbolic, distributed, embodied, or hybrid|the currency of thought — all cognition operates on representations of the world, not the world itself
FD3|information processing|cognition as computation — input → encoding → storage → retrieval → output|dominant framework since cognitive revolution (1950s) — mind as information processor
FD4|qualia|subjective experiential quality of conscious states — "what it is like" to experience something|the hard problem — objective science describes function, qualia describe phenomenal experience
FD5|intentionality|aboutness — mental states are directed at or about something (beliefs about X, desires for Y)|distinguishes mental from physical — a rock is not "about" anything; a thought always is (Brentano)
FD6|emergence|complex cognitive properties arising from simpler neural interactions — not reducible to individual neurons|cognition is not in any single neuron — arises from network dynamics, connectivity, and timing
FD7|binding problem|how the brain integrates separate features (color, shape, motion, location) into unified percepts|we perceive a red ball, not redness + roundness + motion separately — integration mechanism debated
FD8|symbol grounding|how abstract symbols acquire meaning by connecting to sensory-motor experience|symbols without grounding are meaningless — "red" means nothing without connection to seeing red (Harnad)
FD9|computational theory of mind|mental states are computational states — thinking is computation over representations|functionalism — mind defined by what it does (input-output mapping), not what it is made of
FD10|embodied cognition|cognition is shaped by and dependent on the body's interactions with environment — not purely abstract computation|challenges disembodied AI assumptions — spatial reasoning, metaphor, and concept formation are body-dependent
FD11|enactivism|cognition is not internal representation but active engagement — organism and environment co-constitute meaning|radical alternative to representationalism — knowing is doing, not storing
FD12|connectionism|cognition modeled as activation patterns in networks of simple processing units|parallel distributed processing (PDP) — knowledge is in connection weights, not symbolic rules
FD13|global workspace theory (GWT)|consciousness arises when information is broadcast widely across brain via "global workspace" — unconscious processes compete for access, winner is broadcast|Baars (1988) — explains why consciousness is serial and limited while unconscious processing is parallel and vast
FD14|integrated information theory (IIT)|consciousness corresponds to integrated information (Φ) — a system is conscious to the degree it is both differentiated and integrated|Tononi — quantitative measure of consciousness; predicts consciousness in any system with sufficient Φ, not only biological
FD15|predictive processing/coding|brain is a prediction engine — constantly generates predictions about sensory input, updates on prediction error|Clark, Friston — perception is controlled hallucination; action is prediction error minimization; unifies perception, action, and learning
FD16|free energy principle|biological systems minimize variational free energy — encompassing prediction error, surprise, and entropy|Friston — mathematical framework unifying perception, action, learning, and homeostasis under single principle
FD17|dual process theory|cognition operates via two systems — System 1 (fast, automatic, intuitive) and System 2 (slow, deliberate, effortful)|Kahneman, Stanovich — explains why humans are simultaneously brilliant and systematically irrational
FD18|neural correlates of consciousness (NCC)|minimal set of neuronal mechanisms jointly sufficient for a specific conscious percept|empirical approach to consciousness — find what brain activity accompanies what experience
FD19|affordance|action possibilities offered by environment relative to organism's capabilities|Gibson — environment is perceived in terms of what can be done, not abstract properties
FD20|schema|organized knowledge structure that represents concepts, situations, events, and guides expectation|Bartlett, Piaget — schemas filter perception, guide memory encoding, shape interpretation

# processes(id|process|description|input|output|time_scale|neural_basis)
PR1|sensation|transduction of physical energy into neural signals by sensory receptors|physical stimuli (light, pressure, chemical, thermal, vibration)|neural impulses carrying modality-specific information|milliseconds|sensory receptor organs → primary sensory cortex
PR2|perception|organization and interpretation of sensory signals into meaningful patterns|raw sensory neural signals|percepts — integrated, categorized, identified objects and events|100-500ms|sensory cortices → association cortices, feedback from higher areas
PR3|attention|selective allocation of processing resources to subset of available information|all available sensory and internal signals|enhanced processing of selected information, suppression of unselected|sustained or shifting — milliseconds to hours|frontoparietal network, superior colliculus, thalamic gating
PR4|encoding (memory)|transformation of perceived information into memory traces|attended, perceived information|memory traces (engrams) in short-term or working memory|seconds to minutes|hippocampus (episodic), distributed cortical networks
PR5|consolidation|stabilization of memory traces from labile to durable form|recently encoded memory traces|stable long-term memory representations|hours to years — sleep-dependent phase critical|hippocampus → neocortex transfer during sleep (systems consolidation), synaptic consolidation (protein synthesis)
PR6|retrieval|reactivation of stored memory traces|retrieval cues (internal or external)|recalled information — reconstructed, not replayed|milliseconds to seconds|hippocampus (episodic), cortical areas (semantic), prefrontal (strategic search)
PR7|working memory|temporary maintenance and manipulation of information for ongoing cognition|attended information, retrieved memories|maintained active representations available for reasoning, planning, comprehension|seconds (without rehearsal: ~15-30s)|prefrontal cortex, parietal cortex — Baddeley model: phonological loop, visuospatial sketchpad, central executive, episodic buffer
PR8|reasoning|drawing conclusions from premises, evidence, or existing knowledge|premises, beliefs, data, observations|conclusions, inferences, judgments|seconds to hours (deliberate)|prefrontal cortex (especially lateral PFC), anterior cingulate, parietal
PR9|decision-making|selecting action or belief from alternatives based on evaluation of outcomes|alternatives, outcome estimates, values, constraints|chosen action or belief + commitment|milliseconds (intuitive) to days (deliberate)|prefrontal cortex, orbitofrontal cortex, striatum (reward), amygdala (risk/emotion), anterior insula
PR10|problem-solving|searching for path from current state to goal state through problem space|initial state, goal state, operators (legal moves)|solution path or failure + learning|minutes to years|prefrontal cortex (planning), hippocampus (relational binding), basal ganglia (strategy selection)
PR11|language comprehension|extracting meaning from linguistic input — speech or text|phonological/orthographic stream|semantic representation — understanding of what was communicated|real-time (incremental)|Wernicke's area (posterior temporal), Broca's area (inferior frontal), angular gyrus, distributed semantic network
PR12|language production|converting intended meaning into linguistic output — speech or text|conceptual/semantic representation of intended message|articulated speech or written text|planning: hundreds of ms; articulation: ~150ms per syllable|Broca's area (syntactic planning), motor cortex (articulation), supplementary motor area, basal ganglia
PR13|categorization|assigning percepts or concepts to classes based on shared features or similarity|perceived entity or concept|category membership, associated knowledge, expectations|100-500ms|ventral visual stream (objects), temporal cortex, prefrontal (rule-based)
PR14|learning|relatively permanent change in knowledge or behavior from experience|experience, instruction, observation, feedback|modified representations, skills, associations, predictions|minutes to lifetime|hippocampus (declarative), striatum/cerebellum (procedural), synaptic plasticity (LTP/LTD) everywhere
PR15|imagination/mental simulation|generating internal representations of non-present or counterfactual situations|existing knowledge, goals, constraints|simulated scenarios — "what would happen if..."|seconds to minutes|default mode network, hippocampus (scene construction), prefrontal (constraint satisfaction)
PR16|planning|constructing sequence of actions to achieve future goal — mental time travel|current state, goal state, action repertoire, world model|action sequence with anticipated intermediate states|seconds to hours|prefrontal cortex (especially rostral PFC), hippocampus (prospective memory, relational binding)
PR17|cognitive control/executive function|top-down modulation of processing — inhibition, task-switching, conflict monitoring|task demands, rules, competing responses|regulated behavior — overriding prepotent responses, maintaining goals|ongoing — modulates all other processes|prefrontal cortex (dorsolateral, ventrolateral, anterior cingulate), basal ganglia
PR18|insight|sudden reorganization of problem representation producing solution — "aha!" moment|impasse in problem-solving, incubation period|restructured representation, solution, felt certainty|sudden — preceded by incubation (minutes to days)|anterior superior temporal gyrus (right hemisphere burst), anterior cingulate (conflict detection pre-insight)
PR19|creativity|generation of novel and useful ideas, solutions, or artifacts|existing knowledge, constraints, goals, divergent search|original output — ideas, designs, works, solutions|variable — minutes to years|distributed — default mode network (generation), executive network (evaluation), salience network (switching)
PR20|emotion processing|evaluation of stimuli for personal significance — generates feeling states that modulate all cognition|appraised stimuli (internal or external)|emotional states — affect, mood, discrete emotions|rapid (amygdala: <200ms), sustained (mood: hours to days)|amygdala (rapid evaluation), prefrontal (regulation), insula (interoception), hypothalamus/brainstem (autonomic response)

# awareness_types(id|type|definition|characteristics|neural_correlates|philosophical_position)
AW1|phenomenal consciousness|raw subjective experience — what it is like to see red, feel pain, taste coffee|private, ineffable (hard to describe fully), intrinsic|NCC debate — thalamocortical system, posterior cortical hot zone (Koch/Tononi)|hard problem (Chalmers) — why physical processes produce subjective experience at all
AW2|access consciousness|information available for reasoning, reporting, and behavioral control — "I know that I see red"|functional — information is globally accessible to cognitive systems|global workspace activation (FD13), prefrontal-parietal network|easy problem (relatively) — functional access is explainable computationally
AW3|self-awareness|knowledge of oneself as a distinct entity with own mental states, body, and history|develops in human infants ~18 months (mirror test), rare in animals|medial prefrontal cortex, posterior cingulate, temporoparietal junction|prerequisite for autobiography, social cognition, moral reasoning
AW4|metacognitive awareness|awareness of own cognitive processes — knowing what you know and don't know, monitoring comprehension|"I feel uncertain about this answer" — online monitoring of cognitive confidence|anterior prefrontal cortex (BA10), anterior insula|enables learning regulation, error detection, calibrated confidence
AW5|situational awareness|perception and comprehension of current environment plus projection of future state|Endsley model — Level 1: perceive, Level 2: comprehend, Level 3: project|distributed — sensory cortices + prefrontal (projection) + parietal (spatial)|critical for expertise — pilots, surgeons, drivers, military
AW6|peripheral awareness|information processed and available but not in focal attention — "fringe consciousness"|can become focal when relevance detected (pop-out), influences behavior without focal attention|attentional networks, automatic processing in sensory cortex|most cognition operates here — focal awareness is the exception
AW7|subliminal/unconscious processing|information processed below threshold of awareness — no reportability but measurable behavioral effects|masked priming, blindsight, implicit learning — demonstrates extensive unconscious computation|visual cortex (blindsight), amygdala (fear processing without awareness), motor cortex (preparation)|challenges equation of mind with consciousness — most cognitive processing is unconscious
AW8|flow state|complete absorption in task — loss of self-awareness, time distortion, effortless concentration|high skill + high challenge, intrinsic motivation, clear goals, immediate feedback|reduced activity in default mode network and medial prefrontal (reduced self-monitoring), increased dorsal attention network|Csikszentmihalyi — optimal experience, paradox: peak performance without self-awareness
AW9|mindfulness|non-judgmental present-moment awareness of experience — observing thoughts and sensations without reactivity|attentional — deliberate sustained present-focus; attitudinal — acceptance, non-reactivity|increased anterior cingulate activity, reduced default mode network, altered insula activation|contemplative tradition → clinical psychology → neuroscience — measurable structural brain changes with practice
AW10|dreaming consciousness|awareness during sleep — narrative, emotionally vivid, often bizarre, poor metacognition|reduced logical reasoning, acceptance of impossibilities, vivid sensory imagery, emotional amplification|REM: pontine activation → thalamocortex with prefrontal deactivation (reduced executive control)|activation-synthesis (Hobson), threat simulation (Revonsuo), memory consolidation (Walker)

# memory_systems(id|system|duration|capacity|encoding|retrieval|neural_basis)
MS1|iconic (visual sensory)|~250-500ms|high — full visual field|automatic, pre-attentive|rapid decay, no effortful retrieval — must attend within window or lost|primary visual cortex
MS2|echoic (auditory sensory)|~2-4 seconds|high — full auditory field|automatic, pre-attentive|lingers longer than iconic — "what did you say?" retrieval possible briefly|primary auditory cortex
MS3|short-term memory (STM)|~15-30 seconds without rehearsal|7±2 items (Miller) — more accurately 4±1 chunks (Cowan)|phonological or visual code|direct readout while maintained|phonological loop: left hemisphere perisylvian, visuospatial: right hemisphere parietal-occipital
MS4|working memory|seconds to minutes (actively maintained)|3-5 items (Cowan) — capacity limits reasoning, comprehension, and fluid intelligence|multimodal — phonological, visuospatial, episodic buffer|active maintenance + manipulation — requires executive control|prefrontal cortex (central executive), parietal, specialized buffers
MS5|episodic memory|lifetime (but subject to forgetting and distortion)|functionally unlimited for distinct episodes|contextually bound — what/where/when together|mental time travel — re-experiencing with autonoetic awareness|hippocampus (encoding/retrieval), medial temporal lobe, reactivated cortical patterns
MS6|semantic memory|lifetime (relatively stable)|functionally unlimited — all general world knowledge|abstracted from episodes — decontextualized facts and concepts|noetic awareness — knowing without re-experiencing|anterior temporal lobe, distributed cortical networks — hub-and-spoke model
MS7|procedural memory|lifetime (highly durable once consolidated)|unlimited — all motor and cognitive skills|gradual, incremental — practice-dependent|implicit — expressed through performance, not declarative recall|basal ganglia (habit), cerebellum (motor timing/coordination), motor cortex
MS8|prospective memory|until intended action performed|limited — few active intentions|encoding future intention with retrieval context|triggered by encountering planned cue (event-based) or monitoring time (time-based)|rostral prefrontal cortex (BA10), hippocampus
MS9|implicit memory|lifetime|unlimited|unintentional — exposure-based|unconscious influence on behavior — priming, conditioning, perceptual fluency|distributed — amygdala (emotional conditioning), perceptual cortex (priming), cerebellum (classical conditioning)
MS10|autobiographical memory|lifetime (earliest reliable ~3-4 years)|complex episodes organized by life narrative|personally significant events — emotion enhances encoding|reconstruction — not replay; memories are rebuilt each retrieval, influenced by current self|hippocampus, medial prefrontal, posterior cingulate — overlaps episodic + semantic + self

# attention(id|type|description|mechanism|capacity|neural_basis)
AT1|selective attention|focusing on one source while ignoring others — "cocktail party effect"|biased competition — attended input wins over unattended for processing resources|severely limited — typically one focal stream|frontoparietal network biasing sensory cortex — top-down attentional modulation
AT2|divided attention|processing multiple inputs simultaneously — degrades with complexity and similarity|resource sharing — performance declines on each task as load increases|limited by central bottleneck (response selection) and modality overlap|dual-task costs in prefrontal, posterior parietal
AT3|sustained attention/vigilance|maintaining focus over extended period — performance degrades over time|tonic alertness maintained by arousal systems|declines after ~15-20 minutes (vigilance decrement)|right hemisphere frontoparietal, locus coeruleus (norepinephrine)
AT4|executive attention|conflict resolution between competing responses — Stroop effect|anterior attentional network monitors and resolves conflict|limited — conflict resolution is serial|anterior cingulate cortex, dorsolateral prefrontal
AT5|exogenous/bottom-up|involuntary attention capture by salient stimuli — sudden motion, loud sound, own name|stimulus-driven — sensory salience overrides top-down goals|automatic — fast, involuntary, transient|superior colliculus (orienting), temporoparietal junction (reorienting)
AT6|endogenous/top-down|voluntary direction of attention based on goals and expectations|goal-driven — frontal areas bias sensory processing toward task-relevant features|effortful, sustained, limited by executive resources|dorsal frontoparietal network — frontal eye fields, intraparietal sulcus
AT7|feature-based attention|attention to a specific feature across entire visual field — "find all red things"|global enhancement of selected feature regardless of spatial location|can enhance one feature dimension simultaneously|V4 (color), MT (motion) — feature maps modulated by prefrontal
AT8|spatial attention|attention to a location in space — "spotlight" metaphor|enhanced processing at attended location, suppressed at unattended|spotlight can be narrowed or widened — zoom lens model|parietal cortex (spatial maps), superior colliculus
AT9|object-based attention|attention spreads within an object boundary regardless of spatial extent|when attending one feature of an object, other features of same object are enhanced|operates on parsed objects, not raw space|lateral occipital complex (object parsing), temporal cortex
AT10|inattentional blindness|failure to perceive clearly visible stimulus when attention is engaged elsewhere|unattended stimuli do not reach awareness even if fixated|demonstrates that attention, not just eye position, determines conscious perception|reduced activity in relevant sensory cortex for unattended stimuli

# reasoning(id|type|description|direction|validity_criterion|example)
RN1|deductive|conclusion necessarily follows from premises — if premises true, conclusion must be true|general → specific|logical validity — conclusion cannot be false if premises are true|all mammals breathe air; whales are mammals; therefore whales breathe air
RN2|inductive|conclusion probably follows from evidence — generalization from observations|specific → general|strength — how probable is conclusion given evidence|every swan observed has been white; therefore all swans are white (can be wrong — black swans)
RN3|abductive|inference to best explanation — given observation, what hypothesis best explains it|observation → explanation|explanatory quality — simplicity, scope, coherence, predictive power|the lawn is wet; best explanation: it rained (not: someone poured water everywhere)
RN4|analogical|mapping structure from known domain to novel domain — "X is like Y"|known → novel via structural mapping|structural consistency — corresponding elements must play corresponding roles|atom is like solar system — nucleus/sun at center, electrons/planets orbit
RN5|causal|inferring cause-effect relationships from evidence, temporal order, mechanism, and intervention|effect → cause or cause → effect|mechanism identification, temporal precedence, covariation, elimination of alternatives|ice cream sales and drownings correlate — but heat causes both (spurious direct causation)
RN6|spatial|reasoning about spatial relationships, transformations, rotation, navigation|within mental spatial model|consistency with physical laws of space|mental rotation task — imagining object rotated to match target
RN7|moral/ethical|reasoning about right action, fairness, justice, harm, duty|principles + situation → judgment|coherence with moral principles, reflective equilibrium|trolley problem — utilitarian calculation vs. deontological prohibition on using person as means
RN8|probabilistic/Bayesian|updating beliefs based on evidence according to probability theory|prior belief + evidence → posterior belief|calibration — stated confidence matches actual accuracy|P(disease|positive test) requires base rate, sensitivity, and specificity — most people ignore base rate
RN9|counterfactual|reasoning about what would have happened if things were different — "what if"|actual → alternative scenario|consistency with causal model — change one cause, propagate effects|if I had left 5 minutes earlier, I would have missed the traffic
RN10|temporal|reasoning about time — sequence, duration, simultaneity, before/after relationships|events → temporal structure|consistency with temporal logic — before/after, during, overlap|she graduated before she got the job; the interview was during the semester
RN11|means-ends analysis|comparing current state to goal, identifying differences, finding operators to reduce differences|current state + goal → operator sequence|progress — each step reduces distance to goal|GPS (Newell & Simon) — general problem solver
RN12|dialectical|reasoning through opposition — thesis, antithesis, synthesis|proposition → counter → integration|productive tension — synthesis transcends both positions|Hegel — being + nothing → becoming; practical: debating both sides to find truth

# understanding(id|level|description|indicators|cognitive_requirement|failure_mode)
UN1|recognition|identifying something as previously encountered — familiarity without recall of details|"I've seen this before" — sense of knowing without content retrieval|minimal — perceptual matching against stored patterns|false recognition — déjà vu, memory errors, prototype confusion
UN2|recall|retrieving stored information — reproducing learned content|can state facts, recite, list, describe from memory|encoding + consolidation + retrieval chain intact|tip-of-tongue, interference, context-dependent forgetting
UN3|comprehension|grasping meaning — constructing mental model from input|can paraphrase, explain in own words, summarize without losing meaning|builds mental model linking concepts — not just surface memory|illusion of understanding — can repeat words without grasping meaning (Chinese Room argument)
UN4|application|using knowledge in new concrete situations — transfer from learning to action|can solve novel problems using learned principles, can use tools in new contexts|maps abstract knowledge to concrete situation — requires flexible retrieval|inert knowledge — understands in classroom, cannot apply in real world
UN5|analysis|breaking complex wholes into parts, identifying structure, relationships, and organizing principles|can identify assumptions, distinguish evidence from inference, find logical structure|decomposition + relationship mapping — sees internal structure|reductionism error — analyzing parts while losing emergent properties of whole
UN6|synthesis/creation|combining elements into new coherent wholes — generating novel structures|can design, compose, plan, construct original works or solutions|recombination of existing knowledge into novel configurations — requires both domain knowledge and creativity|empty novelty — new but not meaningful; pastiche without understanding
UN7|evaluation|judging value, validity, quality, or effectiveness based on criteria|can critique, assess evidence quality, compare alternatives, identify flaws|requires criteria (internal or external) + analytical ability + knowledge of alternatives|uncalibrated evaluation — judging without adequate criteria or knowledge; Dunning-Kruger effect
UN8|transfer (near)|applying learned skill or knowledge to similar but non-identical situation|performance improves on tasks sharing surface and structural features with training|detecting similarity between training and transfer contexts|overfitting — learning specific solution, not generalizable principle
UN9|transfer (far)|applying learned principle to structurally similar but superficially different domain|performance improves on tasks sharing deep structure but different surface features|abstraction of underlying principle + recognition of structural analogy|far transfer is rare and difficult — most learning is context-bound
UN10|intuitive understanding|fast, holistic grasp without explicit reasoning — "just knowing"|expert rapid assessment, accurate gut feelings in domain of expertise, pattern recognition without conscious analysis|extensive experience + compiled knowledge (10,000 hour rule / deliberate practice)|overconfidence — intuition accurate in valid environments (chess) but misleading in low-validity environments (stock market)
UN11|explanatory understanding|can state WHY something is true — not just WHAT but the causal/logical chain|can construct causal explanation, predict consequences of changes, teach others|mental model with causal structure — not just correlational associations|circular explanation — restating phenomenon as explanation ("why does opium cause sleep? — because of its dormitive virtue")
UN12|somatic/embodied understanding|knowledge held in body — motor skills, spatial intuitions, material feel|can perform without conscious thought, can detect wrongness through bodily feeling|body-environment coupling, procedural memory, haptic knowledge|cannot be fully verbalized — the gap between knowing how and knowing that (Ryle)

# mental_models(id|model|description|function|update_mechanism|failure_mode)
MM1|spatial model|internal map of physical space — layout, distances, orientations|navigation, planning movement, understanding spatial descriptions|exploration, landmark learning, path integration|distortion — distances compressed or expanded based on familiarity and barriers
MM2|causal model|representation of cause-effect relationships in a domain|prediction, explanation, intervention planning|observation of covariation + mechanism learning + intervention outcomes|illusory causation — superstition, post hoc reasoning, confounding
MM3|social model (theory of mind)|representation of other agents' beliefs, desires, intentions, and knowledge|predicting others' behavior, communication, deception, cooperation|observation of behavior, feedback from interaction, perspective-taking|projection — assuming others share your beliefs and knowledge (curse of knowledge)
MM4|temporal model|representation of event sequences, durations, rhythms, and deadlines|planning, scheduling, retrospection, anticipation|experience of events in time, feedback on duration estimates|temporal distortion — time flies when engaged, drags when bored; hindsight bias
MM5|self-model|representation of own abilities, personality, beliefs, and states|metacognition, self-regulation, identity maintenance, social presentation|self-observation, social feedback, outcome monitoring|self-serving bias — inflated assessment of own abilities; impostor syndrome — deflated
MM6|mechanical/physical model|representation of how physical objects behave — folk physics|predicting object behavior, tool use, design, troubleshooting|manipulation, observation, instruction|naive physics errors — heavier falls faster (pre-Galileo intuition), impetus theory, curvilinear motion belief
MM7|narrative model|representation of events as story with agents, motives, conflicts, and resolution|making sense of experience, communicating, predicting social outcomes|experience, cultural narrative exposure, feedback|narrative fallacy — imposing story structure on random events; hindsight coherence
MM8|conceptual model|organized representation of a domain's concepts and their relationships|reasoning within domain, learning new concepts by relating to existing ones|instruction, discovery, analogy, contradiction|misconception — incorrect model that resists correction because it is internally coherent
MM9|emotional model|representation of how situations relate to emotional outcomes — appraisal patterns|predicting emotional reactions (own and others'), emotional regulation planning|emotional experience, observation, reflection|alexithymia — impoverished emotional model; projection — assuming others' emotional reactions match own

# metacognition(id|component|description|function|development|failure_mode)
MC1|metacognitive knowledge|knowledge about own cognitive abilities, strategies, and task demands|knowing what you know and don't know, choosing appropriate strategies|develops through childhood — mature by adolescence, refined through expertise|Dunning-Kruger — poorest performers have worst metacognitive knowledge
MC2|metacognitive monitoring|online tracking of own cognitive performance — feeling of knowing, judgment of learning|detecting errors, adjusting effort, knowing when to seek help|emerges ~4-5 years, improves through adolescence|miscalibration — overconfidence (most common) or underconfidence
MC3|metacognitive control|regulating cognitive processes based on monitoring — allocating study time, selecting strategies, deciding to stop|optimizing learning and performance — spending more time on difficult material, switching strategies when current one fails|develops later than monitoring — executive function dependent|dysregulation — not acting on monitoring signals (knowing you don't understand but not re-reading)
MC4|feeling of knowing (FOK)|subjective sense that one can retrieve information even when retrieval currently fails|guides search — continue trying vs. give up; accept vs. reject recognition candidates|present by age 5 in crude form|inflated FOK — feeling of knowing when actually wrong — tip-of-tongue for incorrect information
MC5|judgment of learning (JOL)|prediction of future recall success during study|allocates study effort — skip well-learned items, spend more time on uncertain ones|improves with expertise in domain|foresight bias — JOLs made immediately after study are inflated; delayed JOLs are more accurate
MC6|calibration|correspondence between confidence and accuracy — well-calibrated when 80% confidence = 80% correct|enables appropriate reliance on own judgments — critical for expertise, teaching, decision-making|improves with feedback and domain experience — experts are better calibrated in domain|overconfidence is default — most people and AI systems are overconfident; underconfidence in some domains
MC7|error detection|recognizing that an error has occurred — either in own processing or in external information|enables correction, learning from mistakes, quality control|develops with domain knowledge — you must know enough to detect errors|unknown unknowns — cannot detect errors in domains where you lack knowledge
MC8|source monitoring|tracking where a memory or belief came from — "did I read this or did someone tell me?"|prevents misattribution, supports credibility evaluation, prevents plagiarism|develops through childhood — children are poor source monitors|source confusion — attributing imagined events to memory (false memory), confusing dreams with reality

# biases(id|bias|description|mechanism|domain|debiasing)
BI1|confirmation bias|seeking, interpreting, and remembering information that confirms existing beliefs|hypothesis-consistent testing, biased interpretation of ambiguous evidence, selective recall|reasoning, science, politics, relationships|actively seek disconfirming evidence, consider opposite hypothesis, structured analysis
BI2|anchoring|over-reliance on first piece of information encountered when making estimates|insufficient adjustment from initial anchor — even irrelevant anchors affect judgment|numerical estimation, negotiation, pricing|generate multiple anchors, use formula-based estimation, be aware of the anchor
BI3|availability heuristic|judging probability by ease of recall — vivid or recent events seem more likely|memory retrieval fluency mistaken for frequency or probability|risk assessment, medical diagnosis, policy|use base rate statistics, not personal recall; ask "is this easy to recall because common or because vivid?"
BI4|representativeness|judging probability by similarity to prototype — ignoring base rates|pattern matching overrides statistical reasoning|categorization, stereotyping, diagnosis|always ask for base rate; probability = base rate × likelihood ratio, not similarity alone
BI5|hindsight bias|after learning outcome, believing "I knew it all along" — creeping determinism|outcome information contaminates memory of prior prediction|evaluation, learning from experience, legal judgment|record predictions before outcome; consider alternative outcomes that could have occurred
BI6|Dunning-Kruger effect|unskilled individuals overestimate competence; experts slightly underestimate|metacognitive deficit — low skill prevents recognizing own incompetence; experts calibrate to harder problems|self-assessment, hiring, learning|seek external feedback, test against objective criteria, compare to peer performance
BI7|sunk cost fallacy|continuing investment because of past irrecoverable costs rather than future value|loss aversion + self-justification — admitting sunk cost means admitting error|financial decisions, project management, relationships|evaluate decisions based only on future costs and benefits; ask "if I were starting fresh, would I invest?"
BI8|framing effect|different decisions from identical information presented differently — "90% survival" vs "10% mortality"|reference point shifts evaluation — losses loom larger than gains (prospect theory)|medical decisions, policy, marketing|reframe in multiple ways before deciding; present both gain and loss frames
BI9|fundamental attribution error|attributing others' behavior to personality while attributing own to situation|actor-observer asymmetry — we see our own situations but only others' actions|social judgment, conflict, management|deliberately consider situational explanations for others' behavior
BI10|status quo bias|preference for current state — disproportionate weight to doing nothing|loss aversion applied to change — losses from change loom larger than gains|policy, investment, personal decisions|reframe as "if you had neither option, which would you choose?"
BI11|peak-end rule|experience evaluated by its peak intensity and how it ended, not by duration or average|memory of experience ≠ experience itself — Kahneman's experiencing self vs remembering self|service design, medical procedures, vacations|design for strong positive endings; manage peaks of discomfort
BI12|base rate neglect|ignoring background frequency when evaluating evidence — focusing only on hit rate|conjunction of representativeness heuristic + neglect of prior probability|medical screening, forensics, hiring|Bayesian reasoning — always start with base rate, then update with evidence
BI13|illusion of transparency|overestimating how well others can read your internal states|self-knowledge is so vivid it feels like it must be visible to others|communication, negotiation, performance anxiety|your feelings are less apparent to others than you think — communicate explicitly
BI14|planning fallacy|underestimating time, cost, and complexity of future tasks while overestimating benefits|focus on best-case scenario, neglect of base rates of similar past tasks, motivated reasoning|project management, construction, personal planning|use reference class forecasting — how long did similar projects actually take?
BI15|groupthink|group consensus overrides individual critical thinking — pressure to conform suppresses dissent|social conformity + leader influence + isolation + stress|committee decisions, organizational strategy, jury deliberation|assign devil's advocate, anonymous input, invite outside critique, leader speaks last

# development(id|stage|age_range|cognitive_achievements|limitations|theorist)
DV1|sensorimotor|0-2 years|object permanence, goal-directed action, mental representation (late), deferred imitation|no symbolic thought, no language (early), egocentrism, A-not-B error|Piaget
DV2|preoperational|2-7 years|symbolic representation, language explosion, pretend play, intuitive reasoning|centration (focus on one dimension), irreversibility, egocentrism, animism, lack of conservation|Piaget
DV3|concrete operational|7-11 years|conservation, classification, seriation, reversibility, decentration|limited to concrete (present, tangible) situations — cannot reason about abstract or hypothetical|Piaget
DV4|formal operational|11+ years|abstract reasoning, hypothetical-deductive reasoning, systematic experimentation, propositional logic|not universally achieved — many adults do not consistently use formal operations|Piaget
DV5|theory of mind emergence|~4-5 years|understanding false belief — recognizing that others can hold beliefs different from reality and from own beliefs|before this age, children predict behavior based on reality, not on what the person believes|Wimmer & Perner (Sally-Anne test)
DV6|executive function development|3-25 years (gradual)|inhibitory control, working memory expansion, cognitive flexibility — prefrontal cortex maturation|protracted development — prefrontal cortex last brain region to fully myelinate (~25 years)|Diamond, Casey
DV7|language acquisition|0-puberty (critical period)|phoneme discrimination (0-12mo), first words (~12mo), grammar explosion (2-3yr), complex syntax (4-5yr), pragmatics (ongoing)|critical period — first language acquisition much harder after puberty (Lenneberg)|Chomsky (nativist), Tomasello (usage-based), both contribute
DV8|moral development|childhood through adulthood|preconventional (reward/punishment) → conventional (social norms) → postconventional (universal principles)|stages are culturally variable, not strictly sequential; care ethic not captured (Gilligan)|Kohlberg (justice), Gilligan (care), Haidt (moral foundations)

# disorders(id|disorder|cognitive_domain_affected|core_deficit|presentation|mechanism)
DO1|aphasia (Broca's)|language production|impaired syntax and fluency, preserved comprehension|telegraphic speech — content words without function words, effortful, aware of deficit|left inferior frontal gyrus (Broca's area) damage — stroke, trauma
DO2|aphasia (Wernicke's)|language comprehension|impaired comprehension, fluent but meaningless speech|fluent jargon — word salad, neologisms, unaware of deficit|left posterior superior temporal gyrus damage
DO3|amnesia (anterograde)|episodic memory encoding|cannot form new episodic memories, preserved procedural learning and old memories|can learn new skills but not remember learning them — intact moment-to-moment but no new episodes|bilateral hippocampal damage (HM case), Korsakoff syndrome (thiamine deficiency)
DO4|amnesia (retrograde)|episodic memory retrieval|loss of memories before injury — temporal gradient (recent lost, remote preserved)|cannot recall recent past but remembers childhood — Ribot's law|medial temporal lobe damage, typically with anterograde component
DO5|prosopagnosia|face perception|cannot recognize faces — even familiar people|uses voice, gait, context to identify people — faces all look similar|fusiform face area (right hemisphere) damage or developmental
DO6|hemispatial neglect|spatial attention|unawareness of contralesional space — not blindness but attentional failure|ignores left side of space, plate, page, own body — even in mental imagery|right parietal cortex damage (typically stroke)
DO7|ADHD|attention, executive function|impaired sustained attention, impulsivity, hyperactivity — executive function deficit|difficulty maintaining focus, frequent task-switching, poor time management, working memory deficits|prefrontal-striatal circuit dysregulation, dopamine/norepinephrine systems
DO8|autism spectrum|social cognition, theory of mind, sensory processing|atypical social communication, restricted/repetitive behaviors, sensory differences|difficulty reading social cues, preference for routine, intense focused interests, sensory over/under-sensitivity|neurodevelopmental — multiple genetic and environmental factors, altered connectivity patterns
DO9|Alzheimer's disease|memory, executive function, language (progressive)|progressive neurodegeneration — episodic memory first, then semantic, then procedural|gradual memory loss → disorientation → language breakdown → loss of independence|amyloid plaques, tau tangles, synaptic loss, hippocampal atrophy progressing cortically
DO10|schizophrenia|reality monitoring, executive function, social cognition|impaired reality testing, disorganized thinking, executive dysfunction|positive symptoms (hallucinations, delusions) + negative symptoms (flat affect, avolition) + cognitive deficits|dopamine dysregulation, glutamate dysfunction, altered prefrontal-temporal connectivity

# measurement(id|method|what_it_measures|temporal_resolution|spatial_resolution|limitations)
ME1|behavioral testing (RT, accuracy)|cognitive processes via performance — reaction time indexes processing stages, accuracy indexes capacity|milliseconds (RT)|no spatial information about brain|indirect — behavior is the output of cognition, not cognition itself
ME2|fMRI (functional MRI)|blood oxygenation level dependent (BOLD) signal — correlate of neural activity|~1-2 seconds (hemodynamic delay)|~1-3mm voxels|measures blood flow, not neural firing directly; slow; expensive; correlation not causation
ME3|EEG/ERP|electrical potentials from scalp — direct measure of summed synaptic activity|<1 millisecond|poor (~cm) — volume conduction smears spatial source|poor spatial resolution; only measures cortical surface activity (not deep structures)
ME4|MEG (magnetoencephalography)|magnetic fields from neural currents|<1 millisecond|moderate (~5mm)|expensive, requires magnetically shielded room, only measures tangential sources
ME5|single-cell recording|individual neuron firing rates and patterns|sub-millisecond|single neuron|invasive — almost exclusively animal research; samples tiny fraction of neurons
ME6|lesion studies|function by observing deficits after brain damage|n/a — permanent|anatomical region of lesion|nature performs imprecise lesions — damage rarely respects functional boundaries; plasticity may compensate
ME7|TMS (transcranial magnetic stimulation)|causal role of brain area — temporary disruption or enhancement|milliseconds (can target specific time windows)|~1cm|surface cortex only; indirect mechanism; variable effects across individuals
ME8|PET (positron emission tomography)|metabolic activity via radioactive tracer|~30-60 seconds|~4-6mm|radioactive — limits repeated use; very slow; expensive
ME9|eye tracking|attentional allocation via gaze position and pupil size|milliseconds|precise gaze point|equates gaze with attention — but covert attention can shift without eye movement
ME10|psychophysics|sensory and perceptual thresholds — just noticeable differences, signal detection|milliseconds|n/a (stimulus-level, not brain-level)|measures conscious report — does not capture unconscious processing; response bias confounds

# embodied(id|concept|description|evidence|implication)
EM1|sensorimotor grounding|abstract concepts grounded in bodily experience — understanding "grasp an idea" uses motor system|brain imaging shows motor cortex activation during comprehension of action words; conceptual deficits after motor cortex damage|language and thought are not amodal symbol manipulation — they reuse sensorimotor circuits
EM2|conceptual metaphor|abstract domains understood through concrete bodily metaphors — time is space, importance is weight, intimacy is warmth|holding warm cup increases social warmth ratings; heavier clipboard makes judgments seem more important (embodied priming)|abstract reasoning is metaphorical at core — grounded in spatial, physical, and social body experience (Lakoff & Johnson)
EM3|extended mind thesis|cognitive processes can extend beyond brain into body and environment — notebook, smartphone, diagrams are part of cognitive system|Otto uses notebook for memory same way Inga uses biological memory (Clark & Chalmers); tool use alters body schema|cognition is not skull-bound — the boundary of the cognitive system is functional, not anatomical
EM4|situated cognition|cognition is always situated in a specific physical and social context — context is not background but co-constituent of thought|memory is context-dependent (encoding specificity), problem-solving is resource-dependent, expertise is domain-bound|cannot separate cognition from context — lab results may not generalize to real-world cognition
EM5|perception-action coupling|perception and action are not separate stages but a continuous loop — we perceive in order to act and act in order to perceive|affordances (FD19), dorsal/ventral visual streams, mirror neurons, coupling in expert performance|perception is for action — not for building internal representations (ecological approach, Gibson)
EM6|interoception|perception of internal bodily states — heartbeat, hunger, pain, temperature, gut feelings|interoceptive accuracy predicts emotional intelligence and decision quality (somatic marker hypothesis, Damasio)|body signals are cognitive signals — "gut feelings" are real information sources, not noise
EM7|body schema|implicit representation of body's spatial configuration, capabilities, and boundaries — updates dynamically with tool use|tool use extends body schema (rubber hand illusion, tool-use body map extension); phantom limb|the body is a cognitive variable — changes to body representation change cognition

# social_cognition(id|concept|description|mechanism|development|neural_basis)
SO1|theory of mind (ToM)|ability to attribute mental states (beliefs, desires, intentions, knowledge) to others — "mentalizing"|simulation (imagine being them) + theory (apply rules about minds) — probably both|false belief understanding ~4-5 years; more sophisticated ToM through adolescence|temporoparietal junction, medial prefrontal cortex, superior temporal sulcus
SO2|empathy|sharing and understanding others' emotional states — feeling with another|emotional contagion (automatic) + cognitive empathy (deliberate perspective-taking)|emotional contagion from birth; cognitive empathy ~4-6 years; mature integration through adolescence|anterior insula (shared experience), anterior cingulate (shared pain), mirror neuron system (action understanding)
SO3|joint attention|two individuals knowingly attending to the same thing — foundational for communication and learning|gaze following → pointing → shared awareness that both are attending|emerges 9-12 months — foundation for language acquisition and social learning|superior temporal sulcus (gaze processing), prefrontal (intentionality)
SO4|social referencing|looking to others' emotional reactions to guide own behavior in ambiguous situations|infant/person encounters ambiguity → checks caregiver/trusted other's expression → calibrates own response|emerges ~8-10 months|amygdala (evaluation), fusiform (face reading), prefrontal (decision)
SO5|mirror neuron system|neurons that fire both when performing action and when observing same action in others|direct mapping of observed action onto own motor repertoire|present from birth in some form — develops with motor repertoire|ventral premotor cortex (F5), inferior parietal lobule
SO6|pragmatics|understanding language in context — implicature, irony, metaphor, indirect requests|inferring speaker's intent beyond literal meaning — Gricean maxims (quantity, quality, relation, manner)|develops through childhood and adolescence — sarcasm understanding ~6-8 years, complex implicature later|right hemisphere (non-literal), medial prefrontal (intent attribution), anterior temporal (integration)
SO7|shared intentionality|ability to form shared goals, joint plans, and mutual commitments with others|"we-mode" — thinking in terms of collective rather than individual goals|emerges ~14 months (joint goals), develops through childhood (shared norms, institutions)|human-specific (debate) — no clear evidence in other great apes for full shared intentionality (Tomasello)
SO8|social learning|learning by observing others' behavior and its consequences — not just imitation but selective copying|model selection (prestige, competence, similarity) + behavior selection (copy successful strategies)|birth onward — imitation very early, selective copying ~2-3 years|mirror system, medial prefrontal (model evaluation), striatum (reward learning from observation)

# comparative(id|species_group|cognitive_capability|evidence|limitation_vs_human)
CG1|great apes|tool use, mirror self-recognition, limited theory of mind, social learning, planning, working memory (~2-3 items)|Köhler's insight experiments (Sultan), mirror test (chimpanzees, orangutans), Premack & Woodruff ToM studies|no evidence for shared intentionality, teaching, full recursion in communication, cumulative culture
CG2|corvids (crows, ravens)|tool manufacture, causal reasoning, future planning, episodic-like memory, mirror test (magpies)|New Caledonian crows craft tools; ravens plan for future tool use; scrub jays cache based on what they'll want|convergent evolution with mammals — different brain architecture (nuclear vs laminar cortex), similar capacity
CG3|cetaceans (dolphins, whales)|mirror self-recognition, social learning, cooperative hunting, cultural transmission, tool use (sponging in dolphins)|dolphin mirror test, humpback whale song culture, synchronized hunting techniques|hard to test — aquatic environment limits experimental paradigms
CG4|octopus/cephalopods|problem-solving, observational learning, tool use, play behavior|octopi open jars, use coconut shells as shelter (tool use), navigate mazes|distributed nervous system — 2/3 of neurons in arms, not centralized; short lifespan limits cumulative learning
CG5|insects (bees, ants)|navigation, communication (waggle dance), counting (small numbers), concept learning|honeybees learn "same/different" concepts, navigate by cognitive maps, communicate distance and direction|hard-wired behavioral repertoire with limited flexibility; very small neural circuit count but surprising capability
CG6|AI systems|pattern recognition, language processing, game playing, mathematical proof, code generation|superhuman in narrow domains (chess, Go, protein folding), increasingly capable in language|no phenomenal consciousness (arguably), no embodiment (typically), no intrinsic motivation, alignment problem, no developmental trajectory

# rules(id|rule|rationale|violation_consequence)
RL1|cognition operates on representations, not directly on the world|all processing is of internal encodings — we never access reality directly, only our model of it|confusing the map for the territory — believing our perception IS reality rather than a model of it
RL2|attention is the bottleneck of consciousness — unattended information is not consciously processed|processing capacity is finite — attention selects what reaches awareness|inattentional blindness, change blindness — critical information missed when attention directed elsewhere
RL3|memory is reconstruction, not replay — every retrieval is a new construction influenced by current state|memories are reassembled from fragments, not read from fixed storage|false memories are expected, not exceptional — eyewitness testimony is unreliable; memory confidence ≠ accuracy
RL4|expertise is domain-specific — expert performance does not transfer to unrelated domains|expertise is built on domain-specific knowledge structures (chunking, patterns), not general intelligence|expecting chess grandmasters to be expert at everything — expertise is narrow and deep, not broad
RL5|intuition is compressed expertise — valid in high-validity environments with clear feedback|expert intuition = rapid pattern recognition from extensive experience; only reliable where patterns exist and feedback is available|trusting intuition in low-validity environments (stock market, long-term political prediction) — systematic error
RL6|conscious processing is serial and slow; unconscious processing is parallel and fast|conscious workspace has limited capacity (~4 items); unconscious processes millions of inputs simultaneously|overvaluing conscious deliberation — most adaptive behavior is unconscious; analysis paralysis from over-deliberation
RL7|cognitive development requires both maturation and experience — neither alone sufficient|brain maturation provides capacity; experience provides content and calibration|deprivation (no experience) prevents development even with mature brain; precocious expectations (too early) exceed maturational capacity
RL8|all perception involves inference — there is no raw uninterpreted sensation reaching consciousness|perception is predictive — brain infers likely cause of sensory signals using prior knowledge (FD15)|perceiving illusions as errors rather than features — illusions reveal the inference process working correctly on unusual input
RL9|emotion and cognition are integrated, not opposing systems|emotion provides value signals essential for rational decision-making — patients with emotional processing damage make poor decisions (Damasio's somatic marker hypothesis)|treating emotion as noise to be suppressed — actually degrades decision quality; or treating cognition as cold calculation — ignores emotional information
RL10|metacognition is learnable and improvable — not fixed|monitoring accuracy, calibration, and strategic regulation all improve with training and feedback|assuming metacognitive ability is innate and unchangeable — failing to teach metacognitive skills
RL11|understanding has levels — recognition is not comprehension is not application is not transfer|each level requires different cognitive operations and produces different capabilities|conflating recognition with understanding — "I recognize this formula" ≠ "I can apply this formula in novel situations"

# relationships(from|rel|to)
# process flow
PR1|enables|PR2
PR2|enables|PR3,PR4,PR13
PR3|enables|PR4,PR7
PR4|enables|PR5
PR5|enables|PR6
PR6|enables|PR7,PR8,PR9
PR7|enables|PR8,PR9,PR10,PR11,PR15,PR16
PR8|enables|PR9,PR10
PR9|enables|PR10,PR16
PR14|enables|PR4,PR7,PR15,PR18,PR19
PR17|constrains|PR3,PR7,PR8,PR9
PR20|modulates|PR3,PR4,PR6,PR8,PR9
# awareness relationships
AW1|enables|AW2
AW2|enables|AW3
AW3|enables|AW4
AW4|enables|MC1,MC2
AW6|enables|AW1
AW7|enables|AW1,AW6
AW5|requires|AW2,PR3
AW8|opposes|AW3,AW4
AW9|enables|AW4,MC2
# memory system relationships
MS1|enables|MS3
MS2|enables|MS3
MS3|enables|MS4
MS4|enables|PR8,PR9,PR10,PR11
MS4|derives_from|MS3
MS5|requires|PR4,PR5
MS6|derives_from|MS5
MS7|requires|PR14
MS8|requires|PR16,MS5
MS9|enables|PR2,PR13
MS10|requires|MS5,MS6,MM5
# attention types
AT1|opposes|AT2
AT3|requires|AT6
AT5|opposes|AT6
AT7|subtype_of|AT1
AT8|subtype_of|AT1
AT9|subtype_of|AT1
AT10|derives_from|AT1
# reasoning depends on
RN1|requires|PR8,MS4
RN2|requires|PR8,MS5,MS6
RN3|requires|RN2,RN5
RN4|requires|MM8
RN5|requires|MM2
RN6|requires|MM1
RN8|requires|RN2,RN1
RN9|requires|MM2,RN5
RN11|requires|PR10,PR16
# understanding levels
UN1|enables|UN2
UN2|enables|UN3
UN3|enables|UN4
UN4|enables|UN5
UN5|enables|UN6
UN6|enables|UN7
UN8|requires|UN4
UN9|requires|UN5,RN4
UN10|requires|MS7,PR14
UN11|requires|UN5,MM2
UN12|requires|EM1,MS7
# mental model dependencies
MM1|requires|PR2,MS5
MM2|requires|RN5,PR14
MM3|requires|SO1,SO2
MM4|requires|MS5,MS8
MM5|requires|AW3,MS10
MM6|requires|EM5,PR14
MM7|requires|MS5,MM4,MM3
MM8|requires|MS6,PR13,PR14
MM9|requires|PR20,EM6,MM3
# metacognition hierarchy
MC1|enables|MC3
MC2|enables|MC3
MC3|requires|MC1,MC2
MC4|subtype_of|MC2
MC5|subtype_of|MC2
MC6|requires|MC2,MC5
MC7|requires|MC1,MC2
MC8|requires|MS5,MS6
# bias → cognitive process
BI1|distorts|RN2,RN3,PR6
BI2|distorts|RN8,PR9
BI3|distorts|RN8,PR9
BI4|distorts|RN8,PR13
BI5|distorts|MM4,PR6
BI6|distorts|MC1,MC2,MC6
BI7|distorts|PR9
BI8|distorts|PR9
BI9|distorts|SO1,RN5
BI12|distorts|RN8
BI14|distorts|PR16,MM4
BI15|distorts|PR8,PR9
# development → cognitive achievement
DV1|enables|DV2
DV2|enables|DV3
DV3|enables|DV4
DV5|enables|SO1,MM3
DV6|enables|PR17,MC3
DV7|enables|PR11,PR12,SO6
# disorders → affected systems
DO1|impairs|PR12
DO2|impairs|PR11
DO3|impairs|MS5,PR4
DO4|impairs|MS5,PR6
DO5|impairs|PR2,PR13
DO6|impairs|AT8,AW5
DO7|impairs|AT3,AT4,PR17
DO8|impairs|SO1,SO2,SO6
DO9|impairs|MS5,MS6,PR17
DO10|impairs|MC8,PR17,SO1
# embodied cognition connections
EM1|supports|FD10
EM2|supports|FD10,RN4
EM3|extends|FD9
EM4|supports|FD10,FD11
EM5|supports|FD11,FD19
EM6|enables|MM9,PR20
EM7|enables|EM5,EM1
# social cognition dependencies
SO1|requires|DV5,AW3
SO2|requires|EM6,SO1
SO3|enables|SO1,DV7
SO4|requires|SO3,PR20
SO5|enables|SO2,SO8
SO6|requires|SO1,PR11,PR12
SO7|requires|SO1,SO3
SO8|requires|SO5,SO1,PR14
# foundations → theories
FD13|opposes|FD14
FD15|implements|FD16
FD15|extends|FD3
FD17|explains|BI1-BI15
FD9|opposes|FD10,FD11
FD12|implements|FD3
# measurement → process
ME1|measures|PR1-PR20
ME2|measures|FD18,PR2-PR20
ME3|measures|PR3,PR11,PR20
ME5|measures|FD6
ME6|reveals|DO1-DO10
ME7|tests|PR3,PR11,PR12
ME9|measures|AT1,AT5,AT6,AT8
# comparative → human cognition
CG1|limited_by|SO7,UN9,DV7
CG2|exhibits|RN5,MS8,PR10
CG6|limited_by|FD4,FD10,EM6
# rules → foundations
RL1|derives_from|FD2,FD15
RL2|derives_from|AT1,AT10,AW2
RL3|derives_from|MS5,PR6
RL4|constrains|UN9
RL5|constrains|UN10,RN3
RL6|derives_from|FD13,FD17
RL8|derives_from|FD15,PR2
RL9|opposes|FD17
RL10|enables|MC1,MC2,MC3
RL11|implements|UN1-UN12
# cross-references to other compactions
FD17|cross_ref|RS1-RS7
PR9|cross_ref|BS1-BS8
BI1-BI15|cross_ref|CO19
MC2|cross_ref|PH9
MM2|cross_ref|RU1-RU25
RL3|cross_ref|DF1-DF18

# section_index(section|title|ids)
1|Foundations of Cognition|FD1-FD20
2|Cognitive Processes|PR1-PR20
3|Types of Awareness|AW1-AW10
4|Memory Systems|MS1-MS10
5|Attention|AT1-AT10
6|Reasoning Types|RN1-RN12
7|Levels of Understanding|UN1-UN12
8|Mental Models|MM1-MM9
9|Metacognition|MC1-MC8
10|Cognitive Biases|BI1-BI15
11|Cognitive Development|DV1-DV8
12|Cognitive Disorders|DO1-DO10
13|Measurement Methods|ME1-ME10
14|Embodied Cognition|EM1-EM7
15|Social Cognition|SO1-SO8
16|Comparative Cognition|CG1-CG6
17|Rules of Cognition|RL1-RL11

# decode_legend
id_prefixes: FD=foundation, PR=process, AW=awareness_type, MS=memory_system, AT=attention, RN=reasoning, UN=understanding, MM=mental_model, MC=metacognition, BI=bias, DV=development, DO=disorder, ME=measurement, EM=embodied, SO=social_cognition, CG=comparative, RL=rule
rel_types: enables|requires|implements|constrains|subtype_of|derives_from|opposes|modulates|distorts|impairs|supports|extends|explains|measures|tests|reveals|exhibits|limited_by|cross_ref
cross_ref_prefixes: RS=reasoner, BS=behavior_selection (from UTILITY AI), CO=concept (from UTILITY AI), PH=phase (from TROUBLESHOOTING), RU=rule, DF=defect (from MASONRY)
time_scales: ms=milliseconds, s=seconds, min=minutes, hr=hours
neural_notation: BA=Brodmann area, PFC=prefrontal cortex, MTL=medial temporal lobe
development_ages: approximate — individual variation is substantial; cultural variation affects some stages
disorder_note: disorders listed are cognitive profiles, not diagnostic criteria — clinical diagnosis requires standardized assessment
theoretical_status: multiple competing theories noted (e.g., GWT vs IIT for consciousness) — no single theory is consensus; entries reflect major positions without adjudication
confidence: generated from LLM weights — reflects established cognitive science, neuroscience, and philosophy of mind (Kahneman, Baddeley, Tulving, Piaget, Friston, Clark, Tononi, Baars, Gibson, Damasio, Tomasello)

# relation_mapping(doc_rel|canonical_rel|notes)
enables|enables|exact match
requires|requires|exact match
implements|implements|exact match
constrains|constrains|exact match
subtype_of|specializes|exact semantic match
derives_from|derived_from|exact match
opposes|opposes|exact match; symmetric
modulates|regulates|emotion modulates attention = regulates its behavior
distorts|degrades|bias distorts reasoning = degrades reasoning quality
impairs|degrades|disorder impairs memory system = degrades its function
supports|enables|embodied cognition supports enactivism = enables that framework
extends|extends|exact match
explains|explains|exact match
measures|inspects|measurement method measures process = inspects without modifying
tests|validates|TMS tests causal role of brain area = validates its involvement
reveals|indicates|lesion study reveals disorder = indicates affected function
exhibits|indicates|corvids exhibit causal reasoning = indicates that capability
limited_by|constrains|inverse; great apes limited by shared intentionality = shared intentionality constrains their cognition
cross_ref|references|cross-domain link = references
