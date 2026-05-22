# ZOOLOGY — ANIMAL KINGDOM STRUCTURE — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: foundations → taxonomy → body_plans → organ_systems → locomotion → reproduction → development → ecology → behavior → phyla → vertebrate_classes → sensory → thermoregulation → scaling → conservation → rules → relationships → section_index

# foundations(id|concept|definition|significance)
FD1|animal|multicellular eukaryotic heterotroph lacking cell walls, possessing nervous tissue (most), motile at some life stage|kingdom Animalia — distinguished from plants (autotroph, cell wall), fungi (cell wall, absorptive), protists (mostly unicellular)
FD2|heterotrophy|obtaining energy by consuming other organisms or organic matter|all animals are heterotrophs — herbivore, carnivore, omnivore, detritivore, parasite, filter feeder
FD3|multicellularity|body composed of many specialized cells organized into tissues and organs|enables division of labor, large body size, complex behavior
FD4|bilateral symmetry|body divisible into mirror halves along one plane — anterior/posterior, dorsal/ventral, left/right|associated with cephalization, directed locomotion, active predation — most animals
FD5|radial symmetry|body divisible into similar halves around a central axis — no front/back|cnidarians, echinoderms (secondary) — associated with sessile or planktonic lifestyle
FD6|cephalization|concentration of sensory organs and neural tissue at the anterior end|correlated with bilateral symmetry and active locomotion — head leads into environment
FD7|segmentation|body divided into repeating units (metameres) that may specialize|annelids (homonomous), arthropods (tagmatized), chordates (vertebral)|enables regional specialization, modularity
FD8|coelom|fluid-filled body cavity lined by mesoderm on both sides|hydrostatic skeleton, space for organ development, separation of gut from body wall
FD9|homeostasis|maintenance of stable internal conditions despite external variation|thermoregulation, osmoregulation, pH balance, glucose regulation
FD10|metabolism|sum of chemical reactions sustaining life — catabolism (breakdown) + anabolism (synthesis)|metabolic rate scales with body mass: MR ∝ M^0.75 (Kleiber's law)
FD11|adaptation|heritable trait that increases fitness in a given environment|product of natural selection — morphological, physiological, behavioral
FD12|phylogeny|evolutionary history and relationships among taxa|tree of life — homology vs analogy, shared derived characters (synapomorphies)
FD13|homology|similarity due to shared ancestry — same structure, potentially different function|bat wing, whale flipper, human arm — same bones, different uses
FD14|analogy (convergence)|similarity due to similar selective pressures, not shared ancestry|bird wing, bat wing, insect wing — different structures, same function
FD15|species|group of organisms that can interbreed and produce fertile offspring (biological species concept)|fundamental unit of taxonomy — other concepts: morphological, phylogenetic, ecological
FD16|fitness|relative reproductive success of an individual genotype in a population|the currency of natural selection — measured by offspring that survive to reproduce

# taxonomy(id|rank|description|example|notes)
TX1|domain|highest rank — Eukarya for all animals|Eukarya|3-domain system: Bacteria, Archaea, Eukarya
TX2|kingdom|Animalia — all animals|Animalia|one of ~6 kingdoms in Eukarya
TX3|phylum|major body plan division|Chordata, Arthropoda, Mollusca|~35 animal phyla recognized
TX4|class|subdivision of phylum|Mammalia, Insecta, Aves|—
TX5|order|subdivision of class|Carnivora, Coleoptera, Passeriformes|—
TX6|family|subdivision of order, name ends in -idae|Felidae, Canidae, Hominidae|—
TX7|genus|group of closely related species, italicized, capitalized|Homo, Canis, Felis|—
TX8|species|fundamental unit, italicized, lowercase|Homo sapiens, Canis lupus|binomial nomenclature (Linnaeus)
TX9|subspecies|geographic or morphological variant within species|Canis lupus familiaris (domestic dog)|trinomial nomenclature
TX10|clade|monophyletic group — ancestor + all descendants|Tetrapoda, Amniota, Dinosauria|not a formal rank — defined by phylogeny
TX11|binomial nomenclature|two-part Latin name: Genus species|Linnaeus 1758|universal, language-independent identification
TX12|type specimen|single specimen permanently linked to a species name|holotype, paratype, neotype|nomenclatural anchor — the name is tied to the specimen, not to the concept

# body_plans(id|plan|symmetry|coelom|germ_layers|segmentation|examples)
BP1|asymmetric|none|none|two (diploblast)|no|Porifera (sponges) — no true tissues
BP2|radial diploblast|radial|gastrovascular cavity (not true coelom)|two (ectoderm, endoderm)|no|Cnidaria (jellyfish, corals, anemones)
BP3|acoelomate bilateral|bilateral|none — solid mesenchyme between gut and body wall|three (triploblast)|no|Platyhelminthes (flatworms)
BP4|pseudocoelomate|bilateral|body cavity not fully lined by mesoderm|three|no|Nematoda (roundworms), Rotifera
BP5|coelomate unsegmented|bilateral|true coelom (mesoderm-lined)|three|no|Mollusca, Echinodermata (secondary radial)
BP6|coelomate segmented|bilateral|true coelom, often segmented|three|yes|Annelida (homonomous), Arthropoda (tagmatized), Chordata (vertebral)
BP7|deuterostome pattern|bilateral|coelom from mesoderm pouches (enterocoely)|three|variable|Echinodermata, Chordata — blastopore becomes anus, radial cleavage
BP8|protostome pattern|bilateral|coelom from mesoderm splitting (schizocoely)|three|variable|Mollusca, Annelida, Arthropoda — blastopore becomes mouth, spiral cleavage

# organ_systems(id|system|function|key_organs|phyla_present|notes)
OS1|nervous|sensory input, integration, motor output|brain, nerve cord, ganglia, sensory organs|all except Porifera|centralized (vertebrates, cephalopods) or distributed (cnidarian nerve net, echinoderm nerve ring)
OS2|digestive|ingestion, digestion, absorption, egestion|mouth, gut (complete = mouth+anus; incomplete = single opening), accessory glands|all animals|incomplete in cnidarians, platyhelminthes; complete in most others
OS3|circulatory|transport of gases, nutrients, wastes, hormones, immune cells|heart, blood vessels, blood/hemolymph|absent in small/thin animals (diffusion sufficient); open (arthropods, most molluscs) or closed (annelids, cephalopods, vertebrates)|open: hemolymph in hemocoel; closed: blood in vessels
OS4|respiratory|gas exchange — O₂ in, CO₂ out|gills (aquatic), lungs (terrestrial), tracheae (insects), skin (amphibians), book lungs (arachnids)|required when body too large/thick for diffusion alone|surface area maximization: alveoli, gill filaments, tracheal branching
OS5|excretory|remove nitrogenous waste, osmoregulate|nephridia (annelids), Malpighian tubules (insects), kidneys (vertebrates), flame cells (flatworms)|all animals produce nitrogenous waste|waste product reflects habitat: ammonia (aquatic), urea (mammals, amphibians), uric acid (birds, reptiles, insects)
OS6|musculoskeletal|support, protection, locomotion|hydrostatic skeleton (annelids, cnidarians), exoskeleton (arthropods), endoskeleton (vertebrates, echinoderms)|all motile animals have some form|three skeleton types: hydrostatic, exo, endo — each with distinct constraints
OS7|reproductive|produce offspring|gonads (ovaries, testes), accessory structures|all animals — sexual in nearly all, asexual in some|gonochoristic (separate sexes) or hermaphroditic; external or internal fertilization
OS8|endocrine|chemical signaling via hormones|endocrine glands (pituitary, thyroid, adrenal, gonads), neurosecretory cells|arthropods (ecdysone, JH), vertebrates (complex endocrine)|coordinates growth, metabolism, reproduction, homeostasis
OS9|immune|defense against pathogens|innate (all animals): phagocytes, antimicrobial peptides; adaptive (vertebrates only): lymphocytes, antibodies|all animals have innate immunity|adaptive immunity unique to jawed vertebrates — MHC, T cells, B cells, immunological memory
OS10|integumentary|protection, sensation, thermoregulation, gas exchange|skin, scales, feathers, fur, shell, cuticle|all animals|arthropod cuticle (chitin), vertebrate skin (keratin), mollusc shell (CaCO₃)

# locomotion(id|mode|mechanism|medium|examples|constraints)
LO1|swimming|undulation, jet propulsion, fin/flipper beating, ciliary|water|fish (undulation), cephalopods (jet), cetaceans (fluke), jellyfish (bell contraction)|drag dominates — streamlining, Reynolds number determines flow regime
LO2|flying|wing flapping generating lift and thrust|air|insects (direct/indirect flight muscles), birds (feathered wings), bats (membrane wings)|wing loading = weight/wing area; must overcome gravity continuously; metabolically expensive
LO3|walking/running|limbs push against substrate|land|tetrapods (4 limbs), arthropods (6-8+ limbs), millipedes (many)|gait transitions: walk→trot→gallop; metabolic cost U-shaped with speed
LO4|burrowing|peristalsis, digging with limbs, hydrostatic pressure|soil/sediment|earthworms (peristaltic), moles (forelimb digging), clams (muscular foot)|high-friction environment — cylindrical body advantageous
LO5|climbing|grasping, clinging, adhesion|vertical surfaces|primates (prehensile hands/feet/tails), geckos (van der Waals adhesion), tree frogs (toe pads)|center of mass must stay over support or adhesion must exceed weight
LO6|gliding|extended surfaces producing lift without flapping|air (descending)|flying squirrels (patagium), flying fish (pectoral fins), Draco lizards (rib extensions)|not true powered flight — always descending relative to air
LO7|crawling/slithering|body undulation against substrate, muscular waves|land surface|snakes (lateral undulation, rectilinear, sidewinding), slugs (mucus pedal wave)|limbless — friction and body mechanics substitute for limb propulsion
LO8|sessile|attached to substrate, no locomotion in adult|none (water current brings food)|sponges, adult barnacles, adult corals, bivalves (some)|larval stage usually motile — sessile adults require current/wave-delivered food
LO9|jumping|rapid limb extension storing and releasing elastic energy|land/water surface|frogs (hindlimb extension), fleas (resilin), kangaroos (tendons)|power amplification — muscles too slow for peak acceleration, elastic storage needed
LO10|peristalsis|sequential contraction waves along body|through substrate or gut|earthworms (locomotion), all animals (gut peristalsis)|requires hydrostatic skeleton or fluid-filled tube

# reproduction(id|mode|description|examples|advantages|disadvantages)
RP1|sexual — external fertilization|gametes released into water, fertilization outside body|most fish, amphibians, many marine invertebrates|many offspring, low parental investment per offspring, genetic diversity|high gamete wastage, requires aquatic medium, limited parental care
RP2|sexual — internal fertilization|sperm deposited inside female reproductive tract|reptiles, birds, mammals, insects, some fish/amphibians|higher fertilization success, enables terrestrial reproduction, allows yolk/placenta investment|lower offspring number, requires copulation behavior, higher per-offspring cost
RP3|oviparity|eggs laid externally, develop outside mother|most fish, amphibians, reptiles, birds, monotremes, most insects|lower maternal metabolic cost, many offspring possible|eggs vulnerable to predation, desiccation, temperature
RP4|viviparity|embryo develops inside mother, live birth|most mammals, some reptiles, some fish, some insects|protection of embryo, thermoregulation, nutrient delivery|high maternal metabolic cost, limits litter size, long gestation
RP5|ovoviviparity|eggs retained inside mother, hatch internally, no placental nutrition|some sharks, some reptiles, some insects|egg protection without placental cost|intermediate strategy — no nutrient transfer beyond yolk
RP6|parthenogenesis|development from unfertilized egg|some insects (aphids), some reptiles (whiptail lizards), rotifers, Daphnia|rapid population growth, no males needed|no genetic recombination — reduced adaptive potential
RP7|hermaphroditism — simultaneous|individual has both male and female functional gonads at same time|earthworms, many snails, some fish (hamlets)|any conspecific is a potential mate — advantageous at low density|self-fertilization usually avoided (inbreeding depression)
RP8|hermaphroditism — sequential|individual changes sex during lifetime|wrasses (protogynous: female→male), clownfish (protandrous: male→female)|optimizes reproductive output based on size advantage|requires social/environmental trigger, energetic cost of transition
RP9|asexual — budding|new individual grows from parent body, detaches|Hydra, corals, some tunicates|rapid clonal reproduction, colonization|no genetic diversity, all offspring identical
RP10|asexual — fission|parent splits into two or more individuals|sea anemones, planarians, some annelids|rapid reproduction, simple|no recombination, limited to organisms with high regenerative capacity

# development(id|stage|description|key_events|examples)
DV1|fertilization|sperm and egg fuse — diploid zygote formed|species recognition, acrosomal reaction, cortical reaction (polyspermy block), pronuclear fusion|universal in sexual reproduction
DV2|cleavage|rapid mitotic divisions without growth — subdivides zygote into blastomeres|radial (deuterostomes) or spiral (protostomes), holoblastic (whole) or meroblastic (partial — yolky eggs)|sea urchin (holoblastic radial), snail (holoblastic spiral), bird (meroblastic discoidal)
DV3|blastula/blastocyst|hollow ball of cells surrounding fluid-filled cavity (blastocoel)|cell polarization, inner cell mass (mammals), blastoderm (birds)|sea urchin blastula, mammalian blastocyst
DV4|gastrulation|cell movements establish three germ layers (ectoderm, mesoderm, endoderm) and basic body axes|invagination, involution, epiboly, ingression — blastopore forms (mouth in protostomes, anus in deuterostomes)|most critical phase — "not birth, marriage, or death, but gastrulation is the most important event in your life" (Wolpert)
DV5|neurulation|ectoderm folds to form neural tube — precursor of CNS|neural plate → neural folds → neural tube closure; neural crest cells migrate|chordates only — defines the phylum's central nervous system architecture
DV6|organogenesis|germ layers differentiate into organs and organ systems|ectoderm → skin, nervous system; mesoderm → muscle, bone, circulatory; endoderm → gut lining, respiratory lining, liver, pancreas|all triploblasts
DV7|metamorphosis — complete|larval form radically different from adult, intervening pupal stage|larva → pupa → adult (holometabolous)|beetles, butterflies, flies, ants/bees — ~85% of insect species
DV8|metamorphosis — incomplete|nymph resembles small wingless adult, molts through instars|nymph → nymph → ... → adult (hemimetabolous)|grasshoppers, dragonflies, true bugs
DV9|metamorphosis — amphibian|aquatic larva (tadpole) transforms to terrestrial or semi-terrestrial adult|gill resorption, tail resorption, limb growth, gut shortening, diet shift (herbivore→carnivore)|frogs, salamanders — thyroid hormone (T3/T4) drives
DV10|direct development|no larval stage — juvenile hatches/born as miniature adult|—|reptiles, birds, mammals, some insects (silverfish), some marine invertebrates
DV11|larval dispersal|free-living larval stage serves as dispersal mechanism — differs morphologically from adult|planktonic larvae carried by currents to new habitats|trochophore (annelids, molluscs), nauplius (crustaceans), pluteus (echinoderms), planula (cnidarians)

# ecology(id|concept|definition|examples|significance)
EC1|trophic level|position in food chain — producer, primary consumer, secondary consumer, tertiary, decomposer|grass→grasshopper→frog→snake→hawk|energy transfer ~10% per level — limits chain length to 4-5 levels
EC2|food web|interconnected food chains in an ecosystem|multiple predators share multiple prey species|more realistic than linear chain — redundancy provides stability
EC3|niche|total range of conditions and resources an organism uses — fundamental vs realized|fundamental = all usable; realized = actually used (reduced by competition)|competitive exclusion: no two species can occupy identical niche indefinitely (Gause)
EC4|predator-prey dynamics|population oscillations driven by predator-prey interaction|Lotka-Volterra cycles, lynx-hare cycle|prey increase → predator increase → prey decrease → predator decrease → cycle repeats
EC5|symbiosis — mutualism|both species benefit from association|cleaner wrasse + grouper, mycorrhizae + plants, coral + zooxanthellae|not always obligate — facultative mutualism allows independent survival
EC6|symbiosis — commensalism|one benefits, other unaffected|remora on shark, barnacles on whale, epiphytes on trees|difficult to confirm true neutrality — may be undetected weak mutualism or parasitism
EC7|symbiosis — parasitism|one benefits at expense of other|tapeworms, ticks, malaria (Plasmodium)|parasites are the most species-rich lifestyle — more parasite species than free-living
EC8|keystone species|species with disproportionately large effect on ecosystem relative to abundance|sea otters (control urchins → protect kelp), wolves (trophic cascade in Yellowstone)|removal causes ecosystem restructuring — identifies conservation priorities
EC9|ecological succession|directional change in community composition over time|primary (bare rock → lichen → moss → shrubs → forest), secondary (after disturbance)|climax community concept debated — more a dynamic equilibrium than static endpoint
EC10|carrying capacity (K)|maximum population size environment can sustain indefinitely|K varies with resource availability, competition, predation, disease|logistic growth: dN/dt = rN(1 - N/K) — S-shaped curve approaching K
EC11|r/K selection|continuum of reproductive strategies|r-selected: many small offspring, little care (insects, small fish); K-selected: few large offspring, extensive care (elephants, whales)|simplification — life history traits form continuum, not strict categories
EC12|migration|seasonal movement between habitats — driven by resources, breeding, climate|Arctic tern (pole-to-pole), wildebeest (Serengeti), salmon (ocean→river)|navigation: magnetic field, sun compass, star compass, olfaction, landmarks
EC13|biogeography|study of geographic distribution of species|Wallace's line (Asian vs Australian fauna), island biogeography (MacArthur-Wilson), continental drift and vicariance|plate tectonics, dispersal, vicariance, and climate history explain current distributions

# behavior(id|behavior|description|mechanism|examples)
BH1|innate (fixed action pattern)|stereotyped behavior triggered by specific stimulus, runs to completion|genetically programmed neural circuits — sign stimulus releases motor pattern|egg-rolling in greylag goose, web-building in spiders, cuckoo chick eviction
BH2|learned — habituation|decreased response to repeated non-threatening stimulus|neural adaptation — simplest form of learning|Aplysia gill withdrawal habituating to repeated touch
BH3|learned — classical conditioning|association between neutral stimulus and significant one|Pavlovian — neutral stimulus predicts biologically relevant event|Pavlov's dogs, predator avoidance learning
BH4|learned — operant conditioning|behavior frequency modified by consequences|reinforcement increases, punishment decreases behavior frequency|Skinner box, foraging optimization
BH5|learned — imprinting|rapid irreversible learning during critical period|neural commitment during developmental window|Lorenz — goslings follow first moving object; filial and sexual imprinting
BH6|communication — visual|signals using body coloration, posture, movement|pigment cells, structural coloration, bioluminescence, display behaviors|peacock tail display, firefly bioluminescence, cuttlefish color change
BH7|communication — acoustic|signals using sound production|stridulation (insects), syrinx (birds), larynx (mammals), drumming, air sacs|birdsong (learned), whale song, cricket chirping, frog calls
BH8|communication — chemical|signals using pheromones or allomones|volatile or contact chemicals detected by chemoreceptors|ant trail pheromones, moth sex pheromones, mammalian scent marking
BH9|communication — tactile|signals using physical contact|grooming, antennation, vibration through substrate|social grooming in primates, honeybee waggle dance (vibrational component)
BH10|eusociality|reproductive division of labor, cooperative brood care, overlapping generations|haplodiploidy (Hymenoptera) or high relatedness promotes; ecological constraints maintain|ants, bees, wasps, termites, naked mole-rats — most extreme cooperative system
BH11|kin selection|altruistic behavior toward relatives, explained by inclusive fitness|Hamilton's rule: rB > C (relatedness × benefit to recipient > cost to actor)|alarm calls in ground squirrels, worker sterility in eusocial insects
BH12|territoriality|defense of an area against conspecifics|territory holder benefits from exclusive resource access; defended when benefits > costs|bird song as territorial advertisement, urine marking in wolves, reef fish aggression
BH13|courtship|behavior sequence leading to mate selection and copulation|species recognition, mate quality assessment, synchronization of gamete release|elaborate displays: bowerbird nests, bird-of-paradise dances, firefly patterns
BH14|parental care|post-hatching/birth investment in offspring survival|feeding, guarding, thermoregulation, teaching|mouthbrooding cichlids, crocodile nest guarding, mammalian nursing, bird feeding
BH15|migration behavior|oriented long-distance movement to seasonal habitats|navigation via magnetic sense, celestial cues, olfaction, learned landmarks|monarch butterflies, salmon homing, arctic tern, wildebeest
BH16|tool use|using external objects to achieve a goal not achievable by body alone|cognitive sophistication — causal understanding varies|chimpanzee termite fishing, crow hook-making, sea otter rock anvil, archer fish water jet

# phyla(id|phylum|species_count|body_plan|key_features|examples)
PY1|Porifera|~9000|asymmetric, diploblast (debated), no true tissues|choanocytes (flagellated collar cells), spicules (silica or CaCO₃) or spongin, filter feeding, totipotent cells|bath sponge, glass sponges, calcareous sponges
PY2|Cnidaria|~11000|radial diploblast, gastrovascular cavity|cnidocytes (stinging cells with nematocysts), two body forms (polyp sessile, medusa motile), nerve net|jellyfish, corals, sea anemones, Hydra, Portuguese man-of-war
PY3|Platyhelminthes|~25000|bilateral, acoelomate, triploblast|flat body (diffusion-dependent), incomplete gut (one opening), cephalization, flame cells (osmoregulation)|planaria (free-living), flukes (parasitic), tapeworms (parasitic — no gut)
PY4|Nematoda|~25000 described (~500K estimated)|bilateral, pseudocoelomate|round cross-section, cuticle molted 4× during development, complete gut, no circular muscles|Caenorhabditis elegans (model), Ascaris (parasite), hookworm, heartworm
PY5|Annelida|~22000|bilateral, coelomate, segmented (homonomous)|true segmentation with septae, closed circulatory (most), nephridia per segment, parapodia (polychaetes)|earthworms (Oligochaeta), leeches (Hirudinea), polychaete worms, tube worms
PY6|Mollusca|~85000|bilateral, coelomate (reduced), unsegmented|mantle (secretes shell), muscular foot, radula (feeding — except bivalves), open circulatory (except cephalopods)|snails (Gastropoda), clams/oysters (Bivalvia), octopus/squid (Cephalopoda), chitons
PY7|Arthropoda|~1.2 million described (~10M estimated)|bilateral, coelomate (hemocoel), tagmatized segments|exoskeleton (chitin), jointed appendages, open circulatory, compound eyes (most), molting (ecdysis)|insects (Hexapoda), spiders (Arachnida), crabs/lobsters (Crustacea), centipedes/millipedes (Myriapoda)
PY8|Echinodermata|~7000|bilateral larva → radial adult (pentameral), coelomate, deuterostome|water vascular system (tube feet), CaCO₃ endoskeleton, regeneration, no cephalization|sea stars, sea urchins, sea cucumbers, brittle stars, sand dollars
PY9|Chordata|~65000|bilateral, coelomate, segmented, deuterostome|notochord (at some stage), dorsal hollow nerve cord, pharyngeal slits/arches, post-anal tail|tunicates (Urochordata), lancelets (Cephalochordata), vertebrates (Vertebrata)

# vertebrate_classes(id|class|species_count|key_features|habitat|thermoregulation|heart|respiration|reproduction)
VC1|Agnatha (jawless fish)|~120|no jaws, no paired fins, cartilaginous skeleton, notochord persists|aquatic (marine + freshwater)|ectotherm|2-chamber|gills|external fertilization (most), some internal (hagfish)
VC2|Chondrichthyes (cartilaginous fish)|~1200|cartilaginous skeleton, jaws, paired fins, placoid scales (dermal denticles), no swim bladder|marine (mostly)|ectotherm|2-chamber|gills (5-7 slits)|internal fertilization, ovoviviparous (most), oviparous, viviparous
VC3|Osteichthyes (bony fish)|~33000|bony skeleton, swim bladder or lung homolog, operculum covering gills, scales (cycloid/ctenoid)|aquatic (marine + freshwater)|ectotherm|2-chamber|gills|external fertilization (most), some internal
VC4|Amphibia|~8400|moist permeable skin (gas exchange), aquatic larva → terrestrial adult (most), no amniotic egg|semi-aquatic / terrestrial (moist)|ectotherm|3-chamber (2 atria, 1 ventricle)|gills (larva), lungs + skin (adult)|external fertilization (most frogs), internal (salamanders/caecilians)
VC5|Reptilia|~11700|amniotic egg (shell — leathery or calcified), keratinized scales, ectothermic (most)|terrestrial (mostly)|ectotherm (most; some regional endothermy in pythons, leatherback turtles)|3-chamber (incomplete septum; crocodilians 4-chamber)|lungs|internal fertilization, oviparous or ovoviviparous
VC6|Aves (birds)|~10500|feathers, hollow bones, keeled sternum (flight), amniotic egg (calcified shell), endothermic, syrinx (vocal)|terrestrial / aerial / aquatic|endotherm (high metabolic rate)|4-chamber|lungs (parabronchi — unidirectional airflow, air sacs)|internal fertilization, oviparous, extensive parental care
VC7|Mammalia|~6500|hair/fur, mammary glands (milk), three middle ear bones, neocortex, heterodonty (differentiated teeth), endothermic|terrestrial / aquatic / aerial|endotherm|4-chamber|lungs (alveolar)|internal fertilization, mostly viviparous (monotremes oviparous), extensive parental care

# sensory(id|modality|receptor_type|medium|examples|notes)
SY1|vision|photoreceptors (rods, cones, rhabdomeres)|electromagnetic (light)|camera eye (vertebrates, cephalopods — convergent), compound eye (arthropods), eyespot (flatworms)|vertebrate and cephalopod camera eyes independently evolved — classic convergence
SY2|hearing|mechanoreceptors (hair cells)|air/water vibration|mammalian ear (pinna→tympanum→ossicles→cochlea), insect tympanal organ, fish lateral line|lateral line is pressure/vibration detection in water — no air equivalent
SY3|chemoreception (olfaction)|chemoreceptors (olfactory neurons)|airborne molecules|vertebrate olfactory epithelium, insect antennae, snake Jacobson's organ|dogs: ~300M olfactory receptors vs human ~6M
SY4|chemoreception (gustation)|chemoreceptors (taste cells)|dissolved molecules|vertebrate taste buds, insect tarsal receptors (taste with feet), catfish (whole body)|fewer distinct modalities than olfaction — sweet, sour, salt, bitter, umami
SY5|mechanoreception (touch)|mechanoreceptors|direct contact/pressure|Pacinian corpuscles (pressure), Merkel cells (texture), insect sensilla, spider slit sensilla|star-nosed mole: 22 appendages with 25000 mechanoreceptors — fastest prey detector
SY6|electroreception|electroreceptors (ampullae of Lorenzini, tuberous organs)|electric fields|sharks/rays (passive — detect prey bioelectric fields), electric fish (active — emit and receive)|only in aquatic/semi-aquatic vertebrates — requires conductive medium
SY7|magnetoreception|unknown receptor (cryptochrome? magnetite?)|geomagnetic field|migratory birds, sea turtles, salmon, honeybees|mechanism still debated — radical pair hypothesis (cryptochrome) vs magnetite crystals
SY8|echolocation|mechanoreceptors (auditory)|reflected sound|bats (laryngeal), dolphins (melon-focused clicks), oilbirds, shrews|frequency, timing, and Doppler shift encode distance, size, texture, and velocity of targets
SY9|infrared detection|thermoreceptors (pit organs)|thermal radiation|pit vipers (loreal pit), boas/pythons (labial pits), vampire bats (nose leaf)|thermal imaging with ~0.003°C resolution — detects warm-blooded prey in darkness
SY10|proprioception|mechanoreceptors (muscle spindles, Golgi tendon organs, joint receptors)|internal body position|all animals with skeletal muscles|insects use chordotonal organs and campaniform sensilla for limb position

# thermoregulation(id|strategy|mechanism|examples|advantages|disadvantages)
TH1|ectothermy|body temperature determined by environment — behavioral thermoregulation (basking, shade-seeking)|reptiles, amphibians, fish, most invertebrates|low metabolic cost — can survive on less food; larger fraction of energy to growth/reproduction|activity limited by ambient temperature; cannot sustain high-intensity activity in cold; vulnerable to thermal extremes
TH2|endothermy|internal metabolic heat maintains stable body temperature|mammals, birds|activity independent of ambient temperature; sustained high-intensity activity; enables occupation of cold habitats|high metabolic cost — must eat 10× more than ectotherm of same mass; continuous food requirement
TH3|heterothermy|switches between endo- and ectothermic states — torpor, hibernation, aestivation|hummingbirds (torpor), bears (hibernation), tenrecs|saves energy during unfavorable periods while retaining endothermic capability when active|complex physiological control; vulnerability during torpor; slow arousal time
TH4|regional endothermy|countercurrent heat exchange maintains elevated temperature in specific body regions while core may vary|tuna (red muscle), lamnid sharks (viscera), leatherback turtles (flippers), swordfish (brain/eye heaters)|high-performance muscles/organs in cold water without cost of whole-body endothermy|limited to specific regions — whole-body temperature still influenced by environment
TH5|gigantothermy|large body mass retains heat due to low surface-area-to-volume ratio|leatherback turtles, large dinosaurs (inferred), large pythons during brooding|endotherm-like thermal stability without endotherm-like metabolic cost|only works at large body size; still ectothermic — core temperature eventually tracks environment

# scaling(id|principle|relationship|significance|examples)
SL1|surface-area-to-volume ratio|SA:V decreases as body size increases (SA ∝ L², V ∝ L³)|constrains gas exchange, heat loss, nutrient absorption — small animals have relatively more surface|insects rely on tracheal diffusion (SA:V high enough); mammals need lungs (SA:V too low for diffusion)
SL2|Kleiber's law|metabolic rate ∝ mass^0.75 (not mass^1.0)|larger animals have lower mass-specific metabolic rate — a mouse burns more calories per gram than an elephant|explains why small endotherms eat constantly; why large animals can fast longer
SL3|heart rate scaling|heart rate ∝ mass^(-0.25)|small animals: fast heart rate, short lifespan; large: slow heart, long lifespan — total heartbeats roughly constant (~1.5 billion per lifetime)|shrew: ~1000 bpm; elephant: ~30 bpm; whale: ~10 bpm
SL4|limb bone scaling|bone diameter scales faster than body length to support weight (positive allometry)|bones must resist bending — stress ∝ force/area; larger animals need proportionally thicker bones|elephant limbs are columnar (resist compression); mouse limbs are slender (low stress)
SL5|brain-body scaling|brain mass ∝ body mass^0.67 — deviations (encephalization quotient) indicate cognitive elaboration|EQ > 1.0 suggests brain larger than expected — correlated with behavioral complexity|human EQ ~7, dolphin ~5, chimp ~2.5, rat ~0.4
SL6|reproductive scaling|gestation ∝ mass^0.25; litter size inversely correlated with body mass|large animals: few offspring, long gestation, high parental investment; small: many offspring, short gestation|mouse: 20-day gestation, 6-8 pups; elephant: 22-month gestation, 1 calf
SL7|flight constraints|minimum power ∝ mass^1.17; maximum load ∝ wing area × velocity²|upper size limit for flight — largest flying animal (Quetzalcoatlus, ~250 kg) near theoretical maximum|hummingbird: 2g → sustainable hovering; albatross: 12kg → dynamic soaring; larger → requires running takeoff or thermal soaring

# conservation(id|concept|description|examples|significance)
CN1|IUCN Red List categories|LC (least concern) → NT → VU → EN → CR → EW → EX|polar bear (VU), tiger (EN), vaquita (CR), thylacine (EX)|standardized extinction risk assessment — basis for conservation priority
CN2|habitat loss|primary driver of species decline — deforestation, urbanization, agriculture, fragmentation|tropical deforestation (greatest species loss), wetland drainage, coral reef degradation|~70% of terrestrial habitat modified by humans; habitat fragmentation isolates populations
CN3|overexploitation|harvesting species faster than reproduction — hunting, fishing, poaching, wildlife trade|passenger pigeon (extinct), bluefin tuna, rhinoceros (poaching for horn), shark finning|historically the largest driver of vertebrate extinction; now second to habitat loss
CN4|invasive species|non-native species outcompete, predate, or parasitize native species|rats on islands (bird extinctions), cane toads in Australia, zebra mussels, brown tree snake (Guam)|third-largest extinction driver — islands especially vulnerable
CN5|climate change|shifting temperature and precipitation patterns alter habitats faster than species can adapt or migrate|coral bleaching, polar species range contraction, phenological mismatch (timing of food/reproduction)|interacts with all other threats — amplifies habitat loss, disease, range shifts
CN6|minimum viable population (MVP)|smallest population size that can persist for a defined period with defined probability (typically 99% / 1000 years)|typically >500 breeding individuals; genetically >50 to avoid inbreeding depression short-term, >500 for long-term evolutionary potential|50/500 rule (Franklin) — below these thresholds, extinction vortex accelerates
CN7|extinction vortex|positive feedback loop where declining population → reduced genetic diversity → reduced fitness → smaller population → further decline|inbreeding depression, Allee effects, demographic stochasticity|once entered, very difficult to reverse without intervention — threshold for recovery action
CN8|flagship species|charismatic species used to raise conservation awareness and funding|giant panda, tiger, elephant, polar bear|may not represent most ecologically important conservation needs — but effective for fundraising
CN9|umbrella species|species whose conservation protects many co-occurring species via habitat preservation|spotted owl (old growth forest), grizzly bear (large wilderness)|protecting umbrella species habitat protects entire community
CN10|biodiversity hotspots|regions with exceptional endemic species richness and significant habitat loss (>70%)|34 recognized: tropical Andes, Sundaland, Madagascar, Caribbean, Mediterranean Basin|2.5% of Earth's surface contains >50% of endemic plant species and ~43% of endemic vertebrate species

# rules(id|rule|domain|rationale|violation_consequence)
RL1|surface-area-to-volume ratio constrains body plan|morphology|gas exchange, heat loss, and nutrient uptake depend on surface area; volume determines metabolic demand|organisms exceeding diffusion limits without respiratory/circulatory adaptation cannot sustain metabolism
RL2|endothermy requires ~10× food intake of equivalent-mass ectotherm|energetics|maintaining elevated body temperature is metabolically expensive|starvation risk in endotherms during food scarcity is acute — small endotherms must eat continuously
RL3|flight imposes upper mass limit|locomotion|power required for sustained flight scales faster than power available from muscle|no flying animal exceeds ~15 kg (living) or ~250 kg (extinct, Quetzalcoatlus — likely soaring, not sustained)
RL4|exoskeleton constrains maximum body size on land|morphology|exoskeleton mass scales with surface area (L²) but body mass with volume (L³) — at large size, exoskeleton too heavy|largest living arthropod on land: coconut crab ~4 kg; in water: Japanese spider crab ~20 kg (buoyancy assists)
RL5|complete metamorphosis decouples larval and adult niches|development|larva and adult can exploit completely different resources — reduces intraspecific competition|enables adaptive radiation — ~85% of insect species are holometabolous
RL6|amniotic egg enables full terrestrial reproduction|reproduction|shell and membranes (amnion, chorion, allantois, yolk sac) protect embryo from desiccation and provide gas exchange|amphibians still require water/moisture for reproduction — amniotes freed from this constraint
RL7|dorsal hollow nerve cord is synapomorphy of Chordata|taxonomy|shared derived character uniting all chordates — not found in any other phylum|distinguishes chordates from all invertebrates, which have ventral solid nerve cord (if present)
RL8|no two species can occupy the same niche indefinitely|ecology|competitive exclusion principle (Gause) — one will outcompete the other|coexistence requires niche differentiation — character displacement, resource partitioning
RL9|energy transfer between trophic levels is ~10%|ecology|metabolic costs, waste, inedible portions consume ~90% of energy at each level|limits food chain length to 4-5 levels; top predators are rare; biomass decreases with trophic level
RL10|island biogeography: species richness = f(area, isolation)|ecology|larger islands have more species (more habitats, larger populations); more isolated islands have fewer (harder to colonize)|MacArthur-Wilson equilibrium model — immigration rate vs extinction rate determines equilibrium species count
RL11|sexual selection can drive traits beyond natural selection optima|evolution|mate choice and intrasexual competition favor traits that reduce survival but increase mating success|peacock tail, elk antlers, bird-of-paradise plumage — honest signals of genetic quality (handicap principle)
RL12|parasites are the most species-rich lifestyle|ecology|every free-living species hosts multiple parasite species — parasites speciate rapidly via host specialization|more parasite species than free-living species in most ecosystems — parasitism is the dominant lifestyle

# relationships(from|rel|to)
# body plan evolution
BP1|enables|BP2
BP2|enables|BP3,BP4,BP5,BP6
BP7|subtype_of|BP5,BP6
BP8|subtype_of|BP5,BP6
FD4|enables|FD6
FD6|requires|FD4
FD7|enables|BP6
FD8|enables|OS6,OS2
# organ system dependencies
OS1|enables|BH1-BH16,LO1-LO9
OS2|enables|FD2
OS3|enables|OS4,OS8
OS4|requires|OS3
OS5|requires|OS3
OS6|enables|LO1-LO9
OS7|requires|OS8
OS8|enables|OS7,DV1-DV11
OS9|requires|OS3
OS10|enables|TH1-TH5
# phyla → body plans
PY1|implements|BP1
PY2|implements|BP2
PY3|implements|BP3
PY4|implements|BP4
PY5|implements|BP6
PY6|implements|BP5
PY7|implements|BP6
PY8|implements|BP5,BP7
PY9|implements|BP6,BP7
# phyla → vertebrate classes
PY9|contains|VC1-VC7
# vertebrate evolution
VC1|enables|VC2
VC2|enables|VC3
VC3|enables|VC4
VC4|enables|VC5
VC5|enables|VC6,VC7
# thermoregulation → vertebrate classes
TH1|characterizes|VC1,VC2,VC3,VC4,VC5
TH2|characterizes|VC6,VC7
TH4|characterizes|VC2
# reproduction modes → vertebrate classes
RP1|characterizes|VC1,VC3,VC4
RP2|characterizes|VC2,VC5,VC6,VC7
RP3|characterizes|VC3,VC4,VC5,VC6
RP4|characterizes|VC7
RP5|characterizes|VC2,VC5
# development → phyla
DV7|characterizes|PY7
DV8|characterizes|PY7
DV9|characterizes|VC4
DV10|characterizes|VC5,VC6,VC7
DV11|characterizes|PY2,PY5,PY6,PY7,PY8
# locomotion → organ systems
LO1|requires|OS6,OS4
LO2|requires|OS6,OS4,OS3
LO3|requires|OS6
LO9|requires|OS6
LO10|requires|FD8
# sensory modalities → organ system
SY1-SY10|component_of|OS1
# scaling laws
SL1|constrains|OS4,OS3,TH1-TH5
SL2|constrains|FD10,TH2
SL3|derives_from|SL2
SL4|constrains|OS6,LO3
SL5|enables|BH16,BH11
SL7|constrains|LO2
# ecology → behavior
EC3|constrains|EC4,BH12
EC4|enables|EC10
EC8|enables|CN9
EC10|constrains|EC11
EC12|requires|BH15,SY7
# behavior dependencies
BH10|requires|BH11
BH11|enables|BH10,BH14
BH13|requires|BH6,BH7,BH8
BH15|requires|SY7,SY1,SY3
BH16|requires|SL5
# conservation chains
CN2|enables|CN7
CN3|enables|CN7
CN4|enables|CN7
CN5|amplifies|CN2,CN3,CN4
CN6|constrains|CN7
CN7|threatens|FD16
CN8|enables|CN10
CN9|enables|CN10
# rules → concepts
RL1|derives_from|SL1
RL2|derives_from|SL2,TH2
RL3|derives_from|SL7
RL4|derives_from|SL1,OS10
RL5|derives_from|DV7
RL6|derives_from|RP2,RP3
RL7|distinguishes|PY9
RL8|derives_from|EC3
RL9|constrains|EC1,EC2
RL10|derives_from|EC13
RL11|derives_from|BH13,FD16
RL12|derives_from|EC7
# cross-references to other compactions
FD11|cross_ref|FD11
FD13|cross_ref|RN4
FD14|cross_ref|RN4
EC4|cross_ref|DP5
EC10|cross_ref|SC5
SL2|cross_ref|SC4
TH1|cross_ref|XD1
BH2|cross_ref|PR14

# section_index(section|title|ids)
1|Foundations|FD1-FD16
2|Taxonomy|TX1-TX12
3|Body Plans|BP1-BP8
4|Organ Systems|OS1-OS10
5|Locomotion|LO1-LO10
6|Reproduction|RP1-RP10
7|Development|DV1-DV11
8|Ecology|EC1-EC13
9|Behavior|BH1-BH16
10|Animal Phyla|PY1-PY9
11|Vertebrate Classes|VC1-VC7
12|Sensory Systems|SY1-SY10
13|Thermoregulation|TH1-TH5
14|Scaling Laws|SL1-SL7
15|Conservation|CN1-CN10
16|Rules|RL1-RL12

# decode_legend
id_prefixes: FD=foundation, TX=taxonomy, BP=body_plan, OS=organ_system, LO=locomotion, RP=reproduction, DV=development, EC=ecology, BH=behavior, PY=phylum, VC=vertebrate_class, SY=sensory, TH=thermoregulation, SL=scaling, CN=conservation, RL=rule
rel_types: enables|requires|constrains|contains|implements|subtype_of|characterizes|component_of|derives_from|threatens|amplifies|distinguishes|cross_ref
cross_ref_prefixes: RN=reasoning (COGNITION), DP=diagnostic_pattern (TROUBLESHOOTING), SC=scoring_curve (UTILITY AI), XD=cross_domain_map (TROUBLESHOOTING), PR=process (COGNITION)
species_counts: approximate, from current estimates — described species; total species including undescribed may be 5-10× higher for invertebrates
taxonomy_note: classification follows current molecular phylogenetics — some traditional groupings (e.g., Reptilia as paraphyletic without birds) noted but modern cladistic arrangement preferred
scaling_notation: ∝ = proportional to; M = body mass; L = linear dimension; ^0.75 = exponent
confidence: generated from LLM weights — reflects standard zoology (Hickman, Campbell, Pough, Kardong, Futuyma) and current phylogenetic consensus

# relation_mapping(doc_rel|canonical_rel|notes)
enables|enables|exact match
requires|requires|exact match
constrains|constrains|exact match
contains|contains|exact match
implements|implements|exact match
subtype_of|specializes|exact semantic match
characterizes|composed_of|thermoregulation characterizes vertebrate class = class composed_of that thermal strategy
component_of|part_of|exact semantic match
derives_from|derived_from|exact match
threatens|threatens|exact match
amplifies|amplifies|exact match
distinguishes|distinguishes|exact match
cross_ref|references|cross-domain link = references
