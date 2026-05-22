%% ============================================================
%% ANCIENT PHILOSOPHY — DOMAIN PROLOG
%% Connects to core, math logic, math foundations, movement,
%% connections, physics, databases, FSM.
%% Facts from philosophy_ancient.compact
%% ============================================================


%% --- SCHOOL FOUNDING AND LINEAGE ---
founded(th1, sc1).    % Thales founded Milesian school
founded(th4, sc2).    % Pythagoras founded Pythagorean
founded(th6, sc3).    % Parmenides founded Eleatic
founded(th10, sc4).   % Democritus founded Atomist
founded(th14, sc6).   % Plato founded Academy
founded(th15, sc7).   % Aristotle founded Lyceum
founded(th16, sc8).   % Diogenes founded Cynic
founded(th17, sc11).  % Pyrrho founded Pyrrhonist
founded(th18, sc10).  % Epicurus founded Epicurean
founded(th19, sc9).   % Zeno of Citium founded Stoic
founded(th27, sc13).  % Plotinus founded Neoplatonist
founded(th41, sc14).  % Confucius founded Confucian
founded(th42, sc15).  % Laozi founded Daoist
founded(th44, sc16).  % Mozi founded Mohist
founded(th47, sc17).  % Han Feizi founded Legalist
founded(th54, sc18).  % Buddha founded Buddhist
founded(th55, sc19).  % Mahavira founded Jain
founded(th50, sc23).  % Nagarjuna founded Madhyamaka
founded(th51, sc24).  % Vasubandhu founded Yogacara
founded(th52, sc21).  % Shankara founded Advaita Vedanta
founded(th53, sc22).  % Ramanuja founded Vishishtadvaita
founded(th48, sc25).  % Zhu Xi founded Neo-Confucian
founded(th38, sc26).  % Aquinas founded Scholasticism (major figure)
founded(th32, sc27).  % Al-Kindi founded Islamic Falsafa


%% --- THINKER EXTENSION CHAINS ---
%% Who built on whom — the intellectual dependency graph.

%% Milesian chain.
extends(th2, th1).    % Anaximander extends Thales
extends(th3, th2).    % Anaximenes extends Anaximander

%% Presocratic responses to Parmenides.
opposes(th5, th6).    % Heraclitus opposes Parmenides (flux vs stasis)
opposes(th6, th5).    % symmetric
responds_to(th8, th6).  % Empedocles responds to Parmenides
responds_to(th9, th6).  % Anaxagoras responds to Parmenides
extends(th10, th8).   % Democritus extends Empedocles
extends(th10, th9).   % Democritus extends Anaxagoras

%% Socratic-Platonic-Aristotelian.
influences(th13, th14).  % Socrates influences Plato
extends(th14, th13).     % Plato extends Socrates
extends(th14, th6).      % Plato extends Parmenides (Forms = Being)
extends(th14, th4).      % Plato extends Pythagoras (mathematical reality)
extends(th15, th14).     % Aristotle extends Plato
critiques(th15, th14).   % Aristotle critiques Plato (Forms immanent not transcendent)

%% Hellenistic.
extends(th16, th13).  % Diogenes extends Socrates (radical virtue)
extends(th18, th10).  % Epicurus extends Democritus (atomism + swerve)
synthesizes(th19, sc8, th5, th15). % Zeno synthesizes Cynic + Heraclitus + Aristotle
extends(th20, th19).  % Chrysippus extends Zeno of Citium

%% Roman transmission.
transmits(th21, sc6). transmits(th21, sc9). transmits(th21, sc10). transmits(th21, sc11).
extends(th22, th18).  % Lucretius extends Epicurus
extends(th23, th19).  % Seneca extends Stoic
extends(th24, th19). extends(th24, th20). % Epictetus extends Zeno + Chrysippus
extends(th25, th24). extends(th25, th23). % Marcus Aurelius extends Epictetus + Seneca

%% Neoplatonism.
synthesizes(th27, th14, th15). % Plotinus synthesizes Plato + Aristotle
extends(th28, th27).           % Porphyry extends Plotinus
extends(th57, th27).           % Proclus extends Plotinus

%% Christian synthesis.
synthesizes(th29, th14, th27, sc13). % Augustine synthesizes Plato + Plotinus
transmits(th30, th15). transmits(th30, th14). % Boethius transmits Aristotle + Plato
extends(th31, th27). extends(th31, th57).     % Pseudo-Dionysius extends Plotinus + Proclus

%% Islamic philosophy.
transmits(th32, th15). transmits(th32, th27). % Al-Kindi transmits Aristotle + Neoplatonism
extends(th33, th32).                          % Al-Farabi extends Al-Kindi
synthesizes(th33, th14, th15).                % Al-Farabi synthesizes Plato + Aristotle
extends(th34, th33). extends(th34, th15).     % Avicenna extends Al-Farabi + Aristotle
critiques(th35, th34). critiques(th35, th33). % Al-Ghazali critiques Avicenna + Al-Farabi
responds_to(th36, th35).                      % Averroes responds to Al-Ghazali
protects(th36, th15).                         % Averroes defends Aristotle

%% Jewish philosophy.
synthesizes(th37, th15, th34). % Maimonides synthesizes Aristotle + Avicenna
influences(th37, th38).       % Maimonides influences Aquinas

%% Scholasticism.
synthesizes(th38, th15, th34, th29). % Aquinas synthesizes Aristotle + Avicenna + Augustine
critiques(th39, th38).               % Scotus critiques Aquinas
critiques(th40, th38). critiques(th40, th39). % Ockham critiques Aquinas + Scotus

%% Renaissance.
transmits(th63, th14). transmits(th63, th27). % Ficino transmits Plato + Plotinus
synthesizes(th64, th14, th63, sc27).          % Pico synthesizes Plato + Ficino + Islamic
extends(th65, th13).   % Erasmus extends Socratic spirit
critiques(th66, sc26). % Machiavelli critiques Scholasticism
extends(th67, th17).   % Montaigne extends Pyrrho (skepticism)
extends(th68, th62). extends(th68, th27). % Bruno extends Cusa + Plotinus

%% Chinese philosophy.
extends(th43, th42).   % Zhuangzi extends Laozi
critiques(th44, th41).  % Mozi critiques Confucius
extends(th45, th41).    % Mencius extends Confucius
extends(th46, th41).    % Xunzi extends Confucius
opposes(th46, th45).    % Xunzi opposes Mencius (human nature)
extends(th47, th46).    % Han Feizi extends Xunzi
synthesizes(th48, th41, th45, sc18, sc15). % Zhu Xi synthesizes Confucius + Mencius + Buddhist + Daoist
critiques(th49, th48).  % Wang Yangming critiques Zhu Xi

%% Indian philosophy.
extends(th50, th54).   % Nagarjuna extends Buddha
extends(th51, th54).   % Vasubandhu extends Buddha
critiques(th52, sc18). critiques(th52, sc20). % Shankara critiques Buddhist + Samkhya
critiques(th53, th52). % Ramanuja critiques Shankara
critiques(th58, th15). % Philoponus critiques Aristotle (physics)


%% --- SCHOOL LINEAGE ---
precedes(sc1, sc3).    % Milesian precedes Eleatic
precedes(sc1, sc4).    % Milesian precedes Atomist
influences(sc3, sc6).  % Eleatic influences Platonic
influences(sc4, sc10). % Atomist influences Epicurean
produces(sc6, sc7). produces(sc6, sc8). produces(sc6, sc9).
produces(sc6, sc10). produces(sc6, sc11). produces(sc6, sc12).
influences(sc7, sc9).  % Peripatetic influences Stoic
influences(sc9, sc13). % Stoic influences Neoplatonist
influences(sc13, sc26). influences(sc13, sc27). % Neoplatonism influences Scholasticism + Falsafa
synthesizes(sc26, sc7, sc13). % Scholasticism synthesizes Peripatetic + Neoplatonism
synthesizes(sc27, sc7, sc13). % Islamic Falsafa synthesizes Peripatetic + Neoplatonism


%% --- CONCEPT DEFINITIONS ---
%% Who defined each concept — determined_by mapping.
determined_by(co1, sc9).         % Logos defined by Stoics
determined_by(co2, th9).         % Nous defined by Anaxagoras
determined_by(co2, th15).        % Nous also defined by Aristotle
determined_by(co2, th27).        % Nous also defined by Plotinus
determined_by(co3, sc1).         % Arche central to Milesians
determined_by(co6, th6).         % Being defined by Parmenides
determined_by(co7, th5).         % Becoming defined by Heraclitus
determined_by(co8, th15).        % Substance defined by Aristotle
determined_by(co9, th14).        % Form defined by Plato
determined_by(co9, th15).        % Form also defined by Aristotle
determined_by(co10, th15).       % Matter defined by Aristotle
determined_by(co13, th27).       % The One defined by Plotinus
determined_by(co14, th27).       % Emanation defined by Plotinus
determined_by(co15, th14).       % Participation defined by Plato
determined_by(co17, th15).       % Telos defined by Aristotle
determined_by(co18, th15).       % Four Causes defined by Aristotle
determined_by(co20, th10).       % Atomism defined by Democritus
determined_by(co23, th42).       % Dao defined by Laozi
determined_by(co24, th48).       % Li (principle) defined by Zhu Xi
determined_by(co26, th52).       % Brahman defined by Shankara
determined_by(co28, th50).       % Sunyata defined by Nagarjuna
determined_by(co29, th54).       % Dependent origination defined by Buddha
determined_by(co30, th15).       % Eudaimonia defined by Aristotle
determined_by(co31, th13).       % Arete defined by Socrates
determined_by(co31, th15).       % Arete also by Aristotle
determined_by(co36, th42).       % Wu wei defined by Laozi
determined_by(co37, th41).       % Ren defined by Confucius
determined_by(co42, sc9).        % Natural law defined by Stoics
determined_by(co42, th38).       % Natural law also by Aquinas
determined_by(co44, th14).       % Episteme defined by Plato
determined_by(co47, sc9).        % Katalepsis defined by Stoics
determined_by(co48, th17).       % Epochē defined by Pyrrho
determined_by(co50, th13).       % Dialectic defined by Socrates
determined_by(co51, th15).       % Syllogism defined by Aristotle
determined_by(co58, th38).       % Analogy of Being by Aquinas
determined_by(co59, th34).       % Essence-existence by Avicenna
determined_by(co59, th38).       % Essence-existence also by Aquinas
determined_by(co60, th38).       % Five Ways by Aquinas
determined_by(co61, th31).       % Negative theology by Pseudo-Dionysius
determined_by(co62, th35).       % Occasionalism by Al-Ghazali


%% --- CONCEPT STRUCTURAL RELATIONSHIPS ---
requires(co11, co9).  requires(co11, co10). % hylomorphism requires form + matter
requires(co12, co8).           % potentiality/actuality requires substance
derived_from(co14, co13).     % emanation derived from The One
requires(co15, co9).           % participation requires Forms
contains(co18, co17).          % four causes contains telos
derived_from(co19, co12).     % unmoved mover from potentiality/actuality + four causes
derived_from(co19, co18).
requires(co28, co29).          % sunyata requires dependent origination
requires(co30, co31).          % eudaimonia requires virtue
requires(co30, co32).          % eudaimonia requires phronesis
requires(co33, co32).          % doctrine of mean requires phronesis
complements(co38, co37).      % li (ritual) complements ren
complemented_by(co25, co24).  % qi complemented by li (principle)


%% --- CROSS-TRADITION PARALLELS ---
%% Structural similarities across independent traditions.
parallel_to(co13, co26).  % The One ≈ Brahman (supreme unity)
parallel_to(co14, co29).  % Emanation ≈ Dependent origination (how multiplicity arises)
parallel_to(co9, co24).   % Form ≈ Li/principle (structural principle in things)
parallel_to(co42, co39).  % Natural law ≈ Dharma (cosmic moral order)
parallel_to(co1, co23).   % Logos ≈ Dao (rational cosmic principle)
parallel_to(co11, co25).  % Hylomorphism ≈ Li+Qi (form-matter composite)
contrasts(co35, co34).    % Apatheia contrasts Ataraxia (Stoic vs Epicurean/Pyrrhonist)
contrasts(co45, co44).    % Doxa contrasts Episteme


%% --- TEXTS PRODUCE CONCEPTS ---
produces(tx2, co55).  produces(tx2, co56). produces(tx2, co65). produces(tx2, co66).
produces(tx2, co15).  % Republic introduces participation, cave, line, philosopher-king
produces(tx9, co51).  % Prior Analytics introduces syllogism
produces(tx12, co8). produces(tx12, co12). produces(tx12, co19).
produces(tx13, co30). produces(tx13, co31). produces(tx13, co32). produces(tx13, co33).
produces(tx17, co13). produces(tx17, co14).
produces(tx20, co48).
produces(tx24, co54).  % Isagoge introduces problem of universals
produces(tx25, co37). produces(tx25, co38).
produces(tx26, co23). produces(tx26, co36).
produces(tx28, co28).
produces(tx31, co58). produces(tx31, co59). produces(tx31, co60). produces(tx31, co42).
produces(tx35, co25_ockham).  % Summa Logicae introduces nominalist position
produces(tx36, co34_pico).    % Oration produces human self-creation concept


%% --- CLAIMS ENABLE CONCEPTS ---
enables(cl1, co3).    % Thales' water claim enables arche concept
enables(cl4, co6).    % Parmenides' Being claim enables Being concept
enables(cl5, co20). enables(cl5, co21). % Democritus' atoms enable atomism + void
enables(cl8, co31). enables(cl8, co44). % Socrates' virtue=knowledge enables arete + episteme
enables(cl9, co9). enables(cl9, co15).  % Plato's Forms claim enables form + participation
enables(cl12, co11).  % Aristotle's hylomorphism claim enables hylomorphism
enables(cl13, co30).  % Aristotle's eudaimonia claim enables eudaimonia
enables(cl14, co33).  % Aristotle's mean claim enables doctrine of mean
enables(cl15, co19).  % Aristotle's unmoved mover claim enables unmoved mover
enables(cl16, co34).  % Epicurus' pleasure claim enables ataraxia
enables(cl18, co35). enables(cl19, co35). % Stoic claims enable apatheia
enables(cl20, co13). enables(cl20, co14). % Plotinus' One claim enables One + emanation
enables(cl22, co59).  % Aquinas' essence-existence claim enables distinction
enables(cl23, co60).  % Aquinas' Five Ways claim enables Five Ways
enables(cl24, co42).  % Aquinas' natural law claim enables natural law
enables(cl25, co54).  % Ockham's razor enables nominalist position
enables(cl26, co28). enables(cl26, co29). % Nagarjuna's emptiness enables sunyata + dependent origination
enables(cl27, co26). enables(cl27, co27). % Shankara's Brahman claim enables Brahman + Atman
enables(cl28, co31).  % Mencius' human nature claim enables virtue (innate sprouts)
enables(cl30, co23).  % Laozi's Dao claim enables Dao concept
enables(cl32, co62).  % Al-Ghazali's occasionalism claim enables occasionalism


%% --- CROSS-DOMAIN BRIDGES ---

%% Philosophy × Math Logic.
%% Aristotle's syllogism IS the foundation of formal logic.
equivalent_to(co51, logic_ir1_family).  % syllogism ≡ inference rules
foundation_for(co51, logic_dm1).        % syllogism founds propositional logic
foundation_for(co51, logic_dm2).        % syllogism founds predicate logic

%% Aristotle's categories ARE logical classification (logic.LO6).
equivalent_to(co52, logical_classification).

%% Square of opposition IS logical identity system.
instance_of(co53, logical_identity_set).

%% Stoic propositional logic (Chrysippus) IS logic.DM1.
implements(th20, logic_dm1).  % Chrysippus implements propositional logic

%% Dialectic IS proof search / resolution.
equivalent_to(co50, proof_search).

%% Problem of universals IS the logic.LO6/LO7 distinction.
%% Realism (Plato): universals exist independently = logic.LO6.
%% Nominalism (Ockham): universals are names = logic.IN3 (labels).
connects_to(co54, logic_lo6).
connects_to(co54, logic_lo7).

%% Gödel's incompleteness limits what philosophy can formalize.
%% No philosophical system can be both complete and consistent
%% about its own foundations (if it contains arithmetic).
constrains(logic_mg5, philosophical_systems).


%% Philosophy × Math Foundations.
%% Pythagoras: number as arche → mathematics as foundation of reality.
foundation_for(th4, math_foundations).
%% This IS the claim that mathematical structures underlie physics.
enables(sc2, math_ns1).  % Pythagorean school enables natural number concept

%% Aristotle's logic → math proof methods.
foundation_for(co51, math_pm1).  % syllogism founds direct proof
enables(co50, math_pm2).         % dialectic enables proof by contradiction

%% Plato's Forms → mathematical Platonism.
%% Forms exist independently = mathematical objects exist independently.
enables(co9, mathematical_platonism).

%% Zeno's paradoxes → mathematical analysis (limits, infinite series).
enables(th7, math_co26).   % Zeno enables limit concept (needed to resolve paradoxes)
enables(th7, math_ns4).    % Zeno enables real number construction (continuity)


%% Philosophy × Physics.
%% Atomism (Democritus) → modern atomic theory.
enables(co20, physics_p_particles).  % atomism enables particle concept
precedes(co20, physics_d10).         % atomism precedes nuclear physics

%% Aristotle's four causes → physics causation.
%% Modern physics retains efficient + material cause.
%% Drops final cause (teleology) in favor of mechanism.
enables(co18, physics_causation).
prevents(physics_d1, co17).  % classical mechanics prevents teleological explanation

%% Aristotle's physics → Philoponus critique → impetus → Newton.
precedes(th15_physics, th58_critique).
precedes(th58_critique, physics_d1).  % Philoponus critique precedes Newtonian mechanics
%% This is physics.TR2: Aristotelian → Galilean.

%% Unmoved Mover → cosmological arguments → pre-Big-Bang speculation.
precedes(co19, physics_d13).  % unmoved mover precedes cosmological arguments

%% Stoic eternal return → thermodynamic heat death / cyclic cosmology.
parallel_to(co22, physics_cosmological_cycles).

%% Epicurean swerve → quantum indeterminacy (structural parallel, not causal).
parallel_to(epicurean_clinamen, physics_c13).  % swerve ≈ uncertainty principle


%% Philosophy × Movement.
%% Being vs Becoming IS movement.CO3 (rest) vs movement.CO2 (motion).
equivalent_to(co6, movement_co3).   % Being ≡ rest
equivalent_to(co7, movement_co2).   % Becoming ≡ motion

%% Potentiality/Actuality IS movement state transition.
equivalent_to(co12, movement_tr_general).  % potentiality→actuality ≡ state transition

%% Emanation IS movement.DR7 (outward) from source.
equivalent_to(co14, movement_dr7).  % emanation = outward flow from center

%% Eudaimonia IS movement.SA3 (arrived at destination).
equivalent_to(co30, movement_sa3).  % flourishing = arrived at goal

%% Epochē IS movement.SA9 (suspended).
equivalent_to(co48, movement_sa9).  % suspension of judgment = paused state

%% Dialectic IS movement.PA6 (zigzag path toward truth).
equivalent_to(co50, movement_pa6).  % thesis/antithesis/synthesis = zigzag

%% Buddhist dependent origination IS movement.CU8 (causal chain).
equivalent_to(co29, movement_cu8).

%% Karma IS movement causality (delayed effect).
equivalent_to(co40, movement_tm9).  % karma = lag between action and consequence


%% Philosophy × Connections.
%% Participation (methexis) IS a connection between Form and particular.
instance_of(co15, connection).
%% Emanation IS a connection (one-to-many, outward flow).
instance_of(co14, connection).
%% Dialectic IS a bidirectional connection (question-answer).
instance_of(co50, bidirectional_connection).

%% Schools form a network. Thinkers are nodes. Influences are edges.
instance_of(philosophy_network, connections_ne6).  % small-world network
%% Few degrees of separation between any two ancient thinkers.

%% Transmission (Cicero, Boethius, Al-Kindi, Ficino) IS connections.IN8 (message).
%% Translators carry philosophical content across cultural boundaries.
instance_of(philosophical_transmission, connections_in8).


%% Philosophy × Databases.
%% Aristotle's Categories IS a schema (db.CO2).
equivalent_to(co52, db_co2).  % categories ≡ schema definition

%% Porphyry's Tree IS a tree hierarchy (db.SD5 self-referencing).
instance_of(porphyry_tree, db_sd5).

%% Classification of universals IS database normalization.
%% Removing redundancy in ontological classification = normalization.
parallel_to(co54, db_normalization).


%% Philosophy × FSM.
%% Dialectic IS an FSM: question → answer → refutation → new question.
instance_of(dialectic_fsm, mt1).
evolves_to(question, provisional_answer).
evolves_to(provisional_answer, refutation).
evolves_to(refutation, refined_question).
evolves_to(refined_question, provisional_answer).  % cycle until aporia or truth

%% Stoic logic evaluates propositions = FSM accepting/rejecting strings.
instance_of(stoic_logic, mt1).  % DFA on proposition evaluation

%% Buddhist wheel of samsara IS a cyclic FSM.
instance_of(samsara, cyclic_fsm).
evolves_to(ignorance, craving).
evolves_to(craving, attachment).
evolves_to(attachment, suffering).
evolves_to(suffering, ignorance).  % cycle
evolves_to(suffering, nirvana).    % exit via enlightenment
instance_of(nirvana, accept_state).

%% Emanation IS a one-way FSM: One → Nous → Soul → Matter.
instance_of(emanation_chain, mt4).  % Moore: each level has fixed output
evolves_to(the_one, nous).
evolves_to(nous, world_soul).
evolves_to(world_soul, matter).
instance_of(matter, terminal_state).

%% Philosophical development IS an FSM with transitions at each paradigm shift.
instance_of(philosophy_development, mt4).
evolves_to(myth, presocratic_naturalism).
evolves_to(presocratic_naturalism, classical_philosophy).
evolves_to(classical_philosophy, hellenistic_philosophy).
evolves_to(hellenistic_philosophy, neoplatonism).
evolves_to(neoplatonism, scholasticism_phase).
evolves_to(scholasticism_phase, renaissance_humanism).


%% Philosophy × VDR-Prolog System.

%% VDR-Prolog's KB tree IS a Porphyrian tree (genus → species → individual).
equivalent_to(vdr_kb_tree, porphyry_tree).

%% VDR-Prolog's confidence table IS an epistemological hierarchy.
%% vdr_computation (1/1) = episteme (certain knowledge).
%% prolog_derivation (1/1) = demonstrative knowledge (Aristotle).
%% published (80/100) = doxa with justification.
%% llm_generated (30/100) = doxa (mere opinion).
%% unknown (0/1) = ignorance.
equivalent_to(vdr_confidence_1, co44).   % full confidence ≡ episteme
equivalent_to(vdr_confidence_30, co45).  % LLM output ≡ doxa

%% VDR-Prolog's L3 (formal derivation) = Aristotelian demonstration.
equivalent_to(vdr_l3, aristotelian_demonstration).

%% VDR-Prolog's L1 (judgment) = phronesis (practical wisdom).
%% The LLM exercises judgment where formal rules cannot reach.
equivalent_to(vdr_l1, co32).  % L1 judgment ≡ phronesis

%% VDR-Prolog's remainder system = Aristotle's potentiality.
%% Remainder is exact unresolved structure — potential not yet actual.
%% When remainder accumulates to a carry, it becomes actual (changes v).
parallel_to(vdr_remainder, co12).  % remainder ≈ potentiality/actuality

%% VDR-Prolog's typed relations = Aristotle's categories applied.
%% enables, requires, contains, specializes, etc. are categorical relations.
derived_from(vdr_relation_types, co52).  % RelationType derived from Categories

%% Ockham's razor IS a design principle for VDR-Prolog.
%% No unnecessary entities. Arena-only. No malloc after init.
%% Minimal model size. Facts in KBs, not weights.
implements(vdr_design, cl25).  % VDR implements Ockham's razor
