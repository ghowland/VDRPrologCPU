# PROJECT MANAGEMENT — MECHANICAL ACTIVITIES — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: foundations → phases → activities → deliverables → roles → artifacts → tracking → estimating → dependencies → risk → change_control → methods → meetings → metrics → communication → tools → rules → failure_modes → relationships → section_index

# foundations(id|concept|definition|significance)
FD1|project|temporary endeavor with defined start, end, scope, resources, and deliverables producing a unique result|the unit of managed work — everything in PM serves the project
FD2|scope|the totality of work required to produce deliverables — what is in and what is out|scope defines boundaries — uncontrolled scope is the primary failure mode (scope creep)
FD3|schedule|time-ordered sequence of activities with durations, dependencies, and milestones mapped to calendar dates|the when — transforms activity list into a timeline with a critical path
FD4|budget|total authorized cost for the project — labor, materials, overhead, contingency, management reserve|the how much — once baselined, changes require formal change control
FD5|quality|degree to which deliverables satisfy requirements and are fit for purpose|not gold-plating — quality is conformance to requirements, measured by acceptance criteria
FD6|risk|uncertain event or condition that, if it occurs, has positive or negative effect on objectives|managed proactively — identified, assessed, planned for, monitored, not merely reacted to
FD7|stakeholder|person, group, or organization that can affect, be affected by, or perceive itself affected by the project|all projects exist within stakeholder ecosystems — ignoring stakeholders kills projects
FD8|baseline|approved version of scope, schedule, or budget against which actual performance is measured|the reference — without baseline there is no variance, without variance there is no control
FD9|constraint|limiting factor — fixed deadline, fixed budget, regulatory requirement, resource ceiling|constraints are not negotiable within the project — they define the solution space
FD10|assumption|factor considered true for planning purposes without proof|assumptions carry risk — every assumption is a potential issue if wrong
FD11|deliverable|tangible or intangible product, result, or capability produced by the project|what the project exists to create — acceptance of deliverables is the measure of completion
FD12|work breakdown structure (WBS)|hierarchical decomposition of total scope into manageable work packages|the skeleton of scope — every activity and deliverable traces to a WBS element
FD13|critical path|longest sequence of dependent activities determining minimum project duration|schedule compression targets the critical path — non-critical activities have float
FD14|earned value|objective measure of work performed expressed in terms of budget — BCWP|integrates scope, schedule, and cost into single measurement framework
FD15|change control|formal process for proposing, evaluating, approving, and implementing changes to baselines|without change control, scope creep is invisible until schedule and budget are consumed
FD16|governance|decision-making framework — who authorizes what, escalation paths, reporting obligations|the authority structure — governs trade-offs between scope, schedule, budget, quality
FD17|lessons learned|documented knowledge gained from project execution — what worked, what didn't, what to do differently|closes the loop — value only realized if captured during execution and applied to future projects
FD18|acceptance criteria|conditions that must be satisfied before a deliverable is accepted by the customer or sponsor|the definition of done — ambiguous criteria produce disputed deliverables

# phases(id|phase|description|entry_criteria|exit_criteria|key_deliverables)
PH1|initiation|define project purpose, authorize project, identify sponsor and key stakeholders|business case or directive exists|project charter approved, sponsor identified, PM assigned|project charter, stakeholder register (initial)
PH2|planning|develop comprehensive plan: scope, schedule, budget, quality, risk, communication, procurement, staffing|charter approved|all baseline plans approved and signed off by sponsor|project management plan (master), WBS, schedule baseline, budget baseline, risk register, communication plan
PH3|execution|perform the work defined in the plan — produce deliverables, manage teams, engage stakeholders|planning complete, baselines approved|all deliverables produced and submitted for acceptance|completed deliverables, status reports, change requests, issue log updates, risk responses executed
PH4|monitoring and control|track, review, and regulate progress — compare actual to baseline, take corrective action|execution begins (runs parallel to PH3)|all deliverables accepted, all issues resolved or transferred|variance reports, earned value reports, change log, corrective actions, updated forecasts
PH5|closing|formalize acceptance, release resources, archive records, capture lessons learned, close contracts|all deliverables accepted, all issues resolved|project formally closed, lessons learned documented, final report approved|final report, lessons learned register, archived project records, resource release

# activities(id|activity|phase|description|inputs|outputs)
# — Initiation activities
AC1|develop business case|PH1|document the justification — problem/opportunity, expected benefits, high-level cost/timeline, alternatives considered|business need, organizational strategy|business case document
AC2|identify sponsor|PH1|determine the person with authority and budget to authorize the project|business case, organizational structure|named sponsor with authority level documented
AC3|develop project charter|PH1|authorize the project — purpose, objectives, high-level scope, constraints, assumptions, success criteria, PM assignment|business case, sponsor input, organizational assets|approved project charter
AC4|identify stakeholders (initial)|PH1|list all known stakeholders with interest, influence, and attitude toward the project|charter, organizational knowledge|initial stakeholder register
# — Planning activities
AC5|collect requirements|PH2|elicit, document, and validate what stakeholders need from the project — functional, non-functional, regulatory|stakeholder register, charter|requirements document, requirements traceability matrix (RTM)
AC6|define scope statement|PH2|detailed description of project and product scope — inclusions, exclusions, constraints, assumptions|requirements document, charter|project scope statement
AC7|create WBS|PH2|decompose total scope into work packages — hierarchical, 100% rule (WBS contains ALL work)|scope statement|WBS, WBS dictionary
AC8|define activities|PH2|identify specific actions to produce work package deliverables|WBS, WBS dictionary|activity list, activity attributes
AC9|sequence activities|PH2|determine dependencies between activities — FS, FF, SS, SF, mandatory, discretionary, external|activity list|network diagram (precedence diagram method)
AC10|estimate durations|PH2|estimate time each activity requires — analogous, parametric, three-point, bottom-up|activity list, resource estimates, historical data|duration estimates with basis of estimate
AC11|develop schedule|PH2|analyze sequences, durations, resources, constraints → calendar-mapped timeline with critical path|network diagram, duration estimates, resource calendars, constraints|schedule baseline (Gantt chart with critical path), milestone list
AC12|estimate costs|PH2|estimate monetary resources for activities — analogous, parametric, bottom-up, vendor quotes|activity list, resource requirements, rate cards|cost estimates with basis of estimate
AC13|determine budget|PH2|aggregate cost estimates, add contingency reserve, establish cost baseline|cost estimates, schedule baseline, risk register|cost baseline (S-curve), project budget with reserves
AC14|plan quality|PH2|define quality standards, metrics, and processes — what "good enough" means per deliverable|requirements, acceptance criteria, organizational quality standards|quality management plan, quality metrics, quality checklists
AC15|plan risk management|PH2|identify risks, assess probability and impact, plan responses — avoid, mitigate, transfer, accept|scope, schedule, budget, stakeholder register, historical data|risk register, risk response plans, risk matrix
AC16|plan communications|PH2|define who needs what information, when, how, and from whom|stakeholder register, organizational requirements|communication management plan, communication matrix
AC17|plan procurement|PH2|determine what to buy/contract, develop SOWs, select contract types|scope statement, make-or-buy analysis|procurement management plan, SOWs, RFP/RFQ templates
AC18|plan resources|PH2|identify, acquire, and plan utilization of human and physical resources|activity list, organizational resource pool|resource management plan, resource calendar, RACI matrix
AC19|develop project management plan|PH2|integrate all subsidiary plans into coherent master plan|all subsidiary plans|project management plan (master document)
AC20|baseline approval|PH2|present plan to sponsor and key stakeholders for formal sign-off|project management plan|signed baseline documents — scope, schedule, cost
# — Execution activities
AC21|direct and manage work|PH3|perform activities per plan, produce deliverables, manage resources|project management plan, approved changes|deliverables, work performance data, change requests, issue log entries
AC22|manage quality|PH3|audit processes and deliverables against quality plan, identify defects and improvements|quality management plan, quality checklists|quality audit reports, verified deliverables, defect logs
AC23|acquire and manage team|PH3|obtain team members, develop capabilities, manage performance, resolve conflicts|resource management plan, RACI|team assignments, team performance assessments
AC24|manage communications|PH3|distribute information per communication plan, respond to ad-hoc information requests|communication plan|status reports, meeting minutes, distributed reports
AC25|manage stakeholder engagement|PH3|work with stakeholders to meet their needs, address concerns, foster appropriate engagement|stakeholder register, communication plan|updated stakeholder register, issue log entries
AC26|conduct procurements|PH3|obtain seller responses, select sellers, award contracts|procurement plan, SOWs, RFPs|awarded contracts, selected sellers
AC27|manage knowledge|PH3|capture and share knowledge during execution — don't wait for closing|lessons learned register, organizational knowledge base|updated lessons learned, knowledge artifacts
# — Monitoring and control activities
AC28|monitor and control work|PH4|track progress, compare to baselines, report variances, recommend corrective actions|work performance data, baselines|work performance reports, variance analysis, corrective action recommendations
AC29|perform integrated change control|PH4|review all change requests, evaluate impact on scope/schedule/cost/quality, approve or reject|change requests, project management plan, baselines|approved or rejected changes, updated baselines, change log
AC30|validate scope|PH4|formal acceptance of completed deliverables by customer/sponsor against acceptance criteria|completed deliverables, acceptance criteria|accepted deliverables, change requests (for rejected items)
AC31|control scope|PH4|monitor scope status, manage scope baseline changes, prevent scope creep|scope baseline, work performance data|scope variance reports, change requests
AC32|control schedule|PH4|monitor schedule status, update forecasts, manage schedule baseline changes|schedule baseline, work performance data|schedule variance reports, schedule forecasts, change requests
AC33|control costs|PH4|monitor cost status, manage budget baseline changes, forecast completion costs|cost baseline, work performance data|cost variance reports, EAC/ETC forecasts, change requests
AC34|control quality|PH4|monitor quality results, identify root causes of defects, recommend corrective action|quality metrics, quality audit reports|quality control measurements, verified deliverables, change requests
AC35|monitor risks|PH4|track identified risks, monitor residual risks, identify new risks, evaluate risk process effectiveness|risk register, work performance data|risk audit results, updated risk register, change requests
AC36|monitor communications|PH4|ensure information needs of stakeholders are met per plan|communication plan, work performance data|updated communication plan if needed
AC37|control procurements|PH4|manage procurement relationships, monitor contract performance, make changes as needed|contracts, work performance data|closed procurements, contract change requests
AC38|earned value analysis|PH4|calculate PV, EV, AC, SV, CV, SPI, CPI, EAC, ETC, TCPI — compare to thresholds|cost baseline, schedule baseline, actual costs, percent complete|EV report, variance analysis, forecast
# — Closing activities
AC39|close project or phase|PH5|finalize all activities, hand off deliverables, release resources, close contracts|accepted deliverables, organizational process assets|final report, archived records
AC40|capture lessons learned|PH5|facilitated sessions to document what went well, what went poorly, recommendations for future|project records, team input, stakeholder feedback|lessons learned register
AC41|release resources|PH5|return team members to functional managers, release physical resources, close accounts|project completion confirmation|resource release confirmation
AC42|archive records|PH5|organize and store all project documentation in organizational archive|all project documents|archived project files

# deliverables(id|deliverable|phase|owner|acceptance_by|notes)
DL1|business case|PH1|sponsor/analyst|governance board|justification for project existence
DL2|project charter|PH1|PM with sponsor approval|sponsor|authorizes project and PM
DL3|stakeholder register|PH1-PH3|PM|PM (internal)|living document — updated throughout
DL4|requirements document|PH2|BA/PM|sponsor + stakeholders|functional, non-functional, regulatory
DL5|requirements traceability matrix|PH2|BA/PM|PM (internal)|maps requirements → deliverables → test cases
DL6|project scope statement|PH2|PM|sponsor|detailed scope description with exclusions
DL7|WBS|PH2|PM|PM + team leads|100% of scope decomposed
DL8|WBS dictionary|PH2|PM|PM (internal)|description, owner, acceptance criteria per work package
DL9|activity list|PH2|PM/scheduler|PM (internal)|all activities to produce work packages
DL10|network diagram|PH2|PM/scheduler|PM (internal)|activity dependencies — precedence diagram method
DL11|schedule baseline|PH2|PM/scheduler|sponsor|Gantt with critical path, milestones, baselined
DL12|cost baseline|PH2|PM/cost analyst|sponsor|time-phased budget (S-curve), baselined
DL13|project budget|PH2|PM|sponsor|cost baseline + contingency + management reserve
DL14|quality management plan|PH2|PM/QA lead|sponsor|standards, metrics, audit schedule
DL15|risk register|PH2-PH4|PM/risk owner|PM (internal)|living document — ID, description, probability, impact, response, owner, status
DL16|communication plan|PH2|PM|sponsor|who/what/when/how/from whom matrix
DL17|procurement plan|PH2|PM/procurement|sponsor|make-or-buy, contract types, SOWs
DL18|resource management plan|PH2|PM|PM + functional managers|resource calendar, RACI matrix
DL19|project management plan|PH2|PM|sponsor|master integrating all subsidiary plans
DL20|status reports|PH3-PH4|PM|sponsor + stakeholders|periodic (weekly/biweekly) progress reports
DL21|change log|PH3-PH5|PM|PM (internal)|all change requests with disposition
DL22|issue log|PH3-PH5|PM|PM (internal)|all issues with owner, status, resolution
DL23|EV reports|PH4|PM/cost analyst|sponsor|PV, EV, AC, SV, CV, SPI, CPI, EAC, ETC
DL24|completed deliverables|PH3|team leads|customer/sponsor via AC30|the actual work products
DL25|final report|PH5|PM|sponsor|summary of performance, variances, lessons reference
DL26|lessons learned register|PH3-PH5|PM + team|PM (internal)|captured throughout, formalized at closing

# roles(id|role|authority|responsibilities|accountable_for)
RL1|sponsor|highest project authority — approves charter, budget, baselines, major changes|provide funding, remove organizational obstacles, make final scope/schedule/cost trade-offs, champion project|project success, business case realization
RL2|project manager (PM)|delegated authority from sponsor — manages day-to-day execution|plan, execute, monitor, control, close — manage scope/schedule/cost/quality/risk/communication/procurement/resources|delivering project within constraints
RL3|business analyst (BA)|requirements authority — elicits, documents, validates requirements|gather stakeholder needs, write requirements, maintain RTM, verify deliverables against requirements|requirements completeness and accuracy
RL4|team lead|technical authority within work area|decompose work packages into tasks, assign team work, track progress, escalate issues, review technical quality|work package completion to spec and schedule
RL5|team member|execution authority over assigned tasks|perform tasks, report progress, flag blockers, participate in reviews|task completion, accurate status reporting
RL6|customer/end user|acceptance authority — defines needs, accepts deliverables|provide requirements, participate in reviews, accept or reject deliverables|clear requirements, timely feedback
RL7|functional manager|resource authority — owns team members outside the project|provide resources, negotiate availability, approve time allocation|resource availability and skill adequacy
RL8|quality assurance (QA)|audit authority — verifies process and product quality|audit processes, inspect deliverables, report defects, verify corrections|quality conformance verification
RL9|procurement manager|contracting authority — manages vendor relationships|develop SOWs, manage RFP/RFQ process, negotiate contracts, monitor vendor performance|contract compliance, vendor delivery
RL10|governance board / steering committee|escalation authority — resolves cross-project conflicts, approves strategic changes|review project status, approve major changes, resolve sponsor-level conflicts, authorize contingency use|strategic alignment, portfolio-level trade-offs
RL11|risk owner|response authority for assigned risks|execute risk response, monitor trigger conditions, report risk status|risk mitigation execution

# tracking(id|mechanism|description|frequency|owner|inputs|outputs)
TK1|status reporting|periodic written report on progress, issues, risks, upcoming milestones|weekly or biweekly|PM|work performance data, issue/risk logs|status report (DL20)
TK2|earned value management (EVM)|quantitative progress measurement integrating scope, schedule, cost|per reporting period|PM/analyst|PV, EV, AC from cost baseline and actuals|EV metrics: SV, CV, SPI, CPI, EAC, ETC, TCPI (DL23)
TK3|milestone tracking|track completion of key milestones against baseline dates|per milestone|PM|milestone list, actual completion dates|milestone status (on-time, late, at-risk)
TK4|issue tracking|log, assign, track, resolve issues — anything impeding progress that is not a risk|as issues arise|PM|team reports, stakeholder concerns|issue log (DL22) — ID, description, owner, priority, status, resolution, dates
TK5|risk tracking|monitor identified risks, watch for triggers, assess new risks|weekly or per event|PM/risk owner|risk register, trigger conditions|updated risk register (DL15), risk audit results
TK6|change tracking|log all change requests with impact assessment and disposition|per change request|PM/CCB|change requests, impact analysis|change log (DL21)
TK7|action item tracking|track commitments made in meetings — who, what, by when|per meeting|PM|meeting minutes|action item list with status
TK8|defect tracking|log, classify, assign, track, verify defects in deliverables|as defects found|QA|inspection/test results|defect log — ID, severity, owner, status, root cause, resolution
TK9|resource tracking|monitor resource utilization against plan — overallocation, underallocation, availability|weekly|PM|resource plan, timesheets|resource utilization report, reallocation recommendations
TK10|schedule variance tracking|compare actual start/finish dates to baseline, calculate float consumption|weekly|PM/scheduler|schedule baseline, actual dates|schedule variance report, critical path update
TK11|cost variance tracking|compare actual costs to planned costs (EV basis), identify trends|per reporting period|PM/analyst|cost baseline, actual expenditures|cost variance report, EAC forecast
TK12|requirements traceability|verify each requirement has a deliverable, test case, and acceptance record|per deliverable acceptance|BA|RTM, test results, acceptance records|updated RTM showing coverage and gaps

# estimating(id|technique|description|accuracy_range|when_to_use|inputs)
ES1|analogous (top-down)|use actual data from similar past project, adjusted for differences|±25-50% (rough order of magnitude)|early planning, limited detail available|historical project data, expert judgment
ES2|parametric|use statistical relationship between variables — cost per unit, hours per function point|±10-25% depending on model quality|when valid parametric model exists and input variables are quantifiable|parametric model, quantity measurements
ES3|bottom-up|estimate each work package or activity individually, sum to total|±5-15% (most accurate)|detailed planning, WBS fully decomposed|WBS dictionary, activity list, resource rates
ES4|three-point (PERT)|weighted average of optimistic, most likely, pessimistic — E = (O + 4M + P) / 6|provides range and expected value|when uncertainty is significant and three estimates are obtainable|optimistic, most likely, pessimistic estimates per activity
ES5|vendor quotes|actual prices from suppliers for purchased items or contracted work|exact for quoted items|procurement — materials, software licenses, contracted services|SOW, vendor proposals
ES6|reserve analysis|add contingency for known risks (estimated from risk register) and management reserve for unknown risks|contingency: typically 5-15% of cost baseline; management reserve: 5-10% additional|budgeting — after cost baseline established|risk register with probability × impact values
ES7|rough order of magnitude (ROM)|very early estimate based on minimal information — ±50% or wider|±25-75%|business case, feasibility, go/no-go decision|concept description, analogous projects

# dependencies(id|type|code|description|example)
DP1|finish-to-start|FS|successor cannot start until predecessor finishes|testing cannot start until coding finishes
DP2|finish-to-finish|FF|successor cannot finish until predecessor finishes|documentation cannot finish until coding finishes
DP3|start-to-start|SS|successor cannot start until predecessor starts|coding and code review can start together
DP4|start-to-finish|SF|successor cannot finish until predecessor starts (rare)|night shift cannot finish until day shift starts
DP5|mandatory|—|inherent in the work — physically or contractually required|foundation must precede framing
DP6|discretionary|—|preferred ordering based on best practice or team preference|design review before coding (could skip but shouldn't)
DP7|external|—|dependency on something outside the project|regulatory approval, vendor delivery, client data
DP8|lead|—|successor can start before predecessor finishes by specified overlap|start testing 2 days before coding finishes (lead = -2 days)
DP9|lag|—|mandatory waiting time between predecessor and successor|concrete must cure 7 days before framing (lag = +7 days)

# risk(id|concept|description|notes)
RK1|risk identification|brainstorm, checklists, interviews, SWOT, assumptions analysis — capture in risk register|continuous throughout project — not just during planning
RK2|qualitative analysis|assess probability (1-5 or %) and impact (1-5 or $) of each risk, calculate risk score = P × I|produces prioritized risk list — focus response planning on top risks
RK3|quantitative analysis|Monte Carlo simulation, decision tree analysis, sensitivity analysis — probabilistic schedule/cost modeling|optional for most projects — required for large/complex/high-stakes
RK4|risk response — avoid|change plan to eliminate the risk entirely|remove scope element, extend schedule, add requirement
RK5|risk response — mitigate|reduce probability or impact to acceptable level|add testing, prototype first, assign experienced resource
RK6|risk response — transfer|shift impact to third party — insurance, warranty, fixed-price contract|does not eliminate risk — transfers financial consequence
RK7|risk response — accept|acknowledge risk and take no proactive action — may plan contingency if triggered|active acceptance: contingency plan ready; passive acceptance: deal with it if it happens
RK8|risk response — escalate|risk is beyond project authority — escalate to program, portfolio, or governance level|appropriate when risk affects multiple projects or requires organizational decision
RK9|risk trigger|event or condition indicating risk has occurred or is about to occur|each risk should have defined triggers in risk register
RK10|residual risk|risk remaining after response execution — the accepted portion|all responses have residual risk — it is tracked, not ignored
RK11|secondary risk|new risk created by executing a risk response|mitigating one risk may introduce another — must be identified and assessed
RK12|risk owner|person responsible for monitoring the risk and executing the response|every risk must have exactly one owner — no orphan risks
RK13|contingency reserve|budget or schedule buffer for identified risks with planned responses|sized from risk register P×I analysis, consumed only when specific risks materialize
RK14|management reserve|budget or schedule buffer for unknown risks — things that weren't identified|controlled by sponsor/governance, not PM — consumed only with sponsor approval

# change_control(id|step|description|responsible|notes)
CC1|change request submission|any stakeholder submits written change request describing what and why|requestor|must describe proposed change, justification, and urgency
CC2|impact assessment|PM and relevant experts evaluate impact on scope, schedule, cost, quality, risk|PM + SMEs|quantify impact on all baselines — not just the obvious one
CC3|CCB review|change control board reviews impact assessment and makes approve/reject/defer decision|CCB (sponsor, PM, key stakeholders)|CCB composition defined in project management plan
CC4|implementation|if approved: update baselines, update plan, communicate change, execute|PM + team|baselines are re-baselined only through this process
CC5|verification|verify the change was implemented correctly and produced intended result|QA/PM|close the change request in the change log
CC6|change log update|record disposition, implementation date, verification result|PM|full audit trail of every change to every baseline

# methods(id|method|cycle_model|planning_depth|change_philosophy|strengths|weaknesses)
MT1|waterfall (true)|sequential phases, each completed before next — but with feedback loops between adjacent phases for rework|full plan before execution — all requirements, all design, all schedule upfront|formal change control — baselines are sacred, changes are controlled and costed|complete visibility into scope/schedule/cost before execution; clear accountability; works for well-understood, stable-requirements projects|late discovery of problems; heavy documentation; assumes requirements are knowable upfront; change is expensive
MT2|iterative waterfall|waterfall phases repeated in planned cycles — each cycle refines and extends|plan per cycle, each cycle adds scope increment|formal change control per cycle, scope can shift between cycles|progressive elaboration — requirements refined through experience; earlier feedback than pure waterfall|still phase-gated within each cycle; overhead of re-planning per cycle
MT3|V-model|waterfall with explicit test phase mirroring each development phase — requirements↔acceptance, design↔integration, detail↔unit|full plan before execution, test plans developed alongside design|formal — same as waterfall|tight verification — every specification level has a corresponding test level; defects found earlier|same rigidity as waterfall; heavy documentation; test plans may be written before understanding is complete
MT4|spiral|risk-driven cycles — each cycle: determine objectives → identify/resolve risks → develop/verify → plan next cycle|plan per cycle, emphasis on risk resolution before commitment|risk-based — scope committed only after risk is acceptable|risk reduction drives decisions — expensive mistakes avoided; appropriate for high-risk projects|requires risk assessment expertise; overhead of risk analysis per cycle; less predictable schedule
MT5|agile (Scrum)|fixed-length sprints (1-4 weeks), product backlog prioritized by value, cross-functional teams|just-in-time — sprint backlog planned per sprint from prioritized product backlog|embrace change — backlog is reprioritized every sprint; no baseline in waterfall sense|fast feedback, adaptive, working software each sprint, continuous stakeholder engagement|less cost/schedule predictability; requires active customer participation; scope is emergent not predetermined; struggles with fixed-price contracts
MT6|Kanban|continuous flow, no fixed iterations, WIP limits per workflow state, pull-based|no sprint planning — items pulled from prioritized backlog when capacity allows|continuous — items can be added/reprioritized at any time|visualizes workflow, minimizes WIP, identifies bottlenecks, no sprint overhead|less structure — requires discipline; no natural planning/review cadence; harder to forecast delivery dates
MT7|hybrid (water-Scrum-fall)|waterfall for governance and milestones, agile for execution within phases|phase-level waterfall planning, sprint-level agile within execution phase|formal at phase gates, adaptive within phases|best of both — governance satisfaction with adaptive execution; common in enterprise|complexity of two systems; risk of treating agile as "mini-waterfall"; requires PM and Scrum Master
MT8|critical chain|schedule based on resource constraints not just task dependencies — uses buffer management instead of task-level contingency|full plan with buffers — project buffer at end, feeding buffers at merge points|formal — buffer consumption triggers corrective action thresholds|addresses resource contention and student syndrome (Parkinson's law); buffer management gives early warning|requires cultural change — task owners must give aggressive estimates without padding; less intuitive than CPM

# methods_vs_waterfall(id|method|what_varies_from_waterfall|what_stays_same)
MV1|iterative waterfall|phases repeat in cycles instead of once|phase gates, formal deliverables, change control, roles
MV2|V-model|adds explicit test phase mirror for each dev phase|everything else — sequential, fully planned, baselined
MV3|spiral|risk analysis inserted before each phase commitment; cycles driven by risk not scope|governance, deliverables, change control (per cycle)
MV4|agile/Scrum|planning is per-sprint not upfront; scope is emergent; no formal baseline|stakeholder management, risk awareness, quality, team management, retrospectives (≈lessons learned)
MV5|Kanban|no iterations at all — continuous flow; no sprint boundary|WIP management, pull-based prioritization, visual tracking, stakeholder communication
MV6|hybrid|execution phase uses sprints; planning/closing remain waterfall|phase gates, governance, milestone tracking, formal change control at phase level
MV7|critical chain|resource-constrained scheduling replaces CPM; buffers replace per-task contingency|WBS, activity sequencing, risk management, change control, governance

# meetings(id|meeting|frequency|attendees|purpose|outputs)
MG1|kickoff|once (start of project)|sponsor, PM, team, key stakeholders|align on charter, scope, roles, communication plan, expectations|meeting minutes, confirmed roles, shared understanding
MG2|status meeting|weekly or biweekly|PM, team leads, stakeholders (optional)|review progress, issues, risks, upcoming milestones, action items|status report, updated action items
MG3|steering committee|monthly or per milestone|sponsor, governance board, PM|review project health, approve major decisions, resolve escalations|decisions documented, direction confirmed
MG4|change control board (CCB)|as needed (per change request batch)|sponsor, PM, SMEs, affected stakeholders|review and approve/reject change requests|approved/rejected changes, updated change log
MG5|risk review|weekly or biweekly (during planning and execution)|PM, risk owners, SMEs|review risk register, assess new risks, check triggers, evaluate response effectiveness|updated risk register
MG6|lessons learned session|at phase gates and closing|PM, team, stakeholders|capture what worked, what didn't, recommendations|lessons learned entries
MG7|daily standup (agile contexts)|daily (15 min)|team members, Scrum Master/PM|what I did, what I'll do, blockers|blocker list for PM action
MG8|sprint review (agile contexts)|end of sprint|team, PO, stakeholders|demo completed work, gather feedback, update backlog|accepted/rejected stories, backlog updates
MG9|sprint retrospective (agile contexts)|end of sprint|team, Scrum Master|what went well, what to improve, action items for next sprint|improvement action items
MG10|design/technical review|per deliverable or milestone|PM, team leads, SMEs, QA|review technical deliverables against requirements and standards|review findings, defect list, approval or rework decision
MG11|gate review|at phase boundaries|sponsor, governance, PM|decide go/no-go/rework for phase transition|gate decision documented

# metrics(id|metric|formula_or_description|interpretation|threshold)
ME1|planned value (PV)|budgeted cost of work scheduled — cumulative budget through reporting date|what SHOULD have been spent by now|baseline reference
ME2|earned value (EV)|budgeted cost of work performed — value of completed work at budget rates|what WAS accomplished (in budget terms)|compared to PV and AC
ME3|actual cost (AC)|actual expenditures through reporting date|what WAS actually spent|compared to EV
ME4|schedule variance (SV)|EV - PV|negative = behind schedule, positive = ahead|SV < 0 requires corrective action
ME5|cost variance (CV)|EV - AC|negative = over budget, positive = under|CV < 0 requires corrective action
ME6|schedule performance index (SPI)|EV / PV|< 1.0 = behind, 1.0 = on, > 1.0 = ahead|SPI < 0.9 triggers escalation typically
ME7|cost performance index (CPI)|EV / AC|< 1.0 = over budget, 1.0 = on, > 1.0 = under|CPI < 0.9 triggers escalation; CPI rarely recovers once below 0.85
ME8|estimate at completion (EAC)|BAC / CPI (most common formula)|forecasted total cost at current performance rate|compared to BAC for overrun magnitude
ME9|estimate to complete (ETC)|EAC - AC|how much more will it cost to finish|resource allocation and funding decisions
ME10|to-complete performance index (TCPI)|(BAC - EV) / (BAC - AC)|required future CPI to finish on budget|TCPI > 1.0 means must improve; > 1.2 is very unlikely
ME11|percent complete|EV / BAC × 100|overall progress toward completion|objective when based on EV; subjective when self-reported
ME12|variance at completion (VAC)|BAC - EAC|expected budget overrun or underrun at finish|negative = overrun
ME13|requirements coverage|requirements with deliverables / total requirements × 100|RTM completeness — unlinked requirements are missing scope|100% required before execution baseline
ME14|defect density|defects found / deliverable size (pages, KLOC, function points)|quality indicator — higher density may indicate inadequate process|compare to organizational benchmarks
ME15|milestone slip rate|milestones completed late / total milestones × 100|schedule reliability indicator|> 20% indicates systemic schedule problems
ME16|change request rate|change requests per reporting period|scope stability indicator — high rate indicates poor requirements or volatile environment|trending upward signals problem
ME17|risk exposure|Σ(probability × impact) for all active risks|aggregate project risk level|compare to contingency reserve — exposure > reserve = underfunded risk
ME18|resource utilization|actual hours / available hours × 100|resource loading — 80-90% is healthy, >95% is unsustainable, <60% is wasteful|target 80-85%

# communication(id|type|direction|formality|frequency|examples)
CM1|upward reporting|PM → sponsor / governance|formal|periodic (weekly/monthly)|status reports, EV reports, gate review presentations, escalation memos
CM2|downward direction|PM → team|formal to informal|as needed + weekly|work assignments, decisions, approved changes, schedule updates
CM3|lateral coordination|PM ↔ other PMs, functional managers|semi-formal|as needed|resource negotiation, dependency coordination, shared risk discussions
CM4|stakeholder engagement|PM ↔ external stakeholders|formal|per communication plan|requirements reviews, progress updates, acceptance sessions
CM5|team collaboration|team ↔ team|informal|continuous|technical discussions, problem-solving, knowledge sharing
CM6|escalation|PM → sponsor → governance|formal|as needed — time-sensitive|issues exceeding PM authority, risk triggers, budget/schedule threats
CM7|vendor communication|PM/procurement ↔ vendors|formal (contractual)|per contract terms|SOW clarifications, progress reviews, change orders, acceptance

# tools(id|tool_type|purpose|key_features|examples)
TL1|scheduling software|develop and maintain schedule|Gantt charts, CPM calculation, resource leveling, baseline comparison, milestone tracking|MS Project, Primavera, Smartsheet, ProjectLibre
TL2|issue/defect tracker|log, assign, track, resolve issues and defects|status workflow, assignment, priority, linking, aging reports|Jira, Azure DevOps, Redmine, GitHub Issues
TL3|document repository|store, version, share project documents|version control, access control, search, approval workflow|SharePoint, Confluence, Google Drive, wiki
TL4|communication platform|team communication and coordination|channels, threads, file sharing, notifications, meeting scheduling|Slack, Teams, email, Zoom
TL5|EVM tool|calculate and report earned value metrics|PV/EV/AC input, automatic SPI/CPI/EAC calculation, trend charts|spreadsheet, Deltek Cobra, custom dashboards
TL6|risk register tool|maintain risk register with probability, impact, response, status|risk matrix visualization, status tracking, trigger alerts|spreadsheet, risk module in PM tools, custom database
TL7|requirements management|document, trace, version requirements|RTM, change tracking, coverage analysis, linking to test cases|DOORS, Jama, ReqView, spreadsheet
TL8|WBS tool|create and maintain work breakdown structure|hierarchical decomposition, code numbering, dictionary linking|WBS Chart Pro, MindManager, spreadsheet, PM tool WBS module
TL9|resource management|plan and track resource allocation|resource calendar, utilization reports, allocation conflicts, skill matching|PM tool resource module, spreadsheet, resource management platform
TL10|change management tool|log, assess, approve, track changes|workflow (submit→assess→review→approve→implement→verify), audit trail|change management module in PM tools, spreadsheet with workflow

# rules(id|rule|domain|rationale|violation_consequence)
RU1|scope must be baselined before execution begins|scope|without baseline, there is no reference for variance — you cannot measure deviation from nothing|invisible scope creep, no cost/schedule control, project never finishes or delivers wrong thing
RU2|every change to baseline goes through change control|change|uncontrolled changes accumulate into scope creep, schedule slip, and budget overrun|baselines become meaningless, forecasts unreliable, stakeholder trust erodes
RU3|every risk must have exactly one owner|risk|unowned risks are unmanaged risks — nobody monitors, nobody responds|risks materialize without response, avoidable impacts become unavoidable
RU4|every deliverable must have acceptance criteria before work begins|quality|without acceptance criteria, "done" is undefined — disputes at acceptance are inevitable|deliverable rejected after significant rework investment, stakeholder conflict
RU5|status reports must compare actual to baseline, not actual to current plan|tracking|comparing to current plan (which may have been adjusted) hides cumulative variance|variance hidden, true project health obscured, late discovery of overrun
RU6|estimates must have a documented basis|estimating|undocumented estimates cannot be validated, calibrated, or improved|repeated estimation errors, no organizational learning, no defensible basis for budget
RU7|contingency reserve is for identified risks — not for scope additions|budget|using contingency for scope changes depletes risk buffer without adding planned risk|risk buffer consumed, project exposed to unreserved identified risks
RU8|WBS must include 100% of scope — no work exists outside the WBS|scope|work outside WBS is unplanned, unbudgeted, unscheduled, and uncontrolled|phantom work consumes resources and time without visibility
RU9|critical path must be identified and actively managed|schedule|non-critical activities have float — only critical path determines project duration|effort spent optimizing non-critical activities while critical path slips
RU10|lessons learned must be captured during execution, not only at closing|knowledge|waiting until closing loses context and detail — team members may have left|superficial lessons, repeated mistakes across projects
RU11|PM must control communication — stakeholders should not learn project status from rumors|communication|uncontrolled information creates misperception, panic, or false confidence|stakeholder trust lost, decisions made on incomplete or incorrect information
RU12|resource conflicts must be resolved through negotiation with functional managers, not by overloading team members|resources|sustained overallocation (>95% utilization) degrades quality, increases errors, causes turnover|burnout, quality defects, team attrition, schedule paradox (more hours = less productivity)
RU13|meeting outputs must include documented decisions and assigned action items with dates|meetings|meetings without documented outputs produce no accountability — discussions are forgotten|repeated discussions, no progress, meeting fatigue, stakeholder disengagement
RU14|procurement SOW must be unambiguous — disputes trace to ambiguous SOWs|procurement|vendor will deliver to the letter of the SOW — if the SOW is vague, delivery will be vague|contract disputes, rework, change orders, vendor relationship damage
RU15|earned value must use objective completion measurement, not subjective percent complete|tracking|self-reported "90% done" is unreliable — objective measures (milestones, deliverables, units) prevent gaming|inflated progress reporting, late discovery of true status, "90% done syndrome"
RU16|assumptions must be documented and monitored — each is a risk waiting to materialize|risk|undocumented assumptions are invisible risks — when they prove wrong, impact is a surprise|surprise impacts from failed assumptions, no prepared response

# failure_modes(id|mode|cause|symptom|prevention)
FM1|scope creep|uncontrolled additions without change control — requirements added informally|schedule extends, budget consumed, team confused about priorities, deliverables multiply|formal change control (CC1-CC6), baselined scope (RU1), saying no with data
FM2|90% done syndrome|subjective percent complete reporting, no objective completion criteria|project reports 90% complete for weeks or months, true remaining work unknown|EVM with objective measurement (RU15), milestone-based tracking (TK3)
FM3|planning fallacy|underestimating duration and cost based on optimistic assumptions|every activity takes longer and costs more than planned, schedule/budget consumed early|three-point estimating (ES4), historical data (ES1), reserve analysis (ES6), challenge assumptions
FM4|stakeholder surprise|inadequate communication — stakeholders learn bad news late or from wrong sources|stakeholder anger, trust breakdown, escalation, project intervention or cancellation|communication plan (AC16), regular reporting (TK1), controlled messaging (RU11)
FM5|analysis paralysis|over-planning, excessive documentation, inability to commit to execution|planning phase extends indefinitely, no deliverables produced, team frustrated|time-boxed planning, "good enough" planning standard, iterative refinement
FM6|gold plating|adding features or quality beyond what requirements specify|cost and schedule consumed on unrequested work, actual requirements under-delivered|strict scope management (RU1, RU8), acceptance criteria (RU4), "not in scope = not done"
FM7|resource contention|shared resources pulled between projects without clear priority|tasks stall waiting for resources, schedule slips, workarounds introduce risk|resource management plan (AC18), escalation to functional managers (RU12), priority negotiation
FM8|orphan risks|risks identified but never assigned an owner or monitored|risks materialize without prepared response, avoidable impacts hit the project|risk ownership rule (RU3), regular risk reviews (MG5, TK5)
FM9|death march|project is clearly failing but no one has authority or willingness to cancel or reset|team burned out, quality abandoned, budget and schedule massively overrun|governance reviews (MG3, MG11), escalation paths (CM6), kill criteria defined upfront
FM10|requirements volatility|requirements change faster than they can be implemented|constant rework, no stable design, team demoralized, schedule meaningless|change control (CC1-CC6), requirements freeze for each cycle, or switch to agile if volatility is inherent
FM11|vendor dependency failure|critical path runs through a vendor who underperforms or defaults|deliverables blocked, schedule slips, costs increase for workarounds or replacement|vendor qualification, contract terms with penalties, contingency plans, multiple-source strategy
FM12|absent sponsor|sponsor is named but unavailable for decisions, reviews, or issue resolution|decisions delayed, escalations stall, team loses direction, governance ineffective|sponsor engagement plan, deputy sponsor identified, escalation to governance if sponsor absent

# relationships(from|rel|to)
# phase sequence
PH1|enables|PH2
PH2|enables|PH3
PH3|enables|PH5
PH4|constrains|PH3
PH4|enables|PH5
# activities → phases
AC1-AC4|component_of|PH1
AC5-AC20|component_of|PH2
AC21-AC27|component_of|PH3
AC28-AC38|component_of|PH4
AC39-AC42|component_of|PH5
# activities → deliverables
AC1|produces|DL1
AC3|produces|DL2
AC4|produces|DL3
AC5|produces|DL4,DL5
AC6|produces|DL6
AC7|produces|DL7,DL8
AC8|produces|DL9
AC9|produces|DL10
AC10|produces|DL9
AC11|produces|DL11
AC12|produces|DL12
AC13|produces|DL13
AC14|produces|DL14
AC15|produces|DL15
AC16|produces|DL16
AC17|produces|DL17
AC18|produces|DL18
AC19|produces|DL19
AC21|produces|DL24
AC24|produces|DL20
AC29|produces|DL21
AC38|produces|DL23
AC39|produces|DL25
AC40|produces|DL26
# activity dependencies
AC1|enables|AC2,AC3
AC3|enables|AC4,AC5
AC4|enables|AC5,AC16
AC5|enables|AC6,AC14
AC6|enables|AC7
AC7|enables|AC8
AC8|enables|AC9,AC10,AC12
AC9|enables|AC11
AC10|enables|AC11
AC12|enables|AC13
AC11|enables|AC19,AC20
AC13|enables|AC19,AC20
AC14|enables|AC19
AC15|enables|AC19
AC16|enables|AC19
AC17|enables|AC19
AC18|enables|AC19
AC19|enables|AC20
AC20|enables|AC21
AC21|enables|AC28,AC30
AC30|enables|AC39
AC39|enables|AC40,AC41,AC42
# roles → activities
RL1|responsible_for|AC2,AC20,AC29
RL2|responsible_for|AC3,AC5-AC19,AC21,AC24,AC25,AC28-AC38
RL3|responsible_for|AC5,TK12
RL4|responsible_for|AC21
RL5|responsible_for|AC21
RL6|responsible_for|AC5,AC30
RL7|responsible_for|AC18,AC23
RL8|responsible_for|AC22,AC34
RL9|responsible_for|AC17,AC26,AC37
RL10|responsible_for|MG3,MG4,MG11
RL11|responsible_for|RK5,TK5
# foundations → activities
FD2|constrains|AC6,AC7,AC31
FD3|constrains|AC9,AC10,AC11,AC32
FD4|constrains|AC12,AC13,AC33
FD5|constrains|AC14,AC22,AC34
FD6|constrains|AC15,AC35
FD7|constrains|AC4,AC25
FD8|constrains|AC20,AC28
FD12|enables|AC8,AC12
FD13|constrains|AC11,AC32
FD14|implements|TK2,AC38
FD15|implements|CC1-CC6
# tracking → deliverables
TK1|produces|DL20
TK2|produces|DL23
TK4|produces|DL22
TK5|produces|DL15
TK6|produces|DL21
# metrics → tracking
ME1|component_of|TK2
ME2|component_of|TK2
ME3|component_of|TK2
ME4|derives_from|ME2,ME1
ME5|derives_from|ME2,ME3
ME6|derives_from|ME2,ME1
ME7|derives_from|ME2,ME3
ME8|derives_from|ME7
ME9|derives_from|ME8,ME3
ME10|derives_from|ME2,ME1,ME3
ME11|derives_from|ME2
# methods → waterfall template
MT1|enables|MT2,MT3,MT4,MT5,MT6,MT7,MT8
MT2|specializes|MT1
MT3|specializes|MT1
MT4|specializes|MT1
MT7|extends|MT1,MT5
# failure modes → rules that prevent them
FM1|prevented_by|RU1,RU2,RU8
FM2|prevented_by|RU15
FM3|prevented_by|ES4,ES1,ES6
FM4|prevented_by|RU11,AC16,TK1
FM5|prevented_by|MT5,MT2
FM6|prevented_by|RU1,RU4,RU8
FM7|prevented_by|RU12,AC18
FM8|prevented_by|RU3,TK5,MG5
FM9|prevented_by|MG3,MG11,CM6
FM10|prevented_by|CC1-CC6,MT5
FM11|prevented_by|AC17,RU14
FM12|prevented_by|RL1,CM6
# change control sequence
CC1|enables|CC2
CC2|enables|CC3
CC3|enables|CC4
CC4|enables|CC5
CC5|enables|CC6
# dependency types
DP1|subtype_of|DP5,DP6,DP7
DP2|subtype_of|DP5,DP6,DP7
DP3|subtype_of|DP5,DP6,DP7
DP4|subtype_of|DP5,DP6,DP7
DP8|modifies|DP1-DP4
DP9|modifies|DP1-DP4
# risk management chain
RK1|enables|RK2
RK2|enables|RK3,RK4-RK8
RK4|produces|RK10,RK11
RK5|produces|RK10,RK11
RK6|produces|RK10,RK11
RK9|triggers|RK7
RK13|derives_from|RK2
RK14|independent_of|RK13
# cross-references to other compactions
FD13|cross_ref|ME4
FD6|cross_ref|FC1-FC10
FD15|cross_ref|CC1-CC6
FM3|cross_ref|BI14
FM9|cross_ref|DP1
TK2|cross_ref|ME1-ME12
AC15|cross_ref|RK1-RK14

# section_index(section|title|ids)
1|Foundations|FD1-FD18
2|Phases|PH1-PH5
3|Activities|AC1-AC42
4|Deliverables|DL1-DL26
5|Roles|RL1-RL11
6|Tracking Mechanisms|TK1-TK12
7|Estimating Techniques|ES1-ES7
8|Dependencies|DP1-DP9
9|Risk Management|RK1-RK14
10|Change Control|CC1-CC6
11|Methods|MT1-MT8
12|Methods vs Waterfall|MV1-MV7
13|Meetings|MG1-MG11
14|Metrics|ME1-ME18
15|Communication|CM1-CM7
16|Tools|TL1-TL10
17|Rules|RU1-RU16
18|Failure Modes|FM1-FM12

# decode_legend
id_prefixes: FD=foundation, PH=phase, AC=activity, DL=deliverable, RL=role, TK=tracking, ES=estimating, DP=dependency, RK=risk, CC=change_control, MT=method, MV=method_vs_waterfall, MG=meeting, ME=metric, CM=communication, TL=tool, RU=rule, FM=failure_mode
rel_types: enables|constrains|component_of|produces|derives_from|responsible_for|implements|specializes|extends|prevented_by|subtype_of|modifies|triggers|independent_of|cross_ref
cross_ref_prefixes: FC=fault_class (TROUBLESHOOTING), BI=bias (COGNITION), DP=diagnostic_pattern (TROUBLESHOOTING)
metric_abbreviations: PV=planned_value, EV=earned_value, AC=actual_cost, SV=schedule_variance, CV=cost_variance, SPI=schedule_performance_index, CPI=cost_performance_index, EAC=estimate_at_completion, ETC=estimate_to_complete, TCPI=to_complete_performance_index, BAC=budget_at_completion, VAC=variance_at_completion
dependency_codes: FS=finish-to-start, FF=finish-to-finish, SS=start-to-start, SF=start-to-finish
role_abbreviations: PM=project_manager, BA=business_analyst, QA=quality_assurance, CCB=change_control_board, SOW=statement_of_work, RFP=request_for_proposal, RTM=requirements_traceability_matrix, WBS=work_breakdown_structure, RACI=responsible_accountable_consulted_informed
method_note: waterfall (MT1) is the template — all other methods are variations that modify specific aspects while preserving others (see MV1-MV7)
confidence: generated from LLM weights — reflects established PM practice (PMBOK, PRINCE2, PMI standards, AACE, Earned Value Management System criteria)

# relation_mapping(doc_rel|canonical_rel|notes)
enables|enables|exact match
constrains|constrains|exact match
component_of|part_of|exact semantic match
produces|produces|exact match
derives_from|derived_from|exact match
responsible_for|manages|role responsible for activity = manages that activity
implements|implements|exact match
specializes|specializes|exact match
extends|extends|exact match
prevented_by|mitigated_by|failure mode prevented by rule = mitigated_by
subtype_of|specializes|exact semantic match
modifies|influences|lead/lag modifies dependency = influences its timing
triggers|activates|risk trigger activates risk response = activates
independent_of|isolates|management reserve independent of contingency = isolates from contingency
cross_ref|references|cross-domain link = references
