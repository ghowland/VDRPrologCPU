# ELECTRONICS: TAXONOMY, FOUNDATIONS, AND DOMAIN MINIMUMS — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: domains → fundamentals → passive_components → semiconductor_devices → active_components → optoelectronics → power_electronics → signal_types → circuit_topologies → filters → amplifier_topologies → oscillators → modulation → digital_foundations → logic_families → memory → microcontrollers → communication_interfaces → power_supply → pcb → test_equipment → units_constants → failure_modes → safety → concepts → relationships → section_index → decode_legend

# domains(id|name|definition|frequency_range|voltage_range|key_concerns)
DM1|DC circuits|steady-state circuits with constant voltage/current; resistive networks; battery systems|0 Hz|mV to kV|Ohm's law, Kirchhoff's laws, power dissipation, voltage division
DM2|analog circuits|continuous-time signal processing; amplification, filtering, mixing, modulation|DC to ~1 GHz (conventional); higher in RF/microwave|μV to kV|noise, bandwidth, linearity, impedance matching, stability
DM3|digital circuits|discrete-state logic (binary 0/1); combinational and sequential; computation|DC to ~10 GHz (modern CMOS clock)|0.8–5 V (logic levels); 1.0–1.8 V (modern CMOS)|timing (setup, hold, propagation delay), noise margin, power-delay product, signal integrity
DM4|RF and microwave|electromagnetic wave propagation in circuits; transmission lines; antennas; radar|30 MHz–300 GHz|mV to kV (power amplifiers)|impedance matching (50 Ω/75 Ω), S-parameters, return loss, transmission line effects, skin effect
DM5|power electronics|conversion and control of electrical power; AC-DC, DC-DC, DC-AC, AC-AC|DC to ~1 MHz (switching)|V to MV (HVDC)|efficiency, thermal management, switching losses, EMI, magnetics design
DM6|embedded systems|microcontroller/microprocessor-based systems; firmware; real-time; sensor/actuator interface|varies (system clock kHz to GHz)|1.8–5 V (logic); sensor interface varies|memory constraints, real-time deadlines, power consumption, peripheral configuration, ISR latency
DM7|instrumentation|precision measurement of electrical and physical quantities; data acquisition; calibration|DC to ~100 MHz (typical DAQ)|nV to kV (measured signals)|accuracy, resolution, noise floor, common-mode rejection, calibration traceability
DM8|electromagnetic compatibility (EMC)|control of electromagnetic emissions and susceptibility; conducted and radiated|9 kHz–40 GHz (regulatory range)|μV to V (emission limits)|emissions (CE, RE), immunity (ESD, EFT, surge), filtering, shielding, grounding, regulatory compliance (FCC, CE, CISPR)

# fundamentals(id|name|symbol|definition|unit|formula|notes)
FN1|voltage (electric potential difference)|V|energy per unit charge between two points; work done moving charge through electric field|volt (V)|V = W/Q = IR|also called EMF when source; potential difference when load
FN2|current|I|rate of charge flow past a point; conventional current: positive to negative; electron flow: negative to positive|ampere (A)|I = Q/t = V/R|DC: steady; AC: time-varying
FN3|resistance|R|opposition to current flow in conductor; dissipates energy as heat|ohm (Ω)|R = V/I = ρL/A|resistivity ρ depends on material and temperature; R increases with temperature in metals (PTC)
FN4|capacitance|C|ability to store charge; charge stored per unit voltage across plates|farad (F)|C = Q/V = εA/d|energy stored: E = ½CV²; opposes change in voltage; i = C(dv/dt)
FN5|inductance|L|ability to store energy in magnetic field; opposes change in current|henry (H)|V = L(di/dt); L = NΦ/I|energy stored: E = ½LI²; opposes change in current
FN6|impedance|Z|complex opposition to AC current; combines resistance and reactance|ohm (Ω)|Z = R + jX; |Z| = √(R² + X²)|X_C = −1/(ωC); X_L = ωL; phase angle φ = arctan(X/R)
FN7|power (electrical)|P|rate of energy conversion or dissipation|watt (W)|P = VI = I²R = V²/R (DC); P = VIcosφ (AC real power)|apparent power S = VI (VA); reactive power Q = VIsinφ (VAR); power factor = cosφ
FN8|frequency|f|number of complete cycles per second of periodic signal|hertz (Hz)|f = 1/T; ω = 2πf|T = period; ω = angular frequency (rad/s)
FN9|Ohm's law|—|voltage across conductor proportional to current through it for constant resistance|—|V = IR|linear relationship; applies to ohmic materials; foundation of DC circuit analysis
FN10|Kirchhoff's current law (KCL)|—|sum of currents entering a node equals sum leaving; ΣI_in = ΣI_out|—|ΣI = 0 at node|conservation of charge
FN11|Kirchhoff's voltage law (KVL)|—|sum of voltage drops around any closed loop equals zero; ΣV = 0|—|ΣV_rise = ΣV_drop|conservation of energy
FN12|Thevenin's theorem|—|any linear two-terminal network can be replaced by voltage source V_th in series with impedance Z_th|—|V_th = open-circuit voltage; Z_th = V_th / I_sc|simplifies complex networks for load analysis
FN13|Norton's theorem|—|any linear two-terminal network can be replaced by current source I_n in parallel with impedance Z_n|—|I_n = short-circuit current; Z_n = Z_th|dual of Thevenin
FN14|superposition|—|in linear circuit with multiple sources, response to each source calculated independently then summed; nonlinear components violate|—|—|sources zeroed: voltage source → short; current source → open
FN15|maximum power transfer|—|maximum power delivered to load when load impedance equals conjugate of source impedance; Z_L = Z_s*|—|P_max = V_th²/(4R_th)|50% efficiency at max power transfer; not optimal for power delivery (want high η)
FN16|time constant|τ|characteristic time of first-order circuit response; RC circuit: τ = RC; RL circuit: τ = L/R|seconds (s)|τ = RC or τ = L/R|63.2% of final value in 1τ; 99.3% in 5τ
FN17|resonance|—|frequency at which inductive and capacitive reactances cancel; impedance purely resistive; energy oscillates between L and C|—|f₀ = 1/(2π√(LC))|series resonance: minimum impedance; parallel resonance: maximum impedance; Q factor determines bandwidth
FN18|Q factor (quality factor)|Q|ratio of energy stored to energy dissipated per cycle; measures sharpness of resonance|dimensionless|Q = f₀/BW = ωL/R = 1/(ωCR)|high Q → narrow bandwidth, low loss; low Q → broad bandwidth, high damping
FN19|skin effect|—|AC current concentrates near conductor surface at high frequencies; effective cross-section decreases → resistance increases|—|δ = √(2ρ/(ωμ))|skin depth δ: copper at 1 MHz → ~66 μm; at 1 GHz → ~2.1 μm; relevant above ~10 kHz
FN20|decibel|dB|logarithmic ratio unit; power: dB = 10log₁₀(P₂/P₁); voltage: dB = 20log₁₀(V₂/V₁)|dimensionless|—|+3 dB = 2× power; +6 dB = 2× voltage; +10 dB = 10× power; +20 dB = 10× voltage

# passive_components(id|name|symbol|function|key_parameters|construction_types|value_range|tolerance_range|failure_modes|applications)
PC1|resistor|R|limits current; voltage division; biasing; current sensing; pull-up/pull-down; termination|resistance (Ω), power rating (W), temperature coefficient (ppm/°C), voltage rating|thick film (SMD), thin film, metal film, wire-wound, carbon composition, shunt (current sense)|1 mΩ–100 GΩ|±0.01% (precision) to ±20% (carbon)|open circuit (most common); drift; solder joint failure|everywhere: biasing, feedback, voltage division, current limiting, sensing
PC2|capacitor|C|stores charge; blocks DC passes AC; filtering; decoupling; energy storage; timing|capacitance (F), voltage rating, ESR, ESL, dissipation factor, ripple current rating, dielectric type|ceramic (MLCC: C0G/NP0, X7R, X5R, Y5V), aluminum electrolytic, tantalum, film (polyester, polypropylene), supercapacitor|0.1 pF–10,000 F (supercap)|±1% (C0G) to ±20/−80% (Y5V)|short circuit (tantalum, electrolytic); capacitance loss; ESR increase; electrolyte dry-out|decoupling, filtering, timing, energy storage, coupling, snubbing, power factor correction
PC3|inductor|L|stores energy in magnetic field; opposes current change; filtering; energy storage in SMPS|inductance (H), DC resistance (DCR), saturation current (I_sat), SRF (self-resonant frequency), core material|air core, ferrite core (drum, toroid, shielded), iron powder, laminated, planar|1 nH–100 H|±1% to ±20%|saturation (inductance drops); core loss (heat); winding failure; DCR increase|SMPS (energy storage), EMI filtering, RF tuning, chokes, impedance matching
PC4|transformer|T|transfers AC energy between circuits via magnetic coupling; voltage/current scaling; isolation|turns ratio (N₁:N₂), VA rating, frequency range, leakage inductance, magnetizing inductance, isolation voltage, regulation|laminated iron core (50/60 Hz), ferrite core (kHz–MHz), toroidal, planar, pulse|turns ratio 1:1 to 1:1000+; power: mW to GW|—|core saturation; winding failure; insulation breakdown; core loss|power supply isolation, voltage step-up/down, impedance matching, signal coupling, gate drive
PC5|crystal (quartz)|XTAL|piezoelectric resonator; provides precise frequency reference|nominal frequency, frequency tolerance (ppm), load capacitance, ESR, aging (ppm/yr), temperature stability|AT-cut (most common), tuning fork (32.768 kHz for RTC), SC-cut (high stability)|1 kHz–200 MHz (fundamental); overtone to 1 GHz|±5 to ±100 ppm (initial); ±0.5 ppm (TCXO); ±0.01 ppm (OCXO)|aging; mechanical shock; contamination|clock source for MCU, FPGA, communication, RTC, frequency standard
PC6|fuse|F|overcurrent protection; sacrificial element melts and opens circuit at rated current × time|rated current, voltage rating, breaking capacity, time-current characteristic (fast-blow, slow-blow)|glass tube, ceramic tube, blade (automotive), SMD, HRC (high rupture capacity)|mA to kA|±10–20% (blow time)|open circuit (by design); nuisance blowing (aging, inrush)|circuit protection, equipment protection, safety (UL/IEC rated)
PC7|relay|K|electromechanically switches circuit; coil drives armature to open/close contacts|coil voltage, contact rating (A/V), contact configuration (SPST, SPDT, DPDT), coil resistance, operate/release time|electromagnetic (general purpose), reed relay (fast, low power), solid-state relay (SSR: semiconductor-based)|contact: mA to 3,000 A; coil: 3–48 V DC or 12–240 V AC|—|contact welding; coil burnout; mechanical wear (limited to ~10⁵–10⁷ operations)|power switching, motor control, safety isolation, automotive, PLC output, signal routing
PC8|connector|J/P|provides separable electrical connection between circuits, boards, cables, or devices|current rating, voltage rating, contact resistance (mΩ), insulation resistance, mating cycles, pin count|PCB header/socket, D-sub, USB, RJ45, circular (MIL), RF (SMA, BNC, N), terminal block, ribbon, card-edge|1–1,000+ pins|—|contact corrosion; fretting; mechanical fatigue; insulation failure|board-to-board, cable-to-board, cable-to-cable, I/O, power, RF, data
PC9|potentiometer (variable resistor)|R_var|adjustable resistance; user-settable voltage division or gain trim|resistance range, taper (linear B, logarithmic A), power, resolution, number of turns|carbon, cermet, wire-wound, conductive plastic; single-turn or multi-turn|10 Ω–10 MΩ|±5–20% (total); ±0.1% (multi-turn setting)|wiper wear; noise; intermittent contact|volume control, calibration trim, feedback adjustment, joystick

# semiconductor_devices(id|name|symbol|type|key_parameters|mechanism|applications)
SD1|silicon diode (rectifier)|D|PN junction|V_F (forward voltage ~0.6–1.1 V), V_R (reverse voltage), I_F (forward current), t_rr (reverse recovery time)|P-doped and N-doped silicon form depletion region; forward bias: current flows; reverse bias: blocks (until breakdown)|rectification, clamping, protection, voltage reference (zener), freewheeling
SD2|Schottky diode|D|metal-semiconductor junction|V_F ~0.15–0.45 V (lower than silicon); fast switching (no minority carrier storage); V_R limited (~100 V typical)|metal-semiconductor barrier; majority carrier device; no reverse recovery charge|high-frequency rectification, SMPS, RF detection/mixing, OR-ing, clamping
SD3|Zener diode|D|PN junction (reverse breakdown)|V_Z (zener voltage 2.4–200 V), I_ZT (test current), Z_ZT (dynamic impedance), P_D (power dissipation)|controlled reverse breakdown (zener < 5 V: quantum tunneling; > 5 V: avalanche); voltage constant across wide current range|voltage regulation, voltage reference, overvoltage clamping, level shifting
SD4|LED (light-emitting diode)|LED|PN junction (direct bandgap)|V_F (1.8–3.5 V depending on color), I_F (typical 5–350 mA), wavelength (nm), luminous intensity (mcd/lm), viewing angle|forward-biased junction in direct-bandgap semiconductor (GaAs, GaN, InGaN) → electron-hole recombination emits photon|indication, illumination, display (7-segment, matrix, backlight), optical communication, sensing
SD5|photodiode|PD|PN or PIN junction|responsivity (A/W), dark current, spectral range (nm), bandwidth (Hz), NEP (noise equivalent power)|reverse-biased junction; incident photon creates electron-hole pair → photocurrent proportional to light intensity|optical receivers (fiber), light measurement, position sensing, medical (pulse oximeter)
SD6|bipolar junction transistor (NPN)|Q|NPN (two PN junctions)|h_FE (current gain β, 20–1,000), V_CE(sat), f_T (transition frequency), I_C(max), P_D(max)|base current controls collector current; I_C = βI_B; three regions: cutoff, active (linear), saturation|switching, amplification (common emitter/base/collector), current source, discrete logic
SD7|bipolar junction transistor (PNP)|Q|PNP|same parameters as NPN; complementary to NPN|emitter current flows when base pulled below emitter; P-type emitter, N-type base, P-type collector|high-side switching, complementary push-pull stages, level shifting
SD8|MOSFET (N-channel enhancement)|Q|field-effect transistor|V_GS(th) (threshold 1–5 V), R_DS(on) (mΩ–Ω), I_D(max), V_DS(max), Q_g (gate charge), C_iss/C_oss/C_rss|gate voltage creates channel in P-type body between source and drain; I_D controlled by V_GS; voltage-driven (no DC gate current)|power switching (SMPS, motor drive, inverter), analog switch, amplifier, logic (CMOS)
SD9|MOSFET (P-channel enhancement)|Q|field-effect transistor|same parameters; complementary to N-channel; typically higher R_DS(on) for same die size|negative V_GS below threshold turns on channel in N-type body|high-side switching (simple gate drive: connect gate to ground to turn on), CMOS complementary pair, load switch
SD10|JFET (N-channel)|Q|field-effect transistor|V_GS(off) (pinch-off voltage, −1 to −10 V), I_DSS (drain current at V_GS=0), g_m (transconductance)|depletion-mode: channel exists at V_GS = 0; negative V_GS depletes channel; very high input impedance|low-noise preamplifier, high-impedance buffer, voltage-controlled resistor, analog switches
SD11|IGBT (insulated gate bipolar transistor)|Q|hybrid FET + BJT|V_CE(sat) (~1.5–3 V), V_GE(th), I_C(max), E_on/E_off (switching energy), SCSOA|MOSFET gate drive controls BJT-like output stage; combines high input impedance of MOSFET with low saturation voltage of BJT|high-power switching: inverters (motor drive, solar, UPS), induction heating, welding, traction; 600–6,500 V range
SD12|thyristor (SCR)|SCR|PNPN structure|V_DRM (blocking voltage), I_T(avg), I_GT (gate trigger current), dv/dt rating, di/dt rating|latching device: once triggered by gate pulse, conducts until current falls below holding current; cannot be turned off by gate alone|AC power control (phase control), HVDC transmission, motor soft start, crowbar protection
SD13|TRIAC|TR|bidirectional thyristor|V_DRM, I_T(rms), I_GT, dv/dt|two antiparallel SCRs in one device; conducts both directions when triggered; turns off at current zero crossing|AC dimmer, motor speed control, heater control, solid-state relay (within SSR)
SD14|GaN HEMT (gallium nitride)|Q|high-electron-mobility transistor|V_DS(max), R_DS(on) (very low), Q_g (very low), zero reverse recovery|2D electron gas (2DEG) at AlGaN/GaN heterojunction; wide bandgap (3.4 eV); high breakdown field; high electron mobility|high-frequency power conversion (>1 MHz), GaN chargers, data center power, RF power amplifiers, lidar
SD15|SiC MOSFET (silicon carbide)|Q|wide-bandgap MOSFET|V_DS(max) (up to 3,300 V), R_DS(on), high-temperature operation (up to 200°C junction), fast body diode|SiC bandgap 3.26 eV; high critical field; high thermal conductivity (490 W/m·K vs Si 150)|EV traction inverter, solar inverter, industrial drives, high-voltage DC-DC, fast charger

# active_components(id|name|type|key_parameters|internal_structure|applications)
IC1|operational amplifier (op-amp)|analog IC|open-loop gain (A_OL: 10⁵–10⁸), GBW (gain-bandwidth product: 1 MHz–10 GHz), input offset voltage (μV–mV), CMRR (60–120 dB), slew rate (V/μs), input bias current (pA–μA), supply voltage, rail-to-rail I/O|differential input pair → gain stage(s) → output stage; feedback configures function|amplification, filtering, comparison, integration, differentiation, voltage follower, instrumentation, ADC driver, DAC output
IC2|comparator|analog IC|propagation delay (ns), input offset voltage, hysteresis (internal or external), output type (open-drain/push-pull), overdrive recovery|differential amplifier optimized for fast switching (no compensation capacitor like op-amp)|zero-crossing detection, threshold detection, window comparator, PWM generation, ADC (flash)
IC3|voltage regulator (linear, LDO)|power IC|V_in range, V_out (fixed or adjustable), dropout voltage (LDO: 30–300 mV), output current (mA–A), PSRR (dB), noise (μV_rms), quiescent current (μA–mA)|error amplifier compares output to reference → controls pass transistor (series regulator)|clean low-noise supply for analog, RF, ADC/DAC, sensor; post-switching-regulator cleanup
IC4|voltage reference|analog IC|output voltage (1.024–10 V), initial accuracy (±0.01–1%), temperature coefficient (1–100 ppm/°C), noise, long-term drift|bandgap reference (V_BG ≈ 1.25 V silicon bandgap); buried zener (higher accuracy)|ADC/DAC reference, calibration, precision comparator, current source
IC5|ADC (analog-to-digital converter)|mixed-signal IC|resolution (bits: 8–32), sampling rate (SPS: 1–10 GSPS), DNL/INL (LSB), SNR/SINAD/ENOB, input range, architecture|SAR (successive approximation: 1–100 MSPS, 8–20 bit), sigma-delta (ΣΔ: high resolution 16–32 bit, low speed 1–1 MSPS), flash (fastest: GSPS, low resolution 6–10 bit), pipeline (10–16 bit, 10–500 MSPS)|sensor digitization, audio, instrumentation, communication receiver, oscilloscope, medical imaging
IC6|DAC (digital-to-analog converter)|mixed-signal IC|resolution (bits: 8–20), settling time, output type (voltage or current), DNL/INL, glitch energy, update rate|R-2R ladder, current-steering, sigma-delta|audio output, waveform generation, actuator drive, calibration, communication transmitter
IC7|timer (555/556)|analog/digital IC|timing range (μs to hours), output current (±200 mA for 555), supply (4.5–16 V)|internal comparators, RS flip-flop, discharge transistor; external R and C set timing|monostable (one-shot), astable (oscillator), PWM, pulse generation, time delay
IC8|logic gate (discrete)|digital IC|propagation delay, fan-out, noise margin, power consumption per gate, logic family voltage levels|NAND, NOR, AND, OR, NOT, XOR, XNOR, buffer; basic combinational building blocks|glue logic, signal conditioning, level translation, simple decoding; largely replaced by FPGA/MCU in complex designs
IC9|flip-flop (D, JK, T)|digital IC|setup time, hold time, clock-to-Q delay, maximum clock frequency, metastability MTBF|edge-triggered bistable; D flip-flop: output follows D input on clock edge; JK: toggle; T: toggle on input|registers, counters, frequency dividers, state machines, synchronizers, shift registers
IC10|FPGA (field-programmable gate array)|digital IC|logic elements/LUTs, block RAM, DSP blocks, I/O pins, clock speed, configuration method (SRAM, flash, antifuse)|array of configurable logic blocks (CLBs) containing LUTs + flip-flops + multiplexers; interconnected by programmable routing; configured at power-up (SRAM) or once (flash/antifuse)|prototyping, DSP, video processing, communication, encryption, motor control, high-speed interface, ASIC replacement
IC11|CPLD (complex programmable logic device)|digital IC|macrocells (typically 32–512), deterministic timing, non-volatile configuration (flash)|AND-OR arrays (product terms) + flip-flops per macrocell; combinational + registered outputs; instant-on|simple glue logic, address decoding, state machines, power sequencing, level translation, I/O expansion
IC12|analog multiplexer/demultiplexer|analog IC|number of channels (2:1–16:1), on-resistance (Ω), bandwidth (MHz), charge injection (pC), off-isolation (dB), supply voltage|transmission gates (CMOS switches) selected by digital address lines; bidirectional|sensor multiplexing, audio routing, test equipment channel selection, data acquisition
IC13|phase-locked loop (PLL)|mixed-signal IC/block|lock range, capture range, loop bandwidth, phase noise (dBc/Hz), jitter (ps), reference frequency, VCO frequency range|phase detector → loop filter → VCO → feedback divider (÷N); locks VCO output to N × reference frequency|clock synthesis (MCU, FPGA), frequency synthesis (radio), clock recovery (SerDes), motor speed control, demodulation
IC14|current sense amplifier|analog IC|gain (1–200 V/V), bandwidth, common-mode voltage range (high-side: up to 100 V+; low-side: near GND), offset voltage, CMRR|amplifier measuring voltage across shunt resistor (PC1 as sense element); high-side or low-side topology|motor current measurement, battery management, power supply monitoring, overcurrent protection, energy metering

# optoelectronics(id|name|type|key_parameters|mechanism|applications)
OE1|LED (covered in SD4)|—|—|—|—|see SD4
OE2|laser diode|emitter|wavelength (nm), output power (mW–W), threshold current, slope efficiency (W/A), spectral width, beam divergence|stimulated emission in direct-bandgap semiconductor; optical cavity (Fabry-Perot, DFB, VCSEL)|fiber optic communication, lidar, laser pointer, optical disc, barcode, medical, industrial cutting/welding (high power)
OE3|photodiode (covered in SD5)|—|—|—|—|see SD5
OE4|phototransistor|detector|responsivity, spectral range, rise/fall time (μs, slower than photodiode), gain (h_FE amplifies photocurrent)|photodiode integrated with BJT; photocurrent amplified by transistor gain; more sensitive but slower|object detection, optocoupler (within package), light barrier, encoder
OE5|optocoupler (optoisolator)|isolation|CTR (current transfer ratio %), isolation voltage (kV), bandwidth (kHz–MHz), creepage/clearance distance|LED + photodetector in single package separated by insulating barrier; signal transferred optically|galvanic isolation: feedback in SMPS, digital signal isolation, gate driver isolation, safety barrier
OE6|LCD (liquid crystal display)|display|resolution, contrast ratio, viewing angle, response time (ms), backlight type (LED), color depth|liquid crystal layer between polarizers; voltage controls crystal alignment → modulates light transmission|monitors, instruments, HMI panels, consumer electronics
OE7|OLED (organic LED)|display/lighting|resolution, contrast (infinite for pixel-off), response time (<1 ms), luminance (cd/m²), lifetime (hours), color gamut|organic electroluminescent layer between anode and cathode; each pixel emits own light (no backlight)|smartphone/TV displays, wearables, automotive dashboards, lighting panels
OE8|solar cell (photovoltaic)|generator|efficiency (%), open-circuit voltage V_OC, short-circuit current I_SC, fill factor, temperature coefficient, degradation rate|photon absorption in semiconductor → electron-hole pair generation → built-in field separates → current; single-junction (Si ~20–26%), multi-junction (~47%)|solar panels (monocrystalline, polycrystalline, thin-film), space power, portable power, building-integrated PV

# power_electronics(id|name|type|topology|input|output|key_parameters|applications)
PE1|half-bridge|inverter/converter building block|two switches (high-side + low-side) with midpoint output|DC bus|switched AC at midpoint|dead time, bootstrap, shoot-through prevention|building block for full-bridge, motor drive, SMPS
PE2|full-bridge (H-bridge)|inverter/converter|four switches; load connected between two midpoints|DC|bidirectional DC or AC across load|dead time, shoot-through prevention, PWM scheme|motor drive (DC and BLDC), inverter, bidirectional DC-DC
PE3|buck converter (step-down)|DC-DC SMPS|switch + diode (or synchronous FET) + inductor + capacitor; switch connects input to inductor|V_in (higher)|V_out < V_in|duty cycle D = V_out/V_in; switching frequency, ripple, efficiency, load regulation|point-of-load power, battery charging, LED driver, voltage rail generation
PE4|boost converter (step-up)|DC-DC SMPS|switch + diode + inductor + capacitor; inductor charges from input, discharges to higher output|V_in (lower)|V_out > V_in|D = 1 − V_in/V_out; V_out limited by duty cycle and parasitics|battery-to-rail (3.3→5 V), LED backlighting, solar MPPT, PFC front end
PE5|buck-boost converter|DC-DC SMPS|inverting: switch + diode + inductor (output negative); non-inverting: SEPIC, Ćuk, or 4-switch|V_in|V_out can be higher or lower than V_in|D = V_out/(V_in + V_out) (inverting)|battery-powered (voltage drops as battery discharges), solar, universal input
PE6|flyback converter|isolated DC-DC SMPS|coupled inductor (transformer) + switch + diode + capacitor; energy stored in core during switch-on, transferred during switch-off|AC (via rectifier) or DC|isolated DC (multiple outputs possible)|turns ratio sets V_out; operates in CCM or DCM; cross-regulation between outputs|AC-DC adapter (phone charger, laptop), auxiliary supply, low-power isolated supply (< 200 W typical)
PE7|forward converter|isolated DC-DC SMPS|transformer + switch + rectifier diode + freewheeling diode + inductor + capacitor; energy transferred during switch-on|DC|isolated DC|requires transformer reset (RCD clamp, active clamp, third winding); single-ended|medium power (100–500 W); telecom, industrial
PE8|LLC resonant converter|isolated DC-DC SMPS|half-bridge or full-bridge + resonant tank (L_r, L_m, C_r) + transformer + rectifier|DC (from PFC)|isolated DC|operates at/near resonance; ZVS across load range; high efficiency >96%; variable frequency control|server power, telecom rectifier, EV charger, high-efficiency AC-DC (200 W–10 kW)
PE9|full-bridge phase-shifted converter|isolated DC-DC SMPS|full-bridge switches with phase-shift control + transformer + inductor + rectifier|DC|isolated DC|ZVS achieved via magnetizing/leakage inductance; constant frequency; duty cycle loss at light load|high-power DC-DC (500 W–5 kW); welding, server, telecom
PE10|three-phase inverter|DC-AC|three half-bridges driving three-phase load; six switches total|DC bus (200–800 V typical)|three-phase AC (variable frequency, variable voltage)|SVPWM or SPWM modulation; dead-time compensation; V/f or FOC control|AC motor drive (induction, PMSM), grid-tied solar inverter, UPS, EV traction
PE11|PFC (power factor correction) stage|AC-DC front end|boost converter operating in CCM or CrCM; shapes input current to follow input voltage waveform|AC mains (rectified)|DC bus (~380–420 V from 230 V AC)|power factor >0.99; THD_i <5%; mandatory >75 W (IEC 61000-3-2)|universal input AC-DC power supply front end; LED driver; server PSU; telecom rectifier
PE12|gate driver|interface IC|isolated or non-isolated; drives MOSFET/IGBT gate capacitance with high peak current|logic-level signal (3.3/5 V)|gate drive signal (10–20 V for MOSFET; 15 V for IGBT)|peak source/sink current (A), propagation delay (ns), dV/dt immunity (kV/μs), dead-time insertion|all power converter switch drive; half-bridge bootstrap; isolated (for high-side); motor drive

# signal_types(id|name|domain|characteristics|representation|examples)
SG1|DC signal|analog|constant voltage or current; zero frequency|V or I = constant|battery voltage, sensor bias, reference voltage
SG2|AC sinusoidal|analog|single frequency; amplitude + frequency + phase fully define|v(t) = V_pk sin(ωt + φ)|mains power (50/60 Hz), audio tone, RF carrier, test signal
SG3|periodic non-sinusoidal|analog|repeating waveform; decomposable by Fourier series into harmonics|square, triangle, sawtooth, pulse train|clock signals, PWM, audio waveforms, function generator output
SG4|transient|analog|non-periodic; decays over time; step, impulse, exponential|step response, impulse response, ringing|switch-on surge, ESD event, power-on transient, trigger pulse
SG5|noise|analog|random fluctuation; characterized by spectral density (V²/Hz or V/√Hz)|thermal (white, flat spectrum), flicker (1/f, dominant at low freq), shot (current-dependent)|limits SNR; floor of measurement; input-referred noise of amplifier
SG6|digital binary|digital|two discrete states: logic HIGH (V_OH) and logic LOW (V_OL); defined by thresholds V_IH, V_IL|0 and 1; voltage levels depend on logic family|TTL, CMOS, LVDS, RS-232, SPI, I²C, USB data lines
SG7|PWM (pulse width modulation)|mixed|fixed frequency; variable duty cycle encodes analog information|duty cycle D = t_on/T; average voltage = D × V_supply|motor speed control, LED dimming, DAC approximation, SMPS control, servo position
SG8|differential|analog/digital|signal carried as voltage difference between two conductors; common-mode rejected|V_signal = V⁺ − V⁻; V_CM = (V⁺ + V⁻)/2|LVDS, RS-485, USB, Ethernet, CAN, audio balanced, instrumentation amplifier input

# circuit_topologies(id|name|type|function|key_equations|advantages|limitations|applications)
CT1|voltage divider|passive|scales voltage by resistor ratio|V_out = V_in × R₂/(R₁+R₂)|simple; no active components|load-dependent (unless buffered); power waste|biasing, sensing, reference scaling, ADC input scaling
CT2|Wheatstone bridge|passive/active|precision measurement of resistance change; balanced when R₁/R₂ = R₃/R₄|V_out = V_in × (R₃/(R₃+R₄) − R₂/(R₁+R₂))|high sensitivity to small ΔR; rejects common-mode drift|requires balanced excitation; nonlinear for large ΔR|strain gauge, RTD, load cell, pressure sensor
CT3|inverting amplifier|active (op-amp)|amplifies with phase inversion; gain set by feedback|V_out = −(R_f/R_in) × V_in|precise gain; virtual ground at inverting input|inverts signal; input impedance = R_in (not infinite)|audio, sensor conditioning, summing amplifier (multiple R_in)
CT4|non-inverting amplifier|active (op-amp)|amplifies without phase inversion|V_out = (1 + R_f/R_g) × V_in|very high input impedance; non-inverting|gain ≥ 1 (minimum gain = 1 as voltage follower)|buffer, sensor amplifier, signal conditioning
CT5|differential amplifier|active (op-amp)|amplifies difference between two inputs; rejects common-mode|V_out = (R_f/R_in)(V₂ − V₁) when R ratios matched|CMRR depends on resistor matching|limited CMRR with discrete resistors (use instrumentation amp for high CMRR)|current sensing, bridge amplifier, differential to single-ended conversion
CT6|instrumentation amplifier|active (3 op-amp or IC)|precision differential amplifier with high CMRR, high Z_in, adjustable gain by single resistor|V_out = G × (V₂ − V₁); G = 1 + 2R/(R_G)|CMRR >100 dB; very high Z_in (>10 GΩ); gain set by one resistor|cost; limited bandwidth at high gain|strain gauge, thermocouple, medical (ECG, EEG), precision measurement, bridge interface
CT7|summing amplifier|active (op-amp)|adds multiple input signals (weighted sum)|V_out = −(R_f/R₁ × V₁ + R_f/R₂ × V₂ + ...)|flexible weighting|inverting; loading depends on input resistors|audio mixing, DAC (R-2R), waveform synthesis, signal combining
CT8|integrator|active (op-amp)|output proportional to integral of input over time|V_out = −(1/RC) ∫V_in dt|generates ramp from constant input; low-pass at high frequency|DC offset → output ramp to rail (add reset resistor in parallel with C)|PID integral term, waveform generator (triangle from square), analog computation
CT9|differentiator|active (op-amp)|output proportional to rate of change of input|V_out = −RC × dV_in/dt|detects edges and rate of change; high-pass at low frequency|amplifies high-frequency noise (add series R to limit gain at HF)|edge detection, PID derivative term, frequency demodulation (FM)
CT10|current mirror|active (BJT or MOSFET)|copies current from reference branch to output branch|I_out = I_ref × (W/L)₂/(W/L)₁ (MOSFET); I_out ≈ I_ref (matched BJTs)|high output impedance; temperature tracking (matched pair)|requires matched devices; compliance voltage limits swing|biasing in IC design, active loads, DAC, current source/sink

# filters(id|name|type|order|passband|key_parameters|topology|applications)
FL1|RC low-pass|passive, 1st order|1|DC to f_c|f_c = 1/(2πRC); −20 dB/decade rolloff above f_c; phase: 0° at DC, −45° at f_c, −90° at HF|series R + shunt C|anti-aliasing (crude), decoupling, noise filtering, smoothing PWM
FL2|RC high-pass|passive, 1st order|1|f_c to ∞|f_c = 1/(2πRC); −20 dB/decade rolloff below f_c; phase: +90° at DC, +45° at f_c, 0° at HF|series C + shunt R|AC coupling, DC blocking, audio treble, differentiating network
FL3|LC low-pass|passive, 2nd order|2|DC to f₀|f₀ = 1/(2π√(LC)); −40 dB/decade; Q = (1/R)√(L/C)|series L + shunt C (π or T networks)|SMPS output filter, EMI filter, speaker crossover
FL4|bandpass filter|passive or active|≥2|f_L to f_H|center frequency f₀ = √(f_L × f_H); bandwidth BW = f_H − f_L; Q = f₀/BW|series RLC, parallel RLC, active (multiple feedback, state variable)|radio tuning, audio equalizer, sensor (lock-in amplifier), communication channel selection
FL5|notch (band-reject) filter|passive or active|≥2|DC to f_L and f_H to ∞ (rejects f₀ band)|rejection depth at f₀; bandwidth; Q|twin-T, active (state variable, biquad)|50/60 Hz hum rejection, anti-resonance, interference rejection
FL6|Butterworth filter|active (design method)|n (any)|low-pass, high-pass, bandpass, notch|maximally flat passband; −20n dB/decade rolloff; phase nonlinear|Sallen-Key, multiple feedback, state variable|general-purpose active filtering where flat passband required
FL7|Chebyshev filter (Type I)|active (design method)|n|low-pass, high-pass, bandpass, notch|steeper rolloff than Butterworth for same order; passband ripple (0.1–3 dB); group delay variation|same topologies as Butterworth; different component values|sharper cutoff where passband ripple tolerable
FL8|Bessel filter|active (design method)|n|low-pass, high-pass|maximally flat group delay (linear phase); slowest rolloff for given order|same topologies; optimized for phase linearity|pulse/step response preservation; data communication; where waveform shape critical
FL9|active low-pass (Sallen-Key)|active, 2nd order per section|2 per section|DC to f_c|f_c, Q (damping), gain; cascadable for higher order|two R, two C, one op-amp per section; unity-gain or gain >1|anti-aliasing before ADC, audio, instrumentation, sensor conditioning
FL10|switched-capacitor filter|active (sampled-data)|programmable|low-pass, high-pass, bandpass, notch|cutoff frequency set by clock frequency (f_c = f_clk/ratio); no precision external R/C needed|internal capacitor arrays switched by clock; on-chip in mixed-signal ICs|telecom, audio CODEC, tunable filters, data acquisition systems

# amplifier_topologies(id|name|type|gain|input_impedance|output_impedance|bandwidth|applications)
AT1|common emitter (CE)|BJT|moderate to high (A_v = −g_m × R_C; 10–500)|moderate (r_π, ~1–10 kΩ)|moderate to high (R_C)|f_T / gain (GBW tradeoff)|general-purpose voltage amplifier, first stage
AT2|common collector (emitter follower)|BJT|≈1 (voltage gain ~0.99)|very high (β × r_e)||wide|buffer (impedance transformation), output stage, level shifter
AT3|common base (CB)|BJT|moderate to high (A_v ≈ g_m × R_C)|very low (~1/g_m, ~25 Ω at 1 mA)|moderate to high|very wide (no Miller effect)|RF amplifier, cascode second stage, high-frequency
AT4|common source (CS)|MOSFET|moderate (A_v = −g_m × R_D)|very high (gate: ~10¹² Ω)|moderate to high|limited by C_gd (Miller effect)|general-purpose FET amplifier, first stage in CMOS
AT5|common drain (source follower)|MOSFET|≈1|very high|low (~1/g_m)|wide|buffer, impedance transformation, LDO pass element
AT6|cascode|BJT or MOSFET|high (CE + CB stacked; or CS + CG)|moderate to high|high|very wide (Miller capacitance eliminated by CB/CG stage)|RF, wideband, high-gain, current mirror output stage
AT7|push-pull (Class AB)|BJT or MOSFET|set by preceding gain stage|depends on driver|very low|wide|audio power output, motor driver output, op-amp output stage
AT8|Class D amplifier|switching (MOSFET)|set by modulator + feedback|—|—|wide (limited by output filter)|audio power (>90% efficiency), motor drive, speaker amplifier
AT9|transimpedance amplifier (TIA)|op-amp + feedback R|R_f (V/A, Ω)|virtual ground (low)|low|determined by R_f × C_feedback tradeoff|photodiode receiver, current-to-voltage conversion, optical communication front-end

# oscillators(id|name|type|frequency_range|stability|output_waveform|key_components|applications)
OS1|RC oscillator (Wien bridge)|analog|1 Hz–1 MHz|moderate (±1–5%)|sine|op-amp + Wien bridge (2R, 2C); AGC for amplitude stabilization|audio signal generation, test equipment, function generator
OS2|LC oscillator (Colpitts)|analog|10 kHz–1 GHz|moderate|sine|active device (BJT/FET) + LC tank (C₁, C₂, L); positive feedback via capacitive divider|RF local oscillator, VCO, transmitter carrier, signal generator
OS3|crystal oscillator (Pierce)|analog/digital|1 kHz–200 MHz|high (±10–100 ppm)|square or sine|inverter + quartz crystal + load capacitors; crystal operates between series and parallel resonance|MCU clock, FPGA clock, communication timing, RTC (32.768 kHz)
OS4|TCXO (temperature-compensated crystal oscillator)|analog|1–50 MHz|very high (±0.5–5 ppm over temperature)|sine or clipped sine|crystal + temperature compensation network (analog or digital)|GPS, cellular, instrumentation, where tight frequency tolerance needed without oven
OS5|OCXO (oven-controlled crystal oscillator)|analog|5–100 MHz|excellent (±0.01–0.1 ppm)|sine|crystal in temperature-controlled oven (~80°C); SC-cut crystal|frequency standard, base station, test equipment, precision timing
OS6|VCO (voltage-controlled oscillator)|analog|kHz–GHz|depends on type (LC, ring, crystal-based)|sine or square|varactor diode tunes LC tank (analog VCO); ring oscillator (digital VCO: delay chain)|PLL building block, FM modulator, frequency synthesizer, sweep generator
OS7|relaxation oscillator (astable 555)|analog/digital|0.1 Hz–500 kHz|low (±5–20%, RC tolerance-dependent)|square or pulse|comparator(s) + RC timing; 555 timer or op-amp + hysteresis|simple clock, LED flasher, tone generator, PWM, timing
OS8|ring oscillator|digital|MHz–GHz|low (PVT-dependent: process, voltage, temperature)|square|odd number of inverter stages in loop; frequency = 1/(2 × N × t_pd)|on-chip clock (PLL VCO in digital CMOS), process speed monitor, random number generation

# modulation(id|name|type|domain|bandwidth|spectral_efficiency|noise_immunity|applications)
MO1|AM (amplitude modulation)|analog|RF|2 × f_signal|low|poor (amplitude noise directly affects signal)|AM radio, aircraft VHF voice, simple remote control
MO2|FM (frequency modulation)|analog|RF|~2(Δf + f_signal) (Carson's rule)|moderate|good (constant envelope; limiter rejects AM noise)|FM radio, analog TV audio, two-way radio, telemetry
MO3|ASK (amplitude shift keying)|digital|RF/baseband|≈ 2 × symbol rate|1 bit/Hz (OOK)|poor|simple transmitters, RFID, optical (OOK in fiber)
MO4|FSK (frequency shift keying)|digital|RF|≈ symbol_rate + 2Δf|< 1 bit/Hz|moderate to good|modem, pager, Bluetooth (GFSK), LoRa (CSS variant)
MO5|PSK (phase shift keying)|digital|RF|≈ symbol rate|BPSK: 1; QPSK: 2; 8PSK: 3 bits/Hz|BPSK best; degrades with higher order|satellite (BPSK, QPSK), Wi-Fi, DVB, cellular
MO6|QAM (quadrature amplitude modulation)|digital|RF/cable|≈ symbol rate|4 (16QAM) to 10 (1024QAM) bits/Hz|degrades with higher order (closer constellation points)|Wi-Fi (64/256QAM), cable modem (256QAM), 5G, DVB-C, microwave links
MO7|OFDM (orthogonal frequency division multiplexing)|digital (multi-carrier)|RF|sum of subcarrier bandwidths|high (subcarriers can use different QAM levels)|excellent multipath resistance (cyclic prefix)|Wi-Fi (802.11a/g/n/ac/ax), LTE/5G, DVB-T, DAB, PLC
MO8|spread spectrum (DSSS/FHSS)|digital|RF|much wider than data rate (processing gain)|low (trades bandwidth for robustness)|excellent (processing gain rejects narrowband interference; LPI)|GPS (DSSS), CDMA, Bluetooth (FHSS), military, ISM
MO9|PCM (pulse code modulation)|digital|baseband|sampling rate × bits per sample|—|excellent (digital quantization; noise added only once)|digital audio (CD: 44.1 kHz × 16 bit), telephony (8 kHz × 8 bit), data acquisition, digital recording
MO10|PWM (as modulation)|analog encoding|baseband/power|switching frequency (carrier)|1 bit per sample|moderate (threshold detection robust vs amplitude noise)|motor control, SMPS, Class D audio, LED dimming, servo control

# digital_foundations(id|name|type|definition|truth_table_or_function|key_properties|applications)
DF1|Boolean algebra|mathematical foundation|algebraic system of two values {0, 1} with operations AND (·), OR (+), NOT ('); governs all digital logic|axioms: identity, complement, commutative, associative, distributive, De Morgan's|complete basis sets: {NAND}, {NOR}, {AND, OR, NOT}|logic design, simplification (Karnaugh maps, Quine-McCluskey), synthesis
DF2|combinational logic|circuit type|output depends only on current inputs; no memory; implemented with gates|any Boolean function: decoders, encoders, multiplexers, adders, comparators|propagation delay is only timing concern; no clock needed|address decoding, arithmetic, data routing, priority encoding
DF3|sequential logic|circuit type|output depends on current inputs AND past state (memory); requires clock (synchronous) or level (asynchronous)|flip-flops, latches, registers, counters, state machines (Mealy/Moore)|setup time, hold time, clock-to-Q delay; metastability at clock domain crossings|registers, counters, FSM, CPU pipeline, memory controllers, protocol handlers
DF4|synchronous design|design methodology|all state changes occur on clock edge; single clock domain (or managed multi-clock with synchronizers)|all flip-flops clocked by same edge of global clock; combinational logic between stages settles within clock period|timing closure: T_clk > T_comb + T_setup + T_skew; deterministic behavior|standard digital design methodology; MCU, FPGA, ASIC, SoC
DF5|number systems|representation|binary (base 2), octal (base 8), hexadecimal (base 16); signed: two's complement (standard), sign-magnitude, ones' complement|binary: MSB to LSB; two's complement: −2^(n−1) to 2^(n−1)−1|two's complement: single representation of zero; addition works for signed/unsigned without modification|all digital computation, addressing, data representation
DF6|fixed-point arithmetic|numeric representation|integer scaled by implicit binary point position; Q_m.n format: m integer bits + n fractional bits|value = integer × 2^(−n); range: −2^m to 2^m − 2^(−n)|fast (integer ALU); deterministic timing; limited range/precision tradeoff|DSP, motor control, audio, embedded (where FPU absent), FPGA
DF7|floating-point arithmetic|numeric representation|IEEE 754: sign + exponent + mantissa; single precision (32 bit: 1+8+23), double precision (64 bit: 1+11+52)|value = (−1)^s × 1.mantissa × 2^(exponent−bias)|wide dynamic range; special values: ±∞, NaN, ±0, denormals; rounding modes|scientific computing, graphics, AI/ML, general-purpose computing, sensor fusion
DF8|finite state machine (FSM)|design pattern|system with finite number of states, transitions triggered by inputs, outputs determined by state (Moore) or state+input (Mealy)|state diagram → state table → logic equations → flip-flops + combinational logic|Moore: output changes only on clock edge (safer); Mealy: output can change asynchronously (faster response)|protocol handler, control sequencer, vending machine, traffic light, UART, SPI, I²C controller
DF9|bus architecture|interconnect|shared communication pathway; multiple devices share address/data/control lines; arbitration resolves contention|address bus + data bus + control bus; multiplexed or separate|bus width (bits), clock speed, bandwidth = width × frequency × transfers/clock|CPU-memory (AHB, AXI), peripheral (APB), PCIe, ISA/PCI (legacy)

# logic_families(id|name|supply_V|V_OH_min|V_OL_max|V_IH_min|V_IL_max|propagation_delay_ns|static_power|speed_power_product|notes)
LF1|5V CMOS (CD4000)|3–15 (typ 5)|4.95 (at 5V)|0.05|3.5|1.5|~50–200|~10 nW/gate (static)|low|very low power; slow; wide supply range; legacy
LF2|74HC (high-speed CMOS)|2–6 (typ 5)|4.9|0.1|3.5|1.0|~8–25|~1 μW/gate (static; dynamic ∝ f)|low|standard modern 5V CMOS logic; good noise margins
LF3|74HCT (HC + TTL-compatible)|4.5–5.5|4.9|0.1|2.0 (TTL-compatible)|0.8|~8–25|slightly higher than HC|low|TTL-compatible input thresholds; interfaces 5V TTL to CMOS
LF4|74LVC (low-voltage CMOS)|1.65–3.6|V_CC−0.3|0.4|0.7×V_CC|0.3×V_CC|~3–10|very low|very low|1.8 V and 3.3 V logic; 5V-tolerant inputs; high speed
LF5|74AUC (advanced ultra-low-voltage CMOS)|0.8–2.7|V_CC−0.3|0.4|0.7×V_CC|0.3×V_CC|~1.5–5|ultra-low|ultra-low|1.2–1.8 V logic; fastest discrete CMOS
LF6|LVTTL (low-voltage TTL)|3.0–3.6|2.4|0.4|2.0|0.8|~5–10|moderate|moderate|3.3V TTL-level standard; FPGA/MCU I/O default
LF7|LVCMOS (low-voltage CMOS)|1.2–3.3|V_CC−0.2|0.2–0.4|0.65×V_CC|0.35×V_CC|~3–10|very low|very low|FPGA I/O standard; 1.2V/1.5V/1.8V/2.5V/3.3V variants
LF8|LVDS (low-voltage differential signaling)|—|V_OD: 250–450 mV differential|—|threshold: 100 mV differential|—|~1–3|low|very low|high-speed differential (up to ~3.125 Gbps); low EMI; 100 Ω differential impedance; FPGA SerDes, display

# memory(id|name|type|volatility|access_type|density|speed|endurance|retention|applications)
ME1|SRAM (static RAM)|semiconductor|volatile|random; read/write|low (6T cell: large)|very fast (sub-ns access; matches CPU clock)|unlimited read/write|power-maintained|CPU cache (L1/L2/L3), register file, FPGA block RAM, scratchpad
ME2|DRAM (dynamic RAM)|semiconductor|volatile|random; read/write; requires periodic refresh (~64 ms)|high (1T1C cell: small)|moderate (10–100 ns; CAS latency)|unlimited read/write|milliseconds (requires refresh)|main system memory (DDR4, DDR5, LPDDR); frame buffer; HBM (GPU)
ME3|flash NOR|semiconductor|non-volatile|random read; block/sector erase + byte/word program|moderate|fast read (~70–120 ns); slow write/erase (μs–ms)|10,000–100,000 erase cycles|10–20 years|firmware/BIOS storage, execute-in-place (XIP), MCU program memory, boot ROM
ME4|flash NAND|semiconductor|non-volatile|page read; page program; block erase|very high (stacked: 3D NAND 100+ layers)|sequential read ~25 μs/page; write ~300 μs/page; erase ~1.5 ms/block|SLC: 100,000; MLC: 10,000; TLC: 3,000; QLC: 1,000 P/E cycles|10 years (decreases with wear)|SSD, USB flash drive, SD card, eMMC, UFS; mass storage
ME5|EEPROM|semiconductor|non-volatile|byte-level read/write/erase|low|slow write (~5 ms per byte); fast read (~200 ns)|100,000–1,000,000 erase cycles|>40 years|configuration storage, serial number, calibration data; typically small (256 B–256 KB)
ME6|MRAM (magnetoresistive RAM)|semiconductor|non-volatile|random; read/write|moderate|fast (10–35 ns; approaching SRAM)|>10¹² (effectively unlimited)|>10 years|SRAM replacement where non-volatility needed; aerospace, automotive, IoT; radiation-hard
ME7|FeRAM (ferroelectric RAM)|semiconductor|non-volatile|random; read/write (destructive read → rewrite)|moderate|fast (50–200 ns)|>10¹² cycles|>10 years|smart meters, RFID, medical devices, automotive; low-power non-volatile
ME8|ROM (mask ROM)|semiconductor|non-volatile (permanent)|read-only; programmed at fabrication|high|fast read (~50–100 ns)|infinite read|permanent|high-volume fixed data: boot code, character tables, lookup; replaced by flash in most applications

# microcontrollers(id|name|type|architecture|bus_width|clock_speed|memory|peripherals|power_consumption|applications)
MC1|8-bit MCU (e.g., ATmega328P)|general purpose|Harvard (modified); RISC|8-bit data; 16-bit address|up to 20 MHz|32 KB flash; 2 KB SRAM; 1 KB EEPROM|GPIO, ADC (10-bit), UART, SPI, I²C, timers/counters, PWM, watchdog, analog comparator|active: ~1–10 mA; sleep: ~1 μA|Arduino, simple sensor nodes, hobby, education, appliance control, automotive body (legacy)
MC2|16-bit MCU (e.g., MSP430)|ultra-low-power|von Neumann; RISC|16-bit|up to 25 MHz|up to 256 KB flash; 66 KB SRAM|GPIO, ADC (12–16 bit), comparator, DMA, UART, SPI, I²C, timers, LCD driver|active: ~100–300 μA/MHz; sleep: ~0.1 μA|battery-powered sensor, wearable, metering, medical, IoT edge
MC3|32-bit MCU (ARM Cortex-M0/M0+)|entry-level 32-bit|Harvard; ARMv6-M; Thumb-2 (subset)|32-bit|up to 48 MHz|16–256 KB flash; 4–32 KB SRAM|GPIO, ADC, UART, SPI, I²C, timers, PWM, DMA|active: ~30–100 μA/MHz; sleep: ~1 μA|IoT, wearable, simple motor control, USB device, cost-sensitive 32-bit
MC4|32-bit MCU (ARM Cortex-M4F)|mid-range with FPU + DSP|Harvard; ARMv7E-M; FPU (single precision); DSP (SIMD, MAC)|32-bit|up to 168–240 MHz|up to 2 MB flash; up to 1 MB SRAM|GPIO, ADC (12–16 bit), DAC, UART, SPI, I²C, CAN, USB, Ethernet MAC, timers, DMA, FPU, DSP instructions|active: ~30–100 μA/MHz|motor control (FOC), audio, IoT gateway, industrial, medical, drones, robotics
MC5|32-bit MCU (ARM Cortex-M7)|high-performance|Harvard; ARMv7E-M; FPU (single + double precision); DSP; I/D cache|32-bit|up to 480–600 MHz|up to 2 MB flash; up to 1 MB SRAM; external memory interface|all M4 peripherals + JPEG codec, LCD controller, camera interface, SDMMC, advanced timers|active: ~20–60 μA/MHz|HMI (graphics), industrial automation, advanced motor control, gateway, multimedia
MC6|32-bit MCU (RISC-V)|open ISA|Harvard or von Neumann; RISC-V (RV32IMAC or RV32IMAFC)|32-bit|up to 160–600 MHz (vendor-dependent)|vendor-dependent; 64 KB–2 MB flash; 16 KB–512 KB SRAM|GPIO, ADC, UART, SPI, I²C, USB, BLE (some), timers; growing ecosystem|competitive with ARM Cortex-M|IoT, AI edge (with vector extensions), cost-sensitive, open-source toolchain preference
MC7|application processor (ARM Cortex-A)|MPU (runs OS)|Harvard (with MMU); ARMv8-A/ARMv9; out-of-order; NEON SIMD; FPU|32/64-bit|1–3 GHz (multi-core)|external DRAM (GB); on-chip L1/L2 cache (MB)|GPU, NPU, ISP, display, USB, PCIe, Ethernet, MIPI CSI/DSI|active: ~200 mA–2A per core|smartphone, tablet, SBC (RPi), gateway, infotainment, edge AI, network equipment
MC8|DSP (digital signal processor)|specialized|Harvard (multiple data buses); VLIW or SIMD; hardware MAC; zero-overhead loops|16/32-bit fixed or floating|150–1,500 MHz|on-chip SRAM (KB–MB); external interface|hardware multipliers, DMA, serial ports, timers; optimized for repetitive math|varies|audio/speech processing, radar, software-defined radio, motor control, medical imaging, telecom baseband

# communication_interfaces(id|name|type|topology|speed|distance|wires|duplex|voltage_levels|applications)
CI1|UART/RS-232|serial, asynchronous|point-to-point|300 bps–1 Mbps (UART); RS-232: 20 kbps max|RS-232: ~15 m|2 (TX, RX) + GND; RS-232: adds RTS, CTS, etc.|full (2 wires)|UART: logic (3.3/5 V); RS-232: ±3–15 V|debug console, GPS, Bluetooth module, modem, legacy PC serial
CI2|SPI (Serial Peripheral Interface)|serial, synchronous|master-slave (single master); 1 CS per slave|up to 100 Mbps (device-dependent)|PCB-level (~30 cm)|4: SCLK, MOSI, MISO, CS (+ additional CS per slave)|full|logic (3.3/5 V)|flash memory, ADC/DAC, display, sensor, SD card, FPGA configuration
CI3|I²C (Inter-Integrated Circuit)|serial, synchronous|multi-master, multi-slave; addressable (7-bit or 10-bit address)|100 kbps (standard), 400 kbps (fast), 1 Mbps (fast-mode plus), 3.4 Mbps (high-speed)|PCB-level (~1 m with buffers)|2: SDA, SCL (+ GND)|half|open-drain + pull-up; logic (3.3/5 V)|sensor, EEPROM, RTC, GPIO expander, power management IC, temperature sensor
CI4|CAN (Controller Area Network)|serial, asynchronous, differential|multi-master bus; message-based (no address: ID + priority)|125 kbps–1 Mbps (Classic CAN); 5 Mbps data (CAN FD)|up to 40 m at 1 Mbps; 1 km at 50 kbps|2: CAN_H, CAN_L (twisted pair)|half|differential: recessive 2.5 V (both), dominant: H=3.5 V, L=1.5 V|automotive (OBD-II), industrial, medical, robotics
CI5|RS-485|serial, asynchronous, differential|multi-drop (up to 32 devices; 256 with repeaters)|up to 10 Mbps|up to 1,200 m (at lower speeds)|2 (half-duplex) or 4 (full-duplex) + GND|half or full|differential: ±200 mV minimum|industrial (Modbus RTU), building automation, POS systems, long-distance serial
CI6|USB (Universal Serial Bus)|serial, packet-based|host-device (tiered star); USB 2.0 hub cascade|USB 1.1: 12 Mbps; USB 2.0: 480 Mbps; USB 3.2 Gen 2: 10 Gbps; USB4: 40 Gbps|5 m (cable); longer with hubs|USB 2.0: 4 (V+, D+, D−, GND); USB 3.x: 9; USB-C: 24|half (2.0); full (3.x, separate TX/RX pairs)|logic: D+/D− 0–3.3 V (NRZI encoded)|PC peripheral, mobile charging/data, mass storage, audio, HID, debug (CDC)
CI7|Ethernet (IEEE 802.3)|serial, packet-based, differential|star (switch/hub center); full-duplex with switch|10 Mbps–400 Gbps|100 m (copper Cat5e/6/6a); km (fiber)|8 (4 pairs, Cat5e+) or 2 fibers|full (switched)|differential: ±1 V (100BASE-TX); PAM-16 (10GBASE-T)|LAN, industrial (PROFINET, EtherNet/IP, EtherCAT), data center, IoT, automotive Ethernet (100BASE-T1)
CI8|I²S (Inter-IC Sound)|serial, synchronous|master-slave|varies with sample rate × bit depth × channels (e.g., 48 kHz × 32 bit × 2 = 3.072 Mbps)|PCB-level|3: SCK, WS, SD (+ additional SD for more channels)|half (per line); separate TX/RX lines for full|logic (3.3/5 V)|digital audio: MCU to codec/DAC/ADC, MEMS microphone, audio DSP
CI9|JTAG (IEEE 1149.1)|serial, synchronous|daisy-chain (multiple devices)|TCK: 10–100 MHz typical|PCB-level|5: TCK, TMS, TDI, TDO, TRST (optional)|half|logic (1.2–3.3 V)|IC debug, boundary scan test, FPGA/CPLD programming, flash programming, production test
CI10|MIPI CSI-2|serial, differential, high-speed|point-to-point (camera → processor)|up to 4.5 Gbps/lane (D-PHY); up to 12 Gbps/lane (C-PHY); 1–4 lanes|PCB/FPC-level (~30 cm)|2 wires/lane (D-PHY) + clock lane|simplex (camera → host)|differential LVDS-like: 200 mV swing|camera interface: smartphone, embedded vision, automotive, medical imaging

# power_supply(id|name|type|input|output|key_parameters|applications)
PW1|linear regulator (78xx/LM317)|series pass|7–35 V DC (unregulated)|fixed (7805 → 5 V) or adjustable (LM317: 1.25–37 V)|dropout ~2 V; efficiency = V_out/V_in; low noise; no switching EMI|low-current post-regulation; analog supply; legacy; simple circuits
PW2|LDO regulator|series pass (low dropout)|V_in > V_out + dropout (30–300 mV)|0.8–5 V typical (adjustable)|dropout 30–300 mV; PSRR 40–80 dB; noise 1–100 μV_rms; quiescent current 1 μA–5 mA|clean supply for ADC, RF, PLL, audio; battery rail (maximizes battery life by minimizing dropout)
PW3|buck regulator module|switching DC-DC|4.5–60 V DC (typical)|0.6–54 V adjustable|efficiency 85–98%; switching freq 100 kHz–4 MHz; output ripple 5–50 mV_pp; inductor integrated or external|point-of-load; 12V→3.3V/1.8V/1.0V rails; battery; industrial; automotive
PW4|AC-DC power supply (off-line SMPS)|switching|85–265 V AC (universal input)|3.3/5/12/24/48 V DC (single or multiple output)|PFC + LLC or flyback; efficiency >90%; safety isolation (reinforced); regulatory: UL/IEC/EN|equipment power (PC, server, industrial, telecom, medical, consumer electronics)
PW5|battery charger IC|mixed (linear or switching)|USB 5V, USB-PD (5–20V), AC adapter|battery voltage (Li-ion: 4.2V/cell; LiFePO₄: 3.6V/cell)|charge profile: CC-CV (constant current then constant voltage); cell balancing (multi-cell); temperature monitoring; safety cutoff|smartphone, laptop, power tool, EV BMS, wearable, IoT
PW6|PoE (Power over Ethernet)|DC-DC (extracted from Ethernet)|IEEE 802.3af: 15.4 W; 802.3at: 30 W; 802.3bt: 71/90 W at PSE|device voltage (3.3/5/12/24 V)|PD controller + isolated DC-DC; classification; inrush limiting|IP camera, access point, VoIP phone, IoT sensor, LED lighting

# pcb(id|name|aspect|specification|typical_values|considerations)
PB1|layer stackup|structure|number and arrangement of copper and dielectric layers|2-layer (simple); 4-layer (standard: SIG-GND-PWR-SIG); 6/8/10+ (complex)|ground/power plane placement critical for impedance control and EMI; signal layers referenced to adjacent plane
PB2|trace width|routing|determined by current capacity and impedance|IPC-2221: 1 oz Cu, 10°C rise: ~10 mil for 1 A (external); impedance: 50 Ω single-ended ~8 mil on 4-layer FR-4 with 8 mil dielectric|wider for power; narrower for signal; impedance calculator needed for controlled impedance
PB3|via|interconnect|plated through-hole connecting layers; blind (surface to inner), buried (inner to inner), microvia (laser-drilled)|PTH: 8–12 mil drill; microvia: 3–6 mil; via-in-pad (filled/capped) for BGA|via inductance ~1 nH/mm; minimize via stubs at high frequency (back-drilling); thermal vias under power pads
PB4|controlled impedance|signal integrity|trace geometry + dielectric constant → characteristic impedance|50 Ω single-ended; 90 Ω or 100 Ω differential (USB, Ethernet, LVDS)|requires impedance calculation (field solver); stackup tolerance; dielectric constant of FR-4 ~4.2–4.5; length matching for differential pairs
PB5|copper weight|material|thickness of copper foil|0.5 oz (17 μm), 1 oz (35 μm), 2 oz (70 μm), 3 oz (105 μm)|heavier copper for power; 1 oz standard; thermal and current-carrying capacity
PB6|solder mask|protection|polymer coating over copper except pads/vias|green (standard); other colors available; LPI (liquid photoimageable)|prevents solder bridges; insulation; cosmetic; opening defines pad size
PB7|silkscreen|marking|epoxy ink printed on solder mask|white (standard); component references, polarity marks, version, logos|aids assembly and debugging; keep out of pads
PB8|surface finish|solderability|coating on exposed copper pads|HASL (cheapest, uneven), ENIG (flat, Au over Ni, good for BGA), OSP (flat, cheap, limited shelf), immersion tin, immersion silver|ENIG: best flatness for fine-pitch; HASL: cheapest for through-hole; OSP: lead-free friendly
PB9|design rules|manufacturing|minimum feature sizes accepted by fabricator|trace/space: 3/3 mil (standard); 2/2 mil (advanced); drill: 8 mil (mechanical); 4 mil (laser)|tighter rules → higher cost; DFM check before submission
PB10|ground plane|EMC/signal integrity|continuous copper layer dedicated to ground return; provides low-impedance return path for all signals|unbroken plane under all signal traces; splits only if absolutely necessary (and bridge with capacitor)|most important single factor for signal integrity and EMI; slot in ground plane creates loop antenna

# test_equipment(id|name|type|measured_quantity|key_specifications|applications)
TE1|digital multimeter (DMM)|handheld/bench|voltage (AC/DC), current (AC/DC), resistance, continuity, capacitance, frequency, temperature|resolution 3.5–8.5 digits; accuracy ±0.01–1%; input impedance 10 MΩ (voltage)|universal first-line measurement; troubleshooting; verification
TE2|oscilloscope (digital storage)|bench|voltage vs time (waveform)|bandwidth (50 MHz–8 GHz); sample rate (1 GSPS–40 GSPS); channels (2–8); memory depth; triggering; math/FFT; serial decode|waveform visualization, timing analysis, signal integrity, debugging, power measurement (with probes)
TE3|logic analyzer|bench/USB|digital signals (multi-channel timing and state)|channels (8–136+); sample rate (up to 12.5 GHz); timing resolution; protocol decode (SPI, I²C, UART, CAN)|digital bus debugging, protocol analysis, timing verification, state machine debugging
TE4|spectrum analyzer|bench|signal amplitude vs frequency|frequency range (9 kHz–110 GHz); RBW (resolution bandwidth); dynamic range; phase noise; tracking generator|RF characterization, EMI pre-compliance, spurious search, harmonic analysis, filter response
TE5|network analyzer (VNA)|bench|S-parameters (reflection and transmission) vs frequency|frequency range (DC–110 GHz); dynamic range (>100 dB); port count (2–4); calibration (SOLT, TRL)|impedance matching, filter/amplifier characterization, antenna measurement, cable testing, PCB trace impedance
TE6|signal generator|bench|generates known test signal|frequency range; amplitude accuracy; modulation (AM/FM/PM/pulse); phase noise; waveform (sine, square, arbitrary)|receiver testing, filter characterization, component test, stimulus in stimulus-response measurement
TE7|power supply (bench)|bench|provides adjustable DC voltage and current|voltage range (0–60 V typical); current range (0–10 A typical); regulation; ripple/noise; OVP/OCP; tracking (series/parallel)|circuit development power, device characterization, burn-in, battery simulation
TE8|LCR meter|bench|impedance: L, C, R, Q, D, Z, θ|frequency range (20 Hz–2 MHz); basic accuracy ±0.05–1%; test signal level; DC bias|component characterization, incoming inspection, material characterization, quality control
TE9|thermal camera (IR)|handheld|surface temperature distribution (non-contact)|temperature range (−20 to 650°C); resolution (160×120 to 640×480); NETD (<50 mK); accuracy ±2°C|hot spot detection, power electronics thermal, PCB thermal debug, predictive maintenance, building inspection

# units_constants(id|name|symbol|value|unit|notes)
UC1|elementary charge|e|1.602176634 × 10⁻¹⁹|C|exact (SI 2019); charge of one electron/proton
UC2|Boltzmann constant|k_B|1.380649 × 10⁻²³|J/K|exact (SI 2019); thermal voltage V_T = k_BT/q ≈ 25.85 mV at 300 K
UC3|thermal voltage (at 300 K)|V_T|~25.85|mV|V_T = k_BT/q; appears in diode equation, BJT equations, noise calculations
UC4|permittivity of free space|ε₀|8.854187817 × 10⁻¹²|F/m|capacitor calculations; electromagnetic wave propagation
UC5|permeability of free space|μ₀|1.25663706212 × 10⁻⁶|H/m|inductor calculations; magnetic field
UC6|speed of light|c|299,792,458|m/s|exact; propagation delay: ~5 ns/m in vacuum; ~6.7 ns/m in FR-4 (v_p ≈ 0.5c)
UC7|Planck constant|h|6.62607015 × 10⁻³⁴|J·s|photon energy E = hf; relevant in optoelectronics, quantum devices
UC8|impedance of free space|Z₀|~376.73|Ω|Z₀ = √(μ₀/ε₀); antenna and EMC calculations
UC9|electron mass|m_e|9.1093837015 × 10⁻³¹|kg|semiconductor physics
UC10|silicon bandgap|E_g(Si)|1.12|eV (at 300 K)|determines junction behavior; V_F ≈ 0.6–0.7 V; bandgap reference ~1.25 V
UC11|GaN bandgap|E_g(GaN)|3.4|eV|wide bandgap → higher breakdown field, higher operating temperature
UC12|SiC bandgap|E_g(SiC)|3.26|eV (4H-SiC)|wide bandgap → high-voltage, high-temperature capability

# failure_modes(id|name|mechanism|symptoms|prevention|affected_components)
FM1|electrostatic discharge (ESD)|charge transfer from human/equipment to device (~100 V–15 kV, ns rise time) → oxide breakdown, junction damage|latent defect or immediate failure; parametric shift; increased leakage|ESD-safe handling (wrist strap, mat, bags); on-chip ESD protection (TVS clamp); PCB design (guard rings)|MOSFET gate oxide, CMOS ICs, LEDs, sensors
FM2|electrical overstress (EOS)|voltage or current exceeding absolute maximum rating → thermal damage, metallization melt, bond wire fuse|burn marks; short circuit; open circuit; parametric degradation|proper supply decoupling; transient protection (TVS, fuse, clamping); derating; inrush limiting|all semiconductor devices; passives (overvoltage on capacitors)
FM3|thermal failure|junction temperature exceeds rating → parameter drift, electromigration, solder joint fatigue, delamination|intermittent operation; smoke; parametric shift; early failure|thermal design (heatsink, fan, thermal pad, copper pour); derating; thermal simulation|power semiconductors, voltage regulators, LEDs, high-power resistors
FM4|solder joint failure|thermal cycling → CTE mismatch → fatigue crack in solder joint; vibration → mechanical fatigue; corrosion (dendritic growth)|intermittent connection; increased resistance; open circuit|proper reflow profile; adequate pad design; underfill (BGA); conformal coating; lead-free alloy selection|BGA (most susceptible due to thermal stress); QFP, through-hole; connectors
FM5|electromigration|high current density in IC metallization (~10⁵–10⁶ A/cm²) → metal ion migration → void formation (open) or hillock (short)|gradual resistance increase; eventual open circuit; latency years|design rule compliance (current density limits); wider metal traces; Cu metallization (better than Al); lower temperature|IC interconnects; bond wires; fine-pitch PCB traces at high current
FM6|latch-up|parasitic thyristor (PNPN) in CMOS triggered by overvoltage or radiation → low-impedance path from V_DD to GND → destructive current|sudden high supply current; IC destruction if not current-limited|guard rings in layout; proper power sequencing (never drive I/O before supply); current limiting; latch-up-immune process|CMOS ICs; FPGAs; ADCs
FM7|tin whisker|spontaneous growth of conductive tin filament from lead-free solder or tin plating; can bridge adjacent conductors|intermittent short circuit; potentially catastrophic in high-reliability|use tin-lead where allowed (military); conformal coating; Ni underplate; annealing; design spacing|lead-free assemblies; connectors; relay pins
FM8|capacitor degradation|electrolytic: electrolyte dry-out → ESR increase, capacitance loss; ceramic (MLCC): DC bias derating (X7R/X5R lose capacitance under DC bias); aging|power supply ripple increase; instability; failure to meet voltage regulation; reduced filtering|derate voltage (50–80% of rating); temperature control; select C0G/NP0 for stable applications; check DC bias curves for MLCC|electrolytic capacitors (lifespan doubles per 10°C reduction); MLCC (DC bias effect critical in decoupling)
FM9|moisture ingress|humidity → corrosion, dendritic growth, insulation breakdown; moisture sensitivity of IC packages (MSL levels)|leakage current increase; intermittent shorts; parametric drift|conformal coating; proper storage (dry pack, MSL handling per J-STD-033); sealed enclosure; potting|PCBs in humid environments; moisture-sensitive devices (BGA, QFN)

# safety(id|standard|scope|key_requirements|applications)
SF1|IEC 61010|safety of electrical equipment for measurement, control, and laboratory|insulation (basic/supplementary/reinforced), creepage/clearance distances, protective earth, enclosure (IP rating), temperature limits|test equipment, industrial instruments, lab devices
SF2|IEC 62368-1|safety of audio/video, information and communication technology equipment (replaced 60950 and 60065)|hazard-based approach: energy source classification (ES1, ES2, ES3); safeguard classes; insulation; touch current limits|consumer electronics, IT equipment, telecom, AV equipment
SF3|IEC 61508 / IEC 61511|functional safety of electrical/electronic/programmable electronic safety-related systems|SIL 1–4; hardware fault tolerance; diagnostic coverage; proof testing; systematic capability|industrial safety systems, process industry, machinery, automotive (ISO 26262 derived)
SF4|UL 60950 / UL 62368|North American safety listing|similar to IEC counterparts; additional UL-specific requirements; NRTL listing|equipment sold in North America
SF5|IEC 60529 (IP rating)|degrees of protection provided by enclosures|IP[X][Y]: X=solids (0–6); Y=liquids (0–9K); e.g., IP67 = dust-tight + 1 m submersion|enclosure design for all environments
SF6|IEC 61000 series (EMC)|electromagnetic compatibility|IEC 61000-4-2 (ESD), -4-3 (radiated immunity), -4-4 (EFT), -4-5 (surge), -4-6 (conducted RF), -4-11 (voltage dip); emissions: CISPR 32|all electronic equipment; CE marking; FCC compliance

# concepts(id|name|definition|category)
ECC1|ground|reference node (0 V) for all voltages in circuit; earth ground (safety, connected to earth via third prong), chassis ground (enclosure), signal ground (circuit reference), analog ground, digital ground|fundamental
ECC2|decoupling|placing capacitors (typically 100 nF MLCC + 10 μF bulk) between IC power pins and ground to provide local charge reservoir and filter high-frequency noise; minimizes supply impedance at IC|design_practice
ECC3|impedance matching|making source impedance equal to load impedance (conjugate match for max power transfer; characteristic impedance match for no reflection on transmission line)|design_practice
ECC4|feedback (negative)|portion of output returned to input in opposition; reduces gain but improves linearity, bandwidth, stability, output impedance; foundation of amplifier design|principle
ECC5|feedback (positive)|portion of output returned to input in reinforcement; creates bistability (flip-flop, Schmitt trigger) or sustained oscillation (oscillator)|principle
ECC6|noise figure (NF)|measure of noise added by component or system; NF = 10log₁₀(F); F = SNR_in/SNR_out; Friis formula for cascaded stages: F_total = F₁ + (F₂−1)/G₁ + ...|metric
ECC7|thermal management|removing heat from electronic components to keep junction temperature within rated limits; thermal resistance chain: junction → case → heatsink → ambient; θ_JA = θ_JC + θ_CS + θ_SA|design_practice
ECC8|derating|operating component below absolute maximum to extend life and improve reliability; typical: 50–80% of voltage rating (capacitor); 60–80% of current (resistor, semiconductor)|design_practice
ECC9|power integrity|ensuring clean, stable power delivery to all ICs; includes PDN (power distribution network) impedance, decoupling strategy, target impedance Z_target = V_ripple / I_transient|design_practice
ECC10|signal integrity|ensuring digital/analog signals arrive at receiver undistorted; includes impedance control, termination, crosstalk, ISI, jitter, eye diagram|design_practice
ECC11|EMI/EMC|electromagnetic interference generation (emissions) and susceptibility (immunity); differential mode (signal path) and common mode (ground path); filter, shield, ground to mitigate|design_practice
ECC12|galvanic isolation|no direct electrical connection between two circuit sections; achieved via transformer, optocoupler, capacitive isolator, or magnetic isolator; provides safety and breaks ground loops|design_practice
ECC13|Nyquist-Shannon sampling theorem|to perfectly reconstruct a band-limited signal, sampling rate must be ≥ 2× highest frequency component; f_sample ≥ 2 × f_max; aliasing occurs below this rate|principle
ECC14|quantization|mapping continuous amplitude to discrete levels; n-bit ADC → 2ⁿ levels; LSB = V_ref / 2ⁿ; quantization noise: SNR_q = 6.02n + 1.76 dB (for sinusoidal input)|principle
ECC15|duty cycle|fraction of period during which signal is active (high); D = t_on / T; 0–100%; key parameter in PWM and SMPS|metric
ECC16|slew rate|maximum rate of change of output voltage; SR = dV/dt max (V/μs); limits maximum undistorted frequency at full output swing: f_max = SR/(2πV_pk)|metric
ECC17|CMRR (common-mode rejection ratio)|ability to reject signals common to both inputs; CMRR = 20log₁₀(A_diff/A_CM) dB; higher is better; critical for differential and instrumentation amplifiers|metric
ECC18|PSRR (power supply rejection ratio)|ability of regulator or amplifier to reject power supply noise from appearing at output; PSRR = 20log₁₀(ΔV_supply/ΔV_out) dB|metric

# relationships(from|rel|to)
# domain hierarchy
DM1|enables|DM2
DM1|enables|DM3
DM2|enables|DM4
DM2|enables|DM5
DM2|enables|DM7
DM3|enables|DM6
DM5|enables|DM3
DM5|enables|DM2
DM8|requires|DM2
DM8|requires|DM3
DM8|requires|DM5
# fundamental law dependencies
FN9|requires|FN1
FN9|requires|FN2
FN9|requires|FN3
FN10|requires|FN2
FN11|requires|FN1
FN6|composed_of|FN3,FN4,FN5
FN7|requires|FN1,FN2
FN12|derived_from|FN9,FN10,FN11
FN13|equivalent_to|FN12
FN17|requires|FN4,FN5
FN18|determined_by|FN17
FN16|determined_by|FN3,FN4
FN16|determined_by|FN3,FN5
FN19|determined_by|FN8
# passive → active dependencies
PC1|enables|CT1
PC1|enables|CT2
PC2|enables|FL1
PC2|enables|PE3
PC3|enables|PE3
PC3|enables|FL3
PC4|enables|PE6
PC4|enables|ECC12
PC5|enables|OS3
PC6|prevents|FM2
# semiconductor hierarchy
SD1|generalizes|SD2
SD1|generalizes|SD3
SD8|generalizes|SD14
SD8|generalizes|SD15
SD11|composed_of|SD8,SD6
SD6|enables|AT1,AT2,AT3
SD8|enables|AT4,AT5
SD8|enables|PE1,PE2,PE3
SD11|enables|PE10
SD12|enables|PE11
# active IC dependencies
IC1|requires|ECC4
IC1|enables|CT3,CT4,CT5,CT6,CT7,CT8,CT9
IC2|specializes|IC1
IC3|requires|SD8
IC3|requires|IC4
IC4|enables|IC5,IC6
IC5|requires|ECC13
IC5|requires|ECC14
IC13|enables|OS6
IC13|requires|IC9
# power electronics chain
PE11|precedes|PE8
PE8|requires|PE1
PE3|requires|SD8,PC3,PC2
PE4|requires|SD8,PC3,PC2
PE6|requires|PC4,SD8
PE10|requires|PE1,SD11,PE12
PE12|enables|PE1,PE2,PE10
# filter dependencies
FL1|requires|PC1,PC2
FL2|requires|PC1,PC2
FL3|requires|PC3,PC2
FL9|requires|IC1
FL6|specializes|FL9
FL7|specializes|FL9
FL8|specializes|FL9
# oscillator dependencies
OS1|requires|IC1
OS2|requires|SD6,PC3,PC2
OS3|requires|PC5,IC8
OS6|requires|SD1
# modulation → communication
MO5|enables|CI7
MO6|enables|CI7
MO7|enables|CI7
MO9|requires|IC5,IC6
# digital foundations
DF1|enables|DF2
DF1|enables|DF3
DF2|requires|IC8
DF3|requires|IC9
DF4|requires|DF3
DF4|enables|IC10,MC1
DF8|requires|DF3
DF5|enables|DF6,DF7
# memory hierarchy
ME1|enables|MC1
ME3|enables|MC1
ME4|enables|MC7
ME2|enables|MC7
ME1|precedes|ME2
# MCU hierarchy
MC1|specializes|MC3
MC3|specializes|MC4
MC4|specializes|MC5
MC7|extends|MC5
MC8|specializes|MC4
MC6|equivalent_to|MC4
# communication → MCU
CI1|enables|MC1
CI2|enables|MC1
CI3|enables|MC1
CI4|enables|MC4
CI6|enables|MC4
CI7|enables|MC5
CI9|enables|IC10
# power supply dependencies
PW1|requires|SD1,IC3
PW2|specializes|PW1
PW3|requires|PE3
PW4|composed_of|PE11,PE8
PW4|requires|PC4
PW5|requires|IC5,SD8
# PCB design principles
PB10|enables|ECC9
PB10|enables|ECC10
PB10|enables|ECC11
PB4|enables|ECC10
PB1|enables|PB4
PB2|determined_by|FN3,PB5
PB3|enables|PB1
# test equipment → measurement
TE1|enables|DM1
TE2|enables|DM2,DM3,ECC10
TE3|enables|DM3
TE4|enables|DM4,DM8
TE5|enables|DM4,ECC3
TE7|enables|DM1,DM2
TE9|enables|ECC7
# concept → design practice
ECC2|prevents|FM2
ECC2|requires|PC2
ECC3|enables|DM4
ECC4|enables|IC1
ECC5|enables|OS1,IC9
ECC7|prevents|FM3
ECC8|prevents|FM2,FM3
ECC9|requires|PB10,PC2
ECC10|requires|PB4,PB10
ECC11|requires|PB10,FL3
ECC12|requires|PC4
ECC12|requires|OE5
ECC13|enables|IC5
ECC14|determined_by|IC5
ECC6|determined_by|IC1,SG5
ECC17|determined_by|CT5,CT6
ECC18|determined_by|IC3
# failure mode connections
FM1|prevents|SD8,IC10
FM2|prevents|SD8,PC2
FM3|prevents|SD8,SD4,IC3
FM4|prevents|PC2,SD11
FM5|prevents|IC10
FM6|prevents|IC10,IC5
FM8|prevents|PC2,IC3
# optoelectronics
OE2|enables|CI10
OE5|enables|ECC12
OE8|enables|PE4
SD4|specializes|SD1
SD5|specializes|SD1
# safety
SF1|requires|ECC12
SF3|requires|DM5
SF6|requires|DM8
# signal types
SG1|instance_of|DM1
SG2|instance_of|DM2
SG3|enables|DM3
SG5|prevents|DM7
SG6|instance_of|DM3
SG7|enables|DM5,PE3
SG8|enables|DM4,CI4,CI5

# section_index(section|title|ids)
1|Domains|DM1-DM8
2|Fundamentals (Laws and Quantities)|FN1-FN20
3|Passive Components|PC1-PC9
4|Semiconductor Devices|SD1-SD15
5|Active Components (ICs)|IC1-IC14
6|Optoelectronics|OE1-OE8
7|Power Electronics Topologies|PE1-PE12
8|Signal Types|SG1-SG8
9|Circuit Topologies|CT1-CT10
10|Filters|FL1-FL10
11|Amplifier Topologies|AT1-AT9
12|Oscillators|OS1-OS8
13|Modulation|MO1-MO10
14|Digital Foundations|DF1-DF9
15|Logic Families|LF1-LF8
16|Memory|ME1-ME8
17|Microcontrollers and Processors|MC1-MC8
18|Communication Interfaces|CI1-CI10
19|Power Supply|PW1-PW6
20|PCB Design|PB1-PB10
21|Test Equipment|TE1-TE9
22|Units and Constants|UC1-UC12
23|Failure Modes|FM1-FM9
24|Safety Standards|SF1-SF6
25|Design Concepts|ECC1-ECC18
26|Relationships|all

# decode_legend
id_prefixes: DM=domain, FN=fundamental, PC=passive_component, SD=semiconductor_device, IC=active_component, OE=optoelectronic, PE=power_electronic, SG=signal_type, CT=circuit_topology, FL=filter, AT=amplifier_topology, OS=oscillator, MO=modulation, DF=digital_foundation, LF=logic_family, ME=memory, MC=microcontroller, CI=communication_interface, PW=power_supply, PB=pcb, TE=test_equipment, UC=unit_constant, FM=failure_mode, SF=safety_standard, ECC=concept
rel_types: enables|requires|prevents|specializes|generalizes|part_of|contains|follows|precedes|instance_of|determined_by|equivalent_to|extends|derived_from|composed_of
notation: _fk=foreign key; ~=approximate; ±=plus or minus; ∝=proportional to; Σ=summation; ∫=integral; V_F=forward voltage; V_R=reverse voltage; V_Z=zener voltage; R_DS(on)=drain-source on-resistance; V_GS(th)=gate-source threshold; Q_g=gate charge; h_FE=DC current gain (β); g_m=transconductance; f_T=transition frequency; GBW=gain-bandwidth product; CMRR=common-mode rejection ratio; PSRR=power supply rejection ratio; ESR=equivalent series resistance; ESL=equivalent series inductance; SRF=self-resonant frequency; SNR=signal-to-noise ratio; SINAD=signal to noise and distortion; ENOB=effective number of bits; DNL=differential nonlinearity; INL=integral nonlinearity; BER=bit error rate; THD=total harmonic distortion; EMI=electromagnetic interference; ESD=electrostatic discharge; EOS=electrical overstress; CTE=coefficient of thermal expansion; PCB=printed circuit board; MLCC=multilayer ceramic capacitor; SMD=surface-mount device; BGA=ball grid array; QFP=quad flat package; QFN=quad flat no-lead; LDO=low-dropout regulator; SMPS=switch-mode power supply; PFC=power factor correction; PWM=pulse width modulation; ADC=analog-to-digital converter; DAC=digital-to-analog converter; PLL=phase-locked loop; VCO=voltage-controlled oscillator; FPGA=field-programmable gate array; CPLD=complex programmable logic device; MCU=microcontroller; DSP=digital signal processor; MPU=microprocessor unit; SRAM=static random-access memory; DRAM=dynamic random-access memory; UART=universal asynchronous receiver-transmitter; SPI=serial peripheral interface; I²C=inter-integrated circuit; CAN=controller area network; USB=universal serial bus; JTAG=joint test action group; LVDS=low-voltage differential signaling; VNA=vector network analyzer; DMM=digital multimeter; IP=ingress protection
units: V=volt; A=ampere; Ω=ohm; F=farad; H=henry; W=watt; Hz=hertz; s=second; dB=decibel; dBm=decibel-milliwatt; ppm=parts per million; °C=degrees Celsius; eV=electron volt; m=meter; mm=millimeter; μm=micrometer; nm=nanometer; mil=thousandth of inch (25.4 μm); oz=ounce (copper weight: 1 oz ≈ 35 μm)
confidence: component parameters are typical/nominal from manufacturer datasheets and industry references; actual values vary by manufacturer and part number; all facts at reference_electronics confidence level
scope: electronics from passive components through system-level design; covers analog, digital, power, RF fundamentals, embedded systems, PCB design, test, and safety; excludes detailed semiconductor process fabrication, antenna design theory, and software/firmware architecture beyond interface description

# relation_mapping(doc_rel|canonical_rel|notes)
enables|enables|exact match
requires|requires|exact match
prevents|prevents|exact match; symmetric
specializes|specializes|exact match
generalizes|generalizes|exact match
part_of|part_of|exact match
contains|contains|exact match
follows|follows|exact match
precedes|precedes|exact match
instance_of|instance_of|exact match
determined_by|determined_by|exact match
equivalent_to|equivalent_to|exact match; symmetric
extends|extends|exact match
derived_from|derived_from|exact match
composed_of|composed_of|exact match

# relation_mapping(doc_rel|canonical_rel|notes)
generates|produces|exact semantic match; X generates Y = X produces Y
requires|requires|exact match
assumes|requires|X assumes Y = X requires Y as precondition
drives|causes|X drives Y = X causes Y
interacts_with|connects_to|symmetric interaction; closest symmetric relation
signals|indicates|X signals Y = X indicates Y
implements|implements|exact match
measures|measured_by|inverse direction; "IC1 measures CO44" → CO44 measured_by IC1; stored as written, inverse() resolves
governed_by|determined_by|X governed by Y = X determined_by Y
explains|explains|exact match
constrains|constrains|exact match
represents|models|X represents Y = X models Y
derives_from|derived_from|exact match
determines|determined_by|inverse direction; "CO21 determines CO7" → CO7 determined_by CO21
characterizes|composed_of|inverse; X characterizes Y = Y composed_of properties X describes
derived_from|derived_from|exact match
caused_by|causes|inverse direction; "CO16 caused by CO29" → CO29 causes CO16
violates|prevents|X violates Y = X prevents Y from holding
specializes|specializes|exact match
enables|enables|exact match
contrasts|contrasts|exact match; symmetric
reduces|degrades|X reduces Y = X degrades Y
affects|influences|exact match in intent
balances|regulates|X balances Y = X regulates Y
governs|governs|exact match
amplifies|amplifies|exact match
offsets|mitigated_by|inverse; "CO52 offsets PI7" → PI7 mitigated_by CO52
relates|connects_to|X relates Y = bidirectional link
predicted_by|determined_by|X predicted by model Y = X determined_by Y
modifies|extends|X modifies Y = X extends Y with changes
part_of|part_of|exact match
formalizes|models|X formalizes Y = X models Y precisely
transfers|produces|X transfers Y = X produces Y in new location
threatens|threatens|exact match
disrupts|disrupts|exact match
augments|extends|X augments Y = X extends Y's capacity
analyzes|models|X analyzes Y = X models Y for understanding
defines|implements|inverse; "TK1 defined CO26" → CO26 implemented/created by TK1; closest: implements
precedes|precedes|exact match
extends|extends|exact match
critiques|critiques|exact match
responds_to|responds_to|exact match
synthesizes|synthesizes|exact match
integrates|synthesizes|X integrates Y = X synthesizes multiple Y
founded|founded|exact match
defined|founded|"TK1 defined CO26" = TK1 founded/originated CO26
models|models|exact match
achieves|implements|X achieves Y = X implements Y successfully
addresses|solves|X addresses Y = X solves problem Y
corrects|mitigated_by|inverse; "PI8 corrects CO29" → CO29 mitigated_by PI8
causes|causes|exact match
counteracts|mitigated_by|inverse; "PI11 counteracts CO29" → CO29 mitigated_by PI11
prevents|prevents|exact match
anchors|regulates|X anchors Y = X regulates Y to stability
adjusts|transforms_to|X adjusts Y = Y transforms_to corrected form
normalizes|transforms_to|X normalizes Y = Y transforms_to normalized form
leads|precedes|X leads Y = X precedes Y temporally
refines|specializes|X refines Y = X specializes Y with more precision
predicts|indicates|X predicts Y = X indicates Y
stabilizes|regulates|X stabilizes Y = X regulates Y
promotes|enables|X promotes Y = X enables Y
enforces|validates|X enforces Y = X validates Y compliance
coordinates|orchestrates|X coordinates Y = X orchestrates Y
disputes|opposes|X disputes Y = X opposes Y
reconciles|synthesizes|X reconciles Y = X synthesizes opposing Y
approaches|enables|X approaches Y = X enables movement toward Y
distinguishes|distinguishes|exact match
illustrates|explains|X illustrates Y = X explains Y via example
