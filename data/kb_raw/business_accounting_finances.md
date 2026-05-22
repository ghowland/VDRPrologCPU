# BUSINESS ACCOUNTING, BOOKKEEPING & FINANCE — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: concepts → accounts → double_entry → financial_statements → transactions → ratios → tax → payroll → cash_management → budgeting → controls → compliance → failure_modes → distinctions → relationships → decode_legend

# concepts(id|name|definition|category)
CO1|Accounting|systematic recording, classifying, summarizing, and reporting of financial transactions; provides information for decision-making; language of business|foundation
CO2|Bookkeeping|daily recording of financial transactions in journals and ledgers; subset of accounting; mechanical data entry; accuracy and completeness required|foundation
CO3|Double-Entry Bookkeeping|every transaction affects at least two accounts; debits must equal credits; self-balancing system; invented/codified by Luca Pacioli (1494)|foundation
CO4|Accrual Basis|recognize revenue when earned and expenses when incurred, regardless of cash receipt/payment timing; GAAP required for most businesses above sole proprietor|foundation
CO5|Cash Basis|recognize revenue when cash received and expenses when cash paid; simpler; permitted for small businesses (under IRS thresholds); does not match revenue with related expenses|foundation
CO6|Accounting Period|time span covered by financial statements; fiscal year (any 12 months), calendar year, quarter, month; consistency required|foundation
CO7|Going Concern|assumption that business will continue operating indefinitely; underlies asset valuation (historical cost vs liquidation value); auditors assess|foundation
CO8|Materiality|threshold above which information would influence a reasonable user's decision; immaterial amounts may use simplified treatment; judgment-based|foundation
CO9|Conservatism (Prudence)|when uncertainty exists, prefer methods that understate assets/income rather than overstate; recognize losses immediately, gains only when realized|foundation
CO10|Matching Principle|expenses recognized in same period as the revenue they helped generate; depreciation matches asset cost to useful life; prepaid expenses allocated over benefit period|foundation
CO11|Revenue Recognition|revenue recorded when performance obligation satisfied (goods delivered, services rendered); not when cash received (accrual); ASC 606 five-step model|foundation
CO12|Historical Cost|assets recorded at original purchase price; objective and verifiable; may not reflect current market value; basis for most asset recording|foundation
CO13|Fair Value|price that would be received to sell asset or paid to transfer liability in orderly transaction; ASC 820; used for certain investments, impairments, acquisitions|foundation
CO14|Entity Principle|business is separate economic entity from its owners; personal transactions excluded from business records; legal form (sole proprietorship, partnership, LLC, corporation) affects specifics|foundation
CO15|Fiscal Year|12-month accounting period; may differ from calendar year; chosen to align with business cycle (retail: Feb-Jan to capture holiday season); consistency required|foundation
CO16|Chart of Accounts|numbered list of all accounts used by business; organized by category (assets, liabilities, equity, revenue, expenses); unique number per account; expandable|foundation
CO17|General Ledger|master record containing all accounts and their balances; updated from journals; basis for financial statements; T-account format: debits left, credits right|foundation
CO18|Journal Entry|chronological record of individual transaction; date, accounts affected, debit/credit amounts, description; recorded first in journal then posted to ledger|foundation
CO19|Trial Balance|list of all ledger account balances at a point in time; total debits must equal total credits; does not prove accuracy (compensating errors, omissions, wrong account)|foundation
CO20|Adjusting Entry|journal entry at end of accounting period to update account balances for accruals, deferrals, estimates, and corrections; required before preparing financial statements|foundation
CO21|Closing Entry|journal entry at end of accounting period transferring temporary account balances (revenue, expenses, dividends) to retained earnings; resets temporary accounts to zero for new period|foundation
CO22|Internal Controls|policies and procedures ensuring reliable financial reporting, compliance with laws, and effective operations; segregation of duties; authorization; reconciliation; physical controls|governance
CO23|Audit Trail|documented path from source document through journal entry to ledger to financial statement; enables verification of any reported number back to originating transaction|governance
CO24|GAAP (Generally Accepted Accounting Principles)|US standard framework for financial reporting; established by FASB (Financial Accounting Standards Board); ASC (Accounting Standards Codification) is authoritative source|standard
CO25|IFRS (International Financial Reporting Standards)|global standard framework for financial reporting; established by IASB; used in 140+ countries; converging with but not identical to GAAP|standard
CO26|Depreciation|systematic allocation of tangible asset cost over its useful life; expense matching; methods: straight-line, declining balance, units-of-production; not cash flow|allocation
CO27|Amortization|systematic allocation of intangible asset cost over useful life (amortization) or loan principal repayment over loan term; similar concept to depreciation for intangibles|allocation
CO28|Depletion|systematic allocation of natural resource cost (mining, timber, oil) as resource extracted; units-of-production method typical|allocation
CO29|Accounts Receivable (AR)|amounts owed to business by customers for goods/services delivered on credit; current asset; tracked by customer; aging schedule monitors overdue amounts|account
CO30|Accounts Payable (AP)|amounts business owes to suppliers for goods/services received on credit; current liability; tracked by vendor; payment terms (Net 30, 2/10 Net 30)|account
CO31|Inventory|goods held for sale or used in production; current asset; methods: FIFO (first-in, first-out), LIFO (last-in, first-out), weighted average; lower of cost or market|account
CO32|Prepaid Expense|payment made in advance for future benefit; current asset; recognized as expense over benefit period (prepaid rent, insurance, supplies)|account
CO33|Unearned Revenue (Deferred Revenue)|payment received before performance obligation fulfilled; current liability; becomes revenue when goods delivered or services performed|account
CO34|Accrued Expense|expense incurred but not yet paid; current liability; wages earned by employees but unpaid at period-end; interest incurred but not yet due|account
CO35|Accrued Revenue|revenue earned but not yet received; current asset; services performed but not yet billed; interest earned but not yet collected|account
CO36|Working Capital|current assets minus current liabilities; measures short-term liquidity; positive = can meet short-term obligations; negative = potential liquidity crisis|metric
CO37|Cost of Goods Sold (COGS)|direct cost of producing goods sold; beginning inventory + purchases - ending inventory; includes materials, direct labor, manufacturing overhead; gross profit = revenue - COGS|account
CO38|Gross Profit|revenue minus COGS; measures profitability of core production; gross margin % = gross profit / revenue × 100; does not include operating expenses|metric
CO39|Operating Expenses (OPEX)|costs of running business not directly tied to production; selling expenses (advertising, commissions); general and administrative (rent, utilities, salaries, insurance, office supplies)|account
CO40|Net Income|total revenue minus all expenses (COGS + operating + interest + tax); bottom line; flows to retained earnings on balance sheet; may be positive (profit) or negative (loss)|metric
CO41|Cash Flow|actual movement of cash in and out of business; different from net income (which includes non-cash items like depreciation); cash is king; profitable businesses can fail from cash flow shortage|metric
CO42|Break-Even Point|sales volume where total revenue = total costs (fixed + variable); units: fixed costs / (price per unit - variable cost per unit); sales $: fixed costs / contribution margin ratio|metric

# accounts(id|name|type|normal_balance|increases_by|decreases_by|examples)
AC1|Assets|balance_sheet|debit|debit|credit|cash, accounts receivable, inventory, equipment, buildings, land, prepaid expenses, investments
AC2|Liabilities|balance_sheet|credit|credit|debit|accounts payable, notes payable, wages payable, unearned revenue, loans, bonds payable, accrued expenses
AC3|Owner's Equity (Stockholders' Equity)|balance_sheet|credit|credit|debit|common stock, retained earnings, additional paid-in capital, owner's capital (sole prop), partner's capital
AC4|Revenue (Income)|income_statement (temporary)|credit|credit|debit|sales revenue, service revenue, interest income, rental income, royalty income
AC5|Expenses|income_statement (temporary)|debit|debit|credit|cost of goods sold, wages expense, rent expense, utilities, depreciation expense, insurance expense, supplies expense
AC6|Contra Asset|balance_sheet (contra)|credit|credit|debit|accumulated depreciation, allowance for doubtful accounts, sales returns and allowances
AC7|Contra Liability|balance_sheet (contra)|debit|debit|credit|bond discount, original issue discount
AC8|Contra Equity|balance_sheet (contra)|debit|debit|credit|treasury stock (shares repurchased by company)
AC9|Dividends / Owner's Draws|equity reduction (temporary)|debit|debit|credit|cash dividends declared, owner's withdrawals; reduces equity; closed to retained earnings at period-end
AC10|Other Income / Gains|income_statement (temporary)|credit|credit|debit|gain on sale of equipment, foreign exchange gain, insurance settlement; non-operating income
AC11|Other Expenses / Losses|income_statement (temporary)|debit|debit|credit|loss on sale of asset, write-off of bad debt, impairment loss, foreign exchange loss; non-operating expense

# double_entry(id|name|description|rule|examples)
DE1|Accounting Equation|Assets = Liabilities + Equity; every transaction maintains this equation; foundation of double-entry system|must always balance; any increase on one side must be offset by increase on other side or decrease on same side|buy equipment with cash: asset ↑ (equipment), asset ↓ (cash) — equation balanced; borrow from bank: asset ↑ (cash), liability ↑ (loan) — equation balanced
DE2|Debit|left side of any account; increases assets and expenses; decreases liabilities, equity, and revenue|debit = left entry; does not inherently mean increase or decrease — depends on account type|debit cash (increase asset); debit rent expense (increase expense); debit accounts payable (decrease liability)
DE3|Credit|right side of any account; increases liabilities, equity, and revenue; decreases assets and expenses|credit = right entry; does not inherently mean increase or decrease — depends on account type|credit cash (decrease asset); credit sales revenue (increase revenue); credit accounts payable (increase liability)
DE4|Normal Balance|the side (debit or credit) where increases are recorded; the side where the account typically has its balance|assets and expenses: normal debit balance; liabilities, equity, and revenue: normal credit balance; contra accounts have opposite normal balance|cash normally has debit balance; accounts payable normally has credit balance; accumulated depreciation (contra asset) normally has credit balance
DE5|T-Account|visual representation of account with vertical line (debit left, credit right); used for analysis and teaching|left side = debits; right side = credits; balance = difference between sides on normal balance side|cash T-account: debits (deposits, receipts) on left; credits (payments) on right; balance on debit side
DE6|Journal Entry Format|Date / Account debited (left) / Amount / Account credited (indented right) / Amount / Description|debits listed first; credits indented; amounts in columns; total debits = total credits; description explains transaction|Jan 15: Debit Cash 5,000 / Credit Service Revenue 5,000 / "Received payment for consulting services"
DE7|Compound Entry|journal entry affecting more than two accounts; still balances (total debits = total credits)|multiple debits and/or credits in single entry; common for complex transactions|purchase equipment $10,000: debit Equipment 10,000 / credit Cash 3,000 / credit Notes Payable 7,000 (partial cash, partial loan)
DE8|Posting|transferring journal entry information to individual ledger accounts; connects journal to ledger; creates audit trail|each journal entry line posted to its respective ledger account; reference numbers link journal to ledger|journal entry debiting Cash → posted as debit in Cash ledger account with journal reference number

# financial_statements(id|name|purpose|structure|period|key_relationships)
FS1|Balance Sheet (Statement of Financial Position)|shows financial position at specific point in time; snapshot; what business owns, owes, and owners' residual interest|Assets = Liabilities + Equity; current (within 1 year) and non-current classification; listed in order of liquidity (most liquid first)|point in time (as of date)|total assets always equals total liabilities + equity; retained earnings connects to income statement; cash connects to cash flow statement
FS2|Income Statement (Profit & Loss)|shows financial performance over a period; revenue minus expenses = net income or net loss|Revenue - COGS = Gross Profit - Operating Expenses = Operating Income ± Other Income/Expenses - Tax = Net Income|period (for the month/quarter/year ended)|net income flows to retained earnings on balance sheet; revenue recognition and matching principle govern timing; multi-step format more informative than single-step
FS3|Statement of Cash Flows|shows actual cash inflows and outflows over a period; reconciles beginning to ending cash balance; three sections|Operating (core business cash) + Investing (long-term asset purchases/sales) + Financing (debt/equity transactions) = Net change in cash|period|indirect method: start with net income, adjust for non-cash items (depreciation, AR/AP changes); direct method: list actual cash receipts and payments; operating cash flow should exceed net income long-term (quality of earnings)
FS4|Statement of Owner's Equity (Statement of Retained Earnings)|shows changes in equity over a period; connects income statement to balance sheet|Beginning balance + Net income - Dividends/draws ± Other comprehensive income = Ending balance|period|beginning balance = prior period ending balance; net income from income statement; dividends are not expenses (equity reduction); ending balance appears on balance sheet
FS5|Notes to Financial Statements|supplementary information explaining accounting policies, significant estimates, contingencies, commitments, and detail behind reported numbers|no fixed structure; narrative and tabular; significant accounting policies first; detail on specific accounts; contingent liabilities; related party transactions; subsequent events|accompanies all statements|essential context; explains methods (depreciation method, inventory method); quantifies uncertainty; discloses what numbers alone cannot; first thing sophisticated readers examine

# transactions(id|name|debit_account|credit_account|description|frequency)
TX1|Cash Sale|Cash (asset)|Sales Revenue|goods or services sold and paid for immediately; revenue recognized at point of sale|daily/ongoing
TX2|Credit Sale|Accounts Receivable (asset)|Sales Revenue|goods or services sold on credit terms; revenue recognized at delivery; cash not yet received|daily/ongoing
TX3|Collection of Receivable|Cash (asset)|Accounts Receivable (asset)|customer pays previously invoiced amount; no revenue impact (revenue already recognized at sale)|daily/ongoing
TX4|Purchase Inventory (Cash)|Inventory (asset) or Purchases (expense, periodic system)|Cash (asset)|buying inventory for resale or raw materials for production|as needed
TX5|Purchase Inventory (Credit)|Inventory (asset) or Purchases|Accounts Payable (liability)|buying inventory on supplier credit terms|as needed
TX6|Payment to Supplier|Accounts Payable (liability)|Cash (asset)|paying previously invoiced supplier amount; no expense impact (expense recognized at purchase or when sold)|as scheduled (Net 30, etc.)
TX7|Payroll Recording|Wages Expense (expense) + Payroll Tax Expense (expense)|Cash/Wages Payable (liability) + various tax payable accounts|recording employee compensation and employer payroll tax obligations|per pay period (weekly, biweekly, monthly)
TX8|Equipment Purchase|Equipment (asset)|Cash and/or Notes Payable|acquiring long-term asset; capitalized (not expensed); depreciated over useful life|as needed
TX9|Depreciation Recording|Depreciation Expense (expense)|Accumulated Depreciation (contra asset)|allocating portion of asset cost to current period; non-cash expense; reduces book value|monthly or annually
TX10|Loan Receipt|Cash (asset)|Notes Payable (liability)|borrowing money; principal recorded as liability; interest will be expensed over loan term|as needed
TX11|Loan Payment|Notes Payable (liability) + Interest Expense (expense)|Cash (asset)|repaying loan; split between principal (reduces liability) and interest (expense); amortization schedule governs split|per schedule (monthly, quarterly)
TX12|Owner Investment|Cash (asset)|Owner's Capital or Common Stock + APIC|owner contributes cash or assets to business; increases equity; not revenue|at formation or additional investment
TX13|Owner Draw / Dividend|Owner's Draws (equity reduction) or Dividends|Cash (asset)|owner withdraws cash from business; not an expense; reduces equity directly|as needed/declared
TX14|Prepaid Expense Payment|Prepaid Insurance/Rent (asset)|Cash (asset)|paying in advance for future benefit; asset until benefit consumed|at payment
TX15|Prepaid Expense Adjustment|Insurance/Rent Expense (expense)|Prepaid Insurance/Rent (asset)|adjusting entry: transferring consumed portion from asset to expense; end of period|monthly (adjusting)
TX16|Unearned Revenue Receipt|Cash (asset)|Unearned Revenue (liability)|customer pays before service delivered; liability until earned|at receipt
TX17|Unearned Revenue Adjustment|Unearned Revenue (liability)|Revenue|adjusting entry: recognizing revenue as performance obligation fulfilled|as earned (adjusting)
TX18|Bad Debt Expense|Bad Debt Expense (expense)|Allowance for Doubtful Accounts (contra asset)|estimating uncollectible receivables; percentage of sales or aging method; adjusting entry|monthly or annually (adjusting)
TX19|Write-Off of Bad Debt|Allowance for Doubtful Accounts (contra asset)|Accounts Receivable (asset)|removing specific uncollectible account; no income statement impact (expense already estimated)|as identified
TX20|Accrued Wages|Wages Expense (expense)|Wages Payable (liability)|adjusting entry: recording wages earned by employees but not yet paid at period-end|end of period (adjusting)
TX21|Sales Tax Collection|Cash or AR (asset)|Sales Tax Payable (liability)|collecting sales tax from customer on behalf of government; liability until remitted; not revenue|with each taxable sale
TX22|Sales Tax Remittance|Sales Tax Payable (liability)|Cash (asset)|paying collected sales tax to government; clears liability|monthly or quarterly per jurisdiction

# ratios(id|name|formula|interpretation|healthy_range|category)
RA1|Current Ratio|current assets / current liabilities|ability to pay short-term obligations; higher = more liquid|1.5-3.0 (industry-dependent); below 1.0 = potential liquidity crisis|liquidity
RA2|Quick Ratio (Acid Test)|(current assets - inventory - prepaid) / current liabilities|stringent liquidity test excluding less-liquid current assets|1.0-2.0; below 1.0 = may struggle to pay bills without selling inventory|liquidity
RA3|Working Capital|current assets - current liabilities|absolute dollar measure of short-term liquidity; must be positive|positive and growing; industry-dependent; negative = borrowing to fund operations|liquidity
RA4|Debt-to-Equity Ratio|total liabilities / total equity|financial leverage; how much creditor financing vs owner financing|0.5-2.0 (industry-dependent); higher = more leveraged = more risk; capital-intensive industries higher|leverage
RA5|Debt-to-Assets Ratio|total liabilities / total assets|proportion of assets financed by debt|0.3-0.6 typical; above 0.6 = highly leveraged; below 0.3 = conservatively financed|leverage
RA6|Interest Coverage Ratio|operating income / interest expense|ability to pay interest from operations; higher = more comfortable|above 3.0 minimum; below 1.5 = distressed; below 1.0 = cannot cover interest from operations|leverage
RA7|Gross Profit Margin|gross profit / revenue × 100|profitability after direct production costs; pricing power indicator|varies widely by industry (retail 25-50%; software 60-80%; manufacturing 20-40%)|profitability
RA8|Operating Profit Margin|operating income / revenue × 100|profitability after all operating costs; operational efficiency|10-25% healthy for most industries; negative = operating at a loss|profitability
RA9|Net Profit Margin|net income / revenue × 100|bottom-line profitability after all costs including interest and tax|5-20% for most industries; varies enormously; track trend over time|profitability
RA10|Return on Assets (ROA)|net income / total assets × 100|efficiency of asset utilization; how much profit generated per dollar of assets|5-15% (industry-dependent); asset-heavy industries lower; asset-light higher|profitability
RA11|Return on Equity (ROE)|net income / total equity × 100|return earned on owners' investment; primary shareholder metric|10-20% good; above 20% excellent; very high may indicate excessive leverage; DuPont decomposition: margin × turnover × leverage|profitability
RA12|Accounts Receivable Turnover|net credit sales / average AR|how quickly AR collected; higher = faster collection|varies by terms; divide 365 by turnover = average collection period (days); compare to credit terms (Net 30 → should be near 30 days)|efficiency
RA13|Inventory Turnover|COGS / average inventory|how quickly inventory sold and replaced; higher = more efficient (generally)|4-12 for most businesses; too low = obsolescence risk; too high = stockout risk; 365 / turnover = days inventory held|efficiency
RA14|Accounts Payable Turnover|COGS (or purchases) / average AP|how quickly business pays suppliers; lower = slower payment (using supplier financing)|varies by terms; 365 / turnover = average payment period; should match or slightly exceed credit terms; paying too fast wastes float; too slow damages relationships|efficiency
RA15|Asset Turnover|revenue / total assets|revenue generated per dollar of assets; operational efficiency|1.0-3.0 (industry-dependent); asset-light businesses higher; capital-intensive lower|efficiency
RA16|Cash Conversion Cycle|days inventory + days receivable - days payable|days between cash outflow for materials and cash inflow from sales; shorter = better cash efficiency|positive and as short as possible; negative = business collects before paying suppliers (ideal; e.g., Amazon); long cycle = cash tied up in operations|efficiency
RA17|Break-Even Sales|fixed costs / contribution margin ratio|minimum sales to cover all costs; below this = loss; above = profit|must be achievable with available capacity and market; high break-even = high risk; low break-even = more resilient|planning
RA18|Contribution Margin|revenue - variable costs; or per unit: selling price - variable cost per unit|amount available to cover fixed costs and generate profit; key to CVP analysis|higher = more profit per unit sold above break-even; expressed as ratio (CM/revenue) for multi-product analysis|planning

# tax(id|name|description|timing|key_details)
TA1|Income Tax (Federal/State)|tax on net taxable income; corporations taxed at entity level (21% federal US); pass-through entities (S-corp, partnership, sole prop) pass income to owners' personal returns|quarterly estimated payments (15th of month following quarter-end); annual return (March 15 for S-corp/partnership; April 15 for C-corp/individual)|taxable income ≠ book income (temporary and permanent differences); deferred tax assets/liabilities arise from timing differences; tax planning legitimate; tax evasion illegal
TA2|Self-Employment Tax|Social Security (12.4% on first $168,600 for 2024) + Medicare (2.9% on all; additional 0.9% above $200K); paid by self-employed in lieu of employer/employee FICA split|quarterly estimated; annual Schedule SE|sole proprietors and partners pay full 15.3% (employees split with employer); deduct 50% of SE tax as adjustment to income; significant burden for small business owners
TA3|Sales Tax|consumption tax collected from customers on taxable goods/services; rates vary by state/county/city (0-10%+); remitted to jurisdiction|monthly or quarterly filing depending on volume; nexus rules determine where obligation exists|economic nexus: sales volume/count threshold creates obligation even without physical presence (Wayfair 2018); exempt items vary by state; tax-exempt customers (resellers, nonprofits) provide exemption certificates
TA4|Payroll Tax (FICA)|employer matches employee Social Security (6.2%) and Medicare (1.45%); FUTA (6.0% on first $7,000 per employee, offset by state credit); state unemployment (SUTA)|FICA/federal withholding: semi-weekly or monthly deposit per schedule; FUTA: quarterly; W-2 by January 31; 941 quarterly|employer payroll tax = 7.65%+ of wages on top of gross wages; total employment cost exceeds gross salary by 10-30% (taxes + benefits); misclassifying employees as contractors triggers penalties
TA5|Property Tax|tax on real and personal property (real estate, equipment, vehicles); assessed by local jurisdiction; ad valorem (based on assessed value)|typically annual or semi-annual; varies by jurisdiction; may be escrowed in mortgage|business property assessments should be reviewed for accuracy; personal property tax on equipment often overlooked; depreciating asset may still be assessed at higher value
TA6|Estimated Tax Payments|quarterly advance payments of expected annual income tax liability; required when expected tax ≥ $1,000 (individual) or $500 (corporation)|April 15, June 15, September 15, January 15 (individual); varies for corporations|safe harbor: pay 100% of prior year tax (110% if AGI > $150K) or 90% of current year tax to avoid underpayment penalty; penalties for underpayment even if return filed on time
TA7|Depreciation (Tax)|tax depreciation may differ from book depreciation; MACRS (Modified Accelerated Cost Recovery System); Section 179 immediate expensing; bonus depreciation|calculated annually; reported on tax return; differences from book create deferred tax|MACRS classes: 3, 5, 7, 10, 15, 20, 27.5 (residential), 39 (nonresidential) years; Section 179 allows immediate expensing up to annual limit ($1.16M for 2024); bonus depreciation phasing down; creates timing difference between book and tax income

# payroll(id|name|description|calculation|timing)
PY1|Gross Pay|total compensation before any deductions; hourly (rate × hours) or salary (annual / pay periods); overtime for non-exempt employees (1.5× after 40 hrs/week FLSA)|hourly: regular hours × rate + overtime hours × 1.5 × rate; salary: annual salary / number of pay periods; commissions, bonuses added as earned|each pay period
PY2|Federal Income Tax Withholding|amount withheld from employee pay for federal income tax; based on W-4 elections (filing status, dependents, additional withholding)|IRS withholding tables or percentage method; based on gross pay, filing status, and W-4 allowances/adjustments; Publication 15 (Circular E)|each pay period; deposited semi-weekly or monthly
PY3|State/Local Income Tax Withholding|amount withheld for state and local income taxes; varies by jurisdiction; some states have no income tax (TX, FL, WA, NV, etc.)|state-specific withholding tables; based on gross pay and state W-4 equivalent|each pay period; deposited per state schedule
PY4|FICA (Employee Share)|Social Security: 6.2% of gross up to wage base ($168,600 for 2024); Medicare: 1.45% of all gross; additional Medicare: 0.9% above $200K|SS: gross × 0.062 (up to wage base); Medicare: gross × 0.0145; additional Medicare: 0.9% on wages exceeding $200K|each pay period; deposited with employer share
PY5|FICA (Employer Share)|employer matches employee Social Security and Medicare; employer cost, not deducted from employee|SS: 6.2% of employee gross up to wage base; Medicare: 1.45% of employee gross; no cap on Medicare; no additional Medicare for employer|each pay period; employer's expense; deposited with employee share
PY6|Net Pay|amount actually paid to employee after all deductions; gross pay minus all withholdings and deductions|gross - federal withholding - state withholding - FICA employee - voluntary deductions (health insurance, retirement, etc.)|each pay period; direct deposit or check
PY7|Employer Payroll Taxes (Total)|total employer cost beyond gross pay; FICA employer share + FUTA + SUTA + workers' compensation|FICA: 7.65% of gross; FUTA: 0.6% on first $7K (after state credit); SUTA: varies (0.5-6%+ on state wage base); workers' comp: varies by industry and claims history|employer expense each pay period; various deposit schedules
PY8|Payroll Register|detailed record of each payroll run; lists every employee with gross, deductions, withholdings, net pay, and employer costs|generated each pay period; source document for journal entries; retained for tax records; supports W-2 preparation|each pay period; retained per record retention requirements (4+ years)
PY9|W-2 (Wage and Tax Statement)|annual form reporting employee gross wages, tax withholdings, and benefits; provided to employee and IRS/SSA|issued by employer; copies to employee (B, C), SSA (A), state (1, 2); electronic filing required above threshold|by January 31 of following year
PY10|1099-NEC (Nonemployee Compensation)|annual form reporting payments to independent contractors; $600+ threshold|issued by payer to contractor and IRS; contractor responsible for own SE tax; employer does not withhold taxes for contractors|by January 31 of following year

# cash_management(id|name|definition|method|importance)
CS1|Bank Reconciliation|comparing bank statement balance to company's cash ledger balance; identifying and resolving differences|start with bank balance; add deposits in transit (recorded by company, not yet on statement); subtract outstanding checks (issued but not yet cleared); compare to adjusted book balance; investigate discrepancies|monthly minimum; catches errors, fraud, timing differences; discovers bank errors; verifies cash balance accuracy; basic internal control; one of most important bookkeeping tasks
CS2|Cash Flow Forecasting|projecting future cash inflows and outflows; 13-week rolling forecast most common for operational management|list all expected receipts (customer payments, loan proceeds, other income) and disbursements (supplier payments, payroll, rent, loan payments, taxes) by week; calculate weekly ending cash balance|prevents cash crises; enables proactive borrowing or investment decisions; seasonal businesses especially critical; actual vs forecast comparison improves accuracy over time
CS3|Aging Report (AR)|categorizing accounts receivable by days outstanding; current, 1-30 days past due, 31-60, 61-90, 90+|generated from AR subsidiary ledger; lists each customer balance by age bucket; total exposure per bucket; oldest amounts most likely uncollectible|drives collection efforts; estimates bad debt allowance; identifies problem customers; percentage of each bucket historically uncollectible informs allowance calculation; reviewed weekly or monthly
CS4|Aging Report (AP)|categorizing accounts payable by payment due date; identifies upcoming payment obligations|lists each vendor balance by due date; identifies amounts due now, due in 7/14/30/60 days; prioritizes payments|prevents late payment penalties; captures early payment discounts (2/10 Net 30 = 2% discount if paid within 10 days); manages cash flow timing; maintains supplier relationships
CS5|Petty Cash|small cash fund for minor business expenses; imprest system (fixed amount replenished to original level)|establish fund (e.g., $200); custodian disburses and collects receipts; when low, total receipts + remaining cash should equal fund amount; replenish with check for receipt total|convenience for small purchases; imprest system provides control; reconcile before replenishment; cash over/short account for discrepancies; receipts required for every disbursement
CS6|Cash Discount|price reduction for early payment; expressed as discount%/discount days Net total days|2/10 Net 30: 2% discount if paid within 10 days, full amount due in 30 days; annualized: 2/98 × 365/20 ≈ 37% annual return; almost always worth taking|reduces cost of purchases; equivalent to high-interest-rate return on cash; record at gross or net method; passing up discounts is very expensive financing
CS7|Line of Credit|pre-approved borrowing facility; draw as needed up to limit; interest only on drawn amount; revolving|arranged with bank; established credit limit; draw and repay as cash flow requires; interest on outstanding balance; annual review/renewal|safety net for cash flow gaps; seasonal businesses draw in low season, repay in high season; less expensive than emergency borrowing; requires financial reporting to bank; personal guarantee often required for small businesses
CS8|Float Management|leveraging time between writing check/initiating payment and actual cash deduction from bank account|disbursement float: checks in transit; collection float: deposits not yet cleared; net float = disbursement - collection; electronic payments reduce float|electronic payments (ACH, wire) reduced float significance; still relevant for check-based transactions; don't rely on float (rubber check risk); lockbox services accelerate collection

# budgeting(id|name|definition|components|process)
BU1|Master Budget|comprehensive financial plan for entire business for upcoming period (usually annual); integrates operating and financial budgets|sales budget → production budget → materials/labor/overhead budgets → selling/admin expense budget → pro forma income statement → capital budget → cash budget → pro forma balance sheet|begins with sales forecast; each subsequent budget derives from sales; iterative process; management review and approval; becomes performance benchmark
BU2|Sales Budget|forecast of units and revenue by product/service for budget period; starting point for all other budgets|units × selling price = revenue; broken down by month/quarter, product, region; based on historical data, market analysis, sales team input|most critical and most uncertain; all other budgets depend on this; conservative vs aggressive; sensitivity analysis (what if sales are 10% below forecast?)
BU3|Cash Budget|forecast of cash receipts and disbursements by period; identifies when cash surpluses or shortfalls will occur|beginning cash + receipts (collection pattern applied to sales) - disbursements (payments for purchases, payroll, overhead, capital, debt, taxes) = ending cash; minimum cash balance target|most operationally important budget; reveals when borrowing needed and when excess cash available; collection pattern: what percentage of sales collected in month of sale, next month, etc.; typically monthly
BU4|Capital Budget|plan for major asset purchases (equipment, vehicles, property, technology); amounts, timing, and financing method|list all planned capital expenditures; amount and timing; financing source (cash, loan, lease); ROI or payback period analysis for each item; approval process for amounts above threshold|separates capital spending from operating expenses; items above threshold require formal approval and analysis; below threshold may be expensed or simplified; affects depreciation expense in future periods; ties to cash budget for timing
BU5|Flexible Budget|budget that adjusts for actual activity level; separates fixed and variable costs; enables meaningful variance analysis|fixed costs remain constant; variable costs adjust per unit; at actual volume: recalculate expected costs; compare to actual for meaningful variances|static budget comparison is misleading if volume differs from plan (of course costs are higher if volume is 20% above budget); flexible budget isolates efficiency from volume effects; essential for fair performance evaluation
BU6|Variance Analysis|comparison of actual results to budgeted amounts; favorable (better than budget) or unfavorable (worse); investigation of significant variances|revenue variance: actual vs budget (volume + price components); cost variance: actual vs budget (volume + price + efficiency); investigate material variances (significance threshold set by management)|don't just explain variances — act on them; unfavorable cost variance may be price (market increase) or efficiency (waste); favorable revenue variance may mask unfavorable mix (selling more low-margin items); threshold for investigation (e.g., >5% or >$5,000)
BU7|Zero-Based Budgeting|every expense must be justified from zero each period; no automatic carry-forward from prior period; each line item starts at zero|every department justifies all spending; decision packages ranked by priority; funding allocated based on ranking; time-intensive but forces critical examination|prevents budget creep (automatic inflation of line items); forces justification; best for overhead and discretionary spending; impractical for every line item every year; often used cyclically (each department every 3-5 years)

# controls(id|name|definition|implementation|risk_addressed)
IC1|Segregation of Duties|no single person should control all aspects of a financial transaction; separate authorization, custody, and recording functions|person who authorizes purchases ≠ person who writes checks ≠ person who reconciles bank; person who invoices ≠ person who collects ≠ person who records|fraud; errors undetected; single points of failure; most fundamental internal control; difficult in very small businesses (compensating controls needed: owner review)
IC2|Authorization Controls|transactions require approval by person with appropriate authority level; dollar thresholds define approval levels|purchase orders above $500 require manager approval; above $5,000 require director; above $25,000 require VP; capital purchases above $50,000 require board|unauthorized spending; commitment without budget; scope creep; ensures management awareness of significant transactions
IC3|Bank Reconciliation (as Control)|monthly reconciliation of bank statement to cash ledger by person independent of cash handling|person who reconciles ≠ person who writes checks or makes deposits; investigate all discrepancies; management review of completed reconciliation|cash theft; check fraud; recording errors; bank errors; verifies most liquid and most vulnerable asset
IC4|Physical Controls|safeguarding assets through physical means; locks, safes, restricted access, security systems, backup storage|cash in safe; inventory in locked warehouse; checks in locked cabinet; server room restricted; offsite backup; insurance|theft; loss; damage; unauthorized access; physical controls complement procedural controls
IC5|Documentation and Records|maintaining complete, organized records of all transactions; source documents retained per retention schedule|every transaction has source document (invoice, receipt, contract, bank statement); filing system (physical and digital); retention schedule (7 years typical for tax; varies by type)|audit trail; legal compliance; dispute resolution; tax audit defense; institutional memory; SOX requirements for public companies
IC6|Reconciliation (General)|regular comparison of related records that should agree; identify and resolve differences|bank reconciliation; AR subsidiary ledger to GL control account; AP subsidiary ledger to GL; inventory count to records; intercompany accounts|errors; theft; system issues; ensures records match reality; discrepancies investigated promptly; monthly minimum
IC7|Prenumbered Documents|sequentially numbered forms (checks, invoices, purchase orders, receipts); gaps in sequence investigated|all documents prenumbered before use; log of document numbers issued; gaps or duplicates investigated; voided documents retained (marked VOID)|missing documents; unauthorized transactions; ensures completeness of recording; gaps may indicate theft or loss
IC8|Access Controls (System)|limiting system access based on role; user permissions; password policies; audit logs of access and changes|role-based access (AR clerk cannot access payroll; payroll clerk cannot modify AR); strong passwords; audit log review; separation of system admin from transaction processing|unauthorized data access; unauthorized changes; data integrity; system security; SOX IT controls for public companies
IC9|Independent Verification|work checked by someone independent of the person who performed it; spot checks; surprise audits|manager reviews journal entries; internal audit samples transactions; surprise cash counts; independent inventory counts; external audit annually|errors; fraud; process breakdowns; independent eye catches what performing person misses; deterrent effect (knowing work will be checked)
IC10|Budgetary Control|comparing actual spending to budget; investigating variances; requiring approval for over-budget spending|actual vs budget reports monthly; variance explanation for significant items; over-budget spending requires additional authorization; budget amendments formalized|overspending; cost overruns; financial surprises; connects planning to execution; accountability

# compliance(id|name|description|requirements|consequences_of_failure)
CP1|Tax Filing Deadlines|federal, state, and local tax returns and payments due on specific dates; varies by entity type and tax type|federal income: C-corp March 15 or April 15; S-corp/partnership March 15; individual April 15; extensions available (6 months) but do not extend payment deadline; quarterly estimated taxes|late filing penalties (5%/month up to 25%); late payment penalties (0.5%/month); interest on underpayment; potential criminal charges for willful evasion; extension avoids filing penalty but not payment penalty
CP2|Payroll Tax Compliance|timely deposit of withholding and employer payroll taxes; proper filing of quarterly (941) and annual (W-2, W-3) returns|deposit schedules: semi-weekly (prior quarter taxes > $50K) or monthly; 941 quarterly; W-2 by Jan 31; accuracy of withholding calculations; classification of employees vs contractors|trust fund recovery penalty (100% personal liability on responsible persons for unpaid withholding); IRS most aggressive collection area; penalties for late deposits, wrong amounts, late filing; worker misclassification penalties
CP3|Sales Tax Compliance|collection, reporting, and remittance of sales tax in all jurisdictions where nexus exists|register in each nexus state; collect correct rate; file returns per state schedule (monthly/quarterly/annually); remit collected tax; maintain exemption certificates|failure to collect does not relieve obligation to remit; back-tax assessments; penalties and interest; audit risk; economic nexus thresholds vary by state; marketplace facilitator laws shift obligation for platform sales
CP4|Record Retention|maintaining financial records for required periods; tax records, employment records, corporate records|tax records: 7 years (IRS can audit 3 years, 6 years for substantial understatement, indefinite for fraud); employment records: 4 years after tax due; corporate records: permanent (charter, minutes, equity)|inability to support tax positions on audit; inability to defend in litigation; regulatory penalties; lost institutional knowledge; digital backup essential; destruction policy after retention period
CP5|1099 Reporting|reporting payments to non-employees; 1099-NEC for contractor payments ≥$600; 1099-MISC for rents, royalties, other; 1099-INT for interest; 1099-DIV for dividends|W-9 collected from payee before or at time of first payment; forms filed by January 31 (NEC) or February 28/March 31 (others, paper/electronic); copies to recipients and IRS|backup withholding (24%) if no W-9 on file; penalties for late or incorrect filing ($60-$310 per form depending on lateness); information matching by IRS catches unreported income on payee's return
CP6|Financial Statement Preparation|preparing accurate financial statements per applicable framework (GAAP/IFRS or other comprehensive basis of accounting)|compilation (no assurance); review (limited assurance); audit (reasonable assurance); internal-use statements may use any consistent basis; loan covenants may require specific preparation level|loan covenant violation; loss of financing; regulatory action; investor/owner misinformation; fraud undetected; tax returns prepared from inaccurate financials

# failure_modes(id|topic|mode|cause|consequence|prevention)
FM1|cash|cash flow insolvency|profitable on paper but cash depleted; AR collection slower than AP payment; seasonal mismatch; rapid growth consuming cash|unable to pay obligations despite positive net income; forced borrowing at unfavorable terms; supplier relationships damaged; ultimately business failure|cash flow forecasting (13-week minimum); AR aging and aggressive collection; negotiate longer AP terms; line of credit as safety net; monitor cash conversion cycle; don't confuse profit with cash
FM2|receivables|bad debt spiral|extending credit without credit checks; poor collection procedures; customer concentration (one large customer fails); economic downturn|receivables become uncollectible; cash shortage; write-offs reduce income; may cascade if bad debt exceeds reserves|credit policy (check references, set limits); collection procedures (aging review weekly, escalation process); diversify customer base; deposits or progress payments for large orders; allowance for doubtful accounts adequate
FM3|inventory|inventory obsolescence|overpurchasing; style/technology changes; poor demand forecasting; long lead times requiring advance purchase|inventory written down to market value (loss); cash tied up in unsaleable goods; storage costs for dead inventory; working capital consumed|just-in-time where possible; regular inventory review (ABC analysis); write-down promptly (don't carry dead inventory at full cost); align purchasing with sales forecasts; return policies with suppliers
FM4|controls|embezzlement / employee fraud|lack of segregation of duties; no reconciliation review; trusted long-term employee with unchecked access; financial pressure on employee|cash missing; fictitious vendors; ghost employees; skimmed receipts; falsified expense reports; often undetected for years; average scheme lasts 14 months (ACFE)|segregation of duties; mandatory vacations (scheme collapses when perpetrator absent); surprise audits; bank reconciliation by independent person; vendor master file controls; pre-approval of expenses; background checks; anonymous reporting hotline
FM5|compliance|payroll tax penalty|late deposit of withholding taxes; misclassification of employees as contractors; incorrect withholding calculations|trust fund recovery penalty (100% personal liability — pierces corporate veil); IRS liens; potential criminal prosecution; most dangerous tax compliance failure|automated payroll system or reliable payroll service; calendar reminders for deposit dates; proper worker classification (IRS 20-factor test); timely filing of all payroll returns; never borrow from payroll tax deposits
FM6|reporting|misstated financial statements|errors in adjusting entries; failure to reconcile; incorrect revenue recognition; misclassified accounts; omitted liabilities|wrong business decisions based on wrong data; loan covenant violations; tax errors; audit adjustments; fraud allegations if intentional|monthly close process with checklist; reconciliation of all balance sheet accounts; adjusting entry review; independent review of statements; external accountant review at minimum annually
FM7|budgeting|budget disconnection|budget prepared once and ignored; no comparison to actual; no variance investigation; budget unrealistic from start|spending unchecked; opportunities missed; surprises at year-end; budget loses credibility; management flying blind|monthly budget vs actual review; variance investigation threshold; mid-year budget revision if conditions change significantly; involve managers in budget creation (buy-in); realistic assumptions
FM8|tax|missed deductions|unfamiliarity with tax code; poor record-keeping; no tax planning; commingling personal and business expenses|paying more tax than legally required; competitive disadvantage; cash outflow unnecessarily high|year-round tax planning (not just at filing); qualified tax advisor; organized record-keeping; separate business and personal finances completely; review all applicable deductions and credits; entity structure optimization
FM9|growth|outgrowing the system|manual bookkeeping or basic software inadequate for volume; chart of accounts not scaled; processes that worked for 5 employees fail for 50|errors increase; reporting delays; audit trail breaks; staff overwhelmed; management lacks timely information|evaluate systems annually; upgrade accounting software before crisis; add staff or outsource as volume grows; implement controls progressively; cloud accounting enables scaling; document processes
FM10|reconciliation|unreconciled accounts|bank accounts, credit cards, AR, AP, inventory not reconciled monthly; differences accumulate; small errors compound|balance sheet unreliable; cash position unknown; fraud undetected; adjustments at year-end are enormous and error-prone; auditor findings|reconcile all balance sheet accounts monthly; investigate discrepancies immediately; document reconciliation with signatures and dates; management review of reconciliations; never carry forward unresolved differences

# distinctions(id|side_a|side_b|key_asymmetry)
DI1|Accrual Basis|Cash Basis|accrual: revenue when earned, expense when incurred; matches revenue to related expenses; GAAP required; more accurate profit measurement; more complex; cash: revenue when received, expense when paid; simpler; may misrepresent profitability (large payment distorts month); acceptable for small businesses; most small businesses start cash, transition to accrual as they grow
DI2|Capital Expenditure (CapEx)|Operating Expenditure (OpEx)|CapEx: purchase of long-term asset benefiting multiple periods; capitalized on balance sheet; depreciated over useful life; increases assets; OpEx: cost of current period operations; expensed immediately on income statement; reduces current period income; CapEx improves future capacity; OpEx maintains current operations; classification affects reported profit
DI3|Debit|Credit|debit: left side entry; increases assets and expenses; decreases liabilities, equity, revenue; credit: right side entry; increases liabilities, equity, revenue; decreases assets and expenses; common misconception: debit ≠ bad, credit ≠ good; debit and credit are simply directional notation
DI4|Cash Flow|Profit (Net Income)|cash flow: actual cash movement; includes non-operating items (loan proceeds, asset sales); excludes non-cash items (depreciation, accruals); profit: revenue minus expenses per accrual accounting; includes non-cash items; excludes some cash movements; businesses fail from cash shortage not lack of profit; profitable companies can be cash-insolvent; cash flow is reality, profit is opinion
DI5|Fixed Cost|Variable Cost|fixed: does not change with production/sales volume (rent, salaries, insurance, depreciation); per-unit cost decreases with volume; variable: changes proportionally with volume (materials, sales commissions, shipping); per-unit cost constant; understanding mix critical for CVP analysis, break-even, and pricing
DI6|Asset|Expense|asset: resource with future economic benefit; on balance sheet; becomes expense over useful life (depreciation) or when consumed; expense: cost consumed in current period; on income statement; reduces current period income; capitalization threshold determines boundary; equipment ($5,000+) = asset; office supplies = expense
DI7|Accounts Receivable|Revenue|AR: balance sheet item; amount owed by customers; asset; revenue: income statement item; value of goods/services delivered; recognized at delivery (accrual); common confusion: recording revenue ≠ receiving cash; credit sale creates both revenue (income statement) and AR (balance sheet) simultaneously
DI8|Bookkeeping|Accounting|bookkeeping: recording transactions; mechanical; data entry; maintaining ledgers; producing trial balance; accounting: interpreting, analyzing, reporting, advising, planning; professional judgment; financial statements; tax strategy; bookkeeping is subset of accounting; bookkeeper records, accountant analyzes and advises
DI9|Financial Accounting|Managerial Accounting|financial: external reporting; GAAP/IFRS; historical; standardized; primarily for investors, creditors, regulators; managerial: internal reporting; no required standards; forward-looking; customized for management decisions; cost analysis, budgeting, forecasting, performance evaluation; financial accounting looks backward; managerial accounting looks forward
DI10|Gross Profit|Net Income|gross profit: revenue minus COGS only; measures production/purchasing efficiency and pricing power; net income: revenue minus ALL expenses (COGS + operating + interest + tax); bottom line; business can have high gross margin but negative net income (excessive overhead); gross profit funds operations; net income measures overall profitability
DI11|Temporary Accounts|Permanent Accounts|temporary: revenue, expenses, dividends; reset to zero at period-end via closing entries; accumulate for one period only; permanent: assets, liabilities, equity; carry forward from period to period; never closed; temporary accounts flow into permanent accounts (net income → retained earnings)
DI12|Tax Accounting|Book (Financial) Accounting|tax: follows IRC (Internal Revenue Code); purpose is calculating taxable income and tax owed; specific rules may differ from GAAP (accelerated depreciation, disallowed expenses); book: follows GAAP/IFRS; purpose is fair presentation of financial position and performance; differences create deferred tax assets and liabilities; same transaction may be treated differently for tax and book purposes

# relationships(from|rel|to)
# Foundation → structure
CO1|encompasses|CO2
CO2|implements|CO3
CO3|maintains|DE1
CO4|contrasts|CO5
CO4|requires|CO10,CO11
CO10|implements|CO4
CO11|implements|CO4
CO12|contrasts|CO13
CO14|governs|CO1
CO16|organizes|CO17
CO17|contains|AC1,AC2,AC3,AC4,AC5,AC6,AC7,AC8,AC9
CO18|recorded_in|CO17
CO19|validates|CO17
CO20|adjusts|CO17
CO21|resets|AC4,AC5,AC9

# Account equation
AC1|component_of|DE1
AC2|component_of|DE1
AC3|component_of|DE1
AC4|increases|AC3
AC5|decreases|AC3
AC6|reduces|AC1
AC7|reduces|AC2
AC8|reduces|AC3

# Double-entry mechanics
DE1|maintained_by|CO3
DE2|increases|AC1,AC5
DE2|decreases|AC2,AC3,AC4
DE3|increases|AC2,AC3,AC4
DE3|decreases|AC1,AC5
DE5|visualizes|CO17
DE6|formats|CO18
DE8|connects|CO18,CO17

# Financial statement → accounts
FS1|reports|AC1,AC2,AC3
FS2|reports|AC4,AC5,AC10,AC11
FS3|reports|CO41
FS4|connects|FS2,FS1
FS5|explains|FS1,FS2,FS3

# Statement relationships
FS2|produces|CO40
CO40|flows_to|FS4
FS4|updates|AC3
FS3|reconciles|AC1

# Transaction → accounts
TX1|debits|AC1
TX1|credits|AC4
TX2|debits|CO29
TX2|credits|AC4
TX3|debits|AC1
TX3|credits|CO29
TX7|debits|AC5
TX7|credits|AC1,AC2
TX8|debits|AC1
TX8|credits|AC1,AC2
TX9|debits|AC5
TX9|credits|AC6
TX12|debits|AC1
TX12|credits|AC3
TX13|debits|AC3
TX13|credits|AC1

# Adjusting entries
TX15|instance_of|CO20
TX17|instance_of|CO20
TX18|instance_of|CO20
TX20|instance_of|CO20

# Ratio → statement
RA1|derived_from|FS1
RA2|derived_from|FS1
RA4|derived_from|FS1
RA7|derived_from|FS2
RA8|derived_from|FS2
RA9|derived_from|FS2
RA10|derived_from|FS1,FS2
RA11|derived_from|FS1,FS2
RA12|derived_from|FS1,FS2
RA13|derived_from|FS1,FS2
RA16|derived_from|RA12,RA13,RA14

# Tax → business
TA1|calculated_from|FS2
TA2|calculated_from|PY1
TA3|collected_via|TX21
TA4|calculated_from|PY1
TA6|prepays|TA1
TA7|reduces|TA1

# Payroll chain
PY1|precedes|PY2,PY3,PY4
PY4|withheld_from|PY1
PY5|matches|PY4
PY6|equals|PY1 minus PY2,PY3,PY4
PY7|adds_to|PY1
PY8|documents|PY1,PY6,PY7
PY9|summarizes|PY1,PY2,PY3,PY4

# Cash management
CS1|validates|AC1
CS1|implements|IC3
CS2|forecasts|CO41
CS3|monitors|CO29
CS4|monitors|CO30
CS5|controls|AC1
CS6|reduces|CO37
CS7|provides|CO41

# Budget → operations
BU1|integrates|BU2,BU3,BU4
BU2|drives|BU1
BU3|derived_from|BU2
BU4|separate_from|BU1
BU5|adjusts|BU1
BU6|compares|BU1,FS2

# Controls → risk
IC1|prevents|FM4
IC2|prevents|FM4
IC3|prevents|FM4
IC4|prevents|FM4
IC5|enables|CO23
IC6|detects|FM6,FM10
IC7|ensures|CO23
IC8|prevents|FM4
IC9|detects|FM4,FM6
IC10|prevents|FM7

# Compliance → consequences
CP1|governs|TA1,TA6
CP2|governs|TA4,PY7
CP3|governs|TA3
CP4|enables|CP1,CP2,CP3
CP5|governs|PY10

# Failure → prevention
FM1|prevented_by|CS2,CS7,RA16
FM2|prevented_by|CS3,IC6
FM3|prevented_by|RA13,BU2
FM4|prevented_by|IC1,IC2,IC3,IC4,IC9
FM5|prevented_by|CP2
FM6|prevented_by|IC6,IC9,CO20
FM7|prevented_by|BU6,IC10
FM8|prevented_by|TA7,CP1
FM9|prevented_by|IC5,CO16
FM10|prevented_by|IC6,CS1

# Distinction mappings
DI1|distinguishes|CO4,CO5
DI2|distinguishes|TX8,CO39
DI3|distinguishes|DE2,DE3
DI4|distinguishes|CO41,CO40
DI5|distinguishes|CO42
DI6|distinguishes|AC1,AC5
DI7|distinguishes|CO29,AC4
DI8|distinguishes|CO2,CO1
DI9|distinguishes|CO1
DI10|distinguishes|CO38,CO40
DI11|distinguishes|AC4,AC1
DI12|distinguishes|TA1,CO24

# decode_legend
# id_prefixes: CO=concept, AC=account, DE=double_entry, FS=financial_statement, TX=transaction, RA=ratio, TA=tax, PY=payroll, CS=cash_management, BU=budgeting, IC=internal_control, CP=compliance, FM=failure_mode, DI=distinction
# rel_types: encompasses|implements|maintains|contrasts|requires|governs|organizes|contains|recorded_in|validates|adjusts|resets|component_of|increases|decreases|reduces|maintained_by|visualizes|formats|connects|reports|produces|flows_to|updates|reconciles|debits|credits|instance_of|derived_from|calculated_from|collected_via|prepays|withheld_from|matches|equals|adds_to|documents|summarizes|monitors|controls|provides|forecasts|integrates|drives|separate_from|compares|prevents|detects|ensures|enables|prevented_by|distinguishes
# normal_balance: the side (debit or credit) where increases are recorded; assets/expenses = debit; liabilities/equity/revenue = credit; contra accounts opposite of parent
# debit_credit_rules: DEAD (Debits increase Expenses, Assets, Dividends); CLER (Credits increase Liabilities, Equity, Revenue); fundamental memorization aid
# GAAP_references: ASC = Accounting Standards Codification (FASB); ASC 606 = revenue recognition; ASC 820 = fair value; ASC 842 = leases; ASC 350 = intangibles
# tax_note: all tax rates, thresholds, and deadlines are US-specific and subject to annual change; consult current IRS publications and state authorities; this compaction provides structure, not current-year specifics
# confidence: synthetic domain knowledge — not extracted from a single source document
