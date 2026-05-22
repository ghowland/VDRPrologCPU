# CLIMATE MECHANICS — LOCAL, REGIONAL & GLOBAL SYSTEMS — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: concepts → energy_budget → atmospheric_structure → circulation → water_cycle → ocean → regional_climates → local_effects → feedback_mechanisms → variability → paleoclimate → biome_climate → measurement → failure_modes → distinctions → relationships → decode_legend

# concepts(id|name|definition|category)
CO1|Climate|statistical description of weather variables (temperature, precipitation, humidity, wind, pressure) averaged over 30+ years for a location; distinguished from weather (short-term state)|foundation
CO2|Weather|instantaneous or short-term (hours to days) state of atmosphere at a location; chaotic, unpredictable beyond ~10 days|foundation
CO3|Insolation|incoming solar radiation reaching Earth's surface or atmosphere; ~1361 W/m² at top of atmosphere (solar constant); varies with latitude, season, time of day, cloud cover|energy
CO4|Albedo|fraction of incoming radiation reflected by a surface; 0 = perfect absorber (black body); 1 = perfect reflector; Earth average ~0.30; ice/snow 0.60-0.90; ocean 0.06; forest 0.10-0.20|energy
CO5|Blackbody Radiation|all objects emit electromagnetic radiation proportional to temperature⁴ (Stefan-Boltzmann law: P = σT⁴); peak wavelength inversely proportional to temperature (Wien's law)|energy
CO6|Greenhouse Effect|atmosphere absorbs and re-emits longwave (infrared) radiation from Earth's surface; warms surface ~33°C above no-atmosphere temperature (~255K → ~288K); without it, Earth would be frozen|energy
CO7|Radiative Forcing|change in net energy flux at tropopause from a perturbation (gas concentration, albedo change, solar variation); positive = warming; negative = cooling; measured in W/m²|energy
CO8|Lapse Rate|rate of temperature decrease with altitude; environmental lapse rate (ELR): observed average ~6.5°C/km; dry adiabatic lapse rate (DALR): ~9.8°C/km; moist (saturated) adiabatic lapse rate (MALR): ~5-6°C/km (varies with moisture)|atmosphere
CO9|Adiabatic Process|temperature change in air parcel from compression (descent = warming) or expansion (ascent = cooling) without heat exchange with surroundings; drives cloud formation and precipitation|atmosphere
CO10|Coriolis Effect|apparent deflection of moving objects (including air and water) caused by Earth's rotation; right in Northern Hemisphere, left in Southern; zero at equator, maximum at poles; f = 2Ω sin(φ)|circulation
CO11|Pressure Gradient Force|force from high pressure toward low pressure; drives all wind; magnitude proportional to pressure difference over distance; perpendicular to isobars|circulation
CO12|Geostrophic Balance|equilibrium between pressure gradient force and Coriolis force; wind flows parallel to isobars (not from high to low); upper atmosphere approximation; surface friction disrupts|circulation
CO13|Convergence|air masses moving toward each other; horizontal inflow forces vertical motion (upward); associated with low pressure, cloud formation, precipitation|circulation
CO14|Divergence|air masses moving apart; horizontal outflow pulls air downward from above (subsidence); associated with high pressure, clear skies, suppressed precipitation|circulation
CO15|Advection|horizontal transport of heat, moisture, or other atmospheric properties by wind; warm advection: warm air replacing cold; cold advection: cold replacing warm|transport
CO16|Convection|vertical transport of heat and moisture by buoyant rising of warm air; dominant in tropics; drives thunderstorms, cumulus clouds, tropical circulation|transport
CO17|Specific Humidity|mass of water vapor per mass of air (g/kg); absolute measure; doesn't change with temperature or pressure unless water added/removed|moisture
CO18|Relative Humidity|ratio of actual water vapor to maximum possible (saturation) at that temperature; 100% = saturated; decreases when air warms (can hold more), increases when air cools; dew point = temperature at which RH = 100%|moisture
CO19|Latent Heat|energy absorbed during phase change (evaporation, melting, sublimation) and released during reverse (condensation, freezing, deposition); water: vaporization 2,260 kJ/kg; fusion 334 kJ/kg|energy
CO20|Sensible Heat|energy transfer changing temperature (measurable by thermometer); differs from latent heat (energy stored in phase, not temperature); Bowen ratio = sensible/latent heat flux|energy
CO21|Continentality|degree to which climate is influenced by distance from ocean; continental interiors: large temperature range (hot summer, cold winter), low humidity, less precipitation; maritime: moderate temperature range, higher humidity|modifier
CO22|Orographic Effect|terrain-forced lifting of air; windward side: forced ascent → cooling → condensation → precipitation (wet); leeward side: descent → warming → drying (rain shadow)|modifier
CO23|Maritime Influence|ocean moderates adjacent land climate; high thermal inertia of water; onshore winds bring moisture and moderate temperatures; coastal fog from cold currents; marine layer|modifier
CO24|Thermal Inertia|resistance to temperature change; water has ~4× the specific heat capacity of soil/rock and mixes through greater depth; oceans lag seasons by ~1-2 months; land responds quickly|property
CO25|Phenology|timing of seasonal biological events (bud burst, flowering, migration, leaf fall) driven by temperature and photoperiod; integrates climate information; sensitive indicator of climate trends|biological

# energy_budget(id|name|definition|magnitude|role)
EB1|Solar Input|shortwave radiation from sun intercepted by Earth; ~1361 W/m² at top of atmosphere; distributed over sphere = ~340 W/m² average|~340 W/m² average incoming|sole external energy source driving climate system; 99.97% of surface energy budget
EB2|Atmospheric Absorption (Shortwave)|atmosphere absorbs ~23% of incoming solar radiation; ozone absorbs UV; water vapor and aerosols absorb visible and near-IR|~78 W/m² absorbed by atmosphere|heats atmosphere directly; ozone absorption creates stratospheric temperature inversion; aerosol absorption depends on composition (black carbon absorbs, sulfate scatters)
EB3|Surface Absorption|surface absorbs ~48% of incoming solar radiation; ocean, land, vegetation absorb shortwave → warm → emit longwave|~163 W/m² absorbed by surface|primary heating of surface; dark surfaces absorb more (low albedo); converted to longwave, latent heat, sensible heat; drives surface energy balance
EB4|Surface Reflection|surface reflects ~7% of incoming radiation; albedo-dependent; ice, snow, desert sand reflect most; ocean, forest reflect least|~23 W/m² reflected by surface|high-albedo surfaces reduce local heating; snow/ice cover significantly affects regional energy balance; albedo changes create powerful feedback (ice-albedo feedback)
EB5|Atmospheric Reflection|atmosphere reflects ~23% of incoming radiation; clouds dominant reflector (~20%); aerosols contribute|~77 W/m² reflected by atmosphere|clouds are primary atmospheric reflector; thick low clouds have highest albedo; cloud cover changes alter planetary energy budget significantly; aerosol-cloud interactions modify cloud reflectivity
EB6|Longwave Emission (Surface)|surface emits infrared radiation according to Stefan-Boltzmann law; ~396 W/m² upward; exceeds incoming solar because greenhouse effect recycles energy|~396 W/m² emitted upward from surface|majority absorbed by greenhouse gases and re-emitted (up and down); atmospheric window: 8-12 μm transmits directly to space (except where blocked); surface emission increases with temperature (T⁴ relationship)
EB7|Atmospheric Counter-Radiation|atmosphere absorbs surface longwave and re-emits in all directions; downward component (~340 W/m²) warms surface further; the greenhouse mechanism|~340 W/m² emitted downward to surface|this return radiation is why surface temperature exceeds no-atmosphere prediction; increases with greenhouse gas concentration; clear night vs cloudy night temperature difference demonstrates this directly
EB8|Outgoing Longwave Radiation (OLR)|infrared radiation escaping to space from upper atmosphere and surface (through atmospheric window); must balance incoming solar for stable climate|~239 W/m² to space (equals absorbed solar at equilibrium)|measured by satellites; departure from balance = energy accumulation or deficit; effective emission temperature ~255K (-18°C) = weighted average of emitting altitudes; tropical OLR lower (thick atmosphere, high clouds emit from cold tops)
EB9|Latent Heat Flux|energy transferred from surface to atmosphere via evaporation; water evaporates from surface absorbing 2,260 kJ/kg; released when water condenses in atmosphere (cloud formation)|~82 W/m² (largest surface-to-atmosphere energy transfer)|dominant energy transfer mechanism from surface to atmosphere (exceeds sensible and radiative); drives atmospheric circulation; links energy and water cycles; tropical oceans: largest source
EB10|Sensible Heat Flux|energy transferred from surface to atmosphere by conduction and convection; direct heating of air in contact with warm surface|~21 W/m²|smaller than latent flux globally but dominant in arid regions (little evaporation); creates thermal convection; surface heating drives boundary layer mixing; desert: high sensible, low latent; tropical ocean: high latent, low sensible
EB11|Greenhouse Gases|atmospheric gases absorbing and re-emitting longwave radiation; H₂O (strongest, 60% of effect), CO₂ (26%), CH₄, N₂O, O₃, CFCs, SF₆|radiative effect expressed as forcing (W/m²)|each gas has specific absorption bands (spectral fingerprint); H₂O absorption broadest but condensable (feedback, not forcing in traditional sense); CO₂ well-mixed and long-lived; CH₄ stronger per molecule but shorter atmospheric lifetime (~12 years); gas concentrations measured in ppm, ppb

# atmospheric_structure(id|name|definition|altitude|temperature_profile|significance)
AS1|Troposphere|lowest atmospheric layer; contains ~80% of mass and virtually all weather; well-mixed by convection|surface to ~8 km (poles) / ~16 km (tropics)|decreases with altitude (lapse rate ~6.5°C/km); heated from below by surface|all weather occurs here; convective mixing distributes heat and moisture; tropopause (upper boundary) = temperature minimum; jet streams near tropopause; deeper in tropics (more convective energy)
AS2|Stratosphere|layer above troposphere; temperature increases with altitude (inversion); stable (no convection); contains ozone layer|~10-50 km|increases with altitude (ozone absorbs UV → heating); inversion suppresses vertical mixing|ozone layer (peak ~25 km) absorbs UV-B and UV-C; very stable (injected aerosols persist months to years: volcanic eruptions); aircraft fly in lower stratosphere; stratospheric intrusions bring ozone to surface
AS3|Mesosphere|layer above stratosphere; temperature decreases again; coldest point in atmosphere at mesopause (~-90°C)|~50-85 km|decreases with altitude (no ozone heating; radiative cooling)|meteors burn up here (shooting stars); noctilucent clouds at mesopause (ice crystals); limited direct climate relevance; temperature minimum in entire atmosphere
AS4|Thermosphere|layer above mesosphere; temperature increases dramatically (to 1000°C+) from absorption of extreme UV and X-ray radiation by atomic oxygen and nitrogen; very thin|~85-600 km|increases sharply with altitude; but so few molecules that it doesn't feel hot|aurora occurs here; satellite orbits; ionosphere (radio reflection) overlaps thermosphere and mesosphere; space station orbit (~400 km); negligible climate influence but upper boundary condition
AS5|Tropopause|boundary between troposphere and stratosphere; temperature minimum; acts as lid on convection; height varies with latitude and season|~8 km poles, ~16 km tropics; higher in summer|temperature minimum (~-55°C to -80°C)|convection generally cannot penetrate (stable stratosphere above); overshooting thunderstorms inject moisture and aerosols into stratosphere; jet stream located near; tropical tropopause extremely cold (freeze-drying air entering stratosphere)
AS6|Boundary Layer|lowest ~1-2 km of troposphere directly influenced by surface; turbulent mixing; diurnal cycle of heating and cooling; friction slows wind|surface to ~100 m (night, stable) to ~2000 m (day, convective)|follows surface temperature cycle; well-mixed during day (convective boundary layer); stable at night (nocturnal inversion)|where humans live; pollutant concentration highest; fog, frost, surface inversions; urban heat island most pronounced; wind profile logarithmic (friction layer); depth varies with surface heating, wind speed, roughness
AS7|Temperature Inversion|temperature increases with altitude (reversing normal lapse rate); extremely stable (warm air above cold = no convection); traps pollution, fog, low clouds|surface (radiation inversion at night) or elevated (subsidence inversion: descending air in high-pressure systems)|temperature increases with altitude in inversion layer|traps pollutants below (smog events: LA, Beijing, Delhi); stratus clouds form below inversions; persistent inversions define subtropical climate (Mediterranean); marine layer capped by inversion; valley inversions in winter (cold air pooling)

# circulation(id|name|definition|mechanism|effects)
CR1|Hadley Cell|tropical circulation cell; air rises at Intertropical Convergence Zone (ITCZ), flows poleward aloft, descends at ~30° latitude (subtropical highs), returns equatorward at surface (trade winds)|thermally direct: warm air rises (convection at ITCZ), radiatively cools aloft, descends at subtropics; Coriolis deflects surface flow creating trade winds (NE in NH, SE in SH)|most powerful circulation cell; drives tropical weather; ascending branch = ITCZ = tropical rain belt; descending branch = subtropical highs = world's great deserts (Sahara, Arabian, Sonoran, Australian); trade winds reliable for sailing; extends poleward with warming
CR2|Ferrel Cell|mid-latitude circulation cell (~30-60°); thermally indirect (driven by Hadley and Polar cells, not by direct thermal convection); surface westerlies|surface: poleward flow deflected by Coriolis → westerlies; aloft: equatorward flow; mechanically driven by eddies (weather systems); weaker and less consistent than Hadley|drives mid-latitude weather; westerlies carry weather systems west to east; most variable climate zone; interaction between polar and subtropical air masses creates fronts and storms; jet stream at poleward boundary
CR3|Polar Cell|high-latitude circulation cell (~60-90°); thermally direct; cold dense air descends at poles, flows equatorward at surface, rises at ~60° (polar front)|radiative cooling at poles → dense air descends → surface flow equatorward → Coriolis deflects → polar easterlies; convergence with westerlies at ~60° = polar front|polar easterlies; polar front = major storm generation zone; arctic/antarctic air masses; polar vortex (upper-level) confines cold air; weakened polar vortex → cold air outbreaks to lower latitudes
CR4|Intertropical Convergence Zone (ITCZ)|zone where trade winds from both hemispheres converge; intense convection; tropical rain belt; migrates seasonally following solar maximum|NE trades meet SE trades → convergence → forced ascent → convection → heavy precipitation; follows thermal equator (not geographic); migrates ~5°N (Jan) to ~15°N (Jul) over land (smaller range over ocean)|determines wet/dry seasons in tropics; monsoons partially driven by ITCZ migration over land; located near equator over ocean but shifts dramatically over continents (especially Asia, Africa); doldrums (light winds within ITCZ)
CR5|Subtropical High Pressure Belt|persistent high-pressure zones at ~30° latitude; descending branch of Hadley Cell; subsidence → adiabatic warming → clear skies → deserts|descending air warms adiabatically → increases temperature → reduces relative humidity → suppresses convection → clear skies; divergence at surface sends air equatorward (trades) and poleward (westerlies)|world's great deserts located under subtropical highs (Sahara, Arabian, Kalahari, Australian, Sonoran, Atacama); Mediterranean climate on poleward edge (summer under subtropical high = dry; winter under westerlies = wet); subsidence inversion caps marine layer
CR6|Jet Stream|narrow band of strong upper-level winds (~10 km altitude) at boundary between circulation cells; westerly; wavy (Rossby waves)|sharp temperature gradient between air masses creates strong pressure gradient aloft → geostrophic wind concentration → jet; polar jet at ~60° latitude; subtropical jet at ~30°|steers weather systems; divides cold and warm air masses; jet position determines mid-latitude weather (equatorward = cold spell; poleward = warm spell); airplane routing; Rossby wave amplitude determines weather pattern persistence (blocking)
CR7|Rossby Waves|large-scale meanders (wavelength ~2000-6000 km) in jet stream and upper-level westerlies; 4-6 waves typically circle hemisphere|conservation of absolute vorticity: air deflected by terrain or temperature gradients oscillates about latitude; wave amplitude and phase determine weather pattern|ridges (poleward deflection): warm, dry surface weather; troughs (equatorward): cold, stormy; persistent (stationary) Rossby wave patterns → extended heat waves or cold spells (blocking); omega block (Ω shape): persistent ridge flanked by troughs
CR8|Monsoon|seasonal reversal of prevailing wind direction driven by differential heating of land and ocean; summer: onshore (wet); winter: offshore (dry)|summer: land heats faster than ocean → low pressure over land → moist oceanic air flows onshore → orographic and convective precipitation; winter: land cools faster → high pressure over land → dry continental air flows offshore|Asian monsoon strongest (Himalayan heating + Indian Ocean moisture); West African monsoon; North American monsoon; Australian monsoon; monsoon onset/withdrawal timing critical for agriculture; 60% of world population depends on monsoon rain
CR9|Land-Sea Breeze|diurnal (daily) wind reversal at coastlines; driven by differential heating of land and ocean|day: land heats faster → low pressure → sea breeze (ocean → land); night: land cools faster → high pressure → land breeze (land → ocean); penetration: sea breeze front ~20-50 km inland|moderates coastal temperature; sea breeze front can trigger afternoon thunderstorms; sea breeze convergence with prevailing wind enhances precipitation (Florida); nocturnal land breeze is weaker; effect disappears in strong synoptic (large-scale) wind
CR10|Mountain-Valley Breeze|diurnal wind along mountain slopes; driven by differential heating of slopes vs valley floor|day: slopes heat faster than valley air at same altitude → anabatic (upslope) wind; night: slopes cool faster → katabatic (downslope) wind; drainage flow pools cold air in valleys|upslope winds carry moisture → afternoon mountain thunderstorms (Rocky Mountains, Alps); nighttime drainage fills valleys with cold air → temperature inversions → frost pockets; wildfire behavior influenced by slope winds; fog in valleys from cold air pooling
CR11|Katabatic Wind|gravity-driven downslope flow of cold dense air; most extreme off continental ice sheets (Antarctica, Greenland) but occurs on any elevated cooled surface|cold air is dense → flows downhill under gravity; ice sheets cool overlying air continuously → persistent powerful katabatic; can exceed 100 km/h (Antarctica); drainage winds nightly from mountain valleys|Antarctic katabatic: sustained high winds at coast; contributes to sea ice formation (pushes sea ice away from coast → polynyas → new ice formation); contributes to downwelling in Southern Ocean; any elevated cold surface generates katabatic (nocturnal valley drainage is mild form)
CR12|Foehn / Chinook Wind|warm dry wind on leeward side of mountains; air forced over mountains loses moisture on windward (MALR ascent), descends dry on leeward (DALR descent)|windward: air rises at MALR (~5°C/km, slower cooling because condensation releases latent heat) → precipitation; leeward: air descends at DALR (~9.8°C/km, faster warming because no moisture to absorb heat) → arrives warmer and drier than it started|dramatic temperature increase on leeward side (chinook in Rockies: +20°C in hours); rapid snowmelt; wildfire risk; alpine foehn; Santa Ana (California); berg wind (South Africa); creates rain shadow deserts
CR13|Walker Circulation|east-west atmospheric circulation over tropical Pacific; rising air over warm western Pacific (Indonesia), sinking over cool eastern Pacific (Peru coast); linked to ENSO|warm surface water accumulates in western Pacific → convection → rising air; cool upwelling in eastern Pacific → stable air → subsidence; upper-level flow from west to east completes cell|normal state: strong trades → warm water west, cool east; El Niño: weakened/reversed → warm water spreads east → changes global precipitation patterns; La Niña: enhanced → cooler east, warmer west; ENSO modifies this cell

# water_cycle(id|name|definition|mechanism|climate_role)
WC1|Evaporation|liquid water → water vapor; energy absorbed (latent heat of vaporization: 2,260 kJ/kg); occurs at any temperature below boiling from any wet surface|rate depends on: temperature, humidity, wind speed, surface area; ocean provides ~86% of atmospheric water vapor; net evaporation exceeds precipitation over ocean (excess returns via runoff)|primary cooling mechanism for surface; primary energy source for atmospheric circulation (latent heat released when water condenses drives storms); links energy budget and water cycle inseparably
WC2|Transpiration|plant water release from leaves via stomata; effectively evaporation through biology; accounts for ~10% of atmospheric moisture over land|plants pull water from soil through roots → xylem → leaves → stomata release vapor; rate modulated by stomatal opening (CO₂, light, humidity, temperature); forests = major moisture source|Amazon rainforest recycles ~50% of its own rainfall via transpiration; deforestation reduces regional moisture recycling → reduced precipitation → drying feedback; transpiration cools land surface (evaporative cooling)
WC3|Condensation|water vapor → liquid water; energy released (latent heat: 2,260 kJ/kg); forms clouds, fog, dew; requires cooling to dew point and condensation nuclei|air cools (adiabatic expansion from lifting, radiative cooling, advection over cold surface) → reaches saturation → water vapor condenses on aerosol particles (CCN: cloud condensation nuclei); without CCN: supersaturation required (~300% RH); with CCN: condensation at ~100-101% RH|latent heat release from condensation warms air → buoyancy → more rising → more condensation → positive feedback (drives thunderstorms, hurricanes); cloud formation modifies albedo and greenhouse effect
WC4|Precipitation|water falling from atmosphere to surface; rain, snow, sleet, hail; requires cloud droplets to grow large enough to fall (collision-coalescence or ice crystal process)|warm rain (tropical): collision-coalescence of cloud droplets; cold rain (mid-latitude): Bergeron process (ice crystals grow at expense of supercooled water droplets → snowflakes → melt falling through warm air); hail: updraft-supported ice cycling in cumulonimbus|redistributes water from ocean to land; drives hydrology; amount and timing define climate type; orographic: forced lifting over terrain; convective: thermal instability; frontal: warm/cold front lifting; convergence: ITCZ and monsoon
WC5|Runoff|water flowing over land surface to streams, rivers, and eventually ocean; completes the ocean → atmosphere → land → ocean cycle|precipitation exceeding infiltration capacity flows downhill; watershed (catchment) defines drainage; river discharge integrates precipitation over basin area; seasonal patterns reflect climate|returns freshwater to ocean (balances ocean evaporation excess); carries sediment and nutrients; flooding when runoff exceeds channel capacity; groundwater recharge from infiltration of precipitation
WC6|Cloud Formation|visible mass of water droplets or ice crystals suspended in atmosphere; formed when air cools to dew point in presence of CCN|four mechanisms: orographic lifting (forced over terrain); convective lifting (thermal buoyancy); frontal lifting (warm air rides over cold or cold undercuts warm); convergence lifting (air masses meet → forced upward)|clouds simultaneously: cool surface (reflect shortwave — high albedo) and warm surface (absorb and re-emit longwave — greenhouse); net effect depends on cloud type: low thick clouds net cooling; high thin clouds (cirrus) net warming; cloud feedback is largest uncertainty in climate sensitivity
WC7|Atmospheric River|narrow corridor of concentrated water vapor transport (250-400 km wide, 1000+ km long); carries moisture equivalent to 7-15 Mississippi River flows|forms along warm conveyor belt of extratropical cyclone; tropical moisture source; follows jet stream; Pineapple Express (Hawaii → US West Coast) is well-known example|produces extreme precipitation (50-75% of annual precipitation in some regions from 2-5 events); critical water supply source (California, Norway, Chile); can cause catastrophic flooding; enhanced by warm ocean temperatures
WC8|Orographic Precipitation|precipitation caused by terrain-forced lifting; windward side wet, leeward side dry (rain shadow)|air forced up mountain → cools at MALR → condenses → precipitates on windward; descends leeward at DALR → warms → dries; rain shadow: dramatic precipitation gradient across mountain range|Cascades: Seattle (1000mm) vs eastern Washington (200mm); Himalayas: Cherrapunji (11,000+ mm) vs Tibetan Plateau (<300mm); Andes: Chilean coast wet, Atacama dry; controls vegetation, agriculture, settlement patterns

# ocean(id|name|definition|mechanism|climate_role)
OC1|Ocean Heat Storage|ocean absorbs and stores vast amount of energy; top 3m of ocean has same heat capacity as entire atmosphere; ocean has absorbed ~90% of excess heat from radiative imbalance|high specific heat capacity (4,186 J/kg·K vs ~1,000 for air); mixed layer (top ~50-200m) exchanges heat with atmosphere; deep ocean (below thermocline) stores heat for centuries to millennia|buffers atmospheric temperature change; delays response to radiative forcing by decades; maritime climates (stable temperature year-round); seasonal lag: warmest month 1-2 months after maximum insolation due to ocean thermal inertia
OC2|Thermohaline Circulation (THC)|global-scale deep ocean circulation driven by density differences from temperature and salinity; Atlantic Meridional Overturning Circulation (AMOC) is key component|cold salty water (dense) sinks in North Atlantic and around Antarctica → flows along ocean floor → gradually mixes and upwells → returns at surface; ~1000 year full cycle; rate ~15-20 Sv (1 Sv = 10⁶ m³/s)|transports enormous heat poleward (~1.3 PW in Atlantic); Gulf Stream/North Atlantic Drift keeps NW Europe 5-10°C warmer than same latitude elsewhere; potential weakening from freshwater input (ice sheet melt) → cooling of North Atlantic; Heinrich events (paleoclimate) show abrupt THC changes
OC3|Ocean Surface Currents|wind-driven horizontal flow in upper ~100-200m; deflected by Coriolis to form gyres; transport heat latitudinally|wind stress on surface → Ekman transport (net flow 90° to right of wind in NH, left in SH) → accumulates water in gyre center (western intensification: narrow fast western boundary currents); trade winds drive equatorial currents westward|Gulf Stream (warm, NW Atlantic); Kuroshio (warm, NW Pacific); Humboldt (cold, SE Pacific); Benguela (cold, SE Atlantic); California (cold, NE Pacific); warm currents warm adjacent land; cold currents cool and stabilize adjacent land (fog, low rainfall, marine layer)
OC4|Upwelling|rising of cold, nutrient-rich deep water to surface; driven by wind or divergence of surface currents|coastal upwelling: equatorward wind along west coast → Ekman transport moves surface water offshore → deep water rises to replace; equatorial upwelling: trade winds diverge surface water from equator → upwelling along equator|biologically productive (nutrients from deep → phytoplankton bloom → fisheries: Peru, California, Canary, Benguela); cools sea surface temperature; stabilizes atmosphere above (cool surface → subsidence → fog, stratus, no thunderstorms); suppressed during El Niño → fishery collapse
OC5|ENSO (El Niño-Southern Oscillation)|coupled ocean-atmosphere oscillation in tropical Pacific; alternates between El Niño (warm eastern Pacific), La Niña (cool eastern Pacific), and neutral; 2-7 year cycle|El Niño: weakened trade winds → warm water spreads east → suppresses eastern Pacific upwelling → Walker circulation weakens/reverses; La Niña: enhanced trades → cooler east → stronger Walker; measured by SOI (pressure), ONI (SST)|strongest year-to-year climate variability source globally; El Niño: wet South America west coast, dry Indonesia/Australia, mild North American winter; La Niña: drought South America, floods Indonesia/Australia, cold/snowy North America; teleconnections reach worldwide
OC6|Sea Surface Temperature (SST)|temperature of ocean surface layer (~1m); measured by ships, buoys, satellites; global average ~17°C; varies from -2°C (polar) to 30°C+ (tropical)|determined by: solar heating, evaporative cooling, ocean currents, upwelling, mixing; tropical warm pool (Indo-Pacific, >28°C) drives atmospheric convection; SST patterns determine atmospheric circulation and precipitation|controls evaporation rate (warmer = more evaporation = more atmospheric moisture); determines tropical cyclone development (>26.5°C threshold); SST gradients drive circulation (Walker, monsoon); SST anomalies used to define ENSO (ONI index); ocean heat content indicator
OC7|Thermocline|layer of rapid temperature decrease with depth; separates warm mixed layer (~50-200m) from cold deep ocean (~2-4°C); strongest in tropics, absent at poles|solar heating warms surface; wind mixing distributes heat through mixed layer; below mixed layer, temperature drops rapidly (thermocline) to near-freezing deep water; seasonal thermocline forms in summer (shallow) and erodes in winter (deep mixing)|barrier to vertical mixing; traps heat in surface layer; depth affects upwelling nutrient supply; El Niño: thermocline deepens in eastern Pacific (suppresses upwelling); La Niña: thermocline shoals (enhances upwelling); polar regions: no permanent thermocline (dense surface water sinks → deep water formation)
OC8|Ocean Acidification|decreasing ocean pH from absorption of atmospheric CO₂; CO₂ + H₂O → H₂CO₃ → H⁺ + HCO₃⁻; ocean pH decreased from ~8.2 to ~8.1 since preindustrial (30% increase in H⁺)|ocean absorbs ~25-30% of anthropogenic CO₂; dissolution produces carbonic acid; shifts carbonate equilibrium; reduces carbonate ion (CO₃²⁻) availability|affects calcifying organisms (coral, shellfish, foraminifera — less CO₃²⁻ for shell building); cold water absorbs more CO₂ (polar regions more affected); rate of change unprecedented in geological record; independent of temperature effects

# regional_climates(id|name|location|mechanism|characteristics|examples)
RC1|Equatorial (Af)|0-10° latitude; ITCZ overhead year-round or most of year|persistent convergence → year-round convection → daily thunderstorms; no seasonal temperature variation (isothermal)|temperature: 25-28°C year-round; precipitation: 2000-4000+ mm/year; no dry season; dense tropical forest; highest biodiversity|Singapore, Manaus, Douala, Kisangani
RC2|Tropical Monsoon (Am)|5-25° latitude; areas influenced by monsoon circulation|seasonal ITCZ migration + continental heating → seasonal wind reversal; onshore (wet summer) vs offshore (dry winter)|intense wet season (may exceed 3000mm); short dry season (1-3 months); warm year-round; cyclone risk|Mumbai, Yangon, Darwin, Freetown
RC3|Tropical Savanna (Aw/As)|5-20° latitude; between equatorial wet and subtropical dry|ITCZ overhead in summer (wet season); subtropical high influence in winter (dry season); duration of wet/dry determined by latitude (closer to equator = longer wet)|distinct wet and dry seasons; warm year-round; grassland with scattered trees; fire-maintained ecology; 500-1500mm precipitation|Nairobi, Brasília, Havana, Bamako
RC4|Hot Desert (BWh)|15-30° latitude (subtropical) and continental interiors|subsidence from descending branch of Hadley Cell (subtropical); rain shadow (continental); cold current offshore (coastal desert)|<250mm precipitation/year; extreme diurnal temperature range (40°C day, 5°C night); clear skies; intense solar radiation; sparse vegetation|Sahara, Arabian, Sonoran, Atacama (coastal cold current), Australian interior, Namib
RC5|Cold Desert (BWk)|continental interiors at mid-latitudes; rain shadow locations|distance from moisture source + mountain rain shadow; low humidity; continental extremes|<250mm precipitation; hot summers, very cold winters; large annual temperature range; sparse shrub vegetation|Gobi, Great Basin (USA), Patagonian steppe, Turkestan
RC6|Semi-Arid / Steppe (BS)|transition zones surrounding deserts; 15-35° latitude and continental interiors|marginal Hadley Cell descent; partial rain shadow; sufficient moisture for grassland but not forest|250-500mm precipitation; grassland; seasonal drought; agriculture marginal without irrigation; highly variable rainfall year-to-year|Sahel, Great Plains, Australian outback margins, Central Asian steppe, Argentinian pampas
RC7|Mediterranean (Csa/Csb)|30-45° latitude on western margins of continents|summer: subtropical high migrates poleward → dry; winter: westerlies and frontal systems bring precipitation; seasonal alternation between two circulation regimes|hot dry summers; mild wet winters; 400-900mm precipitation mostly Oct-Apr; fire-adapted vegetation (chaparral, maquis, fynbos)|Los Angeles, Barcelona, Rome, Cape Town, Perth, Santiago (Chile), Beirut
RC8|Humid Subtropical (Cfa)|25-40° latitude on eastern margins of continents|warm moist air from subtropical ocean (western edge of subtropical high → onshore flow); summer: convective storms; winter: frontal precipitation; no dry season|hot humid summers; mild winters; 1000-1500mm year-round precipitation; thunderstorms common; occasional tropical cyclones|Atlanta, Shanghai, Buenos Aires, Sydney, Tokyo (partially)
RC9|Marine West Coast (Cfb/Cfc)|40-60° latitude on western margins of continents|year-round westerlies bring moist oceanic air onshore; persistent mild temperatures from ocean thermal influence; frequent frontal systems|mild winters, cool summers; narrow annual temperature range; frequent cloud and rain (750-2500mm); lush vegetation; fog|London, Seattle, Melbourne, Bergen, Valdivia, Christchurch
RC10|Humid Continental (Dfa/Dfb)|35-55° latitude in continental interiors and eastern margins (Northern Hemisphere only — Southern Hemisphere lacks sufficient land mass)|continental position: no ocean moderation; polar and tropical air masses alternate; frontal battles; strong seasonal contrast|hot summers (>22°C warmest month for Dfa), cold winters (<-3°C coldest month); large annual range (30-60°C); 500-1000mm; snow cover several months; thunderstorms summer, blizzards winter|Chicago, Moscow, Sapporo, Seoul, Harbin, Toronto
RC11|Subarctic (Dfc/Dfd)|50-70° latitude; vast boreal (taiga) zone|extreme continental: very short summers, long harsh winters; limited solar angle; permafrost underlies much of region; low evaporation → boggy despite low precipitation|very cold winters (-20 to -50°C); brief warm summers (10-20°C); largest annual temperature range of any climate (Yakutsk: -40°C to +20°C); 300-600mm; coniferous forest (taiga); permafrost in colder areas|Fairbanks, Yakutsk, Yellowknife, Norilsk, Murmansk
RC12|Tundra (ET)|poleward of treeline; 60-75° latitude (varies with continental position)|insufficient summer warmth for tree growth (warmest month <10°C); permafrost; extreme winter darkness and summer daylight; high wind exposure|short cool summers (0-10°C); long extremely cold winters; <250mm precipitation (but low evaporation → wet surface); permafrost; moss, lichen, low shrubs; freeze-thaw cycles dominate landscape|Barrow (Utqiaġvik), Svalbard, Nuuk, northern Siberian coast, Antarctic Peninsula fringe
RC13|Ice Cap (EF)|polar ice sheets and high-altitude glaciers; permanent ice and snow cover|radiative cooling exceeds any heating; persistent high-pressure katabatic regime; extremely high albedo (~0.80-0.90); moisture-starved (cold air holds very little water)|permanent ice and snow; temperatures rarely above 0°C; extremely low precipitation (technically desert: Antarctica interior <50mm/year water equivalent); katabatic winds; world's coldest temperatures|Antarctica interior (-89.2°C record), Greenland ice sheet summit
RC14|Highland / Alpine|mountain regions at any latitude; altitude creates temperature and precipitation gradients mimicking latitudinal climate zones|temperature decreases ~6.5°C per 1000m altitude; orographic precipitation on windward; rain shadow leeward; aspect effects (sun-facing vs shade-facing slopes differ dramatically)|climate zones compressed vertically (tropical base → alpine/ice at summit); strong diurnal variation; thin atmosphere → intense solar radiation; valley-mountain wind systems; altitude sickness above ~2500m|Andes, Himalayas, Alps, East African highlands, Rocky Mountains, Ethiopian highlands

# local_effects(id|name|definition|mechanism|scale)
LE1|Urban Heat Island (UHI)|city temperatures 1-5°C (up to 12°C at night) warmer than surrounding rural areas|dark surfaces absorb solar radiation (asphalt, buildings); reduced evapotranspiration (less vegetation); waste heat from vehicles, buildings, industry; urban canyon geometry traps radiation; reduced wind|city-scale (km); strongest at night (surface reradiates stored heat); strongest in calm, clear conditions; magnitude proportional to population and density; mitigation: green roofs, tree canopy, reflective surfaces
LE2|Cold Air Pooling / Frost Pocket|cold dense air drains downhill at night and accumulates in valleys, basins, and depressions; creates temperature inversions with coldest air at lowest elevation|nocturnal radiative cooling → katabatic drainage → pooling in topographic low; clear calm nights strongest; trapped by terrain or forest edges creating air dams|valley to basin scale (100m-10km); agriculture: frost-sensitive crops planted on slopes not valley floors; vineyards on slopes (not valley bottom); temperature difference 5-15°C between valley floor and mid-slope
LE3|Lake Effect (Snow/Rain)|precipitation generated when cold dry air mass passes over relatively warm open water; absorbs moisture and heat → convective instability → heavy precipitation on downwind shore|cold air over warm lake → heat and moisture transfer from lake → convective clouds → precipitation concentrated on downwind shore; requires >13°C air-water temperature difference; open water (freezes → effect stops)|regional (10-100 km downwind); Great Lakes: Buffalo, Cleveland, Syracuse receive heavy lake-effect snow; also: Great Salt Lake, Lake Baikal, Black Sea, Sea of Japan; narrow intense snow bands
LE4|Coastal Fog|fog formation along coastlines with cold ocean currents; warm moist air moves over cold water → cools below dew point → advection fog; or radiative fog in marine layer below inversion|advection fog: warm air over cold current (California, Atacama, Namib, Canary); upwelling fog: cold upwelled water chills marine layer; radiation fog: nocturnal cooling in stable marine layer trapped below subsidence inversion|coastal strip (0-50 km inland); San Francisco fog; Atacama: only moisture for some ecosystems (fog harvesters); Namib: fog-dependent beetle species; dissipates by afternoon as surface heats and mixes through inversion
LE5|Rain Shadow|dry zone leeward of mountains; orographic precipitation strips moisture from air on windward side; descending air warms and dries on leeward|air forced over mountains → MALR ascent → condensation and precipitation (windward wet); descends leeward at DALR (faster warming) → arrives warm and dry; most extreme where mountains are high, perpendicular to prevailing wind, and moisture source is upwind|regional (10-100 km); dramatic: Cascades (2500mm windward, 250mm leeward in 50 km); Himalayas; Andes; creates desert in lee (Great Basin, Patagonia, Gobi partially); defines vegetation, agriculture, settlement patterns
LE6|Aspect Effect|slope orientation relative to sun determines solar heating; south-facing slopes (NH) receive more direct sunlight than north-facing; reversed in SH|south-facing (NH): sun-heated, warmer, drier, different vegetation, earlier snowmelt; north-facing: shaded, cooler, moister, later snowmelt; east-facing: morning sun; west-facing: afternoon sun (hottest)|slope scale (100m-1km); in mountains: opposite sides of same valley can be different climate zones; vineyard orientation; building siting; treeline altitude differs by aspect; permafrost distribution depends on aspect at margins
LE7|Urban Canyon Effect|street-level microclimate created by tall buildings; reduced sky view factor; multiple reflections of radiation; channeled wind|buildings block direct sunlight (shade streets); reradiate longwave; trap heat; channel wind (Venturi effect through gaps); reduce nocturnal cooling (sky view factor reduced → less radiative loss)|building to street scale (10-100m); contributes to UHI; wind tunnel effects; pedestrian comfort; building energy demand; canyon orientation relative to sun path and prevailing wind determines street-level climate
LE8|Albedo Modification|local changes in surface reflectivity alter energy absorption; snow cover, land use change, urbanization, agriculture|forest → cropland: albedo increases (0.10-0.15 → 0.20-0.25) → local cooling (but reduced evapotranspiration → competing warming); snow cover → exposed soil: albedo decreases (0.80 → 0.20) → rapid warming → more melting (positive feedback)|local to regional; Arctic amplification partially from ice-albedo feedback; tropical deforestation: complex (albedo increase cools, but reduced evapotranspiration and roughness change warm); not simply reducible to albedo alone
LE9|Microclimate|climate of small area differing from surroundings due to local features; wall-side, forest interior, courtyard, garden|sheltered from wind; thermal mass of walls; shade patterns; moisture from irrigation or vegetation; aspect; cold air drainage; surface material|1m to 100m scale; gardening: south-facing wall extends growing season; forest interior: cooler summer, warmer winter than clearing; planted windbreaks: reduce wind for 10-20× their height downwind; human comfort: shade, wind, humidity, radiation all matter

# feedback_mechanisms(id|name|type|mechanism|magnitude|timescale)
FB1|Ice-Albedo Feedback|positive|warming → ice/snow melt → lower albedo → more absorption → more warming → more melting; amplifies initial perturbation|strong in Arctic (Arctic amplification: warming 2-4× global average); weaker in Antarctic (ice sheet on land, not sensitive to ocean temp immediately)|years to decades for sea ice; centuries to millennia for ice sheets
FB2|Water Vapor Feedback|positive|warming → more evaporation → more atmospheric H₂O (strongest greenhouse gas) → more greenhouse warming → more evaporation; Clausius-Clapeyron: ~7% more H₂O per °C|largest positive feedback in climate system; approximately doubles warming from CO₂ alone; reason H₂O is feedback not forcing (responds to temperature; doesn't independently change)|days to weeks (fast adjustment)
FB3|Cloud Feedback|positive or negative (uncertain)|warming → changes in cloud cover, altitude, and properties; low clouds cool (reflect shortwave); high clouds warm (trap longwave); net effect depends on which changes dominate|largest uncertainty in climate sensitivity; current evidence suggests slightly net positive (warming amplified); different cloud types respond differently; models disagree most on low cloud response in subtropics|days to weeks (cloud lifetime); but response pattern evolves over decades
FB4|Lapse Rate Feedback|negative (tropics), positive (poles)|warming → tropical upper troposphere warms more than surface (moist adiabatic: more latent heat release aloft) → more OLR from warmer upper atmosphere → net negative; polar: surface warms more than aloft → net positive|negative in tropics partially offsets water vapor feedback; positive at poles contributes to Arctic amplification; global net slightly negative|weeks to months
FB5|Planck Response|negative|warming → surface emits more longwave radiation (T⁴ Stefan-Boltzmann) → more energy escapes to space; fundamental stabilizing mechanism|~3.2 W/m² per °C; without this, any perturbation would cause runaway warming; determines baseline climate sensitivity before feedbacks|immediate (radiative)
FB6|Vegetation-Climate Feedback|positive or negative|warming → vegetation shifts (treeline advances, grassland replaces tundra) → albedo changes, evapotranspiration changes, roughness changes → modifies local/regional energy and water balance|Sahara-Sahel: vegetation-precipitation feedback (more rain → more vegetation → more evapotranspiration → more rain; or reverse: less rain → vegetation dies → less evaporation → less rain); Arctic: shrubs replace tundra → lower albedo → warming|decades to centuries
FB7|Permafrost-Carbon Feedback|positive|warming → permafrost thaws → organic matter decomposes → releases CO₂ (aerobic) and CH₄ (anaerobic, from wetlands) → additional greenhouse warming → more thawing|estimated 30-150 Gt C potentially released by 2100 under high warming; slow but potentially large and essentially irreversible on human timescales; thermokarst (ground collapse) creates wetlands (CH₄ source)|decades to centuries; CH₄ from thermokarst may be faster
FB8|Weathering Feedback|negative (geological)|warming → more precipitation → faster chemical weathering of silicate rocks → CO₂ consumed (CaSiO₃ + CO₂ → CaCO₃ + SiO₂) → reduced greenhouse effect → cooling|geological thermostat; operates over millions of years; explains Earth's long-term temperature stability; prevents runaway greenhouse or snowball (eventually); too slow for current perturbation|10⁵ to 10⁶ years

# variability(id|name|definition|period|mechanism|effects)
VA1|Diurnal Cycle|daily temperature variation from solar heating; maximum afternoon, minimum pre-dawn|24 hours|surface absorbs solar radiation during day → emits longwave → cools at night; amplitude depends on: cloud cover (clouds reduce range), moisture (evaporative cooling limits max), continentality (deserts: 30°C range; oceanic: 2-3°C)|determines frost risk; controls convective precipitation timing (afternoon thunderstorms); drives land-sea breeze; drives mountain-valley breeze; UHI strongest at night
VA2|Seasonal Cycle|annual temperature and precipitation variation from Earth's 23.5° axial tilt and orbital position|12 months|tilt → changing solar angle and day length with season; summer hemisphere receives more direct radiation and longer days; reversed 6 months later; lag from thermal inertia (warmest month ~1-2 months after solstice)|defines growing seasons, monsoons, wet/dry seasons, migration, hibernation; tropics: minimal temperature seasonality but precipitation seasonality; mid-latitudes: strong temperature seasonality; poles: extreme light/dark seasonality
VA3|ENSO (El Niño-Southern Oscillation)|largest source of interannual climate variability; coupled ocean-atmosphere oscillation in tropical Pacific; 2-7 year irregular cycle|see OC5|El Niño: 0.5-2°C tropical Pacific warming; global mean temperature rises ~0.1-0.2°C; drought in Australia/Indonesia; flooding in Peru/Ecuador; mild North American winter; La Niña: opposite; teleconnections: ENSO signal propagates via atmospheric waves to affect weather worldwide|2-7 years
VA4|North Atlantic Oscillation (NAO)|pressure difference between Icelandic Low and Azores High; positive NAO: strong contrast, strong westerlies; negative NAO: weak contrast, weak westerlies|weeks to decades|pressure gradient drives North Atlantic westerlies; positive: strong westerlies → mild wet winters NW Europe, cold dry E Canada, reduced Atlantic hurricanes; negative: weak westerlies → cold European winters, more Mediterranean rain, more blocking|positive: mild European winter, wet Scandinavia; negative: cold European winter, snow; affects Arctic sea ice, Greenland temperature, Sahel rainfall; semi-permanent but fluctuates
VA5|Pacific Decadal Oscillation (PDO)|long-term (20-30 year) SST pattern in North Pacific; positive: warm eastern, cool central-western; negative: cool eastern, warm central-western|20-30 year phases|not fully understood; involves ocean gyre circulation, wind stress patterns, tropical-extratropical interaction; resembles decadal-scale ENSO-like pattern but centered in North Pacific|modulates ENSO impacts (warm PDO + El Niño = amplified effects); affects North American and Asian climate; salmon populations; precipitation patterns in western North America
VA6|Atlantic Multidecadal Oscillation (AMO)|basin-wide North Atlantic SST variation; warm and cool phases lasting 60-80 years (30-40 per phase)|60-80 year full cycle|linked to AMOC strength variation; warm phase: stronger AMOC → warmer North Atlantic SST → more Atlantic hurricanes → Sahel wetter → European summer warmth; mechanisms debated (internal variability vs forced)|warm AMO: more Atlantic hurricanes, wetter Sahel, warmer European summers; cool AMO: fewer hurricanes, Sahel drought; interacts with NAO; current phase: warm since ~1995
VA7|Milankovitch Cycles|long-term variations in Earth's orbital parameters affecting insolation distribution; primary driver of ice age cycles|eccentricity: 100,000 and 400,000 years; obliquity (tilt): 41,000 years; precession: 23,000 years|eccentricity: orbit shape (circular ↔ elliptical); obliquity: tilt angle (22.1-24.5°); precession: wobble of rotation axis → changes which hemisphere is closer to sun at perihelion; combined: modulate seasonal and latitudinal insolation distribution|ice ages paced by Milankovitch; critical factor: Northern Hemisphere summer insolation (must be cool enough for snow to survive → ice sheet growth → albedo feedback → glaciation); last glacial maximum ~20,000 years ago; current interglacial (Holocene) began ~11,700 years ago
VA8|Volcanic Eruption (Climate Impact)|large eruptions inject SO₂ into stratosphere → sulfate aerosols → reflects sunlight → cooling 1-3 years; tropospheric aerosols wash out in weeks (short-lived)|1-3 years cooling; 5-7 years full recovery|stratospheric SO₂ → H₂SO₄ aerosol → increases planetary albedo; must reach stratosphere to persist (tropospheric: weeks only); VEI 5+: measurable global cooling; VEI 7+: severe multi-year cooling|Pinatubo (1991): ~0.5°C global cooling for 2 years; Tambora (1815): "Year Without a Summer" 1816; Toba (~74,000 BP): possible near-extinction cooling (debated); aerosol veil: red sunsets, diffuse light
VA9|Solar Variability|11-year sunspot cycle varies total solar irradiance by ~0.1% (~1.4 W/m²); longer-term variations less well constrained|11 years (Schwabe cycle); 22 years (Hale magnetic); ~80-90 years (Gleissberg); grand minima (Maunder)|sunspot maximum → slightly more solar output → ~0.1 W/m² forcing; UV variation larger (6-8%) → affects stratospheric ozone and heating; possible amplification through stratospheric pathway|0.1% TSI variation → ~0.05-0.1°C surface temperature response per cycle; Maunder Minimum (1645-1715) contributed to Little Ice Age cooling (~0.2°C); current solar forcing much smaller than anthropogenic

# paleoclimate(id|name|period|conditions|mechanism|evidence)
PC1|Snowball Earth|~720-635 Ma (Cryogenian)|global or near-global ice cover; oceans frozen to equator; surface temperature -50°C; albedo ~0.6-0.9|runaway ice-albedo feedback from initial cooling (volcanic, continental position); escape via volcanic CO₂ accumulation (ice-covered ocean can't weather silicates) → extreme greenhouse → rapid deglaciation|glacial deposits at tropical paleolatitudes; cap carbonates (deposited immediately after deglaciation); iron formations (anoxic ocean under ice)
PC2|Paleocene-Eocene Thermal Maximum (PETM)|~56 Ma|+5-8°C global warming in <20,000 years; ice-free poles; ocean acidification; mass extinction of benthic foraminifera; crocodiles in Arctic|massive carbon release (5,000-10,000 Gt C from uncertain source: volcanic, methane hydrates, or combination); positive feedbacks amplified warming; recovery took ~200,000 years|negative carbon isotope excursion (light carbon from organic source); deep-sea carbonate dissolution; fossil evidence of warm-adapted organisms at high latitudes
PC3|Ice Age Cycles (Quaternary)|~2.6 Ma – present|alternating glacial (100,000 year duration) and interglacial (~10,000-30,000 years) periods; glacials: 3km ice sheets over North America and Europe; sea level 120m lower|Milankovitch orbital forcing → initial cooling → ice sheet growth → albedo feedback + CO₂ feedback (ocean absorbs CO₂ when cool → reduced greenhouse) → full glaciation; deglaciation triggered by orbital change → warming → ice melt → albedo feedback + CO₂ release from ocean|ice cores (temperature, CO₂, CH₄ from trapped air bubbles); marine sediment (oxygen isotope ratios reflect ice volume); glacial landforms (moraines, erratics, U-shaped valleys); coral terraces (sea level)
PC4|Holocene|~11,700 years ago – present|current interglacial; relatively stable climate (±1°C global mean until industrial era); agriculture, civilization, all recorded history within this period|orbital forcing trending toward next glaciation (gradual NH summer cooling) but anthropogenic forcing now dominates; 8.2 ka event: brief cooling from glacial lake drainage; Holocene Climatic Optimum: ~6,000 BP slightly warmer than preindustrial|ice cores; tree rings; lake sediments; speleothems (cave formations); historical records; archaeological evidence; pollen records show vegetation migration tracking climate
PC5|Medieval Warm Period|~950-1250 CE|regional warmth in North Atlantic sector (~0.5-1°C above Little Ice Age); Viking settlement of Greenland; European agricultural expansion; not globally synchronous|possibly: positive NAO, increased solar, reduced volcanism, internal variability; regional pattern suggests ocean circulation and atmospheric modes rather than global forcing|historical records; tree rings; ice cores; grape harvest dates; settlement archaeology; less warming in Southern Hemisphere (asymmetric)
PC6|Little Ice Age|~1300-1850 CE|regional cooling in North Atlantic sector (~0.5-1°C below Medieval); glacier advance; Thames freezing; European crop failures; Maunder Minimum period|multiple factors: Maunder solar minimum (~0.2°C forcing), increased volcanism (multiple large eruptions), possible ocean circulation changes, internal variability; not globally uniform|glacier moraines (recent advance positions); tree rings; historical records (paintings, frost fairs); ice cores; crop failure records; globally heterogeneous (some regions less affected)

# biome_climate(id|name|climate_type|temperature_range|precipitation|defining_climate_features)
BM1|Tropical Rainforest|equatorial (RC1)|25-28°C year-round; no month <18°C; <5°C annual range|2000-4000+ mm; no dry month (<60mm)|constant warmth + constant moisture; highest biodiversity; stratified canopy; decomposition fastest; soil leached (laterite); drives significant global evapotranspiration and carbon cycling
BM2|Tropical Savanna|tropical wet-dry (RC3)|20-30°C year-round; warm throughout|500-1500mm; distinct wet (ITCZ) and dry (subtropical high) seasons; dry season 3-8 months|fire-maintained; grass dominates with scattered trees; wildlife migration follows rain; seasonal rivers; laterite soils; wet-dry seasonality is defining feature
BM3|Hot Desert|subtropical desert (RC4)|extreme: 50°C+ max, near-freezing winter nights; >30°C diurnal range|<250mm; years may pass without rain; episodic when it occurs|radiation-dominated energy budget; nearly all solar absorbed (low albedo except sand); extreme diurnal range (clear sky → no insulation); water is limiting factor for all life; adapted organisms: succulents, nocturnal behavior, deep roots
BM4|Temperate Deciduous Forest|humid subtropical/humid continental (RC8/RC10)|4-season: -5 to 30°C; moderate annual range (20-35°C)|750-1500mm; year-round; moderate seasonality|deciduous = trees shed leaves in response to cold winter (photoperiod trigger); defined by freezing winter that limits growing season; rich soils; historically heavily converted to agriculture; spring-autumn growing season 5-8 months
BM5|Temperate Grassland|semi-arid continental (RC6/RC10)|hot summers (30°C+); cold winters (-20°C); large annual range (40-60°C)|250-750mm; summer-dominant; insufficient for forest|insufficient moisture for trees; deep-rooted grasses dominate; most fertile soils (mollisols/chernozems); most converted biome (breadbaskets: Great Plains, Pampas, Ukraine steppe, North China Plain); fire and drought maintain grassland
BM6|Boreal Forest (Taiga)|subarctic (RC11)|long cold winters (-40 to -20°C); brief warm summers (10-20°C); extreme annual range (50-70°C)|300-600mm; low but exceeds evaporation (cold → low evaporation → boggy)|largest terrestrial biome by area; coniferous (needle-leaved evergreen); slow decomposition → peat accumulation → massive carbon storage; permafrost underlying southern portions; fire cycles (30-200 year return); 3-5 month growing season
BM7|Tundra|polar/subpolar (RC12)|warmest month <10°C; coldest: -30 to -50°C|<250mm but surface is wet (low evaporation + permafrost prevents drainage)|treeline boundary defined by 10°C warmest month isotherm; permafrost continuous; active layer thaws annually (50-100 cm); frost-patterned ground (polygons, circles); extreme photoperiod (24h sun/dark); wind exposure
BM8|Mediterranean Scrubland|Mediterranean (RC7)|mild wet winters (5-15°C); hot dry summers (25-35°C)|400-900mm; winter-dominant (summer drought 3-6 months)|fire-adapted vegetation (sclerophyllous: thick waxy leaves minimize water loss); summer drought is defining stress; convergent evolution of similar vegetation on 5 continents; chaparral (California), maquis (Mediterranean), fynbos (South Africa), kwongan (Australia), matorral (Chile)

# measurement(id|name|definition|method|significance)
MS1|Temperature Record|systematic measurement of air temperature (2m above ground in screened shelter); station data from 1850s, global coverage improving|thermometer in Stevenson screen; automated weather stations; radiosondes (balloons); satellite remote sensing (atmospheric profile); ship and buoy SST; reanalysis products (models + observations)|defines climate zones; tracks trends; global mean surface temperature (GMST) is primary metric; station data requires homogenization (site moves, instrument changes, urbanization); satellite era (1979+) provides global coverage
MS2|Precipitation Measurement|rain gauges (point measurement); radar (spatial); satellite (global)|tipping bucket rain gauge; weighing gauge; weather radar (Z-R relationship: reflectivity → rainfall rate); satellite (TRMM, GPM: passive microwave and radar); snow: snow gauge, snow depth, snow water equivalent|precipitation hardest climate variable to measure accurately (spatial variability enormous); gauge undercatch in wind (10-50% for snow); radar calibrated by gauges; satellite estimates improve coverage but less accurate than ground truth
MS3|Proxy Data|indirect climate evidence from natural archives; extends record beyond instrumental era|tree rings (width, density → temperature, precipitation); ice cores (δ¹⁸O, trapped gas → temperature, atmospheric composition); speleothems (cave formations: δ¹⁸O); corals (growth bands: SST); lake/ocean sediments (pollen, diatoms, isotopes)|each proxy has strengths, limitations, and temporal resolution; multi-proxy reconstructions more robust; calibration against instrumental period essential; tree rings: annual resolution, centuries to millennia; ice cores: annual to decadal resolution, 800,000+ years; sediments: decadal to millennial resolution, millions of years
MS4|Satellite Remote Sensing|observation of Earth's climate system from orbit; electromagnetic spectrum measurements providing global coverage|radiometers (temperature, radiation budget); microwave sounders (atmospheric profile); altimeters (sea level, ice thickness); scatterometers (wind); visible/IR imagers (clouds, vegetation, albedo); lidar (aerosol, cloud vertical structure)|global coverage (unlike point measurements); consistent instrumentation; calibration challenges (instrument drift, orbit changes); continuous records since ~1979; transformative for ocean, polar, and developing-world coverage; complements but doesn't replace ground stations
MS5|Reanalysis|combining observations (surface, upper-air, satellite) with numerical weather model to produce physically consistent gridded dataset of atmospheric state|data assimilation: model provides first guess; observations correct model; produces best estimate of atmospheric state at every point and time; ERA5, NCEP/NCAR, MERRA-2, JRA-55|provides complete 3D atmospheric dataset where observations are sparse; enables study of circulation changes; not pure observations (model-dependent); useful for climate analysis but trends must be interpreted cautiously (changing observation density over time can create spurious trends)
MS6|Climate Model|mathematical representation of climate system (atmosphere, ocean, land, ice) solved numerically on grid; General Circulation Model (GCM) / Earth System Model (ESM)|fundamental equations: conservation of mass, energy, momentum; thermodynamics; radiation; parameterized processes (clouds, turbulence, convection) below grid resolution; resolution: ~25-100 km atmosphere; ~10-50 km ocean; coupled models exchange fluxes between components|projects future climate under scenarios; attribution of observed changes; understanding mechanisms; ensemble approaches (multiple models, multiple runs) quantify uncertainty; skill assessed by reproducing observed climate and paleoclimate; largest uncertainty: cloud parameterization and aerosol-cloud interaction

# failure_modes(id|topic|mode|cause|consequence|prevention)
FM1|understanding|confusing weather and climate|short-term weather event treated as climate evidence; cold winter ≠ no warming; hot day ≠ climate change proof|misinformed decisions; false confidence or false complacency; susceptibility to misleading arguments|climate = 30+ year statistics; weather = individual events; distribution shifts (more extreme events) is climate; individual event is weather; attribution science can estimate climate influence on specific weather events
FM2|energy|ignoring latent heat|focusing only on temperature (sensible heat) while ignoring energy stored in water vapor phase changes|underestimates total energy in climate system; misunderstands storm intensification; misinterprets wet-bulb temperature lethality; underestimates ocean energy absorption|latent heat is largest surface-to-atmosphere energy transfer; storm energy comes from latent heat release; wet-bulb temperature (combined heat + humidity) determines human survivability; ocean absorbs energy without proportional temperature rise (phase changes, mixing)
FM3|circulation|treating climate zones as fixed|assuming current boundaries of climate zones, biomes, and agricultural zones are permanent; they shift with climate change|maladapted infrastructure, agriculture, and water management; surprised by shifts in precipitation patterns, growing seasons, or extreme events|climate zones are defined by dynamic circulation (ITCZ position, jet stream, subtropical highs); these circulations respond to forcing; Hadley cell expands with warming; jet stream may shift poleward; subtropical dry zones expand; what grew here historically may not grow here in future
FM4|feedback|linear thinking|assuming climate response is proportional to forcing without considering feedbacks; or that current rate of change will continue unchanged|underestimates nonlinear responses; misses tipping points; false precision about future states|feedback loops amplify or dampen initial forcing; ice-albedo, water vapor, permafrost-carbon can accelerate change; some feedbacks have thresholds (ice sheet collapse, permafrost thaw, forest dieback); system may shift abruptly between states
FM5|ocean|ignoring ocean role|treating climate as atmospheric phenomenon; underestimating ocean thermal inertia, circulation, and heat storage|misunderstands commitment to future warming (ocean has absorbed heat that will re-emerge); underestimates sea level rise timeline; misses ocean circulation changes|ocean absorbs 93% of excess heat; ocean thermal inertia means centuries of adjustment even if forcing stabilizes; AMOC changes affect hemispheric climate distribution; ocean pH changes affect marine ecosystems; sea level responds on centennial-millennial timescales
FM6|regional|assuming uniform response|expecting all regions to change in same direction or magnitude; global mean obscures regional extremes|some regions warm faster (Arctic: 2-4×), some may temporarily cool (North Atlantic if AMOC weakens); precipitation changes are highly regional (wet gets wetter, dry gets drier — approximate); planning based on global mean misses local reality|use regional climate projections; understand mechanisms (why is this region different); Arctic amplification; continental interiors warm faster than oceans; precipitation changes follow circulation changes; extremes change faster than means
FM7|measurement|conflating correlation with mechanism|observed correlation between two climate variables assumed to be mechanistic; teleconnections without physical pathway; spurious correlation from shared trend|false causal claims; misidentified drivers; overconfident predictions based on statistical relationships that may not hold under changed conditions|require physical mechanism to explain correlation; test relationships across different time periods and conditions; distinguish forced trends from internal variability; attribution requires both statistical and physical analysis

# distinctions(id|side_a|side_b|key_asymmetry)
DI1|Weather|Climate|weather: instantaneous atmospheric state; chaotic; unpredictable beyond ~10 days; experienced directly; what you get; climate: statistical description of weather over 30+ years; predictable (forced by boundary conditions); defines what to expect; "climate is what you expect, weather is what you get"
DI2|Sensible Heat|Latent Heat|sensible: changes temperature (measurable by thermometer); transferred by conduction, convection, radiation; latent: changes phase (solid↔liquid↔gas) without changing temperature; stored in molecular arrangement; released during condensation/freezing; latent heat transfer dominates surface-to-atmosphere energy budget
DI3|Forced Response|Internal Variability|forced: climate change driven by external factor (solar, volcanic, orbital, greenhouse gases); predictable direction from known forcing; internal: natural fluctuation from chaotic dynamics, ocean-atmosphere coupling (ENSO, NAO, PDO, AMO); inherently unpredictable beyond seasons; forced response emerges from internal variability over time
DI4|Radiative Forcing|Feedback|forcing: initial perturbation of energy balance from external cause (more CO₂, volcanic aerosol, solar change); independent of climate state; feedback: response of climate system to initial perturbation that further modifies energy balance (ice-albedo, water vapor, cloud); dependent on climate state; forcing causes change; feedbacks amplify or dampen
DI5|Maritime Climate|Continental Climate|maritime: ocean-moderated; small annual temperature range; humid; cloudier; seasons lag; examples: London, San Francisco; continental: land-dominated; large annual temperature range; drier; clearer skies; less lag; examples: Moscow, Ulaanbaatar; continentality increases with distance from ocean and with barriers between ocean and location
DI6|Dry Adiabatic Lapse Rate|Moist Adiabatic Lapse Rate|DALR: ~9.8°C/km; constant; applies to unsaturated air; no condensation occurring; temperature change entirely from compression/expansion; MALR: ~5-6°C/km (varies); applies to saturated air; slower cooling because condensation releases latent heat that partially offsets cooling; MALR varies with temperature (warmer = more moisture = more latent heat = slower lapse rate)
DI7|Shortwave Radiation|Longwave Radiation|shortwave: from sun; visible + near-IR + UV; peak ~0.5 μm; passes through most of atmosphere except clouds and ozone; heats surface; longwave: emitted by earth/atmosphere; infrared; peak ~10 μm; absorbed and re-emitted by greenhouse gases; the radiation greenhouse gases intercept; albedo affects shortwave; greenhouse effect involves longwave
DI8|Convective Precipitation|Frontal Precipitation|convective: from thermal instability (hot surface → rising air → cumulonimbus → rain); intense, localized, short-duration, afternoon timing, tropical dominant; frontal: from forced lifting at air mass boundaries (warm front: warm over cold; cold front: cold under warm); widespread, longer-duration, organized, mid-latitude dominant; orographic: forced by terrain, can combine with either
DI9|Positive Feedback|Negative Feedback|positive: amplifies initial change (ice melts → lower albedo → more warming → more melting); destabilizing; pushes system further from initial state; negative: dampens initial change (warming → more longwave emission → more cooling → returns toward balance); stabilizing; resists change; climate system has both; net feedbacks determine sensitivity
DI10|Advection|Convection|advection: horizontal transport of heat, moisture, or other properties by wind; synoptic scale; warm/cold fronts; heat transport by ocean currents; convection: vertical transport driven by buoyancy (warm air rises); local to mesoscale; thunderstorms, cumulus; dominant in tropics; both move energy but in perpendicular directions
DI11|Albedo|Emissivity|albedo: fraction of shortwave radiation reflected; 0 (perfect absorber) to 1 (perfect reflector); controls solar energy absorption; emissivity: efficiency of longwave radiation emission; 0 (perfect reflector) to 1 (blackbody); controls cooling rate; good absorbers are generally good emitters (Kirchhoff's law); ice: high albedo + high emissivity (reflects solar, efficiently radiates longwave); dark surfaces: low albedo + high emissivity (absorbs solar, efficiently radiates heat)
DI12|Climate Sensitivity (ECS)|Transient Climate Response (TCR)|ECS (equilibrium climate sensitivity): warming after full equilibration (centuries) from CO₂ doubling; ~2.5-4.0°C (IPCC AR6 likely range); includes all feedbacks including slow (ice sheet, vegetation); TCR (transient climate response): warming at time of CO₂ doubling (70 years at 1%/year); ~1.4-2.2°C; includes fast feedbacks only; TCR < ECS because system hasn't equilibrated; ECS determines long-term commitment; TCR determines near-term trajectory

# relationships(from|rel|to)
# Energy budget chain
EB1|drives|EB2,EB3,EB4,EB5
EB3|produces|EB6
EB6|absorbed_by|EB11
EB11|produces|EB7
EB7|warms|EB3
EB8|balances|EB1
EB9|transfers|CO19
EB10|transfers|CO20

# Atmospheric structure → circulation
AS1|contains|CR1,CR2,CR3
AS5|bounds|AS1
AS6|interfaces|AS1
AS7|stabilizes|AS1

# Circulation cells
CR1|drives|CR4,CR5
CR2|driven_by|CR1,CR3
CR3|produces|CR6
CR6|bounds|CR2,CR3
CR7|modulates|CR6
CR8|results_from|CR1,CO24
CR9|results_from|CO24
CR10|results_from|CO24
CR11|results_from|CO24
CR12|results_from|CO22,CO9

# Water cycle
WC1|produces|CO17
WC2|supplements|WC1
WC3|releases|CO19
WC3|requires|WC6
WC4|follows|WC3
WC5|returns_to|OC1
WC6|modifies|EB4,EB5,EB7
WC7|transports|CO17
WC8|caused_by|CO22

# Ocean → atmosphere
OC1|moderates|CO21,CO24
OC2|transports|CO20,EB3
OC3|distributes|OC1
OC4|driven_by|OC3,CR1
OC5|modulates|CR13,VA3
OC6|determines|WC1,CR8
OC7|separates|OC1
OC8|driven_by|EB11

# Regional climate → mechanisms
RC1|controlled_by|CR1,CR4
RC2|controlled_by|CR8
RC3|controlled_by|CR1,CR5
RC4|controlled_by|CR5
RC5|controlled_by|CO21,CO22
RC6|transitional|RC4,RC8
RC7|controlled_by|CR5,CR2
RC8|controlled_by|OC3,CR5
RC9|controlled_by|CR2,CO23
RC10|controlled_by|CO21
RC11|controlled_by|CR3,CO21
RC12|controlled_by|CR3
RC13|controlled_by|EB4,CR3
RC14|controlled_by|CO8,CO22

# Local effects
LE1|modifies|RC8,RC10
LE2|modifies|VA1
LE3|results_from|CO24
LE4|results_from|OC3,OC4
LE5|results_from|CO22
LE6|modifies|CO3
LE7|contributes_to|LE1
LE8|modifies|EB3,EB4

# Feedback → energy budget
FB1|amplifies|EB4
FB2|amplifies|EB7,EB11
FB3|modifies|EB5,EB7
FB4|modifies|EB8
FB5|stabilizes|EB6,EB8
FB6|modifies|EB3,EB4,EB9
FB7|amplifies|EB11
FB8|dampens|EB11

# Variability → mechanisms
VA1|driven_by|EB1,EB3
VA2|driven_by|VA7,EB1
VA3|driven_by|OC5
VA4|driven_by|CR6,OC2
VA5|modulates|VA3
VA6|driven_by|OC2
VA7|paces|PC3
VA8|perturbs|EB5,EB8
VA9|modulates|EB1

# Paleoclimate → mechanisms
PC1|demonstrates|FB1
PC2|demonstrates|FB2,FB7
PC3|paced_by|VA7
PC3|amplified_by|FB1,FB2
PC4|context_for|CO1
PC5|illustrates|VA4,VA6
PC6|illustrates|VA8,VA9

# Biome → climate
BM1|defined_by|RC1
BM2|defined_by|RC3
BM3|defined_by|RC4
BM4|defined_by|RC8,RC10
BM5|defined_by|RC6
BM6|defined_by|RC11
BM7|defined_by|RC12
BM8|defined_by|RC7

# Measurement
MS1|measures|CO1
MS2|measures|WC4
MS3|extends|MS1
MS4|complements|MS1,MS2
MS5|integrates|MS1,MS4
MS6|simulates|CO1

# Concept interdependencies
CO3|modified_by|CO4,VA2,VA7
CO8|determines|WC3,WC6
CO9|drives|WC3,WC4,CR12
CO10|deflects|CR1,CR2,CR3,OC3
CO11|initiates|CR1,CR2,CR3
CO12|produces|CR6
CO13|drives|WC4,CR4
CO14|drives|CR5
CO15|transports|CO20,CO17
CO16|transports|CO19,CO20
CO19|links|EB9,WC1,WC3
CO21|modulates|VA1,RC10,RC11
CO22|produces|WC8,LE5
CO23|produces|LE4,RC9
CO24|moderates|VA1,RC7,RC9

# Distinction mappings
DI1|distinguishes|CO1,CO2
DI2|distinguishes|CO19,CO20
DI3|distinguishes|VA3,EB11
DI4|distinguishes|CO7,FB1
DI5|distinguishes|CO21,CO23
DI6|distinguishes|CO8,CO9
DI7|distinguishes|EB1,EB6
DI8|distinguishes|WC4
DI9|distinguishes|FB1,FB5
DI10|distinguishes|CO15,CO16
DI11|distinguishes|CO4,CO5
DI12|distinguishes|MS6

# decode_legend
# id_prefixes: CO=concept, EB=energy_budget, AS=atmospheric_structure, CR=circulation, WC=water_cycle, OC=ocean, RC=regional_climate, LE=local_effect, FB=feedback_mechanism, VA=variability, PC=paleoclimate, BM=biome_climate, MS=measurement, FM=failure_mode, DI=distinction
# rel_types: drives|absorbed_by|produces|warms|balances|transfers|contains|bounds|interfaces|stabilizes|driven_by|results_from|modulates|supplements|releases|requires|follows|returns_to|modifies|caused_by|transports|distributes|determines|separates|controlled_by|transitional|contributes_to|amplifies|dampens|perturbs|paces|paced_by|amplified_by|context_for|illustrates|demonstrates|defined_by|measures|extends|complements|integrates|simulates|modified_by|deflects|initiates|links|moderates|distinguishes
# climate_classification: Köppen-Geiger system (Af, Am, Aw, BWh, BWk, BSh, BSk, Csa, Csb, Cfa, Cfb, Cfc, Dfa, Dfb, Dfc, Dfd, ET, EF); first letter: A=tropical, B=arid, C=temperate, D=continental, E=polar; subscripts indicate precipitation pattern and temperature
# energy_units: W/m² for fluxes; J or kJ for energy; °C or K for temperature; mm for precipitation; ppm/ppb for gas concentrations
# timescales: diurnal (~24hr); synoptic (days-week); seasonal (~months); interannual (2-10 yr); decadal (10-30 yr); centennial (100 yr); millennial (1000 yr); orbital (10,000-100,000 yr); geological (millions of years)
# confidence: synthetic domain knowledge — not extracted from a single source document

# relation_mapping(doc_rel|canonical_rel|notes)
drives|enables|X drives Y = X enables Y
absorbed_by|input_to|radiation absorbed by gas = radiation is input_to gas process
produces|produces|exact match
warms|amplifies|counter-radiation warms surface = amplifies surface energy
balances|complement_of|OLR balances solar input; symmetric
transfers|flows_to|energy transfers via flux = flows_to
contains|contains|exact match
bounds|constrains|tropopause bounds troposphere = constrains extent
interfaces|connects_to|boundary layer interfaces troposphere; symmetric
stabilizes|regulates|inversion stabilizes troposphere = regulates
driven_by|depends_on|Ferrel cell driven by Hadley = depends_on
results_from|result_of|local effect results from mechanism = result_of
modulates|regulates|Rossby waves modulate jet stream = regulates behavior
supplements|extends|transpiration supplements evaporation = extends
releases|produces|condensation releases latent heat = produces
requires|requires|exact match
follows|follows|exact match
returns_to|flows_to|runoff returns to ocean = flows_to
modifies|influences|local effect modifies regional climate = influences
caused_by|result_of|orographic precip caused by terrain = result_of
transports|flows_to|atmospheric river transports moisture = flows_to
distributes|propagates_via|currents distribute heat = propagates_via
determines|determined_by|inverse; SST determines evaporation = evaporation determined_by SST
separates|isolates|thermocline separates layers = isolates
controlled_by|determined_by|regional climate controlled by circulation = determined_by
transitional|connects_to|steppe transitional between desert and humid; symmetric
contributes_to|enables|urban canyon contributes to UHI = enables
amplifies|amplifies|exact match
dampens|mitigated_by|inverse; weathering dampens greenhouse = greenhouse mitigated_by weathering
perturbs|disrupts|volcanic eruption perturbs energy budget = disrupts
paces|controls|Milankovitch paces ice ages = controls timing
paced_by|determined_by|ice ages paced by Milankovitch = determined_by orbital forcing
amplified_by|amplifies|inverse; ice ages amplified by feedback = feedback amplifies ice ages
context_for|contains|Holocene context for modern climate = contains temporally
illustrates|indicates|MWP illustrates NAO/AMO = indicates their behavior
demonstrates|indicates|Snowball Earth demonstrates ice-albedo feedback = indicates mechanism
defined_by|determined_by|biome defined by climate type = determined_by
measures|inspects|instrument measures variable = inspects without modifying
extends|extends|exact match
complements|complements|exact match; symmetric
integrates|synthesizes|reanalysis integrates observations and model = synthesizes
simulates|models|climate model simulates climate = models
modified_by|influences|inverse; X modified_by Y = Y influences X
deflects|controls|Coriolis deflects circulation = controls direction
initiates|enables|pressure gradient initiates circulation = enables
links|connects_to|latent heat links energy and water cycles; symmetric
moderates|regulates|ocean moderates temperature = regulates
distinguishes|distinguishes|exact match
