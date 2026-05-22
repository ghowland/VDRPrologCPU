# HUMAN ANATOMY: STRUCTURES, SYSTEMS, AND RELATIONSHIPS — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: systems → organs → structures → tissues → regions → landmarks → cavities → planes → concepts → relationships → section_index → decode_legend

# systems(id|name|primary_function|major_organs|regulatory_mechanism)
SY1|skeletal|structural support, protection, mineral storage, hematopoiesis|bones, cartilage, ligaments, joints|mechanical load sensing; osteoblast/osteoclast balance; calcium homeostasis via parathyroid hormone + calcitonin
SY2|muscular|movement, posture maintenance, heat generation|skeletal muscle, smooth muscle, cardiac muscle|neural activation (somatic for skeletal, autonomic for smooth/cardiac); calcium-troponin regulation
SY3|nervous|sensory input, integration, motor output, cognition|brain, spinal cord, peripheral nerves, ganglia|electrochemical signaling; neurotransmitter release; synaptic plasticity
SY4|endocrine|hormone secretion; long-range chemical regulation of metabolism, growth, reproduction|hypothalamus, pituitary, thyroid, adrenals, pancreas, gonads|negative feedback loops; hypothalamic-pituitary axes; blood hormone concentration
SY5|cardiovascular|transport of O₂, CO₂, nutrients, waste, hormones, immune cells|heart, arteries, veins, capillaries|cardiac conduction system (SA node pacemaker); baroreceptor reflex; Frank-Starling mechanism
SY6|lymphatic|fluid recovery, fat absorption, immune cell transport and maturation|lymph nodes, spleen, thymus, tonsils, lymphatic vessels|hydrostatic/osmotic pressure gradient; skeletal muscle pump; one-way valves
SY7|respiratory|gas exchange (O₂ in, CO₂ out); acid-base regulation; phonation|nose, pharynx, larynx, trachea, bronchi, lungs|medullary respiratory center; chemoreceptors (CO₂/pH/O₂); diaphragm contraction
SY8|digestive|mechanical and chemical breakdown of food; nutrient absorption; waste elimination|mouth, esophagus, stomach, small intestine, large intestine, liver, gallbladder, pancreas|enteric nervous system; parasympathetic stimulation; hormonal (gastrin, secretin, CCK)
SY9|urinary|blood filtration; electrolyte/water balance; waste excretion; acid-base regulation|kidneys, ureters, urinary bladder, urethra|glomerular filtration; renin-angiotensin-aldosterone system; ADH; tubular reabsorption/secretion
SY10|reproductive (male)|spermatogenesis; testosterone production; sperm delivery|testes, epididymis, vas deferens, seminal vesicles, prostate, penis|hypothalamic-pituitary-gonadal axis; GnRH → FSH/LH → testosterone; negative feedback
SY11|reproductive (female)|oogenesis; estrogen/progesterone production; gestation; lactation|ovaries, uterine tubes, uterus, vagina, mammary glands|hypothalamic-pituitary-ovarian axis; menstrual cycle (follicular → ovulation → luteal); hCG in pregnancy
SY12|integumentary|barrier protection, thermoregulation, sensation, vitamin D synthesis|skin (epidermis, dermis, hypodermis), hair, nails, glands|sweat glands (eccrine/apocrine); cutaneous vasodilation/vasoconstriction; melanocyte UV response
SY13|immune|defense against pathogens; self/non-self discrimination; immune memory|bone marrow, thymus, spleen, lymph nodes, MALT, leukocytes|innate (immediate, nonspecific) + adaptive (delayed, specific); MHC antigen presentation; clonal selection

# organs(id|name|system_fk|location|weight_g|dimensions|blood_supply|innervation|primary_function)
O1|heart|SY5|mediastinum, left of midline|~250–350|~12 × 8 × 6 cm|coronary arteries (L and R) from aortic root|cardiac plexus (sympathetic + vagus parasympathetic); intrinsic conduction system|4-chamber pump; systemic and pulmonary circulation
O2|brain|SY3|cranial cavity|~1,300–1,400|~15 × 14 × 10 cm|internal carotid arteries + vertebral arteries → circle of Willis|cranial nerves I–XII; autonomic centers in brainstem|integration, cognition, motor control, homeostatic regulation
O3|lungs (pair)|SY7|thoracic cavity, flanking mediastinum|R: ~600, L: ~500|R: 3 lobes; L: 2 lobes; ~25 cm height|pulmonary arteries (deoxygenated) → capillary beds → pulmonary veins (oxygenated)|vagus (parasympathetic bronchoconstriction); T1–T4 sympathetic (bronchodilation)|gas exchange across ~70 m² alveolar surface
O4|liver|SY8|right hypochondriac and epigastric regions|~1,400–1,800|~28 × 16 × 8 cm; R lobe larger|hepatic artery (25% O₂-rich) + portal vein (75% nutrient-rich) → hepatic veins → IVC|hepatic plexus (sympathetic + vagal parasympathetic)|bile production; detoxification; plasma protein synthesis; glycogen storage; ~500 functions
O5|kidneys (pair)|SY9|retroperitoneal, T12–L3|~120–170 each|~11 × 6 × 3 cm|renal arteries from abdominal aorta (~20–25% cardiac output)|renal plexus (T10–L1 sympathetic); vagal parasympathetic|filtration (~180 L/day GFR); reabsorption; secretion; ~1.5 L urine/day output
O6|stomach|SY8|left hypochondriac and epigastric regions|~100 (empty)|~25 cm length; 1–1.5 L capacity (up to 4 L distended)|left gastric, right gastric, short gastric, L/R gastroepiploic arteries (celiac trunk)|vagus (parasympathetic); celiac plexus (sympathetic); enteric (Meissner + Auerbach)|mechanical churning; HCl + pepsin protein digestion; intrinsic factor secretion
O7|small intestine|SY8|central and lower abdomen|~1,000–2,000|~6 m length (duodenum 25 cm, jejunum ~2.5 m, ileum ~3.5 m)|superior mesenteric artery (jejunal, ileal branches); inferior pancreaticoduodenal|vagus (parasympathetic); splanchnic nerves (sympathetic); enteric NS|chemical digestion completion; ~90% nutrient absorption; ~600 m² absorptive surface (villi + microvilli)
O8|large intestine|SY8|frames small intestine peripherally|~1,200–1,500|~1.5 m length; cecum → ascending → transverse → descending → sigmoid → rectum|superior mesenteric (R half); inferior mesenteric (L half)|vagus to proximal 2/3; pelvic splanchnic to distal 1/3; enteric NS|water/electrolyte absorption; microbiome fermentation; feces formation
O9|pancreas|SY8,SY4|retroperitoneal, posterior to stomach, C-loop of duodenum|~70–100|~15 × 4 × 2 cm; head, body, tail|splenic artery + superior/inferior pancreaticoduodenal arteries|vagus (parasympathetic); splanchnic (sympathetic)|exocrine: digestive enzymes (lipase, amylase, trypsinogen) + bicarbonate; endocrine: islets of Langerhans (insulin, glucagon)
O10|spleen|SY6,SY13|left hypochondriac region|~150–200|~12 × 7 × 3 cm|splenic artery (celiac trunk)|splenic plexus (sympathetic)|blood filtration; old RBC removal; immune surveillance (white pulp); blood reservoir (red pulp)
O11|thyroid gland|SY4|anterior neck, inferior to larynx, C5–T1|~15–25|~5 × 3 × 2 cm (each lobe); butterfly shape|superior thyroid (external carotid) + inferior thyroid (thyrocervical trunk)|superior laryngeal nerve (vagus); recurrent laryngeal nerve (vagus); sympathetic|T3/T4 production (metabolic rate); calcitonin (calcium lowering)
O12|adrenal glands (pair)|SY4|superior poles of kidneys, retroperitoneal|~4–6 each|~5 × 3 × 1 cm|superior (inferior phrenic), middle (aorta), inferior (renal) suprarenal arteries|splanchnic nerves (preganglionic sympathetic to medulla); cortex regulated hormonally|cortex: cortisol, aldosterone, androgens; medulla: epinephrine, norepinephrine
O13|pituitary gland|SY4|sella turcica of sphenoid bone|~0.5–0.6|~12 × 8 × 6 mm|superior/inferior hypophyseal arteries (internal carotid)|hypothalamic releasing/inhibiting hormones via portal system|anterior: GH, TSH, ACTH, FSH, LH, prolactin; posterior: stores/releases ADH, oxytocin (made in hypothalamus)
O14|skin|SY12|entire body surface|~4,000–5,000 (total)|~1.5–2.0 m² surface area; thickness 0.5 mm (eyelid) to 4 mm (sole)|dermal arteriolar plexuses from regional arteries|free nerve endings (pain, temperature); Meissner (touch); Pacinian (pressure); Merkel (sustained touch); Ruffini (stretch)|barrier; thermoregulation; sensation; vitamin D synthesis; immune defense (Langerhans cells)
O15|testes (pair)|SY10|scrotum (external to abdominopelvic cavity)|~10–15 each|~4 × 3 × 2 cm|testicular arteries from abdominal aorta|genitofemoral nerve; ilioinguinal nerve; testicular plexus (sympathetic)|spermatogenesis (seminiferous tubules); testosterone production (Leydig cells)
O16|ovaries (pair)|SY11|lateral pelvic wall, in ovarian fossa|~3–5 each|~3 × 2 × 1 cm|ovarian arteries from abdominal aorta + ovarian branch of uterine artery|ovarian plexus (T10–L1 sympathetic); vagal parasympathetic|oogenesis; estrogen + progesterone production (follicles + corpus luteum)
O17|uterus|SY11|pelvic cavity, between bladder and rectum|~60–80 (nulliparous)|~7 × 5 × 2.5 cm|uterine arteries (internal iliac)|uterine plexus (sympathetic T10–L2); parasympathetic S2–S4|endometrial cycling; implantation; gestation; parturition
O18|thymus|SY6,SY13|anterior superior mediastinum|~30–40 (peak at puberty); involutes to ~5–15 in adult|~5 × 4 × 1 cm (variable with age)|internal thoracic artery; inferior thyroid artery|vagus (parasympathetic); sympathetic from cervical ganglia|T-cell maturation and selection; produces thymosin; most active in childhood
O19|bone marrow (red)|SY1,SY13|medullary cavities of flat bones, epiphyses of long bones in adults|~2,600 (total marrow, red + yellow)|distributed; ~4% of body mass|nutrient arteries of individual bones|sympathetic vasomotor fibers|hematopoiesis: produces all blood cell lineages (~500 billion cells/day)
O20|esophagus|SY8|posterior mediastinum, C6 to T11|~50–60|~25 cm length; ~2 cm diameter|inferior thyroid artery (cervical); bronchial arteries (thoracic); left gastric (abdominal)|vagus (parasympathetic motor + sensory); sympathetic chain; enteric NS|propels food bolus from pharynx to stomach via peristalsis; upper esophageal sphincter; lower esophageal sphincter
O21|gallbladder|SY8|inferior surface of liver, right hypochondriac region|~50 (with bile)|~8 × 4 cm; capacity ~50 mL|cystic artery (from right hepatic artery)|vagus (parasympathetic); celiac plexus (sympathetic)|stores and concentrates bile; contracts to release bile into duodenum via cystic → common bile duct; stimulated by CCK
O22|urinary bladder|SY9|pelvic cavity, posterior to pubic symphysis|~50 (empty)|capacity ~400–600 mL|superior vesical arteries (umbilical); inferior vesical (internal iliac)|parasympathetic S2–S4 (pelvic splanchnic: detrusor contraction); sympathetic T11–L2 (hypogastric: relaxation); somatic S2–S4 (pudendal: external sphincter)|urine storage; micturition reflex

# structures(id|name|organ_fk|type|description|clinical_significance)
# Heart structures
S1|right atrium|O1|chamber|receives deoxygenated blood from SVC, IVC, coronary sinus; SA node in wall|site of central venous catheter tip; atrial fibrillation origin
S2|right ventricle|O1|chamber|pumps blood to lungs via pulmonary trunk; trabeculated; moderator band|right heart failure → systemic congestion; pulmonary embolism increases afterload
S3|left atrium|O1|chamber|receives oxygenated blood from 4 pulmonary veins|atrial fibrillation → thrombus in left atrial appendage → stroke risk
S4|left ventricle|O1|chamber|pumps blood to systemic circulation via aorta; wall 3× thicker than RV (~1.3–1.5 cm)|LV hypertrophy in hypertension; MI most common in LV free wall
S5|interventricular septum|O1|wall|separates L and R ventricles; muscular (inferior) and membranous (superior) portions|ventricular septal defect: most common congenital heart defect
S6|mitral valve (bicuspid)|O1|valve|2 cusps; between L atrium and L ventricle; chordae tendineae to papillary muscles|mitral stenosis (rheumatic); mitral valve prolapse; regurgitation
S7|tricuspid valve|O1|valve|3 cusps; between R atrium and R ventricle|tricuspid regurgitation in right heart failure; endocarditis in IV drug use
S8|aortic valve|O1|valve|3 semilunar cusps; between LV and ascending aorta; coronary ostia above R and L cusps|aortic stenosis (calcific in elderly, bicuspid congenital); aortic regurgitation
S9|pulmonary valve|O1|valve|3 semilunar cusps; between RV and pulmonary trunk|pulmonary stenosis (congenital); carcinoid heart disease
S10|SA node|O1|conduction|pacemaker; junction of SVC and R atrium; rate ~60–100 bpm; blood supply: SA nodal artery (60% from RCA)|sick sinus syndrome; sinus bradycardia/tachycardia
S11|AV node|O1|conduction|delays impulse ~0.1 s; at base of interatrial septum in triangle of Koch; rate ~40–60 bpm|AV block (1st, 2nd, 3rd degree); junctional rhythm
S12|bundle of His|O1|conduction|penetrates fibrous skeleton; divides into L and R bundle branches in IVS|bundle branch block (LBBB, RBBB)
S13|Purkinje fibers|O1|conduction|terminal conduction fibers; penetrate ventricular myocardium; rapid conduction ~4 m/s|target of antiarrhythmic drugs; fascicular blocks
S14|coronary arteries|O1|vessel|L main → LAD + LCx; R coronary → PDA (85% R dominant); supply myocardium|atherosclerosis → MI; LAD = "widow-maker"; RCA occlusion → inferior MI
S15|pericardium|O1|membrane|fibrous outer + serous inner (parietal + visceral/epicardium); ~15–50 mL fluid|pericarditis; cardiac tamponade; constrictive pericarditis
# Brain structures
S16|cerebral cortex|O2|gray matter|2–4 mm thick; ~16 billion neurons; 4 lobes per hemisphere; gyri and sulci|stroke; epilepsy; tumors; neurodegenerative disease
S17|frontal lobe|O2|cortical region|anterior to central sulcus; prefrontal (executive), premotor, primary motor cortex (precentral gyrus); Broca's area (L)|personality change; motor deficits; expressive aphasia (Broca's)
S18|parietal lobe|O2|cortical region|posterior to central sulcus; primary somatosensory cortex (postcentral gyrus); spatial processing|contralateral sensory loss; neglect syndrome (R parietal)
S19|temporal lobe|O2|cortical region|inferior to lateral sulcus; primary auditory cortex; Wernicke's area (L); hippocampus (medial)|receptive aphasia (Wernicke's); temporal lobe epilepsy; memory deficits
S20|occipital lobe|O2|cortical region|posterior pole; primary visual cortex (V1) along calcarine sulcus|cortical blindness; visual field defects (homonymous hemianopia)
S21|cerebellum|O2|structure|posterior fossa; 3 lobes; coordinates movement, balance, motor learning; ~80% of brain neurons|ataxia; dysmetria; intention tremor; cerebellar stroke
S22|brainstem|O2|structure|midbrain + pons + medulla oblongata; cranial nerve nuclei III–XII; ascending/descending tracts; vital centers|respiratory/cardiac arrest if damaged; cranial nerve palsies; locked-in syndrome (pons)
S23|thalamus|O2|structure|bilateral ovoid masses flanking third ventricle; relay station for all sensory (except olfaction) to cortex|thalamic pain syndrome; deep brain stimulation target
S24|hypothalamus|O2|structure|inferior to thalamus; floor of third ventricle; controls pituitary; autonomic master regulator|temperature, hunger, thirst, circadian rhythm, hormone regulation; lesions → diabetes insipidus
S25|hippocampus|O2|structure|medial temporal lobe; C-shaped; critical for memory consolidation (short-term → long-term)|Alzheimer's disease (early atrophy); temporal lobe epilepsy focus; anterograde amnesia
S26|amygdala|O2|structure|anterior medial temporal lobe; fear conditioning; emotional memory; threat assessment|anxiety disorders; Klüver-Bucy syndrome (bilateral lesion)
S27|basal ganglia|O2|structure|caudate, putamen, globus pallidus, subthalamic nucleus, substantia nigra; motor initiation and inhibition|Parkinson's disease (substantia nigra dopamine loss); Huntington's (caudate atrophy); dystonia
S28|corpus callosum|O2|structure|largest white matter commissure; connects L and R hemispheres; ~200 million axons|split-brain syndrome (callosotomy); agenesis; multiple sclerosis plaques
S29|ventricles (cerebral)|O2|cavity|4 ventricles: lateral (2), third, fourth; contain ~150 mL CSF; choroid plexus produces ~500 mL/day|hydrocephalus (obstruction or overproduction); ventriculitis; intraventricular hemorrhage
S30|meninges|O2|membrane|dura mater (tough outer), arachnoid mater (middle), pia mater (inner adherent); CSF in subarachnoid space|meningitis; epidural hematoma (middle meningeal artery); subdural hematoma (bridging veins); subarachnoid hemorrhage
# Lung structures
S31|trachea|O3|airway|C-shaped cartilage rings; ~12 cm length; bifurcates at carina (T4–T5) into R and L main bronchi|intubation; tracheal stenosis; foreign body aspiration
S32|bronchial tree|O3|airway|main bronchi → lobar → segmental → terminal bronchioles; cartilage decreases distally; smooth muscle increases|asthma (bronchospasm); chronic bronchitis; bronchiectasis
S33|alveoli|O3|gas exchange|~480 million; diameter ~200 μm; type I cells (gas exchange), type II cells (surfactant); surrounded by capillary network|pneumonia (fluid-filled); emphysema (wall destruction); ARDS; surfactant deficiency in premature infants
S34|pleura|O3|membrane|visceral (on lung) + parietal (on chest wall); pleural cavity with ~5–15 mL serous fluid; negative pressure maintains inflation|pneumothorax; pleural effusion; pleuritis; empyema
S35|diaphragm|O3|muscle|primary respiratory muscle; dome-shaped; separates thorax from abdomen; central tendon; phrenic nerve (C3,C4,C5)|diaphragmatic hernia; phrenic nerve palsy → hemidiaphragm elevation; hiccup = spasmodic contraction
# Kidney structures
S36|nephron|O5|functional unit|~1 million per kidney; glomerulus + Bowman's capsule + PCT + loop of Henle + DCT + collecting duct|glomerulonephritis; acute tubular necrosis; nephrotic/nephritic syndromes
S37|glomerulus|O5|vascular|tuft of fenestrated capillaries between afferent and efferent arterioles; filtration barrier (endothelium + basement membrane + podocytes)|glomerulonephritis; diabetic nephropathy; filtration rate = GFR
S38|loop of Henle|O5|tubule|descending limb (water permeable) + ascending limb (impermeable to water, active NaCl reabsorption); countercurrent multiplier|concentrating mechanism; loop diuretics (furosemide) block Na-K-2Cl cotransporter in thick ascending limb
S39|collecting duct|O5|tubule|merges from multiple nephrons; principal cells (water/Na via ADH/aldosterone) + intercalated cells (acid-base)|ADH → aquaporin-2 insertion → water reabsorption; aldosterone → ENaC Na reabsorption; site of final urine concentration
# Liver structures
S40|hepatic lobule|O4|functional unit|hexagonal; central vein; portal triads at corners (hepatic artery branch + portal vein branch + bile duct); hepatocyte plates radiate|cirrhosis disrupts architecture; portal hypertension
S41|portal triad|O4|vascular|hepatic artery branch + portal vein branch + bile ductule; at lobule corners; blood flows centripetally to central vein|portal hypertension; cholangitis; biliary obstruction
S42|hepatocytes|O4|cell|~80% of liver volume; metabolic workhorses; bile secretion; detoxification (cytochrome P450); protein synthesis; gluconeogenesis/glycogenolysis|hepatitis; cirrhosis; hepatocellular carcinoma; drug metabolism interactions
# Skeletal landmarks
S43|vertebral column|SY1|bone|33 vertebrae: 7 cervical + 12 thoracic + 5 lumbar + 5 sacral (fused) + 4 coccygeal (fused); 4 curves|herniated disc; spinal stenosis; scoliosis; fracture (C2 dens, thoracolumbar junction)
S44|skull|SY1|bone|22 bones: 8 cranial (frontal, 2 parietal, 2 temporal, occipital, sphenoid, ethmoid) + 14 facial; protects brain; houses special senses|fracture (temporal = epidural risk; basilar = CSF leak); craniosynostosis
S45|pelvis|SY1|bone|2 hip bones (ilium + ischium + pubis fused) + sacrum + coccyx; supports trunk; protects pelvic organs; transmits weight to lower limbs|fracture (high energy); obstetric significance of pelvic dimensions; SI joint dysfunction
S46|femur|SY1|bone|longest and strongest bone; ~48 cm; head articulates with acetabulum; greater/lesser trochanters; condyles distally|neck fracture (elderly, osteoporosis); shaft fracture (high energy); avascular necrosis of head
S47|humerus|SY1|bone|arm bone; head articulates with glenoid; surgical neck; deltoid tuberosity; condyles distally|surgical neck fracture (axillary nerve risk); midshaft fracture (radial nerve risk); supracondylar fracture (children)
S48|rib cage|SY1|bone|12 pairs: 1–7 true (direct costal cartilage to sternum), 8–10 false (indirect), 11–12 floating; protects thoracic organs|flail chest (multiple fractures); rib fracture → pneumothorax risk; costochondritis
# Major vessels
S49|aorta|SY5|vessel|largest artery; ascending → arch (brachiocephalic, L common carotid, L subclavian) → descending (thoracic → abdominal) → bifurcation at L4 to common iliacs|aortic aneurysm (abdominal > thoracic); aortic dissection; coarctation (congenital)
S50|inferior vena cava|SY5|vessel|largest vein; formed at L5 by union of common iliac veins; receives hepatic, renal, gonadal veins; pierces diaphragm at T8 → R atrium|IVC thrombosis; Budd-Chiari syndrome; IVC filter placement for PE prevention
S51|pulmonary arteries|SY5|vessel|carry deoxygenated blood from RV → R and L pulmonary arteries → lobar → segmental → capillary beds around alveoli|pulmonary embolism; pulmonary hypertension
S52|portal vein|SY5|vessel|formed by superior mesenteric + splenic veins behind pancreatic neck; carries nutrient-rich blood from GI → liver|portal hypertension → varices (esophageal, caput medusae, hemorrhoidal); portal vein thrombosis
# Major nerves
S53|vagus nerve (CN X)|SY3|nerve|longest cranial nerve; exits jugular foramen; branches to pharynx, larynx, heart, lungs, GI tract to splenic flexure; parasympathetic|vagal syncope; recurrent laryngeal nerve palsy (hoarseness); vagus nerve stimulation for epilepsy
S54|phrenic nerve|SY3|nerve|C3,C4,C5; motor to diaphragm; sensory to central diaphragm, pericardium, mediastinal pleura|phrenic nerve palsy → hemidiaphragm paralysis; referred shoulder pain from diaphragm irritation
S55|sciatic nerve|SY3|nerve|L4–S3; largest nerve in body; exits pelvis through greater sciatic foramen below piriformis; divides into tibial + common peroneal at popliteal fossa|sciatica (compression by herniated disc); piriformis syndrome; injection injury
S56|brachial plexus|SY3|nerve|C5–T1 roots → trunks → divisions → cords → terminal branches (musculocutaneous, median, ulnar, radial, axillary)|Erb-Duchenne palsy (C5–C6 upper trunk); Klumpke palsy (C8–T1 lower trunk); thoracic outlet syndrome
S57|femoral nerve|SY3|nerve|L2–L4; passes under inguinal ligament lateral to femoral artery; motor to quadriceps; sensory to anterior thigh and medial leg (saphenous)|femoral neuropathy → inability to extend knee; psoas abscess compression; nerve block for femoral fracture
S58|spinal cord|SY3|nerve|extends from foramen magnum to conus medullaris (~L1–L2 in adults); ~45 cm; 31 pairs of spinal nerves; gray matter (H-shaped) + white matter tracts|spinal cord injury; cauda equina syndrome (below L2); syringomyelia; lumbar puncture at L3–L4 or L4–L5

# tissues(id|name|type|location|function|distinguishing_features)
TI1|simple squamous epithelium|epithelial|alveoli, Bowman's capsule, endothelium of vessels, mesothelium of serous membranes|diffusion, filtration, secretion of serous fluid|single layer of flat cells; thin for rapid exchange
TI2|simple cuboidal epithelium|epithelial|kidney tubules, thyroid follicles, small gland ducts|secretion and absorption|single layer of cube-shaped cells; central round nucleus
TI3|simple columnar epithelium|epithelial|GI tract lining (stomach to large intestine), gallbladder|secretion (goblet cells: mucus), absorption (microvilli)|single layer of tall cells; may have microvilli or cilia; goblet cells
TI4|pseudostratified columnar epithelium|epithelial|trachea, bronchi, upper respiratory tract|mucus secretion and ciliary movement (mucociliary escalator)|appears multilayered but all cells contact basement membrane; cilia + goblet cells
TI5|stratified squamous epithelium|epithelial|skin (keratinized), oral cavity, esophagus, vagina (nonkeratinized)|protection against abrasion|multiple layers; superficial cells flat; basal cells divide
TI6|transitional epithelium (urothelium)|epithelial|urinary bladder, ureters, renal pelvis|stretches to accommodate volume; barrier to urine|dome-shaped cells when relaxed; flattened when stretched
TI7|skeletal muscle|muscle|attached to bones via tendons|voluntary movement; posture; heat production|striated; multinucleated; long cylindrical fibers; voluntary (somatic motor)
TI8|cardiac muscle|muscle|myocardium (heart wall)|involuntary rhythmic contraction; pumps blood|striated; branched; single central nucleus; intercalated discs (gap junctions); autorhythmic
TI9|smooth muscle|muscle|walls of hollow organs (GI, blood vessels, urinary, respiratory, uterus)|involuntary contraction; peristalsis; vasoconstriction/dilation|non-striated; spindle-shaped; single central nucleus; autonomic + hormonal control
TI10|dense regular connective tissue|connective|tendons, ligaments, aponeuroses|resists tension in one direction|parallel collagen fiber bundles; few cells (fibroblasts); poor blood supply
TI11|dense irregular connective tissue|connective|dermis, organ capsules, periosteum|resists tension in multiple directions|collagen fibers in multiple orientations
TI12|loose (areolar) connective tissue|connective|subcutaneous layer, around organs, lamina propria|cushioning; immune cell transit; nutrient diffusion|fibroblasts, macrophages, mast cells in gel-like ground substance with scattered fibers
TI13|adipose tissue|connective|subcutaneous, visceral (omental, mesenteric), bone marrow (yellow)|energy storage; insulation; cushioning; endocrine (leptin)|large lipid droplet pushes nucleus to periphery (white); multiple small droplets + mitochondria (brown)
TI14|hyaline cartilage|connective|tracheal rings, costal cartilages, articular surfaces, fetal skeleton|low-friction surface; flexible support; growth plate|chondrocytes in lacunae; glassy matrix; avascular → heals poorly
TI15|elastic cartilage|connective|auricle (external ear), epiglottis|flexible support with elastic recoil|similar to hyaline but dense elastic fiber network
TI16|fibrocartilage|connective|intervertebral discs, pubic symphysis, menisci, TMJ disc|shock absorption; resists compression and tension|rows of chondrocytes alternating with thick collagen bundles; no perichondrium
TI17|compact (cortical) bone|connective|outer layer of all bones; shaft (diaphysis) of long bones|structural strength; mineral storage; protects spongy bone|osteons (Haversian systems): concentric lamellae around central canal; osteocytes in lacunae connected by canaliculi
TI18|spongy (cancellous) bone|connective|epiphyses of long bones; interior of flat/irregular bones|lightweight support; contains red marrow in spaces|trabeculae oriented along stress lines; marrow-filled spaces; no osteons
TI19|blood|connective|cardiovascular system|O₂/CO₂ transport; immune defense; clotting; hormone transport|RBCs (~5 million/μL), WBCs (~5,000–10,000/μL), platelets (~150,000–400,000/μL) in plasma
TI20|nervous tissue|nervous|brain, spinal cord, peripheral nerves, ganglia|signal transmission and integration|neurons (cell body + dendrites + axon) + neuroglia (astrocytes, oligodendrocytes, Schwann cells, microglia)

# regions(id|name|boundaries|contents|clinical_significance)
RG1|mediastinum|between pleural cavities; sternum anteriorly, vertebrae posteriorly, diaphragm inferiorly|heart, great vessels, esophagus, trachea, thoracic duct, vagus and phrenic nerves, thymus|mediastinal masses (lymphoma, thymoma); mediastinitis
RG2|retroperitoneal space|posterior to peritoneum, anterior to posterior body wall|kidneys, adrenals, ureters, aorta, IVC, pancreas (except tail), duodenum (2nd–4th parts), ascending/descending colon|retroperitoneal hemorrhage; psoas abscess; aortic aneurysm
RG3|peritoneal cavity|lined by parietal and visceral peritoneum|liver, spleen, stomach, jejunum, ileum, transverse colon, sigmoid colon; omentum; mesentery|ascites; peritonitis; intraperitoneal abscess
RG4|cranial cavity|formed by cranial bones; foramen magnum inferiorly|brain, meninges, CSF, cranial nerves, circle of Willis|epidural/subdural hematoma; brain herniation; meningitis
RG5|anterior triangle of neck|SCM posteriorly, mandible superiorly, midline medially|carotid sheath (common carotid, IJV, vagus), thyroid, larynx, trachea, submandibular gland|carotid endarterectomy; thyroid surgery; lymph node biopsy; tracheostomy
RG6|posterior triangle of neck|SCM anteriorly, trapezius posteriorly, clavicle inferiorly|accessory nerve (CN XI), external jugular vein, brachial plexus trunks, subclavian artery|accessory nerve injury → trapezius weakness; subclavian vein access; brachial plexus block
RG7|inguinal region|inguinal ligament (ASIS to pubic tubercle); inguinal canal|spermatic cord (male) / round ligament (female); ilioinguinal nerve; deep/superficial inguinal rings|inguinal hernia (indirect > direct); femoral hernia (below ligament); lymphadenopathy
RG8|popliteal fossa|posterior knee; diamond-shaped; bounded by hamstrings (superior) and gastrocnemius heads (inferior)|popliteal artery and vein; tibial and common peroneal nerves; lymph nodes|popliteal aneurysm; Baker's cyst; nerve injury during surgery
RG9|cubital fossa|anterior elbow; triangle bounded by pronator teres (medial), brachioradialis (lateral), imaginary line between epicondyles (superior)|biceps tendon, brachial artery, median nerve (medial to lateral: nerve-artery-tendon)|venipuncture (median cubital vein); blood pressure measurement; brachial artery access

# cavities(id|name|boundaries|contains|lining)
CV1|thoracic cavity|superior thoracic aperture to diaphragm; ribs laterally; sternum anteriorly; vertebrae posteriorly|lungs (in pleural cavities), mediastinum (heart, great vessels, esophagus, trachea)|parietal pleura (lungs); pericardium (heart)
CV2|abdominal cavity|diaphragm superiorly to pelvic brim inferiorly; abdominal wall musculature|stomach, liver, spleen, small intestine, large intestine (most), kidneys (retroperitoneal)|peritoneum (visceral and parietal)
CV3|pelvic cavity|continuous with abdominal; pelvic brim to pelvic floor (levator ani)|bladder, rectum, uterus/ovaries (female), prostate/seminal vesicles (male)|peritoneum (superior portions); extraperitoneal fascia
CV4|cranial cavity|cranial bones; foramen magnum|brain, meninges, CSF, cranial nerves|meninges (dura, arachnoid, pia)
CV5|spinal cavity (vertebral canal)|vertebral foramina stacked; foramen magnum to sacral hiatus|spinal cord (to ~L1–L2), cauda equina, CSF, spinal nerve roots, meninges|meninges continuous with cranial; epidural space contains fat and venous plexus
CV6|oral cavity|lips anteriorly; oropharynx posteriorly; hard/soft palate superiorly; tongue/floor inferiorly|tongue, teeth, sublingual and submandibular gland ducts, tonsils (palatine)|stratified squamous epithelium (nonkeratinized)

# planes(id|name|orientation|divides_into|clinical_use)
PL1|sagittal (median)|vertical, anteroposterior|left and right halves (midsagittal = equal; parasagittal = unequal)|MRI standard view; midline anatomy
PL2|coronal (frontal)|vertical, side to side|anterior and posterior portions|CT/MRI standard view; joint anatomy
PL3|transverse (axial/horizontal)|horizontal, perpendicular to long axis|superior and inferior portions|CT standard view (axial slices); cross-sectional anatomy
PL4|oblique|any angle not parallel to standard planes|variable|ultrasound positioning; subcostal views

# concepts(id|name|definition|category)
AC1|anatomical position|body erect, feet together, palms facing forward, thumbs lateral; all descriptions reference this position|reference
AC2|proximal|closer to trunk or point of origin|directional
AC3|distal|farther from trunk or point of origin|directional
AC4|superficial|closer to body surface|directional
AC5|deep|farther from body surface|directional
AC6|medial|closer to midline|directional
AC7|lateral|farther from midline|directional
AC8|anterior (ventral)|toward front of body|directional
AC9|posterior (dorsal)|toward back of body|directional
AC10|superior (cranial)|toward head|directional
AC11|inferior (caudal)|toward feet|directional
AC12|ipsilateral|on same side of body|directional
AC13|contralateral|on opposite side of body|directional
AC14|homeostasis|maintenance of stable internal conditions despite external variation; dynamic equilibrium|principle
AC15|negative feedback|response opposes stimulus; returns variable toward set point; dominant regulatory mechanism|mechanism
AC16|positive feedback|response amplifies stimulus; drives process to completion; examples: blood clotting, labor contractions, lactation|mechanism
AC17|referred pain|pain perceived at site distant from actual source due to convergence of visceral and somatic afferents on same spinal segments|phenomenon
AC18|dermatome|area of skin supplied by sensory fibers of single spinal nerve root; T4=nipple, T10=umbilicus, L1=inguinal|mapping
AC19|myotome|group of muscles innervated by single spinal nerve root|mapping
AC20|collateral circulation|alternative vascular pathways that can supply tissue if primary vessel occluded|mechanism
AC21|watershed zone|boundary zone between territories of two end arteries; vulnerable to ischemia during hypotension|vulnerability
AC22|anatomical snuffbox|triangular depression on lateral wrist; bounded by EPL, EPB, APL tendons; scaphoid palpable in floor|scaphoid fracture tenderness; radial artery pulse; cephalic vein origin
AC23|McBurney's point|1/3 distance from ASIS to umbilicus on right side|maximal tenderness in acute appendicitis
AC24|Murphy's sign|inspiratory arrest during palpation of RUQ during deep breath|positive in acute cholecystitis
AC25|anatomical dead space|volume of conducting airways (~150 mL) that does not participate in gas exchange|increases with intubation; decreased effective ventilation = tidal volume minus dead space

# relationships(from|rel|to)
# system containment
O1|part_of|SY5
O2|part_of|SY3
O3|part_of|SY7
O4|part_of|SY8
O5|part_of|SY9
O6|part_of|SY8
O7|part_of|SY8
O8|part_of|SY8
O9|part_of|SY8
O9|part_of|SY4
O10|part_of|SY6
O10|part_of|SY13
O11|part_of|SY4
O12|part_of|SY4
O13|part_of|SY4
O14|part_of|SY12
O15|part_of|SY10
O16|part_of|SY11
O17|part_of|SY11
O18|part_of|SY6
O18|part_of|SY13
O19|part_of|SY1
O19|part_of|SY13
O20|part_of|SY8
O21|part_of|SY8
O22|part_of|SY9
# organ → structure containment
S1|part_of|O1
S2|part_of|O1
S3|part_of|O1
S4|part_of|O1
S5|part_of|O1
S6|part_of|O1
S7|part_of|O1
S8|part_of|O1
S9|part_of|O1
S10|part_of|O1
S11|part_of|O1
S12|part_of|O1
S13|part_of|O1
S14|part_of|O1
S15|part_of|O1
S16|part_of|O2
S17|part_of|O2
S18|part_of|O2
S19|part_of|O2
S20|part_of|O2
S21|part_of|O2
S22|part_of|O2
S23|part_of|O2
S24|part_of|O2
S25|part_of|O2
S26|part_of|O2
S27|part_of|O2
S28|part_of|O2
S29|part_of|O2
S30|part_of|O2
S31|part_of|O3
S32|part_of|O3
S33|part_of|O3
S34|part_of|O3
S35|part_of|SY7
S36|part_of|O5
S37|part_of|O5
S38|part_of|O5
S39|part_of|O5
S40|part_of|O4
S41|part_of|O4
S42|part_of|O4
S43|part_of|SY1
S44|part_of|SY1
S45|part_of|SY1
S46|part_of|SY1
S47|part_of|SY1
S48|part_of|SY1
S49|part_of|SY5
S50|part_of|SY5
S51|part_of|SY5
S52|part_of|SY5
S53|part_of|SY3
S54|part_of|SY3
S55|part_of|SY3
S56|part_of|SY3
S57|part_of|SY3
S58|part_of|SY3
# cardiac conduction sequence
S10|precedes|S11
S11|precedes|S12
S12|precedes|S13
S13|enables|TI8
# blood flow sequence — right heart
S1|precedes|S7
S7|enables|S2
S2|precedes|S9
S9|enables|S51
# blood flow sequence — left heart
S3|precedes|S6
S6|enables|S4
S4|precedes|S8
S8|enables|S49
# gas exchange chain
S31|precedes|S32
S32|precedes|S33
S33|enables|TI1
S35|enables|S33
# nephron sequence
S37|precedes|S38
S38|precedes|S39
S37|enables|S36
# liver portal flow
S52|enables|S41
S41|enables|S42
S42|enables|S40
# digestive sequence
O6|precedes|O7
O7|precedes|O8
O20|precedes|O6
O4|enables|O7
O9|enables|O7
O21|enables|O7
# brain functional hierarchy
S24|enables|O13
S23|enables|S16
S27|enables|S17
S25|enables|S19
# nerve → organ innervation
S53|enables|O1
S53|enables|O3
S53|enables|O6
S53|enables|O7
S53|enables|O8
S54|enables|S35
S55|enables|S46
S56|enables|S47
S58|enables|S55
S58|enables|S57
# vascular supply dependencies
S14|enables|O1
S49|enables|O2
S49|enables|O7
S49|enables|O5
S49|enables|O4
S51|enables|S33
S50|requires|S1
# system interdependencies
SY5|enables|SY7
SY5|enables|SY9
SY5|enables|SY3
SY7|enables|SY5
SY8|enables|SY5
SY9|enables|SY5
SY4|enables|SY10
SY4|enables|SY11
SY4|enables|SY2
SY3|enables|SY2
SY3|enables|SY4
SY3|enables|SY5
SY1|enables|SY2
SY13|enables|SY1
SY13|enables|SY12
SY6|enables|SY13
SY6|enables|SY5
SY12|enables|SY13
# regulatory mechanisms
AC14|requires|AC15
AC15|enables|AC14
AC16|specializes|AC15
O13|enables|O11
O13|enables|O12
O13|enables|O15
O13|enables|O16
O11|enables|SY2
O12|enables|SY5
# tissue → organ composition
TI8|part_of|O1
TI7|part_of|SY2
TI9|part_of|O6
TI9|part_of|O7
TI9|part_of|O8
TI9|part_of|S49
TI20|part_of|O2
TI20|part_of|S58
TI14|part_of|S31
TI14|part_of|S48
TI17|part_of|S46
TI17|part_of|S44
TI18|part_of|S46
TI19|part_of|SY5
TI1|part_of|S33
TI1|part_of|S37
TI5|part_of|O14
TI6|part_of|O22
TI4|part_of|S31
TI3|part_of|O7
TI3|part_of|O6
TI10|part_of|SY2
TI13|part_of|O14
TI16|part_of|S43
# region containment
O1|part_of|RG1
O20|part_of|RG1
O5|part_of|RG2
O12|part_of|RG2
S49|part_of|RG2
S50|part_of|RG2
O4|part_of|RG3
O10|part_of|RG3
O6|part_of|RG3
O7|part_of|RG3
O2|part_of|RG4
S30|part_of|RG4
O22|part_of|CV3
O17|part_of|CV3
# cavity containment
O1|part_of|CV1
O3|part_of|CV1
O2|part_of|CV4
S58|part_of|CV5
# planes reference
PL1|enables|AC6
PL1|enables|AC7
PL2|enables|AC8
PL2|enables|AC9
PL3|enables|AC10
PL3|enables|AC11
# directional terms require anatomical position
AC2|requires|AC1
AC3|requires|AC1
AC4|requires|AC1
AC5|requires|AC1
AC6|requires|AC1
AC7|requires|AC1
AC8|requires|AC1
AC9|requires|AC1
AC10|requires|AC1
AC11|requires|AC1
AC12|requires|AC1
AC13|requires|AC1
# clinical landmarks
AC22|enables|S47
AC23|enables|O7
AC24|enables|O21
AC25|part_of|SY7

# section_index(section|title|ids)
1|Body Systems|SY1-SY13
2|Organs|O1-O22
3|Structures|S1-S58
4|Tissues|TI1-TI20
5|Body Regions|RG1-RG9
6|Body Cavities|CV1-CV6
7|Anatomical Planes|PL1-PL4
8|Anatomical Concepts|AC1-AC25
9|Relationships|all

# decode_legend
id_prefixes: SY=system, O=organ, S=structure, TI=tissue, RG=region, CV=cavity, PL=plane, AC=anatomical_concept
rel_types: enables|requires|prevents|specializes|generalizes|part_of|contains|follows|precedes|instance_of|determined_by|derived_from|composed_of
notation: _fk=foreign key; ~=approximate value; CN=cranial nerve; C/T/L/S=cervical/thoracic/lumbar/sacral vertebral level; R/L=right/left; SVC=superior vena cava; IVC=inferior vena cava; RCA=right coronary artery; LAD=left anterior descending; LCx=left circumflex; GFR=glomerular filtration rate; ADH=antidiuretic hormone; CCK=cholecystokinin; EPL/EPB/APL=extensor pollicis longus/brevis, abductor pollicis longus; ASIS=anterior superior iliac spine; SCM=sternocleidomastoid; IJV=internal jugular vein; PCT=proximal convoluted tubule; DCT=distal convoluted tubule; ENaC=epithelial sodium channel; MI=myocardial infarction; PE=pulmonary embolism; ARDS=acute respiratory distress syndrome; MHC=major histocompatibility complex; MALT=mucosa-associated lymphoid tissue; BCS=Budd-Chiari syndrome; RUQ=right upper quadrant; GI=gastrointestinal
units: g=grams; cm=centimeters; mm=millimeters; m²=square meters; mL=milliliters; L=liters; μm=micrometers; μL=microliters; bpm=beats per minute; m/s=meters per second
confidence: all anatomical values are standard adult reference ranges; individual variation exists; all facts at reference_anatomy confidence level
scope: standard adult human gross and microscopic anatomy; excludes developmental/embryological anatomy except where noted; excludes detailed neuroanatomical tract mapping; clinical significance included for surgical/diagnostic relevance

# relation_mapping(doc_rel|canonical_rel|notes)
enables|enables|exact match
requires|requires|exact match
prevents|prevents|exact match
specializes|specializes|exact match
generalizes|generalizes|exact match
part_of|part_of|exact match
contains|contains|exact match
follows|follows|exact match
precedes|precedes|exact match
instance_of|instance_of|exact match
determined_by|determined_by|exact match
derived_from|derived_from|exact match
composed_of|composed_of|exact match
