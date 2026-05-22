# CONNECTIONS — TAXONOMY OF RELATEDNESS — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: concepts → spatial → temporal → structural → causal → informational → social → functional → logical → identity → network → channel → protocol → failure_modes → distinctions → relationships → decode_legend

# concepts(id|name|definition|category)
CO1|Connection|relationship between two or more entities enabling transfer of matter, energy, information, force, influence, or reference|foundation
CO2|Node|entity participating in a connection; endpoint; vertex; agent; object; location|foundation
CO3|Edge|the connection itself; link between nodes; carries type, direction, weight, capacity|foundation
CO4|Direction|whether connection flows one way (directed) or both ways (undirected/bidirectional)|property
CO5|Strength|magnitude of connection; bond strength, bandwidth, social tie strength, coupling tightness|property
CO6|Persistence|duration of connection; permanent (bone joint), transient (handshake), intermittent (radio)|property
CO7|Latency|delay between cause at one end and effect at other; zero (rigid rod), finite (electrical signal), variable (postal mail)|property
CO8|Capacity|maximum throughput of connection; bandwidth, load-bearing, flow rate, attention span|property
CO9|Impedance|resistance to flow through connection; friction, electrical resistance, bureaucratic friction, social distance|property
CO10|Coupling|degree to which change in one node propagates to another; tight coupling = strong propagation; loose coupling = buffered/dampened|property
CO11|Interface|boundary where two systems connect; defines protocol, format, physical fit; API, socket, flange, handshake|property
CO12|Multiplexing|multiple connections sharing single channel; time-division, frequency-division, spatial; phone line, highway lanes, attention|property
CO13|Addressing|scheme for identifying and locating specific nodes; phone number, IP address, postal address, name, GPS coordinate, index|property
CO14|Topology|pattern of connections among nodes; star, ring, mesh, tree, bus, hub-and-spoke, small-world|property
CO15|Transitivity|if A connected to B and B connected to C, is A connected to C? transitive: ancestry; non-transitive: friendship; semi-transitive: introduction|property
CO16|Symmetry|if A connected to B, is B connected to A? symmetric: adjacency; asymmetric: parent-child; anti-symmetric: strict ordering|property
CO17|Reflexivity|can a node connect to itself? reflexive: equality; irreflexive: strict less-than; self-loop in graph|property
CO18|Composability|connections combined to form paths, chains, circuits, networks; serial (chain), parallel (redundant), hybrid|property
CO19|Mediation|connection requiring intermediate node; indirect; broker, relay, proxy, translator, bridge|property
CO20|Resonance|amplification when connection properties match natural frequency of system; electrical resonance, social echo chambers, structural vibration|property
CO21|Bandwidth|information capacity per unit time; bits/second, conversations/hour, throughput|property
CO22|Attenuation|loss of signal or strength over distance or time; signal degrades, relationships weaken, force diminishes|property
CO23|Noise|unwanted interference degrading connection quality; electromagnetic, miscommunication, data corruption|property

# spatial(id|name|definition|properties|examples)
SP1|Contact (Touching)|physical surfaces in direct contact; matter-to-matter adjacency; zero separation|force transfer (normal, friction, adhesion); thermal conduction; electrical conduction if conductive; no gap|hand on table; brick on brick; gear teeth meshing; skin contact
SP2|Adjacency|positioned next to without necessarily touching; neighboring; sharing boundary or proximity threshold|defined by proximity metric; may enable connection types (visual, acoustic); topology concept|neighboring rooms; adjacent cells in grid; bordering countries; pixels
SP3|Containment (Inside/Outside)|one entity spatially enclosed within another; topological relationship|container constrains contained; shared atmosphere/environment; nested containment possible|organ in body; file in folder; person in room; water in pipe; component on circuit board
SP4|Above/Below (Vertical)|relative position along gravity vector; implies gravitational relationship; load-bearing if structural|gravity creates directional force; above exerts load on below; fluid flows down; heat rises|floor above basement; shelf above desk; atmosphere above surface; sediment layers
SP5|In Front / Behind|relative position along viewing or movement axis; facing; obstructing or leading|occlusion (blocking view or path); queue ordering; leading/following; windward/leeward|person in front in line; shield in front of body; car ahead on road
SP6|Left/Right (Lateral)|relative position perpendicular to facing direction; handedness; bilateral symmetry|mirror relationships; chirality; cultural conventions (driving side); relative to observer|left hand; port/starboard; stage left/right; political spectrum metaphor
SP7|Surrounding (Encirclement)|entity positioned on all sides of another; enveloping; perimeter contact or proximity|containment variant; restricts movement; environmental influence from all directions; protection or siege|castle moat; atmosphere surrounding earth; crowd around performer; insulation around pipe
SP8|Parallel|entities extending in same direction without intersecting; maintaining constant separation|no intersection; same orientation; can be connected by perpendicular bridges; analogous processes running simultaneously|parallel wires; parallel roads; parallel processing; parallel narrative lines
SP9|Perpendicular (Orthogonal)|entities meeting at right angle; cross-connection; independence of axes|maximal differentiation of direction; structural rigidity when combined (cross-bracing); independent dimensions|wall meeting floor; crossroads; coordinate axes; orthogonal basis vectors
SP10|Concentric|entities sharing same center but at different radii; nested rings, spheres, cylinders|hierarchical distance from center; layers; protection increases inward; access decreases inward|tree rings; onion layers; orbital shells; city zones (urban core to suburbs); defense perimeters
SP11|Tangent|entities touching at exactly one point; glancing contact; near-miss connection|minimal contact; transition between connected and separated; instantaneous connection|ball resting on flat surface at one point; tangent line to circle; orbits at closest approach
SP12|Colinear|entities lying on same line; aligned; serial arrangement|ordering along single dimension; sequence; pipeline; chain|beads on string; cars on road; vertebrae in spine; stations on rail line
SP13|Interleaved|entities alternating in arrangement; woven; interspersed|mutual support; difficult to separate; increased surface contact; mixing|woven fibers; interleaved memory; shuffled cards; brick bond pattern; dovetail joint
SP14|Nested|entity contained within another which is contained within another; recursive containment; hierarchy|depth = distance from outermost; Russian dolls; scope chains; organizational hierarchy mapped spatially|folders within folders; cells within organs within organisms; parentheses in expression
SP15|Bridging|connection spanning a gap, obstacle, or boundary between two otherwise separated regions|enables flow across barrier; bottleneck potential; structural vulnerability; strategic importance|physical bridge; neural synapse; social bridge (weak tie connecting groups); network bridge between LANs
SP16|Offset|entities displaced from alignment by fixed distance; shifted; staggered|partial overlap; pattern creation; phased arrangement|brick courses (half-brick offset); staggered seating; phase offset in signals; timezone offset
SP17|Proximity (Near/Far)|relative distance between entities; continuous measure; near enables connection, far weakens|inversely affects many connection types (gravity, social, signal strength); proximity threshold determines adjacency|neighbors; nearby Wi-Fi; gravitational attraction; Tobler's first law of geography

# temporal(id|name|definition|properties|examples)
TM1|Sequence (Before/After)|temporal ordering; one event precedes another; linear time relationship|irreversible in physical time; causal potential (before can cause after, not reverse); ordering enables scheduling|steps in recipe; historical chronology; program instruction sequence; assembly line stages
TM2|Simultaneity (Concurrent)|events occurring at same time; co-temporal; synchronized|enables interaction; requires coordination; race conditions possible in computing; coincidence vs causation|simultaneous conversations; parallel processes; synchronized swimming; concurrent database access
TM3|Periodicity (Recurring)|connection re-established at regular intervals; cyclic; rhythmic|frequency and phase define pattern; entrainment possible (systems synchronize); resonance when frequencies match|heartbeat; seasons; bus schedule; pay cycle; circadian rhythm; sinusoidal signal
TM4|Duration|length of time connection persists; instantaneous (collision), brief (conversation), long (marriage), permanent (geological stratum)|longer duration = more transfer possible; fatigue in materials; relationship deepening in social; connection cost proportional|phone call duration; employment period; chemical bond lifetime; TCP session
TM5|Precedence (Dependency)|one event must complete before another can begin; blocking; prerequisite|creates critical path; bottleneck potential; serializes execution; ordering constraint|task dependency in project; prerequisite course; compilation before linking; drying before painting
TM6|Overlap (Partial Simultaneity)|events share some but not all temporal extent; partially concurrent|transition period; handoff; gradual replacement; double-coverage|overlapping shifts; software version overlap during migration; overlapping generations; twilight (day and night overlap)
TM7|Synchronization|aligning temporal behavior of two or more entities; clock sync, phase lock, coordination|enables cooperation; requires shared reference (clock, signal, conductor); sync loss → failure|database replication; orchestra conductor; traffic light coordination; NTP clock synchronization
TM8|Causation (Temporal)|event A precedes and produces event B; necessary temporal ordering for causal connection|requires A before B; but precedence alone insufficient (correlation ≠ causation); mechanism required|striking match → flame; request → response; stimulus → response; infection → disease
TM9|Lag (Delayed Connection)|effect occurs after delay following cause; latent period; response time|delay may be fixed or variable; buffering introduces lag; prediction compensates for lag|drug effect onset; network latency; gestation period; light travel time; economic policy lag
TM10|Anticipation (Pre-connection)|preparing for future connection before it occurs; prediction-based alignment|reduces latency when connection occurs; pre-caching, pre-positioning, social introduction|cache prefetch; diplomatic advance team; appetizer before meal; warm-up before exercise; TCP connection setup
TM11|Expiry|connection terminates after fixed time or condition; timeout; deadline; shelf life|prevents stale connections; resource recovery; forces renewal|session timeout; certificate expiry; food expiration; statute of limitations; lease term
TM12|Inheritance (Temporal)|connection persists from past entity to present entity; legacy; succession; provenance|historical continuity; accumulated properties; tradition; technical debt|inheritance in law; cultural traditions; code legacy; geological strata; genetic inheritance

# structural(id|name|definition|properties|examples)
ST1|Physical Bond (Chemical)|atoms sharing or exchanging electrons; covalent, ionic, metallic, hydrogen, van der Waals|strength varies (covalent > ionic > hydrogen > van der Waals); determines material properties; energy required to break|molecular bonds; crystal lattice; protein folding; DNA base pairs; polymer chains
ST2|Mechanical Fastening|physical connection via interlocking, friction, or inserted connector|removable (bolt, clip) or permanent (rivet, weld); load-bearing; alignment maintained|nail; screw; bolt/nut; rivet; weld; solder; crimp; press-fit; snap-fit; mortise-and-tenon; dovetail
ST3|Joint (Anatomical)|connection between bones; permits controlled movement; synovial, cartilaginous, fibrous|degrees of freedom vary (ball-and-socket: 3; hinge: 1; pivot: 1; fixed: 0); stability vs mobility trade-off|knee (hinge); shoulder (ball-and-socket); skull sutures (fixed); vertebral discs (cartilaginous)
ST4|Coupling (Mechanical)|device connecting two shafts or components allowing torque/motion transfer|rigid (flange) or flexible (rubber, universal joint); compensates for misalignment; disconnectable|shaft coupler; universal joint; clutch; chain drive; belt drive; gear mesh
ST5|Pipe/Conduit|hollow channel directing flow of fluid, gas, or cable|cross-section determines flow capacity; pressure rating; material compatibility; routing|water pipe; air duct; cable conduit; blood vessel; nerve sheath; fiber optic cable
ST6|Wire/Cable|flexible linear conductor of electricity, signal, or force|gauge determines current capacity; insulation type; shielding for signal; tensile strength for mechanical|electrical wire; Ethernet cable; steel cable; fiber optic; guy wire; bowstring
ST7|Hinge|pivot connection allowing rotation about single axis; one degree of freedom|constrains movement to rotation; axis position fixed; range of motion limited by stops|door hinge; jaw (temporomandibular); laptop screen; folding knife; gate
ST8|Adhesive Bond|connection via intermediate material that bonds to both surfaces|bond strength depends on surface preparation, adhesive type, cure time; gap-filling; distributed stress|glue (wood, metal, plastic); tape; mortar (partially); sealant; biological adhesion (gecko foot, mussel)
ST9|Woven/Braided|elements interlaced in crossing pattern; mutual constraint through geometry|strength from friction and geometry, not adhesive; flexible yet strong; failure = progressive unraveling|cloth; rope; basket; wire braid (shielding); carbon fiber weave; hair braid
ST10|Magnetic|connection via magnetic field; attractive or repulsive; non-contact force|acts through air/vacuum; alignment-dependent (poles); field strength decreases with distance³|magnet to refrigerator; electromagnetic relay; magnetic lock; MRI; compass; magnetic coupling (fluid pumps)
ST11|Gravitational|connection via mass-mass attraction; universal; weakest fundamental force|always attractive; proportional to masses, inverse square of distance; governs orbital mechanics|apple to earth; moon to earth (tides); solar system; galaxy structure; weight on surface
ST12|Elastic Band/Spring|energy-storing connection; deforms under load, returns to original shape|stores potential energy; restoring force proportional to displacement (Hooke's law); damping dissipates energy|rubber band; coil spring; leaf spring; bungee cord; trampoline; tendon
ST13|Rope/Chain/Cable|flexible linear connection under tension; cannot push, only pull|transmits force along length; can change direction via pulleys/sheaves; knots as connection within connection|anchor chain; climbing rope; suspension bridge cable; tow rope; measuring chain; pull cord
ST14|Scaffold/Framework|temporary or permanent structure providing spatial organization and support for other elements|defines positions; maintains spacing; removed after purpose served (scaffold) or permanent (skeleton)|construction scaffold; software framework; cytoskeleton; skeleton; crystalline lattice; organizational structure
ST15|Socket/Plug (Physical)|male-female interlocking connection; designed for repeated connection/disconnection|keyed (prevents incorrect orientation); rated for specific load/current/pressure; standardized interfaces|electrical outlet; USB port; pipe fitting; ball-and-socket joint; expansion slot; trailer hitch
ST16|Membrane|semi-permeable barrier connecting two regions by selective passage|controls what passes between regions; concentration gradient drives diffusion; active transport requires energy|cell membrane; blood-brain barrier; Gore-Tex fabric; dialysis membrane; firewall (conceptual analog)

# causal(id|name|definition|properties|examples)
CA1|Direct Cause|A produces B without intermediary; immediate mechanism connects them|necessary and/or sufficient relationship; temporal precedence; mechanism identifiable|spark ignites fuel; hammer strikes nail; switch closes circuit; keystroke produces character
CA2|Indirect Cause (Chain)|A causes B which causes C; causal chain; transitive causation|length of chain attenuates certainty; multiple points of intervention; butterfly effect potential|drought → crop failure → famine; code change → bug → system crash; deforestation → erosion → flooding
CA3|Contributing Cause|A increases probability of B but does not guarantee it; risk factor; predisposing condition|multiple contributing causes may combine; INUS condition (insufficient but necessary part of unnecessary but sufficient condition)|smoking → cancer (contributing, not guaranteed); poverty → crime (contributing); fatigue → accident
CA4|Trigger (Proximate Cause)|final event initiating a process already primed; the spark; immediate precipitant|distinguishes from background conditions; often confused with root cause; temporally closest to effect|assassination triggering war (Archduke Franz Ferdinand); last straw; catalyst in chemistry; event handler firing
CA5|Enabling Condition|A makes B possible but does not cause B; necessary background; prerequisite|removal prevents effect; presence does not guarantee effect; often invisible until absent|oxygen enabling fire (but not causing it); infrastructure enabling commerce; literacy enabling reading
CA6|Inhibiting Condition|A prevents or reduces B; suppression; blocking; damping|removal may enable effect; dose-dependent; can be overcome if cause strong enough|firewall preventing intrusion; antibiotic suppressing infection; regulation preventing pollution; friction preventing sliding
CA7|Feedback (Positive)|effect amplifies its own cause; reinforcing loop; exponential growth; runaway|destabilizing; requires limiting factor or system saturates; snowball effect|microphone feedback; compound interest; population growth; social media virality; nuclear chain reaction
CA8|Feedback (Negative)|effect reduces its own cause; balancing loop; homeostasis; self-regulation|stabilizing; drives toward equilibrium; thermostat model; essential for sustainability|thermostat; predator-prey balance; market price equilibrium; blood sugar regulation; governor on engine
CA9|Correlation (Non-Causal)|A and B co-occur but neither causes the other; shared cause, coincidence, or confound|statistical relationship without mechanism; spurious if confounded; establishing causation requires intervention or controlled study|ice cream sales and drowning (shared cause: summer); shoe size and reading ability (shared cause: age)
CA10|Mutual Causation|A causes B and B causes A simultaneously or in rapid alternation; co-evolution; symbiosis|difficult to identify "first cause"; stable or unstable equilibrium depending on feedback sign|arms race; language and thought (Sapir-Whorf); supply and demand; predator-prey co-evolution
CA11|Emergence|macro-level pattern arising from micro-level connections without central direction|not reducible to individual connections; novel properties at higher level; unpredictable from components alone|consciousness from neurons; traffic jams from individual drivers; market price from individual trades; flocking behavior

# informational(id|name|definition|properties|examples)
IN1|Reference (Pointer)|one entity contains address or identifier of another; indirection; lookup|dereference to access target; may dangle (target removed); level of indirection; symbolic|pointer in C; URL; phone number; index entry; foreign key in database; footnote; cross-reference
IN2|Index (Lookup Table)|mapping from key to location or value; enables O(1) or O(log n) access|trades space for time; must be maintained as data changes; primary key uniqueness|book index; database index; hash table; DNS; phone book; array index; registry
IN3|Label (Tag)|identifier attached to entity for classification, retrieval, or description|many-to-many: entity has multiple labels, label applies to multiple entities; namespace prevents collision|file name; product barcode; HTML tag; hashtag; gene name; chemical formula; postal code
IN4|Hyperlink|reference from one document/location to another; clickable; web-native|directed (source → target); target may not link back; broken links possible; anchor text provides context|web hyperlink; wiki link; email link; app deep link; cross-reference; See Also
IN5|Foreign Key|field in one table referencing primary key in another; relational database connection|enforces referential integrity; enables joins; cardinality (1:1, 1:N, N:M with junction table); cascading delete/update|customer_id in orders table; parent_id in employee table; author_id in book table
IN6|Symbolic Reference|connection via shared symbol or convention; requires shared vocabulary/encoding|indirect; requires interpretation; cultural dependency; ambiguity possible|word referring to concept; variable name referring to value; musical notation; traffic sign; emoji; brand logo
IN7|Signal|information-carrying change propagated through medium; modulated carrier|analog or digital; bandwidth limited; attenuated by distance; noise degrades; encoding determines capacity|radio wave; nerve impulse; smoke signal; semaphore; voltage change; hormone; pheromone
IN8|Message|discrete unit of information sent from sender to receiver via channel|has content (payload), sender, receiver, format (protocol); may be lost, delayed, duplicated, corrupted|email; letter; text message; HTTP request; packet; telegram; whisper
IN9|Broadcast|one sender to all receivers in range; no specific target|efficient for one-to-many; no confirmation of receipt; privacy implications; flooding|radio broadcast; ARP request; UDP broadcast; public announcement; social media post; town crier
IN10|Multicast|one sender to specific group of receivers|targeted subset; group management required; more efficient than multiple unicast|IP multicast; mailing list; group chat; pub-sub topic; conference call
IN11|Unicast|one sender to one specific receiver|point-to-point; confirmation possible; private; requires addressing|phone call; TCP connection; direct message; personal letter; HTTP/HTTPS request
IN12|Handshake|bidirectional establishment of connection parameters before data transfer|synchronizes state; negotiates capabilities; establishes trust; overhead before communication|TCP three-way handshake; TLS negotiation; diplomatic credentials; social introduction; API authentication
IN13|Subscription|receiver registers interest; sender pushes updates when available; pub-sub pattern|decouples sender from receiver; receiver controls what they receive; sender doesn't need to know receivers|RSS feed; newsletter; event listener; message queue subscription; streaming service; newspaper subscription
IN14|Query-Response|requester asks, responder answers; pull model; synchronous or asynchronous|requester drives timing; responder must be available; request-response pair linked|database query; HTTP GET; question and answer; API call; DNS lookup; search engine query
IN15|Cache|stored copy of connection result; avoids re-traversing connection|freshness problem (stale data); invalidation complexity; speed vs accuracy trade-off|browser cache; CPU cache; CDN; memoization; DNS cache; memory cache
IN16|Queue|ordered buffer between producer and consumer; temporal decoupling|FIFO typically; handles rate mismatch; overflow if producer > consumer; backpressure mechanism|message queue; print queue; call waiting; email inbox; task queue; buffer in streaming
IN17|Encoding|representation scheme for information in a connection; maps meaning to physical/symbolic form|sender encodes, receiver decodes; shared codec required; lossy vs lossless; compression possible|ASCII; UTF-8; Morse code; DNA codons; binary encoding; analog-to-digital conversion; language itself
IN18|Checksum/Hash|derived value verifying connection integrity; detects corruption or modification|computed from content; any change in content changes hash; collision possible but rare for good hash|MD5; SHA-256; CRC; parity bit; TCP checksum; digital signature; blockchain hash chain

# social(id|name|definition|properties|examples)
SO1|Kinship|connection by blood (consanguinity) or marriage (affinity); biological and legal|degrees (parent, sibling, cousin); creates obligations; inheritable property; culturally defined boundaries|parent-child; sibling; spouse; cousin; in-law; clan; lineage; extended family
SO2|Friendship|voluntary reciprocal social bond; mutual affection and trust|varying strength (close, casual, acquaintance); requires maintenance; reciprocity expectation; may decay without contact|childhood friends; colleagues who become friends; pen pals; online friends
SO3|Professional/Collegial|connection through shared work context; role-defined; institutional|defined by organizational structure; may outlast specific role; networked through industry; asymmetric (boss-subordinate)|manager-report; team member; business partner; professional association; mentor-mentee; committee membership
SO4|Mentorship|experienced person guides less experienced; knowledge and wisdom transfer|asymmetric initially; may evolve toward peer; specific domain; trust-based; long-term investment|master-apprentice; academic advisor; career mentor; coaching relationship; elder teaching youth
SO5|Authority (Hierarchical)|one entity has power or control over another; command structure; governance|asymmetric; positional (can change); scope-limited; legitimacy varies (consent, coercion, tradition)|military chain of command; corporate hierarchy; parent-child authority; government-citizen; religious hierarchy
SO6|Rivalry/Competition|entities contesting same resource, position, or goal|may be cooperative (drives improvement) or destructive; rules-bounded or unbounded; energizing or exhausting|business competitors; sports opponents; sibling rivalry; academic competition; evolutionary arms race
SO7|Alliance/Coalition|entities combining resources for mutual benefit against common challenge|voluntary; may be temporary (alliance of convenience) or permanent (federation); requires trust and coordination|military alliance (NATO); business partnership; political coalition; trade union; mutual aid society
SO8|Weak Tie (Granovetter)|acquaintance-level social connection; bridge between densely connected groups|low emotional intensity; infrequent contact; provides novel information; bridges structural holes; job-finding power|friend-of-friend; conference acquaintance; online follower; former colleague; distant relative
SO9|Strong Tie|close relationship with high emotional intensity, frequent contact, reciprocity|provides emotional support; redundant information (same social circle); bonding capital; durable|close friends; immediate family; romantic partner; long-term collaborator
SO10|Trust|confidence that connected entity will act reliably, honestly, and benevolently|built gradually, destroyed quickly; enables cooperation without verification; reduces transaction costs; contextual|personal trust; institutional trust; brand trust; trust in infrastructure; contractual trust; cryptographic trust
SO11|Obligation|connection creating duty or expectation of action; social, legal, moral|may be reciprocal (gift exchange) or unilateral (debt); violation has consequences; formalized in contracts|debt; promise; contractual obligation; social norm reciprocity; filial duty; warranty; treaty commitment
SO12|Representation|one entity acts on behalf of another; agency; delegation; proxy|principal-agent relationship; scope of authority; accountability; information asymmetry|attorney for client; diplomat for nation; elected representative; guardian for minor; API proxy; power of attorney
SO13|Membership|entity belongs to group; inclusion in collective; identity connection|confers rights and obligations; identity component; in-group/out-group dynamics; formal or informal|citizen of country; member of club; employee of company; subscriber to service; cell in organism; node in network
SO14|Influence (Social)|ability to affect another's beliefs, decisions, or behavior without direct authority|asymmetric but not necessarily hierarchical; reputation-based; amplified by network position; soft power|opinion leader; celebrity endorsement; peer pressure; propaganda; role model; social media influencer
SO15|Communication|exchange of meaning between entities through shared symbolic system|requires encoding, channel, decoding; bidirectional or unidirectional; fidelity varies; context-dependent|conversation; writing; sign language; body language; art; music; code; API; ritual
SO16|Witness/Attestation|third party observing and confirming connection or event; adds trust/legitimacy|reduces fraud; creates accountability; social proof; legal requirement for some connections|notary; witness to signature; peer review; blockchain validator; wedding witness; audit

# functional(id|name|definition|properties|examples)
FU1|Input/Output|one entity provides input consumed by another; producer-consumer; source-sink|directed; type-matched (output type must match input type); buffered or unbounded; rate matching|function parameter; factory supply chain; data pipeline; food chain; stdin/stdout; sensor → processor
FU2|Control (Command)|one entity directs behavior of another; asymmetric; imperative|controller determines state/action of controlled; feedback may close loop; latency matters; authority required|thermostat → furnace; driver → vehicle; manager → employee; program → hardware; remote control
FU3|Dependency|one entity requires another to function; cannot operate without|directed acyclic (ideally); creates fragility (single point of failure); version constraints; diamond dependency problem|software library dependency; organ on blood supply; business on raw material; child on parent; import dependency
FU4|Composition|one entity made from others; parts form whole; assembly|hierarchical; part can exist independently (aggregation) or not (composition); emergent properties at whole level|car from parts; meal from ingredients; program from modules; molecule from atoms; team from individuals
FU5|Delegation|one entity assigns task to another; maintains responsibility but transfers execution|reduces cognitive/functional load on delegator; requires trust; accountability remains with delegator; may chain|manager delegates to employee; OS delegates to device driver; load balancer delegates to servers; contractor subcontracts
FU6|Abstraction Layer|connection between levels of abstraction; higher layer uses lower layer without knowing internals|hides complexity; enables substitution; interface contract; leaky abstractions expose lower level|OS over hardware; HTTP over TCP; programming language over assembly; UI over business logic; nervous system layers
FU7|Plug-in/Extension|entity extends another's functionality through defined extension point; host + plug-in|host defines interface; plug-in implements interface; hot-swappable (ideally); versioning issues|browser extension; IDE plug-in; VST audio plug-in; Minecraft mod; WordPress plug-in; adapter pattern
FU8|Inheritance (OOP)|child entity acquires properties and behaviors from parent entity; is-a relationship|hierarchical; single or multiple; override and specialization; tight coupling between parent and child; fragile base class problem|class inheritance; biological inheritance; cultural inheritance; legal inheritance; prototype chain
FU9|Interface Implementation|entity promises to provide specific capabilities; contract fulfillment|decouples consumer from provider; multiple implementations possible; compile-time or runtime checking|Java interface; Go interface; API contract; USB standard compliance; building code compliance; trait (Rust)
FU10|Callback|entity provides function to be called by another entity at appropriate time; inversion of control|caller doesn't know callee's logic; event-driven; registration + invocation; temporal decoupling|event handler; webhook; interrupt service routine; promise.then(); observer pattern; signal handler
FU11|Binding (Variable/Name)|name associated with value, object, or location; scope-dependent|early (compile-time) or late (runtime); lexical or dynamic scope; shadowing; lifetime|variable binding in programming; DNS name → IP; symbol table; let/const/var; Prolog variable binding
FU12|Mapping (Function)|input domain connected to output range by deterministic rule; f: A → B|each input has exactly one output (function); injective, surjective, bijective; composable; invertible if bijective|mathematical function; hash function; lookup table; translation table; color map; encoding
FU13|Pipeline|chain of processing stages where output of one is input to next; serial composition|unidirectional flow; each stage transforms; buffering between stages; throughput = slowest stage|Unix pipe; ETL pipeline; assembly line; digestive tract; neural pathway; CI/CD pipeline
FU14|Bus (Shared Medium)|shared connection medium accessible by multiple entities; multiplexed|contention management required (arbitration, CSMA/CD); broadcast by default; bandwidth shared|computer bus (PCIe, USB); electrical bus bar; network bus topology; event bus; message bus; shared highway

# logical(id|name|definition|properties|examples)
LO1|Equivalence|two entities are the same in relevant respect; substitutable; interchangeable|reflexive, symmetric, transitive; defines equivalence classes; identity is strongest equivalence|synonym; isomorphism; congruence; equal sign; aliasing; redirect; currency conversion
LO2|Implication (If-Then)|truth of A guarantees truth of B; A → B; connection of truthfulness|directed; contrapositive equivalent; does not mean B → A; foundation of deductive reasoning|logical implication; legal precedent; axiom → theorem; premise → conclusion; condition → action
LO3|Conjunction (AND)|both connections must hold simultaneously; intersection of conditions|order-independent; strengthens requirements; narrows scope|logical AND; joint requirement; intersection of sets; co-occurrence; compound condition; multi-factor authentication
LO4|Disjunction (OR)|at least one connection must hold; union of alternatives|inclusive OR (either or both) vs exclusive OR (exactly one); widens scope; provides alternatives|logical OR; fallback route; redundant connection; any of multiple credentials; alternative path
LO5|Negation (NOT)|absence of connection; explicit non-relationship; exclusion|asserting disconnection; boundary definition; requires closed-world assumption or explicit statement|not-equal; exclusion list; firewall rule; allergy (cannot consume); incompatibility; divorce
LO6|Classification (Is-A)|entity is member of category; type relationship; taxonomic|transitive (dog is-a mammal is-a animal); enables inheritance of properties; subsumption|Lassie is-a dog; 7 is-a prime; TCP is-a protocol; this email is-a spam
LO7|Instantiation (Instance-Of)|specific entity is particular occurrence of general type; token of type|type has many instances; instance inherits type properties; runtime relationship|this chair is instance of Chair class; this HTTP request is instance of GET; this transaction is instance of purchase
LO8|Part-Whole (Has-A)|entity contains or is composed of parts; mereological|transitive or not (debated); part may exist independently (aggregation) or not (composition); emergent properties|engine is part of car; chapter is part of book; department is part of company; organ is part of body
LO9|Ordering (Comparison)|entities ranked relative to each other along some dimension; total or partial|reflexive, antisymmetric, transitive (for partial order); total order: all pairs comparable; partial: some incomparable|less-than; priority ordering; alphabetical; ranking; version numbering; preference ordering
LO10|Analogy|structural similarity between two domains; A:B :: C:D; mapping of relationships|not identity; highlights shared structure; enables reasoning transfer; may mislead if pushed too far|heart:pump; atom:solar system (limited); electrical circuit:water flow; brain:computer (very limited)
LO11|Contradiction|two connections that cannot both hold; mutual exclusion; inconsistency|presence of both indicates error; resolution required; paradox if unresolvable|alive and dead; true and false; north and south pole of same magnet; contradictory testimony
LO12|Correlation|statistical co-occurrence without established causal mechanism|strength (r value); direction (positive, negative); does not establish causation; confounders|height and weight; education and income; temperature and ice cream sales; exercise and mood

# identity(id|name|definition|properties|examples)
ID1|Identifier (Unique)|string or number uniquely identifying an entity within a namespace|must be unique within scope; may be hierarchical (domain\name); opaque or meaningful; collision = error|Social Security Number; UUID; MAC address; ISBN; database primary key; DNA sequence; fingerprint
ID2|Name|human-readable label for entity; may not be unique; culturally assigned|ambiguous (multiple entities with same name); requires disambiguation context; may change over time|personal name; domain name; file name; brand name; species common name; street name
ID3|Address|identifier specifying location within a space; enables routing|hierarchical (country/city/street/number); spatial or logical; changes when entity moves (unlike identity)|postal address; IP address; memory address; email address; GPS coordinate; URL; phone number
ID4|Alias|alternative name for same entity; secondary identifier; also-known-as|multiple aliases for one entity; alias resolution required; may obscure identity; convenience or deception|pen name; domain alias (CNAME); symbolic link; nickname; stage name; brand sub-brand; shortcut
ID5|Credential|token proving identity or authorization; connects claimer to claimed identity|secret (password), possession (key), biometric (fingerprint); multi-factor combines types; revocable; expirable|password; certificate; API key; badge; passport; private key; biometric scan; ticket
ID6|Fingerprint (Hash)|derived identifier computed from entity content; enables verification without full comparison|deterministic; fixed-length output from variable input; collision-resistant; one-way (cannot reconstruct original)|SHA-256 hash; file checksum; audio fingerprint (Shazam); DNA fingerprint; browser fingerprint
ID7|Token (Bearer)|object whose possession grants access; connection between holder and resource|bearer semantics (anyone with token has access); revocable; scoped; expirable; transferable or not|session token; JWT; physical key; transit pass; bearer bond; access badge; concert ticket

# network(id|name|definition|properties|examples)
NE1|Star Topology|all nodes connect to central hub; no direct node-to-node connection|single point of failure (hub); easy to add/remove nodes; hub handles routing; centralized control|telephone exchange; hub-and-spoke airline; teacher-classroom; mainframe-terminal; wheel-and-spoke organization
NE2|Ring Topology|each node connects to exactly two neighbors forming closed loop; data passes around ring|no central point of failure (unless single ring); deterministic latency; token passing for access control; break in ring = network failure (unless dual ring)|Token Ring network; SONET/SDH; some industrial control; circular assembly line; round-robin scheduling
NE3|Mesh Topology|every node connected to every other (full mesh) or many others (partial mesh)|highly redundant; fault-tolerant; expensive (n(n-1)/2 connections for full mesh); distributed routing|internet backbone; military communication; social networks; neural networks; airline routes (partial mesh)
NE4|Tree (Hierarchical)|nodes arranged in parent-child hierarchy; single root; no cycles|single path between any two nodes; natural for classification and command; fragile at higher levels; bottleneck at root|file system; organizational chart; DNS hierarchy; taxonomy; XML/HTML document; management structure
NE5|Bus Topology|single shared medium; all nodes attach to bus; signals propagate to all|simple; cheap; collision management needed; single cable failure = entire network failure; limited scalability|Ethernet (original); USB (shared bus); I²C; shared data bus in CPU; open-plan office (shared acoustic space)
NE6|Small-World Network|most nodes not directly connected but reachable in few hops; high clustering + short path length|Watts-Strogatz model; 6 degrees of separation; efficient information spread; resilient to random failure; vulnerable to targeted hub removal|social networks; neural networks; power grids; airline routes; citation networks; World Wide Web
NE7|Scale-Free Network|degree distribution follows power law; few hubs have very many connections; most nodes have few|preferential attachment (rich get richer); robust to random failure but fragile to targeted hub attack; Barabási-Albert model|World Wide Web; citation networks; protein interaction networks; social media follower networks; airline hubs
NE8|Bipartite Network|nodes divided into two sets; connections only between sets, not within|models two-entity-type relationships; can be projected onto one set; recommendation systems|customer-product; student-course; actor-movie; author-paper; worker-task
NE9|Directed Acyclic Graph (DAG)|directed graph with no cycles; enables topological ordering|dependency representation; task scheduling; version history; blockchain (each block points to previous)|Git commit history; build dependency; blockchain; family tree (ignoring incest); course prerequisites; spreadsheet cell dependencies
NE10|Hypergraph|edge connects any number of nodes (not just two); hyperedge|captures multi-party relationships; database tables as hyperedges; more expressive than simple graph|database relation; chemical reaction (multiple reactants → products); committee membership; co-authorship
NE11|Multiplex Network|same nodes connected by multiple types of edges; layered network|each layer represents different connection type; interlayer connections possible; richer than single-layer|social: friend layer + colleague layer + family layer; transportation: road + rail + air; biological: gene regulatory + protein interaction
NE12|Dynamic Network|connections change over time; edges appear and disappear; nodes join and leave|temporal analysis required; snapshot vs continuous models; evolving communities; epidemiology|social network growth; neural plasticity; internet routing changes; species interaction over seasons; organizational restructuring

# channel(id|name|definition|medium|bandwidth|latency|range|notes)
CH1|Physical Contact|direct matter-to-matter connection|solid/liquid interface|very high (force, heat)|zero to minimal|zero distance|oldest connection type; requires co-location; most reliable
CH2|Sound (Acoustic)|pressure waves through medium (air, water, solid)|air (typical)|~50 kbps equivalent (speech)|speed of sound (~343 m/s in air)|~100m (unaided speech); km (shout, horn); global (electronic)|attenuated by distance; blocked by barriers; broadcast by default; eavesdropping easy
CH3|Light (Visual)|electromagnetic radiation in visible spectrum|air/vacuum|very high (vision processes ~10 Mbps)|speed of light|line of sight; km (unaided); global (fiber optic)|directional; blocked by opaque objects; requires illumination; high bandwidth natural channel
CH4|Electromagnetic (Radio)|radio waves through air/vacuum|air/vacuum|kbps to Gbps depending on frequency and technology|speed of light|global (HF); local (WiFi, Bluetooth); space (satellite)|frequency allocation regulated; penetrates some obstacles; broadcast or directed; noise susceptible
CH5|Electrical (Wired)|electron flow or electromagnetic waves in conductor|copper, aluminum wire|kbps (serial) to Tbps (fiber equivalent over copper at short distance)|near speed of light; distance-dependent|meters (USB) to km (Ethernet, telephone)|reliable; shielded against noise; physical infrastructure required; bandwidth decreases with distance
CH6|Optical Fiber|light pulses through glass/plastic fiber|glass/plastic core|Tbps per fiber (WDM)|speed of light × 0.67 (refraction)|global (undersea cables)|highest bandwidth physical medium; immune to electromagnetic interference; expensive to deploy; fragile
CH7|Chemical|molecules carrying information; concentration gradients|fluid medium (blood, air, water)|very low bandwidth|seconds to hours (hormonal); minutes (pheromonal)|local (synaptic) to km (pheromonal in wind)|ancient signaling mechanism; highly specific (receptor-ligand); persistent signal; slow
CH8|Written/Printed|information encoded in durable physical marks on medium|paper, stone, clay, screen|limited by reading speed (~250 words/min human)|production delay; transit delay (delivery)|global (postal); unlimited duration (if preserved)|most important human information technology; persists across time; requires literacy; copyable
CH9|Gravitational|mass-energy curvature of spacetime|spacetime itself|extremely low (gravitational wave detection barely possible)|speed of light|infinite (inverse square attenuation)|weakest channel; only recently detectable (LIGO 2015); primarily relevant at cosmic scale
CH10|Neural|electrochemical signals along neurons and across synapses|nerve fibers (axons)|individual neuron: ~1-100 Hz firing; aggregate: enormous parallel bandwidth|1-120 m/s (myelination-dependent)|centimeters to meters (within organism)|biological information processing; parallel; adaptive (plasticity); noise filtered by threshold
CH11|Digital Network|packets of data through routed infrastructure|copper, fiber, radio (mixed)|kbps to Tbps|milliseconds (local) to hundreds of ms (global)|global (internet)|dominant modern communication infrastructure; packetized; error-corrected; addressed; routable
CH12|Quantum|entangled particles maintaining correlation regardless of distance|quantum entanglement|1 bit per entangled pair (no FTL communication)|instantaneous correlation (but no FTL information transfer)|theoretically unlimited distance (demonstrated ~1000 km)|cannot transmit classical information FTL; enables quantum key distribution; quantum teleportation of state

# protocol(id|name|definition|layer|key_features|examples)
PR1|Physical Protocol|rules for electrical/optical signaling on physical medium; voltage levels, timing, encoding|physical|bit encoding; clock recovery; signal levels; connector specifications|Ethernet PHY; USB physical layer; RS-232 voltage levels; fiber optic modulation; Bluetooth radio
PR2|Framing Protocol|delimiting message boundaries within bit stream; identifying start/end of frame|data link|frame delimiters; error detection (CRC); addressing (MAC); flow control|Ethernet frame; HDLC; PPP; Wi-Fi frame; serial port framing
PR3|Addressing Protocol|rules for identifying and locating entities; namespace management|network|address format; allocation; resolution (mapping name → address); routing based on address|IP addressing; MAC addressing; DNS (name → IP); ARP (IP → MAC); postal addressing; phone numbering (E.164)
PR4|Routing Protocol|rules for determining path through network from source to destination|network|path selection; metric (hop count, latency, bandwidth); convergence; loop prevention|BGP (internet); OSPF (enterprise); RIP; road signage; postal routing; airline booking
PR5|Transport Protocol|rules for reliable or unreliable end-to-end communication; flow and congestion control|transport|connection management; ordering; reliability (retransmission); flow control; multiplexing (port numbers)|TCP (reliable, ordered); UDP (unreliable, fast); QUIC; SCTP
PR6|Session Protocol|rules for establishing, maintaining, and terminating communication sessions|session|authentication; session state; resumption; timeout; keep-alive|TLS handshake; SSH; HTTP session (cookies); login session; phone call setup (SIP)
PR7|Presentation Protocol|rules for data encoding, encryption, compression between applications|presentation|character encoding; encryption/decryption; serialization format; compression|TLS encryption; JSON/XML serialization; UTF-8 encoding; image codec (JPEG, PNG); video codec (H.264)
PR8|Application Protocol|rules for specific application-level communication; semantics of exchange|application|request/response or stream; methods (GET, POST); status codes; headers; content types|HTTP; SMTP; FTP; DNS query; MQTT; gRPC; IMAP; SIP; WebSocket
PR9|Handshake Protocol|bidirectional procedure establishing connection parameters before data exchange|multi-layer|capabilities negotiation; identity verification; key exchange; state synchronization|TCP 3-way (SYN, SYN-ACK, ACK); TLS handshake; OAuth flow; Bluetooth pairing; diplomatic credentials
PR10|Social Protocol|rules governing human interaction; etiquette; ceremony; convention|social|turn-taking; greeting/farewell; title usage; reciprocity norms; conflict resolution; formality levels|handshake; business card exchange; parliamentary procedure; queue etiquette; dining etiquette; diplomatic protocol
PR11|Biological Protocol|evolved rules for inter-cellular and inter-organism communication|biological|receptor-ligand specificity; signal transduction cascades; quorum sensing; immune recognition|hormone signaling; neurotransmitter release; antigen presentation; bacterial quorum sensing; pollen recognition
PR12|Error Handling Protocol|rules for detecting, reporting, and recovering from connection failures|multi-layer|error detection (checksum, parity); error correction (FEC, retransmission); timeout; fallback; graceful degradation|TCP retransmission; HTTP error codes (404, 500); circuit breaker pattern; exception handling; NACK

# failure_modes(id|topic|mode|cause|consequence|prevention)
FM1|connection|single point of failure|critical node or edge has no redundancy; all traffic through one point|entire system fails when that point fails|redundancy; mesh topology; failover; hot standby; avoid star topology for critical paths
FM2|connection|cascade failure|failure of one connection overloads adjacent connections causing their failure|progressive system-wide collapse; blackout; financial contagion|circuit breakers; load shedding; capacity planning; isolation; bulkhead pattern
FM3|connection|congestion|demand exceeds connection capacity; too many messages, too much traffic|increased latency; packet loss; reduced throughput; deadlock possible|flow control; congestion control (TCP); backpressure; traffic shaping; capacity expansion; load balancing
FM4|connection|partition (split brain)|network divided into non-communicating segments; both segments continue operating independently|inconsistent state; duplicate operations; data loss on reunion; CAP theorem applies|consensus algorithms (Raft, Paxos); partition detection; manual reconciliation; choosing CP or AP (CAP theorem)
FM5|connection|stale reference|pointer/reference to entity that no longer exists or has changed|dangling pointer; 404 error; broken link; cache serving outdated data; NullPointerException|garbage collection; reference counting; TTL on cache; link checking; tombstone records; weak references
FM6|connection|man-in-the-middle|attacker intercepts connection and relays modified communication; both parties believe direct connection|compromised integrity and confidentiality; credential theft; data manipulation|end-to-end encryption; certificate pinning; mutual authentication; out-of-band verification
FM7|connection|impedance mismatch|connected systems have incompatible interfaces, formats, speeds, or assumptions|data loss; reflection (signals); type errors; semantic misunderstanding; performance degradation|adapters; transformers; protocol translation; serialization standards; interface contracts; impedance matching (electrical)
FM8|connection|feedback loop (runaway)|positive feedback without damping; amplification without limit|system instability; oscillation; saturation; destruction|negative feedback; damping; rate limiting; circuit breakers; governor mechanisms; monitoring with automatic shutdown
FM9|connection|connection exhaustion|too many connections open; resource limits reached (file descriptors, memory, ports)|new connections refused; degraded service; crash|connection pooling; timeout and close idle connections; resource limits configured; backpressure
FM10|connection|latency spike|sudden increase in connection delay; temporary or persistent|timeout; cascading failures from retry storms; user experience degradation; lost synchronization|timeout tuning; retry with backoff (exponential); circuit breaker; hedged requests; latency monitoring
FM11|connection|asymmetric failure|one direction of bidirectional connection fails while other works; half-open|messages sent but no response received; appears as timeout to sender but receiver processes normally|bidirectional heartbeat; connection health checking from both ends; half-open detection; reset mechanism
FM12|connection|address exhaustion|addressing scheme runs out of available addresses; namespace collision|new entities cannot be addressed; conflicts between existing entities|larger address space (IPv4 → IPv6); NAT (temporary); hierarchical addressing; CIDR; address recycling

# distinctions(id|side_a|side_b|key_asymmetry)
DI1|Physical Connection|Logical Connection|physical: matter-to-matter or field-mediated; constrained by physics (distance, medium, energy); logical: represented in information system; constrained by design (protocol, address, permission); logical can exist without physical (cached reference) and physical without logical (unintended interference)
DI2|Direct Connection|Indirect Connection|direct: source and target communicate without intermediary; lower latency; simpler; both must be available; indirect: one or more intermediaries (router, broker, translator); decoupling; routing flexibility; higher latency; intermediary failure = connection failure
DI3|Synchronous|Asynchronous|synchronous: sender blocks until receiver processes and responds; tight temporal coupling; simple but slow; asynchronous: sender does not block; messages queued; temporal decoupling; complex but scalable; callback or polling for response
DI4|Persistent Connection|Transient Connection|persistent: maintained continuously (dedicated line, TCP keep-alive, marriage); lower setup cost per use; resource consumption; transient: established per interaction then torn down (HTTP 1.0, greeting, function call); higher setup cost; lower resource consumption
DI5|Tight Coupling|Loose Coupling|tight: change in one entity requires change in other; shared state; direct dependency; fast but fragile; loose: interface-mediated; changes isolated; message-based; slower but resilient; easier to evolve independently
DI6|Unidirectional|Bidirectional|unidirectional: flow in one direction only (broadcast, write-only, one-way valve); simpler; less resource; bidirectional: flow in both directions (conversation, full-duplex); enables feedback; more complex; most social connections bidirectional
DI7|Connection|Disconnection|connection: enabling transfer between entities; disconnection: severing or preventing transfer; both are active states; disconnection can be protective (firewall, quarantine) or harmful (isolation, exile); changing from connected to disconnected = cut, break, revoke; reverse = establish, repair, restore
DI8|Bonding Social Capital|Bridging Social Capital|bonding: strong ties within homogeneous group; trust, reciprocity, emotional support; can be exclusionary; bridging: weak ties between heterogeneous groups; novel information, opportunity, diversity; may lack depth; Putnam framework
DI9|Hub|Leaf|hub: node with many connections; central; powerful; vulnerable; bottleneck; leaf: node with few connections; peripheral; replaceable; less visible; most nodes in scale-free networks are leaves
DI10|Push|Pull|push: sender initiates transfer (notification, broadcast, stream); real-time; receiver passive; pull: receiver initiates transfer (query, request, polling); on-demand; sender passive; push = lower latency but higher resource; pull = more control but polling overhead
DI11|Multiplexed|Dedicated|multiplexed: multiple connections share single channel (TDM, FDM, WDM); efficient but contention possible; dedicated: single connection per channel; no contention but wasteful if underused; cost vs performance trade-off
DI12|Static Connection|Dynamic Connection|static: established at design/build time; fixed topology; predictable; rigid; dynamic: established at runtime; flexible; discoverable; adaptable; overhead of establishment and teardown; more complex failure modes
DI13|Structural Connection|Semantic Connection|structural: physical or topological relationship (adjacent, containing, linked); semantic: meaning-based relationship (about, represents, implies); structural connections exist in the world; semantic connections exist in interpretation; same structure can carry different semantics
DI14|Connection|Relation|connection: implies transfer capacity (information, force, matter can flow); relation: may be purely logical without transfer capacity (greater-than, born-in-same-year, color-of); all connections are relations but not all relations are connections

# relationships(from|rel|to)
# Foundation → properties
CO1|has_property|CO4,CO5,CO6,CO7,CO8,CO9,CO10,CO11,CO12,CO13,CO14,CO15,CO16,CO17,CO18,CO19,CO20,CO21,CO22,CO23
CO2|participates_in|CO1
CO3|implements|CO1

# Spatial → foundational
SP1|instance_of|CO1
SP2|instance_of|CO1
SP3|instance_of|CO1
SP15|specializes|CO19
SP17|modulates|CO5,CO7,CO22

# Spatial relationships
SP1|requires|SP17
SP3|specializes|SP1
SP4|constrained_by|ST11
SP7|specializes|SP3
SP8|contrasts|SP9
SP10|specializes|SP3
SP12|specializes|SP8
SP13|specializes|SP1
SP14|specializes|SP3

# Temporal → foundational
TM1|instance_of|CO1
TM5|specializes|TM1
TM8|specializes|TM1
TM8|requires|TM1

# Temporal relationships
TM3|specializes|TM1
TM4|characterizes|CO6
TM7|enables|TM2
TM9|characterizes|CO7
TM10|compensates_for|TM9
TM11|terminates|CO6
TM12|extends|CO6

# Structural → foundational
ST1|instance_of|CO1
ST2|instance_of|CO1
ST5|specializes|CO1
ST6|specializes|CO1
ST8|instance_of|CO1
ST9|instance_of|CO1
ST10|instance_of|CO1
ST11|instance_of|CO1
ST12|instance_of|CO1
ST13|instance_of|CO1
ST15|instance_of|CO11
ST16|specializes|CO1

# Structural relationships
ST1|governs|ST8
ST2|implements|SP1
ST4|implements|FU1
ST5|enables|FU1,FU13
ST6|enables|IN7,FU1
ST7|specializes|ST3
ST9|specializes|ST1
ST12|implements|CA8
ST14|enables|SP14
ST15|implements|CO11

# Causal → foundational
CA1|specializes|TM8
CA2|extends|CA1
CA3|weakens|CA1
CA4|specializes|CA1
CA5|enables|CA1
CA6|opposes|CA1
CA7|destabilizes|CO1
CA8|stabilizes|CO1
CA9|mimics|CA1
CA10|combines|CA1,CA8
CA11|emerges_from|CO1

# Informational → foundational
IN1|specializes|CO13
IN2|implements|CO13
IN3|specializes|CO13
IN4|specializes|IN1
IN5|specializes|IN1
IN6|specializes|IN1
IN7|implements|CO1
IN8|traverses|CO1
IN9|specializes|IN8
IN10|specializes|IN8
IN11|specializes|IN8
IN12|establishes|CO1
IN13|specializes|IN8
IN14|specializes|IN8
IN15|caches|CO1
IN16|buffers|CO1
IN17|encodes|IN7,IN8
IN18|validates|IN8

# Social → foundational
SO1|instance_of|CO1
SO2|instance_of|CO1
SO3|instance_of|CO1
SO4|specializes|SO3
SO5|specializes|CO1
SO6|instance_of|CO1
SO7|instance_of|CO1
SO8|specializes|SO2
SO9|specializes|SO2
SO10|enables|CO1
SO11|constrains|CO1
SO12|mediates|CO1
SO13|instance_of|CO1
SO14|instance_of|CO1
SO15|requires|CO1
SO16|validates|CO1

# Functional → foundational
FU1|specializes|CO1
FU2|specializes|CO1
FU3|specializes|CO1
FU4|specializes|CO1
FU5|specializes|FU2
FU6|specializes|CO1
FU7|specializes|FU6
FU8|specializes|FU3
FU9|specializes|CO11
FU10|specializes|FU2
FU11|specializes|CO1
FU12|specializes|CO1
FU13|specializes|FU1
FU14|specializes|CO1

# Logical → foundational
LO1|specializes|CO1
LO2|specializes|CO1
LO3|combines|CO1
LO4|combines|CO1
LO5|negates|CO1
LO6|specializes|CO1
LO7|specializes|LO6
LO8|specializes|CO1
LO9|specializes|CO1
LO10|specializes|CO1
LO11|negates|LO1
LO12|mimics|CA1

# Identity → informational
ID1|specializes|CO13
ID2|specializes|IN3
ID3|specializes|CO13
ID4|specializes|ID2
ID5|enables|CO1
ID6|validates|CO1
ID7|enables|CO1

# Network → topology
NE1|instance_of|CO14
NE2|instance_of|CO14
NE3|instance_of|CO14
NE4|instance_of|CO14
NE5|instance_of|CO14
NE6|instance_of|CO14
NE7|instance_of|CO14
NE8|instance_of|CO14
NE9|instance_of|CO14
NE10|extends|CO3
NE11|extends|CO14
NE12|extends|CO14

# Channel → connection
CH1|implements|SP1
CH2|implements|IN7
CH3|implements|IN7
CH4|implements|IN7
CH5|implements|IN7
CH6|implements|IN7
CH7|implements|IN7
CH8|implements|IN8
CH10|implements|IN7
CH11|implements|IN8,IN7
CH12|implements|IN7

# Protocol → channel
PR1|governs|CH4,CH5,CH6
PR2|governs|CH5,CH6,CH11
PR3|governs|CH11
PR4|governs|CH11
PR5|governs|CH11
PR6|governs|CH11
PR7|governs|CH11
PR8|governs|CH11
PR9|implements|IN12
PR10|governs|CH2,CH3,SO15
PR11|governs|CH7,CH10
PR12|protects|CO1

# Cross-category connections
CO10|determines|FM2
CO11|determines|FM7
CO14|determines|FM1
CO22|determines|CH2,CH4,CH5
SO8|enables|SP15
SO10|requires|IN12
FU3|creates|FM1
FU6|implements|CO10
CA7|causes|FM8
CA8|prevents|FM8

# Failure → property
FM1|caused_by|NE1,NE4
FM2|caused_by|CO10
FM3|caused_by|CO8
FM4|caused_by|NE3,CH11
FM5|caused_by|IN1,IN15
FM6|caused_by|CO19,PR9
FM7|caused_by|CO11
FM8|caused_by|CA7
FM9|caused_by|CO8
FM10|caused_by|CO7
FM11|caused_by|CO4
FM12|caused_by|CO13

# Distinction mappings
DI1|distinguishes|SP1,IN1
DI2|distinguishes|CO1,CO19
DI3|distinguishes|IN14,IN13
DI4|distinguishes|CO6
DI5|distinguishes|CO10
DI6|distinguishes|CO4
DI7|distinguishes|CO1
DI8|distinguishes|SO9,SO8
DI9|distinguishes|NE7
DI10|distinguishes|IN13,IN14
DI11|distinguishes|CO12
DI12|distinguishes|NE12
DI13|distinguishes|SP1,LO6
DI14|distinguishes|CO1,LO1

# decode_legend
# id_prefixes: CO=concept, SP=spatial, TM=temporal, ST=structural, CA=causal, IN=informational, SO=social, FU=functional, LO=logical, ID=identity, NE=network, CH=channel, PR=protocol, FM=failure_mode, DI=distinction
# rel_types: has_property|participates_in|implements|instance_of|specializes|modulates|requires|constrained_by|contrasts|characterizes|enables|compensates_for|terminates|extends|governs|opposes|destabilizes|stabilizes|mimics|combines|emerges_from|traverses|establishes|caches|buffers|encodes|validates|mediates|constrains|negates|weakens|causes|prevents|protects|created_by|determines|distinguishes
# connection_properties: direction (directed/undirected), strength (weak/strong), persistence (transient/persistent), latency (zero/finite/variable), capacity (finite/infinite), impedance (low/high)
# confidence: synthetic domain knowledge — not extracted from a single source document
