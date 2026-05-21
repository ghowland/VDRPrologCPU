# ENGLISH LANGUAGE GRAMMAR — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: word_classes → subclasses → morphology → concepts → phrase_types → clause_types → sentence_patterns → agreement → tense_aspect → voice_mood → punctuation → rules → relationships → section_index → decode_legend

# word_classes(id|name|definition|open_closed|inflects)
WC1|noun|word naming person, place, thing, idea, or quality|open|number, case(pronoun only)
WC2|verb|word expressing action, state, or occurrence|open|tense, aspect, mood, person, number, voice
WC3|adjective|word modifying noun or pronoun|open|degree(positive, comparative, superlative)
WC4|adverb|word modifying verb, adjective, another adverb, or clause|open|degree(positive, comparative, superlative)
WC5|pronoun|word substituting for noun or noun phrase|closed|person, number, gender, case
WC6|preposition|word expressing spatial, temporal, or logical relation between complement and another element|closed|none
WC7|conjunction|word joining words, phrases, or clauses|closed|none
WC8|determiner|word specifying reference of noun|closed|none
WC9|interjection|word expressing emotion or reaction, syntactically independent|open|none
WC10|auxiliary verb|verb combining with main verb to express tense, aspect, mood, or voice|closed|tense, person, number

# subclasses(id|parent_fk|name|definition|examples)
SC1|WC1|common noun|names general class of entity|dog, city, idea
SC2|WC1|proper noun|names specific individual entity; capitalized|London, Maria, Tuesday
SC3|WC1|count noun|has singular and plural forms; takes cardinal numbers|book/books, child/children
SC4|WC1|mass noun|denotes undifferentiated substance or concept; no plural without reclassification|water, information, furniture
SC5|WC1|collective noun|names group as single unit|team, flock, committee
SC6|WC1|abstract noun|names quality, state, or concept without physical referent|freedom, anger, knowledge
SC7|WC1|concrete noun|names entity perceivable by senses|table, smoke, thunder
SC8|WC2|transitive verb|requires direct object|build, carry, see
SC9|WC2|intransitive verb|takes no direct object|arrive, sleep, exist
SC10|WC2|ditransitive verb|takes direct object and indirect object|give, send, tell
SC11|WC2|linking verb|connects subject to subject complement; no action|be, seem, become, appear
SC12|WC2|phrasal verb|verb + particle forming single semantic unit; meaning not compositional|give up, look after, break down
SC13|WC3|attributive adjective|appears before noun in NP|the red door
SC14|WC3|predicative adjective|appears after linking verb as complement|the door is red
SC15|WC3|postpositive adjective|appears immediately after noun|attorney general, something useful
SC16|WC3|participial adjective|derived from verb participle|broken glass, running water
SC17|WC4|manner adverb|describes how action performed|quickly, carefully
SC18|WC4|degree adverb|modifies intensity of adjective, adverb, or verb|very, extremely, quite
SC19|WC4|frequency adverb|describes how often|always, never, sometimes
SC20|WC4|temporal adverb|describes when|yesterday, soon, now
SC21|WC4|spatial adverb|describes where|here, everywhere, outside
SC22|WC4|sentence adverb|modifies entire clause; expresses speaker stance|fortunately, however, frankly
SC23|WC5|personal pronoun|refers to specific persons or things|I, you, he, she, it, we, they
SC24|WC5|possessive pronoun|indicates ownership; functions as NP|mine, yours, his, hers, ours, theirs
SC25|WC5|reflexive pronoun|co-refers to subject; object position|myself, yourself, themselves
SC26|WC5|demonstrative pronoun|points to specific referent by proximity|this, that, these, those
SC27|WC5|interrogative pronoun|introduces question; seeks identity of referent|who, whom, whose, which, what
SC28|WC5|relative pronoun|introduces relative clause; refers back to antecedent|who, whom, whose, which, that
SC29|WC5|indefinite pronoun|refers to nonspecific entity|someone, anything, everybody, none
SC30|WC6|simple preposition|single word|in, on, at, by, for, with, to, from
SC31|WC6|compound preposition|multi-word unit functioning as single preposition|in front of, because of, on behalf of
SC32|WC6|participial preposition|derived from present or past participle|during, concerning, given, past
SC33|WC7|coordinating conjunction|joins grammatically equal elements|for, and, nor, but, or, yet, so
SC34|WC7|subordinating conjunction|introduces dependent clause; marks it as subordinate|because, although, when, if, while, unless, until
SC35|WC7|correlative conjunction|paired conjunctions framing two elements|both...and, either...or, neither...nor, not only...but also
SC36|WC8|article|marks definiteness or indefiniteness of noun|the, a, an
SC37|WC8|demonstrative determiner|specifies referent by proximity|this, that, these, those
SC38|WC8|possessive determiner|specifies referent by ownership|my, your, his, her, its, our, their
SC39|WC8|quantifying determiner|specifies amount|some, many, few, each, every, all, no
SC40|WC8|interrogative determiner|asks which referent|which, what, whose
SC41|WC10|primary auxiliary|be, have, do — mark tense, aspect, voice, emphasis, negation, inversion|be, have, do
SC42|WC10|modal auxiliary|express modality: ability, permission, obligation, possibility, prediction|can, could, may, might, shall, should, will, would, must
SC43|WC10|semi-modal|marginal auxiliaries sharing some modal properties|ought to, need to, dare to, used to, had better

# morphology(id|class_fk|form|formation|irregular_notes)
MR1|WC1|plural|regular: +s/+es; sibilant endings +es|child→children, mouse→mice, ox→oxen, criterion→criteria, fungus→fungi
MR2|WC1|possessive singular|+'s|the dog's, James's or James'
MR3|WC1|possessive plural|s+' or irregular plural+'s|the dogs', the children's
MR4|WC2|base form|uninflected infinitive stem|walk, be, go
MR5|WC2|third person singular present|-s/-es/-ies|walks, goes, carries; be→is, have→has
MR6|WC2|past simple|regular: +ed|walked; be→was/were, go→went, see→saw
MR7|WC2|past participle|regular: +ed; used with have/be|walked; be→been, go→gone, see→seen, write→written
MR8|WC2|present participle / gerund|+ing; doubling/dropping rules apply|walking, running, writing; be→being
MR9|WC2|-s form (3sg present)|identical to MR5|—
MR10|WC3|comparative|one syllable: +er; two+: more + adj|taller, more beautiful; good→better, bad→worse
MR11|WC3|superlative|one syllable: +est; two+: most + adj|tallest, most beautiful; good→best, bad→worst
MR12|WC4|comparative|+er or more + adv|faster, more carefully; well→better
MR13|WC4|superlative|+est or most + adv|fastest, most carefully; well→best
MR14|WC5|subjective case|pronoun as subject|I, he, she, we, they, who
MR15|WC5|objective case|pronoun as object|me, him, her, us, them, whom
MR16|WC5|possessive case|pronoun showing ownership|my/mine, his, her/hers, our/ours, their/theirs, whose

# concepts(id|name|definition|category)
C1|subject|NP performing action or being described; controls verb agreement|syntactic_role
C2|predicate|VP and its complements; everything about the subject|syntactic_role
C3|direct object|NP receiving action of transitive verb|syntactic_role
C4|indirect object|NP receiving direct object; beneficiary or recipient|syntactic_role
C5|subject complement|NP or AdjP renaming or describing subject after linking verb|syntactic_role
C6|object complement|NP or AdjP renaming or describing direct object|syntactic_role
C7|adjunct|optional modifier providing circumstantial info; removable without ungrammaticality|syntactic_role
C8|appositive|NP placed beside another NP to rename or describe it|syntactic_role
C9|vocative|NP used to address someone directly; syntactically independent|syntactic_role
C10|finite clause|clause containing verb marked for tense and agreement|clause_property
C11|non-finite clause|clause headed by infinitive, participle, or gerund; no tense/agreement marking|clause_property
C12|transitivity|property of verb determining number and type of required complements|verb_property
C13|valency|number of arguments a verb requires|verb_property
C14|agreement|requirement that related words match in person, number, gender, or case|mechanism
C15|government|requirement that one word dictates the form of another|mechanism
C16|coordination|joining of grammatically equivalent elements by coordinating conjunction|mechanism
C17|subordination|embedding one clause within another as dependent|mechanism
C18|modification|syntactic relation where one element restricts or describes another|mechanism
C19|complementation|syntactic relation where one element completes the meaning of another|mechanism
C20|ellipsis|omission of recoverable material from clause|mechanism
C21|anaphora|use of pronoun or pro-form to refer back to antecedent|mechanism
C22|cataphora|use of pronoun or pro-form to refer forward to postcedent|mechanism
C23|deixis|reference to context-dependent entities: person, place, time|mechanism
C24|topicalization|fronting constituent to clause-initial position for emphasis|word_order
C25|cleft construction|it-cleft or wh-cleft restructuring to focus one constituent|word_order
C26|extraposition|moving heavy constituent to end; placeholder it in canonical position|word_order
C27|subject-auxiliary inversion|auxiliary moves before subject; triggers: questions, negative fronting, conditionals|word_order
C28|do-support|insertion of dummy do when no other auxiliary present; required for negation, inversion, emphasis|mechanism
C29|there-insertion|existential there as dummy subject; notional subject follows verb|word_order
C30|dangling modifier|participial or adjectival phrase with no logical subject in clause|anti_pattern
C31|comma splice|joining two independent clauses with only a comma and no conjunction|anti_pattern
C32|run-on sentence|joining two independent clauses with no punctuation or conjunction|anti_pattern
C33|sentence fragment|dependent clause or phrase punctuated as complete sentence|anti_pattern
C34|double negative|two negative elements producing unintended affirmative or nonstandard negation|anti_pattern
C35|squinting modifier|adverb placed where it could modify either preceding or following element|anti_pattern
C36|misplaced modifier|modifier positioned too far from word it modifies, creating ambiguity|anti_pattern
C37|faulty parallelism|coordinated elements not matching in grammatical form|anti_pattern
C38|pronoun-antecedent ambiguity|pronoun with two or more possible antecedents|anti_pattern
C39|shift in person|inconsistent pronoun person within passage|anti_pattern
C40|shift in tense|unjustified change of tense within passage|anti_pattern
C41|recursion|property of grammar allowing structures to embed within themselves indefinitely|structural_property
C42|constituency|grouping of words into hierarchical phrase units|structural_property
C43|head|obligatory central word of phrase determining category and distribution|structural_property
C44|complement|obligatory element completing head's meaning; subcategorized by head|structural_property
C45|specifier|element marking definiteness, quantity, or reference at phrase edge|structural_property
C46|adjunction|optional attachment of modifier to phrase|structural_property

# phrase_types(id|name|head|modifiers|complements|function)
PH1|noun phrase (NP)|noun or pronoun|determiners, adjectives, relative clauses, PPs|appositive NPs, PPs|subject, object, complement, appositive
PH2|verb phrase (VP)|main verb|adverbs|NPs(objects), AdjPs(complements), PPs, clauses|predicate
PH3|adjective phrase (AdjP)|adjective|degree adverbs|PPs, that-clauses, infinitives|pre/postnominal modifier, predicative complement
PH4|adverb phrase (AdvP)|adverb|degree adverbs|PPs, that-clauses|modifier of VP, AdjP, AdvP, clause
PH5|prepositional phrase (PP)|preposition|none|NP (obligatory)|adjunct, complement, postnominal modifier

# clause_types(id|name|structure|function|examples)
CL1|independent clause (main)|subject + finite VP; can stand alone|forms simple sentence or conjoined sentence|The dog barked.
CL2|coordinate clause|independent clause joined by coordinating conjunction|equal partner in compound sentence|The dog barked and the cat hid.
CL3|noun clause (nominal)|that/wh-word/if + finite clause or infinitive|subject, object, complement, appositive|That he left surprised me. / I know what you mean.
CL4|adjective clause (relative)|relative pronoun/adverb + finite or non-finite clause|postnominal modifier of NP|The book which I read was long.
CL5|adverb clause (adverbial)|subordinating conjunction + finite clause|adjunct: time, cause, condition, concession, purpose, result, comparison|When it rains, I stay home.
CL6|conditional clause|if/unless/provided that + clause; protasis of conditional|expresses condition for main clause (apodosis)|If it rains, we cancel.
CL7|infinitive clause|to + base verb; no finite marking|subject, object, complement, adjunct, postnominal modifier|To err is human. / I want to leave.
CL8|participial clause|present or past participle + complements; no finite marking|adjunct, postnominal modifier|Running late, she skipped breakfast.
CL9|gerund clause|gerund (-ing form) + complements; functions as NP|subject, object, complement|Swimming is fun. / I enjoy reading.
CL10|absolute clause|NP + participle; no syntactic link to main clause; provides circumstantial info|adjunct|The weather being fine, we walked.
CL11|cleft clause|It + be + focused element + relative clause|focus/emphasis on one constituent|It was John who called.
CL12|pseudo-cleft clause|wh-clause + be + focused element|focus/emphasis on one constituent|What I need is coffee.
CL13|comparative clause|than/as + clause (often with ellipsis)|complement of comparative adjective or adverb|She runs faster than I do.
CL14|verbless clause|clause with verb omitted; recoverable from context|adjunct, reduced relative|Although tired, she continued. / The man, a doctor, helped.

# sentence_patterns(id|pattern|components|example|notes)
SP1|SV|subject + intransitive verb|Birds fly.|simplest complete clause
SP2|SVO|subject + transitive verb + direct object|She reads books.|most common English pattern
SP3|SVC|subject + linking verb + subject complement|He is a teacher. / She seems happy.|complement = NP or AdjP
SP4|SVA|subject + verb + obligatory adverbial|She lives in Paris.|adverbial is required, not optional
SP5|SVOO|subject + ditransitive verb + indirect object + direct object|She gave him a book.|IO precedes DO; paraphrase with to/for PP
SP6|SVOC|subject + verb + direct object + object complement|They elected her president. / I painted it red.|complement = NP or AdjP
SP7|SVOA|subject + verb + direct object + obligatory adverbial|She put the book on the table.|adverbial required by verb

# agreement(id|type|controller|target|condition)
AG1|subject-verb number|subject NP|finite verb|verb matches subject in number and person; 3sg present marked with -s
AG2|subject-verb person|subject NP|finite verb|first/second/third person determines verb form; visible mainly in be (am/are/is)
AG3|pronoun-antecedent number|antecedent NP|pronoun|pronoun matches antecedent in number
AG4|pronoun-antecedent gender|antecedent NP|pronoun|pronoun matches antecedent in gender; singular they for unknown/nonbinary
AG5|pronoun-antecedent person|antecedent NP|pronoun|pronoun matches antecedent in person
AG6|pronoun case|syntactic position|pronoun form|subject position→subjective; object position→objective; possessive position→possessive
AG7|determiner-noun number|noun|determiner|this/that+singular; these/those+plural; a/an+singular only
AG8|relative pronoun selection|antecedent animacy|relative pronoun|who/whom/whose for human; which for nonhuman; that for either
AG9|collective noun agreement|collective noun (subject)|verb and pronoun|BrE: plural verb if group acts individually; AmE: usually singular
AG10|correlative conjunction agreement|nearest NP (in neither...nor, either...or)|verb|verb agrees with NP nearest to it (proximity agreement)
AG11|indefinite pronoun agreement|indefinite pronoun (subject)|verb|each, every, everyone, someone, etc. take singular verb; some context-dependent

# tense_aspect(id|tense|aspect|auxiliary_pattern|time_reference|example)
TA1|present|simple|∅ (base or -s form)|habitual, general truth, scheduled future|She walks. / Water boils at 100°C.
TA2|present|progressive|am/is/are + -ing|action in progress now, temporary state|She is walking.
TA3|present|perfect|have/has + past participle|past event with present relevance; indefinite past|She has walked five miles.
TA4|present|perfect progressive|have/has + been + -ing|action begun in past continuing to present; duration emphasis|She has been walking for an hour.
TA5|past|simple|-ed form or irregular past|completed past event|She walked.
TA6|past|progressive|was/were + -ing|action in progress at past reference point|She was walking when it rained.
TA7|past|perfect|had + past participle|past event completed before another past event|She had walked before the bus came.
TA8|past|perfect progressive|had + been + -ing|ongoing past action completed before another past event|She had been walking for an hour when it rained.
TA9|future|simple|will + base|prediction, spontaneous decision, future fact|She will walk.
TA10|future|progressive|will + be + -ing|action in progress at future reference point|She will be walking at noon.
TA11|future|perfect|will + have + past participle|future event completed before another future point|She will have walked ten miles by then.
TA12|future|perfect progressive|will + have + been + -ing|ongoing future action viewed from later future point|She will have been walking for two hours by noon.

# voice_mood(id|name|formation|use|example)
VM1|active voice|subject performs action; standard SVO order|default; agent is topic|The cat chased the mouse.
VM2|passive voice|be + past participle; agent demoted to optional by-phrase|patient is topic; agent unknown/irrelevant|The mouse was chased (by the cat).
VM3|get-passive|get + past participle|informal passive; implies adversity or change of state|He got fired.
VM4|indicative mood|default finite verb form|statements and questions of fact|She leaves tomorrow.
VM5|imperative mood|base form; subject (you) typically omitted|commands, requests, instructions|Close the door. / Please sit down.
VM6|subjunctive — mandative|base form in that-clause after verbs/adjectives of demand, suggestion, necessity|formal requirement/recommendation|I insist that he leave. / It is essential that she be present.
VM7|subjunctive — formulaic|fixed expressions preserving older subjunctive|wishes, set phrases|God bless you. / If need be. / Come what may.
VM8|subjunctive — were (irrealis)|were for all persons in if-clauses and wishes contrary to fact|hypothetical, counterfactual|If I were you. / I wish she were here.
VM9|conditional|would + base form; in apodosis paired with if-clause|hypothetical result|If it rained, I would stay home.

# punctuation(id|mark|name|primary_use|secondary_uses)
PN1|.|period / full stop|terminates declarative or imperative sentence|abbreviations
PN2|?|question mark|terminates direct question|rhetorical questions; tag questions
PN3|!|exclamation mark|terminates exclamatory sentence or strong imperative|interjections
PN4|,|comma|separates items in list; before coordinating conjunction joining independent clauses|after introductory elements; around nonrestrictive modifiers; before tag questions; around appositives
PN5|;|semicolon|joins closely related independent clauses without conjunction|separates list items containing internal commas
PN6|:|colon|introduces list, explanation, or amplification after independent clause|introduces quotation; time notation; ratios
PN7|—|em dash|parenthetical insertion stronger than commas|abrupt break; interrupted speech; amplification
PN8|–|en dash|number ranges|compound adjectives where one element is multi-word
PN9|()|parentheses|enclose supplementary or tangential information|in-text citations; numbered/lettered lists
PN10|""|quotation marks (double)|enclose direct speech or quotation|titles of short works; words used as words; scare quotes
PN11|''|quotation marks (single)|quotation within quotation (AmE); primary quotation (BrE)|—
PN12|'|apostrophe|marks possessive case|marks omitted letters in contractions
PN13|...|ellipsis|indicates omitted material from quotation|trailing off in speech; pause
PN14|-|hyphen|joins compound modifiers before noun; joins prefixes|word division at line break; compound numbers twenty-one through ninety-nine
PN15|/|slash|indicates alternatives|abbreviations; line breaks in quoted poetry

# rules(id|rule|scope|violation_result)
R1|every sentence requires subject + finite verb (except imperative)|clause structure|fragment (C33)
R2|transitive verb requires direct object|verb complementation|incomplete clause
R3|subject and finite verb agree in number and person|agreement|subject-verb disagreement
R4|pronoun agrees with antecedent in number, person, gender|agreement|pronoun-antecedent error
R5|pronoun takes case form matching its syntactic function|agreement|case error (e.g. me/I confusion)
R6|participial phrase must have clear logical subject in clause|modification|dangling modifier (C30)
R7|modifier should be adjacent to word it modifies|modification|misplaced modifier (C36) or squinting modifier (C35)
R8|coordinated elements must match in grammatical form|coordination|faulty parallelism (C37)
R9|two independent clauses joined without conjunction require semicolon or period|punctuation|comma splice (C31) or run-on (C32)
R10|nonrestrictive relative clause takes commas; restrictive does not|punctuation|meaning change or error
R11|only use whom in object position; who in subject position|case|whom/who error
R12|subjunctive base form required in mandative that-clauses|mood|mood error (e.g. insist that he leaves → insist that he leave)
R13|maintain consistent tense unless shift is logically motivated|tense|tense shift (C40)
R14|maintain consistent person throughout passage|person|person shift (C39)
R15|every pronoun requires unambiguous antecedent|reference|pronoun-antecedent ambiguity (C38)
R16|comma required before coordinating conjunction joining two independent clauses|punctuation|missing comma in compound sentence
R17|adjectives in pre-nominal position follow order: opinion-size-age-shape-color-origin-material-purpose|word_order|unnatural adjective sequence
R18|articles required with singular count nouns (a/an for indefinite, the for definite)|determination|bare singular count noun error
R19|mass nouns take no indefinite article and no plural in default interpretation|determination|a furniture, informations
R20|adverb not adjective modifies verb|modification|e.g. run quick → run quickly
R21|comparative for two items; superlative for three or more|degree|degree mismatch
R22|double negation is nonstandard in standard English|negation|double negative (C34)
R23|active preferred over passive unless agent is unknown, irrelevant, or patient is topic|style|unnecessary passive
R24|that introduces restrictive clauses; which introduces nonrestrictive (in AmE)|clause typing|that/which confusion (AmE)

# relationships(from|rel|to)
# word_class hierarchy
SC1|specializes|WC1
SC2|specializes|WC1
SC3|specializes|WC1
SC4|specializes|WC1
SC5|specializes|WC1
SC6|specializes|WC1
SC7|specializes|WC1
SC8|specializes|WC2
SC9|specializes|WC2
SC10|specializes|WC2
SC11|specializes|WC2
SC12|specializes|WC2
SC13|specializes|WC3
SC14|specializes|WC3
SC15|specializes|WC3
SC16|specializes|WC3
SC17|specializes|WC4
SC18|specializes|WC4
SC19|specializes|WC4
SC20|specializes|WC4
SC21|specializes|WC4
SC22|specializes|WC4
SC23|specializes|WC5
SC24|specializes|WC5
SC25|specializes|WC5
SC26|specializes|WC5
SC27|specializes|WC5
SC28|specializes|WC5
SC29|specializes|WC5
SC30|specializes|WC6
SC31|specializes|WC6
SC32|specializes|WC6
SC33|specializes|WC7
SC34|specializes|WC7
SC35|specializes|WC7
SC36|specializes|WC8
SC37|specializes|WC8
SC38|specializes|WC8
SC39|specializes|WC8
SC40|specializes|WC8
SC41|specializes|WC10
SC42|specializes|WC10
SC43|specializes|WC10
# morphology belongs to class
MR1|part_of|WC1
MR2|part_of|WC1
MR3|part_of|WC1
MR4|part_of|WC2
MR5|part_of|WC2
MR6|part_of|WC2
MR7|part_of|WC2
MR8|part_of|WC2
MR10|part_of|WC3
MR11|part_of|WC3
MR12|part_of|WC4
MR13|part_of|WC4
MR14|part_of|WC5
MR15|part_of|WC5
MR16|part_of|WC5
# phrase structure
PH1|contains|WC1
PH1|contains|WC8
PH1|contains|WC3
PH2|contains|WC2
PH2|contains|WC4
PH3|contains|WC3
PH3|contains|WC4
PH4|contains|WC4
PH5|contains|WC6
PH5|requires|PH1
# clause composition
CL1|contains|PH1
CL1|contains|PH2
CL2|requires|SC33
CL3|requires|SC34
CL4|requires|SC28
CL5|requires|SC34
CL6|specializes|CL5
CL7|contains|C11
CL8|contains|C11
CL9|contains|C11
CL10|contains|C11
CL11|specializes|CL1
CL12|specializes|CL1
CL13|requires|MR10
# sentence patterns — what they require
SP1|requires|SC9
SP2|requires|SC8
SP3|requires|SC11
SP4|requires|C7
SP5|requires|SC10
SP6|requires|C6
SP7|requires|C7
# sentence pattern sequence
SP1|instance_of|CL1
SP2|instance_of|CL1
SP3|instance_of|CL1
SP4|instance_of|CL1
SP5|instance_of|CL1
SP6|instance_of|CL1
SP7|instance_of|CL1
# tense_aspect composition
TA2|composed_of|SC41
TA2|requires|MR8
TA3|composed_of|SC41
TA3|requires|MR7
TA4|composed_of|SC41
TA4|requires|MR8
TA5|requires|MR6
TA6|composed_of|SC41
TA6|requires|MR8
TA7|composed_of|SC41
TA7|requires|MR7
TA8|composed_of|SC41
TA8|requires|MR8
TA9|composed_of|SC42
TA10|composed_of|SC42
TA10|requires|MR8
TA11|composed_of|SC42
TA11|requires|MR7
TA12|composed_of|SC42
TA12|requires|MR8
# voice transformations
VM1|transforms_to|VM2
VM2|requires|MR7
VM2|composed_of|SC41
VM3|transforms_to|VM2
VM3|requires|MR7
# mood relationships
VM4|generalizes|VM5
VM4|generalizes|VM6
VM6|requires|MR4
VM8|requires|MR6
VM9|composed_of|SC42
VM9|depends_on|CL6
# agreement mechanisms
AG1|determined_by|C1
AG1|validates|R3
AG2|determined_by|C1
AG2|validates|R3
AG3|validates|R4
AG4|validates|R4
AG5|validates|R4
AG6|validates|R5
AG7|determined_by|WC1
AG8|determined_by|WC1
AG9|specializes|AG1
AG10|specializes|AG1
AG11|specializes|AG1
# syntactic role dependencies
C1|part_of|CL1
C2|part_of|CL1
C3|depends_on|SC8
C4|depends_on|SC10
C5|depends_on|SC11
C6|requires|C3
C7|extends|CL1
C8|extends|PH1
C9|part_of|CL1
# mechanism relationships
C14|enables|AG1
C14|enables|AG3
C15|enables|AG6
C16|requires|SC33
C17|requires|SC34
C18|enables|C7
C19|enables|C44
C20|enables|CL13
C20|enables|CL14
C21|requires|C14
C22|specializes|C21
C24|transforms_to|SP2
C25|specializes|CL11
C26|transforms_to|C29
C27|requires|WC10
C28|requires|SC41
C28|enables|C27
# structural properties
C41|enables|C17
C42|enables|PH1
C43|part_of|PH1
C43|part_of|PH2
C43|part_of|PH3
C43|part_of|PH4
C43|part_of|PH5
C44|requires|C43
C45|part_of|PH1
C46|enables|C7
# anti-pattern prevention
C30|prevents|R6
C31|prevents|R9
C32|prevents|R9
C33|prevents|R1
C34|prevents|R22
C35|prevents|R7
C36|prevents|R7
C37|prevents|R8
C38|prevents|R15
C39|prevents|R14
C40|prevents|R13
# punctuation and clause rules
PN4|enables|R16
PN4|enables|R10
PN5|enables|R9
PN1|enables|R9
R10|depends_on|CL4
R24|depends_on|CL4
R17|depends_on|SC13
R18|depends_on|SC3
R19|depends_on|SC4
R20|depends_on|WC4
R21|depends_on|MR10

# section_index(section|title|ids)
1|Word Classes|WC1-WC10
2|Subclasses|SC1-SC43
3|Morphology|MR1-MR16
4|Core Grammatical Concepts|C1-C46
5|Phrase Types|PH1-PH5
6|Clause Types|CL1-CL14
7|Sentence Patterns|SP1-SP7
8|Agreement|AG1-AG11
9|Tense and Aspect|TA1-TA12
10|Voice and Mood|VM1-VM9
11|Punctuation|PN1-PN15
12|Rules|R1-R24

# decode_legend
id_prefixes: WC=word_class, SC=subclass, MR=morphology, C=concept, PH=phrase_type, CL=clause_type, SP=sentence_pattern, AG=agreement, TA=tense_aspect, VM=voice_mood, PN=punctuation, R=rule
rel_types: enables|requires|prevents|specializes|generalizes|part_of|contains|depends_on|determined_by|composed_of|transforms_to|instance_of|validates|extends
notation: _fk suffix=foreign key reference to parent table; ∅=zero/null morpheme; 3sg=third person singular; AmE=American English; BrE=British English; NP=noun phrase; VP=verb phrase; AdjP=adjective phrase; AdvP=adverb phrase; PP=prepositional phrase
confidence: all facts asserted at reference_grammar confidence level
scope: Modern Standard English prescriptive grammar; excludes dialectal, historical, and generative-formal representations
