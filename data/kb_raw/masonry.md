# MASONRY — CONSTRUCTION KNOWLEDGE — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: unit_types → stone_types → brick_types → mortar_types → bond_patterns → joint_profiles → wall_types → arch_construction → reinforcement → tools → techniques → defects → rules → relationships → section_index
# Cross-references: AT=arch_type, EL=element, SS=structural_system, VZ=vertical_zone from ARCHITECTURE compaction

# unit_types(id|type|material|dimensions|weight_class|manufacture|notes)
UT1|common brick|fired clay|215×102.5×65mm (UK standard), 194×92×57mm (US modular)|~2.2kg each|kiln-fired from clay/shale|workhorse unit, not selected for face appearance
UT2|facing brick|fired clay|same as common|~2.2kg|kiln-fired, controlled color/texture|exposed face, selected for appearance
UT3|engineering brick|fired clay|same as common|~2.5kg|high-temperature firing, dense body|Class A (>70 N/mm²) or Class B (>50 N/mm²), low porosity, damp-proof courses
UT4|firebrick/refractory|refractory clay|230×114×64mm typical|~2.8kg|fired above 1300°C|fireplaces, kilns, flues — withstands sustained heat
UT5|clinker brick|over-fired clay|irregular|~2.5kg|kiln waste, partially vitrified|dark, distorted, very hard — used decoratively or for paving
UT6|sand-lime/calcium silicate brick|sand + lime|same as common|~2.4kg|autoclaved, not kiln-fired|precise dimensions, uniform color, lower thermal mass than clay
UT7|concrete block (hollow)|concrete|440×215×100-215mm (UK)|10-20kg depending on width|cast and cured|cores allow rebar/grout, structural or infill
UT8|concrete block (solid)|concrete|same dimensions|15-25kg|cast and cured|higher compression, used where cores not needed
UT9|aerated/autoclaved concrete block (AAC)|cement + aluminum powder + sand|440×215×100-215mm|~50% weight of concrete block|autoclaved with gas expansion|lightweight, insulating, easy to cut, low compressive strength
UT10|ashlar stone|natural stone, dressed|variable, coursed to uniform height|heavy — density varies by stone type|quarried, sawn, dressed to flat faces|finest stonework — tight joints, smooth or textured face
UT11|rubble stone|natural stone, rough|irregular|heavy|quarried or field-gathered, minimal dressing|random or coursed rubble, thick mortar joints
UT12|dimension stone|natural stone, sawn to spec|cut to specified dimensions|heavy|quarried and sawn|cladding, sills, lintels, copings
UT13|adobe|unbaked earth + straw|variable, typically 250×120×75mm|~3kg|sun-dried in molds|ancient, arid climates, poor water resistance
UT14|compressed earth block (CEB)|earth + small cement %|similar to concrete block|~7kg|hydraulic press, cured|modern refinement of adobe, better dimensional control
UT15|glass block|cast glass|190×190×80mm typical|~2.5kg|two halves fused|translucent, non-load-bearing, decorative
UT16|cob|monolithic earth + straw|not unit-based — built in lifts|n/a|hand-formed wet, dried in place|no formwork, sculptural, thick walls
UT17|flint|knapped or whole flint nodule|irregular|~0.3-1kg per nodule|gathered, split or knapped|used with brick or stone dressings, East Anglia and chalk regions
UT18|terracotta block|fired clay, hollow|larger than brick, variable|lighter than solid brick|extruded and fired|ornamental cladding, fireproofing, cornices — not load-bearing

# stone_types(id|type|geological_class|hardness|workability|durability|typical_use)
ST1|granite|igneous|very hard (6-7 Mohs)|difficult — requires carbide/diamond tools|excellent — resists weathering and pollution|foundations, plinths, curbstones, monuments
ST2|limestone|sedimentary|soft to medium (3-4 Mohs)|good — saws and carves well|variable — some vulnerable to acid rain|ashlar walls, carving, Gothic cathedrals (eg Caen, Portland, Bath)
ST3|sandstone|sedimentary|medium (variable)|good — saws well, some friable|variable — depends on binder (silica best, calcite worst)|ashlar, rubble, brownstone facades, Scottish/Northern English tradition
ST4|marble|metamorphic (recrystallized limestone)|medium (3-4 Mohs)|excellent carving stone|poor outdoors in polluted/freeze climates — sugaring|sculpture, interior cladding, classical temples
ST5|slate|metamorphic|medium-hard|cleaves easily along foliation, difficult across|excellent — low porosity, acid resistant|roofing, damp-proof courses, flooring, cladding
ST6|basalt|igneous|very hard (6 Mohs)|very difficult|excellent|paving, foundations, rubble walls
ST7|travertine|sedimentary (chemical precipitate)|medium (3-4 Mohs)|good — saws well|moderate — porous, needs sealing outdoors|cladding, flooring, Roman construction (Colosseum)
ST8|flint|sedimentary (silica nodule)|very hard (7 Mohs)|knapped — cannot be sawn traditionally|excellent|wall infill with dressed stone or brick surrounds
ST9|tufa/tuff|volcanic|soft (2-3 Mohs)|very easy to cut|moderate — lightweight but porous|Roman concrete aggregate, lightweight walls
ST10|gneiss|metamorphic|hard (6-7 Mohs)|difficult — uneven fracture|excellent|rubble walls, foundations, northern/mountain regions
ST11|chalk|sedimentary|very soft (1-2 Mohs)|extremely easy to cut when freshly quarried|poor — erodes rapidly outdoors|interior walls (clunch), underground structures, lime production feedstock

# brick_types(id|type|firing|color_range|compressive_strength|use)
BK1|common/building|standard (~1000°C)|variable, often irregular|15-30 N/mm²|internal walls, backing, hidden work
BK2|facing (wirecut)|standard, controlled atmosphere|uniform — buff, red, brown, grey|20-40 N/mm²|exposed external walls, consistent texture
BK3|facing (handmade)|standard|variable, creased/folded face|15-35 N/mm²|exposed work, traditional/heritage appearance
BK4|facing (stock)|standard, with added material for color|London yellow, red, grey|15-30 N/mm²|regional character — London, Kent
BK5|engineering Class A|high (~1200°C+)|dark red to blue|>70 N/mm², water absorption <4.5%|damp-proof courses, manholes, retaining walls, high-load
BK6|engineering Class B|high|red to dark red|>50 N/mm², water absorption <7%|damp-proof courses, below-grade, moderate exposure
BK7|firebrick|very high (~1300-1500°C)|pale yellow to white|variable — selected for thermal resistance not compression|fireplaces, kilns, flue linings, furnaces
BK8|perforated|standard|variable|20-40 N/mm²|reduces weight, improves mortar key, standard in many countries
BK9|frogged|standard|variable|15-35 N/mm²|frog provides mortar key — laid frog-up for structural, frog-down for speed
BK10|bull-nose|standard, special shape|matches facing range|same as parent type|rounded edge — external corners, sills, copings
BK11|closer (queen/king)|cut or molded to half/quarter width|matches parent|same as parent|closes bond at quoins and jambs — essential for pattern integrity
BK12|air brick|standard, perforated through|matches facing range|non-structural|ventilation through walls — sub-floor voids, cavity ventilation
BK13|glazed brick|standard + glaze firing|wide color range, glossy|20-40 N/mm²|hygienic surfaces — tunnels, dairies, public toilets, decorative
BK14|clinker|over-fired, distorted|dark purple/brown/black|very high — partially vitrified|paving, decorative — valued for irregular character

# mortar_types(id|type|composition|strength|flexibility|period|use)
MO1|fat lime (non-hydraulic)|putty lime (Ca(OH)₂) + sand (1:3)|very low (0.5-1 N/mm²)|very high — accommodates movement|ancient to 19th c|heritage work, soft masonry — sets by carbonation with CO₂, very slow
MO2|natural hydraulic lime NHL 2|hydraulic lime + sand (1:2.5-3)|low (1-2 N/mm²)|high|medieval onward (natural deposits)|conservation, soft stone, damp environments — sets by hydration + carbonation
MO3|natural hydraulic lime NHL 3.5|hydraulic lime + sand (1:2.5-3)|moderate (2-4 N/mm²)|moderate-high|medieval onward|general heritage, moderate-strength masonry
MO4|natural hydraulic lime NHL 5|hydraulic lime + sand (1:2-2.5)|moderate-high (4-7 N/mm²)|moderate|medieval onward|engineering applications in heritage, harder stone
MO5|Portland cement : lime : sand (Type N)|1:1:6 OPC:lime:sand|moderate (5-7 N/mm²)|moderate|20th c onward|general purpose above-grade, most residential
MO6|Portland cement : lime : sand (Type S)|1:0.5:4.5|moderate-high (8-12 N/mm²)|low-moderate|20th c onward|below-grade, retaining walls, moderate structural
MO7|Portland cement : lime : sand (Type M)|1:0.25:3.5|high (12-17 N/mm²)|low|20th c onward|foundations, high-load, below-grade, engineering
MO8|Portland cement : lime : sand (Type O)|1:2:9|low (2-4 N/mm²)|high|20th c onward|non-load-bearing interior partitions
MO9|Portland cement : sand (Type K/no lime)|1:3-4 OPC:sand|very high (15-20 N/mm²)|very low — rigid, brittle|20th c|avoid in masonry — too hard for most units, causes spalling
MO10|Roman/pozzolanic|lime + volcanic ash (pozzolan) + sand|moderate — gains strength slowly|moderate|Roman, 3rd c BCE onward|hydraulic set without Portland cement, underwater work, heritage
MO11|gauged lime|fat lime + fine silver sand, thin joints (1-2mm)|low|very high|17th-19th c|rubbed and gauged brickwork — precision joints, high craft
MO12|refractory morite|calcium aluminate cement + firecite clay + sand|high thermal resistance|low|modern|firebrick joints, kiln lining

# bond_patterns(id|pattern|description|structural_value|appearance|thickness)
BP1|stretcher/running bond|all stretchers, each course offset half|single-wythe only — no through-bonding|simple, uniform, modern|half-brick (102.5mm)
BP2|English bond|alternating courses of all headers and all stretchers|excellent — full through-bonding every other course|strong horizontal lines, alternating texture|one brick (215mm) minimum
BP3|Flemish bond|alternating headers and stretchers in every course|good — through-bonding in every course but less than English|decorative, rhythmic, classical|one brick (215mm) minimum
BP4|English garden wall|3 stretcher courses to 1 header course|moderate — headers every 4th course|economical on headers, less decorative|one brick minimum
BP5|Flemish garden wall (Sussex)|3 stretchers to 1 header in each course|moderate|more stretcher-dominated than true Flemish|one brick minimum
BP6|header bond|all headers in every course|excellent through-bonding|uniform small rectangles, curves well|one brick minimum
BP7|stack bond|units aligned vertically — no offset|zero — continuous vertical joints, structurally poor|modern, graphic, grid pattern|any — requires reinforcement
BP8|herringbone|units at 45° in alternating directions|moderate — interlocking but complex|decorative diagonal pattern|infill panels, paving, Roman opus spicatum
BP9|rat-trap bond|bricks laid on edge with cavity between|moderate — through-bonding with headers on edge|similar to Flemish from face|one brick — 33% material saving, insulating cavity
BP10|monk bond|2 stretchers then 1 header per course|moderate|subtler rhythm than Flemish|one brick minimum
BP11|Dearne's bond|header-stretcher alternation like Flemish but header centered over stretcher below|moderate|similar to Flemish, different alignment|one brick minimum
BP12|random rubble|uncoursed irregular stones bedded in thick mortar|moderate if done well — relies on through-stones|rustic, textured|300-600mm — depends on stone
BP13|coursed rubble|irregular stones roughly leveled to courses|better than random — courses provide horizontal planes|semi-regular, rustic|300-600mm
BP14|ashlar|dressed stone, tight joints, coursed|excellent — precision-cut, minimal mortar|formal, refined, smooth or textured face|variable — 200-600mm
BP15|polygonal/cyclopean|large irregular stones fitted without mortar or minimal mortar|excellent — massive weight resists movement|prehistoric/monumental — Inca, Mycenaean|600mm+
BP16|opus reticulatum|small square stones set diagonally in diamond pattern over concrete core|good — concrete core is structural, facing is cladding|distinctive diagonal grid|Roman — facing over opus caementicium

# joint_profiles(id|profile|description|weather_resistance|appearance)
JP1|flush/flat|mortar cut level with wall face|moderate — no ledge for water but no compression|neutral, minimally visible
JP2|bucket handle/concave|curved inward with jointing tool|excellent — compresses mortar, sheds water, no ledge|most common modern joint, shadow line
JP3|weathered/struck|angled inward from top to bottom, top recessed|good — sheds water downward off joint face|moderate shadow, slight recession at top
JP4|recessed/raked|mortar cut back from face by 5-10mm|poor — creates ledge collecting water, exposes unit edges|deep shadow, emphasizes unit shape — interior or sheltered only
JP5|V-joint|pointed V-shape pressed into mortar|good — sheds water both sides, compresses mortar|strong shadow line, crisp pattern
JP6|beaded|raised half-round bead projecting from joint|poor — bead vulnerable to frost damage|decorative, period appearance — interior preferred
JP7|grapevine|thin indented line impressed in center of flush joint|moderate — essentially flush with texture|colonial American aesthetic, subtle
JP8|extruded/squeezed|excess mortar left unfinished as squeezed from joints|poor — irregular surface traps water|rustic, deliberately rough
JP9|ribbon/raised|mortar projects beyond face|very poor — water trapped behind projection, frost-vulnerable|avoid except interior — common 19th c error, debonding failure
JP10|tuck pointing|contrasting thin lime putty ribbon centered in wider joint of colored mortar|moderate — depends on maintenance|creates illusion of fine joints in rough brickwork — high craft

# wall_types(id|type|construction|structural_role|thickness|notes)
WT1|solid single-wythe|one unit thick, stretcher bond|non-load-bearing partition or veneer backing|102.5mm (half-brick)|no through-bonding — requires ties if combined
WT2|solid one-brick|two wythes bonded with headers (English/Flemish)|load-bearing, low-rise|215mm|minimum for structural external wall
WT3|solid one-and-a-half brick|three wythes bonded|load-bearing, thicker wall for greater height|327.5mm|heavy, good thermal mass, older construction
WT4|solid two-brick|four wythes bonded|heavy load-bearing, foundations, retaining|440mm|maximum common solid wall — pre-20th c institutional/industrial
WT5|cavity wall|two wythes separated by 50-100mm air gap, connected by wall ties|outer wythe weathering, inner wythe structural or both structural|250-300mm total|standard modern UK/European — cavity prevents moisture bridging
WT6|cavity wall (insulated)|cavity wall with insulation in gap — full-fill or partial-fill|same as WT5 plus thermal performance|270-350mm total|current standard — insulation type affects moisture management
WT7|veneer wall|single-wythe facing over structural frame (steel/timber/concrete)|decorative only — no structural role, self-weight + wind only|102.5mm facing + gap + structure|common North American — ties to backing, shelf angles at floors
WT8|collar-jointed wall|two wythes with filled mortar joint between (no cavity)|load-bearing if grouted — wythes act compositely|variable|requires careful grouting — voids reduce capacity
WT9|grouted/reinforced masonry|hollow block with rebar in grouted cores|structural — acts as reinforced masonry column/wall|200-300mm block|seismic regions, high-load, retaining walls
WT10|diaphragm wall|two wythes connected by perpendicular masonry ribs|structural — ribs create I-beam action, very stiff|wide — 400-800mm overall|sports halls, industrial — long spans without buttresses
WT11|gabion wall|wire cages filled with stone|retaining, landscaping, erosion control|500-1000mm|not mortared — free-draining, flexible, rapid construction
WT12|dry stone wall|stone stacked without mortar|retaining, field boundary, low-height structural|400-900mm, battered (wider at base)|through-stones every 1m height, coping stones on top — ancient tradition
WT13|rammed earth wall|compacted earth in formwork|load-bearing, thermal mass|300-600mm|ancient method — modern versions add cement, built in lifts
WT14|cob wall|monolithic earth-straw mix|load-bearing, low-rise|400-600mm|no formwork — hand-built in lifts, rounded forms
WT15|composite wall|masonry outer + concrete/timber/steel inner structure|combined — each material contributes differently|variable|modern hybrid — masonry provides weather/fire/appearance, frame provides structure

# arch_construction(id|element|role|description|rules)
AC1|centering|temporary support|timber frame shaped to arch intrados — carries voussoirs until keystone placed and mortar cured|must be rigid enough to hold full arch weight without deflection
AC2|formwork/lagging|surface on centering|boards or sheet over centering ribs providing continuous curved surface|tight fit to centering ribs, defines intrados profile
AC3|springer/skewback|first voussoir|set on impost at spring line, angle matches arch curve at base|must be level, firmly bedded, angle cut precisely to design geometry
AC4|voussoir laying|construction sequence|voussoirs laid simultaneously from both springers toward crown|symmetric loading prevents centering tilt — never build one side ahead
AC5|keystone insertion|completion|final central voussoir wedged into place, locks arch in compression|arch is not structural until keystone is placed — centering carries all load before this
AC6|striking (decentering)|centering removal|centering eased down gradually after mortar reaches sufficient strength|too early = arch collapse; too sudden = shock loading — ease uniformly, never drop
AC7|back-filling/haunching|load stabilization|masonry or concrete fill between arch extrados and horizontal structure above|fills spandrel, prevents arch rocking, distributes live load to arch
AC8|ring thickness|structural dimensioning|depth of voussoir measured radially — determines arch structural capacity|rule of thumb: ring ≥ span/20 for semicircular, deeper for flat or segmental
AC9|mortar joints in arch|joint geometry|joints radial — perpendicular to curve at every point, tapering toward intrados|parallel joints (non-radial) create slip planes — arch will fail
AC10|skewback angle|geometry|angle of bed at springer, measured from horizontal|semicircular = 0° (horizontal bed), segmental = angle increases with flatness
AC11|centering striking sequence (multi-arch)|staged removal|for multiple arches in series, strike center arch first, then alternating outward|prevents asymmetric thrust on intermediate piers
AC12|arch abutment sizing|structural design|abutment mass must resist horizontal thrust without sliding or overturning|rule of thumb: abutment width ≥ span/3 for semicircular; more for flatter arches

# reinforcement(id|type|material|location|purpose|notes)
RE1|wall tie|stainless steel or galvanized steel wire|across cavity between wythes|connects wythes so they act together for lateral loads|spacing: typically 900mm horizontal, 450mm vertical — staggered
RE2|bed joint reinforcement|stainless steel ladder or truss type|embedded in horizontal mortar joints|crack control, spans over openings when designed, distributes stress|typically every 3rd-6th course in crack-prone areas
RE3|vertical rebar|steel reinforcing bar|in grouted cores of hollow block|provides tensile/flexural capacity — seismic resistance|cores grouted solid around bars — lapped at splices
RE4|horizontal bond beam|U-block or cut block filled with rebar and grout|horizontal course, typically at floor/roof level and mid-height|ties wall together horizontally, distributes point loads|acts as ring beam in seismic design
RE5|steel lintel|galvanized steel angle or channel|above openings|carries masonry above opening in bending|sizing: depth ≥ span/12, bearing ≥ 150mm each end
RE6|precast concrete lintel|reinforced concrete beam|above openings|same as steel lintel — carries masonry above|bearing ≥ 150mm, must match coursing height
RE7|stone lintel|single stone spanning opening|above openings|compression on top, tension on bottom — stone weak in tension|limited span — ~1.5m for most stone, must be deep relative to span
RE8|relieving arch|masonry arch built within wall above lintel|above opening, within wall thickness|diverts wall load around opening, reduces lintel load|arch must be properly abutted within wall — see AT15
RE9|damp-proof course (DPC)|engineering brick, slate, bitumen felt, or polymer|horizontal layer minimum 150mm above ground level|prevents rising moisture from ground entering wall above|must be continuous, lapped at joints, not bridged by mortar droppings
RE10|movement joint|compressible sealant in full-height gap|vertical at intervals (typ 10-12m clay, 6m concrete block)|allows thermal/moisture expansion without cracking|filled with flexible sealant, never mortared — coincide with structural breaks
RE11|anchor/strap|metal strap or bolt|connecting wall to floor/roof structure|prevents wall overturning, transfers lateral load to diaphragm|critical in seismic and high-wind zones — spacing per engineering
RE12|post-tensioning rod|high-strength steel rod|vertical through grouted core, anchored at foundation and wall top|compresses wall — greatly increases lateral resistance|used in thin tall walls, wind-loaded panels, seismic retrofit
RE13|helical bar|stainless steel helix|drilled into existing mortar joints|stitches cracks, reinforces existing walls, retro-fit bed joint reinforcement|bonded with cementitious grout — conservation and retrofit use

# tools(id|tool|function|stage)
TL1|trowel (brick)|picks up mortar from board, spreads on bed and perpend joints, taps units level|laying
TL2|trowel (pointing)|smaller trowel for pushing mortar into joints during repointing|pointing/repointing
TL3|hawk|flat plate with handle — holds mortar close to work|laying, pointing
TL4|spirit level|checks horizontal (level) and vertical (plumb) alignment|laying — checked every few courses and at every corner
TL5|line and pins|string stretched between corners to guide course alignment|laying — set at each course height
TL6|gauge rod/story pole|marked rod showing course heights including joints|laying — ensures consistent coursing over entire wall height
TL7|jointer/striker|shaped metal tool pressed along fresh joints to form profile|jointing — used while mortar is thumbprint-firm
TL8|bolster chisel|wide flat chisel for cutting bricks|cutting — struck with club hammer
TL9|club hammer|short heavy hammer used with bolster or cold chisel|cutting
TL10|mason's hammer|double-ended — one flat face, one chisel edge|stone dressing, rough cutting
TL11|scutch hammer|hammer with replaceable comb blades|texturing and trimming brick or stone faces
TL12|angle grinder/masonry saw|power tool with diamond blade|precision cutting — mitres, specials, chases
TL13|corner blocks|L-shaped blocks clamped to completed corners to hold line|laying — maintain straight courses between built corners
TL14|plumb bob|weighted string for true vertical|laying — checks face of wall and corners for plumb
TL15|tape measure|measurement|all stages
TL16|brick tongs|spring clamp carrying 6-10 bricks|material handling
TL17|mixing paddle/mixer|mechanical mortar mixing|preparation
TL18|cold chisel|narrow chisel for chasing and fine removal|cutting, chasing
TL19|plugging chisel|tapered chisel for removing old mortar from joints|repointing preparation
TL20|mortar gun|caulking-style gun for injecting mortar into joints|repointing — especially deep joints
TL21|banker|heavy stone slab or bench for stone dressing|stone preparation — stable flat surface for chisel work
TL22|pitcher/point chisel|pointed chisel for rough stone dressing — primary waste removal|stone dressing — first tool used on rough block
TL23|claw chisel|toothed chisel for intermediate stone dressing|stone dressing — after pitcher, before flat chisel
TL24|flat/drove chisel|wide flat chisel for final stone surface|stone dressing — final flat surface, tool marks may be left as finish

# techniques(id|technique|description|when_used|skill_level)
TQ1|setting out|marking wall position on slab/foundation using line, chalk, and dimensions from drawings|before any laying — first operation|fundamental
TQ2|dry bonding|laying first course without mortar to check bond, cuts, and openings|before mortared first course|fundamental
TQ3|laying to line|spreading bed mortar, placing unit, tapping level and plumb, checking against string line|every course|fundamental
TQ4|building corners first|raising corners (racking back) 4-5 courses ahead, then infilling between corners to line|every wall section — corners establish alignment and gauge|core skill
TQ5|racking back|stepping corners back one half-unit per course as corner rises|during corner building — allows toothing into future work|core skill
TQ6|toothing|leaving projecting units at wall end for future bonding connection|where wall will be extended or intersected later|core skill
TQ7|buttering perpends|applying mortar to end of unit before placing — forms vertical joint|every unit except first in course|fundamental
TQ8|furrowing|drawing trowel point along center of bed mortar to create groove|bed joints — distributes mortar to edges, not universally approved — some specs forbid|variable — forbidden in structural/engineering work (creates void)
TQ9|jointing|forming joint profile while mortar is still fresh (part of laying process)|during laying — mortar at thumbprint firmness|fundamental
TQ10|pointing|raking out joints and filling with fresh mortar — separate operation from laying|after laying — sometimes years later during maintenance|moderate
TQ11|repointing|removing old mortar to depth of 2-2.5× joint width, filling with new mortar|maintenance/repair — mortar is sacrificial, replaced before units|moderate-high — mortar selection critical
TQ12|tuck pointing|filling joints with mortar colored to match brick, then pressing thin ribbon of lime putty in center|decorative — creates illusion of very fine joints on rough brickwork|high craft
TQ13|rubbed and gauged work|soft bricks rubbed to exact size on stone, laid with thin lime putty joints (1-2mm)|finest brickwork — arches, decorative panels, 17th-19th c|highest craft — joints nearly invisible
TQ14|cutting in|cutting bricks to fit around obstacles, services, openings|throughout construction|fundamental
TQ15|fair-faced work|laying with consistent joints and clean face — no plastering intended|exposed walls — requires higher skill than covered work|moderate-high
TQ16|bagging/bag rubbing|rubbing damp hessian over fresh joints and face to fill pinholes and even color|after initial set — decorative/protective finish|moderate
TQ17|damp-proof course laying|bedding DPC material on mortar, lapping joints 100mm minimum, no punctures|at designated levels — 150mm minimum above ground|fundamental — error causes rising damp
TQ18|cavity wall construction|building both wythes simultaneously, placing ties as courses rise, keeping cavity clean|modern cavity walls — droppings caught on cavity battens|moderate — cleanliness critical
TQ19|grouting cores|pouring fluid grout into hollow block cores around rebar|reinforced masonry — lifts of max 1.2m, vibrated|moderate — voids reduce structural capacity
TQ20|stone dressing|shaping stone with pitcher → claw → flat chisel sequence, finishing face to specification|before laying — stone prepared on banker|high craft
TQ21|lime washing/limewash|applying thin lime paint to masonry face|traditional finish — breathable, antifungal, renewable|fundamental
TQ22|flaunching|applying mortar slope on top of chimney pots and copings to shed water|chimney and coping completion|fundamental

# defects(id|defect|cause|indicator|severity|repair)
DF1|efflorescence|soluble salts migrating to surface and crystallizing as moisture evaporates|white powder/crystal deposits on face|cosmetic (primary) — can indicate persistent moisture source|dry brush first year — if persistent, investigate moisture source
DF2|spalling|moisture trapped in unit freezing and expanding, popping face off|flaking, delamination of brick/stone face|moderate to severe — exposes core to accelerated decay|replace spalled units, investigate water entry, avoid hard repointing
DF3|frost damage|water in saturated masonry expanding on freezing|crumbling mortar, fractured units, displaced copings|severe if structural — progressive|repoint, replace damaged units, improve drainage/DPC
DF4|sulfate attack|sulfates in clay brick dissolving in water and reacting with Portland cement mortar|white expansion deposits, mortar swelling, horizontal cracking|severe — mortar expansion cracks wall|use sulfate-resisting cement, improve drainage, replace mortar in severe cases
DF5|rising damp|ground moisture ascending by capillary action through masonry lacking/bridged DPC|tide mark at ~1m height, salt deposits, damp plaster, musty smell|moderate — damages finishes, degrades mortar over decades|install/repair DPC, do not bridge with render or soil — misdiagnosis very common
DF6|penetrating damp|rainwater entering through wall — cracked mortar, failed sealant, porous stone|damp patches on interior corresponding to external exposure|moderate|repoint, seal, improve drainage details, check window/door junctions
DF7|cracking (vertical)|differential settlement, thermal movement, shrinkage|straight or stepped vertical cracks, often at openings or changes in load|variable — may be cosmetic or structural|monitor first — if progressive: underpin, install movement joints, stitch with helical bars
DF8|cracking (horizontal)|lateral pressure (earth behind wall), sulfate expansion, slab thrust|horizontal crack along mortar bed line|potentially severe — wall may bow|relieve pressure source, install ties, rebuild if displaced
DF9|cracking (stepped diagonal)|differential settlement — follows mortar joints in stair-step pattern|crack steps along bed and perpend joints diagonally|moderate to severe — indicates foundation movement|underpin foundation, stitch crack with helical bars, repoint
DF10|bulging/bowing|wall tie failure (cavity walls), eccentric loading, inadequate lateral restraint|face of wall curves outward, visible to eye or straightedge|severe — collapse risk|install new ties (cavity walls), add lateral restraint, rebuild if excessive
DF11|wall tie failure|corrosion of metal ties in cavity wall — expansion of rust pushes wythes apart|horizontal cracking at tie positions (every 6th course typical), bulging|severe — outer wythe may collapse|install replacement stainless steel ties, remove old corroded ties
DF12|mortar decay|carbonation, freeze-thaw, chemical attack|soft, crumbling, recessed, or missing mortar|moderate — progressive if not addressed|repoint with compatible mortar — must be softer than units
DF13|staining (iron)|iron fixings or pyrite inclusions rusting|orange-brown runs or spots on face|cosmetic|remove iron source, treat with proprietary iron stain remover
DF14|staining (biological)|algae, lichen, moss growth in damp/shaded areas|green/black growth on face, usually north-facing|cosmetic to moderate — roots can enter joints|biocide treatment, improve air circulation, do not pressure wash — drives water into wall
DF15|crypto-efflorescence|salt crystallization within pore structure of unit (not on surface)|surface blistering, sub-surface delamination, sounds hollow when tapped|severe — internal pressure destroys unit|cannot repair — replace unit, address moisture source
DF16|lime bloom|lime leaching from mortar or concrete — calcium hydroxide carbonates on surface|white haze or drips, especially below mortar joints or concrete elements|cosmetic — usually self-resolving|acid wash (dilute HCl) if persistent — test inconspicuous area first
DF17|thermal cracking|restrained thermal expansion in long wall runs without movement joints|vertical crack, typically at regular intervals or at restraint points|moderate|cut movement joints at crack locations, fill with flexible sealant
DF18|inadequate bonding|continuous vertical joints from incorrect bond pattern or missing headers|vertical weakness line visible in face|severe — wall acts as two separate leaves|rebuild section with correct bond, or install remedial ties

# rules(id|rule|domain|rationale|violation_consequence)
RU1|mortar must be weaker than units it joins|material|masonry is sacrificial joint system — mortar is replaceable, units are not — soft mortar absorbs movement|hard mortar on soft brick causes brick spalling — irreversible damage
RU2|bricks must be dampened before laying in hot/dry conditions|material|dry brick absorbs water from mortar too rapidly — mortar cannot hydrate/carbonate properly|weak joints — mortar crumbles, poor bond
RU3|bricks must not be saturated before laying|material|excess water in unit dilutes mortar at interface, floats unit, prevents bond|units slide, weak bond, efflorescence
RU4|mortar must match original in repair/repointing — never stronger|material|hard repointing in soft historic wall redirects stress into original fabric|original brick/stone spalls around hard mortar — common conservation error
RU5|perpend (vertical) joints must be staggered minimum quarter-bond, half-bond preferred|structural|continuous vertical joints create slip planes — wall has no transverse tensile capacity|wall splits along vertical joint line — DF18
RU6|through-bond (headers or ties) required in walls thicker than one wythe|structural|without through-bonding, wall acts as independent leaves — buckles under load|bulging, delamination, partial collapse
RU7|maximum wall height without lateral support = 12× thickness (unreinforced)|structural|slenderness ratio beyond this risks buckling under eccentric load or wind|wall buckles laterally — sudden collapse
RU8|damp-proof course must be continuous and unbridged|moisture|any break allows capillary path for rising damp|rising damp — DF5
RU9|cavity must be kept clean during construction — no mortar droppings bridging gap|moisture|mortar bridges allow water to cross cavity to inner leaf|penetrating damp on inner wall — DF6
RU10|movement joints at 10-12m intervals in clay brick, 6m in concrete block|structural|thermal and moisture movement inevitable — restraint causes cracking|thermal cracking — DF17
RU11|frost protection: no laying when temperature below 3°C or falling|material|water in mortar freezes before hydration — mortar will never gain strength|weak mortar throughout, joints fail in service
RU12|mortar joint thickness: 10mm for brick (±3mm), varies for stone|dimensional|consistent joints maintain coursing gauge and structural uniformity|irregular coursing, difficulty tying into adjacent work, visual defect
RU13|new masonry must be protected from rain for minimum 48 hours (OPC mortar) or longer (lime)|material|rain washes unset mortar from joints, saturates fresh work|loss of mortar, efflorescence, weak joints
RU14|load-bearing walls must be built plumb — maximum deviation 10mm in 3m height|structural|out-of-plumb wall has eccentric load — creates bending in addition to compression|eccentric loading reduces capacity, can cause buckling
RU15|arch voussoir joints must be radial — perpendicular to curve at every point|structural|non-radial joints create shear planes — arch cannot maintain compression line|voussoir slippage, arch collapse — AC9
RU16|lintel bearing minimum 150mm at each end|structural|insufficient bearing concentrates load on small area of supporting masonry|crushing of masonry at bearing, lintel drops
RU17|stone must be laid on its natural bed — bedding planes horizontal|structural|stone is strongest in compression perpendicular to bedding planes (as formed geologically)|face delamination — bedding planes peel away if vertical — called face-bedding
RU18|corbelling must not project more than one-third of unit length per course|structural|greater projection creates overturning moment — unit tips|unit drops out of wall
RU19|wall ties in cavity walls: minimum 2.5 ties per m², staggered, within 225mm of openings|structural|ties transfer wind load from outer to inner wythe and prevent relative movement|outer leaf blows off in wind — DF10, DF11
RU20|repointing depth must be 2-2.5× joint width before filling|repair|shallow repointing has no key — mortar falls out within years|failed repointing, repeated maintenance
RU21|lime mortar must not be allowed to dry too fast — mist cure, protect from sun and wind|material|lime mortar carbonates slowly — rapid drying prevents carbonation, causes shrinkage cracking|weak, crumbly mortar — dust joints
RU22|always build corners first, infill to line between corners|construction|corners establish plumb, level, and gauge — wall between is controlled by corner accuracy|crooked wall, mismatched coursing, poor joints
RU23|never chase horizontally in load-bearing masonry|structural|horizontal chase cuts through units and mortar — removes cross-section at that level|wall has reduced section — behaves as if cracked horizontally
RU24|bricks from different packs must be mixed before laying|appearance|color varies between kiln batches — unmixed packs create visible banding|patchy appearance — bands of different color across wall
RU25|copings and sills must project beyond wall face with drip groove on underside|moisture|water running down wall face enters at top — projection and drip throw water clear|water tracks under sill/coping into wall — penetrating damp

# relationships(from|rel|to)
# unit types → bond patterns they enable
UT1|enables|BP1-BP11
UT2|enables|BP1-BP11
UT7|enables|BP1,BP7
UT10|enables|BP14
UT11|enables|BP12,BP13
UT13|enables|BP12
# stone types → unit types
ST1|enables|UT10,UT11,UT12
ST2|enables|UT10,UT11,UT12
ST3|enables|UT10,UT11,UT12
ST4|enables|UT10,UT12
ST5|enables|UT12
ST8|enables|UT17
# brick types → unit types
BK1|subtype_of|UT1
BK2|subtype_of|UT2
BK3|subtype_of|UT2
BK5|subtype_of|UT3
BK6|subtype_of|UT3
BK7|subtype_of|UT4
# mortar → unit compatibility
MO1|enables|UT10,UT11,UT13
MO2|enables|UT1,UT2,UT10,UT11
MO5|enables|UT1,UT2,UT7,UT8
MO7|enables|UT3,UT7,UT8
MO9|opposes|UT1,UT2,UT10,UT11
MO11|enables|TQ13
MO12|enables|UT4
# wall types → unit/bond requirements
WT1|requires|BP1
WT2|requires|BP2,BP3
WT5|requires|RE1,BP1
WT6|requires|RE1,BP1
WT7|requires|RE1
WT9|requires|RE3,RE4,UT7
WT12|requires|UT11
# mortar rule relationships
RU1|constrains|MO1-MO12
RU4|constrains|MO5-MO9
MO9|violates|RU1
# bond → structural rules
BP7|violates|RU5
RU5|enforces|BP1-BP6,BP8-BP11
RU6|enforces|BP2-BP6
# arch construction sequence
AC1|enables|AC2
AC2|enables|AC3
AC3|enables|AC4
AC4|enables|AC5
AC5|enables|AC6
AC6|enables|AC7
# arch construction → architecture cross-refs
AC1|enables|AT1-AT13
AC9|implements|RU15
AC12|constrains|EL24
# defect → cause chains
DF1|derives_from|MO5,MO6,MO7
DF2|derives_from|DF3
DF3|derives_from|MO9,DF6
DF4|derives_from|MO5,MO6,BK1
DF5|derives_from|RE9
DF10|derives_from|DF11
DF11|derives_from|RE1
DF15|derives_from|DF1
DF17|derives_from|RE10
DF18|derives_from|RU5,RU6
# defect → rule violations
DF2|caused_by_violating|RU1
DF5|caused_by_violating|RU8
DF6|caused_by_violating|RU9,RU25
DF7|caused_by_violating|RU10
DF8|caused_by_violating|RU6
DF10|caused_by_violating|RU19
DF18|caused_by_violating|RU5
# tool → technique relationships
TL1|enables|TQ3,TQ4,TQ7,TQ8
TL2|enables|TQ10,TQ11,TQ12
TL4|enables|TQ3,TQ4
TL5|enables|TQ3,TQ4
TL6|enables|TQ3,TQ4
TL7|enables|TQ9,TQ10
TL8|enables|TQ14
TL14|enables|TQ3,TQ4
TL19|enables|TQ11
TL20|enables|TQ11
TL22|enables|TQ20
TL23|enables|TQ20
TL24|enables|TQ20
# technique dependencies
TQ1|enables|TQ2
TQ2|enables|TQ3
TQ4|enables|TQ3
TQ3|requires|TQ7
TQ9|requires|TL7
TQ11|requires|TQ10
TQ12|subtype_of|TQ10
TQ13|requires|MO11
TQ18|requires|WT5,RE1
TQ19|requires|WT9,RE3
TQ20|requires|TL21,TL22,TL23,TL24
# stone dressing sequence
TL22|enables|TL23
TL23|enables|TL24
# reinforcement → wall type
RE1|component_of|WT5,WT6,WT7
RE3|component_of|WT9
RE4|component_of|WT9
RE5|component_of|WT2,WT5,WT7
RE9|component_of|WT2,WT3,WT4,WT5,WT6,WT7
RE10|component_of|WT5,WT6,WT7,WT9
# cross-references to ARCHITECTURE compaction
UT10|implements|EL10
UT1|implements|EL49
BP14|implements|EL10
BP2|implements|EL50
BP3|implements|EL50
MO1|enables|SS2
MO5|enables|SS2
SS2|requires|UT1-UT14
SS3|requires|AC1-AC12
EL21|requires|AC4
EL22|requires|AC5
EL11|implements|SS12
RE8|implements|AT15,EL51
RU15|constrains|AT1-AT15
RU17|constrains|ST1-ST11
WT2|implements|EL13
WT5|implements|EL13,EL14
WT7|implements|EL14
WT12|implements|EL13
# joint profiles → weather performance
JP2|implements|RU25
JP4|violates|RU25
JP9|violates|RU25
# rules → rules
RU1|enables|RU4
RU5|enables|RU6
RU22|implements|TQ4

# section_index(section|title|ids)
1|Unit Types|UT1-UT18
2|Stone Types|ST1-ST11
3|Brick Types|BK1-BK14
4|Mortar Types|MO1-MO12
5|Bond Patterns|BP1-BP16
6|Joint Profiles|JP1-JP10
7|Wall Types|WT1-WT15
8|Arch Construction|AC1-AC12
9|Reinforcement|RE1-RE13
10|Tools|TL1-TL24
11|Techniques|TQ1-TQ22
12|Defects|DF1-DF18
13|Rules|RU1-RU25

# decode_legend
id_prefixes: UT=unit_type, ST=stone_type, BK=brick_type, MO=mortar_type, BP=bond_pattern, JP=joint_profile, WT=wall_type, AC=arch_construction, RE=reinforcement, TL=tool, TQ=technique, DF=defect, RU=rule
rel_types: enables|requires|implements|composes|component_of|subtype_of|constrains|enforces|contains|limited_by|prevents|opposes|derives_from|violates|caused_by_violating
cross_ref_prefixes: AT=arch_type, EL=element, SS=structural_system, VZ=vertical_zone (from ARCHITECTURE compaction)
strength_units: N/mm² = megapascals (MPa)
dimension_convention: length×width×height in mm unless noted
mortar_ratios: by volume (cement:lime:sand)
abbreviations: OPC=Ordinary Portland Cement, DPC=damp-proof course, NHL=Natural Hydraulic Lime, AAC=autoclaved aerated concrete, CEB=compressed earth block, HCl=hydrochloric acid
confidence: generated from LLM weights — reflects established trade practice and building science, not corpus statistics

# relation_mapping(doc_rel|canonical_rel|notes)
enables|enables|exact match
requires|requires|exact match
implements|implements|exact match
composes|composed_of|inverse; entablature composes elements = composed_of parts
component_of|part_of|exact semantic match
subtype_of|specializes|brick type is subtype of unit type = specializes
constrains|constrains|exact match
enforces|validates|bond rule enforces pattern compliance = validates
contains|contains|exact match
limited_by|constrains|inverse; system limited by element = element constrains system
prevents|prevents|exact match
opposes|opposes|exact match
derives_from|derived_from|exact match
violates|violates|exact match
caused_by_violating|result_of|defect caused by violating rule = result_of rule violation
