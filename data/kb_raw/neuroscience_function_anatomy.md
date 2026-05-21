# NEUROSCIENCE: FUNCTIONAL NEUROANATOMY — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: divisions → regions → nuclei → tracts → neurotransmitters → receptors → circuits → cells → concepts → functional_maps → cranial_nerves → vasculature → barriers → clinical → relationships → section_index → decode_legend

# divisions(id|name|embryonic_origin|adult_structures|primary_function)
DV1|telencephalon|prosencephalon (forebrain)|cerebral cortex, basal ganglia, hippocampus, amygdala, olfactory bulb, lateral ventricles|cognition, voluntary movement, sensation, emotion, memory, language
DV2|diencephalon|prosencephalon (forebrain)|thalamus, hypothalamus, epithalamus (pineal, habenula), subthalamus, third ventricle|sensory relay, homeostasis, endocrine control, circadian rhythm, motor modulation
DV3|mesencephalon|mesencephalon (midbrain)|tectum (superior/inferior colliculi), tegmentum (red nucleus, substantia nigra, PAG, VTA), cerebral peduncles|visual/auditory reflexes, dopaminergic pathways, motor relay, pain modulation
DV4|metencephalon|rhombencephalon (hindbrain)|pons, cerebellum|motor coordination, balance, respiratory regulation, relay between cortex and cerebellum
DV5|myelencephalon|rhombencephalon (hindbrain)|medulla oblongata|autonomic vital centers (cardiac, respiratory, vasomotor), cranial nerve nuclei, decussation of pyramids
DV6|spinal cord|neural tube|cervical (C1–C8), thoracic (T1–T12), lumbar (L1–L5), sacral (S1–S5), coccygeal segments|sensory relay to brain, motor output to body, spinal reflexes, autonomic preganglionic outflow

# regions(id|name|division_fk|location|layers_or_subdivisions|function)
# Cerebral cortex lobes and major areas
R1|frontal lobe|DV1|anterior to central sulcus, superior to lateral sulcus|prefrontal cortex, premotor cortex, supplementary motor area, primary motor cortex (M1, Brodmann area 4), Broca's area (44, 45), frontal eye fields (area 8)|executive function, planning, working memory, personality, voluntary movement, speech production, eye movement
R2|parietal lobe|DV1|posterior to central sulcus, superior to lateral sulcus, anterior to parieto-occipital sulcus|primary somatosensory cortex (S1, areas 3,1,2), posterior parietal cortex (areas 5, 7), supramarginal gyrus (40), angular gyrus (39)|somatosensory processing, spatial awareness, visuomotor integration, language comprehension (angular gyrus), attention
R3|temporal lobe|DV1|inferior to lateral sulcus|primary auditory cortex (A1, areas 41, 42), Wernicke's area (22 posterior), superior temporal sulcus, fusiform gyrus, inferior temporal cortex, medial temporal (hippocampus, entorhinal, parahippocampal)|auditory processing, language comprehension, face recognition (fusiform), object recognition (ventral stream), memory encoding
R4|occipital lobe|DV1|posterior to parieto-occipital sulcus|primary visual cortex (V1, area 17), V2 (18), V3, V4 (color), V5/MT (motion)|visual processing, color perception, motion detection, form recognition
R5|insular cortex|DV1|deep to lateral sulcus, covered by frontal/parietal/temporal opercula|anterior insula (agranular), posterior insula (granular)|interoception, taste (gustatory cortex), pain processing, emotional awareness, autonomic regulation, empathy
R6|cingulate cortex|DV1|medial surface, arching over corpus callosum|anterior cingulate cortex (ACC, area 24/32), posterior cingulate cortex (PCC, area 23/31), retrosplenial cortex (29/30)|ACC: conflict monitoring, error detection, pain affect, motivation; PCC: default mode network, self-referential processing, memory retrieval
R7|prefrontal cortex|DV1|anterior frontal lobe|dorsolateral PFC (areas 9, 46), ventromedial PFC (areas 10, 11, 12, 25), orbitofrontal cortex (areas 11, 47)|working memory, decision-making, impulse control, reward valuation, social cognition, goal-directed behavior
# Subcortical telencephalon
R8|hippocampal formation|DV1|medial temporal lobe|dentate gyrus → CA3 → CA1 → subiculum; entorhinal cortex (input/output hub)|episodic memory encoding, spatial navigation (place cells), memory consolidation, pattern separation (DG), pattern completion (CA3)
R9|amygdala|DV1|anterior medial temporal lobe|basolateral complex (BLA), central nucleus (CeA), medial nucleus, cortical nucleus|fear conditioning, threat detection, emotional memory, reward learning, social evaluation
R10|basal ganglia|DV1|deep cerebral hemispheres|caudate nucleus, putamen (together = striatum), globus pallidus (internal GPi, external GPe), nucleus accumbens (ventral striatum)|motor initiation/selection, action selection, reward processing, procedural learning, habit formation
R11|striatum|DV1|caudate + putamen + nucleus accumbens|dorsal striatum (caudate + putamen): motor/cognitive; ventral striatum (nucleus accumbens): reward/motivation|input station of basal ganglia; receives cortical glutamatergic + nigral dopaminergic input; GABAergic medium spiny neurons (MSNs) as principal cells
R12|globus pallidus|DV1|medial to putamen|GPe (external): indirect pathway relay; GPi (internal): major output nucleus of BG → thalamus|tonic inhibition of thalamus; GPi = output gate; disinhibition model of movement initiation
# Diencephalon
R13|thalamus|DV2|bilateral ovoid masses flanking third ventricle|~60 nuclei grouped: anterior, medial, lateral, ventral, intralaminar, reticular|sensory relay (all modalities except olfaction), motor relay, arousal gating, attention filtering, cortical synchronization
R14|hypothalamus|DV2|floor of third ventricle, inferior to thalamus, superior to pituitary|suprachiasmatic (SCN), supraoptic (SON), paraventricular (PVN), arcuate, ventromedial (VMH), lateral hypothalamic area (LHA), preoptic area|circadian rhythm (SCN), osmolality/ADH (SON), stress/CRH/oxytocin (PVN), feeding (arcuate, VMH, LHA), thermoregulation (preoptic), reproductive behavior
R15|epithalamus|DV2|posterior dorsal diencephalon|pineal gland, habenula, stria medullaris|pineal: melatonin secretion (circadian); habenula: reward prediction error, aversion, modulates dopamine and serotonin systems
# Midbrain
R16|superior colliculus|DV3|dorsal midbrain (tectum)|superficial layers (visual), intermediate/deep layers (multimodal, motor)|saccadic eye movements, visual orienting reflexes, multisensory integration
R17|inferior colliculus|DV3|dorsal midbrain, caudal to superior colliculus|central nucleus, pericentral, external cortex|obligatory auditory relay; tonotopic organization; ascending auditory pathway to MGN
R18|substantia nigra|DV3|ventral midbrain|pars compacta (SNc): dopaminergic neurons; pars reticulata (SNr): GABAergic output|SNc: dopamine to striatum (nigrostriatal pathway); SNr: BG output nucleus (functionally similar to GPi)
R19|ventral tegmental area (VTA)|DV3|medial to substantia nigra|dopaminergic (A10 cell group) and GABAergic neurons|mesolimbic pathway (VTA → nucleus accumbens): reward, motivation; mesocortical pathway (VTA → PFC): cognition, working memory
R20|periaqueductal gray (PAG)|DV3|surrounds cerebral aqueduct|dorsolateral, lateral, ventrolateral columns|descending pain modulation (endogenous opioids), defensive behaviors (fight/flight/freeze), vocalization, autonomic regulation
R21|red nucleus|DV3|tegmentum, ventromedial to PAG|magnocellular (rubrospinal) and parvocellular (rubro-olivary) portions|rubrospinal tract: flexor motor control (upper limb); relay in cerebellar-cortical loop
# Pons and Cerebellum
R22|pontine nuclei|DV4|ventral pons|scattered nuclei receiving cortical input|relay cortical input to contralateral cerebellum via middle cerebellar peduncle; corticopontocerebellar pathway
R23|locus coeruleus|DV4|dorsal pons, lateral to fourth ventricle floor|compact noradrenergic nucleus (A6 cell group); ~15,000–50,000 neurons per side|sole source of norepinephrine to cortex; arousal, attention, vigilance, stress response, memory consolidation
R24|raphe nuclei|DV4,DV5|midline brainstem, pons through medulla|dorsal raphe (B7), median raphe (B8), magnus, obscurus, pallidus|principal serotonergic nuclei; mood regulation, sleep-wake, pain modulation, appetite, aggression
R25|parabrachial nucleus|DV4|dorsolateral pons, around superior cerebellar peduncle|lateral (sensory) and medial (motor) subnuclei|taste relay, visceral sensation relay, respiratory chemosensitivity, arousal, pain processing, thermoregulation
R26|cerebellum|DV4|posterior fossa|anterior lobe (spinocerebellum), posterior lobe (cerebrocerebellum/neocerebellum), flocculonodular lobe (vestibulocerebellum); deep nuclei: dentate, interposed (emboliform + globose), fastigial|motor coordination, error correction, motor learning, timing, balance, cognitive/emotional modulation (posterior lobe)
R27|cerebellar cortex|DV4|surface of cerebellum|3 layers: molecular (parallel fibers, stellate, basket cells), Purkinje cell layer, granular layer (granule cells, Golgi cells)|computation: granule cells receive mossy fiber input → parallel fibers excite Purkinje cells; climbing fibers (from inferior olive) → Purkinje cells; Purkinje output = sole cerebellar cortical output (inhibitory, GABA)
# Medulla
R28|medulla oblongata|DV5|inferior brainstem, continuous with spinal cord|pyramids (corticospinal decussation), inferior olivary nucleus, nucleus tractus solitarius (NTS), dorsal motor nucleus of vagus, nucleus ambiguus, area postrema, gracile/cuneate nuclei|cardiovascular center, respiratory center, vomiting, swallowing, cranial nerve nuclei IX–XII, sensory relay (posterior columns → medial lemniscus decussation)
R29|nucleus tractus solitarius (NTS)|DV5|dorsal medulla|receives visceral afferents from CN VII, IX, X|taste processing, baroreceptor reflex integration, chemoreceptor input, cardiorespiratory regulation, GI regulation
R30|reticular formation|DV3,DV4,DV5|core of brainstem from medulla through midbrain|ascending reticular activating system (ARAS), descending reticulospinal tracts, multiple nuclei|consciousness/arousal (ARAS), sleep-wake transitions, autonomic regulation, postural tone, pain modulation, motor pattern generators
# Spinal cord
R31|dorsal horn|DV6|posterior gray matter of spinal cord|laminae I–VI (Rexed); substantia gelatinosa (lamina II); nucleus proprius (III–IV)|sensory processing: pain (I, II), temperature (I), touch (III–V), proprioception relay; gate control of pain
R32|ventral horn|DV6|anterior gray matter of spinal cord|lamina IX (alpha and gamma motor neurons); lamina VIII (interneurons)|lower motor neurons → skeletal muscle via ventral roots; alpha MN: extrafusal (force); gamma MN: intrafusal (spindle sensitivity)
R33|lateral horn|DV6|lateral gray matter, T1–L2 (sympathetic) and S2–S4 (parasympathetic)|intermediolateral cell column (IML)|preganglionic autonomic neurons; sympathetic (T1–L2); parasympathetic (S2–S4, sacral)
R34|posterior column nuclei|DV5|dorsal medulla|nucleus gracilis (lower body, T6 and below), nucleus cuneatus (upper body, T6 and above)|relay station for fine touch, vibration, proprioception; second-order neurons → medial lemniscus → VPL thalamus

# nuclei(id|name|region_fk|neurotransmitter|projections|function)
N1|ventral posterolateral nucleus (VPL)|R13|glutamate|receives medial lemniscus + spinothalamic → projects to S1 (areas 3,1,2)|relay for body somatosensory (touch, pain, temperature, proprioception)
N2|ventral posteromedial nucleus (VPM)|R13|glutamate|receives trigeminothalamic tract → projects to S1 face area|relay for face somatosensory
N3|lateral geniculate nucleus (LGN)|R13|glutamate|receives optic tract → projects to V1 via optic radiation|relay for vision; 6 layers (magno 1–2, parvo 3–6, konio)
N4|medial geniculate nucleus (MGN)|R13|glutamate|receives inferior colliculus → projects to A1 via auditory radiation|relay for audition; tonotopic organization
N5|ventral lateral nucleus (VL)|R13|glutamate|receives cerebellar (dentate) and BG (GPi) output → projects to M1 and premotor|motor relay; integrates cerebellar and BG signals for cortical motor areas
N6|ventral anterior nucleus (VA)|R13|glutamate|receives BG output (GPi, SNr) → projects to premotor and prefrontal cortex|motor planning relay; BG influence on frontal cortex
N7|anterior nucleus|R13|glutamate|receives mammillary body (mammillothalamic tract) → projects to cingulate cortex|part of Papez circuit; memory, emotion
N8|mediodorsal nucleus (MD)|R13|glutamate|reciprocal connections with prefrontal cortex; receives amygdala, BG input|executive function, memory, emotional processing; damaged in Korsakoff syndrome
N9|pulvinar|R13|glutamate|reciprocal with parietal, temporal, occipital cortex|visual attention, multisensory integration, salience detection; largest thalamic nucleus
N10|reticular nucleus|R13|GABA|surrounds thalamus laterally; receives collaterals from all thalamocortical and corticothalamic fibers; inhibits other thalamic nuclei|attention gating; does NOT project to cortex; modulates which thalamic relay nuclei are active
N11|intralaminar nuclei (centromedian, parafascicular)|R13|glutamate|project diffusely to cortex and striatum|arousal, consciousness, pain processing; part of ARAS
N12|suprachiasmatic nucleus (SCN)|R14|GABA, VIP, AVP|receives retinal input (melanopsin RGCs via retinohypothalamic tract); projects to pineal (via SCG), PVN, other hypothalamic nuclei|master circadian pacemaker; ~20,000 neurons; entrains to light-dark cycle
N13|paraventricular nucleus (PVN)|R14|CRH, oxytocin, AVP (vasopressin), TRH|magnocellular → posterior pituitary (oxytocin, AVP); parvocellular → median eminence (CRH, TRH); autonomic → brainstem, spinal cord|stress response (HPA axis via CRH → ACTH); water balance (AVP); parturition/lactation (oxytocin); autonomic control
N14|arcuate nucleus|R14|POMC/α-MSH (anorexigenic), NPY/AgRP (orexigenic), dopamine (TIDA neurons)|projects within hypothalamus and to median eminence|feeding regulation (hunger/satiety); dopamine → inhibits prolactin; GnRH pulse generator nearby
N15|lateral hypothalamic area (LHA)|R14|orexin/hypocretin, MCH|widespread projections to cortex, brainstem, spinal cord|promotes wakefulness and arousal (orexin); feeding (hunger center); reward; loss of orexin → narcolepsy
N16|ventromedial hypothalamus (VMH)|R14|glutamate, SF-1 expressing neurons|projects to PAG, brainstem|satiety center; defensive aggression; glucose sensing; bone metabolism regulation
N17|preoptic area|R14|GABA (VLPO sleep neurons), GnRH neurons|VLPO → inhibits wake-promoting nuclei (LC, raphe, TMN, orexin); GnRH → median eminence|thermoregulation; sleep initiation (VLPO flip-flop switch); reproductive hormone control (GnRH)
N18|basolateral amygdala (BLA)|R9|glutamate (principal neurons), GABA (interneurons)|receives sensory cortex, thalamus, hippocampus → projects to CeA, PFC, striatum, hippocampus|fear learning (CS-US association), reward valuation, emotional memory encoding, decision-making under uncertainty
N19|central nucleus of amygdala (CeA)|R9|GABA, CRH, enkephalin|receives BLA → projects to hypothalamus, PAG, brainstem (NTS, parabrachial, LC)|output station of amygdala; triggers autonomic fear responses (freezing, HR increase, cortisol), pain modulation, anxiety
N20|dentate gyrus|R8|glutamate (granule cells), GABA (interneurons)|receives entorhinal cortex layer II (perforant path) → projects to CA3 via mossy fibers|pattern separation; sparse coding; one of two sites of adult neurogenesis (subgranular zone)
N21|CA3|R8|glutamate (pyramidal cells)|receives mossy fibers (DG), perforant path (EC layer II); extensive recurrent collaterals → projects to CA1 via Schaffer collaterals|pattern completion; autoassociative memory; recurrent network enables recall from partial cues
N22|CA1|R8|glutamate (pyramidal cells)|receives Schaffer collaterals (CA3), direct EC layer III input → projects to subiculum, EC, PFC|memory encoding output; place cells; temporal coding; comparator function (match/mismatch detection)
N23|dentate nucleus|R26|glutamate|receives Purkinje cell inhibition (cerebellar cortex); projects to contralateral VL thalamus and red nucleus|largest deep cerebellar nucleus; primary output for cerebrocerebellum (voluntary movement planning, cognitive functions)
N24|fastigial nucleus|R26|glutamate|receives Purkinje input from vermis; projects to vestibular nuclei and reticular formation|balance, postural control, eye movements (vestibulocerebellum output)
N25|inferior olivary nucleus|R28|glutamate|receives input from red nucleus, cortex, spinal cord → climbing fibers to contralateral cerebellar cortex (1:1 to Purkinje cells)|error signal for motor learning; climbing fiber discharge triggers complex spike in Purkinje cell → LTD at parallel fiber synapse → cerebellar learning
N26|vestibular nuclei|DV5|glutamate|receive CN VIII vestibular input + cerebellar (fastigial) → project to spinal cord (vestibulospinal), CN III/IV/VI nuclei (VOR), cerebellum, thalamus|balance, postural reflexes, vestibulo-ocular reflex (VOR), spatial orientation
N27|nucleus basalis of Meynert|DV1|acetylcholine|projects diffusely to entire neocortex|cortical cholinergic innervation; attention, arousal, plasticity; degenerates in Alzheimer's disease
N28|pedunculopontine nucleus (PPN)|DV3|acetylcholine, glutamate|reciprocal with BG (GPi, SNr, STN); projects to thalamus, brainstem, spinal cord|locomotor initiation, REM sleep, reward; part of mesencephalic locomotor region
N29|tuberomammillary nucleus (TMN)|R14|histamine|projects diffusely to cortex, BG, brainstem|wakefulness promotion; antihistamines cause drowsiness by blocking TMN output; inhibited by VLPO during sleep

# tracts(id|name|origin|termination|decussation|function|modality)
TR1|corticospinal (pyramidal)|primary motor cortex (M1, area 4) + premotor areas|ventral horn motor neurons (alpha MN)|~90% decussate at pyramidal decussation (medulla) → lateral CST; ~10% ipsilateral → anterior CST|voluntary skilled movement, especially distal limbs|motor (descending)
TR2|corticobulbar|motor cortex (face area of M1)|cranial nerve motor nuclei (V, VII, IX, X, XI, XII) in brainstem|bilateral innervation to most CN nuclei; CN VII lower face and CN XII receive predominantly contralateral|voluntary control of face, tongue, pharynx, larynx|motor (descending)
TR3|rubrospinal|red nucleus (magnocellular)|ventral horn interneurons, cervical/upper thoracic cord|decussates in ventral tegmental decussation (midbrain)|upper limb flexor facilitation; minor in humans; supplements CST|motor (descending)
TR4|reticulospinal (pontine/medullary)|pontine reticular formation (medial) + medullary reticular formation (lateral)|ventral horn interneurons and motor neurons|pontine: ipsilateral (facilitates extensors); medullary: bilateral (inhibits extensors)|postural control, automatic movements, muscle tone|motor (descending)
TR5|vestibulospinal (lateral)|lateral vestibular nucleus (Deiters')|ventral horn motor neurons, ipsilateral|ipsilateral (does not decussate)|facilitates ipsilateral extensors; postural reflexes against gravity|motor (descending)
TR6|tectospinal|superior colliculus (deep layers)|upper cervical ventral horn|decussates in dorsal tegmental decussation (midbrain)|orienting head/neck movements toward visual/auditory stimuli|motor (descending)
TR7|dorsal column–medial lemniscus (DCML)|peripheral sensory receptors → dorsal root ganglia → posterior columns (gracile fasciculus: below T6; cuneate fasciculus: above T6)|gracile/cuneate nuclei (medulla) → medial lemniscus (decussates) → VPL thalamus → S1|medulla (internal arcuate fibers)|fine touch, vibration, proprioception, two-point discrimination|sensory (ascending)
TR8|spinothalamic (anterolateral)|dorsal horn (laminae I, IV, V) → decussate within 1–2 segments via anterior white commissure|VPL thalamus → S1; also intralaminar nuclei|spinal cord (anterior white commissure, within 1–2 segments of entry)|lateral: pain, temperature; anterior: crude touch, pressure|sensory (ascending)
TR9|spinocerebellar (dorsal)|Clarke's nucleus (C8–L2, lamina VII)|ipsilateral cerebellum (inferior cerebellar peduncle)|ipsilateral (does not decussate)|unconscious proprioception from lower limb to cerebellum|sensory (ascending)
TR10|spinocerebellar (ventral)|border cells (laminae V–VII, lumbar cord)|cerebellum (superior cerebellar peduncle)|double decussation: once in cord, once in cerebellum (net ipsilateral)|unconscious proprioception; internal copy of spinal motor commands|sensory (ascending)
TR11|optic pathway|retinal ganglion cells → optic nerve → optic chiasm (nasal fibers decussate) → optic tract → LGN → optic radiation → V1|V1 (area 17) along calcarine sulcus|partial at optic chiasm (nasal fibers only)|vision; retinotopic organization preserved throughout|sensory (ascending)
TR12|auditory pathway|cochlear hair cells → spiral ganglion → CN VIII → cochlear nuclei → superior olivary complex → lateral lemniscus → inferior colliculus → MGN → A1|A1 (areas 41, 42)|multiple partial decussations at superior olive and beyond; bilateral representation above brainstem|audition; tonotopic organization preserved; bilateral → unilateral lesion rarely causes deafness|sensory (ascending)
TR13|medial longitudinal fasciculus (MLF)|vestibular nuclei, PPRF (paramedian pontine reticular formation)|CN III, IV, VI nuclei|bilateral|coordinates conjugate eye movements; VOR; internuclear connections for horizontal gaze|sensory-motor (integrative)
TR14|fornix|hippocampus (subiculum, CA1) → fimbria → crus → body → columns|mammillary bodies (postcommissural); septal nuclei (precommissural)|primarily ipsilateral|hippocampal output; memory circuit (Papez); spatial memory|limbic
TR15|mammillothalamic tract|mammillary bodies|anterior thalamic nucleus|ipsilateral|Papez circuit relay; episodic memory|limbic
TR16|stria terminalis|amygdala (BLA, CeA)|bed nucleus of stria terminalis (BNST), hypothalamus, nucleus accumbens|ipsilateral|slow amygdala output pathway; sustained anxiety, reproductive/social behavior|limbic
TR17|uncinate fasciculus|anterior temporal lobe|orbitofrontal cortex|ipsilateral|connects emotional memory (temporal) with decision-making (OFC); emotional regulation; social cognition|association
TR18|arcuate fasciculus|Wernicke's area (posterior temporal)|Broca's area (inferior frontal)|ipsilateral (L hemisphere dominant)|language: connects receptive and expressive areas; phonological loop; repetition|association
TR19|cingulum|cingulate cortex (runs within cingulate gyrus)|connects frontal, parietal, temporal cortex, hippocampus, cingulate|ipsilateral|limbic association; default mode network connectivity; emotional processing; memory|association
TR20|corpus callosum|cortical areas of one hemisphere|mirror cortical areas of opposite hemisphere|commissural (interhemispheric)|interhemispheric transfer of all modalities; ~200 million axons; largest white matter structure|commissural
TR21|anterior commissure|anterior temporal cortex, olfactory structures|contralateral mirror areas|commissural|olfactory and temporal interhemispheric connections; supplement to corpus callosum|commissural
TR22|nigrostriatal pathway|SNc (substantia nigra pars compacta)|dorsal striatum (caudate + putamen)|ipsilateral|dopamine delivery to striatum; movement initiation; degeneration → Parkinson's disease|modulatory
TR23|mesolimbic pathway|VTA|nucleus accumbens, amygdala, hippocampus|ipsilateral predominantly|reward, motivation, reinforcement learning; implicated in addiction, schizophrenia (positive symptoms)|modulatory
TR24|mesocortical pathway|VTA|prefrontal cortex (especially DLPFC, ACC)|ipsilateral predominantly|working memory, attention, executive function; hypofunction → negative symptoms of schizophrenia|modulatory
TR25|tuberoinfundibular pathway|arcuate nucleus|median eminence (pituitary portal system)|local|dopamine inhibits prolactin release from anterior pituitary; blockade → hyperprolactinemia|modulatory

# neurotransmitters(id|name|type|synthesis|inactivation|primary_systems|receptors)
NT1|glutamate|amino acid (excitatory)|from glutamine via glutaminase; from α-ketoglutarate|reuptake by EAAT1-5 (astrocytes + neurons) → converted to glutamine by glutamine synthetase|~80% of cortical synapses; principal excitatory NT of CNS|AMPA (fast EPSP), NMDA (slow, Ca²⁺, coincidence detector), kainate, mGluR (metabotropic, 8 subtypes)
NT2|GABA (γ-aminobutyric acid)|amino acid (inhibitory)|from glutamate via glutamic acid decarboxylase (GAD); requires pyridoxal phosphate (vitamin B6)|reuptake by GAT-1,2,3; metabolized by GABA-transaminase|~20% of cortical neurons are GABAergic interneurons; principal inhibitory NT of CNS|GABA_A (ionotropic, Cl⁻ channel; site for benzodiazepines, barbiturates, ethanol), GABA_B (metabotropic, K⁺/Ca²⁺, Gi-coupled)
NT3|dopamine|monoamine (catecholamine)|tyrosine → L-DOPA (tyrosine hydroxylase, rate-limiting) → dopamine (DOPA decarboxylase)|reuptake by DAT; degraded by MAO + COMT → HVA|nigrostriatal (motor), mesolimbic (reward), mesocortical (cognition), tuberoinfundibular (prolactin)|D1-like (D1, D5: Gs, ↑cAMP), D2-like (D2, D3, D4: Gi, ↓cAMP); D2 autoreceptors on presynaptic terminal
NT4|norepinephrine (noradrenaline)|monoamine (catecholamine)|dopamine → norepinephrine (dopamine β-hydroxylase)|reuptake by NET; degraded by MAO + COMT → VMA, MHPG|locus coeruleus → diffuse cortical/subcortical projection; arousal, attention, stress|α1 (Gq, ↑IP3/DAG), α2 (Gi, ↓cAMP, presynaptic autoreceptor), β1 (Gs, ↑cAMP, cardiac), β2 (Gs, bronchial smooth muscle), β3 (adipose)
NT5|serotonin (5-HT)|monoamine (indolamine)|tryptophan → 5-HTP (tryptophan hydroxylase, rate-limiting) → serotonin (aromatic amino acid decarboxylase)|reuptake by SERT; degraded by MAO → 5-HIAA|raphe nuclei → widespread cortical, limbic, brainstem projections; mood, sleep, appetite, pain|14 subtypes in 7 families: 5-HT1A (Gi, anxiolysis), 5-HT2A (Gq, psychedelic target), 5-HT3 (ionotropic, emesis), 5-HT4 (Gs, GI motility), etc.
NT6|acetylcholine (ACh)|ester|choline + acetyl-CoA via choline acetyltransferase (ChAT)|hydrolysis by acetylcholinesterase (AChE) in synaptic cleft → choline recycled|NMJ (all skeletal muscle); autonomic ganglia; parasympathetic postganglionic; basal forebrain → cortex (attention); striatal interneurons|nicotinic (ionotropic: NMJ type α1β1δε; neuronal types α4β2, α7); muscarinic (metabotropic: M1,M3,M5 Gq excitatory; M2,M4 Gi inhibitory)
NT7|histamine|monoamine|histidine → histamine (histidine decarboxylase)|methylation by HNMT (intracellular); oxidation by DAO (extracellular)|tuberomammillary nucleus → diffuse cortical/subcortical; wakefulness|H1 (Gq, wakefulness, allergic), H2 (Gs, gastric acid), H3 (Gi, presynaptic autoreceptor, heteroreceptor)
NT8|glycine|amino acid (inhibitory)|from serine via serine hydroxymethyltransferase|reuptake by GlyT1 (astrocytes), GlyT2 (neurons)|principal inhibitory NT of spinal cord and brainstem; co-agonist at NMDA receptor (with glutamate)|glycine receptor (ionotropic, Cl⁻ channel; strychnine-sensitive); NMDA receptor glycine site (strychnine-insensitive)
NT9|endorphins/enkephalins|neuropeptide (opioid)|pro-opiomelanocortin (POMC) → β-endorphin; proenkephalin → met/leu-enkephalin; prodynorphin → dynorphin|peptidase degradation (no reuptake)|PAG, raphe, spinal dorsal horn, hypothalamus, amygdala, nucleus accumbens|μ (MOR: analgesia, euphoria, respiratory depression), δ (DOR: analgesia, mood), κ (KOR: dysphoria, spinal analgesia)
NT10|endocannabinoids|lipid (retrograde)|anandamide (AEA): from membrane phospholipids via NAPE-PLD; 2-AG: from DAG via DAG lipase|FAAH (degrades AEA); MAGL (degrades 2-AG)|synthesized on demand postsynaptically → act retrogradely on presynaptic CB1; widespread cortical, hippocampal, cerebellar, BG|CB1 (Gi, presynaptic inhibition of NT release, most abundant GPCR in brain), CB2 (immune cells, microglia)
NT11|substance P|neuropeptide (tachykinin)|preprotachykinin A gene → substance P|peptidase degradation|primary sensory C fibers (pain), dorsal horn, substantia nigra, brainstem|NK1 (neurokinin-1, Gq); pain transmission, neurogenic inflammation, emesis
NT12|orexin/hypocretin|neuropeptide|prepro-orexin → orexin-A (OxA) and orexin-B (OxB)|peptidase degradation|lateral hypothalamic area → widespread (LC, raphe, TMN, VTA, cortex)|OX1R (Gq, selective for OxA), OX2R (Gq, nonselective OxA/OxB); wakefulness stabilization; loss → narcolepsy type 1

# receptors(id|name|type|endogenous_ligand|mechanism|location|function)
RC1|AMPA receptor|ionotropic glutamate|glutamate|Na⁺/K⁺ channel (some Ca²⁺ permeable if lacking GluA2 subunit); fast EPSP|postsynaptic; ubiquitous in CNS|fast excitatory transmission; trafficking underlies LTP expression (insertion) and LTD (removal)
RC2|NMDA receptor|ionotropic glutamate|glutamate + glycine (co-agonist)|Ca²⁺/Na⁺/K⁺ channel; voltage-dependent Mg²⁺ block removed by depolarization; slow EPSP|postsynaptic; cortex, hippocampus, widespread|coincidence detector (requires presynaptic glutamate + postsynaptic depolarization); LTP induction; learning and memory; excitotoxicity if overactivated
RC3|GABA_A receptor|ionotropic|GABA|Cl⁻ channel (hyperpolarization = inhibition); pentameric (usually 2α, 2β, 1γ)|postsynaptic and extrasynaptic; ubiquitous|fast inhibition; benzodiazepine site (α/γ interface, ↑frequency of opening), barbiturate site (↑duration), ethanol site, neurosteroid site
RC4|GABA_B receptor|metabotropic|GABA|Gi-coupled; ↑K⁺ conductance (postsynaptic hyperpolarization), ↓Ca²⁺ conductance (presynaptic inhibition of NT release), ↓cAMP|pre and postsynaptic|slow inhibition; baclofen agonist (spasticity treatment); presynaptic autoinhibition
RC5|D1 receptor|metabotropic|dopamine|Gs-coupled; ↑cAMP → PKA activation|striatum (direct pathway MSNs), PFC, hippocampus|facilitates direct pathway (movement initiation); enhances working memory in PFC; reward learning
RC6|D2 receptor|metabotropic|dopamine|Gi-coupled; ↓cAMP; ↑K⁺ conductance|striatum (indirect pathway MSNs), VTA/SNc (autoreceptor), pituitary (lactotrophs)|indirect pathway inhibition (movement suppression); autoreceptor limits DA release; target of antipsychotics; inhibits prolactin
RC7|5-HT1A receptor|metabotropic|serotonin|Gi-coupled; ↓cAMP; ↑K⁺ conductance|raphe nuclei (somatodendritic autoreceptor), hippocampus, cortex|anxiolysis; mood regulation; autoreceptor limits 5-HT firing; buspirone partial agonist
RC8|5-HT2A receptor|metabotropic|serotonin|Gq-coupled; ↑IP3/DAG → PKC|cortex (layer V pyramidal neurons), claustrum, platelets|cortical excitation; psychedelic effects (LSD, psilocybin agonism); antipsychotic target (antagonism); platelet aggregation
RC9|μ-opioid receptor (MOR)|metabotropic|β-endorphin, enkephalins|Gi-coupled; ↓cAMP; ↑K⁺ conductance; ↓Ca²⁺ conductance|PAG, raphe, spinal dorsal horn, nucleus accumbens, thalamus|analgesia, euphoria, respiratory depression, dependence; target of morphine, fentanyl; naloxone antagonist
RC10|nicotinic ACh receptor (nAChR)|ionotropic|acetylcholine|Na⁺/K⁺ (some Ca²⁺) channel; pentameric|NMJ (α1₂β1δε); CNS (α4β2 most common; α7 hippocampus); autonomic ganglia (α3β4)|NMJ: muscle contraction; CNS: attention, reward (α4β2), synaptic plasticity (α7); ganglionic fast transmission
RC11|muscarinic M1 receptor|metabotropic|acetylcholine|Gq-coupled; ↑IP3/DAG|cortex, hippocampus, striatum|cognition, memory; excitatory postsynaptic effects; target for Alzheimer's therapeutics
RC12|CB1 receptor|metabotropic|anandamide, 2-AG|Gi-coupled; ↓cAMP; ↓presynaptic Ca²⁺ → ↓NT release|presynaptic terminals; cortex, hippocampus, cerebellum, BG; most abundant GPCR in brain|retrograde inhibition of both excitatory and inhibitory transmission (DSE, DSI); modulates synaptic plasticity; THC target
RC13|NMDA glycine site|co-agonist site on NMDA receptor|glycine (or D-serine from astrocytes)|required for NMDA channel opening along with glutamate binding and membrane depolarization|same as RC2|obligatory co-activation; D-serine release by astrocytes regulates NMDA function; therapeutic target for schizophrenia

# circuits(id|name|components|pathway|function|dysfunction)
CI1|basal ganglia direct pathway|cortex → striatum (D1 MSNs) → GPi/SNr (inhibited) → thalamus (VL/VA, disinhibited) → cortex|cortex excites D1 MSNs → D1 MSNs inhibit GPi → GPi releases tonic inhibition of thalamus → thalamus excites cortex|facilitates selected motor program; GO signal|hypokinesia when direct pathway weakened (Parkinson's)
CI2|basal ganglia indirect pathway|cortex → striatum (D2 MSNs) → GPe (inhibited) → STN (disinhibited) → GPi/SNr (excited) → thalamus (inhibited) → cortex|cortex excites D2 MSNs → D2 MSNs inhibit GPe → GPe releases tonic inhibition of STN → STN excites GPi → GPi inhibits thalamus|suppresses competing motor programs; NO-GO signal|hyperkinesia when indirect pathway weakened (Huntington's: loss of D2 MSNs in striatum)
CI3|basal ganglia hyperdirect pathway|cortex → STN (direct) → GPi/SNr → thalamus|cortex excites STN directly (bypassing striatum) → STN excites GPi → GPi inhibits thalamus|rapid global suppression of motor programs before direct pathway selects one; braking/stopping|impulsivity when hyperdirect weakened; target of DBS in Parkinson's (STN stimulation)
CI4|Papez circuit|hippocampus → fornix → mammillary bodies → mammillothalamic tract → anterior thalamus → cingulate cortex → cingulum → parahippocampal gyrus → entorhinal cortex → hippocampus|circular limbic loop|episodic memory, emotional processing, spatial memory|Korsakoff syndrome (mammillary body damage); temporal lobe amnesia (hippocampal damage)
CI5|mesolimbic reward circuit|VTA → nucleus accumbens (via medial forebrain bundle); modulated by PFC, amygdala, hippocampus input to NAc|VTA DA neurons fire to unexpected reward or reward-predicting cues → DA release in NAc → reinforcement signal|reward prediction, motivation, reinforcement learning, incentive salience|addiction (hijacked DA signaling); anhedonia (reduced DA); schizophrenia positive symptoms (excess mesolimbic DA)
CI6|HPA axis|hypothalamus (PVN: CRH) → anterior pituitary (ACTH) → adrenal cortex (cortisol) → negative feedback to hypothalamus and pituitary|CRH → ACTH → cortisol; cortisol feeds back to suppress CRH and ACTH|stress response; metabolic regulation; immune modulation; circadian cortisol rhythm|chronic stress → HPA dysregulation; Cushing syndrome (excess cortisol); Addison disease (cortisol deficiency); major depression (HPA hyperactivity)
CI7|vestibulo-ocular reflex (VOR)|semicircular canals → vestibular nerve (CN VIII) → vestibular nuclei → CN III/IV/VI nuclei (via MLF) → extraocular muscles|head rotation detected → equal and opposite eye rotation; 3-neuron arc|stabilizes gaze during head movement; latency ~15 ms|bilateral vestibular loss → oscillopsia; MLF lesion → internuclear ophthalmoplegia (INO)
CI8|pupillary light reflex|retina → optic nerve → pretectal nucleus (midbrain) → bilateral Edinger-Westphal nuclei → CN III parasympathetic → ciliary ganglion → pupillary sphincter|light in one eye → bilateral pupil constriction (direct + consensual)|pupil constriction to light; tests CN II (afferent) and CN III (efferent)|RAPD (relative afferent pupillary defect) → optic nerve lesion; CN III palsy → fixed dilated pupil
CI9|cortico-cerebellar loop|cortex → pontine nuclei → contralateral cerebellar cortex → deep cerebellar nuclei (dentate) → contralateral VL thalamus → motor cortex|double decussation: corticopontine (ipsilateral) → pontocerebellar (contralateral) → cerebellothalamic (contralateral) → net: cerebellum modulates ipsilateral body|motor planning, timing, error correction, motor learning; non-motor: cognitive and affective (posterior lobe)|cerebellar lesion → ipsilateral ataxia; cerebellar cognitive affective syndrome (Schmahmann syndrome)
CI10|default mode network (DMN)|medial PFC, PCC/precuneus, angular gyrus, medial temporal lobe (hippocampus), lateral temporal cortex|functionally connected regions active during rest, self-referential thought, mind-wandering; deactivated during externally focused tasks|self-referential processing, autobiographical memory, future planning, theory of mind, mind-wandering|disrupted in Alzheimer's (early amyloid deposition in DMN nodes); altered in depression, schizophrenia, ADHD
CI11|salience network|anterior insula, dorsal ACC; connected to amygdala, thalamus, brainstem autonomic centers|detects salient stimuli → switches between DMN and central executive network|identifies most important internal/external stimuli for processing; autonomic regulation; emotional awareness|disrupted in anxiety (hyperactive), schizophrenia, frontotemporal dementia
CI12|sleep-wake flip-flop|wake-promoting: LC (NE), raphe (5-HT), TMN (histamine), orexin (LHA), PPN (ACh); sleep-promoting: VLPO (GABA/galanin)|mutual inhibition between wake and sleep centers; orexin stabilizes wake state → prevents unwanted transitions|sharp transitions between wake and sleep; stability of each state|narcolepsy (orexin loss → unstable switching); insomnia (VLPO hypofunction); excessive daytime sleepiness

# cells(id|name|type|location|function|distinguishing_features)
CL1|pyramidal neuron|projection neuron (glutamatergic)|cortical layers III and V; hippocampus (CA1, CA3)|principal excitatory output neuron of cortex; corticospinal, corticostriatal, corticothalamic, commissural|triangular soma; single apical dendrite to layer I; basal dendrites; long axon; dendritic spines
CL2|medium spiny neuron (MSN)|projection neuron (GABAergic)|striatum (caudate, putamen, nucleus accumbens)|principal neuron of striatum (~95%); D1-MSN (direct pathway) or D2-MSN (indirect pathway)|medium soma; dense dendritic spines; low spontaneous firing; requires convergent cortical input to fire
CL3|Purkinje cell|projection neuron (GABAergic)|cerebellar cortex (Purkinje cell layer)|sole output of cerebellar cortex → deep cerebellar nuclei; inhibitory|largest neurons in brain; massive planar dendritic arbor; receives ~200,000 parallel fiber synapses + 1 climbing fiber
CL4|granule cell (cerebellar)|interneuron (glutamatergic)|cerebellar granular layer|most numerous neuron in brain (~50 billion); receives mossy fiber input → sends parallel fibers to molecular layer|smallest neurons in brain; 4–5 short dendrites; T-shaped axon (parallel fiber)
CL5|granule cell (hippocampal DG)|projection neuron (glutamatergic)|dentate gyrus granular layer|pattern separation; sparse coding; mossy fiber output to CA3|small soma; cone-shaped dendritic tree; mossy fiber axon with large boutons; adult neurogenesis site
CL6|interneuron (cortical basket cell)|local interneuron (GABAergic)|cortical layers II–VI|perisomatic inhibition of pyramidal neurons; controls output timing; fast-spiking|PV-positive (parvalbumin); fast-spiking; targets soma and proximal dendrites; generates gamma oscillations
CL7|interneuron (cortical chandelier cell)|local interneuron (GABAergic)|cortical layers II–III|axo-axonic inhibition of pyramidal neurons at axon initial segment; gates action potential generation|PV-positive; vertical cartridge-like axon terminals (candlesticks) on AIS
CL8|astrocyte|glial|throughout CNS gray and white matter|metabolic support (glucose → lactate shuttle); K⁺ buffering; glutamate recycling (glutamine synthetase); BBB maintenance; synaptic modulation (tripartite synapse)|star-shaped; GFAP+; end-feet on capillaries; gap junction networks; Ca²⁺ waves; each covers ~100,000 synapses
CL9|oligodendrocyte|glial|CNS white matter|myelination (each wraps ~30–60 axon segments); metabolic support to axons|multiple processes each forming myelin sheath segment; MBP, PLP expression; saltatory conduction
CL10|Schwann cell|glial|PNS|myelination (each wraps single axon internode in PNS); nerve regeneration support|basal lamina retained after injury → guides regeneration; Wallerian degeneration clearance
CL11|microglia|glial (immune)|throughout CNS|resident macrophages; synaptic pruning (complement-mediated); neuroinflammation; surveillance|mesodermal origin (yolk sac); ramified (surveillance) → amoeboid (activated); phagocytosis; cytokine release
CL12|ependymal cell|glial|lines ventricles and central canal|CSF circulation (ciliary movement); some are neural stem cells (subventricular zone)|ciliated; cuboidal/columnar; choroid plexus ependymal cells (modified) secrete CSF
CL13|dopaminergic neuron (SNc)|projection neuron (dopaminergic)|substantia nigra pars compacta|dopamine production and release to striatum; movement initiation|neuromelanin pigmented; autonomous pacemaker firing ~2–5 Hz; vulnerable to oxidative stress; loss → Parkinson's
CL14|noradrenergic neuron (LC)|projection neuron (noradrenergic)|locus coeruleus|NE release to cortex, hippocampus, cerebellum, brainstem, spinal cord; arousal, attention|small nucleus but widest projection of any single nucleus; tonic and phasic firing modes; phasic = novel/salient stimuli
CL15|serotonergic neuron (raphe)|projection neuron (serotonergic)|raphe nuclei (dorsal and median)|5-HT release to widespread targets; mood, sleep, appetite, pain modulation|slow regular firing (~1–5 Hz); inhibited during REM sleep; targeted by SSRIs
CL16|cholinergic neuron (basal forebrain)|projection neuron (cholinergic)|nucleus basalis of Meynert, medial septal nucleus, diagonal band|ACh to neocortex (attention, plasticity) and hippocampus (theta rhythm, memory)|vulnerable in Alzheimer's disease; septal → hippocampus drives theta oscillations

# concepts(id|name|definition|category)
CO1|long-term potentiation (LTP)|persistent strengthening of synapse based on recent activity; NMDA-dependent at Schaffer collateral–CA1 synapse; requires coincident pre and postsynaptic activity|plasticity
CO2|long-term depression (LTD)|persistent weakening of synapse; multiple mechanisms: cerebellar (climbing fiber–triggered, mGluR-dependent), hippocampal (low-frequency stimulation, NMDA-dependent AMPAR removal)|plasticity
CO3|spike-timing-dependent plasticity (STDP)|direction of plasticity determined by relative timing of pre and postsynaptic spikes; pre-before-post → LTP; post-before-pre → LTD; millisecond window|plasticity
CO4|Hebbian learning|neurons that fire together wire together; coincident activity strengthens connection; basis of associative learning; NMDA receptor implements molecular AND gate|plasticity
CO5|homeostatic plasticity (synaptic scaling)|global scaling of all synaptic strengths on a neuron to maintain stable firing rate; compensates for prolonged excitation or inhibition|plasticity
CO6|neurogenesis (adult)|new neuron production in adult brain; confirmed in subgranular zone (DG → granule cells) and subventricular zone (SVZ → olfactory bulb interneurons); human hippocampal neurogenesis debated but supported|plasticity
CO7|critical period|developmental window of heightened plasticity; experience shapes circuit architecture; ends with maturation of PV+ interneurons and perineuronal nets|plasticity
CO8|myelination|oligodendrocytes (CNS) or Schwann cells (PNS) wrap axons in lipid-rich membrane; increases conduction velocity 10–100×; saltatory conduction between nodes of Ranvier|conduction
CO9|saltatory conduction|action potential jumps between nodes of Ranvier; enables fast conduction (up to 120 m/s) in myelinated axons; Na⁺ channels concentrated at nodes|conduction
CO10|action potential|all-or-none depolarization; threshold ~−55 mV; Na⁺ influx (depolarization) → K⁺ efflux (repolarization) → refractory period; propagates unidirectionally|signaling
CO11|resting membrane potential|~−70 mV; maintained by Na⁺/K⁺ ATPase (3 Na⁺ out, 2 K⁺ in) and K⁺ leak channels; Nernst/Goldman equation|signaling
CO12|excitatory postsynaptic potential (EPSP)|graded depolarization; primarily glutamate → AMPA/NMDA; summates temporally and spatially to reach threshold|signaling
CO13|inhibitory postsynaptic potential (IPSP)|graded hyperpolarization or shunting; primarily GABA → GABA_A (Cl⁻) or GABA_B (K⁺)|signaling
CO14|neuromuscular junction (NMJ)|synapse between alpha motor neuron and skeletal muscle fiber; ACh release → nicotinic receptor → end-plate potential → muscle contraction; 1:1 reliability|signaling
CO15|blood-brain barrier (BBB)|tight junctions between brain capillary endothelial cells; astrocyte end-feet and pericytes maintain; restricts paracellular transport; lipophilic and small molecules pass; glucose via GLUT1|barrier
CO16|cerebrospinal fluid (CSF)|clear fluid; ~150 mL total; produced by choroid plexus (~500 mL/day); circulates ventricles → subarachnoid space → absorbed by arachnoid granulations into venous sinuses|barrier
CO17|tripartite synapse|synapse = presynaptic terminal + postsynaptic membrane + perisynaptic astrocyte process; astrocyte detects and modulates synaptic transmission via gliotransmitters (glutamate, D-serine, ATP)|concept
CO18|volume transmission|non-synaptic neurotransmitter release into extracellular space; diffuses to distant receptors; monoamines (DA, NE, 5-HT) act partly via volume transmission; slower, wider effect|signaling
CO19|oscillations (neural)|rhythmic fluctuations in neural activity; delta (0.5–4 Hz, deep sleep), theta (4–8 Hz, hippocampal memory), alpha (8–13 Hz, relaxed wakefulness), beta (13–30 Hz, motor, active thinking), gamma (30–100+ Hz, binding, attention)|signaling
CO20|place cells|hippocampal CA1 pyramidal neurons firing at specific spatial locations (place fields); discovered by O'Keefe 1971; basis of cognitive map|spatial
CO21|grid cells|entorhinal cortex layer II neurons firing in hexagonal spatial pattern; discovered by Moser and Moser 2005; provides metric for spatial navigation|spatial
CO22|sharp-wave ripples|hippocampal high-frequency oscillation (~150–250 Hz) during quiet wakefulness and NREM sleep; replays sequential place cell activity; critical for memory consolidation|spatial
CO23|reward prediction error|signal encoding difference between expected and received reward; phasic dopamine neuron firing: burst for positive RPE (better than expected), pause for negative RPE (worse than expected); Schultz 1997|learning
CO24|dopamine ramp|sustained dopamine increase as animal approaches reward; distinct from phasic RPE; encodes proximity to goal; nucleus accumbens and dorsal striatum|learning
CO25|Broca's area|left inferior frontal gyrus (areas 44, 45); speech production, syntactic processing, motor programming of speech; damage → non-fluent/expressive aphasia|language
CO26|Wernicke's area|left posterior superior temporal gyrus (area 22 posterior); speech comprehension, semantic processing; damage → fluent/receptive aphasia|language
CO27|lateralization|functional asymmetry between hemispheres; language: left dominant (~95% right-handers, ~70% left-handers); spatial attention: right dominant; handedness; emotional valence|concept
CO28|mirror neuron system|neurons firing both during action execution and action observation; originally in macaque F5 (ventral premotor); human homolog in inferior frontal and inferior parietal; debated role in imitation, empathy, language|concept
CO29|central pattern generator (CPG)|neural circuit producing rhythmic motor output without rhythmic sensory or central input; locomotion (spinal), respiration (pre-Bötzinger complex), chewing|circuit
CO30|gate control theory of pain|Melzack and Wall 1965; large-diameter Aβ fibers (touch) activate inhibitory interneurons in dorsal horn → close gate to pain transmission from small-diameter C and Aδ fibers; explains rubbing reducing pain|pain
CO31|descending pain modulation|PAG → rostral ventromedial medulla (RVM) → dorsal horn; serotonergic and noradrenergic; can facilitate or inhibit pain; endogenous opioid system; stress-induced analgesia|pain
CO32|wind-up|progressive increase in dorsal horn neuron firing to repeated C-fiber stimulation at same intensity; NMDA receptor-dependent; contributes to central sensitization and chronic pain|pain
CO33|neuroinflammation|activation of microglia and astrocytes; release of pro-inflammatory cytokines (TNF-α, IL-1β, IL-6); complement activation; implicated in neurodegeneration, chronic pain, psychiatric disorders|pathology
CO34|excitotoxicity|excessive glutamate → sustained NMDA/AMPA activation → Ca²⁺ overload → mitochondrial dysfunction → cell death; mechanism in stroke, TBI, neurodegenerative disease|pathology
CO35|Wallerian degeneration|distal axon segment degenerates after axon transection; Schwann cells/macrophages clear debris (PNS: efficient → regeneration possible; CNS: myelin debris persists → inhibits regeneration)|pathology
CO36|long-term memory consolidation|hippocampal-dependent encoding → systems consolidation (hippocampus replays to neocortex during sleep, especially SWS) → neocortex stores long-term; weeks to years|memory
CO37|working memory|temporary maintenance and manipulation of information; capacity ~4 items (Cowan); persistent firing in DLPFC and posterior parietal cortex; dopamine D1-dependent|memory
CO38|explicit (declarative) memory|conscious recall; episodic (events, hippocampus-dependent) + semantic (facts, neocortical); medial temporal lobe system: hippocampus + entorhinal + perirhinal + parahippocampal|memory
CO39|implicit (non-declarative) memory|unconscious; procedural (skills, striatum + cerebellum), priming (neocortex), classical conditioning (cerebellum for motor; amygdala for emotional), habituation/sensitization|memory
CO40|autonomic nervous system|sympathetic (T1–L2, fight-or-flight, NE at target except sweat glands ACh) + parasympathetic (CN III,VII,IX,X + S2–S4, rest-and-digest, ACh at target); dual innervation of most viscera; enteric NS (gut-brain)|system
CO41|sympathetic division|preganglionic: IML T1–L2 → short preganglionic (ACh) → paravertebral or prevertebral ganglia → long postganglionic (NE, except sweat glands ACh); adrenal medulla = modified ganglion (releases EPI into blood)|system
CO42|parasympathetic division|preganglionic: brainstem CN III,VII,IX,X + sacral S2–S4 → long preganglionic (ACh) → terminal ganglia near/in target organ → short postganglionic (ACh)|system

# functional_maps(id|name|cortical_area|brodmann|input|output|function|somatotopy)
FM1|primary motor cortex (M1)|precentral gyrus|4|premotor, supplementary motor, somatosensory, BG (via thalamus VL), cerebellum (via thalamus VL)|corticospinal tract, corticobulbar tract|voluntary movement execution; force and direction encoding|motor homunculus: medial → foot, leg; lateral → hand, face; hand area disproportionately large
FM2|premotor cortex|lateral area 6|6 (lateral)|prefrontal, parietal (area 5, 7), visual (via dorsal stream)|M1; corticospinal (some direct); reticulospinal|motor planning; visually guided movement; movement sequences|somatotopic but less discrete than M1
FM3|supplementary motor area (SMA)|medial area 6|6 (medial)|prefrontal, BG (via thalamus VA), contralateral SMA|M1; corticospinal (some direct)|internally generated movement sequences; bimanual coordination; motor intention (Bereitschaftspotential)|somatotopic; face, arm, leg from anterior to posterior
FM4|primary somatosensory cortex (S1)|postcentral gyrus|3a, 3b, 1, 2|VPL/VPM thalamus (DCML + spinothalamic); 3a receives proprioception, 3b receives cutaneous, 1 receives texture, 2 receives size/shape|secondary somatosensory (S2); posterior parietal (areas 5, 7); M1|conscious somatosensory perception; receptive field processing in columnar organization|sensory homunculus: medial → foot, leg; lateral → hand, face, tongue; hand and face disproportionately large
FM5|primary visual cortex (V1)|calcarine sulcus banks|17|LGN (optic radiation: upper visual field → lingual gyrus below calcarine; lower visual field → cuneus above calcarine)|V2, V3, V4, V5/MT; feedback to LGN|orientation selectivity (simple/complex cells), ocular dominance columns, color blobs, retinotopic map|retinotopic: fovea = large occipital pole representation; periphery = anterior calcarine
FM6|primary auditory cortex (A1)|transverse temporal gyrus (Heschl's gyrus)|41, 42|MGN (auditory radiation)|secondary auditory (belt/parabelt), Wernicke's area|frequency discrimination, sound localization onset, temporal pattern|tonotopic: low frequency = anterolateral; high frequency = posteromedial
FM7|primary gustatory cortex|anterior insula + frontal operculum|43|VPM thalamus (taste relay from NTS → parabrachial → VPM)|orbitofrontal (flavor integration), amygdala (hedonic value)|taste perception: sweet, sour, salty, bitter, umami|—
FM8|primary olfactory cortex|piriform cortex, amygdala (cortical nucleus), entorhinal cortex|—|olfactory bulb (mitral/tufted cell axons via lateral olfactory tract); only sensory modality bypassing thalamic relay to reach cortex|orbitofrontal, amygdala, hypothalamus, thalamus (MD)|odor identification, emotional association; direct amygdala access explains strong odor-emotion-memory links|—
FM9|dorsal visual stream|V1 → V2 → V3 → V5/MT → posterior parietal (areas 7a, MST, LIP)|—|V1; LGN magnocellular layers|premotor, frontal eye fields, superior colliculus|"where/how" pathway: spatial location, motion perception, visuomotor transformation, reaching, grasping|retinotopic in early stages; head-centered/body-centered in parietal
FM10|ventral visual stream|V1 → V2 → V4 → inferior temporal (TEO → TE)|—|V1; LGN parvocellular layers|prefrontal, hippocampus, amygdala|"what" pathway: object recognition, face recognition (fusiform face area), scene recognition (parahippocampal place area)|retinotopic in early stages; object-centered in IT

# cranial_nerves(id|number|name|type|nuclei|exit_foramen|innervation|function|clinical_test)
CN1|I|olfactory|sensory (special)|olfactory epithelium → olfactory bulb → olfactory tract|cribriform plate|olfactory epithelium (bipolar neurons)|smell|identify common odors (coffee, vanilla) each nostril separately
CN2|II|optic|sensory (special)|retinal ganglion cells → optic nerve → chiasm → tract → LGN|optic canal|retina|vision; pupillary light reflex (afferent limb)|visual acuity (Snellen chart); visual fields (confrontation); fundoscopy; RAPD (swinging flashlight)
CN3|III|oculomotor|motor + parasympathetic|oculomotor nucleus (midbrain) + Edinger-Westphal nucleus|superior orbital fissure|superior/inferior/medial rectus, inferior oblique, levator palpebrae; parasympathetic → ciliary ganglion → pupil constriction + lens accommodation|eye movement (up, down, medial, elevation of lid); pupil constriction; accommodation|eye movements (H-test); pupillary light reflex (efferent limb); ptosis check
CN4|IV|trochlear|motor|trochlear nucleus (midbrain, dorsal); only CN exiting dorsally; longest intracranial course; fully decussates|superior orbital fissure|superior oblique muscle|intorsion and depression (especially when eye adducted); looking down and in|look down and medially; head tilt test (Bielschowsky)
CN5|V|trigeminal|mixed (sensory + motor)|sensory: trigeminal ganglion → principal sensory nucleus (touch), spinal trigeminal nucleus (pain/temp), mesencephalic nucleus (proprioception); motor: motor nucleus of V|V1: superior orbital fissure; V2: foramen rotundum; V3: foramen ovale|sensory: face, scalp, cornea, nasal/oral mucosa, dura; motor: muscles of mastication (masseter, temporalis, medial/lateral pterygoids), mylohyoid, anterior belly of digastric, tensor tympani, tensor veli palatini|facial sensation; mastication; corneal reflex (afferent)|corneal reflex; facial sensation (all 3 divisions); jaw opening/clenching
CN6|VI|abducens|motor|abducens nucleus (pons, beneath fourth ventricle floor)|superior orbital fissure|lateral rectus muscle|eye abduction (lateral gaze)|lateral eye movement
CN7|VII|facial|mixed (motor + sensory + parasympathetic)|motor nucleus of VII (pons); superior salivatory nucleus (parasympathetic); nucleus of solitary tract (taste)|internal acoustic meatus → facial canal → stylomastoid foramen|motor: muscles of facial expression, stapedius, stylohyoid, posterior belly of digastric; sensory: taste anterior 2/3 tongue (via chorda tympani); parasympathetic: submandibular, sublingual, lacrimal glands|facial expression; taste (anterior 2/3); salivation; lacrimation; dampens loud sounds (stapedius)|facial movements (raise eyebrows, close eyes, smile, puff cheeks); taste anterior tongue; Schirmer test (lacrimation)
CN8|VIII|vestibulocochlear|sensory (special)|cochlear nuclei (auditory), vestibular nuclei (balance)|internal acoustic meatus|cochlea (hearing), semicircular canals + otolith organs (balance)|hearing, balance, VOR|Weber test (tuning fork on vertex); Rinne test (air vs bone conduction); Romberg test; caloric testing; Dix-Hallpike
CN9|IX|glossopharyngeal|mixed|nucleus ambiguus (motor); inferior salivatory nucleus (parasympathetic); nucleus of solitary tract (taste, baroreceptor); spinal trigeminal nucleus (sensation)|jugular foramen|motor: stylopharyngeus; sensory: posterior 1/3 tongue taste + sensation, pharynx, carotid body/sinus; parasympathetic: parotid gland (via otic ganglion)|taste posterior 1/3 tongue; pharyngeal sensation (gag reflex afferent); carotid baroreceptor/chemoreceptor; parotid secretion|gag reflex (afferent); taste posterior tongue
CN10|X|vagus|mixed (motor + sensory + parasympathetic)|nucleus ambiguus (motor); dorsal motor nucleus (parasympathetic); nucleus of solitary tract (visceral sensory); spinal trigeminal nucleus|jugular foramen|motor: pharynx, larynx (recurrent laryngeal nerve); parasympathetic: heart, lungs, GI to splenic flexure; sensory: larynx, viscera, external ear (Arnold's nerve)|phonation, swallowing, cough reflex, heart rate regulation, GI motility, bronchomotor|gag reflex (efferent); say "aah" (palate elevation, uvula midline); hoarseness assessment
CN11|XI|accessory (spinal)|motor|spinal accessory nucleus (C1–C5 ventral horn)|jugular foramen (enters via foramen magnum)|sternocleidomastoid (contralateral head turning), trapezius (shoulder shrug)|head rotation, shoulder elevation|shrug shoulders against resistance; turn head against resistance
CN12|XII|hypoglossal|motor|hypoglossal nucleus (medulla)|hypoglossal canal|intrinsic + extrinsic tongue muscles (except palatoglossus = CN X)|tongue movement (speech, swallowing, food manipulation)|protrude tongue (deviates toward lesion side in LMN); tongue strength/fasciculations

# vasculature(id|name|source|territory|clinical_significance)
V1|anterior cerebral artery (ACA)|internal carotid → ACA|medial frontal and parietal cortex; corpus callosum anterior 4/5; caudate head|ACA stroke → contralateral leg weakness/sensory loss; personality change (medial frontal); abulia
V2|middle cerebral artery (MCA)|internal carotid → MCA (largest branch)|lateral frontal, parietal, temporal cortex; insula; caudate, putamen, internal capsule (lenticulostriate perforating branches)|MCA stroke → contralateral face/arm > leg weakness; contralateral sensory loss; aphasia (L dominant); neglect (R); most common stroke territory
V3|posterior cerebral artery (PCA)|basilar artery → PCA|occipital cortex; medial and inferior temporal; thalamus (thalamoperforating, thalamogeniculate branches); midbrain|PCA stroke → contralateral homonymous hemianopia (macular sparing possible); thalamic stroke → sensory loss, pain; midbrain stroke
V4|basilar artery|vertebral arteries fuse at pontomedullary junction|pons (pontine perforators); supplies posterior circulation via superior cerebellar, AICA, PCA|basilar occlusion → locked-in syndrome (ventral pons); cerebellar infarct; devastating stroke
V5|vertebral arteries (pair)|subclavian arteries → vertebral arteries|medulla (PICA territory: lateral medulla, inferior cerebellum)|PICA stroke → lateral medullary syndrome (Wallenberg): ipsilateral face pain/temp loss, contralateral body pain/temp loss, vertigo, dysphagia, Horner syndrome
V6|circle of Willis|ACA + AComm + ICA + PComm + PCA; anastomotic ring at base of brain|provides collateral between anterior and posterior circulation; highly variable anatomy (~50% classic complete ring)|collateral protection if one feeding artery occluded; aneurysm sites (AComm most common, then PComm, then MCA bifurcation)
V7|lenticulostriate arteries|MCA proximal branches|caudate, putamen, globus pallidus, anterior limb of internal capsule|most common site of hypertensive intracerebral hemorrhage (basal ganglia hemorrhage); lacunar infarcts

# barriers(id|name|location|structure|function|clinical_significance)
BR1|blood-brain barrier (BBB)|brain capillaries|endothelial tight junctions + basement membrane + pericytes + astrocyte end-feet|restricts entry of hydrophilic molecules, pathogens, immune cells; permits O₂, CO₂, lipophilic molecules, glucose (GLUT1), amino acids (specific transporters)|disrupted in stroke, MS, meningitis, brain tumors (allows contrast enhancement on MRI); drug delivery challenge
BR2|blood-CSF barrier|choroid plexus|choroid plexus epithelial tight junctions (fenestrated capillaries underneath)|produces CSF; selectively transports ions, nutrients into CSF; barrier to blood-borne substances|choroid plexus tumors; infections can enter via this route
BR3|circumventricular organs (CVOs)|midline structures around third and fourth ventricles: area postrema, median eminence, subfornical organ, organum vasculosum lamina terminalis (OVLT), others|fenestrated capillaries; no BBB|allow brain to sense blood-borne signals (hormones, osmolality, toxins) and respond; area postrema = chemoreceptor trigger zone (vomiting); OVLT = osmosensing; median eminence = hypothalamic hormone release to pituitary portal|area postrema: emetic drugs act here; OVLT: thirst regulation; median eminence: neuroendocrine interface

# clinical(id|condition|affected_structure|mechanism|presentation)
CX1|Parkinson's disease|R18 (SNc), TR22|loss of dopaminergic neurons in SNc → dopamine depletion in striatum → overactive indirect pathway, underactive direct pathway|resting tremor (pill-rolling), rigidity (cogwheel), bradykinesia, postural instability; non-motor: anosmia, depression, REM sleep behavior disorder, constipation
CX2|Huntington's disease|R11 (striatum, especially caudate)|CAG repeat expansion in huntingtin gene → selective loss of D2-MSNs (indirect pathway) → underactive indirect pathway|chorea (involuntary dance-like movements), cognitive decline, psychiatric symptoms (depression, irritability); autosomal dominant; onset ~30–50 years
CX3|Alzheimer's disease|R8 (hippocampus), N27, CL16, CO33|amyloid-β plaques (extracellular) + tau neurofibrillary tangles (intracellular) → synaptic loss → neuronal death; earliest in entorhinal cortex and hippocampus; cholinergic basal forebrain degeneration|progressive memory loss (episodic first), language decline, visuospatial impairment, executive dysfunction; hippocampal atrophy on MRI; amyloid PET+
CX4|stroke (ischemic)|V1-V7 territories|arterial occlusion (thrombotic or embolic) → ischemia → excitotoxicity (CO34) → neuronal death; penumbra = salvageable tissue around infarct core|sudden onset focal neurological deficit matching vascular territory; MCA most common → contralateral hemiparesis (face/arm > leg), sensory loss, aphasia or neglect
CX5|multiple sclerosis|CO8, CL9|autoimmune demyelination of CNS; perivenular inflammation → demyelination → axonal damage; relapsing-remitting or progressive|optic neuritis, internuclear ophthalmoplegia (MLF lesion), sensory symptoms, weakness, fatigue, Lhermitte sign, Uhthoff phenomenon; white matter lesions on MRI (Dawson fingers)
CX6|epilepsy|R1-R4 (cortex), R8 (temporal lobe)|abnormal excessive synchronous neuronal firing; focal (localized onset) or generalized (bilateral from start); ion channel mutations, structural lesions, or idiopathic|seizures: focal (aura, automatisms, Todd's paralysis) or generalized (tonic-clonic, absence); temporal lobe epilepsy most common focal: déjà vu, epigastric rising, automatisms
CX7|narcolepsy type 1|N15, CI12, NT12|loss of orexin/hypocretin neurons in LHA (autoimmune); destabilizes wake-sleep flip-flop switch|excessive daytime sleepiness, cataplexy (sudden bilateral muscle atonia triggered by emotion), sleep paralysis, hypnagogic hallucinations, fragmented nocturnal sleep; low CSF orexin
CX8|Wernicke aphasia|CO26, R3|lesion of posterior superior temporal gyrus (Wernicke's area, area 22); usually L MCA stroke|fluent but meaningless speech (word salad, neologisms, paraphasias); impaired comprehension; impaired repetition; unaware of deficit (anosognosia)
CX9|Broca aphasia|CO25, R1|lesion of left inferior frontal gyrus (areas 44, 45); usually L MCA stroke (superior division)|non-fluent effortful speech; telegraphic output; relatively preserved comprehension; impaired repetition; aware of deficit → frustrated
CX10|amyotrophic lateral sclerosis (ALS)|R32 (ventral horn), CL1 (layer V), TR1|degeneration of both upper motor neurons (cortex) and lower motor neurons (brainstem/spinal cord)|combined UMN signs (spasticity, hyperreflexia, Babinski) + LMN signs (weakness, atrophy, fasciculations); progressive; respiratory failure; cognition often spared initially; frontotemporal overlap in ~15%
CX11|Wallenberg syndrome (lateral medullary)|R28, V5|PICA or vertebral artery occlusion → lateral medullary infarct|ipsilateral: facial pain/temp loss (spinal trigeminal), Horner syndrome, ataxia (inferior cerebellar peduncle), dysphagia/hoarseness (nucleus ambiguus); contralateral: body pain/temp loss (spinothalamic decussation)
CX12|Brown-Séquard syndrome|DV6, R31, R32, TR1, TR7, TR8|hemisection of spinal cord|ipsilateral: motor loss below lesion (CST), fine touch/proprioception loss below (DCML); contralateral: pain/temp loss 1–2 segments below (spinothalamic crosses in cord)

# relationships(from|rel|to)
# division hierarchy
DV1|part_of|DV1
DV2|part_of|DV2
DV3|follows|DV2
DV4|follows|DV3
DV5|follows|DV4
DV6|follows|DV5
# region → division
R1|part_of|DV1
R2|part_of|DV1
R3|part_of|DV1
R4|part_of|DV1
R5|part_of|DV1
R6|part_of|DV1
R7|part_of|DV1
R8|part_of|DV1
R9|part_of|DV1
R10|part_of|DV1
R11|part_of|DV1
R12|part_of|DV1
R13|part_of|DV2
R14|part_of|DV2
R15|part_of|DV2
R16|part_of|DV3
R17|part_of|DV3
R18|part_of|DV3
R19|part_of|DV3
R20|part_of|DV3
R21|part_of|DV3
R22|part_of|DV4
R23|part_of|DV4
R24|part_of|DV4
R24|part_of|DV5
R25|part_of|DV4
R26|part_of|DV4
R27|part_of|DV4
R28|part_of|DV5
R29|part_of|DV5
R30|part_of|DV3
R30|part_of|DV4
R30|part_of|DV5
R31|part_of|DV6
R32|part_of|DV6
R33|part_of|DV6
R34|part_of|DV5
# nuclei → region
N1|part_of|R13
N2|part_of|R13
N3|part_of|R13
N4|part_of|R13
N5|part_of|R13
N6|part_of|R13
N7|part_of|R13
N8|part_of|R13
N9|part_of|R13
N10|part_of|R13
N11|part_of|R13
N12|part_of|R14
N13|part_of|R14
N14|part_of|R14
N15|part_of|R14
N16|part_of|R14
N17|part_of|R14
N18|part_of|R9
N19|part_of|R9
N20|part_of|R8
N21|part_of|R8
N22|part_of|R8
N23|part_of|R26
N24|part_of|R26
N25|part_of|R28
N26|part_of|DV5
N27|part_of|DV1
N28|part_of|DV3
N29|part_of|R14
# functional maps → region
FM1|part_of|R1
FM2|part_of|R1
FM3|part_of|R1
FM4|part_of|R2
FM5|part_of|R4
FM6|part_of|R3
FM7|part_of|R5
FM8|part_of|R3
FM9|part_of|R4
FM9|extends|R2
FM10|part_of|R4
FM10|extends|R3
# sensory relay chains
TR7|precedes|N1
N1|precedes|FM4
TR8|precedes|N1
TR11|precedes|N3
N3|precedes|FM5
TR12|precedes|N4
N4|precedes|FM6
N2|precedes|FM4
# motor output chain
FM1|enables|TR1
FM1|enables|TR2
R10|enables|FM1
N5|enables|FM1
N6|enables|FM2
R26|enables|N5
R12|enables|N6
# basal ganglia circuit
R11|requires|NT3
R11|requires|NT1
CI1|enables|FM1
CI2|prevents|FM1
CI3|precedes|CI1
R18|enables|R11
R19|enables|R11
TR22|enables|CI1
TR22|enables|CI2
N5|part_of|CI1
N6|part_of|CI2
# cerebellar circuit
CI9|enables|FM1
R22|enables|R27
N25|enables|R27
N23|enables|N5
N24|enables|N26
R27|enables|N23
R27|enables|N24
CL3|enables|N23
CL4|enables|CL3
# hippocampal circuit
N20|precedes|N21
N21|precedes|N22
N22|enables|TR14
TR14|precedes|TR15
TR15|precedes|N7
N7|precedes|R6
CI4|enables|CO36
CI4|enables|CO38
CO22|enables|CO36
# limbic / emotion
N18|enables|N19
N19|enables|R14
N19|enables|R20
TR16|enables|R14
R9|enables|CI5
R9|enables|CI6
# reward circuit
CI5|requires|NT3
CI5|requires|R19
TR23|enables|CI5
CO23|determined_by|NT3
CO24|determined_by|NT3
# sleep-wake
CI12|requires|NT12
CI12|requires|NT7
CI12|requires|NT4
CI12|requires|NT5
CI12|requires|NT6
N15|enables|CI12
N17|enables|CI12
N29|enables|CI12
R23|enables|CI12
R24|enables|CI12
# language circuit
CO25|enables|TR18
TR18|enables|CO26
CO25|part_of|R1
CO26|part_of|R3
FM6|enables|CO26
CO27|enables|CO25
CO27|enables|CO26
# pain pathways
CO30|part_of|R31
TR8|enables|CO30
CO31|requires|R20
CO31|requires|R24
CO31|enables|CO30
NT9|enables|CO31
CO32|requires|RC2
# neurotransmitter → receptor binding
NT1|enables|RC1
NT1|enables|RC2
NT2|enables|RC3
NT2|enables|RC4
NT3|enables|RC5
NT3|enables|RC6
NT4|enables|RC7
NT5|enables|RC7
NT5|enables|RC8
NT6|enables|RC10
NT6|enables|RC11
NT9|enables|RC9
NT10|enables|RC12
NT8|enables|RC13
# plasticity mechanisms
RC2|enables|CO1
RC2|enables|CO2
CO1|requires|RC1
CO3|specializes|CO4
CO4|requires|RC2
CO5|prevents|CO34
CO7|determined_by|CL6
# cell → function
CL1|enables|TR1
CL2|enables|CI1
CL2|enables|CI2
CL3|enables|R26
CL6|enables|CO19
CL8|enables|CO15
CL8|enables|CO17
CL9|enables|CO8
CL10|enables|CO8
CL11|enables|CO33
CL13|enables|TR22
CL14|enables|R23
CL15|enables|R24
CL16|enables|N27
# signaling chain
CO11|enables|CO10
CO10|enables|CO12
CO10|enables|CO13
CO12|enables|CO10
CO8|enables|CO9
CO14|requires|NT6
CO14|requires|RC10
# vascular territories
V6|contains|V1
V6|contains|V2
V6|contains|V3
V2|enables|R1
V2|enables|R2
V2|enables|R3
V2|enables|R10
V1|enables|R1
V1|enables|R6
V3|enables|R4
V3|enables|R13
V4|enables|R22
V4|enables|R28
V5|enables|R28
V5|enables|R26
V7|enables|R10
V7|enables|R11
# barrier relationships
BR1|prevents|CO33
BR3|enables|R14
BR2|enables|CO16
CO15|equivalent_to|BR1
# clinical → structural
CX1|determined_by|CL13
CX2|determined_by|CL2
CX3|determined_by|N20
CX3|determined_by|N27
CX4|determined_by|V2
CX5|determined_by|CL9
CX6|determined_by|CL1
CX7|determined_by|N15
CX8|determined_by|CO26
CX9|determined_by|CO25
CX10|determined_by|CL1
CX10|determined_by|R32
CX11|determined_by|V5
CX12|determined_by|DV6
# autonomic
CO40|contains|CO41
CO40|contains|CO42
CO41|part_of|R33
CO42|requires|CN10
R14|enables|CO40
R29|enables|CO40

# section_index(section|title|ids)
1|Developmental Divisions|DV1-DV6
2|Brain Regions|R1-R34
3|Thalamic and Subcortical Nuclei|N1-N29
4|Major Tracts|TR1-TR25
5|Neurotransmitters|NT1-NT12
6|Receptors|RC1-RC13
7|Functional Circuits|CI1-CI12
8|Cell Types|CL1-CL16
9|Core Concepts|CO1-CO42
10|Functional Cortical Maps|FM1-FM10
11|Cranial Nerves|CN1-CN12
12|Cerebral Vasculature|V1-V7
13|CNS Barriers|BR1-BR3
14|Clinical Conditions|CX1-CX12
15|Relationships|all

# decode_legend
id_prefixes: DV=division, R=region, N=nucleus, TR=tract, NT=neurotransmitter, RC=receptor, CI=circuit, CL=cell, CO=concept, FM=functional_map, CN=cranial_nerve, V=vasculature, BR=barrier, CX=clinical
rel_types: enables|requires|prevents|specializes|generalizes|part_of|contains|follows|precedes|instance_of|determined_by|equivalent_to|extends|derived_from|composed_of
notation: → denotes projection direction in pathway descriptions; _fk=foreign key; ~=approximate; L/R=left/right; CN=cranial nerve; BG=basal ganglia; LMN/UMN=lower/upper motor neuron; MSN=medium spiny neuron; PFC=prefrontal cortex; DLPFC=dorsolateral PFC; ACC=anterior cingulate cortex; PCC=posterior cingulate cortex; VTA=ventral tegmental area; SNc/SNr=substantia nigra pars compacta/reticulata; GPi/GPe=globus pallidus internal/external; STN=subthalamic nucleus; LGN/MGN=lateral/medial geniculate nucleus; VPL/VPM=ventral posterolateral/posteromedial; NTS=nucleus tractus solitarius; PAG=periaqueductal gray; RVM=rostral ventromedial medulla; ARAS=ascending reticular activating system; MLF=medial longitudinal fasciculus; DCML=dorsal column-medial lemniscus; CST=corticospinal tract; BBB=blood-brain barrier; CSF=cerebrospinal fluid; IML=intermediolateral cell column; SCN=suprachiasmatic nucleus; PVN=paraventricular nucleus; LHA=lateral hypothalamic area; VMH=ventromedial hypothalamus; VLPO=ventrolateral preoptic area; NMJ=neuromuscular junction; LTP/LTD=long-term potentiation/depression; STDP=spike-timing-dependent plasticity; EPSP/IPSP=excitatory/inhibitory postsynaptic potential; DAT/NET/SERT=dopamine/norepinephrine/serotonin transporter; MAO/COMT=monoamine oxidase/catechol-O-methyltransferase; GABA=γ-aminobutyric acid; ACh=acetylcholine; NE=norepinephrine; DA=dopamine; 5-HT=serotonin; AMPA=α-amino-3-hydroxy-5-methyl-4-isoxazolepropionic acid; NMDA=N-methyl-D-aspartate; mGluR=metabotropic glutamate receptor; GPCR=G-protein coupled receptor; Gs/Gi/Gq=stimulatory/inhibitory/phospholipase-C-coupled G-protein; cAMP=cyclic adenosine monophosphate; IP3/DAG=inositol trisphosphate/diacylglycerol; PKA/PKC=protein kinase A/C; HPA=hypothalamic-pituitary-adrenal; CRH=corticotropin-releasing hormone; ACTH=adrenocorticotropic hormone; ADH=antidiuretic hormone; GnRH=gonadotropin-releasing hormone; FSH/LH=follicle-stimulating/luteinizing hormone; TSH=thyroid-stimulating hormone; MCA/ACA/PCA=middle/anterior/posterior cerebral artery; PICA=posterior inferior cerebellar artery; ICA=internal carotid artery; AComm/PComm=anterior/posterior communicating artery; MRI=magnetic resonance imaging; CT=computed tomography; DBS=deep brain stimulation; MS=multiple sclerosis; RAPD=relative afferent pupillary defect; VOR=vestibulo-ocular reflex; SWS=slow-wave sleep; NREM=non-rapid eye movement; REM=rapid eye movement; PV=parvalbumin; GFAP=glial fibrillary acidic protein; MBP=myelin basic protein; Hz=hertz; mV=millivolts; m/s=meters per second
confidence: all facts at reference_neuroscience confidence level; clinical presentations are typical/classic; individual variation exists
scope: functional neuroanatomy of adult human nervous system; covers structure-function relationships, major circuits, neurotransmitter systems, and key clinical correlates; excludes detailed developmental neuroscience, computational neuroscience formalisms, and invertebrate systems
