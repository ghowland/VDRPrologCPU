# GEOGRAPHY: EARTH SYSTEMS AND LOCAL COSMOS — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: continents → tectonic_plates → countries → oceans → seas → rivers → mountains → deserts → climate_zones → biomes → earth_layers → atmosphere_layers → solar_system → orbital_mechanics → earth_solar → concepts → relationships → section_index → decode_legend

# continents(id|name|area_km2|population_2024|countries_count|highest_point|lowest_point|avg_elevation_m|avg_rainfall_mm_yr|major_climate_zones)
CT1|Asia|44,579,000|4,800,000,000|49|Everest 8,849 m|Dead Sea −430 m|960|726|tropical, subtropical, arid, temperate, continental, polar (Siberia)
CT2|Africa|30,370,000|1,460,000,000|54|Kilimanjaro 5,895 m|Lake Assal −155 m|750|678|tropical, arid (Sahara, Kalahari), equatorial, Mediterranean, semi-arid
CT3|North America|24,709,000|580,000,000|23|Denali 6,190 m|Death Valley −86 m|720|660|arctic, subarctic, temperate, subtropical, tropical, arid
CT4|South America|17,840,000|440,000,000|12|Aconcagua 6,961 m|Laguna del Carbón −105 m|590|1,564|tropical, equatorial (Amazon), arid (Atacama), temperate, alpine
CT5|Antarctica|14,200,000|~1,000–5,000 (research)|0|Vinson Massif 4,892 m|Bentley Subglacial Trench −2,555 m|2,300 (ice sheet surface)|166 (driest continent)|polar ice cap
CT6|Europe|10,180,000|750,000,000|44|Elbrus 5,642 m|Caspian Sea coast −28 m|340|590|maritime, continental, Mediterranean, subarctic, alpine
CT7|Oceania/Australia|8,526,000|46,000,000|14|Puncak Jaya 4,884 m (Papua); Kosciuszko 2,228 m (Australia)|Lake Eyre −15 m|330|Australia: 534; PNG/islands: 2,000–4,000|arid (interior Australia), tropical (north, Pacific islands), temperate (SE Australia, NZ)

# tectonic_plates(id|name|type|area_km2|velocity_mm_yr|direction|major_boundaries)
TP1|Pacific|oceanic|103,300,000|50–100|NW|subduction under North American, Philippine, Australian, Eurasian; transform (San Andreas); divergent (East Pacific Rise)
TP2|North American|continental + oceanic|75,900,000|15–25|W-SW|transform (San Andreas vs Pacific); divergent (Mid-Atlantic Ridge vs Eurasian); subduction (Juan de Fuca under NA; Caribbean)
TP3|Eurasian|continental + oceanic|67,800,000|7–14|E|collision (Indian → Himalayas); divergent (Mid-Atlantic Ridge vs NA); subduction (Pacific, Philippine under Eurasian)
TP4|African|continental + oceanic|61,300,000|15–20|NE|divergent (Mid-Atlantic Ridge vs SA; East African Rift); collision (vs Eurasian → Alps, Atlas)
TP5|Antarctic|continental + oceanic|60,900,000|~0–10|various|divergent on all sides (surrounded by Southern Ocean ridges)
TP6|Indo-Australian|continental + oceanic|58,900,000|60–70|NE|collision (Indian portion vs Eurasian → Himalayas); subduction (Pacific under Australian portion); divergent (SE Indian Ridge)
TP7|South American|continental + oceanic|43,600,000|25–35|W|subduction (Nazca under SA → Andes); divergent (Mid-Atlantic Ridge vs African)
TP8|Nazca|oceanic|15,600,000|40–65|E|subduction under South American (→ Andes, Peru-Chile Trench); divergent (East Pacific Rise vs Pacific)
TP9|Philippine Sea|oceanic|5,500,000|50–80|NW|subduction under Eurasian (Mariana Trench, deepest point on Earth 10,935 m); subduction of Pacific under Philippine
TP10|Arabian|continental|5,000,000|15–25|NE|collision (vs Eurasian → Zagros Mountains); divergent (Red Sea Rift vs African)
TP11|Caribbean|oceanic + continental|3,300,000|10–20|E|subduction (NA under Caribbean → Lesser Antilles arc); transform (northern and southern boundaries)
TP12|Cocos|oceanic|2,900,000|55–80|NE|subduction under Caribbean and North American (→ Central American volcanoes)
TP13|Juan de Fuca|oceanic|250,000|40–50|E|subduction under North American (→ Cascadia subduction zone, Cascade volcanoes)
TP14|Scotia|oceanic|1,600,000|variable|E|subduction + transform (connects South American and Antarctic plates)

# countries(id|name|continent_fk|area_km2|population_2024|capital|gdp_usd_2023|gdp_per_capita_usd|top_exports|top_imports|major_resources|elevation_range_m|avg_rainfall_mm_yr|government_type)
# Top 30 by GDP + regional representation
CO1|China|CT1|9,597,000|1,425,000,000|Beijing|17,795,000,000,000|12,500|electronics, machinery, textiles, steel, chemicals|petroleum, integrated circuits, iron ore, soybeans|rare earth elements, coal, iron, hydropower, tin, tungsten|Turpan −154 to Everest 8,849|645|single-party socialist republic
CO2|India|CT1|3,287,000|1,442,000,000|New Delhi|3,730,000,000,000|2,600|refined petroleum, IT services, pharmaceuticals, gems/jewelry, textiles|crude petroleum, gold, electronics, coal|coal, iron ore, manganese, bauxite, titanium, natural gas|Kuttanad −2.2 to K2 8,611 (admin)|1,170|federal parliamentary republic
CO3|Japan|CT1|378,000|124,000,000|Tokyo|4,213,000,000,000|34,000|motor vehicles, electronics, machinery, steel, chemicals|petroleum, LNG, electronics, clothing, pharmaceuticals|minimal mineral; fisheries, timber, geothermal|sea level to Fuji 3,776|1,668|constitutional monarchy (parliamentary)
CO4|Indonesia|CT1|1,905,000|277,000,000|Jakarta|1,417,000,000,000|5,100|palm oil, coal, petroleum gas, rubber, nickel|refined petroleum, electronics, machinery, iron/steel|petroleum, tin, nickel, bauxite, copper, gold, coal, palm oil, timber|sea level to Puncak Jaya 4,884|2,702|presidential republic
CO5|Saudi Arabia|CT1|2,150,000|37,000,000|Riyadh|1,069,000,000,000|29,000|crude petroleum (~75% export revenue), refined petroleum, petrochemicals, plastics|machinery, vehicles, foodstuffs, electronics|petroleum (~15% global reserves), natural gas, iron ore, gold, copper|sea level to Jabal Sawda 3,000|100|absolute monarchy
CO6|South Korea|CT1|100,000|52,000,000|Seoul|1,713,000,000,000|33,000|semiconductors, motor vehicles, petroleum products, ships, electronics|crude petroleum, semiconductors, natural gas, electronics|coal, tungsten, graphite, limited minerals|sea level to Hallasan 1,950|1,274|presidential republic
CO7|Turkey|CT1,CT6|784,000|86,000,000|Ankara|1,108,000,000,000|13,000|motor vehicles, machinery, iron/steel, textiles, electronics|petroleum, gold, machinery, iron/steel, electronics|coal, iron ore, copper, chromium, antimony, mercury, gold, barite|sea level to Ararat 5,137|632|presidential republic
CO8|Thailand|CT1|513,000|72,000,000|Bangkok|515,000,000,000|7,200|electronics, motor vehicles, machinery, rubber, gems, rice|crude petroleum, electronics, machinery, iron/steel, chemicals|tin, rubber, natural gas, tungsten, tantalum, timber, lead, gems|sea level to Doi Inthanon 2,565|1,622|constitutional monarchy (parliamentary)
CO9|Nigeria|CT2|924,000|230,000,000|Abuja|363,000,000,000|1,600|crude petroleum (~85% export revenue), LNG, cocoa|refined petroleum, wheat, vehicles, electronics|petroleum, natural gas, tin, iron ore, coal, limestone, niobium, lead, zinc|sea level to Chappal Waddi 2,419|1,150|federal presidential republic
CO10|South Africa|CT2|1,221,000|62,000,000|Pretoria/Cape Town/Bloemfontein|377,000,000,000|6,100|gold, platinum group metals, iron ore, coal, vehicles, fruit|petroleum, machinery, electronics, vehicles|gold, chromium, antimony, coal, iron ore, manganese, nickel, phosphates, tin, uranium, diamonds, platinum, vanadium|sea level to Mafadi 3,450|495|parliamentary republic
CO11|Egypt|CT2|1,001,000|106,000,000|Cairo|395,000,000,000|3,700|petroleum, LNG, fertilizers, textiles, Suez Canal revenue|wheat, petroleum products, machinery, vehicles, meat|petroleum, natural gas, iron ore, phosphates, manganese, limestone, gypsum, Suez Canal|Qattara Depression −133 to Mt Catherine 2,629|18 (one of driest)|presidential republic
CO12|Kenya|CT2|580,000|56,000,000|Nairobi|113,000,000,000|2,000|tea, cut flowers, coffee, petroleum products, vegetables|petroleum, machinery, vehicles, iron/steel, pharmaceuticals|limestone, soda ash, gemstones, fluorspar, zinc, diatomite, geothermal|sea level to Mt Kenya 5,199|680|presidential republic
CO13|DR Congo|CT2|2,345,000|105,000,000|Kinshasa|66,000,000,000|630|cobalt (~70% global), copper, crude petroleum, diamonds, gold|machinery, vehicles, foodstuffs, fuel|cobalt, copper, diamonds, gold, coltan (tantalum), tin, tungsten, zinc, hydropower, timber|sea level to Margherita Peak 5,109|1,543|semi-presidential republic
CO14|United States|CT3|9,834,000|340,000,000|Washington D.C.|27,361,000,000,000|80,400|refined petroleum, aircraft, natural gas, pharmaceuticals, electronics, agricultural products|crude petroleum, vehicles, electronics, machinery, pharmaceuticals|petroleum, natural gas, coal, copper, lead, molybdenum, phosphates, rare earths, uranium, bauxite, gold, iron, mercury, nickel, potash, silver, tungsten, zinc, timber|Death Valley −86 to Denali 6,190|715|federal presidential republic
CO15|Canada|CT3|9,985,000|41,000,000|Ottawa|2,140,000,000,000|52,200|crude petroleum, motor vehicles, gold, natural gas, lumber|motor vehicles, machinery, electronics, crude petroleum|petroleum (oil sands), natural gas, nickel, zinc, potash, diamonds, uranium, timber, hydropower|sea level to Mt Logan 5,959|537|federal parliamentary constitutional monarchy
CO16|Mexico|CT3|1,964,000|130,000,000|Mexico City|1,789,000,000,000|13,800|motor vehicles, electronics, petroleum, machinery, agricultural products|refined petroleum, electronics, vehicles, machinery, plastics|petroleum, silver (world's largest producer), copper, gold, lead, zinc, natural gas|sea level to Pico de Orizaba 5,636|758|federal presidential republic
CO17|Brazil|CT4|8,516,000|216,000,000|Brasília|2,174,000,000,000|10,100|soybeans, crude petroleum, iron ore, poultry, sugar, coffee|refined petroleum, electronics, machinery, vehicles, pharmaceuticals|iron ore (largest reserves), petroleum, bauxite, gold, manganese, nickel, phosphates, platinum, tin, uranium, hydropower, timber|sea level to Pico da Neblina 2,994|1,761|federal presidential republic
CO18|Argentina|CT4|2,780,000|46,000,000|Buenos Aires|641,000,000,000|13,900|soybean meal, corn, motor vehicles, crude petroleum, wheat|machinery, vehicles, chemicals, refined petroleum|lithium (expanding), petroleum, lead, zinc, tin, copper, iron ore, manganese, uranium, arable land|Laguna del Carbón −105 to Aconcagua 6,961|591|federal presidential republic
CO19|Colombia|CT4|1,142,000|52,000,000|Bogotá|344,000,000,000|6,600|crude petroleum, coal, coffee, gold, cut flowers|refined petroleum, vehicles, machinery, electronics, chemicals|petroleum, natural gas, coal, iron ore, nickel, gold, copper, emeralds (world's largest producer)|sea level to Pico Cristóbal Colón 5,775|2,612|presidential republic
CO20|Germany|CT6|357,000|84,000,000|Berlin|4,456,000,000,000|53,000|motor vehicles, machinery, chemicals, pharmaceuticals, electronics|crude petroleum, natural gas, vehicles, electronics, pharmaceuticals|coal, lignite, natural gas, iron ore, copper, nickel, uranium, potash, salt|sea level to Zugspitze 2,962|700|federal parliamentary republic
CO21|United Kingdom|CT6|243,000|68,000,000|London|3,340,000,000,000|49,100|crude petroleum, motor vehicles, pharmaceuticals, gold, machinery|motor vehicles, crude petroleum, gold, machinery, electronics|petroleum (North Sea declining), natural gas, coal, tin, limestone, iron ore, salt|Fenlands −4 to Ben Nevis 1,345|1,154|parliamentary constitutional monarchy
CO22|France|CT6|641,000|68,000,000|Paris|3,031,000,000,000|44,600|aircraft, motor vehicles, pharmaceuticals, wine, electronics|crude petroleum, motor vehicles, natural gas, electronics|coal, iron ore, bauxite, zinc, uranium, antimony, arsenic, potash, timber, fish, hydropower, nuclear|sea level to Mont Blanc 4,809|867|semi-presidential republic
CO23|Russia|CT6,CT1|17,098,000|144,000,000|Moscow|1,862,000,000,000|12,900|crude petroleum, refined petroleum, natural gas, wheat, metals|vehicles, machinery, pharmaceuticals, electronics, plastics|petroleum, natural gas (largest reserves), coal, iron ore, manganese, chromium, nickel, platinum, diamonds, gold, silver, copper, lead, zinc, bauxite, timber|Caspian −28 to Elbrus 5,642|460|federal semi-presidential republic
CO24|Italy|CT6|301,000|59,000,000|Rome|2,255,000,000,000|38,200|machinery, motor vehicles, pharmaceuticals, refined petroleum, fashion/leather, wine|crude petroleum, vehicles, natural gas, pharmaceuticals, electronics|coal, mercury, zinc, potash, marble, barite, asbestos, pumice, fluorspar, feldspar, pyrite, natural gas, crude oil (limited)|sea level to Mont Blanc de Courmayeur 4,748|832|parliamentary republic
CO25|Australia|CT7|7,692,000|27,000,000|Canberra|1,724,000,000,000|63,900|iron ore, coal, LNG, gold, aluminum, beef, wheat|motor vehicles, refined petroleum, telecommunications equipment, electronics|iron ore (world's largest exporter), bauxite, coal, copper, gold, diamonds, uranium, nickel, zinc, LNG, lead, tungsten|Lake Eyre −15 to Kosciuszko 2,228|534|federal parliamentary constitutional monarchy
CO26|New Zealand|CT7|268,000|5,300,000|Wellington|252,000,000,000|47,500|dairy products, meat, wood, fruit, wine, fish|motor vehicles, petroleum, machinery, electronics|natural gas, iron ore sand, coal, gold, limestone, timber, hydropower, geothermal|sea level to Aoraki/Mt Cook 3,724|1,732|parliamentary constitutional monarchy
CO27|Israel|CT1|22,000|9,900,000|Jerusalem (declared)|525,000,000,000|53,000|electronics, diamonds, chemicals, machinery, pharmaceuticals|crude petroleum, diamonds, vehicles, electronics, machinery|potash, copper ore, natural gas (offshore), phosphate rock, magnesium bromide, clays, sand|Dead Sea −430 to Mt Hermon 2,236|435|parliamentary republic
CO28|United Arab Emirates|CT1|84,000|10,000,000|Abu Dhabi|509,000,000,000|50,900|crude petroleum, refined petroleum, natural gas, aluminum, gold re-export|gold, electronics, vehicles, machinery, jewelry|petroleum, natural gas|sea level to Jebel Jais 1,934|78|federal absolute monarchy (federation of emirates)
CO29|Poland|CT6|313,000|38,000,000|Warsaw|842,000,000,000|22,200|machinery, motor vehicles, furniture, electronics, food products|machinery, vehicles, crude petroleum, electronics, chemicals|coal, copper, natural gas, silver, lead, salt, amber, sulfur|sea level to Rysy 2,499|600|parliamentary republic
CO30|Ethiopia|CT2|1,104,000|130,000,000|Addis Ababa|156,000,000,000|1,200|coffee (~30% export revenue), gold, oilseeds, cut flowers, vegetables, khat|petroleum products, machinery, vehicles, wheat, fertilizers|gold, platinum, copper, potash, natural gas, hydropower|Danakil Depression −125 to Ras Dejen 4,550|848|federal parliamentary republic

# oceans(id|name|area_km2|avg_depth_m|max_depth_m|max_depth_location|volume_km3|salinity_ppt|avg_temp_C|major_currents)
OC1|Pacific|168,723,000|3,970|10,935|Mariana Trench (Challenger Deep)|710,000,000|34.5|3.1 (deep avg)|Kuroshio, North Pacific, California (cold), Humboldt (cold), South Equatorial, Antarctic Circumpolar
OC2|Atlantic|85,133,000|3,646|8,376|Puerto Rico Trench|310,000,000|35.0|2.8 (deep avg)|Gulf Stream, North Atlantic Drift, Canary (cold), Benguela (cold), Brazil, Labrador (cold), Antarctic Circumpolar
OC3|Indian|70,560,000|3,741|7,450|Java Trench (Sunda Trench)|264,000,000|34.8|3.7 (deep avg)|Agulhas, Somali (seasonal reversal, monsoon), South Equatorial, West Australian (cold), Antarctic Circumpolar
OC4|Southern (Antarctic)|21,960,000|3,270|7,235|South Sandwich Trench|71,800,000|34.7|−1.8 to 10 (surface)|Antarctic Circumpolar Current (largest by volume: ~130 Sv); Antarctic Coastal Current (westward)
OC5|Arctic|15,558,000|1,205|5,450|Molloy Deep (Fram Strait)|18,750,000|30–34 (variable; freshwater input)|−1.8 to 3 (surface)|Transpolar Drift, Beaufort Gyre; sea ice cover declining ~13% per decade (summer minimum)

# seas(id|name|ocean_fk|area_km2|max_depth_m|salinity_ppt|notes)
SE1|South China Sea|OC1|3,500,000|5,560|32–34|major shipping lane; contested sovereignty; ~$5 trillion annual trade transit
SE2|Caribbean Sea|OC2|2,754,000|7,686|35–36|Cayman Trough; hurricane corridor; coral reef systems
SE3|Mediterranean Sea|OC2|2,500,000|5,267|36–39 (high evaporation)|nearly enclosed; Gibraltar Strait connection; Messinian Salinity Crisis ~5.96 Ma
SE4|Bering Sea|OC1|2,292,000|4,773|30–33|former Beringia land bridge during glacial maxima; major fishery
SE5|Gulf of Mexico|OC2|1,550,000|4,384|36|Loop Current; major petroleum production; hypoxic dead zone (Mississippi outflow)
SE6|Arabian Sea|OC3|3,862,000|5,803|35–37|monsoon-driven upwelling; major shipping (oil tankers); piracy corridor
SE7|Red Sea|OC3|438,000|3,040|36–41 (highest open-sea salinity)|spreading center (divergent: African-Arabian plates); Suez Canal connects to Mediterranean
SE8|Black Sea|OC2 (via Mediterranean)|436,000|2,212|17–18 (surface; anoxic below ~150 m)|world's largest meromictic basin; Bosphorus connection; anoxic deep water
SE9|Baltic Sea|OC2|377,000|459|7–8 (brackish)|low salinity from river input; shallow; freezes partially in winter
SE10|Coral Sea|OC1|4,791,000|9,140|34–36|Great Barrier Reef (world's largest coral system ~2,300 km); warm tropical

# rivers(id|name|continent_fk|length_km|discharge_m3_s|drainage_area_km2|source|mouth|countries)
RV1|Nile|CT2|6,650|2,830|3,349,000|Nyungwe Forest, Rwanda / Lake Victoria|Mediterranean Sea (Egypt)|11 countries
RV2|Amazon|CT4|6,400|209,000|7,050,000|Mantaro River, Andes, Peru|Atlantic Ocean (Brazil)|8 countries
RV3|Yangtze (Chang Jiang)|CT1|6,300|30,166|1,809,000|Tanggula Mountains, Qinghai-Tibet Plateau|East China Sea (Shanghai)|China
RV4|Mississippi-Missouri|CT3|6,275|16,200|2,981,000|Lake Itasca, Minnesota (Mississippi); Brower's Spring, Montana (Missouri)|Gulf of Mexico (Louisiana)|USA, Canada (minor)
RV5|Yenisei-Angara|CT1|5,539|19,600|2,580,000|Mungaragiyn-Gol, Mongolia|Kara Sea (Arctic)|Russia, Mongolia
RV6|Yellow River (Huang He)|CT1|5,464|2,571|752,000|Bayan Har Mountains, Qinghai|Bohai Sea (Shandong)|China
RV7|Congo (Zaire)|CT2|4,700|41,000|3,680,000|Chambeshi River headwaters, Zambia|Atlantic Ocean (DRC/Angola border)|9 countries
RV8|Ganges-Brahmaputra|CT1|Ganges: 2,525; Brahmaputra: 2,900|combined ~38,000|1,730,000|Gangotri Glacier (Ganges); Angsi Glacier, Tibet (Brahmaputra)|Bay of Bengal (Bangladesh)|India, Bangladesh, China, Nepal, Bhutan
RV9|Danube|CT6|2,850|6,500|817,000|Black Forest, Germany|Black Sea (Romania/Ukraine delta)|10 countries
RV10|Mekong|CT1|4,350|16,000|795,000|Lasagongma Spring, Qinghai-Tibet Plateau|South China Sea (Vietnam)|6 countries

# mountains(id|name|continent_fk|range|peak_elevation_m|coordinates|formation|tectonic_cause)
MT1|Everest|CT1|Himalayas|8,849|27.9881°N, 86.9250°E|collision orogeny; ongoing uplift ~4 mm/yr|Indian plate colliding with Eurasian plate
MT2|K2|CT1|Karakoram|8,611|35.8800°N, 76.5133°E|collision orogeny|Indian-Eurasian collision
MT3|Aconcagua|CT4|Andes|6,961|32.6532°S, 70.0109°W|subduction orogeny|Nazca plate subducting under South American plate
MT4|Denali|CT3|Alaska Range|6,190|63.0695°N, 151.0074°W|subduction + transform|Pacific plate subducting under North American plate
MT5|Kilimanjaro|CT2|standalone (East African Rift)|5,895|3.0674°S, 37.3556°E|volcanic (stratovolcano, dormant)|East African Rift (continental divergence)
MT6|Elbrus|CT6|Caucasus|5,642|43.3499°N, 42.4453°E|volcanic (dormant stratovolcano)|Arabian-Eurasian collision zone
MT7|Vinson Massif|CT5|Sentinel Range, Ellsworth Mountains|4,892|78.5254°S, 85.6171°W|fault-block uplift|ancient orogeny; Gondwana breakup related
MT8|Mont Blanc|CT6|Alps|4,809|45.8326°N, 6.8652°E|collision orogeny|African plate colliding with Eurasian plate (via Adriatic microplate)
MT9|Puncak Jaya (Carstensz)|CT7|Sudirman Range, Papua|4,884|4.0833°S, 137.1833°E|collision orogeny|Australian plate colliding with Pacific plate
MT10|Mauna Kea|CT3|Hawaii (shield volcano)|4,207 (above sea level); 10,210 (from ocean floor)|19.8207°N, 155.4680°W|hotspot volcanism|Pacific plate moving over Hawaii hotspot

# deserts(id|name|continent_fk|area_km2|type|avg_rainfall_mm_yr|avg_temp_C|notable_features)
DS1|Antarctic (polar)|CT5|14,200,000|polar ice|~166 (mostly snow)|−49 (interior avg)|largest desert by area; ice sheet up to 4,776 m thick; contains ~70% of Earth's fresh water
DS2|Arctic (polar)|CT3,CT6,CT1|13,985,000|polar ice|~250|−20 (avg)|second largest; permafrost; sea ice; shrinking due to climate change
DS3|Sahara|CT2|9,200,000|subtropical (hot)|<25 (hyperarid core); 100 (margins)|30 (avg); 58 recorded max (debated)|largest hot desert; Erg (sand seas), Reg (gravel plains), Hamada (rocky plateaus); expanding southward
DS4|Arabian|CT1|2,330,000|subtropical (hot)|<100|27 (avg)|Rub' al Khali (Empty Quarter): largest contiguous sand sea 650,000 km²
DS5|Gobi|CT1|1,295,000|cold winter (rain shadow)|194|−2.5 (avg annual); −40 winter to 45 summer|rain shadow of Himalayas; major fossil sites; expanding ~3,600 km²/yr (desertification)
DS6|Kalahari|CT2|900,000|semi-arid|250–500|19 (avg)|not true hyperarid desert; supports some vegetation; Okavango Delta inland
DS7|Patagonian|CT4|673,000|cold winter (rain shadow)|150–250|6 (avg)|rain shadow of Andes; strong persistent winds
DS8|Great Victoria|CT7|647,000|subtropical|200–250|20 (avg)|Australia's largest desert; spinifex grasslands
DS9|Atacama|CT4|105,000|coastal cold|<15 (hyperarid core; some stations 0 recorded rainfall)|18 (avg)|driest non-polar place; Mars analog site; nitrate/lithium deposits; Humboldt Current + rain shadow
DS10|Namib|CT2|81,000|coastal cold|5–85|17 (avg)|oldest desert (~55–80 million years); fog-dependent ecosystem; Sossusvlei dunes up to 325 m

# climate_zones(id|name|koppen_code|latitude_range|avg_temp_range_C|avg_rainfall_mm_yr|characteristics)
CZ1|tropical rainforest|Af|0°–10° N/S|24–28 (year-round)|>2,000|no dry season; highest biodiversity; Amazon, Congo, SE Asia
CZ2|tropical monsoon|Am|5°–25° N/S|24–28|1,500–3,000|short dry season offset by heavy monsoon; India, SE Asia, W Africa
CZ3|tropical savanna|Aw/As|5°–20° N/S|20–30|800–1,600|distinct wet/dry seasons; grasslands with scattered trees; Sahel, Brazilian cerrado
CZ4|hot desert (arid)|BWh|15°–30° N/S|20–35 (extreme diurnal range)|<250|Sahara, Arabian, Australian interior; subtropical high pressure; clear skies
CZ5|cold desert (arid)|BWk|35°–50° N/S|−5 to 20 (extreme seasonal range)|<250|Gobi, Patagonia; rain shadow; continental interior
CZ6|hot semi-arid (steppe)|BSh|15°–35° N/S|18–30|250–500|transition between desert and wetter zones; Sahel margins, outback margins
CZ7|cold semi-arid (steppe)|BSk|35°–55° N/S|0–18|250–500|Great Plains, Central Asian steppe, Patagonia margin
CZ8|Mediterranean|Csa/Csb|30°–45° N/S (western coasts)|10–25|400–900|dry hot summers, mild wet winters; Mediterranean basin, California, Chile, SW Australia, Cape region
CZ9|humid subtropical|Cfa|25°–40° N/S (eastern coasts)|15–25|1,000–1,500|hot humid summers, mild winters; SE USA, E China, SE Brazil, E Australia
CZ10|oceanic (marine west coast)|Cfb/Cfc|45°–60° N/S (western coasts)|5–15|750–2,500|cool summers, mild winters, rain year-round; NW Europe, NZ, Pacific NW, S Chile
CZ11|humid continental (hot summer)|Dfa/Dwa|35°–50° N|−5 to 25 (large seasonal range)|600–1,200|large temperature range; NE USA, N China, Korea
CZ12|humid continental (warm summer)|Dfb/Dwb|40°–60° N|−10 to 20|500–1,000|shorter warm season; S Scandinavia, Russia west of Urals, N Japan
CZ13|subarctic (boreal/taiga)|Dfc/Dwc/Dfd|50°–70° N|−30 to 15 (extreme range)|300–600|long harsh winters; world's largest biome by area; Siberia, Canada, Alaska
CZ14|tundra|ET|60°–75° N; Antarctic coast|−30 to 10|150–350|permafrost; very short growing season; treeless; Arctic coast, Antarctic Peninsula
CZ15|ice cap|EF|interior Greenland, Antarctica|−60 to −10 (Antarctica interior avg −49)|<166|permanent ice; no vegetation; katabatic winds
CZ16|alpine/highland|H|any latitude at high elevation|decreases ~6.5°C per 1,000 m elevation|variable (orographic enhancement)|altitudinal zonation mimics latitudinal zonation; Andes, Himalayas, East African highlands

# biomes(id|name|climate_zone_fk|area_km2|dominant_vegetation|characteristic_fauna|soil_type|carbon_storage_Gt)
BM1|tropical rainforest|CZ1|17,000,000|broadleaf evergreen canopy; emergent, canopy, understory, floor layers; epiphytes, lianas|primates, big cats, parrots, insects (>50% of all species)|oxisols (laterite): deep, weathered, nutrient-poor, acidic; nutrients in biomass not soil|~250 (vegetation + soil)
BM2|tropical savanna/grassland|CZ3|20,000,000|grasses with scattered fire-adapted trees (Acacia, baobab)|large herbivores (elephants, zebra, wildebeest), predators (lions, cheetahs)|alfisols/ultisols; seasonal moisture; laterite hardpan possible|~65
BM3|temperate deciduous forest|CZ9,CZ11|10,400,000|deciduous broadleaf (oak, maple, beech); seasonal leaf drop|deer, bears, wolves, songbirds|alfisols: fertile, moderate organic matter; well-developed horizons|~100
BM4|temperate grassland|CZ7,CZ11|9,000,000|grasses (tall in wetter east, short in drier west); few trees|bison, pronghorn, prairie dogs, raptors|mollisols: deep, dark, organic-rich topsoil; world's most fertile; major agricultural soils|~60
BM5|boreal forest (taiga)|CZ13|17,000,000|coniferous evergreen (spruce, pine, fir, larch); understory mosses/lichens|moose, wolves, bears, lynx, wolverine|spodosols: acidic, sandy, leached upper layers; organic mat; slow decomposition|~270 (largest terrestrial carbon store; includes peatlands)
BM6|tundra|CZ14|8,000,000|mosses, lichens, sedges, dwarf shrubs; no trees|caribou/reindeer, musk ox, arctic fox, lemmings, snowy owl|gelisols: permafrost within 2 m of surface; active layer thaws seasonally|~250 (permafrost carbon; potential climate feedback if thawed)
BM7|desert|CZ4,CZ5|33,000,000|sparse xerophytic vegetation; cacti, succulents, shrubs; some bare|reptiles, small mammals, insects; adapted to heat/water stress|aridisols/entisols: thin, mineral-rich, low organic matter; caliche layers|~10
BM8|Mediterranean scrubland (chaparral/maquis)|CZ8|3,400,000|evergreen shrubs, sclerophyllous leaves; fire-adapted|rabbits, reptiles, raptors, insects|alfisols; thin rocky; fire-regenerated nutrient cycling|~15
BM9|mangrove|CZ1,CZ2 (coastal)|150,000|salt-tolerant trees with aerial roots; intertidal|fish nursery, crabs, crocodilians, wading birds|histosols/entisols: waterlogged, anaerobic, organic-rich; carbon-dense sediment|~5 (dense per unit area: 3–5× tropical forest per hectare)
BM10|coral reef|OC1,OC2,OC3 (tropical shallow)|~285,000 (substrate area)|zooxanthellae-coral symbiosis; calcareous framework|fish (~25% marine species), invertebrates, sea turtles, sharks|biogenic carbonate (limestone framework)|~2 (framework carbon)

# earth_layers(id|name|depth_range_km|thickness_km|composition|state|temperature_range_C|density_g_cm3|seismic_characteristics)
EL1|crust (continental)|0–30 to 70|30–70|silicates: granite (SiO₂-rich, felsic); avg composition = granodiorite|solid|surface to ~400|2.7–2.8|P-wave velocity 6.0–6.5 km/s; Moho discontinuity at base
EL2|crust (oceanic)|0–7 to 10|7–10|basalt + gabbro (mafic, denser)|solid|surface to ~400|2.9–3.0|P-wave velocity 6.5–7.0 km/s; thinner but denser than continental
EL3|upper mantle (lithospheric)|base of crust to ~100|variable (crust + lithospheric mantle = lithosphere ~100 km)|peridotite (olivine, pyroxene)|solid (rigid)|400–1,300|3.3–3.4|lithosphere = rigid plate that moves; LAB (lithosphere-asthenosphere boundary) at ~100 km
EL4|upper mantle (asthenosphere)|~100–660|~560|peridotite; partially molten (~1–5% melt)|plastic/ductile (solid but flows)|1,300–1,600|3.4–3.6|low-velocity zone (seismic waves slow due to partial melt); enables plate motion
EL5|transition zone|410–660|250|olivine → wadsleyite (410 km) → ringwoodite (520 km) → perovskite + magnesiowüstite (660 km)|solid (phase transitions)|1,600–1,900|3.7–4.0|seismic discontinuities at 410 km and 660 km (mineral phase changes)
EL6|lower mantle|660–2,891|2,231|bridgmanite (Mg-perovskite) + magnesiowüstite; highly compressed|solid (viscous, convects very slowly)|1,900–2,700|4.0–5.5|seismically relatively uniform; large low-shear-velocity provinces (LLSVPs) at base near CMB
EL7|outer core|2,891–5,150|2,259|iron-nickel alloy + lighter elements (S, O, Si, H)|liquid|2,700–4,200|9.9–12.2|S-waves do not transmit → confirms liquid; Gutenberg discontinuity at 2,891 km (CMB); source of magnetic field (geodynamo)
EL8|inner core|5,150–6,371|1,221|iron-nickel alloy (solid crystalline)|solid|4,200–5,700 (center ~5,400)|12.8–13.1|Lehmann discontinuity at 5,150 km; super-rotation debated (~0.1–1°/yr faster than surface); anisotropic (P-waves faster N-S than E-W)

# atmosphere_layers(id|name|altitude_range_km|temperature_trend|key_features|composition_notes)
AL1|troposphere|0–8 (poles) to 18 (equator)|decreases ~6.5°C/km (lapse rate)|all weather; 75% of atmospheric mass; convection; water vapor|N₂ 78.08%, O₂ 20.95%, Ar 0.93%, CO₂ 0.042% (2024, ~425 ppm), H₂O 0–4%
AL2|stratosphere|~8/18–50|increases with altitude (ozone absorbs UV)|ozone layer (O₃ peak at ~20–25 km); minimal weather; stable stratification; jet aircraft cruise upper troposphere/lower stratosphere|dry; ozone concentration ~1–10 ppm
AL3|mesosphere|50–85|decreases with altitude (coldest layer at mesopause ~−85°C)|meteors burn up; noctilucent clouds; sprites/elves above thunderstorms|very thin; some ozone; atomic oxygen
AL4|thermosphere|85–600|increases dramatically (up to 2,500°C during solar max; but low particle density = low heat transfer)|aurora (charged particles from solar wind excite atmospheric gases); ISS orbits ~400 km; ionosphere overlaps (ionized layers: D, E, F)|atomic oxygen dominant above ~200 km; N₂ below
AL5|exosphere|600–10,000+|temperature concept less meaningful (particles on ballistic trajectories)|transition to outer space; hydrogen and helium escape to space; satellites orbit|H, He dominate; extremely low density; no clear upper boundary

# solar_system(id|name|type|distance_from_sun_AU|orbital_period|rotation_period|diameter_km|mass_kg|surface_gravity_m_s2|atmosphere|moons|notable_features)
SS1|Sun|G2V main-sequence star|0|—|~25 days (equator) to ~35 days (poles) differential rotation|1,392,700|1.989 × 10³⁰|274|hydrogen plasma; photosphere ~5,778 K; corona ~1–3 × 10⁶ K|—|99.86% of solar system mass; luminosity 3.828 × 10²⁶ W; main sequence age ~4.6 Gyr; ~5 Gyr remaining before red giant
SS2|Mercury|terrestrial planet|0.387|87.97 days|58.646 days (3:2 spin-orbit resonance)|4,880|3.302 × 10²³|3.7|negligible (exosphere: Na, K, O)|0|largest iron core relative to size (~85% radius); temperature range −180 to 430°C; permanently shadowed craters may hold water ice
SS3|Venus|terrestrial planet|0.723|224.7 days|243 days retrograde (day longer than year)|12,104|4.867 × 10²⁴|8.87|CO₂ 96.5%, N₂ 3.5%; surface pressure 92 atm; sulfuric acid clouds|0|runaway greenhouse effect; surface ~465°C (hottest planet); retrograde rotation; similar size to Earth
SS4|Earth|terrestrial planet|1.000|365.25 days|23 h 56 min 4 s (sidereal)|12,742|5.972 × 10²⁴|9.81|N₂ 78%, O₂ 21%, Ar 1%, CO₂ ~0.042%|1 (Moon)|liquid water; plate tectonics; magnetic field; biosphere; only known life
SS5|Mars|terrestrial planet|1.524|687 days|24 h 37 min|6,779|6.417 × 10²³|3.72|CO₂ 95%, N₂ 2.6%; surface pressure 0.006 atm|2 (Phobos, Deimos)|Olympus Mons 21,900 m (tallest volcano); Valles Marineris 4,000 km canyon; polar CO₂/H₂O ice caps; evidence of past liquid water
SS6|Jupiter|gas giant|5.203|11.86 years|9 h 55 min (fastest rotation)|139,820|1.898 × 10²⁷|24.79|H₂ ~90%, He ~10%; metallic hydrogen interior|95 confirmed|Great Red Spot (anticyclonic storm ~16,000 km); strongest magnetic field; Galilean moons (Io, Europa, Ganymede, Callisto); Europa: subsurface ocean
SS7|Saturn|gas giant|9.537|29.46 years|10 h 33 min|116,460|5.683 × 10²⁶|10.44|H₂ ~96%, He ~3%|146 confirmed|ring system (ice + rock, 280,000 km diameter, <1 km thick); Titan (thick N₂ atmosphere, methane lakes); Enceladus (water geysers, subsurface ocean); lowest density planet (0.687 g/cm³)
SS8|Uranus|ice giant|19.19|84.01 years|17 h 14 min retrograde|50,724|8.681 × 10²⁵|8.87|H₂ ~83%, He ~15%, CH₄ ~2%|28 confirmed|97.8° axial tilt (rolls on side); methane gives blue-green color; faint ring system; extreme seasonal variation
SS9|Neptune|ice giant|30.07|164.8 years|16 h 6 min|49,244|1.024 × 10²⁶|11.15|H₂ ~80%, He ~19%, CH₄ ~1.5%|16 confirmed|strongest winds in solar system (~2,100 km/h); dark spots; Triton (retrograde orbit, geysers, likely captured KBO)
SS10|Moon (Luna)|natural satellite of Earth|1.000 (with Earth)|27.32 days (sidereal) = orbital period|27.32 days (synchronous → same face always toward Earth)|3,474|7.342 × 10²²|1.62|negligible (exosphere)|—|tidally locked; maria (basaltic plains) + highlands (anorthosite); regolith; stabilizes Earth's axial tilt (~23.4°); drives tides; formed ~4.5 Ga (giant impact hypothesis)
SS11|Asteroid Belt|region|2.1–3.3 AU|—|—|—|total ~3 × 10²¹ (4% of Moon)|—|—|—|Ceres (dwarf planet, 940 km); Vesta (525 km); total mass small; Jupiter resonances create Kirkwood gaps
SS12|Kuiper Belt|region|30–55 AU|—|—|—|total estimated ~0.1 Earth mass|—|—|—|Pluto (dwarf planet, 2,377 km); Eris (2,326 km); Haumea, Makemake; source of short-period comets
SS13|Oort Cloud|region|~2,000–100,000 AU (hypothesized)|—|—|—|estimated ~5 Earth masses|—|—|—|spherical shell of icy bodies; source of long-period comets; outer boundary defines gravitational influence of Sun; never directly observed

# orbital_mechanics(id|parameter|value|unit|significance_for_earth)
OM1|Earth-Sun distance (1 AU)|149,597,870.7|km|defines habitable zone distance; light travel time ~8 min 20 s
OM2|Earth orbital eccentricity|0.0167|dimensionless|nearly circular; varies 0.000055–0.0679 over ~100,000 yr (Milankovitch); affects insolation by ~6.8%
OM3|Earth axial tilt (obliquity)|23.4393°|degrees|causes seasons; varies 22.1°–24.5° over ~41,000 yr (Milankovitch)
OM4|precession of equinoxes|~25,772 yr cycle|years|Earth's rotational axis traces cone; shifts solstice/equinox dates relative to orbit; Milankovitch cycle
OM5|Earth rotation period (sidereal)|23 h 56 min 4.1 s|time|defines day; slowing ~2.3 ms/century due to tidal friction with Moon
OM6|Moon orbital distance (mean)|384,400|km|~60 Earth radii; receding ~3.8 cm/yr; controls tidal amplitude
OM7|solar luminosity|3.828 × 10²⁶|W|determines Earth's energy budget; increasing ~1% per 100 Myr (faint young Sun paradox)
OM8|solar constant (Earth orbit)|~1,361|W/m²|total solar irradiance at 1 AU; varies ~0.1% over solar cycle (~11 yr)
OM9|Earth's magnetic field dipole moment|~7.94 × 10²²|A·m²|deflects solar wind; protects atmosphere from stripping; weakening ~5% per century; polarity reversals avg every ~200,000–300,000 yr
OM10|Roche limit (Earth-Moon)|~9,500 (rigid body); ~18,400 (fluid body)|km|Moon closer than this → tidal forces exceed self-gravity → disintegration; Saturn's rings within Roche limit
OM11|Hill sphere (Earth)|~1,500,000|km|region where Earth's gravity dominates over Sun's; Moon orbits well within Hill sphere
OM12|escape velocity (Earth surface)|11.186|km/s|minimum velocity to leave Earth's gravitational well without further propulsion

# earth_solar(id|phenomenon|cause|period|magnitude|effect_on_earth)
ES1|seasons|axial tilt (23.4°) + orbital position|annual (365.25 days)|insolation varies ~50% between summer and winter solstice at mid-latitudes|temperature cycles, growing seasons, weather patterns, animal migration
ES2|tides|gravitational pull of Moon (~68%) and Sun (~32%) on Earth's ocean|~12.42 h (semidiurnal lunar); ~24 h (diurnal); spring tides at new/full Moon|range: 0.5 m (open ocean) to 16 m (Bay of Fundy)|coastal ecosystems, navigation, tidal energy, tidal friction slowing Earth rotation
ES3|Milankovitch cycles|orbital eccentricity (~100,000 yr) + obliquity (~41,000 yr) + precession (~26,000 yr)|composite: dominant ~100,000 yr glacial cycle in Pleistocene|insolation at 65°N summer varies ~10–15%|ice ages and interglacials; CO₂ and sea level oscillations; Quaternary glaciation timing
ES4|solar cycle|periodic variation in solar magnetic activity (sunspot number)|~11 yr (Schwabe cycle); ~22 yr (Hale magnetic cycle)|sunspot number: 0 (minimum) to ~200+ (maximum); TSI varies ~0.1%|space weather (CME, geomagnetic storms); minor climate effect; aurora frequency; satellite/communications disruption
ES5|geomagnetic field|convection in liquid outer core (geodynamo); Earth's rotation (Coriolis)|continuous; secular variation; polarity reversals every ~200,000–300,000 yr (current: last reversal Brunhes-Matuyama ~780,000 yr ago)|dipole field ~25–65 μT at surface; South Atlantic Anomaly (weak spot)|shields atmosphere from solar wind stripping; deflects charged particles; enables magnetic navigation; radiation belts (Van Allen)
ES6|precession of equinoxes|gravitational torque of Sun and Moon on Earth's equatorial bulge|~25,772 yr|rotational axis traces cone with half-angle ~23.4°|shifts seasonal timing relative to orbital position; currently perihelion near N winter solstice (moderates N seasons); in ~13,000 yr perihelion near N summer (amplifies N seasons)
ES7|Earth's energy budget|solar input vs terrestrial radiation; greenhouse effect|continuous steady-state (perturbed by CO₂ increase)|incoming solar: ~340 W/m² (avg over sphere); reflected: ~100 W/m² (albedo ~0.30); absorbed: ~240 W/m²; outgoing IR: ~240 W/m² (current imbalance ~1 W/m² → warming)|climate; greenhouse effect raises surface temperature from theoretical −18°C to actual +15°C (33°C warming); current CO₂ forcing → ~+1.2°C above preindustrial (2024)
ES8|Chandler wobble|free nutation of Earth's rotation axis|~433 days|amplitude ~9 m at poles (0.7 arcsec)|minor latitude variation; affects precise geodetic measurements
ES9|length of day variation|tidal friction (Moon), atmospheric/oceanic angular momentum exchange, post-glacial rebound, core-mantle coupling|secular slowing + short-term variations|slowing ~2.3 ms/century (tidal); short-term variations ~1 ms|leap seconds (introduced 1972, 27 added through 2017); UTC coordination; 600 Ma ago day was ~21 hours
ES10|aurorae|solar wind charged particles guided by magnetic field to polar regions → excite atmospheric N₂ (green, blue) and O (green 557.7 nm, red 630 nm)|continuous (enhanced during solar maximum / CME events)|visible at geomagnetic latitudes >~60° (expands to ~40° in major storms)|visual phenomenon; ionospheric disturbance; GPS/radio disruption during geomagnetic storms

# concepts(id|name|definition|category)
GC1|plate tectonics|lithospheric plates move on asthenosphere driven by mantle convection, ridge push, and slab pull; creates earthquakes, volcanoes, mountains, ocean basins|mechanism
GC2|mantle convection|thermal convection in mantle driven by radiogenic heat + primordial heat; hot material rises at ridges/plumes, cool material sinks at subduction zones; drives plate motion|mechanism
GC3|subduction|denser oceanic plate descends beneath another plate at convergent boundary; creates trenches, volcanic arcs, earthquakes; recycles oceanic crust into mantle|mechanism
GC4|seafloor spreading|new oceanic crust created at mid-ocean ridges where plates diverge; magma rises, solidifies, moves laterally; magnetic stripe symmetry confirms|mechanism
GC5|orogenesis|mountain building via convergent plate interactions: collision (Himalayas), subduction (Andes), accretion (N American Cordillera)|mechanism
GC6|isostasy|gravitational equilibrium of lithosphere floating on asthenosphere; thicker/less-dense crust rises higher; post-glacial rebound is isostatic adjustment|mechanism
GC7|Coriolis effect|deflection of moving objects on rotating Earth; rightward in N hemisphere, leftward in S; governs wind patterns, ocean currents, cyclone rotation|mechanism
GC8|Hadley cell|tropical atmospheric circulation cell; warm air rises at ITCZ (equator), flows poleward at altitude, sinks at ~30° latitude (subtropical high pressure); drives trade winds|mechanism
GC9|Ferrel cell|mid-latitude circulation cell (~30°–60°); surface winds = westerlies; driven indirectly by Hadley and polar cells|mechanism
GC10|polar cell|high-latitude circulation cell (~60°–90°); cold dense air sinks at poles, flows equatorward; polar easterlies at surface|mechanism
GC11|thermohaline circulation|global ocean conveyor belt driven by density differences (temperature + salinity); North Atlantic Deep Water formation (sinking cold salty water); ~1,000 year full circuit|mechanism
GC12|El Niño–Southern Oscillation (ENSO)|coupled ocean-atmosphere cycle in tropical Pacific; El Niño: weakened trade winds → warm water shifts east → suppressed upwelling; La Niña: opposite; period 2–7 yr|mechanism
GC13|monsoon|seasonal wind reversal driven by differential heating of land and ocean; brings wet season; South Asian monsoon strongest (affects ~2 billion people)|mechanism
GC14|greenhouse effect|atmospheric gases (CO₂, CH₄, N₂O, H₂O) absorb and re-emit terrestrial infrared radiation → surface warmer than blackbody temperature; natural effect +33°C; enhanced by anthropogenic emissions|mechanism
GC15|carbon cycle|movement of carbon through atmosphere (CO₂), biosphere (organic C), ocean (dissolved CO₂/carbonate), lithosphere (fossil carbon, carbonate rock); human perturbation: ~10 Gt C/yr fossil emissions (2024)|cycle
GC16|water cycle (hydrological)|evaporation (~500,000 km³/yr) → atmospheric transport → precipitation (~500,000 km³/yr) → runoff + infiltration → ocean/groundwater → evaporation; total water ~1.386 × 10⁹ km³; 97.5% saline, 2.5% fresh (68.7% of fresh in ice)|cycle
GC17|rock cycle|igneous (crystallization from magma) → sedimentary (weathering, erosion, deposition, lithification) → metamorphic (heat/pressure) → magma (melting) → igneous; continuous recycling|cycle
GC18|Milankovitch cycles|orbital parameter variations (eccentricity, obliquity, precession) modulating solar insolation distribution; pacemaker of Pleistocene glacial-interglacial cycles|mechanism
GC19|albedo|fraction of incoming solar radiation reflected by surface; fresh snow ~0.80–0.90; ocean ~0.06; forest ~0.10–0.20; Earth avg ~0.30; ice-albedo feedback amplifies warming/cooling|property
GC20|habitable zone|orbital region around star where liquid water can exist on surface; Sun's HZ ~0.95–1.67 AU (conservative); depends on atmospheric composition and greenhouse effect|boundary
GC21|Lagrange points|5 positions in Sun-Earth system where gravitational and centrifugal forces balance; L1 (~1.5 Mkm sunward: solar observatories, DSCOVR); L2 (~1.5 Mkm anti-sunward: JWST)|boundary
GC22|Van Allen radiation belts|two toroidal zones of trapped charged particles (protons + electrons) held by Earth's magnetic field; inner belt (~1,000–6,000 km, protons); outer belt (~13,000–60,000 km, electrons)|boundary
GC23|magnetosphere|region around Earth dominated by its magnetic field; compressed on sunward side (~10 Earth radii) by solar wind; extended tail on night side (~200+ Earth radii)|boundary
GC24|heliosphere|region of space dominated by solar wind; extends to ~120 AU (heliopause, where solar wind pressure = interstellar medium pressure); Voyager 1 crossed heliopause 2012 at ~121 AU|boundary
GC25|geoid|equipotential surface of Earth's gravity field that best fits mean sea level; deviates from ellipsoid by ±100 m due to density variations; reference for elevation measurement|property
GC26|orogeny|specific mountain-building event; examples: Alpine orogeny (ongoing), Caledonian (~490–390 Ma), Variscan/Hercynian (~380–280 Ma), Laramide (~80–35 Ma)|event_type
GC27|hotspot volcanism|volcanic activity driven by mantle plume (deep thermal anomaly) independent of plate boundaries; plate moves over stationary plume → volcanic chain; Hawaii, Yellowstone, Iceland (also on ridge)|mechanism
GC28|glaciation|expansion of ice sheets/glaciers during cold periods; Quaternary glaciation: ~30 glacial-interglacial cycles in past 2.6 Myr; last glacial maximum ~20,000 yr ago; sea level ~120 m lower|process
GC29|sea level|global mean height of ocean surface; currently ~3.4 mm/yr rise (2006–2024); thermal expansion + ice melt; since 1900 ~+20 cm; LGM was ~120 m lower; Pliocene (3 Ma) was ~15–25 m higher|measurement
GC30|supercontinent cycle|assembly and breakup of supercontinents over ~400–600 Myr; Pangaea (~335–175 Ma), Rodinia (~1,100–750 Ma), Columbia/Nuna (~1,800–1,300 Ma); Wilson cycle of ocean opening/closing|mechanism

# relationships(from|rel|to)
# continent → plate
CT1|part_of|TP3
CT1|part_of|TP6
CT2|part_of|TP4
CT3|part_of|TP2
CT4|part_of|TP7
CT5|part_of|TP5
CT6|part_of|TP3
CT7|part_of|TP6
# plate mechanics
GC1|requires|GC2
GC2|enables|GC1
GC3|specializes|GC1
GC4|specializes|GC1
GC5|requires|GC1
GC6|requires|EL4
TP1|enables|GC3
TP8|enables|MT3
TP6|enables|MT1
TP4|enables|MT5
TP10|enables|MT6
GC27|enables|MT10
GC4|enables|EL2
GC3|enables|TP1
# earth layer sequence
EL1|precedes|EL3
EL2|precedes|EL3
EL3|precedes|EL4
EL4|precedes|EL5
EL5|precedes|EL6
EL6|precedes|EL7
EL7|precedes|EL8
EL7|enables|ES5
EL7|enables|GC23
EL4|enables|GC1
# atmosphere layer sequence
AL1|precedes|AL2
AL2|precedes|AL3
AL3|precedes|AL4
AL4|precedes|AL5
AL1|contains|GC14
AL2|contains|GC19
# atmospheric circulation
GC7|enables|GC8
GC7|enables|GC9
GC7|enables|GC10
GC8|enables|GC13
GC8|precedes|GC9
GC9|precedes|GC10
GC11|enables|CZ10
GC12|enables|CZ1
GC13|enables|CZ2
# climate → biome
CZ1|enables|BM1
CZ3|enables|BM2
CZ9|enables|BM3
CZ11|enables|BM3
CZ7|enables|BM4
CZ8|enables|BM8
CZ13|enables|BM5
CZ14|enables|BM6
CZ4|enables|BM7
CZ5|enables|BM7
# ocean circulation
OC1|contains|SE1
OC1|contains|SE4
OC1|contains|SE10
OC2|contains|SE2
OC2|contains|SE3
OC2|contains|SE5
OC2|contains|SE8
OC2|contains|SE9
OC3|contains|SE6
OC3|contains|SE7
GC11|part_of|OC2
GC11|part_of|OC3
GC11|part_of|OC1
# river → continent
RV1|part_of|CT2
RV2|part_of|CT4
RV3|part_of|CT1
RV4|part_of|CT3
RV5|part_of|CT1
RV6|part_of|CT1
RV7|part_of|CT2
RV8|part_of|CT1
RV9|part_of|CT6
RV10|part_of|CT1
# desert → climate zone
DS1|instance_of|CZ15
DS2|instance_of|CZ14
DS3|instance_of|CZ4
DS4|instance_of|CZ4
DS5|instance_of|CZ5
DS6|instance_of|CZ6
DS7|instance_of|CZ5
DS8|instance_of|CZ4
DS9|instance_of|CZ4
DS10|instance_of|CZ4
# mountain → tectonic cause
MT1|determined_by|TP6
MT1|determined_by|TP3
MT3|determined_by|TP8
MT3|determined_by|TP7
MT5|determined_by|TP4
MT8|determined_by|TP4
MT8|determined_by|TP3
MT10|determined_by|GC27
# solar system relationships
SS1|enables|SS4
SS1|enables|GC20
SS10|enables|ES2
SS10|enables|OM3
SS4|part_of|SS1
SS4|requires|GC20
SS6|enables|SS11
SS12|contains|SS9
GC24|contains|SS1
GC24|contains|SS11
GC24|contains|SS12
GC24|contains|SS13
# earth-solar relationships
OM3|enables|ES1
OM2|enables|ES3
OM4|enables|ES6
OM6|enables|ES2
OM7|enables|ES7
OM8|enables|ES7
OM9|enables|ES5
OM9|enables|GC22
OM9|enables|GC23
ES3|determined_by|GC18
ES5|determined_by|EL7
ES7|determined_by|GC14
ES7|determined_by|GC19
ES2|determined_by|SS10
ES2|determined_by|SS1
ES9|determined_by|SS10
# cycles
GC15|requires|AL1
GC15|requires|OC1,OC2,OC3
GC15|enables|GC14
GC16|requires|SS1
GC16|enables|AL1
GC17|requires|GC1
GC17|requires|GC2
GC30|determined_by|GC2
GC28|determined_by|GC18
GC28|enables|GC29
GC19|enables|GC28
# country → continent
CO1|part_of|CT1
CO2|part_of|CT1
CO3|part_of|CT1
CO4|part_of|CT1
CO5|part_of|CT1
CO6|part_of|CT1
CO7|part_of|CT1
CO7|part_of|CT6
CO8|part_of|CT1
CO9|part_of|CT2
CO10|part_of|CT2
CO11|part_of|CT2
CO12|part_of|CT2
CO13|part_of|CT2
CO14|part_of|CT3
CO15|part_of|CT3
CO16|part_of|CT3
CO17|part_of|CT4
CO18|part_of|CT4
CO19|part_of|CT4
CO20|part_of|CT6
CO21|part_of|CT6
CO22|part_of|CT6
CO23|part_of|CT6
CO23|part_of|CT1
CO24|part_of|CT6
CO25|part_of|CT7
CO26|part_of|CT7
CO27|part_of|CT1
CO28|part_of|CT1
CO29|part_of|CT6
CO30|part_of|CT2

# section_index(section|title|ids)
1|Continents|CT1-CT7
2|Tectonic Plates|TP1-TP14
3|Countries|CO1-CO30
4|Oceans|OC1-OC5
5|Seas|SE1-SE10
6|Rivers|RV1-RV10
7|Mountains|MT1-MT10
8|Deserts|DS1-DS10
9|Climate Zones|CZ1-CZ16
10|Biomes|BM1-BM10
11|Earth Interior Layers|EL1-EL8
12|Atmosphere Layers|AL1-AL5
13|Solar System Bodies|SS1-SS13
14|Orbital Mechanics|OM1-OM12
15|Earth-Solar Phenomena|ES1-ES10
16|Geographic and Planetary Concepts|GC1-GC30
17|Relationships|all

# decode_legend
id_prefixes: CT=continent, TP=tectonic_plate, CO=country, OC=ocean, SE=sea, RV=river, MT=mountain, DS=desert, CZ=climate_zone, BM=biome, EL=earth_layer, AL=atmosphere_layer, SS=solar_system_body, OM=orbital_mechanics, ES=earth_solar_phenomenon, GC=geographic_concept
rel_types: enables|requires|prevents|specializes|generalizes|part_of|contains|follows|precedes|instance_of|determined_by|derived_from|composed_of|equivalent_to|extends
notation: AU=astronomical unit (149,597,870.7 km); Gt=gigatonnes; Gyr=billion years; Ma=million years ago; LGM=last glacial maximum; ITCZ=Intertropical Convergence Zone; CMB=core-mantle boundary; LAB=lithosphere-asthenosphere boundary; TSI=total solar irradiance; CME=coronal mass ejection; HZ=habitable zone; ppm=parts per million; Sv=sverdrup (10⁶ m³/s); _fk=foreign key; ~=approximate; km²=square kilometers; m³/s=cubic meters per second; W/m²=watts per square meter; g/cm³=grams per cubic centimeter; μT=microtesla; mm/yr=millimeters per year
units: distances in km unless AU specified; areas in km²; masses in kg; temperatures in °C unless K specified; rainfall in mm/yr; GDP in nominal USD 2023; population estimates 2024 mid-year
confidence: country data from World Bank/IMF/CIA World Factbook 2023–2024; solar system data from NASA/JPL/IAU; Earth interior from PREM (Preliminary Reference Earth Model); climate data from IPCC AR6 and CRU/NOAA; tectonic velocities from GPS and MORVEL; all facts at reference_geography confidence level
scope: global physical and political geography; Earth systems (geosphere, hydrosphere, atmosphere, biosphere); local cosmic context (solar system, orbital mechanics, Earth-Sun-Moon interactions); excludes detailed sub-national geography, urban systems, and exoplanetary science; country selection = top 30 GDP + regional representation

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
equivalent_to|equivalent_to|exact match
extends|extends|exact match
