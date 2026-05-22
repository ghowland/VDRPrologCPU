# OUTDOOR SKILLS: CAMPING, HIKING, AND WILDERNESS — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: domains → shelter → sleep_systems → water → fire → food → navigation → clothing → footwear → packing → terrain → weather → hazards → first_aid → knots → tools → hygiene → planning → signals → flora_fauna_awareness → concepts → relationships → section_index → decode_legend

# domains(id|name|definition)
DM1|shelter|protection from wind, rain, cold, sun, insects; includes tents, tarps, hammocks, bivouacs, snow shelters, natural shelters
DM2|sleep_systems|insulation and comfort for sleeping; bags, pads, quilts, liners; warmth is function of loft, ground insulation, and wind protection combined
DM3|water|procurement, purification, storage, and hydration management; dehydration is the fastest non-trauma incapacitator in the field
DM4|fire|ignition, fuel management, fire types, cooking fire, signal fire, warmth fire; fire is shelter-multiplier and morale-multiplier
DM5|food_and_cooking|caloric needs, food selection, cooking systems, food storage, bear-country protocols
DM6|navigation|map reading, compass use, GPS, natural navigation, route finding, terrain association
DM7|clothing|layering system, material selection, weather-specific gear; clothing is the first and most important shelter
DM8|footwear|boots, trail runners, camp shoes, sock systems; feet are the primary mobility system — failure is mission-ending
DM9|pack_systems|backpacks, load distribution, packing order, weight management
DM10|terrain|trail types, off-trail travel, river crossings, scrambling, snow travel, desert travel
DM11|weather|reading weather, forecasting, storm behavior, lightning, wind chill, heat index
DM12|hazards|wildlife, plants, insects, terrain dangers, environmental dangers, human factors
DM13|first_aid|wilderness medical response; differs from urban: delayed evacuation, improvisation, environmental exposure
DM14|hygiene|waste management, personal cleanliness, water source protection; Leave No Trace principles
DM15|planning|trip planning, permits, fitness, group management, contingency, communication

# shelter(id|name|type|weight_g|capacity|setup_time_min|rain_rating|wind_rating|temperature_range|pros|cons|when_to_use)
SH1|freestanding dome tent|tent|1,500–3,000 (2P)|1–4 person|5–15|excellent (full fly, bathtub floor, taped seams)|good (aerodynamic dome shape)|3-season: −5 to 35°C; 4-season: −30 to 20°C|self-supporting (can move after setup); full weather protection; interior storage; bug-proof|heavier; more expensive; condensation if poor ventilation|general backpacking; all conditions; group camping
SH2|non-freestanding tent (trekking pole supported)|tent|500–1,500 (1–2P)|1–2 person|5–15|good to excellent (depends on fly coverage)|moderate (requires staking; less stable than dome)|3-season: −5 to 35°C|very light; packs small; uses trekking poles (dual purpose)|requires stakes (won't work on rock); less stable in high wind; smaller interior|ultralight backpacking; thru-hiking; weight-conscious
SH3|tarp|open shelter|200–500|1–4 (depending on size)|5–15|good (requires proper pitch angle and orientation to wind)|moderate (depends on pitch; no floor)|3-season; limited in winter|lightest shelter option; versatile pitch configurations; excellent ventilation; minimal condensation|no floor (need ground sheet); no bug protection; requires skill to pitch well; rain can blow in|ultralight; skilled users; mild weather; supplement with bivy or bug net
SH4|hammock + tarp + bug net|suspended|800–1,500 (full system)|1 person|10–20|good (tarp over hammock)|moderate (tarp must be properly angled)|3-season; with underquilt: to −10°C|off-ground (avoids wet/rocky/sloped terrain); very comfortable; good in rain|requires trees 3–5 m apart; cold underneath without underquilt (sleeping bag compresses under body); heavier complete system than ultralight tent|forested terrain; wet ground; warm-to-cool conditions
SH5|bivy sack|minimalist|200–500|1 person|1–2|good (waterproof/breathable fabric)|poor (no structure)|3-season; emergency: any|lightest enclosed shelter; fast deployment; always have as backup|claustrophobic; condensation (even with WPB fabric); no sitting room; no cooking space|emergency; alpinism; ultralight supplement to tarp; planned bivy
SH6|snow shelter (quinzhee)|constructed|0 (built from snow)|1–4|60–120 (build time)|excellent (snow is waterproof)|excellent (very stable once set)|winter only; interior stays ~0°C regardless of exterior (snow insulates)|free material; warmer than tent in deep cold; wind-proof; silent|requires adequate snow depth (~1 m); building is exhausting (sweat management critical); collapse risk if built wrong; takes hours|winter camping; survival; extended cold-weather stay
SH7|lean-to (natural)|constructed|0 (built from materials)|1–2|30–60|poor to moderate (depends on construction)|poor (open one side)|mild conditions only|free; minimal tools; primitive skills practice|single-sided exposure; labor-intensive; poor weather protection|survival situation; primitive camping; mild weather; supplement with fire in front
SH8|emergency space blanket / bivy|emergency|50–150|1 person|<1|waterproof|windproof if sealed|emergency: any|ultralight; reflective (retains ~80% radiated body heat); fits in pocket; minimal cost|single-use (most types); crinkly (noise); condensation trap; tears easily; not comfortable|emergency always-carry; day hikes; car kit; supplement to primary shelter

# sleep_systems(id|name|type|weight_g|comfort_rating_C|limit_rating_C|insulation_type|r_value|pack_volume_L|pros|cons|when_to_use)
SS1|mummy sleeping bag (down)|bag|500–1,200|−5 to 5°C (varies by fill)|−10 to 0°C|goose down (600–900+ fill power)|—|3–8|lightest warmth-to-weight; compresses small; long lifespan if cared for|loses insulation when wet; expensive; requires dry storage; slow to dry|3-season; dry conditions; weight-conscious; cold to moderate
SS2|mummy sleeping bag (synthetic)|bag|800–2,000|−5 to 5°C|−10 to 0°C|synthetic fill (PrimaLoft, Climashield, Polartec Alpha)|—|5–12|insulates when wet; cheaper than down; non-allergenic; faster drying|heavier for same warmth; less compressible; shorter lifespan (fill degrades)|wet conditions; budget; spring/fall; situations where moisture likely
SS3|quilt (down or synthetic)|quilt|400–900|0 to 10°C|−5 to 5°C|down or synthetic|—|2–6|lighter than equivalent bag (no back insulation — compressed under you anyway); versatile (open in warm weather); no zipper snags|drafts if not attached to pad; side sleepers may get gaps; less intuitive than mummy|ultralight; warm-climate thru-hiking; side sleepers; experienced users
SS4|sleeping pad (closed-cell foam)|pad|200–400|—|—|closed-cell PE or EVA foam|R-value 1.5–3.0|bulky (roll or fold: ~10 L)|indestructible; lightweight; always works; doubles as sit pad; cheap|low comfort (thin, firm); low R-value alone; bulky|summer; ultralight; supplement under inflatable for winter; backup; always works
SS5|sleeping pad (self-inflating)|pad|400–900|—|—|open-cell foam + air|R-value 2.5–5.0|2–5|good comfort; moderate R-value; self-inflates (partially); durable|heavier than air pad; bulkier; foam degrades over years|general backpacking; car camping; good comfort-to-weight
SS6|sleeping pad (inflatable air)|pad|250–600|—|—|air chambers; some with synthetic or down insulation baffles|R-value 2.0–7.0 (insulated versions)|0.5–2|lightest comfort option; very compact; high R-values available (Therm-a-Rest NeoAir, Sea to Summit Ether Light)|puncture risk; requires inflation (lungs or pump sack); noisy (crinkle); expensive; repair kit needed|3-season to winter (insulated versions); comfort-focused; ultralight if chosen carefully
SS7|sleeping bag liner|liner|100–300|adds 5–15°C|—|silk (lightest), cotton (comfort), synthetic (warmth), thermal (reflective)|—|0.5–1|adds warmth; keeps bag clean (extends bag life); standalone in hot weather|additional item to carry; tangles in bag sometimes|extending bag range; hot-weather standalone; hygiene in shelters
SS8|pillow (inflatable)|comfort|40–100|—|—|—|—|0.2–0.5|comfort dramatically improves sleep quality; lightweight; packs tiny|can deflate; another item; stuff sack with clothes works as free alternative|anyone who values sleep quality — underrated item

# water(id|name|type|method|capacity_or_rate|weight_g|effective_against|not_effective_against|field_time|notes)
WA1|chemical treatment (chlorine dioxide)|purification|Aquamira, Katadyn Micropur; ClO₂ tablets or drops|varies (treat 0.5–10 L per dose)|30–60 (for container)|bacteria, viruses, protozoa (including Cryptosporidium with 4-hour wait)|chemical contaminants; heavy metals; sediment|30 min standard; 4 hours for Crypto|lightest purification; no moving parts; backup for any trip; tablets have shelf life ~5 years; taste acceptable
WA2|pump filter|filtration|ceramic or hollow-fiber element; hand-pumped through hose|1–2 L/min|200–500|bacteria, protozoa, sediment|viruses (most filters); chemical contaminants|immediate (pump and drink)|reliable in cold (won't freeze like squeeze); good for groups; can draw from shallow sources; filters clog (need cleaning/replacement)
WA3|squeeze filter (gravity/squeeze)|filtration|hollow-fiber membrane (Sawyer Squeeze, Platypus QuickDraw)|1–2 L/min (squeeze); 1–4 L in 3–10 min (gravity)|50–150|bacteria, protozoa, sediment|viruses (most); chemical contaminants|immediate (squeeze) or 3–10 min (gravity)|lightest filter option; no pump mechanism to fail; backflush to maintain flow; freeze protection needed (ice shatters fibers → undetectable failure)
WA4|UV treatment (SteriPEN)|purification|UV-C light kills pathogens in clear water|0.5–1 L per treatment (90 seconds)|100–130 (with batteries)|bacteria, viruses, protozoa|sediment (must pre-filter turbid water); chemical contaminants|90 seconds per liter|effective against viruses (unlike most filters); requires clear water; battery-dependent; fragile; does not remove sediment; cold reduces battery life
WA5|boiling|purification|heat water to rolling boil|any volume (pot-limited)|0 (uses existing pot + fuel)|bacteria, viruses, protozoa, all biological|chemical contaminants|1 min at sea level; 3 min above 2,000 m (lower boiling point)|100% reliable biological kill; no equipment needed beyond pot and fire/stove; uses fuel; slow for large volumes; water is hot (cooling time)
WA6|water bottle (hard, Nalgene-type)|storage|BPA-free plastic (Tritan) or stainless steel|0.5–1.5 L|100–300 (plastic); 150–400 (steel)|—|—|—|durable; wide mouth (easy to fill, add mix, clean); steel can boil water directly; gradations for measuring|heavier than soft bottles; doesn't compress when empty; can crack if frozen full
WA7|soft flask / collapsible bottle|storage|TPU or PE film (CNOC, HydraPak, Evernew)|0.5–3 L|20–50|—|—|—|ultralight; compresses when empty; can squeeze through filter; flexible shape|less durable (puncture); harder to drink from (floppy); develops taste over time; threading can leak if worn
WA8|hydration bladder (reservoir)|storage + delivery|TPU bladder with drink tube in pack|1.5–3 L|150–250|—|—|—|hands-free drinking; encourages regular hydration; large capacity|harder to fill/clean; hard to monitor remaining volume; tube freezes in cold; adds complexity; leak risk
WA9|pre-filter (bandana/coffee filter)|pre-treatment|fabric or paper filter removes large sediment before main treatment|any (flow-through)|0–10|large sediment, debris, some turbidity|bacteria, viruses, protozoa, dissolved contaminants|seconds|extends life of main filter; essential for turbid water; bandana is multi-use item; no weight penalty if bandana already carried

# fire(id|name|type|weight_g|reliability|conditions|burn_time|notes)
FR1|ferrocerium rod (ferro rod)|ignition|25–80|very high (works wet, high altitude, any temperature; 3,000–20,000 strikes)|all conditions including wet and high altitude|n/a (ignition only)|scrape with knife spine or striker; produces ~3,000°C sparks; requires prepared tinder; practice needed; works when lighters fail
FR2|waterproof matches|ignition|20–50 (box of 40)|moderate (limited supply; can be extinguished by wind)|moderate wind; rain if strike is sheltered|5–15 seconds per match|carry in waterproof container; strike-anywhere preferred; limited quantity = limited attempts; stormproof matches burn 15+ seconds
FR3|butane lighter (Bic)|ignition|20–30|high (thousands of lights)|fails below ~−1°C (butane won't vaporize); reduced at high altitude (less O₂)|~1,000–3,000 lights|lightest fire-starting weight-to-reliability; warm in pocket for cold weather; altitude: works to ~3,000 m; carry two
FR4|fire steel + char cloth|ignition|50–100|very high (indefinite)|all conditions; char cloth must be kept dry|n/a|traditional method; char cloth catches spark at low temperature; can make char cloth in field from cotton
FR5|tinder (prepared)|fuel|10–50|high (if kept dry)|requires dry storage|1–5 min burn|cotton balls + petroleum jelly (best: burns 3–5 min, waterproof once lit); dryer lint; birch bark; fatwood; commercial fire starters; carry in waterproof bag
FR6|kindling|fuel|0 (gathered)|variable (depends on conditions)|must be dry; pencil-diameter dead twigs; standing dead wood preferred over ground wood|5–15 min|feather sticks (shaving dry stick to create curls) increase success in damp conditions; dead twigs from underside of conifers often dry even in rain; batoning to split wet wood exposes dry interior
FR7|fuel wood|fuel|0 (gathered)|high if dry|wrist-diameter to forearm-diameter; dead standing preferred; hardwood burns longer, softwood ignites faster|hours|three sizes: twig (kindling), thumb (transition), wrist+ (sustained); process from smallest to largest; never skip sizes; let each layer establish before adding larger
FR8|teepee fire|fire_type|—|—|good for quick heat, boiling water|30–60 min per load|tinder center; kindling teepee around; fuel logs leaned teepee-style; burns hot and fast; self-feeding as outer logs fall inward
FR9|log cabin fire|fire_type|—|—|good for cooking (flat top), sustained heat, coals|1–3 hours|parallel logs stacked alternating; tinder and kindling in center; creates coal bed; stable platform for pot; burns more slowly than teepee
FR10|long fire (reflector fire)|fire_type|—|—|best for warmth while sleeping; reflector directs heat|4–8 hours|two parallel logs with fire between; or fire against rock/log wall reflector; lie parallel to fire; heat radiates toward sleeper; requires thick logs for overnight
FR11|Dakota fire hole|fire_type|—|—|windy or concealment conditions; cooking|1–3 hours|two holes connected by tunnel underground; fire in one hole, air intake in other; low visibility; wind-resistant; efficient; pot sits on fire hole opening; requires diggable soil

# food_and_cooking(id|name|type|weight_per_day_g|calories_per_day|calorie_density_kcal_per_g|prep_required|storage_needs|notes)
FC1|freeze-dried meals|prepared|150–200 per meal (dry)|2,000–2,500 (3 meals)|4–5|add boiling water; wait 10–15 min|dry; rodent-proof container or bear canister|convenient; lightweight; variety; expensive (~$8–15/meal); high sodium; generates trash (foil pouches)
FC2|dehydrated staples|bulk ingredient|varies|custom|3–5 (rice, pasta, lentils, oats, dried fruit, jerky)|cook 10–30 min (varies by ingredient)|dry; bulk bags|cheaper than freeze-dried; customizable; heavier if long cook time foods (more fuel needed); requires meal planning
FC3|energy bars and trail mix|ready-to-eat|150–200 per serving|1,500–2,500 (if primary food)|4–5 (nuts, chocolate: up to 6)|none (eat from wrapper)|dry; no temperature sensitivity|no cook = no stove/fuel weight; calorie-dense; good for lunch/snack; monotonous if sole food; some melt in heat (chocolate)
FC4|peanut butter / nut butter|ready-to-eat|100–200 per serving|~600 per 100 g|6.0|none (spread or eat direct)|jar or squeeze tube; no refrigeration|highest calorie density of common trail foods; protein + fat; versatile (add to oats, tortillas, crackers); heavy per container but efficient per calorie
FC5|canister stove (isobutane)|cooking_system|100–200 (stove head) + 220–450 (canister)|—|—|screw onto canister; light; boil 0.5 L in 3–5 min|canister must stay upright; cold performance degrades below −7°C (invert-capable stoves exist)|simplest stove system; good for boiling water; flame adjustable; canister is waste (recyclable some areas); poor in extreme cold; altitude reduces output
FC6|alcohol stove|cooking_system|20–50 (stove) + fuel|—|—|pour fuel; light; no moving parts; boil 0.5 L in 5–10 min|fuel in leak-proof bottle (denatured alcohol, methanol)|ultralight; near-silent; cheap; no mechanical failure possible; slower boil; no flame control (some designs); cold weather: slower; restricted in fire-ban areas (open flame)
FC7|solid fuel stove (Esbit)|cooking_system|15–30 (stove) + tablets|—|—|place tablet; light; boil 0.5 L in 8–12 min|tablets in original packaging; residue on pot|lightest complete system; foolproof; no spill risk; slow; leaves residue; smells; limited flame control; good emergency backup
FC8|wood-burning stove|cooking_system|100–400|—|—|feed small sticks; boil 0.5 L in 5–10 min|no fuel to carry (uses found wood)|no fuel weight; unlimited fuel supply; charges USB (some models: BioLite); smoke; requires dry wood; banned in fire-restriction areas; sooty pots; requires attention
FC9|bear canister|food_storage|900–1,400|—|—|—|hard-sided cylinder; volume 8–12 L; fits ~5–7 days food|required in many bear areas (Sierras, RMNP, etc.); doubles as camp stool; heavy; bulky; reliable; animals cannot open
FC10|bear hang (PCT method / counterbalance)|food_storage|rope + carabiner + stuff sack: 100–200|—|—|—|50+ ft cord; two equal food bags; requires suitable tree (branch 6+ m high, 3+ m from trunk)|lighter than canister; free (no purchase); requires tall trees; skill needed; time-consuming; less reliable than canister (bears learn); not permitted where canisters required
FC11|Ursack (bear-resistant bag)|food_storage|200–250|—|—|—|Kevlar/Spectra bag; tie to tree with knot|lighter than canister; approved in some areas (not all — check regulations); bears can crush food (bag resists tearing, not compression); must be tied to tree

# navigation(id|name|type|weight_g|power_required|accuracy|limitations|skill_required|applications)
NV1|topographic map (paper)|map|50–100 per sheet|none|depends on scale (1:24,000 USGS = ~12 m per mm; 1:50,000 = ~25 m per mm)|degrades when wet (use waterproof map or map case); requires interpretation skill; static (no real-time position)|moderate: read contours, interpret terrain features, measure distance/bearing|primary navigation; backup to GPS; route planning; terrain association; emergency (no battery)
NV2|baseplate compass (orienteering)|compass|30–60|none|±2° (with good technique)|affected by local magnetic anomalies, metal objects, power lines; declination must be set or compensated|moderate: take bearing, follow bearing, triangulate position, orient map|primary direction-finding; used with map for full navigation; bearing following; triangulation; always carry as GPS backup
NV3|GPS device (handheld)|electronic|150–300 (with batteries)|batteries (AA or rechargeable): 15–30 hours typical|±3–5 m (open sky); ±10–15 m (forest canopy)|battery-dependent; slow fix under canopy; can fail (electronics); false sense of security if map skills lacking|low to moderate (device use is easy; map interpretation still needed)|position confirmation; track recording; waypoint navigation; breadcrumb trail; rescue coordination (coordinates)
NV4|smartphone + GPS app (Gaia, AllTrails, CalTopo)|electronic|included (phone already carried)|phone battery: 4–12 hours with GPS active (airplane mode + GPS extends dramatically)|±3–10 m|battery-dependent (most critical limitation); fragile; cold drains battery; touchscreen fails in rain/gloves|low (app use) to moderate (map interpretation)|convenient (already carrying); excellent offline maps; track recording; pre-loaded routes; photo waypoints; carry battery bank
NV5|altimeter (barometric)|instrument|included in many watches and GPS units|watch battery or GPS battery|±3–10 m (barometric, must be calibrated); drifts with weather change|pressure changes with weather (not just altitude); must recalibrate at known elevation regularly|low to moderate|elevation confirmation; identifies position on contour line (combined with compass bearing = position fix); weather trend detection (falling pressure = approaching storm)
NV6|natural navigation|technique|0|none|variable (sun: ±15°; stars: ±5°; vegetation: unreliable)|imprecise; requires clear sky (celestial); vegetation indicators vary by region|high (requires practice and knowledge)|backup when instruments fail; supplements compass; enriches outdoor experience; shadow stick method; North Star; Southern Cross; sun arc; prevailing wind indicators

# clothing(id|name|layer|material|weight_g|warmth|breathability|water_resistance|dry_time|when_to_use)
CG1|base layer top (lightweight)|base|merino wool (150–200 g/m²) or synthetic (polyester)|100–200|light (wicking, next-to-skin comfort)|excellent (both)|none (not the job of base layer)|merino: moderate; synthetic: fast|year-round; all activities; worn against skin; manages moisture
CG2|base layer top (midweight)|base|merino (200–260 g/m²) or synthetic grid fleece|150–250|moderate (more insulation than lightweight)|good to excellent|none|merino: moderate; synthetic: fast|cool to cold conditions; high-output activities in cold; sleep layer
CG3|base layer bottom (lightweight)|base|merino or synthetic|80–150|light|excellent|none|same as top|cool conditions; sleep comfort; under shell pants in rain/cold
CG4|insulating mid-layer (fleece)|mid|polyester fleece (100–300 weight)|200–400|moderate to high (depending on weight)|excellent|none (wind passes through)|very fast|active insulation in cold; camp warmth; versatile; durable; affordable; retains warmth when damp
CG5|insulating mid-layer (down jacket)|mid|goose down (700–900 FP) in nylon shell|200–400|very high for weight|poor (traps moisture if worn during high output)|DWR-treated shell resists light rain; fails in sustained wet|down: very slow if wet; synthetic: moderate|static insulation: camp, breaks, cold mornings; layered under shell in extreme cold; compress into stuff sack or hood pocket for storage; keep dry
CG6|insulating mid-layer (synthetic jacket)|mid|PrimaLoft, Climashield, or Polartec Alpha in nylon shell|250–500|high (slightly less than equivalent down)|moderate to good (Polartec Alpha: excellent active insulation)|DWR-treated shell; better than down in wet|moderate|wet conditions where down would fail; active insulation during cold high-output activity; more versatile than down in variable weather
CG7|wind shell|outer|ultralight nylon (7–20 denier) or Pertex Quantum|50–100|minimal (but dramatically reduces wind chill)|excellent (most are air-permeable enough for moderate activity)|DWR only; not waterproof|very fast|wind protection during exposed ridge walks, descents, cool evenings; weighs almost nothing; always carry; most underrated layer
CG8|waterproof shell (hardshell)|outer|Gore-Tex, eVent, Pertex Shield, proprietary WPB membranes|200–500|none (no insulation; warmth comes from layers underneath)|moderate (WPB membranes: 10,000–30,000+ g/m²/24h MVTR; always less breathable than non-WP)|fully waterproof (taped seams, waterproof zippers or storm flaps)|moderate (membrane slows evaporation)|rain; sustained wet conditions; snow; wind; always carry in pack; pit zips improve ventilation; size to fit over all layers
CG9|waterproof shell pants|outer|same as hardshell jacket materials|150–350|none|moderate|fully waterproof|moderate|rain; wet brush; snow; full-zip side entry allows putting on over boots/crampons; can skip if using water-resistant hiking pants + umbrella strategy
CG10|hiking pants (softshell / nylon)|lower body|nylon-elastane blend or softshell|200–400|light|excellent|DWR (light rain, dries fast); not waterproof|fast|general hiking; most conditions except sustained heavy rain; stretchy for mobility; zip-off legs = shorts option
CG11|sun shirt (UPF)|outer / base|lightweight polyester or nylon with UPF 30–50+|100–200|none|excellent|none|very fast|desert, high altitude, tropical, river; superior to sunscreen (no reapplication, no chemicals); long sleeves + collar; hooded versions
CG12|insulated pants|lower body|down or synthetic fill in nylon shell|200–400|very high|poor (meant for static use)|DWR on shell|slow if insulation wets|camp; rest stops; very cold conditions; static belays; sleeping in extreme cold
CG13|gaiters|accessory|nylon + elastic + strap|100–200|slight (keeps debris, snow, and moisture out of boots)|n/a|partial (keeps rain/snow from entering boot top)|—|snow travel; wet brush/grass; scree/sand; muddy trails; prevents debris in boots; low gaiters (trail runners) vs full gaiters (mountaineering)
CG14|hat (sun)|accessory|nylon or polyester; wide brim or legionnaire style|50–100|none|n/a|n/a|fast|sun protection; desert; high altitude; reduces heat load; cape-style protects neck
CG15|hat (insulating)|accessory|fleece, wool, or down|30–80|high (head loses significant heat due to blood flow)|varies|none to moderate|varies|cold conditions; sleeping; enormous warmth return for minimal weight; beanie or balaclava
CG16|gloves (liner + shell system)|accessory|liner: merino or synthetic; shell: Gore-Tex or softshell|50–150 (system)|moderate to high|liner: good; shell: varies|shell: waterproof; liner: none|liner: fast; shell: moderate|cold and wet conditions; liner alone for cool; add shell for rain/wind/snow; mittens warmer than gloves (shared finger warmth)

# footwear(id|name|type|weight_g_pair|ankle_support|waterproof|breathability|traction|break_in|when_to_use)
FW1|leather hiking boot|boot|1,000–1,800|high (above-ankle, stiff)|waterproof leather + membrane or wax treatment|poor to moderate|excellent (Vibram-type lug sole)|long (days to weeks)|heavy loads (>15 kg); off-trail; rocky terrain; ankle injury history; cold/wet conditions; mountaineering approach
FW2|synthetic hiking boot|boot|700–1,200|moderate to high|membrane-lined (Gore-Tex) or non-waterproof|moderate|good to excellent|short (days)|general backpacking; moderate loads; mixed terrain; faster break-in than leather; lighter than leather
FW3|trail runner|shoe|500–800|none (below-ankle)|most non-waterproof (preferred: breathable); some GTX versions|excellent (non-WP versions)|moderate to good|minimal (almost none)|ultralight backpacking; thru-hiking; day hiking; fast-and-light; trail running; lighter loads (<12 kg); dries faster than boots; requires strong ankles or adaptation period
FW4|approach shoe|shoe|600–900|none to low|usually non-waterproof|moderate|excellent (sticky rubber; climbing-zone toe)|short|scrambling; rocky terrain; via ferrata approach; technical trail; preference for more precision on rock than trail runner
FW5|camp shoe / sandal|camp|100–300|none|n/a|n/a|minimal|none|give feet rest in camp; river crossings (protect feet, drain water); let boots dry; Crocs, flip-flops, or sport sandals; multi-use: camp + river crossings
FW6|sock (merino wool hiking)|sock|50–80 per pair|—|—|good (merino manages moisture)|—|—|primary hiking sock; carry 2–3 pairs; merino resists odor (can wear multiple days); cushioned sole; moisture management prevents blisters; no cotton ever
FW7|sock (liner)|sock|20–40|—|—|excellent (wicks away from skin to outer sock)|—|—|reduces friction between skin and hiking sock; silk or thin synthetic; blister prevention; optional if outer sock fits well
FW8|gaiter (low/trail)|accessory|40–80|—|—|—|—|—|keeps debris out of trail runners and low-cut shoes; essential with trail runners on dusty/sandy/gravelly terrain; Dirty Girl or similar

# packing(id|name|type|volume_L|weight_g|frame|load_capacity_kg|features|when_to_use)
PK1|ultralight frameless pack|backpack|30–45|200–500|none (foam pad serves as frame)|5–10|roll-top; minimal pockets; light fabric (Dyneema, X-Pac, Robic); hipbelt optional or minimal|ultralight (base weight <5 kg); thru-hiking; experienced packers; requires careful weight management
PK2|lightweight framed pack|backpack|45–60|800–1,500|internal frame (stays or framesheet)|10–18|hipbelt transfers load; compression straps; hydration compatible; lid or roll-top; side/front pockets|general 3-season backpacking; 2–7 day trips; most popular type; balances weight and carrying comfort
PK3|expedition pack|backpack|60–85|1,500–3,000|internal frame (robust stays, hipbelt, load lifters)|18–30|multiple compartments; gear loops; crampon attachments; removable lid/daypack|winter; extended trips (7+ days); heavy group gear; mountaineering; when load exceeds 18 kg
PK4|daypack|backpack|15–30|300–800|none or minimal framesheet|5–10|simple; hydration compatible; rain cover pocket; hip belt optional|day hikes; summit bag (leave main pack at camp); travel; urban
PK5|stuff sack (waterproof)|organization|1–30|10–50 per sack|—|—|roll-top closure; silnylon or DCF; color-coded by category|organize gear inside pack; waterproof critical items (sleeping bag, electronics, first aid); compression sacks reduce volume for sleeping bags and clothing
PK6|dry bag|waterproof storage|5–40|30–150|—|—|roll-top; welded seams; PVC or TPU-coated nylon|river crossings; kayaking; rain; canoe portage; camera/electronics protection; guaranteed waterproof when properly sealed

# terrain(id|name|type|difficulty|hazards|footwear|technique|navigation_notes)
TN1|maintained trail (graded)|trail|easy to moderate|tripping (roots, rocks); erosion steps; slippery when wet|any (trail runners to boots)|stay on trail to prevent erosion; follow blazes/cairns; switchbacks: don't cut|follow blazes, cairns, signs; trail junctions require attention
TN2|unmaintained trail (social/game trail)|trail|moderate|faint tread; deadfall; overgrowth; wrong turns|boots or sturdy trail runners|bushwhack sections; step over deadfall; GPS track helps; game trails may dead-end|GPS helpful; map and compass essential; terrain association (match ground to map) critical
TN3|off-trail (cross-country)|no trail|moderate to hard|route-finding error; cliff-outs; unstable ground; exhaustion from slow travel|boots (ankle support for uneven ground)|plan route on map first; follow ridgelines, drainages, or contour lines; avoid cliffy terrain visible on map (closely spaced contours)|expert map reading; GPS waypoints pre-loaded; altimeter confirms elevation; terrain association mandatory
TN4|river/stream crossing|water|moderate to extreme (current-depth-temperature)|drowning; hypothermia; loss of gear; foot entrapment|water shoes or camp sandals (not barefoot); boots for crossing if serious|face upstream; use trekking pole(s) as third point; unbuckle pack hipbelt and sternum strap (quick release if swept); cross at widest/shallowest point; diagonal upstream angle; never cross above waterfall or strainer|scout crossing from above first; early morning = lowest flow (snowmelt peaks afternoon)
TN5|talus / scree|rocky|moderate to hard|twisted ankles; rockfall; falling; unstable surface|boots with ankle support (preferred) or approach shoes|talus (large blocks): hop between stable-looking rocks; test before committing weight; scree (small loose): descend by scree-running (controlled slide); ascend by zig-zagging; avoid knocking rocks onto people below|cairns may mark route; direct line often not best — look for stable rock bands
TN6|snow travel (non-technical)|snow|moderate to hard|postholing; snow bridges over streams; avalanche (on slopes >25°); sun blindness; navigation difficulty (everything looks same)|boots with gaiters; microspikes or light crampons; snowshoes if deep|kick steps ascending; plunge step descending; glissade (controlled slide on butt) with ice axe self-arrest backup; early morning = firm consolidated snow; afternoon = soft postholing|landmarks buried; GPS essential; contour navigation; wand marking for whiteout return
TN7|desert travel|arid|moderate to extreme|dehydration (primary threat); heat exhaustion/stroke; flash flood; exposure (no shade); navigation (few features); venomous creatures|light boots or trail runners; gaiters for sand|travel early morning and late afternoon; rest in shade midday; water caching; carry minimum 4 L and know every water source; long sleeves + sun hat; never enter slot canyons with upstream rain forecast|map every water source; GPS waypoints for water; distance between sources determines feasibility; 1 L per 3 km walking is minimum in heat
TN8|scrambling (Class 2–3)|rock|hard|falling; exposure (height); rockfall; route-finding error|approach shoes or boots with good sole|hands for balance (Class 2) or hands for actual holds (Class 3); three points of contact; test holds; helmet if rockfall risk; retreat if above comfort/skill|route may not be marked; look for wear marks on rock (boot rubber); cairns; stay on the path of least resistance

# weather(id|name|type|indicators|risks|response)
WX1|approaching cold front|synoptic|barometer falling; cirrus clouds → altostratus → cumulonimbus; wind shift (S/SW → W/NW); temperature drops rapidly after passage|thunderstorms before front; cold rain or snow; high winds; rapid temperature drop|shelter before arrival; secure tent (guy lines, stakes); waterproof gear accessible; carry extra insulation for post-frontal cold
WX2|approaching warm front|synoptic|barometer falling slowly; high clouds (cirrus → cirrostratus → altostratus → nimbostratus); steady light-to-moderate rain for hours; gradual temperature rise|prolonged rain/drizzle (can last 12–24 hours); fog; low visibility; saturated ground|waterproof everything; plan for wet trails; don't camp in drainages; tent ventilation to manage condensation
WX3|thunderstorm|convective|cumulus building vertically (cumulonimbus); anvil shape; 30-30 rule (flash-to-bang < 30 s = within 10 km; wait 30 min after last thunder)|lightning strike (primary lethal threat); flash flood; hail; strong downdraft winds; hypothermia from cold rain|descend from ridges, summits, exposed terrain; avoid lone trees, water, metal objects; lightning crouch (feet together, squat, ears covered) if caught above treeline; get into forest (uniform height trees) if possible
WX4|wind chill|temperature effect|use wind chill chart: 0°C + 30 km/h wind = feels −7°C; −10°C + 40 km/h wind = feels −23°C|frostbite (exposed skin); hypothermia acceleration; reduced manual dexterity|wind shell (CG7) is most effective first response; shelter from wind; face protection; keep extremities covered
WX5|heat index|temperature effect|temperature + humidity; 35°C + 60% RH = heat index ~43°C|heat exhaustion (heavy sweating, weakness, nausea, headache); heat stroke (confusion, hot dry skin, emergency)|hydrate aggressively; electrolytes; shade; wet clothing; reduce pace; rest during peak heat (11:00–15:00); recognize heat stroke as life-threatening emergency
WX6|whiteout|visibility|snow + wind + overcast = featureless white; no horizon, no shadows, no depth perception; disorientation|navigation failure; cliff/cornice edge walking; exhaustion from disorientation; separation from group|stop if disoriented; use compass/GPS for straight-line navigation; wand marking on approach (follow back); rope team for glacier/slope; stay put if truly lost
WX7|flash flood|precipitation event|heavy rain (even distant) in narrow drainage; water rises extremely fast (minutes); debris flow; slot canyons most dangerous|drowning; impact from debris; stranding; gear loss|never camp in wash bottoms; exit slot canyons before rain; camp above flood line; watch for upstream rain; if caught: climb immediately — 2 m vertical saves life
WX8|fog|visibility|radiation fog (overnight cooling, valley bottoms, morning); advection fog (warm moist air over cold surface); dissipates with sun/wind|navigation error; getting lost; wet gear (persistent moisture); hypothermia (wet + wind)|compass navigation; GPS; stay on trail; reflective gear if near roads; fog often lifts by mid-morning — wait if safe

# hazards(id|name|type|region|severity|prevention|response)
HZ1|hypothermia|environmental|any (cold + wet + wind; most common at 0–10°C with rain, not extreme cold)|life-threatening|stay dry (most important); eat and drink (fuel for thermogenesis); layer properly; recognize early symptoms in self and others (shivering, confusion, slurred speech, loss of dexterity)|stop and shelter; remove wet clothing; insulate (sleeping bag, pad, emergency blanket); warm drinks (not alcohol); body-to-body contact in bag if severe; evacuate if altered mental status
HZ2|hyperthermia (heat stroke)|environmental|hot climate; desert; humid tropical|life-threatening|hydrate proactively; electrolytes; shade; reduce exertion in heat; acclimatize (3–7 days); recognize heat exhaustion before it progresses|cool immediately: shade, remove clothing, wet skin + fan (evaporative cooling); ice packs at neck, armpits, groin; evacuate — heat stroke is medical emergency (core temp >40°C)
HZ3|dehydration|environmental|any; accelerated at altitude, in heat, during high exertion|performance-degrading → life-threatening|drink before thirsty (0.5–1 L per hour during exertion); urine color monitor (pale yellow = good; dark = dehydrated); electrolytes in heat/long days|rest; drink; add electrolytes; reduce pace; shade; severe: evacuate (IV fluids may be needed)
HZ4|altitude sickness (AMS)|altitude|above 2,400 m; risk increases with rate of ascent and altitude|moderate → life-threatening (HACE, HAPE)|ascend slowly (max 300–500 m sleeping altitude gain per day above 3,000 m); hydrate; acclimatize (rest day every 3rd day); acetazolamide (Diamox) prophylaxis|descend immediately if symptoms worsen (headache, nausea, vomiting, ataxia, confusion); descent of even 300–500 m usually brings rapid improvement; HACE/HAPE are emergencies: descend, supplemental O₂, dexamethasone (HACE), nifedipine (HAPE)
HZ5|blisters|mechanical|any terrain; wet conditions worsen|performance-degrading (can end trip)|proper boot/shoe fit; break in footwear before trip; moisture management (merino socks, liner socks, foot powder); address hot spots immediately (before blister forms)|hot spot: tape with Leukotape or moleskin immediately; formed blister: do not drain unless causing gait change; if draining: sterilize needle, drain edge, leave roof intact, dress with antibiotic + Leukotape; change socks
HZ6|bear encounter (black bear)|wildlife|North America (widespread); forested, montane|moderate (rarely fatal; defensive attacks)|proper food storage (FC9, FC10, FC11); cook and eat 60+ m from camp; no food odors in tent; make noise on trail; carry bear spray (if in bear country)|make yourself large; shout; do not run (triggers chase); back away slowly; if black bear attacks: fight back (punch, kick, rocks); bear spray at 5–10 m range (aim slightly below face for rising cloud)
HZ7|bear encounter (grizzly)|wildlife|western North America; Alaska; limited lower-48 (Yellowstone, Glacier, etc.)|serious (can be fatal)|same food storage as black bear; travel in groups; make noise; carry bear spray (most effective deterrent: 92% success rate in studies)|do not run; speak calmly; back away slowly; if grizzly charges: bear spray at 5–10 m; if contact: play dead (face down, hands behind neck, legs spread, pack on); if predatory attack (stalking, nighttime): fight back
HZ8|snake bite (venomous)|wildlife|varies by species; mostly temperate to tropical; warm months|moderate to serious|watch where hands and feet go; step on logs not over them; shake out boots and bags; don't reach into holes/crevices|stay calm; immobilize limb; remove rings/watches (swelling); evacuate to hospital (antivenin); do NOT: cut, suck, tourniquet, ice, alcohol; time is non-critical for most pit viper bites (hours, not minutes), but sooner is better
HZ9|tick-borne disease|insect-borne|temperate forests, grasslands; spring-fall; Lyme (NE US, upper Midwest), Rocky Mountain spotted fever (SE US), tick-borne encephalitis (Europe/Asia)|moderate (treatable if caught early)|permethrin-treated clothing (kills ticks on contact); DEET or picaridin on skin; tuck pants into socks; tick checks every evening (full body); light-colored clothing (easier to spot ticks)|remove tick with fine-tipped tweezers (grasp at skin, pull straight out steadily); clean site; save tick (identification); watch for rash (bullseye = Lyme — seek treatment immediately: doxycycline)
HZ10|lightning|environmental|exposed terrain: ridges, summits, open water, isolated trees|life-threatening|descend before storm arrives (watch clouds, check forecast); 30-30 rule; avoid exposed terrain, water, metal objects, tall isolated features|if caught above treeline: descend or find depression; lightning crouch (feet together, squat on balls of feet, ears covered); spread group out (5+ m apart); seek uniform forest if possible; avoid shallow caves (ground current)
HZ11|river/water hazard|terrain|any crossing; especially snowmelt-fed or rain-swollen|life-threatening (drowning, hypothermia)|scout crossing; don't cross if water above knee and current is strong; unbuckle pack; use trekking poles; don't cross above strainers, waterfalls, or rapids; early morning crossing (lower flow)|if swept: jettison pack if necessary; float on back feet-first downstream; work toward eddy or shallow water; do not try to stand in fast water (foot entrapment → death)
HZ12|falling tree/branch (widowmaker)|terrain|forested areas; wind; dead trees|serious to fatal|don't camp under dead trees or large dead branches; look up when selecting campsite; avoid forest edge in high wind (trees most exposed)|no response possible during event; prevention is everything; always look up at campsite

# first_aid(id|name|type|symptoms|treatment|gear_needed|evacuation_trigger)
FA1|wound care (laceration/abrasion)|trauma|bleeding; broken skin; pain|control bleeding (direct pressure); irrigate (clean water, pressure syringe); remove debris; close with butterfly strips or wound closure strips if clean linear cut; dress (gauze + tape or adhesive bandage); monitor for infection (redness spreading, warmth, pus, red streaks)|wound closure strips, gauze, tape, antiseptic wipes, irrigation syringe, nitrile gloves|deep wound (fat or muscle visible); won't stop bleeding after 15 min direct pressure; signs of infection after 24–48 hours; wound on face or over joint
FA2|sprain (ankle/knee)|musculoskeletal|pain, swelling, bruising, limited range of motion; weight-bearing ability determines severity|RICE adapted to field: Rest (reduce load), Ice (cold stream water), Compression (elastic bandage), Elevation; assess weight-bearing; tape for support; trekking poles reduce load; ibuprofen for inflammation|elastic bandage (ACE), tape, trekking poles, ibuprofen|cannot bear weight after rest and taping; suspected fracture (deformity, crepitus, point tenderness); knee injury with instability
FA3|blister treatment|skin|fluid-filled pocket; hot spot precedes blister|hot spot: immediate tape (Leukotape preferred); blister formed: if small/painless leave intact; if large/painful: drain (sterilize needle, puncture edge, leave roof, apply antibiotic, cover with Leukotape wrapping around foot); change dressing daily|Leukotape, moleskin, sterile needle, antibiotic ointment, alcohol wipe|infection signs (spreading redness, pus, red streaks, fever)
FA4|hypothermia treatment|environmental|mild: shivering, cold extremities, reduced dexterity, poor judgment; moderate: violent shivering → shivering stops, confusion, drowsiness, paradoxical undressing; severe: unconscious, weak pulse, very cold|mild: shelter, remove wet clothes, insulate, warm drinks, gentle exercise; moderate: as above + prevent further heat loss + body-to-body contact in sleeping bag; severe: handle gently (cardiac irritability), insulate, evacuate|sleeping bag, sleeping pad, emergency blanket, dry clothing, insulated flask for warm drinks|any altered mental status; shivering stops without rewarming; unconsciousness; core temp <32°C estimated
FA5|heat exhaustion / heat stroke treatment|environmental|heat exhaustion: heavy sweating, weakness, nausea, headache, dizziness, pale/clammy skin, normal-to-slightly-elevated temperature; heat stroke: confusion, altered mental status, hot/red/dry skin, temperature >40°C, seizure|heat exhaustion: shade, rest, cool skin (wet clothing, fan), drink water + electrolytes, elevate legs; heat stroke: EMERGENCY — cool immediately and aggressively (immerse in cold water if available, ice packs at neck/armpits/groin, wet + fan)|water, electrolytes, shade-making material (tarp), thermometer if available|heat stroke: immediate evacuation; heat exhaustion: evacuate if not improving within 30 min or if confusion develops
FA6|allergic reaction / anaphylaxis|immune|mild: localized hives, itching, swelling; anaphylaxis: throat swelling, difficulty breathing, drop in blood pressure, rapid pulse, widespread hives, dizziness|mild: oral antihistamine (diphenhydramine 25–50 mg); anaphylaxis: epinephrine auto-injector (EpiPen) into outer thigh immediately; then antihistamine; monitor airway; prepare for second dose (biphasic reaction possible)|antihistamine (Benadryl), EpiPen (anyone with known allergy; consider carrying for group), nitrile gloves|anaphylaxis: evacuate immediately even if EpiPen provides relief (observation needed for biphasic reaction); any difficulty breathing
FA7|fracture (suspected)|musculoskeletal|deformity, crepitus (grinding), point tenderness, swelling, inability to bear weight, angulation|immobilize above and below injury; pad splint; check circulation distal to injury (pulse, sensation, color) before and after splinting; manage pain (ibuprofen + acetaminophen); treat for shock if needed|SAM splint (moldable aluminum), tape, elastic bandage, padding (clothing), trekking poles (as impromptu splint), triangle bandage (sling)|all suspected fractures need evacuation; femur/pelvis/spine: do not move unless life threat at current location; call for rescue

# knots(id|name|type|strength_retention|difficulty|uses|notes)
KN1|bowline|loop (fixed)|60–70%|moderate|rescue loop around person; tie to anchor; bear hang; non-slip loop at end of rope|does not slip or bind under load; easy to untie after loading; learn one-handed tie; "the rabbit comes out of the hole, around the tree, and back in the hole"
KN2|clove hitch|hitch|60–65%|easy|attach rope to post/pole/carabiner; tarp guyline to pole; adjustable; quick to tie and untie|can slip under variable/cyclic load; use as temporary or add half-hitches for security; adjustable (slide to tension)
KN3|taut-line hitch|hitch|—|moderate|tension adjustment on guylines (tent, tarp, ridge line); adjustable grip on rope under tension|slides to adjust tension but grips under load; self-locking; essential tent/tarp knot; Midshipman's hitch variant more secure
KN4|trucker's hitch|compound (mechanical advantage)|—|moderate to hard|bear hang (high tension); tarp ridgeline; lashing loads; creating mechanical advantage on rope|creates 3:1 (theoretical) mechanical advantage; compound knot: loop (Alpine butterfly or slip knot) + redirect + tie-off; most useful backcountry knot for creating tension
KN5|figure-eight on a bight|loop (fixed)|75–80%|easy|climbing anchor; fixed loop; end-of-rope stopper; connecting to carabiner|strongest common loop knot; easy to inspect visually (critical for safety); slightly harder to untie after heavy loading than bowline
KN6|square knot (reef knot)|binding|45–50%|easy|binding bandages; tying two ends of same rope around object; bundling|not for joining two ropes under tension (can capsize and slip); only for binding (around an object); flat profile
KN7|sheet bend|joining|45–55%|easy|joining two ropes of different diameter; extending guylines|will slip if ropes are very different material (add double sheet bend); works where square knot would fail
KN8|prusik hitch|friction hitch|—|moderate|ascending rope; backup on rappel; tensioning ridgeline; adjustable grip on fixed rope|tied with thinner cord around thicker rope; grips when loaded, slides when unloaded; 3 wraps minimum; cord must be thinner than rope
KN9|Alpine butterfly|mid-line loop|75%|moderate|mid-rope loop for clipping; isolating damaged section of rope; multi-point anchor|strong in all three directions (both ends + loop); easy to untie after loading; better than figure-eight on a bight for mid-rope

# tools(id|name|type|weight_g|functions|notes)
TL1|fixed-blade knife (4–5 inch)|cutting|100–250|cutting cordage, food prep, batoning (splitting wood), feather sticks, first aid, general camp tasks|most important single tool; full tang for strength; carry always; 4–5 inch blade is versatile sweet spot; plain edge preferred (easier to sharpen in field)
TL2|folding knife / multitool|cutting + multi|100–250|backup cutting, screwdrivers, pliers, scissors, can opener, file|Swiss Army Knife or Leatherman-type; more tools but weaker blade than fixed; good complement to fixed blade; pliers invaluable for pot-lifting, repairs, tick removal
TL3|saw (folding)|cutting|100–200|cutting branches for shelter, firewood processing, clearing deadfall from trail|Silky-type pull-cut saw; cuts wood faster and more safely than batoning for diameter > wrist; useful in established camp; not essential for lightweight/fast trips
TL4|trekking poles (pair)|mobility + multi|300–600 (pair)|balance on terrain, reduce knee impact (descending), river crossing stability, tent/tarp support, splint, snow probe, defense|adjustable (telescoping) or folding; cork or foam grips; carbide tips; reduce compressive load on knees by ~25%; essential for heavy packs, bad knees, river crossings, or tarp/tent that requires poles
TL5|repair kit|maintenance|50–150|sleeping pad patch, tape (duct + tenacious), needle + thread, safety pins, cordage, buckle replacement, pole sleeve|small but critical; duct tape wrapped around trekking pole or water bottle (saves weight of roll); Tenacious Tape for fabric repair; carry needle + dental floss (strong thread); a broken zipper or torn tent in remote area = emergency without repair kit
TL6|headlamp|illumination|30–100 (with batteries)|night hiking, camp tasks, navigation, signaling, night emergency|200+ lumens for hiking; 30 lumens sufficient for camp; red light mode preserves night vision; carry spare batteries; strap around water bottle = lantern; always carry even on day hikes (unplanned bivy)
TL7|cordage (paracord or equivalent)|multi|50–100 (15–30 m)|bear hang, shelter guylines, clothesline, gear repair, lashing, emergency (inner strands as thread/fishing line)|550 paracord: 7 inner strands, 250 kg breaking strength; alternatives: Dyneema cord (stronger, lighter, no stretch) or bank line (lighter, UV-resistant); carry 15–30 m minimum
TL8|whistle|signaling|5–10|emergency signal (3 blasts = distress); bear deterrent (limited); getting attention of group members|louder and longer-lasting than voice (carries 1+ km); works when voice fails (hypothermia, exhaustion); always on person (not in pack); pealess whistle (works when wet/frozen)
TL9|emergency shelter / space blanket|survival|50–150|retain body heat; emergency ground sheet; signal (reflective); rain protection; wind break|weighs almost nothing; carry always on every hike; orange or reflective preferred; upgrade: emergency bivy (SH8) weighs ~100 g and is more effective than flat blanket

# hygiene(id|name|type|method|supplies|notes)
HY1|water source protection|LNT principle|camp and relieve yourself 60+ m (200 ft) from any water source; wash (dishes, self) 60+ m from water; strain dishwater and scatter broadly|—|most important single hygiene practice; protects water for everyone downstream; non-negotiable
HY2|cat hole (solid waste)|waste disposal|dig hole 15–20 cm deep, 10–15 cm diameter; deposit; cover and disguise; 60+ m from water, trail, and camp|lightweight trowel (30–50 g)|pack out toilet paper in high-use areas (zip-lock bag + hand sanitizer); in some areas (desert, alpine, high-use) pack out all solid waste (WAG bag)
HY3|hand hygiene|personal|hand sanitizer (60%+ alcohol) after bathroom, before eating, before water purification; proper handwashing when water available|hand sanitizer (30–60 mL: lasts ~1 week); biodegradable soap (small dropper bottle)|most important personal hygiene for illness prevention; GI illness is leading cause of trip-ending medical issue
HY4|body washing|personal|biodegradable soap + water, carried 60+ m from water source; sponge bath with bandana; don't enter water with soap/sunscreen|biodegradable soap (2–5 mL per wash); bandana; collapsible water container|full wash every 2–3 days minimum; daily feet, groin, armpits; prevents skin breakdown and infection; morale booster
HY5|dish washing|camp|scrape food residue (pack out); hot water + small amount biodegradable soap; rinse; strain dishwater (remove particles); broadcast liquid 60+ m from water|small sponge or scrub pad; biodegradable soap; mesh strainer|food residue attracts animals; strain and scatter is critical; food particles packed out with trash
HY6|menstrual hygiene|personal|menstrual cup (reusable, empty into cat hole), or tampons/pads (pack out all — do not bury; double-bag in opaque zip-lock)|menstrual cup or preferred products; zip-lock bags; hand sanitizer; wipes|pack out all menstrual products (they are not biodegradable in wilderness timeframes); treat as bear-attractant (store with food); cup minimizes waste and pack-out volume

# planning(id|name|type|timing|key_actions|notes)
PL1|route planning|pre-trip|weeks to months before|select route matching fitness and skill; study topo maps; calculate distance + elevation gain per day; identify water sources, campsites, escape routes, resupply points; check permit requirements|daily distance target: 15–25 km on trail (varies with elevation gain: subtract 1 km per 100 m climb from flat distance capacity); first and last days shorter
PL2|fitness preparation|pre-trip|months before|train with loaded pack on terrain similar to trip; progressive increase in distance and weight; stair climbing for elevation; focus on feet (break in shoes)|most injuries and trip failures are fitness-related; training with actual pack and shoes is essential; don't start a 7-day trip as your first backpacking experience
PL3|gear shakedown|pre-trip|weeks before|assemble all gear; weigh every item; eliminate duplicates; identify multi-use items; test new gear (tent setup, stove operation, water filter); do overnight test trip|target base weight (everything except consumables): <7 kg ultralight; <10 kg lightweight; 10–15 kg traditional; >15 kg heavy (reexamine choices)
PL4|trip plan / itinerary|pre-trip + safety|day before departure|write detailed plan: dates, route, campsites each night, expected return time, vehicle location, emergency contacts; leave copy with responsible person not on trip|this is your search-and-rescue trigger; if you don't return by stated time, responsible person initiates contact; include: number in group, vehicle description, planned entry/exit trailheads
PL5|permit and regulation check|pre-trip|months before (popular areas)|check land management agency (NPS, USFS, BLM, state parks); wilderness permits; bear canister requirements; fire restrictions; group size limits; camping zone restrictions|many popular areas require advance reservation (months ahead); some have quota systems (lottery); fire restrictions change seasonally; check one week before departure for current conditions
PL6|weather and conditions check|pre-trip + active|24–72 hours before + daily in field|check forecast for trip area; NOAA point forecast (US); check trail condition reports (recent trip reports, ranger station); avalanche forecast (winter); river levels (spring)|weather changes everything: adjust route, add/remove gear, postpone if dangerous; mountain weather can differ dramatically from valley forecast; check elevation-specific forecast
PL7|group management|active|during trip|assign roles (navigator, sweep, first aid); establish pace (slowest member sets pace); maintain visual or voice contact; brief daily plan each morning; check in on each group member's condition|group moves at speed of slowest member; getting separated is preventable emergency; buddy system for water and hazards; democratic decisions on route changes; any member can call halt for safety
PL8|Leave No Trace (7 principles)|ethic|always|plan ahead and prepare; travel on durable surfaces; dispose of waste properly; leave what you find; minimize campfire impacts; respect wildlife; be considerate of other visitors|not optional; these are the shared ethic of wilderness use; fire is the most commonly violated (fire rings, burn scars, log damage); pack out all trash including microtrash (tape, wrappers, food bits)

# signals(id|name|type|method|range|conditions|notes)
SG1|whistle (3 blasts)|auditory|3 short blasts, pause, repeat; universally recognized distress signal|0.5–2 km (depending on terrain and wind)|works in fog, darkness, forest; reduced by wind|pealess whistle works wet/frozen; on person always (not in pack); voice fails from exhaustion/hypothermia — whistle does not
SG2|mirror signal|visual|flash reflected sunlight toward rescuers or aircraft; use signal mirror or any reflective surface; sweep horizon|up to 15 km (aircraft visible from further)|requires sun and line of sight to target|aiming: look through hole in mirror, place bright spot on hand, align hand with target; most effective long-range ground-to-air signal
SG3|fire signal|visual/thermal|three fires in triangle (international distress); green branches on hot fire = smoke (daytime); bright flame (nighttime)|visible for kilometers (smoke column in still air: 10+ km)|requires fire-making materials and ability; smoke best in clear air; fire best at night|also provides warmth while waiting for rescue; maintain through night
SG4|ground-to-air signals|visual|stomp/arrange symbols in open area: V = need assistance; X = need medical; → = traveling this direction; use contrasting materials (rocks on snow, branches on sand)|visible to aircraft from hundreds of meters|requires open clearing visible from above; works in conjunction with other signals|make symbols minimum 3 m long; high contrast with ground; can use clothing, branches, rocks, stamped snow
SG5|PLB (personal locator beacon)|electronic|activate → sends GPS position + distress signal via Cospas-Sarsat satellite network to rescue coordination center|global coverage (satellite)|works anywhere with sky view; dedicated emergency device; no subscription for basic 406 MHz PLB; registered to owner|one-way: sends signal but no confirmation or communication; battery: 24–48 hours continuous; register with NOAA; test annually; carry when beyond cell coverage
SG6|satellite messenger (inReach, SPOT)|electronic|two-way text messaging via satellite; SOS button triggers rescue coordination|global coverage (Iridium for inReach; Globalstar for SPOT)|works anywhere with sky view; requires subscription ($12–65/month)|two-way communication: can coordinate with rescuers, update contacts, receive weather; tracking (share location with family); SOS is one-button rescue trigger; heavier and more expensive than PLB but far more functional
SG7|cell phone (if signal)|electronic|call 911/emergency; text (lower bandwidth requirement: may work where voice fails); GPS coordinates via phone|varies wildly (ridgetops may have signal; valleys rarely)|cell coverage only; battery-dependent; cold drains battery|phone is not a reliable emergency communication device in wilderness; always carry independent signaling (whistle, mirror, PLB/messenger); put in airplane mode to save battery; know coordinates if you can call (GPS works without cell signal)

# flora_fauna_awareness(id|name|type|identification|risk|response|region)
FF1|poison ivy / poison oak / poison sumac|plant (contact dermatitis)|leaves of three (ivy/oak); smooth leaflets (ivy) or lobed (oak); sumac: 7–13 leaflets on red stem; urushiol oil on all plant parts; all seasons (even dormant stems)|contact causes itchy blistering rash (24–72 hours after exposure); severity increases with repeated exposures; can spread from contaminated clothing/gear|wash with soap and cold water within 30 min of contact; wash all clothing and gear that contacted plant; calamine lotion and antihistamine for itch; severe: oral steroids (prescription)|North America (ivy: eastern/central; oak: western; sumac: eastern wetlands)
FF2|stinging nettle|plant (contact urticaria)|heart-shaped serrated leaves; tiny hairs on stem and underside of leaves; grows in moist disturbed soil|immediate burning/stinging rash on contact; subsides in hours (usually); not dangerous|dock leaf (Rumex) rubbed on area (traditional); wash; antihistamine cream; avoid scratching; pain is self-limiting|temperate worldwide
FF3|mosquitoes|insect (vector)|familiar; breed in standing water; most active dawn and dusk; attracted to CO₂, heat, sweat, dark clothing|annoyance; disease vector (malaria, dengue, Zika, West Nile depending on region)|DEET 20–30% or picaridin 20% on skin; permethrin on clothing; head net; long sleeves at dawn/dusk; camp away from standing water; no-see-um mesh on tent|worldwide (worst: tropical, subarctic summer, near standing water)
FF4|ticks|arachnid (vector)|small (2–5 mm); attach and feed for hours/days; found on vegetation (brushing against); most active spring-fall; nymph stage hardest to detect|Lyme disease, Rocky Mountain spotted fever, tick-borne encephalitis, alpha-gal allergy, others depending on region|see HZ9 (prevention and removal); permethrin-treated clothing most effective; daily tick checks; prompt removal (<24 hours) greatly reduces Lyme transmission|temperate forests and grasslands worldwide
FF5|bears (black and grizzly)|mammal (large predator)|see HZ6 and HZ7|see HZ6 and HZ7|see HZ6 and HZ7|North America; European brown bear in Scandinavia, Balkans; Asian black bear
FF6|mountain lion / cougar|mammal (ambush predator)|large (50–100 kg); solitary; stalks prey; rarely seen; attacks from behind; most active dawn/dusk/night|rare but serious (attacks occasionally fatal, especially children and solo hikers)|do not run (triggers chase instinct); face the animal; make yourself large (raise arms, open jacket); shout; throw rocks; fight back aggressively if attacked; never play dead; keep children close|western North America; Florida (panther)
FF7|moose|mammal (large ungulate)|very large (400–700 kg); appear docile but highly aggressive when surprised, with calves, or in rut (fall)|trampling, goring; more injuries than bears in some regions (Alaska)|give wide berth (30+ m); if moose charges: run (unlike bears — moose usually don't pursue far); get behind tree or large obstacle; signs of agitation: ears back, hackles raised, lip licking, head lowered|northern North America; Scandinavia; Russia
FF8|venomous snakes|reptile|varies by species: rattlesnake (rattle, triangular head, pit), copperhead (hourglass pattern), coral snake (red-yellow-black bands), adders/vipers (various)|see HZ8|see HZ8|worldwide except Ireland, Iceland, NZ, Antarctica; highest diversity in tropics

# concepts(id|name|definition|category)
CC1|layering system|clothing strategy: base layer (moisture management), mid layer (insulation), outer layer (weather protection); each layer has specific function; system adjustable by adding/removing layers|clothing
CC2|base weight|total weight of pack minus consumables (food, water, fuel); primary metric for pack weight management; ultralight: <4.5 kg; lightweight: <7 kg; traditional: 7–14 kg|packing
CC3|skin-out weight|everything on your person and in your pack including consumables; true carried weight; relevant for daily energy expenditure and joint stress|packing
CC4|ten essentials|always-carry items regardless of trip length: navigation (map+compass), sun protection, insulation (extra clothing), illumination (headlamp), first aid, fire (lighter+tinder), repair kit+tools, nutrition (extra food), hydration (extra water), emergency shelter|planning
CC5|Leave No Trace|ethical framework: plan ahead; travel on durable surfaces; dispose of waste properly; leave what you find; minimize campfire impacts; respect wildlife; be considerate of others|ethic
CC6|HYOH (hike your own hike)|principle: each hiker's pace, style, gear choices, and goals are their own; no single correct approach; respect individual choices while maintaining group safety|ethic
CC7|caloric deficit|in backcountry, expenditure (3,000–5,000 kcal/day for strenuous hiking) typically exceeds intake; acceptable for trips <7 days; beyond that, caloric debt degrades performance significantly|food
CC8|cotton kills|cotton absorbs and retains moisture; wet cotton conducts heat 25× faster than dry; loses all insulation when wet; extremely dangerous in cold/wet; never wear cotton in backcountry except desert (evaporative cooling exception)|clothing
CC9|Type 2 fun|not enjoyable during the experience (suffering, challenge, discomfort) but rewarding in retrospect; much of wilderness travel falls here; builds resilience and lasting satisfaction|philosophy
CC10|situational awareness|continuous assessment of environment, weather, group condition, terrain, time, and own physical/mental state; the meta-skill underlying all outdoor competence|skill
CC11|thermoregulation|body maintains ~37°C core; cold: shivering (generates heat), vasoconstriction (preserves core); hot: sweating (evaporative cooling), vasodilation; clothing and behavior choices support thermoregulation|physiology
CC12|moisture management|keeping dry is the primary survival strategy; sources: rain, sweat, condensation, ground moisture, stream crossings; each requires different management (shell, wicking base, ventilation, pad, gaiters)|principle
CC13|microclimate selection|campsite and rest-stop selection based on local conditions: wind shelter (below ridge, behind terrain feature), solar exposure (morning sun warms camp), cold air drainage (avoid valley floor in cold), distance from water (condensation, insects)|skill
CC14|pace management|sustainable pace that can be maintained all day; faster is not better; rest-step technique (pause at full leg extension on steep uphill); regular water and calorie intake; 10 min break per hour|skill
CC15|risk management|continuous: identify hazards → assess likelihood and consequence → mitigate or avoid; turnaround time (the time by which you must reverse course regardless of position); conservative decision-making in remote setting|skill

# relationships(from|rel|to)
# domain hierarchy
DM7|enables|DM1
DM7|enables|CC11
DM1|enables|DM2
DM2|enables|DM3
DM4|enables|DM5
DM4|enables|DM1
DM6|enables|DM10
DM15|enables|DM1,DM2,DM3,DM4,DM5,DM6,DM7,DM8,DM9,DM10
# shelter dependencies
SH1|requires|TL7
SH2|requires|TL4
SH3|requires|TL7,TL4
SH4|requires|TL7
SH6|requires|TN6
SH7|requires|TL1,TL7
SH8|enables|CC4
# sleep → shelter
SS1|requires|SH1
SS1|requires|SS4
SS1|requires|SS6
SS4|enables|SS1,SS2,SS3
SS6|enables|SS1,SS2,SS3
SS5|enables|SS1,SS2,SS3
SS7|extends|SS1,SS2,SS3
# water chain
WA9|precedes|WA3
WA3|enables|DM3
WA1|enables|DM3
WA4|requires|WA9
WA5|requires|DM4
WA6|enables|DM3
WA7|enables|DM3
WA8|enables|DM3
# fire chain
FR5|precedes|FR6
FR6|precedes|FR7
FR1|enables|FR5
FR2|enables|FR5
FR3|enables|FR5
FR8|specializes|DM4
FR9|specializes|DM4
FR10|specializes|DM4
FR11|specializes|DM4
# food dependencies
FC1|requires|FC5
FC2|requires|FC5
FC5|enables|DM5
FC6|enables|DM5
FC7|enables|DM5
FC8|enables|DM5
FC9|enables|FC1,FC2,FC3,FC4
FC10|enables|FC1,FC2,FC3,FC4
FC11|enables|FC1,FC2,FC3,FC4
# navigation dependencies
NV1|enables|DM6
NV2|enables|DM6
NV3|enables|DM6
NV4|enables|DM6
NV1|requires|NV2
NV6|extends|NV2
NV5|extends|NV1
# clothing system
CG1|precedes|CG4
CG4|precedes|CG8
CG1|precedes|CG5
CG5|precedes|CG8
CG7|enables|WX4
CC1|contains|CG1,CG4,CG8
CC1|contains|CG1,CG5,CG8
CC1|contains|CG1,CG6,CG8
CC8|prevents|CG1
# footwear → terrain
FW1|enables|TN5,TN6,TN8
FW3|enables|TN1,TN2,TN7
FW4|enables|TN5,TN8
FW6|enables|FW1,FW2,FW3,FW4
FW5|enables|TN4
# packing
PK1|requires|CC2
PK2|enables|DM9
PK3|enables|DM9
PK5|enables|PK1,PK2,PK3
PK6|enables|TN4
# terrain → hazard
TN4|requires|HZ11
TN6|requires|HZ4
TN7|requires|HZ2,HZ3
TN8|requires|HZ10
# weather → hazard
WX1|enables|HZ1
WX3|enables|HZ10
WX5|enables|HZ2
WX7|enables|HZ11
WX4|enables|HZ1
# hazard → first aid
HZ1|requires|FA4
HZ2|requires|FA5
HZ5|requires|FA3
HZ8|requires|FA7
HZ6|requires|FC9
HZ7|requires|FC9
# first aid → tool
FA1|requires|TL5
FA2|requires|TL4
FA7|requires|TL5,TL4
# knot → function
KN1|enables|SG4
KN3|enables|SH1,SH3
KN4|enables|FC10
KN5|enables|TN8
KN8|enables|TN8
# tool → domain
TL1|enables|DM4,DM5,DM1
TL4|enables|DM10,DM6,FA2
TL6|enables|DM6
TL7|enables|DM1,FC10
TL8|enables|SG1
TL9|enables|SH8
# signal → rescue
SG1|enables|DM15
SG5|enables|DM15
SG6|enables|DM15
SG7|enables|DM15
SG2|enables|DM15
# planning → trip
PL1|precedes|PL2
PL2|precedes|PL3
PL3|precedes|PL4
PL5|precedes|PL1
PL6|precedes|PL1
PL4|enables|SG5,SG6
PL7|enables|DM15
PL8|equivalent_to|CC5
# hygiene
HY1|enables|DM3
HY2|requires|TL2
HY3|prevents|HZ3
# concept foundations
CC1|requires|CG1,CG4,CG8
CC4|enables|CC15
CC10|enables|CC15
CC11|requires|CC1,CC12
CC12|requires|CC1,DM3
CC13|enables|DM1
CC14|enables|DM10
CC15|enables|DM15
CC7|determined_by|DM5
CC8|prevents|CG1
CC9|enables|CC6

# section_index(section|title|ids)
1|Domains|DM1-DM15
2|Shelter|SH1-SH8
3|Sleep Systems|SS1-SS8
4|Water|WA1-WA9
5|Fire|FR1-FR11
6|Food and Cooking|FC1-FC11
7|Navigation|NV1-NV6
8|Clothing|CG1-CG16
9|Footwear|FW1-FW8
10|Pack Systems|PK1-PK6
11|Terrain|TN1-TN8
12|Weather|WX1-WX8
13|Hazards|HZ1-HZ12
14|First Aid|FA1-FA7
15|Knots|KN1-KN9
16|Tools|TL1-TL9
17|Hygiene|HY1-HY6
18|Planning|PL1-PL8
19|Signals and Communication|SG1-SG7
20|Flora and Fauna Awareness|FF1-FF8
21|Core Concepts|CC1-CC15
22|Relationships|all

# decode_legend
id_prefixes: DM=domain, SH=shelter, SS=sleep_system, WA=water, FR=fire, FC=food_cooking, NV=navigation, CG=clothing, FW=footwear, PK=pack, TN=terrain, WX=weather, HZ=hazard, FA=first_aid, KN=knot, TL=tool, HY=hygiene, PL=planning, SG=signal, FF=flora_fauna, CC=concept
rel_types: enables|requires|prevents|specializes|generalizes|part_of|contains|follows|precedes|instance_of|determined_by|equivalent_to|extends|derived_from|composed_of
notation: _fk=foreign key; ~=approximate; °C=degrees Celsius; m=meters; km=kilometers; g=grams; kg=kilograms; L=liters; kW=kilowatts; kcal=kilocalories; FP=fill power (down); WPB=waterproof-breathable; MVTR=moisture vapor transmission rate; DWR=durable water repellent; UPF=ultraviolet protection factor; GTX=Gore-Tex; DEET=N,N-diethyl-meta-toluamide; NOAA=National Oceanic and Atmospheric Administration; NPS=National Park Service; USFS=US Forest Service; BLM=Bureau of Land Management; LNT=Leave No Trace; PLB=personal locator beacon; GPS=global positioning system; AMS=acute mountain sickness; HACE=high-altitude cerebral edema; HAPE=high-altitude pulmonary edema; GI=gastrointestinal; SAM=structural aluminum malleable (splint); ACE=brand name elastic bandage; RH=relative humidity; P/E=protein/energy; R-value=thermal resistance of sleeping pad (higher=warmer); HYOH=hike your own hike
confidence: weights and specifications are typical ranges from major manufacturers (2023–2024); medical protocols are Wilderness Medical Society guidelines; individual variation applies to all physiological and performance data; all facts at reference_outdoor confidence level
scope: backcountry camping, hiking, and wilderness travel in temperate, alpine, desert, and cold environments; covers gear, skills, hazards, first aid, navigation, and ethics; excludes: technical rock climbing, mountaineering above 5,000 m, whitewater kayaking, ocean sailing, hunting, fishing (separate domains); focused on self-powered human travel with overnight capability

# relation_mapping(doc_rel|canonical_rel|notes)
enables|enables|exact match
requires|requires|exact match
prevents|prevents|exact match; symmetric
specializes|specializes|exact match
contains|contains|exact match
precedes|precedes|exact match
extends|extends|exact match
equivalent_to|equivalent_to|exact match; symmetric
determined_by|determined_by|exact match
