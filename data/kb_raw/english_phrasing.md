# ENGLISH PHRASING: CONSTRUCTIONAL CONSTRAINTS ON GRAMMAR — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: domains → constructions → argument_roles → slot_constraints → phrase_patterns → information_structure → discourse_functions → pragmatic_markers → collocations → idiom_patterns → register_patterns → metaphor_frames → speech_acts → coherence_relations → prosodic_patterns → concepts → relationships → section_index → decode_legend

# domains(id|name|definition)
DM1|construction grammar|grammar as inventory of form-meaning pairings (constructions) at all levels; no strict syntax/lexicon divide; meaning resides in the construction itself, not just the words
DM2|argument structure|mapping between semantic roles (agent, patient, goal) and syntactic positions (subject, object, oblique); constructions impose role constraints beyond verb valency
DM3|information structure|how speakers package known vs new, topic vs focus, given vs asserted; determines word order, prosody, and construction choice
DM4|pragmatics|meaning arising from context, speaker intention, shared knowledge; goes beyond literal compositional semantics; implicature, presupposition, speech act
DM5|discourse|organization of language above the sentence; coherence relations, topic management, rhetorical structure, paragraph-level patterning
DM6|register and genre|systematic variation in language use tied to situation (formality, medium, field, tenor); constrains vocabulary, construction choice, and phrasing
DM7|collocational constraint|restrictions on which words co-occur beyond grammar; strong tea not *powerful tea; make a decision not *do a decision; probabilistic but conventionalized
DM8|metaphor and framing|systematic conceptual mappings that constrain phrasing; ARGUMENT IS WAR (attack a position, defend a claim); TIME IS MONEY (spend time, waste time)

# constructions(id|name|form|meaning|slot_count|example|constraints_beyond_grammar)
# Argument structure constructions
CX1|ditransitive construction|SUBJ V OBJ1 OBJ2|X causes Y to receive Z (caused transfer)|3 (agent, recipient, theme)|She gave him the book.|verb must denote transfer or intended transfer (give, send, offer, tell, teach, deny); *She carried him the box (no transfer meaning); recipient must be animate or metaphorically animate
CX2|caused-motion construction|SUBJ V OBJ OBLIQUE_path|X causes Y to move along path Z|3 (agent, theme, path/goal)|She sneezed the napkin off the table.|verb need not be motion verb — construction coerces motion reading; path must be directional PP (into, off, onto, across, out of); *She sneezed the napkin (incomplete without path)
CX3|resultative construction|SUBJ V OBJ RESULT_PHRASE|X causes Y to become Z (change of state via action)|3 (agent, patient, result state)|He hammered the metal flat. / She painted the wall red.|result phrase must be adjective or PP denoting end-state; verb must denote activity causing the state change; *He hammered the metal beautiful (beautiful not achievable by hammering — pragmatic constraint)
CX4|way-construction|SUBJ V POSS way OBLIQUE_path|X moves along path with difficulty or manner implied by V|2 (agent, path)|She elbowed her way through the crowd.|verb slot accepts any manner-of-action verb (elbow, fight, push, joke, bluff); possessive pronoun must agree with subject; construction adds motion meaning not in verb alone
CX5|intransitive motion construction|SUBJ V OBLIQUE_path|X moves along path|2 (mover, path)|The ball rolled into the garden.|verb must be manner-of-motion (roll, slide, bounce, walk, run, swim) or directed motion (go, come, fall, rise); path must be directional PP
CX6|transitive construction|SUBJ V OBJ|X acts on Y|2 (agent, patient)|She broke the vase.|prototypical: agent deliberately acts on patient causing change; metaphorical extension allows non-agentive subjects: Sadness filled the room
CX7|conative construction|SUBJ V at OBJ|X attempts or directs action toward Y without necessarily achieving contact/effect|2 (agent, target)|She kicked at the ball. (vs She kicked the ball.)|limited to verbs of contact/impact (kick, hit, slash, bite, grab); *She broke at the vase (break requires result → incompatible)
CX8|middle construction|SUBJ V (ADVL)|X has property of being V-able in manner described|1 (patient as subject)|This bread cuts easily. / The book reads well.|subject is patient not agent; no agent expressed or implied; requires adverb of manner (easily, well, smoothly); *This bread cuts (ungrammatical without manner adverb); verb must be activity that yields a quality judgment about the patient
CX9|existential construction|There V SUBJ (LOCATIVE)|asserts existence or appearance of X (at location Y)|1–2 (entity, optional location)|There is a cat on the mat. / There arose a great commotion.|there is dummy subject (no referent); real subject follows verb; verb typically be, exist, arise, remain, emerge, develop; definite NPs dispreferred: ?There is the cat on the mat (violates givenness constraint — definite implies already known, but existential introduces new entity)
CX10|possessive-have construction|SUBJ have OBJ|X possesses/experiences/contains Y|2 (possessor, possessed)|She has a car. / He has a headache. / The room has three windows.|polysemous: ownership, kinship (She has two brothers), body state (has a cold), containment (has three rooms), scheduling (has a meeting); object NP determines reading
CX11|light verb construction|SUBJ V_light OBJ_deverbal|V contributes aspect/aktionsart; OBJ carries core meaning|2 (agent, eventive object)|make a decision / take a walk / give a laugh / have a look|verb is semantically bleached (make, take, give, have, do, get); object is deverbal noun; verb choice is collocational not free: make a decision not *do a decision; take a walk not *make a walk; construction allows modification of event noun: make a quick decision (vs *decide quickly in some registers)
CX12|it-cleft construction|It be FOCUS_XP that/who CLAUSE|focus on one constituent; presupposes the rest|2 (focused element, presupposed clause)|It was John who called. / It's the price that bothers me.|focused element receives contrastive or exhaustive focus; presupposed clause is backgrounded (treated as known); cleft creates exhaustive reading: It was John who called implies nobody else called
CX13|wh-cleft (pseudo-cleft)|WH-CLAUSE be FOCUS_XP|focus on the post-copular element; wh-clause is presupposed|2 (presupposed, focused)|What I need is coffee. / What happened was a disaster.|wh-clause must be interpretable as open proposition (gap); focused element fills the gap; wh-cleft foregrounds the focused element more gently than it-cleft
CX14|topicalization construction|TOPIC_XP, SUBJ V ... (gap)|places known/contrastive element sentence-initially for topic management|2 (topic, comment)|Beans, I don't like. / This book, I've already read.|topicalized element is typically given/contrastive (not brand-new information); leaves gap in canonical position; intonation: rise on topic, then normal comment intonation; *A random thing, I saw yesterday (brand-new topic dispreferred)
CX15|left-dislocation|TOPIC_NP, ... PRONOUN_resumptive ...|establishes topic with resumptive pronoun in canonical position|2 (topic, comment with pronoun)|My brother, he never listens. / That restaurant, I went there last week.|resumptive pronoun present (unlike topicalization which has gap); topic NP is referentially accessible; establishes discourse topic; more colloquial than topicalization
CX16|right-dislocation|CLAUSE ... PRONOUN ..., REFERENT_NP|clarifies or afterthoughts referent of pronoun already in clause|2 (clause, clarifying NP)|He never listens, my brother. / I went there last week, that restaurant.|anticlimactic: main information already delivered; NP provides clarification or repair; more spoken than written
CX17|comparative correlative|The MORE/LESS X, the MORE/LESS Y|covariation: as X increases, Y increases (or decreases)|2 (correlating clauses)|The bigger they are, the harder they fall. / The more you practice, the better you get.|requires paired the + comparative; both clauses must contain comparative element; expresses proportional covariation; often proverbial or generalizing
CX18|not-only-but-also construction|Not only X, but also Y|additive scalar: Y adds to X and is at least as noteworthy|2 (base, added)|Not only did she win, but she also set a record.|often triggers subject-auxiliary inversion in first clause (emphatic); scalar implicature: Y is more surprising or important than X
CX19|let-alone construction|NEG X, let alone Y|Y is even less likely/possible than already-negated X|2 (negated base, scalar extreme)|He can't run a mile, let alone a marathon.|scalar: Y is more extreme on the relevant scale than X; X must be negated; Y inherits negation; establishes pragmatic scale
CX20|if-then conditional construction|If P, (then) Q|protasis (condition) and apodosis (consequence)|2 (condition, consequence)|If it rains, we'll cancel.|verb form in protasis determines type: real (present → will), unreal (past → would), counterfactual (past perfect → would have); temporal/causal inference embedded in construction; zero conditional (present/present) for general truths

# argument_roles(id|name|definition|typical_syntactic_position|prototypical_properties|examples)
AR1|agent|entity that intentionally initiates and controls the action|subject|animate, volitional, causally responsible|She opened the door. (she = agent)
AR2|patient|entity undergoing change of state or being affected by action|direct object|inanimate or affected, undergoes change|She broke the vase. (vase = patient)
AR3|theme|entity that moves or is located; or entity whose existence is asserted|direct object or subject (of intransitive)|moves or exists; less affected than patient|The ball rolled down the hill. (ball = theme)
AR4|experiencer|entity that perceives, cognizes, or undergoes psychological state|subject or object (psych-verbs)|animate, sentient, no control over experience|She feared the dark. (she = experiencer) / The noise frightened her. (her = experiencer as object)
AR5|goal|endpoint of motion or transfer|indirect object or oblique PP (to X)|destination, recipient|She sent the letter to him. (him = goal)
AR6|source|origin point of motion or transfer|oblique PP (from X)|point of departure|She drove from Boston. (Boston = source)
AR7|instrument|entity used by agent to perform action|oblique PP (with X) or subject|inanimate, used as tool|She cut the bread with a knife. / The key opened the door.
AR8|beneficiary|entity for whose benefit action is performed|oblique PP (for X) or indirect object in some constructions|animate, benefits|She baked a cake for him. (him = beneficiary)
AR9|stimulus|entity causing psychological state in experiencer|subject (with experiencer-object verbs) or oblique|triggers perception/emotion|The movie bored her. (movie = stimulus)
AR10|location|place where event or state holds|oblique PP (in/at/on X)|spatial reference point|She lives in Paris. (Paris = location)
AR11|path|trajectory of motion|oblique PP (through/along/across X)|spatial extent traversed|She walked through the park. (through the park = path)
AR12|result|end-state achieved by patient/theme through action|post-verbal AP or PP|state arrived at|She hammered the metal flat. (flat = result)
AR13|comitative|entity accompanying the agent|oblique PP (with X)|co-participant|She walked with her dog. (with her dog = comitative)
AR14|possessor|entity that owns or contains another entity|subject of have; genitive determiner|controls or encompasses possessed|She has a car. / Her car broke down.

# slot_constraints(id|construction_fk|slot_name|required_semantic_class|prohibited_semantic_class|additional_constraints|examples_valid|examples_invalid)
# Ditransitive
SC1|CX1|verb|transfer, future-transfer, communication, creation-for-recipient|pure-motion, pure-state, pure-perception|must imply recipient receives or is intended to receive theme|give, send, offer, tell, teach, show, promise, deny, refuse|*carry (no transfer), *push (no transfer), *see (perception)
SC2|CX1|OBJ1 (recipient)|animate entity or metaphorically animate (institution, organization)|inanimate concrete without metaphor|must be capable of receiving or possessing|him, the teacher, the company, the government|*the table, *the floor, *the weather
SC3|CX1|OBJ2 (theme)|transferable entity (concrete or abstract)|—|must be something that can be given, sent, told, etc.|the book, a message, a chance, permission|—
# Caused-motion
SC4|CX2|verb|any activity verb (construction coerces motion meaning)|pure stative verbs (*know, *be, *seem)|activity → motion coercion; verb provides manner|sneeze, kick, push, laugh, shove, waltz, roll|*know, *resemble, *weigh
SC5|CX2|OBJ (theme)|entity capable of motion (concrete preferred; abstract requires metaphor)|—|must be construable as movable|the napkin, the ball, him, the thought (metaphorical)|—
SC6|CX2|OBLIQUE (path/goal)|directional PP: into, onto, off, out of, across, through, over, to, from|locative-only PPs dispreferred without directionality: *at, *in (static)|must indicate direction or endpoint of motion|off the table, into the room, across the field, out the door|*at the table, *in the room (static location, not path)
# Resultative
SC7|CX3|verb|activity verb (hit, hammer, paint, wipe, sing, drive, work)|achievement or state verb without activity phase|must denote action whose continuation or force can cause result|hammer, paint, wipe, scrub, drive, run, work, sing|*arrive (achievement, not activity), *know (state)
SC8|CX3|result_phrase|achievable-by-verb end-state (adjective: flat, clean, dry, open, red; PP: into pieces, to death)|end-state not causally achievable by the verb action|must be pragmatically achievable result of verb action|flat (by hammering), clean (by wiping), red (by painting)|*beautiful (by hammering → pragmatically implausible), *French (by painting)
# Way-construction
SC9|CX4|verb|manner-of-action (elbow, fight, push, joke, bluff, bribe, stumble)|stative; achievement without manner|provides manner or means of difficult progression|elbow, fight, push, joke, bluff, lie, buy, bribe, stumble, weave|*know, *be, *arrive, *find
SC10|CX4|POSS way|possessive pronoun agreeing with subject + way|—|obligatory: POSS must match subject|her way, his way, my way, their way, its way|*the way (without possessive matching subject)
SC11|CX4|OBLIQUE (path)|directional PP indicating trajectory|static location without directionality|motion endpoint or trajectory|through the crowd, into the room, out of trouble, across the field|*in the room (static)
# Existential
SC12|CX9|verb|existence, appearance, emergence, remaining (be, exist, arise, remain, emerge, develop, come, appear, lie, stand)|agentive transitive verbs|must be compatible with existential/presentative semantics|be, exist, arise, remain, emerge, develop, appear, stand, lie, hang|*eat, *build, *destroy, *run
SC13|CX9|SUBJ (postverbal)|indefinite NP or quantified NP (a, some, many, several, three, no)|definite NPs strongly dispreferred unless contrastive/listing|existential introduces new entities → indefiniteness constraint|a cat, some books, three problems, no solution|*the cat (definite → already known → contradicts introducing), *John (proper → already known)
# Middle
SC14|CX8|verb|activity verb (cut, read, wash, sell, drive, play, translate)|stative verb; verb without scalar quality dimension|must describe activity whose patient has inherent quality affecting ease/quality of action|cut, read, wash, sell, drive, play, write, translate, photograph|*exist, *weigh, *cost
SC15|CX8|adverb|manner adverb evaluating quality or ease (easily, well, smoothly, beautifully, poorly, quickly)|—|obligatory: middle without manner adverb is ungrammatical|easily, well, smoothly, nicely, terribly, like a dream|*She cuts this bread. (missing manner → ungrammatical as middle)
# Light verb
SC16|CX11|V_light|semantically bleached verb (make, take, give, have, do, get)|fully semantic verbs|contributes aspect or aktionsart, not core meaning; choice is collocational|make, take, give, have, do, get, put, pay|*construct, *manufacture, *accomplish
SC17|CX11|OBJ_deverbal|deverbal or eventive noun (decision, walk, look, try, attempt, bath, nap)|non-eventive concrete noun without metaphor|must denote event or action; often with a/an|a decision, a walk, a try, a look, a bath, a nap, a start|*a table, *a dog, *a mountain (not eventive)

# phrase_patterns(id|name|form|function|slot_types|ordering_constraints|examples)
PP1|NP modification stack|DET + OPINION + SIZE + AGE + SHAPE + COLOR + ORIGIN + MATERIAL + PURPOSE + NOUN|fully specified noun phrase with stacked pre-modifiers|each slot optional; head noun obligatory|fixed order: opinion before size before age before shape before color before origin before material before purpose|a lovely little old rectangular green French silver whittling knife
PP2|PP attachment (argument)|V + NP + PP_arg|PP completes verb meaning (selected by verb)|verb selects PP type: put requires LOC; give allows to/for; rely requires on|PP follows NP in default order; PP is obligatory|put the book on the table / rely on evidence / consist of parts
PP3|PP attachment (adjunct)|V + (NP) + PP_adjunct|PP adds circumstantial information (time, place, manner, reason)|any verb allows adjunct PPs; multiple PPs stackable|default: manner < place < time (She sang beautifully in the hall yesterday)|She worked in the office on Tuesday for three hours
PP4|VP complementation (infinitive)|V + to-infinitive|main verb takes infinitival complement; subject control or object control|control verb determines whether matrix subject or object is understood as infinitive subject|subject control: She wants to leave (she = leaver); object control: She persuaded him to leave (him = leaver)|want to go, decide to stay, persuade him to leave, expect to win
PP5|VP complementation (gerund)|V + V-ing|main verb takes gerund complement|some verbs take only gerund (enjoy, avoid, deny); some only infinitive (decide, hope); some both with meaning shift (stop, remember, try)|gerund implies ongoing/habitual; infinitive implies future/potential|enjoy swimming, avoid running, deny knowing
PP6|VP complementation (that-clause)|V + (that) + CLAUSE|main verb takes finite clausal complement|verbs of cognition (think, believe, know), communication (say, tell, report), perception (see, notice)|that is optional in informal speech; obligatory after certain verbs (the fact that...)|She thinks (that) he left. / He said (that) it was fine.
PP7|particle shift|V + PARTICLE + NP / V + NP + PARTICLE|phrasal verb with movable particle|pronoun objects must precede particle: pick it up, not *pick up it; full NP: either order|pronoun: V + NP + PART (obligatory); full NP: V + PART + NP (preferred for short NPs) or V + NP + PART (preferred for long NPs)|pick up the book / pick the book up / pick it up / *pick up it
PP8|heavy NP shift|V + (light elements) + PP/ADV + HEAVY_NP|heavy (long/complex) NP shifted rightward past lighter elements|NP must be informationally heavy (new, complex, long); light elements (PP, adverb) precede|She gave to charity all the money she had inherited. (normal: gave all the money she had inherited to charity)|She explained to the committee the complex reasons behind the decision.
PP9|extraposition (sentential subject)|It V_copular/psych ADJ/NP that-CLAUSE / to-INFINITIVE|heavy sentential subject moved to end; dummy it in subject position|obligatory when subject clause is long; optional for short|subject clause is new/asserted information; it is placeholder|It is important that we leave. / It surprised me that he agreed. (vs That we leave is important — grammatical but heavy)
PP10|there-insertion with locative inversion|LOC_PP V SUBJ|locative PP fronted; subject follows verb; no dummy there|verb must be intransitive (be, stand, sit, hang, lie, live, grow); subject is typically indefinite|locative PP provides scene-setting given information; subject is new|On the hill stood a castle. / Under the bridge lived a troll. / In the corner sat a cat.
PP11|absolute phrase|NP + PARTICIPLE/ADJ/PP, MAIN_CLAUSE|provides circumstantial background; syntactically independent of main clause|NP in absolute must differ from main clause subject; participle or adjective modifies absolute NP|absolute precedes or follows main clause; provides time, cause, or accompanying circumstance|Her hands trembling, she opened the letter. / The work done, they left. / Weather permitting, we'll go.

# information_structure(id|name|definition|marking_mechanism|default_position|examples)
IS1|topic|what the sentence is about; given or accessible information; establishes referential frame|sentence-initial position (default); left-dislocation; topicalization; as-for X|sentence-initial|As for the budget, we need to cut it. / The old house, it finally sold.
IS2|comment|what is said about the topic; new information predicated of the topic|everything after topic (in topic-comment structure)|follows topic|[The cat]_topic [sat on the mat]_comment.
IS3|focus|most informative part of sentence; new or contrastive information; answers implicit question|prosodic prominence (nuclear stress); cleft construction; focus particle (only, even, just)|sentence-final in neutral declarative (end-focus); various in marked|She bought a CAR. (neutral: focus on car) / It was a CAR that she bought. (cleft focus) / She only bought a CAR. (focus particle)
IS4|given information|information already activated in discourse or shared knowledge; deaccented prosodically|definite NPs; pronouns; deaccented phrases; ellipsis|tends toward sentence-initial|She saw a dog. The dog was barking. (the dog = given)
IS5|new information|information not yet activated; bears prosodic prominence|indefinite NPs; stressed; end-position (end-focus principle)|sentence-final (default)|She bought [a new car]_new.
IS6|contrastive focus|explicitly contrasts with alternative(s); stronger prosodic prominence; may trigger inversion or cleft|heavy stress; cleft; contrastive left-dislocation; focus particle (not X but Y)|variable (wherever contrast is needed)|She didn't buy a HOUSE. She bought a CAR. / It's JOHN I want to see, not Mary.
IS7|background|information presupposed or taken for granted; not foregrounded|relative clauses; temporal clauses; cleft presupposition; because-clauses when non-focal|subordinate positions|The man [who lives next door]_background is a teacher. / It was John who called — [that someone called]_background is presupposed.
IS8|end-weight principle|longer/heavier constituents tend to be placed later in the sentence|heavy NP shift; extraposition; PP ordering (long before short dispreferred)|complex/long elements → sentence-final|She gave the prize to the student who had written the best essay. (not: She gave the student who had written the best essay the prize.)
IS9|end-focus principle|newest/most important information tends to occur at the end of the information unit|default nuclear stress falls on last lexical item in tone unit; rearrangement to shift focus|nuclear stress on final content word|She drove to LONDON. (London = new information, end-focus) / To LONDON she drove. (London still focused but now marked/emphatic)

# discourse_functions(id|name|definition|constructions_used|effect|examples)
DC1|scene-setting|establishes time, place, or circumstance before main assertion|fronted adverbial PP/clause; absolute phrase; temporal clause|grounds the assertion in context; given → new flow|In the early morning, the birds began to sing. / After the rain stopped, we went outside.
DC2|topic-shift|introduces new topic; redirects discourse|as for X; speaking of X; left-dislocation; full NP (not pronoun) in subject position|signals to listener that referential frame is changing|As for your proposal, I have some concerns. / Now, the second issue is funding.
DC3|elaboration|adds detail to previously established point|appositive NP; non-restrictive relative clause; parenthetical; namely/that is/in other words|enriches without changing topic|The CEO, a former engineer, redesigned the product. / She speaks three languages — namely, English, French, and Mandarin.
DC4|contrast|highlights difference between two elements|but, however, on the other hand, while, whereas; cleft; contrastive focus|creates oppositional frame; activates alternative set|He wanted to stay, but she wanted to leave. / While the north froze, the south baked.
DC5|concession|acknowledges counterpoint before asserting main claim|although, even though, admittedly, granted, while; yes...but pattern|shows awareness of opposing view; strengthens main claim by addressing objection|Although the evidence is limited, the trend is clear. / Granted, the cost is high, but the return justifies it.
DC6|hedging|reduces speaker commitment to proposition; softens assertion|modal verbs (might, could, may); epistemic adverbs (perhaps, probably, possibly); I think/believe; seem/appear; sort of, kind of|manages face; expresses uncertainty; avoids over-commitment|This might be a problem. / It seems that the data suggests a trend. / She's sort of an expert.
DC7|intensification|strengthens assertion; increases force|very, extremely, absolutely, completely, utterly; emphatic do (She DID leave); degree modifiers; hyperbole|adds force; conveys speaker's strong stance|This is absolutely essential. / She did finish the project. / I've told you a million times.
DC8|mitigation|softens potentially face-threatening act (request, criticism, disagreement)|indirect speech act; past tense for politeness (I wondered if...); conditional (Would you mind...); minimizers (just, a little, slightly)|reduces imposition; maintains social harmony|I was wondering if you could help. / Could you possibly move? / It's just a small point.
DC9|evidentiality|signals source of information; marks epistemic status|reportedly, apparently, allegedly, I hear that, according to X; seem/appear; hearsay markers|distinguishes firsthand knowledge from reported/inferred|Apparently, the meeting was cancelled. / She reportedly left early. / According to the report, costs have risen.
DC10|repair|corrects or refines previous utterance|I mean, that is to say, or rather, well actually, more precisely|maintains coherence after misstatement or imprecision|She arrived at noon — or rather, just after noon. / He's a doctor — well, a resident, actually.

# pragmatic_markers(id|name|position|function|register|examples)
PM1|well|turn-initial|signals upcoming dispreferred response, hesitation, topic shift, or self-repair|spoken, informal|Well, I'm not sure about that. / Well, that's one way to look at it.
PM2|you know|mid-sentence or turn-final|appeals to shared knowledge; softens; holds floor|spoken, informal|It's, you know, not exactly what I expected.
PM3|I mean|mid-sentence|self-repair; clarification; reformulation|spoken, informal to neutral|She's smart — I mean, she's brilliant.
PM4|actually|sentence-initial or mid|counter-expectation; polite contradiction; updating shared knowledge|spoken and written, neutral|Actually, I think the deadline is Friday. / She's actually quite experienced.
PM5|so|turn-initial|summarizes; draws conclusion; initiates new topic or action|spoken, informal to neutral|So, what do we do now? / So, the results suggest a problem.
PM6|now|turn-initial|signals topic shift or new phase; draws attention|spoken, neutral to formal|Now, let's turn to the second question. / Now, I want to be clear about this.
PM7|right|turn-final or tag|seeks confirmation; checks understanding; holds floor|spoken, informal|We're meeting at three, right? / So you need the report by Friday, right?
PM8|like|mid-sentence|approximation; quotative (like, "..."); hedge; filler|spoken, very informal|She was like, "No way." / It costs like fifty dollars. / I was like totally confused.
PM9|just|pre-verbal or pre-nominal|minimizer (reduces imposition); restrictor (only); emphatic (just perfect)|spoken and written, all registers|Could you just sign here? (minimizer) / I just want one. (restrictor) / That's just wonderful. (emphatic/sarcastic)
PM10|literally|pre-adjectival or pre-verbal|emphatic intensifier (informal, often hyperbolic) or true literal meaning (formal)|spoken and written, informal (intensifier) to formal (literal)|I literally couldn't move. (intensifier) / The word literally means "by the letter." (literal)
PM11|of course|sentence-initial or parenthetical|marks information as obvious or expected; concessive; politeness|spoken and written, neutral to formal|Of course, you're welcome to join. / She was, of course, the best candidate.
PM12|in fact|sentence-initial or mid|strengthens previous assertion; introduces surprising or contrary information|written and spoken, neutral to formal|She wasn't upset. In fact, she was delighted. / The plan worked. In fact, it exceeded expectations.

# collocations(id|pattern|type|correct_collocation|incorrect_alternative|semantic_domain|notes)
CL1|MAKE + decision/mistake/progress/effort/attempt/money/point/suggestion/promise|V+N (light verb)|make a decision|*do a decision, *take a decision (BrE: take acceptable)|action/cognition|make = creation/production metaphor; most productive light verb for abstract events
CL2|TAKE + walk/bath/look/break/step/chance/risk/turn/seat/responsibility|V+N (light verb)|take a walk|*make a walk, *do a walk|action/experience|take = undertaking/experiencing metaphor; implies volition
CL3|DO + work/homework/research/business/damage/favor/dishes/laundry|V+N (light verb)|do the work|*make the work|activity/task|do = performing an activity; used for tasks and jobs
CL4|HAVE + look/rest/drink/meal/conversation/meeting/effect/impact/time|V+N (light verb)|have a look|*take a look (acceptable in some dialects); *make a look|experience|have = experiencing; neutral
CL5|GIVE + speech/lecture/performance/impression/advice/permission/rise to|V+N (light verb)|give a speech|*make a speech (acceptable); *do a speech|communication/transfer|give = transfer metaphor; applies to communicative and enabling acts
CL6|ADJ + N (gradability collocation)|ADJ+N|strong tea, heavy rain, high temperature, deep sleep, wide range|*powerful tea, *big rain, *tall temperature, *low sleep, *broad range|degree/intensity|adjective choice for intensity is arbitrary and collocational, not predicted by grammar or semantics alone
CL7|ADV + ADJ (intensifier collocation)|ADV+ADJ|deeply concerned, highly unlikely, bitterly disappointed, painfully aware, wildly inaccurate|*deeply unlikely, *highly concerned, *bitterly inaccurate|intensification|intensifying adverb + adjective pairs are lexically restricted; not free combination
CL8|V + PP (prepositional collocation)|V+PP|depend on, consist of, result in, account for, comply with, refer to, insist on|*depend of, *consist in (different meaning), *result from (different meaning), *insist at|verb-preposition|preposition is selected by verb; changing preposition changes meaning or produces error
CL9|N + N compound (stress pattern)|N+N|BLACKbird (compound: species) vs black BIRD (phrase: dark-colored bird); GREENhouse (compound: building) vs green HOUSE (phrase)|—|compounding|stress on first element = compound (lexicalized, often specialized meaning); stress on second = normal phrase; semantic compositionality decreases in compounds
CL10|COMMIT + crime/murder/suicide/sin/act/offense/error|V+N|commit a crime|*do a crime (informal but non-standard); *make a crime|transgression|commit collocates with transgressions and binding acts; highly restricted
CL11|HEAVY + traffic/smoker/drinker/rain/workload/accent/losses/criticism|ADJ+N|heavy traffic|*strong traffic, *thick traffic (except in some varieties)|degree (metaphorical weight)|heavy metaphorically = burdensome, intense, large quantity; but not freely productive — *heavy sunshine

# idiom_patterns(id|name|form|meaning|compositionality|fixedness|transformability|examples)
ID1|fully fixed idiom|frozen form; no syntactic variation|non-compositional: meaning not derivable from parts|zero: kick the bucket ≠ kick + the + bucket|word order, article, number all fixed|no passivization, no modification, no relative clause: *The bucket was kicked by him; *kick the old bucket|kick the bucket (= die), bite the bullet (= endure), spill the beans (= reveal secret)
ID2|semi-fixed idiom|some variation possible (tense, aspect, negation)|partially compositional: some literal connection remains|partial: break the ice → ice = social barrier (metaphorical but traceable)|tense varies (broke/breaking the ice); determiner fixed (the)|limited transformation: The ice was broken (passive acceptable for some); *break some ice|break the ice, pull strings, burn bridges, rock the boat
ID3|constructional idiom|schematic pattern with open slots|meaning from construction + slot fillers; productive|construction-level: X's way through Y (difficulty of motion)|slot-filling constrained; construction frame fixed|open slots allow creativity: She joked her way into the job / He bribed his way through customs|the X-er the Y-er; X let alone Y; X's way through Y; no sooner X than Y
ID4|binomial idiom|X and Y (fixed or semi-fixed pair)|meaning may be compositional but order is frozen|varies: bread and butter (transparent), odds and ends (opaque)|order irreversible: *butter and bread; *ends and odds; sometimes alliterative/rhythmic|no reversal; no insertion|bread and butter, trial and error, give and take, pros and cons, odds and ends, hustle and bustle
ID5|simile frame|as ADJ as NP|comparison to stereotypical exemplar; often hyperbolic|partially compositional: as cold as ice (traceable); as dead as a doornail (less traceable)|NP is conventionalized: *as cold as snow (non-standard pairing)|ADJ can be varied only if pairing is conventional; NP is frozen|as cold as ice, as blind as a bat, as quick as a flash, as stubborn as a mule
ID6|phrasal verb idiom|V + PARTICLE with non-compositional meaning|non-compositional: meaning of combination ≠ verb + particle|varies: look up (= search, not look upward); give up (= surrender); break down (= fail)|particle fixed to verb|particle shift applies (looked it up); but meaning shift distinguishes: look up the word (search) vs look up the chimney (literal)|look up, give up, break down, figure out, turn out, come across, get over

# register_patterns(id|register|formality|typical_constructions|typical_vocabulary|typical_sentence_length|examples)
RP1|academic prose|very formal|passive (was investigated); nominalization (the investigation of X); hedging (tend to, appear to, it is suggested that); impersonal subjects (it, this); complex NP (the previously mentioned...; the degree to which...)|Latinate vocabulary; technical terminology; abstract nouns; cautious verbs (suggest, indicate, demonstrate)|long (25–40 words average)|The results suggest that further investigation into the relationship between X and Y is warranted.
RP2|legal prose|very formal|passive; shall for obligation; defined terms (capitalized); conditional chains (if...then...provided that...unless); nominalization; archaic (herein, thereof, notwithstanding)|archaic terms; technical legal; doublets (null and void, cease and desist)|very long (30–60+ words)|The Party shall indemnify and hold harmless the Company from and against any and all claims arising out of or related to the performance of this Agreement.
RP3|journalism (news)|formal to neutral|short sentences; inverted pyramid (most important first); attribution (said, according to); present tense headlines; passive for unknown agent; direct quotes|concrete vocabulary; active verbs; minimal hedging; attribution verbs|medium (15–25 words)|The president signed the bill into law Tuesday, ending months of debate.
RP4|conversational (informal)|informal|fragments (Nice one. / Sounds good.); ellipsis (Want some?); contractions (I'm, don't, can't); tag questions (right?, eh?); discourse markers (so, well, like, you know); vague language (stuff, thing, whatever)|common words; slang; vague nouns; intensifiers (totally, super)|short (5–15 words)|So I was like, "No way," and she goes, "Way."
RP5|instructional/procedural|neutral to formal|imperative (Preheat the oven.); sequential markers (first, next, then, finally); second person (you); conditionals (if the light flashes...); present tense|action verbs; concrete nouns; measurement terms|short to medium (8–20 words)|First, remove the cover. Then, disconnect the power cable. If the LED is red, wait 30 seconds.
RP6|literary/narrative|variable (formal to informal within)|past tense (narrative past); free indirect discourse (She wondered if he would come back.); metaphor; varied sentence length; show-don't-tell; dialogue with said/asked|varied; figurative; sensory; specific over general|highly variable (5–60+ words)|The rain hammered the windows like fists, and she pulled the blanket tighter, wondering if morning would ever come.
RP7|technical/engineering|neutral to formal|passive or imperative; numbered steps; conditional; specification (shall, must, should per RFC 2119); present tense (describes system behavior)|precise terminology; abbreviations; units; specification language|medium (15–25 words)|The system shall respond within 200 ms. If the sensor reading exceeds 5.0 V, the controller triggers a fault.

# metaphor_frames(id|source_domain|target_domain|mappings|linguistic_evidence|constraints)
MF1|WAR|ARGUMENT|positions = claims; attack = criticize; defend = support; retreat = concede; shoot down = reject; ammunition = evidence; ally = supporter|He attacked my position. / She defended her thesis. / That argument is indefensible. / His claims were shot down.|limited to adversarial argumentation; not used for collaborative discussion: *We allied our ideas together
MF2|JOURNEY|LIFE|path = life course; crossroads = decision point; obstacles = difficulties; destination = goal; companion = partner; lost = confused/purposeless|She's at a crossroads. / He's lost his way. / We've come a long way. / Life is a journey.|agent must be sentient entity living a life; not used for objects: *The rock reached a crossroads
MF3|MONEY|TIME|spend = use; waste = use poorly; save = preserve; invest = use for future benefit; budget = plan; cost = require; buy = gain|Don't waste my time. / She invested years in that project. / Can you spare a minute? / That will cost you an hour.|time cannot be physically transferred: *She gave him three hours (of her life, metaphorically works; of physical time, doesn't); time doesn't earn interest
MF4|CONTAINER|MIND/EMOTIONS|in = experiencing; out = not experiencing; full = overwhelmed; empty = lacking; bottled up = suppressed; overflow = lose control; pour out = express|She's in love. / He fell into despair. / I'm full of ideas. / She poured out her feelings. / He bottled up his anger.|emotions enter and leave; mind can be full or empty; contents can overflow; but: *She unscrewed her emotions (physical container mechanics don't fully transfer)
MF5|BUILDING|THEORY/ARGUMENT|foundation = base assumptions; construct = create; structure = organization; framework = organizing principle; collapse = fail; support = evidence; pillar = key component|The theory has a solid foundation. / The argument collapsed under scrutiny. / This evidence supports the framework.|used for abstract systems requiring structural integrity; not for emotions: *She built a happiness
MF6|MACHINE|BODY/ORGANIZATION|running = functioning; broken down = failing; well-oiled = efficient; gears = processes; fuel = energy; overheated = stressed; shutdown = stop working|The government is running smoothly. / He's running on empty. / The team is a well-oiled machine.|agent can be individual or organization; used for functional state, not emotional: *Her sadness broke down (wrong — body breaks down, not emotions via machine metaphor)
MF7|SPATIAL (UP/DOWN)|QUANTITY/STATUS/EMOTION|up = more/good/happy/high-status; down = less/bad/sad/low-status|Prices went up. / She's feeling down. / He climbed the ranks. / Spirits are high. / Standards fell.|pervasive: almost all scalar properties can use up/down; but physical orientation must be ignorable: The price of oil rose (not physically spatial)
MF8|LIQUID/FLOW|INFORMATION/COMMUNICATION|flow = transmission; channel = medium; stream = continuous data; flood = too much; trickle = too little; dry up = stop; filter = select; leak = unauthorized release|Information flowed freely. / The news leaked. / Data streams into the server. / Communications dried up.|requires continuous rather than discrete information; *The single fact flowed (single discrete items don't flow naturally)
MF9|PLANT/GROWTH|IDEAS/ORGANIZATIONS|seed = initial idea; root = origin/foundation; branch = subdivision; flourish = succeed; wither = decline; cultivate = develop; bear fruit = produce results; prune = remove excess|The idea took root. / The organization flourished. / Her efforts bore fruit. / They pruned the department.|growth must be gradual and organic; not for sudden events: *The idea exploded into a tree
MF10|FOOD/TASTE|IDEAS/EXPERIENCE|digest = understand; appetite = desire; taste = preference; swallow = accept reluctantly; half-baked = underdeveloped; raw = unprocessed; spice up = make interesting|I can't digest all this information. / That's a half-baked idea. / She has no appetite for risk. / Let me chew on that.|used for processing and evaluating; not for creating: *She cooked an idea (possible but rare/humorous)

# speech_acts(id|name|type|form|felicity_conditions|indirect_forms|examples)
SA1|assertion|representative|declarative sentence|speaker believes proposition; evidence available|—|The meeting is at three. / Water boils at 100°C.
SA2|question (information)|directive|interrogative (wh- or yes/no)|speaker doesn't know answer; believes hearer does|Can you tell me...; I was wondering...; Do you happen to know...|What time is the meeting? / Is John coming?
SA3|request|directive|imperative; interrogative; declarative|speaker wants hearer to do something; hearer is able; act is not in hearer's normal course|Could you...; Would you mind...; I'd appreciate it if...; declarative: The trash needs taking out.|Pass the salt. / Could you open the window? / I was wondering if you could help me with this.
SA4|command|directive|imperative; performative declarative|speaker has authority; hearer is obligated|shall (legal); must (regulatory)|Stop. / You will report to base at 0800. / The defendant shall appear on the stated date.
SA5|promise|commissive|performative declarative; future declarative|speaker intends to do act; act benefits hearer; speaker able|guarantee, assure, commit to|I promise I'll be there. / I will finish by Friday. / You have my word.
SA6|offer|commissive|interrogative; conditional; declarative|speaker willing and able; act benefits hearer|Can I...; Shall I...; Would you like me to...; Let me...|Can I help you? / Shall I carry that? / Let me get the door.
SA7|apology|expressive|performative: I apologize / I'm sorry; explanation|speaker regrets act; act affected hearer negatively|I'm afraid...; Sorry about...; I shouldn't have...|I'm sorry I'm late. / I apologize for the confusion. / My mistake — I should have checked.
SA8|compliment|expressive|declarative (evaluative)|speaker positively evaluates hearer's quality/possession/achievement|What a...; I love...; That's a great...|Nice work on the presentation. / What a lovely garden! / I love your shoes.
SA9|refusal|commissive (negative)|declarative; hedged|speaker will not do requested act|I'm afraid I can't...; I wish I could but...; Unfortunately...; That's not going to work for me.|I'm afraid I can't make it. / I wish I could, but I'm already committed. / I'll have to pass on that.
SA10|invitation|directive/commissive|interrogative; imperative; declarative|speaker wants hearer to attend/participate; speaker has authority to invite|Would you like to...; Why don't you...; You're welcome to...; Come...|Would you like to join us for dinner? / Come over anytime. / You're welcome to use the office.
SA11|warning|directive|imperative; declarative; conditional|speaker believes danger exists; hearer is unaware; information benefits hearer|Be careful...; Watch out...; I should mention that...; You might want to...|Watch out for the step. / I should warn you, the deadline is strict. / If you don't backup, you'll lose everything.

# coherence_relations(id|name|definition|typical_markers|unmarked_default|examples)
CR1|cause-effect|first element causes second|because, since, as, so, therefore, consequently, as a result, hence, thus|cause before effect OR effect before cause (both unmarked)|The bridge collapsed because the supports corroded. / The supports corroded, so the bridge collapsed.
CR2|temporal sequence|events in time order|then, next, after, before, subsequently, following, once, when|first-event first (iconic order)|She opened the door and walked in. / After dinner, we went for a walk.
CR3|contrast|two elements differ on relevant dimension|but, however, whereas, while, on the other hand, in contrast, yet, although|juxtaposition alone can signal contrast|He's tall but she's short. / The north is industrial; the south is agricultural.
CR4|elaboration|second element provides more detail about first|specifically, in particular, namely, for example, for instance, that is, in other words|apposition or relative clause (no marker needed)|The test failed — specifically, the connection timed out. / She enjoys music, particularly jazz.
CR5|concession|acknowledges counterpoint; main assertion stands despite it|although, even though, despite, in spite of, admittedly, granted, nonetheless, nevertheless|concessive before main (typical), or after|Although the evidence is weak, the conclusion holds. / The cost is high. Nevertheless, the project should proceed.
CR6|condition|one element depends on other holding|if, unless, provided that, as long as, on condition that, supposing, in case|protasis before apodosis (typical)|If you heat water to 100°C, it boils. / Unless you object, I'll proceed.
CR7|purpose|action performed for a goal|to, in order to, so that, so as to, for the purpose of|purpose clause after main (typical)|She left early to catch the train. / He spoke slowly so that everyone could understand.
CR8|addition|second element adds to first on same dimension|and, also, moreover, furthermore, in addition, besides, additionally|simple conjunction (and) or juxtaposition|She speaks French and German. / Moreover, the study was replicated in three countries.
CR9|reformulation|second element restates first differently|in other words, that is, put differently, to put it another way, i.e.|—|The system is idempotent — in other words, running it twice produces the same result as running it once.
CR10|exemplification|second element gives instance of first|for example, for instance, such as, including, like (informal), e.g.|—|Several factors contributed — for example, poor planning and inadequate funding.
CR11|summary|second element synthesizes preceding discourse|in summary, to sum up, in conclusion, in short, overall, all in all|—|In short, the project succeeded despite significant challenges.
CR12|result|second element is consequence but emphasizes the outcome over the cause|so, therefore, as a result, consequently, hence, accordingly|effect follows cause|The road was icy, so we drove slowly. / The experiment failed; consequently, the hypothesis was revised.

# prosodic_patterns(id|name|pattern|function|context|examples)
PR1|neutral declarative|falling nuclear tone on last content word (end-focus)|unmarked assertion; new information at end|default for statements|She drove to ↘LONDON.
PR2|yes/no question|rising nuclear tone at end|signals question requiring yes/no answer|yes/no interrogative|Are you ↗COMING?
PR3|wh-question|falling nuclear tone on wh-word or last content word|signals open question|wh-interrogative|↘WHERE did you go? / Where did you ↘GO?
PR4|contrastive stress|heavy stress on contrasted element, deaccenting given material|signals contrast with an alternative|correction, contrast|She drove to ↘LONDON, not ↘PARIS.
PR5|list intonation|rising on each item; final item falling|signals incomplete list (rising) or completed list (final fall)|enumeration|We need ↗eggs, ↗butter, and ↘flour.
PR6|tag question (seeking confirmation)|main clause falling; tag rising|speaker expects confirmation but genuinely asks|moderate certainty|She's coming, ↗ISN'T she?
PR7|tag question (expecting agreement)|main clause falling; tag falling|speaker expects agreement; rhetorical|high certainty|Nice day, ↘ISN'T it.
PR8|implication contour|rise-fall on focused element|conveys the speaker knows more; insinuation; "you know what I mean"|innuendo, shared knowledge|She was THERE, if you know what I ↗↘MEAN.
PR9|parenthetical/aside|lower pitch, faster tempo, compressed range|signals backgrounded or supplementary material|non-restrictive clauses, asides, discourse markers|The company — (which was founded in 1990) — has grown rapidly.
PR10|vocative calling contour|high level + step down|summons addressee|calling someone's attention|↑JOHN. / ↑MA‑ ↓ry.

# concepts(id|name|definition|category)
CN1|construction|learned pairing of form and meaning at any level of complexity (morpheme, word, phrase, clause, discourse pattern); not derivable from parts alone; constructions are the grammar|foundation
CN2|coercion|construction forces non-prototypical word into a compatible reading; caused-motion construction coerces sneeze into motion event; container coerces mass noun into countable (three coffees)|mechanism
CN3|compositionality (partial)|meaning of whole = meaning of parts + meaning of construction; constructions add meaning beyond word meanings; partial compositionality is the norm|principle
CN4|slot constraint|semantic restriction on what can fill a position in a construction; goes beyond syntactic category (noun, verb) to require specific semantic class (transfer verb, animate recipient, directional PP)|mechanism
CN5|information packaging|speaker's choice of how to present proposition — which part is topic, which is focus, which is backgrounded — determines construction selection|principle
CN6|end-focus|tendency to place new/important information at end of clause; driven by processing (listener expects new info last)|principle
CN7|end-weight|tendency to place longer/heavier constituents at end of clause; reduces processing load|principle
CN8|given-before-new|tendency to place given/accessible information before new information; establishes referential grounding before adding content|principle
CN9|collocational restriction|conventionalized co-occurrence of specific words; not predicted by grammar or meaning alone; strong tea, make a decision, deeply concerned; must be learned as pairs|mechanism
CN10|semantic prosody|word's habitual association with positive or negative contexts affects its meaning beyond denotation; cause tends to collocate with negative events (cause damage, cause problems); commit collocates with transgressions|mechanism
CN11|register|variety of language defined by situation of use (field, tenor, mode); determines construction choice, vocabulary, and phrasing conventions|mechanism
CN12|conceptual metaphor|systematic mapping from concrete source domain to abstract target domain; constrains which phrasings are natural; ARGUMENT IS WAR predicts attack, defend, shoot down|mechanism
CN13|scalar implicature|pragmatic inference based on scale: using weaker term implies stronger does not hold; some implies not all; warm implies not hot; let alone construction exploits scales|mechanism
CN14|indirect speech act|utterance whose literal meaning differs from intended illocutionary force; Can you pass the salt? is literally question but intended as request; conventionalized indirectness|mechanism
CN15|presupposition|information taken for granted as background; survives negation; cleft presupposes the open proposition; even presupposes the proposition is unexpected|mechanism
CN16|face|speaker's and hearer's public self-image (positive face: desire for approval; negative face: desire for autonomy); politeness strategies manage threat to face|principle
CN17|iconicity|form mirrors meaning: temporal sequence of clauses mirrors temporal sequence of events (veni, vidi, vici); quantity of form mirrors quantity of meaning (a looong time)|principle
CN18|constructional polysemy|single construction has related but distinct meanings; ditransitive: transfer (give him the book), intended transfer (bake him a cake), refusal-of-transfer (deny him access)|mechanism

# relationships(from|rel|to)
# domain hierarchy
DM1|enables|DM2
DM1|enables|DM7
DM1|enables|DM8
DM2|enables|DM3
DM3|enables|DM5
DM4|enables|DM3
DM4|enables|DM6
DM7|part_of|DM1
DM8|part_of|DM4
# construction → slot constraint
CX1|contains|SC1,SC2,SC3
CX2|contains|SC4,SC5,SC6
CX3|contains|SC7,SC8
CX4|contains|SC9,SC10,SC11
CX8|contains|SC14,SC15
CX9|contains|SC12,SC13
CX11|contains|SC16,SC17
# construction → argument role mapping
CX1|requires|AR1,AR5,AR3
CX2|requires|AR1,AR3,AR11
CX3|requires|AR1,AR2,AR12
CX4|requires|AR1,AR11
CX5|requires|AR3,AR11
CX6|requires|AR1,AR2
CX7|requires|AR1,AR3
CX8|requires|AR2
CX9|requires|AR3
CX10|requires|AR14
CX11|requires|AR1
CX12|requires|IS3,IS7
CX13|requires|IS3,IS7
CX14|requires|IS1,IS6
CX15|requires|IS1
CX17|requires|IS3
CX20|requires|CR6
# construction specialization
CX7|specializes|CX6
CX12|specializes|CX9
CX13|specializes|CX9
CX18|specializes|CR8
CX19|specializes|CR3
CX17|specializes|CR1
# coercion
CN2|enables|CX2
CN2|enables|CX4
CN2|enables|CX3
# information structure → construction mapping
IS3|enables|CX12
IS3|enables|CX13
IS1|enables|CX14
IS1|enables|CX15
IS1|enables|CX16
IS6|enables|CX12
IS8|enables|PP8
IS8|enables|PP9
IS9|enables|PR1
CN6|equivalent_to|IS9
CN7|equivalent_to|IS8
CN8|enables|IS4
CN5|enables|IS1,IS3
# phrase pattern → information structure
PP7|determined_by|IS8
PP8|determined_by|IS8
PP9|determined_by|IS8
PP10|requires|IS5
PP11|extends|DC1
# discourse function → construction
DC1|requires|PP3
DC2|requires|CX14
DC2|requires|CX15
DC3|requires|PP11
DC4|requires|CR3
DC5|requires|CR5
DC6|requires|PM1,PM8
DC7|requires|PM10,PM12
DC8|requires|SA3
DC9|requires|PM4
DC10|requires|PM3
# pragmatic marker → discourse function
PM1|enables|DC6
PM1|enables|DC2
PM3|enables|DC10
PM4|enables|DC9
PM5|enables|DC2
PM5|enables|CR11
PM6|enables|DC2
PM7|enables|SA2
PM9|enables|DC8
PM12|enables|DC7
# collocation → light verb construction
CL1|instance_of|CX11
CL2|instance_of|CX11
CL3|instance_of|CX11
CL4|instance_of|CX11
CL5|instance_of|CX11
# collocation → collocational constraint
CL6|instance_of|CN9
CL7|instance_of|CN9
CL8|instance_of|CN9
CL9|instance_of|CN9
CL10|instance_of|CN9
CL11|instance_of|CN9
# idiom fixedness hierarchy
ID1|specializes|ID2
ID2|specializes|ID3
ID4|specializes|ID1
ID5|specializes|ID3
ID6|specializes|ID2
# metaphor → phrasing constraint
MF1|enables|DM8
MF2|enables|DM8
MF3|enables|DM8
MF4|enables|DM8
MF5|enables|DM8
MF6|enables|DM8
MF7|enables|DM8
MF8|enables|DM8
MF9|enables|DM8
MF10|enables|DM8
MF7|generalizes|MF1,MF2,MF3
# speech act → indirect form
SA3|enables|CN14
SA2|enables|CN14
SA9|requires|CN16
SA8|requires|CN16
SA6|requires|CN16
SA10|requires|CN16
SA11|requires|CR6
# coherence → discourse
CR1|enables|DM5
CR2|enables|DM5
CR3|enables|DM5
CR4|enables|DM5
CR5|enables|DM5
CR6|enables|DM5
CR7|enables|DM5
CR8|enables|DM5
CR12|specializes|CR1
CR9|specializes|CR4
CR10|specializes|CR4
# prosody → information structure
PR1|determined_by|IS9
PR4|determined_by|IS6
PR6|enables|SA2
PR7|enables|SA1
PR9|determined_by|IS7
# register → construction preference
RP1|requires|CX8
RP1|requires|PP9
RP1|requires|DC6
RP2|requires|CX20
RP3|requires|CR2
RP4|requires|PM2,PM8
RP4|enables|ID6
RP5|requires|SA4
RP5|requires|CR2
RP6|requires|MF1,MF2,MF4
RP7|requires|SA4
# concept foundations
CN1|enables|CN2
CN1|enables|CN3
CN1|enables|CN4
CN1|enables|CN18
CN4|enables|SC1
CN4|enables|SC4
CN4|enables|SC7
CN4|enables|SC12
CN4|enables|SC14
CN4|enables|SC16
CN9|enables|CL1,CL6,CL7,CL8
CN10|enables|CL10
CN12|enables|MF1,MF2,MF3,MF4,MF5,MF6,MF7,MF8,MF9,MF10
CN13|enables|CX19
CN14|enables|SA3,SA6
CN15|enables|CX12,CX13
CN16|enables|DC8,SA9
CN17|enables|CR2

# section_index(section|title|ids)
1|Domains|DM1-DM8
2|Constructions (Argument Structure and Beyond)|CX1-CX20
3|Argument Roles|AR1-AR14
4|Slot Constraints|SC1-SC17
5|Phrase Patterns|PP1-PP11
6|Information Structure|IS1-IS9
7|Discourse Functions|DC1-DC10
8|Pragmatic Markers|PM1-PM12
9|Collocations|CL1-CL11
10|Idiom Patterns|ID1-ID6
11|Register Patterns|RP1-RP7
12|Metaphor Frames|MF1-MF10
13|Speech Acts|SA1-SA11
14|Coherence Relations|CR1-CR12
15|Prosodic Patterns|PR1-PR10
16|Core Concepts|CN1-CN18
17|Relationships|all

# decode_legend
id_prefixes: DM=domain, CX=construction, AR=argument_role, SC=slot_constraint, PP=phrase_pattern, IS=information_structure, DC=discourse_function, PM=pragmatic_marker, CL=collocation, ID=idiom_pattern, RP=register_pattern, MF=metaphor_frame, SA=speech_act, CR=coherence_relation, PR=prosodic_pattern, CN=concept
rel_types: enables|requires|prevents|specializes|generalizes|part_of|contains|follows|precedes|instance_of|determined_by|equivalent_to|extends|derived_from|composed_of
notation: _fk=foreign key; SUBJ=subject; V=verb; OBJ=direct object; OBJ1/OBJ2=first/second object; OBLIQUE=oblique complement (typically PP); PP=prepositional phrase; NP=noun phrase; AP/AdjP=adjective phrase; VP=verb phrase; ADV/ADVL=adverb/adverbial; DET=determiner; POSS=possessive; XP=any phrase; ADJ=adjective; N=noun; *=ungrammatical; ?=marginal; ↗=rising intonation; ↘=falling intonation; ↑=high pitch; ↓=step down; BrE=British English; V+N=verb-noun collocation; ADJ+N=adjective-noun collocation; V+PP=verb-preposition collocation; ADV+ADJ=adverb-adjective collocation; FSM=finite state machine; IS=information structure (context-dependent: disambiguate from initials by table context)
confidence: all patterns described are well-attested in English linguistics literature (Goldberg 1995, 2006; Fillmore et al. 1988; Halliday 1994; Lakoff & Johnson 1980; Levinson 1983; Biber et al. 1999; Sinclair 1991); individual examples may vary by dialect and register; all facts at reference_linguistics confidence level
scope: Modern Standard English phrasing patterns; covers construction grammar, argument structure, information structure, pragmatics, discourse, register, collocation, metaphor, and prosody; complements the English Grammar compact (which covers syntax and morphology) by adding the constraint layer that determines which grammatically valid sentences are actually produced in context; excludes historical development of constructions, child acquisition sequence, and computational/formal modeling
