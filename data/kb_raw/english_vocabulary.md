# ENGLISH CORE VOCABULARY — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: frequency_tiers → etymology_layers → register_tiers → word_formation → semantic_fields → affixes → core_words → relationships → section_index

# frequency_tiers(id|tier|description|approximate_count)
FT1|ultra-high|function words, copulas, basic pronouns|~100
FT2|high|basic verbs, common nouns, core adjectives|~800
FT3|mid-high|extended concrete nouns, manner adverbs, secondary verbs|~3000
FT4|mid|domain-general abstract nouns, compound-capable roots|~8000
FT5|low-mid|specialized but widely understood terms|~20000
FT6|low|domain-specific, technical, archaic, literary|~60000+

# etymology_layers(id|layer|period|characteristics|proportion)
EL1|Old English / Germanic|pre-1066|short, monosyllabic, daily life, body, kinship, weather, function words|~26%
EL2|French / Norman|1066-1400|law, government, cuisine, fashion, abstract social concepts|~29%
EL3|Latin (direct)|1400-1700|science, religion, formal register, polysyllabic|~29%
EL4|Greek|classical + ongoing|medicine, philosophy, science, technical compounds|~6%
EL5|Old Norse|800-1100|everyday words absorbed during Danelaw — they, take, skin, skirt, egg|~2%
EL6|Other (Arabic, Hindi, Nahuatl, Japanese, etc.)|various|borrowed with referent — alcohol, jungle, chocolate, tsunami|~8%

# register_tiers(id|register|context|formality|examples)
RT1|intimate|close relationships, internal speech|lowest|gonna, wanna, nah, yeah, bro
RT2|casual|friends, informal writing|low|pretty (as intensifier), kids, stuff, cool, hang out
RT3|consultative|workplace, strangers, standard prose|mid|approximately, provide, request, indicate
RT4|formal|academic, legal, official|high|hereinafter, notwithstanding, aforementioned, pursuant
RT5|frozen|rituals, oaths, fixed texts|highest|dearly beloved, whereby, thou, henceforth

# word_formation(id|process|description|productivity|examples)
WF1|compounding|two free morphemes joined|high|sunlight, doorknob, blackbird, toothpaste
WF2|derivation|affix added to base to change pos or meaning|high|un+kind, kind+ness, re+build
WF3|conversion (zero derivation)|pos change with no affix|high|run (n→v), email (n→v), clean (adj→v)
WF4|back-formation|shorter word extracted from longer by removing real or perceived affix|mid|edit←editor, donate←donation, babysit←babysitter
WF5|blending|parts of two words fused|mid|smog (smoke+fog), brunch (breakfast+lunch), motel
WF6|clipping|word shortened|mid|phone←telephone, lab←laboratory, flu←influenza
WF7|acronym/initialism|first letters form new word|mid|radar, scuba, NATO, laser
WF8|reduplication|base repeated or altered|low|zigzag, flip-flop, mishmash
WF9|borrowing|word adopted from another language|ongoing|café, karate, canyon, piano
WF10|onomatopoeia|word imitates sound|low|buzz, hiss, bang, splash
WF11|inflection|grammatical affix, no pos change|obligatory|-s (plural), -ed (past), -ing (progressive), -er/-est (comparative/superlative)

# semantic_fields(id|field|core_words|notes)
SF1|existence/state|be, exist, become, remain, seem|copulas and state verbs — highest frequency cluster
SF2|possession|have, own, get, give, take, keep, lose|transfer and retention
SF3|motion|go, come, move, run, walk, fall, rise, turn, pass|physical displacement
SF4|perception|see, hear, feel, taste, smell, look, watch, notice|sensory input
SF5|cognition|think, know, believe, understand, remember, forget, learn, mean|mental operations
SF6|communication|say, tell, speak, talk, ask, answer, call, write, read|language acts
SF7|desire/emotion|want, need, like, love, hate, fear, hope, wish, enjoy|affective states
SF8|causation/force|make, let, cause, force, help, allow, prevent, stop|causal relations
SF9|spatial relations|in, on, at, under, over, between, through, near, far|location and containment
SF10|temporal relations|now, then, before, after, when, while, until, already, still|time reference
SF11|quantity|all, some, many, few, much, more, less, most, enough, each|amount and distribution
SF12|body|hand, head, eye, face, foot, heart, mouth, blood, bone, back|physical form
SF13|kinship|mother, father, child, son, daughter, brother, sister, family|social bonds
SF14|sustenance|food, water, eat, drink, bread, meat, fire, cook|survival basics
SF15|nature|sun, moon, earth, sky, tree, stone, river, rain, wind, sea|physical world
SF16|social structure|king, law, people, war, god, work, money, home, land, town|organized life
SF17|evaluation|good, bad, right, wrong, true, false, new, old, great, small|judgment and scale
SF18|modality|can, could, will, would, shall, should, may, might, must|possibility, necessity, permission

# affixes(id|affix|type|meaning|origin|examples)
AX1|un-|prefix|negation / reversal|OE|unhappy, undo, unclear
AX2|re-|prefix|again / back|Latin|rebuild, return, reconsider
AX3|pre-|prefix|before|Latin|preview, prehistoric, prepay
AX4|mis-|prefix|wrongly|OE|misunderstand, misplace, mislead
AX5|over-|prefix|excessive|OE|overwork, overcook, overestimate
AX6|under-|prefix|insufficient / beneath|OE|underpay, underestimate, underground
AX7|dis-|prefix|negation / removal|Latin|disagree, disconnect, disappear
AX8|in-/im-/il-/ir-|prefix|negation|Latin|invisible, impossible, illegal, irregular
AX9|inter-|prefix|between / among|Latin|international, interact, intervene
AX10|sub-|prefix|under / below|Latin|submarine, subset, subconscious
AX11|super-|prefix|above / beyond|Latin|supernatural, supermarket, supervise
AX12|anti-|prefix|against|Greek|antiwar, antibody, anticlimax
AX13|auto-|prefix|self|Greek|automatic, autobiography, autonomy
AX14|micro-|prefix|small|Greek|microscope, microchip, microbe
AX15|macro-|prefix|large|Greek|macroeconomics, macroscope
AX16|multi-|prefix|many|Latin|multiply, multilingual, multimedia
AX17|non-|prefix|not|Latin|nonfiction, nonsense, nonprofit
AX18|out-|prefix|surpassing / external|OE|outrun, outperform, outside
AX19|-ness|suffix|state / quality (adj→n)|OE|kindness, darkness, happiness
AX20|-ment|suffix|result / action (v→n)|French|movement, judgment, agreement
AX21|-tion/-sion|suffix|act / state (v→n)|Latin|action, decision, creation
AX22|-able/-ible|suffix|capable of (v→adj)|Latin|readable, visible, flexible
AX23|-ful|suffix|full of (n→adj)|OE|hopeful, beautiful, careful
AX24|-less|suffix|without (n→adj)|OE|hopeless, careless, fearless
AX25|-ly|suffix|in manner of (adj→adv)|OE|quickly, quietly, happily
AX26|-er/-or|suffix|agent / doer (v→n)|OE/Latin|teacher, actor, builder
AX27|-ist|suffix|one who practices (n→n)|Greek|artist, scientist, pianist
AX28|-ize/-ise|suffix|to make / become (n/adj→v)|Greek|modernize, realize, organize
AX29|-ify|suffix|to make (n/adj→v)|Latin|simplify, clarify, purify
AX30|-ous/-ious|suffix|having quality of (n→adj)|Latin|dangerous, curious, famous
AX31|-al|suffix|relating to (n→adj)|Latin|natural, musical, personal
AX32|-ive|suffix|tending to (v→adj)|Latin|active, creative, explosive
AX33|-ing|suffix|progressive / gerund (v→adj/n)|OE|running, building, interesting
AX34|-ed|suffix|past / participial (v→adj)|OE|broken, excited, interested
AX35|-s/-es|suffix|plural / 3sg present|OE|cats, watches, runs
AX36|-er/-est|suffix|comparative / superlative|OE|bigger, fastest, smaller

# core_words(id|word|pos|frequency_tier|register|etymology|definition)
# — Function words (determiners, pronouns, prepositions, conjunctions)
CW1|the|det|FT1|RT1-RT5|OE|definite article
CW2|a/an|det|FT1|RT1-RT5|OE|indefinite article
CW3|this|det/pron|FT1|RT1-RT5|OE|proximal demonstrative
CW4|that|det/pron/conj/rel|FT1|RT1-RT5|OE|distal demonstrative, complementizer, relative
CW5|I|pron|FT1|RT1-RT4|OE|first person singular subject
CW6|you|pron|FT1|RT1-RT4|OE|second person
CW7|he|pron|FT1|RT1-RT5|OE|third person singular masculine subject
CW8|she|pron|FT1|RT1-RT5|OE|third person singular feminine subject
CW9|it|pron|FT1|RT1-RT5|OE|third person singular neuter / expletive
CW10|we|pron|FT1|RT1-RT5|OE|first person plural subject
CW11|they|pron|FT1|RT1-RT5|ON|third person plural / singular epicene
CW12|me|pron|FT1|RT1-RT4|OE|first person singular object
CW13|him|pron|FT1|RT1-RT5|OE|third person singular masculine object
CW14|her|pron/det|FT1|RT1-RT5|OE|third person singular feminine object / possessive
CW15|us|pron|FT1|RT1-RT5|OE|first person plural object
CW16|them|pron|FT1|RT1-RT5|ON|third person plural object
CW17|my|det|FT1|RT1-RT4|OE|first person singular possessive
CW18|your|det|FT1|RT1-RT4|OE|second person possessive
CW19|his|det|FT1|RT1-RT5|OE|third person singular masculine possessive
CW20|our|det|FT1|RT1-RT5|OE|first person plural possessive
CW21|their|det|FT1|RT1-RT5|ON|third person plural possessive
CW22|in|prep|FT1|RT1-RT5|OE|containment, temporal within
CW23|on|prep/adv|FT1|RT1-RT5|OE|surface contact, continuation
CW24|at|prep|FT1|RT1-RT5|OE|point location, time point
CW25|to|prep/inf|FT1|RT1-RT5|OE|direction, infinitive marker
CW26|for|prep/conj|FT1|RT1-RT5|OE|beneficiary, purpose, duration
CW27|with|prep|FT1|RT1-RT5|OE|accompaniment, instrument
CW28|from|prep|FT1|RT1-RT5|OE|source, origin
CW29|by|prep|FT1|RT1-RT5|OE|agent, proximity, means
CW30|of|prep|FT1|RT1-RT5|OE|genitive, partitive, composition
CW31|and|conj|FT1|RT1-RT5|OE|coordination
CW32|or|conj|FT1|RT1-RT5|OE|disjunction
CW33|but|conj|FT1|RT1-RT5|OE|adversative
CW34|if|conj|FT1|RT1-RT5|OE|conditional
CW35|because|conj|FT1|RT1-RT4|OE|causal
CW36|when|conj/adv|FT1|RT1-RT5|OE|temporal
CW37|while|conj|FT1|RT2-RT5|OE|simultaneous, concessive
CW38|not|adv|FT1|RT1-RT5|OE|negation
CW39|no|det/adv|FT1|RT1-RT5|OE|negation (determiner/adverb)
CW40|who|pron/rel|FT1|RT1-RT5|OE|interrogative/relative animate
CW41|what|pron/det/rel|FT1|RT1-RT5|OE|interrogative/relative inanimate
CW42|which|pron/det/rel|FT1|RT2-RT5|OE|interrogative/relative selective
CW43|where|adv/conj|FT1|RT1-RT5|OE|interrogative/relative place
CW44|how|adv|FT1|RT1-RT5|OE|interrogative manner/degree
CW45|there|adv/pron|FT1|RT1-RT5|OE|locative, existential
CW46|then|adv|FT1|RT1-RT5|OE|temporal sequence, consequence
CW47|so|adv/conj|FT1|RT1-RT4|OE|degree, consequence
CW48|very|adv|FT1|RT1-RT4|French|degree intensifier
CW49|also|adv|FT1|RT2-RT5|OE|additive
CW50|just|adv|FT1|RT1-RT4|Latin|restrictive, temporal recency
# — Copulas and core state verbs
CW51|be|v|FT1|RT1-RT5|OE|existence, identity, copula
CW52|have|v|FT1|RT1-RT5|OE|possession, perfect auxiliary
CW53|do|v|FT1|RT1-RT5|OE|action pro-verb, auxiliary
# — Modals
CW54|can|modal|FT1|RT1-RT5|OE|ability, permission
CW55|could|modal|FT1|RT1-RT5|OE|past ability, possibility, politeness
CW56|will|modal|FT1|RT1-RT5|OE|future, volition
CW57|would|modal|FT1|RT1-RT5|OE|conditional, past habitual, politeness
CW58|shall|modal|FT1|RT3-RT5|OE|obligation, future (formal)
CW59|should|modal|FT1|RT1-RT5|OE|advice, expectation
CW60|may|modal|FT1|RT2-RT5|OE|permission, possibility
CW61|might|modal|FT1|RT2-RT5|OE|weak possibility
CW62|must|modal|FT1|RT2-RT5|OE|necessity, strong inference
# — Core verbs
CW63|go|v|FT1|RT1-RT5|OE|motion away from reference point
CW64|come|v|FT1|RT1-RT5|OE|motion toward reference point
CW65|get|v|FT1|RT1-RT4|ON|obtain, become, causative
CW66|make|v|FT1|RT1-RT5|OE|create, cause, force
CW67|take|v|FT1|RT1-RT5|ON|seize, carry, require
CW68|give|v|FT1|RT1-RT5|OE|transfer to recipient
CW69|say|v|FT1|RT1-RT5|OE|utter, express
CW70|tell|v|FT1|RT1-RT5|OE|inform, narrate
CW71|know|v|FT1|RT1-RT5|OE|possess knowledge, be acquainted
CW72|think|v|FT1|RT1-RT5|OE|cognition, opinion
CW73|see|v|FT1|RT1-RT5|OE|visual perception, understand
CW74|look|v|FT1|RT1-RT5|OE|direct gaze, appear
CW75|want|v|FT1|RT1-RT4|ON|desire
CW76|find|v|FT1|RT1-RT5|OE|discover, locate
CW77|put|v|FT1|RT1-RT5|OE|place, position
CW78|use|v/n|FT1|RT1-RT5|French|employ, utilize
CW79|try|v|FT1|RT1-RT5|French|attempt
CW80|ask|v|FT1|RT1-RT5|OE|request, inquire
CW81|need|v/n|FT1|RT1-RT5|OE|require, necessity
CW82|feel|v|FT1|RT1-RT5|OE|tactile/emotional perception
CW83|leave|v|FT1|RT1-RT5|OE|depart, allow to remain
CW84|call|v/n|FT1|RT1-RT5|ON|summon, name, phone
CW85|keep|v|FT1|RT1-RT5|OE|retain, continue, maintain
CW86|let|v|FT1|RT1-RT5|OE|permit, causative
CW87|begin|v|FT1|RT2-RT5|OE|start, commence
CW88|seem|v|FT1|RT2-RT5|ON|appear to be
CW89|help|v/n|FT1|RT1-RT5|OE|assist, aid
CW90|show|v/n|FT1|RT1-RT5|OE|display, demonstrate
CW91|turn|v/n|FT1|RT1-RT5|OE/French|rotate, change direction/state
CW92|move|v/n|FT1|RT1-RT5|French|change position
CW93|live|v/adj|FT1|RT1-RT5|OE|inhabit, be alive
CW94|run|v/n|FT2|RT1-RT5|OE|rapid motion, operate, manage
CW95|set|v/n|FT2|RT1-RT5|OE|place, establish, group
CW96|work|v/n|FT1|RT1-RT5|OE|labor, function, employment
CW97|play|v/n|FT2|RT1-RT5|OE|engage in activity, perform
CW98|stand|v/n|FT2|RT1-RT5|OE|upright position, endure, booth
CW99|hold|v/n|FT2|RT1-RT5|OE|grasp, contain, maintain
CW100|bring|v|FT2|RT1-RT5|OE|carry toward
CW101|write|v|FT2|RT1-RT5|OE|inscribe, compose text
CW102|read|v|FT2|RT1-RT5|OE|decode text, interpret
CW103|grow|v|FT2|RT1-RT5|OE|increase in size, cultivate
CW104|open|v/adj|FT2|RT1-RT5|OE|make accessible, not closed
CW105|close|v/adj|FT2|RT1-RT5|French|shut, near, end
CW106|stop|v/n|FT2|RT1-RT5|OE|cease, halt
CW107|start|v/n|FT2|RT1-RT5|OE|begin, initiate
CW108|eat|v|FT2|RT1-RT5|OE|consume food
CW109|drink|v/n|FT2|RT1-RT5|OE|consume liquid
CW110|sleep|v/n|FT2|RT1-RT5|OE|rest unconsciously
CW111|die|v|FT2|RT1-RT5|ON|cease living
CW112|kill|v|FT2|RT1-RT5|OE|cause death
CW113|cut|v/n|FT2|RT1-RT5|OE|sever, divide with blade
CW114|build|v/n|FT2|RT1-RT5|OE|construct
CW115|break|v/n|FT2|RT1-RT5|OE|fracture, violate, interrupt
CW116|fall|v/n|FT2|RT1-RT5|OE|descend by gravity, decrease
CW117|raise|v|FT2|RT1-RT5|ON|lift, increase, rear
CW118|send|v|FT2|RT1-RT5|OE|cause to go, transmit
CW119|sit|v|FT2|RT1-RT5|OE|seated position
CW120|wait|v/n|FT2|RT1-RT5|French|remain in expectation
CW121|walk|v/n|FT2|RT1-RT5|OE|move on foot
CW122|pay|v/n|FT2|RT1-RT5|French|give money, compensate
CW123|buy|v|FT2|RT1-RT5|OE|purchase
CW124|sell|v|FT2|RT1-RT5|OE|exchange for money
CW125|speak|v|FT2|RT1-RT5|OE|produce speech
CW126|listen|v|FT2|RT1-RT5|OE|attend aurally
CW127|learn|v|FT2|RT1-RT5|OE|acquire knowledge
CW128|teach|v|FT2|RT1-RT5|OE|impart knowledge
CW129|follow|v|FT2|RT1-RT5|OE|go after, obey
CW130|lead|v/n|FT2|RT1-RT5|OE|guide, be first, metal
CW131|change|v/n|FT2|RT1-RT5|French|alter, become different
CW132|carry|v|FT2|RT1-RT5|French|transport, bear
CW133|pull|v/n|FT2|RT1-RT5|OE|draw toward
CW134|push|v/n|FT2|RT1-RT5|French|press away
CW135|fight|v/n|FT2|RT1-RT5|OE|combat, struggle
CW136|catch|v/n|FT2|RT1-RT5|French|seize in motion
CW137|throw|v/n|FT2|RT1-RT5|OE|propel through air
CW138|hit|v/n|FT2|RT1-RT5|ON|strike, impact
CW139|lose|v|FT2|RT1-RT5|OE|cease to have, fail to win
CW140|win|v/n|FT2|RT1-RT5|OE|achieve victory
# — Core nouns
CW141|time|n|FT1|RT1-RT5|OE|temporal extent, occasion
CW142|year|n|FT1|RT1-RT5|OE|365-day period
CW143|people|n|FT1|RT1-RT5|French|persons collectively
CW144|way|n|FT1|RT1-RT5|OE|manner, path, method
CW145|day|n|FT1|RT1-RT5|OE|24-hour period, daylight period
CW146|man|n|FT1|RT1-RT5|OE|adult male, human (archaic)
CW147|woman|n|FT1|RT1-RT5|OE|adult female
CW148|child|n|FT1|RT1-RT5|OE|young human
CW149|world|n|FT1|RT1-RT5|OE|earth, realm of experience
CW150|life|n|FT1|RT1-RT5|OE|state of being alive, biography
CW151|hand|n|FT1|RT1-RT5|OE|terminal part of arm
CW152|part|n|FT1|RT1-RT5|French|portion, component
CW153|place|n/v|FT1|RT1-RT5|French|location, position
CW154|thing|n|FT1|RT1-RT5|OE|entity, object, matter
CW155|name|n/v|FT1|RT1-RT5|OE|label, identity
CW156|head|n|FT1|RT1-RT5|OE|top of body, leader
CW157|home|n/adv|FT1|RT1-RT5|OE|dwelling, base
CW158|water|n|FT1|RT1-RT5|OE|H2O, liquid
CW159|word|n|FT1|RT1-RT5|OE|unit of language
CW160|house|n|FT1|RT1-RT5|OE|building for dwelling
CW161|money|n|FT1|RT1-RT5|French|medium of exchange
CW162|mother|n|FT1|RT1-RT5|OE|female parent
CW163|father|n|FT1|RT1-RT5|OE|male parent
CW164|night|n|FT1|RT1-RT5|OE|dark period of day
CW165|eye|n|FT1|RT1-RT5|OE|organ of sight
CW166|door|n|FT2|RT1-RT5|OE|hinged barrier at entrance
CW167|room|n|FT2|RT1-RT5|OE|enclosed space within building
CW168|book|n/v|FT2|RT1-RT5|OE|bound written work, reserve
CW169|food|n|FT2|RT1-RT5|OE|edible substance
CW170|friend|n|FT2|RT1-RT5|OE|person of mutual affection
CW171|body|n|FT2|RT1-RT5|OE|physical form, main part
CW172|heart|n|FT2|RT1-RT5|OE|cardiac organ, emotional center
CW173|face|n/v|FT2|RT1-RT5|French|front of head, confront
CW174|fire|n/v|FT2|RT1-RT5|OE|combustion, dismiss
CW175|sun|n|FT2|RT1-RT5|OE|star of solar system
CW176|earth|n|FT2|RT1-RT5|OE|ground, planet
CW177|road|n|FT2|RT1-RT5|OE|path for travel
CW178|side|n|FT2|RT1-RT5|OE|lateral surface, faction
CW179|end|n/v|FT2|RT1-RT5|OE|termination point, finish
CW180|line|n/v|FT2|RT1-RT5|OE/French|mark, row, boundary, queue
CW181|power|n|FT2|RT1-RT5|French|ability, authority, energy
CW182|light|n/adj/v|FT2|RT1-RT5|OE|electromagnetic radiation, not heavy, illuminate
CW183|war|n|FT2|RT1-RT5|French|armed conflict
CW184|land|n/v|FT2|RT1-RT5|OE|ground, country, arrive
CW185|king|n|FT2|RT1-RT5|OE|male monarch
CW186|god|n|FT2|RT1-RT5|OE|supreme being, deity
CW187|death|n|FT2|RT1-RT5|OE|cessation of life
CW188|blood|n|FT2|RT1-RT5|OE|fluid in circulatory system
CW189|law|n|FT2|RT1-RT5|ON|rule enforced by authority
CW190|town|n|FT2|RT1-RT5|OE|small urban settlement
# — Core adjectives
CW191|good|adj|FT1|RT1-RT5|OE|positive quality, competent
CW192|new|adj|FT1|RT1-RT5|OE|recently made, novel
CW193|old|adj|FT1|RT1-RT5|OE|having existed long, aged
CW194|great|adj|FT1|RT1-RT5|OE|large in degree, important
CW195|big|adj|FT1|RT1-RT4|OE|large in size
CW196|small|adj|FT1|RT1-RT5|OE|little in size
CW197|long|adj/adv|FT1|RT1-RT5|OE|extended in space/time
CW198|little|adj/det|FT1|RT1-RT5|OE|small, not much
CW199|right|adj/n/adv|FT1|RT1-RT5|OE|correct, opposite of left, entitlement
CW200|high|adj/adv|FT1|RT1-RT5|OE|elevated, great in degree
CW201|other|adj/pron|FT1|RT1-RT5|OE|additional, different
CW202|own|adj/v|FT1|RT1-RT5|OE|belonging to self, possess
CW203|same|adj|FT1|RT1-RT5|ON|identical, not different
CW204|first|adj/adv|FT1|RT1-RT5|OE|ordinal 1st, initial
CW205|last|adj/adv/v|FT1|RT1-RT5|OE|final, most recent, endure
CW206|bad|adj|FT1|RT1-RT4|OE|negative quality, poor
CW207|young|adj|FT2|RT1-RT5|OE|not old, early in life
CW208|hard|adj/adv|FT2|RT1-RT5|OE|solid, difficult, intensely
CW209|true|adj|FT2|RT1-RT5|OE|in accordance with fact
CW210|black|adj/n|FT2|RT1-RT5|OE|darkest color
CW211|white|adj/n|FT2|RT1-RT5|OE|lightest color
CW212|red|adj/n|FT2|RT1-RT5|OE|color of blood
CW213|dark|adj|FT2|RT1-RT5|OE|absence of light
CW214|dead|adj|FT2|RT1-RT5|OE|no longer alive
CW215|full|adj|FT2|RT1-RT5|OE|containing maximum capacity
CW216|strong|adj|FT2|RT1-RT5|OE|having great force/power
CW217|free|adj/v|FT2|RT1-RT5|OE|unrestrained, without cost, liberate
CW218|cold|adj/n|FT2|RT1-RT5|OE|low temperature
CW219|hot|adj|FT2|RT1-RT5|OE|high temperature
CW220|deep|adj/adv|FT2|RT1-RT5|OE|extending far down, profound

# relationships(from|rel|to)
# frequency tier structure
FT1|contains|CW1-CW50,CW51-CW53,CW54-CW62,CW63-CW93,CW141-CW165,CW191-CW206
FT2|contains|CW94-CW140,CW166-CW190,CW207-CW220
# etymology feeds register
EL1|enables|RT1,RT2
EL2|enables|RT3,RT4
EL3|enables|RT3,RT4
EL4|enables|RT4
# word formation uses affixes
WF2|requires|AX1-AX36
WF11|requires|AX33-AX36
# affix origin tracks etymology
AX1|derives_from|EL1
AX2|derives_from|EL3
AX3|derives_from|EL3
AX4|derives_from|EL1
AX5|derives_from|EL1
AX6|derives_from|EL1
AX7|derives_from|EL3
AX8|derives_from|EL3
AX9|derives_from|EL3
AX10|derives_from|EL3
AX11|derives_from|EL3
AX12|derives_from|EL4
AX13|derives_from|EL4
AX14|derives_from|EL4
AX15|derives_from|EL4
AX16|derives_from|EL3
AX17|derives_from|EL3
AX18|derives_from|EL1
AX19|derives_from|EL1
AX20|derives_from|EL2
AX21|derives_from|EL3
AX22|derives_from|EL3
AX23|derives_from|EL1
AX24|derives_from|EL1
AX25|derives_from|EL1
AX26|derives_from|EL1
AX27|derives_from|EL4
AX28|derives_from|EL4
AX29|derives_from|EL3
AX30|derives_from|EL3
AX31|derives_from|EL3
AX32|derives_from|EL3
AX33|derives_from|EL1
AX34|derives_from|EL1
AX35|derives_from|EL1
AX36|derives_from|EL1
# semantic fields map to core words
SF1|contains|CW51,CW88
SF2|contains|CW52,CW65,CW68,CW85,CW139
SF3|contains|CW63,CW64,CW92,CW94,CW121,CW116,CW117
SF4|contains|CW73,CW74,CW82,CW126
SF5|contains|CW71,CW72,CW127
SF6|contains|CW69,CW70,CW80,CW84,CW101,CW102,CW125
SF7|contains|CW75,CW81,CW82
SF8|contains|CW66,CW86,CW89,CW106
SF9|contains|CW22-CW30,CW45
SF10|contains|CW36,CW46
SF11|contains|CW198
SF12|contains|CW151,CW156,CW165,CW171,CW172,CW173,CW188
SF13|contains|CW162,CW163,CW148,CW170
SF14|contains|CW158,CW169,CW108,CW109
SF15|contains|CW175,CW176,CW174,CW184
SF16|contains|CW185,CW189,CW143,CW183,CW186,CW96,CW161,CW157,CW184,CW190
SF17|contains|CW191,CW206,CW199,CW209,CW194,CW196
SF18|contains|CW54-CW62
# affix negation pairs
AX1|opposes|AX23
AX24|opposes|AX23
AX7|opposes|AX2
# word formation productivity
WF1|enables|FT3,FT4
WF2|enables|FT3,FT4,FT5
WF3|enables|FT2,FT3
WF9|enables|FT4,FT5,FT6
# register constrains word choice
RT4|requires|EL2,EL3,EL4
RT1|requires|EL1,EL5
# etymology layers compose English
EL1|composes|CW1-CW53,CW63,CW64,CW66,CW71-CW74,CW76-CW78,CW82-CW87,CW89-CW91,CW93-CW99,CW100-CW104,CW106-CW110,CW112-CW116,CW118-CW119,CW121,CW123-CW130,CW133,CW135,CW137,CW139-CW142,CW144-CW151,CW154-CW160,CW162-CW168,CW169-CW172,CW174-CW179,CW182,CW184-CW188,CW190-CW220
EL2|composes|CW48,CW78,CW79,CW91,CW92,CW105,CW120,CW122,CW124,CW131,CW132,CW134,CW136,CW143,CW152,CW153,CW161,CW173,CW180,CW181,CW183
EL5|composes|CW11,CW16,CW21,CW65,CW67,CW75,CW84,CW88,CW111,CW117,CW138,CW189,CW203

# section_index(section|title|ids)
1|Frequency Distribution|FT1-FT6
2|Etymology Layers|EL1-EL6
3|Register System|RT1-RT5
4|Word Formation Processes|WF1-WF11
5|Semantic Fields|SF1-SF18
6|Productive Affixes|AX1-AX36
7|Core Function Words|CW1-CW50
8|Copulas and Modals|CW51-CW62
9|Core Verbs|CW63-CW140
10|Core Nouns|CW141-CW190
11|Core Adjectives|CW191-CW220

# decode_legend
id_prefixes: CW=core_word, AX=affix, EL=etymology_layer, RT=register_tier, FT=frequency_tier, WF=word_formation, SF=semantic_field
rel_types: contains|derives_from|enables|requires|composes|opposes
etymology_abbrevs: OE=Old English, ON=Old Norse
pos_abbrevs: n=noun, v=verb, adj=adjective, adv=adverb, det=determiner, pron=pronoun, prep=preposition, conj=conjunction, rel=relative, inf=infinitive marker, modal=modal verb
register_ranges: RT1-RT5 means word spans all registers from intimate to frozen
frequency: FT1=ultra-high (~100 words), FT2=high (~800 words), FT3-FT6=progressively less frequent
confidence: generated from LLM weights, not from corpus count — frequency tiers are ordinal not cardinal

# relation_mapping(doc_rel|canonical_rel|notes)
contains|contains|exact match
derives_from|derived_from|exact match
enables|enables|exact match
requires|requires|exact match
composes|composed_of|inverse; EL1 composes core words = core words composed_of EL1
opposes|opposes|exact match
