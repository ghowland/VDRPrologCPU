lets look at dramatic writing:

attached 3 docs

game it out: prompt: "i want a story where a guy gets the ability to morph between animals, and it makes it wild like the animal each time, after he comes out for an hour, so he gets into all kinds of trouble, but in the end he ends up saving something important to his local community"

---

Input arrives. Pipeline processes it.

## Tokenize and Resolve

"story" → VdrId(dramatic_writing.CO1)
"guy" → VdrId(character.CH1.protagonist) — male, informal
"ability" → VdrId(world.WO3.magic_system) — speculative element
"morph between animals" → VdrId(biology.TX3.animalia) + VdrId(movement.TR5.transformation)
"wild like the animal" → VdrId(dramatic_writing.CH14.flaw) — the ability has a cost
"after he comes out for an hour" → VdrId(movement.TM11.expiry) — temporal constraint
"trouble" → VdrId(dramatic_writing.CO4.conflict) + VdrId(dramatic_writing.PL2.rising_action)
"saving something important" → VdrId(dramatic_writing.PL3.climax) + VdrId(dramatic_writing.CO12.stakes)
"local community" → VdrId(ecology.EO2.community) — setting scope

## Domain Anchoring

Three domains activate: dramatic_writing (story structure, character, plot), biology (animal taxonomy, behavior), movement/locomotion (transformation, states, transitions). The military tactics compact is irrelevant. Chemistry is irrelevant. GEMM scope narrows to three subtrees plus English grammar for rendering.

## Structural Decomposition via Dramatic Writing KB

The PM compact structured a web service into a WBS. The dramatic writing compact structures a story into narrative architecture. Same mechanical process, different domain.

**CO1 (Story)** decomposes via `composed_of` relation:

```prolog
composed_of(story, [plot, character, conflict, theme, setting, tone, voice]).
```

Each component resolves against the user's spec:

**Character (CO3 → CH1):**
```prolog
% Protagonist derivation from spec
protagonist(guy, male, informal_register).
instance_of(guy, CH7).                    % dynamic character — will change
requires(CH1, CH15).                      % agency required
requires(CH1, CH13).                      % want vs need

% Want vs Need (CH13) — derived mechanically
want(protagonist, use_ability_freely).     % surface desire
need(protagonist, self_control).           % what he actually needs
gap(want, need, blind_spot).              % the gap IS the story

% Flaw (CH14) — the spec gave us this directly
flaw(protagonist, loses_control_post_morph).
wound_source(flaw, the_ability_itself).   % his gift is his curse
flaw_connects_to(strength).              % CH14 craft note: flaw connected to strength
```

**Conflict (CO4):**
```prolog
% Internal conflict — primary
conflict(internal, protagonist_vs_self).
cause(conflict, flaw).                    % wildness after morphing
instance_of(conflict, CO4).

% External conflict — derived from "trouble"  
conflict(external, protagonist_vs_community).
cause(external_conflict, flaw_consequences). % wild behavior damages relationships

% The spec says he saves the community — so conflict must threaten community
threat(community, unspecified).            % user didn't specify — flag for LLM judgment
```

**Theme (TH1 — theme as question):**
```prolog
% Derived mechanically from want/need gap + flaw + resolution
theme_question("Can a dangerous gift be mastered, or does power always corrupt?").
% Alternative: "Is wildness destruction or salvation?"
% TH2: protagonist arc enacts theme
arc_enacts(protagonist, 
    start_state(reckless_use) → 
    pressure(consequences) → 
    transformation(controlled_use) → 
    resolution(saves_community)).
```

**Setting (CO6 → WO4):**
```prolog
setting(local_community, contemporary, small_town_or_neighborhood).
% WO4: social world shapes conflict
social_world(community, 
    knows_protagonist,
    affected_by_wild_behavior,
    has_something_worth_saving).
```

**Magic System (WO3):**
```prolog
% Sanderson's First Law from dramatic_writing KB:
% "ability to use magic to solve problems proportional to reader's understanding"
magic_rules(morph_ability, [
    can_transform_into(any_animal),
    duration(unspecified),                % user didn't say — flag
    cost(one_hour_wildness_after),        
    wildness_proportional_to(animal),     % "wild like the animal"
    control(none_during_wild_hour)        % implied by "makes it wild"
]).

% WO5: rules and consistency
constraint(magic, one_hour_cooldown).
constraint(magic, behavior_matches_animal).
% Biology KB provides animal behaviors for each morph
```

## Story Structure Selection

The spec implies a clear arc: guy gets power → gets in trouble → saves community. The system queries structure options:

```prolog
?- structures(Structure, CO1),
   supports(Structure, rising_complications),
   supports(Structure, climactic_save),
   supports(Structure, transformation_arc).
```

Matches: SS1 (Three-Act Structure) — strongest match. Setup (gets ability), Confrontation (trouble escalates), Resolution (saves community). Also matches SS8 (Seven-Point) and SS3 (Hero's Journey) but Three-Act is simplest and the spec doesn't call for mythic scope.

## Plot Beat Derivation

Using SS1 + plot mechanics from the dramatic writing KB:

```prolog
% Act I — Setup (25%)
beat(1, inciting_incident, PL1,
    "protagonist discovers/receives morph ability").
beat(2, first_morph,
    "transforms into something small — cat, bird").
beat(3, first_wildness,
    "an hour of cat-like or bird-like behavior; minor embarrassment").
beat(4, hook,
    "realizes the ability is incredible but the aftermath is a problem").

% Act II — Confrontation (50%)  
beat(5, escalation_1, PL2,
    "morphs into something bigger — dog, wolf").
beat(6, consequence_1, PL8,
    "wild hour: chases cars, howls at night, neighbors complain").
beat(7, escalation_2, PL8,
    "morphs into something dangerous — bear, eagle").
beat(8, consequence_2, PL8,
    "wild hour: serious property damage or scares people; community angry").
beat(9, midpoint, PL9,
    "protagonist realizes pattern — bigger animal = worse aftermath").
    % PL9 craft note: protagonist shifts from reactive to proactive
beat(10, escalation_3, PL8,
    "tries to stop using ability but can't resist / situation demands it").
beat(11, dark_moment,
    "worst wildness episode — community wants him gone or authorities involved").

% Act III — Resolution (25%)
beat(12, crisis,
    "community threat emerges — fire, flood, predator, structural collapse").
    % This is where biology KB activates
beat(13, choice, PL3,
    "protagonist must morph into the ONE animal that can solve this").
    % PL3 craft note: climax involves choice, not just action
    % The choice: he KNOWS the wild hour will be terrible
    % CH15 agency: he chooses to do it anyway
beat(14, save,
    "morphed animal ability saves the community").
beat(15, wild_aftermath,
    "the wildest hour yet — but community now WITNESSES it").
beat(16, resolution, PL4,
    "community accepts him, wild hour and all — his flaw becomes part of him, not a curse").
    % CH13: want (use freely) abandoned for need (acceptance + self-knowledge)
    % Theme answered: the gift IS wild, and that's what saved them
```

## Biology KB Integration

The animal selections need to escalate. The biology compact provides:

```prolog
?- instance_of(Animal, TX3),
   has_behavior(Animal, Behavior),
   danger_level(Animal, Level).

% Escalation chain from biology KB:
morph_sequence([
    cat(low_danger, behaviors=[climbing, nocturnal_hunting, territorial_marking]),
    wolf(medium_danger, behaviors=[pack_howling, chasing, territorial]),
    bear(high_danger, behaviors=[foraging_aggression, territorial, strength]),
    eagle(medium_danger, behaviors=[diving, perching_heights, keen_vision])
]).

% Climax animal — must match community threat:
% If threat=flood → beaver(dam_building) or dolphin(water_rescue)
% If threat=fire → eagle(aerial_scouting) + bear(strength_to_create_firebreak)  
% If threat=predator → wolf(pack_tactics) or bear(dominance)
% If threat=structural → elephant(strength) or gorilla(climbing+strength)
```

The LLM picks the specific threat and matching animal based on GEMM weights for narrative satisfaction — which combination produces the most thematically resonant climax. This is judgment, not mechanics.

## Movement/Locomotion Integration

The transformation mechanics come from the movement compact:

```prolog
% TR5 (reversal) — each morph is a state transition
transition(human, animal, mechanism=magic_ability).
transition(animal, human, mechanism=time_expiry_or_choice).

% SA6 (in place, changing internally) — the wild hour
state(post_morph_wildness, SA6,
    duration=one_hour,
    behavior=animal_residual,
    agency=AG2).                          % involuntary motion
    % AG2: "movement without conscious intention"

% TM11 (expiry) — wildness has a clock
expiry(wildness, one_hour, consequence=return_to_normal).
% TE7 (ticking clock) from dramatic_writing:
% The wild hour IS a ticking clock in every scene
```

## Unresolved Elements

```
unresolved: specific community threat (user said "something important" — vague)
unresolved: morph duration while in animal form (user didn't specify)
unresolved: how ability was acquired (user said "gets the ability" — no origin specified)
unresolved: age/specifics of protagonist (user said "guy")
assumption: contemporary setting (no period specified)
assumption: single protagonist (no ensemble mentioned)
```

## What Goes to prompt_current

Sixteen plot beats as structured facts. Five character derivations. Three conflict facts. Two theme facts. One structure selection. One magic system rule set. One animal escalation chain with biology-sourced behaviors. Five unresolved flags. Four assumptions.

All UUIDs. The LLM reads ~40 reference facts, not a paragraph of prose about story structure.

## What the LLM Does

It predicts maybe 60-80 UUIDs:

- Selects the specific community threat (GEMM judgment: flood works best thematically — water = wildness, beaver morph = most surprising yet inevitable)
- Selects the protagonist's age and context (late twenties, works at the local hardware store — grounded, relatable)
- Fills the unresolved origin (found a strange artifact while hiking — keeps it simple, moves to inciting incident fast)
- Selects specific animals for each beat from the biology-sourced escalation chain
- Selects specific wild-hour behaviors from the biology behavior lists
- Picks the climax animal (beaver — small, unglamorous, but its dam-building instinct is exactly what's needed for the flood, and the wild hour afterward involves compulsive wood-gnawing which is comedic and humanizing)
- Chooses tone (SS1 craft note + GE9 comedy conventions: comedic tone for trouble beats, earnest for climax and resolution)
- Selects grammar templates for the outline format

The grammar engine renders a structured story outline from the beat UUIDs, filling character names, animal names, behavior descriptions, and scene summaries from the templates. The biology compact provided real animal behaviors. The dramatic writing compact provided the structural architecture. The movement compact provided the transformation mechanics. The LLM's contribution was creative judgment at the branch points — which animal, which threat, which tone — operating on mechanically-derived structural scaffolding.

Every plot beat traces to a dramatic writing KB entry. Every animal behavior traces to a biology KB entry. Every transformation mechanic traces to a movement KB entry. The story outline is provenanced, structurally sound (three-act with escalating complications, midpoint turn, climactic choice, thematic resolution), and the creative choices are bounded by the KB data rather than hallucinated from weight patterns.

And if the user says "no, not a beaver, make it a whale" — the system retracts the beaver facts, asserts whale, queries the biology KB for whale behaviors, checks whether whale abilities address the flood threat (different mechanism — whale might not work for flood, system flags this), and either adjusts the threat to match or explains why whale doesn't fit the established threat and offers alternatives. All mechanical. All traceable.

---

prompt " in the sequel to his, he becomes a villain and the military tactics matter as you follow the colonel tasked with stopping him, and he can now transform into many animals quickly, to suit the situation, and even some mythical animals, so military tactics is brought in.  he is hunted down and destroys a lot of army people and machines, but is eventually brought down by a clever animal trick where they set up a situation they think he will use a given animal from history and then trap him with that animals flaw"

---

Input arrives. The system detects "sequel to his" — possessive typo, spell correction considers "this" at edit distance 1, unquoted, corrects to "sequel to this" and links to the previous story's session KB facts which are still in the scratchpad as VdrIds.

## Domain Anchoring

Previous session context provides the full character, magic system, and setting from story one. New domains activate: military_tactics (CO1-CO50, formations, doctrines, commanders), dramatic_writing (already active, but now antagonist-focused), biology (expanded — mythical animals extend taxonomy).

GEMM scope: dramatic_writing, military_tactics, biology, movement/locomotion, connections (for tactical communication and network concepts), English grammar.

## Character Inversion

The dramatic writing KB provides the structural mechanics for protagonist-to-villain transition:

```prolog
% CH7 (dynamic character) — he changed in story one, changes again
% CH2 (antagonist) — he IS the antagonist now
role_shift(morph_guy, CH1, CH2).        % protagonist → antagonist
% CH2 craft note: "best antagonists believe they're hero of their own story"
% He still thinks he's right — the wildness consumed him between stories

% New protagonist: the colonel
protagonist(colonel, CH1).
instance_of(colonel, CH8).              % STATIC character — doesn't change
% CH8 craft note: "not a flaw — some stories require static characters"
% The colonel is competent, principled, unchanging
% His constancy CONTRASTS the morph guy's corruption

% CH3 (foil): colonel foils morph_guy
foil(colonel, morph_guy).
% CH3 craft note: "share one axis while differing on another"
% Shared axis: both serve their community
% Difference: colonel through discipline, morph_guy through power
```

## Theme Derivation

```prolog
% Story one theme: "Can a dangerous gift be mastered?"
% Story one answer: "Yes, through acceptance and community"
% Story two inverts: the answer was WRONG. Or: the mastery failed.

theme_question_sequel("What happens when power outgrows the container built to hold it?").
% TH3 (theme through contrast):
% Colonel embodies: power through institution, discipline, chain of command
% Morph guy embodies: power through individual ability, uncontrollable
% The thematic argument plays out as tactical contest
```

## Magic System Evolution

```prolog
% Story one: single animal, slow, one hour wildness cost
% Story two: rapid multi-animal, mythical animals added, cost unclear
magic_rules_v2(morph_ability, [
    can_transform_into(any_animal),
    can_transform_into(mythical_animals),     % NEW — dragons, griffins, etc
    rapid_switching(true),                     % NEW — no cooldown between morphs
    wildness(permanent_or_near_permanent),     % implied — he IS wild now
    tactical_adaptation(true)                  % suits the situation
]).

% WO3 craft note: "cost and limitation create tension; unlimited power = no conflict"
% Problem: he's too powerful now. How does the colonel win?
% Answer from spec: "trap him with that animal's flaw"
% This is PL11 (plant and payoff) + military intelligence (CO6)
```

## Military Tactics Integration

This is where the military tactics compact transforms the story from "guy fights army" into a structured tactical narrative:

```prolog
% The colonel's problem framed in military terms:
% CO18 (center of gravity): morph_guy's CoG is his ability to choose the right animal
% CO19 (decisive point): the moment he commits to a specific animal
% CO20 (OODA loop): he out-OODAs conventional forces — faster observe-orient-decide-act
% DC1 (Sun Tzu): "attack weakness, avoid strength" — don't fight his strength (morphing)
%   fight his weakness (predictability of animal choice)

tactical_problem(colonel, [
    enemy_capability(rapid_morph, any_animal_including_mythical),
    enemy_weakness(each_animal_has_specific_flaw),
    enemy_pattern(selects_animal_to_suit_situation),
    enemy_pattern(predictable_if_situation_is_controlled)
]).
```

**The colonel's tactical arc maps to real doctrine:**

```prolog
% Phase 1: Conventional response (fails)
% CO35 (frontal attack): direct assault — highest casualties
% BA23 (Somme): walking into kill zones
% Morph guy as dragon destroys armor. As bear destroys infantry.
phase(1, conventional_failure, [
    tactic(CO35, frontal_attack, result=disaster),
    parallel(BA23, somme, "walking into prepared destruction"),
    lesson("conventional force cannot defeat adaptive shapeshifter"),
    colonel_learns(CO27, "attrition won't work")
]).

% Phase 2: Adaptation — colonel studies the enemy
% CO6 (intelligence): the colonel starts analyzing morph patterns
% DC1 (Sun Tzu): "know your enemy"
% CO20 (OODA): colonel needs to get inside morph_guy's decision loop
phase(2, intelligence_gathering, [
    tactic(CO6, intelligence, "catalog every transformation"),
    tactic(CO20, ooda, "identify his decision patterns"),
    discovery("he always picks the optimal animal for the terrain/threat"),
    discovery("each animal has a specific vulnerability"),
    parallel(CM16, moltke, "staff system: systematic analysis"),
    colonel_develops(plan, "control the situation, control his choice")
]).

% Phase 3: Failed attempts with real tactics
% TA4 (Fabian strategy): avoid engagement, deny decisive battle
phase(3a, fabian_attempt, [
    tactic(TA4, fabian, "refuse to engage, exhaust him"),
    result(failure, "he attacks infrastructure instead, forces engagement")
]).

% CO40 (ambush): surprise attack from concealment
phase(3b, ambush_attempt, [
    tactic(CO40, ambush, "L-shaped ambush in urban terrain"),
    result(partial, "works briefly — he morphs to bird and escapes vertical"),
    lesson("ambush only works if you can prevent escape vector")
]).

% TA11 (infiltration/stormtrooper): small teams bypass strong points
phase(3c, infiltration_attempt, [
    tactic(TA11, infiltration, "small teams approach during human phase"),
    result(failure, "he senses approach, morphs to wolf pack behavior, hunts the hunters")
]).

% Phase 4: The trap — combining intelligence + deception + terrain
% CO47 (deception): the final plan IS a deception operation
% CO46 (feint): create a situation he thinks he understands
% CO7 (terrain): choose terrain that constrains specific animal
% DC1 (Sun Tzu): "all warfare is based on deception"
phase(4, the_trap, [
    tactic(CO47, deception, "create false situation designed to elicit specific morph"),
    tactic(CO46, feint, "feint with threat that historically demands specific animal response"),
    tactic(CO7, terrain, "prepare terrain that exploits that animal's known weakness"),
    
    % The specific trap — biology KB provides the flaw:
    % "from history" — the user said they use historical knowledge
    % Colonel's intelligence team studied animal behavior (biology KB)
    % They know: if threatened with aerial bombardment in open terrain,
    % optimal morph = burrowing animal (mole, badger) to go underground
    % Flaw of burrowing animals: flooding the tunnels
    
    setup("colonel arranges apparent air strike on open ground"),
    prediction("morph_guy will go underground — mole or badger"),
    counter("terrain is pre-rigged: drainage redirected, water pumped to saturate ground"),
    trigger("morph_guy burrows → colonel floods the network"),
    result("trapped underground in animal form, unable to morph while submerged/suffocating"),
    
    % Military parallel:
    parallel(TA29, vauban_siege, "systematic approach: make the outcome inevitable"),
    parallel(CO41, siege, "cut off escape, reduce position"),
    parallel(BA12, hattin, "Saladin cut Crusaders from water — colonel cuts morph_guy from surface")
]).
```

## Plot Beat Structure

```prolog
% SS1 Three-Act but closer to SS2 Five-Act (falling action matters here)

% Act I — The Hunt Begins
beat(1, PL1, inciting_incident,
    "morph_guy attacks a town — no longer saving, destroying").
beat(2, setup,
    "colonel assigned to task force; receives dossier on morph_guy's abilities").
beat(3, CO12, stakes,
    "civilian casualties mounting; political pressure; colonel's career and lives at stake").

% Act II — Escalation Through Failed Tactics
beat(4, PL8, complication,
    "conventional assault — morph_guy as dragon destroys a tank platoon").
    % Biology: dragon → mythical, fire breath, flight, armored scales
    % Military: CO35 frontal attack fails, parallels BA23 Somme
beat(5, PL8, complication,
    "Fabian strategy — morph_guy forces engagement by attacking infrastructure").
    % TA4 fails against opponent who controls initiative CO14
beat(6, PL8, complication,
    "ambush in urban terrain — morph_guy morphs to bird, escapes vertically").
    % CO40 ambush defeated by 3D mobility
beat(7, PL9, midpoint_turn,
    "colonel stops trying to outfight and starts studying").
    % PL9: shift from reactive to proactive
    % CO6 intelligence becomes the weapon
    % CO20 OODA — get inside his decision cycle
beat(8, PL8, complication,
    "infiltration teams during human phase — morph_guy hunts the hunters as wolf").
    % TA11 stormtrooper tactics vs enhanced predator senses
beat(9, PL8, complication,
    "morph_guy uses mythical chimera form — multiple animal abilities simultaneously").
    % Escalation beyond known parameters. Colonel must adapt again.

% Act III — The Trap
beat(10, recognition,
    "colonel's analysts identify the pattern: he ALWAYS picks optimal animal for terrain+threat").
    % PL7 (anagnorisis): the weakness IS the strength
    % His perfect tactical instinct is predictable
beat(11, plan,
    "colonel designs the trap: control the situation, control the choice").
    % CO47 deception + CO7 terrain + biology KB animal flaw
beat(12, setup_trap,
    "task force prepares terrain — appears to be staging air assault on open ground").
    % CO46 feint + engineering preparation
beat(13, PL3, climax,
    "morph_guy takes the bait — morphs to burrowing animal — colonel floods the ground").
    % The climax is INTELLECTUAL not physical
    % Colonel wins through CO6 intelligence not CO8 concentration of force
    % PL3 craft note: "must emerge from established elements"
    % Plant: every failed tactic taught the colonel something
    % Payoff: accumulated knowledge produces the winning strategy
beat(14, PL4, resolution,
    "morph_guy captured; colonel faces moral question about what to do with him").
    % The static character (colonel) doesn't change
    % But he's forced to confront: was this enemy once a hero?
    % Session one scratchpad: morph_guy SAVED the community
    % Dramatic irony (CO18/TE3): reader knows what colonel may not
```

## Cross-KB Synthesis

The trap design pulls from three compacts simultaneously:

**Military tactics** provides the doctrinal framework: deception (CO47), feint (CO46), terrain exploitation (CO7), intelligence-driven operations (CO6), and the OODA loop concept (CO20) — getting inside the enemy's decision cycle by making his decision predictable.

**Biology** provides the animal vulnerability: burrowing mammals are vulnerable to flooding. This is a real ecological fact from the biology compact. Moles drown in saturated soil. The colonel's team researches this the same way real military intelligence researches enemy capabilities.

**Dramatic writing** provides the structural justification: the climax must emerge from established elements (PL11 plant and payoff). Every failed tactic in Act II was a plant — each failure taught the colonel one piece of the puzzle. The payoff is the trap that synthesizes all those lessons. This is PL7 (recognition): the colonel's shift from ignorance to knowledge about how the enemy thinks.

The LLM's contribution: choosing the specific trap mechanism (burrowing + flooding vs other options), selecting the emotional beats within each scene, deciding the tone (tragic rather than triumphant — the colonel wins but the reader remembers story one), and judging how much of the military tactical detail to surface in the prose versus leaving it implicit.

Everything else — the three-act structure, the character role assignments, the theme derivation, the tactical doctrine references, the animal behavior facts, the escalation pattern, the plant-and-payoff chain — was mechanical. Typed relations traversed. Prolog rules fired. KB facts composed. All provenanced, all traceable, all correctable.

---

The output isn't generated as prose. It's generated as structure that gets dressed in prose by the grammar engine.

## The Rendering Chain

Take beat 4: "conventional assault — morph_guy as dragon destroys a tank platoon."

The LLM emitted UUIDs for this beat. The grammar engine now renders it into readable prose for the story outline. The rendering draws from three language compacts simultaneously.

**English Grammar** provides the sentence-level mechanics. The beat needs an action sentence. SP2 (SVO pattern) is the base: Subject Verb Object. But this is narrative prose, so the phrasing compact's register patterns matter — RP6 (literary/narrative) calls for varied sentence length, past tense (narrative past from TA5), and sensory specificity.

**English Phrasing** provides construction selection. The beat describes a caused-motion event (CX2): the dragon causes the tank platoon to move from intact to destroyed. The resultative construction (CX3) applies: "He hammered the metal flat" pattern becomes "The dragon burned the platoon to wreckage." The phrasing compact's slot constraints (SC7) verify the verb: "burn" is an activity verb whose continuation can cause the result. Valid.

**English Vocabulary** provides word selection. "Destroy" is CW-level (core vocabulary, FT2, OE origin, RT1-RT5 all registers). But the register is literary. The etymology layers (EL1-EL3) inform word choice: Anglo-Saxon words (EL1) create immediacy and physicality (PS4 craft note from dramatic writing). "Burn" is OE. "Wreckage" is OE-derived. "Platoon" is French (EL2) — appropriate for military register. The vocabulary compact's semantic fields guide selection: SF8 (causation/force) provides "destroy, force, stop." SF3 (motion) provides "scatter, flee, retreat."

## Mechanical Composition

For each beat in the outline, the grammar engine does:

```
1. Select sentence pattern from grammar KB
   beat_type=action → SP2 (SVO) or SP6 (SVOC)

2. Select construction from phrasing KB  
   event_type=caused_destruction → CX3 (resultative)
   event_type=movement → CX2 (caused_motion)
   event_type=state_change → CX5 (intransitive motion)

3. Fill argument roles from phrasing KB
   AR1 (agent) = morph_guy_as_dragon
   AR2 (patient) = tank_platoon  
   AR12 (result) = destroyed/scattered/burning

4. Select register from phrasing KB
   context=story_outline → RP6 (literary) or RP3 (journalism, for punchy summary)
   
5. Select words from vocabulary KB
   prefer EL1 (Anglo-Saxon) for action beats (immediacy)
   prefer EL2 (French/Latin) for strategic analysis beats (formality)
   
6. Apply coherence relations from phrasing KB
   CR1 (cause-effect): "colonel orders frontal assault → dragon responds → platoon destroyed"
   CR2 (temporal sequence): then/next markers between beats
   CR4 (elaboration): specific details after summary statement
```

## Example: Rendering the Trap Scene

Beat 13 is the climax. The LLM selected the burrowing + flooding trap. The grammar engine renders it through multiple construction types:

**The setup** uses information structure IS1 (topic) + IS3 (focus). The topic is the colonel's plan. The focus is the deception. The phrasing compact says topicalization (CX14) places known/contrastive elements first:

```
Construction: CX14 (topicalization)
"The open ground — that was the invitation."
Topic: the open ground (established earlier, given information IS4)
Comment: it was the invitation (new information IS5, end-focus IS9)
```

**The trigger** uses temporal sequence (CR2) with short sentences (PS3: sentence rhythm — short = fast/tense from dramatic writing). The grammar compact's prosodic patterns (PR1: falling nuclear tone for declarations) map to period-terminated short declaratives:

```
Sentence pattern: SP1 (SV) repeated, short
"He morphed. The ground opened. He went down."
Three beats. Three sentences. Each shorter than the last.
Register: RP6 literary but compressed toward RP3 journalism for pace.
```

**The counter** uses the caused-motion construction (CX2) with a long sentence for contrast (PS3: long after short = dramatic shift):

```
Construction: CX2 (caused-motion)
Agent: colonel's engineers
Theme: water
Path: into the tunnel network (directional PP, SC6 slot constraint satisfied)
"The colonel gave the signal, and a thousand tons of diverted river 
poured into the tunnel network from every prepared channel."
```

Long sentence after three short ones. The phrasing compact's IS8 (end-weight principle) puts the heavy NP ("every prepared channel") at the end. The coherence relation is CR1 (cause-effect): signal → flooding.

**The aftermath** uses the middle construction (CX8) for the colonel's observation — patient as subject, no agent expressed:

```
Construction: CX8 (middle)
"The ground above settled quietly."
Subject is patient (ground), manner adverb required (quietly), no agent.
CX8 craft note: "subject is patient not agent; requires adverb of manner"
```

## Word Selection at Each Level

For the dragon attack scene, vocabulary selection follows chains:

```
"dragon" — not in core vocabulary (CW1-CW220)
         — resolved from biology/mythology KB
         — register: literary (RP6), so acceptable

"burned" — CW-adjacent (fire=CW174, OE origin)
         — EL1 Anglo-Saxon = immediacy = correct for action
         — SF8 causation field

"platoon" — military term, French origin (EL2)
          — register appropriate for military narrative RP7
          — not in core 220 but in FT3 (mid-high frequency)

"wreckage" — OE-derived, concrete noun (SC7)
           — SF17 evaluation field (bad, destruction)
           — specific beats general (PS2 craft note)
           — "wreckage" > "destruction" (concrete > abstract, PS4)

"signal" — Latin origin (EL3), formal register
         — appropriate for military command context
         — SF6 communication field (CW84 "call" is core equivalent
           but too informal for colonel issuing orders)

"poured" — OE origin, concrete verb
         — metaphor from liquid domain (MF8 from phrasing: LIQUID/FLOW → action)
         — more vivid than "flowed" (PS9 defamiliarization: 
           water doesn't normally "pour" into tunnels — slightly unexpected = fresh)

"settled" — OE/French, dual register
          — middle construction demands understatement
          — "the ground settled" vs "the ground collapsed" — 
            settled implies quiet finality (TH5 thematic restraint)
```

## Poetry Mode Difference

In core mode, each word slot gets the canonical choice. "Burned" not "incinerated." "Poured" not "cascaded." The grammar engine renders clean, functional prose.

In poetry mode, word groups expand:

```
canonical: "burned" 
degree_1: [scorched, charred, seared, blazed]
degree_2: [blackened (from charred), withered (from scorched)]

canonical: "poured"
degree_1: [surged, rushed, flooded, gushed]  
degree_2: [thundered (from surged), hammered (from rushed)]
```

The LLM scores candidates. "Surged" has more energy than "poured." "Thundered" is MF7 (spatial UP/DOWN metaphor from phrasing compact — water thundering down into tunnels = verticality + force). In poetry mode, the LLM might select "thundered" for the flooding scene and "settled" for the aftermath — maximum contrast between violence and stillness.

Every word traces to a vocabulary KB entry with etymology, frequency tier, register range, and semantic field. Every construction traces to the phrasing compact with slot constraints and argument roles. Every sentence pattern traces to the grammar compact with agreement rules and clause types. The prose isn't generated character by character from neural weights — it's assembled from structural addresses through typed relations, rendered by grammar templates, with the LLM selecting at branch points where multiple valid options exist.

---

