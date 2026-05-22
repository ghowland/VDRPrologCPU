# HUMAN HISTORY: MECHANICAL TRANSITIONS — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: domains → eras → concepts → transitions → thresholds → demographics → relationships → section_index → decode_legend

# domains(id|name|definition)
D1|subsistence|how humans obtain food and material resources
D2|energy|primary energy sources and conversion methods
D3|materials|dominant materials for tools, construction, and manufacture
D4|social_organization|structure of human groups: kinship, hierarchy, governance
D5|information|methods of recording, storing, and transmitting knowledge
D6|transport|methods of moving people and goods
D7|economy|systems of production, exchange, and resource allocation
D8|warfare|dominant weapons, tactics, and military organization
D9|medicine|understanding and treatment of disease and injury
D10|demographics|population size, density, distribution, life expectancy
D11|labor|how work is organized, who performs it, and how it is compensated
D12|belief_systems|dominant frameworks for explaining existence and organizing morality

# eras(id|name|date_range|defining_characteristic)
E1|Lower Paleolithic|~3,300,000–300,000 BCE|stone tool use; Oldowan and Acheulean industries
E2|Middle Paleolithic|~300,000–50,000 BCE|Levallois technique; anatomically modern humans; symbolic behavior emerges
E3|Upper Paleolithic|~50,000–10,000 BCE|blade tools; cave art; behavioral modernity; global dispersal
E4|Mesolithic|~10,000–8,000 BCE|post-glacial adaptation; microliths; semi-sedentism
E5|Neolithic|~8,000–3,300 BCE|agriculture; permanent settlement; pottery; polished stone
E6|Bronze Age|~3,300–1,200 BCE|copper-tin alloy tools/weapons; writing; first states and empires
E7|Iron Age|~1,200–500 BCE|iron smelting; alphabetic writing; coinage
E8|Classical Antiquity|~500 BCE–476 CE|Mediterranean empires; codified law; philosophy; engineering at scale
E9|Post-Classical / Medieval|~476–1450 CE|feudalism; religious institutions dominate; regional trade networks
E10|Early Modern|~1450–1750 CE|printing; gunpowder warfare; oceanic navigation; colonial expansion; scientific method
E11|Industrial|~1750–1945 CE|fossil fuel energy; mechanized production; mass urbanization; nation-states
E12|Postwar / Information|~1945–present|nuclear energy; electronics; digital computing; globalization; internet

# concepts(id|name|definition|category)
C1|Neolithic Revolution|transition from foraging to agriculture; independent origins in multiple regions|transition_complex
C2|Urban Revolution|emergence of cities with stratified society, surplus storage, and administrative class|transition_complex
C3|Axial Age|~800–200 BCE; independent emergence of philosophical/ethical systems across Eurasia|transition_complex
C4|Scientific Revolution|~1543–1687; shift from scholastic authority to empirical observation and mathematical modeling|transition_complex
C5|Industrial Revolution|~1760–1840; shift from manual/animal labor to machine manufacturing powered by fossil fuels|transition_complex
C6|Green Revolution|~1950–1970; high-yield crop varieties, synthetic fertilizers, irrigation → massive yield increase|transition_complex
C7|Digital Revolution|~1970–present; shift from analog/mechanical to digital electronics and computing|transition_complex
C8|demographic transition|shift from high birth/high death rates to low birth/low death rates accompanying industrialization|mechanism
C9|surplus|production exceeding immediate consumption; prerequisite for specialization, trade, and taxation|mechanism
C10|specialization|individuals/groups performing narrow tasks; enabled by surplus; increases productivity|mechanism
C11|network effect|value of system increases with number of participants; applies to language, currency, roads, internet|mechanism
C12|diminishing returns on complexity|as societies add complexity layers, marginal return per unit of complexity decreases|mechanism
C13|Malthusian trap|population grows to absorb productivity gains; per-capita output stagnates; broken by Industrial Revolution|mechanism
C14|Bronze Age Collapse|~1200–1150 BCE; simultaneous failure of multiple Eastern Mediterranean civilizations|collapse
C15|Western Roman Collapse|~376–476 CE; loss of centralized administration, trade networks, urban population in Western Europe|collapse
C16|Black Death|1347–1353 CE; Yersinia pestis killed ~30–60% of European population|collapse
C17|Columbian Exchange|post-1492 transfer of organisms, diseases, crops, populations between Old and New Worlds|transition_complex
C18|Great Divergence|~1750–1900; Western European economies outpaced Chinese and Indian per-capita output|transition_complex
C19|Anthropocene|proposed geological epoch defined by measurable human impact on Earth systems|concept
C20|state|polity with centralized government, territorial sovereignty, monopoly on legitimate violence, bureaucracy|structure
C21|empire|multi-ethnic polity controlling large territory through military, administrative, and economic dominance|structure
C22|nation-state|polity where political boundaries align with cultural/linguistic identity; post-1648 dominant form|structure
C23|carrying capacity|maximum population an environment can sustain given current technology and resource use|mechanism
C24|path dependence|early choices constrain later options; small initial advantages compound|mechanism
C25|intensification|applying more labor/capital per unit of land to increase output; precedes most transitions in D1|mechanism
C26|knowledge ratchet|cumulative culture — each generation builds on prior without re-deriving; unique to humans at scale|mechanism

# transitions(id|domain|prior_state|new_state|date_range|region|trigger)
# Subsistence
T1|D1|opportunistic scavenging and gathering|systematic hunting and gathering with seasonal rounds|~300,000 BCE|Africa|improved stone tools; cooperative hunting; fire control
T2|D1|hunting-gathering|semi-sedentary foraging with managed wild stands|~13,000–10,000 BCE|Levant (Natufian)|Younger Dryas climate pressure; abundant wild cereals
T3|D1|foraging|cereal cultivation (wheat, barley)|~9,500 BCE|Fertile Crescent|deliberate planting of selected wild grains
T4|D1|foraging|rice cultivation|~8,000 BCE|Yangtze River valley|wetland rice domestication
T5|D1|foraging|maize cultivation (from teosinte)|~7,000 BCE|Mesoamerica (Oaxaca/Balsas)|selective breeding of teosinte
T6|D1|foraging|potato and quinoa cultivation|~8,000 BCE|Andes|high-altitude crop domestication
T7|D1|foraging|millet and sorghum cultivation|~5,000 BCE|Sahel / Yellow River|independent domestication centers
T8|D1|wild animal hunting|sheep and goat domestication|~9,000 BCE|Fertile Crescent|managed herds from captured wild stock
T9|D1|wild animal hunting|cattle domestication|~8,000 BCE|Fertile Crescent / Sahara|aurochs tamed independently in at least two regions
T10|D1|no draft animals|horse domestication for riding and traction|~3,500 BCE|Pontic-Caspian steppe|Botai culture horse management
T11|D1|subsistence farming|surplus agriculture with irrigation|~5,500 BCE|Mesopotamia (Ubaid)|canal irrigation of alluvial soils
T12|D1|rain-fed agriculture|large-scale irrigation systems|~3,100 BCE|Egypt, Mesopotamia|state-organized canal and basin irrigation
T13|D1|manual farming|heavy plow agriculture|~500 CE|Northern Europe|moldboard plow enabled cultivation of heavy clay soils
T14|D1|two-field rotation|three-field crop rotation|~800 CE|Carolingian Europe|spring planting field added; yield increase ~50%
T15|D1|human/animal-powered farming|mechanized farming (seed drills, threshers)|~1700–1850 CE|Britain, North America|Jethro Tull seed drill 1701; mechanical reaper 1831
T16|D1|traditional crop varieties|high-yield dwarf varieties + synthetic fertilizer + irrigation|~1950–1970|Global (Mexico, India, Philippines first)|Borlaug's dwarf wheat; Haber-Bosch nitrogen fixation
T17|D1|conventional breeding|genetically modified crops|1994 CE|United States|Flavr Savr tomato first commercial GM crop; Bt crops follow
# Energy
T18|D2|metabolic energy only (human muscle)|controlled fire|~1,000,000–400,000 BCE|Africa, Eurasia|Homo erectus fire evidence; cooking unlocks calories
T19|D2|human muscle only|animal muscle (domesticated draft animals)|~4,000 BCE|Mesopotamia, Nile valley|oxen pulling plows and sledges
T20|D2|muscle power|wind power (sailing)|~5,000 BCE|Persian Gulf / Nile|reed-sail boats; wind as first non-biological energy
T21|D2|muscle and animal power|water mill|~300 BCE–100 CE|Mediterranean|vertical water wheel; grain milling
T22|D2|water mill|windmill|~900 CE|Persia; 1180 CE NW Europe|vertical-axis windmill Persia; post-mill Europe
T23|D2|biomass (wood, charcoal)|coal as primary fuel|~1700–1800 CE|Britain|deforestation pressure; accessible coal seams
T24|D2|coal burned directly|steam engine converts coal to mechanical work|1712 CE (Newcomen); 1769 CE (Watt)|Britain|Newcomen atmospheric engine; Watt separate condenser
T25|D2|stationary steam engines|mobile steam (railways, steamships)|1804 CE (Trevithick); 1807 CE (Fulton)|Britain, United States|high-pressure steam locomotive; steamboat
T26|D2|steam power|internal combustion engine (petroleum)|1876 CE (Otto); 1892 CE (Diesel)|Germany|four-stroke gasoline engine; compression-ignition diesel
T27|D2|no electricity generation|electrical grid (coal/hydro → electricity)|1882 CE|United States, Britain|Edison Pearl Street Station; AC systems follow
T28|D2|fossil fuels only|nuclear fission power|1951 CE (EBR-I); 1956 CE (Calder Hall)|United States, Britain|controlled chain reaction for electricity
T29|D2|fossil fuel dominance|solar photovoltaic and wind at grid scale|~2010–present|Global|silicon PV cost dropped ~90% 2010–2020; onshore wind cost dropped ~70%
# Materials
T30|D3|unworked stone and wood|knapped stone tools (Oldowan)|~3,300,000 BCE|East Africa|Lomekwian/Oldowan lithic industry
T31|D3|Oldowan choppers|Acheulean handaxes (bifacial symmetry)|~1,700,000 BCE|Africa, Eurasia|Homo erectus standardized tool forms
T32|D3|stone tools|bone, antler, and ivory tools added|~100,000–40,000 BCE|Africa, Europe|Upper Paleolithic toolkit diversification
T33|D3|stone|native copper (cold-hammered)|~9,000 BCE|Anatolia, Great Lakes|surface copper deposits worked without smelting
T34|D3|native copper|smelted copper|~5,500 BCE|Balkans, Anatolia|charcoal furnace temperatures reach copper melting point (~1,085°C)
T35|D3|copper|bronze (copper + tin alloy)|~3,300 BCE|Mesopotamia, Indus valley|tin alloying produces harder metal; edge retention improves
T36|D3|bronze|iron (smelted)|~1,200 BCE|Anatolia (Hittites), Levant|iron smelting at ~1,538°C; initially inferior to bronze but ore more abundant
T37|D3|wrought iron|steel (carbon-controlled iron)|~300 BCE (wootz); 1856 CE (Bessemer mass production)|India; Britain|crucible steel India; Bessemer converter enables cheap mass steel
T38|D3|natural materials only|cement and concrete|~3,000 BCE (lime morite); 1824 CE (Portland cement)|Levant; Britain|hydraulic cement; Aspdin patent
T39|D3|natural fibers only|synthetic polymers (plastics)|1907 CE (Bakelite); 1935 CE (nylon)|United States, Germany|Baekeland phenol-formaldehyde; Carothers polyamide
T40|D3|bulk materials|semiconductor materials (silicon, germanium)|1947 CE|United States|transistor at Bell Labs; silicon crystal growing
T41|D3|bulk metals|engineered composites (carbon fiber, Kevlar)|~1960–1970 CE|United States, Britain, Japan|aerospace demand for high strength-to-weight
# Social Organization
T42|D4|bands (15–50 individuals, kin-based, egalitarian)|tribes (150–1,500; lineage-based; informal hierarchy)|~50,000–10,000 BCE|Global|population growth beyond band scale
T43|D4|tribes|chiefdoms (1,000–10,000+; ranked hierarchy; redistribution economy)|~5,500 BCE|Mesopotamia, Mesoamerica, Polynesia|surplus agriculture enables permanent leadership
T44|D4|chiefdoms|states (centralized bureaucracy, codified law, taxation, standing army)|~3,100 BCE|Egypt (unification), Mesopotamia (Uruk)|irrigation management; surplus storage; writing for administration
T45|D4|independent city-states|territorial empires|~2,334 BCE (Akkadian); ~1,500 BCE (Egyptian New Kingdom)|Mesopotamia, Egypt|Sargon of Akkad unifies Sumerian city-states
T46|D4|empires governed by divine/personal authority|codified legal systems|~1,754 BCE (Hammurabi); ~450 BCE (Twelve Tables)|Mesopotamia; Rome|written law replaces customary/oral adjudication
T47|D4|monarchy as sole governance form|democratic assemblies (limited franchise)|~508 BCE (Cleisthenes)|Athens|Athenian male citizen assembly; excludes women, slaves, foreigners
T48|D4|feudal fragmentation|centralized monarchies|~1450–1650 CE|Western Europe|gunpowder makes castles obsolete; crown consolidates military monopoly
T49|D4|dynastic sovereignty|popular sovereignty / constitutional government|1688 CE (English); 1776 CE (American); 1789 CE (French)|Britain, United States, France|Glorious Revolution; Declaration of Independence; French Revolution
T50|D4|colonial empires|decolonization and independent nation-states|1947–1975 CE (peak)|Asia, Africa|Indian independence 1947; African decolonization wave 1960s
T51|D4|bipolar Cold War order|unipolar / multipolar order|1991 CE|Global|Soviet dissolution
# Information
T52|D5|no symbolic representation|symbolic marking (ochre, beads, cave art)|~100,000–40,000 BCE|Africa, Europe|Blombos Cave ochre ~100,000 BCE; Chauvet cave ~36,000 BCE
T53|D5|symbolic art only|token accounting systems (clay tokens)|~8,000 BCE|Mesopotamia|small clay shapes representing commodities for trade/storage tracking
T54|D5|tokens|proto-writing (cuneiform on clay tablets)|~3,400–3,100 BCE|Sumer (Uruk)|token impressions on clay envelopes evolve to incised signs
T55|D5|logographic proto-writing|full writing systems (logographic + phonetic)|~2,600 BCE|Sumer; Egypt (hieroglyphs ~3,200 BCE); China (~1,200 BCE Shang oracle bones)|rebus principle extends signs to represent sounds
T56|D5|logographic/syllabic scripts|alphabetic writing (~22–30 symbols)|~1,800 BCE (Proto-Sinaitic); ~1,050 BCE (Phoenician)|Sinai, Levant|one sign per consonant; vowels added by Greeks ~800 BCE
T57|D5|hand-copied manuscripts|movable-type printing|1040 CE (Bi Sheng, China); 1440 CE (Gutenberg, Europe)|China; Germany|ceramic type China; metal type + oil ink + screw press Europe
T58|D5|printing press|telegraph (electrical long-distance communication)|1837–1844 CE|Britain, United States|Cooke-Wheatstone; Morse code telegraph
T59|D5|telegraph|telephone (voice transmission)|1876 CE|United States|Bell patent; electrical voice encoding
T60|D5|wired communication|radio (wireless electromagnetic broadcast)|1895–1920 CE|Italy, United States|Marconi transmission; commercial broadcasting 1920s
T61|D5|radio|television (wireless image + sound broadcast)|1928–1936 CE|United States, Britain|Farnsworth electronic TV; BBC regular broadcasts 1936
T62|D5|analog broadcast media|digital computing|1945–1946 CE (ENIAC); 1971 CE (microprocessor)|United States|vacuum tube computer; Intel 4004 chip
T63|D5|mainframe computing|personal computing|1977–1981 CE|United States|Apple II 1977; IBM PC 1981
T64|D5|standalone computers|networked computing (internet)|1969 CE (ARPANET); 1991 CE (WWW)|United States; CERN|packet switching; Berners-Lee HTTP/HTML
T65|D5|desktop internet|mobile internet (smartphones)|2007 CE|Global|iPhone launch; mobile broadband proliferation
T66|D5|keyword search / curated content|large language models and generative AI|2017–2023 CE|Global|transformer architecture 2017; GPT series; commercial deployment 2022–2023
# Transport
T67|D6|walking|animal riding and pack transport|~4,000 BCE|Central Asia, Near East|domesticated donkey ~4,000 BCE; horse riding ~3,500 BCE
T68|D6|pack animals|wheeled vehicles|~3,500 BCE|Mesopotamia / Pontic steppe|solid wooden wheel; axle; ox-drawn carts
T69|D6|river rafts|plank-built sailing vessels|~3,000 BCE|Egypt, Mesopotamia|Nile cargo ships; Mediterranean trade vessels
T70|D6|coastal sailing|open-ocean navigation|~1000 CE (Polynesian); ~1420–1500 CE (European)|Pacific; Atlantic/Indian|Polynesian wayfinding; Portuguese caravel; compass, astrolabe
T71|D6|sailing ships|steamships|1807 CE (Fulton); 1840s transatlantic|United States, Britain|steam propulsion replaces wind dependence
T72|D6|animal-drawn land transport|railways|1825 CE (Stockton-Darlington); 1830 CE (Liverpool-Manchester)|Britain|steam locomotive on iron rail
T73|D6|horse-drawn vehicles|automobiles (internal combustion)|1886 CE (Benz); 1908 CE (Ford Model T mass production)|Germany; United States|gasoline engine; assembly line production
T74|D6|surface transport only|powered heavier-than-air flight|1903 CE|United States|Wright brothers Kitty Hawk
T75|D6|propeller aircraft|jet aircraft|1939 CE (He 178); 1952 CE (de Havilland Comet commercial)|Germany; Britain|turbojet engine; jet airliner service
T76|D6|atmospheric flight only|spaceflight|1957 CE (Sputnik); 1961 CE (Gagarin); 1969 CE (Apollo 11)|Soviet Union; United States|liquid-fuel rocketry; orbital insertion; lunar landing
T77|D6|petroleum-fueled vehicles|electric vehicles at mass market|~2017–present|Global|lithium-ion battery cost decline; Tesla Model 3; regulatory pressure
# Economy
T78|D7|gift/reciprocity economy|redistribution economy (centralized collection and allocation)|~5,500–3,100 BCE|Mesopotamia, Egypt|temple/palace granaries; surplus taxation
T79|D7|barter and redistribution|commodity money (grain, silver, cattle)|~3,000 BCE|Mesopotamia, Egypt|standardized weights of silver as unit of account
T80|D7|commodity money|coined money (stamped metal of guaranteed weight)|~600 BCE|Lydia (Anatolia)|electrum coins of Alyattes/Croesus
T81|D7|coined money only|paper money (promissory notes, banknotes)|~1000 CE (Song dynasty); 1694 CE (Bank of England)|China; Britain|jiaozi notes; government-backed banknotes
T82|D7|metallic/paper currency|fiat currency (no commodity backing)|1971 CE|United States / Global|Nixon ends dollar-gold convertibility; Bretton Woods collapses
T83|D7|manual production in guilds/households|factory system (centralized mechanized production)|~1760–1830 CE|Britain|water frame, spinning jenny, power loom concentrated in factories
T84|D7|mercantilism (state-directed trade for bullion accumulation)|free-trade capitalism (market-set prices, comparative advantage)|~1776–1846 CE|Britain|Adam Smith Wealth of Nations 1776; Corn Law repeal 1846
T85|D7|laissez-faire capitalism|mixed economies with state welfare and regulation|~1880–1945 CE|Germany, Britain, United States|Bismarck social insurance 1880s; New Deal 1933; Beveridge Report 1942
T86|D7|national economies with limited trade|globalized supply chains and capital flows|~1945–2000 CE|Global|Bretton Woods institutions; GATT/WTO; containerization 1956
T87|D7|physical cash and checks|electronic payments and digital banking|~1950–present|Global|credit cards 1950; ATMs 1967; online banking 1990s; mobile payments 2010s
T88|D7|centralized fiat currency only|cryptocurrency (decentralized digital ledger)|2009 CE|Global|Bitcoin whitepaper 2008; Genesis block January 2009
# Warfare
T89|D8|bare hands and thrown rocks|edged stone weapons (spears, axes)|~400,000 BCE|Africa, Europe|Schöningen spears ~300,000 BCE; hafted stone points
T90|D8|thrusting spears|projectile weapons (atlatl, bow and arrow)|~70,000–20,000 BCE|Africa; global by Upper Paleolithic|atlatl ~30,000 BCE; bow ~70,000–20,000 BCE
T91|D8|stone weapons|bronze weapons and armor|~3,000 BCE|Mesopotamia, Egypt|bronze swords, spearheads, helmets, shields
T92|D8|bronze weapons|iron weapons|~1,200–800 BCE|Anatolia, Levant, South Asia|iron ore more abundant; eventually surpasses bronze edge
T93|D8|infantry with edged weapons|cavalry as decisive arm|~900–500 BCE|Eurasian steppe; Assyria, Persia|horse breeding; mounted archers; stirrup ~300 CE amplifies
T94|D8|individual combat emphasis|disciplined infantry formations (phalanx, legion)|~700–300 BCE|Greece, Rome|hoplite phalanx; Roman manipular/cohort legion
T95|D8|muscle-powered weapons|gunpowder weapons (cannon, handguns)|~1280–1500 CE|China (invention ~850 CE); Europe (adoption ~1280 CE)|Chinese fire lance; European bombard; arquebus
T96|D8|smoothbore muskets and cannon|rifled firearms and artillery|~1850–1870 CE|Europe, United States|Minié ball; breech-loading rifles; rifled artillery
T97|D8|single-shot firearms|repeating and automatic firearms|1860–1884 CE|United States, Europe|Spencer repeater; Maxim machine gun 1884
T98|D8|conventional explosives|nuclear weapons|1945 CE|United States|Manhattan Project; Trinity test July 1945; Hiroshima/Nagasaki August 1945
T99|D8|human-piloted weapons only|guided missiles and drones|1944 CE (V-1/V-2); 2000s (armed UAVs)|Germany; United States|V-weapons; Predator/Reaper UAV strikes
T100|D8|kinetic warfare only|cyber warfare|~2007–present|Global|Estonia 2007; Stuxnet 2010; state-sponsored cyber operations
# Medicine
T101|D9|no medical treatment beyond wound licking|herbal medicine and trepanation|~10,000 BCE|Global|Neolithic trepanned skulls show healing; plant pharmacopeia
T102|D9|folk/religious healing|systematic medical observation (Hippocratic tradition)|~400 BCE|Greece|Hippocrates; naturalistic disease explanation; case records
T103|D9|humoral theory|anatomical study (dissection-based)|1543 CE|Europe|Vesalius De Humani Corporis Fabrica
T104|D9|no understanding of circulation|circulation of blood described|1628 CE|Britain|William Harvey De Motu Cordis
T105|D9|no immunization|vaccination (smallpox)|1796 CE|Britain|Edward Jenner cowpox inoculation
T106|D9|miasma theory of disease|germ theory of disease|1860s–1880s CE|France, Germany|Pasteur (fermentation, pasteurization); Koch (postulates, tuberculosis bacillus)
T107|D9|unsterilized surgery|antiseptic surgery|1867 CE|Britain|Joseph Lister carbolic acid
T108|D9|antiseptic technique|aseptic technique (sterilized environment)|~1890 CE|Germany|steam sterilization of instruments and gowns
T109|D9|no antibiotics|antibiotic therapy|1928 CE (discovery); 1942 CE (mass production)|Britain, United States|Fleming discovers penicillin; Florey and Chain develop production
T110|D9|no anesthesia|general anesthesia (ether, chloroform)|1846 CE|United States|Morton ether demonstration at Massachusetts General
T111|D9|no diagnostic imaging|X-ray imaging|1895 CE|Germany|Röntgen discovers X-rays
T112|D9|X-ray only|advanced imaging (CT, MRI, ultrasound)|1971 CE (CT); 1977 CE (MRI)|Britain, United States|Hounsfield CT scanner; Damadian/Lauterbur MRI
T113|D9|no organ replacement|organ transplantation|1954 CE (kidney); 1967 CE (heart)|United States; South Africa|Murray kidney transplant; Barnard heart transplant
T114|D9|no understanding of genetic basis|DNA structure and genetic medicine|1953 CE (structure); 2003 CE (Human Genome Project complete)|Britain, United States|Watson and Crick double helix; HGP sequencing
T115|D9|no gene editing|CRISPR-Cas9 gene editing|2012 CE|United States, Europe|Doudna and Charpentier demonstrate programmable gene editing
T116|D9|no mRNA therapeutics|mRNA vaccines|2020 CE|United States, Germany|BioNTech/Pfizer and Moderna COVID-19 vaccines
# Labor
T117|D11|all members forage; no specialization|craft specialization (potters, weavers, metallurgists)|~5,000–3,000 BCE|Mesopotamia, Egypt, Indus|surplus enables full-time non-food producers
T118|D11|free labor only|institutionalized slavery|~3,500 BCE|Mesopotamia, Egypt|war captives and debt bondage formalized
T119|D11|widespread slavery|abolition of chattel slavery|1807 CE (British trade); 1833 CE (British Empire); 1865 CE (US)|Britain, United States, global|abolitionist movements; British Slavery Abolition Act; US 13th Amendment
T120|D11|independent artisans|guild system (regulated craft production)|~1000–1200 CE|Europe, Islamic world|apprentice-journeyman-master hierarchy; quality/price control
T121|D11|guild-regulated craft|factory wage labor|~1760–1840 CE|Britain|factory system replaces cottage industry; hourly wage emerges
T122|D11|unregulated factory labor|labor regulation and unions|~1830–1900 CE|Britain, United States, Europe|Factory Acts; trade union legalization; collective bargaining
T123|D11|no child labor restrictions|child labor prohibition|1833 CE (Factory Act); 1938 CE (US Fair Labor Standards)|Britain; United States|minimum age laws; compulsory schooling
T124|D11|manual labor dominant|automation of physical tasks|~1913–1970 CE|United States, Japan|Ford assembly line 1913; industrial robots 1960s
T125|D11|human cognitive labor for routine tasks|AI automation of cognitive tasks|~2020–present|Global|LLMs and ML systems perform translation, coding, analysis, customer service
# Belief Systems
T126|D12|animism and shamanism|organized polytheistic religion with priesthood|~4,000–3,000 BCE|Mesopotamia, Egypt, Indus|temple institutions; codified ritual; professional priests
T127|D12|polytheism|ethical monotheism (Judaism)|~1,200–500 BCE|Levant|Mosaic covenant; Torah compilation; exclusive Yahweh worship
T128|D12|regional polytheisms|Axial Age philosophical/ethical systems|~800–200 BCE|India, China, Greece, Persia|Upanishads; Buddha; Confucius; Laozi; Socrates/Plato; Zoroaster
T129|D12|Judaism regional|Christianity spreads across Roman Empire|~30–380 CE|Mediterranean, Europe|Paul's missions; Constantine's Edict of Milan 313; Theodosius state religion 380
T130|D12|Arabian polytheism|Islam|622 CE (Hijra)|Arabia, then SW Asia, N Africa, SE Asia|Muhammad; Quran; rapid caliphal expansion
T131|D12|Catholic unity in Western Europe|Protestant Reformation|1517 CE|Europe|Luther's 95 Theses; printing press amplifies; Wars of Religion follow
T132|D12|religious authority over knowledge|secular Enlightenment rationalism|~1650–1800 CE|Europe|Descartes, Locke, Voltaire, Hume, Kant; reason as primary authority
T133|D12|church-state integration|secularization of governance|~1789–1900 CE|Europe, Americas|French Revolution laïcité; US First Amendment; gradual European disestablishment

# thresholds(id|name|date|description|consequence)
TH1|controlled fire|~1,000,000–400,000 BCE|sustained use of fire for cooking, warmth, protection|caloric unlock from cooked food; predator defense; social focal point; enabled range expansion
TH2|language|~100,000–50,000 BCE (behavioral evidence)|fully recursive symbolic language emerges|cumulative culture possible; planning; teaching; social coordination at scale
TH3|agriculture|~9,500 BCE|deliberate cultivation of cereal crops|sedentism; surplus; population growth; social stratification; all subsequent complexity depends on this
TH4|writing|~3,400–3,100 BCE|symbolic recording of language on durable medium|administration at scale; law; accumulated knowledge across generations; history begins
TH5|iron smelting|~1,200 BCE|smelting of iron ore into usable metal|cheaper tools and weapons than bronze; agricultural productivity leap; military democratization
TH6|printing|1440 CE|movable-type printing press in Europe|information cost drops by orders of magnitude; literacy spreads; Reformation; Scientific Revolution enabled
TH7|scientific method|~1543–1687 CE|empirical observation + mathematical modeling as standard for knowledge|self-correcting knowledge accumulation; basis for all subsequent technological acceleration
TH8|fossil fuel energy|~1712–1769 CE|coal → steam engine → mechanical work conversion|energy ceiling of biology broken; industrial production; urbanization; population explosion
TH9|germ theory|1860s–1880s CE|microorganisms identified as disease cause|sanitation, vaccination, antibiotics become rational; life expectancy doubles within century
TH10|electrification|1882 CE|electrical grid distributes energy remotely|decouples energy production from consumption site; enables all electronics; modern urban form
TH11|nuclear fission|1945 CE|controlled and uncontrolled nuclear chain reaction|existential military capability; energy source; geopolitical MAD equilibrium
TH12|digital computing|1945–1971 CE|programmable electronic computation and microprocessor|automation of information processing; all subsequent digital technology depends on this
TH13|internet|1969–1991 CE|global packet-switched computer network|near-zero marginal cost of information distribution; network effects at planetary scale
TH14|Haber-Bosch process|1909–1913 CE|industrial synthesis of ammonia from atmospheric nitrogen|synthetic fertilizer; supports ~50% of current world food production; enabled population above ~3 billion

# demographics(id|date|metric|value|region|notes)
DM1|~10,000 BCE|world population|~5,000,000–10,000,000|Global|pre-agricultural
DM2|~3,000 BCE|world population|~45,000,000|Global|early Bronze Age
DM3|1 CE|world population|~200,000,000–300,000,000|Global|Roman/Han peak
DM4|1340 CE|world population|~400,000,000|Global|pre-Black Death
DM5|1400 CE|world population|~350,000,000|Global|post-Black Death nadir
DM6|1500 CE|world population|~450,000,000–500,000,000|Global|pre-Columbian Exchange
DM7|1800 CE|world population|~1,000,000,000|Global|first billion; early industrialization
DM8|1900 CE|world population|~1,650,000,000|Global|industrial era
DM9|1928 CE|world population|~2,000,000,000|Global|second billion
DM10|1960 CE|world population|~3,000,000,000|Global|third billion
DM11|1975 CE|world population|~4,000,000,000|Global|Green Revolution era
DM12|1987 CE|world population|~5,000,000,000|Global|—
DM13|1999 CE|world population|~6,000,000,000|Global|—
DM14|2011 CE|world population|~7,000,000,000|Global|—
DM15|2022 CE|world population|~8,000,000,000|Global|—
DM16|1800 CE|urbanization rate|~3%|Global|vast majority rural
DM17|1900 CE|urbanization rate|~15%|Global|industrializing nations urbanizing rapidly
DM18|1950 CE|urbanization rate|~30%|Global|post-WWII urbanization wave
DM19|2007 CE|urbanization rate|~50%|Global|majority urban for first time in history
DM20|2025 CE|urbanization rate|~57%|Global|continuing trend
DM21|1800 CE|life expectancy at birth|~30–35 years|Global average|pre-germ-theory; high infant mortality dominates
DM22|1900 CE|life expectancy at birth|~31 years|Global average|improvement mainly in industrialized nations
DM23|1950 CE|life expectancy at birth|~47 years|Global average|antibiotics, sanitation, vaccination spreading
DM24|2000 CE|life expectancy at birth|~67 years|Global average|—
DM25|2020 CE|life expectancy at birth|~73 years|Global average|pre-COVID
DM26|1750 CE|share of global GDP|~25%|China|largest single economy pre-Great Divergence
DM27|1750 CE|share of global GDP|~23%|India|second largest pre-Great Divergence
DM28|1900 CE|share of global GDP|~24%|United States|post-industrialization American rise
DM29|1900 CE|share of global GDP|~11%|China|Qing decline
DM30|1492–1600 CE|indigenous American population decline|~50,000,000–90,000,000 → ~10,000,000|Americas|Old World diseases (smallpox, measles, influenza); greatest demographic catastrophe in recorded history

# relationships(from|rel|to)
# era sequence
E1|precedes|E2
E2|precedes|E3
E3|precedes|E4
E4|precedes|E5
E5|precedes|E6
E6|precedes|E7
E7|precedes|E8
E8|precedes|E9
E9|precedes|E10
E10|precedes|E11
E11|precedes|E12
# domain → transition membership
T1-T17|instance_of|D1
T18-T29|instance_of|D2
T30-T41|instance_of|D3
T42-T51|instance_of|D4
T52-T66|instance_of|D5
T67-T77|instance_of|D6
T78-T88|instance_of|D7
T89-T100|instance_of|D8
T101-T116|instance_of|D9
T117-T125|instance_of|D11
T126-T133|instance_of|D12
# transition causal chains — subsistence
T3|enables|T11
T11|enables|T12
T12|enables|C9
C9|enables|C10
C9|enables|T44
T15|enables|T16
T16|enables|DM11
T10|enables|T67
T10|enables|T93
# energy causal chains
T18|enables|T1
T19|enables|T11
T23|enables|T24
T24|enables|T25
T24|enables|T83
T24|enables|T72
T26|enables|T73
T27|enables|T62
T27|enables|T40
# materials causal chains
T30|enables|T1
T34|enables|T35
T35|enables|T91
T35|enables|E6
T36|enables|T92
T36|enables|E7
T37|enables|T72
T37|enables|T96
T40|enables|T62
T40|enables|T63
T39|enables|T41
# social organization causal chains
C9|enables|T42
T42|follows|T3
T43|requires|C9
T44|requires|TH4
T44|enables|T45
T45|enables|T46
T48|requires|T95
T49|follows|T132
T50|follows|T49
# information causal chains
T53|enables|T54
T54|enables|T55
T55|enables|T46
T56|enables|T57
T57|enables|T131
T57|enables|TH6
T58|enables|T59
T59|enables|T60
T62|enables|T63
T63|enables|T64
T64|enables|T65
T65|enables|T66
# transport causal chains
T68|requires|T10
T70|enables|C17
T72|requires|T24
T73|requires|T26
T74|enables|T75
T75|enables|T76
# economy causal chains
C9|enables|T78
T78|enables|T79
T79|enables|T80
T80|enables|T81
T81|enables|T82
T83|requires|T24
T84|follows|T83
T86|requires|T75
T86|requires|T64
# warfare causal chains
T89|precedes|T90
T90|precedes|T91
T91|precedes|T92
T92|precedes|T93
T95|enables|T48
T96|precedes|T97
T97|precedes|T98
T99|requires|T62
T100|requires|T64
# medicine causal chains
T102|precedes|T103
T103|enables|T104
T105|precedes|T106
T106|enables|T107
T106|enables|TH9
T107|enables|T108
T109|requires|T106
T111|enables|T112
T114|enables|T115
T115|enables|T116
# labor causal chains
C9|enables|T117
T117|enables|C10
T118|enables|T44
T119|follows|T49
T121|requires|T83
T122|follows|T121
T124|requires|T27
T125|requires|T66
# belief causal chains
T126|requires|C9
T127|precedes|T129
T128|instance_of|C3
T129|enables|T131
T131|requires|T57
T132|follows|T131
T133|follows|T132
# threshold dependencies
TH1|enables|T1
TH2|enables|T42
TH2|enables|C26
TH3|enables|C9
TH3|enables|E5
TH4|enables|T44
TH4|enables|T46
TH5|enables|E7
TH6|enables|C4
TH6|enables|T131
TH7|enables|C5
TH7|enables|TH9
TH8|enables|C5
TH8|enables|T83
TH8|enables|T72
TH9|enables|T109
TH9|enables|DM23
TH10|enables|T62
TH10|enables|T61
TH11|enables|T51
TH12|enables|C7
TH12|enables|T63
TH13|enables|T65
TH13|enables|T86
TH14|enables|T16
TH14|enables|DM10
# concept mechanisms
C8|determined_by|C5
C11|enables|T64
C12|enables|C14
C12|enables|C15
C13|determined_by|C23
C13|prevents|DM7
TH8|prevents|C13
C24|enables|C18
C25|enables|T3
C26|requires|TH2
C26|enables|TH7
# collapse causes and effects
C14|follows|E6
C14|causes|T36
C15|causes|E9
C16|causes|DM5
C17|follows|T70
C17|causes|DM30
C18|requires|TH8

# section_index(section|title|ids)
1|Domains|D1-D12
2|Eras|E1-E12
3|Concepts and Mechanisms|C1-C26
4.1|Transitions: Subsistence|T1-T17
4.2|Transitions: Energy|T18-T29
4.3|Transitions: Materials|T30-T41
4.4|Transitions: Social Organization|T42-T51
4.5|Transitions: Information|T52-T66
4.6|Transitions: Transport|T67-T77
4.7|Transitions: Economy|T78-T88
4.8|Transitions: Warfare|T89-T100
4.9|Transitions: Medicine|T101-T116
4.10|Transitions: Labor|T117-T125
4.11|Transitions: Belief Systems|T126-T133
5|Thresholds|TH1-TH14
6|Demographics|DM1-DM30
7|Relationships|all

# decode_legend
id_prefixes: T=transition, D=domain, E=era, TH=threshold, C=concept, DM=demographic
rel_types: enables|requires|prevents|specializes|generalizes|part_of|contains|follows|precedes|instance_of|determined_by|causes|composed_of|transforms_to|depends_on|equivalent_to|extends|validates
notation: ~=approximate date; fk=foreign key reference; range X1-X17 expands to individual IDs; comma-separated to-field expands to multiple rules; BCE=Before Common Era; CE=Common Era
confidence: demographic values are estimates with uncertainty increasing with antiquity; transition dates are approximate where prefixed with ~; all facts asserted at reference_history confidence level
scope: global human history ~3,300,000 BCE to ~2025 CE; mechanical state-transitions only; no political interpretation; no normative framing

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
causes|causes|exact match
composed_of|composed_of|exact match
transforms_to|transforms_to|exact match
depends_on|depends_on|exact match
equivalent_to|equivalent_to|exact match
extends|extends|exact match
validates|validates|exact match
