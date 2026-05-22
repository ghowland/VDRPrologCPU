# CHEMISTRY — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: concepts → atomic_structure → periodic_trends → bonding → states_of_matter → reactions → stoichiometry → thermodynamics → kinetics → equilibrium → acids_bases → electrochemistry → organic → solutions → nuclear → laboratory → failure_modes → distinctions → relationships → decode_legend

# concepts(id|name|definition|category)
CO1|Atom|smallest unit of an element retaining chemical identity; nucleus (protons + neutrons) surrounded by electron cloud; diameter ~10⁻¹⁰ m; mass concentrated in nucleus (~10⁻¹⁵ m)|foundation
CO2|Element|substance composed of atoms with identical atomic number (proton count); 118 known; organized in periodic table; cannot be decomposed by chemical means|foundation
CO3|Compound|substance composed of two or more elements in fixed ratio bonded chemically; properties differ from constituent elements; water (H₂O) ≠ hydrogen + oxygen|foundation
CO4|Molecule|smallest unit of a compound (or diatomic element) retaining chemical properties; atoms held by covalent bonds; H₂O, CO₂, O₂|foundation
CO5|Ion|atom or group with net electric charge from gaining (anion, negative) or losing (cation, positive) electrons; Na⁺, Cl⁻, SO₄²⁻|foundation
CO6|Mole|6.022 × 10²³ entities (Avogadro's number); bridges atomic scale to macroscopic scale; 1 mole of ¹²C = exactly 12 g; molar mass = mass of 1 mole in grams|foundation
CO7|Chemical Reaction|process where bonds break and form, rearranging atoms into new substances; reactants → products; conserves mass, atom count, and charge|foundation
CO8|Chemical Equation|symbolic representation of reaction; reactants left, products right, arrow indicates direction; must be balanced (same atoms each side); coefficients indicate mole ratios|foundation
CO9|Conservation of Mass|total mass of reactants = total mass of products; atoms rearranged not created or destroyed; Lavoisier; foundation of stoichiometry|law
CO10|Conservation of Energy|energy neither created nor destroyed, only transformed; total energy of isolated system is constant; first law of thermodynamics applied to chemistry|law
CO11|Periodic Law|properties of elements are periodic functions of atomic number; elements arranged by increasing atomic number show recurring patterns in properties|law
CO12|Valence|combining capacity of atom; number of bonds atom typically forms; related to valence electron count; carbon = 4, oxygen = 2, hydrogen = 1, nitrogen = 3|foundation
CO13|Oxidation State|hypothetical charge assigned to atom assuming all bonds are ionic; tracks electron transfer; increases in oxidation, decreases in reduction; sum of oxidation states = overall charge|foundation
CO14|Concentration|amount of solute per amount of solution or solvent; molarity (mol/L), molality (mol/kg solvent), mass percent, ppm, mole fraction|foundation
CO15|Empirical Formula|simplest whole-number ratio of atoms in compound; CH₂O (glucose empirical); derived from percent composition|foundation
CO16|Molecular Formula|actual number of atoms of each element in molecule; C₆H₁₂O₆ (glucose molecular); integer multiple of empirical|foundation

# atomic_structure(id|name|definition|properties|significance)
AT1|Proton|positive subatomic particle in nucleus; mass ≈ 1.673 × 10⁻²⁷ kg (≈ 1 amu); charge = +1; atomic number = proton count defines element identity|proton count defines element; changing proton count = transmutation (different element); hydrogen has 1, carbon 6, iron 26, uranium 92|atomic number (Z) = number of protons; identity of element
AT2|Neutron|neutral subatomic particle in nucleus; mass ≈ 1.675 × 10⁻²⁷ kg (≈ 1 amu); no charge; number varies creating isotopes|neutron count varies among isotopes of same element; affects nuclear stability; determines atomic mass; contributes to nuclear binding energy|mass number (A) = protons + neutrons; isotope notation: ¹²C, ¹⁴C
AT3|Electron|negative subatomic particle in electron cloud; mass ≈ 9.109 × 10⁻³¹ kg (≈ 1/1836 amu); charge = -1; determines chemical behavior|electron count = proton count in neutral atom; loss/gain creates ions; electron configuration determines chemical properties, bonding, and reactivity|chemical behavior is electron behavior; all chemistry is fundamentally about electron arrangement
AT4|Electron Configuration|distribution of electrons among energy levels (shells) and subshells (s, p, d, f); fills by aufbau principle, Pauli exclusion, Hund's rule|notation: 1s² 2s² 2p⁶ 3s² 3p⁶...; shorthand uses noble gas core [Ne] 3s² 3p⁶; valence electrons in outermost shell determine chemistry|aufbau: fill lowest energy first; Pauli: max 2 electrons per orbital (opposite spin); Hund: fill degenerate orbitals singly before pairing; explains periodic table structure
AT5|Orbital|mathematical function describing probability of finding electron in space; s (spherical), p (dumbbell, 3 orientations), d (cloverleaf, 5), f (complex, 7)|each orbital holds max 2 electrons; energy: 1s < 2s < 2p < 3s < 3p < 4s < 3d (approximate; exceptions exist); shape determines bonding geometry|quantum mechanical description; replaces Bohr orbit model; square of wavefunction = probability density; nodes, lobes, phases
AT6|Valence Electrons|electrons in outermost (highest principal quantum number) shell; determine bonding, reactivity, and chemical properties|group 1: 1 valence e⁻; group 2: 2; groups 13-18: 3-8; transition metals: more complex (d electrons); noble gases: full valence shell (8, except He: 2)|valence electron count = group number for main group; periodic trends in reactivity follow valence electron patterns; octet rule: atoms tend toward 8 valence electrons
AT7|Isotope|atoms of same element (same proton count) with different neutron count; same chemistry, different mass; some stable, some radioactive|carbon-12 (6p, 6n, stable), carbon-13 (6p, 7n, stable, NMR-active), carbon-14 (6p, 8n, radioactive, t½ = 5730 years)|isotope notation: mass number as superscript; atomic mass on periodic table = weighted average of isotope masses; radioisotopes used in dating, medicine, energy
AT8|Quantum Numbers|four numbers (n, l, mₗ, mₛ) defining electron state; n = shell (1,2,3...); l = subshell (0 to n-1: s,p,d,f); mₗ = orbital orientation (-l to +l); mₛ = spin (+½ or -½)|each electron has unique set (Pauli exclusion); n determines energy and size; l determines shape; mₗ determines spatial orientation; mₛ determines spin direction|complete description of electron state; Pauli exclusion principle: no two electrons in atom share all four quantum numbers

# periodic_trends(id|name|definition|trend_across_period|trend_down_group|explanation)
PT1|Atomic Radius|distance from nucleus to outermost electron shell boundary; measured as half of internuclear distance in bonded atoms|decreases left → right (more protons pull electrons closer at same shell)|increases top → bottom (more shells = larger electron cloud)|across period: increasing nuclear charge at same principal quantum number contracts electron cloud; down group: each period adds a shell, increasing distance from nucleus
PT2|Ionization Energy (IE)|minimum energy to remove outermost electron from gaseous atom; X(g) → X⁺(g) + e⁻; measured in kJ/mol|increases left → right (smaller atom, stronger nuclear pull on electrons)|decreases top → bottom (outermost electron farther from nucleus, easier to remove)|higher IE = harder to remove electron = less metallic; noble gases highest IE; alkali metals lowest; successive IE values increase (removing each subsequent electron harder)
PT3|Electron Affinity (EA)|energy change when atom gains electron in gas phase; X(g) + e⁻ → X⁻(g); negative value = exothermic (favorable)|generally becomes more negative (more favorable) left → right; halogens most negative (most favorable)|generally becomes less negative top → bottom (atom larger, less attraction for added electron)|halogens: highest EA (one electron from full octet); noble gases: near-zero or positive EA (full shell, no benefit from extra electron); group 2 and group 15: anomalously low (stable subshell or half-filled subshell)
PT4|Electronegativity (EN)|tendency of atom to attract shared electrons in a bond; Pauling scale (F = 4.0, most electronegative)|increases left → right (smaller atom, more nuclear charge, pulls shared electrons)|decreases top → bottom (electrons farther from nucleus, less pull)|determines bond polarity; EN difference: <0.4 nonpolar covalent; 0.4-1.7 polar covalent; >1.7 ionic (approximate guidelines); F > O > N > Cl > Br > S > C > H
PT5|Metallic Character|tendency to lose electrons, form cations, conduct electricity, be malleable/ductile; metals are reducing agents|decreases left → right (increasing IE, EA, EN)|increases top → bottom (decreasing IE, lower EN)|metals: left side + bottom; nonmetals: right side + top; metalloids: diagonal boundary (B, Si, Ge, As, Sb, Te); alkali metals most metallic
PT6|Ionic Radius|radius of ion; cations smaller than parent atom (lost electrons); anions larger than parent atom (gained electrons)|cation radii decrease left → right within a period for isoelectronic series; anion radii decrease left → right|increases top → bottom for same group|Na⁺ (0.95 Å) < Na (1.86 Å); Cl⁻ (1.81 Å) > Cl (0.99 Å); isoelectronic series: O²⁻ > F⁻ > Na⁺ > Mg²⁺ (same electron count, more protons = smaller)

# bonding(id|name|definition|properties|examples)
BO1|Ionic Bond|electrostatic attraction between oppositely charged ions; metal transfers electron(s) to nonmetal; EN difference typically > 1.7|high melting/boiling point (strong electrostatic lattice); brittle crystalline solids; conduct electricity when dissolved or molten (ions mobile); soluble in polar solvents|NaCl (Na⁺ + Cl⁻); MgO (Mg²⁺ + O²⁻); CaCl₂; lattice energy governs stability (proportional to charge product, inversely proportional to ion distance)
BO2|Covalent Bond|sharing of electron pair(s) between atoms; typically nonmetal-nonmetal; EN difference typically < 1.7; single (1 pair), double (2 pairs), triple (3 pairs)|lower melting point than ionic (intermolecular forces weaker than ionic bonds); molecular compounds; may be polar or nonpolar; do not conduct electricity typically|H₂O (polar covalent); CO₂ (polar bonds, nonpolar molecule); N₂ (triple bond, nonpolar); CH₄ (nonpolar covalent)
BO3|Metallic Bond|delocalized electron sea shared among metal cations in lattice; valence electrons not associated with specific atoms|conduct electricity and heat (mobile electrons); malleable and ductile (layers slide without breaking bonds); metallic luster (electrons interact with light); variable melting points|Fe, Cu, Al, Au, Na; alloys: mixture of metals (bronze = Cu+Sn; steel = Fe+C; brass = Cu+Zn)
BO4|Polar Covalent Bond|unequal sharing of electrons; electron density shifted toward more electronegative atom; creates partial charges (δ⁺ and δ⁻); creates dipole moment|intermediate between ionic and nonpolar covalent; EN difference 0.4-1.7; dipole moment measurable; affects intermolecular forces|H-O (δ⁺H—Oδ⁻); H-N; H-Cl; C-O; determines molecular polarity (depends on molecular geometry — symmetric arrangements of polar bonds can cancel)
BO5|Coordinate (Dative) Covalent Bond|both shared electrons come from same atom; one atom donates lone pair to empty orbital of other; once formed, indistinguishable from regular covalent bond|common in complex ions and Lewis acid-base reactions; NH₄⁺ (NH₃ donates lone pair to H⁺); transition metal complexes|NH₃→BF₃; H₃O⁺ (water donates to H⁺); metal coordination compounds [Cu(NH₃)₄]²⁺; CO bonding to metals
BO6|Hydrogen Bond|unusually strong intermolecular attraction between H bonded to F, O, or N and lone pair on F, O, or N of another molecule; ~5-30 kJ/mol (vs ~400 kJ/mol covalent)|explains anomalously high boiling points of H₂O, HF, NH₃; responsible for water's unique properties; DNA base pairing; protein secondary structure|H₂O···H₂O; NH₃···NH₃; DNA: adenine-thymine (2 H-bonds), guanine-cytosine (3); protein α-helix and β-sheet; strongest intermolecular force (excluding ion-dipole)
BO7|Van der Waals Forces (London Dispersion)|instantaneous and induced dipole attractions between all atoms/molecules; strength increases with electron count (more polarizable); weakest intermolecular force|present in ALL molecules; only intermolecular force for nonpolar molecules; increases with molecular weight and surface area; explains why noble gases and nonpolar molecules liquefy at low temp|Ar-Ar; CH₄-CH₄; I₂ (solid at room temp due to large electron cloud → strong LDF); linear molecules have higher LDF than branched (more surface contact)
BO8|Dipole-Dipole Forces|attraction between permanent dipoles of polar molecules; positive end of one molecule attracts negative end of another; ~5-25 kJ/mol|stronger than London forces for similar-size molecules; affects boiling point (polar > nonpolar at similar MW); alignment of dipoles in solid state|HCl-HCl; acetone-acetone; SO₂-SO₂; determines solubility patterns (like dissolves like); intermediate strength intermolecular force
BO9|Ion-Dipole Forces|attraction between ion and polar molecule; strongest intermolecular force; governs dissolution of ionic compounds in polar solvents|drives solvation/hydration of ions; energy released during dissolution can overcome lattice energy; smaller/more charged ions → stronger ion-dipole interaction|Na⁺ surrounded by water molecules (δ⁻ oxygen faces cation); Cl⁻ surrounded by water (δ⁺ hydrogen faces anion); hydration shells; salting out
BO10|Lewis Structure|diagram showing bonding and lone pairs; follows octet rule (8 valence electrons per atom, except H: 2); multiple valid structures → resonance|count valence electrons; connect atoms with bonds; distribute remaining as lone pairs; octet check; formal charge minimization; resonance structures when multiple valid arrangements exist|H₂O: H-O-H with 2 lone pairs on O; CO₂: O=C=O; NO₃⁻: three resonance structures (each O takes turn double-bonding to N); BF₃: incomplete octet (exception); SF₆: expanded octet (exception)
BO11|VSEPR Theory|valence shell electron pair repulsion: electron groups (bonding and lone pairs) arrange to minimize repulsion; determines molecular geometry|count electron groups around central atom; electron geometry: linear (2), trigonal planar (3), tetrahedral (4), trigonal bipyramidal (5), octahedral (6); molecular geometry adjusted for lone pairs (occupy space but invisible)|CH₄: tetrahedral (4 bonding, 0 lone); H₂O: bent (2 bonding, 2 lone pairs); NH₃: trigonal pyramidal (3 bonding, 1 lone); CO₂: linear (2 bonding, 0 lone); lone pairs compress bond angles
BO12|Hybridization|mixing of atomic orbitals to form new hybrid orbitals for bonding; explains observed geometries|sp: 2 hybrid orbitals, linear, 180° (BeCl₂, CO₂); sp²: 3 hybrid, trigonal planar, 120° (BF₃, C=C); sp³: 4 hybrid, tetrahedral, 109.5° (CH₄, H₂O); sp³d: 5, trigonal bipyramidal; sp³d²: 6, octahedral|number of hybrid orbitals = number of electron groups; unhybridized p orbitals form π bonds (double/triple bonds); sigma (σ) bonds: head-on overlap; pi (π) bonds: side-on overlap

# states_of_matter(id|name|definition|properties|transitions)
SM1|Solid|definite shape and volume; particles in fixed positions; strong intermolecular forces; vibrational motion only|crystalline (ordered lattice: ionic, molecular, covalent network, metallic) or amorphous (disordered: glass, plastic); incompressible; rigid|melting (→ liquid); sublimation (→ gas directly); deposition (← gas)
SM2|Liquid|definite volume, no definite shape; particles close but flowing; moderate intermolecular forces|takes shape of container; incompressible; surface tension (inward pull at surface); viscosity (resistance to flow); capillary action|freezing (→ solid); evaporation/boiling (→ gas); condensation (← gas)
SM3|Gas|no definite shape or volume; particles widely separated; minimal intermolecular forces; random rapid motion|fills container; compressible; low density; diffusion; pressure from particle collisions with walls; described by gas laws|condensation (→ liquid); deposition (→ solid); ionization (→ plasma)
SM4|Plasma|ionized gas; electrons stripped from atoms; electrically conductive; responds to electromagnetic fields|fourth state; most common state of matter in universe (stars); fluorescent lights, lightning, neon signs, fusion reactors|ionization (← gas); recombination (→ gas); requires high temperature or strong electric field
SM5|Phase Diagram|graph of pressure vs temperature showing phases and boundaries; triple point (all three phases coexist); critical point (liquid-gas distinction disappears)|triple point of water: 0.01°C at 611.73 Pa; critical point of water: 374°C at 22.064 MPa; normal melting/boiling points at 1 atm|slope of solid-liquid line: positive for most substances (solid denser than liquid); water anomalous: negative slope (ice floats); supercritical fluid above critical point (properties of both liquid and gas)

# reactions(id|name|definition|general_form|examples)
RX1|Synthesis (Combination)|two or more reactants combine to form single product|A + B → AB|2H₂ + O₂ → 2H₂O; Na + Cl₂ → 2NaCl; SO₃ + H₂O → H₂SO₄; metal oxide + water → metal hydroxide
RX2|Decomposition|single compound breaks down into two or more simpler substances|AB → A + B|2H₂O → 2H₂ + O₂ (electrolysis); CaCO₃ → CaO + CO₂ (thermal); 2KClO₃ → 2KCl + 3O₂ (catalytic)
RX3|Single Replacement (Substitution)|element replaces another element in compound; active element displaces less active|A + BC → AC + B|Zn + CuSO₄ → ZnSO₄ + Cu; Fe + CuCl₂ → FeCl₂ + Cu; activity series determines which metal displaces which
RX4|Double Replacement (Metathesis)|cations and anions of two compounds exchange partners; driven by formation of precipitate, gas, or water|AB + CD → AD + CB|AgNO₃ + NaCl → AgCl↓ + NaNO₃; HCl + NaOH → NaCl + H₂O; BaCl₂ + Na₂SO₄ → BaSO₄↓ + 2NaCl
RX5|Combustion|rapid reaction with oxygen producing heat and light; complete combustion of hydrocarbons → CO₂ + H₂O|CₓHᵧ + O₂ → CO₂ + H₂O|CH₄ + 2O₂ → CO₂ + 2H₂O; C₃H₈ + 5O₂ → 3CO₂ + 4H₂O; incomplete combustion: insufficient O₂ → CO or C (soot)
RX6|Oxidation-Reduction (Redox)|transfer of electrons between species; oxidation = loss of electrons (OIL); reduction = gain of electrons (RIG); always occur together|oxidizing agent + reducing agent → reduced product + oxidized product|2Mg + O₂ → 2MgO (Mg oxidized: 0→+2; O reduced: 0→-2); Zn + Cu²⁺ → Zn²⁺ + Cu; Fe₂O₃ + 3CO → 2Fe + 3CO₂ (iron smelting)
RX7|Acid-Base (Neutralization)|acid + base → salt + water (Arrhenius); proton transfer from acid to base (Brønsted-Lowry)|HA + BOH → BA + H₂O (Arrhenius); HA + B → A⁻ + BH⁺ (Brønsted)|HCl + NaOH → NaCl + H₂O; H₂SO₄ + 2NaOH → Na₂SO₄ + 2H₂O; CH₃COOH + NH₃ → CH₃COONH₄
RX8|Precipitation|mixing solutions produces insoluble solid (precipitate); driven by low solubility product|A⁺(aq) + B⁻(aq) → AB(s)|Ag⁺ + Cl⁻ → AgCl↓; Ba²⁺ + SO₄²⁻ → BaSO₄↓; Pb²⁺ + 2I⁻ → PbI₂↓; solubility rules predict precipitate formation
RX9|Hydrolysis|reaction with water that breaks bonds; water acts as reactant; salt hydrolysis determines pH of salt solution|AB + H₂O → HA + BOH (or variants)|NaCH₃COO + H₂O ⇌ CH₃COOH + NaOH (basic solution); NH₄Cl + H₂O ⇌ NH₃·H₂O + HCl (acidic solution); esters + H₂O → acid + alcohol (with catalyst)
RX10|Polymerization|monomers link to form long-chain polymer; addition (free radical chain: ethylene → polyethylene) or condensation (loss of small molecule: nylon, polyester)|nA → [-A-]ₙ (addition); nA + nB → [-AB-]ₙ + nH₂O (condensation)|ethylene → polyethylene; styrene → polystyrene; amino acids → protein (condensation: peptide bond + H₂O); glucose → starch/cellulose

# stoichiometry(id|name|definition|method|key_relationships)
SC1|Balancing Equations|adjusting coefficients so atom count is equal on both sides; start with most complex molecule; adjust H and O last; never change subscripts|inspection method; algebraic method for complex equations; check each element; charges must also balance for ionic equations|balanced equation provides mole ratios: 2H₂ + O₂ → 2H₂O means 2 mol H₂ reacts with 1 mol O₂ to produce 2 mol H₂O
SC2|Mole Ratios|stoichiometric coefficients in balanced equation give mole ratios; bridge between different substances in reaction|from balanced equation: coefficient A / coefficient B = mole ratio; used to convert moles of one substance to moles of another|2H₂ + O₂ → 2H₂O: ratio H₂:O₂ = 2:1; ratio H₂:H₂O = 1:1; ratio O₂:H₂O = 1:2
SC3|Molar Mass|mass of one mole of substance in grams; numerically equal to atomic/molecular weight in amu; sum of atomic masses of all atoms in formula|H₂O: 2(1.008) + 16.00 = 18.016 g/mol; NaCl: 22.99 + 35.45 = 58.44 g/mol; CaCO₃: 40.08 + 12.01 + 3(16.00) = 100.09 g/mol|conversion factor between grams and moles: moles = mass / molar mass; mass = moles × molar mass
SC4|Limiting Reagent|reactant completely consumed first; determines maximum product yield; other reactant(s) in excess|convert all reactant amounts to moles; divide by respective coefficients; smallest value identifies limiting reagent; calculate product from limiting reagent moles only|if 3 mol H₂ and 2 mol O₂ for 2H₂ + O₂ → 2H₂O: H₂ limiting (3/2 = 1.5 < 2/1 = 2); maximum H₂O = 3 mol
SC5|Percent Yield|actual yield / theoretical yield × 100; measures efficiency; always ≤ 100% for real reactions|theoretical yield from stoichiometry (limiting reagent calculation); actual yield from experiment; losses from incomplete reaction, side reactions, transfer losses|80% yield means 80% of theoretical maximum was obtained; cascading reactions: overall yield = product of individual yields (3 steps at 80% each: 0.8³ = 51.2% overall)
SC6|Percent Composition|mass percentage of each element in compound; (mass of element / molar mass of compound) × 100|CO₂: C = 12.01/44.01 × 100 = 27.3%; O = 2(16.00)/44.01 × 100 = 72.7%|used to determine empirical formula from experimental mass data; analytical technique; relates to combustion analysis
SC7|Molarity (M)|moles of solute per liter of solution; M = mol/L; most common concentration unit|prepare by dissolving measured mass of solute in solvent and diluting to volume in volumetric flask; M₁V₁ = M₂V₂ for dilutions|1 M NaCl = 58.44 g NaCl dissolved and diluted to 1.000 L; dilution doesn't change moles, only concentration

# thermodynamics(id|name|definition|formula|significance)
TD1|Enthalpy (H)|heat content of system at constant pressure; ΔH = heat absorbed or released by reaction|ΔH = H_products - H_reactants; ΔH < 0: exothermic (releases heat); ΔH > 0: endothermic (absorbs heat)|measured by calorimetry; standard enthalpy of formation (ΔH°f): enthalpy change forming 1 mol compound from elements in standard states; Hess's Law: ΔH is path-independent (state function)
TD2|Entropy (S)|measure of disorder/randomness/microstates of system; S = k_B ln W; nature favors increasing entropy|ΔS = S_products - S_reactants; ΔS > 0: disorder increases (favorable); ΔS < 0: disorder decreases (unfavorable)|gases > liquids > solids (entropy); more moles of gas in products → positive ΔS; dissolution increases entropy; second law: total entropy of universe increases in spontaneous processes
TD3|Gibbs Free Energy (G)|criterion for spontaneity at constant temperature and pressure; combines enthalpy and entropy|ΔG = ΔH - TΔS; ΔG < 0: spontaneous (thermodynamically favorable); ΔG = 0: equilibrium; ΔG > 0: non-spontaneous|spontaneous ≠ fast (diamond → graphite is spontaneous but imperceptibly slow); ΔG° = -RT ln K (relates to equilibrium constant); exergonic (ΔG < 0) vs endergonic (ΔG > 0)
TD4|Hess's Law|enthalpy change of reaction is independent of pathway; if reaction is sum of steps, ΔH is sum of step ΔH values|ΔH_total = ΣΔH_steps; reverse reaction → change sign; multiply reaction → multiply ΔH; add reactions algebraically to reach target|enables calculation of ΔH for reactions difficult to measure directly; foundation for using standard enthalpies of formation: ΔH°rxn = ΣΔH°f(products) - ΣΔH°f(reactants)
TD5|Bond Energy|energy required to break one mole of bonds in gas phase; always positive (breaking bonds requires energy); approximate method for estimating ΔH|ΔH ≈ Σ(bonds broken) - Σ(bonds formed); breaking bonds = endothermic; forming bonds = exothermic|C-H: 413 kJ/mol; O=O: 498; C=O: 799; O-H: 463; N≡N: 945 (triple bond very strong → N₂ unreactive); average values (vary by molecular environment)
TD6|Specific Heat Capacity (c)|energy required to raise temperature of 1 gram of substance by 1°C (or 1 K)|q = mcΔT; q = heat (J); m = mass (g); c = specific heat (J/g·K); ΔT = temperature change|water: 4.184 J/g·K (unusually high → temperature buffer); metals: low c (iron: 0.449); used in calorimetry to measure ΔH of reactions
TD7|Calorimetry|measuring heat of reaction by observing temperature change in known mass of surroundings (calorimeter)|q_rxn = -q_cal = -mcΔT (for simple calorimeter); bomb calorimeter for combustion (constant volume)|coffee-cup calorimeter: open, constant pressure, ΔH directly; bomb calorimeter: sealed, constant volume, measures ΔU (internal energy); convert to ΔH if needed

# kinetics(id|name|definition|formula_or_mechanism|significance)
KN1|Reaction Rate|change in concentration per unit time; rate of disappearance of reactant or appearance of product|rate = -Δ[A]/Δt = Δ[B]/Δt (adjusted by stoichiometric coefficients); instantaneous rate from slope of concentration vs time curve|measured experimentally; initial rate method most common; rate changes as reaction proceeds (reactant concentration changes)
KN2|Rate Law|mathematical expression relating rate to concentrations of reactants raised to experimentally determined powers|rate = k[A]ᵐ[B]ⁿ; k = rate constant; m, n = reaction orders (determined experimentally, not from stoichiometry); overall order = m + n|must be determined experimentally (cannot be predicted from balanced equation except for elementary steps); zero-order: rate independent of [A]; first-order: rate ∝ [A]; second-order: rate ∝ [A]²
KN3|Activation Energy (Ea)|minimum energy required for reaction to occur; energy barrier between reactants and products; determines temperature sensitivity|Arrhenius equation: k = Ae^(-Ea/RT); ln k = ln A - Ea/RT; plot ln k vs 1/T → slope = -Ea/R|higher Ea = slower reaction at given temperature; catalyst lowers Ea (provides alternative pathway); Ea is always positive; determines how strongly temperature affects rate
KN4|Catalyst|substance that increases reaction rate without being consumed; lowers activation energy by providing alternative reaction pathway|homogeneous: same phase as reactants (acid catalyst in solution); heterogeneous: different phase (solid catalyst for gas reaction); enzymes: biological catalysts (highly specific)|does not change ΔH or equilibrium position; only affects rate of reaching equilibrium; provides alternative mechanism with lower Ea; catalytic converters (Pt, Pd, Rh); industrial: Haber process (Fe catalyst)
KN5|Collision Theory|for reaction to occur: molecules must collide, with sufficient energy (≥ Ea), and with proper orientation|rate ∝ collision frequency × fraction with sufficient energy × fraction with correct orientation|explains temperature effect (more energetic collisions); concentration effect (more collisions per time); steric factor (not all collisions productive); surface area effect (more contact area)
KN6|Reaction Mechanism|step-by-step sequence of elementary reactions that sum to overall reaction; each step has its own rate law derivable from stoichiometry|elementary steps sum to overall; rate-determining step (slowest) controls overall rate; intermediates produced then consumed; rate law of rate-determining step ≈ overall rate law|mechanism cannot be proven (only disproven); consistent with rate law and stoichiometry; intermediates: present in mechanism but not overall equation; transition state: peak of energy diagram, not isolatable
KN7|Half-Life (t½)|time for concentration of reactant to decrease by half; constant for first-order reactions|first-order: t½ = ln2/k = 0.693/k (independent of initial concentration); second-order: t½ = 1/(k[A]₀); zero-order: t½ = [A]₀/(2k)|first-order t½ constant → radioactive decay, drug metabolism; second-order t½ depends on concentration; number of half-lives determines remaining fraction: n half-lives → (1/2)ⁿ remaining

# equilibrium(id|name|definition|expression|significance)
EQ1|Chemical Equilibrium|state where forward and reverse reaction rates are equal; concentrations no longer change macroscopically; dynamic (reactions still occurring at molecular level)|rate_forward = rate_reverse; concentrations constant but not necessarily equal; system appears static but is microscopically active|equilibrium is dynamic (not static); reached from either direction; position described by equilibrium constant; disturbing equilibrium → system adjusts (Le Chatelier)
EQ2|Equilibrium Constant (K)|ratio of product concentrations to reactant concentrations at equilibrium, each raised to stoichiometric power|K_c = [C]^c[D]^d / [A]^a[B]^b for aA + bB ⇌ cC + dD; K_p = (P_C)^c(P_D)^d / (P_A)^a(P_B)^b for gases; K_p = K_c(RT)^Δn|K >> 1: products favored (reaction essentially complete); K << 1: reactants favored (reaction barely proceeds); K depends on temperature only (not concentration, pressure, or catalyst)
EQ3|Le Chatelier's Principle|if equilibrium system is stressed, it shifts to partially counteract the stress; restores a new equilibrium|add reactant → shift right (toward products); remove product → shift right; increase temperature: shift toward endothermic direction; increase pressure: shift toward fewer moles of gas; catalyst: no shift (reaches equilibrium faster)|predicts direction of shift only (not magnitude); adding inert gas at constant volume: no shift (partial pressures unchanged); dilution: shifts toward side with more moles of solute; industrial: Haber process optimized using Le Chatelier
EQ4|Reaction Quotient (Q)|same expression as K but using non-equilibrium concentrations; comparison to K determines direction system will shift|Q = [C]^c[D]^d / [A]^a[B]^b (at any point, not just equilibrium)|Q < K: reaction proceeds forward (toward products) to reach equilibrium; Q > K: reaction proceeds reverse (toward reactants); Q = K: system at equilibrium
EQ5|Solubility Product (Ksp)|equilibrium constant for dissolution of sparingly soluble ionic solid; K_sp = [cation]^m[anion]^n|AgCl(s) ⇌ Ag⁺(aq) + Cl⁻(aq); K_sp = [Ag⁺][Cl⁻] = 1.8 × 10⁻¹⁰ at 25°C|low Ksp = low solubility; Q > Ksp → precipitate forms; Q < Ksp → more dissolves; common ion effect: adding common ion decreases solubility (Le Chatelier); molar solubility calculated from Ksp

# acids_bases(id|name|definition|formula_or_scale|significance)
AB1|Arrhenius Acid/Base|acid: produces H⁺ in water; base: produces OH⁻ in water|HCl → H⁺ + Cl⁻ (acid); NaOH → Na⁺ + OH⁻ (base)|limited to aqueous solutions; historically first definition; neutralization: H⁺ + OH⁻ → H₂O
AB2|Brønsted-Lowry Acid/Base|acid: proton (H⁺) donor; base: proton acceptor; broader than Arrhenius (not limited to water)|HA + B ⇌ A⁻ + BH⁺; conjugate acid-base pairs: HA/A⁻ and BH⁺/B|every acid has conjugate base (after losing H⁺); every base has conjugate acid (after gaining H⁺); amphoteric: can act as acid or base (water: H₂O + H₂O ⇌ H₃O⁺ + OH⁻)
AB3|Lewis Acid/Base|acid: electron pair acceptor; base: electron pair donor; broadest definition|Lewis acid accepts electron pair into empty orbital; Lewis base donates lone pair|includes all Brønsted acids/bases plus: BF₃ (accepts pair, no H⁺ involved); metal cations as Lewis acids; coordination chemistry; explains acid behavior of metal ions in solution
AB4|pH Scale|measure of H⁺ (H₃O⁺) concentration; pH = -log[H⁺]; scale typically 0-14 in water|pH 0-7: acidic (higher [H⁺]); pH 7: neutral (pure water at 25°C); pH 7-14: basic (lower [H⁺]); each pH unit = 10× concentration change|pOH = -log[OH⁻]; pH + pOH = 14 (at 25°C); Kw = [H⁺][OH⁻] = 1.0 × 10⁻¹⁴ at 25°C; strong acids: pH ≈ -log(C_acid); weak acids: Henderson-Hasselbalch equation: pH = pKa + log([A⁻]/[HA])
AB5|Strong vs Weak Acid/Base|strong: completely dissociates in water (100%); weak: partially dissociates (equilibrium between dissociated and undissociated)|strong acids: HCl, HBr, HI, HNO₃, H₂SO₄ (first H), HClO₄; strong bases: Group 1 and 2 hydroxides (NaOH, KOH, Ca(OH)₂); all others are weak|Ka (acid dissociation constant) quantifies weak acid strength: larger Ka = stronger weak acid; acetic acid Ka = 1.8 × 10⁻⁵; Kb for weak bases; Ka × Kb = Kw for conjugate pairs
AB6|Buffer|solution resisting pH change upon addition of small amounts of acid or base; contains weak acid + its conjugate base (or weak base + conjugate acid)|Henderson-Hasselbalch: pH = pKa + log([A⁻]/[HA]); effective buffer range: pKa ± 1; buffer capacity proportional to total concentration of acid + conjugate base|blood buffer: H₂CO₃/HCO₃⁻ (pH 7.35-7.45); acetate buffer: CH₃COOH/CH₃COO⁻; phosphate buffer: H₂PO₄⁻/HPO₄²⁻; choose buffer acid with pKa near desired pH; add acid → consumes A⁻ → pH drops slightly; add base → consumes HA → pH rises slightly
AB7|Titration|quantitative analysis: adding solution of known concentration (titrant) to solution of unknown until reaction complete (equivalence point)|equivalence point: moles of acid = moles of base (adjusted for stoichiometry); indicator changes color near equivalence point; pH curve shape depends on strong/weak combination|strong acid + strong base: equivalence at pH 7; strong acid + weak base: equivalence at pH < 7; weak acid + strong base: equivalence at pH > 7; half-equivalence point of weak acid: pH = pKa (buffer region); polyprotic acids have multiple equivalence points

# electrochemistry(id|name|definition|formula_or_principle|applications)
EC1|Oxidation|loss of electrons; increase in oxidation state; occurs at anode|Zn → Zn²⁺ + 2e⁻; Fe²⁺ → Fe³⁺ + e⁻; oxidation state increases|OIL: Oxidation Is Loss; anode = oxidation; oxidizing agent is reduced (accepts electrons); corrosion is oxidation of metals
EC2|Reduction|gain of electrons; decrease in oxidation state; occurs at cathode|Cu²⁺ + 2e⁻ → Cu; O₂ + 4e⁻ + 4H⁺ → 2H₂O; oxidation state decreases|RIG: Reduction Is Gain; cathode = reduction; reducing agent is oxidized (donates electrons); electroplating deposits metal at cathode
EC3|Electrochemical Cell|device converting between chemical and electrical energy; two half-cells connected by wire (electron flow) and salt bridge (ion flow)|galvanic/voltaic: spontaneous reaction generates electricity (ΔG < 0, E° > 0); electrolytic: external electricity drives non-spontaneous reaction (ΔG > 0, E° < 0)|galvanic: batteries, fuel cells; electrolytic: electroplating, electrorefining, electrolysis of water, aluminum smelting (Hall-Héroult); E°cell = E°cathode - E°anode
EC4|Standard Electrode Potential (E°)|potential of half-reaction measured against standard hydrogen electrode (SHE = 0.00 V); positive = spontaneous reduction; negative = spontaneous oxidation|standard reduction potentials: F₂/F⁻ = +2.87 V (strongest oxidizing agent); Li⁺/Li = -3.04 V (strongest reducing agent); more positive = easier to reduce; more negative = easier to oxidize|activity series from E° values; E°cell = E°cathode - E°anode; positive E°cell → spontaneous galvanic cell; ΔG° = -nFE° (n = moles e⁻, F = 96,485 C/mol)
EC5|Nernst Equation|relates cell potential to non-standard conditions (non-unity concentrations/pressures)|E = E° - (RT/nF) ln Q = E° - (0.0592/n) log Q at 25°C|at equilibrium: E = 0, Q = K; concentration cells: same electrodes, different concentrations; pH electrodes use Nernst equation; batteries under load: E < E° because Q ≠ 1
EC6|Electrolysis|using external electrical energy to drive non-spontaneous chemical reaction; decomposition by electricity|Faraday's laws: moles deposited = It/(nF); I = current (A), t = time (s), n = electrons per ion, F = 96,485 C/mol|water electrolysis: 2H₂O → 2H₂ + O₂ (minimum 1.23 V); aluminum: Al₂O₃ → 2Al + 3/2 O₂ (in cryolite); electroplating: metal ion reduced onto cathode surface; chlor-alkali process: NaCl → NaOH + Cl₂ + H₂
EC7|Corrosion|electrochemical degradation of metals; iron rusting is most common|Fe → Fe²⁺ + 2e⁻ (anodic area); O₂ + 2H₂O + 4e⁻ → 4OH⁻ (cathodic area); Fe²⁺ + 2OH⁻ → Fe(OH)₂ → further oxidation to Fe₂O₃·nH₂O (rust)|prevention: galvanizing (zinc coating: zinc corrodes preferentially = sacrificial anode); painting (barrier); cathodic protection (more active metal connected); alloying (stainless steel: Cr forms protective oxide layer); electrochemical principles govern all corrosion

# organic(id|name|definition|formula_pattern|key_properties)
OR1|Alkane|saturated hydrocarbon; all single bonds; CₙH₂ₙ₊₂; sp³ hybridized carbons|CH₄ (methane), C₂H₆ (ethane), C₃H₈ (propane), C₈H₁₈ (octane)|least reactive hydrocarbons; undergo combustion and halogenation (with UV); boiling point increases with chain length; branching lowers boiling point (less surface contact → weaker LDF); naming: -ane suffix
OR2|Alkene|unsaturated hydrocarbon with C=C double bond; CₙH₂ₙ; sp² carbons at double bond|C₂H₄ (ethylene), C₃H₆ (propylene); cis-trans isomerism when substituents differ on each carbon of double bond|more reactive than alkanes (π bond electron-rich → electrophilic addition); addition of H₂ (hydrogenation), HX (Markovnikov), X₂ (halogenation), H₂O (hydration); no free rotation around C=C → geometric isomers; naming: -ene suffix
OR3|Alkyne|unsaturated hydrocarbon with C≡C triple bond; CₙH₂ₙ₋₂; sp carbons at triple bond|C₂H₂ (acetylene), C₃H₄ (propyne)|linear at triple bond (180°); more reactive than alkenes; undergoes addition reactions (can add twice: alkyne → alkene → alkane); terminal alkynes weakly acidic (sp C-H); naming: -yne suffix
OR4|Alcohol|contains -OH (hydroxyl) group bonded to sp³ carbon; R-OH|CH₃OH (methanol), C₂H₅OH (ethanol), C₃H₇OH (propanol); primary (1°), secondary (2°), tertiary (3°) based on carbon substitution|hydrogen bonding (higher BP than comparable alkane); polar; water-soluble (short chain); naming: -ol suffix; reactions: dehydration (→ alkene), oxidation (1° → aldehyde → acid; 2° → ketone; 3° → no oxidation); ethanol: beverages, solvent, fuel
OR5|Carboxylic Acid|contains -COOH (carboxyl) group; R-COOH|HCOOH (formic), CH₃COOH (acetic), C₆H₅COOH (benzoic); fatty acids: long-chain carboxylic acids|weak acids (partial dissociation in water); hydrogen bonding (dimers); naming: -oic acid suffix; reactions: neutralization (→ salt), esterification (with alcohol → ester + H₂O); vinegar = 5% acetic acid; citric acid in citrus
OR6|Ester|formed from carboxylic acid + alcohol with loss of water; R-COO-R'; hydrolyzed by acid or base (saponification)|CH₃COOC₂H₅ (ethyl acetate); fats/oils = glycerol triesters of fatty acids (triglycerides)|often pleasant fruity odors (flavors and fragrances); fats are esters; polyesters (PET: polyethylene terephthalate); saponification of fats → soap + glycerol; biodiesel from transesterification of vegetable oils
OR7|Amine|contains nitrogen bonded to 1-3 carbons + hydrogens; R-NH₂ (primary), R₂NH (secondary), R₃N (tertiary)|CH₃NH₂ (methylamine); (CH₃)₃N (trimethylamine); amino acids contain both amine and carboxylic acid groups|basic (lone pair on N accepts proton); hydrogen bonding (1° and 2° amines); often fishy or unpleasant smell; naming: -amine suffix; biologically crucial: amino acids, neurotransmitters, DNA bases, alkaloids
OR8|Aldehyde and Ketone|carbonyl group (C=O); aldehyde: terminal (R-CHO); ketone: internal (R-CO-R')|HCHO (formaldehyde), CH₃CHO (acetaldehyde); CH₃COCH₃ (acetone), cyclohexanone|polar (C=O dipole); hydrogen bond acceptors but not donors; aldehydes easily oxidized (→ carboxylic acid); ketones resist oxidation; nucleophilic addition reactions; naming: aldehyde -al, ketone -one
OR9|Aromatic (Benzene Ring)|cyclic conjugated system with 4n+2 π electrons (Hückel's rule); benzene C₆H₆ is prototype; delocalized π electron cloud|benzene (6 C, planar, hexagonal, all bonds equal 1.5 bond order); toluene (methylbenzene); phenol (hydroxybenzene); aniline (aminobenzene)|unusually stable (resonance energy ~150 kJ/mol); undergoes electrophilic aromatic substitution (not addition — preserves aromaticity); substituent effects: electron-donating (ortho/para directors), electron-withdrawing (meta directors); polycyclic: naphthalene, anthracene
OR10|Polymer|large molecule made of repeating monomer units; molecular weight 10,000-10,000,000+|addition: polyethylene [-CH₂CH₂-]ₙ; condensation: nylon-6,6 (diamine + dicarboxylic acid - H₂O); natural: protein, DNA, cellulose, rubber|thermoplastic (soften when heated: PE, PP, PET, nylon); thermoset (cross-linked, don't soften: epoxy, vulcanized rubber, Bakelite); elastomer (rubber-like, reversible stretching); crystalline vs amorphous regions affect properties
OR11|Isomer|molecules with same molecular formula but different structural arrangement; different properties|structural (different connectivity); geometric/cis-trans (different spatial arrangement around rigid bond); optical/enantiomers (mirror images, chiral centers); conformational (different rotations)|structural isomers: butane vs isobutane (C₄H₁₀); cis/trans: cis-2-butene vs trans-2-butene; enantiomers: D-glucose vs L-glucose (biological systems often use only one); chirality: central carbon with 4 different substituents
OR12|Functional Group|specific atom or group of atoms within molecule determining chemical reactivity and properties; same functional group → similar reactions regardless of rest of molecule|-OH (alcohol); -COOH (carboxylic acid); -NH₂ (amine); C=C (alkene); C=O (carbonyl); -CHO (aldehyde); C-O-C (ether); -COO- (ester); C-X (halide)|chemistry organized by functional group; predict reactivity from functional group identification; multiple functional groups in same molecule (amino acid has both -NH₂ and -COOH); naming prioritizes functional groups

# solutions(id|name|definition|properties|key_relationships)
SL1|Solution|homogeneous mixture of two or more substances; solute dissolved in solvent; molecular-level mixing|transparent; does not settle; cannot be filtered; uniform properties throughout; liquid solutions most common but gas and solid solutions exist (alloys)|like dissolves like: polar solvents dissolve polar/ionic solutes; nonpolar solvents dissolve nonpolar solutes; entropy drives dissolution; enthalpy may favor or oppose
SL2|Solubility|maximum amount of solute that dissolves in given amount of solvent at specific temperature|saturated: maximum dissolved (equilibrium); unsaturated: below maximum; supersaturated: above maximum (metastable, crystallizes upon disturbance)|gas solubility decreases with temperature (hot soda goes flat); solid solubility usually increases with temperature (most salts); Henry's law for gas solubility: S = kH × P (pressure dependence)
SL3|Colligative Properties|solution properties depending on number of solute particles, not identity; boiling point elevation, freezing point depression, osmotic pressure, vapor pressure lowering|ΔTb = iKbm; ΔTf = iKfm; π = iMRT; i = van't Hoff factor (number of particles per formula unit: NaCl i≈2, glucose i=1)|antifreeze (ethylene glycol lowers freezing point); road salt (depresses freezing point of water); osmotic pressure drives reverse osmosis (water purification); boiling point elevation small but measurable; i accounts for dissociation
SL4|Dilution|adding solvent to decrease concentration; moles of solute unchanged|M₁V₁ = M₂V₂; C₁V₁ = C₂V₂ (for any concentration unit × volume); always add solute/concentrate to solvent (not reverse, especially for acids → water)|serial dilution: repeated fixed-ratio dilutions for very low concentrations; stock solutions prepared concentrated and diluted to working concentration; dilution does not change total moles
SL5|Precipitation and Solubility Rules|predicting whether mixing solutions produces insoluble precipitate; solubility rules guide prediction|generally soluble: Na⁺, K⁺, NH₄⁺ (all salts); NO₃⁻ (all nitrates); Cl⁻ (except Ag⁺, Pb²⁺, Hg₂²⁺); generally insoluble: CO₃²⁻, PO₄³⁻, S²⁻ (except with Group 1/NH₄⁺); OH⁻ (except Group 1, Ca²⁺, Ba²⁺, Sr²⁺)|net ionic equation removes spectator ions; only shows species that change; AgNO₃ + NaCl → AgCl↓ + NaNO₃; net ionic: Ag⁺ + Cl⁻ → AgCl↓

# nuclear(id|name|definition|properties|applications)
NU1|Radioactive Decay|unstable nucleus emits radiation to become more stable; spontaneous nuclear transformation|alpha (⁴He nucleus, +2 charge, stopped by paper); beta (electron or positron, stopped by aluminum); gamma (high-energy photon, stopped by lead/concrete)|natural decay series: U-238 → ... → Pb-206 (14 steps); detection: Geiger counter, scintillation; medical imaging; geological dating; smoke detectors (Am-241 alpha source)
NU2|Half-Life (Nuclear)|time for half of radioactive atoms to decay; characteristic of each isotope; unaffected by temperature, pressure, or chemistry|N = N₀(1/2)^(t/t½); C-14: 5,730 years; I-131: 8 days; U-238: 4.5 × 10⁹ years; Po-214: 164 microseconds|radiocarbon dating (C-14); medical: short half-life isotopes minimize patient exposure; nuclear waste: long half-lives = long storage requirements; after 10 half-lives: < 0.1% remains
NU3|Fission|heavy nucleus splits into two lighter nuclei + neutrons + enormous energy; neutrons can trigger chain reaction|²³⁵U + n → ¹⁴¹Ba + ⁹²Kr + 3n + 200 MeV; chain reaction: each fission produces 2-3 neutrons that can trigger more fissions|nuclear power (controlled chain reaction; moderator slows neutrons; control rods absorb neutrons); nuclear weapons (uncontrolled chain reaction); critical mass: minimum mass for sustained chain reaction
NU4|Fusion|light nuclei combine to form heavier nucleus + enormous energy; powers stars; requires extreme temperature to overcome electrostatic repulsion|²H + ³H → ⁴He + n + 17.6 MeV; solar fusion: 4 ¹H → ⁴He + 2e⁺ + 2ν + 26.7 MeV|greatest energy per mass of any reaction; solar energy source; hydrogen bomb; controlled fusion: plasma confinement at >100 million °C; ITER (experimental); not yet commercially viable; fuel (deuterium) abundant in seawater
NU5|Nuclear Binding Energy|energy required to disassemble nucleus into individual protons and neutrons; mass defect × c²|E = Δmc²; mass defect Δm = (mass of protons + neutrons) - (mass of nucleus); binding energy per nucleon peaks at Fe-56 (most stable nucleus)|explains why fission of heavy nuclei AND fusion of light nuclei both release energy — both move toward Fe-56 (maximum binding energy per nucleon); curve of binding energy per nucleon explains nuclear energetics

# laboratory(id|name|definition|procedure|safety)
LB1|Filtration|separating solid from liquid using filter medium (paper, glass frit, membrane); gravity or vacuum (faster)|gravity: filter paper in funnel, liquid passes through, solid retained; vacuum: Büchner funnel + flask + vacuum pump; faster, drier product|ensure filter medium appropriate mesh size; don't let filtrate overflow funnel; wash precipitate on filter with solvent to remove impurities
LB2|Distillation|separating liquids by boiling point difference; liquid boiled, vapor condensed and collected|simple: single boil-condense cycle (>25°C boiling point difference); fractional: column packing provides multiple theoretical plates (closer boiling points); vacuum distillation: for heat-sensitive or high-BP compounds|thermometer at distillation head; collect fractions at different temperature ranges; boiling chips prevent bumping; never heat sealed system (explosion risk); never distill to dryness (residue may be unstable)
LB3|Titration (Lab)|quantitative analysis using calibrated buret to add titrant to analyte until equivalence point|indicator method: add indicator matching equivalence pH; potentiometric: use pH meter; read buret volume at endpoint; calculate unknown concentration from volume and molarity|rinse buret with titrant before filling; read meniscus at eye level; approach endpoint slowly (half-drops); record volume to 0.01 mL; practice produces precision
LB4|Chromatography|separating mixture components based on differential distribution between stationary and mobile phases|paper/TLC: mobile phase moves through stationary (silica, paper); column: gravity or pressure drives mobile through packed column; GC: gas mobile, liquid stationary on column; HPLC: liquid mobile, packed column, high pressure|Rf value (TLC/paper) = distance of spot / distance of solvent front; retention time (GC/HPLC); polar stationary phase retains polar compounds (elute with more polar solvent); "like dissolves like" governs partitioning
LB5|Spectroscopy|analyzing interaction of electromagnetic radiation with matter to identify or quantify substances|UV-Vis: electronic transitions; IR: molecular vibrations (functional group identification); NMR: nuclear spin states (structure); mass spectrometry: fragmentation pattern + molecular weight|Beer's Law (UV-Vis): A = εbc (absorbance = molar absorptivity × path length × concentration); IR fingerprint region (below 1500 cm⁻¹) unique to each compound; ¹H NMR: chemical shift (δ, ppm) indicates electronic environment; coupling patterns reveal connectivity
LB6|Gravimetric Analysis|quantitative determination by mass; precipitate target ion, filter, dry, weigh|dissolve sample; add precipitating agent (excess); filter precipitate; wash; dry/ignite to constant mass; calculate mass of analyte from precipitate mass and stoichiometry|must ensure complete precipitation; wash precipitate to remove co-precipitated impurities; drying to constant mass ensures all water removed; crucible must be pre-weighed; accurate but slow
LB7|Acid-Base Indicator|weak acid or base that changes color at specific pH range; different dissociated and undissociated forms have different colors|phenolphthalein: colorless pH < 8.2, pink pH > 10; methyl orange: red pH < 3.1, yellow pH > 4.4; litmus: red acid, blue base; universal indicator: rainbow scale|choose indicator with color change near equivalence point pH; strong acid + strong base: use any indicator near pH 7; weak acid + strong base: use phenolphthalein (changes at pH 8-10, near equivalence)

# failure_modes(id|topic|mode|cause|consequence|prevention)
FM1|stoichiometry|unbalanced equation|failure to verify atom and charge counts on both sides|incorrect mole ratios; wrong yield predictions; incorrect reagent quantities calculated|systematic balancing; check each element; verify charges; use algebraic method for complex equations; always verify
FM2|technique|contamination|dirty glassware; impure reagents; improper technique (touching inside of vessels)|inaccurate results; unexpected reactions; failed synthesis; safety hazard|clean all glassware before use; use appropriate grade reagents; proper technique (never touch inside of flask; clean spatulas between reagents)
FM3|measurement|incorrect concentration|wrong mass weighed; wrong volume measured; calculation error; temperature not accounted for|every subsequent calculation wrong; quantitative analysis fails; reactions may not proceed as expected|calibrate balances; use volumetric glassware for precision (not beakers); double-check calculations; record all measurements immediately; use significant figures correctly
FM4|equilibrium|assuming K changes with concentration|adding reactant and expecting K to change (it doesn't — concentrations adjust to maintain K)|incorrect predictions of product yield; misunderstanding of Le Chatelier|K depends only on temperature; concentration changes shift position to maintain K; adding reactant shifts equilibrium but K remains constant; only temperature changes K
FM5|acid-base|using wrong indicator|indicator changes color at pH far from equivalence point|missed or incorrect endpoint; inaccurate concentration determination|match indicator pKa to expected equivalence pH; use pH meter for highest accuracy; know strong/strong (pH 7), weak/strong (pH > 7), strong/weak (pH < 7) equivalence points
FM6|organic|confusing molecular and empirical formula|treating CH₂O (empirical) as if it were the actual molecule when molecular formula is C₆H₁₂O₆|wrong molar mass; wrong stoichiometry; wrong structure prediction|empirical gives ratio only; determine molecular formula from empirical + molar mass; molecular formula = (empirical formula) × n where n = molar mass / empirical mass
FM7|safety|mixing incompatible chemicals|acids + bases without preparation; oxidizers + reducers without control; water into concentrated acid (violent exothermic)|explosion; fire; toxic gas release; chemical burns; property damage|consult SDS (Safety Data Sheet) before handling; add acid to water (never reverse: "do as you oughta, add acid to water"); know incompatibilities; fume hood for toxic/volatile reagents; proper PPE
FM8|gas_laws|ignoring non-ideal behavior|applying ideal gas law (PV=nRT) at high pressure or low temperature where intermolecular forces matter|incorrect pressure, volume, or temperature predictions; real gas deviates significantly from ideal prediction|use van der Waals equation at high P or low T: (P + an²/V²)(V - nb) = nRT; gases most ideal at high T and low P; small nonpolar molecules are most ideal (He, N₂); large polar molecules deviate most
FM9|kinetics|confusing thermodynamics and kinetics|assuming spontaneous reaction (ΔG < 0) is fast; or that fast reaction is thermodynamically favorable|spontaneous reactions may be imperceptibly slow (diamond → graphite); fast reactions may be endothermic (dissolving NH₄NO₃)|thermodynamics (ΔG) tells whether reaction can occur; kinetics (Ea, rate law) tells how fast; catalyst affects kinetics not thermodynamics; diamond is thermodynamically unstable but kinetically inert

# distinctions(id|side_a|side_b|key_asymmetry)
DI1|Element|Compound|element: single type of atom; cannot be decomposed chemically; 118 known; listed on periodic table; compound: two or more elements chemically bonded in fixed ratio; can be decomposed; infinite possible compounds; properties differ from constituent elements
DI2|Ionic Bond|Covalent Bond|ionic: electron transfer → ions → electrostatic attraction; high MP, soluble in polar solvents, conducts when dissolved; covalent: electron sharing; lower MP; molecular compounds; doesn't conduct; polar covalent is intermediate; EN difference is approximate guide (not sharp boundary)
DI3|Exothermic|Endothermic|exothermic: releases heat to surroundings; ΔH < 0; products lower energy than reactants; feels warm; endothermic: absorbs heat from surroundings; ΔH > 0; products higher energy; feels cold; exothermic is not necessarily spontaneous (ΔG depends on ΔS too)
DI4|Acid|Base|Brønsted: acid donates H⁺; base accepts H⁺; conjugate pairs linked by H⁺; Lewis: acid accepts electron pair; base donates electron pair; broader; pH < 7 acidic; pH > 7 basic; neutralization produces salt + water
DI5|Oxidation|Reduction|oxidation: loss of electrons, increase in oxidation state; OIL; occurs at anode; reduction: gain of electrons, decrease in oxidation state; RIG; occurs at cathode; always occur together (one substance oxidized, another reduced); electron transfer is the connection
DI6|Kinetics|Thermodynamics|kinetics: how fast reaction proceeds; rate law, activation energy, mechanism; influenced by temperature, concentration, catalyst; thermodynamics: whether reaction proceeds; ΔG, ΔH, ΔS, K; independent of pathway; spontaneous ≠ fast; catalysts affect kinetics but not thermodynamics
DI7|Strong Electrolyte|Weak Electrolyte|strong: completely dissociates in water (100% ions); strong acids, bases, soluble salts; excellent conductors; written with → (not ⇌); weak: partially dissociates (equilibrium between molecules and ions); weak acids and bases; poor conductors; written with ⇌
DI8|Empirical Formula|Molecular Formula|empirical: simplest whole-number ratio of atoms; determined from percent composition; CH₂O; molecular: actual number of atoms in molecule; integer multiple of empirical; C₆H₁₂O₆ (glucose); ionic compounds: empirical formula only (no discrete molecules)
DI9|Saturated|Unsaturated (Organic)|saturated: all single bonds (C-C, C-H); maximum hydrogen atoms; alkanes; less reactive; unsaturated: contains double (C=C) or triple (C≡C) bonds; fewer than maximum H; alkenes, alkynes; more reactive (π bonds are electron-rich targets for electrophiles)
DI10|Organic|Inorganic|organic: compounds containing carbon bonded to hydrogen (and often O, N, S, P); associated with life; enormous variety (~10 million known); inorganic: all other compounds; metals, minerals, salts; exceptions: CO₂, carbonates, cyanides, carbides classified as inorganic despite containing carbon; boundary is historical convention not sharp chemical distinction
DI11|Homogeneous|Heterogeneous|homogeneous: uniform composition throughout; solutions; single phase; cannot see components; heterogeneous: non-uniform; multiple phases; components visible (often); suspensions, colloids, immiscible mixtures; can often be separated by physical means (filtration, decanting)
DI12|Physical Change|Chemical Change|physical: change in form but not identity (melting, dissolving, cutting); reversible by physical means; no new substance formed; chemical: change producing new substance(s) with different properties; bonds broken and formed; evidence: gas evolution, color change, precipitate, energy change; not easily reversed

# relationships(from|rel|to)
# Atomic structure → bonding
AT1|defines|CO2
AT3|determines|AT4,BO1,BO2
AT4|determines|AT6,CO12
AT6|determines|BO1,BO2,BO10,PT1,PT2,PT3,PT4
AT7|variants_of|CO2
AT8|constrains|AT4,AT5

# Periodic trends
PT1|inversely_correlates|PT2
PT2|correlates|PT4
PT4|determines|BO4
PT5|inversely_correlates|PT2,PT4

# Bonding → properties
BO1|produces|CO5
BO1|requires|PT4
BO2|creates|CO4
BO3|characteristic_of|PT5
BO4|creates|BO8
BO6|strongest_of|BO6,BO7,BO8
BO6|explains|SM2
BO7|present_in|CO4
BO9|drives|SL1
BO10|predicts|BO11
BO11|determines|BO12
BO12|explains|BO11

# States of matter
SM1|transitions_to|SM2,SM3
SM2|transitions_to|SM1,SM3
SM3|transitions_to|SM1,SM2
SM5|maps|SM1,SM2,SM3

# Reactions → types
RX1|contrasts|RX2
RX3|specializes|RX6
RX4|specializes|RX8
RX5|specializes|RX6
RX6|requires|CO13,EC1,EC2
RX7|specializes|RX4
RX9|requires|SM2
RX10|produces|OR10

# Stoichiometry
SC1|enables|SC2
SC2|connects|CO6,CO8
SC3|converts|CO6
SC4|limits|SC5
SC5|measures|SC4
CO9|governs|SC1

# Thermodynamics chain
TD1|component_of|TD3
TD2|component_of|TD3
TD3|determines|EQ2
TD4|enables|TD1
TD5|approximates|TD1
TD6|measures|TD1
TD7|measures|TD1

# Kinetics
KN1|quantified_by|KN2
KN2|contains|KN3
KN3|lowered_by|KN4
KN4|enables|KN1
KN5|explains|KN1
KN6|produces|KN2
KN7|derived_from|KN2

# Equilibrium
EQ1|quantified_by|EQ2
EQ3|predicts|EQ1
EQ4|compares_to|EQ2
EQ5|specializes|EQ2
TD3|relates_to|EQ2

# Acid-base
AB1|specializes|AB2
AB2|specializes|AB3
AB4|quantifies|AB2
AB5|categorizes|AB2
AB6|resists|AB4
AB7|measures|AB5

# Electrochemistry
EC1|pairs_with|EC2
EC3|uses|EC1,EC2
EC4|quantifies|EC1,EC2
EC5|extends|EC4
EC6|requires|EC3
EC7|instance_of|EC1

# Organic
OR1|simplest|OR12
OR2|extends|OR1
OR3|extends|OR2
OR4|contains|OR12
OR5|contains|OR12
OR6|formed_from|OR4,OR5
OR7|contains|OR12
OR8|contains|OR12
OR9|stabilized_by|BO2
OR10|formed_from|RX10
OR11|rearranges|CO4
OR12|determines|OR1,OR2,OR3,OR4,OR5,OR6,OR7,OR8,OR9

# Solutions
SL1|governed_by|BO9,BO6,BO7,BO8
SL2|constrained_by|TD3
SL3|depends_on|CO14
SL4|changes|CO14
SL5|predicts|RX8

# Nuclear
NU1|involves|AT1,AT2
NU2|characterizes|NU1
NU3|type_of|NU1
NU4|contrasts|NU3
NU5|explains|NU3,NU4

# Laboratory → concept
LB1|separates|SL1
LB2|separates|SL1
LB3|measures|AB7,CO14
LB4|separates|SL1
LB5|identifies|CO4,OR12
LB6|measures|CO14
LB7|indicates|AB4

# Failure → concept
FM1|errors_in|SC1
FM3|errors_in|CO14,SC3
FM4|misunderstands|EQ2
FM5|misapplies|LB7
FM6|confuses|CO15,CO16
FM7|violates|CO10
FM8|oversimplifies|SM3
FM9|confuses|KN1,TD3

# Distinction mappings
DI1|distinguishes|CO2,CO3
DI2|distinguishes|BO1,BO2
DI3|distinguishes|TD1
DI4|distinguishes|AB2
DI5|distinguishes|EC1,EC2
DI6|distinguishes|KN1,TD3
DI7|distinguishes|AB5
DI8|distinguishes|CO15,CO16
DI9|distinguishes|OR1,OR2
DI10|distinguishes|OR1
DI11|distinguishes|SL1
DI12|distinguishes|CO7

# decode_legend
# id_prefixes: CO=concept, AT=atomic_structure, PT=periodic_trend, BO=bonding, SM=state_of_matter, RX=reaction, SC=stoichiometry, TD=thermodynamics, KN=kinetics, EQ=equilibrium, AB=acid_base, EC=electrochemistry, OR=organic, SL=solution, NU=nuclear, LB=laboratory, FM=failure_mode, DI=distinction
# rel_types: defines|determines|variants_of|constrains|inversely_correlates|correlates|produces|requires|creates|characteristic_of|strongest_of|explains|present_in|drives|predicts|maps|transitions_to|contrasts|specializes|enables|connects|converts|limits|measures|governs|component_of|approximates|quantified_by|contains|lowered_by|compares_to|relates_to|categorizes|resists|pairs_with|uses|quantifies|extends|instance_of|formed_from|stabilized_by|rearranges|governed_by|constrained_by|depends_on|changes|involves|characterizes|type_of|separates|identifies|indicates|errors_in|misunderstands|misapplies|confuses|violates|oversimplifies|distinguishes
# units: energy: kJ/mol or eV; temperature: K or °C; pressure: atm, kPa, Pa; concentration: mol/L (M); mass: g, kg, amu; length: pm, Å, nm, m
# constants: R = 8.314 J/(mol·K); F = 96,485 C/mol; NA = 6.022 × 10²³; c = 3.00 × 10⁸ m/s; h = 6.626 × 10⁻³⁴ J·s; kB = 1.381 × 10⁻²³ J/K
# confidence: synthetic domain knowledge — not extracted from a single source document

# relation_mapping(doc_rel|canonical_rel|notes)
defines|produces|X defines Y = X produces Y's identity
determines|determined_by|inverse; X determines Y = Y determined_by X
variants_of|specializes|X is variant of Y = X specializes Y
constrains|constrains|exact match
inversely_correlates|opposes|X inversely correlates with Y = X opposes Y's direction
correlates|connects_to|X correlates with Y = X connects to Y statistically
produces|produces|exact match
requires|requires|exact match
creates|produces|X creates Y = X produces Y
characteristic_of|indicates|X characteristic of Y = X indicates Y
strongest_of|generalizes|X strongest of group = X generalizes as superlative
explains|explains|exact match
present_in|part_of|X present in Y = X is part of Y
drives|causes|X drives Y = X causes Y
predicts|indicates|X predicts Y = X indicates Y
maps|models|X maps Y = X models Y's relationships
transitions_to|transforms_to|exact semantic match
contrasts|contrasts|exact match; symmetric
specializes|specializes|exact match
enables|enables|exact match
connects|connects_to|exact match; symmetric
converts|transforms_to|X converts Y = Y transforms to new form
limits|constrains|X limits Y = X constrains Y
measures|measured_by|inverse; X measures Y = Y measured by X
governs|governs|exact match
component_of|part_of|X component of Y = X is part of Y
approximates|approximates|exact match; symmetric
quantified_by|measured_by|X quantified by Y = X measured by Y
contains|contains|exact match
lowered_by|mitigated_by|X lowered by Y = X mitigated by Y
compares_to|equivalent_to|X compares to Y = X equivalent to Y for comparison
relates_to|connects_to|X relates to Y = X connects to Y
categorizes|organizes|X categorizes Y = X organizes Y
resists|prevents|X resists Y = X prevents Y's change
pairs_with|complements|X pairs with Y = X complements Y; symmetric
uses|requires|X uses Y = X requires Y
quantifies|measured_by|inverse; X quantifies Y = Y measured by X
extends|extends|exact match
instance_of|instance_of|exact match
formed_from|composed_of|X formed from Y = X composed of Y
stabilized_by|maintained|inverse; X stabilized by Y = Y maintains X
rearranges|transforms_to|X rearranges Y = Y transforms to new arrangement
governed_by|determined_by|X governed by Y = X determined by Y
constrained_by|constrains|inverse; X constrained by Y = Y constrains X
depends_on|depends_on|exact match
changes|transforms_to|X changes Y = Y transforms to new state
involves|contains|X involves Y = X contains Y as participant
characterizes|indicates|X characterizes Y = X indicates Y's nature
type_of|specializes|X is type of Y = X specializes Y
separates|decomposes_to|X separates Y = Y decomposes to parts
identifies|indicates|X identifies Y = X indicates Y's identity
indicates|indicates|exact match
errors_in|anti_pattern_of|X errors in Y = X is anti-pattern of Y
misunderstands|anti_pattern_of|X misunderstands Y = X is anti-pattern of Y
misapplies|anti_pattern_of|X misapplies Y = X is anti-pattern of Y
confuses|anti_pattern_of|X confuses Y = X is anti-pattern of Y
violates|prevents|X violates Y = X prevents Y from holding
oversimplifies|anti_pattern_of|X oversimplifies Y = X is anti-pattern of Y
distinguishes|distinguishes|exact match

