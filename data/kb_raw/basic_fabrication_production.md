# BASIC PRODUCTION & FABRICATION SKILLS — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: concepts → materials → tools → processes → products → recipes → failure_modes → safety → distinctions → relationships → decode_legend

# concepts(id|name|definition|category)
CO1|Raw Material|unprocessed natural resource used as input to production; ore, fiber, hide, clay, wood, fat|foundation
CO2|Processing|transforming raw material into usable intermediate; smelting ore, retting fiber, tanning hide|foundation
CO3|Fabrication|shaping processed material into finished product; forging, weaving, sewing, molding|foundation
CO4|Heat Treatment|controlled heating and cooling to alter material properties; annealing, hardening, tempering|foundation
CO5|Mechanical Working|shaping by physical force; hammering, rolling, drawing, pressing, cutting|foundation
CO6|Chemical Processing|transforming material via chemical reaction; tanning, saponification, fermentation, mordanting|foundation
CO7|Joining|connecting two or more pieces; sewing, riveting, welding, gluing, lashing, mortise-and-tenon|foundation
CO8|Finishing|final surface treatment; polishing, dyeing, oiling, glazing, sealing|foundation
CO9|Measurement|determining dimensions, weight, temperature, concentration; prerequisite for consistent production|foundation
CO10|Pattern|template guiding cutting or shaping; paper pattern for clothing, mold for casting, jig for repetition|foundation
CO11|Grain (wood)|direction of wood fibers; working with grain = easier, cleaner cuts; against grain = rougher, harder; cross-grain = weakest|property
CO12|Grain (leather)|natural pattern of hair follicles on skin surface; tight grain = high quality; loose grain = lower quality|property
CO13|Temper (metal)|balance between hardness and toughness achieved by controlled reheating after hardening; higher temper = softer, tougher; lower = harder, more brittle|property
CO14|pH|measure of acidity/alkalinity; 0-14 scale; 7 neutral; critical in tanning, soap-making, dyeing, fermentation|property
CO15|Moisture Content|percentage of water in material by weight; governs wood working, clay forming, grain storage, leather conditioning|property
CO16|Work Hardening|metal becomes harder and more brittle with repeated cold working; must anneal to restore ductility|property
CO17|Annealing|heating metal to recrystallization temperature then slow cooling; restores ductility after work hardening; softens for further working|process
CO18|Flux|substance promoting fusion and preventing oxidation during soldering, brazing, or smelting; borax, rosin, limestone|material
CO19|Slag|waste byproduct of smelting; lighter than metal, floats on surface; removed by skimming;iteiteiteite indicates impurity removal|material
CO20|Mordant|substance fixing dye to fiber; alum (most common), iron (darkens/saddens), copper (greens), tannin (browns); creates chemical bond between dye and fiber|material
CO21|Lye|strong alkali solution; traditionally from wood ash leached in water (potassium hydroxide KOH); or sodium hydroxide NaOH (caustic soda); essential for soap and nixtamalization|material
CO22|Tannin|plant-derived polyphenol that binds to collagen in animal skin; converts hide to leather; found in oak bark, chestnut, mimosa, sumac|material
CO23|Collagen|structural protein in animal skin, tendon, bone; converts to gelatin when heated in water; basis of hide glue; tanning stabilizes collagen against decomposition|material
CO24|Cellulose|structural carbohydrate in plant cell walls; basis of all plant fibers (cotton, linen, hemp); paper production breaks wood into cellulose fibers|material
CO25|Keratin|structural protein in hair, wool, horn, hooves, feathers; resistant to chemicals; wool fiber is keratin|material
CO26|Calcination|heating calcium carbonate (limestone) to drive off CO₂ producing quickite lime (CaO); ~900°C; basis for morite mortar, plaster, whitewash|process
CO27|Slaking|adding water to quickite lime (CaO) producing hydrated lime Ca(OH)₂ (slaked lime); exothermic reaction; used in mortar, plaster, tanning, soil amendment|process
CO28|Saponification|chemical reaction between fat/oil and alkali (lye) producing soap (fatty acid salt) and glycerin; requires correct fat-to-lye ratio|process
CO29|Fermentation|anaerobic microbial metabolism converting sugars to alcohol, acids, or gases; basis of bread leavening, vinegar, alcohol, sauerkraut|process
CO30|Retting|controlled decomposition of plant stems to separate bast fibers from woody core; water retting (soak 5-14 days) or dew retting (lay in field 2-6 weeks)|process
CO31|Carding|aligning and cleaning fibers (wool, cotton) into parallel arrangement using toothed paddles or drum; produces roving for spinning|process
CO32|Spinning|twisting fibers into continuous yarn or thread; adds strength through twist; S-twist or Z-twist; drop spindle or spinning wheel|process
CO33|Fulling|washing and beating woven wool cloth to shrink, thicken, and felt; traditionally by stomping or mechanical hammering; felts surface fibers|process
CO34|Felting|matting animal fibers (wool) without weaving; heat, moisture, and agitation cause scales on keratin fibers to interlock irreversibly|process
CO35|Nixtamalization|soaking maize in alkali solution (lime water) to release niacin, soften hull, improve nutritional value; produces hominy/masa; Mesoamerican origin|process
CO36|Rendering|extracting fat from animal tissue by heating; wet rendering (with water) or dry rendering (without); produces tallow (beef/mutton) or lard (pork)|process
CO37|Charcoal Making|pyrolysis of wood in oxygen-limited environment; drives off water and volatile compounds; charcoal burns hotter and cleaner than wood; essential for smelting|process

# materials(id|name|source|processing_required|properties|primary_uses)
MA1|Iron Ore (Hematite/Magnetite)|mined from earth; hematite (Fe₂O₃) most common; magnetite (Fe₃O₄); bog iron from swamps|smelting in bloomery or blast furnace with charcoal/coke|hard, strong, corrodes (rust), magnetic (magnetite); melts at 1538°C; wrought iron workable by forging|tools, weapons, hardware, construction, cookware
MA2|Copper Ore (Malachite/Chalcopyrite)|mined; malachite (Cu₂CO₃(OH)₂) green; smelts at lower temperature than iron|smelting at ~1100°C; relatively easy to smelt from oxide ores|soft, ductile, excellent conductor; melts at 1085°C; work hardens; alloys with tin (bronze) or zinc (brass)|cookware, wire, ornament, roofing, alloys
MA3|Tin Ore (Cassiterite)|mined or alluvial; SnO₂; historically rare and traded widely|smelting at ~1000°C with charcoal|soft, low melting point (232°C); corrosion resistant; alloys with copper (bronze)|bronze alloy; tin plating; solder (with lead)
MA4|Clay|weathered rock minerals; found near rivers, exposed banks; kaolinite, illite, montmorillonite|dig, soak, remove debris, wedge (knead to remove air); fire in kiln|plastic when wet; hard when fired; vitrifies at high temperature; porous unless glazed|pottery, brick, tile, pipe, mortar addite additive
MA5|Limestone (Calcium Carbonate)|sedimentary rock; CaCO₃; abundant globally|quarry; calcine at ~900°C for quicklime; slake for hydrated lime|calcium source; produces strong alkaline solutions; makes mortar, plaster|mortar, plaster, whitewash, flux in smelting, soil amendment, tanning
MA6|Wood (Hardwood)|deciduous trees: oak, ash, maple, hickory, walnut|fell, season (air dry 1 year per inch thickness or kiln dry), saw, shape|strong along grain; carves and joins well; burns hot (oak ~900°C); varies by species|construction, furniture, tool handles, fuel, charcoal
MA7|Wood (Softwood)|coniferous trees: pine, spruce, cedar, fir|fell, season, saw|lighter, easier to work; less strong; resinous (pine); rot-resistant (cedar)|framing, sheathing, fencing, fuel, pitch/tar extraction
MA8|Animal Hide (Cattle)|skin of cattle, removed after slaughter; collagen matrix|fleshing, dehairing (lime soak), tanning, finishing|strong, flexible, durable when tanned; breathable; natural material|leather for shoes, belts, bags, armor, upholstery, bookbinding
MA9|Wool (Sheep)|shorn fleece from sheep; keratin fiber; crimped structure traps air|washing (scouring), carding, spinning, weaving or felting|warm (insulates wet or dry); felts naturally; takes dye well; elastic; flame-resistant|clothing, blankets, carpets, insulation, felt
MA10|Flax|stem of Linum usitatissimum; bast fiber in stem|retting, breaking, scutching, hackling, spinning|strong, smooth, cool, absorbent; low elasticity; stronger wet than dry|linen cloth, thread, rope, linseed oil (from seed)
MA11|Cotton|seed hair of Gossypium plant; nearly pure cellulose|ginning (seed removal), carding, spinning|soft, absorbent, breathable; weaker wet than dry; wrinkles; takes dye well|clothing, bedding, thread, bandages
MA12|Hemp|bast fiber from Cannabis sativa stem|retting, breaking, scutching, hackling, spinning|very strong; coarse; durable; rot-resistant; similar processing to flax|rope, canvas, sacking, coarse cloth, paper
MA13|Animal Fat (Tallow)|rendered beef or mutton fat; solid at room temperature|rendering from suet (kidney fat); straining; purifying by repeated melting|hard, white, high melting point (~45°C); saponification value ~195|soap, candles, lubricant, leather conditioning
MA14|Animal Fat (Lard)|rendered pig fat; softer than tallow|rendering from back fat or leaf fat; straining|soft, white; lower melting point than tallow (~35°C); saponification value ~195|soap (softer bars), cooking, leather treatment, lubricant
MA15|Vegetable Oil (Olive/Linseed/Coconut)|pressed from seeds, nuts, or fruits|cold press or hot press; filter; settle|liquid at room temperature (most); linseed polymerizes (drying oil); coconut high in lauric acid (hard soap)|soap (liquid or hard depending on oil), cooking, lamps, wood finishing (linseed), leather conditioning
MA16|Wood Ash|residue from burning hardwood; contains potassium carbonate (potash) and calcium compounds|collect; leach with water to extract lye (KOH solution)|alkaline; potassium-rich; variable concentration (must test strength)|lye for soap; fertilizer (potash); glaze ingredient; cleaning agent
MA17|Sand|granular quartz (SiO₂); river sand or pit sand|wash to remove clay and organic matter|inert filler; aggregate in mortar and concrete; melts at ~1700°C for glass|mortar aggregate, concrete, glass-making, abrasive, casting mold
MA18|Beeswax|secreted by honeybees; harvested from honeycomb|melt, strain, filter impurities; remelt and pour into blocks|water-resistant; flexible; melts at ~63°C; burns cleanly|candles, leather waterproofing, thread waxing, polish, sealant, lost-wax casting
MA19|Plant Dye|extracted from roots, leaves, bark, berries, flowers|harvest; extract by soaking/boiling in water; some require fermentation|color varies by plant, mordant, and pH; fugitive unless mordanted|dyeing fiber and cloth; ink; wood stain
MA20|Bone/Horn|animal skeletal material and horn sheaths|clean, boil (bone for glue), shape horn with heat and pressure|bone: rigid, fine-grained, carvable; horn: thermoplastic when heated, tough, translucent in thin sheets|buttons, combs, handles, glue (bone), containers (horn), fertilizer (bone meal)
MA21|Pitch/Tar|distilled from pine resin (pitch) or pyrolyzed from wood (tar)|collect resin; heat to distill turpentine off leaving pitch; or pyrolyze wood in closed container|waterproof; adhesive; antiseptic; flammable|waterproofing wood and rope, boat caulking, adhesive, torches
MA22|Natural Rubber (Latex)|sap of Hevea brasiliensis or similar trees|collect latex; coagulate with acid or smoke; roll into sheets|elastic; waterproof; degrades in sunlight and heat unless vulcanized|waterproofing, erasers, basic gaskets; vulcanization (sulfur + heat) for durable rubber
MA23|Salt (Sodium Chloride)|mined (rock salt), evaporated from seawater or brine springs|mining, dissolving, filtering, evaporating; solar or fire evaporation|preservative; essential nutrient; osmotic dehydration of food; lowers freezing point|food preservation (curing, brining), hide curing, ceramic glazing, ice control
MA24|Calcium Oxide (Quicklime)|calcined limestone; CaO|heat limestone to ~900°C in lime kiln|highly reactive with water (exothermic); strongly alkaline; caustic|mortar, plaster, tanning (lime soak), soil amendment, sanitization
MA25|Calcium Hydroxide (Slaked Lime)|quicklime + water → Ca(OH)₂|add water to quicklime carefully; exothermic|less reactive than quicklime; still strongly alkaline; paste or putty form|lime mortar, lime plaster, whitewash, nixtamalization, water treatment, tanning

# tools(id|name|description|materials_required|primary_uses)
TL1|Forge (Blacksmith)|fire pit or enclosed structure for heating metal; fueled by charcoal or coal; bellows supply air|firebrick or stone structure, bellows (leather + wood), fuel (charcoal/coal), anvil|heating iron/steel for forging, heat treatment, welding
TL2|Anvil|heavy steel or iron block with flat face, horn (tapered end), and hardy/pritchel holes|cast or forged iron/steel; ~50-150 kg for working anvil|surface for hammering hot metal; horn for bending curves; holes for punches and tools
TL3|Hammer (Blacksmith)|2-4 lb head with flat face and cross/ball peen; wooden handle (hickory/ash)|forged steel head, hardwood handle|primary tool for shaping hot metal; drawing out, upsetting, bending, flattening
TL4|Tongs (Blacksmith)|long-handled gripping tools; various jaw shapes for different stock profiles (flat, round, square)|forged iron/steel|holding hot metal during forging; various jaw profiles match stock shape
TL5|Bellows|air-pumping device forcing draft through forge fire; increases combustion temperature|wood frames, leather bag, nozzle (tuyere)|raising forge temperature to working heat (~800-1200°C for iron); essential for smelting and forging
TL6|Bloomery Furnace|simple shaft furnace for smelting iron from ore; produces spongy iron mass (bloom) mixed with slag|clay/stone construction, ~1-2m tall; charcoal fuel; tuyere for bellows|reducing iron ore to metallic iron at ~1200°C; bloom requires extensive forging to consolidate
TL7|Kiln (Pottery)|enclosed firing chamber reaching 600-1300°C; updraft, downdraft, or crossdraft designs|clay/brick/stone construction; wood, charcoal, or coal fuel|firing pottery, brick, tile; calcining limestone; drying wood; charcoal making (modified)
TL8|Potter's Wheel|rotating platform for forming clay vessels; kick wheel (foot-powered) or hand-powered|wood or stone wheel, axle, bearings (wood or stone); flywheel for momentum|centering and shaping clay into symmetrical vessels; throwing
TL9|Loom (Frame/Backstrap/Warp-Weighted)|device holding warp threads under tension; shuttle passes weft threads through shed|wood frame; heddle bars; reed (for beating weft); shuttle|weaving cloth from yarn; plain weave, twill, satin; width limited by loom size
TL10|Drop Spindle|weighted shaft for spinning fiber into yarn; whorl provides flywheel momentum|shaft (wood or bone), whorl (clay, stone, or wood); ~30-50g|spinning fiber into yarn; portable; used for thousands of years before spinning wheel
TL11|Spinning Wheel|foot or hand-powered wheel spinning fiber into yarn via continuous drafting; faster than drop spindle|wood frame, drive wheel, flyer assembly, bobbin|spinning fiber 3-5× faster than drop spindle; continuous production
TL12|Carders (Hand)|pair of flat paddles with fine wire teeth; fiber pulled between them to align and clean|wood paddles, bent wire teeth (leather backing)|aligning wool or cotton fibers into parallel roving for spinning
TL13|Hackle|bed of upright steel spikes; flax drawn through to split and align long fibers (line) from short (tow)|wood base, steel spikes (~10-20cm long)|processing retted flax into spinnable fiber; separates long line fibers from short tow
TL14|Saw (Hand)|toothed blade for cutting wood; crosscut (across grain) and rip (with grain) tooth patterns|steel blade, wood handle|dimensioning lumber; joinery; cuts across or along grain
TL15|Plane (Hand)|blade set in body at angle; shaves thin wood shavings to produce flat, smooth surfaces|steel blade, wood or metal body, adjustable mouth|smoothing and flattening wood surfaces; dimensioning boards; joinery preparation
TL16|Chisel (Wood)|steel blade with cutting edge; struck with mallet or pushed by hand; various widths|forged steel blade, wood handle|cutting joints (mortise, dovetail); carving; paring; shaping
TL17|Chisel (Cold)|hardened steel chisel for cutting cold metal; struck with hammer|hardened steel|cutting metal stock; shearing rivets; cutting sheet metal
TL18|Auger/Brace and Bit|rotating drill for boring holes in wood; brace provides leverage; various bit types|steel bit, wood brace body|boring holes for pegs, dowels, bolts; joinery; well-making
TL19|Adze|axe-like tool with blade perpendicular to handle; for shaping wood surfaces|forged steel head, wood handle|hollowing (bowls, troughs); smoothing logs; timber framing
TL20|Drawknife|two-handled blade drawn toward user; shaves wood quickly|forged steel blade, two wood handles|debarking logs; shaping chair parts, shingles, staves; rapid stock removal
TL21|Froe|L-shaped blade struck with mallet to split wood along grain; produces shingles, staves, clapboards|forged steel blade, wood handle and mallet|riving (splitting) wood along grain; produces strongest possible pieces following natural fiber
TL22|Needles (Sewing)|thin pointed tool with eye for thread; various sizes for different fabrics and leathers|steel wire (drawn and pointed); bone or thorn (primitive)|sewing cloth, leather, canvas; embroidery; sailmaking
TL23|Awl|pointed tool for piercing holes in leather, wood, or fabric before sewing or pegging|steel point, wood handle|piercing stitch holes in leather (saddler's awl); starting screw holes; marking
TL24|Scissors/Shears|pivoted cutting blades; scissors for cloth, tin snips for sheet metal|forged steel blades, rivet pivot|cutting fabric, thread, thin metal; essential for tailoring
TL25|Tanning Vat|large container (wood, stone, or clay-lined pit) for immersing hides in tanning solution|wood staves or stone-lined pit; holds bark liquor or other tanning solution|soaking hides in tanning liquor for weeks to months; vegetable tanning
TL26|Fleshing Beam|curved wooden beam for draping hide while scraping off flesh and fat with fleshing knife|smooth hardwood log, ~1m long, curved surface; fleshing knife (two-handled blade)|preparing hide for tanning by removing subcutaneous tissue
TL27|Stretching Frame|wooden frame with ties or clamps for stretching hide taut during drying and finishing|wood frame, cord or clips|drying tanned leather under tension to prevent shrinkage and wrinkling
TL28|Soap Mold|wooden or silicone container for pouring and solidifying soap; lined to prevent sticking|wood (lined with parchment or cloth), or silicone|shaping soap bars during curing/hardening
TL29|Crucible|heat-resistant container for melting metal; withstands forge/furnace temperatures|refractory clay (fire clay + sand); graphite crucible for higher temperatures|melting bronze, brass, copper, gold, silver for casting
TL30|Mold (Casting)|negative impression for shaping molten or plastic material; sand mold, clay mold, stone mold|sand (green sand casting), clay, stone (soapstone), or metal (permanent mold)|casting metal objects; pottery slip-casting; candle molding
TL31|Quench Tank|container of water, oil, or brine for rapid cooling of heated metal during hardening|metal or stone tank; water, oil (mineral or vegetable), or brine|quenching steel after heating to critical temperature; hardens by forming martensite
TL32|Whetstone/Grindstone|abrasive stone for sharpening edge tools; coarse for shaping, fine for honing|natural stone (novaculite, sandstone) or manufactured (aluminum oxide)|sharpening knives, chisels, axes, plane blades; maintaining cutting edges
TL33|Measuring Tools|straight edge, square, marking gauge, plumb bob, level, calipers, tape|wood, metal, string, weight|ensuring accuracy in layout, cutting, and assembly; critical for joinery and construction
TL34|Clamps|devices for holding work pieces together during gluing, assembly, or machining|wood (hand screw), iron (bar clamp, C-clamp)|applying pressure during gluing; holding work for cutting or drilling
TL35|Trowel|flat-bladed hand tool for spreading and smoothing mortar, plaster, or concrete|steel blade, wood handle|applying mortar between courses; plastering walls; finishing concrete surfaces
TL36|Mortar Mixer|vessel or platform for mixing mortar, plaster, or concrete; hand-mixed with hoe or mechanical|wood trough or metal pan; hoe or shovel for mixing|combining lime/cement with sand and water to uniform consistency
TL37|Level/Plumb Bob|gravity-based tools for determining horizontal (level) and vertical (plumb)|wood straight edge with water vial (level); weight on string (plumb bob)|ensuring walls are vertical, floors horizontal, courses level; fundamental to construction

# processes(id|name|input_materials|tools_required|steps|output|duration|critical_parameters)
PR1|Iron Smelting (Bloomery)|iron ore (hematite or bog iron), charcoal, clay for furnace|TL6 (bloomery), TL5 (bellows), TL3 (hammer), TL2 (anvil)|1. build clay shaft furnace (~1m tall) with tuyere hole; 2. preheat with charcoal fire; 3. alternate layers of crushed ore and charcoal; 4. maintain continuous bellows airflow 4-8 hours; 5. CO reduces Fe₂O₃ to Fe; 6. slag melts and drains or is tapped; 7. extract bloom (spongy iron+slag mass); 8. repeatedly forge hot bloom to expel slag and consolidate|wrought iron bloom (~2-5 kg from 10-15 kg ore)|8-16 hours per smelt|temperature ~1200°C (below iron's melting point); ore-to-charcoal ratio ~1:1 by weight; continuous air supply critical; slag must be fluid enough to separate
PR2|Forging (Blacksmithing)|wrought iron or steel stock|TL1 (forge), TL2 (anvil), TL3 (hammer), TL4 (tongs), TL5 (bellows), TL31 (quench)|1. heat stock in forge to working temperature (bright orange-yellow ~900-1100°C for iron); 2. draw out (lengthen by hammering); 3. upset (shorten/thicken by hammering end); 4. bend over horn or edge; 5. punch/drift holes; 6. join by forge welding (heat to white, flux with borax, hammer together); 7. heat treat if steel (harden + temper)|finished iron/steel object (tools, hardware, fasteners)|minutes to hours per piece|correct temperature by color (cherry red ~750°C, orange ~1000°C, yellow-white ~1200°C); avoid overheating (burns iron); work quickly as metal cools; steel hardens when quenched from above critical temperature (~770°C for plain carbon)
PR3|Steel Making (Cementation/Case Hardening)|wrought iron, charcoal, sealed container|TL1 (forge) or furnace, sealed clay or iron box|1. pack wrought iron bars in sealed container with charcoal; 2. heat to ~900-1000°C for hours to days; 3. carbon diffuses into iron surface; 4. result: blister steel (surface high-carbon, core low-carbon); 5. forge-weld and fold to distribute carbon (shear steel)|carbon steel (0.3-1.5% C depending on duration)|12-72+ hours of heating; longer = deeper carbon penetration|temperature must stay below melting; sealed container prevents carbon loss; deeper penetration requires more time; folding and forge-welding homogenizes carbon
PR4|Vegetable Tanning|raw hide (cattle), oak bark (or other tannin source), lime, water|TL25 (vat), TL26 (beam), TL27 (frame), fleshing knife, scraping tools|1. cure fresh hide with salt (prevent decomposition); 2. soak in lime solution 1-2 weeks (loosens hair, swells hide); 3. remove hair and epidermis on beam with scraping tools; 4. flesh: remove subcutaneous tissue; 5. delime with mild acid (vinegar or bran drench); 6. immerse in progressively stronger bark tannin solutions; 7. move to new stronger solutions every 2-4 weeks; 8. process takes 6-18 months for full penetration; 9. dry under tension on frame; 10. finish: oil/wax for suppleness|vegetable-tanned leather|6-18 months (traditional pit tanning)|lime concentration must dissolve hair without damaging grain; tannin concentration increased gradually (too strong too fast = case-hardening of surface); final moisture ~14%; oiling prevents brittleness
PR5|Chrome Tanning (Modern)|raw hide, chromium sulfate, salt, acid|vats or rotating drums, chemicals|1. cure and soak; 2. lime and dehair; 3. flesh and delime; 4. pickle in salt and acid (pH ~3); 5. add chromium sulfate solution; 6. tumble in drum 8-24 hours; 7. basify to raise pH and fix chrome; 8. wet-blue leather results; 9. retan, dye, fat-liquor; 10. dry and finish|chrome-tanned leather (wet-blue)|1-2 days (vs months for vegetable)|pH control critical at each stage; chrome fixation requires basification; environmental concern: chromium wastewater; produces softer, more heat-resistant leather than vegetable
PR6|Soap Making (Cold Process)|fat or oil (MA13/MA14/MA15), lye (NaOH solution), optional: essential oils, herbs|TL28 (mold), mixing vessel, thermometer, scale, stick blender (modern) or wooden spoon|1. calculate lye amount using saponification values (each oil has specific SAP value); 2. dissolve NaOH in water (exothermic, ~95°C); 3. cool lye solution to ~38-43°C; 4. heat/melt fats to ~38-43°C; 5. slowly add lye to oils while stirring; 6. stir to trace (thickened emulsion, ~10-30 min by hand, 2-5 min with stick blender); 7. add fragrance/additives at trace; 8. pour into mold; 9. insulate 24 hours (gel phase); 10. unmold after 24-48 hours; 11. cut into bars; 12. cure 4-6 weeks (excess water evaporates, saponification completes)|solid soap bars|4-6 weeks cure time|lye concentration: typically 5-6% superfat (excess oil for mildness); temperature matching prevents separation; trace = emulsion won't separate; cure time mandatory: fresh soap is harsh (unreacted lye); NaOH → hard bar; KOH → liquid soap
PR7|Soap Making (Traditional Lye)|animal fat (tallow), wood ash lye (KOH solution)|ash hopper or barrel, rendering pot, soap pot, mold|1. collect hardwood ash; 2. build leaching setup: barrel with straw filter at bottom; 3. pour water through ash repeatedly; 4. test lye strength (strong enough to dissolve a feather or float an egg); 5. render fat: chop suet, simmer in water, skim clean fat; 6. combine lye and rendered fat in large pot; 7. simmer and stir 4-8 hours (hot process); 8. paste thickens and becomes translucent when complete; 9. pour into mold or store as soft soap|soft soap (KOH-based) or hard soap if salt added (salting out converts to NaCl soap)|1 day cooking + weeks for ash leaching|lye strength variable (cannot precisely measure KOH concentration from ash); excess lye → caustic soap; insufficient lye → greasy, won't set; salting out: add salt to pot → NaCl displaces K, producing harder soap that floats to top
PR8|Spinning (Wool)|raw wool fleece|TL12 (carders), TL10 (drop spindle) or TL11 (spinning wheel)|1. wash fleece (scour in warm soapy water to remove lanolin and dirt); 2. dry thoroughly; 3. pick apart and remove vegetable matter; 4. card: pull fiber between carders to align and create roving; 5. draft: pull small amount of roving, attenuate to desired thickness; 6. twist: rotate spindle or wheel to add twist; 7. wind finished yarn onto spindle or bobbin; 8. ply: twist two or more singles together in opposite direction for strength and balance|yarn (singles or plied)|~50-100 yards/hour by hand (drop spindle); 200-400 yards/hour (spinning wheel)|twist direction: S or Z; consistent drafting = even yarn; too much twist = kinky, stiff; too little = weak, pulls apart; plying in opposite direction to singles prevents twist bias
PR9|Weaving (Basic Plain Weave)|yarn (warp and weft)|TL9 (loom), shuttle, reed/beater|1. calculate warp length and number of ends for desired fabric width and length; 2. warp loom: measure threads, beam onto loom, thread through heddles and reed; 3. create shed: raise/lower alternating warp threads via heddles; 4. pass shuttle with weft thread through shed; 5. beat weft into place with reed; 6. change shed (alternate heddles); 7. repeat steps 4-6; 8. cut finished cloth from loom; 9. finish: wash, full (for wool), press|woven cloth|varies by loom type; ~1-3 yards/day handloom for medium cloth|warp tension must be even; weft beaten consistently; selvedge (edges) maintained straight; sett (threads per inch) determines fabric density and drape; warp threads must be stronger than weft (under tension)
PR10|Sewing (Garment Construction)|fabric (woven or knit), thread, pattern|TL22 (needles), TL24 (scissors), TL33 (measuring tools), pins, thimble|1. take body measurements; 2. draft or select pattern; 3. lay pattern on fabric respecting grain direction; 4. cut fabric pieces with seam allowance (~1-1.5 cm); 5. mark darts, notches, gathering points; 6. pin pieces together; 7. baste (temporary large stitches); 8. sew seams with running stitch, backstitch, or machine stitch; 9. press seams open or to one side; 10. finish raw edges (overcast, fell, or fold); 11. set sleeves, collar, waistband as applicable; 12. hem; 13. add closures (buttons, ties, hooks)|finished garment|hours to days depending on complexity|grain alignment prevents twisting; seam allowance consistent; backstitch strongest hand stitch; bias cuts drape but stretch; pressing critical at each stage; fit requires muslin mock-up for complex garments
PR11|Leather Working (Shoe Making)|tanned leather (vegetable-tanned sole leather, chrome-tanned upper leather), thread (linen or nylon), nails|TL23 (awl), TL22 (needles), TL24 (scissors), last (foot-shaped form), hammer, knife, edge tools|1. select last matching foot shape/size; 2. cut pattern pieces: upper (vamp, quarter, tongue), lining, sole, insole; 3. skive edges (thin for overlap); 4. sew upper pieces together; 5. last the upper: pull and tack over last; 6. attach insole to last; 7. sew or cement upper to insole (Goodyear welt: sew welt strip → sew sole to welt; cement: glue sole directly); 8. attach outsole; 9. heel build-up (stacked leather or rubber); 10. finish: edge dressing, polish, burnishing|finished shoes|8-20 hours per pair (handmade)|sole leather must be vegetable-tanned (firm); upper leather more flexible (chrome-tan acceptable); lasting requires precise tension; welted construction allows resoling; cemented is faster but not repairable; heel alignment affects gait
PR12|Lime Mortar Making|limestone, sand, water|lime kiln or purchased quicklime, TL36 (mixer), TL35 (trowel)|1. calcine limestone at ~900°C producing quicklime (CaO); 2. slake quicklime with water → slaked lime Ca(OH)₂ (exothermic, dangerous); 3. age slaked lime putty minimum 3 months (ideally years; improves workability); 4. mix lime putty with sand (ratio 1:2.5 to 1:3 by volume); 5. add water to achieve workable consistency; 6. apply to masonry within working time; 7. mortar sets by carbonation: Ca(OH)₂ + CO₂ → CaCO₃ + H₂O (reverts to limestone)|lime mortar|setting: weeks to months (carbonation from surface inward); full strength in years|sand must be clean, sharp (angular), well-graded; lime:sand ratio affects strength and workability; carbonation requires CO₂ access (don't seal surface); frost damage if applied below ~5°C; keep moist during initial cure
PR13|Brick Making|clay, sand (temper), water, straw (optional for adobe)|mold (wooden form), kiln (for fired brick), drying yard|1. dig clay; remove stones and debris; 2. soak and mix to uniform consistency; 3. add sand (temper, ~10-20%) to reduce shrinkage cracking; 4. press into wet mold dusted with sand (prevent sticking); 5. turn out onto drying ground; 6. air dry 2-4 weeks (turn periodically); 7. stack in kiln; 8. fire: slow ramp to ~900-1100°C over 24-48 hours; 9. hold at temperature 12-24 hours; 10. slow cool 2-4 days; 11. sort by hardness (closest to fire = hardest)|fired brick|2-4 weeks drying + 4-7 days firing cycle|clay shrinks ~8-12% during drying (cracks if too fast or too thick); temper (sand) reduces shrinkage; firing temperature determines hardness: ~900°C = soft, ~1100°C = hard engineering brick; cooling must be gradual (thermal shock cracks)
PR14|Charcoal Making|hardwood (oak, maple, hickory preferred)|earth mound kiln or metal retort|1. cut wood to uniform length (~50cm); 2. stack vertically in dome shape around central chimney; 3. cover with leaves/straw then earth/turf (airtight except chimney and vent holes); 4. light from top through chimney; 5. manage vents: restrict air to prevent combustion but maintain pyrolysis; 6. process takes 3-7 days; 7. wood turns to charcoal at ~300-500°C; 8. seal all vents when smoke turns from white (steam) to blue (volatile gases) to thin/clear; 9. cool 1-2 days sealed; 10. open carefully (reignition risk)|charcoal (75-90% carbon by weight)|5-10 days total|air control critical: too much = wood burns to ash; too little = process stalls; yield ~20-25% by weight of original wood; hardwood produces denser, longer-burning charcoal; charcoal burns at ~700-1000°C vs ~300-600°C for wood
PR15|Dyeing (Natural/Vegetable)|plant dye material (madder, woad, walnut, onion skin, etc.), mordant (alum), fiber or cloth|dye pot (non-reactive: enamel, stainless, ceramic), heat source, water|1. scour fiber/cloth (wash thoroughly to remove oils, sizing); 2. mordant: dissolve alum (~15% weight of fiber) in warm water; soak fiber 1 hour at simmer; 3. prepare dye bath: simmer plant material in water 1-2 hours; strain out plant matter; 4. enter wet mordanted fiber into dye bath; 5. simmer at ~80-90°C for 1-2 hours; 6. check color (dries lighter); 7. cool in bath for deeper color; 8. rinse in progressively cooler water; 9. wash gently; 10. dry out of direct sunlight|dyed fiber or cloth|1-3 days (including mordanting)|mordant type determines color shift: alum = truest color; iron = darkens/saddens; copper = shifts green; chrome = brightens; tin = brightens but can damage wool; pH affects color (vinegar vs alkali); protein fibers (wool, silk) take dye more readily than cellulose (cotton, linen)
PR16|Pottery (Wheel-Thrown)|prepared clay (wedged, de-aired)|TL8 (wheel), TL7 (kiln), wire (for cutting off wheel), trimming tools, glaze materials|1. wedge clay (knead 50-100 times to remove air bubbles); 2. center on wheel (compress rotating clay until symmetrical and still); 3. open: press thumb into center; 4. pull up walls: squeeze between fingers while wheel turns; 5. shape with ribs and fingers; 6. cut from wheel with wire; 7. dry to leather-hard; 8. trim foot and refine shape; 9. attach handles/spouts (score and slip join); 10. dry fully (bone dry; ~1-2 weeks); 11. bisque fire (~900°C); 12. apply glaze (dip, pour, or brush); 13. glaze fire (~1200-1300°C for stoneware)|finished pottery vessel|2-4 weeks (drying + two firings)|centering is most critical skill; uneven walls → collapse or wobble; drying must be slow and even (cover loosely; fast drying = cracking); bone dry clay is fragile; bisque fire removes chemical water; glaze melts to glass coating; thermal shock from rapid heating/cooling cracks ware
PR17|Rope Making|fiber (hemp, sisal, flax, cotton)|rope walk or ropewalk machine, hooks, top (compression tool)|1. prepare fiber: hackle or card to parallel strands; 2. spin fiber into yarn (Z-twist); 3. group yarns into strands (3 strands typical); 4. attach strand ends to hooks on ropewalk; 5. twist strands individually (Z-twist); 6. allow strands to wrap around each other in opposite direction (S-twist); top travels along rope keeping twist even; 7. secure ends to prevent unraveling (whip, seize, or splice)|finished rope (three-strand laid)|hours for rope making; days including fiber preparation|twist must be balanced: too much = kinks; too little = weak; lay direction opposite to strand twist (prevents unwinding under load); hemp strongest traditional fiber; rope strength = ~50% of combined yarn strength (geometry and friction losses)
PR18|Candle Making (Tallow Dipped)|rendered tallow (MA13) or beeswax (MA18), cotton or linen wick|dipping frame, melting pot, wick material|1. prepare wick: braid or twist cotton/linen cord (~2mm diameter for table candle); 2. melt tallow to ~65-70°C (just above melting point); 3. dip wick into tallow; 4. lift out and let cool and harden (~30 seconds); 5. repeat dipping 20-40 times building up layers; 6. between dips, ensure previous layer solidified; 7. straighten while warm if bent; 8. final dip at slightly higher temperature for smooth finish; 9. trim base flat and wick to ~1cm|tallow or wax candles|2-4 hours for batch (including cooling between dips)|temperature too high = previous layers melt off; too low = thick uneven coating; wick must be proper size for candle diameter (too thin = drowns; too thick = smokes); beeswax burns cleaner and brighter than tallow; tallow candles smell unless well-rendered
PR19|Glue Making (Hide/Bone)|hide scraps, rawhide, or bones; water|large pot, straining cloth, mold|1. clean material: wash hide scraps; break/crush bones; 2. soak in water 12-24 hours; 3. simmer (not boil) in fresh water for 6-12 hours (bones longer); 4. collagen dissolves into gelatin solution; 5. strain through cloth; 6. reduce liquid by simmering until syrupy; 7. pour into shallow molds; 8. cool and gel; 9. cut into blocks/sheets; 10. dry blocks in ventilated area until hard and brittle; 11. to use: soak in water to swell, then heat in double boiler to ~60°C; apply hot|hide glue (reversible, strong, traditional)|1-3 days preparation; months shelf life dried|never boil (destroys bonding strength); use in double boiler to prevent overheating; apply hot (sets as it cools and dries); reversible with heat and moisture (advantage for repair); stronger than wood along grain; gap-filling; must be clamped 4-8 hours
PR20|Fertilizer (Composting)|kitchen scraps, animal manure, plant matter, straw/leaves|pitchfork, bin or pile area, optional thermometer|1. layer brown material (carbon: straw, leaves, dry stalks) and green material (nitrogen: food scraps, fresh manure, green plants); 2. ratio ~25-30:1 carbon to nitrogen by weight; 3. moisten to damp sponge consistency; 4. turn pile every 1-2 weeks to aerate; 5. hot composting: internal temperature reaches 55-65°C within days (kills pathogens and weed seeds); 6. continue turning until temperature no longer rises after turning; 7. cure for 2-4 weeks after active phase; 8. finished compost is dark, crumbly, earthy smell|finished compost (humus-rich soil amendment)|2-6 months (hot composting: 1-3 months; cold: 6-12 months)|C:N ratio critical: too much carbon = slow; too much nitrogen = ammonia smell and anaerobic; moisture: too wet = anaerobic (stinks); too dry = stalls; aeration accelerates; temperature indicates microbial activity; finished when cool and earthy-smelling
PR21|Fertilizer (Manure/Ash Direct)|animal manure (cow, horse, chicken, sheep), wood ash|shovel, wheelbarrow, storage area|1. collect manure; 2. age/compost 3-6 months (fresh manure burns plants from ammonia); 3. chicken manure hottest (highest nitrogen); cow/horse cooler; 4. wood ash: collect from clean hardwood fires; 5. apply ash directly to soil for potassium and calcium (not for acid-loving plants); 6. apply aged manure at 2-5 cm layer, incorporate into soil|soil amendments: nitrogen, phosphorus, potassium, calcium, micronutrients|manure aging: 3-6 months; ash: immediate use|fresh manure: too much ammonia; chicken manure must be composted (very hot); ash raises pH (alkaline); don't combine fresh manure with seed (burning); wood ash provides K and Ca but no nitrogen
PR22|Flax Processing (Linen Production)|harvested flax stalks|retting area (pond or field), breaking machine or hand-break, scutching blade, TL13 (hackle), TL10/TL11 (spinning), TL9 (loom)|1. harvest flax at seed maturity; pull (don't cut) to preserve fiber length; 2. dry in sheaves 1-2 weeks; 3. remove seeds (rippling through comb); 4. ret: submerge bundles in slow water 5-14 days (or dew ret in field 2-6 weeks); bacteria dissolve pectin binding fiber to woody core; 5. dry retted stalks; 6. break: crush stems with fluted rollers or hand-break to fracture woody core (shive); 7. scutch: scrape with wooden blade to remove broken shive; 8. hackle: draw through progressively finer hackles to separate long line fiber from short tow; 9. spin line fiber (fine linen thread); 10. weave|linen cloth|4-6 months from harvest to cloth|retting is most critical and difficult step: under-retted = fiber won't separate; over-retted = fiber weakened; water temperature affects speed; fine hackled line fiber makes finest linen; tow used for coarse products (twine, sacking)
PR23|Basic Wall Construction (Load-Bearing Masonry)|brick or stone, lime mortar (PR12), wooden lintels|TL35 (trowel), TL37 (level/plumb bob), TL33 (measuring), mason's line, hammer|1. dig foundation trench to firm ground (below frost line); 2. lay foundation course: largest/hardest stones or double-width brick; 3. spread mortar bed (~10mm thickness); 4. lay first course checking level; 5. butter end of next brick with mortar; press into place; 6. maintain bond pattern (stretcher, header, or Flemish bond); each course offsets joints from course below; 7. check plumb with every 3-4 courses; 8. build corners first as guides; run mason's line between for straight courses; 9. install wooden lintel above window and door openings; 10. build to desired height; 11. cap wall (coping stones or mortar cap to shed water); 12. point joints: fill any voids with mortar pressed in with pointing tool|load-bearing masonry wall|days to weeks depending on wall length and height|bond pattern prevents vertical joint alignment (weak plane); mortar joints ~10mm; walls must be plumb; lintels span openings (wood, stone, or brick arch); wall thickness minimum ~200mm for single-story; thicker walls = more stable; lime mortar allows movement without cracking (unlike cement)
PR24|Basic Timber Framing|sawn or hewn timbers (hardwood: oak preferred), wooden pegs (treenails)|TL14 (saw), TL16 (chisel), TL18 (auger), TL19 (adze), TL3 (hammer or mallet), TL33 (measuring), TL37 (level)|1. select and prepare timbers: hew or saw to dimension; season if possible; 2. layout joints: mark mortise and tenon locations with measuring tools; 3. cut mortises (rectangular holes) with auger and chisel; 4. cut tenons (projecting tongues) with saw and chisel; 5. fit joints dry: test and adjust; 6. cut peg holes through joint (~1mm offset for draw-bore); 7. assemble frame sections on ground (bent/cross-frame); 8. raise bents with community help or mechanical advantage (gin pole, block and tackle); 9. connect bents with plates, girts, braces; 10. peg all joints with hardwood treenails (driven through offset holes → draws joint tight); 11. add diagonal braces (resist racking); 12. infill walls (wattle-and-daub, brick, plank)|timber frame structure|weeks to months depending on size|mortise-and-tenon is primary joint; shoulders bear load, peg prevents withdrawal; draw-bore offset pulls joint tight; bracing resists lateral forces; green (unseasoned) timber acceptable if joints accommodate shrinkage; oak strongest traditional framing timber
PR25|Tallow Rendering|raw beef suet (kidney fat) or mutton fat, water|large pot, straining cloth, water, molds|1. cut suet into small pieces or grind; 2. place in large pot with ~2 cm water at bottom (prevents scorching); 3. heat on low flame; fat slowly melts out of connective tissue; 4. stir occasionally; 5. simmer (never boil hard) for 2-4 hours until all tissue is rendered (cracklings float and are crisp); 6. strain through cloth into clean container; 7. for purer tallow: add water, melt again, let cool; clean fat solidifies on top, impurities settle in water below; 8. remove solid fat disc; scrape any residue from bottom; 9. remelt and pour into storage molds|clean rendered tallow|4-8 hours per batch|low heat critical: high heat scorches fat (brown, smelly, poor soap); water-washing step removes protein residue; cleaner tallow = whiter soap and cleaner-burning candles; store cool and dry; tallow is shelf-stable 6-12 months if well-rendered
PR26|Nixtamalization|dried maize kernels, slaked lime or wood ash, water|cooking pot, strainer, grinding stone (metate) or grain mill|1. combine dried maize with water (~3:1 water to maize); 2. add slaked lime (~1 tablespoon per 500g maize) or wood ash; 3. bring to boil; simmer 30-60 minutes; 4. remove from heat; steep overnight (8-12 hours); 5. drain and wash kernels thoroughly, rubbing to remove pericarp (hull); 6. kernels are now nixtamal (hominy); 7. grind wet nixtamal on metate or through mill to produce masa (dough); 8. masa used for tortillas, tamales, etc.|nixtamal (hominy) / masa (dough)|12-16 hours (including overnight steep)|lime concentration critical: too much = yellow, chemical taste; too little = hull not loosened; releases bound niacin (prevents pellagra); improves protein availability; calcium fortification; rinsing removes excess alkali
PR27|Basic Pottery Glaze|silica (ground quartz/flint), flux (wood ash, feldspar, or limestone), alumina (clay), water|grinding equipment, mixing vessel, kiln capable of glaze temperature|1. calculate recipe by Seger formula or empirical test; basic ash glaze: 40% wood ash + 40% feldspar + 20% clay (by weight); 2. grind all materials to fine powder; 3. mix with water to cream consistency; 4. sieve through 80+ mesh screen; 5. apply to bisque-fired pottery by dipping, pouring, or brushing; 6. clean foot (bottom) to prevent fusing to kiln shelf; 7. fire to maturation temperature (stoneware: cone 6-10, ~1200-1300°C); 8. cool slowly|glaze coating on pottery: waterproof, durable, decorative|included in glaze firing (12-24 hours firing cycle)|silica = glass former; flux = lowers melting point; alumina = stiffens melt (prevents running); thickness matters: too thin = crawling; too thick = running and dripping; ash composition varies (test batches); kiln atmosphere: oxidation = brighter colors; reduction = darker, earthier
PR28|Leather Working (Belt/Strap Making)|vegetable-tanned leather (8-10 oz weight), edge tools, hardware (buckle)|sharp knife or strap cutter, TL23 (awl), edge beveler, burnishing tool (bone or wood), leather dye, finish (oil/wax)|1. select firm vegetable-tanned leather; 2. cut strap to width using straight edge and sharp knife or strap cutter; 3. bevel edges with edge beveler (45° chamfer both sides); 4. burnish edges: wet edge, rub vigorously with burnishing tool until smooth and compressed; 5. apply edge dye if desired; 6. mark and punch buckle holes and keeper slots; 7. fold buckle end, punch rivet holes, set rivets; 8. punch size holes (~25mm apart over adjustment range); 9. dye surface if desired (multiple coats, dry between); 10. apply finish (neatsfoot oil for suppleness, then wax for protection)|finished leather belt|2-4 hours|vegetable-tanned leather essential (chrome-tan too soft); edge burnishing seals fibers (prevents fraying); grain side is outer face; cuts must be clean and straight; hardware attachment must be secure (rivets or stitching, not glue alone)
PR29|Whitewash Making|slaked lime (MA25), water, optional: salt (hardener), tallow (binder)|bucket, stirring stick, brush (natural bristle)|1. mix slaked lime putty with water to thin cream consistency (~1 part lime putty to 4-6 parts water); 2. optional: add 2-5% salt (by lime weight) for hardness and weather resistance; 3. optional: add small amount of tallow or linseed oil for weather resistance; 4. stir thoroughly; 5. apply to damp wall surface with brush; 6. apply thin coats (thick coats crack and peel); 7. allow 24 hours between coats; 8. apply 2-3 coats minimum; 9. sets by carbonation (CO₂ absorption converts back to calcium carbonate)|whitewashed surface (antimicrobial, reflective, protective)|application: hours; full cure: weeks|damp surface essential for adhesion; thin coats only; carbonation hardens over weeks; antimicrobial properties (high pH); reflective (reduces heat in buildings); historically universal coating; reapply annually for maintenance
PR30|Starch Extraction (Wheat)|wheat flour, water|bowl, cloth, container|1. make stiff dough from flour and water; 2. knead 10 minutes; 3. wash dough in bowl of water: squeeze and knead in water; starch washes into water, gluten remains in hands as elastic ball; 4. pour starchy water through cloth into container; 5. repeat washing with fresh water 2-3 times; 6. let starch water settle 4-8 hours; starch sinks to bottom; 7. pour off water; 8. dry starch in thin layer; 9. gluten ball can be dried or used (seitan)|wheat starch (for sizing cloth, stiffening, adhesive) and gluten|1-2 days including settling|starch used for: sizing warp threads (strengthens for weaving); stiffening cloth; adhesive (paper, bookbinding); laundry starch; cooking; gluten used for: seitan (protein food); historical adhesive

# products(id|name|required_processes|required_materials|required_tools|complexity|notes)
PD1|Wrought Iron Nails|PR1 (iron smelting) → PR2 (forging)|iron ore, charcoal|TL1, TL2, TL3, TL4, TL5|moderate|forge thin iron rod; cut to length; draw point; form head on header plate; ~60-100 nails/hour for skilled smith
PD2|Iron Knife|PR1 → PR2 (with heat treatment)|iron ore, charcoal; or steel stock|TL1, TL2, TL3, TL4, TL5, TL31, TL32|moderate-high|forge blade shape; file to refine; harden (quench from cherry red); temper (reheat to straw color ~220°C); handle: wood or antler riveted on; sharpen on whetstone
PD3|Basic Linen Shirt|PR22 (flax to linen) → PR10 (sewing)|flax fiber, thread|TL13, TL10/TL11, TL9, TL22, TL24, TL33|high (many stages)|historically most labor-intensive common garment; ~50-80 hours spinning alone for one shirt's worth of linen thread; simple rectangular construction reduces cutting waste
PD4|Wool Blanket|PR8 (spinning) → PR9 (weaving) → PR33 (fulling)|raw wool fleece|TL12, TL10/TL11, TL9|moderate-high|spin heavy yarn (fewer twists per inch); weave plain or twill; full (wash and beat) to felt surface for warmth; ~40-60 hours total for single blanket
PD5|Leather Shoes (Basic)|PR4 or PR5 (tanning) → PR11 (shoe making)|raw hide, tanning materials, thread, nails|TL25, TL26, TL27, TL23, TL22, TL24, last|high|vegetable-tanned sole; flexible upper; turnshoe (medieval: sewn inside-out, turned) or welted construction; sole replaceable in welted
PD6|Bar Soap|PR25 (rendering) → PR6 or PR7 (soap making)|animal fat, lye (NaOH or wood ash KOH)|rendering pot, soap pot, TL28, thermometer, scale|moderate|cold process with NaOH: most controllable; traditional wood ash method: variable but achievable; 4-6 weeks cure
PD7|Fired Clay Pot|PR16 (pottery)|clay, glaze materials, fuel|TL8, TL7|moderate|wheel-thrown; 2 firings (bisque + glaze); 3-4 weeks start to finish; waterproof with glaze
PD8|Tallow Candles|PR25 (rendering) → PR18 (dipping)|beef suet|rendering pot, dipping frame, wick material|low-moderate|simplest lighting technology; smells unless well-rendered; ~20-40 dips per candle; batch production efficient
PD9|Hemp Rope|PR17 (rope making)|hemp fiber|hackle, spinning tools, rope walk|moderate|strongest traditional natural fiber rope; 3-strand laid; knot strength ~50% of breaking strength
PD10|Compost Fertilizer|PR20 (composting)|organic waste, manure, straw|pitchfork, bin|low|requires patience and turning; hot composting: 1-3 months; produces balanced slow-release soil amendment
PD11|Hide Glue|PR19 (glue making)|hide scraps, bones|large pot, strainer, molds|low-moderate|reversible adhesive; stronger than wood; used for millennia in woodworking, bookbinding; dissolves in water (weakness and advantage)
PD12|Lime Mortar|PR12 (mortar making)|limestone, sand, water|lime kiln, TL36, TL35|moderate|sets slowly by carbonation; flexible (self-healing microcracks); allows building movement; suitable for soft brick and stone
PD13|Brick|PR13 (brick making)|clay, sand, fuel|brick mold, TL7|moderate|reliable building unit; standardized size; fire-resistant; durable; labor-intensive but low-skill individual steps
PD14|Whitewash|PR29 (whitewash making)|slaked lime, water|bucket, brush|low|antimicrobial coating; reflects heat; cheap; annual reapplication; historically universal
PD15|Charcoal|PR14 (charcoal making)|hardwood|mound materials|moderate (fire management skill)|essential for metal smelting (burns hotter than wood); also for cooking, water filtration, drawing, soil amendment (biochar)
PD16|Dyed Wool Cloth|PR8 → PR15 (dyeing) → PR9 (weaving)|wool, mordant, plant dye|carders, spinning tools, loom, dye pot|high (many stages)|dye can be applied at fiber, yarn, or cloth stage; yarn-dyeing allows color patterns; cloth-dyeing most uniform
PD17|Nixtamalized Maize (Masa)|PR26 (nixtamalization)|dried maize, lime|cooking pot, grinding stone|low-moderate|nutritionally superior to untreated maize; prevents pellagra; basis of tortilla, tamale, hominy
PD18|Starch (Wheat)|PR30 (starch extraction)|wheat flour|bowl, cloth|low|sizing agent for warp threads (critical for weaving); laundry starch; adhesive; cooking thickener
PD19|Timber Frame Building|PR24 (framing) + PR23 (wall infill) + PR12 (mortar)|timber, wooden pegs, brick/stone, lime mortar|full woodworking toolkit, masonry tools|very high|community effort to raise; durable (centuries if maintained); repairable; adaptable; most significant pre-industrial construction method
PD20|Basic Woven Basket|basket weaving (stakes-and-weavers or coiled)|willow, ash splits, reed, or other flexible material|knife, bodkin|low-moderate|no loom needed; coiled or woven; functional containers predating pottery; willow or ash splits most common; soaked to maintain flexibility during weaving

# recipes(id|name|ingredients|proportions|method_summary|yield|notes)
RC1|Basic Tallow Soap (Cold Process)|beef tallow, NaOH (lye), water|1000g tallow, 136g NaOH, 320ml water (5% superfat)|dissolve NaOH in water; cool to 38°C; melt tallow to 38°C; combine and stir to trace; pour into mold; cure 4-6 weeks|~1.4 kg soap (approximately 10-12 bars)|NaOH amount calculated from tallow SAP value (0.1405 × fat weight × (1 - superfat%)); superfat = excess oil for mildness
RC2|Olive Oil Castile Soap (Cold Process)|olive oil, NaOH, water|1000g olive oil, 124g NaOH, 310ml water (7% superfat)|same as tallow soap; olive oil traces very slowly (hours by hand); 8-12 month cure optimal|~1.3 kg very mild soap|longest cure of any soap; extremely mild; very slow trace; traditionally Marseille/Castile
RC3|All-Purpose Fertilizer Mix (Organic)|blood meal, bone meal, wood ash, compost|parts by volume: 2 blood meal, 3 bone meal, 1 wood ash, 10 compost|mix dry ingredients; incorporate into soil 2-4 weeks before planting; water in|covers ~10 m² at 2cm depth|blood meal: nitrogen (fast release); bone meal: phosphorus (slow); ash: potassium + calcium; compost: humus + micronutrients + soil biology
RC4|Lime Mortar (Standard)|lime putty, sharp sand, water|1 part lime putty to 2.5-3 parts sand by volume; water to workable consistency|mix thoroughly; use within 2 hours of mixing; apply in layers no thicker than ~20mm|sufficient for ~10-15 m² of wall at ~10mm joint thickness|aged lime putty (>3 months) far superior to fresh; hot-mixed lime (quicklime + sand + water simultaneously) also effective
RC5|Hide Glue (Standard Use)|dried hide glue, water|1 part glue to 1.5-2 parts water by weight (soak ratio)|soak in cold water 4-12 hours until swollen and soft; heat in double boiler to 60°C (140°F); stir until smooth; apply hot with brush|thin enough to flow from brush but thick enough to resist running off vertical surface; gel strength measured in grams (120-250g typical)|working time: ~5-10 minutes at room temperature before gelling; clamping: 4-8 hours; full strength: 24 hours; reversible: steam or hot water softens joint
RC6|Whitewash (Exterior Grade)|slaked lime putty, water, salt, linseed oil|4 parts water, 1 part lime putty, 2% salt by lime weight, 1% linseed oil by lime weight|dissolve salt in warm water; add lime putty; stir until smooth; add oil; mix vigorously; apply to damp surface in thin coats|~4 liters covers 10-15 m² per coat (apply 2-3 coats)|salt improves weather resistance; oil improves adhesion and water-shedding; must cure (carbonate) between coats; annual reapplication ideal
RC7|Natural Dye: Onion Skin Yellow|onion skins (brown outer), alum (mordant), fiber/cloth, water|~100g skins per 100g fiber; alum at 15% weight of fiber|mordant fiber in alum solution 1 hour at simmer; prepare dye bath by simmering skins 1 hour; strain; enter mordanted fiber; simmer 1 hour; cool in bath; rinse|strong yellow to golden; lightfast with alum mordant|easiest beginner natural dye; skins collected from cooking; color range: yellow (alum), burnt orange (tin), olive (iron); iron modifier applied by brief dip in iron water after dyeing
RC8|Natural Dye: Walnut Brown|walnut hulls (green outer shell), fiber/cloth, water|~200g hulls per 100g fiber; no mordant needed (tannin self-mordants)|simmer crushed green hulls in water 2-4 hours; strain; enter fiber; simmer 1-2 hours; cool in bath; rinse|rich brown; very lightfast; stains everything permanently|walnut is substantive dye (no mordant needed); stains hands and equipment permanently; hulls collected in autumn; store dried for year-round use
RC9|Tallow Candle Recipe|rendered tallow (MA13), cotton wick (braided, not twisted)|~500g tallow yields 4-6 taper candles; wick: 2mm braided cotton for ~2cm diameter candle|melt tallow to ~70°C; dip wick in and out; cool 30 seconds between dips; repeat 25-35 dips until ~2cm diameter; straighten between dips|4-6 candles from 500g tallow; burn time ~1 hour per cm of candle|braided wick curls as it burns (self-trimming); twisted wick requires trimming; beeswax addition (10-20%) improves hardness and reduces smell; bayberry wax also excellent but scarce

# failure_modes(id|process_fk|mode|cause|consequence|prevention)
FL1|PR1|bloom fails to consolidate|insufficient temperature or bellows pressure; ore too impure|spongy mass full of slag; unusable without extensive reforging|ensure continuous bellows operation; use higher-quality ore; add limestone flux for acidic ores
FL2|PR2|metal cracks during forging|working too cold (below red heat); working hardened steel without annealing|piece splits or fractures; material wasted|maintain working temperature; anneal between working sessions; avoid hammering below cherry red
FL3|PR2|burned iron|overheating (white-hot for extended time); spark shower at anvil|grain structure destroyed; steel becomes irreparably brittle|watch temperature by color; don't leave metal in hottest part of fire unnecessarily
FL4|PR4|case-hardened leather|tannin solution too strong too early; bark liquor penetrates surface but not core|surface tanned, core still raw; stiff, cracks in use; will decompose internally|start with weak tannin solutions; increase gradually over months; patience is essential
FL5|PR6|lye-heavy soap|too much NaOH or too little fat; measurement error|caustic soap; burns skin; crumbly white texture; cannot be cured out|weigh precisely; use verified SAP values; include 3-7% superfat; test pH (should be 8-10)
FL6|PR6|soap won't trace|oils too cold; insufficient stirring; certain oils (olive) naturally slow|mixture remains liquid; separation possible|ensure temperature matched; increase stirring; use stick blender; add faster-tracing oils (coconut, palm)
FL7|PR8|yarn breaks during spinning|insufficient twist; drafting too thin; fiber too short|broken thread; must rejoin (splice)|add more twist; draft thicker; blend short fibers with longer ones; practice consistent drafting
FL8|PR9|warp threads breaking during weaving|warp tension uneven or too high; weak yarn; sizing not applied|broken threads halt production; tedious repair|use stronger yarn for warp; size warp with starch; maintain even tension; check for weak spots before beaming
FL9|PR13|bricks crack during drying|drying too fast; insufficient temper (sand); walls too thick|cracked or broken bricks; rejected|dry slowly in shade; add 10-20% sand; limit thickness; turn periodically
FL10|PR13|bricks crack during firing|heating too fast; residual moisture; air pockets in clay|exploding or cracking bricks; kiln damage|ramp temperature slowly (~50°C/hour initially); ensure fully air-dried before firing; wedge clay thoroughly
FL11|PR16|pot collapses on wheel|walls too thin; clay too wet; uncentered; pulling up too fast|collapsed vessel; reclaim clay and start over|center thoroughly; keep walls even thickness; don't over-wet; support with inside hand
FL12|PR16|pot cracks during drying|uneven thickness; drying too fast; trapped air bubbles|cracked green ware; unsalvageable|even wall thickness; dry slowly under plastic or cloth; wedge clay thoroughly
FL13|PR12|mortar crumbles|too little lime in mix; mortar dried too fast (water evaporated before carbonation); frost damage during cure|weak joints; wall structural integrity compromised|correct lime:sand ratio; keep moist during initial cure; cover in hot/windy weather; don't apply below 5°C
FL14|PR14|charcoal mound burns through|air leak in earth covering; vent too large; wind exposure|wood burns to ash instead of charcoaling; total loss of batch|seal all cracks; monitor for wisps of flame; shelter from wind; reduce vents promptly when smoke thins
FL15|PR15|dye doesn't take|fiber not scoured (oils block absorption); no mordant; pH wrong|pale or no color; washes out immediately|scour fiber thoroughly; mordant with alum before dyeing; check pH; protein fibers accept more readily
FL16|PR19|glue too weak|overheated above 65°C; diluted too much; old degraded stock|bond fails; joint opens|never boil; use double boiler; correct dilution ratio; use fresh stock; test bond on scrap
FL17|PR24|mortise-and-tenon joint loose|tenon cut undersize; wood shrank after cutting; poor fit|joint wobbles; structural weakness|cut tenon to fit snugly; draw-bore peg pulls tight; use green timber carefully (allow for shrinkage); test fit before final assembly
FL18|PR23|wall out of plumb|not checking plumb frequently enough; foundation settling; poor technique|leaning wall; structural instability; eventual collapse|check plumb every 3-4 courses; ensure firm level foundation; use mason's line for straight courses; build corners first as guides
FL19|PR25|tallow scorched during rendering|heat too high; not stirring; solid fat touching bottom of dry pot|brown, foul-smelling tallow; poor soap and candle quality|low heat; add water to bottom of pot; stir regularly; patience
FL20|PR17|rope unbalances (kinks or unravels)|uneven twist in strands; lay applied in same direction as strand twist; strands of different thickness|weak rope; kinks reduce strength; unsafe for load-bearing|equal thickness strands; strand twist and lay twist in opposite directions; consistent tension during laying

# safety(id|process_fk|hazard|severity|precaution)
SA1|PR1|carbon monoxide from incomplete combustion in enclosed space|lethal|work in well-ventilated area; open-sided forge; never smelt indoors without chimney
SA2|PR2|burns from hot metal, forge fire, and radiant heat|serious|leather apron and gloves; tongs for all hot metal; clear floor; keep quench water nearby
SA3|PR6|lye (NaOH/KOH) causes severe chemical burns on skin and eyes; exothermic when dissolved in water|serious|wear goggles and gloves; add lye to water (never water to lye); work in ventilated area; keep vinegar nearby (neutralizer); no aluminum containers (reacts violently)
SA4|PR12|quicklime reacts violently with water; exothermic; causes burns|serious|add quicklime to water slowly; wear goggles and gloves; keep dry quicklime away from water until ready
SA5|PR14|carbon monoxide and methane from pyrolysis; fire risk from premature opening|serious to lethal|ventilated area; never open mound prematurely; monitor for external flame; keep water available
SA6|PR16|kiln temperatures 900-1300°C; steam explosions from moisture in clay or kiln structure|serious|ensure ware is bone-dry before firing; kiln must be structurally sound; slow initial heating drives off residual moisture; stand clear of kiln door during firing
SA7|PR7|wood ash lye is caustic (KOH solution); concentration variable and hard to test precisely|moderate-serious|wear gloves; protect eyes; test strength before use (feather dissolve test, egg float test); assume strong until proven otherwise
SA8|PR2|eye damage from forge brightness and flying scale|serious|don't stare into fire; safety glasses; scale (oxide flakes) flies when hammering hot iron
SA9|PR25|hot fat splatters and burns|moderate|low heat; don't add water to hot fat (steam explosion); keep lid available; handle carefully
SA10|PR23|falling materials from height; back injury from lifting heavy masonry units|serious|hard hat for overhead work; proper lifting technique; scaffold properly braced; don't overreach

# distinctions(id|side_a|side_b|key_asymmetry)
DI1|Wrought Iron|Cast Iron|wrought: low carbon (<0.08%); forged/hammered; fibrous; bends before breaking; weldable in forge; cast: high carbon (2-4%); poured molten into molds; brittle; breaks without bending; not forge-weldable; cast iron requires blast furnace (~1400°C) vs bloomery (~1200°C)
DI2|Vegetable Tanning|Chrome Tanning|vegetable: tannin-based (bark); 6-18 months; firm, toolable, molds to shape; ages with patina; traditional; chrome: chromium sulfate; 1-2 days; soft, flexible, heat-resistant; most modern leather; environmental concerns with chromium wastewater
DI3|Hardwood|Softwood|hardwood: deciduous; denser; harder; more durable; better fuel; tool handles, furniture, framing; softwood: coniferous; lighter; easier to work; resinous; cheaper; framing, sheathing; exceptions exist (balsa is hardwood but soft)
DI4|Warp|Weft|warp: lengthwise threads under tension on loom; must be stronger; set up first; determine fabric length; weft: crosswise threads passed through shed by shuttle; can be weaker, softer; determine fabric width; more visible in finished cloth
DI5|Spinning S-Twist|Spinning Z-Twist|S-twist: fibers spiral upward to the left (like middle of S); Z-twist: fibers spiral upward to the right (like middle of Z); singles typically Z-twist; plying typically S-twist (opposite to singles for balance); cultural variation
DI6|Cold Process Soap|Hot Process Soap|cold: mix at moderate temp, cure 4-6 weeks in mold; smoother bars; easier to customize; hot: cook after trace (65-80°C) to force complete saponification; usable immediately but rougher texture; traditional method
DI7|Lime Mortar|Portland Cement Mortar|lime: sets by carbonation (slow); flexible; breathable; self-healing microcracks; suitable for soft brick and stone; historic buildings; cement: sets by hydration (fast); rigid; strong; impermeable; cracks under movement; can damage soft historic masonry by trapping moisture
DI8|Green Wood|Seasoned Wood|green: freshly cut; high moisture (30-60%); easier to split and shape; shrinks as it dries; traditional for some chairmaking (joints tighten as they dry); seasoned: air-dried or kiln-dried (<20% MC); stable; less likely to crack or warp; required for most joinery and construction
DI9|Drawing Out|Upsetting|drawing out: lengthening metal by hammering on flat face; makes stock thinner and longer; upsetting: shortening and thickening by hammering on end; concentrates mass; opposite operations; both fundamental to forging
DI10|Natural Dye|Synthetic Dye|natural: from plants, insects, minerals; requires mordant for most; subtle colors; variable; historical; sustainable but labor-intensive; synthetic: from petroleum/coal tar chemicals; consistent color; no mordant needed (reactive dyes bond directly); brighter; cheaper; environmental impact from chemical manufacturing
DI11|Leavened Bread|Unleavened Bread|leavened: fermentation produces CO₂ gas expanding dough (yeast or sourdough); lighter texture; requires rising time; unleavened: no fermentation; flat; quick (no rising); tortilla, matzo, chapati; leavening requires active yeast/starter culture
DI12|Protein Fiber|Cellulose Fiber|protein (wool, silk): animal origin; keratin or fibroin; takes acid dyes; damaged by alkali; felts (wool); burns with hair smell; cellulose (cotton, linen, hemp): plant origin; takes fiber-reactive dyes; damaged by acid; doesn't felt; burns with paper smell; stronger wet (linen) or weaker wet (cotton)
DI13|Forging|Casting|forging: shaping solid metal by hammering; grain structure aligned; strongest; any temperature (hot or cold forging); casting: pouring molten metal into mold; complex shapes possible; grain structure random; may have porosity; requires melting temperature; forged parts stronger than cast in same metal
DI14|Plain Weave|Twill Weave|plain: weft passes over one, under one warp thread; simplest; strongest per thread; both sides identical; stiff; twill: weft passes over two or more, under one (or variation); creates diagonal pattern; softer drape; more complex threading; denim and herringbone are twills
DI15|Riving|Sawing|riving: splitting wood along grain with froe or wedge; follows natural fiber; pieces are stronger because fibers are continuous; fast; sawing: cutting wood with toothed blade; any direction; more precise dimensions; severs fibers (weaker than rived); slower but more controllable

# relationships(from|rel|to)
# Material → process
MA1|input_to|PR1
MA2|input_to|PR2
MA4|input_to|PR13,PR16
MA5|input_to|PR12,PR26,PR27,PR29
MA6|input_to|PR14,PR24
MA7|input_to|PR24,PR14
MA8|input_to|PR4,PR5
MA9|input_to|PR8
MA10|input_to|PR22
MA11|input_to|PR8
MA12|input_to|PR17
MA13|input_to|PR6,PR7,PR18
MA14|input_to|PR6,PR7
MA15|input_to|PR6
MA16|input_to|PR7
MA17|input_to|PR12,PR13
MA18|input_to|PR18
MA19|input_to|PR15
MA20|input_to|PR19
MA21|input_to|PR24
MA23|input_to|PR4
MA24|input_to|PR12,PR4,PR29
MA25|input_to|PR12,PR26,PR29

# Process → product
PR1|produces|PD1,PD2,PD15
PR2|produces|PD1,PD2
PR4|produces|PD5,PD11
PR5|produces|PD5
PR6|produces|PD6
PR7|produces|PD6
PR8|produces|PD3,PD4,PD16
PR9|produces|PD3,PD4,PD16
PR10|produces|PD3,PD5
PR11|produces|PD5
PR12|produces|PD12,PD19
PR13|produces|PD13,PD19
PR14|produces|PD15
PR15|produces|PD16
PR16|produces|PD7
PR17|produces|PD9
PR18|produces|PD8
PR19|produces|PD11
PR20|produces|PD10
PR22|produces|PD3
PR24|produces|PD19
PR25|produces|PD6,PD8
PR26|produces|PD17
PR29|produces|PD14
PR30|produces|PD18

# Process chains
PR1|precedes|PR2
PR25|precedes|PR6,PR7,PR18
PR22|precedes|PR8
PR8|precedes|PR9,PR15
PR9|precedes|PR10,PR33
PR4|precedes|PR11,PR28
PR12|required_by|PR23
PR14|required_by|PR1,PR2

# Tool → process
TL1|used_in|PR1,PR2,PR3
TL2|used_in|PR2
TL3|used_in|PR2,PR24
TL4|used_in|PR2
TL5|used_in|PR1,PR2
TL6|used_in|PR1
TL7|used_in|PR13,PR16,PR27,PR14
TL8|used_in|PR16
TL9|used_in|PR9,PR22
TL10|used_in|PR8,PR22
TL11|used_in|PR8,PR22
TL12|used_in|PR8
TL13|used_in|PR22
TL14|used_in|PR24
TL15|used_in|PR24
TL16|used_in|PR24
TL18|used_in|PR24
TL22|used_in|PR10,PR11
TL23|used_in|PR11,PR28
TL24|used_in|PR10
TL25|used_in|PR4,PR5
TL26|used_in|PR4,PR5
TL27|used_in|PR4,PR5
TL28|used_in|PR6
TL29|used_in|PR2
TL31|used_in|PR2
TL32|used_in|PR2
TL33|used_in|PR10,PR23,PR24
TL35|used_in|PR12,PR23
TL36|used_in|PR12
TL37|used_in|PR23,PR24

# Concept relationships
CO1|transformed_by|CO2
CO2|precedes|CO3
CO3|produces|CO8
CO4|specializes|CO2
CO5|specializes|CO3
CO6|specializes|CO2
CO7|specializes|CO3
CO8|finalizes|CO3
CO9|enables|CO3,CO5,CO10
CO10|enables|CO3
CO11|constrains|CO5
CO16|caused_by|CO5
CO17|reverses|CO16
CO13|determined_by|CO4
CO14|constrains|CO6,CO28
CO15|constrains|CO3,CO5,CO16
CO18|enables|PR1,PR2
CO19|byproduct_of|PR1
CO20|enables|PR15
CO21|enables|PR6,PR7,CO28,PR26
CO22|enables|PR4
CO23|basis_of|PR4,PR19
CO24|basis_of|MA10,MA11,MA12
CO25|basis_of|MA9
CO26|transforms|MA5
CO27|transforms|MA24
CO28|requires|CO21
CO29|enables|PR20
CO30|enables|PR22
CO31|precedes|CO32
CO32|precedes|PR9
CO33|finalizes|PR9
CO34|alternative_to|PR9
CO36|produces|MA13,MA14
CO37|produces|PD15

# Product dependencies
PD1|requires|PD15
PD2|requires|PD15
PD3|requires|PD18
PD5|requires|PD1
PD6|requires|PD15
PD8|requires|PD15
PD12|requires|PD15
PD13|requires|PD15
PD19|requires|PD1,PD12,PD13

# Safety → process
SA1|hazard_of|PR1
SA2|hazard_of|PR2
SA3|hazard_of|PR6,PR7
SA4|hazard_of|PR12
SA5|hazard_of|PR14
SA6|hazard_of|PR16,PR13
SA7|hazard_of|PR7
SA8|hazard_of|PR2
SA9|hazard_of|PR25
SA10|hazard_of|PR23

# Failure → process
FL1|failure_of|PR1
FL2|failure_of|PR2
FL3|failure_of|PR2
FL4|failure_of|PR4
FL5|failure_of|PR6
FL6|failure_of|PR6
FL7|failure_of|PR8
FL8|failure_of|PR9
FL9|failure_of|PR13
FL10|failure_of|PR13
FL11|failure_of|PR16
FL12|failure_of|PR16
FL13|failure_of|PR12
FL14|failure_of|PR14
FL15|failure_of|PR15
FL16|failure_of|PR19
FL17|failure_of|PR24
FL18|failure_of|PR23
FL19|failure_of|PR25
FL20|failure_of|PR17

# Distinction mappings
DI1|distinguishes|MA1,PR1
DI2|distinguishes|PR4,PR5
DI3|distinguishes|MA6,MA7
DI4|distinguishes|PR9
DI5|distinguishes|PR8
DI6|distinguishes|PR6,PR7
DI7|distinguishes|PR12
DI8|distinguishes|MA6,CO15
DI9|distinguishes|PR2
DI10|distinguishes|PR15
DI11|distinguishes|CO29
DI12|distinguishes|MA9,MA10
DI13|distinguishes|PR2,TL30
DI14|distinguishes|PR9
DI15|distinguishes|TL21,TL14

# Charcoal as universal dependency
PD15|enables|PR1,PR2,PR3

# decode_legend
# id_prefixes: CO=concept, MA=material, TL=tool, PR=process, PD=product, RC=recipe, FL=failure_mode, SA=safety, DI=distinction
# rel_types: input_to|produces|precedes|required_by|used_in|transformed_by|specializes|finalizes|enables|constrains|caused_by|reverses|determined_by|byproduct_of|basis_of|transforms|requires|alternative_to|hazard_of|failure_of|distinguishes
# complexity: low|low-moderate|moderate|moderate-high|high|very high — subjective scale reflecting number of skills, tools, and process steps required
# duration: time from start of specific process to usable output; does not include prerequisite processes unless noted
# critical_parameters: the variables that most determine success or failure; controlling these separates competent work from failure
# SAP value: saponification value = mg KOH needed to saponify 1g of fat; NaOH SAP = KOH SAP / 1.403; lookup per oil type
# confidence: synthetic domain knowledge — not extracted from a single source document

# relation_mapping(doc_rel|canonical_rel|notes)
input_to|input_to|exact match
produces|produces|exact match
precedes|precedes|exact match
required_by|requires|inverse; X required by Y = Y requires X
used_in|implements|inverse; X used in Y = X implements Y's process
transformed_by|transforms_to|inverse; X transformed by Y = X transforms to new form via Y
specializes|specializes|exact match
finalizes|follows|X finalizes Y = X follows Y as completion step
enables|enables|exact match
constrains|constrains|exact match
caused_by|causes|inverse; X caused by Y = Y causes X
reverses|reverses|exact match
determined_by|determined_by|exact match
byproduct_of|result_of|X byproduct of Y = X is result of Y
basis_of|foundation_for|X is basis of Y = X is foundation for Y
transforms|transforms_to|X transforms Y = Y transforms to new state
requires|requires|exact match
alternative_to|alternative_to|exact match; symmetric
hazard_of|hazard_of|exact match
failure_of|anti_pattern_of|X failure of Y = X is anti-pattern of Y
distinguishes|distinguishes|exact match
