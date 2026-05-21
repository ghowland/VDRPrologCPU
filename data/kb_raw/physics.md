# PHYSICS: LAWS, CONSTANTS, AND STRUCTURAL TRANSITIONS — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: domains → constants → concepts → laws → equations → particles → forces → transitions → thresholds → relationships → section_index → decode_legend

# domains(id|name|definition)
D1|classical mechanics|motion of macroscopic bodies under forces; Newton's framework
D2|thermodynamics|heat, work, energy, entropy; macroscopic equilibrium systems
D3|electromagnetism|electric and magnetic fields, charges, currents, radiation
D4|optics|behavior of light; refraction, diffraction, interference, polarization
D5|special relativity|mechanics at velocities approaching c; Lorentz invariance; mass-energy equivalence
D6|general relativity|gravitation as spacetime curvature; Einstein field equations
D7|quantum mechanics|physics at atomic/subatomic scale; wavefunctions, operators, measurement
D8|quantum field theory|relativistic quantum mechanics; fields as fundamental; particle creation/annihilation
D9|statistical mechanics|macroscopic properties derived from microscopic ensemble averages
D10|nuclear physics|structure and reactions of atomic nuclei; binding energy, decay, fission, fusion
D11|particle physics|fundamental particles and their interactions via gauge bosons
D12|condensed matter|collective behavior of many-body systems; phases, phase transitions, emergent phenomena
D13|cosmology|origin, structure, evolution of universe at largest scales
D14|astrophysics|physics of stars, galaxies, compact objects, interstellar medium

# constants(id|symbol|name|value|unit|notes)
K1|c|speed of light in vacuum|299,792,458|m/s|exact by definition (SI 2019)
K2|G|gravitational constant|6.67430 × 10⁻¹¹|m³ kg⁻¹ s⁻²|least precisely known fundamental constant
K3|ℏ|reduced Planck constant|1.054571817 × 10⁻³⁴|J·s|ℏ = h / 2π; exact by definition (SI 2019)
K4|h|Planck constant|6.62607015 × 10⁻³⁴|J·s|exact by definition (SI 2019)
K5|k_B|Boltzmann constant|1.380649 × 10⁻²³|J/K|exact by definition (SI 2019)
K6|e|elementary charge|1.602176634 × 10⁻¹⁹|C|exact by definition (SI 2019)
K7|ε₀|vacuum permittivity|8.8541878128 × 10⁻¹²|F/m|ε₀ = 1/(μ₀c²)
K8|μ₀|vacuum permeability|1.25663706212 × 10⁻⁶|N/A²|formerly exact 4π × 10⁻⁷; now derived
K9|N_A|Avogadro constant|6.02214076 × 10²³|mol⁻¹|exact by definition (SI 2019)
K10|σ|Stefan-Boltzmann constant|5.670374419 × 10⁻⁸|W m⁻² K⁻⁴|σ = 2π⁵k_B⁴ / (15h³c²)
K11|α|fine-structure constant|~1/137.035999084|dimensionless|α = e² / (4πε₀ℏc); coupling strength of EM interaction
K12|m_e|electron mass|9.1093837015 × 10⁻³¹|kg|—
K13|m_p|proton mass|1.67262192369 × 10⁻²⁷|kg|m_p / m_e ≈ 1836.15
K14|m_n|neutron mass|1.67492749804 × 10⁻²⁷|kg|m_n > m_p by 1.293 MeV/c²
K15|R_∞|Rydberg constant|10,973,731.568160|m⁻¹|hydrogen spectral series
K16|a₀|Bohr radius|5.29177210903 × 10⁻¹¹|m|a₀ = ℏ / (m_e c α)
K17|G_F|Fermi coupling constant|1.1663787 × 10⁻⁵|GeV⁻²|weak interaction strength
K18|Λ|cosmological constant|~1.1056 × 10⁻⁵²|m⁻²|drives accelerating expansion; value from observations
K19|H₀|Hubble constant|~67.4 (Planck) or ~73.0 (SH0ES)|km/s/Mpc|tension between early-universe and late-universe measurements unresolved
K20|T_CMB|CMB temperature|2.72548|K|cosmic microwave background blackbody temperature
K21|t_P|Planck time|5.391247 × 10⁻⁴⁴|s|t_P = √(ℏG/c⁵)
K22|l_P|Planck length|1.616255 × 10⁻³⁵|m|l_P = √(ℏG/c³)
K23|m_P|Planck mass|2.176434 × 10⁻⁸|kg|m_P = √(ℏc/G)
K24|E_P|Planck energy|1.220890 × 10¹⁹|GeV|E_P = m_P c²

# concepts(id|name|definition|category)
C1|inertia|body remains in uniform motion unless acted on by net external force|principle
C2|momentum|product of mass and velocity; conserved in isolated systems; p = mv|conserved_quantity
C3|angular momentum|rotational analog of momentum; L = r × p; conserved under rotational symmetry|conserved_quantity
C4|energy|capacity to do work; conserved in all isolated systems; manifests as kinetic, potential, thermal, electromagnetic, nuclear, mass-energy|conserved_quantity
C5|entropy|measure of microscopic multiplicity consistent with macroscopic state; S = k_B ln Ω; never decreases in isolated system|conserved_quantity
C6|charge|property of matter producing electromagnetic interaction; conserved in all known processes; quantized in units of e|conserved_quantity
C7|baryon number|net number of baryons minus antibaryons; conserved in Standard Model|conserved_quantity
C8|lepton number|net number of leptons minus antileptons; conserved per family in Standard Model (violated by neutrino oscillation)|conserved_quantity
C9|spin|intrinsic angular momentum of particle; quantized in half-integer (fermions) or integer (bosons) units of ℏ|quantum_property
C10|wave-particle duality|all matter and radiation exhibit both wave and particle properties depending on measurement context|principle
C11|superposition|quantum system exists in linear combination of eigenstates until measured|principle
C12|entanglement|quantum correlation between particles such that measurement of one instantaneously determines state of other regardless of separation|principle
C13|uncertainty principle|conjugate observables cannot both be known to arbitrary precision; ΔxΔp ≥ ℏ/2; ΔEΔt ≥ ℏ/2|principle
C14|Pauli exclusion principle|no two identical fermions can occupy same quantum state simultaneously|principle
C15|equivalence principle|gravitational mass equals inertial mass; freefall is locally indistinguishable from absence of gravity|principle
C16|gauge invariance|physical observables unchanged under local gauge transformations; dictates form of interactions|principle
C17|Noether's theorem|every continuous symmetry of action corresponds to a conserved quantity|principle
C18|Lorentz invariance|laws of physics take same form in all inertial reference frames|principle
C19|CPT symmetry|combined charge conjugation + parity + time reversal is exact symmetry of all known interactions|principle
C20|spontaneous symmetry breaking|ground state of system has less symmetry than its governing equations; generates mass via Higgs mechanism|mechanism
C21|renormalization|procedure to remove infinities from quantum field theory calculations by absorbing them into redefined parameters|mechanism
C22|phase transition|abrupt change in macroscopic properties at critical point; first-order (latent heat) or continuous (critical exponents)|mechanism
C23|degeneracy pressure|quantum mechanical pressure from Pauli exclusion; supports white dwarfs (electron) and neutron stars (neutron)|mechanism
C24|tunneling|quantum particle traverses potential barrier it classically cannot surmount; probability exponentially decreasing with barrier width and height|mechanism
C25|blackbody radiation|thermal electromagnetic radiation from opaque body in thermal equilibrium; spectrum depends only on temperature|phenomenon
C26|photoelectric effect|light ejects electrons from metal surface; energy depends on frequency not intensity; explained by photon quantization|phenomenon
C27|Compton scattering|photon scattering off free electron; wavelength shift depends on scattering angle; demonstrates photon momentum|phenomenon
C28|Casimir effect|attractive force between two uncharged parallel conducting plates due to vacuum fluctuation pressure difference|phenomenon
C29|Hawking radiation|thermal radiation emitted by black holes due to quantum effects near event horizon; temperature inversely proportional to mass|phenomenon
C30|cosmic inflation|exponential expansion of early universe (~10⁻³⁶ to ~10⁻³² s after Big Bang); solves horizon, flatness, monopole problems|mechanism
C31|dark matter|non-luminous matter comprising ~27% of universe energy density; detected via gravitational effects; composition unknown|unknown
C32|dark energy|energy comprising ~68% of universe energy density; drives accelerating expansion; possibly cosmological constant Λ|unknown
C33|frame dragging|rotating mass drags spacetime around it (Lense-Thirring effect); confirmed by Gravity Probe B|phenomenon
C34|gravitational lensing|mass curves spacetime causing light deflection; strong (multiple images), weak (statistical distortion), micro (brightness magnification)|phenomenon
C35|Chandrasekhar limit|maximum mass of stable white dwarf; ~1.4 M☉; above this electron degeneracy pressure fails → collapse|threshold
C36|Tolman-Oppenheimer-Volkoff limit|maximum mass of stable neutron star; ~2.0–2.5 M☉; above this neutron degeneracy pressure fails → black hole|threshold
C37|event horizon|boundary of black hole; escape velocity equals c; radius r_s = 2GM/c² (Schwarzschild)|boundary
C38|cosmological horizon|maximum distance from which light can reach observer given expansion; ~46.5 Gly comoving radius for observable universe|boundary
C39|Planck scale|energy/length/time scales where quantum gravity effects dominate; E ~ E_P, l ~ l_P, t ~ t_P|boundary
C40|decoherence|quantum superposition destroyed by interaction with environment; explains classical appearance of macroscopic world|mechanism
C41|virtual particle|quantum field fluctuation mediating force; off-mass-shell; exists within uncertainty time Δt ~ ℏ/ΔE|mechanism
C42|asymptotic freedom|strong coupling decreases at high energies / short distances; quarks behave as free at high Q²|mechanism
C43|confinement|quarks and gluons cannot exist as isolated free particles; color charge must form color-neutral hadrons|mechanism
C44|CP violation|charge-parity symmetry is violated in weak interactions; observed in kaon and B-meson systems; necessary for matter-antimatter asymmetry|phenomenon
C45|neutrino oscillation|neutrinos change flavor during propagation; implies nonzero neutrino mass; contradicts original Standard Model|phenomenon
C46|Bose-Einstein condensation|bosonic particles occupy same quantum ground state below critical temperature; macroscopic quantum coherence|phenomenon
C47|superconductivity|zero electrical resistance and Meissner effect below critical temperature; explained by Cooper pairing (BCS theory)|phenomenon
C48|superfluidity|zero viscosity flow below critical temperature; observed in He-4 (bosonic) and He-3 (fermionic pairing)|phenomenon
C49|symmetry|transformation that leaves physical system or equations unchanged; continuous (rotation, translation) or discrete (parity, charge conjugation)|principle
C50|locality|physical influences propagate at or below speed of light; no instantaneous action at distance|principle
C51|unitarity|total probability is conserved; time evolution operator is unitary; information is preserved|principle
C52|ergodic hypothesis|time average of system equals ensemble average; foundation of statistical mechanics|principle

# laws(id|name|statement|domain_fk|conditions|discovered_by|date)
L1|Newton's first law|body at rest stays at rest; body in uniform motion stays in uniform motion; unless acted on by net external force|D1|inertial reference frame; v << c|Newton|1687
L2|Newton's second law|net force on body equals rate of change of momentum; F = dp/dt = ma (constant mass)|D1|inertial frame; v << c; constant mass|Newton|1687
L3|Newton's third law|every action has equal and opposite reaction; F₁₂ = −F₂₁|D1|contact or instantaneous action; fails for EM radiation|Newton|1687
L4|Newton's law of gravitation|F = GMm/r²; every mass attracts every other mass; inverse square|D1|point masses or spherical; weak field; v << c|Newton|1687
L5|conservation of energy|total energy of isolated system is constant; energy transforms between forms but is neither created nor destroyed|D1,D2|all domains; includes mass-energy in relativity|Mayer, Joule, Helmholtz|~1842–1847
L6|conservation of momentum|total momentum of isolated system is constant; Σp = constant|D1|no external forces; translational symmetry (Noether)|Descartes, Newton|1644, 1687
L7|conservation of angular momentum|total angular momentum of isolated system is constant; ΣL = constant|D1|no external torques; rotational symmetry (Noether)|—|—
L8|zeroth law of thermodynamics|if A is in thermal equilibrium with B and B with C, then A is in thermal equilibrium with C|D2|defines temperature|—|formalized ~1930s
L9|first law of thermodynamics|ΔU = Q − W; internal energy change equals heat added minus work done|D2|closed system|Clausius, Kelvin|~1850
L10|second law of thermodynamics|entropy of isolated system never decreases; ΔS ≥ 0; heat flows spontaneously from hot to cold only|D2|statistical: overwhelmingly probable, not absolute for small N|Clausius, Kelvin|~1850
L11|third law of thermodynamics|entropy of perfect crystal approaches zero as temperature approaches absolute zero; T = 0 K is unattainable in finite steps|D2|perfect crystal; no residual entropy|Nernst|1906
L12|ideal gas law|PV = nRT = Nk_BT|D2|low density; no intermolecular forces; point particles|Clapeyron|1834
L13|Coulomb's law|F = ke q₁q₂/r²; like charges repel, unlike attract; inverse square|D3|point charges; static; vacuum|Coulomb|1785
L14|Gauss's law (electric)|∮ E·dA = Q_enc / ε₀; electric flux through closed surface proportional to enclosed charge|D3|any charge distribution|Gauss|1835
L15|Gauss's law (magnetic)|∮ B·dA = 0; no magnetic monopoles; magnetic field lines always close|D3|always; fundamental|Gauss|—
L16|Faraday's law|∮ E·dl = −dΦ_B/dt; changing magnetic flux induces electric field|D3|any loop; time-varying B|Faraday|1831
L17|Ampère-Maxwell law|∮ B·dl = μ₀(I_enc + ε₀ dΦ_E/dt); current and changing electric flux produce magnetic field|D3|any loop; displacement current term added by Maxwell|Ampère 1823; Maxwell 1865|1823, 1865
L18|Maxwell's equations|L14 + L15 + L16 + L17 as unified system; predict electromagnetic waves propagating at c|D3|vacuum or linear media; classical|Maxwell|1865
L19|Lorentz force law|F = q(E + v × B); force on charge in electromagnetic field|D3|any charge velocity|Lorentz|1895
L20|Snell's law|n₁ sin θ₁ = n₂ sin θ₂; refraction at interface between media|D4|geometric optics; wavelength << aperture|Snell, Descartes|1621
L21|law of reflection|θ_incident = θ_reflected; same plane|D4|specular surfaces|—|antiquity
L22|principle of least time (Fermat)|light follows path of least optical path length between two points|D4|geometric optics; equivalent to Snell and reflection|Fermat|1662
L23|Einstein's postulate 1 (relativity)|laws of physics are the same in all inertial reference frames|D5|inertial frames|Einstein|1905
L24|Einstein's postulate 2 (light)|speed of light in vacuum is the same for all inertial observers regardless of source motion|D5|vacuum; inertial frames|Einstein|1905
L25|time dilation|Δt = γΔt₀; moving clocks run slower; γ = 1/√(1 − v²/c²)|D5|inertial frames; v approaching c|Einstein|1905
L26|length contraction|L = L₀/γ; moving objects contract along direction of motion|D5|inertial frames; v approaching c|Einstein|1905
L27|mass-energy equivalence|E = mc²; rest energy of mass m; total energy E² = (pc)² + (mc²)²|D5|all frames|Einstein|1905
L28|Einstein field equations|G_μν + Λg_μν = (8πG/c⁴)T_μν; spacetime curvature determined by energy-momentum content|D6|classical gravity; breaks down at Planck scale|Einstein|1915
L29|Schwarzschild solution|spherically symmetric vacuum solution to L28; r_s = 2GM/c²; predicts black holes|D6|non-rotating, uncharged, spherical mass|Schwarzschild|1916
L30|Friedmann equations|describe expansion of homogeneous, isotropic universe; (ȧ/a)² = 8πGρ/3 − kc²/a² + Λc²/3|D6,D13|homogeneous, isotropic; cosmological principle|Friedmann|1922
L31|Schrödinger equation (time-dependent)|iℏ ∂ψ/∂t = Ĥψ; governs time evolution of quantum state|D7|non-relativistic; single or multi-particle|Schrödinger|1926
L32|Schrödinger equation (time-independent)|Ĥψ = Eψ; eigenvalue equation for stationary states|D7|non-relativistic; time-independent potential|Schrödinger|1926
L33|Born rule|probability of measurement outcome = |⟨φ|ψ⟩|²; wavefunction amplitude squared gives probability density|D7|all quantum measurements|Born|1926
L34|Heisenberg uncertainty principle|ΔxΔp ≥ ℏ/2; ΔEΔt ≥ ℏ/2; conjugate variables cannot both be precisely known|D7|all quantum systems|Heisenberg|1927
L35|Pauli exclusion principle|two identical fermions cannot occupy same quantum state; explains electron shell structure, degeneracy pressure|D7|fermions (half-integer spin)|Pauli|1925
L36|Dirac equation|(iγ^μ ∂_μ − m)ψ = 0; relativistic wave equation for spin-1/2 particles; predicts antimatter|D7,D8|spin-1/2; relativistic|Dirac|1928
L37|Planck's law|spectral radiance B(ν,T) = (2hν³/c²) × 1/(e^(hν/k_BT) − 1); blackbody radiation spectrum|D7,D2|thermal equilibrium; blackbody|Planck|1900
L38|photoelectric equation|E_kinetic = hν − φ; photon energy minus work function; threshold frequency ν₀ = φ/h|D7|metal surface; monochromatic light|Einstein|1905
L39|de Broglie relation|λ = h/p; every particle has associated wavelength|D7|all matter; non-relativistic approximation|de Broglie|1924
L40|Stefan-Boltzmann law|total radiated power per unit area j = σT⁴|D2|blackbody in thermal equilibrium|Stefan 1879; Boltzmann 1884|1879, 1884
L41|Wien's displacement law|λ_max T = 2.897771955 × 10⁻³ m·K; peak wavelength inversely proportional to temperature|D2|blackbody|Wien|1893
L42|Boltzmann entropy formula|S = k_B ln Ω; entropy proportional to log of number of microstates|D9|equilibrium; ergodic system|Boltzmann|1877
L43|partition function|Z = Σ_i e^(−E_i/k_BT); all thermodynamic quantities derivable from Z|D9|canonical ensemble; thermal equilibrium|Gibbs, Boltzmann|~1900
L44|Fermi-Dirac distribution|⟨n⟩ = 1/(e^((E−μ)/k_BT) + 1); occupation probability for fermions|D9|fermions in thermal equilibrium|Fermi, Dirac|1926
L45|Bose-Einstein distribution|⟨n⟩ = 1/(e^((E−μ)/k_BT) − 1); occupation probability for bosons|D9|bosons in thermal equilibrium|Bose, Einstein|1924
L46|radioactive decay law|N(t) = N₀ e^(−λt); t₁/₂ = ln2/λ; exponential decay of unstable nuclei|D10|large N; constant λ; no external influence|Rutherford, Soddy|1902
L47|mass-energy relation in nuclear binding|B = Zm_p c² + Nm_n c² − M_nucleus c²; binding energy = mass defect × c²|D10|any nucleus|Aston|1920s
L48|Hubble's law|v = H₀d; recession velocity proportional to distance; expansion of space|D13|cosmological distances; homogeneous expansion|Hubble, Lemaître|1927, 1929
L49|Kepler's first law|planets orbit in ellipses with Sun at one focus|D1|two-body gravitational; negligible perturbation|Kepler|1609
L50|Kepler's second law|line from Sun to planet sweeps equal areas in equal times|D1|conservation of angular momentum|Kepler|1609
L51|Kepler's third law|T² ∝ a³; orbital period squared proportional to semi-major axis cubed|D1|two-body; Newtonian: T² = 4π²a³/(GM)|Kepler|1619
L52|Archimedes' principle|buoyant force on submerged body equals weight of displaced fluid|D1|incompressible fluid; gravitational field|Archimedes|~250 BCE
L53|Pascal's principle|pressure applied to confined fluid transmitted equally in all directions|D1|incompressible fluid; static|Pascal|1653
L54|Bernoulli's principle|P + ½ρv² + ρgh = constant along streamline; pressure decreases as fluid velocity increases|D1|incompressible, inviscid, steady flow along streamline|Bernoulli|1738
L55|Ohm's law|V = IR; voltage proportional to current for ohmic materials|D3|ohmic conductors; constant temperature|Ohm|1827
L56|Kirchhoff's current law|sum of currents entering node equals sum leaving; ΣI_in = ΣI_out|D3|conservation of charge at junction|Kirchhoff|1845
L57|Kirchhoff's voltage law|sum of voltage drops around closed loop equals zero; ΣV = 0|D3|conservation of energy around loop|Kirchhoff|1845
L58|Hooke's law|F = −kx; restoring force proportional to displacement from equilibrium|D1|elastic limit; small deformations|Hooke|1660
L59|law of universal gravitation (general form)|gravitational potential Φ satisfies ∇²Φ = 4πGρ; Poisson equation for gravity|D1|Newtonian limit; weak field; v << c|Poisson|1813
L60|continuity equation|∂ρ/∂t + ∇·(ρv) = 0; conservation of mass/charge in flow|D1,D3|any conserved quantity in continuum|Euler|1757
L61|Navier-Stokes equations|ρ(∂v/∂t + v·∇v) = −∇P + μ∇²v + f; momentum conservation for viscous fluid|D1|Newtonian viscous fluid; continuum|Navier 1822; Stokes 1845|1822, 1845
L62|wave equation|∂²ψ/∂t² = v²∇²ψ; governs propagation of mechanical and electromagnetic waves|D1,D3,D4|linear medium; small amplitude|d'Alembert|1747
L63|Rayleigh-Jeans law|B(ν,T) = 2ν²k_BT/c²; classical prediction for blackbody; diverges at high frequency (ultraviolet catastrophe)|D2|classical limit of L37; fails at high ν; historically motivated quantization|Rayleigh, Jeans|1900, 1905

# particles(id|name|symbol|type|spin|charge_e|mass|generation|interaction)
# Quarks
P1|up quark|u|quark|1/2|+2/3|~2.16 MeV/c²|1|strong, EM, weak
P2|down quark|d|quark|1/2|−1/3|~4.67 MeV/c²|1|strong, EM, weak
P3|charm quark|c|quark|1/2|+2/3|~1.27 GeV/c²|2|strong, EM, weak
P4|strange quark|s|quark|1/2|−1/3|~93 MeV/c²|2|strong, EM, weak
P5|top quark|t|quark|1/2|+2/3|~172.69 GeV/c²|3|strong, EM, weak
P6|bottom quark|b|quark|1/2|−1/3|~4.18 GeV/c²|3|strong, EM, weak
# Leptons
P7|electron|e⁻|lepton|1/2|−1|0.51099895 MeV/c²|1|EM, weak
P8|electron neutrino|ν_e|lepton|1/2|0|< 0.8 eV/c² (upper bound)|1|weak
P9|muon|μ⁻|lepton|1/2|−1|105.6583755 MeV/c²|2|EM, weak
P10|muon neutrino|ν_μ|lepton|1/2|0|< 0.19 MeV/c² (upper bound)|2|weak
P11|tau|τ⁻|lepton|1/2|−1|1776.86 MeV/c²|3|EM, weak
P12|tau neutrino|ν_τ|lepton|1/2|0|< 18.2 MeV/c² (upper bound)|3|weak
# Gauge bosons
P13|photon|γ|gauge boson|1|0|0|—|mediates EM
P14|W+ boson|W⁺|gauge boson|1|+1|80.377 GeV/c²|—|mediates weak (charged current)
P15|W− boson|W⁻|gauge boson|1|−1|80.377 GeV/c²|—|mediates weak (charged current)
P16|Z boson|Z⁰|gauge boson|1|0|91.1876 GeV/c²|—|mediates weak (neutral current)
P17|gluon|g|gauge boson|1|0|0|—|mediates strong; carries color charge; 8 types
P18|graviton|G (hypothetical)|gauge boson|2|0|0|—|hypothetical mediator of gravity; not yet detected
# Scalar boson
P19|Higgs boson|H⁰|scalar boson|0|0|125.25 GeV/c²|—|gives mass to W, Z, and fermions via Yukawa coupling
# Composite
P20|proton|p|baryon|1/2|+1|938.272 MeV/c²|—|uud; stable (mean lifetime > 10³⁴ years)
P21|neutron|n|baryon|1/2|0|939.565 MeV/c²|—|udd; free neutron half-life ~610 s
P22|pion (charged)|π±|meson|0|±1|139.570 MeV/c²|—|lightest meson; mediates residual strong force
P23|pion (neutral)|π⁰|meson|0|0|134.977 MeV/c²|—|decays to 2γ; mean lifetime 8.4 × 10⁻¹⁷ s

# forces(id|name|mediator|relative_strength|range|acts_on|gauge_group)
F1|gravitational|P18 (hypothetical)|~10⁻³⁸ (relative to strong)|infinite (1/r²)|all mass-energy|—
F2|electromagnetic|P13 (photon)|~1/137 (α)|infinite (1/r²)|electric charge|U(1)_EM
F3|weak nuclear|P14,P15,P16 (W±, Z⁰)|~10⁻⁶|~10⁻¹⁸ m (range ~ ℏ/(m_W c))|all fermions|SU(2)_L
F4|strong nuclear|P17 (gluon)|1 (reference)|~10⁻¹⁵ m (confinement); asymptotic freedom at short range|color-charged particles (quarks, gluons)|SU(3)_C
F5|residual strong (nuclear)|P22,P23 (pion exchange)|~1–20% of F4|~1–3 × 10⁻¹⁵ m|nucleons (protons, neutrons)|derived from F4

# transitions(id|domain|prior_state|new_state|date|trigger)
# Conceptual / theoretical transitions
TR1|D1|no formal mechanics|Aristotelian physics (natural place, impetus)|~350 BCE|Aristotle's Physics and On the Heavens
TR2|D1|Aristotelian physics|Galilean mechanics (inertia, falling bodies, kinematics)|1589–1638|Galileo experiments and Discorsi
TR3|D1|Galilean kinematics|Newtonian mechanics (F=ma, gravity, calculus)|1687|Newton Principia Mathematica
TR4|D1|Newtonian mechanics + absolute space|Lagrangian/Hamiltonian mechanics (generalized coordinates, least action)|1788 (Lagrange); 1833 (Hamilton)|Mécanique Analytique; Hamiltonian formulation
TR5|D2|caloric theory (heat as fluid)|kinetic theory of heat (heat as molecular motion)|~1798–1850|Rumford cannon-boring; Joule mechanical equivalent of heat
TR6|D2|no entropy concept|entropy and second law formalized|1850–1865|Clausius defines entropy; Kelvin absolute temperature
TR7|D9|thermodynamics without microscopic basis|statistical mechanics (Boltzmann, Gibbs)|1877–1902|Boltzmann H-theorem and S = k_B ln Ω; Gibbs ensemble theory
TR8|D3|separate electric and magnetic phenomena|unified electromagnetism|1865|Maxwell's equations; EM waves predicted
TR9|D3|action at a distance (Coulomb)|field theory (Faraday fields, Maxwell equations)|1831–1865|Faraday field concept; Maxwell mathematical formulation
TR10|D4|corpuscular theory of light (Newton)|wave theory of light|1801–1818|Young double-slit; Fresnel diffraction theory
TR11|D4|wave theory (mechanical ether)|electromagnetic wave theory (no ether needed)|1865–1887|Maxwell identifies light as EM wave; Michelson-Morley null result
TR12|D5|Galilean relativity + absolute time|special relativity (Lorentz invariance)|1905|Einstein "On the Electrodynamics of Moving Bodies"
TR13|D6|Newtonian gravity (instantaneous, flat space)|general relativity (spacetime curvature)|1915|Einstein field equations
TR14|D7|classical deterministic trajectories|quantum mechanics (wavefunctions, probabilistic)|1900–1926|Planck quanta; Bohr atom; Heisenberg matrix mechanics; Schrödinger wave equation
TR15|D7|old quantum theory (Bohr model, ad hoc quantization)|full quantum mechanics (Hilbert space, operators, Born rule)|1925–1927|Heisenberg, Schrödinger, Born, Dirac
TR16|D7|non-relativistic QM|relativistic quantum mechanics (Dirac equation)|1928|Dirac equation; predicts positron
TR17|D8|single-particle QM|quantum field theory (second quantization)|1927–1949|Dirac radiation theory; Tomonaga-Schwinger-Feynman QED renormalization
TR18|D8|QED only|electroweak unification (EM + weak)|1967–1971|Glashow-Weinberg-Salam model; 't Hooft renormalizability proof
TR19|D8|separate strong interaction theory|quantum chromodynamics (QCD)|1973|Gross, Wilczek, Politzer asymptotic freedom; SU(3) color gauge theory
TR20|D8|separate electroweak + QCD|Standard Model (SU(3)×SU(2)×U(1))|~1973–1979|Glashow-Weinberg-Salam + QCD unified framework
TR21|D13|static eternal universe|expanding universe (Big Bang)|1927–1929|Lemaître 1927; Hubble redshift-distance 1929
TR22|D13|steady-state vs Big Bang debate|Big Bang confirmed (CMB detection)|1964|Penzias and Wilson detect 2.725 K microwave background
TR23|D13|decelerating expansion assumed|accelerating expansion (dark energy)|1998|Perlmutter, Riess, Schmidt: Type Ia supernovae dimmer than expected
TR24|D10|atom as indivisible|subatomic structure (electron, nucleus)|1897–1911|Thomson electron 1897; Rutherford nucleus 1911
TR25|D10|static nucleus model|nuclear reactions (fission, fusion)|1938–1952|Hahn-Strassmann fission 1938; thermonuclear fusion 1952
TR26|D11|hadron zoo (hundreds of particles)|quark model (3 quarks compose hadrons)|1964|Gell-Mann and Zweig quark model
TR27|D11|3 quark flavors|6 quark flavors confirmed|1974–1995|charm 1974 (J/ψ); bottom 1977 (Υ); top 1995 (Tevatron)
TR28|D11|electroweak theory without mass mechanism|Higgs mechanism confirmed|2012|ATLAS and CMS at LHC detect Higgs boson at ~125 GeV
TR29|D12|classical phase theory|quantum phase transitions and topological phases|~1980–present|quantum Hall effect 1980; topological insulators 2005+
TR30|D7|massless neutrinos in Standard Model|neutrino oscillation confirms nonzero mass|1998–2002|Super-Kamiokande atmospheric ν oscillation 1998; SNO solar ν 2002
# Experimental confirmation transitions
TR31|D5|SR predicted|SR confirmed (time dilation)|1938–1971|muon lifetime; Hafele-Keating 1971 atomic clocks on aircraft
TR32|D6|GR predicted gravitational waves|gravitational waves detected|2015 (detection); 2016 (announced)|LIGO binary black hole merger GW150914
TR33|D6|GR predicted black holes|black hole imaged|2019|Event Horizon Telescope M87* shadow image
TR34|D12|BCS theory predicted Cooper pairs|superconductivity explained and high-T_c discovered|1957 (BCS); 1986 (high-T_c)|Bardeen-Cooper-Schrieffer; Bednorz-Müller cuprate superconductors
TR35|D7|entanglement as theoretical|Bell inequality violated experimentally|1982 (Aspect); 2022 (Nobel: loophole-free)|Aspect experiment; Clauser, Aspect, Zeilinger Nobel 2022
TR36|D12|predicted Bose-Einstein condensate|BEC created in laboratory|1995|Cornell, Wieman, Ketterle: rubidium-87 atoms cooled to nanokelvin

# thresholds(id|name|value|unit|significance)
TH1|Planck energy|1.220890 × 10¹⁹|GeV|quantum gravity effects dominate; all four forces comparable; current physics breaks down
TH2|electroweak symmetry breaking|~246|GeV|Higgs field VEV; W±, Z acquire mass; EM and weak separate below this scale
TH3|QCD confinement scale (Λ_QCD)|~200|MeV|below this energy, quarks confined into hadrons; perturbative QCD fails
TH4|Chandrasekhar limit|~1.4|M☉|maximum white dwarf mass; above → Type Ia supernova or neutron star
TH5|TOV limit|~2.0–2.5|M☉|maximum neutron star mass; above → black hole
TH6|Schwarzschild radius|r_s = 2GM/c²|m|event horizon; escape velocity = c; causal boundary
TH7|CMB decoupling temperature|~3,000|K (~0.26 eV)|photons decouple from matter; universe becomes transparent; z ≈ 1100; t ≈ 380,000 yr
TH8|nucleosynthesis window|~10⁹–10⁸|K (t ≈ 10s – 20min post-BB)|protons and neutrons fuse to form H-2, He-3, He-4, Li-7; sets primordial abundances
TH9|absolute zero|0|K|lowest possible temperature; unattainable in finite steps (third law); quantum ground state
TH10|speed of light|299,792,458|m/s|maximum signal velocity; causal limit; mass-energy boundary
TH11|Bohr energy (hydrogen ground state)|−13.6|eV|ionization energy of hydrogen; sets atomic energy scale
TH12|nuclear binding energy peak|~8.8|MeV/nucleon (Fe-56, Ni-62)|maximum binding energy per nucleon; fusion releases energy below; fission releases energy above

# relationships(from|rel|to)
# domain dependencies
D5|extends|D1
D6|extends|D5
D7|extends|D1
D8|extends|D7
D8|extends|D5
D9|extends|D2
D9|extends|D7
D10|depends_on|D7
D10|depends_on|D8
D11|depends_on|D8
D12|depends_on|D7
D12|depends_on|D9
D13|depends_on|D6
D13|depends_on|D8
D14|depends_on|D10
D14|depends_on|D6
D4|specializes|D3
# conservation laws from Noether
C17|enables|L5
C17|enables|L6
C17|enables|L7
C17|enables|C6
L5|instance_of|C4
L6|instance_of|C2
L7|instance_of|C3
# symmetry → force structure
C16|enables|F2
C16|enables|F3
C16|enables|F4
C49|enables|C16
C49|enables|C17
C49|enables|C19
# quantum principles → phenomena
C10|enables|C26
C10|enables|C27
C11|enables|C12
C11|enables|C40
C13|enables|C24
C13|equivalent_to|L34
C14|enables|C23
C14|enables|C46
C14|enables|C47
C14|equivalent_to|L35
C20|enables|P19
C20|enables|TH2
C21|enables|TR17
# force → mediator
F1|determined_by|P18
F2|determined_by|P13
F3|determined_by|P14,P15,P16
F4|determined_by|P17
F5|derived_from|F4
# particle hierarchy
P1|part_of|P20
P1|part_of|P20
P2|part_of|P20
P2|part_of|P21
P20|composed_of|P1,P1,P2
P21|composed_of|P1,P2,P2
P22|composed_of|P1,P2
# generation structure
P1|generalizes|P3
P3|generalizes|P5
P2|generalizes|P4
P4|generalizes|P6
P7|generalizes|P9
P9|generalizes|P11
P8|generalizes|P10
P10|generalizes|P12
# Higgs gives mass
P19|enables|P14
P19|enables|P15
P19|enables|P16
P19|enables|P1,P2,P3,P4,P5,P6,P7,P9,P11
# law dependencies
L2|requires|C1
L4|specializes|L28
L18|composed_of|L14,L15,L16,L17
L18|enables|L24
L19|requires|L14,L16
L28|generalizes|L4
L29|derived_from|L28
L30|derived_from|L28
L31|generalizes|L32
L36|extends|L31
L36|requires|L23
L37|enables|L40
L37|enables|L41
L38|requires|L37
L39|requires|L37
L42|enables|L43
L43|enables|L44
L43|enables|L45
L44|requires|C14
L45|requires|C9
L46|determined_by|C24
L47|requires|L27
L48|derived_from|L30
L49|derived_from|L4
L50|derived_from|L7
L51|derived_from|L4
L55|specializes|L19
L58|enables|L62
L59|generalizes|L4
L60|enables|L61
L62|derived_from|L2
L63|contradicts|L37
L63|causes|TR14
# transition chains
TR1|precedes|TR2
TR2|precedes|TR3
TR3|precedes|TR4
TR3|precedes|TR12
TR5|precedes|TR6
TR6|precedes|TR7
TR8|enables|TR11
TR9|enables|TR8
TR10|precedes|TR11
TR11|enables|TR12
TR12|precedes|TR13
TR14|precedes|TR15
TR15|precedes|TR16
TR16|enables|TR17
TR17|precedes|TR18
TR17|precedes|TR19
TR18|enables|TR20
TR19|enables|TR20
TR20|enables|TR28
TR21|precedes|TR22
TR22|precedes|TR23
TR24|precedes|TR25
TR24|enables|TR26
TR26|precedes|TR27
TR30|contradicts|TR20
# experimental confirmations
TR31|validates|L25
TR32|validates|L28
TR33|validates|C37
TR34|validates|C47
TR35|validates|C12
TR36|validates|C46
TR28|validates|C20
# constant → law/threshold
K1|enables|L24,L27
K2|enables|L4,L28
K3|enables|L31,L34
K4|enables|L37,L38,L39
K5|enables|L42,L43
K6|enables|L13,L19
K7|enables|L14
K8|enables|L17
K11|determines|F2
K17|determines|F3
K18|enables|L30
K19|determined_by|L30
K21|part_of|C39
K22|part_of|C39
K23|part_of|C39
K24|part_of|C39
# threshold dependencies
TH1|requires|K21,K22,K23
TH2|determined_by|P19
TH3|determined_by|F4
TH4|determined_by|C23
TH5|determined_by|C23
TH6|derived_from|L29
TH7|determined_by|L37
TH8|requires|L47
TH9|determined_by|L11
TH10|equivalent_to|K1
TH11|derived_from|L32
TH12|determined_by|L47
# strong force internal
C42|enables|C43
C43|requires|C42
# anti-patterns / open problems
C31|contradicts|C32
K19|contradicts|K19
C45|contradicts|TR20

# section_index(section|title|ids)
1|Domains|D1-D14
2|Fundamental Constants|K1-K24
3|Core Concepts and Principles|C1-C52
4|Laws and Equations|L1-L63
5|Fundamental Particles|P1-P23
6|Fundamental Forces|F1-F5
7|Theoretical Transitions|TR1-TR36
8|Physical Thresholds|TH1-TH12

# decode_legend
id_prefixes: D=domain, K=constant, C=concept, L=law, P=particle, F=force, TR=transition, TH=threshold
rel_types: enables|requires|prevents|extends|validates|verified_by|contradicts|causes|determined_by|depends_on|equivalent_to|specializes|generalizes|part_of|contains|follows|precedes|instance_of|derived_from|composed_of|transforms_to
notation: ~=approximate value; ℏ=h-bar (reduced Planck); γ=Lorentz factor; ∮=closed surface/line integral; ∇²=Laplacian; ∂=partial derivative; M☉=solar mass; eV=electron volt; GeV=gigaelectron volt; MeV=megaelectron volt; _fk=foreign key; e=elementary charge unit (context distinguishes from Euler's number)
confidence: constant values from CODATA 2018 / PDG 2023; particle masses from PDG 2023; cosmological parameters from Planck 2018 + SH0ES; all facts at reference_physics confidence level
scope: physics from classical mechanics through Standard Model and general relativity; excludes speculative beyond-SM theories (string theory, loop quantum gravity, SUSY) except where noted as open problems; covers established experimental results through 2023
