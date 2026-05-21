# ECONOMICS — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: concepts → schools → thinkers → models → market_structures → policy_instruments → indicators → institutions → claims → distinctions → relationships → decode_legend

# concepts(id|name|definition|category)
CO1|Scarcity|resources are finite; wants exceed available means; forces choice and trade-off; foundational problem of economics|foundation
CO2|Opportunity Cost|value of next-best alternative forgone when making a choice; true cost of any decision|foundation
CO3|Marginal Analysis|decision-making by comparing additional benefit to additional cost of one more unit; rational agent equates MB=MC|foundation
CO4|Incentive|factor motivating agent toward or away from an action; prices, taxes, subsidies, regulations, norms alter behavior|foundation
CO5|Rationality (Economic)|agents choose to maximize utility (consumers) or profit (firms) subject to constraints; bounded rationality recognizes cognitive limits|foundation
CO6|Equilibrium|state where no agent has incentive to change behavior given others' behavior; supply = demand in market; Nash in games|foundation
CO7|Supply|quantity of good producers willing and able to sell at each price; positive relationship with price (law of supply); shifts with input costs, technology, expectations|market
CO8|Demand|quantity of good consumers willing and able to buy at each price; negative relationship with price (law of demand); shifts with income, preferences, substitutes, complements|market
CO9|Price|amount paid per unit; signal coordinating supply and demand; reflects scarcity and value; emerges from market interaction|market
CO10|Market|institution or mechanism through which buyers and sellers interact; determines price and quantity via supply and demand|market
CO11|Elasticity (Price)|responsiveness of quantity demanded (or supplied) to price change; Ed = %ΔQd/%ΔP; elastic |Ed|>1; inelastic |Ed|<1; unit elastic |Ed|=1|market
CO12|Cross-Price Elasticity|responsiveness of demand for good X to change in price of good Y; positive = substitutes; negative = complements|market
CO13|Income Elasticity|responsiveness of demand to income change; positive = normal good; >1 = luxury; <0 = inferior good|market
CO14|Consumer Surplus|difference between willingness to pay and actual price paid; area below demand curve above price; measure of consumer welfare|welfare
CO15|Producer Surplus|difference between price received and minimum acceptable price; area above supply curve below price; measure of producer welfare|welfare
CO16|Deadweight Loss|welfare loss from inefficient allocation; triangle of unrealized gains from trade; caused by taxes, price controls, monopoly, externalities|welfare
CO17|Utility|satisfaction or benefit derived from consuming a good or service; cardinal (measurable) or ordinal (rankable); basis of demand theory|consumer
CO18|Diminishing Marginal Utility|each additional unit consumed yields less additional satisfaction; explains downward-sloping demand; Gossen's First Law|consumer
CO19|Budget Constraint|set of affordable bundles given income and prices; slope = -Px/Py; consumer optimizes where indifference curve is tangent to budget line|consumer
CO20|Indifference Curve|locus of bundles yielding equal utility; convex to origin (diminishing MRS); higher curve = higher utility; cannot cross|consumer
CO21|Production Function|relationship between inputs and maximum output; Q = f(L,K,...); short run: at least one input fixed; long run: all variable|producer
CO22|Marginal Product|additional output from one more unit of input; MPL = ΔQ/ΔL; diminishing marginal product (eventually) as input increases|producer
CO23|Returns to Scale|how output changes when all inputs increase proportionally; increasing (output rises more than proportionally), constant, or decreasing|producer
CO24|Cost Function|minimum cost of producing each output level; TC = FC + VC; MC = ΔTC/ΔQ; ATC = TC/Q; economies of scale when ATC declining|producer
CO25|Profit|total revenue minus total cost; economic profit includes opportunity cost of all resources; accounting profit uses only explicit costs|producer
CO26|Comparative Advantage|ability to produce a good at lower opportunity cost than trading partner; basis of gains from trade; Ricardo's principle|trade
CO27|Absolute Advantage|ability to produce a good using fewer resources than another producer; necessary for neither trade nor mutual benefit (comparative advantage suffices)|trade
CO28|Gains from Trade|increase in total welfare when agents specialize according to comparative advantage and exchange|trade
CO29|Externality|cost (negative) or benefit (positive) imposed on third party not involved in transaction; market failure; not reflected in price|market_failure
CO30|Public Good|non-rival (one person's use doesn't reduce availability) and non-excludable (cannot prevent consumption); free-rider problem; underprovided by market|market_failure
CO31|Common-Pool Resource|rival but non-excludable; subject to overuse (tragedy of the commons); fisheries, groundwater, atmosphere|market_failure
CO32|Asymmetric Information|one party has more or better information than other; generates adverse selection (hidden information) and moral hazard (hidden action)|market_failure
CO33|Adverse Selection|pre-contractual opportunism; informed party self-selects disadvantageously for uninformed party; Akerlof's lemons problem|market_failure
CO34|Moral Hazard|post-contractual opportunism; insured/guaranteed party takes more risk because they don't bear full cost|market_failure
CO35|Principal-Agent Problem|agent (employee, manager) may not act in principal's (owner, shareholder) interest due to divergent incentives and information asymmetry|market_failure
CO36|Transaction Cost|cost of using market mechanism: search, negotiation, monitoring, enforcement; Coase: explains existence of firms; positive transaction costs prevent some efficient trades|institutional
CO37|Property Rights|legally or socially enforced rights to use, exclude, and transfer resources; Coase theorem: if defined and costless to enforce, private bargaining solves externalities regardless of initial allocation|institutional
CO38|Rent-Seeking|expending resources to capture existing wealth (redistribution) rather than creating new wealth; lobbying, regulatory capture; socially wasteful|institutional
CO39|Money|medium of exchange, unit of account, store of value; overcomes double coincidence of wants; fiat money backed by government authority, not commodity|monetary
CO40|Inflation|sustained increase in general price level; reduces purchasing power of money; measured by CPI, PCE, GDP deflator|monetary
CO41|Deflation|sustained decrease in general price level; increases real debt burden; can cause deflationary spiral (expect lower prices → delay spending → lower output → lower prices)|monetary
CO42|Interest Rate|price of borrowing money; return to lender; Fisher equation: nominal = real + expected inflation; central bank policy instrument|monetary
CO43|Time Value of Money|dollar today worth more than dollar tomorrow due to interest/opportunity cost; PV = FV/(1+r)^n; basis of all financial valuation|monetary
CO44|Gross Domestic Product (GDP)|total market value of all final goods and services produced within country in a period; GDP = C + I + G + (X-M)|macro
CO45|Unemployment|percentage of labor force actively seeking but unable to find work; frictional (search), structural (mismatch), cyclical (demand shortfall)|macro
CO46|Business Cycle|recurring pattern of expansion (growth above trend) and contraction (recession: two consecutive quarters of GDP decline); peak, trough, recovery|macro
CO47|Aggregate Demand|total spending in economy at each price level; AD = C + I + G + NX; shifts with monetary/fiscal policy, expectations, wealth|macro
CO48|Aggregate Supply|total output firms willing to produce at each price level; short-run upward-sloping; long-run vertical at potential GDP (LRAS)|macro
CO49|Fiscal Policy|government use of spending (G) and taxation (T) to influence economy; expansionary: increase G or cut T; contractionary: opposite|policy
CO50|Monetary Policy|central bank actions affecting money supply and interest rates; expansionary: lower rates, increase money supply; contractionary: opposite|policy
CO51|Multiplier Effect|initial spending generates additional rounds of spending; multiplier = 1/(1-MPC) where MPC = marginal propensity to consume; amplifies fiscal policy impact|macro
CO52|Crowding Out|government borrowing raises interest rates, reducing private investment; partially offsets fiscal stimulus; degree depends on monetary policy response|macro
CO53|Quantity Theory of Money|MV = PQ; money supply × velocity = price level × real output; monetarist: inflation is always monetary phenomenon; velocity assumed stable|monetary
CO54|Phillips Curve|inverse relationship between unemployment and inflation (short-run); vertical at natural rate (long-run); expectations-augmented version shifts with inflation expectations|macro
CO55|Natural Rate of Unemployment|unemployment rate consistent with stable inflation; NAIRU (Non-Accelerating Inflation Rate of Unemployment); structural + frictional components|macro
CO56|Okun's Law|empirical relationship: 1% unemployment above natural rate ≈ 2% output gap below potential GDP (approximate coefficient varies)|macro
CO57|Ricardian Equivalence|government debt financing equivalent to tax financing if consumers fully anticipate future taxes to repay debt; consumers save more, offsetting stimulus; Barro formalization|macro
CO58|Liquidity Trap|interest rates at zero lower bound; monetary policy loses effectiveness because money and bonds become perfect substitutes; Keynes concept; Japan 1990s+|macro
CO59|Rational Expectations|agents form expectations using all available information and understanding of economic model; policy cannot systematically fool agents; Lucas|macro
CO60|Adaptive Expectations|agents form expectations based on past experience; adjust slowly; Friedman natural rate hypothesis uses adaptive expectations|macro
CO61|Moral Hazard (Macro)|bailout guarantees encourage excessive risk-taking by financial institutions; "too big to fail" socializes losses; 2008 financial crisis|macro
CO62|Financial Intermediation|institutions (banks, funds) channel savings from lenders to borrowers; reduce information asymmetry and transaction costs; maturity transformation|financial
CO63|Leverage|use of borrowed funds to amplify returns; leverage ratio = assets/equity; amplifies gains and losses; systemic risk when widespread|financial
CO64|Securitization|pooling illiquid assets (loans, mortgages) into tradable securities; transfers risk; can obscure underlying asset quality; CDOs, MBS|financial
CO65|Systemic Risk|risk that failure of one institution triggers cascading failures across financial system; contagion; network effects; "too interconnected to fail"|financial
CO66|Creative Destruction (Schumpeter)|process by which new innovations displace old technologies and firms; engine of capitalist growth; temporary monopoly profits reward innovation|growth
CO67|Total Factor Productivity (TFP)|output growth not explained by growth in labor or capital inputs; residual; attributed to technology, institutions, management; Solow residual|growth
CO68|Human Capital|knowledge, skills, health embodied in workers; investment via education, training, healthcare; increases productivity; Becker, Schultz|growth
CO69|Capital Accumulation|increase in stock of physical capital (machinery, infrastructure, equipment); diminishing returns in Solow model; necessary but not sufficient for sustained growth|growth
CO70|Endogenous Growth|growth driven by factors within the model: R&D, human capital, knowledge spillovers; increasing returns; AK model, Romer model; no convergence prediction|growth
CO71|Convergence (Economic)|poorer countries grow faster than richer countries (conditional on similar institutions, savings, education); predicted by Solow model; evidence mixed|growth
CO72|Institutions (Economic)|formal rules (laws, property rights, contracts) and informal norms (trust, culture) shaping economic incentives; Acemoglu, North: institutions as fundamental cause of growth differences|institutional
CO73|Comparative Institutional Analysis|comparing how different institutional arrangements (markets, hierarchies, networks, government) solve economic problems; Williamson|institutional
CO74|Game Theory|study of strategic interaction where outcomes depend on all players' choices; Nash equilibrium; dominant strategy; iterated games; mechanism design|analytical
CO75|Nash Equilibrium|set of strategies where no player can improve payoff by unilaterally changing strategy; may not be Pareto optimal (Prisoner's Dilemma)|analytical
CO76|Prisoner's Dilemma|game where individually rational choices lead to collectively suboptimal outcome; both defect despite mutual cooperation being better; models free-riding, arms races, cartels|analytical
CO77|Auction Theory|analysis of bidding strategies and auction design; first-price, second-price (Vickrey), English, Dutch; revenue equivalence theorem; mechanism design application|analytical
CO78|Behavioral Economics|incorporates psychological findings into economic models; bounded rationality, loss aversion, framing effects, hyperbolic discounting, nudges; Kahneman, Thaler|analytical
CO79|Loss Aversion|losses weigh more heavily than equivalent gains (approximately 2×); prospect theory (Kahneman-Tversky); explains risk aversion for gains, risk-seeking for losses; endowment effect|behavioral
CO80|Hyperbolic Discounting|agents discount near-future more steeply than far-future; present bias; explains procrastination, under-saving; time-inconsistent preferences|behavioral
CO81|Nudge|choice architecture that steers behavior without restricting options; opt-out vs opt-in; Thaler-Sunstein; libertarian paternalism|behavioral
CO82|Gini Coefficient|measure of income/wealth inequality; 0 = perfect equality; 1 = perfect inequality; area between Lorenz curve and 45° line divided by total area below 45° line|distribution
CO83|Lorenz Curve|graphical representation of cumulative income/wealth distribution; x-axis = cumulative population %, y-axis = cumulative income/wealth %; 45° line = perfect equality|distribution
CO84|Pareto Efficiency|allocation where no one can be made better off without making someone else worse off; First Welfare Theorem: competitive equilibrium is Pareto efficient (under certain conditions)|welfare
CO85|Pareto Improvement|change making at least one person better off without making anyone worse off; movement toward Pareto efficiency|welfare
CO86|Market Efficiency Hypothesis (EMH)|asset prices fully reflect all available information; weak (past prices), semi-strong (public info), strong (all info including private); Fama|financial
CO87|Moral Hazard in Insurance|insured party takes greater risks because insurer bears cost; mitigated by deductibles, copayments, monitoring|market_failure
CO88|Coase Theorem|if property rights well-defined and transaction costs zero, private bargaining achieves efficient outcome regardless of initial allocation; Coase 1960|institutional
CO89|Arrow's Impossibility Theorem|no voting system satisfying unrestricted domain, Pareto, independence of irrelevant alternatives, and non-dictatorship simultaneously; Arrow 1951|social_choice
CO90|Revealed Preference|consumer's choices reveal their preferences; if A chosen when B available, A preferred to B (WARP); Samuelson|consumer
CO91|Expected Utility|von Neumann-Morgenstern: rational agents maximize expected utility EU = Σp_i × u(x_i); axioms: completeness, transitivity, continuity, independence|analytical
CO92|Risk Aversion|preferring certain outcome over gamble with same expected value; concave utility function; explains insurance demand; Arrow-Pratt measure|analytical
CO93|Discount Rate|rate at which future values are discounted to present; reflects time preference, risk, opportunity cost; central to investment, project evaluation, climate economics|analytical
CO94|Purchasing Power Parity (PPP)|exchange rates should adjust so identical goods cost the same across countries; law of one price; long-run tendency; Big Mac Index (informal test)|international
CO95|Balance of Payments|record of all economic transactions between residents and rest of world; current account + capital account + financial account = 0; deficit = net borrower|international
CO96|Exchange Rate|price of one currency in terms of another; floating (market-determined), fixed (government-pegged), managed float; affects trade competitiveness|international
CO97|Terms of Trade|ratio of export prices to import prices; improvement = can buy more imports per unit of exports; deterioration = opposite|international
CO98|Tariff|tax on imported goods; raises domestic price; protects domestic producers; generates revenue; creates deadweight loss; optimal tariff argument for large country|trade_policy
CO99|Quota|quantitative limit on imports; raises domestic price; benefits domestic producers and quota holders; creates deadweight loss; less transparent than tariff|trade_policy
CO100|Capital Account Liberalization|removing restrictions on cross-border capital flows; enables investment and risk-sharing; but can cause volatile capital flows, sudden stops, financial crises|international

# schools(id|name|period|key_figures|core_tenets|policy_implications)
SC1|Mercantilism|c. 16th–18th century|Thomas Mun, Jean-Baptiste Colbert|wealth = gold/silver accumulation; trade surplus as national goal; government intervention to promote exports, restrict imports; zero-sum view of trade|high tariffs; export subsidies; colonial extraction; state-directed industry
SC2|Physiocracy|c. 1750s–1770s|François Quesnay, Turgot|land as sole source of wealth; Tableau Économique (circular flow); agriculture is only productive sector; natural order (laissez-faire)|single tax on land rent; remove trade restrictions; minimal government intervention
SC3|Classical|c. 1776–1870s|TK1 (Smith), TK2 (Ricardo), TK4 (Mill), TK3 (Malthus)|labor theory of value (partially); comparative advantage; free trade; self-regulating markets; Say's Law (supply creates its own demand); diminishing returns; Malthusian population|free trade; limited government; gold standard; balanced budgets
SC4|Marxian|c. 1867 onward|TK5 (Marx), Friedrich Engels|labor theory of value; surplus value extraction; class struggle; tendency of rate of profit to fall; historical materialism; capitalism self-destructs through internal contradictions|collective ownership of means of production; planned economy; abolition of private property
SC5|Marginalist/Neoclassical|c. 1870s onward|TK6 (Marshall), TK7 (Walras), Jevons, Menger, TK10 (Pigou)|marginal utility theory of value; supply and demand; general equilibrium; perfect competition as benchmark; Pareto efficiency|market-based allocation; correct market failures (externalities, monopoly); marginal tax analysis
SC6|Austrian|c. 1870s onward|Carl Menger, TK8 (Hayek), Ludwig von Mises, Eugen Böhm-Bawerk|subjective value; methodological individualism; spontaneous order; business cycle from credit expansion; knowledge problem; skepticism of mathematical formalism|minimal government; sound money; no central planning; Austrian Business Cycle Theory
SC7|Keynesian|c. 1936 onward|TK9 (Keynes), TK14 (Hicks), TK15 (Samuelson), James Tobin|aggregate demand determines output in short run; sticky prices/wages; paradox of thrift; liquidity preference; animal spirits; multiplier|fiscal stimulus in recessions; monetary policy accommodation; automatic stabilizers; deficit spending acceptable in downturns
SC8|Monetarist|c. 1960s–1980s|TK11 (Friedman), Anna Schwartz, Karl Brunner|money supply growth determines inflation; natural rate of unemployment; adaptive expectations; rules over discretion; monetary policy dominant over fiscal|stable money supply growth rule; limit fiscal policy; deregulation; natural rate framework
SC9|New Classical|c. 1970s onward|TK12 (Lucas), Thomas Sargent, Robert Barro|rational expectations; policy ineffectiveness proposition; microfoundations; real business cycle theory; market-clearing models|rules-based policy; credible commitment; minimize discretionary intervention
SC10|New Keynesian|c. 1980s onward|TK16 (Stiglitz), N. Gregory Mankiw, Olivier Blanchard, Michael Woodford|microfoundations for sticky prices and wages (menu costs, efficiency wages, staggered contracts); rational expectations with imperfections; DSGE models|monetary policy effective (Taylor Rule); fiscal policy useful at zero lower bound; inflation targeting
SC11|Supply-Side|c. 1980s|Arthur Laffer, Robert Mundell|tax cuts increase incentives to work, save, invest; Laffer Curve (revenue maximized at intermediate tax rate); supply determines growth|lower marginal tax rates; deregulation; reduce government spending growth
SC12|Institutional|c. 1900s, revived 1990s|Thorstein Veblen (old), TK13 (North), Oliver Williamson, TK17 (Acemoglu)|institutions shape economic outcomes; property rights, rule of law, norms matter more than resources; transaction costs; path dependence|strengthen institutions; property rights enforcement; anti-corruption; rule of law
SC13|Development Economics|c. 1940s onward|W. Arthur Lewis, Amartya Sen, TK17 (Acemoglu), Esther Duflo|why some countries are poor; dual economy; capability approach; randomized controlled trials; geography vs institutions vs culture debate|foreign aid (debate); institutional reform; education investment; industrial policy; RCT-based policy design
SC14|Public Choice|c. 1960s onward|James Buchanan, Gordon Tullock|apply economic analysis to political behavior; politicians and bureaucrats are self-interested; government failure parallels market failure; rent-seeking|constitutional constraints on government; balanced budget amendments; limit regulatory capture; skepticism of government intervention

# thinkers(id|name|dates|key_contributions)
TK1|Adam Smith|1723–1790|Wealth of Nations (1776); invisible hand; division of labor; self-interest as coordination mechanism; free trade; labor theory of value (partial); pin factory; theory of moral sentiments
TK2|David Ricardo|1772–1823|comparative advantage; labor theory of value; iron law of wages; theory of rent (differential rent); Ricardian equivalence (precursor); free trade advocacy
TK3|Thomas Robert Malthus|1766–1834|population grows geometrically, food arithmetically; population checks (positive: famine, disease; preventive: moral restraint); general glut possibility (against Say's Law)
TK4|John Stuart Mill|1806–1873|Principles of Political Economy; synthesis of classical economics; utilitarianism applied to policy; distinction between production (laws) and distribution (malleable); progressive taxation; women's equality
TK5|Karl Marx|1818–1883|Das Kapital; labor theory of value; surplus value; exploitation; commodity fetishism; falling rate of profit; alienation; historical materialism; base-superstructure; class struggle
TK6|Alfred Marshall|1842–1924|Principles of Economics; supply-demand scissors; partial equilibrium; consumer/producer surplus; elasticity; short-run/long-run distinction; marginal analysis formalized
TK7|Léon Walras|1834–1910|Elements of Pure Economics; general equilibrium theory; simultaneous market-clearing; auctioneer (tâtonnement); mathematical economics foundation
TK8|Friedrich Hayek|1899–1992|knowledge problem (dispersed information); prices as signals; spontaneous order; Road to Serfdom; Austrian business cycle theory; critique of central planning; Nobel 1974
TK9|John Maynard Keynes|1883–1946|General Theory (1936); aggregate demand; liquidity preference; animal spirits; paradox of thrift; multiplier; fiscal policy for recession; Bretton Woods architect
TK10|Arthur Cecil Pigou|1877–1959|Economics of Welfare; Pigouvian tax (tax = marginal external cost); externalities formalized; welfare economics foundation; Pigou effect (real balance effect)
TK11|Milton Friedman|1912–2006|monetarism; natural rate of unemployment; permanent income hypothesis; A Monetary History of the United States (with Schwartz); k-percent rule; free to choose; Nobel 1976
TK12|Robert Lucas|1937–2023|rational expectations revolution; Lucas critique (econometric models break under policy change); microfoundations; policy ineffectiveness proposition; Nobel 1995
TK13|Douglass North|1920–2015|institutions as fundamental determinant of economic performance; transaction costs; path dependence; institutional change theory; Nobel 1993
TK14|John Hicks|1904–1989|IS-LM model (with Hansen); value and capital; consumer surplus reformulation; compensating/equivalent variation; Nobel 1972
TK15|Paul Samuelson|1915–2009|Foundations of Economic Analysis; revealed preference; Stolper-Samuelson theorem; public goods theory; neoclassical synthesis; factor price equalization; Nobel 1970
TK16|Joseph Stiglitz|1943–|information asymmetry in markets; screening; credit rationing; Stiglitz-Weiss model; globalization critique; inequality; Nobel 2001
TK17|Daron Acemoglu|1967–|Why Nations Fail (with Robinson); inclusive vs extractive institutions; political economy of development; directed technical change; Nobel 2024
TK18|Daniel Kahneman|1934–2024|prospect theory (with Tversky); loss aversion; cognitive biases; heuristics; dual-process theory (System 1/System 2); Nobel 2002
TK19|Ronald Coase|1910–2013|nature of the firm (transaction costs explain firm existence); Coase theorem (property rights + zero transaction costs → efficient bargaining); Nobel 1991
TK20|Kenneth Arrow|1921–2017|Arrow's impossibility theorem; general equilibrium existence proof (with Debreu); welfare economics; moral hazard in healthcare; endogenous growth (learning by doing); Nobel 1972
TK21|Gary Becker|1930–2014|human capital theory; economics of discrimination; crime as rational choice; family economics; time allocation; Nobel 1992
TK22|Amartya Sen|1933–|capability approach; development as freedom; welfare beyond GDP; famine and democracy; social choice theory; Nobel 1998
TK23|Robert Solow|1924–2023|Solow growth model; neoclassical growth theory; Solow residual (TFP); capital accumulation and diminishing returns; steady state; Nobel 1987
TK24|Paul Romer|1955–|endogenous growth theory; ideas as non-rival goods; R&D-driven growth; increasing returns; charter cities concept; Nobel 2018
TK25|John Nash|1928–2015|Nash equilibrium; bargaining theory; cooperative and non-cooperative game theory; Nash embedding theorem; Nobel 1994
TK26|Joseph Schumpeter|1883–1950|creative destruction; entrepreneur as innovator; business cycles driven by innovation waves; capitalism's tendency to evolve into bureaucratic socialism
TK27|Irving Fisher|1867–1947|Fisher equation (nominal = real + expected inflation); debt-deflation theory of depression; time preference and interest; quantity theory reformulation

# models(id|name|formulation|key_predictions|assumptions|limitations)
MD1|Supply-Demand (Marshallian)|Qd = f(P), Qs = g(P); equilibrium where Qd = Qs; graphical scissors|price adjusts to clear market; surplus → price falls; shortage → price rises; shifts in S or D predict new equilibrium|many buyers/sellers; homogeneous good; perfect information; no externalities; price-taking|ignores dynamics, market power, information asymmetry; partial equilibrium only
MD2|IS-LM (Hicks-Hansen)|IS: goods market equilibrium (I=S); LM: money market equilibrium (Md=Ms); intersection determines Y and r|fiscal expansion shifts IS right → higher Y and r; monetary expansion shifts LM right → higher Y, lower r; crowding out visible|fixed price level (short-run); closed economy (basic version); stable money demand; single interest rate|no microfoundations; price level fixed; expectations absent; Lucas critique applies
MD3|AD-AS|AD: total spending at each price level; SRAS: upward-sloping (sticky prices); LRAS: vertical at potential output|demand shock → short-run output change + price change; supply shock → stagflation; long-run output at potential regardless of price level|LRAS at natural rate; short-run price stickiness; expectations adjust to actual inflation eventually|aggregate level hides sectoral detail; mechanism for price stickiness debated; expectations formation varies by school
MD4|Solow Growth Model|Y = A × F(K,L); capital accumulation: ΔK = sY - δK; steady state where sY = δK|convergence to steady state; per-capita growth requires TFP growth (A); saving rate affects level, not long-run growth rate; diminishing returns to capital|constant returns to scale; exogenous technology; closed economy; single sector; Cobb-Douglas typical|technology exogenous (black box); no role for institutions, human capital (basic version); convergence prediction often fails unconditionally
MD5|Romer Endogenous Growth|Y = A(R&D) × F(K,L); knowledge accumulation via R&D; ideas are non-rival|sustained growth without exogenous technology; R&D investment drives growth; knowledge spillovers; scale effects; no automatic convergence|increasing returns to ideas; competitive markets for goods; monopolistic competition for innovators; non-rival knowledge|scale effects prediction debated; difficulty measuring ideas; institutional factors omitted
MD6|Phillips Curve (Expectations-Augmented)|π = π^e - β(u - u*) + ε; inflation = expected inflation - coefficient × (unemployment gap) + supply shock|short-run trade-off between inflation and unemployment; long-run vertical at natural rate; expectations shift curve|adaptive or rational expectations; natural rate exists and is stable; supply shocks separable|natural rate may shift; expectations formation uncertain; flattening observed post-2000; disinflation without large unemployment increase (puzzle)
MD7|Mundell-Fleming|IS-LM extended to open economy; adds balance of payments; BP curve|under floating rates: monetary policy effective, fiscal less so (exchange rate offset); under fixed rates: fiscal effective, monetary powerless (impossible trinity)|perfect capital mobility (basic); small open economy; fixed or floating exchange rate; uncovered interest parity|capital mobility varies; exchange rate expectations complex; large economies don't fit small-country assumption
MD8|Heckscher-Ohlin|countries export goods intensive in their abundant factor; 2×2×2 model (2 countries, 2 goods, 2 factors)|trade patterns follow factor endowments; factor price equalization; Stolper-Samuelson (trade hurts scarce factor owners)|identical technology across countries; constant returns; perfect competition; no transport costs; factors immobile internationally|Leontief paradox (empirical challenge); intra-industry trade unexplained; technology differences matter; gravity model better empirically
MD9|Ricardian Trade Model|comparative advantage from technology differences; labor as sole input; opportunity cost determines specialization|both countries gain from trade by specializing in lower opportunity cost good; terms of trade between autarky prices|single factor (labor); constant opportunity cost; two countries, two goods; no transport costs|oversimplified; doesn't explain factor proportions trade; no role for demand; no intra-industry trade
MD10|Prisoner's Dilemma|two players; each can cooperate or defect; defect dominant strategy; mutual defection is Nash equilibrium but Pareto inferior to mutual cooperation|individually rational behavior → collectively suboptimal outcome; explains cartels, arms races, public goods free-riding|simultaneous moves; single-shot (repeated game enables cooperation); complete information about payoffs|single-shot assumption unrealistic for many applications; folk theorem shows cooperation possible in repeated games
MD11|Solow-Swan with Human Capital|Y = K^α × (hL)^(1-α); h = human capital per worker; augmented Solow|human capital accumulation explains income differences across countries; Mankiw-Romer-Weil extension fits data better|same as Solow plus human capital as accumulated factor|human capital measurement difficulties; still leaves TFP residual
MD12|DSGE (Dynamic Stochastic General Equilibrium)|microfounded model with optimizing agents; rational expectations; random shocks; New Keynesian version adds sticky prices|forecasting and policy simulation; impulse response functions; welfare analysis of policy rules|representative agent (or limited heterogeneity); rational expectations; specific shock distributions; log-linearization|representative agent ignores inequality; financial frictions often missing (pre-2008); forecast performance debated
MD13|Gravity Model of Trade|Trade_ij = A × (GDP_i × GDP_j) / Distance_ij; trade proportional to economic size, inversely proportional to distance|predicts bilateral trade flows well empirically; larger/closer economies trade more; border effects large|distance as proxy for trade costs; GDP as proxy for market size|theoretical foundations debated; border effects puzzling; distance declining with technology (slowly)
MD14|Laffer Curve|revenue = rate × base; revenue initially rises with tax rate, then falls as base shrinks; revenue-maximizing rate exists between 0% and 100%|tax cuts can increase revenue if current rate above revenue-maximizing rate; revenue-maximizing rate depends on elasticities|taxable income responds to tax rates; single rate; static vs dynamic scoring|actual revenue-maximizing rate uncertain (estimates: 50-80% for income tax); empirically difficult to identify position on curve
MD15|Taylor Rule|i = r* + π + 0.5(π - π*) + 0.5(y - y*); prescribed interest rate based on inflation gap and output gap|provides systematic monetary policy prescription; inflation above target → raise rates; output below potential → lower rates|neutral real rate (r*) known; output gap measurable; coefficients appropriate; central bank credibility|neutral rate uncertain; output gap measured with error; zero lower bound may bind; unconventional policy not covered

# market_structures(id|name|firms|product|entry_barriers|price_power|efficiency|examples)
MS1|Perfect Competition|very many|homogeneous|none|none (price-taker)|allocatively and productively efficient in long run; P=MC=min ATC|agricultural commodities (approximation); foreign exchange
MS2|Monopolistic Competition|many|differentiated|low|some (downward-sloping demand)|excess capacity in long run; P > MC; product variety benefit|restaurants; clothing brands; craft breweries
MS3|Oligopoly|few|homogeneous or differentiated|high (economies of scale, capital, regulation)|significant; interdependent pricing; game theory applies|automobiles; airlines; telecommunications; oil (OPEC)
MS4|Monopoly|one|unique (no close substitutes)|very high (legal, natural, strategic)|price-setter; restricted output for higher price|deadweight loss; P > MC; productive inefficiency possible; may be natural monopoly where ATC declining|local utilities (natural); historical Standard Oil; patents (temporary)
MS5|Monopsony|many sellers, one buyer|varies|buyer-side barriers|buyer sets price below competitive level|below-competitive employment/purchases; deadweight loss|company towns (historical); some labor markets; large retailers vs small suppliers
MS6|Natural Monopoly|one (efficient)|unique|high (subadditive cost: single firm produces at lower cost than multiple)|regulated or unregulated price-setter|efficient to have one firm (economies of scale); regulation needed to prevent exploitation|water supply; electricity transmission; railway infrastructure

# policy_instruments(id|name|type|mechanism|intended_effect|trade_offs)
PI1|Open Market Operations|monetary|central bank buys/sells government securities; buying injects reserves, selling drains|control short-term interest rate; manage money supply; primary tool of monetary policy|lag between action and effect; transmission mechanism complex; less effective at zero lower bound
PI2|Reserve Requirements|monetary|minimum fraction of deposits banks must hold as reserves; raising requirement tightens|control money multiplier; limit credit creation|blunt instrument; rarely changed in advanced economies; banks hold excess reserves voluntarily
PI3|Discount Rate (Policy Rate)|monetary|interest rate central bank charges commercial banks for emergency borrowing|signal monetary policy stance; lender of last resort|stigma may prevent use; signaling effect sometimes unclear
PI4|Quantitative Easing (QE)|monetary|central bank purchases long-term assets (government bonds, MBS) to lower long-term rates when short-term rate at zero|reduce long-term interest rates; portfolio rebalancing; wealth effect; signal commitment|diminishing returns; potential asset price inflation; exit strategy difficult; distributional effects (benefits asset holders)
PI5|Forward Guidance|monetary|central bank communicates future policy intentions to shape expectations|anchor expectations; extend effective lower bound; reduce uncertainty|credibility dependent; time-inconsistency problem; may constrain future policy flexibility
PI6|Progressive Income Tax|fiscal|marginal tax rate increases with income; brackets define rate schedule|redistribution; vertical equity; revenue generation; automatic stabilizer (revenue falls in recession)|deadweight loss from distorted labor supply/savings; compliance costs; tax avoidance/evasion; optimal top rate debated (40-70% range in literature)
PI7|Government Spending (G)|fiscal|direct purchase of goods and services or transfer payments|stimulate aggregate demand; provide public goods; infrastructure investment|crowding out; deficit financing; implementation lag; political allocation (pork barrel); multiplier varies (0.5-2.0 range in estimates)
PI8|Pigouvian Tax|fiscal/regulatory|tax equal to marginal external cost of activity; internalizes externality|correct negative externality; price reflects true social cost; revenue generated|measuring externality precisely difficult; distributional impact (regressive if on necessities); political resistance
PI9|Cap-and-Trade|regulatory|set total emissions cap; distribute/auction permits; allow trading|achieve pollution target at lowest cost; price discovery for externality; certainty on quantity|permit allocation politics; price volatility; monitoring and enforcement; leakage to unregulated jurisdictions
PI10|Tariff|trade|tax on imports; ad valorem (percentage) or specific (per unit)|protect domestic industry; raise revenue; improve terms of trade (large country)|deadweight loss; retaliation risk; higher consumer prices; rent-seeking by protected industries; reduces gains from trade
PI11|Subsidy|fiscal|government payment to producers or consumers; reduces effective cost|encourage desired activity; support domestic industry; lower consumer price|fiscal cost; distorts allocation; benefits may accrue to producers not consumers; trade disputes (export subsidies)
PI12|Price Ceiling|regulatory|maximum legal price below equilibrium; e.g., rent control|protect consumers from high prices|creates shortage (Qd > Qs); reduces quality; black markets; misallocation; discourages supply long-run
PI13|Price Floor|regulatory|minimum legal price above equilibrium; e.g., minimum wage|protect producers/workers from low prices/wages|creates surplus (Qs > Qd); unemployment (minimum wage debate); government may purchase surplus (agriculture)
PI14|Antitrust/Competition Policy|regulatory|prevent monopolization, price-fixing, anti-competitive mergers; break up dominant firms|maintain competition; prevent deadweight loss from monopoly; protect consumer welfare|definition of market debated; innovation trade-offs (Schumpeterian argument); enforcement costs; regulatory capture risk
PI15|Capital Controls|regulatory/monetary|restrictions on cross-border capital flows; taxes on short-term inflows; quantity limits|reduce volatility; prevent sudden stops; maintain monetary policy autonomy|reduce investment; signal instability; enforcement difficult; IMF view shifted toward conditional acceptance
PI16|Deposit Insurance|regulatory/financial|government guarantees deposits up to limit (e.g., $250,000 FDIC); prevents bank runs|financial stability; depositor confidence; prevents self-fulfilling bank runs|moral hazard (banks take more risk); fiscal contingent liability; encourages larger banks (implicit too-big-to-fail)
PI17|Inflation Targeting|monetary|central bank publicly commits to explicit inflation target (typically 2%); adjusts policy to achieve|anchor inflation expectations; transparency; accountability; credibility|may not address financial stability; zero lower bound problem; appropriate target level debated; average vs point target

# indicators(id|name|formula_or_method|interpretation|frequency)
IC1|GDP (Nominal)|C + I + G + (X - M) at current prices|total economic output; size of economy; not adjusted for price changes|quarterly, annual
IC2|GDP (Real)|nominal GDP adjusted by GDP deflator; constant base-year prices|economic output adjusted for inflation; growth measure; comparable across time|quarterly, annual
IC3|GDP per Capita|real GDP / population|average standard of living; productivity proxy; ignores distribution|annual
IC4|GDP Growth Rate|(GDP_t - GDP_t-1) / GDP_t-1 × 100|rate of economic expansion or contraction; negative for two consecutive quarters = recession (rule of thumb)|quarterly (annualized)
IC5|Unemployment Rate|unemployed / labor force × 100; labor force = employed + unemployed actively seeking|labor market slack; social welfare indicator; U-3 (official) vs U-6 (broader including discouraged and underemployed)|monthly
IC6|Consumer Price Index (CPI)|weighted average price of basket of consumer goods/services relative to base year; Laspeyres index|headline inflation measure; cost-of-living indicator; used for indexation (Social Security, wages)|monthly
IC7|Producer Price Index (PPI)|average change in selling prices received by domestic producers; input prices|leading indicator of consumer inflation; measures cost pressures in supply chain|monthly
IC8|Core Inflation|CPI or PCE excluding food and energy (volatile components)|underlying inflation trend; used by central banks for policy decisions|monthly
IC9|Interest Rate (Federal Funds Rate)|rate at which banks lend reserves to each other overnight; targeted by Federal Reserve|primary monetary policy instrument in US; benchmark for all short-term rates|set by FOMC (8 meetings/year)
IC10|Yield Curve|plot of interest rates across maturities (3-month to 30-year); normally upward-sloping|inverted yield curve (short > long) historically predicts recession (lead time ~12-18 months); steepness indicates growth expectations|continuous
IC11|Money Supply (M1, M2)|M1: currency + demand deposits + other checkable; M2: M1 + savings + small time deposits + money market funds|monetary conditions; monetarist: M2 growth predicts inflation; velocity unstable complicates interpretation|weekly (M1), monthly (M2)
IC12|Current Account Balance|exports - imports + net income + net transfers; as % of GDP|positive = net lender to world; negative = net borrower; persistent deficits may be unsustainable or reflect investment attractiveness|quarterly
IC13|Budget Deficit/Surplus|government revenue - government spending; as % of GDP|fiscal stance; negative = deficit (government borrowing); positive = surplus; structural vs cyclical decomposition|annual
IC14|Debt-to-GDP Ratio|government debt / GDP × 100|fiscal sustainability indicator; Reinhart-Rogoff threshold debated (90%); Japan >250%, US >120%, context matters|annual
IC15|Gini Coefficient|area between Lorenz curve and 45° line / total area below 45° line|income/wealth inequality; 0 = perfect equality; 1 = maximal inequality; US ~0.39; Nordics ~0.25-0.28; South Africa ~0.63|varies (annual typical)
IC16|Human Development Index (HDI)|geometric mean of indices for life expectancy, education (years of schooling), and GNI per capita|multidimensional development measure; broader than GDP per capita; Sen-influenced; UNDP publishes annually|annual
IC17|Purchasing Managers' Index (PMI)|survey of purchasing managers; >50 = expansion; <50 = contraction; components: new orders, production, employment, deliveries, inventories|leading indicator of economic activity; manufacturing and services variants; timely (released monthly)|monthly
IC18|Consumer Confidence Index|survey of consumer expectations about economy, income, spending|leading indicator of consumption; animal spirits proxy; University of Michigan and Conference Board versions|monthly
IC19|Trade Balance|exports - imports of goods and services|component of current account; surplus = net exporter; deficit = net importer; bilateral vs aggregate|monthly, quarterly

# institutions(id|name|type|function|established)
IS1|Federal Reserve System|central bank|US monetary policy; lender of last resort; financial regulation; dual mandate (maximum employment + price stability)|1913
IS2|European Central Bank (ECB)|central bank|eurozone monetary policy; price stability mandate (inflation near 2%); lender of last resort for euro area|1998
IS3|Bank of England|central bank|UK monetary policy; inflation targeting (2%); financial stability|1694 (central banking functions evolved)
IS4|International Monetary Fund (IMF)|international organization|surveillance of global economy; financial assistance to countries in crisis (conditional); technical assistance; SDR|1944 (Bretton Woods)
IS5|World Bank|international organization|development lending; poverty reduction; technical assistance; infrastructure financing; knowledge sharing|1944 (Bretton Woods)
IS6|World Trade Organization (WTO)|international organization|multilateral trade rules; dispute settlement; trade negotiations (rounds); most-favored-nation principle; successor to GATT|1995 (GATT: 1947)
IS7|Bank for International Settlements (BIS)|international organization|central bank cooperation; banking supervision standards (Basel Accords); financial stability research|1930
IS8|FDIC (Federal Deposit Insurance Corporation)|regulatory agency|insures deposits up to $250,000; resolves failed banks; reduces bank run risk|1933
IS9|Securities and Exchange Commission (SEC)|regulatory agency|regulates securities markets; protects investors; enforces disclosure requirements; insider trading prosecution|1934
IS10|OPEC (Organization of Petroleum Exporting Countries)|cartel/international organization|coordinate oil production among member states; influence global oil prices; 13 member states (2024)|1960

# claims(id|claim|type|grounds|source_fk)
CL1|Self-interested individuals pursuing own gain promote social welfare through invisible hand of market|axiom|competition channels self-interest into socially beneficial outcomes; prices coordinate; no central direction needed|TK1
CL2|Division of labor is primary source of productivity gains|observation|specialization increases skill, saves time, enables tool development; pin factory example: 10 workers produce 48,000 pins/day vs 10 individually|TK1
CL3|Trade between nations is mutually beneficial when each specializes according to comparative advantage|derivation|country gains by exporting goods with lower opportunity cost; both parties benefit even if one has absolute advantage in everything|TK2
CL4|Population tends to grow faster than food supply, creating persistent pressure toward subsistence|axiom|geometric growth of population vs arithmetic growth of food; checked by famine, disease, or moral restraint|TK3
CL5|All value derives from socially necessary labor time; capitalists extract surplus value from workers|axiom|labor theory of value; workers paid less than value they create; difference = surplus value = source of profit; exploitation inherent in wage labor|TK5
CL6|In the long run we are all dead; markets may not self-correct fast enough|reframe|classical self-correction relies on flexible prices and wages; in practice adjustment slow and painful; active policy needed now|TK9
CL7|Aggregate demand determines output in short run; economies can remain below full employment equilibrium|axiom|paradox of thrift; sticky wages and prices prevent automatic adjustment; involuntary unemployment is real; animal spirits affect investment|TK9
CL8|Inflation is always and everywhere a monetary phenomenon|axiom|sustained inflation requires sustained money supply growth; MV=PQ; velocity relatively stable; central bank controls M|TK11
CL9|Dispersed knowledge in economy cannot be centrally collected; prices are the only mechanism that aggregates it|axiom|each individual has unique local knowledge; no planner can know all; price system transmits information efficiently and decentrally|TK8
CL10|Econometric models break down when policy regime changes because agents' expectations and behavior adjust|derivation|structural parameters are not policy-invariant; reduced-form relationships shift when agents anticipate policy; microfoundations required|TK12
CL11|Economic institutions (inclusive vs extractive) are fundamental cause of long-run prosperity differences|derivation|inclusive institutions (property rights, rule of law, fair markets) create incentives for investment and innovation; extractive institutions concentrate power and wealth|TK17
CL12|Ideas are non-rival; growth driven by accumulation of ideas; no automatic convergence|derivation|using an idea doesn't reduce its availability; R&D produces ideas; firms investing in R&D earn temporary monopoly profits; increasing returns at societal level|TK24
CL13|People systematically deviate from rational choice: loss aversion, framing effects, anchoring, availability bias|observation|experimental evidence from Kahneman-Tversky; prospect theory; S-shaped value function; people are predictably irrational|TK18
CL14|Firms exist because market transactions have costs; firms internalize transactions when hierarchy is cheaper than market|derivation|search, negotiation, enforcement costs in market; firm boundary where marginal cost of internal transaction = marginal cost of market transaction|TK19
CL15|If property rights well-defined and transaction costs zero, private bargaining resolves externalities efficiently regardless of initial allocation|derivation|parties negotiate to mutual benefit; assignment of rights affects distribution but not efficiency; Coase theorem|TK19
CL16|Creative destruction is the essential fact about capitalism; innovation by entrepreneurs drives growth and displaces incumbents|observation|railroad displaces canal; automobile displaces horse; digital displaces analog; temporary monopoly profits reward disruptive innovation|TK26
CL17|No voting rule can simultaneously satisfy unrestricted domain, Pareto, independence of irrelevant alternatives, and non-dictatorship|derivation|Arrow's impossibility theorem (1951); formal proof; fundamental limit on aggregating individual preferences into social choice|TK20
CL18|Development requires expanding freedoms (capabilities), not merely increasing income|reframe|income is instrumentally important but not constitutive of well-being; health, education, political participation are intrinsic components|TK22

# distinctions(id|side_a|side_b|key_asymmetry)
DI1|Microeconomics|Macroeconomics|micro: individual agents, firms, markets, prices, allocation; macro: aggregate output, employment, inflation, growth, policy; micro provides foundations for macro; macro emergent properties not always reducible
DI2|Positive Economics|Normative Economics|positive: what is, testable statements about economic relationships; normative: what ought to be, value judgments about policy; Friedman: economics should be positive; policy inherently normative
DI3|Short Run|Long Run|short run: at least one input fixed; prices may be sticky; cyclical fluctuations; long run: all inputs variable; prices flexible; economy at potential output; growth dynamics
DI4|Real|Nominal|real: adjusted for inflation (constant prices); nominal: in current prices; real variables (output, wages, interest rate) drive economic decisions; money illusion confuses nominal for real
DI5|Partial Equilibrium|General Equilibrium|partial: analyzes one market holding others constant (Marshall); general: all markets simultaneously (Walras); partial simpler but misses cross-market effects
DI6|Stock|Flow|stock: quantity at point in time (wealth, capital, debt); flow: quantity per unit time (income, investment, deficit); related: flow changes stock; deficit adds to debt
DI7|Progressive Tax|Regressive Tax|progressive: average tax rate rises with income (income tax); regressive: average rate falls with income (sales tax); proportional (flat): constant rate
DI8|Fiscal Policy|Monetary Policy|fiscal: government spending and taxation; direct but slow implementation; political process; monetary: interest rates and money supply; faster but indirect transmission; central bank independence
DI9|Demand-Side|Supply-Side|demand: spending drives short-run output (Keynesian); supply: incentives, technology, factor accumulation drive long-run growth; both matter at different horizons
DI10|Public Good|Private Good|public: non-rival and non-excludable; free-rider problem; underprovided by market; private: rival and excludable; market provision efficient
DI11|Absolute Advantage|Comparative Advantage|absolute: produce more with same resources; comparative: produce at lower opportunity cost; comparative advantage sufficient for mutual gains from trade; absolute advantage neither necessary nor sufficient
DI12|Free Trade|Protectionism|free trade: no tariffs/quotas; maximizes global welfare; comparative advantage; protectionism: tariffs, quotas, subsidies; protects domestic industry; reduces total welfare but redistributes; infant industry and strategic trade arguments
DI13|Inflation|Deflation|inflation: rising prices, falling purchasing power, benefits debtors, harms savers; deflation: falling prices, rising real debt burden, delays spending, risks deflationary spiral; moderate inflation preferred (2% target)
DI14|Market Failure|Government Failure|market failure: externalities, public goods, asymmetric information, market power → inefficient market outcome; government failure: rent-seeking, regulatory capture, information problems, unintended consequences → government intervention may worsen outcome
DI15|Inclusive Institutions|Extractive Institutions|inclusive: property rights, rule of law, open markets, pluralism → incentives for investment and innovation → prosperity; extractive: concentrated power, insecure property, restricted entry → rent extraction → stagnation; Acemoglu-Robinson framework
DI16|Keynesian Unemployment|Classical Unemployment|Keynesian: insufficient aggregate demand, sticky wages prevent adjustment, involuntary; classical: real wage above market-clearing level (minimum wage, unions), voluntary in sense that jobs exist at lower wage
DI17|Active Policy|Rules-Based Policy|active: discretionary response to economic conditions; flexible but time-inconsistency problem; rules: pre-committed formula (Taylor Rule, k-percent rule); credible but inflexible; central debate in macro

# relationships(from|rel|to)
# Foundational concept dependencies
CO1|generates|CO2,CO3
CO2|requires|CO1
CO3|requires|CO5
CO4|drives|CO5
CO5|assumes|CO17
CO6|requires|CO7,CO8,CO9
CO7|interacts_with|CO8
CO9|signals|CO1,CO7,CO8
CO10|implements|CO6,CO7,CO8,CO9
CO11|measures|CO7,CO8

# Consumer theory chain
CO17|governed_by|CO18
CO18|explains|CO8
CO19|constrains|CO17
CO20|represents|CO17
CO90|derives_from|CO17

# Producer theory chain
CO21|determines|CO7
CO22|governs|CO21
CO23|characterizes|CO21
CO24|derived_from|CO21
CO25|requires|CO7,CO24
CO66|disrupts|CO25

# Welfare economics
CO14|measured_by|CO8,CO9
CO15|measured_by|CO7,CO9
CO16|caused_by|CO29,MS4,PI10,PI12,PI13
CO84|requires|MS1
CO85|approaches|CO84
CO89|constrains|CO84

# Market failures
CO29|violates|CO84
CO30|violates|CO84
CO31|violates|CO84
CO32|generates|CO33,CO34,CO35
CO33|specializes|CO32
CO34|specializes|CO32
CO36|explains|CO37
CO37|enables|CO88

# Trade theory
CO26|derived_from|CO2
CO27|contrasts|CO26
CO28|requires|CO26
CO97|affects|CO28
CO98|reduces|CO28
CO99|reduces|CO28

# Money and macro
CO39|enables|CO10
CO40|reduces|CO39
CO41|increases|CO63
CO42|balances|CO39,CO43
CO43|governs|CO42,CO93
CO44|measures|CO10
CO45|measures|CO10
CO46|characterizes|CO44,CO45
CO47|determines|CO44
CO48|determines|CO44
CO51|amplifies|PI7
CO52|offsets|PI7
CO53|explains|CO40
CO54|relates|CO40,CO45

# Growth theory
CO66|drives|CO67
CO67|measures|CO69,CO68
CO68|augments|CO21
CO69|augments|CO21
CO70|requires|CO68,CO67
CO71|predicted_by|MD4
CO72|determines|CO70,CO71

# Game theory and behavioral
CO74|analyzes|MS3,CO76
CO75|defines|CO6
CO76|illustrates|CO30,CO31
CO78|modifies|CO5
CO79|part_of|CO78
CO80|part_of|CO78
CO81|derived_from|CO78
CO91|formalizes|CO5
CO92|derived_from|CO91

# Financial
CO62|reduces|CO32,CO36
CO63|amplifies|CO65
CO64|transfers|CO65
CO65|threatens|CO62

# School lineage
SC1|precedes|SC2
SC2|precedes|SC3
SC3|generates|SC4,SC5
SC4|critiques|SC3
SC5|extends|SC3
SC6|critiques|SC5,SC7
SC7|responds_to|SC3
SC8|responds_to|SC7
SC9|extends|SC8
SC10|synthesizes|SC7,SC9
SC11|extends|SC3,SC8
SC12|extends|SC3,SC5
SC13|integrates|SC5,SC7,SC12
SC14|extends|SC5

# Thinker → school
TK1|founded|SC3
TK2|extends|SC3
TK3|extends|SC3
TK4|extends|SC3
TK5|founded|SC4
TK6|founded|SC5
TK7|founded|SC5
TK8|founded|SC6
TK9|founded|SC7
TK11|founded|SC8
TK12|founded|SC9
TK13|founded|SC12
TK16|extends|SC10
TK17|extends|SC12,SC13

# Thinker contributions → concepts
TK1|defined|CO26,CO28
TK2|defined|CO26,CO27
TK5|defined|CL5
TK6|defined|CO11,CO14,CO15
TK7|defined|CO6
TK8|defined|CL9
TK9|defined|CO47,CO51,CO58
TK10|defined|CO29,PI8
TK11|defined|CO53,CO55,CO59
TK12|defined|CO59,CL10
TK13|defined|CO72,CO36
TK14|defined|MD2
TK15|defined|CO90,CO30
TK16|defined|CO32,CO33
TK17|defined|DI15,CO72
TK18|defined|CO78,CO79,CO80
TK19|defined|CO36,CO88
TK20|defined|CO89,CO84
TK21|defined|CO68
TK22|defined|IC16
TK23|defined|MD4,CO67
TK24|defined|MD5,CO70
TK25|defined|CO75
TK26|defined|CO66
TK27|defined|CO42,CO43

# Model → concept
MD1|models|CO6,CO7,CO8,CO9
MD2|models|CO47,CO50
MD3|models|CO47,CO48,CO40,CO45
MD4|models|CO69,CO67,CO71
MD5|models|CO70,CO68
MD6|models|CO54,CO40,CO45
MD7|extends|MD2
MD8|models|CO26
MD9|models|CO26,CO28
MD10|models|CO74,CO75,CO76
MD12|extends|MD3,MD6
MD13|models|CO28
MD14|models|PI6,CO11
MD15|models|CO50,CO42

# Market structure → welfare
MS1|achieves|CO84
MS2|generates|CO16
MS3|generates|CO16,CO74
MS4|generates|CO16
MS5|generates|CO16
MS6|requires|PI14

# Policy → problem addressed
PI1|implements|CO50
PI4|extends|PI1
PI5|extends|CO50
PI6|addresses|CO82,CO83
PI7|implements|CO49
PI8|corrects|CO29
PI9|corrects|CO29
PI10|implements|CO98
PI11|counteracts|CO29
PI12|causes|CO16
PI13|causes|CO16
PI14|corrects|MS4,MS3
PI15|prevents|CO100
PI16|prevents|CO65
PI17|anchors|CO40

# Indicator relationships
IC1|measured_by|CO44
IC2|adjusts|IC1
IC3|normalizes|IC2
IC4|derived_from|IC2
IC5|measures|CO45
IC6|measures|CO40
IC7|leads|IC6
IC8|refines|IC6
IC9|implements|PI1
IC10|predicts|CO46
IC11|measures|CO39
IC12|measures|CO95
IC13|measures|CO49
IC14|measures|CO49
IC15|measures|CO82
IC16|measures|CO68,CO44
IC17|leads|IC2
IC18|leads|IC1
IC19|measures|CO28

# Institution → function
IS1|implements|CO50,PI1,PI4,PI5
IS2|implements|CO50,PI17
IS3|implements|CO50,PI17
IS4|stabilizes|CO96,CO100
IS5|promotes|CO71
IS6|enforces|CO28,CO98
IS7|coordinates|IS1,IS2,IS3
IS8|implements|PI16
IS9|implements|PI14
IS10|implements|MS3

# Cross-school debates
SC7|disputes|SC3
SC8|disputes|SC7
SC9|disputes|SC7
SC6|disputes|SC7,SC8
SC10|reconciles|SC7,SC9

# Distinction mappings
DI1|distinguishes|CO17,CO44
DI2|distinguishes|CL1,CL7
DI3|distinguishes|CO48,CO47
DI4|distinguishes|IC2,IC1
DI5|distinguishes|MD1,MD2
DI6|distinguishes|CO69,CO44
DI7|distinguishes|PI6
DI8|distinguishes|CO49,CO50
DI9|distinguishes|SC7,SC11
DI10|distinguishes|CO30
DI11|distinguishes|CO27,CO26
DI12|distinguishes|CO28,CO98
DI13|distinguishes|CO40,CO41
DI14|distinguishes|CO29,CO38
DI15|distinguishes|CO72
DI16|distinguishes|CO45
DI17|distinguishes|PI1,PI7

# decode_legend
# id_prefixes: CO=concept, SC=school, TK=thinker, MD=model, MS=market_structure, PI=policy_instrument, IC=indicator, IS=institution, CL=claim, DI=distinction
# rel_types: generates|requires|assumes|drives|interacts_with|signals|implements|measures|governed_by|explains|constrains|represents|derives_from|determines|characterizes|derived_from|caused_by|violates|specializes|enables|contrasts|reduces|affects|balances|governs|amplifies|offsets|relates|predicted_by|modifies|part_of|formalizes|transfers|threatens|disrupts|augments|analyzes|defines|illustrates|precedes|extends|critiques|responds_to|synthesizes|integrates|founded|defined|models|achieves|addresses|corrects|causes|counteracts|prevents|anchors|adjusts|normalizes|leads|refines|predicts|stabilizes|promotes|enforces|coordinates|disputes|reconciles|approaches|distinguishes
# claim_types: axiom=foundational unargued commitment; derivation=follows from prior claims; observation=empirical finding; reframe=reconceptualization of existing idea; prescription=recommended action
# market_structure: firms=number of firms; product=homogeneous or differentiated; entry_barriers=none/low/high/very high; price_power=none to price-setter
# confidence: synthetic domain knowledge — not extracted from a single source document
