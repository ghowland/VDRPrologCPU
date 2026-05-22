# LOCOMOTION, DIRECTION, TRANSITION & STATE — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: concepts → spatial_motion → temporal_position → direction → state → transition → causality → reference_frames → path → velocity → oscillation → navigation → agency → constraints → failure_modes → distinctions → relationships → decode_legend

# concepts(id|name|definition|category)
CO1|Position|location of entity in space at a given time; requires reference frame; absolute position requires coordinate system; relative position requires another entity|foundation
CO2|Motion|change of position over time; requires observer and reference frame; all motion is relative (no absolute motion in physics); perceived motion may differ from actual|foundation
CO3|Rest|absence of motion relative to chosen reference frame; entity at rest in one frame may be in motion in another; rest is relative not absolute|foundation
CO4|Time|dimension along which events are ordered; past → present → future; irreversible in macroscopic experience (arrow of time); measured by periodic processes (clock)|foundation
CO5|State|complete description of entity's condition at an instant; includes position, velocity, internal configuration, and all relevant properties; snapshot|foundation
CO6|Transition|change from one state to another; requires time; may be continuous (gradual) or discrete (sudden); the process connecting states|foundation
CO7|Direction|orientation of motion, force, or reference in space; requires coordinate system or reference point; vector quantity has magnitude and direction|foundation
CO8|Cause|event or condition producing or contributing to a subsequent event; temporal precedence required (cause before effect); mechanism connects cause to effect|foundation
CO9|Path|trajectory through space-time; sequence of positions occupied during motion; may be straight, curved, cyclic, branching, or random|foundation
CO10|Velocity|rate of change of position; speed (scalar: how fast) + direction (vector: which way); instantaneous or average; first derivative of position with respect to time|foundation
CO11|Acceleration|rate of change of velocity; speeding up, slowing down, or changing direction; requires force (Newton's second law: F=ma); second derivative of position|foundation
CO12|Frame of Reference|coordinate system from which observations are made; determines what appears stationary and what appears moving; inertial (non-accelerating) vs non-inertial (accelerating)|foundation
CO13|Origin|point of departure; starting position; source; beginning state; reference zero for measurement; the "from" in movement|foundation
CO14|Destination|point of arrival; ending position; target; goal state; the "to" in movement|foundation
CO15|Displacement|change in position; vector from start to end; direction matters; differs from distance (total path length traveled); shortest path between origin and destination|foundation
CO16|Distance|total path length traveled; scalar (no direction); always positive; ≥ magnitude of displacement; equals displacement only for straight-line motion|foundation
CO17|Duration|elapsed time between two events or states; temporal distance; interval; how long a transition takes|foundation
CO18|Simultaneity|two events occurring at the same time; relative in special relativity (depends on observer's frame); absolute in Newtonian mechanics|foundation
CO19|Sequence|ordered arrangement of events or states in time; before-after relationship; determines narrative, process, and causality|foundation
CO20|Cycle|path that returns to starting point/state; periodic repetition; closed loop in space or state; oscillation, orbit, rotation, iteration|foundation
CO21|Threshold|boundary value that must be crossed for transition to occur; activation energy; tipping point; minimum velocity for escape; critical mass; point of no return|foundation
CO22|Inertia|resistance to change in motion (physics: mass) or state (general: habit, institutional momentum, psychological resistance); tendency to continue current trajectory|foundation
CO23|Momentum|quantity of motion; physics: mass × velocity (p=mv); metaphor: accumulated progress or force making change difficult to stop; conservation law in closed systems|foundation

# spatial_motion(id|name|definition|properties|examples)
SM1|Translation|movement where every point of body moves same distance in same direction; no rotation; pure position change|preserves orientation; displacement vector same for all points; straight or curved path|car driving straight; elevator ascending; bird gliding without banking; chess piece sliding; planet orbiting (center translates)
SM2|Rotation|movement around an axis; points at different distances from axis move different distances; angular displacement|axis may be internal (spinning top) or external (orbiting planet); measured in degrees or radians; angular velocity ω = dθ/dt; requires centripetal force|Earth rotating on axis; wheel turning; dancer pirouetting; door on hinge; electron orbiting nucleus (quantum mechanical analog)
SM3|Revolution|one body orbiting another; rotation about external axis; combines translation with constraint to curved path|period = time for one complete circuit; orbital mechanics: Kepler's laws; gravitational binding; centripetal force from gravity|Earth around sun; moon around Earth; electron around nucleus (classical model); satellite; car on roundabout
SM4|Oscillation|repetitive motion about equilibrium position; back and forth; characterized by frequency, amplitude, period|simple harmonic: restoring force proportional to displacement (F=-kx); damped: amplitude decreases over time; driven: external force maintains; resonance: driving frequency matches natural|pendulum; spring; vibrating string; sound wave; AC current; breathing; walking (legs as inverted pendulums); tides
SM5|Locomotion|self-propelled movement of organism or machine through environment; requires energy expenditure and interaction with medium|mode depends on medium and morphology; efficiency varies by speed and mode; gait selection optimizes energy cost; all locomotion involves push against medium or surface|walking, running, swimming, flying, crawling, burrowing, climbing, rolling, slithering, hopping, swinging (brachiation)
SM6|Reciprocating Motion|back-and-forth linear motion; converted to/from rotation; piston, pump, saw|converts between linear and rotary (crankshaft); stroke length; frequency; dead points at extremes|piston engine; reciprocating saw; sewing machine needle; pump; human chewing
SM7|Projectile Motion|motion under gravity after initial impulse; parabolic trajectory (ignoring air resistance); horizontal velocity constant; vertical acceleration = g|determined by initial velocity and angle; maximum range at ~45° (vacuum); actual trajectories affected by drag, spin (Magnus effect), wind|thrown ball; bullet; jumping; waterfall; launched rocket (before engine cutoff); arrow; volcanic ejecta
SM8|Free Fall|motion under gravity alone; no other forces (idealized); all objects fall at same rate regardless of mass (Galileo; vacuum)|acceleration = g ≈ 9.81 m/s² (Earth surface); terminal velocity when air resistance equals gravity; weightlessness in free fall (astronauts in orbit are falling around Earth)|dropped object; skydiver (before parachute); orbiting spacecraft (continuous free fall); falling raindrop (until terminal velocity)
SM9|Brownian Motion|random motion of particles suspended in fluid from molecular collisions; statistical; no net direction|path is random walk; displacement grows as √time (not linearly); temperature-dependent (higher T = more energetic collisions); Einstein quantified (1905)|pollen grain in water; dust in sunbeam; molecular diffusion; stock price fluctuations (mathematical model); thermal noise in electronics
SM10|Wave Propagation|disturbance traveling through medium or space; energy transfers without net matter movement; transverse or longitudinal|frequency (oscillations/sec); wavelength (distance per cycle); speed = frequency × wavelength; amplitude; phase; interference; diffraction|sound (longitudinal: compression waves in air); light (transverse: EM field oscillation); water surface (combination); seismic; gravitational waves
SM11|Diffusion|net movement of particles from high concentration to low concentration; driven by random motion (Brownian); no external force required|rate proportional to concentration gradient (Fick's law: J = -D∇C); increases with temperature; decreases with molecular size; eventually reaches uniform distribution (equilibrium)|smell spreading across room; ink in water; oxygen from lungs to blood; heat conduction (thermal diffusion); osmosis (solvent through membrane)
SM12|Convection (Fluid Motion)|bulk movement of fluid carrying heat, matter, or momentum; driven by density differences (buoyancy) or mechanical forcing|natural convection: heated fluid rises (less dense), cool fluid sinks; forced convection: fan, pump, wind; convection cell: rising-spreading-sinking-returning|boiling water; atmospheric circulation (Hadley cell); mantle convection (plate tectonics); radiator heating room; ocean thermohaline circulation
SM13|Advection|horizontal transport by bulk flow; heat, moisture, pollutants carried by wind or current|distinguished from diffusion (random) and convection (vertical buoyancy-driven); advection is directed horizontal bulk transport|warm front (warm air advected over cold); ocean heat transport by currents; smoke plume carried by wind; fog advection (sea fog pushed onshore)
SM14|Migration|long-distance directed movement of organisms between habitats; seasonal or life-stage; round-trip or one-way|navigation by magnetic field, stars, sun, landmarks, olfaction; energy reserves critical; follows resources (food, breeding, climate); innate and learned components|bird migration (Arctic tern: pole to pole); wildebeest (Serengeti); salmon (ocean to natal stream); monarch butterfly (Mexico to Canada); human migration (seasonal, economic, forced)
SM15|Dispersal|spreading of entities from point of origin; increases range; one-way (not round-trip like migration); may be passive or active|seed dispersal (wind, water, animal); larval dispersal (ocean currents); spore dispersal; diaspora; information spread; epidemic spread|dandelion seeds; coconuts (ocean); planktonic larvae; pollen; gossip; disease vector; invasive species colonization

# temporal_position(id|name|definition|properties|examples)
TP1|Past|events/states that have already occurred; fixed (cannot be changed); known (potentially) through memory, record, evidence|irreversible; accessible through memory, documentation, archaeological/geological record; causal influence on present; certainty decreases with distance from present|yesterday; last year; geological eras; historical events; personal memory; fossil record; light from distant stars (seeing the past)
TP2|Present|current instant; boundary between past and future; the "now"; infinitesimally thin in physics; experientially extended (~3 seconds)|only directly experienceable moment; simultaneously the end of the past and beginning of future; relativistic: no universal present (simultaneity relative to observer)|this instant; "now"; specious present (psychological ~3s window); simultaneity depends on reference frame in relativity
TP3|Future|events/states that have not yet occurred; uncertain; probabilistically knowable (prediction) but not certain; branching possibilities|open (not fixed); accessible through prediction, projection, planning; uncertainty increases with distance from present; future causes cannot affect past (classical causality)|tomorrow; next year; predicted outcomes; plans; forecasts; trajectories; scheduled events; entropy increase (thermodynamic arrow)
TP4|Before (Temporal Priority)|event A occurs earlier than event B in time; A precedes B; necessary condition for A to cause B|antisymmetric (if A before B, then B not before A); transitive (if A before B and B before C, then A before C); frames temporal ordering|preparation before action; cause before effect; premise before conclusion; seed before plant; question before answer
TP5|After (Temporal Succession)|event B occurs later than event A; B succeeds A; consequence, result, aftermath|inverse of before; the "then" in "if-then" temporal sequences; where effects appear; where consequences manifest|result after action; effect after cause; conclusion after premise; response after stimulus; recovery after injury
TP6|During (Temporal Overlap)|event A occurs within the time span of event B; simultaneous existence; concurrent processes|containment: A's entire duration within B's; or partial overlap; or exact coincidence; enables interaction between concurrent processes|thinking during walking; rain during the wedding; reading while commuting; sleeping during night; parallel processing during computation
TP7|Meanwhile (Concurrent Elsewhere)|events occurring simultaneously but in different locations or domains; parallel timelines; what happens elsewhere while this happens here|spatial separation; independent or coupled processes; narrative device: "meanwhile, back at the ranch"; parallel computation; distributed systems|two people in different cities; server processing while user waits; photosynthesis while respiration; tectonic plates moving while erosion occurs
TP8|Already (Completed Prior)|state achieved before reference point; accomplished; done; prerequisite met|indicates completion relative to a reference time; may be recent or distant; implies readiness or accomplishment|already arrived; already learned; water already boiling; prerequisites already met; damage already done (irreversibility)
TP9|Not Yet (Pending)|state not achieved at reference point but expected or possible; still in progress or not begun|indicates incompleteness; expectation of future completion; potential; anticipation; prerequisite unmet|not yet arrived; not yet learned; water not yet boiling; still in transit; pending approval; fruit not yet ripe
TP10|No Longer (Ceased)|state that was active but has ended; was but is not; completed transition away from|indicates loss, completion, or passage; nostalgia; former state; expiry; the aftermath of transition|no longer raining; no longer employed; no longer alive; season ended; no longer in range; expired subscription
TP11|Permanent (Unchanging)|state persisting indefinitely; no expected end; outside temporal transition|may be physical (conservation laws), mathematical (proven theorem), or practical (effectively irreversible within relevant timescale)|death; extinction; mathematical truth; speed of light (constant); radioactive decay of individual atom (unpredictable but irreversible once occurred)
TP12|Temporary (Bounded Duration)|state with finite beginning and end; transient; will change|all physical states are ultimately temporary (entropy); duration varies from femtoseconds to billions of years; bounded by transitions|weather; employment; seasons; illness; childhood; battery charge; fashion; political regime; stellar lifetime

# direction(id|name|definition|reference|implications)
DR1|Forward|direction of facing, travel, or progress; the way one is headed; default direction of intended motion|requires facing or heading; relative to entity orientation; metaphor for progress, advancement, future|walking forward; facing direction; narrative forward (plot progresses); time moves forward; progress; car in drive gear
DR2|Backward|opposite of forward/facing direction; retreating from facing; reversing course; direction already traversed|requires facing reference; literal: walking backward; metaphorical: regression, return, reversal; viewing the past|reversing car; retreating army; looking backward (review, retrospection); backtracking; undoing; regression
DR3|Upward|direction opposing gravity; away from earth's center; toward sky/zenith; metaphor for improvement, transcendence|defined by gravity vector (varies on different bodies); absolute within local frame; counteracts weight; requires energy input to sustain|climbing; ascending; rocket launch; bubble rising; balloon; social advancement (metaphor); price increase; mood elevation (metaphor)
DR4|Downward|direction aligned with gravity; toward earth's center; toward ground/nadir; metaphor for decline, descent|natural direction of unsupported objects; requires no energy (gravity provides); terminal velocity limits speed in medium|falling; descending stairs; water flowing downhill; sinking; landing; price drop; mood decline (metaphor); diving
DR5|Lateral (Left/Right)|direction perpendicular to forward-backward axis; sideways; requires facing to define|relative to body orientation; culturally loaded (left/right political spectrum; left-hand path); bilateral symmetry creates paired directions|sidestepping; turning; lane change; political spectrum; branching choice; deviation from straight path; flanking (military)
DR6|Inward (Centripetal)|toward center; converging; contracting; deepening; introspective|toward reference center (self, group center, origin point); concentrating; focusing; introversion; compression|spiral inward; centripetal force; introspection; consolidation; focusing attention; tightening; densification; implosion
DR7|Outward (Centrifugal)|away from center; diverging; expanding; extending; extroverted|from reference center toward periphery; dispersing; broadening; extraversion; expansion|explosion; radiation; broadcasting; expansion; extending reach; exploration; diffusion; centrifugal tendency
DR8|Toward (Approaching)|reducing distance to target; converging on destination; attraction|requires target reference; distance decreasing; may be spatial, temporal, or abstract; approach can be asymptotic (never arriving)|walking toward building; approaching deadline; converging on solution; gravitational attraction; seeking; homing
DR9|Away From (Receding)|increasing distance from reference; diverging from source; repulsion|requires source reference; distance increasing; flight, escape, dispersal|running away; fleeing danger; retreating; expanding universe; repulsion; avoidance; distancing; growing apart
DR10|Clockwise / Counterclockwise|rotational direction defined by viewing axis; convention-dependent; screw direction (right-hand rule)|clock convention (viewed from front); right-hand rule for positive rotation in physics; weather systems: Northern Hemisphere low pressure = counterclockwise|clock hands; tightening screws (typically clockwise); cyclone rotation; dance direction; stirring; mathematical angle convention (counterclockwise positive)
DR11|Along (Parallel to Path)|direction aligned with path, boundary, or linear feature; following; tracking|requires reference line or boundary; motion that doesn't cross but follows; can be either direction along the line|walking along the river; driving along the coast; tracing a contour; following a boundary; reading along a line; current along a wire
DR12|Across (Perpendicular to Path/Boundary)|direction crossing path, boundary, or linear feature; transverse; traversing|requires reference to cross; creates intersection; transition from one side to other; crossing implies entering new territory|crossing the street; fording a river; crossing a border; transverse wave oscillation; transcontinental; cutting across a field
DR13|Through (Penetrating)|direction passing into, within, and out of a bounded region; transit; permeation|requires bounded region to traverse; implies entry, passage, and exit; interior experience of enclosed space|walking through a tunnel; light through glass; needle through fabric; passing through a phase; filtering through; due diligence (going through the process)
DR14|Around (Circumnavigation)|direction encircling or bypassing an obstacle or reference; orbital; circumferential|requires reference object to encircle or avoid; may return to start (complete circuit) or divert past obstacle|walking around the lake; orbiting; detour around obstacle; circumnavigation; avoiding; encirclement; wrapping

# state(id|name|definition|properties|transitions_to)
SA1|At Rest|entity stationary relative to reference frame; no motion; equilibrium or waiting|all forces balanced (Newton's first law satisfied); potential energy may be stored; stable rest (returns to rest after perturbation) or unstable (departs from rest after perturbation)|SA2 (initiating motion); SA6 (internal change without external motion)
SA2|In Motion|entity changing position relative to reference frame; traveling; kinetic|has velocity, direction, kinetic energy; subject to friction, drag, gravity; constant velocity (no acceleration) or changing velocity (accelerated)|SA1 (coming to rest); SA3 (arriving); SA4 (returning); SA5 (lost/wandering); SA7 (transforming while moving)
SA3|Arrived (At Destination)|entity has reached intended endpoint; journey complete; at goal|position = destination; velocity = 0 (or matched to destination reference frame); purpose of journey fulfilled; new state begins at destination|SA1 (resting at destination); SA2 (departing for new destination); SA6 (internal processing/change at destination)
SA4|Returning|entity in motion back toward origin; retracing; homeward; reversing previous displacement|direction = toward origin; displacement decreasing; may follow same path (retrace) or different (shortcut); round-trip completing|SA1 (returned to origin); SA2 (continuing past origin); SA3 (arriving back at origin)
SA5|Lost / Disoriented|entity's position or direction unknown relative to intended path or destination; uncertainty in navigation|information deficit: doesn't know where they are, or which way to go, or both; increased entropy of path (random walk); anxiety (organism); error state (system)|SA2 (found direction, resuming travel); SA1 (stopping to assess); SA3 (accidentally arriving); any state (depends on resolution)
SA6|In Place (Changing Internally)|entity stationary in space but undergoing internal transformation; metamorphosis; processing; aging; chemical reaction|position fixed; internal state changing; time passing; examples span from milliseconds (reaction) to billions of years (stellar evolution)|SA2 (internal change completed, entity now moves); SA7 (entity moves while still changing); SA8 (entity ceases to exist through transformation)
SA7|In Transit (Between States)|entity moving between defined states or locations; liminal; neither fully departed nor arrived; in-between|ambiguous identity (between roles, locations, phases); vulnerable; transformative potential; threshold state; ritually significant (liminal space)|SA3 (arrival completes transit); SA4 (return abandons transit); SA5 (transit becomes disoriented); SA8 (transit fails, entity transforms)
SA8|Dissolved / Transformed|entity no longer exists in original form; identity changed through combination, decomposition, or metamorphosis; the former state|irreversible (or difficult to reverse); components may persist in new arrangement; death, reaction completion, merger, metamorphosis|new entity emerges (SA1 of different entity); components dispersed (SM15); information may persist (memory, record, fossil)
SA9|Suspended (Paused)|motion or process temporarily halted; not at rest (expects resumption) nor terminated; frozen in time; on hold|preserves state for later resumption; energy/attention diverted; queue; sleep; standby; cryopreservation; buffered|SA2 (resumed motion); SA1 (suspension becomes permanent rest); SA6 (internal change during suspension); SA8 (suspension exceeds viability, entity degrades)
SA10|Orbiting (Bound Cycle)|entity in perpetual motion around reference; bound by force; dynamic equilibrium between inertia and attraction|balance of centripetal force and tangential velocity; stable orbit, decaying orbit (energy loss), or escape trajectory; periodic; gravitational, electromagnetic, or metaphorical|SA2 (orbit decays, entity spirals inward or escapes); SA1 (orbit circularizes, dynamic rest); SA8 (collision with central body)
SA11|Accelerating|entity's velocity is increasing; gaining speed; force exceeds resistance; building momentum|kinetic energy increasing; force applied in direction of motion; sensation of being pushed back (inertial frame); distance covered per unit time increasing|SA2 (reaches constant velocity: cruising); SA12 (begins decelerating); SA1 (if acceleration ceases and friction brings to rest)
SA12|Decelerating|entity's velocity is decreasing; slowing; resistance exceeds applied force; losing momentum|kinetic energy decreasing; force opposing direction of motion (friction, braking, drag); sensation of being pushed forward; distance per unit time decreasing|SA1 (comes to rest); SA2 (deceleration stops, constant velocity resumes); SA11 (reverses, begins accelerating again)
SA13|Hovering (Dynamic Rest)|entity maintaining position through continuous energy expenditure against displacement force; not at stable rest but appearing stationary|energy required to maintain (unlike true rest); hummingbird, helicopter, treading water, geostationary satellite; position stable but state is active not passive|SA2 (moves from hover); SA1 (finds stable rest without energy expenditure); SA8 (energy exhausted, falls/sinks)

# transition(id|name|definition|mechanism|properties)
TR1|Departure|leaving origin; initiating journey; beginning of displacement from starting point|overcoming inertia (physical or psychological); energy input; decision point; breaking bonds (physical, social, emotional); irreversibility threshold may apply|requires activation energy; emotional loading (excitement, anxiety, grief); point of no return may follow departure; changes frame of reference
TR2|Arrival|reaching destination; journey's end; stopping at intended point; meeting between traveler and place|deceleration; recognition of destination; matching position and velocity to destination frame; unloading, unpacking, integrating|completion of spatial goal; may trigger new sequence (arrival is departure from transit state); orientation to new environment
TR3|Acceleration (Phase)|transition from rest to motion or from slower to faster; gaining kinetic energy; force applied|force > resistance → net acceleration; energy source (engine, muscle, gravity, chemical); momentum building; overcoming static friction (greater than kinetic)|jerk (rate of change of acceleration) determines smoothness; gradual vs sudden; linear or angular; launch, ramp-up, onset
TR4|Deceleration (Phase)|transition from faster to slower or from motion to rest; losing kinetic energy; resistance applied|friction, braking, drag, uphill; kinetic energy converted to heat, deformation, or stored energy (regenerative braking); deceleration force may be controlled or uncontrolled|controlled: braking; uncontrolled: collision; gradual: coasting to stop; sudden: impact; energy must go somewhere (heat, deformation, sound)
TR5|Reversal|changing direction to opposite; turning around; returning; negating previous displacement|requires deceleration to zero then acceleration in opposite direction; U-turn; reflection; rebound; policy reversal; emotional reversal|velocity passes through zero (momentary rest); kinetic energy converts to potential or heat then reconverts; reversals in oscillation are continuous; in decision-making may be abrupt
TR6|Phase Transition (Physical)|change in state of matter; solid↔liquid↔gas; occurs at specific temperature/pressure combinations; latent heat absorbed/released|melting, freezing, evaporation, condensation, sublimation, deposition; occurs at constant temperature (latent heat); first-order (discontinuous volume/entropy change) or second-order (continuous)|critical point: liquid-gas distinction vanishes; supercooling/superheating possible (metastable states past transition point); nucleation required to initiate (seed crystal, condensation nucleus)
TR7|Threshold Crossing|passing a critical value triggering qualitative change in behavior; discontinuous response to continuous change; tipping point|system accumulates change (continuous) until threshold reached → abrupt qualitative shift; hysteresis: threshold for forward transition may differ from threshold for reverse|all-or-nothing: neuron firing, phase transition, structural failure; gradual approach, sudden change; point of no return; cascade may follow threshold crossing; warning signs may precede (critical slowing down)
TR8|Gradual Change|continuous incremental change in state over time; no abrupt transitions; smooth transformation|rate may be constant (linear) or varying (exponential, logarithmic); each instant differs only infinitesimally from previous; trend visible only over accumulated time|erosion; aging; learning; inflation; drift; gradual warming; skill acquisition; evolutionary adaptation; continental drift; compound interest
TR9|Sudden Change|abrupt discontinuous change in state; step function; shock; event|occurs in negligible time relative to observation scale; may be triggered by threshold crossing, external event, or cascade failure; large energy release possible|earthquake; explosion; birth; death; switching; breaking; power failure; revelation; phase transition; market crash; regime change
TR10|Bifurcation|system reaches point where single path splits into two or more distinct possible states; choice point; branching|parameter change makes current state unstable; system must choose between new stable states; small perturbation determines which branch taken (sensitivity); once chosen, system follows new trajectory|road fork; decision point; phase diagram triple point; pitchfork bifurcation (physics); species divergence (evolution); career choice; symmetry breaking
TR11|Convergence|multiple paths, states, or entities approaching common point; merging; focusing; agreement|distance between entities or states decreasing over time; may reach common point (convergence) or asymptotically approach; iterative processes may converge on solution|rivers merging; consensus forming; evolutionary convergence (similar solutions to similar problems); mathematical convergence (series approaching limit); population gathering; lane merging
TR12|Divergence|single path splitting or entities moving apart; separating; branching; disagreement|distance between entities or states increasing over time; originated from common point; butterfly effect (sensitive dependence on initial conditions in chaotic systems)|river delta (branching); species divergence; opinion polarization; chaotic trajectories; light diverging from source; diaspora; organizational split
TR13|Oscillatory Transition|alternating between two or more states repetitively; no permanent change; dynamic equilibrium|period, frequency, amplitude; may be damped (decreasing amplitude → settling to one state), sustained (constant amplitude), or growing (increasing → instability)|pendulum; alternating current; breathing; sleep-wake cycle; economic cycles; tidal cycle; seasonal variation; predator-prey population oscillation; mood cycling

# causality(id|name|definition|temporal_requirement|strength)
CU1|Necessary Cause|A must be present for B to occur; without A, B impossible; but A alone may not be sufficient|A before or simultaneous with B; counterfactual: if not A, then not B|eliminates B when absent; identified by: removing A always prevents B; oxygen necessary for combustion; but oxygen doesn't cause combustion (not sufficient)
CU2|Sufficient Cause|A alone guarantees B; whenever A occurs, B follows; but B may occur from other causes too|A before B; deterministic: if A then always B|guarantees B when present; identified by: A always produces B regardless of other factors; decapitation sufficient for death; but death occurs from many other causes
CU3|Necessary and Sufficient|A is required for B and A alone produces B; A if and only if B; complete causal specification|A before B; bijective causal relationship; if A then B, and if B then A must have occurred|strongest causal claim; rare in complex systems; more common in logic and mathematics; XOR gate: specific input combination necessary and sufficient for specific output
CU4|Proximate Cause|most immediate cause in causal chain; last event before effect; the trigger|immediately precedes effect; temporally closest; mechanism directly connects|striking match is proximate cause of flame; often confused with root cause; legal causation focuses on proximate; assassination triggering war
CU5|Distal (Root) Cause|underlying cause far back in causal chain; fundamental; removing it prevents entire chain|temporally distant from effect; connected through chain of intermediate causes; often structural or systemic|poverty as root cause of crime (not proximate); tectonic stress as root cause of earthquake (not the rupture); system design flaw as root cause of failure
CU6|Contributory Cause|increases probability of effect without guaranteeing it; risk factor; partial cause|temporally before or concurrent; probabilistic rather than deterministic; may combine with other contributory causes|smoking contributes to cancer (not all smokers get cancer); fatigue contributes to accidents; multiple contributory causes may combine to reach sufficiency
CU7|Counterfactual Causation|A caused B if: had A not occurred, B would not have occurred; the "but for" test; most intuitive causal reasoning|requires imagining alternative scenario (counterfactual world); assumes everything else held equal (ceteris paribus); may be ambiguous with multiple causes|but for the defective brake, the accident would not have occurred; counterfactual reasoning: the foundation of most causal claims; problematic when multiple sufficient causes present (overdetermination)
CU8|Causal Chain|sequence A → B → C where A causes B and B causes C; transitive causation; domino effect; cascade|each link is proximate cause of next; removing any link breaks chain downstream; chain can be long (many intermediate steps) or short|Rube Goldberg machine; food chain (sun → plant → herbivore → predator); production chain (raw material → component → assembly → product); infection → inflammation → tissue damage → organ failure
CU9|Mutual Causation|A causes B and B causes A; circular causality; feedback loop; co-evolution; chicken-and-egg|no clear temporal priority; simultaneous or rapidly alternating; creates self-sustaining dynamic; may be stabilizing (negative feedback) or destabilizing (positive feedback)|predator-prey cycle; supply and demand; chicken and egg; technology and society; climate and vegetation; trust and cooperation
CU10|Overdetermination|multiple independently sufficient causes for same effect; each would have caused it alone; redundancy of causation|multiple sufficient causes present; removing any single one doesn't prevent effect; complicates counterfactual reasoning|two assassins independently fire lethal shots simultaneously; multiple adequate explanations for same phenomenon; redundant safety systems all triggered
CU11|Teleological Cause (Purpose)|cause understood as goal or purpose toward which system tends; future state explains current behavior; intentional in agents, functional in biology/design|conceptually: future state "causes" present action (backward causation in explanation, not physics); in agents: representation of goal drives behavior; in biology: function explains structure (selected for)|intention: "I study because I want to graduate" (future goal → present action); biological function: "the heart beats to circulate blood" (function = effect that was selected for); thermostat: set point determines behavior
CU12|Stochastic Causation|cause increases probability of effect but doesn't determine it; probabilistic; statistical causation|probability P(B|A) > P(B|not-A); may or may not produce effect in any individual case; aggregate pattern over many cases|smoking causes cancer (statistically, not deterministically); exposure to pathogen → probability of infection; radioactive decay: cause (nuclear instability) is deterministic in principle but unpredictable for individual atom; drug efficacy

# reference_frames(id|name|definition|properties|examples)
RF1|Egocentric (Self-Centered)|spatial relationships defined relative to one's own body; left, right, front, behind; moves with the entity|rotates and translates with observer; natural for navigation and action; develops first in children (~6 months); automatically engaged|"the door is to my left"; "the car is behind me"; proprioceptive space; body schema; personal space
RF2|Allocentric (World-Centered)|spatial relationships defined relative to external landmarks or cardinal directions; independent of observer position|fixed relative to environment; requires cognitive map; develops later in children (~2 years); hippocampus-dependent; survey knowledge|"the library is north of the park"; "the cup is left of the plate" (from any viewing angle); maps; coordinate systems; absolute directions
RF3|Relative (Object-Centered)|spatial relationships defined relative to another object; object's intrinsic frame (front, back) or viewing-dependent|requires knowing object's orientation; or imposing orientation from viewing angle; intermediate between egocentric and allocentric|"the ball is in front of the chair" (chair's front); "the cat is behind the tree" (relative to my view); spatial prepositions in language
RF4|Temporal (Before/After as Frame)|events ordered by temporal sequence from reference event; past/future relative to "now" or reference event; history as frame|origin = reference event; before = negative; after = positive; duration = distance; "now" continuously advancing; multiple temporal frames possible (narrative time vs clock time)|"three days before the wedding"; "two hours after sunrise"; geological time scale (before/after K-Pg boundary); narrative: flashback (reframing temporal reference point); relativity: no universal "now"
RF5|Inertial Frame|reference frame not accelerating; Newton's laws hold without modification; all inertial frames equivalent (special relativity)|uniform motion or rest; no fictitious forces (centrifugal, Coriolis) needed; Einstein's first postulate: physics same in all inertial frames; can't distinguish rest from uniform motion without external reference|passenger in smooth train at constant velocity; free-floating spacecraft (no thrust); laboratory on Earth's surface (approximately inertial; small corrections for rotation)
RF6|Non-Inertial Frame|accelerating reference frame; fictitious (pseudo) forces appear; Newton's laws require correction terms|rotating, accelerating, or decelerating; fictitious forces (centrifugal, Coriolis, Euler) must be added to explain observed motion; observer experiences forces with no physical source|merry-go-round (centrifugal force pushes outward); accelerating car (passengers feel pushed backward); Earth's surface (Coriolis deflects large-scale motion); elevator accelerating upward (feel heavier)
RF7|Moving Frame (Relative Motion)|describing motion from perspective of another moving entity; velocity addition; relative velocity|velocity of A relative to B: v_AB = v_A - v_B; different observers disagree on velocity but agree on acceleration (Galilean) or disagree on both (relativistic)|train passenger sees stationary platform moving backward; two cars on highway: relative speed determines overtaking; wind chill: air velocity relative to body; Galilean transformation: r' = r - vt

# path(id|name|definition|properties|examples)
PA1|Straight Line (Rectilinear)|shortest distance between two points in Euclidean space; constant direction; zero curvature|displacement equals distance; no direction change; constant heading; ray of light in vacuum|highway through flat terrain; laser beam; free-falling object (ignoring air resistance, horizontal component); Euclidean geodesic
PA2|Curved Path|path with continuously changing direction; nonzero curvature; requires centripetal acceleration|radius of curvature at each point; tighter curve = higher acceleration for given speed; natural trajectories under force (projectile, orbit)|planetary orbit; river meander; mountain road switchback; thrown ball trajectory; electron in magnetic field; spiral staircase
PA3|Circular Path|constant radius from center; closed curve; 360° returns to start; special case of curved path|circumference = 2πr; period = time per revolution; centripetal acceleration = v²/r; uniform circular motion: constant speed, changing direction|satellite orbit (approximately); wheel point; clock hand; track running; merry-go-round; electron in classical orbit model
PA4|Spiral|path combining rotation with radial change; either expanding (outward spiral) or contracting (inward spiral); never closes unless special case|Archimedean: r = a + bθ (constant separation); logarithmic: r = ae^(bθ) (self-similar, natural); helix: 3D spiral with constant altitude gain|galaxy arms; hurricane; DNA double helix; spiral staircase; nautilus shell (logarithmic); toilet flush (Coriolis myth but real for other spirals); spring (helix)
PA5|Random Walk|path where each step is in random direction; no net direction over time; displacement grows as √(steps), not linearly|expected displacement proportional to √n (not n); diffusion follows random walk statistics; in higher dimensions: probability of return to origin decreases (2D: returns with probability 1; 3D: probability ~0.34)|Brownian motion; drunk walking; stock prices (model); molecular diffusion; genetic drift; foraging in unknown territory; unbiased random search
PA6|Zigzag|path alternating between two directions; back and forth across a general heading; tacking|covers more distance than straight line but may be necessary (sailing upwind, switchback road); frequency and amplitude of zigzag vary; combines forward progress with lateral oscillation|sailing upwind (tacking); switchback mountain road; running between bases; needle through fabric; evasive driving; search pattern (lawn mowing)
PA7|Orbital Path|closed or nearly closed curved path under central force; gravitationally or electromagnetically bound|Keplerian: elliptical (bound), parabolic (escape), hyperbolic (flyby); two-body approximation; perturbations from other bodies; precession of orbit; stable or decaying|planets around sun; moon around Earth; electrons around nucleus (quantum model); binary stars; satellite; space station; geostationary orbit
PA8|Geodesic|shortest path between two points in curved space; straight line in flat space; great circle on sphere; curved by mass-energy in general relativity|in Euclidean space: straight line; on sphere: great circle (not constant latitude except equator); in general relativity: curvature of spacetime determines geodesic; light follows geodesics|airplane great circle route (shortest over sphere); light path near massive object (gravitational lensing); Einstein ring; free-falling objects follow spacetime geodesics; equator and meridians are geodesics, parallels of latitude are not (except equator)
PA9|Closed Path (Loop)|path returning to starting point; cycle completed; net displacement zero; distance > 0 but displacement = 0|any loop: displacement = 0; may pass through many states/locations before returning; circular, elliptical, irregular, or figure-eight; round trip|daily commute (home → work → home); orbit; feedback loop; seasonal cycle; circular walk; blood circulation; iteration in computation; Euler circuit (graph theory: visit every edge exactly once)
PA10|One-Way Path (Irreversible)|path that cannot be retraced; direction is fixed; no return possible; temporal paths are inherently one-way|may be physically one-way (valve, ratchet, diode, time) or practically one-way (entropy increase, bridge burned, commitment made)|arrow of time; one-way street; diode; ratchet; aging; entropy increase; irreversible chemical reaction; burned bridge; point of no return; death

# velocity(id|name|definition|properties|examples)
VE1|Zero Velocity (Stationary)|v = 0 in reference frame; at rest; no motion; static|all forces balanced or no forces acting; potential energy may be maximal (hilltop) or minimal (valley); equilibrium|parked car; sleeping animal; book on table; eye of hurricane; equilibrium point of oscillation (momentary); lagrange point
VE2|Constant Velocity (Uniform Motion)|speed and direction unchanging; no acceleration; Newton's first law: continues until force acts|no net force required (inertia); kinetic energy constant; straight-line path; in practice: rare (friction and gravity ubiquitous); cruise control approximates|spacecraft in deep space (no friction); object on frictionless surface (idealized); airplane at cruising altitude (approximately); terminal velocity in free fall (drag = gravity)
VE3|Variable Velocity (Accelerated Motion)|speed, direction, or both changing over time; force acting; energy being added or removed|requires net force; acceleration = Δv/Δt; can be speeding up, slowing down, or turning; most real motion is accelerated|car accelerating from stoplight; ball thrown upward (decelerating then accelerating); planet in elliptical orbit (speed varies); runner in a race (accelerates, cruises, decelerates)
VE4|Terminal Velocity|maximum velocity reached when driving force equals resistance force; no further acceleration; dynamic equilibrium|drag force increases with velocity (typically v² for turbulent flow) until equals driving force (gravity for falling); shape, density, and medium determine terminal velocity|skydiver (~55 m/s belly-down, ~90 m/s head-down); raindrop (~9 m/s); dust particle (~0.001 m/s); feather vs bowling ball in vacuum (same acceleration, no terminal velocity)
VE5|Escape Velocity|minimum velocity to escape gravitational bound without further propulsion; depends on mass and radius of gravitating body|v_escape = √(2GM/r); Earth: ~11.2 km/s; Moon: ~2.4 km/s; direction doesn't matter (only speed); escape = never returns (kinetic ≥ gravitational potential)|rocket leaving Earth (must reach 11.2 km/s); gas molecules escaping atmosphere (light gases: H₂, He escape more easily); escape from star, galaxy; metaphorical: escape velocity from poverty, bad situation
VE6|Group Velocity vs Phase Velocity|wave packets: group velocity (speed of envelope/energy) may differ from phase velocity (speed of individual wave crests)|phase: v_p = ω/k; group: v_g = dω/dk; in dispersive media: v_g ≠ v_p; energy travels at group velocity; information limited by group velocity|water waves: individual crests move faster than wave packet; light in glass: phase velocity can exceed c but group velocity (and energy) cannot; quantum mechanics: particle velocity = group velocity of wavefunction

# oscillation(id|name|definition|properties|examples)
OS1|Simple Harmonic Motion (SHM)|oscillation where restoring force proportional to displacement from equilibrium; sinusoidal in time|F = -kx; x(t) = A cos(ωt + φ); period T = 2π√(m/k); frequency independent of amplitude; energy oscillates between kinetic and potential|ideal spring; ideal pendulum (small angle); LC circuit (current/voltage oscillation); molecular vibration; sound wave; simple model for many oscillatory phenomena
OS2|Damped Oscillation|oscillation with amplitude decreasing over time due to energy dissipation (friction, resistance); eventually returns to equilibrium|underdamped: oscillates with decreasing amplitude; critically damped: returns to equilibrium fastest without oscillating; overdamped: returns slowly without oscillating|car shock absorber (designed near critical damping); bell (underdamped: rings and fades); door closer (critically damped: closes smoothly); grief process (emotional damped oscillation)
OS3|Forced Oscillation / Resonance|external periodic force drives oscillation; if driving frequency matches natural frequency → resonance → amplitude maximizes (potentially destructive)|resonance frequency = natural frequency of system; amplitude at resonance limited only by damping; phase relationship between driving force and response shifts through 90° at resonance|pushing a swing (timing must match natural frequency); Tacoma Narrows Bridge collapse (wind-driven resonance); radio tuning (selecting resonant frequency); MRI (nuclear magnetic resonance); microwave oven (water molecule resonance)
OS4|Standing Wave|superposition of two waves traveling in opposite directions; creates pattern of nodes (zero amplitude) and antinodes (maximum amplitude); appears stationary|fixed nodes and antinodes; occurs in bounded systems (string, pipe, cavity); wavelength constrained by boundary conditions (λ = 2L/n for string fixed at both ends); harmonic series|guitar string; organ pipe; laser cavity; quantum particle in box; electromagnetic cavity; bathtub sloshing; stadium wave (approximate)

# navigation(id|name|definition|method|requirements)
NV1|Dead Reckoning|estimating current position by advancing previous known position using speed, direction, and elapsed time|start from known position; measure heading (compass) and speed (odometer, knot log); calculate new position; accumulates error over time (no correction)|known starting position; heading measurement; speed measurement; time measurement; errors compound without external fix; historically primary marine and air navigation before GPS
NV2|Celestial Navigation|determining position by measuring angles between celestial bodies (sun, moon, stars, planets) and horizon|sextant measures altitude of celestial body; almanac provides body's position; spherical trigonometry calculates observer position; fixes from multiple bodies for accuracy|clear sky; known date and time; sextant; almanac; mathematical skills; limited accuracy (~1-2 nautical miles); historically: open ocean navigation; Polynesian wayfinding used stars, waves, clouds, birds without instruments
NV3|Landmark Navigation|determining position and direction by reference to known features in environment; piloting; visual navigation|recognize landmarks; compare to map or mental model; determine position relative to known features; infer direction to destination|visibility of landmarks; prior knowledge or map; line-of-sight; cognitive map; oldest and most intuitive navigation method; animals use landmarks (bees, birds, fish)
NV4|Inertial Navigation|measuring acceleration and rotation to calculate position change from known starting point; self-contained; no external signals|accelerometers measure acceleration (3 axes); gyroscopes measure rotation (3 axes); integrate acceleration twice to get position; errors accumulate (drift); periodic correction needed|no external signals required; works underwater, underground, in space; drift error accumulates (~1 km/hr for navigation-grade); corrected by GPS, stellar, or other fix; aircraft, submarine, spacecraft, missile
NV5|Satellite Navigation (GPS/GNSS)|determining position by measuring time-of-flight of signals from multiple satellites with known positions|each satellite broadcasts precise time signal; receiver measures arrival time difference; distance = time × speed of light; 4+ satellites for 3D position + time correction; accuracy: ~1-5m civilian|GPS (US), GLONASS (Russia), Galileo (EU), BeiDou (China); requires line-of-sight to sky (fails indoors, underground, dense canyon); differential GPS/RTK for cm-level accuracy; transformed navigation for all applications
NV6|Magnetic Navigation|using Earth's magnetic field for direction finding; compass; animal magnetoreception|compass needle aligns with magnetic field (magnetic north ≠ geographic north: declination varies by location); magnetic dip (inclination) provides latitude information; some animals detect magnetic field directly (birds, sea turtles, bees)|compass: oldest navigation instrument; declination correction required; magnetic anomalies mislead; animal migration: birds navigate using magnetic map + sun compass + stars; magnetotactic bacteria; compass rose on maps

# agency(id|name|definition|properties|examples)
AG1|Voluntary Motion|self-initiated movement based on intention; goal-directed; requires decision and energy; agent chooses to move|requires agency, decision-making, energy source, motor capability; can be modified, stopped, or redirected by agent; distinguishes living from non-living motion|human walking; bird flying; fish swimming; robot executing programmed task (pseudo-agency); animal foraging; choosing to turn left
AG2|Involuntary Motion|movement without conscious intention; reflexive, passive, or externally imposed|may be reflexive (sneeze, startle), passive (carried by current, gravity), or forced (pushed, dragged); agent does not choose; may resist or not|heartbeat; reflexive withdrawal from pain; being carried by current; falling; being pushed; peristalsis; breathing (partially involuntary); pupil dilation
AG3|Guided Motion|movement directed by external information or constraint; following path, instruction, or signal|agent moves but direction determined by guide: tracks, rails, signs, GPS, leader, pheromone trail, gradient; reduces navigation burden; constrains freedom|train on track; car following GPS; ant following pheromone trail; aircraft on instrument approach; guided missile; following directions; electron in wire
AG4|Constrained Motion|movement limited by physical barriers, rules, or boundaries; freedom of motion restricted|constraints reduce degrees of freedom; joint allows rotation but prevents translation; wall prevents passage; law limits speed; prison confines|pendulum (constrained to arc); car on road (constrained to road surface); ball in bowl (constrained to interior); joint articulation; legal speed limit; social norms limiting behavior
AG5|Assisted Motion|movement augmented by external force, technology, or other agent; amplifies or enables motion that agent alone cannot achieve|tool, vehicle, helper, prosthetic, exoskeleton, riding animal, sail, current; extends range, speed, or capability beyond biological limits|riding horse; cycling; sailing; wheelchair; elevator; escalator; moving walkway; prosthetic limb; power steering; aiding someone to walk; jetpack
AG6|Impeded Motion|movement hindered by resistance, obstruction, or opposition; friction, drag, barrier, adversary|requires more energy or time than unimpeded motion; may slow, redirect, or stop motion; obstacle may be physical, social, legal, or psychological|walking through mud; headwind; locked door; bureaucratic obstacles; traffic jam; gravitational hill; social resistance to change; writer's block; swim against current

# constraints(id|name|definition|mechanism|examples)
CN1|Friction|force opposing relative motion between surfaces in contact; static (prevents initiation) > kinetic (opposes ongoing)|surface roughness; molecular adhesion; normal force dependent; coefficient of friction (μ) varies by material pair; essential for locomotion (walking requires friction; ice is dangerous because low friction)|walking (foot pushes backward, friction pushes forward); braking; belt drive; writing with pencil; sandpaper; tires on road; joints (synovial fluid reduces friction)
CN2|Drag (Fluid Resistance)|force opposing motion through fluid (air, water); increases with velocity (proportional to v² for turbulent flow)|depends on: velocity, fluid density, cross-sectional area, shape (drag coefficient); streamlining reduces drag; terminal velocity when drag = driving force|air resistance on car; water resistance on swimmer; parachute (maximizes drag intentionally); aerodynamic design; airplane; bird; raindrop reaching terminal velocity
CN3|Gravity|attractive force between all masses; dominant constraint on terrestrial motion; determines "up" and "down"|F = GMm/r²; surface: F = mg; g ≈ 9.81 m/s² (Earth); always attractive; infinite range; weakest fundamental force but dominant at macroscopic scale|falling; orbital mechanics; weight; tides; vertical constraint on locomotion; energy cost of climbing; water flows downhill; atmosphere retained by gravity; structural engineering (buildings must resist gravity)
CN4|Inertia (as Constraint)|mass resists changes in motion; more mass = harder to start, stop, or redirect; Newton's first law as constraint|proportional to mass; no friction needed for inertia to operate; applies equally to starting and stopping; rotational inertia (moment of inertia) depends on mass distribution|heavy object hard to push; supertanker takes km to stop; ice skater pulls in arms to spin faster (reducing moment of inertia); changing organizational direction (institutional inertia)
CN5|Barrier (Physical)|solid obstacle preventing passage; wall, fence, mountain, body of water; requires going over, under, around, or through|may be natural (mountain, river, ocean) or constructed (wall, fence, locked door); permeability varies (fence: partial barrier; wall: complete; membrane: selective)|prison wall; mountain range; ocean; locked door; cell membrane (selectively permeable); blood-brain barrier; firewall (digital); customs border; language barrier (metaphorical)
CN6|Boundary (Spatial Limit)|edge of permitted or possible movement region; may be physical, legal, or conceptual|hard boundary: impassable (wall, cliff edge); soft boundary: crossable with penalty or effort (speed zone, social norm); absorbing: entity captured; reflecting: entity bounced back|property line; national border; cell membrane; event horizon (hard); territorial boundary (animal); comfort zone (psychological); speed limit (legal); edge of map
CN7|Temporal Constraint|deadline, sequence requirement, duration limitation, or timing restriction on motion/action|must arrive before X; must wait until Y; cannot exceed Z duration; must occur in sequence A→B→C; synchronization requirement|flight departure time; traffic signal; seasonal migration window; cooking time; gestation period; expiry date; reaction time; musical tempo; construction schedule
CN8|Energy Constraint|motion requires energy; available energy limits range, speed, duration, and payload of movement|kinetic energy = ½mv²; potential energy = mgh; chemical energy (fuel, food); battery capacity; metabolic rate limits sustained output; energy efficiency determines range|fuel range of vehicle; migratory bird fat reserves; battery life of drone; caloric requirements of hiking; range anxiety (electric vehicles); food supply for expedition; metabolic cost of different gaits

# failure_modes(id|topic|mode|cause|consequence|prevention)
FM1|navigation|getting lost|insufficient landmarks; dead reckoning error accumulation; map-territory mismatch; unfamiliar territory; instrument failure|inability to reach destination; wasted time and energy; danger (wilderness, sea); psychological distress; resource depletion|multiple navigation methods; regular position fixes; familiar landmarks; GPS with backup; map and compass skills; tell someone your plan
FM2|motion|collision|converging paths; insufficient stopping distance; obscured sightlines; miscalculated relative velocity; inattention|energy transfer (damage); momentum change (injury); path disruption; secondary effects (fire, spillage, obstruction)|collision avoidance: maintain distance; clear sightlines; reduce speed when visibility limited; separate converging traffic (altitude, time, lanes); radar/sensors; right-of-way rules
FM3|transition|premature transition|threshold not actually reached; false trigger; insufficient preparation; rushed departure|incomplete process; failure at new state (not ready); resource waste; may not be reversible (premature birth, premature launch, premature commitment)|verify threshold conditions before committing; checklists; testing; staging (gradual transition through intermediate states); rehearsal; pilot program before full deployment
FM4|transition|failed transition|insufficient energy to cross threshold; barrier too high; opposing forces too strong; interrupted process|stuck between states (liminal trap); energy wasted; may require returning to original state (if possible) or finding alternative path|assess requirements before attempting; ensure sufficient resources; address barriers before transition; contingency plans; alternative paths; staged approach (lower barriers incrementally)
FM5|causality|confusing correlation with causation|two events co-occur but no mechanism connects them; shared cause creates appearance of causation; coincidence|false causal beliefs; ineffective interventions; wasted resources addressing symptoms not causes; superstition|require mechanism (not just correlation); test by intervention (change A, observe B); control for confounders; counterfactual reasoning; statistical methods (randomized controlled trials)
FM6|state|state decay|maintenance required but not performed; entropy; degradation; resource depletion without replenishment|gradual loss of function; eventual failure; system drifts from intended state; equipment breakdown; skill atrophy; relationship decay|maintenance schedules; monitoring; resource replenishment; practice (skills); attention (relationships); preventive replacement before failure; entropy is natural — resistance requires energy
FM7|direction|wrong direction|misread compass; wrong turn; reversed signs; dyslexic map reading; assumption error|increasing distance from destination; wasted time and resources; may reach opposite of intended goal; disorientation|verify direction against multiple references; check early (error detected sooner = less waste); compass + landmarks + GPS; trust instruments over intuition when disoriented
FM8|path|path dependency (lock-in)|early choice constrains future options; switching costs too high; sunk cost fallacy keeps entity on suboptimal path|stuck on inferior path despite better alternatives existing; innovation blocked; suboptimal equilibrium; QWERTY keyboard; VHS over Beta; technological lock-in|evaluate path choices for long-term constraints before committing; maintain optionality; reduce switching costs; recognize sunk costs as irrelevant to future decisions; sunset clauses; modular design enabling component replacement
FM9|velocity|exceeding safe speed|driving force exceeds control capability; insufficient braking distance for conditions; speed inappropriate for visibility or path curvature|loss of control; collision; derailment; structural failure from dynamic loads; inability to stop or turn in available space|match speed to conditions (visibility, path curvature, stopping distance, control capability); speed limits based on worst reasonable conditions; progressive speed zones; automatic speed limiting
FM10|oscillation|resonance failure|driving frequency matches natural frequency; insufficient damping; amplitude grows beyond structural limits|catastrophic oscillation; structural failure; Tacoma Narrows Bridge; wine glass shattered by voice; machinery vibration damage|damping; avoid operating near resonant frequencies; design natural frequency away from expected driving frequencies; vibration isolation; monitoring; detuning

# distinctions(id|side_a|side_b|key_asymmetry)
DI1|Position|Velocity|position: where entity is at an instant; scalar or vector specifying location; velocity: how position changes over time; first derivative; knowing position doesn't tell you velocity; knowing velocity doesn't tell you position (without knowing starting position and duration)
DI2|Speed|Velocity|speed: rate of travel, scalar (magnitude only); always ≥ 0; distance/time; velocity: rate and direction of travel, vector; can be negative (opposite direction); displacement/time; car speedometer shows speed; velocity requires direction specification
DI3|Distance|Displacement|distance: total path length traveled; scalar; always positive; depends on path taken; displacement: net change in position; vector (magnitude + direction); independent of path; straight line from start to end; driving 5 km north then 5 km south: distance = 10 km, displacement = 0
DI4|Motion|Change|motion: change of position in space over time; physical; observable; change: alteration of any property over time; broader than motion; includes internal transformation, state change, chemical reaction, aging; motion is a type of change; not all change involves motion
DI5|Cause|Correlation|cause: A produces B through mechanism; removing A prevents B; intervention test; correlation: A and B co-occur; may share common cause, be coincidental, or one may cause the other; correlation is necessary but not sufficient evidence for causation; requires mechanism
DI6|State|Process|state: condition at an instant; snapshot; time-independent description; process: series of states connected by transitions over time; temporal extent; narrative; state is a point; process is a path through state space; photography vs film
DI7|Continuous|Discrete|continuous: infinitely divisible; smooth transition between values; analog; calculus describes; real number line; discrete: indivisible units; jumps between values; digital; counting describes; integers; natural world often appears continuous but may be fundamentally discrete (quantum)
DI8|Reversible|Irreversible|reversible: can return to initial state via reverse path; no net change in universe; idealized (frictionless, infinitely slow); irreversible: cannot return to initial state without external work; entropy increased; all real processes are irreversible; forward and reverse are not symmetric; time has a direction because processes are irreversible
DI9|Absolute|Relative|absolute: independent of observer or reference frame; invariant; same for everyone; speed of light (special relativity); relative: dependent on observer; changes with reference frame; velocity, position, simultaneity (in relativity); most kinematic quantities are relative; only certain quantities are absolute (spacetime interval, proper time, speed of light)
DI10|Linear Motion|Rotational Motion|linear: along a line; described by displacement, velocity, acceleration, force, mass; rotational: around an axis; described by angular displacement, angular velocity, angular acceleration, torque, moment of inertia; parallel mathematical structure; every linear quantity has rotational analog (v↔ω, a↔α, F↔τ, m↔I, p↔L)
DI11|Voluntary|Involuntary|voluntary: initiated and controlled by agent's intention; goal-directed; can be stopped; requires decision; involuntary: not initiated by intention; reflexive, passive, or externally imposed; may not be stoppable; breathing is intermediate (normally involuntary, can be voluntarily controlled)
DI12|Periodic|Aperiodic|periodic: repeats at regular intervals; predictable; frequency and period defined; Fourier-decomposable into sine waves; aperiodic: does not repeat regularly; one-time event, chaotic, or quasi-periodic; weather is aperiodic; seasons are periodic; heartbeat is quasi-periodic
DI13|Egocentric Direction|Allocentric Direction|egocentric: defined by body orientation (left, right, forward, behind); changes when entity turns; natural for action and navigation; allocentric: defined by external reference (north, south, toward landmark); stable regardless of body orientation; required for maps and shared spatial reference
DI14|Path|Trajectory|path: spatial curve of motion (shape through space); time-independent; geometry only; trajectory: path + timing; position as function of time; includes velocity at each point; two objects can follow same path at different speeds (same path, different trajectories)
DI15|Origin|Destination|origin: starting point; source; the "from"; past-associated; what is left behind; destination: ending point; target; the "to"; future-associated; what is approached; journey defined by the pair; without either, motion is wandering not traveling; origin and destination may be the same (round trip) but the traveler is changed

# relationships(from|rel|to)
# Foundational
CO1|requires|CO12
CO2|changes|CO1
CO3|absence_of|CO2
CO4|orders|CO19,TP1,TP2,TP3
CO5|snapshot_at|CO4
CO6|connects|CO5
CO7|characterizes|CO2,CO15
CO8|precedes|CO6
CO9|traced_by|CO2
CO10|measures|CO2
CO11|changes|CO10
CO12|defines|CO1,CO2,CO3
CO13|begins|CO9
CO14|ends|CO9
CO15|connects|CO13,CO14
CO16|measures|CO9
CO17|measures|CO6
CO22|resists|CO6
CO23|product_of|CO2

# Spatial motion types
SM1|type_of|CO2
SM2|type_of|CO2
SM3|combines|SM1,SM2
SM4|oscillates_about|CO3
SM5|requires|CN8,AG1
SM6|converts|SM1,SM2
SM7|follows|CN3
SM8|caused_by|CN3
SM9|caused_by|SM11
SM10|transports|CO10
SM11|driven_by|SM9
SM12|driven_by|SM10
SM13|type_of|CO15
SM14|specializes|SM5
SM15|specializes|SM5

# Temporal position
TP1|precedes|TP2
TP2|precedes|TP3
TP4|relates|TP1,TP2
TP5|relates|TP2,TP3
TP6|overlaps|TP4,TP5
TP7|concurrent_with|TP6
TP8|completed_before|TP2
TP9|pending_after|TP2
TP10|ended_before|TP2
TP11|extends_beyond|TP3
TP12|bounded_within|TP4,TP5

# Direction
DR1|opposes|DR2
DR3|opposes|DR4
DR5|perpendicular_to|DR1,DR2
DR6|opposes|DR7
DR8|opposes|DR9
DR10|type_of|SM2
DR11|parallel_to|CO9
DR12|perpendicular_to|CO9
DR13|passes_through|CN5
DR14|encircles|CO1

# State relationships
SA1|precedes|SA2
SA2|may_become|SA1,SA3,SA4,SA5,SA7,SA8
SA3|follows|SA7
SA4|toward|SA1
SA5|disrupts|SA2,SA7
SA6|stationary_during|CO6
SA7|between|SA1,SA3
SA8|terminates|SA1,SA2,SA3,SA4,SA5,SA6,SA7
SA9|pauses|SA2,SA6
SA10|combines|SA2,SM3
SA11|increases|CO10
SA12|decreases|CO10
SA13|maintains|CO1

# Transition
TR1|initiates|SA2
TR2|terminates|SA2
TR3|transitions|SA1,SA11
TR4|transitions|SA2,SA12
TR5|reverses|DR1,DR2
TR6|requires|CO21
TR7|crosses|CO21
TR8|avoids|CO21
TR9|crosses|CO21
TR10|creates|DR5
TR11|reduces|CO16
TR12|increases|CO16
TR13|alternates|SA1,SA2

# Causality
CU1|subtype_of|CO8
CU2|subtype_of|CO8
CU3|combines|CU1,CU2
CU4|specializes|CO8
CU5|specializes|CO8
CU6|weakens|CO8
CU7|tests|CO8
CU8|chains|CO8
CU9|loops|CO8
CU10|overloads|CO8
CU11|goal_driven|CO8
CU12|probabilistic|CO8

# Causality → transition
CU1|required_for|TR7
CU2|guarantees|TR7
CU4|triggers|TR9
CU5|underlies|CU8
CU8|composed_of|CU4

# Reference frames
RF1|centered_on|AG1
RF2|independent_of|RF1
RF3|relative_to|CO1
RF4|orders|TP1,TP2,TP3
RF5|simplifies|CO2
RF6|complicates|CO2
RF7|relates|RF5,RF6

# Path
PA1|simplest|CO9
PA2|generalizes|PA1
PA3|specializes|PA2
PA4|combines|SM2,DR6
PA5|models|SM9
PA6|alternates|DR5
PA7|specializes|PA2
PA8|minimizes|CO16
PA9|returns_to|CO13

# Velocity
VE1|instance_of|SA1
VE2|instance_of|SA2
VE3|generalizes|VE2
VE4|equilibrium_of|CN2,CN3
VE5|escapes|CN3

# Oscillation
OS1|ideal_of|SM4
OS2|realistic_of|SM4
OS3|driven|SM4
OS4|superposition_of|SM10

# Navigation → reference
NV1|uses|RF1
NV2|uses|RF2
NV3|uses|RF3
NV4|uses|RF5
NV5|provides|CO1
NV6|provides|CO7

# Agency
AG1|initiates|TR1,SA2
AG2|excludes|AG1
AG3|constrains|AG1
AG4|constrains|AG1,CO9
AG5|augments|AG1
AG6|opposes|AG1

# Constraints
CN1|opposes|SM1,SM2
CN2|opposes|SM5
CN3|constrains|DR3,DR4
CN4|resists|TR3,TR4,TR5
CN5|blocks|DR13
CN6|limits|CO9
CN7|constrains|CO17,TR1,TR2
CN8|limits|CO16,CO17

# Failure → cause
FM1|caused_by|NV1,NV3
FM2|caused_by|PA2,VE3
FM3|violates|CO21
FM4|blocked_by|CN5,CN8
FM5|confuses|CU6,CU12
FM6|results_from|CN8
FM7|misapplies|CO7,DR1
FM8|trapped_by|PA10
FM9|exceeds|CN4,CN6
FM10|caused_by|OS3

# Distinction mappings
DI1|distinguishes|CO1,CO10
DI2|distinguishes|CO16,CO10
DI3|distinguishes|CO16,CO15
DI4|distinguishes|CO2,CO6
DI5|distinguishes|CO8,CU12
DI6|distinguishes|CO5,CO6
DI7|distinguishes|TR8,TR9
DI8|distinguishes|PA9,PA10
DI9|distinguishes|RF5,CO1
DI10|distinguishes|SM1,SM2
DI11|distinguishes|AG1,AG2
DI12|distinguishes|SM4,SM7
DI13|distinguishes|RF1,RF2
DI14|distinguishes|CO9,VE3
DI15|distinguishes|CO13,CO14

# decode_legend
# id_prefixes: CO=concept, SM=spatial_motion, TP=temporal_position, DR=direction, SA=state, TR=transition, CU=causality, RF=reference_frame, PA=path, VE=velocity, OS=oscillation, NV=navigation, AG=agency, CN=constraint, FM=failure_mode, DI=distinction
# rel_types: requires|changes|absence_of|orders|snapshot_at|connects|characterizes|precedes|traced_by|measures|defines|begins|ends|resists|product_of|type_of|combines|oscillates_about|follows|caused_by|driven_by|transports|specializes|relates|overlaps|concurrent_with|completed_before|pending_after|ended_before|extends_beyond|bounded_within|opposes|perpendicular_to|passes_through|encircles|parallel_to|may_become|toward|disrupts|stationary_during|between|terminates|pauses|maintains|increases|decreases|initiates|transitions|reverses|crosses|avoids|creates|reduces|alternates|subtype_of|weakens|tests|chains|loops|overloads|goal_driven|probabilistic|required_for|guarantees|triggers|underlies|composed_of|centered_on|independent_of|relative_to|simplifies|complicates|simplest|generalizes|minimizes|returns_to|instance_of|equilibrium_of|escapes|ideal_of|realistic_of|driven|superposition_of|uses|provides|excludes|constrains|augments|blocks|limits|violates|blocked_by|confuses|results_from|misapplies|trapped_by|exceeds|distinguishes
# state_model: states (SA*) connected by transitions (TR*); entity occupies one primary state at a time; transitions require causes and may be constrained; state diagram is directed graph
# direction_model: directions defined relative to reference frame (RF*); egocentric directions (forward/back/left/right) rotate with entity; allocentric (north/south/up/down) are frame-fixed
# confidence: synthetic domain knowledge — not extracted from a single source document

# relation_mapping(doc_rel|canonical_rel|notes)
requires|requires|exact match
changes|transforms_to|X changes Y = X transforms Y's state
absence_of|complement_of|rest is absence of motion = complement; symmetric
orders|organizes|time orders sequence = organizes into structure
snapshot_at|instance_of|state snapshot at time = instance_of that time
connects|connects_to|exact match; symmetric
characterizes|composed_of|direction characterizes motion = motion composed_of direction property
precedes|precedes|exact match
traced_by|produces|motion traced by path = motion produces path
measures|inspects|velocity measures motion = inspects quantity
defines|determines|frame defines position = frame determines position; mapped via determined_by inverse
begins|source_of|origin begins path = origin is source_of path
ends|destination_of|destination ends path = destination_of path
resists|opposes|inertia resists transition = opposes
product_of|result_of|momentum is product of motion = result_of
type_of|specializes|translation is type of motion = specializes
combines|synthesizes|revolution combines translation and rotation = synthesizes
oscillates_about|alternative_to|oscillation alternates about rest = alternative_to; symmetric
follows|follows|exact match
caused_by|result_of|free fall caused by gravity = result_of gravity
driven_by|depends_on|convection driven by density = depends_on
transports|flows_to|wave transports energy = flows_to
specializes|specializes|exact match
relates|connects_to|temporal priority relates past and present = connects_to; symmetric
overlaps|parallel_to|temporal overlap = parallel_to; symmetric
concurrent_with|parallel_to|meanwhile concurrent with overlap = parallel_to; symmetric
completed_before|precedes|already completed before present = precedes
pending_after|follows|not yet pending after present = follows
ended_before|precedes|no longer ended before present = precedes
extends_beyond|spans|permanent extends beyond future = spans
bounded_within|scoped_to|temporary bounded within interval = scoped_to
opposes|opposes|exact match; symmetric
perpendicular_to|contrasts|lateral perpendicular to forward = contrasts; symmetric
passes_through|traverses|through direction passes through barrier = traverses
encircles|frames|around direction encircles position = frames
parallel_to|parallel_to|exact match; symmetric
may_become|evolves_to|in motion may become at rest = evolves_to
toward|flows_to|returning toward origin = flows_to directionally
disrupts|disrupts|lost disrupts motion = disrupts
stationary_during|scoped_to|changing in place stationary during transition = scoped_to
between|connects_to|in transit between states = connects_to
terminates|removes|dissolved terminates prior states = removes
pauses|maintains|suspended pauses motion = maintains state temporarily
maintains|maintains|hovering maintains position = maintains
increases|amplifies|accelerating increases velocity = amplifies
decreases|degrades|decelerating decreases velocity = degrades
initiates|enables|departure initiates motion = enables
transitions|transforms_to|acceleration transitions rest to motion = transforms_to
reverses|reverses|exact match
crosses|overcomes|threshold crossing overcomes barrier = overcomes
avoids|prevents|gradual change avoids threshold = prevents
creates|produces|bifurcation creates branching = produces
reduces|simplifies|convergence reduces distance = simplifies
alternates|alternative_to|oscillatory transition alternates states = alternative_to; symmetric
subtype_of|specializes|necessary cause subtype of cause = specializes
weakens|degrades|contributory cause weakens certainty = degrades
tests|validates|counterfactual tests causation = validates
chains|composed_of|causal chain composed of links = composed_of
loops|connects_to|mutual causation loops = connects_to; symmetric
overloads|amplifies|overdetermination overloads causation = amplifies
goal_driven|motivates|teleological cause is goal driven = motivates
probabilistic|approximates|stochastic causation is probabilistic = approximates; symmetric
required_for|requires|inverse; A required for B = B requires A
guarantees|enables|sufficient cause guarantees effect = enables
triggers|activates|proximate cause triggers sudden change = activates
underlies|foundation_for|distal cause underlies chain = foundation_for
composed_of|composed_of|exact match
centered_on|scoped_to|egocentric frame centered on agent = scoped_to
independent_of|isolates|allocentric frame independent of egocentric = isolates
relative_to|references|object-centered frame relative to position = references
simplifies|simplifies|inertial frame simplifies motion = simplifies
complicates|constrains|non-inertial frame complicates motion = constrains
simplest|specializes|straight line is simplest path = specializes
generalizes|generalizes|exact match
minimizes|simplifies|geodesic minimizes distance = simplifies
returns_to|connects_to|closed path returns to origin = connects_to
instance_of|instance_of|exact match
equilibrium_of|complement_of|terminal velocity is equilibrium of drag and gravity = complement; symmetric
escapes|overcomes|escape velocity overcomes gravity = overcomes
ideal_of|models|SHM is ideal of oscillation = models
realistic_of|specializes|damped oscillation is realistic of oscillation = specializes
driven|input_to|forced oscillation is driven by external input = input_to
superposition_of|composed_of|standing wave is superposition of traveling waves = composed_of
uses|requires|dead reckoning uses egocentric frame = requires
provides|produces|GPS provides position = produces
excludes|prevents|involuntary excludes voluntary = prevents
constrains|constrains|exact match
augments|extends|assisted motion augments voluntary = extends
blocks|prevents|barrier blocks passage = prevents
limits|constrains|boundary limits path = constrains
violates|violates|premature transition violates threshold = violates
confuses|contradicts|correlation confusion contradicts proper causation = contradicts
results_from|result_of|state decay results from energy constraint = result_of
misapplies|violates|wrong direction misapplies direction = violates
exceeds|overcomes|exceeding safe speed overcomes constraint = overcomes
distinguishes|distinguishes|exact match
blocked_by|prevents|inverse; failed transition blocked_by barrier = barrier prevents transition
trapped_by|constrains|inverse; lock-in trapped_by path = path constrains entity
