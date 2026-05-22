# RADIO & CELLULAR COMMUNICATIONS — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: concepts → electromagnetic → propagation → modulation → antenna → analog_systems → digital_systems → cellular_generations → cellular_architecture → protocols → spectrum → components → signal_processing → failure_modes → distinctions → relationships → decode_legend

# concepts(id|name|definition|category)
CO1|Electromagnetic Radiation|self-propagating transverse wave of electric and magnetic fields oscillating perpendicular to each other and to direction of travel; speed c ≈ 3×10⁸ m/s in vacuum|foundation
CO2|Frequency|number of wave cycles per second; measured in hertz (Hz); f = c/λ; higher frequency = shorter wavelength = higher energy per photon|foundation
CO3|Wavelength|physical distance of one complete wave cycle; λ = c/f; determines antenna size, propagation behavior, penetration|foundation
CO4|Amplitude|magnitude of wave oscillation; determines signal power; measured in volts (electric field) or watts (power)|foundation
CO5|Phase|position within wave cycle at given time; measured in degrees (0-360°) or radians (0-2π); phase differences enable modulation and beamforming|foundation
CO6|Bandwidth|range of frequencies occupied by signal; BW = f_high - f_low; wider bandwidth = more data capacity; Shannon limit governs|foundation
CO7|Signal-to-Noise Ratio (SNR)|ratio of desired signal power to noise power; usually in dB; SNR = 10 log₁₀(P_signal/P_noise); higher SNR = better reception|foundation
CO8|Channel Capacity (Shannon)|maximum information rate over noisy channel; C = B × log₂(1 + SNR) bits/second; fundamental limit; cannot be exceeded|foundation
CO9|Decibel (dB)|logarithmic ratio unit; power: dB = 10 log₁₀(P₁/P₂); voltage: dB = 20 log₁₀(V₁/V₂); dBm = dB relative to 1 mW; dBi = dB relative to isotropic antenna|foundation
CO10|Carrier Wave|continuous wave at fixed frequency onto which information is modulated; carries no information itself; modulation imparts information|foundation
CO11|Modulation|process of varying carrier wave properties (amplitude, frequency, phase) to encode information; demodulation reverses|foundation
CO12|Demodulation|extracting information from modulated carrier; performed by receiver; inverse of modulation; requires knowledge of modulation scheme|foundation
CO13|Multiplexing|combining multiple signals onto shared medium; FDMA, TDMA, CDMA, OFDMA, SDMA; enables multiple simultaneous users|foundation
CO14|Duplex|bidirectional communication; FDD (frequency-division: separate frequencies for uplink/downlink) or TDD (time-division: alternating time slots)|foundation
CO15|Transceiver|combined transmitter and receiver in single unit; alternates or operates simultaneously depending on duplex mode|foundation
CO16|Baseband|original information signal before modulation; audio, data, video; occupies frequencies from 0 to some maximum|foundation
CO17|Passband|frequency range occupied by modulated signal centered around carrier frequency; baseband shifted to carrier frequency region|foundation
CO18|Power Spectral Density (PSD)|distribution of signal power over frequency; watts per hertz; governs interference and regulatory compliance|foundation
CO19|Link Budget|accounting of all gains and losses between transmitter and receiver; P_received = P_transmitted + G_tx - L_path - L_other + G_rx; must exceed receiver sensitivity|foundation
CO20|Noise Figure (NF)|measure of noise added by receiver components; NF = SNR_in/SNR_out in dB; lower = better; first amplifier stage dominates (Friis formula)|foundation
CO21|Sensitivity|minimum signal power receiver can detect with acceptable SNR; measured in dBm; typical: -90 to -120 dBm for cellular|foundation
CO22|Dynamic Range|ratio between strongest and weakest signal receiver can handle; limited by noise floor (bottom) and saturation/clipping (top)|foundation
CO23|Spectrum|range of electromagnetic frequencies; radio spectrum: 3 kHz to 300 GHz; regulated by national authorities (FCC, Ofcom, etc.) and ITU internationally|foundation
CO24|Interference|unwanted signal degrading desired signal; co-channel (same frequency), adjacent-channel (nearby frequency), inter-symbol (time spreading), self-interference|foundation
CO25|Fading|variation in signal strength over time, frequency, or space; multipath fading (constructive/destructive interference from reflections); slow fading (shadowing from obstacles)|propagation

# electromagnetic(id|band|frequency_range|wavelength_range|propagation_mode|penetration|primary_uses)
EM1|Extremely Low Frequency (ELF)|3-30 Hz|100,000-10,000 km|ground wave; penetrates seawater and earth|excellent (deep earth, deep ocean)|submarine communication; geophysical research
EM2|Very Low Frequency (VLF)|3-30 kHz|100-10 km|ground wave; follows earth curvature|very good (some building penetration)|navigation (Omega, historical); submarine communication; time signals
EM3|Low Frequency (LF)|30-300 kHz|10-1 km|ground wave; some skywave at night|good|AM longwave broadcast; navigation beacons (NDB); RFID (125-134 kHz)
EM4|Medium Frequency (MF)|300 kHz - 3 MHz|1000-100 m|ground wave (daytime); skywave at night (ionospheric reflection)|moderate|AM broadcast (530-1700 kHz); maritime communication; direction finding
EM5|High Frequency (HF)|3-30 MHz|100-10 m|skywave (ionospheric refraction); ground wave limited|moderate|shortwave broadcast; amateur radio; aviation HF; military; OTH radar; intercontinental before satellite
EM6|Very High Frequency (VHF)|30-300 MHz|10-1 m|line-of-sight with some diffraction; tropospheric scatter|limited building penetration|FM broadcast (87.5-108 MHz); TV channels 2-13; aviation voice; marine VHF; public safety
EM7|Ultra High Frequency (UHF)|300 MHz - 3 GHz|1 m - 10 cm|line-of-sight; some penetration of buildings; multipath from reflections|moderate (lower UHF penetrates better than upper)|TV (470-806 MHz); cellular (700 MHz-2.6 GHz); WiFi 2.4 GHz; GPS (1.575 GHz); Bluetooth; RFID; radar
EM8|Super High Frequency (SHF)|3-30 GHz|10-1 cm|line-of-sight; rain attenuation above 10 GHz; atmospheric absorption windows|poor|satellite communication; radar; WiFi 5 GHz; 5G mmWave (below); point-to-point microwave links; radio astronomy
EM9|Extremely High Frequency (EHF/mmWave)|30-300 GHz|10-1 mm|line-of-sight only; severe rain and atmospheric attenuation; oxygen absorption at 60 GHz|very poor; blocked by walls, foliage, rain|5G mmWave (24-47 GHz); point-to-point; automotive radar (76-81 GHz); airport security imaging; radio astronomy
EM10|Infrared|300 GHz - 400 THz|1 mm - 750 nm|line-of-sight; no penetration through walls|none through solids|TV remote; IrDA (historical); fiber optics (1310 nm, 1550 nm); thermal imaging; short-range data

# propagation(id|name|definition|frequency_dependence|distance|effects)
PG1|Free-Space Path Loss (FSPL)|signal attenuation in ideal unobstructed vacuum; inverse square law; FSPL(dB) = 20 log₁₀(d) + 20 log₁₀(f) + 32.44 (d in km, f in MHz)|increases with frequency (20 dB/decade) and distance (20 dB/decade)|any distance|fundamental loss; cannot be reduced except by antenna gain; doubles in dB every doubling of distance or frequency
PG2|Ground Wave|signal follows earth's surface due to diffraction; surface conductivity affects range|effective at LF and MF (< 3 MHz); diminishes rapidly above MF|hundreds to thousands of km at LF/MF|reliable daytime propagation at LF/MF; AM radio primary mode; diminishes with frequency and dry soil
PG3|Skywave (Ionospheric)|signal refracted by ionosphere back to earth; skip distance; multiple hops possible|HF (3-30 MHz); depends on ionospheric conditions (solar activity, time of day, season)|hundreds to thousands of km per hop; global with multiple hops|variable; day/night differences (D-layer absorbs by day); solar cycle affects maximum usable frequency (MUF); fading from ionospheric variation
PG4|Line-of-Sight (LOS)|direct path between transmitter and receiver; requires clear Fresnel zone; limited by earth curvature and terrain|VHF and above (>30 MHz); all microwave and mmWave|d(km) ≈ 4.12 × (√h_tx + √h_rx) where h in meters; ~50 km typical with towers|dominant mode above VHF; affected by terrain, buildings; Fresnel zone clearance needed (60% of first zone minimum)
PG5|Multipath|signal arrives via multiple reflected/diffracted/scattered paths; creates constructive and destructive interference|all frequencies but most problematic at UHF and above|urban environments primarily|Rayleigh fading (no LOS: many reflected paths); Rician fading (LOS + reflected paths); delay spread → inter-symbol interference; OFDM designed to handle multipath
PG6|Diffraction|signal bends around obstacles (hills, buildings); Huygens' principle; knife-edge diffraction model|better at lower frequencies (longer wavelength diffracts more); VHF/UHF diffract around buildings; mmWave almost none|extends LOS range slightly past obstruction|explains reception behind hills and buildings; amount of bending depends on wavelength/obstacle size ratio
PG7|Reflection|signal bounces off surfaces (buildings, ground, water); angle of incidence = angle of reflection|all frequencies; smooth surfaces relative to wavelength reflect well|multiple reflections create multipath|primary cause of multipath fading in urban areas; ground reflection modifies antenna pattern
PG8|Scattering|signal scattered by objects comparable to or smaller than wavelength; foliage, rain, rough surfaces|increases with frequency (rain scatter significant above 10 GHz); foliage scatter affects UHF+|relatively short range contributions|rain attenuation: 0.01 dB/km at 4 GHz → 1 dB/km at 10 GHz → 10 dB/km at 30 GHz; foliage loss: 0.2-1.0 dB/m at UHF
PG9|Atmospheric Absorption|specific gases absorb at specific frequencies; water vapor (~22 GHz, 183 GHz); oxygen (~60 GHz, 118 GHz)|frequency-selective; resonance absorption peaks|reduces range at affected frequencies|60 GHz oxygen absorption: ~15 dB/km (limits range but enables frequency reuse); water vapor absorption increases in rain/humidity
PG10|Fresnel Zone|ellipsoidal region between TX and RX where reflected signals can constructively/destructively interfere; first Fresnel zone most important|zone radius proportional to √(λ×d); larger at lower frequencies|affects link quality when zone obstructed|rule of thumb: 60% clearance of first Fresnel zone needed for near-free-space propagation; trees, buildings, terrain in Fresnel zone increase loss
PG11|Shadow Fading (Log-Normal)|slow signal strength variation caused by obstacles blocking path; modeled as log-normal distribution around mean path loss|all frequencies; more severe at higher frequencies (less diffraction)|10s of meters to 100s of meters correlation distance|standard deviation typically 4-12 dB depending on environment; outdoor urban ~8 dB; indoor ~5-7 dB
PG12|Fast Fading (Rayleigh/Rician)|rapid signal strength fluctuation from constructive/destructive multipath interference; varies over distances of λ/2|all frequencies; rate proportional to velocity and frequency|half-wavelength distance (cm at GHz frequencies)|Rayleigh: no LOS component; Rician: strong LOS + multipath; fading depth can be 30+ dB; diversity techniques combat fading
PG13|Ducting (Tropospheric)|temperature inversion traps signal in atmospheric duct; signal propagates far beyond LOS|VHF to microwave; most common at SHF|hundreds to thousands of km|unpredictable; can cause interference from distant transmitters; common over ocean and desert

# modulation(id|name|type|description|bandwidth_efficiency|robustness|primary_use)
MO1|Amplitude Modulation (AM)|analog|carrier amplitude varies with baseband signal; envelope = baseband waveform|low (2× baseband BW); DSB uses 2×, SSB uses 1×|poor (noise affects amplitude directly)|AM broadcast; aviation voice; simple receivers
MO2|Frequency Modulation (FM)|analog|carrier frequency varies with baseband signal; amplitude constant; deviation proportional to signal|wider than AM (~200 kHz for broadcast FM vs ~10 kHz for AM)|excellent (noise is amplitude; FM captures strongest signal; capture effect)|FM broadcast; analog TV audio; two-way radio; analog cellular (AMPS)
MO3|Single Sideband (SSB)|analog|AM with carrier and one sideband suppressed; only one sideband transmitted|very efficient (baseband BW only); 3 kHz for voice|moderate|HF amateur radio; HF military; maritime HF; most bandwidth-efficient analog voice
MO4|Amplitude Shift Keying (ASK)|digital|carrier amplitude switched between levels to represent bits; OOK = simplest (on/off)|1 bit/Hz (BASK); higher with multi-level|poor (noise susceptible)|simple RFID; optical communication (OOK); low-data-rate systems
MO5|Frequency Shift Keying (FSK)|digital|carrier frequency switched between discrete frequencies to represent bits|depends on deviation; typically 1-2 bit/Hz|good (inherits FM noise immunity)|paging; POCSAG; caller ID; early modems; Bluetooth (GFSK); LoRa (chirp variant)
MO6|Phase Shift Keying (PSK)|digital|carrier phase shifted between discrete values; BPSK (2 phases, 1 bit/symbol), QPSK (4 phases, 2 bits/symbol)|BPSK: 1 bit/Hz; QPSK: 2 bits/Hz; 8PSK: 3 bits/Hz|BPSK most robust; degrades with higher order|satellite; deep space (BPSK); QPSK: DVB-S, CDMA, LTE initial; 8PSK: EDGE, satellite
MO7|Quadrature Amplitude Modulation (QAM)|digital|combines amplitude and phase modulation; constellation of signal points; 16-QAM = 4 bits/symbol, 64-QAM = 6, 256-QAM = 8, 1024-QAM = 10|16-QAM: 4 bits/Hz; 64-QAM: 6; 256-QAM: 8; 1024-QAM: 10|degrades with higher order (points closer together → higher SNR needed); 256-QAM needs ~27 dB SNR|WiFi; LTE/5G; cable modem; microwave links; DVB; primary high-data-rate modulation family
MO8|Orthogonal Frequency-Division Multiplexing (OFDM)|digital multi-carrier|data spread across many closely-spaced orthogonal subcarriers; each subcarrier narrowband; resistant to multipath|very high aggregate; per-subcarrier efficiency varies with adaptive modulation|excellent multipath immunity (cyclic prefix absorbs delay spread); narrowband fading affects few subcarriers|WiFi (802.11a/g/n/ac/ax); LTE downlink; 5G NR; DVB-T; DAB; WiMAX; dominant wideband modulation
MO9|Code Division Multiple Access (CDMA)|digital spread-spectrum|each user assigned unique spreading code; all users transmit simultaneously on same frequency; receiver correlates with desired code|bandwidth expanded by spreading factor; spectral efficiency ~1-2 bit/Hz/cell with sectorization|near-far problem (strong signal overwhelms weak); power control critical; soft capacity (degrades gradually)|CDMA2000 (2G/3G); WCDMA (3G UMTS); GPS (spreading codes); military (anti-jam, LPI)
MO10|Orthogonal Frequency-Division Multiple Access (OFDMA)|digital multi-carrier multi-access|OFDM with subcarriers allocated to different users; each user gets subset of subcarriers per time slot|high; adaptive per user; resource blocks assigned dynamically|inherits OFDM multipath immunity; scheduling gain from multiuser diversity|LTE downlink; 5G NR; WiMAX; WiFi 6 (802.11ax); primary 4G/5G access scheme
MO11|Direct Sequence Spread Spectrum (DSSS)|digital spread-spectrum|baseband signal multiplied by high-rate pseudo-random code (chips); spreads signal over wide bandwidth; processing gain = chip rate / data rate|low spectral efficiency per user; processing gain = 10 log₁₀(chip_rate/data_rate)|resistant to narrowband interference (processing gain); low probability of intercept; anti-jam|GPS (C/A code: 1.023 Mchip/s); CDMA IS-95; 802.11b; military communications
MO12|Frequency Hopping Spread Spectrum (FHSS)|digital spread-spectrum|carrier frequency hops pseudo-randomly across wide band; dwell time per hop typically milliseconds|low per-hop; aggregate bandwidth wide|avoids narrowband interference; anti-jam; coexistence by hopping pattern orthogonality|Bluetooth (79 channels, 1600 hops/s); military radios; some cordless phones; 802.11 (original)
MO13|Minimum Shift Keying (MSK) / GMSK|digital|continuous-phase FSK with minimum frequency deviation; Gaussian filter smooths transitions (GMSK)|~1.35 bit/Hz (GMSK); compact spectrum (Gaussian filter reduces sidelobes)|good; constant envelope (efficient power amplifier); reduced spectral splatter|GSM (GMSK with BT=0.3); MSK used in satellite links
MO14|Chirp Spread Spectrum (CSS)|digital spread-spectrum|frequency sweeps linearly over bandwidth (chirp); up-chirp or down-chirp; correlation at receiver extracts data|low data rate; high processing gain|excellent range; immune to Doppler and multipath; simple receiver|LoRa (long-range IoT); radar; sonar
MO15|Pulse Position Modulation (PPM)|digital|information encoded in timing of pulses; used in optical and UWB communication|variable; depends on number of positions|moderate; timing sensitive to jitter|UWB (Ultra-Wideband); optical communication; IR remote control
MO16|Adaptive Modulation and Coding (AMC)|digital (meta-scheme)|dynamically select modulation order and code rate based on channel conditions (SNR feedback); higher SNR → higher order modulation → more bits/symbol|maximizes throughput for given channel conditions; ranges from QPSK 1/3 to 256-QAM 5/6 typically|always uses most robust scheme that channel supports; no fixed rate|LTE/5G (CQI → MCS table); WiFi (rate adaptation); satellite; all modern systems use AMC

# antenna(id|name|type|gain_dBi|pattern|bandwidth|size|primary_use)
AN1|Isotropic (Theoretical)|reference|0 dBi|perfect sphere; equal radiation in all directions|infinite (theoretical)|point (theoretical)|reference for gain measurements; does not physically exist; all real antenna gains measured relative to isotropic
AN2|Dipole (Half-Wave)|wire|2.15 dBi|donut (toroidal); maximum radiation perpendicular to axis; null along axis|~10% of center frequency|λ/2 length (~15 cm at 1 GHz)|fundamental antenna; FM radio; base for many designs; reference antenna (dBd = dBi - 2.15)
AN3|Monopole (Quarter-Wave)|wire|2.15 dBi (over ground plane; 5.15 dBi including image)|hemisphere (half of dipole pattern); ground plane provides mirror image|~10% of center frequency|λ/4 length (~7.5 cm at 1 GHz)|vehicle antennas; handheld radios; cellular base station (ground plane = tower/building)
AN4|Yagi-Uda|directional array|6-20 dBi (depends on number of elements)|directional beam with main lobe, side lobes, back lobe; front-to-back ratio 15-30 dB|~5-10% of center frequency|several wavelengths long|TV reception; amateur radio; point-to-point; WiFi directional; simple high-gain
AN5|Parabolic Dish|aperture|20-60 dBi (proportional to dish diameter/λ)|highly directional pencil beam; very narrow beamwidth θ ≈ 70λ/D degrees|~10-20% typically; wideband feeds available|diameter must be >> λ; 0.3-30 m typical|satellite communication; radar; radio astronomy; microwave backhaul; deep space communication
AN6|Patch (Microstrip)|planar|5-9 dBi per element|hemispherical; directional perpendicular to patch surface|~2-5% (narrow; techniques to widen)|λ/2 × λ/2 approximately; very thin (< λ/10)|mobile phones; GPS receivers; WiFi; arrays on circuit board; conformal (curved surface) mounting
AN7|Phased Array|array of elements|depends on number of elements N; gain ≈ 10 log₁₀(N) + element gain|electronically steerable beam; beam direction changed by phase shifting element signals; no mechanical movement|wideband possible with proper design|array of λ/2-spaced elements; 64-256 elements common in 5G|5G massive MIMO; radar (AESA); satellite; military; beamforming is defining feature
AN8|Omnidirectional (Collinear)|array|5-12 dBi|pancake pattern; radiation concentrated in horizontal plane; null above and below|moderate|vertically stacked elements; tall (several λ)|cellular base station; broadcast; marine; public safety; maximizes horizontal coverage
AN9|Helical (Axial Mode)|wire|10-15 dBi|circular polarization; directional along helix axis|~70% bandwidth (very wideband)|circumference ≈ λ; length = Nλ/4|satellite uplink/downlink; GPS reception; circular polarization applications; telemetry
AN10|Horn|aperture|10-25 dBi|directional; smooth pattern; low sidelobes|very wideband (octave or more)|flared waveguide; length scales with gain|feed for parabolic dishes; radar; calibration reference; microwave links; EMC testing
AN11|MIMO Array (Massive)|array of independent elements|proportional to number of elements; 128-256 elements typical for massive MIMO|multiple independent beams simultaneously; spatial multiplexing + beamforming|wideband|panel of 64-256 dual-polarized elements|5G base station; LTE-Advanced; spatial multiplexing; multiuser MIMO; orders of magnitude capacity increase
AN12|Small Cell Antenna|varies (patch, dipole, omnidirectional)|2-8 dBi|omnidirectional or sector|wideband (cellular bands)|compact; designed for pole/wall mount|small cells (femto, pico, micro); WiFi access points; indoor coverage; densification

# analog_systems(id|name|era|frequency_band|modulation|channel_spacing|capacity|notes)
AS1|AM Broadcasting|1920s onward|MF (530-1700 kHz)|AM (DSB-FC)|10 kHz (Americas); 9 kHz (elsewhere)|single program per channel; ~4.5 kHz audio|ground wave propagation; simple receivers; susceptible to noise and interference; declining use
AS2|FM Broadcasting|1940s onward|VHF (87.5-108 MHz)|FM; 75 kHz deviation; stereo via 19 kHz pilot + 38 kHz subcarrier|200 kHz (includes guard bands)|single stereo program per channel; ~15 kHz audio|superior audio quality to AM; capture effect rejects interference; line-of-sight; RDS data subcarrier
AS3|Shortwave Broadcasting|1920s onward|HF (3-30 MHz)|AM (DSB-FC or SSB)|5 or 10 kHz|single program per channel|ionospheric propagation; international broadcasting; conditions vary with solar cycle; declining but still used
AS4|Citizens Band (CB)|1940s onward|HF/VHF (27 MHz; 40 channels)|AM and SSB|10 kHz|40 channels shared (no individual assignment)|unlicensed; 4W AM / 12W SSB; truckers, personal communication; skip interference from skywave
AS5|AMPS (Advanced Mobile Phone System)|1983-2008|UHF (824-894 MHz)|FM; 12 kHz deviation|30 kHz per channel|832 channels per market (416 per carrier)|first widely deployed cellular; analog; no encryption; easy eavesdropping; handoff based on signal strength; fully retired
AS6|Analog Television (NTSC/PAL/SECAM)|1941-2009 (NTSC US)|VHF/UHF (54-806 MHz)|AM (video) + FM (audio); vestigial sideband|6 MHz (NTSC); 7-8 MHz (PAL/SECAM)|one program per 6-8 MHz channel|analog; ghosts from multipath; snow from noise; fully replaced by digital TV (ATSC, DVB-T); spectrum reallocated to cellular and public safety

# digital_systems(id|name|standard|frequency_band|modulation|channel_bandwidth|data_rate|multiple_access|notes)
DS1|WiFi 4 (802.11n)|IEEE 802.11n (2009)|2.4 GHz and 5 GHz|OFDM; BPSK to 64-QAM|20/40 MHz|up to 600 Mbps (4×4 MIMO, 40 MHz)|CSMA/CA|introduced MIMO (up to 4 spatial streams); channel bonding (40 MHz); backward compatible with a/b/g
DS2|WiFi 5 (802.11ac)|IEEE 802.11ac (2013)|5 GHz only|OFDM; up to 256-QAM|20/40/80/160 MHz|up to 6.9 Gbps (8×8 MIMO, 160 MHz)|CSMA/CA; MU-MIMO (downlink)|wider channels; 256-QAM; MU-MIMO (multi-user, downlink only); beamforming standard
DS3|WiFi 6 (802.11ax)|IEEE 802.11ax (2020)|2.4 GHz and 5 GHz|OFDMA; up to 1024-QAM|20/40/80/160 MHz|up to 9.6 Gbps|OFDMA (uplink and downlink); MU-MIMO|OFDMA enables scheduling (like cellular); target wake time (battery savings); BSS coloring (interference management); 1024-QAM
DS4|WiFi 7 (802.11be)|IEEE 802.11be (2024)|2.4/5/6 GHz|OFDMA; up to 4096-QAM|up to 320 MHz|up to 46 Gbps|OFDMA; 16×16 MU-MIMO; MLO|multi-link operation (simultaneous on multiple bands); 320 MHz channels; 4096-QAM; extremely low latency target
DS5|Bluetooth|IEEE/Bluetooth SIG|2.4 GHz ISM (2400-2483.5 MHz)|FHSS (classic); GFSK (BLE)|1 MHz per hop; 79 channels; 1600 hops/s|1-3 Mbps (classic); 2 Mbps (BLE 5)|FHSS TDD|short range (~10-100 m); low power (BLE: months on coin cell); piconet (1 master + 7 slaves); profiles define application (A2DP audio, HID keyboard)
DS6|Zigbee (IEEE 802.15.4)|IEEE 802.15.4|2.4 GHz (global); 868/915 MHz (regional)|DSSS; O-QPSK|2 MHz (2.4 GHz); 600 kHz (868 MHz)|250 kbps (2.4 GHz); 20-40 kbps (sub-GHz)|CSMA/CA|mesh networking; low power; low data rate; home automation; sensor networks; up to 65,535 nodes per network
DS7|LoRa/LoRaWAN|Semtech proprietary (LoRa); LoRa Alliance (LoRaWAN)|sub-GHz ISM (868 MHz EU; 915 MHz US; 433 MHz Asia)|CSS (chirp spread spectrum)|125/250/500 kHz|0.3-50 kbps (SF7-SF12)|ALOHA-like|long range (2-15 km urban; 40+ km rural LOS); very low power; IoT sensors; spreading factor trades rate for range
DS8|Digital Television (ATSC 3.0)|ATSC 3.0 (2017)|UHF (470-698 MHz typical)|OFDM; LDPC + BCH coding; up to 4096-QAM|6 MHz|up to 57 Mbps per 6 MHz channel|broadcast (one to many)|4K/HDR capable; internet-hybrid; robust mobile reception; layered modulation; IP-based transport
DS9|Digital Audio Broadcasting (DAB/DAB+)|ETSI DAB (1995); DAB+ (2007)|VHF Band III (174-240 MHz); L-band (1452-1492 MHz)|OFDM (COFDM); DQPSK; HE-AAC v2 (DAB+)|1.536 MHz per ensemble|up to 1.2 Mbps per ensemble; ~18 services per ensemble|broadcast TDM|multipath resistant (OFDM); no analog fade-out (digital cliff); each ensemble carries multiple stations; DAB+ more efficient codec than DAB
DS10|TETRA (Terrestrial Trunked Radio)|ETSI|380-400 MHz (public safety); 410-430 MHz; 450-470 MHz; 870-876/915-921 MHz|π/4-DQPSK|25 kHz (4 TDMA slots per carrier)|7.2 kbps voice; 28.8 kbps data|TDMA (4 slots)|professional mobile radio; police, fire, ambulance; encrypted; group calls; direct mode (no infrastructure); trunking
DS11|DMR (Digital Mobile Radio)|ETSI TS 102 361|VHF/UHF (136-174 MHz; 403-470 MHz; 450-512 MHz)|4FSK|12.5 kHz (2 TDMA slots per carrier)|3.6 kbps voice per slot|TDMA (2 slots)|two-way radio digital standard; backward compatible with analog channel spacing; Tier I (unlicensed), II (conventional), III (trunked)
DS12|P25 (Project 25)|TIA-102|VHF/UHF/700/800 MHz|Phase 1: C4FM (FDMA, 12.5 kHz); Phase 2: H-DQPSK (TDMA, 2 slots per 12.5 kHz)|12.5 kHz|4.8 kbps voice (IMBE/AMBE+2 vocoder)|Phase 1: FDMA; Phase 2: TDMA|US public safety standard; interoperability between agencies; encryption (DES, AES); trunked or conventional

# cellular_generations(id|generation|standard|era|frequency_bands|modulation|access_method|peak_data_rate|latency|key_features)
CG1|1G|AMPS, NMT, TACS|1979-1990s|800-900 MHz|FM analog|FDMA|N/A (voice only)|N/A|analog voice; no encryption; frequency reuse; handoff; ~832 channels per market; large cells; car phones primarily
CG2|2G|GSM, IS-136 (D-AMPS), cdmaOne (IS-95)|1991 onward|850/900/1800/1900 MHz|GMSK (GSM); QPSK (cdmaOne)|GSM: TDMA (8 slots per 200 kHz); cdmaOne: CDMA|9.6 kbps (circuit-switched data); 14.4 kbps (IS-95)|~500 ms|first digital cellular; encryption (A5/1 GSM); SMS; SIM card (GSM); roaming; spectral efficiency 3× analog
CG3|2.5G|GPRS|2000|same as 2G|GMSK|TDMA (packet-switched overlay on GSM)|57-114 kbps|~500-700 ms|packet-switched data overlay; always-on connectivity; IP-based; multiple timeslot aggregation; enabled mobile internet (basic)
CG4|2.75G|EDGE (Enhanced Data for GSM Evolution)|2003|same as 2G|8PSK (3 bits/symbol vs GMSK 1 bit)|TDMA|up to 384 kbps|~300-400 ms|higher-order modulation on GSM; 3× GPRS throughput; still widely deployed in developing markets; incremental upgrade
CG5|3G|UMTS (WCDMA), CDMA2000|2001 onward|850/900/1700/1900/2100 MHz|QPSK (downlink); BPSK (uplink)|WCDMA: CDMA (5 MHz carrier); CDMA2000: CDMA (1.25 MHz)|384 kbps (R99); 2 Mbps (theoretical)|~100-200 ms|wideband CDMA; voice + broadband data; video calling; soft handoff; Rake receiver for multipath; power control critical (near-far problem)
CG6|3.5G|HSPA (HSDPA/HSUPA)|2005/2007|same as 3G|16-QAM (HSDPA); QPSK (HSUPA)|CDMA + shared channel scheduling|14.4 Mbps (HSDPA); 5.76 Mbps (HSUPA)|~50-100 ms|adaptive modulation and coding; hybrid ARQ; shared channel scheduling; fast scheduling (2 ms TTI); enabled mobile broadband (smartphone era began)
CG7|3.9G|HSPA+ (Evolved HSPA)|2008|same as 3G|64-QAM downlink; 16-QAM uplink; 2×2 MIMO|CDMA + shared channel|42 Mbps (DL); 11.5 Mbps (UL)|~30-50 ms|MIMO added; 64-QAM; dual-carrier; bridge technology to LTE; marketed as "4G" by some carriers
CG8|4G|LTE (Long Term Evolution)|2009 onward|700/800/850/900/1700/1800/1900/2100/2300/2600 MHz|OFDMA (downlink); SC-FDMA (uplink); QPSK to 64-QAM; 2×2 or 4×4 MIMO|OFDMA/SC-FDMA|150 Mbps (DL, 2×2 MIMO, 20 MHz); 50 Mbps (UL)|~30-50 ms|all-IP (no circuit-switched voice in pure LTE; VoLTE added); flat architecture (fewer nodes); carrier aggregation (LTE-A); 1-20 MHz flexible bandwidth; low latency; handover without interruption
CG9|4.5G|LTE-Advanced / LTE-Advanced Pro|2013/2016|same as LTE + additional bands|up to 256-QAM; 8×8 MIMO; carrier aggregation up to 5 carriers (100 MHz)|OFDMA|up to 3 Gbps (theoretical with CA + MIMO)|~10-20 ms|carrier aggregation (5× 20 MHz); 256-QAM; 8×8 MIMO; CoMP (coordinated multipoint); heterogeneous networks; LAA (licensed-assisted access on unlicensed spectrum)
CG10|5G NR (Sub-6)|5G NR Release 15/16/17|2019 onward|600-700 MHz; 2.5 GHz; 3.3-4.2 GHz; 4.4-5 GHz (n77/n78 most common)|OFDMA; CP-OFDM (DL and UL); up to 256-QAM; massive MIMO (64T64R)|OFDMA|up to 4.7 Gbps (theoretical)|~1-4 ms (user plane)|flexible numerology (subcarrier spacing 15-120 kHz); massive MIMO; beamforming; network slicing; lower latency than LTE; enhanced mobile broadband (eMBB)
CG11|5G NR (mmWave)|5G NR|2019 onward|24.25-27.5 GHz (n257/n258); 27.5-28.35 GHz; 37-43.5 GHz (n260)|OFDMA; up to 256-QAM; up to 800 MHz channel bandwidth|OFDMA|up to 20 Gbps (theoretical)|~1 ms|enormous bandwidth (up to 400 MHz per carrier, 800 MHz with aggregation); very short range (100-300 m); beam steering required; dense deployment; fixed wireless access; stadium/venue coverage
CG12|5G-Advanced|3GPP Release 18+|2024 onward|all 5G bands + new bands|same as 5G NR + AI/ML integration|OFDMA|evolving|sub-1 ms target|AI-native air interface optimization; extended reality (XR) support; ambient IoT; NTN (non-terrestrial networks: satellite integration); sidelink enhancement; energy efficiency improvements
CG13|6G (Research)|pre-standard research|~2030 target|sub-THz (100-300 GHz); existing bands|potential: advanced OFDM, OTFS, holographic MIMO|TBD|target 1 Tbps|target 10-100 μs|terahertz spectrum; joint sensing and communication; digital twin integration; AI-native design; holographic MIMO; reconfigurable intelligent surfaces (RIS); research phase only

# cellular_architecture(id|name|definition|function|connections)
AR1|User Equipment (UE)|mobile device (phone, tablet, IoT device, modem); contains SIM/eSIM, baseband processor, RF front-end, antenna|originates/terminates calls and data; connects to cell tower via air interface; measures signal quality and reports to network|air interface to AR2; SIM authentication to AR7
AR2|Cell Tower / Base Station (gNB/eNodeB)|radio equipment serving a cell; antennas, RF electronics, baseband processing; gNB (5G), eNodeB (4G), NodeB (3G), BTS (2G)|transmit/receive radio signals; schedule resources; manage connections; handover coordination with neighbors|air interface to AR1; backhaul to AR3/AR4; X2/Xn interface to neighboring AR2
AR3|Base Station Controller / RAN Controller|aggregates and manages multiple base stations; BSC (2G), RNC (3G); function absorbed into eNodeB in 4G, distributed in 5G (CU/DU split)|radio resource management; handover between cells under its control; transcoding (2G); traffic concentration|fronthaul/midhaul to AR2; interface to AR4
AR4|Core Network|central network elements handling routing, authentication, mobility, policy; EPC (4G), 5GC (5G)|user authentication; session management; mobility management; policy enforcement; gateway to external networks|to AR2/AR3 via backhaul; to AR5 via gateway; to AR7 for authentication
AR5|Internet / External Networks|public internet, enterprise networks, IMS (IP Multimedia Subsystem for voice)|provides services accessed by UE; web, streaming, voice (VoLTE via IMS)|connected via gateway in AR4 (PGW in 4G, UPF in 5G)
AR6|Backhaul|connection between base station and core network; fiber, microwave, or satellite|carries aggregated user traffic and signaling between RAN and core; bandwidth must match peak cell capacity|fiber (preferred; Gbps); microwave point-to-point (common; 100 Mbps-10 Gbps); satellite (remote areas; higher latency)
AR7|SIM / eSIM / Authentication|subscriber identity module; stores IMSI (subscriber ID), authentication keys, network parameters|authenticates subscriber to network; enables roaming; stores cryptographic keys for air interface encryption|UE physically contains SIM; network authenticates via HSS/UDM in core
AR8|Small Cell|low-power base station for coverage densification; femtocell (home), picocell (enterprise), microcell (outdoor)|fills coverage gaps; increases capacity in dense areas; offloads macro cell; typically user-deployed (femto) or operator-deployed (pico/micro)|backhaul via internet (femto) or dedicated (pico/micro); interference coordination with macro cell
AR9|Distributed Antenna System (DAS)|network of spatially separated antenna nodes connected to common base station; indoor or outdoor|extends coverage inside buildings, tunnels, stadiums; uses existing base station capacity; each antenna node covers small area|fiber or coax from head-end to antenna nodes; connected to AR2 baseband
AR10|Network Slicing (5G)|virtualized logical network on shared physical infrastructure; each slice has isolated resources and QoS parameters|enables different service profiles on same physical network; eMBB (high throughput), URLLC (low latency), mMTC (massive IoT)|slices share AR2 radio, AR6 backhaul, AR4 core; isolated by virtualization and scheduling
AR11|Mobile Edge Computing (MEC)|computing resources deployed at network edge (at or near base station); reduces latency for applications|processes data close to user; reduces round-trip to cloud; enables AR/VR, autonomous driving, industrial IoT|co-located with AR2 or AR4 edge nodes; application servers at edge
AR12|Fronthaul|connection between central unit (CU) and distributed unit (DU) or remote radio head (RRH) in split architectures|carries digitized radio signals or partially processed data; requires very low latency and high bandwidth; eCPRI protocol|fiber (required for bandwidth); CU-DU split enables centralized processing; latency < 100 μs typically required
AR13|O-RAN (Open RAN)|disaggregated, open-interface RAN architecture; separates hardware from software; multi-vendor interoperability|enables competition; reduces vendor lock-in; AI/ML-based RAN intelligent controller (RIC); open fronthaul interfaces|AR2 disaggregated into O-RU (radio unit), O-DU (distributed unit), O-CU (central unit); RIC controls optimization

# protocols(id|name|layer|function|generation|notes)
PC1|OFDMA (air interface)|physical|multi-user access via orthogonal subcarrier allocation; resource blocks assigned per user per time slot|4G LTE, 5G NR|subcarrier spacing: 15 kHz (LTE), 15/30/60/120 kHz (5G NR flexible numerology); cyclic prefix absorbs multipath delay spread
PC2|SC-FDMA|physical (uplink)|single-carrier FDMA; lower PAPR than OFDM; enables more efficient power amplifier in UE|4G LTE uplink|DFT-spread OFDM; each user transmits on contiguous subcarriers; replaced by CP-OFDM in 5G NR (optional transform precoding)
PC3|HARQ (Hybrid ARQ)|link|combines forward error correction with retransmission; incremental redundancy or chase combining|3G+|receiver attempts decoding; if fails, requests retransmission; combines original and retransmission for better decoding probability; 8 HARQ processes in LTE
PC4|RRC (Radio Resource Control)|control plane|manages radio connection state; idle → connected transitions; measurement configuration; handover commands|3G, 4G, 5G|RRC_IDLE (battery saving, no dedicated resources), RRC_CONNECTED (active communication); RRC_INACTIVE (5G: reduced signaling for IoT)
PC5|NAS (Non-Access Stratum)|control plane|signaling between UE and core network; authentication, security, session management; transparent to RAN|4G, 5G|EMM/ESM (4G); 5GMM/5GSM (5G); carries subscriber identity and security context
PC6|GTP (GPRS Tunneling Protocol)|user/control plane|tunnels user data between RAN and core; encapsulates IP packets; enables mobility (tunnel endpoint moves during handover)|2G+|GTP-U (user data); GTP-C (control/tunnel management); each bearer has GTP tunnel; enables seamless handover
PC7|SIP/IMS (Session Initiation Protocol)|application/control|voice call setup/teardown over IP; VoLTE and VoNR use SIP via IMS infrastructure|4G (VoLTE), 5G (VoNR)|replaced circuit-switched voice; SIP INVITE → 200 OK → ACK; QCI 1 bearer (guaranteed bit rate) for voice; codecs: AMR-WB (HD Voice), EVS
PC8|MIMO Precoding|physical|spatial multiplexing and beamforming; transmitter applies precoding matrix to map data streams to antennas; receiver uses spatial processing to separate|4G, 5G|rank indication (RI) from UE tells network how many spatial layers channel supports; codebook-based (4G) or non-codebook (5G massive MIMO); up to 8 layers (LTE-A), theoretically more in 5G
PC9|Channel Estimation / Reference Signals|physical|UE and network measure channel conditions using known reference signals; enables coherent demodulation, AMC, beamforming|all digital|CSI-RS (channel state information RS); DMRS (demodulation RS); SRS (sounding RS, uplink); pilot signals in OFDM; density vs overhead trade-off
PC10|Scheduling (MAC)|MAC|base station allocates time-frequency resources to UEs each TTI (transmission time interval); considers channel quality, QoS, fairness|3G+|proportional fair scheduler most common (balances throughput and fairness); max C/I (maximum throughput); round-robin (equal time); 1 ms TTI (LTE); 0.5/0.25/0.125 ms (5G NR mini-slots)
PC11|Handover / Handoff|control|transferring UE connection from one cell to another during mobility; measurement → decision → execution|all|hard handover (break-before-make: GSM, LTE); soft handover (make-before-break: CDMA/WCDMA); LTE: UE-assisted, network-decided; inter-frequency, inter-RAT handovers; target < 50 ms interruption
PC12|Power Control|physical|adjust transmit power to maintain required quality while minimizing interference|all|open-loop (initial estimate from path loss); closed-loop (feedback from receiver); critical in CDMA (near-far problem); UE power control saves battery; uplink power control in all systems
PC13|Random Access (RACH)|MAC|UE requests connection when entering coverage or resuming from idle; preamble-based contention resolution|all|preamble detection at base station; timing advance correction; contention resolution for collision (multiple UEs choose same preamble); 2-step (5G simplified) or 4-step traditional

# spectrum(id|topic|description|details)
SM1|Spectrum Allocation|government assigns frequency bands to services (cellular, broadcast, military, safety, satellite, amateur)|ITU defines global framework (Radio Regulations); national regulators (FCC US, Ofcom UK, BNetzA Germany) assign specific bands; regional harmonization (3GPP bands defined globally)
SM2|Licensed Spectrum|exclusive use rights purchased at auction or assigned by regulator; interference protection guaranteed|cellular operators bid billions at auction; exclusive access enables QoS guarantees and capacity planning; most cellular bands are licensed
SM3|Unlicensed Spectrum|shared spectrum open to all users following power and protocol rules; no auction; no exclusive rights|ISM bands: 2.4 GHz, 5 GHz, 5.9-7.125 GHz (WiFi 6E/7), 60 GHz; WiFi, Bluetooth, LoRa, Zigbee; interference possible from other users; no QoS guarantee
SM4|Shared Spectrum (CBRS)|middle ground; licensed users share spectrum under dynamic management; SAS (Spectrum Access System) coordinates|3.5 GHz CBRS (US): incumbent (military radar) → priority access (licensed small cells) → general authorized (unlicensed-like); enables enterprise private networks
SM5|Spectrum Efficiency|bits per second per hertz per cell; measure of how well spectrum is utilized|improved by: higher-order modulation, MIMO, densification (small cells), beamforming, interference management; LTE: ~2-3 bps/Hz/cell; 5G: ~5-10 bps/Hz/cell with massive MIMO
SM6|Frequency Reuse|same frequency used in non-adjacent cells; cellular concept; reuse distance depends on interference tolerance|reuse factor 1 (every cell uses all frequencies; requires interference management: CDMA, LTE, 5G); reuse factor 3 or 7 (classic GSM: cells use 1/3 or 1/7 of frequencies; simpler interference but less capacity)
SM7|Carrier Aggregation (CA)|combining multiple frequency bands (component carriers) into single wider logical channel for one user|LTE-A: up to 5 CC (100 MHz); 5G NR: up to 16 CC; contiguous or non-contiguous; intra-band or inter-band; requires multi-band radio in UE
SM8|Dynamic Spectrum Sharing (DSS)|4G LTE and 5G NR share same frequency band simultaneously; resources dynamically allocated between technologies|enables 5G deployment on existing LTE frequencies without full refarming; reduces efficiency (overhead from dual scheduling); transition technology
SM9|Spectrum Auction|government sells exclusive spectrum licenses to highest bidder; billions of dollars at stake|US AWS-3 auction (2015): $44.9 billion; C-band auction (2021): $81.2 billion; enables market-based allocation; term limits and renewal conditions; coverage obligations
SM10|Guard Band|unused frequency between adjacent channels preventing interference; wastes spectrum but essential for filter roll-off|OFDM reduces need for guard bands (subcarrier orthogonality); guard bands still needed between operators and between technologies

# components(id|name|function|key_specifications|location)
CP1|Power Amplifier (PA)|amplifies transmitter signal to required output power for antenna; most power-hungry component in radio|output power (watts/dBm); efficiency (% DC→RF; 30-70%); linearity (EVM); frequency range; technology (GaAs, GaN, LDMOS, CMOS)|transmitter; base station (high power 20-40W per antenna element); UE (0.1-2W)
CP2|Low-Noise Amplifier (LNA)|amplifies weak received signal with minimal added noise; first active stage in receiver|noise figure (0.5-3 dB); gain (10-20 dB); linearity (IP3); frequency range|receiver front end; immediately after antenna; dominates overall receiver noise figure (Friis formula)
CP3|Filter (RF)|passes desired frequencies, rejects others; bandpass, lowpass, highpass, notch|center frequency; bandwidth; insertion loss; rejection (stopband attenuation); selectivity (shape factor)|between antenna and amplifiers; duplexer combines TX and RX filters; SAW, BAW, cavity, ceramic
CP4|Mixer|translates signal between frequencies; multiplies signal with local oscillator; produces sum and difference frequencies|conversion loss/gain; noise figure; linearity (IP3); LO-RF isolation|frequency conversion: RF → IF (downconversion in receiver); IF → RF (upconversion in transmitter)
CP5|Local Oscillator (LO)|generates stable reference frequency for mixer; frequency determines receive/transmit channel|frequency stability (ppm); phase noise (dBc/Hz); tuning range; settling time|paired with mixer; PLL (phase-locked loop) synthesizer generates LO from reference crystal
CP6|Analog-to-Digital Converter (ADC)|converts continuous analog signal to discrete digital samples; sampling rate and resolution determine quality|sampling rate (MSPS/GSPS); resolution (bits; 8-16 typical for radio); SFDR (spurious-free dynamic range)|receiver; after downconversion and filtering; Nyquist: sample rate ≥ 2× signal bandwidth; oversampling for better SNR
CP7|Digital-to-Analog Converter (DAC)|converts digital samples to continuous analog signal for transmission|sampling rate; resolution (bits); output power; spectral purity|transmitter; before upconversion and PA; generates baseband or IF waveform from digital modulated signal
CP8|Baseband Processor|digital signal processing: modulation/demodulation, channel coding/decoding, equalization, MIMO processing|computational power (GOPS); latency; power consumption; programmability (DSP, FPGA, ASIC)|central processing in both UE and base station; most computationally intensive component; handles all digital signal processing
CP9|Duplexer|allows simultaneous transmit and receive on same antenna; separates TX and RX signals by frequency (FDD) or time (TDD)|isolation between TX and RX (>50 dB); insertion loss (<1 dB); frequency separation|between antenna and TX/RX chains; FDD: paired bandpass filters; TDD: fast switch
CP10|Phase-Locked Loop (PLL)|frequency synthesizer; locks output frequency to stable reference via feedback; generates precise tunable LO|lock time; phase noise; frequency resolution (step size); reference frequency (typically crystal ~10-50 MHz)|generates local oscillator frequencies; enables channel selection; every radio contains at least one PLL
CP11|Crystal Oscillator|precision frequency reference; quartz crystal vibrating at natural resonant frequency|frequency accuracy (±1-50 ppm); stability over temperature (TCXO: ±0.5 ppm; OCXO: ±0.01 ppm)|master clock reference for PLL, ADC, DAC, digital circuits; GPS-disciplined oscillators for base stations
CP12|Digital Signal Processor (DSP)|specialized processor optimized for repetitive mathematical operations (multiply-accumulate); real-time signal processing|MIPS/GFLOPS; power efficiency; fixed-point or floating-point; hardware accelerators|baseband processing; channel estimation; equalization; decoding; increasingly replaced by ASIC or FPGA for high-throughput
CP13|FPGA (Field-Programmable Gate Array)|reconfigurable digital hardware; programmed post-manufacturing; parallel processing|logic elements; DSP slices; clock speed; I/O bandwidth; power consumption|base station signal processing; prototyping; O-RAN DU implementations; flexible deployment
CP14|RF Switch|electronically controlled switch selecting between antenna paths, bands, or modes|insertion loss; isolation; switching speed; power handling; linearity|antenna selection; band selection; TDD TX/RX switching; antenna tuning; UE front-end routing

# signal_processing(id|name|definition|purpose|implementation)
SG1|Channel Coding (FEC)|adding redundancy to data before transmission; receiver detects and corrects errors without retransmission|combat noise and fading; ensure reliable delivery; trade bandwidth for reliability|turbo codes (3G/4G); LDPC (5G data, WiFi); polar codes (5G control); convolutional codes (2G, older systems); Viterbi decoding; iterative decoding
SG2|Interleaving|rearranging order of coded bits before transmission; spreads burst errors across multiple codewords|converts burst errors (from fading) into random errors (correctable by FEC); essential for fading channels|bit interleaver; frequency interleaving in OFDM (spread data across subcarriers); time interleaving (spread across OFDM symbols)
SG3|Equalization|compensating for channel distortion (multipath, frequency-selective fading) at receiver|restores signal distorted by channel; estimates and inverts channel response|time-domain: linear (ZF, MMSE), decision-feedback (DFE); frequency-domain: OFDM inherently equalizes per-subcarrier (one-tap equalizer with channel estimate)
SG4|Channel Estimation|measuring channel characteristics using known reference signals; produces channel matrix H|enables coherent demodulation; required for MIMO precoding, beamforming, equalization, AMC|pilot/reference signals (known to receiver); interpolation between pilots; tracking for time-varying channels; key overhead-accuracy trade-off
SG5|Beamforming|focusing antenna radiation in specific direction by adjusting phase and amplitude of each antenna element|increases signal strength toward intended receiver; reduces interference to/from other directions; extends range; increases capacity|analog beamforming (phase shifters): one beam per panel; digital beamforming (precoding in baseband): independent beam per user; hybrid: combination; massive MIMO enables many simultaneous beams
SG6|Spatial Multiplexing|transmitting independent data streams on different spatial paths using multiple antennas at both TX and RX|multiplies data rate by number of spatial layers (rank); requires rich scattering environment; limited by min(N_tx, N_rx)|MIMO: 2×2 (2 layers), 4×4 (4 layers), 8×8 (8 layers); MU-MIMO: multiple users served simultaneously on different spatial beams; massive MIMO: dozens of simultaneous users
SG7|Diversity|using multiple independent copies of signal to combat fading; if one copy fades, others likely don't|reduces probability of deep fade; improves reliability without increasing average power|spatial (multiple antennas); frequency (spread across subcarriers); time (interleaving across slots); polarization (vertical + horizontal antennas); selection, MRC (maximal ratio combining), EGC (equal gain combining)
SG8|RAKE Receiver|combines multiple multipath copies of signal using time-diversity; each "finger" tracks one multipath component|exploits multipath rather than fighting it; combining improves SNR; used in wideband CDMA|each finger correlates with specific delay and code offset; MRC combining of finger outputs; 3-6 fingers typical; CDMA/WCDMA specific
SG9|Turbo Decoding|iterative decoding of parallel concatenated convolutional codes; approaches Shannon limit within ~0.5 dB|near-optimal error correction; enables communication near channel capacity; used in 3G/4G|two component decoders exchange soft information (extrinsic LLRs) iteratively (6-8 iterations typical); complexity proportional to iterations × block length
SG10|LDPC Decoding|decoding low-density parity-check codes; iterative belief propagation on bipartite graph|near-Shannon-limit performance; parallelizable; flexible code rates and lengths|belief propagation (sum-product or min-sum algorithm); 5G NR data channel; WiFi (802.11n+); DVB-S2; iterations 10-50; hardware-friendly parallelism
SG11|Polar Decoding|decoding polar codes; successive cancellation (SC) or SC list (SCL) decoding|provably capacity-achieving for BEC; good performance at short block lengths with list decoding|SC: sequential, O(N log N); SCL: parallel paths with CRC-aided selection; 5G NR control channels
SG12|OFDM Processing|IFFT at transmitter (frequency → time domain); FFT at receiver (time → frequency domain); cyclic prefix insertion/removal|converts frequency-domain symbols to time-domain for transmission; enables simple one-tap equalization per subcarrier; absorbs multipath via cyclic prefix|IFFT/FFT size: 256 (WiFi), 2048 (LTE 20 MHz), up to 4096 (5G); cyclic prefix length ≥ maximum channel delay spread; windowing reduces spectral leakage
SG13|Automatic Gain Control (AGC)|adjusts receiver amplification to maintain signal within ADC dynamic range regardless of input power variation|handles near-far problem (signal from nearby phone vs distant phone); prevents ADC saturation; maintains linearity|fast AGC (adapts within symbol); slow AGC (adapts over frames); gain steps typically 1-3 dB; settling time vs stability trade-off
SG14|Carrier Frequency Offset (CFO) Estimation and Correction|estimating and compensating frequency difference between transmitter and receiver oscillators|prevents inter-carrier interference in OFDM (subcarrier orthogonality destroyed by CFO); required for coherent demodulation|preamble-based estimation (coarse); pilot-based tracking (fine); typically must correct to < 1% of subcarrier spacing
SG15|Power Control|adjusting transmitter output power based on channel conditions and interference|minimizes interference to other users; saves UE battery; maintains target SINR at receiver|open-loop: UE estimates path loss from downlink; closed-loop: base station commands UE power adjustment (TPC bits); step size typically 1-3 dB; CDMA: 800-1500 updates/second

# failure_modes(id|topic|mode|cause|consequence|prevention)
FL1|propagation|dead zone / coverage hole|terrain obstruction; building shadowing; insufficient cell density|no service; dropped calls; user frustration|small cells; DAS; repeaters; antenna optimization; site surveys; drive testing
FL2|propagation|multipath fading (deep fade)|destructive interference from reflected signals; stationary UE in fade null|signal drops 20-40 dB below mean; temporary loss of connection|diversity (spatial, frequency, time); OFDM (frequency diversity inherent); MIMO; movement resolves (half-wavelength away)
FL3|capacity|cell congestion|too many users in one cell; events (concert, emergency); insufficient capacity for demand|slow data; dropped calls; access denied; latency spikes|densification (small cells); carrier aggregation; load balancing; traffic shaping; temporary cells (COWs: cells on wheels)
FL4|interference|co-channel interference|neighboring cells using same frequency; poor frequency planning or reuse factor 1|reduced SINR; lower throughput; dropped calls|ICIC (inter-cell interference coordination); eICIC (enhanced); CoMP (coordinated multipoint); beamforming; proper planning
FL5|interference|adjacent-channel leakage|imperfect filtering; transmitter spectral mask violation; intermodulation products|interference to adjacent channel users; regulatory violation|better filters; linearization (DPD: digital pre-distortion); compliance testing; guard bands
FL6|hardware|PA nonlinearity|power amplifier operating near saturation; high PAPR signals (OFDM)|spectral regrowth (out-of-band emissions); in-band distortion (EVM degradation); adjacent channel interference|back-off (reduce average power below saturation, wastes efficiency); DPD (digital pre-distortion); CFR (crest factor reduction); use SC-FDMA (lower PAPR)
FL7|handover|ping-pong handover|UE at cell boundary oscillates between cells; hysteresis too low; timer too short|excessive signaling; momentary interruptions; battery drain|hysteresis margin (3-6 dB); time-to-trigger (40-640 ms); proper parameter tuning; A3 event configuration
FL8|handover|handover failure|target cell overloaded; insufficient signal at target; preparation timeout|dropped call; connection interruption; data loss|neighbor relation optimization; load-based handover parameters; handover preparation timer; inter-RAT handover as fallback
FL9|authentication|SIM cloning / IMSI catching|intercepting subscriber identity or cloning SIM credentials; IMSI catchers (Stingray devices)|eavesdropping; location tracking; billing fraud; privacy violation|5G SUPI encryption (SUCI); mutual authentication; randomized temporary identifiers; 5G improved over 4G/3G significantly
FL10|backhaul|backhaul bottleneck|cell site radio capacity exceeds backhaul capacity; especially small cells with limited backhaul|throughput capped by backhaul regardless of air interface speed; latency increases; user experience limited|fiber backhaul (preferred); sufficient microwave capacity; backhaul capacity planning to match radio capacity; network monitoring
FL11|power|UE battery drain|high transmit power; continuous connectivity; poor signal (UE increases power); inefficient DRX (discontinuous reception)|short battery life; user frustration; UE overheating|DRX optimization; power-efficient scheduling; C-DRX (connected mode DRX); target wake time (WiFi 6); network-assisted idle mode management

# distinctions(id|side_a|side_b|key_asymmetry)
DI1|Analog Modulation|Digital Modulation|analog: continuous signal representation; simple; degrades gracefully with noise; inefficient spectrum use; digital: discrete symbols; error correction possible; cliff effect (works or doesn't); efficient spectrum use via higher-order modulation; all modern systems digital
DI2|FDD (Frequency Division Duplex)|TDD (Time Division Duplex)|FDD: separate frequencies for uplink and downlink; simultaneous TX/RX; needs paired spectrum; guard band between; simpler but inflexible ratio; TDD: same frequency, alternating time slots; flexible UL/DL ratio; needs guard period; channel reciprocity (simplifies MIMO); single band needed; 5G trend toward TDD
DI3|Licensed Spectrum|Unlicensed Spectrum|licensed: exclusive use; auction-purchased; interference protection; QoS guarantees; expensive; unlicensed: shared; free; no QoS guarantee; interference from others; CSMA/CA collision avoidance; coexistence challenges; WiFi, Bluetooth, LoRa
DI4|Sub-6 GHz|mmWave (>24 GHz)|sub-6: moderate bandwidth (5-100 MHz); good propagation and penetration; km range; mature; deployed globally; mmWave: enormous bandwidth (100-800 MHz); poor propagation (LOS only, rain attenuation); 100-300 m range; dense deployment; beamforming required; highest capacity
DI5|Circuit-Switched|Packet-Switched|circuit: dedicated path for duration of call; guaranteed bandwidth; resource reserved even during silence; 1G/2G voice; packet: data divided into packets; shared resources; statistical multiplexing; efficient; variable latency; 4G/5G all-IP; VoLTE replaces circuit voice
DI6|Macro Cell|Small Cell|macro: high power (20-40W/element); tower-mounted; 1-30 km radius; provides wide coverage; expensive infrastructure; small: low power (0.1-5W); pole/wall mounted; 10-300 m radius; densification; capacity; lower cost; femto/pico/micro classifications
DI7|OFDM|Single-Carrier|OFDM: data on parallel narrowband subcarriers; multipath tolerant (cyclic prefix); high PAPR; FFT processing; dominant in downlink; single-carrier: one wideband carrier; lower PAPR (better PA efficiency); requires complex equalization for multipath; used in uplink (SC-FDMA in LTE) and low-complexity links
DI8|Narrowband|Wideband / Broadband|narrowband: BW << coherence bandwidth of channel; flat fading (all frequencies fade together); simpler equalization; low data rate; wideband: BW ≥ coherence bandwidth; frequency-selective fading (different frequencies fade differently); requires equalization or OFDM; higher data rate
DI9|MIMO|SISO|SISO: single antenna TX and RX; single spatial stream; limited by Shannon; MIMO: multiple antennas TX and/or RX; multiple spatial streams (spatial multiplexing) or improved reliability (diversity) or directed energy (beamforming); capacity scales linearly with min(N_tx, N_rx) in rich scattering; massive MIMO (64+) = step change
DI10|Coverage-Limited|Capacity-Limited|coverage: signal too weak at cell edge; need more cells or higher power; rural/indoor challenge; capacity: sufficient signal but too many users; need more spectrum, more cells, better efficiency; urban/event challenge; solutions different for each
DI11|Uplink|Downlink|uplink: UE → base station; power-limited (small battery, small antenna); lower data rates typically; SC-FDMA (LTE); downlink: base station → UE; power advantage (grid power, high-gain antenna); higher data rates; OFDMA; system designs typically downlink-optimized

# relationships(from|rel|to)
# Electromagnetic fundamentals
CO1|characterized_by|CO2,CO3,CO4,CO5
CO2|inverse_of|CO3
CO6|determines|CO8
CO7|determines|CO8
CO8|constrains|CO6,MO7
CO10|modified_by|CO11
CO11|inverse_of|CO12
CO13|enables|CO8
CO14|enables|CO15

# Band → propagation
EM1|propagates_via|PG2
EM2|propagates_via|PG2
EM3|propagates_via|PG2,PG3
EM4|propagates_via|PG2,PG3
EM5|propagates_via|PG3
EM6|propagates_via|PG4,PG6
EM7|propagates_via|PG4,PG5,PG6,PG7
EM8|propagates_via|PG4,PG8,PG9
EM9|propagates_via|PG4,PG8,PG9

# Propagation → problems
PG1|governs|CO19
PG5|causes|CO25
PG5|causes|FL2
PG7|causes|PG5
PG8|causes|PG1
PG9|causes|PG1
PG11|causes|CO25
PG12|causes|CO25

# Modulation relationships
MO1|instance_of|CO11
MO2|instance_of|CO11
MO6|extends|MO4
MO7|extends|MO6
MO8|extends|MO7
MO9|instance_of|CO13
MO10|extends|MO8
MO11|instance_of|CO13
MO12|instance_of|CO13
MO13|specializes|MO5
MO14|specializes|MO12
MO16|selects|MO6,MO7

# Modulation → generation
MO13|used_by|CG2
MO9|used_by|CG5,CG6
MO10|used_by|CG8,CG9,CG10,CG11
MO7|used_by|CG6,CG7,CG8,CG9,CG10,CG11
MO8|used_by|CG8,CG9,CG10,CG11

# Antenna → application
AN5|used_by|AR6
AN6|used_by|AR1
AN7|used_by|AR2,CG10,CG11
AN8|used_by|AR2
AN11|used_by|CG10,CG11
AN12|used_by|AR8

# Cellular generation evolution
CG1|evolves_to|CG2
CG2|evolves_to|CG3
CG3|evolves_to|CG4
CG4|evolves_to|CG5
CG5|evolves_to|CG6
CG6|evolves_to|CG7
CG7|evolves_to|CG8
CG8|evolves_to|CG9
CG9|evolves_to|CG10,CG11
CG10|evolves_to|CG12
CG12|evolves_to|CG13

# Architecture connections
AR1|connects_to|AR2
AR2|connects_to|AR3,AR4
AR2|uses|AR6,AR12
AR3|connects_to|AR4
AR4|connects_to|AR5
AR7|authenticates|AR1
AR8|extends|AR2
AR9|extends|AR2
AR10|virtualizes|AR4
AR11|co_located_with|AR2
AR13|disaggregates|AR2

# Protocol → layer
PC1|operates_at|AR2
PC3|operates_at|AR2
PC4|operates_at|AR1,AR2
PC5|operates_at|AR1,AR4
PC6|operates_at|AR2,AR4
PC7|operates_at|AR1,AR4,AR5
PC8|operates_at|AR2,AR1
PC10|operates_at|AR2
PC11|operates_at|AR2,AR4
PC12|operates_at|AR1,AR2

# Signal processing → modulation/protocol
SG1|protects|CO8
SG2|complements|SG1
SG3|compensates_for|PG5
SG4|enables|SG5,SG6,MO16
SG5|implements|AN7,AN11
SG6|implements|AN11
SG7|combats|CO25,PG12
SG8|exploits|PG5
SG9|decodes|SG1
SG10|decodes|SG1
SG11|decodes|SG1
SG12|implements|MO8
SG13|enables|CO22
SG15|implements|PC12

# Components → functions
CP1|amplifies|CO4
CP2|amplifies|CO4
CP3|implements|CO6
CP4|implements|CO2
CP5|drives|CP4
CP6|digitizes|CO4
CP7|synthesizes|CO4
CP8|processes|MO8,SG1,SG3,SG4,SG5
CP9|separates|CO14
CP10|implements|CP5
CP11|references|CP10
CP12|implements|CP8
CP13|implements|CP8

# Spectrum management
SM1|governs|EM1,EM2,EM3,EM4,EM5,EM6,EM7,EM8,EM9
SM2|enables|CG1,CG2,CG5,CG8,CG10
SM3|enables|DS1,DS2,DS3,DS4,DS5,DS6,DS7
SM5|improved_by|MO10,SG5,SG6,AN11
SM6|enables|CG1,CG2,CG5,CG8,CG10
SM7|extends|CO6

# Failure → system
FL1|affects|AR1
FL2|affects|AR1,AR2
FL3|affects|AR2,CG8,CG10
FL4|affects|CG8,CG10
FL7|affects|PC11
FL8|affects|PC11
FL9|affects|AR7
FL10|affects|AR6
FL11|affects|AR1

# Distinction mappings
DI1|distinguishes|MO1,MO7
DI2|distinguishes|CO14
DI3|distinguishes|SM2,SM3
DI4|distinguishes|CG10,CG11
DI5|distinguishes|CG1,CG8
DI6|distinguishes|AR2,AR8
DI7|distinguishes|MO8,MO13
DI8|distinguishes|CO6
DI9|distinguishes|AN11,AN2
DI10|distinguishes|FL1,FL3
DI11|distinguishes|PC2,PC1

# decode_legend
# id_prefixes: CO=concept, EM=electromagnetic_band, PG=propagation, MO=modulation, AN=antenna, AS=analog_system, DS=digital_system, CG=cellular_generation, AR=cellular_architecture, PC=protocol, SM=spectrum, CP=component, SG=signal_processing, FL=failure_mode, DI=distinction
# rel_types: characterized_by|inverse_of|determines|constrains|modified_by|enables|propagates_via|governs|causes|instance_of|extends|specializes|used_by|selects|evolves_to|connects_to|uses|authenticates|virtualizes|co_located_with|disaggregates|operates_at|protects|complements|compensates_for|combats|exploits|decodes|implements|amplifies|digitizes|synthesizes|processes|separates|drives|references|improved_by|affects|distinguishes
# dBm: decibels relative to 1 milliwatt; 0 dBm = 1 mW; 30 dBm = 1 W; -90 dBm = 1 pW (typical receiver sensitivity)
# dBi: antenna gain relative to isotropic radiator; 0 dBi = omnidirectional; 20 dBi = 100× power concentration
# PAPR: Peak-to-Average Power Ratio; high PAPR requires PA back-off reducing efficiency; OFDM has high PAPR (~8-12 dB); SC-FDMA has lower PAPR (~2-4 dB)
# 3GPP: Third Generation Partnership Project; standardization body for cellular (2G GSM onward); releases define features (R15=5G initial, R16/R17=5G evolution, R18+=5G-Advanced)
# confidence: synthetic domain knowledge — not extracted from a single source document

# relation_mapping(doc_rel|canonical_rel|notes)
characterized_by|composed_of|X is characterized by its properties = X composed of those attributes
inverse_of|complement_of|mathematical inverse relationship; symmetric
determines|determined_by|inverse query direction; "CO6 determines CO8" → CO8 determined_by CO6
constrains|constrains|exact match
modified_by|transforms_to|inverse direction; carrier modified by modulation = transforms via modulation
enables|enables|exact match
propagates_via|propagates_via|exact match
governs|governs|exact match
causes|causes|exact match
instance_of|instance_of|exact match
extends|extends|exact match
specializes|specializes|exact match
used_by|implements|inverse query direction; "MO13 used_by CG2" → CG2 implements MO13
selects|selects|exact match
evolves_to|evolves_to|exact match
connects_to|connects_to|exact match; symmetric
uses|requires|exact match in intent; AR2 uses AR6 = AR2 requires AR6
authenticates|validates|authentication is validation of identity
virtualizes|models|AR10 virtualizes AR4 = AR10 models AR4 as logical abstraction
co_located_with|part_of|physical co-location = part of same site
disaggregates|decomposes_to|exact semantic match; breaking into components
operates_at|scoped_to|protocol operates at layer = protocol scoped to that layer
protects|protects|exact match
complements|complements|exact match; symmetric
compensates_for|mitigated_by|inverse; SG3 compensates for PG5 = PG5 mitigated_by SG3
combats|mitigated_by|SG7 combats CO25 = CO25 mitigated_by SG7
exploits|input_to|SG8 exploits PG5 = PG5 is input to SG8's processing
decodes|reverses|decoding reverses encoding
implements|implements|exact match
amplifies|amplifies|exact match
digitizes|transforms_to|analog to digital is a transformation
synthesizes|produces|CP7 synthesizes signal = CP7 produces signal
processes|input_to|inverse; CP8 processes X = X is input_to CP8
separates|isolates|exact semantic match
drives|enables|CP5 drives CP4 = CP5 enables CP4
references|references|exact match
improved_by|enables|inverse; X improved by Y = Y enables better X
affects|degrades|failure affects component = failure degrades component
distinguishes|distinguishes|exact match
