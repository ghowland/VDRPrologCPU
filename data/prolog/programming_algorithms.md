%% ============================================================
%% PROGRAMMING ALGORITHMS — DOMAIN PROLOG
%% Connects to core prolog + data structures prolog.
%% Facts from programming_algorithms.compact
%% ============================================================


%% --- COMPLEXITY CLASS HIERARCHY ---
%% P ⊂ NP ⊂ PSPACE ⊂ EXP. NP-Complete ⊂ NP. NP-Hard ⊇ NP-Complete.
contains(cx9, cx1).    % P contains O(1)
contains(cx9, cx2).    % P contains O(log n)
contains(cx9, cx3).    % P contains O(n)
contains(cx9, cx4).    % P contains O(n log n)
contains(cx9, cx5).    % P contains O(n²)
contains(cx9, cx6).    % P contains O(n³)
contains(cx10, cx9).   % NP contains P
contains(cx14, cx10).  % PSPACE contains NP
contains(cx14, cx13).  % PSPACE contains co-NP
contains(cx15, cx14).  % EXP contains PSPACE
specializes(cx11, cx10).  % NP-Complete specializes NP (hardest in NP)
generalizes(cx12, cx11).  % NP-Hard generalizes NP-Complete

%% Complexity ordering for comparison queries.
follows(cx1, cx2).     % O(1) < O(log n)
follows(cx2, cx3).     % O(log n) < O(n)
follows(cx3, cx4).     % O(n) < O(n log n)
follows(cx4, cx5).     % O(n log n) < O(n²)
follows(cx5, cx6).     % O(n²) < O(n³)
follows(cx6, cx7).     % O(n³) < O(2ⁿ)
follows(cx7, cx8).     % O(2ⁿ) < O(n!)


%% --- ASYMPTOTIC NOTATION HIERARCHY ---
generalizes(co4, co6).  % O generalizes Θ (upper bound widens tight bound)
generalizes(co5, co6).  % Ω generalizes Θ (lower bound widens tight bound)
specializes(co7, co4).  % o specializes O (strict upper is tighter)


%% --- TECHNIQUE → ALGORITHM BINDING ---
%% Which technique each algorithm uses.

%% Divide and conquer.
implements(te1, al4).   % D&C implements merge sort
implements(te1, al5).   % D&C implements quicksort
implements(te1, al21).  % D&C implements median of medians
implements(te1, al68).  % D&C implements closest pair
implements(te1, al76).  % D&C implements Strassen
implements(te1, al77).  % D&C implements FFT

%% Dynamic programming.
implements(te2, al45).  % DP implements Fibonacci
implements(te2, al46).  % DP implements LCS
implements(te2, al47).  % DP implements edit distance
implements(te2, al48).  % DP implements 0/1 knapsack
implements(te2, al49).  % DP implements LIS
implements(te2, al50).  % DP implements matrix chain
implements(te2, al51).  % DP implements subset sum
implements(te2, al52).  % DP implements coin change

%% Greedy.
implements(te3, al32).  % greedy implements Kruskal
implements(te3, al33).  % greedy implements Prim
implements(te3, al54).  % greedy implements activity selection
implements(te3, al55).  % greedy implements Huffman
implements(te3, al56).  % greedy implements fractional knapsack
implements(te3, al57).  % greedy implements interval scheduling

%% Randomization.
implements(te6, al5).   % randomization implements quicksort (random pivot)
implements(te6, al20).  % randomization implements quickselect
implements(te6, al60).  % randomization implements Rabin-Karp
implements(te6, al80).  % randomization implements reservoir sampling
implements(te6, al81).  % randomization implements Fisher-Yates

%% Binary search as technique.
implements(te12, al16).  % binary search technique implements binary search
implements(te12, al17).  % binary search implements interpolation search
implements(te12, al18).  % binary search implements exponential search
implements(te12, al49).  % binary search used in LIS (patience sorting)

%% Sweep line.
instance_of(al69, te9).  % line sweep intersection is sweep line instance
instance_of(al70, te9).  % Fortune's algorithm is sweep line instance

%% Backtracking.
implements(te4, pc14).   % backtracking implements constraint satisfaction


%% --- TECHNIQUE PREREQUISITES ---
%% What properties a problem must have for technique to apply.
requires(te1, co42).   % D&C requires divide step
requires(te1, co43).   % D&C requires conquer step
requires(te1, co44).   % D&C requires combine step
requires(te2, co46).   % DP requires optimal substructure
requires(te2, co47).   % DP requires overlapping subproblems
requires(te3, co45).   % greedy requires greedy choice property
requires(te3, co46).   % greedy requires optimal substructure
extends(te5, te4).     % branch and bound extends backtracking


%% --- ALGORITHM → DATA STRUCTURE REQUIREMENTS ---
%% What structures algorithms need to run.

%% Sorting.
requires(al4, ds1).    % merge sort requires array
requires(al5, ds1).    % quicksort requires array
requires(al6, ds8).    % heapsort requires binary heap

%% Searching.
requires(al16, ds1).   % binary search requires sorted array
requires(al17, ds1).   % interpolation search requires sorted array
requires(al18, ds1).   % exponential search requires array
requires(al18, al16).  % exponential search requires binary search

%% Graph algorithms.
requires(al23, ds24).  % BFS requires adjacency list
requires(al24, ds24).  % DFS requires adjacency list
requires(al26, ds24).  % Dijkstra requires adjacency list
requires(al26, ds10).  % Dijkstra requires priority queue
requires(al27, ds24).  % Bellman-Ford requires adjacency list
requires(al28, ds25).  % Floyd-Warshall requires adjacency matrix
requires(al32, ds23).  % Kruskal requires union-find
requires(al33, ds10).  % Prim requires priority queue
requires(al35, ds6).   % Kahn's topo sort requires queue

%% Flow algorithms.
requires(al40, co51).  % Ford-Fulkerson requires augmenting path concept
requires(al40, co52).  % Ford-Fulkerson requires residual graph concept

%% String algorithms.
requires(al59, co63).  % KMP requires prefix function
requires(al60, te14).  % Rabin-Karp requires hashing technique

%% Geometry.
requires(al66, ds35).  % Graham scan requires monotone stack


%% --- ALGORITHM EXTENSION CHAINS ---
%% How algorithms build on each other.

%% Hybrid sorts: composed from simpler sorts.
extends(al10, al4).   % TimSort extends merge sort
extends(al10, al3).   % TimSort extends insertion sort
extends(al11, al5).   % Introsort extends quicksort
extends(al11, al6).   % Introsort extends heapsort
extends(al11, al3).   % Introsort extends insertion sort
extends(al14, al5).   % pdqsort extends quicksort
extends(al14, al6).   % pdqsort extends heapsort
extends(al14, al3).   % pdqsort extends insertion sort

%% Insertion sort is component of hybrids.
part_of(al3, al10).   % insertion sort part of TimSort
part_of(al3, al11).   % insertion sort part of Introsort
part_of(al3, al14).   % insertion sort part of pdqsort

%% Search extensions.
extends(al30, al26).   % A* extends Dijkstra (adds heuristic)

%% Flow extensions.
extends(al41, al40).   % Edmonds-Karp extends Ford-Fulkerson (BFS selection)
extends(al42, al40).   % Dinic extends Ford-Fulkerson (layered graph)
requires(al41, al23).  % Edmonds-Karp requires BFS

%% Shortest path composition.
requires(al29, al27).  % Johnson requires Bellman-Ford (reweighting)
requires(al29, al26).  % Johnson requires Dijkstra (per-source)

%% SCC algorithms depend on DFS.
requires(al37, al24).  % Kosaraju requires DFS
requires(al38, al24).  % Tarjan requires DFS

%% DAG shortest path requires topological sort.
requires(al31, te19).  % DAG shortest path requires topological sort

%% String algorithm extensions.
extends(al61, al58).   % Boyer-Moore extends naive matching (same goal, better)
extends(al62, ds19).   % Aho-Corasick extends trie (failure links)
extends(al62, al59).   % Aho-Corasick extends KMP (multi-pattern)
equivalent_to(al63, al59).  % Z-algorithm equivalent to KMP (same power)

%% Numerical extensions.
extends(al72, al71).   % extended Euclidean extends Euclidean GCD

%% Geometry equivalences.
equivalent_to(al67, al66).  % Andrew's monotone chain ≡ Graham scan


%% --- SORTING PROPERTY CLASSIFICATION ---
%% Which sorts have which properties.

%% Stable sorts.
instance_of(al1, co17).   % bubble sort is stable
instance_of(al3, co17).   % insertion sort is stable
instance_of(al4, co17).   % merge sort is stable
instance_of(al7, co17).   % counting sort is stable
instance_of(al8, co17).   % radix sort is stable
instance_of(al10, co17).  % TimSort is stable

%% In-place sorts.
instance_of(al1, co18).   % bubble sort is in-place
instance_of(al2, co18).   % selection sort is in-place
instance_of(al3, co18).   % insertion sort is in-place
instance_of(al5, co18).   % quicksort is in-place
instance_of(al6, co18).   % heapsort is in-place

%% Comparison-based sorts.
instance_of(al1, co22).   % bubble sort is comparison-based
instance_of(al2, co22).   % selection sort is comparison-based
instance_of(al3, co22).   % insertion sort is comparison-based
instance_of(al4, co22).   % merge sort is comparison-based
instance_of(al5, co22).   % quicksort is comparison-based
instance_of(al6, co22).   % heapsort is comparison-based

%% Adaptive sorts.
instance_of(al3, co21).   % insertion sort is adaptive
instance_of(al10, co21).  % TimSort is adaptive

%% Non-comparison sorts (bypass Ω(n log n) bound).
prevents(al7, co22).   % counting sort is NOT comparison-based
prevents(al8, co22).   % radix sort is NOT comparison-based


%% --- DP PROBLEM PROPERTIES ---
%% What makes a problem solvable by DP.
instance_of(al46, co46).  % LCS has optimal substructure
instance_of(al46, co47).  % LCS has overlapping subproblems
instance_of(al47, co46).  % edit distance has optimal substructure
instance_of(al47, co47).  % edit distance has overlapping subproblems
instance_of(al48, co46).  % knapsack has optimal substructure
instance_of(al48, co47).  % knapsack has overlapping subproblems
instance_of(al49, co46).  % LIS has optimal substructure
instance_of(al50, co46).  % matrix chain has optimal substructure
instance_of(al50, co47).  % matrix chain has overlapping subproblems


%% --- PROBLEM CLASS → COMPLEXITY ---
bounded_by(pc1, cx17).   % sorting lower-bounded by Ω(n log n) (comparison)
bounded_by(pc2, cx2).    % searching lower-bounded by O(log n) (sorted)
solves(cx9, pc3).         % P solves shortest path
solves(cx9, pc4).         % P solves MST
solves(cx9, pc5).         % P solves max flow
solves(cx9, pc6).         % P solves matching
solves(cx3, pc7).         % O(n) solves string matching
instance_of(pc11, cx11).  % SAT is NP-Complete
instance_of(pc12, cx12).  % TSP is NP-Hard
instance_of(pc13, cx12).  % graph coloring is NP-Hard


%% --- RECURRENCE → MASTER THEOREM ---
%% Classify recurrences by which Master Theorem case applies.
instance_of(re1, re8).   % merge sort recurrence is case 2
instance_of(re2, re8).   % quicksort average is case 2
instance_of(re4, re7).   % binary search is case 1
instance_of(re5, re7).   % Strassen is case 1
instance_of(re6, re7).   % Karatsuba is case 1
instance_of(re12, re8).  % closest pair is case 2

%% Recurrence determines complexity.
determined_by(al4, re1).   % merge sort complexity determined by its recurrence
determined_by(al5, re2).   % quicksort avg determined by its recurrence
determined_by(al16, re4).  % binary search determined by its recurrence
determined_by(al76, re5).  % Strassen determined by its recurrence
determined_by(al68, re12). % closest pair determined by its recurrence


%% --- NEGATIVE CONSTRAINTS ---
%% What algorithms cannot do or require.
prevents(al26, co50).  % Dijkstra prevents negative edge relaxation
%% (Dijkstra fails on negative edges — use Bellman-Ford instead)

constrains(co23, al1).  % comparison lower bound constrains bubble sort
constrains(co23, al2).  % constrains selection sort
constrains(co23, al3).  % constrains insertion sort
constrains(co23, al4).  % constrains merge sort
constrains(co23, al5).  % constrains quicksort
constrains(co23, al6).  % constrains heapsort
%% All comparison sorts bounded by Ω(n log n).


%% --- ALGORITHM SELECTION RULES ---
%% Domain-specific: given problem properties, select algorithm. L3.

%% Sort selection.
select_sort(AL, stable, in_place, guaranteed_nlogn) :-
    instance_of(AL, co17),     % stable
    instance_of(AL, co18),     % in-place
    complexity(AL, _, cx4, _). % O(n log n) worst
%% Only AL13 (block sort) satisfies all three. Rare.

select_sort(AL, stable, _, guaranteed_nlogn) :-
    instance_of(AL, co17),
    complexity(AL, _, cx4, _).
%% AL4 (merge sort), AL10 (TimSort).

select_sort(AL, _, in_place, guaranteed_nlogn) :-
    instance_of(AL, co18),
    complexity(AL, _, cx4, _).
%% AL6 (heapsort), AL11 (introsort), AL14 (pdqsort).

select_sort(AL, _, _, expected_nlogn) :-
    complexity(AL, cx4, _, _).
%% AL5 (quicksort) — O(n log n) average, O(n²) worst.

select_sort(AL, _, _, small_n) :-
    instance_of(AL, co21). % adaptive
%% AL3 (insertion sort) — optimal for small/nearly sorted.

select_sort(AL, _, _, integer_keys) :-
    prevents(AL, co22).  % non-comparison
%% AL7 (counting sort), AL8 (radix sort) — O(n) possible.

%% Shortest path selection.
select_shortest_path(al26, nonneg_weights, single_source).
%% Dijkstra: non-negative, single source.

select_shortest_path(al27, any_weights, single_source).
%% Bellman-Ford: handles negative edges.

select_shortest_path(al28, any_weights, all_pairs).
%% Floyd-Warshall: all pairs, dense graph.

select_shortest_path(al29, neg_weights, all_pairs).
%% Johnson: all pairs with negative edges, sparse graph.

select_shortest_path(al31, any_weights, dag_only).
%% DAG shortest path: any weights, DAG structure.

select_shortest_path(al30, nonneg_weights, single_target) :-
    available(heuristic).
%% A*: single source-target with admissible heuristic.

%% Graph representation selection.
select_graph_repr(ds24, sparse).   % adjacency list for sparse
select_graph_repr(ds25, dense).    % adjacency matrix for dense
select_graph_repr(ds24, traverse). % adjacency list for neighbor iteration
select_graph_repr(ds25, edge_check). % matrix for O(1) edge check

%% String matching selection.
select_string_match(al59, single_pattern, guaranteed_linear).
%% KMP: single pattern, O(n+m) guaranteed.

select_string_match(al60, single_pattern, simple_implementation).
%% Rabin-Karp: single pattern, expected linear, simple.

select_string_match(al61, single_pattern, fast_average).
%% Boyer-Moore: single pattern, sublinear average.

select_string_match(al62, multi_pattern, _).
%% Aho-Corasick: multiple patterns simultaneously.


%% --- TECHNIQUE SELECTION ---
%% Given problem properties, select technique. L3.

select_technique(te1, Problem) :-
    has_property(Problem, co42),  % divisible
    has_property(Problem, co44),  % combinable
    \+ has_property(Problem, co47). % no overlap (else use DP)

select_technique(te2, Problem) :-
    has_property(Problem, co46),  % optimal substructure
    has_property(Problem, co47).  % overlapping subproblems

select_technique(te3, Problem) :-
    has_property(Problem, co45),  % greedy choice property
    has_property(Problem, co46).  % optimal substructure

select_technique(te4, Problem) :-
    instance_of(Problem, pc14).   % constraint satisfaction


%% --- CROSS-DOMAIN BRIDGES ---

%% Algorithms × Data Structures (direct bindings).
%% Heapsort uses binary heap → data structures ST12.
requires(al6, st12).
%% Kruskal uses union-find → data structures ST40.
requires(al32, st40).
%% Dijkstra uses priority queue → data structures ST11.
requires(al26, st11).
%% BFS uses queue → data structures ST8.
requires(al23, st8).
%% DFS uses stack → data structures ST6.
requires(al24, st6).
%% Graham scan uses monotone stack → data structures ST61.
requires(al66, st61).
%% Huffman uses priority queue → data structures ST11.
requires(al55, st11).

%% Algorithms × Connections.
%% Graph algorithms operate on connection networks.
instance_of(al23, graph_traversal).  % BFS traverses connections
instance_of(al24, graph_traversal).  % DFS traverses connections
%% BFS = breadth-first = connections.NE1 (star-like expansion per level).
%% DFS = depth-first = connections.NE4 (tree-like descent).
%% Max flow operates on connections with CO8 (capacity).
requires(al40, co8_capacity).  % flow requires capacity on edges
%% MST produces connections.CO54 spanning tree = connections.NE4 tree topology.
produces(al32, spanning_tree).
produces(al33, spanning_tree).

%% Algorithms × Movement.
%% BFS explores states in temporal sequence (movement.TM1).
instance_of(bfs_exploration, temporal_sequence).
%% Relaxation (CO50) is a transition: distance estimate evolves_to better estimate.
instance_of(co50, state_transition).
evolves_to(distance_estimate_old, distance_estimate_new) :-
    enables(co50, distance_improvement).
%% Convergence (movement.TR11): relaxation converges when no more improvements.
enables(co50, convergence).

%% Algorithms × Logic.
%% Correctness (CO12) requires loop invariant (CO13) = logic.CO4 (invariant).
requires(co12, co13).
%% Loop invariant IS a logical formula universally quantified over iterations.
instance_of(co13, logical_formula).
%% Lower bound proofs use adversarial argument = logic.CO36.
implements(co36, lower_bound_proof).
%% NP-completeness proof uses reduction = logic.TE8/CO24.
implements(co24, np_hardness_proof).
%% Decision tree argument for Ω(n log n) is a logical proof.
instance_of(cx17, lower_bound_theorem).

%% Recurrence solving uses mathematical induction.
requires(co35, mathematical_induction).

%% Algorithms × English.
%% Algorithm names map to mechanical descriptions via grammar patterns.
%% "Merge sort divides the array, sorts halves, merges results."
%% = SP2 (SVO) × 3, coordinated (CL2), temporal sequence (follows).
%% The system describes algorithms using:
%%   SP2: "X requires Y." "X produces Y." "X uses Y."
%%   CL5: "X because Y." "X if Y."
%%   CL6: "If input is sorted, then binary search applies."
%%   follows: "Divide, then conquer, then combine."


%% --- VDR-PROLOG SYSTEM BRIDGES ---
%% Algorithms the VDR-Prolog system itself uses.

%% Prolog engine uses DFS with backtracking = AL24 + TE4.
implements(vdr_prolog_engine, al24).  % DFS for proof search
implements(vdr_prolog_engine, te4).   % backtracking for alternatives

%% Typed relation query uses binary search on sorted index.
implements(vdr_relation_query, al16). % binary search on relation index

%% Transitive closure uses BFS = AL23.
implements(vdr_transitive_closure, al23). % BFS for closure

%% GEMM is matrix multiplication. Naive = O(n³).
%% VDR uses direct GEMM, not Strassen (too complex for SIMD i32).
implements(vdr_gemm, al79_variant).  % direct matrix multiply
prevents(vdr_gemm, al76).           % Strassen not used (complexity vs SIMD)

%% LRU session management uses LRU cache = DS28 = ST54.
implements(vdr_session_mgmt, ds28).

%% Softmax FRU is a selection algorithm: find max remainder = AL20 variant.
instance_of(vdr_fru, selection_algorithm).

%% Hash-based path index = DS12 with hashing technique TE14.
implements(vdr_path_index, ds12).
implements(vdr_path_index, te14).

%% Arena allocator is O(1) bump pointer = CX1 constant time allocation.
instance_of(vdr_arena_alloc, cx1).

%% KB lazy loading is online algorithm (CO19): load on access, not upfront.
instance_of(vdr_lazy_loading, co19).
