# HUMAN HOMEOSTASIS: REGULATORY SYSTEMS AND FEEDBACK MECHANISMS — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: domains → regulated_variables → sensors → control_centers → effectors → feedback_loops → hormones → enzymes → transport_proteins → fluid_compartments → electrolytes → acid_base → thermoregulation → glucose_regulation → blood_pressure → oxygen_co2 → water_balance → calcium_phosphate → iron → energy_balance → immune_homeostasis → circadian → stress_response → failure_modes → concepts → relationships → section_index → decode_legend

# domains(id|name|definition)
DM1|thermoregulation|maintenance of core body temperature at ~37°C (36.5–37.5°C) despite environmental variation; balance of heat production and heat loss
DM2|glucose regulation|maintenance of blood glucose at 3.9–5.6 mmol/L (70–100 mg/dL) fasting; balance of glucose entry into blood (diet, glycogenolysis, gluconeogenesis) and glucose exit (cellular uptake, glycogenesis, lipogenesis)
DM3|cardiovascular regulation|maintenance of adequate blood pressure (~120/80 mmHg) and tissue perfusion; balance of cardiac output and peripheral resistance; acute (neural) and chronic (renal-hormonal) mechanisms
DM4|respiratory regulation|maintenance of arterial PO₂ (~100 mmHg), PCO₂ (~40 mmHg), and pH (7.35–7.45); balance of ventilation rate and metabolic CO₂/O₂ demands
DM5|fluid and electrolyte balance|maintenance of total body water (~60% body mass), osmolarity (~280–295 mOsm/L), and electrolyte concentrations within narrow ranges; balance of intake, production, and excretion
DM6|acid-base balance|maintenance of arterial pH at 7.35–7.45; buffering, respiratory compensation (CO₂), and renal compensation (H⁺/HCO₃⁻ excretion/reabsorption)
DM7|calcium and phosphate regulation|maintenance of serum Ca²⁺ at 2.2–2.6 mmol/L (8.8–10.4 mg/dL) and phosphate at 0.8–1.5 mmol/L; balance of bone deposition/resorption, intestinal absorption, and renal excretion
DM8|iron homeostasis|maintenance of body iron stores (~3–4 g total); balance of dietary absorption, recycling from senescent RBCs, storage (ferritin), and loss (minimal: desquamation, menstruation, bleeding)
DM9|energy balance|maintenance of body weight and composition; balance of caloric intake and energy expenditure (BMR + activity + thermogenesis); regulated by hypothalamic circuits integrating hormonal and neural signals
DM10|immune homeostasis|maintenance of immune surveillance without autoimmunity or excessive inflammation; balance of activation and suppression; tolerance to self-antigens; resolution of inflammatory responses
DM11|circadian regulation|maintenance of ~24-hour biological rhythms; entrained by light-dark cycle; coordinates sleep-wake, hormone secretion, metabolism, body temperature, and immune function
DM12|stress response|acute mobilization of resources for survival (fight-or-flight); return to baseline after threat resolves; chronic activation causes pathology; HPA axis and sympathoadrenal system
DM13|reproductive hormone regulation|maintenance of sex hormone levels via hypothalamic-pituitary-gonadal axis; pulsatile GnRH → FSH/LH → gonadal steroids; negative and positive feedback (LH surge)
DM14|clotting and anticlotting balance|maintenance of blood fluidity while retaining capacity for rapid hemostasis; balance of procoagulant, anticoagulant, and fibrinolytic systems

# regulated_variables(id|name|normal_range|unit|compartment|sensing_method|primary_control_center|consequences_if_low|consequences_if_high)
RV1|core body temperature|36.5–37.5|°C|core (rectal, esophageal, tympanic)|thermoreceptors (peripheral: skin; central: hypothalamus, spinal cord, abdominal viscera)|hypothalamus (preoptic area / anterior hypothalamus, POAH)|hypothermia → bradycardia, confusion, arrhythmia, cardiac arrest|hyperthermia → protein denaturation, organ failure, heat stroke, death above ~41.5°C sustained
RV2|blood glucose|3.9–5.6 (fasting); <7.8 (2h postprandial)|mmol/L|plasma|pancreatic beta cells (glucose transporter GLUT2 + glucokinase); hypothalamic glucose-sensing neurons|pancreatic islets; hypothalamus|hypoglycemia → neuroglycopenia (confusion, seizure, coma, death); sympathoadrenal response (tremor, sweating, tachycardia)|hyperglycemia → osmotic diuresis, dehydration, glycation of proteins (long-term: retinopathy, nephropathy, neuropathy), DKA (type 1), HHS (type 2)
RV3|mean arterial pressure (MAP)|70–105|mmHg|arterial blood|baroreceptors (carotid sinus CN IX, aortic arch CN X); juxtaglomerular cells (kidney: renin release); atrial stretch receptors|medullary cardiovascular center (RVLM, CVLM, nucleus ambiguus); kidney (RAAS)|hypotension → inadequate perfusion → syncope, organ ischemia, shock, death|hypertension → vascular damage, LVH, stroke, MI, renal failure, retinopathy
RV4|arterial PO₂|75–100|mmHg|arterial blood|peripheral chemoreceptors (carotid body: CN IX; aortic body: CN X); detect PO₂ <60 mmHg primarily|medullary respiratory center (dorsal respiratory group, ventral respiratory group, pre-Bötzinger complex)|hypoxemia → anaerobic metabolism, lactic acidosis, confusion, cyanosis, cardiac arrest|hyperoxemia → oxygen toxicity (rare at physiological levels; relevant in supplemental O₂: retinopathy of prematurity, pulmonary toxicity)
RV5|arterial PCO₂|35–45|mmHg|arterial blood|central chemoreceptors (medulla: detect H⁺ in CSF from CO₂ diffusion; most sensitive); peripheral chemoreceptors (carotid/aortic bodies)|medullary respiratory center|hypocapnia → respiratory alkalosis, cerebral vasoconstriction, lightheadedness, tetany (low ionized Ca²⁺)|hypercapnia → respiratory acidosis, CO₂ narcosis, confusion, coma; vasodilation; elevated intracranial pressure
RV6|arterial pH|7.35–7.45|pH units|arterial blood|central and peripheral chemoreceptors (indirectly via CO₂/H⁺); renal tubular cells sense pH|respiratory center (rapid: minutes); kidney (slow: hours to days)|acidemia (<7.35) → enzyme dysfunction, cardiac depression, confusion, coma, death below ~6.8|alkalemia (>7.45) → neuromuscular irritability, tetany, arrhythmia, seizure, death above ~7.8
RV7|plasma osmolarity|280–295|mOsm/L|plasma|hypothalamic osmoreceptors (OVLT, subfornical organ — circumventricular organs outside BBB)|hypothalamus (supraoptic nucleus, paraventricular nucleus → ADH release); thirst center|hypo-osmolarity → cellular swelling, cerebral edema, confusion, seizure (hyponatremia)|hyperosmolarity → cellular shrinkage, neuronal dysfunction, confusion, coma (hypernatremia, DKA)
RV8|plasma Na⁺|136–145|mmol/L|plasma|osmoreceptors (indirectly); macula densa (kidney: Na⁺ delivery); juxtaglomerular cells; atrial stretch receptors (ANP)|RAAS; ADH; ANP; hypothalamus|hyponatremia → cerebral edema, confusion, seizure, coma, death (if acute and severe)|hypernatremia → neuronal shrinkage, confusion, seizure, intracerebral hemorrhage
RV9|plasma K⁺|3.5–5.0|mmol/L|plasma|adrenal cortex (aldosterone release); cardiac cells (resting membrane potential); renal tubular K⁺ sensors|adrenal cortex (aldosterone); kidney (principal cells of collecting duct)|hypokalemia → muscle weakness, arrhythmia (U wave, flattened T), paralytic ileus, cardiac arrest|hyperkalemia → arrhythmia (peaked T, widened QRS, sine wave), cardiac arrest; most dangerous electrolyte abnormality
RV10|serum Ca²⁺ (ionized)|1.1–1.3 (ionized); 2.2–2.6 (total)|mmol/L|plasma|parathyroid chief cells (calcium-sensing receptor, CaSR: G-protein coupled; decreased Ca²⁺ → increased PTH)|parathyroid glands (PTH); thyroid C-cells (calcitonin); kidney (calcitriol)|hypocalcemia → neuromuscular irritability, tetany (Chvostek sign, Trousseau sign), seizure, QT prolongation, cardiac arrest|hypercalcemia → muscle weakness, polyuria, kidney stones, constipation, confusion, shortened QT, cardiac arrest; bones, stones, groans, moans
RV11|serum phosphate|0.8–1.5|mmol/L|plasma|parathyroid (inversely; high PO₄ stimulates PTH via FGF23 pathway); kidney (FGF23 from osteocytes)|parathyroid (PTH); bone (FGF23); kidney (reabsorption/excretion)|hypophosphatemia → muscle weakness, respiratory failure, hemolytic anemia, impaired ATP synthesis|hyperphosphatemia → metastatic calcification (Ca×PO₄ product >4.4), renal osteodystrophy, vascular calcification
RV12|hemoglobin / oxygen carrying capacity|male: 130–175 g/L; female: 120–160 g/L|g/L|blood|kidney peritubular interstitial cells (detect tissue PO₂); liver (minor EPO source)|kidney (erythropoietin, EPO)|anemia → fatigue, tachycardia, dyspnea, tissue hypoxia|polycythemia → hyperviscosity, thrombosis, stroke
RV13|body weight / adiposity|variable (BMI 18.5–24.9 considered normal range)|kg (mass) or % body fat|whole body|hypothalamic arcuate nucleus: integrates leptin (from adipose: long-term energy stores), ghrelin (from stomach: short-term hunger), insulin (from pancreas: fed state), PYY, CCK, GLP-1|hypothalamus (arcuate → PVN → satiety/hunger circuits)|underweight → muscle wasting, immune suppression, hormonal disruption (amenorrhea), osteoporosis, death|obesity → insulin resistance, type 2 diabetes, cardiovascular disease, cancer risk, joint degeneration, sleep apnea
RV14|plasma iron / transferrin saturation|serum iron: 10–30 μmol/L; transferrin saturation: 20–50%|μmol/L or %|plasma|hepatocytes (sense iron-loaded transferrin and BMP6 → regulate hepcidin); enterocytes (DMT1, ferroportin regulated by hepcidin)|liver (hepcidin production)|iron deficiency → microcytic hypochromic anemia, fatigue, pica, koilonychia, impaired immunity|iron overload → hemochromatosis: liver cirrhosis, cardiomyopathy, diabetes, arthritis, skin bronzing (iron catalyzes free radical damage)

# sensors(id|name|location|stimulus|mechanism|afferent_pathway|sensitivity)
SN1|peripheral thermoreceptors|skin (cold: more numerous than warm; Krause end bulbs and free nerve endings)|skin temperature change|cold receptors: fire maximally ~25°C; warm receptors: fire maximally ~45°C; encode rate of change and absolute temperature|A-delta (cold) and C fibers (warm) → dorsal horn → spinothalamic tract → hypothalamus (POAH)|detect ~0.01°C change in skin temperature; cold receptors 10× more numerous than warm
SN2|central thermoreceptors|hypothalamus (POAH); spinal cord; abdominal viscera|core temperature change (blood temperature bathing hypothalamus)|warm-sensitive neurons in POAH increase firing rate with rising temperature; integrate with peripheral input|local (hypothalamic neurons directly sense blood temperature)|POAH warm-sensitive neurons: ~0.1°C resolution; dominant driver of thermoregulatory responses
SN3|carotid sinus baroreceptors|carotid sinus (bifurcation of common carotid)|arterial blood pressure (stretch of vessel wall)|stretch-activated mechanoreceptors; increased stretch → increased firing rate; decreased stretch → decreased firing rate; encode both mean pressure and pulse pressure|glossopharyngeal nerve (CN IX) → nucleus tractus solitarius (NTS) → cardiovascular center|sensitive to pressures ~60–180 mmHg; reset with sustained pressure changes (chronic hypertension → new set point)
SN4|aortic arch baroreceptors|aortic arch|arterial blood pressure|same mechanism as carotid sinus baroreceptors|vagus nerve (CN X) → NTS → cardiovascular center|similar range; less sensitive to pulse pressure than carotid; more sensitive to mean pressure
SN5|peripheral chemoreceptors (carotid body)|carotid body (at carotid bifurcation)|primarily PO₂; also PCO₂ and pH|glomus cells (type I): K⁺ channels close in hypoxia → depolarization → Ca²⁺ entry → neurotransmitter release → afferent nerve firing|CN IX → NTS → respiratory center|primary O₂ sensor; activated when PaO₂ <60 mmHg (steep response curve); also responds to PCO₂/pH but less than central chemoreceptors
SN6|central chemoreceptors|ventral medulla (retrotrapezoid nucleus, raphe)|H⁺ concentration in CSF (reflects arterial PCO₂; CO₂ crosses BBB freely → carbonic anhydrase → H⁺ + HCO₃⁻)|chemosensitive neurons increase firing rate with rising H⁺ (falling pH); H⁺ in CSF is proximate stimulus, CO₂ is distal|local projection to respiratory center (DRG, VRG, pre-Bötzinger complex)|most sensitive CO₂/pH sensor (~70% of ventilatory response to CO₂); responds to ΔpCO₂ of ~1–2 mmHg
SN7|hypothalamic osmoreceptors|OVLT and subfornical organ (circumventricular organs — lack BBB)|plasma osmolarity change|osmoreceptor cells shrink in hyperosmolarity → mechanosensitive channels open → depolarization → signal to SON/PVN (ADH release) and thirst center; swell in hypo-osmolarity → decreased firing|local projection to supraoptic (SON) and paraventricular (PVN) nuclei and lateral hypothalamus (thirst)|detect 1–2% change in osmolarity (~2–5 mOsm/L); ADH release threshold ~280 mOsm/L; thirst threshold ~290 mOsm/L (thirst lags behind ADH)
SN8|juxtaglomerular (JG) cells|afferent arteriole wall of renal glomerulus|reduced renal perfusion pressure; reduced Na⁺ delivery to macula densa; sympathetic nerve activity (β1)|modified smooth muscle cells containing renin granules; release renin when: (1) decreased stretch of afferent arteriole, (2) decreased NaCl at macula densa, (3) β1 sympathetic stimulation|renin released into blood → activates RAAS cascade (angiotensinogen → angiotensin I → angiotensin II)|integrates three inputs; most important chronic blood pressure / volume sensor
SN9|macula densa|distal convoluted tubule wall (adjacent to JG cells; part of juxtaglomerular apparatus)|NaCl concentration in tubular fluid|apical Na⁺-K⁺-2Cl⁻ cotransporter (NKCC2) senses NaCl delivery; low NaCl → prostaglandin release → stimulates renin from JG cells; high NaCl → ATP/adenosine release → constricts afferent arteriole (tubuloglomerular feedback)|paracrine signaling to adjacent JG cells and afferent arteriole|links tubular fluid composition to GFR and renin release; tubuloglomerular feedback adjusts single-nephron GFR within seconds
SN10|pancreatic beta cells|islets of Langerhans (pancreas)|blood glucose concentration|GLUT2 transporter admits glucose → glucokinase phosphorylates (rate-limiting; sets glucose sensitivity) → ↑ATP/ADP ratio → K_ATP channel closes → depolarization → Ca²⁺ influx → insulin granule exocytosis|insulin released directly into portal circulation → liver (first pass) → systemic|glucose-sensing threshold ~5 mmol/L; graded response: insulin secretion proportional to glucose above threshold; first-phase (rapid; pre-formed granules) + second-phase (sustained; newly synthesized)
SN11|pancreatic alpha cells|islets of Langerhans|blood glucose concentration (low)|mechanism debated: possible intrinsic glucose sensing (K_ATP channels); paracrine inhibition by beta cells removed when insulin drops; sympathetic and parasympathetic input|glucagon released into portal circulation → liver|activated by glucose <3.9 mmol/L; inhibited by insulin, somatostatin, and high glucose; counter-regulatory role
SN12|parathyroid chief cells|parathyroid glands (4 glands on posterior thyroid)|serum ionized Ca²⁺|calcium-sensing receptor (CaSR): GPCR on chief cell membrane; high Ca²⁺ activates CaSR → Gq/Gi → inhibits PTH secretion; low Ca²⁺ → reduced CaSR activation → PTH secretion increases|PTH released into blood → acts on bone (osteoclast activation via osteoblasts) and kidney (Ca²⁺ reabsorption, PO₄ excretion, calcitriol synthesis)|inverse sigmoidal response curve; set point ~1.1–1.2 mmol/L ionized Ca²⁺; maximal PTH suppression at ~1.3 mmol/L; maximal stimulation at ~0.8 mmol/L
SN13|hepatocytes (iron sensing)|liver|plasma iron (transferrin saturation); BMP6 from liver sinusoidal endothelial cells|high iron → ↑BMP6 → ↑SMAD signaling → ↑hepcidin transcription; HFE and transferrin receptor 2 (TfR2) sense iron-loaded transferrin → enhance hepcidin; low iron → opposite|hepcidin released into blood → binds ferroportin on enterocytes and macrophages → ferroportin internalized and degraded → reduced iron export into blood|hepcidin is master iron regulator; also upregulated by IL-6 (inflammation → anemia of chronic disease); downregulated by hypoxia (via EPO and erythroferrone)
SN14|hypothalamic arcuate nucleus (energy sensing)|hypothalamus (arcuate nucleus, ARC)|leptin, insulin, ghrelin, glucose, PYY, CCK, GLP-1, FFA|two populations: POMC/CART neurons (anorexigenic: activated by leptin, insulin → α-MSH → MC4R → satiety) and NPY/AgRP neurons (orexigenic: activated by ghrelin, inhibited by leptin → NPY → hunger, AgRP antagonizes MC4R)|projects to PVN (→ CRH, TRH → metabolic rate), lateral hypothalamus (→ orexin, MCH → feeding drive), brainstem (NTS → autonomic)|integrates long-term (leptin, insulin) and short-term (ghrelin, PYY, CCK, GLP-1) signals; leptin resistance in obesity disrupts this circuit
SN15|atrial stretch receptors (volume receptors)|cardiac atria (especially right atrium and pulmonary vein-atrial junctions)|atrial wall stretch (proportional to blood volume / venous return)|mechanoreceptors; increased stretch → increased firing → (1) ANP release from atrial myocytes and (2) vagal afferent → NTS → decreased ADH release (Henry-Gauer reflex)|vagus nerve (CN X) → NTS; local paracrine → ANP release|detect changes in effective circulating volume; volume expansion → ANP → natriuresis → reduced volume

# control_centers(id|name|location|function|inputs|outputs)
CC1|hypothalamic thermoregulatory center (POAH)|preoptic area and anterior hypothalamus|integrates thermal information; compares to set point (~37°C); initiates heating or cooling responses|peripheral thermoreceptors (SN1); central thermoreceptors (SN2); pyrogens (shift set point upward in fever)|sympathetic vasomotor (vasoconstriction/vasodilation); sweat glands (sudomotor); shivering center (posterior hypothalamus → motor neurons); behavioral drive (seek warmth/cooling); thyroid axis (chronic cold → ↑TRH → ↑TSH → ↑T3/T4 → ↑metabolic rate)
CC2|medullary cardiovascular center|rostral ventrolateral medulla (RVLM: sympathoexcitatory); caudal ventrolateral medulla (CVLM: sympathoinhibitory); nucleus ambiguus (vagal motor to heart)|regulates heart rate, contractility, and peripheral vascular resistance; integrates baroreceptor, chemoreceptor, and higher input|baroreceptors (SN3, SN4) via NTS; chemoreceptors (SN5, SN6); higher input (hypothalamus: defense, emotion; cortex: anticipation)|sympathetic output to heart (↑HR, ↑contractility) and blood vessels (vasoconstriction); vagal output to heart (↓HR); sympathetic to adrenal medulla (epinephrine release)
CC3|medullary respiratory center|dorsal respiratory group (DRG: inspiratory neurons); ventral respiratory group (VRG: expiratory neurons); pre-Bötzinger complex (rhythm generator); pontine respiratory group (pneumotaxic: limits inspiration)|generates and modulates breathing rhythm; adjusts rate and depth to maintain PO₂, PCO₂, pH|central chemoreceptors (SN6: PCO₂/pH); peripheral chemoreceptors (SN5: PO₂, PCO₂, pH); lung stretch receptors (Hering-Breuer reflex); higher centers (cortex: voluntary; hypothalamus: emotion; pain)|phrenic nerve (C3–C5) → diaphragm; intercostal nerves → intercostal muscles; accessory muscles in distress; output = respiratory rate × tidal volume = minute ventilation
CC4|hypothalamic-posterior pituitary axis (ADH)|supraoptic nucleus (SON) and paraventricular nucleus (PVN) → posterior pituitary (neurohypophysis)|osmoregulation (primary) and volume regulation (secondary); synthesizes and releases ADH (vasopressin)|osmoreceptors (SN7: hyperosmolarity → ↑ADH); baroreceptors / volume receptors (SN15: hypovolemia → ↑ADH; overrides osmotic control if severe); angiotensin II (↑ADH); pain, nausea, stress (↑ADH)|ADH → kidney collecting duct (aquaporin-2 insertion → water reabsorption); V2 receptor (kidney); V1 receptor (vascular smooth muscle: vasoconstriction at high ADH levels)
CC5|RAAS (renin-angiotensin-aldosterone system)|kidney (renin) → liver (angiotensinogen) → lung (ACE) → adrenal cortex (aldosterone)|chronic blood pressure and volume regulation; Na⁺/K⁺ balance|JG cells (SN8: ↓perfusion → ↑renin); macula densa (SN9: ↓NaCl → ↑renin); sympathetic nervous system (β1 → ↑renin)|angiotensin II: vasoconstriction (↑TPR); ↑aldosterone (→ Na⁺ reabsorption, K⁺ secretion in collecting duct); ↑ADH; ↑thirst; ↑sympathetic tone; renal Na⁺ reabsorption in PCT; aldosterone: acts on principal cells (ENaC, Na⁺/K⁺-ATPase)
CC6|pancreatic islet regulation|islets of Langerhans (1–2 million islets; beta cells ~60%, alpha cells ~30%, delta cells ~10%)|glucose homeostasis; integrates glucose sensing with hormonal output|beta cells (SN10: glucose → insulin); alpha cells (SN11: low glucose → glucagon); delta cells (somatostatin: paracrine inhibition of both); incretin hormones (GLP-1, GIP from gut → amplify insulin); autonomic (parasympathetic → ↑insulin; sympathetic → ↓insulin, ↑glucagon)|insulin: ↓blood glucose (muscle/adipose GLUT4 uptake; liver glycogenesis, lipogenesis, protein synthesis; suppresses gluconeogenesis and glycogenolysis); glucagon: ↑blood glucose (liver glycogenolysis, gluconeogenesis, ketogenesis)
CC7|parathyroid-calcitonin-calcitriol axis|parathyroid glands (PTH); thyroid C-cells (calcitonin); kidney (calcitriol synthesis)|calcium and phosphate homeostasis; bone remodeling|parathyroid chief cells (SN12: Ca²⁺ via CaSR); thyroid C-cells (parafollicular: high Ca²⁺ → calcitonin); kidney (PTH stimulates 1α-hydroxylase → calcitriol from 25-OH vitamin D)|PTH: ↑bone resorption (via RANKL on osteoblasts → osteoclast activation), ↑renal Ca²⁺ reabsorption (DCT), ↓renal PO₄ reabsorption (PCT: downregulates NaPi-IIa), ↑calcitriol synthesis; calcitonin: ↓osteoclast activity (minor in adults); calcitriol: ↑intestinal Ca²⁺ and PO₄ absorption, ↑bone resorption (at high levels), ↑renal Ca²⁺ reabsorption
CC8|hepatic iron regulation|liver hepatocytes|systemic iron homeostasis via hepcidin production|iron status (SN13: transferrin saturation, BMP6 → SMAD → hepcidin); inflammation (IL-6 → JAK-STAT → hepcidin); erythropoietic demand (erythroferrone from erythroblasts → suppresses hepcidin; hypoxia → ↓hepcidin)|hepcidin: binds ferroportin → internalization + degradation → reduced iron export from enterocytes (dietary absorption blocked), macrophages (recycled iron trapped), hepatocytes (stored iron trapped); net effect: ↓serum iron when hepcidin high
CC9|hypothalamic energy balance center|arcuate nucleus → paraventricular nucleus; lateral hypothalamic area; ventromedial hypothalamus; brainstem NTS|long-term energy balance; body weight set point (contested but functionally observed)|SN14: leptin (adiposity signal), ghrelin (hunger signal), insulin (fed state), PYY, CCK, GLP-1 (satiety signals); reward circuits (VTA dopamine); cortical input (cognitive eating)|PVN → TRH (→ thyroid: metabolic rate), CRH (→ cortisol: energy mobilization); LHA → orexin (wakefulness, feeding drive), MCH (feeding); autonomic → GI motility, insulin secretion; behavioral → appetite/satiety
CC10|HPA axis|hypothalamus (PVN: CRH) → anterior pituitary (corticotrophs: ACTH) → adrenal cortex (zona fasciculata: cortisol)|stress response; metabolic regulation; immune modulation; circadian cortisol rhythm|stress (physical, psychological, immune); circadian input from SCN; inflammatory cytokines (IL-1, IL-6, TNF-α); low cortisol (positive drive); high cortisol (negative feedback at hypothalamus and pituitary)|cortisol: ↑blood glucose (gluconeogenesis, glycogenolysis, insulin resistance); ↑protein catabolism; ↑lipolysis; anti-inflammatory (↓cytokines, ↓immune cell activation); permissive for catecholamine vascular effects; negative feedback → ↓CRH, ↓ACTH
CC11|sympathoadrenal system|sympathetic preganglionic neurons (IML T1–L2) → adrenal medulla (chromaffin cells) + postganglionic sympathetic neurons → target organs|acute stress response (fight-or-flight); rapid cardiovascular, metabolic, and respiratory adjustments|hypothalamus (defense reaction); medullary cardiovascular center; pain; fear; hypoglycemia; hypotension; exercise|norepinephrine (postganglionic → target organs); epinephrine (adrenal medulla → blood → systemic): ↑HR, ↑contractility (β1); vasoconstriction (α1 skin, splanchnic); vasodilation (β2 skeletal muscle); bronchodilation (β2); ↑glycogenolysis (liver β2, muscle); ↑lipolysis (β3 adipose); pupil dilation; ↓GI motility
CC12|SCN circadian master clock|suprachiasmatic nucleus (SCN) of hypothalamus|generates and entrains ~24-hour rhythms; coordinates peripheral clocks in all tissues|retinal melanopsin ganglion cells → retinohypothalamic tract → SCN (light is primary zeitgeber); also: feeding timing, social cues, exercise (minor zeitgebers)|SCN → pineal gland (via SCG: melatonin secretion at night); SCN → PVN (cortisol rhythm); SCN → VLPO/orexin neurons (sleep-wake); SCN → autonomic (body temperature rhythm); humoral signals to peripheral clocks (glucocorticoids, body temperature)

# feedback_loops(id|name|type|stimulus|sensor|control_center|effector|response|net_effect|time_course)
FB1|baroreceptor reflex|negative|↑ arterial BP|SN3 (carotid sinus), SN4 (aortic arch)|CC2 (medullary CV center)|heart (↓HR via vagus, ↓contractility via ↓sympathetic); blood vessels (vasodilation via ↓sympathetic)|↓HR × ↓SV = ↓CO; ↓TPR; → ↓BP toward set point|restores BP to normal|seconds (fastest cardiovascular reflex)
FB2|baroreceptor reflex (hypotension)|negative|↓ arterial BP|SN3, SN4 (decreased firing)|CC2|heart (↑HR, ↑contractility via sympathetic); blood vessels (vasoconstriction via sympathetic); adrenal medulla (epinephrine)|↑CO; ↑TPR; → ↑BP toward set point|restores BP to normal|seconds
FB3|chemoreceptor ventilatory reflex|negative|↑ PCO₂ (or ↓pH or ↓PO₂)|SN6 (central: PCO₂/pH), SN5 (peripheral: PO₂, PCO₂, pH)|CC3 (respiratory center)|diaphragm (↑contraction rate and depth); intercostal muscles (↑activity)|↑minute ventilation → ↑CO₂ exhalation → ↓PCO₂ → ↑pH; ↑O₂ intake → ↑PaO₂|restores blood gases and pH|seconds to minutes
FB4|osmotic ADH loop|negative|↑ plasma osmolarity (>280 mOsm/L)|SN7 (hypothalamic osmoreceptors)|CC4 (SON/PVN → posterior pituitary)|kidney collecting duct (ADH → aquaporin-2 → ↑water reabsorption)|↑water retention → ↓osmolarity toward set point; concentrated urine|restores osmolarity|minutes (ADH release) to hours (full effect)
FB5|RAAS volume/pressure loop|negative|↓ renal perfusion pressure or ↓ Na⁺ delivery or ↑ sympathetic|SN8 (JG cells), SN9 (macula densa)|CC5 (RAAS cascade)|angiotensin II (vasoconstriction, ↑aldosterone, ↑ADH, ↑thirst, ↑Na⁺ reabsorption); aldosterone (collecting duct: ↑Na⁺ reabsorption, ↑K⁺ secretion)|↑blood volume; ↑BP; ↑Na⁺; ↓K⁺|restores perfusion pressure and volume|hours to days (full aldosterone effect: 24–48 h)
FB6|insulin-glucose loop|negative|↑ blood glucose (>5.6 mmol/L)|SN10 (beta cells)|CC6 (pancreatic islets)|muscle, adipose (GLUT4 translocation → glucose uptake); liver (glycogenesis, ↓gluconeogenesis, ↓glycogenolysis)|↓blood glucose toward fasting range (3.9–5.6 mmol/L)|restores euglycemia|minutes (insulin peak 30–60 min postprandial)
FB7|glucagon-glucose loop|negative (counter-regulatory)|↓ blood glucose (<3.9 mmol/L)|SN11 (alpha cells); also: hypothalamus, adrenal medulla|CC6 (alpha cells); CC11 (sympathoadrenal)|liver (glycogenolysis, gluconeogenesis, ketogenesis); adipose (lipolysis); ↑sympathoadrenal activation (epinephrine → hepatic glucose output)|↑blood glucose toward fasting range|restores euglycemia from hypoglycemia|minutes
FB8|PTH-calcium loop|negative|↓ serum ionized Ca²⁺|SN12 (parathyroid CaSR)|CC7 (parathyroid-calcitriol axis)|bone (osteoclast activation → Ca²⁺ release); kidney (↑Ca²⁺ reabsorption DCT; ↓PO₄ reabsorption PCT; ↑calcitriol synthesis); intestine (calcitriol → ↑Ca²⁺ absorption)|↑serum Ca²⁺ toward normal; ↓serum PO₄|restores calcium|hours (renal, bone resorption) to days (calcitriol → intestinal absorption)
FB9|hepcidin-iron loop|negative|↑ serum iron / transferrin saturation|SN13 (hepatocytes: BMP6-SMAD pathway)|CC8 (liver)|hepcidin → ferroportin degradation on enterocytes (↓dietary iron absorption), macrophages (↓recycled iron release), hepatocytes (↓stored iron release)|↓serum iron toward normal|restores iron balance|hours to days
FB10|leptin-energy loop|negative (long-term)|↑ adipose mass → ↑ leptin|SN14 (arcuate POMC/CART neurons activated by leptin)|CC9 (hypothalamic energy center)|↓appetite (via melanocortin → MC4R → satiety); ↑metabolic rate (via thyroid axis, sympathetic thermogenesis); ↑activity|↓food intake; ↑energy expenditure → ↓adipose mass → ↓leptin|restores energy balance (body weight)|weeks to months (leptin resistance complicates in obesity)
FB11|cortisol negative feedback|negative|↑ cortisol|glucocorticoid receptors (GR) in hypothalamus (PVN) and anterior pituitary (corticotrophs)|CC10 (HPA axis)|↓CRH release from PVN; ↓ACTH release from pituitary; → ↓cortisol secretion from adrenal cortex|↓cortisol toward baseline|restores basal cortisol|hours (fast feedback: minutes via non-genomic; slow feedback: hours via genomic transcription changes)
FB12|ovulatory LH surge|positive (unique physiological positive feedback)|sustained high estradiol (>200 pg/mL for >36 hours from dominant follicle)|anterior pituitary gonadotrophs; hypothalamic GnRH neurons (estradiol switches from negative to positive feedback at high sustained levels)|CC13 (HPG axis: hypothalamus GnRH → anterior pituitary → LH)|massive LH surge → ovulation within 24–36 hours; follicle ruptures; oocyte released; corpus luteum forms → progesterone (which then switches back to negative feedback)|triggers ovulation|unique positive feedback that terminates itself (progesterone from corpus luteum → negative feedback → LH drops)
FB13|ANP volume loop|negative|↑ blood volume / atrial stretch|SN15 (atrial stretch receptors → ANP release from atrial myocytes)|CC4 (opposes ADH); CC5 (opposes RAAS)|kidney: ↑Na⁺ excretion (natriuresis: inhibits Na⁺ reabsorption in collecting duct); ↑GFR (dilates afferent arteriole, constricts efferent); ↓renin release; ↓aldosterone; ↓ADH|↓blood volume; ↓BP|restores volume|minutes to hours
FB14|erythropoietin loop|negative|↓ tissue PO₂ (hypoxia)|renal peritubular interstitial cells (HIF-2α stabilized in hypoxia → EPO gene transcription)|kidney (EPO production; liver minor)|bone marrow: EPO → erythroid progenitor proliferation and differentiation → ↑reticulocyte release → ↑RBC mass → ↑hemoglobin → ↑O₂ carrying capacity → ↑tissue PO₂ → ↓HIF-2α → ↓EPO|↑O₂ delivery restores tissue PO₂|restores oxygen carrying capacity|days to weeks (RBC maturation ~7 days from committed progenitor to reticulocyte; reticulocyte → mature RBC: 1–2 days)
FB15|tubuloglomerular feedback (TGF)|negative|↑ NaCl delivery to macula densa (indicates ↑GFR)|SN9 (macula densa: NKCC2 senses NaCl)|local (juxtaglomerular apparatus)|↑NaCl sensed → adenosine/ATP release → afferent arteriole constriction → ↓GFR → ↓NaCl delivery; simultaneously: ↓renin release|↓single-nephron GFR toward set point|stabilizes GFR|seconds (fastest renal feedback)

# hormones(id|name|source|target|receptor_type|primary_actions|regulation|half_life)
HM1|insulin|pancreatic beta cells|liver, skeletal muscle, adipose tissue (and nearly all cells)|tyrosine kinase receptor (insulin receptor → IRS → PI3K → Akt pathway; also Ras-MAPK for growth)|↑glucose uptake (GLUT4: muscle, adipose); ↑glycogenesis (liver, muscle); ↓gluconeogenesis (liver); ↑lipogenesis; ↑protein synthesis; ↑K⁺ uptake (cell); ↓lipolysis; ↓ketogenesis|↑: glucose, amino acids, GLP-1/GIP, parasympathetic (vagus), ↑FFAs (short-term); ↓: sympathetic (α2 on beta cells), somatostatin, low glucose|~5 min (rapid clearance by liver and kidney)
HM2|glucagon|pancreatic alpha cells|liver (primarily)|GPCR (Gs → ↑cAMP → PKA)|↑glycogenolysis; ↑gluconeogenesis; ↑ketogenesis; ↑lipolysis (at pharmacological doses); overall: ↑hepatic glucose output|↑: low glucose, amino acids (especially arginine, alanine), sympathetic (β2), cortisol, exercise; ↓: glucose, insulin, somatostatin, GLP-1, GABA from beta cells|~5 min
HM3|ADH (vasopressin)|hypothalamus (SON, PVN) → posterior pituitary (storage and release)|kidney collecting duct (V2R); vascular smooth muscle (V1aR); anterior pituitary (V1bR/V3R)|V2: GPCR (Gs → cAMP → aquaporin-2 insertion); V1a: GPCR (Gq → vasoconstriction)|V2: ↑water reabsorption in collecting duct → concentrated urine; V1a: vasoconstriction (at high levels); V1b/V3: ↑ACTH release|↑: hyperosmolarity (primary), hypovolemia, angiotensin II, pain, nausea, nicotine; ↓: hypo-osmolarity, hypervolemia, ethanol, ANP|15–20 min
HM4|aldosterone|adrenal cortex (zona glomerulosa)|kidney (principal cells of collecting duct, DCT); also colon, sweat glands, salivary glands|nuclear receptor (mineralocorticoid receptor, MR → gene transcription)|↑ENaC (Na⁺ reabsorption); ↑Na⁺/K⁺-ATPase; ↑ROMK (K⁺ secretion); ↑H⁺-ATPase (H⁺ secretion); net: ↑Na⁺/water reabsorption, ↑K⁺ excretion, ↑H⁺ excretion|↑: angiotensin II (primary), hyperkalemia (direct), ACTH (minor, pulsatile); ↓: ANP, hypokalemia, dopamine|~20 min
HM5|angiotensin II|ACE (lung endothelium, kidney) converts angiotensin I → angiotensin II|vascular smooth muscle (AT1R); adrenal cortex (AT1R); kidney PCT (AT1R); hypothalamus (thirst, ADH); sympathetic nerves|AT1R: GPCR (Gq → vasoconstriction, aldosterone, thirst, ADH, sympathetic facilitation, Na⁺ reabsorption, cardiac/vascular remodeling); AT2R: opposes AT1 (vasodilation, anti-proliferative)|vasoconstriction (most potent endogenous vasoconstrictor); ↑aldosterone; ↑ADH; ↑thirst; ↑sympathetic tone; ↑Na⁺ reabsorption in PCT; cardiac and vascular hypertrophy (chronic)|↑: renin (from JG cells); ↓: ACE inhibitors (drugs); neprilysin|~1–2 min (rapidly degraded by angiotensinases)
HM6|ANP (atrial natriuretic peptide)|atrial cardiomyocytes (released in response to atrial stretch)|kidney (↑GFR, ↓Na⁺ reabsorption); adrenal cortex (↓aldosterone); JG cells (↓renin); hypothalamus (↓ADH); vascular smooth muscle (vasodilation)|NPR-A: guanylyl cyclase receptor → ↑cGMP|↑natriuresis (↑Na⁺ and water excretion); ↓renin; ↓aldosterone; ↓ADH; vasodilation; ↓blood volume and BP|↑: atrial stretch (volume expansion); ↓: reduced venous return|~2–3 min
HM7|PTH (parathyroid hormone)|parathyroid chief cells|bone (osteoblasts → RANKL → osteoclasts); kidney (DCT, PCT, proximal tubule 1α-hydroxylase); intestine (indirect via calcitriol)|GPCR (Gs → cAMP → PKA)|↑serum Ca²⁺: bone resorption (indirect via RANKL); ↑renal Ca²⁺ reabsorption (DCT); ↓renal PO₄ reabsorption (PCT NaPi-IIa downregulation → phosphaturia); ↑1α-hydroxylase → ↑calcitriol synthesis → ↑intestinal Ca²⁺ absorption|↑: low Ca²⁺ (via CaSR); ↓: high Ca²⁺, calcitriol, hypermagnesemia; secreted within seconds of Ca²⁺ drop|~4 min (intact PTH 1-84)
HM8|calcitriol (1,25-(OH)₂D₃)|kidney proximal tubule (1α-hydroxylase converts 25-OH-D → calcitriol); requires 25-OH-D substrate (from liver hydroxylation of vitamin D from skin/diet)|intestine (↑Ca²⁺/PO₄ absorption); bone (↑resorption at high levels; ↑mineralization at physiological levels); kidney (↑Ca²⁺ reabsorption); parathyroid (↓PTH transcription)|nuclear receptor (VDR → gene transcription)|↑intestinal Ca²⁺ absorption (↑calbindin, ↑TRPV6, ↑Ca²⁺-ATPase); ↑intestinal PO₄ absorption; ↑bone resorption (synergizes with PTH); ↓PTH transcription (negative feedback)|↑: PTH (primary), low Ca²⁺, low PO₄, prolactin (pregnancy); ↓: high Ca²⁺, high PO₄ (via FGF23), calcitriol itself (negative feedback), FGF23|~4–6 hours
HM9|cortisol|adrenal cortex (zona fasciculata)|nearly all cells (GR is ubiquitous)|nuclear receptor (glucocorticoid receptor, GR → gene transcription; also non-genomic rapid effects)|metabolic: ↑blood glucose (gluconeogenesis, glycogenolysis, insulin resistance); ↑protein catabolism (muscle); ↑lipolysis; immune: anti-inflammatory (↓cytokines, ↓immune cell migration, ↓prostaglandins); permissive for catecholamine vasoconstriction; ↑bone resorption|↑: ACTH (primary), stress, circadian (peak 06:00–08:00); ↓: cortisol negative feedback at hypothalamus/pituitary|~60–90 min
HM10|epinephrine|adrenal medulla (chromaffin cells)|heart (β1), blood vessels (α1, β2), bronchioles (β2), liver (β2), adipose (β3), pancreas (α2 on beta cells, β2 on alpha cells)|adrenergic receptors (GPCR: α1 Gq; α2 Gi; β1/β2/β3 Gs)|↑HR, ↑contractility (β1); vasoconstriction (α1: skin, splanchnic) / vasodilation (β2: muscle); bronchodilation (β2); ↑hepatic glycogenolysis (β2); ↑lipolysis (β3); ↓insulin secretion (α2); ↑glucagon secretion (β2); pupil dilation (α1)|↑: sympathetic activation from medullary CV center and hypothalamus; hypoglycemia; exercise; stress; pain; ↓: cessation of sympathetic stimulus|~2 min
HM11|leptin|adipose tissue (white adipocytes; proportional to fat mass)|hypothalamus (arcuate nucleus POMC/CART and NPY/AgRP neurons); also immune cells, endothelium|JAK-STAT receptor (ObRb long form in hypothalamus → STAT3 → gene transcription)|↓appetite (activates POMC/CART anorexigenic neurons; inhibits NPY/AgRP orexigenic neurons); ↑energy expenditure (↑sympathetic thermogenesis, ↑thyroid axis); ↑reproductive axis; modulates immunity|↑: large adipose stores, insulin, feeding; ↓: fasting, weight loss, low body fat; diurnal rhythm (peak nocturnal)|~25 min
HM12|ghrelin|stomach (fundic X/A-like cells); minor: duodenum, hypothalamus|hypothalamus (arcuate nucleus NPY/AgRP neurons)|GPCR (growth hormone secretagogue receptor, GHSR1a → Gq → ↑intracellular Ca²⁺)|↑appetite (activates NPY/AgRP orexigenic neurons); ↑GH release from anterior pituitary; ↑gastric motility; ↑reward/hedonic feeding (VTA dopamine)|↑: fasting, pre-meal, weight loss; ↓: feeding, gastric distension, glucose, insulin, PYY; acylated form (octanoyl) is active|~30 min
HM13|erythropoietin (EPO)|kidney peritubular interstitial cells (~90%); liver (~10%)|bone marrow erythroid progenitor cells (CFU-E, proerythroblasts)|JAK-STAT receptor (EpoR → JAK2 → STAT5)|↑erythroid progenitor survival (anti-apoptotic), proliferation, and differentiation → ↑reticulocyte production → ↑RBC mass → ↑hemoglobin → ↑O₂ carrying capacity|↑: hypoxia (HIF-2α stabilization); cobalt, androgens; ↓: restored O₂ delivery (HIF-2α degraded by prolyl hydroxylases + VHL)|~5 hours
HM14|hepcidin|liver hepatocytes|enterocytes (duodenal), macrophages (splenic, hepatic Kupffer cells), hepatocytes|binds ferroportin directly → ferroportin internalization and degradation|↓iron absorption from gut; ↓iron release from macrophages (recycled iron from old RBCs); ↓iron release from hepatocytes; net: ↓serum iron|↑: high iron (BMP6-SMAD), inflammation (IL-6-JAK-STAT); ↓: iron deficiency, hypoxia (erythroferrone from erythroblasts), EPO (indirect)|~2.5 hours
HM15|melatonin|pineal gland (pinealocytes; synthesized from serotonin; N-acetyltransferase rate-limiting)|SCN (feedback); hypothalamus; immune cells; peripheral tissues (MT1, MT2 receptors)|MT1, MT2: GPCR (Gi → ↓cAMP)|promotes sleep onset (↓core body temperature, ↓alertness); circadian phase-setting (zeitgeber for peripheral clocks); antioxidant; immunomodulatory (enhances immune function during sleep)|↑: darkness (SCN disinhibits pineal via sympathetic; light inhibits); ↓: light exposure (especially blue 460–480 nm); β-blocker drugs (block sympathetic to pineal)|~30–60 min
HM16|thyroid hormones (T3, T4)|thyroid follicular cells (T4 primary product; T3 from peripheral deiodination of T4 by D1/D2)|nearly all cells|nuclear receptor (thyroid receptor, TR → gene transcription; also non-genomic effects on mitochondria)|↑basal metabolic rate (↑O₂ consumption, ↑heat production); ↑protein synthesis; ↑lipolysis; ↑glycogenolysis; ↑Na⁺/K⁺-ATPase activity; ↑cardiac output (↑β1 receptor expression); required for normal CNS development; ↑bone turnover|↑: TSH (from anterior pituitary); ↓: T3/T4 negative feedback at hypothalamus (↓TRH) and pituitary (↓TSH); iodine deficiency → ↓T4 → ↑TSH → goiter|T4: ~6–7 days; T3: ~1 day

# fluid_compartments(id|name|volume_L|percentage_of_TBW|osmolarity_mOsm_L|major_solutes|barriers|exchange_mechanism)
FC1|intracellular fluid (ICF)|~28 (for 70 kg male)|~67% of TBW (~40% of body mass)|~280–295|K⁺ (~140 mmol/L), Mg²⁺, PO₄³⁻, proteins, organic anions|cell membrane (lipid bilayer + selective channels and transporters)|osmosis (water follows solute); ion channels; active transport (Na⁺/K⁺-ATPase: 3 Na⁺ out, 2 K⁺ in → maintains concentration gradients)
FC2|extracellular fluid (ECF) — interstitial|~11|~26% of TBW|~280–295|Na⁺ (~140 mmol/L), Cl⁻ (~100 mmol/L), HCO₃⁻ (~24 mmol/L); low protein|capillary wall (fenestrated or continuous endothelium)|Starling forces: hydrostatic pressure (pushes out at arteriolar end) vs oncotic pressure (pulls in at venular end); bulk flow; diffusion
FC3|extracellular fluid (ECF) — plasma|~3|~7% of TBW|~280–295|Na⁺, Cl⁻, HCO₃⁻, proteins (~70 g/L: albumin 60%, globulins, fibrinogen)|capillary wall (retains most proteins); intact endothelium|same as FC2; plasma proteins generate oncotic pressure (~25 mmHg; mostly albumin) → retains water in vasculature
FC4|transcellular fluid|~1 (CSF, synovial, pleural, pericardial, peritoneal, aqueous humor, GI secretions)|~2–3% of TBW|varies by compartment|varies (CSF: low protein, similar electrolytes to plasma; GI: high variable)|epithelial barriers specific to each compartment|active secretion and absorption; epithelial transport

# electrolytes(id|name|symbol|normal_plasma_range|primary_compartment|major_functions|regulated_by|consequences_of_imbalance)
EL1|sodium|Na⁺|136–145 mmol/L|ECF (primary extracellular cation)|determines ECF osmolarity and volume; nerve/muscle excitability; Na⁺/K⁺-ATPase; cotransport (glucose, amino acids)|RAAS (aldosterone → ↑reabsorption); ADH (→ ↑water retention to dilute); ANP (→ ↑excretion); thirst|hyponatremia: cerebral edema, confusion, seizure; hypernatremia: neuronal shrinkage, confusion, seizure
EL2|potassium|K⁺|3.5–5.0 mmol/L|ICF (primary intracellular cation; ~140 mmol/L inside cells)|resting membrane potential (−90 mV in cardiac cells); nerve/muscle excitability; enzyme cofactor; acid-base (K⁺/H⁺ exchange)|aldosterone (↑K⁺ secretion in collecting duct); insulin (↑K⁺ uptake into cells); β2 agonists (↑cellular uptake); pH (acidosis → K⁺ shifts out of cells)|hypokalemia: weakness, arrhythmia (U wave), paralytic ileus; hyperkalemia: peaked T waves, widened QRS, cardiac arrest
EL3|chloride|Cl⁻|98–106 mmol/L|ECF (primary extracellular anion)|maintains electrical neutrality; follows Na⁺; gastric acid (HCl); chloride shift (RBC: Cl⁻/HCO₃⁻ exchange)|follows Na⁺ (RAAS); renal reabsorption|hypochloremia: metabolic alkalosis (contraction alkalosis); hyperchloremia: non-anion-gap metabolic acidosis
EL4|bicarbonate|HCO₃⁻|22–28 mmol/L|ECF|primary blood buffer (H₂CO₃/HCO₃⁻ system); CO₂ transport; renal acid-base regulation|kidney (reabsorption in PCT ~85%; generation of new HCO₃⁻ in intercalated cells); respiratory system (CO₂ exhalation removes carbonic acid)|low: metabolic acidosis; high: metabolic alkalosis
EL5|calcium (ionized)|Ca²⁺|1.1–1.3 mmol/L (ionized)|ICF: ~0.0001 mmol/L (10,000× gradient); bone: ~99% of body calcium|muscle contraction (excitation-contraction coupling); neurotransmitter release; blood clotting (factor IV); second messenger; enzyme cofactor; bone minerite|PTH (↑); calcitriol (↑ intestinal absorption); calcitonin (↓ minor); pH affects binding to albumin (alkalosis → more bound → ↓ionized → symptoms)|hypocalcemia: tetany, Chvostek, Trousseau, seizure, QT prolongation; hypercalcemia: weakness, constipation, polyuria, stones, shortened QT, cardiac arrest
EL6|phosphate|PO₄³⁻|0.8–1.5 mmol/L|ICF (mostly as organic phosphate: ATP, DNA, phospholipids)|ATP synthesis; DNA/RNA; phospholipid membranes; 2,3-DPG (O₂ release from Hb); bone mineral (hydroxyapatite); pH buffer (urinary phosphate buffer)|PTH (↓ renal reabsorption → phosphaturia); FGF23 (↓ renal reabsorption); calcitriol (↑ intestinal absorption); dietary intake|hypophosphatemia: weakness, respiratory failure, hemolysis, impaired ATP; hyperphosphatemia: metastatic calcification, renal osteodystrophy
EL7|magnesium|Mg²⁺|0.7–1.0 mmol/L|ICF (second most abundant intracellular cation)|enzyme cofactor (300+ enzymes including all ATP-dependent reactions); Na⁺/K⁺-ATPase cofactor; neuromuscular excitability (stabilizes nerve/muscle); PTH secretion cofactor|kidney (reabsorption in thick ascending limb primarily; regulated by CaSR); dietary intake; PTH (minor effect)|hypomagnesemia: neuromuscular irritability, arrhythmia, refractory hypokalemia and hypocalcemia (Mg²⁺ needed for K⁺ channel function and PTH secretion); hypermagnesemia: loss of reflexes, bradycardia, respiratory depression

# acid_base(id|name|type|mechanism|speed|capacity|location|key_reactions)
AB1|bicarbonate buffer system|chemical buffer|H⁺ + HCO₃⁻ ⇌ H₂CO₃ ⇌ CO₂ + H₂O; open system (CO₂ can be exhaled); most important physiological buffer because both components are independently regulated|instantaneous|large (because open: CO₂ blown off by lungs, HCO₃⁻ regenerated by kidneys)|ECF (plasma and interstitial)|Henderson-Hasselbalch: pH = 6.1 + log([HCO₃⁻] / (0.03 × PCO₂)); normal: pH = 6.1 + log(24 / (0.03 × 40)) = 6.1 + log(20) = 6.1 + 1.3 = 7.4
AB2|respiratory compensation|physiological (ventilatory)|↑PCO₂ (acidosis) → ↑ventilation → ↑CO₂ exhalation → ↓PCO₂ → ↑pH; ↓PCO₂ (alkalosis) → ↓ventilation → ↑CO₂ retention → ↑PCO₂ → ↓pH|minutes (begins within seconds; full compensation hours)|moderate (cannot fully compensate metabolic disorder; gets within ~80% of correction)|medullary respiratory center responding to central and peripheral chemoreceptors|metabolic acidosis: expected PCO₂ = 1.5 × [HCO₃⁻] + 8 ± 2 (Winter's formula); metabolic alkalosis: PCO₂ rises ~0.7 mmHg per 1 mmol/L rise in HCO₃⁻
AB3|renal compensation|physiological (renal)|kidney adjusts HCO₃⁻ reabsorption (PCT: 85% via carbonic anhydrase + Na⁺/H⁺ exchange); generates new HCO₃⁻ (intercalated cells type A: H⁺ secretion via H⁺-ATPase and H⁺/K⁺-ATPase; HCO₃⁻ returned to blood); excretes excess HCO₃⁻ (type B intercalated cells in alkalosis)|slow: hours to begin; 3–5 days for full compensation|very large (can fully compensate chronic respiratory disorders)|kidney (PCT, thick ascending limb, collecting duct intercalated cells)|acidosis: ↑H⁺ secretion, ↑HCO₃⁻ reabsorption, ↑NH₄⁺ excretion (ammoniagenesis: glutamine → NH₃ + H⁺ → NH₄⁺ excreted), ↑titratable acid (H₂PO₄⁻); alkalosis: ↓H⁺ secretion, ↑HCO₃⁻ excretion
AB4|phosphate buffer system|chemical buffer|HPO₄²⁻ + H⁺ ⇌ H₂PO₄⁻; pKa = 6.8 (close to physiological pH = effective buffer)|instantaneous|limited in ECF (low concentration); important in urine (titratable acid) and ICF|ICF; renal tubular fluid (major urinary buffer)|titratable acid in urine; also buffers ICF
AB5|protein buffer system|chemical buffer|protein-NH₃⁺ ⇌ protein-NH₂ + H⁺; protein-COO⁻ + H⁺ ⇌ protein-COOH; histidine imidazole group most important|instantaneous|very large (proteins are most abundant buffer in body; hemoglobin is major blood protein buffer)|ICF (proteins); blood (hemoglobin in RBCs)|hemoglobin: deoxyhemoglobin is better H⁺ buffer than oxyhemoglobin (Haldane effect: deoxygenated blood in tissues picks up more CO₂ and H⁺); albumin in plasma; intracellular proteins
AB6|hemoglobin buffer|chemical buffer (specialized)|HbO₂ + H⁺ ⇌ HHb + O₂; in tissues: O₂ released → deoxyhemoglobin accepts H⁺ (from CO₂ → H₂CO₃ → H⁺ + HCO₃⁻); in lungs: O₂ binds → H⁺ released → combines with HCO₃⁻ → H₂CO₃ → CO₂ (exhaled)|instantaneous|very large (~75% of non-bicarbonate buffering in blood)|RBCs|Haldane effect links O₂ transport to CO₂/H⁺ transport; chloride shift: HCO₃⁻ exits RBC via AE1 (band 3 anion exchanger) → Cl⁻ enters (maintains electrical neutrality); carbamino compounds: CO₂ binds directly to Hb N-terminus (~15% of CO₂ transport)

# failure_modes(id|name|variable_affected|direction|cause_category|specific_causes|compensation_mechanisms|consequences_if_uncompensated)
FM1|hypothermia|RV1|low (<35°C)|environmental; metabolic; iatrogenic|cold exposure + inadequate insulation; immersion; anesthesia; hypothyroidism; hypoglycemia; sepsis; burns; elderly; neonatal|shivering (↑heat production 5×); vasoconstriction (↓heat loss); behavioral (seek warmth, add clothing); ↑metabolic rate (thyroid, sympathoadrenal)|<32°C: shivering stops, confusion, cardiac irritability; <28°C: VF risk, loss of consciousness; <20°C: asystole
FM2|hyperthermia / heat stroke|RV1|high (>40°C)|environmental; metabolic; drug-induced|heat exposure + dehydration + exertion; malignant hyperthermia (genetic: ryanodine receptor); neuroleptic malignant syndrome; thyroid storm; stimulants (MDMA, cocaine)|sweating (evaporative cooling); vasodilation (convective/radiative loss); behavioral (seek shade, remove clothing); ↓metabolic rate; ↓activity|>41.5°C sustained: protein denaturation, rhabdomyolysis, DIC, multi-organ failure, death
FM3|type 1 diabetes|RV2|high (chronic)|autoimmune|autoimmune destruction of pancreatic beta cells (T-cell mediated; HLA-DR3/DR4 associated); absolute insulin deficiency|none (no insulin production → cannot compensate; exogenous insulin required); glucosuria (osmotic diuresis → polyuria → polydipsia)|DKA (diabetic ketoacidosis: ketone overproduction → anion gap metabolic acidosis + dehydration + hyperkalemia → lethal if untreated); chronic: retinopathy, nephropathy, neuropathy, CVD
FM4|type 2 diabetes|RV2|high (chronic)|metabolic; genetic; lifestyle|insulin resistance (target tissues: muscle, liver, adipose) → compensatory hyperinsulinemia → eventual beta cell failure; associated with obesity, physical inactivity, genetics|initially: beta cell compensation (↑insulin); eventually: beta cell exhaustion → relative insulin deficiency|HHS (hyperosmolar hyperglycemic state); chronic complications same as type 1; accelerated atherosclerosis; neuropathy
FM5|hypertension (essential)|RV3|high (chronic >140/90)|multifactorial|genetic predisposition + environmental: high Na⁺ intake, obesity, physical inactivity, stress, aging → ↑TPR and/or ↑blood volume; RAAS overactivity; sympathetic overactivity; endothelial dysfunction|baroreceptor reset (adapts to higher pressure → maintains higher set point); renal pressure natriuresis (partially; impaired in hypertension)|end-organ damage: LVH → heart failure; atherosclerosis → MI, stroke; nephrosclerosis → CKD; retinopathy; aortic aneurysm/dissection
FM6|metabolic acidosis|RV6|low pH (<7.35)|metabolic|↑acid production (DKA, lactic acidosis, uremia); ↓acid excretion (renal failure); ↑HCO₃⁻ loss (diarrhea, renal tubular acidosis)|respiratory compensation (↑ventilation → ↓PCO₂: Kussmaul breathing); renal compensation (↑H⁺ excretion, ↑NH₄⁺, ↑HCO₃⁻ reabsorption) — if kidneys functional|severe (<7.10): cardiac depression, vasodilation, confusion, coma, death; anion gap helps diagnosis: AG = Na⁺ − (Cl⁻ + HCO₃⁻); normal 8–12; elevated in DKA, lactic acidosis, uremia, toxins (MUDPILES)
FM7|respiratory acidosis|RV6|low pH; ↑PCO₂|respiratory|hypoventilation: COPD, CNS depression (opioids, sedatives), neuromuscular disease (ALS, myasthenia), chest wall restriction, severe asthma|acute: chemical buffering (proteins, Hb); chronic: renal compensation (↑HCO₃⁻ reabsorption/generation over 3–5 days)|acute: confusion, CO₂ narcosis, coma; chronic: compensated (pH near normal but ↑HCO₃⁻); decompensation during acute-on-chronic episodes
FM8|metabolic alkalosis|RV6|high pH (>7.45)|metabolic|↑HCO₃⁻: vomiting (loss of HCl), NG suction, diuretics (volume contraction alkalosis), alkali ingestion (antacids); ↓H⁺: hyperaldosteronism; hypokalemia (H⁺/K⁺ exchange)|respiratory compensation (↓ventilation → ↑PCO₂; limited because hypoventilation → hypoxia limits compensation); renal compensation (excrete HCO₃⁻ — but requires adequate Cl⁻ and K⁺; saline-responsive vs saline-resistant)|neuromuscular irritability, confusion, arrhythmia; hypokalemia worsens and is worsened by alkalosis; compensatory hypoventilation can cause hypoxemia
FM9|dehydration (hypovolemia)|RV7, RV3|↑ osmolarity; ↓ volume|fluid loss > intake|vomiting, diarrhea, excessive sweating, fever, burns, hemorrhage, inadequate intake; diuretic overuse; DKA osmotic diuresis|thirst (↑water intake); ADH (↑water reabsorption); RAAS (↑Na⁺/water reabsorption); sympathetic activation (↑HR, vasoconstriction to maintain BP); ↓ANP|mild (3–5% BW): thirst, ↓urine output, fatigue; moderate (6–9%): tachycardia, hypotension, oliguria, confusion; severe (>10%): hypovolemic shock, organ failure, death
FM10|Cushing syndrome|RV2, RV3, RV10|↑ cortisol (chronic)|iatrogenic (most common: exogenous steroids); endogenous: pituitary adenoma (Cushing disease: 70%), adrenal adenoma, ectopic ACTH|negative feedback suppressed by exogenous; endogenous: tumor overrides feedback|hyperglycemia (insulin resistance); hypertension (cortisol permits catecholamines; mineralocorticoid effect); osteoporosis (↑bone resorption, ↓absorption); immune suppression; central obesity; moon face; buffalo hump; purple striae; proximal muscle weakness; psychiatric symptoms
FM11|Addison disease (primary adrenal insufficiency)|RV2, RV3, RV8|↓ cortisol; ↓ aldosterone|autoimmune (most common in developed world); TB (most common worldwide); hemorrhage; metastasis; granulomatous|↑ACTH (loss of negative feedback → hyperpigmentation from ACTH/MSH on melanocytes); ↑renin (no aldosterone → RAAS activated but cannot produce aldosterone)|hypotension (no cortisol permissive effect; no aldosterone → Na⁺ loss → volume depletion); hypoglycemia; hyperkalemia (no aldosterone K⁺ secretion); hyponatremia; weakness; hyperpigmentation; adrenal crisis (acute: life-threatening shock with vomiting, fever, hypotension)

# concepts(id|name|definition|category)
HC1|negative feedback|output opposes the stimulus that caused it; returns variable toward set point; dominant homeostatic mechanism (>99% of loops)|mechanism
HC2|positive feedback|output amplifies the stimulus; drives process to completion then terminates; rare in homeostasis (FB12: LH surge; also: blood clotting cascade, labor contractions, nerve impulse propagation)|mechanism
HC3|set point|target value that the control system defends; genetically determined but can be modulated (fever: pyrogens ↑thermoregulatory set point; chronic hypertension: baroreceptor resetting; obesity: leptin resistance may ↑weight set point)|concept
HC4|gain|ratio of correction achieved to remaining error; high gain = tight regulation; blood glucose gain: ~10:1 (actual deviation is ~1/10 of what it would be without regulation); core temperature gain: ~30:1|metric
HC5|effector|organ or tissue that executes the corrective response; can be muscle, gland, organ, or behavior; multiple effectors can respond to single controller (thermoregulation: sweat glands + blood vessels + muscles + behavior)|component
HC6|receptor / sensor|structure that detects the current value of the regulated variable; converts physiological stimulus to neural or chemical signal; sensitivity and range determine detection capability|component
HC7|control center / integrator|structure that receives sensor input, compares to set point, and activates appropriate effector response; may be neural (hypothalamus, medulla) or endocrine (pancreatic islets, parathyroid)|component
HC8|anticipatory (feedforward) regulation|correction initiated BEFORE error is detected; faster than feedback but requires prediction; examples: insulin secretion stimulated by sight/smell of food (cephalic phase) before glucose rises; sympathetic activation before exercise begins (anticipatory cardiovascular response)|mechanism
HC9|redundancy|multiple overlapping systems regulate the same variable; glucose: insulin + glucagon + epinephrine + cortisol + GH + sympathetic; ensures survival if one system fails; counter-regulatory hormones provide backup|principle
HC10|hierarchical control|regulation operates at multiple levels: local (autoregulation: intrinsic tissue response), regional (neural reflexes: baroreceptor), systemic (hormonal: RAAS, ADH); higher levels modulate lower; behavioral is highest level|principle
HC11|permissive effect|one hormone enables the full effect of another without directly causing the effect; cortisol is permissive for epinephrine's vasoconstrictor effect; thyroid hormones are permissive for GH effects on growth|mechanism
HC12|circadian modulation|many homeostatic set points vary with 24-hour rhythm; cortisol peaks 06:00–08:00; melatonin peaks 02:00–04:00; body temperature lowest 04:00–05:00; growth hormone peaks during sleep; immune cell trafficking varies diurnally|mechanism
HC13|allostasis|process of achieving stability through change; long-term adaptation of set points in response to chronic conditions; allostatic load = cumulative physiological cost of repeated allostatic adaptation; chronic stress → elevated cortisol baseline → allostatic overload|concept
HC14|predictive homeostasis|physiological adjustments made in anticipation of predictable environmental changes; seasonal acclimatization; cephalic-phase insulin release; pre-exercise cardiovascular adjustment; anticipatory thirst|mechanism
HC15|trade-off / hierarchy of survival|when multiple variables are threatened simultaneously, body prioritizes: core temperature > blood pressure > pH > glucose > long-term tissue integrity; acute: survival of brain and heart over periphery (centralized circulation in shock)|principle

# relationships(from|rel|to)
# domain → regulated variable
DM1|contains|RV1
DM2|contains|RV2
DM3|contains|RV3
DM4|contains|RV4,RV5
DM5|contains|RV7,RV8,RV9
DM6|contains|RV6
DM7|contains|RV10,RV11
DM8|contains|RV14
DM9|contains|RV13
DM10|contains|RV12
DM11|contains|HC12
DM12|contains|HC13
DM13|contains|FB12
DM14|contains|EL5
# sensor → regulated variable
SN1|enables|RV1
SN2|enables|RV1
SN3|enables|RV3
SN4|enables|RV3
SN5|enables|RV4,RV5
SN6|enables|RV5,RV6
SN7|enables|RV7
SN8|enables|RV3
SN9|enables|RV3
SN10|enables|RV2
SN11|enables|RV2
SN12|enables|RV10
SN13|enables|RV14
SN14|enables|RV13
SN15|enables|RV3
# sensor → control center
SN1|precedes|CC1
SN2|precedes|CC1
SN3|precedes|CC2
SN4|precedes|CC2
SN5|precedes|CC3
SN6|precedes|CC3
SN7|precedes|CC4
SN8|precedes|CC5
SN9|precedes|CC5
SN10|precedes|CC6
SN11|precedes|CC6
SN12|precedes|CC7
SN13|precedes|CC8
SN14|precedes|CC9
SN15|precedes|CC4,CC5
# control center → feedback loop
CC1|enables|FB1
CC2|enables|FB1,FB2
CC3|enables|FB3
CC4|enables|FB4,FB13
CC5|enables|FB5
CC6|enables|FB6,FB7
CC7|enables|FB8
CC8|enables|FB9
CC9|enables|FB10
CC10|enables|FB11
CC11|enables|FB2,FB7
CC12|enables|HC12
# feedback loop → hormone
FB4|requires|HM3
FB5|requires|HM4,HM5
FB6|requires|HM1
FB7|requires|HM2,HM10
FB8|requires|HM7,HM8
FB9|requires|HM14
FB10|requires|HM11
FB11|requires|HM9
FB12|requires|HM1
FB13|requires|HM6
FB14|requires|HM13
# hormone → target effects
HM1|enables|RV2
HM2|enables|RV2
HM3|enables|RV7,RV8
HM4|enables|RV8,RV9
HM5|enables|RV3,RV8
HM6|enables|RV8
HM7|enables|RV10,RV11
HM8|enables|RV10,RV11
HM9|enables|RV2,RV3
HM10|enables|RV2,RV3
HM11|enables|RV13
HM12|enables|RV13
HM13|enables|RV12
HM14|enables|RV14
HM15|enables|DM11
HM16|enables|RV1,RV2,DM9
# hormone interactions
HM1|prevents|HM2
HM2|prevents|HM1
HM5|enables|HM3,HM4
HM6|prevents|HM3,HM4,HM5
HM7|enables|HM8
HM8|prevents|HM7
HM9|enables|HM10
HM11|prevents|HM12
HM9|requires|HC11
HM10|requires|HC11
# acid-base chain
AB1|enables|AB2,AB3
AB2|requires|CC3
AB3|requires|CC5
AB5|enables|AB6
AB6|enables|AB1
AB4|extends|AB1
# fluid compartments
FC1|requires|EL2
FC2|requires|EL1
FC3|requires|EL1
FC2|enables|FC3
FC3|part_of|FC2
FC1|determined_by|RV7
FC2|determined_by|RV7
# electrolyte → regulation
EL1|determined_by|HM4,HM3,HM6
EL2|determined_by|HM4,HM1
EL3|follows|EL1
EL4|determined_by|AB3
EL5|determined_by|HM7,HM8
EL6|determined_by|HM7,HM8
EL7|enables|EL2,EL5
# failure mode → system
FM1|prevents|RV1
FM2|prevents|RV1
FM3|prevents|FB6
FM4|prevents|FB6
FM5|prevents|FB1,FB2
FM6|prevents|RV6
FM7|prevents|RV6
FM8|prevents|RV6
FM9|prevents|RV3,RV7
FM10|prevents|FB11
FM11|prevents|CC10,CC5
# concept → system architecture
HC1|enables|FB1,FB2,FB3,FB4,FB5,FB6,FB7,FB8,FB9,FB10,FB11,FB13,FB14,FB15
HC2|enables|FB12
HC3|enables|HC1
HC4|determined_by|HC1
HC5|requires|HC7
HC6|requires|HC7
HC7|enables|HC5
HC8|extends|HC1
HC9|enables|RV2,RV3
HC10|contains|CC1,CC2,CC3
HC11|enables|HM9,HM10,HM16
HC12|enables|CC12
HC13|extends|HC3
HC14|extends|HC8
HC15|enables|RV1,RV3,RV6

# section_index(section|title|ids)
1|Domains|DM1-DM14
2|Regulated Variables|RV1-RV14
3|Sensors|SN1-SN15
4|Control Centers|CC1-CC12
5|Feedback Loops|FB1-FB15
6|Hormones|HM1-HM16
7|Fluid Compartments|FC1-FC4
8|Electrolytes|EL1-EL7
9|Acid-Base Balance|AB1-AB6
10|Failure Modes|FM1-FM11
11|Homeostatic Concepts|HC1-HC15
12|Relationships|all

# decode_legend
id_prefixes: DM=domain, RV=regulated_variable, SN=sensor, CC=control_center, FB=feedback_loop, HM=hormone, FC=fluid_compartment, EL=electrolyte, AB=acid_base, FM=failure_mode, HC=homeostatic_concept
rel_types: enables|requires|prevents|specializes|generalizes|part_of|contains|follows|precedes|instance_of|determined_by|equivalent_to|extends|derived_from|composed_of
notation: _fk=foreign key; ~=approximate; ↑=increase; ↓=decrease; →=leads to / stimulates; ⇌=reversible; mmol/L=millimoles per liter; mOsm/L=milliosmoles per liter; mmHg=millimeters of mercury; mg/dL=milligrams per deciliter; g/L=grams per liter; μmol/L=micromoles per liter; °C=degrees Celsius; mV=millivolts; pH=negative log of hydrogen ion concentration; PCO₂=partial pressure of carbon dioxide; PO₂=partial pressure of oxygen; BW=body weight; TBW=total body water; ICF=intracellular fluid; ECF=extracellular fluid; GFR=glomerular filtration rate; MAP=mean arterial pressure; CO=cardiac output; SV=stroke volume; HR=heart rate; TPR=total peripheral resistance; BP=blood pressure; RAAS=renin-angiotensin-aldosterone system; ADH=antidiuretic hormone (vasopressin); ANP=atrial natriuretic peptide; PTH=parathyroid hormone; EPO=erythropoietin; GnRH=gonadotropin-releasing hormone; FSH=follicle-stimulating hormone; LH=luteinizing hormone; TSH=thyroid-stimulating hormone; TRH=thyrotropin-releasing hormone; CRH=corticotropin-releasing hormone; ACTH=adrenocorticotropic hormone; GH=growth hormone; T3=triiodothyronine; T4=thyroxine; GLUT=glucose transporter; ENaC=epithelial sodium channel; CaSR=calcium-sensing receptor; GPCR=G-protein coupled receptor; cAMP=cyclic adenosine monophosphate; cGMP=cyclic guanosine monophosphate; PKA=protein kinase A; JAK-STAT=Janus kinase-signal transducer and activator of transcription; SMAD=signaling molecules downstream of BMP; HIF=hypoxia-inducible factor; VHL=von Hippel-Lindau protein; RANKL=receptor activator of nuclear factor kappa-B ligand; BMP6=bone morphogenetic protein 6; FGF23=fibroblast growth factor 23; IL-6=interleukin-6; TNF-α=tumor necrosis factor alpha; POMC=pro-opiomelanocortin; CART=cocaine and amphetamine-regulated transcript; NPY=neuropeptide Y; AgRP=agouti-related peptide; MC4R=melanocortin 4 receptor; MCH=melanin-concentrating hormone; PYY=peptide YY; CCK=cholecystokinin; GLP-1=glucagon-like peptide-1; GIP=glucose-dependent insulinotropic peptide; DKA=diabetic ketoacidosis; HHS=hyperosmolar hyperglycemic state; DIC=disseminated intravascular coagulation; COPD=chronic obstructive pulmonary disease; ALS=amyotrophic lateral sclerosis; LVH=left ventricular hypertrophy; MI=myocardial infarction; CKD=chronic kidney disease; CVD=cardiovascular disease; CN=cranial nerve; NTS=nucleus tractus solitarius; RVLM=rostral ventrolateral medulla; CVLM=caudal ventrolateral medulla; DRG=dorsal respiratory group; VRG=ventral respiratory group; SCN=suprachiasmatic nucleus; POAH=preoptic area / anterior hypothalamus; SON=supraoptic nucleus; PVN=paraventricular nucleus; OVLT=organum vasculosum of the lamina terminalis; IML=intermediolateral cell column; PCT=proximal convoluted tubule; DCT=distal convoluted tubule; BBB=blood-brain barrier; CSF=cerebrospinal fluid; RBC=red blood cell; AE1=anion exchanger 1 (band 3); AG=anion gap; MUDPILES=methanol, uremia, DKA, propylene glycol, isoniazid/iron, lactic acidosis, ethylene glycol, salicylates (anion gap mnemonic)
confidence: normal ranges from standard clinical references (Harrison's, Guyton, Ganong); hormonal values and mechanisms from molecular endocrinology literature; feedback loop descriptions represent established physiological understanding; individual variation exists in all ranges; all facts at reference_physiology confidence level
scope: human homeostatic regulation across all major physiological systems; covers sensors, control centers, effectors, feedback loops, hormones, electrolytes, acid-base, fluid balance, and failure modes; integrates thermoregulation, glucose, cardiovascular, respiratory, renal, calcium, iron, energy, immune, circadian, and stress; excludes detailed molecular signaling cascades beyond receptor level; excludes pharmacological interventions except as context for failure mode mechanisms; complements the Human Anatomy and Neuroscience compacts by adding the dynamic regulatory layer
