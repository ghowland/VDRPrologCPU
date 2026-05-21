# MECHANICAL SYSTEMS: PHYSICAL INFRASTRUCTURE — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: domains → energy_conversion → prime_movers → pumps → compressors → valves → actuators → bearings → gears → couplings → seals → fasteners → springs → dampers → heat_exchangers → piping → hydraulic_systems → pneumatic_systems → structural → sensors → controllers → materials → failure_modes → concepts → relationships → section_index → decode_legend

# domains(id|name|definition)
DM1|fluid power|transmission and control of energy using pressurized fluid (hydraulic: liquid; pneumatic: gas)
DM2|power transmission|transfer of mechanical energy between components via shafts, gears, belts, chains, couplings
DM3|thermal systems|generation, transfer, rejection of heat; combustion, heat exchange, refrigeration
DM4|structural/machine frame|load-bearing structures; frames, supports, mounts, vibration isolation
DM5|instrumentation and control|measurement of process variables; feedback loops; actuator command; safety interlocks
DM6|material handling|conveyors, hoists, cranes, lifts; moving solid materials through processes
DM7|sealing and containment|preventing fluid leakage across pressure boundaries; gaskets, seals, packing
DM8|motion conversion|converting between rotary and linear motion; cams, cranks, screws, linkages

# energy_conversion(id|name|input_energy|output_energy|mechanism|efficiency_range|examples)
EC1|combustion engine (reciprocating)|chemical (fuel)|mechanical (shaft rotation)|fuel-air combustion → piston → crankshaft; Otto cycle (spark ignition) or Diesel cycle (compression ignition)|25–45% (Otto); 35–55% (Diesel)|gasoline engine, diesel generator, gas engine
EC2|gas turbine|chemical (fuel)|mechanical (shaft rotation)|continuous combustion; compressor → combustor → turbine (Brayton cycle)|30–45% (simple); 55–62% (combined cycle with steam)|jet engine, power generation, mechanical drive
EC3|steam turbine|thermal (steam)|mechanical (shaft rotation)|high-pressure steam expands through blade stages (Rankine cycle)|30–45% (subcritical); 45–49% (supercritical)|power plant, ship propulsion, industrial drive
EC4|electric motor|electrical|mechanical (shaft rotation)|electromagnetic force between stator field and rotor; AC (induction, synchronous) or DC (brushed, brushless)|85–97% (AC induction); 90–99% (permanent magnet synchronous)|industrial drive, pump drive, compressor drive, EV traction
EC5|electric generator|mechanical (shaft rotation)|electrical|conductor moving through magnetic field → induced EMF (Faraday's law); synchronous or induction|90–98%|power plant generator, wind turbine, backup genset
EC6|hydraulic motor|hydraulic (pressurized fluid)|mechanical (shaft rotation)|pressure difference across vanes, gears, or pistons → torque|85–95% (volumetric × mechanical)|excavator swing, winch drive, wheel motor
EC7|hydraulic cylinder|hydraulic (pressurized fluid)|mechanical (linear force)|pressure acts on piston area → F = P × A|90–98% (mechanical)|excavator boom, press, steering, lift
EC8|pneumatic motor|pneumatic (compressed gas)|mechanical (shaft rotation)|compressed air expands against vanes or pistons|10–30% (low due to expansion losses)|air tools, paint mixing, hazardous environment drives
EC9|pneumatic cylinder|pneumatic (compressed gas)|mechanical (linear force)|compressed air acts on piston area|70–90% (depends on friction and air consumption)|clamping, sorting, packaging, automation
EC10|heat pump / refrigeration|mechanical + electrical|thermal (heat transfer against gradient)|vapor-compression cycle (evaporate → compress → condense → expand) or absorption cycle|COP 2.5–5.5 (heating); COP 2.0–4.5 (cooling)|HVAC, industrial chiller, heat recovery

# prime_movers(id|name|type|power_range_kW|speed_range_rpm|torque_characteristics|fuel_or_input|starting_method|applications)
PM1|diesel engine|reciprocating IC|1–100,000|300–3,600|high torque at low RPM; torque curve relatively flat|diesel fuel (cetane 40–55)|electric starter, air starter (large), hydraulic starter|generators, pumps, marine propulsion, heavy vehicles, rail
PM2|gasoline engine|reciprocating IC|1–500|800–10,000|peak torque at mid-RPM; peak power at high RPM|gasoline (octane 87–100)|electric starter|vehicles, portable generators, small equipment
PM3|gas turbine (industrial)|turbine|500–500,000|3,000–15,000 (power turbine may be geared)|constant power over speed range; poor part-load efficiency|natural gas, diesel, dual-fuel|electric starter motor → self-sustaining at ~60% speed|power generation, pipeline compression, LNG, offshore, marine
PM4|steam turbine|turbine|100–1,800,000|1,500–30,000|best efficiency at design point; poor off-design|steam (from boiler: coal, gas, nuclear, biomass, waste heat)|steam admission (self-starting once steam available)|power generation, industrial CHP, nuclear plant, ship propulsion
PM5|AC induction motor|electric|0.1–30,000|720–3,600 (2-pole to 10-pole at 60 Hz)|starting torque 150–300% rated; breakdown torque 200–350% rated; slip 1–5%|3-phase AC (230/460/4,160/13,800 V)|DOL, star-delta, soft starter, VFD|pumps, compressors, fans, conveyors, most industrial drives
PM6|synchronous motor|electric|10–100,000|fixed at synchronous speed (3,600/1,800/1,200/900 rpm at 60 Hz)|constant speed; power factor adjustable (leading/lagging)|3-phase AC + DC field excitation (or PM)|synchronous starting or VFD starting|large compressors, ball mills, extruders; power factor correction
PM7|DC motor|electric|0.01–5,000|0–5,000 (continuously variable)|torque proportional to current; speed proportional to voltage; excellent controllability|DC (battery, rectified AC)|direct energization; SCR/chopper control|cranes, elevators, traction (legacy), servo systems, battery vehicles
PM8|servo motor|electric|0.01–100|0–10,000|high torque at zero speed; precise position/velocity control; low inertia|DC brushless (BLDC) or AC permanent magnet synchronous (PMSM)|servo drive (closed-loop position/velocity/torque)|robotics, CNC, pick-and-place, semiconductor, precision motion
PM9|stepper motor|electric|0.001–5|0–3,000 (decreasing torque with speed)|discrete angular steps (0.9°, 1.8° typical); holding torque at standstill; open-loop position control|DC (pulse-driven)|pulse train from controller|3D printers, scanners, positioning stages, valves, instruments
PM10|hydraulic power unit (HPU)|hydraulic|1–5,000|pump driven by electric motor or diesel|constant pressure source; flow determined by pump displacement × speed|hydraulic fluid (mineral oil, synthetic, water-glycol)|electric motor start or diesel start|construction equipment, presses, injection molding, marine, mobile

# pumps(id|name|type|principle|flow_range|pressure_range_bar|fluid_types|self_priming|efficiency|applications)
PU1|centrifugal pump|rotodynamic|impeller imparts kinetic energy to fluid → volute/diffuser converts to pressure; flow proportional to speed, head proportional to speed²|1–100,000 m³/h|1–100 (single stage); up to 600 (multistage)|clean to moderately dirty liquids; low viscosity preferred (<500 cP)|no (requires priming or submersion)|60–90%|water supply, process, fire, cooling, irrigation, boiler feed
PU2|axial flow pump|rotodynamic|propeller-type impeller moves fluid axially; very high flow, low head|1,000–500,000 m³/h|0.5–10|clean water, low-viscosity|no|75–90%|flood control, cooling water, irrigation, drainage
PU3|gear pump (external)|positive displacement|two meshing gears trap and displace fluid between gear teeth and casing|0.1–500 m³/h|up to 250|oils, viscous fluids, fuels; not for abrasives|yes|80–95% (volumetric)|lubrication systems, fuel transfer, chemical dosing, hydraulic
PU4|gear pump (internal)|positive displacement|internal gear meshes with external gear; crescent separator; smooth flow|0.1–500 m³/h|up to 170|oils, viscous fluids, food-grade|yes|80–92%|fuel systems, lubrication, food/pharma
PU5|vane pump|positive displacement|vanes in slotted rotor slide out against cam ring; trapped volume changes with rotation|0.5–500 m³/h|up to 280|hydraulic fluid, fuels, solvents; not for abrasives|yes|80–95%|hydraulic systems, fuel dispensing, chemical transfer
PU6|piston pump (axial)|positive displacement|pistons in rotating barrel reciprocate via swashplate; displacement variable by swashplate angle|1–1,000 L/min|up to 700|hydraulic fluid (clean, filtered)|no|90–98% (volumetric)|high-pressure hydraulic systems, mobile equipment, presses, injection molding
PU7|piston pump (radial)|positive displacement|pistons arranged radially; cam or eccentric drives reciprocation|0.1–200 L/min|up to 1,000|hydraulic fluid (clean)|no|90–97%|very high pressure: waterjet cutting, test benches, machine tools
PU8|diaphragm pump|positive displacement|flexible diaphragm reciprocates; check valves control flow direction; no rotating seals|0.1–500 m³/h|up to 100|corrosive, abrasive, viscous, slurries, shear-sensitive|yes|40–85%|chemical dosing, slurry, mining, food, pharma, wastewater
PU9|screw pump (progressing cavity)|positive displacement|helical rotor turns in elastomer stator; cavities progress from suction to discharge|0.1–500 m³/h|up to 120|viscous, abrasive, shear-sensitive, solids-laden|yes|50–80%|wastewater, oil well (downhole), sludge, food, polymer
PU10|peristaltic pump|positive displacement|rollers compress flexible tube; fluid pushed ahead of compression; tube relaxation draws new fluid|0.001–100 m³/h|up to 16|any (fluid contacts only tube); sterile, abrasive, corrosive|yes|50–70%|pharma, biotech, lab, food, water treatment dosing
PU11|submersible pump|rotodynamic (centrifugal)|motor and pump submerged in fluid; close-coupled; shaft seal eliminated|1–10,000 m³/h|up to 250 (multistage)|water (clean to wastewater), oil well (ESP)|not applicable (submerged)|50–85%|borehole, well dewatering, sewage, oil well artificial lift
PU12|vacuum pump (rotary vane)|positive displacement|vanes in eccentric rotor create expanding/contracting chambers; draws gas from system|1–2,500 m³/h|absolute down to ~0.5 mbar|air, gases; oil-sealed or dry|yes|30–60% (isothermal efficiency)|vacuum packaging, lab, printing, plastics, semiconductor (dry type)

# compressors(id|name|type|principle|flow_range_m3_min|pressure_range_bar|efficiency|applications)
CP1|reciprocating compressor|positive displacement|piston compresses gas in cylinder; check valves; single or multi-stage with intercooling|0.5–3,000|up to 1,000+ (multi-stage)|70–90% (adiabatic)|natural gas processing, air compression, refrigeration, PET blowing
CP2|rotary screw compressor|positive displacement|two helical rotors (male + female) trap and compress gas between lobes and casing|0.5–3,000|5–15 (single stage); up to 40 (two-stage)|70–85% (adiabatic)|industrial compressed air (most common), gas gathering, process air
CP3|centrifugal compressor|rotodynamic|impeller accelerates gas → diffuser converts kinetic to pressure energy; multi-stage for high ratios|100–300,000|up to 100 (multi-stage)|70–85% (polytropic)|natural gas pipeline, refinery, LNG, HVAC chiller, turbocharger
CP4|axial compressor|rotodynamic|alternating rows of rotating blades and stationary vanes; high flow, moderate pressure ratio per stage|1,000–1,000,000|up to 40 (multi-stage; pressure ratio 10–30:1)|85–92% (polytropic)|gas turbine compressor section, large air separation, blast furnace blowing
CP5|scroll compressor|positive displacement|two interleaving scrolls; orbiting scroll traps and compresses gas pockets toward center|0.5–100|up to 12|65–80%|HVAC (residential/light commercial), refrigeration, medical air
CP6|diaphragm compressor|positive displacement|piston drives hydraulic fluid against metal diaphragm; gas never contacts piston or oil|0.1–500|up to 2,500|60–80%|ultra-high purity gas (semiconductor, pharma, hydrogen), leak-tight applications

# valves(id|name|type|motion|flow_characteristic|pressure_range_bar|sealing|quarter_turn|applications)
VL1|gate valve|isolation|linear (rising stem)|full bore open → minimum restriction; poor throttling; on/off only|up to 2,500|metal-to-metal or resilient seat|no|pipeline isolation, process, water, steam, oil/gas
VL2|globe valve|throttling/isolation|linear (rising stem)|good throttling; S-shaped flow path → higher pressure drop than gate|up to 1,000|metal disc on metal/soft seat|no|flow regulation, cooling water, feedwater, steam, chemical dosing
VL3|ball valve|isolation (some throttling)|rotary (90° quarter-turn)|full bore (low restriction) or reduced bore; fast open/close|up to 1,000 (trunnion-mounted)|PTFE/PEEK/metal seat; floating or trunnion ball|yes|pipeline isolation, process, chemical, oil/gas, cryogenic, fire-safe
VL4|butterfly valve|isolation/throttling|rotary (90° quarter-turn)|disc rotates in flow; higher pressure drop at partial open; good for large diameters|up to 150 (resilient); up to 250 (high-performance triple offset)|resilient seat (EPDM, Viton) or metal seat (triple offset)|yes|HVAC, water, wastewater, large pipeline, moderate-pressure process
VL5|check valve (swing)|non-return|automatic (flow-actuated)|disc swings open on forward flow; swings shut on reverse; prevents backflow|up to 500|metal disc on metal seat|n/a|pump discharge, compressor discharge, pipeline
VL6|check valve (spring-loaded disc)|non-return|automatic (spring + flow)|disc held shut by spring; opens when upstream pressure exceeds spring + downstream; fast closing|up to 400|metal or soft seat|n/a|where water hammer risk is high; vertical lines; compressor discharge
VL7|relief valve (spring-loaded)|pressure relief/safety|automatic (pressure-actuated)|spring holds disc closed; opens at set pressure; reseats when pressure drops below blowdown|set pressures 0.5–500|metal-to-metal|n/a|overpressure protection for vessels, piping, boilers (ASME code-stamped)
VL8|pressure reducing valve|pressure regulation|automatic (pilot or spring-diaphragm)|maintains constant downstream pressure regardless of upstream variation or flow changes|up to 400 (inlet)|diaphragm or piston + seat|n/a|steam pressure stations, compressed air, water distribution, process gas
VL9|solenoid valve|on/off (electrically actuated)|linear (plunger pulled by electromagnet)|fast switching (5–50 ms); normally open or normally closed; direct-acting or pilot-operated|up to 250|elastomer or PTFE seat|n/a|automation, safety shutdown, pneumatic control, fuel gas, irrigation
VL10|control valve (globe-type)|modulating flow control|linear (diaphragm or piston actuator)|plug/cage controls flow per installed characteristic (linear, equal-percentage, quick-opening); 4–20 mA signal input|up to 420|metal trim; soft or metal seat; characterized cage|no|process control (temperature, pressure, level, flow); refinery, chemical, power
VL11|control valve (rotary)|modulating flow control|rotary (quarter-turn actuator)|segmented ball, V-notch ball, or eccentric disc; good rangeability|up to 150|metal or soft seat|yes|large flow, slurry, fibrous media, moderate control accuracy
VL12|needle valve|fine throttling|linear (fine-thread stem)|tapered needle into seat; very fine flow adjustment; small bore|up to 600|metal-to-metal|no|instrument lines, sampling, gauge isolation, hydraulic systems
VL13|plug valve|isolation|rotary (quarter-turn)|tapered or cylindrical plug with bore; fast switching; moderate sealing|up to 700|lubricated (grease between plug and body) or PTFE-sleeved|yes|pipeline, chemical, slurry, oil/gas, multiport (3-way, 4-way)
VL14|diaphragm valve|isolation/throttling|linear (weir-type or full-bore)|flexible diaphragm pressed against weir; excellent for sterile and corrosive; dead-leg free|up to 16|diaphragm (EPDM, PTFE, natural rubber)|no|pharma, biotech, food, corrosive chemicals, slurry
VL15|pinch valve|isolation/throttling|linear (external compression of elastomer sleeve)|sleeve pinched by air or mechanical; excellent for solids, slurry; self-cleaning|up to 10|elastomer sleeve|no|mining, slurry, wastewater, bulk solids, abrasive media
VL16|directional control valve (hydraulic)|flow routing|spool (linear) or rotary|2-way, 3-way, 4-way, 5-way; 2-position or 3-position; routes hydraulic flow to actuator ports|up to 350|spool-to-bore clearance (μm-level); O-ring or lip seals|no|hydraulic cylinders, motors; mobile equipment; industrial presses
VL17|proportional valve (hydraulic)|modulating flow/pressure|spool with proportional solenoid|analog spool position proportional to electrical signal; flow or pressure control|up to 350|spool-to-bore|no|precision hydraulic positioning, injection molding, mobile proportional control
VL18|servo valve (hydraulic)|high-precision modulating|two-stage: torque motor → pilot spool → main spool|very fast response (<10 ms); high bandwidth (>100 Hz); 4-way metering; closed-loop position/force|up to 350|nozzle-flapper or jet-pipe first stage; spool second stage|no|aerospace flight control, test machines, CNC, high-precision motion

# actuators(id|name|type|motion|force_or_torque|speed|control_method|applications)
AC1|hydraulic cylinder (single-acting)|hydraulic|linear (extend only; spring or gravity return)|F = P × A; up to 10,000 kN (large bore)|0.01–1 m/s|directional valve + flow control|jacks, lifts, dump bodies, single-direction loads
AC2|hydraulic cylinder (double-acting)|hydraulic|linear (extend and retract)|F = P × A (differential area retract); up to 10,000 kN|0.01–1 m/s|4-way directional valve; proportional or servo for precision|excavators, presses, steering, industrial positioning
AC3|hydraulic rotary actuator|hydraulic|rotary (limited angle: 90°–360°)|torque = P × displacement/2π; up to 500,000 N·m|0.1–100 rpm|directional valve|crane slew, valve operation, hatch opening, rotating platforms
AC4|pneumatic cylinder (double-acting)|pneumatic|linear|F = P × A; typically 1–50 kN (limited by practical bore/pressure)|0.05–3 m/s (higher speed than hydraulic)|5/2 or 5/3 directional valve; speed regulated by flow control|clamping, ejecting, sorting, packaging, assembly automation
AC5|pneumatic rotary actuator|pneumatic|rotary (rack-and-pinion or vane)|torque typically 1–10,000 N·m|fast (90° in 0.1–5 s)|pilot valve, solenoid valve|valve automation (quarter-turn), indexing, material handling
AC6|electric linear actuator|electric|linear (motor + screw)|up to 500 kN (roller screw); ball screw lower|0.001–1 m/s|servo drive or stepper drive; position feedback (encoder/LVDT)|precision positioning, injection molding ejector, aircraft flight surface, medical
AC7|electric rotary actuator|electric|rotary (motor + gearbox)|torque range: fractional N·m (servo) to 100,000+ N·m (large geared)|continuously variable|VFD, servo drive, or simple on/off with limit switches|valve automation, damper control, industrial positioning, robotics
AC8|diaphragm actuator|pneumatic (spring-return)|linear (limited stroke ~50–100 mm)|F = P × diaphragm area; 1–200 kN|slow (1–30 s full stroke)|pneumatic signal 3–15 psi (0.2–1 bar) or 4–20 mA via I/P converter|control valve actuation (most common for globe valves); fail-safe: spring drives to safe position on air failure
AC9|piston actuator (pneumatic, for valves)|pneumatic|linear or scotch-yoke rotary|higher force than diaphragm (P × piston area); up to 1,000 kN|moderate (1–15 s)|solenoid pilot; fail-safe with spring or accumulator|large control valves, on/off isolation valves, emergency shutdown valves

# bearings(id|name|type|load_direction|speed_capability|friction_coefficient|lubrication|applications)
BE1|deep groove ball bearing|rolling element|radial + light axial|very high (dN values up to 2,000,000 mm·rpm)|0.001–0.003|grease or oil|electric motors, pumps, gearboxes, general purpose
BE2|angular contact ball bearing|rolling element|combined radial + axial (one direction per row; paired for bidirectional)|high|0.001–0.003|grease or oil|machine tool spindles, pumps, turbochargers; paired (DB, DF, DT arrangements)
BE3|tapered roller bearing|rolling element|combined radial + heavy axial (one direction; paired for bidirectional)|moderate to high|0.005–0.010|oil or grease|vehicle wheel hubs, gearboxes, heavy-duty machinery, rolling mills
BE4|cylindrical roller bearing|rolling element|heavy radial; no axial (or limited if flanged)|high|0.003–0.006|oil or grease|heavy radial loads: rolling mills, gearboxes, electric motors, compressors
BE5|spherical roller bearing|rolling element|heavy radial + moderate axial; self-aligning|moderate|0.005–0.010|oil|misalignment tolerance: vibrating screens, conveyors, paper machines, mining crushers
BE6|thrust ball bearing|rolling element|axial only|moderate to high|0.001–0.003|grease or oil|vertical shafts, low-speed axial loads, clutch release bearings
BE7|needle roller bearing|rolling element|radial (compact cross-section)|moderate|0.003–0.006|oil or grease|space-constrained: connecting rods, gearboxes, rocker arms, cam followers
BE8|plain bearing (journal)|sliding|radial|low to moderate (limited by surface speed and heat)|0.01–0.10 (boundary); 0.001–0.01 (hydrodynamic film)|oil film (hydrodynamic) or grease (boundary)|large turbines, marine shafts, crankshafts, slow heavy machinery; Babbitt metal or bronze bushings
BE9|plain bearing (thrust)|sliding|axial|low to moderate|0.01–0.05 (hydrodynamic)|oil film (tilting pad, tapered land)|large turbine thrust bearings, vertical pump thrust; tilting pad design for stability
BE10|linear bearing (ball, rail)|rolling element|linear (along rail)|high|0.001–0.005|grease|CNC machine axes, semiconductor equipment, linear actuators, 3D printers
BE11|magnetic bearing (active)|non-contact|radial and/or axial|very high (no mechanical speed limit → limited by rotor dynamics)|~0 (no contact)|none (electromagnetic suspension; backup: touchdown bearings)|high-speed turbomachinery, flywheel energy storage, turbo compressors, vacuum applications

# gears(id|name|type|axis_arrangement|speed_ratio_range|efficiency|noise_level|torque_capacity|applications)
GR1|spur gear|parallel axis|shafts parallel|1:1 to 6:1 per stage|97–99% per mesh|moderate to high (no axial thrust)|moderate to high|simple drives, clocks, conveyor drives, low-cost industrial
GR2|helical gear|parallel axis|shafts parallel|1:1 to 10:1 per stage|96–99% per mesh|lower than spur (gradual engagement)|high|automotive transmissions, industrial gearboxes, compressors
GR3|herringbone (double helical) gear|parallel axis|shafts parallel|1:1 to 10:1|96–99%|low|very high|large industrial (turbine gearboxes, ship drives); eliminates axial thrust of helical
GR4|bevel gear (straight)|intersecting axis|shafts at 90° (or other angles)|1:1 to 5:1|95–98%|moderate|moderate|hand tools, differentials, light-duty right-angle drives
GR5|bevel gear (spiral)|intersecting axis|shafts at 90°|1:1 to 5:1|96–99%|low (gradual engagement)|high|automotive differentials, industrial right-angle gearboxes
GR6|worm gear|non-intersecting perpendicular|worm on one shaft, wheel on perpendicular shaft|5:1 to 100:1 (single stage)|40–90% (depends on lead angle; self-locking below ~50%)|low|moderate; self-locking if lead angle < friction angle|conveyors, lifts, tuning mechanisms; self-locking for holding loads
GR7|planetary (epicyclic) gear|coaxial|sun + planets + ring; compound ratios by fixing one element|3:1 to 12:1 per stage; up to 1,000,000:1 multi-stage|95–97% per stage|low to moderate|very high (load shared across planets)|automatic transmissions, wind turbine gearboxes, helicopter, robotics, industrial speed reducers
GR8|rack and pinion|linear-rotary conversion|pinion rotates; rack translates|depends on pinion diameter and module|95–98%|moderate|moderate|steering systems, CNC linear drives, gate openers, elevators
GR9|harmonic drive (strain wave)|coaxial|wave generator + flex spline + circular spline|30:1 to 320:1 (single stage)|65–85%|very low|moderate (compact size)|robotics, aerospace, semiconductor, precision positioning; zero backlash
GR10|cycloidal drive|coaxial|eccentric input + cycloidal disc + output pins|10:1 to 120:1|85–93%|low|high (shock-load tolerant)|heavy-duty robotics, material handling, rolling mills; zero or near-zero backlash

# couplings(id|name|type|misalignment_tolerance|torque_range_Nm|torsional_stiffness|applications)
CU1|rigid coupling (flanged)|rigid|none (shafts must be precisely aligned)|up to 1,000,000|very high (essentially infinite)|pump-motor where precise alignment achieved; test rigs
CU2|flexible jaw coupling|elastomeric|angular ±1°, radial 0.1–0.5 mm, axial ±2 mm|10–100,000|medium (spider element absorbs shock)|general purpose pump, fan, compressor drives
CU3|gear coupling|metallic flexible|angular ±0.5°, radial 0.1–0.3 mm per half|up to 10,000,000|very high|high-torque: turbine-generator, rolling mill, ship drive
CU4|disc coupling|metallic flexible|angular ±1°, axial ±2 mm|up to 5,000,000|high (torsionally rigid; flexes axially/angularly)|turbomachinery, compressor trains; maintenance-free; no lubrication
CU5|Oldham coupling|sliding|large radial offset (up to 10% of shaft diameter)|1–10,000|medium|parallel shaft misalignment; instrumentation; low speed
CU6|universal joint (Cardan)|mechanical|angular up to 45° (speed fluctuation at angles >~10°)|up to 500,000|high|automotive driveshaft, industrial shafting, agricultural PTO
CU7|constant-velocity (CV) joint|mechanical|angular up to 50° (constant output speed at all angles)|up to 200,000|high|front-wheel-drive automotive halfshafts; independent suspension
CU8|fluid coupling|hydrodynamic|inherent misalignment absorption|up to 1,000,000 (slip-dependent)|zero (no mechanical connection; slip = speed difference)|soft start; overload protection; conveyor, crusher, fan drives
CU9|torque converter|hydrodynamic|inherent|up to 2,000,000|zero (stall); approaches 1:1 at coupling point|automatic transmission; construction equipment; provides torque multiplication at stall (2:1 to 3:1)
CU10|magnetic coupling|non-contact|large (no mechanical connection)|1–50,000|medium (magnetic spring effect)|hermetic seal (fluid contained without shaft seal); chemical pumps, mixers, hazardous fluids

# seals(id|name|type|motion|pressure_range_bar|speed_limit|media|life_driver|applications)
SL1|O-ring|elastomeric|static or slow dynamic|up to 700 (static); up to 350 (dynamic)|<0.5 m/s (dynamic)|most fluids (material-dependent: Viton, EPDM, Nitrile, PTFE)|extrusion, compression set, chemical attack|universal: hydraulic, pneumatic, flanges, fittings, instrument housings
SL2|lip seal (rotary shaft seal)|elastomeric|rotary|up to 0.5 (standard); up to 5 (pressure lip)|up to 35 m/s peripheral|oil, grease|wear of sealing lip; contamination ingress|shaft sealing: motors, gearboxes, pumps, wheels
SL3|mechanical seal|face seal (hard/soft pair)|rotary|up to 450|up to 100 m/s|liquids (process fluids, water, chemicals)|face wear; thermal distortion; dry running damage|centrifugal pump sealing (replaced packing in most applications); reactor, mixer, compressor
SL4|packing (braided)|compression packing|rotary or reciprocating|up to 250|up to 25 m/s (rotary)|water, steam, mild chemicals|wear; leakage rate increases over time; periodic adjustment|valve stems, older pumps, marine stern tubes; adjustable leakage
SL5|hydraulic rod seal (U-cup)|elastomeric/PTFE|reciprocating linear|up to 700|up to 1 m/s|hydraulic fluid|wear, extrusion at high pressure|hydraulic cylinder rod sealing
SL6|hydraulic piston seal|elastomeric/PTFE|reciprocating linear|up to 700|up to 1 m/s|hydraulic fluid|wear, extrusion|hydraulic cylinder piston sealing (contains pressure behind piston)
SL7|wiper/scraper|elastomeric/PTFE|reciprocating linear|atmospheric (excludes contamination)|up to 1 m/s|external contaminants (dirt, water)|wear; cracking|hydraulic cylinder rod protection; machine way wipers
SL8|gasket (spiral wound)|semi-metallic|static|up to 250|n/a (static)|steam, gases, chemicals|creep, bolt relaxation, thermal cycling|pipe flanges (ASME B16.20); pressure vessel; heat exchanger
SL9|gasket (sheet, compressed fiber)|non-metallic|static|up to 100|n/a|water, air, low-pressure steam, chemicals|creep, degradation|pipe flanges, equipment covers, low-pressure joints
SL10|labyrinth seal|non-contact|rotary|up to 500|unlimited (no contact)|gas (steam, air, process gas)|erosion of teeth; contamination buildup|turbine shaft sealing, compressor interstage, bearing isolators; allows controlled leakage

# fasteners(id|name|type|tensile_strength_class|load_type|preload_method|applications)
FA1|hex bolt + nut|threaded|4.6 to 12.9 (ISO); SAE Grade 2 to Grade 8|tension + shear (clamping force via preload)|torque wrench; turn-of-nut; tension-indicating|general structural, mechanical, pipe flanges
FA2|socket head cap screw|threaded|8.8, 10.9, 12.9|tension (compact head for confined spaces)|torque wrench|machine assembly, fixtures, precision equipment
FA3|stud bolt|threaded both ends|B7 (ASTM A193), B16|tension (flange bolting; double-nutted)|torque or hydraulic tensioner|high-temperature/pressure flanges: refinery, power plant, pressure vessels
FA4|self-tapping screw|threaded (forms own thread)|varies|tension + shear|torque limited (overtorque strips thread)|sheet metal, light assembly, HVAC ductwork
FA5|rivet (solid/blind)|permanent|based on material (aluminum, steel, Monel)|shear (permanent joint)|squeeze (solid) or mandrel pull (blind)|aircraft skin, structural steel, boiler; blind rivets where access from one side only
FA6|weld (fillet/butt)|permanent (fusion)|base + filler metal strength|all (tension, shear, bending, torsion)|heat input + cooling|structural steel, pressure vessels, piping, machinery frames; governed by AWS/ASME codes
FA7|adhesive bond|permanent or semi-permanent|depends on adhesive chemistry (epoxy, acrylic, polyurethane)|shear and peel (poor in peel)|surface preparation + cure time/temperature|composites, electronics, automotive panels, wind turbine blades, thread locking

# springs(id|name|type|load_direction|characteristic|material|applications)
SP1|helical compression spring|coil|axial compression|linear (F = k × x); constant rate|spring steel (music wire, chrome-vanadium, chrome-silicon)|valves, automotive suspension, switches, return mechanisms
SP2|helical extension spring|coil|axial tension|linear; initial tension in free state|spring steel|doors, gates, counterbalances, trampolines
SP3|helical torsion spring|coil|torsional (angular deflection)|torque proportional to angle (T = k_θ × θ)|spring steel, stainless|clothespins, clipboards, hinges, lever-return mechanisms
SP4|leaf spring|flat|bending (transverse load)|approximately linear; multiple leaves for progressive rate|spring steel|truck/trailer suspension, railcar, heavy vehicle
SP5|Belleville washer (disc spring)|disc|axial compression|nonlinear; stackable in series (more deflection) or parallel (more force); can achieve constant force|spring steel, Inconel|bolted joint preload maintenance, valve springs, overload protection; compact axial space
SP6|gas spring|pneumatic cylinder|axial (extension or compression)|nearly constant force over stroke (gas law)|steel cylinder, nitrogen gas fill|vehicle tailgates, furniture, machine guards, hoods; progressive or locking
SP7|torsion bar|bar/tube|torsional|linear (T = G × J × θ / L)|spring steel, titanium|vehicle suspension (front independent), stabilizer bars (anti-roll)

# dampers(id|name|type|principle|force_characteristic|adjustability|applications)
DA1|hydraulic shock absorber (twin-tube)|hydraulic|oil forced through orifice by piston; energy converted to heat|velocity-dependent (F ∝ v or F ∝ v²); compression and rebound rates differ|fixed or manually adjustable (valve shimming)|vehicle suspension, industrial vibration control
DA2|hydraulic shock absorber (monotube)|hydraulic|single tube; gas-charged (floating piston separates oil and nitrogen); higher performance|velocity-dependent; better heat dissipation than twin-tube; less fade|adjustable (often remote reservoir; compression/rebound independent)|performance vehicles, off-road, motorcycle, industrial
DA3|gas strut (damping type)|pneumatic + hydraulic|combined gas spring + hydraulic damping in single unit|nearly constant force + velocity-dependent damping|factory-set (non-adjustable)|vehicle tailgates, machine covers, aviation, medical equipment
DA4|magnetorheological (MR) damper|hydraulic (smart fluid)|MR fluid viscosity changes with magnetic field; real-time adjustable|force = f(current, velocity); millisecond response|continuously variable via electrical current|semi-active suspension (automotive, military), seismic building isolation, prosthetics
DA5|friction damper|mechanical|sliding friction between surfaces; energy dissipated as heat|Coulomb friction (force constant regardless of velocity)|adjustable (bolt preload changes normal force)|structural (seismic bracing), machine tool chatter suppression, door closers
DA6|viscous damper (rotary)|hydraulic|rotor shears viscous fluid (silicone) in housing|torque proportional to rotational speed|fixed (fluid selection sets damping)|engine crankshaft vibration (torsional vibration damper), industrial drives, building dampers
DA7|tuned mass damper|inertial|auxiliary mass on spring/damper tuned to structure's natural frequency; absorbs energy at that frequency|effective in narrow band around tuned frequency|tunable (mass or spring adjustable)|tall buildings (wind sway), bridges, machinery vibration, power lines

# heat_exchangers(id|name|type|flow_arrangement|heat_transfer_area_density|pressure_range_bar|temperature_range_C|applications)
HX1|shell-and-tube|tubular|counterflow, parallel, multi-pass; baffles direct shell-side flow|50–100 m²/m³|up to 300 (shell); up to 1,400 (tubes)|−200 to 800|refinery, chemical, power plant, HVAC; most common industrial type
HX2|plate heat exchanger (gasketed)|plate|counterflow (alternating plate channels)|200–1,000 m²/m³|up to 25 (gasketed)|−35 to 200|HVAC, dairy, brewing, pharma, district heating; compact; easy to clean and expand
HX3|plate heat exchanger (brazed)|plate|counterflow|200–700 m²/m³|up to 45|−195 to 225|refrigeration, solar thermal, hydronic heating; compact; not expandable
HX4|plate heat exchanger (welded)|plate|counterflow|200–700 m²/m³|up to 80|−50 to 400|chemical, aggressive media; higher pressure/temperature than gasketed
HX5|air-cooled heat exchanger (fin-fan)|tubular + finned|crossflow (air over finned tubes; fan-driven)|100–300 m²/m³|up to 200 (tubes)|−50 to 400|refinery overhead condensers, compressor aftercoolers, power plant (where water scarce)
HX6|double-pipe heat exchanger|tubular|counterflow or parallel (pipe-in-pipe)|10–50 m²/m³|up to 300|−200 to 600|small duties, high pressure, pilot plants; simple; easily modified
HX7|spiral heat exchanger|plate (spiral)|true counterflow (single channel per side; self-cleaning)|100–200 m²/m³|up to 25|up to 400|slurry, fibrous media, wastewater; self-cleaning; low fouling
HX8|cooling tower|direct contact|evaporative (water contacts air; latent heat transfer)|very high (direct contact)|atmospheric|ambient to ~45 wet bulb approach|power plant condenser cooling, HVAC, industrial process cooling
HX9|condenser (surface)|tubular|crossflow or multi-pass|50–100 m²/m³|vacuum to 50|cooling water: 15–35; condensing steam/refrigerant: 30–100|steam power plant, refrigeration, chemical process
HX10|economizer / recuperator|tubular or plate|counterflow (exhaust gas → feedwater or combustion air)|50–300 m²/m³|up to 100|200–600 (gas side)|boiler flue gas heat recovery; gas turbine exhaust recovery; furnace air preheat

# piping(id|name|material|pressure_class|temperature_range_C|joining|corrosion_resistance|applications)
PI1|carbon steel pipe (ASTM A106)|ferrous|up to ASME Class 2500 (~430 bar)|−29 to 427|welding (butt, socket), flanged, threaded (small bore)|low (requires coating, lining, or cathodic protection for corrosive service)|general process, steam, water, oil/gas, structural
PI2|stainless steel pipe (304/316)|ferrous (austenitic)|up to Class 2500|−254 to 816|welding (TIG/orbital for high purity), flanged|high (316 > 304 due to molybdenum; pitting resistance)|chemical, pharma, food, cryogenic, marine, high-temperature
PI3|copper pipe/tube (Type K, L, M)|non-ferrous|up to ~30 bar (depends on size and type)|−200 to 200|soldering, brazing, compression fittings, press-connect|good (patina); dezincification in aggressive water if brass fittings|potable water, HVAC refrigerant, medical gas, plumbing
PI4|PVC pipe (Schedule 40/80)|thermoplastic|up to ~16 bar (derates with temperature)|0 to 60|solvent cement, threaded, flanged|excellent (chemical inert to most acids/bases)|water supply, drainage, chemical waste, irrigation, pool
PI5|HDPE pipe (PE100)|thermoplastic|up to ~25 bar (SDR-dependent)|−50 to 60|butt fusion, electrofusion, mechanical|excellent; flexible; impact-resistant|gas distribution, water main, mining slurry, landfill leachate, directional drilling
PI6|fiberglass (FRP/GRP) pipe|composite|up to ~25 bar|−40 to 120|adhesive bonding, mechanical coupling, flanged|excellent (no corrosion)|corrosive chemical service, seawater, cooling water, fume ducts
PI7|ductile iron pipe|ferrous|up to ~40 bar (push-on joint); higher flanged|−20 to 350|push-on (rubber gasket), mechanical joint, flanged|moderate (internal cement or poly lining; external coating)|water main, sewage, fire hydrant supply; buried service
PI8|flexible hose (hydraulic)|rubber + steel braid/spiral|up to 700 (4-spiral)|−40 to 120|crimped end fittings (JIC, ORFS, BSP)|outer cover: abrasion and weather|hydraulic power transmission; vibration isolation; moving connections (excavator, press)
PI9|tubing (instrument, stainless)|ferrous (316SS or alloy)|up to 700 (depends on OD/wall)|−254 to 540|compression fitting (Swagelok-type), orbital weld|high|instrument lines, sampling, analyzer, hydraulic pilot, process sensing

# hydraulic_systems(id|name|components|operating_pressure_bar|fluid|function|applications)
HS1|open-center hydraulic system|HPU + open-center directional valve + actuator + tank|100–250|mineral oil ISO VG 32–68|pump runs constantly; oil flows through valve center to tank when no demand; simple; wastes energy at idle|agricultural equipment, small mobile, utility vehicles
HS2|closed-center (load-sensing) hydraulic system|HPU + variable-displacement pump + LS compensator + proportional valve + actuator + tank|150–350|mineral oil or synthetic|pump adjusts displacement to match load; standby pressure ~20 bar above load; energy-efficient|excavators, modern mobile, industrial presses, injection molding
HS3|closed-circuit (hydrostatic drive)|variable pump + variable motor (bi-directional) + charge pump + heat exchanger|300–500|mineral oil or synthetic|pump and motor connected directly; no directional valve; speed = pump displacement/motor displacement; 4-quadrant operation|track drives (bulldozer, skid-steer), winches, marine propulsion, test stands
HS4|accumulator system|HPU + bladder/piston accumulator + valves + actuator|up to 350 (bladder); up to 700 (piston)|mineral oil or synthetic; nitrogen pre-charge gas|stores energy; smooths pulsations; provides emergency power; absorbs shock|injection molding (fast clamp), press, emergency steering/braking, pulsation dampening
HS5|electrohydraulic servo system|servo valve + hydraulic cylinder or motor + position/force transducer + servo controller + HPU|210–350|clean mineral oil (NAS 7 or better cleanliness)|closed-loop position/force/velocity control; high bandwidth; high stiffness|flight simulators, fatigue test machines, steel rolling gap control, active suspension, CNC

# pneumatic_systems(id|name|components|operating_pressure_bar|medium|function|applications)
PS1|compressed air utility system|compressor + aftercooler + dryer (refrigerant or desiccant) + receiver tank + filter-regulator-lubricator (FRL) + distribution piping|6–10|air (ISO 8573 quality classes)|provides clean dry compressed air for tools, actuators, instruments|factory air, workshops, food/beverage, pharma, packaging
PS2|pneumatic automation system|directional solenoid valves (5/2, 5/3) + cylinders + sensors (reed, proximity) + PLC/valve island|4–8|air (filtered, regulated)|sequence of actuator motions for production automation|pick-and-place, assembly, packaging, sorting, labeling, welding fixtures
PS3|pneumatic conveying system|blower or compressor + rotary valve or blow tank + conveying pipe + filter/cyclone separator + receiver|0.5–3 (positive pressure) or −0.3 to −0.8 (vacuum)|air|transports bulk solids (powder, pellets, granules) through pipeline in air stream|grain handling, cement, flour, plastic pellets, pharmaceutical powder, fly ash

# structural(id|name|type|material|load_type|function|applications)
ST1|I-beam / H-beam (wide flange)|structural steel section|A36, A992 (structural steel)|bending, shear|primary load-bearing member; high section modulus for weight|building frames, bridges, crane runways, machine frames
ST2|hollow structural section (HSS)|structural steel tube|A500 (round, square, rectangular)|axial, bending, torsion|good torsional resistance; aesthetics; compact|columns, trusses, frames, guardrails, mechanical supports
ST3|angle iron (L-section)|structural steel|A36|axial, bending|bracing, frame members, supports|shelving, tank supports, tower legs, equipment frames
ST4|channel (C-section)|structural steel|A36|bending, shear|secondary framing, purlin, equipment base|machinery bases, building secondary structure, racking
ST5|baseplate and anchor bolts|steel plate + bolts (A325, A490, or chemical anchor)|structural steel + concrete|compression, shear, moment|transfers structural loads to foundation|column bases, machine foundations, equipment mounting
ST6|vibration isolator (elastomeric mount)|rubber/neoprene + steel|elastomer + steel|compression + shear (isolates vibration)|reduces vibration transmission from machine to foundation; natural frequency below excitation frequency|HVAC equipment, engines, pumps, compressors, sensitive instruments
ST7|vibration isolator (spring mount)|coil spring + housing|spring steel + steel housing|compression (isolates low-frequency vibration)|lower natural frequency than elastomeric; better for heavy low-RPM machines|large reciprocating compressors, diesel generators, presses
ST8|leveling pad/grout|epoxy or cementitious grout + steel plate|composite|compression|fills gap between machine base and foundation; distributes load; provides precise leveling|all rotating equipment, pumps, compressors, turbines
ST9|strut (compression member)|steel tube or rod|structural steel, aluminum|axial compression|resists compressive loads; bracing|vehicle suspension strut (MacPherson), building bracing, truss web members, aircraft structure
ST10|tie rod (tension member)|steel rod with threaded ends|high-strength steel (4140, B7)|axial tension|resists pull-apart loads; pre-tensioned or reactive|hydraulic press tie rods, tank roof-to-shell, bracing, vehicle steering

# sensors(id|name|measured_variable|principle|range|accuracy|output|applications)
SN1|RTD (Pt100)|temperature|resistance of platinum wire changes linearly with temperature; R = R₀(1 + αT)|−200 to 850°C|±0.1–0.5°C (Class A/B)|4–20 mA, 3/4-wire resistance|process, HVAC, pharma, food (high accuracy, stability)
SN2|thermocouple (Type K)|temperature|Seebeck effect: voltage at junction of two dissimilar metals proportional to temperature|−200 to 1,260°C|±1.5–2.5°C|mV signal → transmitter → 4–20 mA|furnaces, exhaust, high-temperature process, wide range
SN3|pressure transmitter (piezoresistive)|pressure (gauge, absolute, differential)|strain gauge on diaphragm; resistance changes with deformation|0–1 to 0–700 bar|±0.1–0.5% of span|4–20 mA / HART / fieldbus|process, hydraulic, pneumatic, water, HVAC
SN4|pressure switch|pressure (on/off)|diaphragm or bourdon tube actuates microswitch at set point|0.1–1,000 bar|±1–5% of set point|discrete (NO/NC contact)|low-pressure alarm, high-pressure trip, pump control, compressor unloading
SN5|flow meter (electromagnetic)|volumetric flow rate|Faraday's law: voltage induced in conductive fluid moving through magnetic field proportional to velocity|0.01–100,000 m³/h|±0.2–0.5% of reading|4–20 mA / pulse / fieldbus|water, wastewater, chemical, slurry (conductive fluids only; no hydrocarbons)
SN6|flow meter (Coriolis)|mass flow rate + density|vibrating tube: Coriolis force proportional to mass flow causes phase shift; frequency → density|0.001–3,000 t/h|±0.05–0.1% of reading (mass)|4–20 mA / fieldbus|custody transfer, chemical dosing, batching; measures mass directly; insensitive to fluid properties
SN7|flow meter (vortex)|volumetric flow rate|bluff body creates vortex street; vortex frequency proportional to velocity (Strouhal number)|DN15–DN300; Re > 20,000|±0.75–1.5% of reading|4–20 mA / pulse|steam, gas, clean liquids; no moving parts; wide temperature range
SN8|level transmitter (radar)|liquid level|microwave pulse reflected from liquid surface; time of flight → distance|up to 40 m range|±1–3 mm|4–20 mA / HART / fieldbus|tank level, vessel, silo; non-contact; works through vapor, foam
SN9|level switch (float)|liquid level (on/off)|buoyant float on lever or magnetic coupling actuates switch at fixed level|fixed point|±5–25 mm|discrete (NO/NC)|pump on/off control, high-level alarm, condensate drain
SN10|vibration sensor (accelerometer)|acceleration / vibration|piezoelectric crystal generates charge proportional to acceleration|0.5 Hz–20 kHz; ±500 g|±1–5%|charge or voltage (ICP/IEPE) → 4–20 mA or digital|rotating equipment condition monitoring, predictive maintenance, machinery protection
SN11|proximity sensor (inductive)|presence/position (metal target)|oscillating magnetic field dampened by approaching metal target → output switches|0–50 mm sensing distance|±0.01–0.1 mm (analog); sensing point repeatable|discrete (PNP/NPN) or analog 4–20 mA|cylinder position confirmation, limit detection, cam/shaft position, counting
SN12|encoder (rotary, incremental)|angular position / speed|optical or magnetic: disc with patterns; pulses generated as shaft rotates; quadrature for direction|100–10,000,000 pulses/rev|depends on resolution and interpolation|digital pulse (A, B, Z channels); RS-422, SSI, BiSS|motor feedback, spindle speed, conveyor position, robotics
SN13|LVDT (linear variable differential transformer)|linear displacement|AC excitation of primary coil; two secondary coils; core position determines differential voltage|±0.1 to ±500 mm|±0.1–0.5% of full range|AC voltage ratio or DC conditioned (4–20 mA)|hydraulic servo position feedback, turbine valve position, material testing, precision gauging
SN14|load cell (strain gauge)|force / weight|strain gauge bonded to elastic element; deformation → resistance change → bridge output|0.5 kg–5,000,000 kg|±0.02–0.1% of rated capacity|mV/V signal → amplifier → 4–20 mA or digital|weighing scales, hopper/tank weighing, force measurement, material testing
SN15|tachometer (magnetic pickup)|rotational speed|gear tooth passing magnetic sensor generates voltage pulse; frequency = speed × teeth|0–100,000 rpm|±0.1% of reading|pulse frequency|engine speed, turbine speed, pump speed, overspeed trip

# controllers(id|name|type|input|output|function|tuning_parameters|applications)
CT1|PID controller|feedback|process variable (PV) from sensor; set point (SP) from operator/cascade|control output (CO) to actuator (4–20 mA, 0–10 V, digital)|minimizes error (e = SP − PV) using proportional + integral + derivative action|Kp (proportional gain), Ki (integral gain / reset time), Kd (derivative gain / rate time)|temperature, pressure, flow, level control; >90% of industrial process loops
CT2|on/off controller|feedback (bang-bang)|PV from sensor; SP + deadband|discrete output (on or off)|switches output at set point ± deadband; simplest control; oscillates around SP|deadband (hysteresis)|thermostat, level switch pump control, pressure switch compressor loading
CT3|PLC (programmable logic controller)|sequential + logic + PID|discrete inputs (switches, sensors), analog inputs (4–20 mA)|discrete outputs (relays, solenoids), analog outputs (4–20 mA)|executes ladder logic, function blocks, structured text; scan cycle 1–50 ms; deterministic|program-dependent|factory automation, packaging, batch, machine control, safety (SIL-rated PLCs)
CT4|DCS (distributed control system)|supervisory + regulatory|field instruments via I/O cards or fieldbus; operator interface (HMI)|control outputs to field devices; alarms, trends, reports|coordinated control of entire plant; redundant controllers; historian; advanced process control (APC)|site-wide tuning + model predictive control (MPC)|refinery, power plant, chemical, pharmaceutical, water treatment
CT5|VFD (variable frequency drive)|motor speed control|speed/torque command (analog, digital, fieldbus); motor current/voltage feedback|variable-frequency AC to motor (PWM inverter)|adjusts motor speed by changing frequency (n = 120f/P); torque control; energy savings on fans/pumps (cube law)|V/f ratio, slip compensation, vector control tuning, PID (for pump/fan)|pump, fan, compressor, conveyor speed control; soft start; energy savings 20–60% on variable-torque loads
CT6|servo controller|motion control|position/velocity/torque command (trajectory); encoder feedback (position + velocity)|current to servo motor (torque)|closed-loop position/velocity/torque control; trajectory generation; electronic gearing/camming|position loop gain, velocity loop gain, acceleration feedforward, current loop bandwidth|CNC, robotics, pick-and-place, semiconductor, printing, winding
CT7|safety instrumented system (SIS)|safety|safety-critical sensors (pressure, temperature, level, gas, flame)|safety-critical actuators (ESD valves, pump trips, fire/gas suppression)|independent safety layer; detects hazardous condition → executes safe shutdown; SIL 1–4 per IEC 61511|proof test interval, redundancy architecture (1oo1, 1oo2, 2oo3), dangerous failure rate|emergency shutdown, fire and gas, burner management, high-integrity pressure protection
CT8|governor (mechanical/electronic)|speed regulation|shaft speed (centrifugal flyweight or magnetic pickup)|fuel/steam admission valve position|maintains constant speed under varying load; droop or isochronous|droop (%), speed setting, dead band|diesel engine generator, steam turbine, gas turbine; grid frequency regulation

# materials(id|name|type|yield_strength_MPa|tensile_strength_MPa|density_kg_m3|elastic_modulus_GPa|thermal_conductivity_W_mK|max_service_temp_C|corrosion_resistance|applications)
MA1|carbon steel (A36/S275)|ferrous|250|400–550|7,850|200|50|400|low (rusts readily; requires protection)|structural, piping, vessels, machine frames, general fabrication
MA2|alloy steel (4140/4340)|ferrous|655–860 (heat treated)|900–1,100|7,850|205|42|540|low (same as carbon steel)|shafts, gears, bolts, connecting rods, high-strength machine parts
MA3|stainless steel 304 (18-8)|ferrous (austenitic)|205|515|8,000|193|16|870|high (chromium oxide passive layer)|food, pharma, chemical, architectural, general corrosion-resistant
MA4|stainless steel 316|ferrous (austenitic)|205|515|8,000|193|16|870|very high (molybdenum improves pitting/crevice resistance)|marine, chemical, pharma, offshore, chloride environments
MA5|cast iron (gray)|ferrous|—|150–400 (compression strength 3–4× tensile)|7,150|100–120|46|350|moderate (graphite flakes provide some lubricity and corrosion resistance)|engine blocks, pump casings, machine bases, pipe fittings, brake rotors
MA6|ductile iron (nodular)|ferrous|275–620|415–830|7,100|170|36|350|moderate to good|pipe (water, sewage), automotive (crankshafts, gears), heavy machinery
MA7|aluminum alloy (6061-T6)|non-ferrous|276|310|2,700|69|167|150 (strength degrades above)|good (oxide layer); poor in alkaline/galvanic|aerospace, automotive, bicycle, structural, heat sinks, marine
MA8|copper alloy (C36000 brass)|non-ferrous|140|340|8,500|97|115|260|moderate (dezincification in some waters)|fittings, valves, instrument parts, electrical connectors
MA9|bronze (C93200 tin bronze)|non-ferrous|125|240|8,900|76|59|260|good (marine)|bearing bushings, pump wear rings, marine hardware, valve components
MA10|titanium alloy (Ti-6Al-4V)|non-ferrous|880|950|4,430|114|7|315 (long-term)|excellent (oxide passive layer; resistant to seawater, acids)|aerospace, medical implants, chemical processing, marine, high-performance fasteners
MA11|Inconel 625|nickel alloy|490|900|8,440|205|10|980|excellent (extreme corrosion + oxidation resistance)|gas turbine hot section, chemical reactors, subsea, nuclear, flue gas desulfurization
MA12|PTFE (Teflon)|fluoropolymer|10–25 (yield at 10% strain)|20–35|2,150|0.4–0.8|0.25|260 (continuous)|excellent (chemically inert to nearly everything)|seals, gaskets, valve seats, bearings (low friction μ = 0.04–0.10), pipe lining, non-stick coatings
MA13|Nitrile rubber (NBR)|elastomer|—|10–25|1,000|0.003–0.01|0.25|120 (continuous)|good against petroleum oils, fuels, hydraulic fluids; poor against ozone, ketones|O-rings, hydraulic seals, gaskets, hoses, fuel system components
MA14|Viton (FKM)|elastomer|—|10–20|1,800|0.005–0.01|0.2|200 (continuous; 300 short-term)|excellent against fuels, oils, acids, solvents, ozone|high-temperature seals, O-rings, chemical service, aerospace, automotive
MA15|UHMWPE|thermoplastic|22|40|930|0.7|0.4|80|excellent (abrasion, chemical)|wear strips, conveyor guides, chute liners, marine bearings, medical implants
MA16|carbon fiber reinforced polymer (CFRP)|composite|—|500–2,500 (depending on layup)|1,550|70–230 (depending on fiber orientation)|1–7|150–300 (resin-limited)|excellent|aerospace primary structure, F1, wind turbine blades, pressure vessels, sports equipment

# failure_modes(id|name|mechanism|detection|prevention|affected_components)
FM1|fatigue|cyclic stress below yield → crack initiation at stress concentration → propagation → fracture; S-N curve defines life; endurance limit in ferrous only|vibration monitoring, visual inspection (dye penetrant, magnetic particle), ultrasonic|reduce stress concentrations (fillet radii); shot peening; proper design for fatigue life; avoid resonance|shafts, gears, springs, bolts, welds, structural members, blades
FM2|wear (adhesive)|metal-to-metal contact; asperities weld and tear; galling; seizure|dimensional inspection; surface profilometry; debris analysis|lubrication; material selection (dissimilar hardnesses); surface coatings (nitride, chrome, DLC)|bearings, gears, pistons, valve stems, journal surfaces
FM3|wear (abrasive)|hard particles or surface asperities plow softer surface|visual; weight loss; surface profile|filtration; hard facing (hardfacing weld, tungsten carbide); rubber lining; material selection|pump impellers, conveyor surfaces, pipe bends, hydraulic components
FM4|corrosion (uniform)|electrochemical oxidation of metal surface by environment|visual; thickness measurement (UT); corrosion coupons|material selection (SS, alloy); coatings (paint, galvanize, epoxy lining); cathodic protection; inhibitors|piping, vessels, structural steel, heat exchangers, tanks
FM5|corrosion (pitting)|localized attack at passive film breakdown; small surface area → deep penetration|visual; eddy current; UT|material upgrade (316SS, duplex, alloy); chloride control; cathodic protection|stainless steel in chloride; copper alloys in stagnant water
FM6|corrosion (stress corrosion cracking)|tensile stress + corrosive environment → crack initiation and growth; transgranular or intergranular|dye penetrant; acoustic emission; UT|material selection (resistant alloys); stress relief; environmental control (chloride, caustic, H₂S)|austenitic SS in chloride; carbon steel in caustic; copper alloys in ammonia
FM7|cavitation|local pressure drops below vapor pressure → vapor bubble formation → collapse generates high-pressure shock wave and micro-jets → surface damage|noise (characteristic crackling); vibration; visual (pitted surface)|maintain adequate NPSH margin (NPSH_available > NPSH_required + margin); proper pump selection; anti-cavitation trim in valves|pump impellers, valve trims, propellers, hydraulic turbines
FM8|erosion|high-velocity fluid or particles impacting surface → material removal|visual; wall thickness measurement; acoustic|velocity control; erosion-resistant materials (tungsten carbide, ceramics, rubber lining); geometry (avoid sharp bends)|pipe elbows, choke valves, cyclone separators, turbine blades
FM9|overheating|temperature exceeds material capability → creep deformation, oxidation, thermal fatigue, loss of strength|temperature monitoring; metallographic examination; hardness testing|temperature control; material selection for service temperature; thermal insulation; cooling|boiler tubes, turbine blades, engine components, heat exchanger tubes
FM10|vibration-induced failure|resonance, imbalance, misalignment, looseness → excessive dynamic loads → fatigue, fretting, bearing damage|vibration analysis (spectrum, envelope, time waveform); phase analysis|balancing; alignment; avoid operating at natural frequency; damping; stiffness modification|rotating equipment (pumps, compressors, turbines, motors), piping, structures
FM11|seal failure|wear, extrusion, chemical degradation, thermal degradation, improper installation → leakage|visual (leakage); pressure decay test; emissions monitoring|correct material selection; proper installation; surface finish specification; operating within seal limits|mechanical seals, O-rings, gaskets, packing, hydraulic seals
FM12|bearing failure|lubrication failure, contamination, overload, misalignment, fatigue spalling, electrical discharge (VFD-induced)|vibration (high-frequency envelope analysis); temperature; grease/oil analysis; visual (spalling, discoloration)|correct lubrication (type, quantity, interval); alignment; load analysis; shaft grounding (VFD); filtration|all bearing types
FM13|bolt failure|fatigue (cyclic tension), overload (shear/tension), hydrogen embrittlement, corrosion, improper preload|torque audit; visual; ultrasonic bolt measurement|correct preload (torque, tension, turn-of-nut); proper grade selection; anti-corrosion; avoid hydrogen sources|flanged joints, structural connections, machine assembly, foundation bolts

# concepts(id|name|definition|category)
CC1|pressure|force per unit area; P = F/A; SI unit: pascal (Pa); 1 bar = 100,000 Pa|fundamental
CC2|flow rate|volume per unit time (volumetric: m³/s) or mass per unit time (mass: kg/s)|fundamental
CC3|head|energy per unit weight of fluid; H = P/(ρg) + v²/(2g) + z; measured in meters of fluid|fundamental
CC4|torque|rotational force; T = F × r; SI unit: N·m; power = torque × angular velocity (P = Tω)|fundamental
CC5|power|rate of energy transfer; P = F × v (linear) or P = T × ω (rotary); SI unit: watt (W)|fundamental
CC6|efficiency|useful output / total input × 100%; applies to every energy conversion; overall = product of component efficiencies|fundamental
CC7|NPSH (net positive suction head)|absolute pressure at pump suction minus fluid vapor pressure; expressed as head; NPSH_available must exceed NPSH_required to avoid cavitation|pump_design
CC8|specific speed (pump)|N_s = N√Q / H^(3/4); dimensionless index classifying pump impeller type; low N_s → centrifugal; high N_s → axial|pump_design
CC9|system curve|plot of total head loss vs flow rate for piping system; H_system = H_static + H_friction(Q²); intersection with pump curve = operating point|pump_design
CC10|affinity laws (pump/fan)|Q ∝ N; H ∝ N²; P ∝ N³; flow proportional to speed, head to speed squared, power to speed cubed; valid for geometrically similar conditions|pump_design
CC11|Reynolds number|Re = ρvD/μ; ratio of inertial to viscous forces; Re < 2,300 laminar; Re > 4,000 turbulent (pipe flow)|fluid_mechanics
CC12|Bernoulli's principle|P + ½ρv² + ρgz = constant along streamline (inviscid, incompressible, steady)|fluid_mechanics
CC13|Pascal's law|pressure applied to confined fluid is transmitted equally in all directions; basis of hydraulic systems|fluid_mechanics
CC14|bulk modulus|resistance of fluid to compression; hydraulic oil ~1,400–1,700 MPa; water ~2,200 MPa; higher = stiffer system response|fluid_mechanics
CC15|viscosity|resistance to shear flow; dynamic viscosity μ (Pa·s); kinematic viscosity ν = μ/ρ (m²/s or centistokes); ISO VG grades for hydraulic oil|fluid_mechanics
CC16|heat transfer coefficient|h (W/m²·K); rate of heat transfer per unit area per unit temperature difference; depends on fluid properties, flow regime, geometry|thermal
CC17|LMTD (log mean temperature difference)|ΔT_lm = (ΔT₁ − ΔT₂) / ln(ΔT₁/ΔT₂); driving force for heat exchanger sizing; Q = U × A × LMTD|thermal
CC18|fouling factor|additional thermal resistance due to deposits on heat transfer surfaces; reduces effective U; accounted for in design margin|thermal
CC19|natural frequency|f_n = (1/2π)√(k/m); frequency at which system oscillates freely; must avoid operating at or near f_n (resonance)|vibration
CC20|critical speed|rotational speed at which shaft deflection becomes theoretically infinite (resonance with lateral natural frequency); must pass through quickly or operate well above/below|vibration
CC21|alignment|process of positioning rotating machine shafts coaxially; angular and offset misalignment; measured with dial indicators or laser alignment tools; tolerance typically <0.05 mm|maintenance
CC22|balancing|process of adjusting mass distribution on rotor to reduce centrifugal forces at operating speed; single-plane (static) or two-plane (dynamic); residual unbalance per ISO 1940|maintenance
CC23|predictive maintenance|condition-based maintenance using monitoring data (vibration, temperature, oil analysis, thermography, ultrasonics) to predict failure and schedule maintenance before failure occurs|maintenance
CC24|reliability|probability that component/system performs function for specified time under stated conditions; MTBF = mean time between failures; bathtub curve: infant mortality → random → wear-out|design
CC25|redundancy|duplication of critical components or functions to increase system reliability; N+1, 2N, 2N+1 architectures; applied to pumps, power supplies, control systems, safety systems|design
CC26|derating|operating component below maximum rated capacity to extend life; applies to motors (thermal), seals (pressure/temperature), electronics (temperature)|design
CC27|water hammer|pressure transient in piping caused by sudden flow stoppage (valve closure, pump trip); magnitude ΔP = ρcΔv; c = wave speed (~1,000–1,400 m/s in water); mitigation: slow valve closure, surge tanks, relief valves|piping
CC28|stress concentration|local stress amplification at geometric discontinuity (hole, notch, fillet, thread root, weld toe); stress concentration factor K_t; fatigue initiation site|design
CC29|creep|slow plastic deformation under sustained stress at elevated temperature (>~0.3–0.4 × melting point in K); time-dependent; Larson-Miller parameter for life prediction|failure
CC30|friction|resistance to relative motion between surfaces; static > kinetic; Coulomb model: F_f = μN; reduced by lubrication, bearings, coatings|fundamental

# relationships(from|rel|to)
# energy conversion hierarchy
EC1|enables|PM1
EC1|enables|PM2
EC2|enables|PM3
EC3|enables|PM4
EC4|enables|PM5
EC4|enables|PM6
EC4|enables|PM7
EC4|enables|PM8
EC4|enables|PM9
EC5|requires|PM1
EC5|requires|PM3
EC5|requires|PM4
EC6|requires|DM1
EC7|requires|DM1
EC8|requires|DM1
EC9|requires|DM1
EC10|requires|EC4
# prime mover → pump/compressor
PM5|enables|PU1
PM5|enables|CP2
PM5|enables|CP3
PM1|enables|PU6
PM1|enables|PM10
PM8|enables|AC6
PM9|enables|AC6
PM10|enables|AC2
PM10|enables|AC3
PM10|enables|EC6
# pump types → applications
PU1|requires|CC7
PU6|enables|HS2
PU6|enables|HS3
PU6|enables|HS5
PU1|determined_by|CC8
CC9|determines|PU1
CC10|enables|CT5
# hydraulic system hierarchy
HS1|requires|VL16
HS1|requires|PM10
HS2|requires|PU6
HS2|requires|VL17
HS3|requires|PU6
HS3|requires|EC6
HS4|requires|VL16
HS5|requires|VL18
HS5|requires|SN13
HS5|requires|CT6
# pneumatic system hierarchy
PS1|requires|CP2
PS1|requires|VL9
PS2|requires|AC4
PS2|requires|CT3
PS3|requires|CP2
# valve → function mapping
VL1|enables|DM1
VL2|enables|DM1
VL3|enables|DM1
VL7|prevents|FM9
VL8|enables|CC1
VL10|requires|AC8
VL10|requires|CT1
VL16|enables|AC2
VL17|specializes|VL16
VL18|specializes|VL17
# actuator → valve
AC8|enables|VL10
AC9|enables|VL1
AC7|enables|VL3
AC7|enables|VL4
# seal → component
SL1|enables|VL16
SL2|enables|PM5
SL3|enables|PU1
SL5|enables|AC2
SL6|enables|AC2
SL7|enables|AC2
SL8|enables|PI1
SL10|enables|EC3
# bearing → rotating equipment
BE1|enables|PM5
BE2|enables|PM8
BE3|enables|PM1
BE4|enables|PM5
BE8|enables|PM4
BE10|enables|AC6
BE11|enables|CP3
# gear → power transmission
GR1|part_of|DM2
GR2|part_of|DM2
GR7|part_of|DM2
GR8|enables|DM8
GR9|enables|PM8
# coupling → drive train
CU2|enables|PM5
CU3|enables|PM3
CU4|enables|PM3
CU4|enables|PM4
CU6|enables|DM2
CU8|enables|PM5
CU9|enables|PM1
# spring/damper → structural/vibration
SP1|enables|VL7
SP1|enables|ST6
DA1|enables|ST9
DA4|specializes|DA1
DA7|requires|CC19
ST6|prevents|FM10
ST7|prevents|FM10
CC19|enables|DA7
CC20|determined_by|CC19
# fastener → structure
FA1|enables|ST1
FA3|enables|SL8
FA6|enables|PI1
FA6|enables|ST1
# sensor → controller
SN1|enables|CT1
SN2|enables|CT1
SN3|enables|CT1
SN5|enables|CT1
SN6|enables|CT1
SN8|enables|CT1
SN10|enables|CC23
SN12|enables|CT6
SN13|enables|HS5
SN14|enables|CT1
SN15|enables|CT8
# controller hierarchy
CT1|part_of|CT4
CT3|enables|PS2
CT4|enables|CT1
CT5|enables|PM5
CT6|enables|PM8
CT7|prevents|FM9
CT8|enables|PM1
CT8|enables|PM3
# material → component
MA1|enables|ST1
MA1|enables|PI1
MA2|enables|GR2
MA2|enables|BE3
MA3|enables|PI2
MA4|enables|SL3
MA5|enables|PU1
MA7|enables|HX5
MA10|enables|CP3
MA11|enables|EC2
MA12|enables|SL1
MA12|enables|VL3
MA13|enables|SL1
MA13|enables|PI8
MA14|enables|SL1
# failure → component
FM1|prevents|BE1
FM1|prevents|GR2
FM1|prevents|SP1
FM2|prevents|BE8
FM3|prevents|PU1
FM4|prevents|PI1
FM5|prevents|PI2
FM7|prevents|PU1
FM7|determined_by|CC7
FM10|determined_by|CC19
FM11|prevents|SL3
FM12|prevents|BE1
FM13|prevents|FA1
# fundamental concepts
CC1|enables|DM1
CC2|enables|PU1
CC3|enables|PU1
CC4|enables|DM2
CC5|enables|CC6
CC11|determines|CC16
CC12|enables|PU2
CC13|enables|DM1
CC14|enables|HS5
CC15|determines|CC11
CC17|enables|HX1
CC27|determined_by|CC14
CC28|enables|FM1
CC29|enables|FM9
CC30|enables|FM2
# heat exchanger → thermal systems
HX1|part_of|DM3
HX2|part_of|DM3
HX5|part_of|DM3
HX8|part_of|DM3
HX10|enables|EC3
EC10|requires|HX9
# maintenance concepts
CC21|prevents|FM10
CC22|prevents|FM10
CC23|requires|SN10
CC24|requires|CC25
CC26|prevents|FM9

# section_index(section|title|ids)
1|Domains|DM1-DM8
2|Energy Conversion|EC1-EC10
3|Prime Movers|PM1-PM10
4|Pumps|PU1-PU12
5|Compressors|CP1-CP6
6|Valves|VL1-VL18
7|Actuators|AC1-AC9
8|Bearings|BE1-BE11
9|Gears|GR1-GR10
10|Couplings|CU1-CU10
11|Seals|SL1-SL10
12|Fasteners|FA1-FA7
13|Springs|SP1-SP7
14|Dampers|DA1-DA7
15|Heat Exchangers|HX1-HX10
16|Piping|PI1-PI9
17|Hydraulic Systems|HS1-HS5
18|Pneumatic Systems|PS1-PS3
19|Structural Components|ST1-ST10
20|Sensors|SN1-SN15
21|Controllers|CT1-CT8
22|Materials|MA1-MA16
23|Failure Modes|FM1-FM13
24|Fundamental Concepts|CC1-CC30
25|Relationships|all

# decode_legend
id_prefixes: DM=domain, EC=energy_conversion, PM=prime_mover, PU=pump, CP=compressor, VL=valve, AC=actuator, BE=bearing, GR=gear, CU=coupling, SL=seal, FA=fastener, SP=spring, DA=damper, HX=heat_exchanger, PI=piping, HS=hydraulic_system, PS=pneumatic_system, ST=structural, SN=sensor, CT=controller, MA=material, FM=failure_mode, CC=concept
rel_types: enables|requires|prevents|specializes|generalizes|part_of|contains|follows|precedes|instance_of|determined_by|derived_from|composed_of|equivalent_to|extends
notation: _fk=foreign key; ~=approximate; ISO VG=viscosity grade; dN=bore diameter (mm) × speed (rpm); NPSH=net positive suction head; LMTD=log mean temperature difference; COP=coefficient of performance; SIL=safety integrity level; VFD=variable frequency drive; PLC=programmable logic controller; DCS=distributed control system; HMI=human-machine interface; HART=Highway Addressable Remote Transducer; PID=proportional-integral-derivative; DOL=direct on-line; SCR=silicon-controlled rectifier; PWM=pulse width modulation; PTFE=polytetrafluoroethylene; EPDM=ethylene propylene diene monomer; FKM=fluoroelastomer; NBR=nitrile butadiene rubber; UHMWPE=ultra-high molecular weight polyethylene; CFRP=carbon fiber reinforced polymer; DLC=diamond-like carbon; SS=stainless steel; NAS=National Aerospace Standard (contamination class); AWS=American Welding Society; ASME=American Society of Mechanical Engineers; IEC=International Electrotechnical Commission
units: bar (1 bar = 100,000 Pa); MPa (1 MPa = 10 bar); kW (kilowatt); N·m (newton-meter); kN (kilonewton); m³/h (cubic meters per hour); L/min (liters per minute); rpm (revolutions per minute); mm (millimeters); μm (micrometers); m/s (meters per second); °C (degrees Celsius); W/m·K (watts per meter-kelvin); g/cm³ (grams per cubic centimeter); GPa (gigapascal); cP (centipoise); cSt (centistokes); Sv (sverdrup, for flow); mA (milliampere); mV (millivolt)
confidence: material properties are typical/nominal values; ranges given where significant variation exists; manufacturer-specific data may differ; all facts at reference_engineering confidence level
scope: mechanical systems, fluid power, thermal systems, instrumentation, and structural components for industrial, mobile, and infrastructure applications; excludes electronic circuit design, software architecture, and building architectural design; covers component-level through system-level