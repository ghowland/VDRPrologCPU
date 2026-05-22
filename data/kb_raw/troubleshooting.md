# TROUBLESHOOTING — UNIVERSAL METHODOLOGY — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: principles → phases → methods → sensory_checks → fault_classes → diagnostic_patterns → domain_systems → interventions → escalation_triggers → concepts → cross_domain_map → relationships → section_index

# principles(id|principle|rationale|violation_consequence)
PR1|change one variable at a time|multiple simultaneous changes make it impossible to identify which change fixed or worsened the problem|cannot determine cause — wastes time, introduces new faults
PR2|start with the simplest and most likely cause|most failures are mundane — loose connection, dead battery, unplugged cable, dirty filter|wasted hours on complex diagnosis when fix was trivial
PR3|verify the problem exists before diagnosing|reported symptoms may be user error, misperception, or already resolved|diagnosing a non-problem — unnecessary intervention, new damage
PR4|understand normal before diagnosing abnormal|you cannot identify deviation without knowing baseline behavior|misidentifying normal operation as fault, or missing actual fault
PR5|work from known-good toward unknown|start at a point confirmed working, move toward the fault — reduces search space|searching randomly wastes time, may miss fault entirely
PR6|document every change made|undoing failed fixes requires knowing exactly what was changed|cannot restore original state — cascading problems from forgotten changes
PR7|do not destroy evidence before observing it|cleaning, resetting, or restarting before documenting symptoms erases diagnostic information|intermittent fault becomes unreproducible — critical clues lost
PR8|the fault is in the system until proven otherwise|assume the system has a real problem — do not blame the user, environment, or bad luck without evidence|real faults dismissed, problem recurs, trust eroded
PR9|intermittent faults are real faults|a problem that comes and goes has a cause — thermal, mechanical, timing, load-dependent|ignoring intermittent fault allows progression to permanent failure
PR10|the most recent change is the most likely cause|systems that worked before a change and fail after point to that change|overlooking obvious temporal correlation — complex diagnosis of simple cause
PR11|correlation is not causation but is always worth investigating|co-occurring events may share a root cause even if neither causes the other|dismissing useful diagnostic clues, or false confidence in wrong cause
PR12|a system has exactly one root cause per failure mode (usually)|multiple symptoms usually trace to single origin — fix root cause, symptoms resolve|treating symptoms individually — repeated failure, wasted parts
PR13|the fix must explain the symptom|if proposed fix does not logically account for observed symptom, either fix is wrong or diagnosis is incomplete|false fix — problem returns or was never the actual issue
PR14|never assume — measure|assumptions bypass verification — measurement confirms or refutes|misdiagnosis based on expectation rather than evidence
PR15|respect the danger hierarchy: life safety → system preservation → data preservation → convenience|troubleshooting must never create greater harm than the fault|electrocution, data loss, structural collapse, chemical exposure

# phases(id|phase|description|entry_criteria|exit_criteria)
PH1|safety assessment|identify hazards before touching anything — electrical, chemical, mechanical, thermal, biological|problem reported or observed|hazards identified and mitigated, safe to proceed
PH2|symptom gathering|collect all observable symptoms — what, when, where, how often, what changed recently|safe to proceed|complete symptom list documented, timeline established
PH3|problem verification|confirm the reported problem actually exists and is reproducible|symptoms gathered|problem reproduced or confirmed present — if not reproducible, document conditions and monitor
PH4|baseline comparison|compare current behavior against known-good reference — specs, prior readings, identical working system|problem verified|deviation from normal quantified — "it's 40° above normal" not "it's hot"
PH5|hypothesis formation|generate ranked list of possible causes based on symptoms, probability, and accessibility|baseline deviation identified|candidate causes listed from most to least likely
PH6|isolation/testing|systematically test hypotheses using methods (bisection, substitution, signal tracing, etc.)|hypotheses ranked|fault localized to specific component, connection, module, or condition
PH7|root cause identification|determine why the fault occurred — not just what failed but why it failed|fault localized|root cause identified and explains all symptoms (PR13)
PH8|repair/remediation|implement fix for root cause|root cause identified|fix applied — single variable changed (PR1)
PH9|verification|confirm fix resolved original problem — test under same conditions that produced fault|fix applied|original symptom absent, system operates within baseline, no new symptoms
PH10|prevention/documentation|document fault, cause, fix, and preventive measure — update maintenance schedule if applicable|fix verified|record complete, preventive action identified, knowledge captured for future

# methods(id|method|description|when_to_use|domain_applicability)
ME1|power cycle / restart|remove all power, wait, restore — clears volatile state, resets controllers and firmware|first intervention for any system with electrical/digital control|electrical, digital, software, network, embedded mechanical
ME2|visual inspection|look for obvious damage — burns, cracks, leaks, corrosion, disconnection, wear, discoloration|always — first diagnostic action after safety check|all domains
ME3|sensory scan|use all senses — smell for burning/chemicals, listen for abnormal sounds, feel for heat/vibration|early diagnosis — before instruments|all physical domains
ME4|bisection/half-split|divide system in half, test each half — recursively narrow to faulty section|large systems with many components in series — networks, pipelines, wiring runs|all domains — most efficient for serial systems
ME5|substitution/swap|replace suspected component with known-good equivalent — if problem resolves, original was faulty|when spare/known-good available and swap is safe|all domains — definitive when possible
ME6|signal tracing/flow following|follow the signal, fluid, current, or data from input to output — find where it stops or degrades|systems with clear input-to-output path|electrical, plumbing, network, physiological, pneumatic
ME7|isolation/bypass|disconnect suspected component from system — if system works without it, component was the fault|when component can be safely removed without damaging system|all domains
ME8|load testing/stress testing|apply maximum or above-normal load — intermittent faults often appear under stress|intermittent faults, performance degradation, capacity verification|mechanical, electrical, software, network, structural
ME9|comparison to known-good|place identical working system side by side — compare readings, behavior, timing, output|when reference system available|all domains
ME10|rollback/undo|reverse the most recent change — if problem resolves, change was the cause|problem appeared after known change (PR10)|software, configuration, mechanical adjustment
ME11|divide and conquer (dependency tree)|map system as tree of dependencies — test at branch points to isolate which branch contains fault|complex systems with parallel subsystems|software, network, mechanical, physiological
ME12|input/output testing|apply known input, measure output — compare to expected result|any system with measurable I/O|electrical, software, network, physiological (stimulus-response)
ME13|environmental variation|change temperature, humidity, vibration, load, timing — see if fault correlates with environmental factor|intermittent faults suspected environmentally triggered|all physical domains, some software (race conditions)
ME14|temporal correlation|map fault occurrence against time — time of day, duration of operation, calendar date, system uptime|pattern-dependent faults — thermal cycling, scheduled tasks, peak load periods|all domains
ME15|minimum viable system|strip system to minimum components needed to function — add components back one at a time|complex systems with many optional components — isolates which addition causes fault|software, network, electrical, mechanical
ME16|logging/monitoring|instrument the system to record state over time — wait for fault to recur while recording|intermittent faults that cannot be reproduced on demand|software, network, electrical, mechanical, physiological
ME17|tap test/wiggle test|physically disturb components — tap, flex, wiggle connectors — observe if fault appears or clears|suspected loose connection, cracked solder joint, intermittent contact|electrical, mechanical, structural
ME18|thermal profiling|measure temperature distribution across system — infrared camera, thermal probe, or touch|overheating, thermal intermittent, uneven load distribution|electrical, mechanical, structural, physiological
ME19|fluid/pressure testing|pressurize system or introduce tracer fluid — observe where pressure drops or fluid escapes|leak detection in sealed systems|plumbing, pneumatic, hydraulic, HVAC, physiological (contrast dye)
ME20|continuity/resistance testing|measure electrical path integrity — zero resistance = good connection, infinite = break|suspected open circuit, broken wire, bad connector|electrical, network (cable testing)
ME21|reference measurement|measure voltage, pressure, temperature, flow rate, frequency at standard test points — compare to specification|quantifying deviation from normal — PH4|all domains with measurable parameters

# sensory_checks(id|sense|what_to_detect|domain_examples)
SN1|sight — color change|discoloration indicates overheating, chemical reaction, contamination, corrosion|burnt components (brown/black), corroded terminals (green/white), contaminated fluid (dark oil, cloudy coolant), rust (orange), mold (green/black)
SN2|sight — physical damage|cracks, breaks, deformation, swelling, leaks, wear patterns|cracked hoses, bulging capacitors, worn tire tread, cracked masonry, frayed cable, hairline fractures
SN3|sight — displacement|things not where they should be — loose, shifted, disconnected, missing|unseated connector, popped circuit breaker, slipped belt, displaced pipe, dislodged tile
SN4|sight — deposits/residue|accumulation indicates leak, emission, or chemical process|oil stain under car, salt deposits on masonry (efflorescence), dust on fan filter, carbon deposits on spark plug, mineral buildup in pipe
SN5|sight — light/indicator|warning lights, status LEDs, spark, arc, flame where none should be|dashboard warning light, blinking error LED, visible arc at connection, pilot light out
SN6|smell — burning|overheated insulation, friction, electrical short, organic material charring|burning rubber (belt slip), hot plastic (electrical overload), acrid/sharp (PCB burn), sweet (coolant leak on hot engine)
SN7|smell — chemical|fuel, solvent, gas, refrigerant, sewage — substance present where it should not be|gasoline (fuel leak), rotten egg (gas leak/H₂S/battery sulfation), ammonia (refrigerant leak), sewage (drain trap dry or broken)
SN8|smell — biological|decay, mold, infection|musty (mold in HVAC/walls), putrid (dead animal in duct/wall cavity), sweet-sick (anaerobic decay), acetone breath (diabetic ketoacidosis)
SN9|sound — rhythm change|knocking, ticking, grinding, squealing — deviation from normal operating sound|engine knock (detonation/bearing), grinding (worn bearing/gear), squeal (belt slip/brake wear), clicking (relay cycling, hard drive failure)
SN10|sound — absence|expected sound missing — motor not running, fan not spinning, heartbeat absent, flow stopped|silent compressor (failed start), no dial tone (line dead), no breath sounds (obstruction), no water flow (blockage/pump failure)
SN11|sound — intermittent/irregular|sound comes and goes, varies with speed, load, temperature, position|intermittent rattle (loose component), speed-dependent whine (gear/bearing), position-dependent creak (structural joint)
SN12|touch — temperature|hot or cold where it should not be — indicates energy loss, friction, blockage, inflammation|hot wire connection (high resistance), cold radiator section (blocked), hot joint (infection/inflammation), one hot breaker (overloaded circuit)
SN13|touch — vibration|abnormal vibration indicates imbalance, looseness, misalignment, wear|engine vibration (misfire, imbalance), tremor (neurological), loose panel (missing fastener), vibrating pipe (water hammer)
SN14|touch — texture/moisture|wet, sticky, gritty, slimy, rough where should be smooth|oil film (leak), moisture on wall (condensation/penetrating damp), gritty residue (wear particles in fluid), swelling/edema (inflammation)
SN15|touch — resistance/compliance|stiff where should be free, loose where should be firm, soft where should be hard|stiff joint (binding, corrosion, lack of lubrication), loose handle (worn mechanism), spongy brake pedal (air in line), boggy tissue (edema)

# fault_classes(id|class|description|characteristics|examples)
FC1|catastrophic/sudden|complete failure with no warning — system stops functioning instantly|no gradual degradation, often dramatic, may cause secondary damage|blown fuse, snapped cable, shattered component, cardiac arrest, collapsed beam
FC2|progressive/degrading|performance worsens over time — system still functions but below spec|measurable decline, predictable if monitored, accelerates without intervention|worn brake pads, failing capacitor, chronic disease progression, mortar decay, memory leak
FC3|intermittent|fault appears and disappears — may correlate with conditions (thermal, vibration, load, time)|hardest to diagnose, requires logging/monitoring, real fault with variable trigger|loose connection, thermal intermittent solder joint, occasional software crash, episodic arrhythmia, seasonal leak
FC4|latent/hidden|fault exists but has not yet produced symptoms — will manifest under specific conditions|undetectable in normal operation, discovered during testing or when conditions change|backup system never tested, corroded wire adequate until high load, asymptomatic disease, cracked beam bearing normal load
FC5|induced/iatrogenic|fault caused by previous repair or intervention|temporal correlation with recent work, often near repair site|cross-threaded bolt from last service, wrong driver installed during update, medication side effect, mortar bridge from repointing
FC6|design/systemic|fault inherent in design — all instances of system have same vulnerability|affects all units of same model/type, not repairable without redesign|undersized component in all units, software architecture flaw, genetic predisposition, structural design error
FC7|environmental|fault caused by operating conditions — temperature, humidity, vibration, contamination, EMI|correlates with environmental change, may affect multiple systems simultaneously|overheating in summer, corrosion near coast, EMI near transmitter, altitude sickness, frost damage to masonry
FC8|human error/configuration|system is capable but misconfigured, misoperated, or improperly maintained|system works correctly when properly configured — fault is in settings/operation, not hardware|wrong settings, skipped maintenance, improper use, misdiagnosis, incorrect prescription, wrong mortar mix
FC9|cascade/secondary|failure in one component causes failure in dependent components|sequential failure pattern — domino effect, root cause is the first failure|power surge burns multiple components, water leak causes electrical short causes fire, organ failure cascade
FC10|wear-out/end-of-life|component has reached design life — failure is expected and normal|age-correlated, statistical, predictable with maintenance data|bearing wear, battery capacity loss, joint degeneration, mortar weathering, capacitor dry-out

# diagnostic_patterns(id|pattern|description|logic|cross_domain_examples)
DP1|completely dead|system shows zero response to any input — no power, no movement, no output|check power source first, then power delivery path, then power consumer|dead battery, tripped breaker, severed cable, cardiac arrest, failed PSU, unplugged device
DP2|starts then stops|system initiates operation then shuts down — may cycle repeatedly|protection system triggering (overload, overheat, fault detect) — identify what triggers protection|compressor short-cycling (high pressure), engine stalls (fuel delivery), kernel panic on boot, circuit breaker tripping under load
DP3|runs but no output|system operates (motor spins, CPU runs, heart beats) but produces nothing useful|connection between drive and driven component broken — power present but not transmitted|broken belt (motor spins, pump doesn't), software runs but no display (output path), circulation but no oxygenation (PE)
DP4|degraded performance|system works but below spec — slow, weak, noisy, hot, inaccurate|partial blockage, worn component, reduced input, software bloat, deconditioning|clogged filter, worn clutch, slow network, anemia, degraded mortar
DP5|intermittent operation|works sometimes, fails sometimes — no obvious pattern initially|log occurrences with conditions — temperature, load, time, vibration — pattern will emerge|loose connector, thermal crack in solder, race condition in code, episodic vertigo, seasonal roof leak
DP6|wrong output|system produces output but incorrect — wrong value, wrong direction, wrong color, wrong substance|calibration, sensor, configuration, or logic error — input path or processing corrupted|miscalibrated instrument, wrong data from bad sensor, swapped wires (reversed polarity), misdiagnosis, wrong mortar color
DP7|noise/vibration appeared|new sound or vibration that was not present before|something loose, worn, misaligned, resonating, or rubbing|bearing wear, loose panel, unbalanced load, heart murmur (valve issue), rattling pipe
DP8|leak appeared|fluid, gas, air, current, data, or heat escaping where it should not|seal failure, crack, corrosion through, joint failure — trace leak to source (highest point of evidence may not be source)|oil leak, water pipe joint, refrigerant, current leakage to ground, data exfiltration, heat loss through gap
DP9|overheating|temperature above normal operating range|inadequate cooling, excessive load, blocked airflow, failed cooling component, high resistance connection|blocked radiator, dusty heatsink, seized bearing friction, fever (immune response), hot electrical joint
DP10|everything failed at once|multiple unrelated systems fail simultaneously|common cause — power supply, environmental event, shared dependency|lightning strike, flood, power supply failure, server crash affecting all services, stroke affecting multiple functions
DP11|works in safe mode / minimal config|system works when stripped to minimum but fails with full load/config|fault is in something added beyond minimum — use ME15 to identify which|Windows safe mode boot, car runs with accessories off, symptoms resolve with medication withdrawal
DP12|problem appeared after change|system worked, change was made, system now fails|the change is the most likely cause (PR10) — rollback to verify|post-update crash, post-repair new symptom, post-medication side effect, post-renovation leak
DP13|problem affects one zone only|fault contained to one area, room, circuit, segment, organ, region|boundary of fault zone reveals which subsystem contains fault|one room no power (single circuit), one limb weakness (nerve/vascular), one wall damp (local breach), one VLAN down
DP14|problem affects everything|all zones, circuits, functions affected|fault is in shared resource — main supply, trunk line, central controller, systemic condition|main breaker tripped, DNS server down, sepsis (whole-body infection), foundation settlement, master clock failure

# domain_systems(id|domain|components|signal_type|common_fault_modes)
DS1|automotive/mechanical|engine, drivetrain, suspension, brakes, electrical, cooling, fuel, exhaust, body|mechanical force, fluid pressure, electrical current, combustion|wear, leak, blockage, electrical fault, sensor failure, corrosion
DS2|electrical/electronic|power source, conductors, switches, loads, controllers, protection devices|voltage/current (AC or DC)|open circuit, short circuit, high resistance, component failure, overload
DS3|computer hardware|CPU, RAM, storage, PSU, motherboard, cooling, peripherals, connectors|digital signals, DC power, data buses|overheating, component failure, connection fault, PSU failure, storage failure
DS4|software/application|OS, runtime, application code, configuration, data, dependencies, state|data, function calls, events, state transitions|crash, hang, memory leak, logic error, configuration error, dependency failure, corruption
DS5|network|endpoints, cables, switches, routers, firewalls, DNS, DHCP, protocols, services|packets/frames over electrical/optical/radio|cable fault, misconfiguration, DNS failure, congestion, routing error, authentication failure
DS6|plumbing/hydraulic|pipes, valves, pumps, seals, tanks, drains, traps, fixtures|fluid flow and pressure|leak, blockage, corrosion, pump failure, valve failure, water hammer
DS7|HVAC|compressor, condenser, evaporator, fan, filter, thermostat, ductwork, refrigerant|heat transfer, airflow, refrigerant cycle|dirty filter, refrigerant leak, compressor failure, thermostat fault, duct leak
DS8|structural/building|foundation, walls, floors, roof, connections, loads, drainage|compressive/tensile/shear forces, load paths, moisture|cracking, settlement, water penetration, material decay, connection failure, overload
DS9|physiological/medical|organs, vessels, nerves, muscles, bones, immune system, endocrine|electrical impulses, blood flow, biochemical signals, mechanical force|blockage, inflammation, infection, degeneration, trauma, metabolic imbalance, autoimmune
DS10|pneumatic/gas|compressor, lines, valves, actuators, regulators, filters, dryers|compressed gas pressure and flow|leak, contamination (moisture/oil), regulator failure, blockage, seal wear

# interventions(id|intervention|description|risk_level|reversibility|domain_examples)
IV1|power cycle / restart|remove power, wait 10-30 seconds, restore — clears volatile state|very low|fully reversible|reboot computer, cycle breaker, restart engine, power-cycle router
IV2|clean / remove contamination|remove dirt, dust, debris, corrosion, biological growth blocking function|low|reversible (cleaning is additive — removes only contaminant)|clean filter, clean contacts, clean wound, brush efflorescence, clear drain, blow out dust
IV3|tighten / secure|restore fastener or connection to proper torque or engagement|low|reversible|tighten terminal, reseat connector, tighten bolt, reconnect hose clamp
IV4|lubricate|apply appropriate lubricant to reduce friction at moving interface|low|reversible|oil hinge, grease bearing, lubricate lock, synovial injection (medical)
IV5|adjust / calibrate|change setting to bring system within specification — no parts replaced|low|reversible (if original setting documented)|adjust idle speed, calibrate sensor, tune thermostat, adjust medication dosage, align antenna
IV6|reseat / reconnect|remove and reinstall component in same position — clears oxidation, ensures contact|very low|fully reversible|reseat RAM, reseat connector, replug cable, reseat brick on mortar bed
IV7|replace component|remove faulty component, install new identical component|moderate|reversible if old component saved|replace fuse, swap hard drive, replace gasket, replace brick, joint replacement (medical)
IV8|repair component|fix the faulty component itself rather than replacing|moderate to high|depends on repair method|solder broken joint, patch pipe, stitch wound, repoint mortar, patch software
IV9|update / patch|apply newer version of software, firmware, or calibration data|low to moderate|reversible if backup taken (PR6)|OS update, firmware flash, ECU reprogram, update drug protocol
IV10|rollback / restore|return system to previous known-good state|low|reversible (previous state becomes the rollback target)|restore backup, undo update, reverse surgical revision, reinstall old firmware
IV11|bypass / workaround|route around faulty component — system functions but with reduced capability or redundancy|moderate|reversible — temporary measure|jumper around switch, static route around failed router, dietary workaround for enzyme deficiency, temporary shoring
IV12|isolate / disable|remove faulty component from system without replacement — system functions without that feature|low to moderate|reversible|disconnect faulty sensor, disable problematic service, tourniquet (temporary), remove short-circuiting ornament
IV13|rebuild / overhaul|complete disassembly, inspection, replacement of worn parts, reassembly|high|partially reversible|engine rebuild, server rebuild from scratch, full repointing of masonry wall, joint reconstruction
IV14|replace system|entire system replaced — fault not worth diagnosing or repairing|high|irreversible if old system discarded|new computer, new engine, organ transplant, demolish and rebuild wall
IV15|environmental correction|change operating environment rather than system — reduce heat, add ventilation, control humidity, add shielding|low|reversible|add fan, install DPC, add surge protector, humidify/dehumidify, install EMI shielding, move to shade
IV16|preventive maintenance|scheduled intervention before failure — replace wear items, clean, lubricate, test|very low|reversible|oil change, filter replacement, repointing before decay, health screening, backup testing

# escalation_triggers(id|trigger|description|action)
ET1|safety risk|troubleshooting itself creates danger — electrical, chemical, structural, biological|stop immediately — isolate system — call specialist — do not resume without clearance
ET2|beyond skill level|diagnosis requires knowledge, tools, or certification you do not have|stop — document findings so far — hand over to qualified specialist with your notes
ET3|beyond tool level|diagnosis requires instruments, equipment, or access you do not have|document what you know, what you need measured — request specialist with correct tools
ET4|making it worse|each intervention creates new symptoms or damage|stop — do not attempt further fixes — document what was changed (PR6) — call specialist
ET5|cannot reproduce|intermittent fault will not appear during diagnosis|install monitoring/logging (ME16) — capture next occurrence with data — do not guess
ET6|fix does not hold|problem returns after apparently successful repair|root cause not found — re-enter PH7 — consider FC6 (design fault) or FC5 (induced fault)
ET7|multiple systems affected|fault spans beyond single system boundary — shared cause likely|escalate to infrastructure/systems level — individual component diagnosis will not find shared root cause
ET8|time/cost threshold exceeded|diagnosis time or parts cost approaching replacement cost|cost-benefit decision — consider IV14 (replace system) — document everything for replacement team
ET9|legal/regulatory requirement|system is regulated — medical device, electrical code, structural engineering, aviation|stop — engage licensed/certified professional — document everything — do not modify regulated system without authority
ET10|patient/client deteriorating|in medical/physiological troubleshooting: condition worsening during diagnosis|stabilize first — treat most dangerous possible cause even if unconfirmed — diagnose after stable

# concepts(id|name|definition|category)
CO1|root cause|the originating fault that, if removed, prevents the problem from recurring|core concept
CO2|symptom|observable deviation from normal — what the user/operator/patient reports or what is measured|core concept
CO3|sign|objective evidence of fault — measurable, verifiable, not dependent on report|core concept
CO4|failure mode|the specific way a component fails — determines symptoms and downstream effects|core concept
CO5|fault domain|the subsystem boundary containing the fault — narrows search space|core concept
CO6|known-good|a component, system, or state confirmed to be functioning correctly — used as reference|core concept
CO7|mean time between failures (MTBF)|average operating time between failures — statistical measure of reliability|core concept
CO8|single point of failure|component whose failure alone causes system failure — no redundancy|core concept
CO9|defense in depth|multiple independent layers of protection — failure of one layer does not cause system failure|core concept
CO10|signal-to-noise ratio (diagnostic)|ratio of useful diagnostic information to irrelevant data — higher is better|core concept
CO11|shotgunning|replacing multiple components at once hoping one was the fault|anti_pattern
CO12|blame the user|assuming operator error without evidence — dismissing reported symptoms|anti_pattern
CO13|warranty void|continuing to disassemble beyond your skill/authority, damaging evidence or voiding coverage|anti_pattern
CO14|infinite loop diagnosis|repeatedly testing same thing expecting different results — not advancing through hypotheses|anti_pattern
CO15|fix the symptom|addressing visible symptom without identifying root cause — problem recurs|anti_pattern
CO16|assume the worst first|jumping to most expensive/complex diagnosis before checking simple causes|anti_pattern
CO17|cargo cult fix|applying a fix that worked on a different problem without understanding why it worked|anti_pattern
CO18|parts cannon|ordering and installing parts based on guesses rather than diagnosis|anti_pattern
CO19|tunnel vision|fixating on one hypothesis and ignoring contradicting evidence|anti_pattern
CO20|undocumented change|making changes during troubleshooting without recording them|anti_pattern

# cross_domain_map(id|generic_step|mechanical|electrical|software|network|physiological|structural)
XD1|power cycle / restart|turn off engine, wait, restart|cycle breaker / unplug and replug|reboot / restart service|power-cycle switch/router|rest / sleep / reset circadian|n/a — structures have no restart (remove and reapply load)
XD2|check power / energy source|fuel level, battery charge|voltage at outlet, battery voltage|PSU status, power LED|PoE check, UPS status|pulse, blood pressure, blood glucose|n/a — load is continuous (gravity)
XD3|check connections|hose clamps, belt tension, fasteners|terminal tightness, plug seating, wire continuity|cable seating, connector pins, solder joints|patch cable, port link light, fiber connector|joint integrity, ligament continuity, nerve conduction|mortar joints, wall ties, structural connections
XD4|visual inspection|leaks, cracks, wear, corrosion, discoloration|burns, swelling, corrosion, discoloration, arc marks|bulging capacitors, burnt chips, broken pins, dust buildup|damaged cable, bent pin, dirty fiber end, LED status|skin color, swelling, deformity, wound, rash|cracking, displacement, staining, efflorescence, spalling
XD5|smell check|burning rubber/oil, fuel leak, coolant (sweet), exhaust in cabin|burning insulation (acrid), ozone (arc), hot metal|burning electronics, hot plastic|burning cable (rare)|infection (sweet/putrid), ketones (fruity), GI bleed (metallic)|damp/musty (moisture), sulfur (gas leak)
XD6|listen|knock, squeal, grind, hiss, rattle, tick|hum, buzz, arc crack, relay click, transformer whine|fan noise, click of death (HDD), coil whine, silence (fan stopped)|no link tone, crackling (bad cable), interference|heart sounds, breath sounds, bowel sounds, joint crepitus|creak, crack, drip, wind whistle through gap
XD7|feel / touch|vibration, heat, looseness, stiffness|hot connection, vibrating transformer|hot component, excessive case heat|hot switch, warm cable at fault|temperature, pulse, swelling, tenderness, crepitus|damp, loose, crumbling mortar, hot surface
XD8|clean / remove obstruction|replace filter, clear blockage, clean contacts|clean terminals, clear ventilation|blow dust from heatsink, clean contacts|clean fiber end, clear port|clear airway, drain abscess, remove obstruction|clear drainage, repoint joints, remove biological growth
XD9|tighten / secure|torque bolts, adjust belt, clamp hoses|tighten terminals, secure wire nuts, crimp connectors|reseat cards, reseat cables, tighten standoffs|reseat patch cables, secure fiber, tighten rack screws|splint fracture, suture wound, stabilize spine|repoint joints, reset displaced units, install ties
XD10|substitute / swap|swap with known-good part|swap component, try different outlet|swap RAM stick, try different cable, swap PSU|swap cable, try different port, swap switch|change medication, donor organ, prosthetic|replace unit, sister (reinforce beside) failing member
XD11|isolate / bypass|disconnect component, run without it|disconnect load from circuit, test circuit alone|boot in safe mode, disable service, remove plugin|bypass switch, direct connection, test segment alone|tourniquet, nerve block, dietary elimination|shore and remove section, temporary support
XD12|measure / quantify|pressure gauge, temperature, rpm, timing|multimeter (V, A, Ω), oscilloscope, clamp meter|diagnostic software, performance monitor, SMART data|ping, traceroute, packet capture, signal strength|thermometer, blood test, imaging, ECG, spirometry|level, plumb, crack gauge, moisture meter, load test
XD13|trace / follow path|follow hose from source to destination|trace wire from source to load|trace code execution, follow call stack, trace log|traceroute, follow cable, trace VLAN|angiogram, nerve conduction study, barium swallow|follow load path from roof to foundation, trace crack
XD14|divide in half|test midpoint of linkage/piping run|test midpoint of wiring run|binary search of code/config, bisect commits|test midpoint switch in path|test mid-level of physiological system|test mid-height of wall, mid-span of beam
XD15|stress test|load engine to full power, brake test, endurance run|apply maximum rated load, measure voltage/temp|benchmark, load testing tool, memory stress test|flood ping, bandwidth saturation test|exercise stress test, glucose tolerance test|proof load test, wind load simulation
XD16|check most recent change|what was last repaired/adjusted/replaced|what was last wired/connected/updated|what was last deployed/updated/configured|what was last changed in config/topology|what medication/activity/diet changed|what was last modified/repaired/loaded

# relationships(from|rel|to)
# phase sequence
PH1|enables|PH2
PH2|enables|PH3
PH3|enables|PH4
PH4|enables|PH5
PH5|enables|PH6
PH6|enables|PH7
PH7|enables|PH8
PH8|enables|PH9
PH9|enables|PH10
# principles → phases they govern
PR1|constrains|PH6,PH8
PR2|constrains|PH5
PR3|constrains|PH3
PR4|constrains|PH4
PR5|constrains|PH6
PR6|constrains|PH6,PH8,PH10
PR7|constrains|PH2,PH3
PR8|constrains|PH3
PR9|constrains|PH5,PH6
PR10|constrains|PH5
PR13|constrains|PH7,PH9
PR14|constrains|PH4,PH6
PR15|constrains|PH1
# methods → phases where used
ME1|implements|PH6,IV1
ME2|implements|PH2,PH3
ME3|implements|PH2,PH3
ME4|implements|PH6
ME5|implements|PH6
ME6|implements|PH6
ME7|implements|PH6
ME8|implements|PH6
ME9|implements|PH4
ME10|implements|PH6,IV10
ME11|implements|PH6
ME12|implements|PH6
ME13|implements|PH6
ME14|implements|PH5,PH6
ME15|implements|PH6
ME16|implements|PH6,ET5
ME17|implements|PH6
ME18|implements|PH6
ME19|implements|PH6
ME20|implements|PH6
ME21|implements|PH4
# methods → principles they implement
ME4|implements|PR5
ME5|implements|PR14
ME10|implements|PR10
ME15|implements|PR2
ME21|implements|PR14
# sensory checks → methods and phases
SN1-SN5|implements|ME2
SN6-SN8|implements|ME3
SN9-SN11|implements|ME3
SN12-SN15|implements|ME3
ME2|implements|PH2
ME3|implements|PH2
# diagnostic patterns → methods for resolution
DP1|requires|ME6,ME20,ME21
DP2|requires|ME8,ME16
DP3|requires|ME6,ME7
DP4|requires|ME21,ME8,ME18
DP5|requires|ME13,ME14,ME16,ME17
DP6|requires|ME12,ME5
DP7|requires|ME17,ME18,ME3
DP8|requires|ME6,ME19
DP9|requires|ME18,ME2,IV2,IV15
DP10|requires|ME11,ME21
DP11|requires|ME15
DP12|requires|ME10
DP13|requires|ME4,ME7
DP14|requires|ME11,ME21
# fault classes → diagnostic patterns (typical presentations)
FC1|manifests_as|DP1,DP10
FC2|manifests_as|DP4,DP7
FC3|manifests_as|DP5
FC4|manifests_as|DP11
FC5|manifests_as|DP12
FC6|manifests_as|DP4,DP6
FC7|manifests_as|DP5,DP9
FC8|manifests_as|DP6,DP11
FC9|manifests_as|DP10
FC10|manifests_as|DP4,DP1
# interventions → phases
IV1-IV6|implements|PH8
IV7-IV8|implements|PH8
IV9-IV10|implements|PH8
IV11-IV12|implements|PH8
IV13-IV14|implements|PH8
IV15|implements|PH8
IV16|implements|PH10
# intervention ordering (least to most invasive)
IV1|precedes|IV2
IV2|precedes|IV3
IV3|precedes|IV4
IV4|precedes|IV5
IV5|precedes|IV6
IV6|precedes|IV7
IV7|precedes|IV8
IV8|precedes|IV13
IV13|precedes|IV14
# escalation triggers → phases
ET1|gates|PH1
ET2|gates|PH6
ET3|gates|PH6
ET4|gates|PH8
ET5|gates|PH6
ET6|gates|PH7
ET7|gates|PH6
ET8|gates|PH8
ET9|gates|PH8
ET10|gates|PH8
# anti-patterns → principles they violate
CO11|violates|PR1
CO12|violates|PR8
CO13|violates|PR15,ET2
CO14|violates|PR5
CO15|violates|PR12
CO16|violates|PR2
CO17|violates|PR13
CO18|violates|PR1,PR14
CO19|violates|PR11
CO20|violates|PR6
# anti-patterns → correct alternatives
CO11|anti_pattern_of|ME5
CO12|anti_pattern_of|PR8
CO15|anti_pattern_of|CO1
CO16|anti_pattern_of|PR2
CO17|anti_pattern_of|PR13
CO18|anti_pattern_of|ME4,ME5
CO19|anti_pattern_of|PH5
CO20|anti_pattern_of|PR6
# cross-domain map → methods
XD1|implements|ME1,IV1
XD2|implements|ME21
XD3|implements|ME2,ME20
XD4|implements|ME2
XD5|implements|ME3,SN6,SN7,SN8
XD6|implements|ME3,SN9,SN10,SN11
XD7|implements|ME3,SN12,SN13,SN14,SN15
XD8|implements|IV2
XD9|implements|IV3
XD10|implements|ME5,IV7
XD11|implements|ME7,IV12
XD12|implements|ME21
XD13|implements|ME6
XD14|implements|ME4
XD15|implements|ME8
XD16|implements|ME10,PR10
# domain systems → common diagnostic patterns
DS1|exhibits|DP1-DP9
DS2|exhibits|DP1-DP10,DP13,DP14
DS3|exhibits|DP1-DP7,DP9-DP12
DS4|exhibits|DP2-DP6,DP10-DP12
DS5|exhibits|DP1,DP3-DP5,DP10,DP13,DP14
DS6|exhibits|DP1,DP3,DP4,DP8
DS7|exhibits|DP1-DP4,DP9
DS8|exhibits|DP4,DP7,DP8,DP13
DS9|exhibits|DP1-DP9,DP13,DP14
DS10|exhibits|DP1,DP4,DP8
# cross-references to MASONRY and ARCHITECTURE compactions
DS8|cross_ref|SS2,EL13,WT1-WT15,DF1-DF18
IV2|cross_ref|TQ11,TQ16
IV8|cross_ref|TQ10,TQ11
ME2|cross_ref|SN1-SN5,DF1-DF18

# section_index(section|title|ids)
1|Universal Principles|PR1-PR15
2|Troubleshooting Phases|PH1-PH10
3|Diagnostic Methods|ME1-ME21
4|Sensory Checks|SN1-SN15
5|Fault Classification|FC1-FC10
6|Diagnostic Patterns|DP1-DP14
7|Domain Systems|DS1-DS10
8|Interventions|IV1-IV16
9|Escalation Triggers|ET1-ET10
10|Core Concepts and Anti-Patterns|CO1-CO20
11|Cross-Domain Comparison Map|XD1-XD16

# decode_legend
id_prefixes: PH=phase, PR=principle, ME=method, SN=sensory_check, DS=domain_system, FC=fault_class, DP=diagnostic_pattern, IV=intervention, ET=escalation_trigger, CO=concept, XD=cross_domain_map
rel_types: enables|requires|implements|constrains|gates|manifests_as|violates|anti_pattern_of|precedes|exhibits|cross_ref|component_of
cross_ref_prefixes: SS=structural_system, EL=element, WT=wall_type, DF=defect, TQ=technique, SN=sensory_check (from MASONRY and ARCHITECTURE compactions)
category_values: core_concept|anti_pattern (in concepts table)
risk_levels: very_low|low|moderate|high (in interventions table)
reversibility_values: fully_reversible|reversible|partially_reversible|irreversible
phase_convention: phases are sequential but may loop — PH6→PH5 when hypothesis fails, PH9→PH5 when fix fails
confidence: generated from LLM weights — reflects established diagnostic methodology across engineering, IT, medical, and trade disciplines

# relation_mapping(doc_rel|canonical_rel|notes)
enables|enables|exact match
requires|requires|exact match
implements|implements|exact match
constrains|constrains|exact match
gates|controls|escalation trigger gates phase = controls access to phase
manifests_as|indicates|fault class manifests as diagnostic pattern = indicates that pattern
violates|violates|exact match
anti_pattern_of|anti_pattern_of|exact match
precedes|precedes|exact match
exhibits|indicates|domain system exhibits diagnostic pattern = indicates that pattern
cross_ref|references|cross-domain link to related entity = references
component_of|part_of|exact semantic match
