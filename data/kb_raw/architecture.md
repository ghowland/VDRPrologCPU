# ARCHITECTURE — STRUCTURAL CONSTRUCTION VOCABULARY — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: vertical_zones → structural_systems → arch_types → column_orders → roof_forms → elements → openings → spatial_concepts → ornament_types → building_types → rules → relationships → section_index

# vertical_zones(id|zone|position|structural_role|typical_contents)
VZ1|foundation|below grade|transfers all loads to soil/rock|footings, piles, mat slabs, basement walls
VZ2|substructure|grade to first floor|transitions foundation to superstructure|basement, plinth, podium, crawl space
VZ3|lower/ground|first 1-2 stories|heaviest live loads, public entry, thickest walls|entrance, arcade, rusticated base, commercial
VZ4|middle|stories between lower and upper|repetitive floor plates, primary occupancy|typical floors, regular fenestration, service cores
VZ5|upper/attic|top stories below roof|reduced live load, transitional to roof|attic, clerestory, gallery, mechanical
VZ6|roof/crown|topmost enclosure|sheds weather, resolves vertical composition|roof structure, parapet, dome, spire, cornice
VZ7|spire/finial|above roof if present|symbolic termination, no occupancy|spire, lantern, finial, antenna, lightning rod

# structural_systems(id|system|description|force_path|span_capacity|materials)
SS1|post-and-lintel|vertical posts support horizontal beam|vertical compression through posts, bending in lintel|short (3-6m stone, 6-12m timber)|stone, timber, steel
SS2|load-bearing wall|continuous wall carries floor/roof loads|vertical compression distributed along wall length|limited by wall thickness and openings|masonry, stone, brick, concrete, adobe
SS3|arch system|curved element converts vertical load to diagonal thrust|compression follows curve to abutments, horizontal thrust at base|moderate (5-30m masonry, 50m+ concrete)|stone, brick, concrete, steel
SS4|vault|extruded or rotated arch forming curved ceiling|continuous compression surface to walls/piers|moderate to large|stone, brick, concrete
SS5|dome|rotated arch forming hemispherical shell|meridional compression + hoop tension/compression|large (up to 43m unreinforced — Pantheon)|stone, brick, concrete, steel
SS6|frame (rigid)|beams and columns with moment-resisting joints|bending and compression shared between members|large (steel/concrete virtually unlimited)|steel, reinforced concrete, timber
SS7|frame (braced)|frame with diagonal bracing for lateral loads|axial forces in braces resist lateral loads, gravity through columns|large|steel, timber
SS8|truss|triangulated assembly of axial members|pure tension and compression in members, no bending|large (20-100m+)|timber, steel, iron
SS9|shell/thin-shell|curved surface carries load through membrane action|in-plane compression and tension, minimal bending|very large (spans 50m+)|reinforced concrete, steel
SS10|cable/tension|cables in pure tension support deck or roof|tension in cables, compression in masts/towers|very large (suspension bridges 1000m+)|steel cable, carbon fiber
SS11|cantilever|member fixed at one end, free at other|bending moment maximum at support, shear decreases to tip|limited by depth and material|steel, reinforced concrete, timber
SS12|buttress system|external prop resists lateral thrust from arch/vault|redirects horizontal thrust diagonally to ground|extends arch/vault span capability|stone, masonry, concrete
SS13|space frame|three-dimensional truss grid|axial forces in all directions, highly redundant|very large roof spans|steel, aluminum
SS14|pneumatic/membrane|air pressure or tensioned fabric resists loads|tension in membrane, internal pressure or cable net|very large (stadia)|fabric, ETFE, cable net
SS15|hybrid/composite|combination of two or more systems|load sharing between systems|varies by combination|mixed

# arch_types(id|type|geometry|thrust_profile|span_range|period|origin)
AT1|round/semicircular|half circle, rise = radius = span/2|symmetric outward thrust, constant curvature|2-25m|ancient onward|Roman
AT2|segmental|arc less than semicircle, rise < radius|lower thrust angle, more horizontal push|2-20m|Roman onward|Roman
AT3|pointed/Gothic|two arcs meeting at apex, rise > span/2 possible|steeper thrust line, reduced horizontal thrust|3-25m|12th c onward|Islamic → Gothic
AT4|lancet|narrow pointed arch, rise >> span/2|very steep thrust, minimal horizontal component|2-10m|13th c|Gothic
AT5|equilateral|pointed arch where radius = span|balanced thrust, moderate horizontal component|3-15m|12th-15th c|Gothic
AT6|horseshoe|arc exceeds semicircle, narrows below spring line|thrust directed inward at base, requires rigid abutment|2-12m|8th c onward|Moorish/Visigothic
AT7|ogee|S-curve: concave lower, convex upper meeting at point|decorative, minimal structural use, low load capacity|1-5m|14th c onward|English Decorated
AT8|Tudor/four-centered|flattened pointed arch from four radii|wide span, low rise, moderate thrust|3-12m|15th-16th c|English Perpendicular
AT9|parabolic|parabolic curve|thrust follows pure compression line for uniform load — ideal arch|5-100m+|19th c onward|modern engineering
AT10|catenary|shape of hanging chain inverted|pure compression under self-weight, zero bending|5-100m+|17th c theory, 19th c practice|Hooke/Gaudí
AT11|flat/jack|nearly horizontal, very slight rise|almost entirely horizontal thrust, requires strong abutments|1-3m|ancient onward|Roman/Renaissance
AT12|trefoil|three-lobed arch|decorative, each lobe a small arch|1-4m|Gothic onward|Gothic
AT13|multifoil/polylobed|multiple lobes along arch curve|decorative, each lobe structural micro-arch|1-6m|10th c onward|Islamic
AT14|corbel arch|horizontal courses each projecting past lower, not true arch|no thrust — pure cantilever from each side|1-5m|prehistoric onward|Mycenaean/Maya
AT15|relieving/discharge|arch built above lintel to divert load around opening|carries wall load around opening, lintel carries only its span|matches opening|ancient onward|Roman/Egyptian

# column_orders(id|order|origin|proportions|capital_form|entablature|character)
CO1|Doric (Greek)|Greek, 7th c BCE|height 4-6× lower diameter, no base|echinus (convex cushion) + abacus (square slab)|triglyphs and metopes frieze|sturdy, masculine, austere
CO2|Doric (Roman/Tuscan)|Roman adaptation|height 7× diameter, base added|simpler echinus + abacus, sometimes unfluted|simplified frieze, sometimes plain|plainer than Greek Doric
CO3|Ionic|Greek Ionia, 6th c BCE|height 8-9× diameter, base with torus and scotia|paired volutes (scrolls) flanking echinus|continuous frieze (often sculptured), dentils|elegant, scholarly, feminine
CO4|Corinthian|Greek, 5th c BCE (rare until Roman)|height 10× diameter, elaborate base|acanthus leaf basket with small volutes|modillions and dentils, richest entablature|ornate, celebratory
CO5|Composite|Roman, 1st c CE|height 10× diameter|combines Ionic volutes with Corinthian acanthus|richest Roman entablature|imperial, triumphal
CO6|Solomonic/barley-sugar|Baroque, 17th c|twisted shaft, proportions vary|usually Composite or Corinthian capital|standard entablature adapted to twist|dynamic, theatrical
CO7|Caryatid/Atlantes|Greek, 6th c BCE|human figure replaces shaft|head supports entablature directly|standard entablature|figural, monumental
CO8|pilaster|flat column engaged in wall|follows proportions of its order|capital matches its order|entablature matches its order|decorative wall articulation, not freestanding

# roof_forms(id|form|geometry|structural_basis|drainage|typical_use)
RF1|gable/pitched|two inclined planes meeting at ridge|rafters or trusses span between walls|two-slope runoff|houses, churches, barns — universal
RF2|hip|four inclined planes, no vertical gable ends|hip rafters from corners to ridge, more rigid than gable|four-slope runoff|residential, institutional — wind resistant
RF3|gambrel/mansard (lower)|double-slope each side, steep lower + shallow upper|allows usable attic space, truss or purlin|four-slope runoff|residential, barn (gambrel), urban (mansard)
RF4|flat|horizontal or near-horizontal (<10°)|slab or joist, requires waterproof membrane|internal drains or slight pitch to scuppers|modern commercial, residential, industrial
RF5|shed/mono-pitch|single inclined plane|rafters or joists slope one direction|single-slope runoff|additions, industrial, modern residential
RF6|barrel vault roof|continuous semicircular or pointed section|vault structure (SS4)|runoff at sides|churches, train stations, markets
RF7|dome|hemispherical or raised hemispherical|dome structure (SS5), may use pendentives or drum|radial runoff or oculus|religious, civic, monumental
RF8|conical|cone shape|rafters to central peak or compression ring|radial runoff|towers, turrets, roundhouses
RF9|butterfly/V|two planes sloping inward to central valley|inverted truss or beam, central gutter|central valley drain|modern, tropical (rainwater collection)
RF10|sawtooth|repeated asymmetric gable, one side glazed|truss per tooth, glazed side faces away from sun|multiple parallel gutters|factories, studios — north light
RF11|cross-gable|two gable roofs intersecting at right angles|valley rafters at intersections|valleys channel water to gutters|residential, churches (nave + transept)
RF12|helm/rhenish|four faces rising to point from gable walls|pyramid over square with gable-end dormers|four-slope runoff|church towers, Germanic tradition
RF13|onion dome|bulbous dome wider than drum|timber or metal frame over masonry drum|compound curved runoff|Russian/Orthodox churches, Mughal

# elements(id|element|category|zone|structural_role|description)
# — Foundation elements
EL1|footing|structural|VZ1|spreads column/wall load over soil area|widened base, sized to soil bearing capacity
EL2|pile|structural|VZ1|transfers load through weak soil to bearing stratum or via friction|driven or bored deep element
EL3|mat/raft slab|structural|VZ1|distributes entire building load across full footprint|thick continuous slab, used on poor soil or high water table
EL4|retaining wall|structural|VZ1-VZ2|resists lateral earth pressure|holds back soil at grade changes
# — Substructure elements
EL5|plinth|structural/ornamental|VZ2|raises building above grade, visual base|projecting base course, often different material
EL6|podium|structural|VZ2|elevated platform supporting building above|massive base structure, Roman temples
EL7|basement wall|structural|VZ2|below-grade enclosure, resists earth pressure|foundation wall doubling as habitable boundary
# — Vertical structural elements
EL8|column|structural|VZ3-VZ5|carries axial compression from beam/slab above|freestanding vertical, round or polygonal
EL9|pier|structural|VZ3-VZ5|carries heavier loads than column, often rectangular|massive vertical, often compound section
EL10|pilaster|structural/ornamental|VZ3-VZ5|engaged column providing wall stiffening and visual rhythm|flat column projecting from wall face
EL11|buttress|structural|VZ3-VZ5|resists lateral thrust from arch/vault|thickened wall projection or stepped pier
EL12|flying buttress|structural|VZ4-VZ5|transmits vault thrust over aisle roof to outer buttress|inclined arch or half-arch spanning between wall and pier
EL13|wall (load-bearing)|structural|VZ3-VZ5|carries gravity load and may resist lateral force|continuous vertical enclosure, thickness decreases upward
EL14|wall (curtain/infill)|enclosure|VZ3-VZ5|no structural load — only self-weight and wind|hung from or infilling between structure
EL15|engaged column|structural/ornamental|VZ3-VZ5|partly embedded in wall, shares wall load|column bonded into wall surface
# — Horizontal structural elements
EL16|beam/lintel|structural|VZ3-VZ5|spans opening, carries load in bending|horizontal member over opening or between supports
EL17|girder|structural|VZ3-VZ5|primary beam carrying secondary beams|heavy beam, often deeper section
EL18|architrave|structural/ornamental|VZ3-VZ6|lowest division of entablature spanning column to column|main beam resting directly on capitals
EL19|floor slab|structural|VZ3-VZ5|horizontal diaphragm carrying live load|concrete, timber, or composite plate
EL20|joist|structural|VZ3-VZ5|repetitive beam supporting floor or ceiling|closely spaced parallel members
# — Arch and vault elements
EL21|voussoir|structural|VZ3-VZ6|wedge-shaped block forming arch ring|tapered unit, compression across joints
EL22|keystone|structural/ornamental|VZ3-VZ6|central voussoir locking arch|topmost wedge, often enlarged or carved
EL23|springer/impost|structural|VZ3-VZ5|first voussoir above support, defines spring line|transition from vertical pier to curved arch
EL24|abutment|structural|VZ2-VZ3|mass resisting arch thrust at base|heavy masonry or concrete at arch ends
EL25|spandrel|structural/enclosure|VZ3-VZ5|triangular area between arch extrados and rectangular frame|filled panel or open (bridge spandrel)
EL26|pendentive|structural|VZ5-VZ6|curved triangle transitioning square plan to circular dome|concave spherical triangle at dome corners
EL27|squinch|structural|VZ5-VZ6|arch or corbel bridging square corner to support octagonal/circular element above|small arch across interior corner
EL28|rib|structural/ornamental|VZ5-VZ6|projecting band on vault underside concentrating thrust|allows thinner vault web between ribs
EL29|boss|ornamental|VZ5-VZ6|carved block at intersection of vault ribs|covers rib junction, often decorated
# — Roof elements
EL30|rafter|structural|VZ6|inclined member carrying roof load to wall/beam|from ridge to eave
EL31|ridge beam|structural|VZ6|horizontal member at roof apex|carries or stabilizes rafter tops
EL32|purlin|structural|VZ6|horizontal member spanning between trusses or frames supporting rafters|intermediate roof beam perpendicular to rafters
EL33|truss|structural|VZ6|triangulated frame spanning between walls or columns|carries roof load without intermediate support (SS8)
EL34|eave|transitional|VZ6|roof edge overhanging wall face|protects wall from rain, defines shadow line
EL35|soffit|enclosure|VZ6|underside of eave overhang|enclosed or open, ventilation path
EL36|fascia|enclosure/ornamental|VZ6|vertical board at rafter ends|finishes eave edge, carries gutter
EL37|parapet|enclosure|VZ6|low wall extending above roof line|conceals roof, provides fall protection
EL38|battlement/crenellation|structural/ornamental|VZ6|parapet with alternating merlons and crenels|defensive/decorative wall top
# — Entablature elements
EL39|entablature|structural/ornamental|VZ5-VZ6|horizontal assembly above columns: architrave + frieze + cornice|full classical horizontal band
EL40|frieze|ornamental|VZ5-VZ6|middle band of entablature|may be plain, sculptured, or with triglyphs
EL41|cornice|ornamental/structural|VZ6|projecting horizontal molding at wall/entablature top|sheds water, casts shadow, crowns composition
EL42|pediment|ornamental/structural|VZ6|triangular gable end framed by cornice|classical temple front, often with sculpture
EL43|tympanum|ornamental|VZ6|surface enclosed by pediment|often carved or filled with mosaic
# — Floor/stair elements
EL44|staircase|structural/circulation|VZ2-VZ5|inclined passage between floors|steps, landings, structural support
EL45|landing|structural|VZ2-VZ5|horizontal platform between stair flights|resting point, direction change
EL46|balustrade|enclosure/ornamental|VZ3-VZ6|row of balusters supporting handrail|stair/balcony edge protection and decoration
EL47|newel|structural/ornamental|VZ3-VZ5|principal post at stair turn or termination|carries handrail, often carved
# — Wall elements
EL48|quoin|structural/ornamental|VZ3-VZ5|corner stones alternating header and stretcher|reinforces and decorates wall corners
EL49|course|structural|VZ2-VZ6|continuous horizontal layer of masonry|bonding pattern determines wall strength
EL50|bond pattern|structural|VZ2-VZ6|arrangement of units in courses|English, Flemish, running, stack — affects strength and appearance
EL51|relieving arch|structural|VZ3-VZ5|arch built within wall above opening to redirect load|protects lintel from full wall weight (AT15)
EL52|niche|enclosure/ornamental|VZ3-VZ5|recessed space in wall|for sculpture, functional storage, visual depth

# openings(id|type|zone|framing|function|description)
OP1|doorway|VZ3|lintel, arch, or frame|primary entry/egress|full-height opening for passage
OP2|window|VZ3-VZ5|lintel, arch, or frame with sill|light and ventilation|glazed or open aperture in wall
OP3|arcade|VZ3-VZ4|series of arches on columns or piers|covered passage, structural rhythm|repeated arch-on-support module
OP4|colonnade|VZ3-VZ4|series of columns supporting entablature|covered passage, monumental frontage|repeated column-and-beam module
OP5|loggia|VZ3-VZ4|arcade or colonnade recessed into building face|sheltered outdoor room|open gallery within building envelope
OP6|portico|VZ3|columns supporting pediment at entry|monumental entrance|projecting columned porch
OP7|oculus|VZ6|circular opening, unframed or with ring|light from above, symbolic|round aperture in dome or wall (Pantheon = 8.7m)
OP8|rose window|VZ4-VZ5|circular window with tracery|light, iconographic display|large circular window divided by stone tracery
OP9|clerestory|VZ5|row of windows above adjacent roof|light into nave or central space|upper wall windows above aisle roof level
OP10|dormer|VZ6|windowed structure projecting from roof slope|light and ventilation to attic|has own roof, walls, and window
OP11|lancet window|VZ3-VZ5|tall narrow window with pointed arch top|light, defensive (narrow)|single-light pointed opening
OP12|transom window|VZ3-VZ5|horizontal bar dividing window, upper section may open|ventilation above, fixed below|window divided horizontally
OP13|fanlight|VZ3|semicircular or elliptical window above door|light into entry hall|radiating glazing bars suggest fan
OP14|skylight|VZ6|glazed opening in roof plane|overhead light|flush or raised from roof surface
OP15|arrow loop/slit|VZ3-VZ5|narrow vertical opening, splayed inside|defensive firing position, minimal light|wider inside for bow arc, narrow outside for protection
OP16|portcullis opening|VZ3|vertical slot in gateway for sliding grille|defensive closure of gate passage|grooves in jambs guide iron/wood grille

# spatial_concepts(id|concept|definition|applies_to)
SC1|bay|structural module defined by adjacent column/pier lines|all building types — fundamental planning unit
SC2|nave|central longitudinal vessel of church|churches, basilicas
SC3|aisle|lateral vessel parallel to nave, separated by columns/piers|churches, basilicas, halls
SC4|transept|arm crossing nave at right angles|cruciform churches
SC5|crossing|intersection of nave and transept|cruciform churches — often carries tower/dome
SC6|apse|semicircular or polygonal termination|churches (east end), Roman basilicas
SC7|narthex|entrance vestibule before nave|churches, basilicas
SC8|ambulatory|passage curving around apse behind altar|pilgrimage churches, cathedrals
SC9|atrium|open central court|Roman houses, modern buildings, early churches
SC10|cloister|covered walkway around courtyard|monasteries, universities, mosques
SC11|courtyard|open space enclosed by building wings|universal — residential, institutional, religious
SC12|threshold|transition zone between inside and outside|all buildings — doorway, vestibule, porch
SC13|enfilade|rooms aligned with doors on common axis|palaces, galleries — visual depth
SC14|piano nobile|principal elevated floor with tallest ceilings and finest rooms|palaces, villas — typically first floor above ground
SC15|crypt|vaulted chamber below main floor, often below altar|churches — burial, relics
SC16|gallery|upper-level open corridor overlooking main space|churches, theaters, halls
SC17|triforium|narrow arcaded passage in nave wall between arcade and clerestory|Gothic cathedrals — three-level elevation
SC18|choir/chancel|area between crossing and apse for clergy and singers|churches
SC19|vestibule|transitional entry space between exterior and main interior|all building types
SC20|portico|covered entrance supported by columns|temples, civic buildings, grand houses
SC21|span|clear distance between supports|universal structural concept
SC22|bay window|window projecting from wall face, creating interior alcove|residential, commercial
SC23|turret|small tower projecting from wall|castles, Gothic Revival, corner emphasis
SC24|buttress bay|space between buttresses used for chapels or structure|Gothic cathedrals

# ornament_types(id|type|category|zone|medium|description)
OT1|molding (base)|profile|VZ2-VZ3|stone, wood, plaster|shaped profile at base of wall or column — torus, scotia, fillet
OT2|molding (cornice)|profile|VZ6|stone, wood, plaster|projecting profile at wall top — cyma recta, cyma reversa, ovolo, cavetto
OT3|molding (string course)|profile|VZ3-VZ5|stone, brick|horizontal band marking floor divisions on facade
OT4|rustication|surface treatment|VZ3|stone|deeply jointed or textured masonry at base — conveys mass and strength
OT5|ashlar|surface treatment|VZ3-VZ5|stone|smooth-faced precisely cut stone — conveys refinement
OT6|tracery (plate)|carved pattern|VZ4-VZ5|stone|openings cut through solid stone slab — Early Gothic
OT7|tracery (bar)|carved pattern|VZ4-VZ5|stone|thin stone bars forming geometric/flowing patterns — Decorated/Rayonnant
OT8|crocket|sculptural|VZ6|stone|projecting leaf form on spire/pinnacle edges — Gothic
OT9|finial|sculptural|VZ7|stone, metal|terminal ornament at apex of spire, gable, pinnacle
OT10|gargoyle|sculptural/functional|VZ6|stone|projecting water spout carved as creature — directs rainwater from wall
OT11|grotesque|sculptural|VZ4-VZ6|stone|carved figure without water function — decorative/apotropaic
OT12|boss (vault)|sculptural|VZ5-VZ6|stone|carved block at rib intersection — covers joint, displays heraldry/foliage
OT13|capital (carved)|sculptural|VZ3-VZ5|stone|decorated top of column — acanthus, volute, historiated, waterleaf
OT14|corbel|structural/sculptural|VZ3-VZ6|stone, wood|projecting bracket supporting beam/arch/statue — often carved
OT15|dentil|profile|VZ5-VZ6|stone|row of small rectangular blocks under cornice — Ionic/Corinthian
OT16|modillion|profile|VZ5-VZ6|stone|scroll-shaped bracket under cornice — Corinthian/Composite
OT17|egg-and-dart|profile|VZ5-VZ6|stone, plaster|alternating ovoid and pointed forms — classical molding enrichment
OT18|acanthus|motif|VZ3-VZ6|stone, plaster, wood|stylized leaf of acanthus plant — Corinthian capitals, scrollwork
OT19|palmette|motif|VZ3-VZ6|stone, plaster|fan-shaped palm leaf ornament — antefixae, friezes
OT20|guilloche|motif|VZ3-VZ5|stone, mosaic|interlaced circular bands — borders, friezes
OT21|arabesque|motif|VZ3-VZ5|stone, plaster, tile|flowing vegetal/geometric interlace — Islamic, Renaissance
OT22|muqarnas|motif/structural|VZ5-VZ6|stone, plaster, wood|honeycomb vault of miniature squinch cells — Islamic
OT23|cartouche|motif|VZ3-VZ5|stone, plaster|oval frame with scroll edges — inscriptions, heraldry
OT24|quoin (decorative)|surface treatment|VZ3-VZ5|stone, brick, render|emphasized corner stones — alternating size, contrasting material
OT25|baluster|sculptural|VZ3-VZ6|stone, wood, metal|shaped vertical post in balustrade — vase, column, or slab form
OT26|rose/wheel window|compositional|VZ4-VZ5|stone, glass|large circular window with radiating tracery — Gothic facades
OT27|tympanum relief|sculptural|VZ6|stone|carved scene filling pediment or arch tympanum
OT28|spandrel panel|ornamental|VZ3-VZ5|stone, plaster, tile|decorated surface between arches or arch and frame
OT29|pinnacle|sculptural/structural|VZ6-VZ7|stone|small pointed tower weighting buttress top — adds vertical load to resist thrust
OT30|battlement (decorative)|profile|VZ6|stone, brick|crenellation pattern used ornamentally without defensive function
OT31|machicolation|structural/ornamental|VZ6|stone|projecting parapet on corbels with floor openings — defensive or decorative
OT32|voussoir (emphasized)|surface treatment|VZ3-VZ5|stone|alternating colored or projecting arch stones — visual rhythm

# building_types(id|type|primary_function|typical_stories|structural_system|historical_period)
BT1|dwelling/house|habitation|1-3|SS2, SS6|prehistoric onward
BT2|villa|elite habitation, often rural|1-3|SS2, SS1, SS6|Roman, Renaissance onward
BT3|palace|ruler/state residence and administration|2-5|SS2, SS6, SS3|ancient onward
BT4|temple (classical)|worship, deity housing|1 (on podium)|SS1, SS2|Egyptian, Greek, Roman
BT5|church (basilican)|Christian worship|1-2 (+ towers)|SS1, SS2, SS3, SS4|4th c onward
BT6|cathedral (Gothic)|episcopal seat, monumental worship|1-3 (+ towers)|SS3, SS4, SS12, SS8|12th-16th c
BT7|mosque|Islamic worship and gathering|1-2 (+ minaret)|SS5, SS3, SS2|7th c onward
BT8|castle/fortress|military defense and lordly residence|2-5 (+ towers)|SS2, SS3|9th-16th c
BT9|tower (freestanding)|defense, observation, signaling, symbolic|3-20+|SS2, SS6|ancient onward
BT10|bridge|crossing over gap/water|n/a|SS3, SS8, SS10, SS11|ancient onward
BT11|aqueduct|water transport over terrain|n/a|SS3, SS1|Roman
BT12|amphitheater|spectacle, combat, assembly|1-4 (tiered)|SS3, SS2|Roman
BT13|barn|agricultural storage|1-3|SS8, SS2, SS6|medieval onward
BT14|market hall|commercial exchange|1-2|SS8, SS6, SS3|medieval onward
BT15|town hall|civic administration|2-4|SS2, SS6|medieval onward
BT16|skyscraper|high-density commercial/residential|10-100+|SS6, SS7|1880s onward
BT17|factory/industrial|manufacturing|1-5|SS6, SS8, SS13|18th c onward
BT18|railway station|transit|1-3|SS8, SS3, SS6, SS9|19th c onward
BT19|theater/opera house|performance|2-5|SS6, SS8, SS5|Greek onward
BT20|stadium|mass spectator sports|2-5 (tiered)|SS6, SS10, SS14, SS13|ancient onward
BT21|mausoleum/tomb|burial, commemoration|1-2|SS5, SS2, SS3|ancient onward
BT22|lighthouse|maritime navigation|3-10|SS2, SS6|ancient onward
BT23|minaret|call to prayer, symbolic|1 (tall)|SS2|7th c onward
BT24|pagoda|Buddhist relic housing, symbolic|3-13|SS6 (timber frame)|East Asian, 1st c onward
BT25|ziggurat|temple platform, cosmic mountain|stepped mass|SS2|Mesopotamian
BT26|pyramid|royal tomb, monumental|solid mass|SS2 (solid masonry)|Egyptian, Mesoamerican

# rules(id|rule|domain|rationale|violation_consequence)
RU1|load path must be continuous from roof to foundation|structural|every gravity load must have unbroken path of structural members to ground|collapse — load finds no support
RU2|lateral loads require dedicated system — bracing, shear walls, or moment frames|structural|gravity system alone cannot resist wind or earthquake|progressive collapse, overturning
RU3|arch requires abutment capable of resisting horizontal thrust|structural|arch converts vertical load to angled thrust at supports|arch spreads and collapses without abutment
RU4|load-bearing walls must be thicker at base than top when tall|structural|compressive stress accumulates downward|crushing or buckling of lower wall
RU5|openings in load-bearing walls must not exceed ~50% of wall length per story|structural|remaining wall sections (piers) must carry load above openings|pier overload, lintel failure, wall collapse
RU6|floor-to-floor height decreases or holds constant ascending — never increases|composition|visual stability, structural efficiency — heavier loads below|top-heavy appearance, inefficient structure
RU7|base zone receives heaviest material treatment — rustication, thicker walls, fewer openings|composition|visual and structural grounding — building appears to stand firmly|building appears to float or lack foundation
RU8|cornice or parapet terminates wall top — wall never ends as raw cut|composition|weather protection, shadow line, visual completion|unfinished appearance, water infiltration at wall top
RU9|window-to-wall ratio must balance light, thermal performance, and structural integrity|performance|too much glass = overheating and structural weakness; too little = dark interior|thermal failure, structural weakness, or unusable dark space
RU10|column spacing (intercolumniation) must match lintel material capacity|structural|stone lintels span short, steel spans long — spacing follows material|lintel failure in bending
RU11|vault thrust must be resisted at every bay — buttress rhythm matches vault rhythm|structural|each bay generates its own thrust|localized vault failure, domino collapse
RU12|dome requires transition element (pendentive or squinch) when placed on square plan|structural/geometric|circular dome base ≠ square plan — geometry must be reconciled|dome cannot seat on square without transition
RU13|stair rise-to-run ratio must remain constant within a flight|safety|variable steps cause falls — human gait expects uniform rhythm|tripping hazard, code violation
RU14|foundation must extend below frost line or to competent bearing stratum|structural|frost heave lifts shallow foundations; weak soil compresses|seasonal movement, differential settlement, cracking
RU15|masonry bond pattern must interlock — no continuous vertical joints through wall thickness|structural|continuous vertical joint creates slip plane — wall splits into two leaves|wall delamination, reduced load capacity
RU16|tall structure aspect ratio (height/base width) limited by overturning moment|structural|wind and seismic loads create overturning — base must resist|overturning failure, foundation uplift
RU17|thermal mass placement must match climate — heavy inside in hot climates, heavy outside in cold|performance|thermal mass absorbs heat swings — correct placement reduces energy use|overheating or overcooling, energy waste
RU18|drainage must direct water away from foundations|performance|water at foundations causes settlement, erosion, hydrostatic pressure|foundation failure, flooding, mold
RU19|fire compartmentation — fire-rated walls and floors subdivide building into zones|safety|limits fire spread, provides refuge and egress time|rapid fire spread, structural failure in fire
RU20|redundancy — structure should not depend on any single member (progressive collapse resistance)|structural|loss of one member should not trigger chain failure|disproportionate collapse from local damage

# relationships(from|rel|to)
# structural system dependencies
SS3|requires|EL24
SS3|requires|EL21
SS4|subtype_of|SS3
SS5|subtype_of|SS3
SS5|requires|EL26,EL27
SS6|requires|EL8,EL16
SS7|requires|EL8
SS8|composes|EL33
SS12|enables|SS3,SS4,SS5
SS12|implements|EL11,EL12
# arch type → structural system
AT1-AT15|implements|SS3
# vertical zone ordering
VZ1|enables|VZ2
VZ2|enables|VZ3
VZ3|enables|VZ4
VZ4|enables|VZ5
VZ5|enables|VZ6
VZ6|enables|VZ7
# elements → zones
EL1-EL3|component_of|VZ1
EL4|component_of|VZ1,VZ2
EL5-EL7|component_of|VZ2
EL8-EL15|component_of|VZ3,VZ4,VZ5
EL16-EL20|component_of|VZ3,VZ4,VZ5
EL21-EL29|component_of|VZ3,VZ4,VZ5,VZ6
EL30-EL38|component_of|VZ6
EL39-EL43|component_of|VZ5,VZ6
EL44-EL47|component_of|VZ2,VZ3,VZ4,VZ5
EL48-EL52|component_of|VZ3,VZ4,VZ5
# arch elements
EL21|component_of|AT1-AT15
EL22|component_of|AT1-AT13
EL23|component_of|AT1-AT13
EL24|requires|SS3
# column orders → elements
CO1-CO7|subtype_of|EL8
CO8|subtype_of|EL10
# entablature composition
EL39|composes|EL18,EL40,EL41
# dome transitions
EL26|enables|SS5
EL27|enables|SS5
RU12|enforces|EL26,EL27
# roof forms → structural systems
RF1|requires|SS8,EL30
RF2|requires|SS8,EL30
RF6|implements|SS4
RF7|implements|SS5
RF4|requires|SS6,EL19
# building types → structural systems
BT4|requires|SS1,SS2
BT5|requires|SS1,SS2,SS3
BT6|requires|SS3,SS4,SS12
BT7|requires|SS5,SS3
BT8|requires|SS2
BT10|requires|SS3,SS8,SS10
BT16|requires|SS6,SS7
BT20|requires|SS6,SS10,SS13,SS14
# building types → spatial concepts
BT5|contains|SC2,SC3,SC7,SC6
BT6|contains|SC2,SC3,SC4,SC5,SC8,SC17,SC9,SC24
BT7|contains|SC11,SC9
BT3|contains|SC13,SC14,SC11
# building types → vertical zones
BT1|contains|VZ1,VZ2,VZ3,VZ6
BT16|contains|VZ1-VZ7
BT4|contains|VZ1,VZ2,VZ3,VZ6
BT6|contains|VZ1-VZ7
# rules → elements they constrain
RU1|constrains|EL1-EL20,EL30-EL33
RU3|constrains|EL24,EL21
RU4|constrains|EL13
RU5|constrains|EL13,OP1,OP2
RU6|constrains|VZ3,VZ4,VZ5
RU7|constrains|VZ3
RU8|constrains|EL41,EL37
RU10|constrains|EL8,EL16,CO1-CO7
RU11|constrains|EL11,EL12
RU12|constrains|EL26,EL27,SS5
RU13|constrains|EL44,EL45
RU14|constrains|EL1,EL2
RU15|constrains|EL49,EL50
# ornament → zone and element relationships
OT1|component_of|VZ2,VZ3
OT2|component_of|EL41
OT3|component_of|VZ3,VZ4,VZ5
OT4|component_of|VZ3
OT5|component_of|VZ3,VZ4,VZ5
OT6|component_of|OP8
OT7|component_of|OP8
OT8|component_of|VZ6,VZ7
OT9|component_of|VZ7
OT10|component_of|VZ6
OT12|component_of|EL28
OT13|component_of|EL8,CO1-CO7
OT14|component_of|VZ3,VZ4,VZ5,VZ6
OT15|component_of|EL39
OT16|component_of|EL39
OT17|component_of|EL39
OT18|component_of|CO4,CO5
OT22|component_of|EL27,SS5
OT25|component_of|EL46
OT26|component_of|OP8
OT28|component_of|EL25
OT29|component_of|EL11,EL12
# ornament → structural relationships
OT29|enables|SS12
OT10|implements|RU18
EL12|implements|RU11
# opening → zone relationships
OP1|component_of|VZ3
OP2|component_of|VZ3,VZ4,VZ5
OP3|component_of|VZ3,VZ4
OP7|component_of|VZ6
OP8|component_of|VZ4,VZ5
OP9|component_of|VZ5
OP10|component_of|VZ6
OP14|component_of|VZ6
# spatial concept relationships
SC5|requires|SC2,SC4
SC8|requires|SC6
SC17|component_of|BT6
SC14|component_of|BT3,BT2
# anti-patterns
AT14|opposes|AT1
SS1|limited_by|EL16
RU5|prevents|OP1,OP2
RU16|constrains|BT9,BT16,BT23

# section_index(section|title|ids)
1|Vertical Zones|VZ1-VZ7
2|Structural Systems|SS1-SS15
3|Arch Types|AT1-AT15
4|Column Orders|CO1-CO8
5|Roof Forms|RF1-RF13
6|Structural and Enclosure Elements|EL1-EL52
7|Openings|OP1-OP16
8|Spatial Concepts|SC1-SC24
9|Ornament Types|OT1-OT32
10|Building Types|BT1-BT26
11|Structural and Compositional Rules|RU1-RU20

# decode_legend
id_prefixes: VZ=vertical_zone, SS=structural_system, AT=arch_type, CO=column_order, RF=roof_form, EL=element, OP=opening, SC=spatial_concept, OT=ornament_type, BT=building_type, RU=rule
rel_types: requires|enables|implements|composes|component_of|subtype_of|constrains|enforces|contains|limited_by|prevents|opposes
element_categories: structural=carries load, enclosure=separates inside/outside, ornamental=decorative, transitional=mediates between zones, circulation=enables movement
notation: fk references use table prefix (e.g. VZ3 = vertical_zones row 3), range X1-X15 expands to all IDs in range, comma-separated targets expand to individual rules
confidence: generated from LLM weights — structural rules reflect established engineering and architectural theory, not corpus statistics

# relation_mapping(doc_rel|canonical_rel|notes)
requires|requires|exact match
enables|enables|exact match
implements|implements|exact match
composes|composed_of|inverse; entablature composes architrave+frieze+cornice = entablature composed_of those parts
component_of|part_of|exact semantic match
subtype_of|specializes|vault is subtype of arch system = specializes
constrains|constrains|exact match
enforces|validates|rule enforces element requirement = validates compliance
contains|contains|exact match
limited_by|constrained_by|mapped via constrains inverse; post-and-lintel limited by lintel = lintel constrains post-and-lintel
prevents|prevents|exact match
opposes|opposes|exact match
