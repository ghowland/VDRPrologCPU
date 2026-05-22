# PROGRAMMING ALGORITHMS — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: concepts → complexity_classes → techniques → data_structures → algorithms → problem_classes → recurrences → distinctions → relationships → decode_legend

# concepts(id|name|definition|category)
CO1|Algorithm|finite sequence of well-defined instructions solving a computational problem|foundation
CO2|Time Complexity|function mapping input size n to number of elementary operations|analysis
CO3|Space Complexity|function mapping input size n to memory required beyond input|analysis
CO4|Big-O (O)|asymptotic upper bound; f(n) = O(g(n)) iff ∃c,n₀: f(n) ≤ c·g(n) ∀n≥n₀|notation
CO5|Big-Omega (Ω)|asymptotic lower bound; f(n) = Ω(g(n)) iff ∃c,n₀: f(n) ≥ c·g(n) ∀n≥n₀|notation
CO6|Big-Theta (Θ)|tight asymptotic bound; f(n) = Θ(g(n)) iff f(n) = O(g(n)) and f(n) = Ω(g(n))|notation
CO7|Little-o (o)|strict upper bound; f(n) = o(g(n)) iff lim(n→∞) f(n)/g(n) = 0|notation
CO8|Amortized Complexity|average cost per operation over worst-case sequence of operations|analysis
CO9|Best Case|minimum operations for any input of size n|analysis
CO10|Average Case|expected operations over all inputs of size n under some distribution|analysis
CO11|Worst Case|maximum operations for any input of size n|analysis
CO12|Correctness|algorithm terminates and produces correct output for all valid inputs|property
CO13|Loop Invariant|condition true before loop, maintained by each iteration, establishes postcondition on termination|verification
CO14|Termination|guarantee that algorithm halts on all valid inputs|property
CO15|Determinism|same input always produces same output and same execution path|property
CO16|Randomization|algorithm uses random bits; may be faster in expectation or simpler|property
CO17|Stability (sort)|equal elements retain their original relative order after sorting|property
CO18|In-Place|algorithm uses O(1) or O(log n) extra space beyond input|property
CO19|Online Algorithm|processes input piece-by-piece without seeing entire input|property
CO20|Offline Algorithm|requires access to entire input before producing output|property
CO21|Adaptive (sort)|performance improves when input is partially sorted|property
CO22|Comparison-Based|algorithm accesses elements only via pairwise comparisons|property
CO23|Lower Bound (comparison sort)|Ω(n log n) for any comparison-based sorting algorithm; decision tree argument|theorem
CO24|Reduction|transforming problem A into problem B to solve A using B's solver|technique
CO25|Decidability|problem is decidable iff an algorithm exists that always halts with correct answer|computability
CO26|Tractability|problem is tractable if solvable in polynomial time|computability
CO27|Optimal Algorithm|algorithm whose worst-case complexity matches the problem's lower bound|property
CO28|Approximation Ratio|for optimization: max over all inputs of (algorithm result / optimal result) or inverse|property
CO29|Competitive Ratio|for online algorithms: worst-case ratio of online cost to optimal offline cost|property
CO30|Cache-Oblivious|algorithm performs well on memory hierarchy without knowing cache parameters|property
CO31|Tail Recursion|recursive call is last operation; can be optimized to iteration by compiler|property
CO32|Memoization|caching results of function calls to avoid recomputation|technique
CO33|Invariant|condition maintained across steps of an algorithm; proves correctness|verification
CO34|Recurrence Relation|equation defining T(n) in terms of T on smaller inputs|analysis
CO35|Master Theorem|solves recurrences of form T(n) = aT(n/b) + f(n) into Θ-bounds|analysis
CO36|Adversarial Argument|proving lower bounds by constructing worst-case input adversary|analysis
CO37|Amortized Analysis (Aggregate)|total cost of n operations / n; assigns uniform amortized cost|analysis
CO38|Amortized Analysis (Accounting)|assign amortized cost per operation; overpayment stored as credit for future expensive operations|analysis
CO39|Amortized Analysis (Potential)|define potential function Φ; amortized cost = actual cost + ΔΦ|analysis
CO40|NP-Hardness Proof|reduce known NP-complete problem to target problem in polynomial time|technique
CO41|Halting Problem|undecidable: no algorithm can determine for all programs whether they halt|computability
CO42|Divide Step|split problem into smaller subproblems of same type|technique
CO43|Conquer Step|solve subproblems recursively (or directly if base case)|technique
CO44|Combine Step|merge subproblem solutions into solution for original problem|technique
CO45|Greedy Choice Property|locally optimal choice leads to globally optimal solution|property
CO46|Optimal Substructure|optimal solution contains optimal solutions to subproblems|property
CO47|Overlapping Subproblems|same subproblems recur multiple times in recursive solution|property
CO48|Subproblem Graph|DAG of dependencies between subproblems; DP computes in topological order|structure
CO49|State Space|set of all configurations reachable from initial state|structure
CO50|Relaxation (graph)|updating distance estimate: if d[u]+w(u,v) < d[v] then d[v] = d[u]+w(u,v)|technique
CO51|Augmenting Path|path from source to sink in residual graph with positive capacity on all edges|structure
CO52|Residual Graph|graph showing remaining capacity on each edge after current flow|structure
CO53|Cut (graph)|partition of vertices into two sets S,T where s∈S and t∈T|structure
CO54|Spanning Tree|connected acyclic subgraph containing all vertices|structure
CO55|Topological Order|linear ordering of vertices where u appears before v for every edge (u,v)|structure
CO56|Strongly Connected Component|maximal set of vertices where every vertex is reachable from every other|structure
CO57|Bipartite Graph|graph whose vertices can be partitioned into two sets with edges only between sets|structure
CO58|Eulerian Path|path visiting every edge exactly once|structure
CO59|Hamiltonian Path|path visiting every vertex exactly once|structure
CO60|Convex Hull|smallest convex polygon containing all points in a set|structure
CO61|Voronoi Diagram|partition of plane into regions closest to each site point|structure
CO62|Suffix|suffix of string S starting at position i: S[i..n]|string
CO63|Prefix Function|π[i] = length of longest proper prefix of S[0..i] that is also a suffix|string
CO64|Back Edge|edge to an ancestor in DFS tree; indicates cycle|structure
CO65|Cross Edge|edge to a non-ancestor, non-descendant in DFS tree|structure
CO66|Tree Edge|edge in DFS/BFS tree connecting parent to child|structure

# complexity_classes(id|name|definition|bounds|example_problems)
CX1|O(1)|constant time; independent of input size|1|hash table lookup, array index access, stack push/pop
CX2|O(log n)|logarithmic; halving input each step|log₂ n|binary search, balanced BST lookup, exponentiation by squaring
CX3|O(n)|linear; proportional to input|n|linear search, single-pass array scan, counting sort (per range)
CX4|O(n log n)|linearithmic; comparison-sort optimal|n log₂ n|merge sort, heap sort, FFT, convex hull (optimal)
CX5|O(n²)|quadratic; all pairs|n²|insertion sort worst, bubble sort, naive string matching
CX6|O(n³)|cubic; all triples|n³|naive matrix multiplication, Floyd-Warshall
CX7|O(2ⁿ)|exponential; all subsets|2ⁿ|brute-force SAT, traveling salesman (brute-force), power set generation
CX8|O(n!)|factorial; all permutations|n!|brute-force TSP via permutation, unrestricted constraint satisfaction
CX9|P|problems solvable in polynomial time by deterministic TM|O(nᵏ) for some k|sorting, shortest path, matching, linear programming
CX10|NP|problems verifiable in polynomial time by deterministic TM|verify in O(nᵏ)|SAT, clique, vertex cover, subset sum, Hamiltonian path
CX11|NP-Complete|in NP and every NP problem reduces to it in polynomial time; hardest problems in NP|≥O(nᵏ) for all known k|SAT (Cook-Levin), 3-SAT, clique, vertex cover, Hamiltonian cycle, subset sum
CX12|NP-Hard|at least as hard as NP-complete; need not be in NP|≥NP-complete|halting problem, optimization TSP, general integer programming
CX13|co-NP|complement of NP; "no" answers verifiable in polynomial time|verify "no" in O(nᵏ)|tautology, non-Hamiltonicity
CX14|PSPACE|solvable with polynomial space|O(nᵏ) space|QBF (PSPACE-complete), generalized chess/Go
CX15|EXP|solvable in exponential time|O(2^(nᵏ))|complete game trees, brute-force combinatorial optimization
CX16|BPP|solvable by randomized TM in polynomial time with error probability < 1/3|O(nᵏ) randomized|primality testing (Miller-Rabin), polynomial identity testing
CX17|Ω(n log n)|lower bound for comparison-based sorting|n log₂ n|any comparison sort must make at least ⌈log₂(n!)⌉ comparisons

# techniques(id|name|definition|when_used|mechanism)
TE1|Divide and Conquer|split into subproblems, solve recursively, combine results|problem decomposes into independent subproblems of same type|divide → conquer → combine; recurrence T(n)=aT(n/b)+f(n)
TE2|Dynamic Programming|solve overlapping subproblems once, store results, build up to full solution|optimal substructure + overlapping subproblems|define subproblem → recurrence → base cases → compute bottom-up or top-down with memoization
TE3|Greedy|make locally optimal choice at each step|greedy choice property + optimal substructure|sort/prioritize → choose best available → commit → never revisit
TE4|Backtracking|explore candidate solutions incrementally; abandon (prune) when constraint violated|constraint satisfaction; exhaustive search with pruning|extend partial solution → check constraints → recurse or backtrack
TE5|Branch and Bound|backtracking + bounding function to prune suboptimal branches|optimization over search tree|maintain best-known bound; prune subtrees worse than bound
TE6|Randomization|use random choices to achieve expected efficiency or simplicity|avoiding worst-case inputs; breaking symmetry|random pivot (quicksort), random sampling, random hashing
TE7|Amortized Analysis|prove average cost per operation over sequence is low despite occasional expensive operations|data structure operations with varying costs|aggregate, accounting, or potential method
TE8|Reduction|transform unknown problem into known problem to leverage existing solution|proving hardness or reusing algorithms|encode instance of A as instance of B; solve B; decode answer
TE9|Sweep Line|process geometric events in sorted order along a line|computational geometry: intersections, unions, closest pair|sort events by coordinate; maintain active set; process events left-to-right
TE10|Two Pointers|maintain two indices scanning array; adjust based on condition|sorted array problems; window-based problems|left/right pointers converge or expand based on comparison
TE11|Sliding Window|fixed or variable-size window over sequence; update incrementally|subarray/substring optimization with contiguity constraint|expand right → check condition → contract left → track optimum
TE12|Binary Search (technique)|halve search space each step by comparing with midpoint|sorted or monotonic structure; decision problems|lo, hi → mid = (lo+hi)/2 → compare → narrow to left or right half
TE13|Bit Manipulation|use bitwise operations to encode sets, flags, or perform arithmetic|subset enumeration; flags; fast arithmetic; space optimization|AND, OR, XOR, NOT, shifts; bitmask = set of elements
TE14|Hashing|map keys to fixed-size values via hash function for O(1) expected access|fast lookup, deduplication, set operations|hash(key) → index; handle collisions via chaining or probing
TE15|Prefix Sums|precompute cumulative sums; answer range-sum queries in O(1)|range queries on static arrays|P[0]=0; P[i]=P[i-1]+A[i-1]; sum(l,r) = P[r+1]-P[l]
TE16|Monotone Stack|stack maintaining monotonic order; elements popped when order violated|next greater/smaller element; histogram problems|push index; pop while top violates monotonicity; record relationships
TE17|Union-Find (technique)|track disjoint sets with union and find operations|connected components; Kruskal's; equivalence classes|find with path compression; union by rank
TE18|Relaxation|iteratively improve estimates until optimal|shortest paths; linear programming; network flow|update d[v] = min(d[v], d[u]+w(u,v)) until no improvement
TE19|Topological Sort (technique)|linearize DAG respecting edge directions|scheduling; dependency resolution; DP on DAGs|DFS post-order reverse; or Kahn's with in-degree queue
TE20|Coordinate Compression|map large coordinate range to dense [0,n) range preserving order|geometry and range problems with sparse coordinates|sort unique coordinates → assign consecutive indices
TE21|Euler Tour|record DFS entry/exit times to flatten tree into array|subtree queries; LCA; tree to range reduction|enter[v] on DFS entry; exit[v] on DFS exit; subtree = range [enter[v], exit[v]]
TE22|Heavy-Light Decomposition|partition tree edges into heavy/light chains for O(log n) path queries|path queries and updates on trees|heavy child = child with largest subtree; chain = sequence of heavy edges
TE23|Centroid Decomposition|recursively decompose tree by centroids; O(n log n) levels|counting/optimizing paths in trees|find centroid → remove → recurse on subtrees → centroid tree has O(log n) depth
TE24|Mo's Algorithm|offline answer range queries by reordering to minimize pointer movement|range queries without updates; or with rollback|sort queries by (l/√n, r); maintain current window; extend/contract
TE25|Square Root Decomposition|partition array into √n blocks; precompute per-block answers|range queries with updates; moderate performance|block size ≈ √n; query: iterate blocks O(√n); update: update block O(√n)
TE26|Meet in the Middle|split problem in half, solve each half, combine using sorted merge or hash|exponential problems where 2^(n/2) is feasible|split into halves → enumerate each → merge via sort/hash → O(2^(n/2))

# data_structures(id|name|definition|operations|time_complexity|space|notes)
DS1|Array|contiguous fixed-size block of same-type elements|access, update|access Θ(1); search O(n)|O(n)|cache-friendly; basis for most structures
DS2|Dynamic Array|resizable array; doubles capacity on overflow|access, append, delete|access Θ(1); append amortized Θ(1); insert O(n)|O(n)|amortized via doubling strategy
DS3|Singly Linked List|nodes with value + next pointer|insert_front, delete_front, traverse|insert/delete front Θ(1); search O(n); access O(n)|O(n)|no random access; pointer overhead
DS4|Doubly Linked List|nodes with value + next + prev pointers|insert, delete at known node, traverse both directions|insert/delete at node Θ(1); search O(n)|O(n)|bidirectional traversal; more memory per node
DS5|Stack (LIFO)|collection with push/pop at one end|push, pop, peek|all Θ(1)|O(n)|array-backed or linked-list-backed
DS6|Queue (FIFO)|collection with enqueue at back, dequeue at front|enqueue, dequeue, peek|all Θ(1) amortized|O(n)|circular array or linked-list backed
DS7|Deque|double-ended queue; insert/remove at both ends|push_front, push_back, pop_front, pop_back|all Θ(1) amortized|O(n)|circular buffer implementation
DS8|Binary Heap (min)|complete binary tree; parent ≤ children|insert, extract_min, decrease_key|insert O(log n); extract_min O(log n); build O(n)|O(n)|array-backed; index arithmetic: children at 2i+1, 2i+2
DS9|Binary Heap (max)|complete binary tree; parent ≥ children|insert, extract_max, increase_key|insert O(log n); extract_max O(log n); build O(n)|O(n)|same as min-heap with reversed comparison
DS10|Priority Queue|abstract: supports insert and extract_min/max|insert, extract_min, decrease_key|depends on implementation (heap, Fibonacci heap)|varies|typically backed by binary heap or Fibonacci heap
DS11|Fibonacci Heap|collection of heap-ordered trees; lazy consolidation|insert, extract_min, decrease_key, merge|insert Θ(1); extract_min O(log n) amortized; decrease_key Θ(1) amortized; merge Θ(1)|O(n)|optimal for Dijkstra/Prim; complex implementation
DS12|Hash Table|array of buckets; hash function maps key to index|insert, delete, lookup|avg Θ(1); worst O(n)|O(n)|collision handling: chaining (linked lists) or open addressing (probing)
DS13|Hash Table (open addressing)|single array; collision resolved by probing sequence|insert, delete, lookup|avg Θ(1); worst O(n); load factor α < 1 required|O(n)|linear probing, quadratic probing, double hashing
DS14|Binary Search Tree (BST)|binary tree; left < root < right|insert, delete, search, min, max, successor|avg O(log n); worst O(n) if degenerate|O(n)|unbalanced; worst case is linked list
DS15|AVL Tree|self-balancing BST; height difference ≤ 1 between subtrees|insert, delete, search|all O(log n) worst|O(n)|rotations on insert/delete; stricter balance than red-black
DS16|Red-Black Tree|self-balancing BST; nodes colored red/black satisfying 5 properties|insert, delete, search|all O(log n) worst|O(n)|at most 2 rotations per insert, 3 per delete; height ≤ 2 log₂(n+1)
DS17|B-Tree|balanced multi-way search tree; nodes hold t-1 to 2t-1 keys|insert, delete, search|all O(log n); optimized for disk I/O|O(n)|order t; all leaves at same depth; used in databases and filesystems
DS18|B+ Tree|B-tree variant; all data in leaves; leaves linked|insert, delete, search, range_scan|all O(log n); range scan O(log n + k)|O(n)|leaves form sorted linked list; dominant index structure in databases
DS19|Trie (Prefix Tree)|tree where each edge represents a character; paths = strings|insert, search, prefix_search, delete|O(m) where m = key length|O(ALPHABET × N × m) worst|prefix queries; autocomplete; no hash collisions
DS20|Segment Tree|binary tree over array; each node stores aggregate of range|build, query, update|build O(n); query O(log n); point update O(log n)|O(n)|supports range min/max/sum/gcd; lazy propagation for range updates
DS21|Fenwick Tree (BIT)|implicit binary tree for prefix operations; stored as array|update, prefix_query|both O(log n)|O(n)|simpler/faster than segment tree for prefix sums; uses bit tricks (i & -i)
DS22|Sparse Table|precomputed table for idempotent range queries on static array|build, query|build O(n log n); query O(1)|O(n log n)|range min/max in O(1); no updates; idempotent operations only
DS23|Disjoint Set (Union-Find)|forest of trees representing disjoint sets|find, union|amortized α(n) ≈ Θ(1) per operation with path compression + union by rank|O(n)|α = inverse Ackermann; near-constant
DS24|Graph (Adjacency List)|array of lists; list[u] contains neighbors of u|add_edge, neighbors, iterate|add_edge Θ(1); check_edge O(degree); iterate neighbors O(degree)|O(V+E)|preferred for sparse graphs
DS25|Graph (Adjacency Matrix)|V×V matrix; M[u][v]=1 if edge (u,v)|add_edge, check_edge|add_edge Θ(1); check_edge Θ(1)|O(V²)|preferred for dense graphs; fast edge check
DS26|Skip List|layered linked list with probabilistic balancing|insert, delete, search|avg O(log n); worst O(n)|O(n) expected|randomized; alternative to balanced BST; simpler implementation
DS27|Bloom Filter|bit array with k hash functions; probabilistic set membership|insert, query|both O(k)|O(m) bits|false positives possible; no false negatives; no deletion (standard)
DS28|LRU Cache|hash map + doubly linked list; evicts least recently used|get, put|both Θ(1)|O(capacity)|used in caching, page replacement
DS29|Suffix Array|sorted array of all suffixes of a string|build, search|build O(n log n) or O(n); search O(m log n)|O(n)|space-efficient alternative to suffix tree; used with LCP array
DS30|Suffix Tree|compressed trie of all suffixes|build, search, LCS, LRS|build O(n) (Ukkonen's); search O(m)|O(n) but large constant|linear-time construction; powerful string queries
DS31|Interval Tree|BST augmented with max endpoint; stores intervals|insert, delete, overlap_query|all O(log n + k) where k = overlapping intervals|O(n)|stabbing queries; overlapping interval detection
DS32|KD-Tree|binary tree partitioning k-dimensional space by alternating axes|insert, nearest_neighbor, range_search|avg O(log n); worst O(n) for unbalanced|O(n)|spatial indexing; nearest neighbor in low dimensions
DS33|Persistent Data Structure|preserves previous versions after modification|query any version, update creates new version|O(log n) per update via path copying|O(n log n) total over n updates|functional programming; versioned queries
DS34|Rope|balanced binary tree of strings; leaves hold substrings|concat, split, index|concat O(log n); split O(log n); index O(log n)|O(n)|efficient for large text editing; avoids O(n) concat
DS35|Monotone Stack|stack where elements maintain monotonic order (increasing or decreasing)|push, pop|amortized O(1) per element over n operations|O(n)|next greater element, histogram max rectangle

# algorithms(id|name|family|input|output|time_avg|time_worst|space|stable|in_place|notes)
# Sorting
AL1|Bubble Sort|sort|array of n comparable elements|sorted array|Θ(n²)|Θ(n²)|O(1)|yes|yes|adaptive if optimized with early-exit flag
AL2|Selection Sort|sort|array of n comparable elements|sorted array|Θ(n²)|Θ(n²)|O(1)|no|yes|minimum swaps: exactly n-1
AL3|Insertion Sort|sort|array of n comparable elements|sorted array|Θ(n²)|Θ(n²)|O(1)|yes|yes|adaptive: O(n) on nearly sorted; optimal for small n; used as base case in hybrid sorts
AL4|Merge Sort|sort|array of n comparable elements|sorted array|Θ(n log n)|Θ(n log n)|O(n)|yes|no|divide-and-conquer; guaranteed O(n log n); parallelizable
AL5|Quick Sort|sort|array of n comparable elements|sorted array|Θ(n log n)|Θ(n²)|O(log n) stack|no (typical)|yes|randomized pivot avoids worst case in practice; cache-friendly
AL6|Heap Sort|sort|array of n comparable elements|sorted array|Θ(n log n)|Θ(n log n)|O(1)|no|yes|build heap O(n) + n extract_max O(log n); not adaptive
AL7|Counting Sort|sort|array of n integers in range [0,k]|sorted array|Θ(n+k)|Θ(n+k)|O(n+k)|yes|no|non-comparison; stable; requires known integer range
AL8|Radix Sort|sort|array of n d-digit integers|sorted array|Θ(d(n+k))|Θ(d(n+k))|O(n+k)|yes|no|non-comparison; uses stable sort per digit (typically counting sort)
AL9|Bucket Sort|sort|array of n elements uniformly distributed in [0,1)|sorted array|Θ(n) expected|Θ(n²)|O(n)|yes (depends on sub-sort)|no|distribute into n buckets; sort each; concatenate
AL10|Tim Sort|sort|array of n comparable elements|sorted array|Θ(n log n)|Θ(n log n)|O(n)|yes|no|hybrid merge+insertion; exploits existing runs; Python/Java default
AL11|Introsort|sort|array of n comparable elements|sorted array|Θ(n log n)|Θ(n log n)|O(log n)|no|yes|hybrid quick+heap+insertion; switches to heapsort on deep recursion; C++ std::sort
AL12|Shell Sort|sort|array of n comparable elements|sorted array|depends on gap sequence|O(n^(4/3)) to O(n²)|O(1)|no|yes|generalized insertion sort with decreasing gap sequence
AL13|Block Sort (WikiSort)|sort|array of n comparable elements|sorted array|Θ(n log n)|Θ(n log n)|O(1)|yes|yes|stable in-place merge sort; complex implementation
AL14|pdqsort|sort|array of n comparable elements|sorted array|Θ(n log n)|Θ(n log n)|O(log n)|no|yes|pattern-defeating quicksort; Rust default; handles adversarial inputs

# Searching
AL15|Linear Search|search|array of n elements, target|index or not-found|Θ(n/2)|Θ(n)|O(1)|—|—|no precondition on order
AL16|Binary Search|search|sorted array of n elements, target|index or not-found|Θ(log n)|Θ(log n)|O(1)|—|—|requires sorted input; iterative or recursive
AL17|Interpolation Search|search|sorted uniformly distributed array, target|index or not-found|Θ(log log n)|Θ(n)|O(1)|—|—|probe position estimated from value distribution
AL18|Exponential Search|search|sorted array, target|index or not-found|Θ(log i) where i=target position|Θ(log n)|O(1)|—|—|find range via doubling, then binary search; good for unbounded arrays
AL19|Ternary Search|search|unimodal function over interval [a,b]|maximum or minimum point|Θ(log n)|Θ(log n)|O(1)|—|—|divides interval into thirds; requires unimodal function

# Selection
AL20|Quickselect|selection|array of n elements, rank k|kth smallest element|Θ(n)|Θ(n²)|O(1)|—|yes|randomized partition; expected linear; Hoare's algorithm
AL21|Median of Medians|selection|array of n elements, rank k|kth smallest element|Θ(n)|Θ(n)|O(n)|—|no|deterministic linear; groups of 5; guarantees good pivot; BFPRT algorithm
AL22|Introselect|selection|array of n elements, rank k|kth smallest element|Θ(n)|Θ(n)|O(n)|—|yes|quickselect switching to median-of-medians on bad partitions

# Graph traversal
AL23|Breadth-First Search (BFS)|graph_traversal|graph G=(V,E), source s|BFS tree, distances from s|Θ(V+E)|Θ(V+E)|O(V)|—|—|uses queue; finds shortest path in unweighted graphs; level-order
AL24|Depth-First Search (DFS)|graph_traversal|graph G=(V,E), source s|DFS tree, discovery/finish times|Θ(V+E)|Θ(V+E)|O(V)|—|—|uses stack/recursion; detects cycles; topological sort; SCC
AL25|Iterative Deepening DFS (IDDFS)|graph_traversal|graph G=(V,E), source s|target node or exhaustion|Θ(V+E) for graphs; O(b^d) for trees|O(b^d)|O(d)|—|—|DFS with increasing depth limit; optimal for unweighted; O(bd) space

# Shortest path
AL26|Dijkstra|shortest_path|weighted graph G, source s, non-negative weights|shortest distances from s to all vertices|O((V+E) log V) with binary heap|O((V+E) log V)|O(V)|—|—|greedy relaxation; fails on negative edges; O(V²) with array, O((V+E) log V) with binary heap, O(V log V + E) with Fibonacci heap
AL27|Bellman-Ford|shortest_path|weighted graph G, source s, may have negative weights|shortest distances or negative cycle detection|Θ(VE)|Θ(VE)|O(V)|—|—|relax all edges V-1 times; detects negative cycles on Vth pass
AL28|Floyd-Warshall|shortest_path|weighted graph G, all pairs|V×V distance matrix|Θ(V³)|Θ(V³)|O(V²)|—|—|dynamic programming over intermediate vertices; handles negative edges (no negative cycles)
AL29|Johnson's Algorithm|shortest_path|weighted graph G, all pairs, may have negative weights|V×V distance matrix|O(V² log V + VE)|O(V² log V + VE)|O(V²)|—|—|reweight with Bellman-Ford to eliminate negatives, then V × Dijkstra
AL30|A* Search|shortest_path|weighted graph G, source s, target t, heuristic h|shortest s-t path|depends on heuristic; O(E) optimal for consistent h|O(b^d) worst with inconsistent h|O(V)|—|—|Dijkstra + admissible heuristic h(n)≤actual; f(n)=g(n)+h(n)
AL31|DAG Shortest Path|shortest_path|weighted DAG, source s|shortest distances from s|Θ(V+E)|Θ(V+E)|O(V)|—|—|topological sort then relax in order; handles negative weights on DAGs

# Minimum spanning tree
AL32|Kruskal|MST|weighted undirected graph G|minimum spanning tree|O(E log E)|O(E log E)|O(V)|—|—|sort edges; add if no cycle (union-find); greedy
AL33|Prim|MST|weighted undirected graph G|minimum spanning tree|O((V+E) log V) with binary heap|O((V+E) log V)|O(V)|—|—|grow tree from source; add lightest crossing edge; O(V²) with array, O(E + V log V) with Fibonacci heap
AL34|Borůvka|MST|weighted undirected graph G|minimum spanning tree|O(E log V)|O(E log V)|O(V+E)|—|—|each component finds lightest outgoing edge; merge; O(log V) phases

# Graph algorithms (other)
AL35|Topological Sort (Kahn)|graph|DAG|linear order of vertices|Θ(V+E)|Θ(V+E)|O(V)|—|—|BFS-based; repeatedly remove zero in-degree vertices
AL36|Topological Sort (DFS)|graph|DAG|linear order of vertices|Θ(V+E)|Θ(V+E)|O(V)|—|—|DFS post-order reverse
AL37|Kosaraju (SCC)|graph|directed graph G|set of strongly connected components|Θ(V+E)|Θ(V+E)|O(V)|—|—|two DFS passes: first on G, second on G^T in reverse finish order
AL38|Tarjan (SCC)|graph|directed graph G|set of strongly connected components|Θ(V+E)|Θ(V+E)|O(V)|—|—|single DFS with low-link values; stack-based
AL39|Articulation Points/Bridges|graph|undirected graph G|set of cut vertices and bridges|Θ(V+E)|Θ(V+E)|O(V)|—|—|DFS with discovery time and low values
AL40|Ford-Fulkerson|network_flow|flow network G, source s, sink t|maximum flow value and flow assignment|O(E × max_flow)|O(E × max_flow)|O(V+E)|—|—|augmenting path method; terminates for integer capacities; depends on path selection
AL41|Edmonds-Karp|network_flow|flow network G, source s, sink t|maximum flow|O(VE²)|O(VE²)|O(V+E)|—|—|Ford-Fulkerson with BFS for shortest augmenting path
AL42|Dinic's Algorithm|network_flow|flow network G, source s, sink t|maximum flow|O(V²E)|O(V²E)|O(V+E)|—|—|layered graph + blocking flow; O(E√V) for unit-capacity
AL43|Hungarian Algorithm|matching|bipartite graph with edge weights|minimum-cost perfect matching|O(V³)|O(V³)|O(V²)|—|—|augmenting paths with potentials; assignment problem
AL44|Hopcroft-Karp|matching|bipartite graph|maximum cardinality matching|O(E√V)|O(E√V)|O(V)|—|—|BFS layering + DFS augmentation in phases

# Dynamic programming examples
AL45|Fibonacci (DP)|dynamic_programming|integer n|F(n) = F(n-1) + F(n-2)|Θ(n)|Θ(n)|O(1) iterative or O(n) table|—|—|bottom-up avoids exponential recursion
AL46|Longest Common Subsequence|dynamic_programming|strings X[1..m], Y[1..n]|length of LCS and optionally the subsequence|Θ(mn)|Θ(mn)|O(mn) or O(min(m,n)) space-optimized|—|—|dp[i][j] = dp[i-1][j-1]+1 if match, else max(dp[i-1][j], dp[i][j-1])
AL47|Edit Distance (Levenshtein)|dynamic_programming|strings X[1..m], Y[1..n]|minimum insertions, deletions, substitutions|Θ(mn)|Θ(mn)|O(mn) or O(min(m,n))|—|—|dp[i][j] = min(dp[i-1][j]+1, dp[i][j-1]+1, dp[i-1][j-1]+cost)
AL48|0/1 Knapsack|dynamic_programming|n items with weights w[i] and values v[i], capacity W|maximum total value fitting in capacity|Θ(nW)|Θ(nW)|O(nW)|—|—|pseudo-polynomial; dp[i][w] = max(dp[i-1][w], dp[i-1][w-w[i]]+v[i])
AL49|Longest Increasing Subsequence|dynamic_programming|sequence A[1..n]|length of LIS|Θ(n log n) with patience sorting|Θ(n log n)|O(n)|—|—|maintain tails array; binary search for insertion point
AL50|Matrix Chain Multiplication|dynamic_programming|sequence of matrix dimensions p[0..n]|minimum scalar multiplications for product|Θ(n³)|Θ(n³)|O(n²)|—|—|dp[i][j] = min over k of dp[i][k]+dp[k+1][j]+p[i-1]p[k]p[j]
AL51|Subset Sum|dynamic_programming|set of n integers, target sum S|boolean: does subset summing to S exist|Θ(nS)|Θ(nS)|O(nS) or O(S)|—|—|pseudo-polynomial; NP-complete in general
AL52|Coin Change|dynamic_programming|denominations d[1..k], target amount n|minimum coins to make n (or number of ways)|Θ(kn)|Θ(kn)|O(n)|—|—|dp[i] = min over j of dp[i-d[j]]+1
AL53|Shortest Path in DAG (DP)|dynamic_programming|weighted DAG, source s|shortest distances|Θ(V+E)|Θ(V+E)|O(V)|—|—|topological order then relax; equivalent to AL31

# Greedy examples
AL54|Activity Selection|greedy|set of activities with start/finish times|maximum non-overlapping activities|Θ(n log n)|Θ(n log n)|O(1) beyond sort|—|—|sort by finish time; greedily select earliest-finishing compatible
AL55|Huffman Coding|greedy|alphabet with frequencies|optimal prefix-free binary code|Θ(n log n)|Θ(n log n)|O(n)|—|—|priority queue; merge two lowest-frequency nodes; builds tree bottom-up
AL56|Fractional Knapsack|greedy|n items with weights/values, capacity W|maximum value with fractional items allowed|Θ(n log n)|Θ(n log n)|O(1) beyond sort|—|—|sort by value/weight ratio; take greedily
AL57|Interval Scheduling Maximization|greedy|set of intervals|maximum non-overlapping intervals|Θ(n log n)|Θ(n log n)|O(1)|—|—|equivalent to activity selection; sort by end time

# String algorithms
AL58|Naive String Matching|string|text T[1..n], pattern P[1..m]|all positions where P occurs in T|O(nm)|O(nm)|O(1)|—|—|slide pattern over text; check each position
AL59|KMP (Knuth-Morris-Pratt)|string|text T[1..n], pattern P[1..m]|all occurrences of P in T|Θ(n+m)|Θ(n+m)|O(m)|—|—|precompute prefix function π; never backtrack in text
AL60|Rabin-Karp|string|text T[1..n], pattern P[1..m]|all occurrences of P in T|Θ(n+m) expected|Θ(nm)|O(1)|—|—|rolling hash; hash comparison then character verification on match
AL61|Boyer-Moore|string|text T[1..n], pattern P[1..m]|all occurrences of P in T|sublinear average|O(nm)|O(m+ALPHABET)|—|—|bad character + good suffix heuristics; scans pattern right-to-left
AL62|Aho-Corasick|string|text T[1..n], set of patterns P₁..Pₖ total length m|all occurrences of all patterns|Θ(n+m+z) where z=output count|Θ(n+m+z)|O(m)|—|—|trie + failure links; multi-pattern generalization of KMP
AL63|Z-Algorithm|string|string S[1..n]|Z-array: Z[i] = length of longest substring starting at i matching prefix of S|Θ(n)|Θ(n)|O(n)|—|—|linear-time; alternative to KMP for pattern matching via concatenation P$T
AL64|Manacher's Algorithm|string|string S[1..n]|longest palindromic substring|Θ(n)|Θ(n)|O(n)|—|—|linear-time palindrome detection; tracks palindrome radii
AL65|Suffix Array Construction|string|string S[1..n]|sorted array of suffix indices|O(n) to O(n log² n)|O(n log² n) typical|O(n)|—|—|SA-IS achieves O(n); used with LCP array for substring queries

# Computational geometry
AL66|Graham Scan|geometry|set of n 2D points|convex hull vertices in order|Θ(n log n)|Θ(n log n)|O(n)|—|—|sort by polar angle; maintain hull with stack; left-turn test
AL67|Andrew's Monotone Chain|geometry|set of n 2D points|convex hull vertices in order|Θ(n log n)|Θ(n log n)|O(n)|—|—|sort by x; build upper and lower hulls separately
AL68|Closest Pair|geometry|set of n 2D points|pair with minimum Euclidean distance|Θ(n log n)|Θ(n log n)|O(n)|—|—|divide-and-conquer; split by x-median; merge step checks strip
AL69|Line Sweep Intersection|geometry|set of n line segments|all intersection points|O((n+k) log n) where k=intersections|O((n+k) log n)|O(n)|—|—|sweep line with event queue and active segment tree
AL70|Fortune's Algorithm|geometry|set of n 2D points|Voronoi diagram|Θ(n log n)|Θ(n log n)|O(n)|—|—|sweep line; beach line maintained as balanced tree; produces dual Delaunay triangulation

# Numerical
AL71|Euclidean Algorithm (GCD)|numerical|integers a, b|gcd(a,b)|O(log(min(a,b)))|O(log(min(a,b)))|O(1)|—|—|gcd(a,b) = gcd(b, a mod b); base: gcd(a,0)=a
AL72|Extended Euclidean|numerical|integers a, b|gcd(a,b) and coefficients x,y where ax+by=gcd(a,b)|O(log(min(a,b)))|O(log(min(a,b)))|O(1)|—|—|used for modular inverse: a⁻¹ mod m when gcd(a,m)=1
AL73|Sieve of Eratosthenes|numerical|integer n|all primes ≤ n|Θ(n log log n)|Θ(n log log n)|O(n)|—|—|mark multiples starting from 2; remaining unmarked are prime
AL74|Fast Exponentiation|numerical|base b, exponent e, modulus m|b^e mod m|Θ(log e)|Θ(log e)|O(1)|—|—|square-and-multiply; binary representation of exponent
AL75|Miller-Rabin Primality Test|numerical|integer n, witnesses k|probably prime or composite|O(k log² n)|O(k log² n)|O(1)|—|—|probabilistic; deterministic for n < 3.317×10¹⁴ with specific witnesses
AL76|Strassen Matrix Multiplication|numerical|two n×n matrices|product matrix|Θ(n^2.807)|Θ(n^2.807)|O(n²)|—|—|7 multiplications of n/2 × n/2 submatrices; crossover to naive at small n
AL77|FFT (Fast Fourier Transform)|numerical|polynomial coefficients or signal of length n (power of 2)|point-value representation or frequency domain|Θ(n log n)|Θ(n log n)|O(n)|—|—|divide-and-conquer on even/odd indices; used for polynomial multiplication, convolution
AL78|Newton's Method|numerical|differentiable function f, initial guess x₀|root of f(x)=0|quadratic convergence near root|may diverge|O(1)|—|—|x_{n+1} = x_n - f(x_n)/f'(x_n); requires good initial guess
AL79|Gaussian Elimination|numerical|m×n matrix A, vector b|solution to Ax=b or row echelon form|Θ(n³) for n×n|Θ(n³)|O(n²)|—|—|forward elimination + back substitution; partial pivoting for numerical stability

# Randomized
AL80|Reservoir Sampling|randomized|stream of n elements, sample size k|uniform random sample of k elements|Θ(n)|Θ(n)|O(k)|—|—|each element i replaces random element in reservoir with probability k/i
AL81|Fisher-Yates Shuffle|randomized|array of n elements|uniformly random permutation|Θ(n)|Θ(n)|O(1)|—|yes|swap each element with random element from remaining

# problem_classes(id|name|definition|canonical_problems|solved_by)
PC1|Sorting|arrange elements in specified order|comparison sort, integer sort, external sort|AL1-AL14
PC2|Searching|find element or verify existence in structure|array search, graph search, string search|AL15-AL19,AL23,AL24
PC3|Shortest Path|find minimum-weight path between vertices|single-source, all-pairs, constrained|AL26-AL31
PC4|Minimum Spanning Tree|find minimum-weight connected subgraph spanning all vertices|undirected weighted graph|AL32-AL34
PC5|Maximum Flow|find maximum flow from source to sink respecting capacities|max-flow min-cut|AL40-AL42
PC6|Matching|find maximum or optimal pairing in graph|bipartite matching, weighted matching|AL43,AL44
PC7|String Matching|find occurrences of pattern(s) in text|single-pattern, multi-pattern, regex|AL58-AL65
PC8|Convex Hull|find smallest convex polygon enclosing point set|2D and higher-dimensional|AL66,AL67
PC9|Closest Pair|find two points with minimum distance|2D Euclidean|AL68
PC10|Dynamic Programming Problems|optimization/counting via optimal substructure + overlapping subproblems|knapsack, LCS, edit distance, matrix chain|AL45-AL53
PC11|Satisfiability (SAT)|determine if Boolean formula has satisfying assignment|2-SAT (polynomial), 3-SAT (NP-complete)|backtracking, DPLL, CDCL
PC12|Traveling Salesman (TSP)|find minimum-cost Hamiltonian cycle|symmetric, asymmetric, metric|DP O(2ⁿn²); approximation for metric TSP
PC13|Graph Coloring|assign colors to vertices so no adjacent vertices share color|chromatic number, k-coloring|backtracking; NP-complete for k≥3
PC14|Constraint Satisfaction|assign values to variables satisfying all constraints|scheduling, Sudoku, map coloring|TE4,TE5
PC15|Selection|find kth order statistic|kth smallest, median|AL20-AL22
PC16|Primality Testing|determine if integer is prime|deterministic and probabilistic|AL73,AL75
PC17|Integer Factorization|decompose integer into prime factors|RSA, cryptanalysis|trial division, Pollard's rho, number field sieve; no known polynomial algorithm

# recurrences(id|name|formula|solution|used_by)
RE1|Merge Sort Recurrence|T(n) = 2T(n/2) + Θ(n)|Θ(n log n)|AL4
RE2|Quick Sort Average|T(n) = 2T(n/2) + Θ(n) (balanced partition)|Θ(n log n) expected|AL5
RE3|Quick Sort Worst|T(n) = T(n-1) + Θ(n)|Θ(n²)|AL5
RE4|Binary Search Recurrence|T(n) = T(n/2) + Θ(1)|Θ(log n)|AL16
RE5|Strassen Recurrence|T(n) = 7T(n/2) + Θ(n²)|Θ(n^log₂7) ≈ Θ(n^2.807)|AL76
RE6|Karatsuba Recurrence|T(n) = 3T(n/2) + Θ(n)|Θ(n^log₂3) ≈ Θ(n^1.585)|—
RE7|Master Theorem Case 1|T(n) = aT(n/b) + f(n) where f(n) = O(n^(log_b(a)-ε))|Θ(n^log_b(a))|general case; work dominated by leaves
RE8|Master Theorem Case 2|T(n) = aT(n/b) + f(n) where f(n) = Θ(n^log_b(a))|Θ(n^log_b(a) × log n)|general case; work evenly distributed
RE9|Master Theorem Case 3|T(n) = aT(n/b) + f(n) where f(n) = Ω(n^(log_b(a)+ε)) and regularity|Θ(f(n))|general case; work dominated by root
RE10|Fibonacci Recurrence|F(n) = F(n-1) + F(n-2), F(0)=0, F(1)=1|Θ(φⁿ) naive; Θ(n) DP; Θ(log n) matrix exponentiation|AL45
RE11|Tower of Hanoi|T(n) = 2T(n-1) + 1|Θ(2ⁿ - 1)|—
RE12|Closest Pair Recurrence|T(n) = 2T(n/2) + Θ(n)|Θ(n log n)|AL68
RE13|Linear Selection|T(n) = T(n/5) + T(7n/10) + Θ(n)|Θ(n)|AL21

# distinctions(id|side_a|side_b|key_asymmetry)
DI1|Comparison-Based Sort|Non-Comparison Sort|comparison: Ω(n log n) lower bound; non-comparison (counting, radix): can achieve O(n) but requires integer/key structure
DI2|Stable Sort|Unstable Sort|stable: equal elements maintain input order (merge, insertion, counting); unstable: may reorder equals (quick, heap)
DI3|In-Place Sort|Out-of-Place Sort|in-place: O(1) extra space (heap, insertion, quick); out-of-place: O(n) auxiliary (merge, counting)
DI4|Optimal Algorithm|Sub-Optimal Algorithm|optimal matches problem lower bound; sub-optimal has higher complexity (e.g., bubble sort O(n²) vs merge sort O(n log n) for comparison sort)
DI5|Greedy|Dynamic Programming|greedy: one irrevocable choice per step, requires greedy choice property; DP: explores all subproblems, requires overlapping subproblems
DI6|Top-Down DP|Bottom-Up DP|top-down: recursive + memoization, computes only needed subproblems; bottom-up: iterative, fills entire table, often faster due to no recursion overhead
DI7|BFS|DFS|BFS: queue, level-order, shortest path in unweighted; DFS: stack/recursion, preorder, detects back edges/cycles, uses less memory on sparse
DI8|Directed Graph|Undirected Graph|directed: edges have orientation (u→v); undirected: edges are symmetric (u—v); different algorithms for SCC vs connected components
DI9|Dense Graph|Sparse Graph|dense: E ≈ V²; sparse: E ≈ V; affects choice of adjacency matrix vs list and algorithm constants
DI10|Exact Algorithm|Approximation Algorithm|exact: guaranteed optimal solution, may be exponential; approximation: polynomial time, bounded approximation ratio
DI11|Deterministic|Randomized|deterministic: same output on same input; randomized: uses random bits; Las Vegas always correct, Monte Carlo may err
DI12|Online|Offline|online: processes input incrementally without future knowledge; offline: sees entire input; competitive ratio measures online quality
DI13|Divide and Conquer|Dynamic Programming|D&C: independent subproblems, no overlap; DP: overlapping subproblems cached; D&C recurse then combine; DP builds table
DI14|Adjacency Matrix|Adjacency List|matrix: O(V²) space, O(1) edge check; list: O(V+E) space, O(degree) edge check; matrix for dense, list for sparse
DI15|Amortized|Worst-Case|amortized: average per operation over sequence may be low even if single operation is expensive; worst-case: bound on every individual operation
DI16|Pseudo-Polynomial|Polynomial|pseudo-polynomial: polynomial in numeric value of input (e.g., O(nW) knapsack); polynomial: polynomial in input size (bit length); pseudo-polynomial is exponential in input length for large values

# relationships(from|rel|to)
# Complexity class hierarchy
CX9|contains|CX1,CX2,CX3,CX4,CX5,CX6
CX10|contains|CX9
CX11|specializes|CX10
CX12|generalizes|CX11
CX14|contains|CX10,CX13
CX15|contains|CX14

# Asymptotic notation
CO4|generalizes|CO6
CO5|generalizes|CO6
CO7|specializes|CO4

# Analysis techniques
CO2|measured_by|CO4,CO5,CO6
CO3|measured_by|CO4,CO5,CO6
CO8|specializes|CO2
CO34|determines|CO2
CO35|solves|CO34

# Technique → algorithm family
TE1|implements|AL4,AL5,AL21,AL68,AL76,AL77
TE2|implements|AL45,AL46,AL47,AL48,AL49,AL50,AL51,AL52
TE3|implements|AL32,AL33,AL54,AL55,AL56,AL57
TE4|implements|PC14
TE5|extends|TE4
TE6|implements|AL5,AL20,AL60,AL80,AL81
TE12|implements|AL16,AL17,AL18,AL49
TE14|implements|DS12,DS13,AL60
TE15|enables|DS20,DS21
TE17|implements|DS23

# Technique dependencies
TE2|requires|CO46,CO47
TE3|requires|CO45,CO46
TE1|requires|CO42,CO43,CO44
TE5|extends|TE4
TE7|implements|CO8
TE8|implements|CO24
TE18|implements|CO50

# Data structure relationships
DS2|extends|DS1
DS4|extends|DS3
DS7|extends|DS5,DS6
DS8|implements|DS10
DS9|implements|DS10
DS11|implements|DS10
DS13|specializes|DS12
DS15|specializes|DS14
DS16|specializes|DS14
DS17|generalizes|DS14
DS18|extends|DS17
DS19|specializes|DS14
DS29|implements|DS30
DS22|enables|DS20

# Sorting algorithm relationships
AL3|part_of|AL10,AL11
AL4|requires|DS1
AL5|requires|DS1
AL6|requires|DS8
AL7|requires|AL8
AL10|extends|AL4,AL3
AL11|extends|AL5,AL6,AL3
AL14|extends|AL5,AL6,AL3

# Sort properties
AL1|instance_of|CO17,CO18,CO22
AL2|instance_of|CO18,CO22
AL3|instance_of|CO17,CO18,CO22,CO21
AL4|instance_of|CO17,CO22
AL5|instance_of|CO18,CO22
AL6|instance_of|CO18,CO22
AL7|instance_of|CO17
AL8|instance_of|CO17
AL10|instance_of|CO17,CO21

# Search dependencies
AL16|requires|DS1
AL17|requires|DS1
AL18|requires|DS1,AL16
AL19|requires|CO22

# Graph algorithm requirements
AL23|requires|DS24
AL24|requires|DS24
AL26|requires|DS24,DS10
AL26|prevents|CO50
AL27|requires|DS24
AL28|requires|DS25
AL29|requires|AL27,AL26
AL30|extends|AL26
AL31|requires|TE19
AL32|requires|DS23
AL33|requires|DS10
AL35|requires|DS6
AL37|requires|AL24
AL38|requires|AL24
AL40|requires|CO51,CO52
AL41|extends|AL40
AL41|requires|AL23
AL42|extends|AL40

# DP algorithm dependencies
AL46|instance_of|CO46,CO47
AL47|instance_of|CO46,CO47
AL48|instance_of|CO46,CO47
AL49|instance_of|CO46
AL50|instance_of|CO46,CO47

# String algorithm relationships
AL59|requires|CO63
AL60|requires|TE14
AL61|extends|AL58
AL62|extends|DS19,AL59
AL63|equivalent_to|AL59

# Geometry algorithm relationships
AL66|requires|DS35
AL67|equivalent_to|AL66
AL68|instance_of|TE1
AL69|instance_of|TE9
AL70|instance_of|TE9

# Numerical algorithm relationships
AL72|extends|AL71
AL74|requires|CO51
AL76|instance_of|TE1
AL77|instance_of|TE1

# Problem class → complexity class
PC1|lower_bound|CX17
PC2|lower_bound|CX2
PC3|solved_in|CX9
PC4|solved_in|CX9
PC5|solved_in|CX9
PC6|solved_in|CX9
PC7|solved_in|CX3
PC11|instance_of|CX11
PC12|instance_of|CX12
PC13|instance_of|CX12

# Recurrence → Master Theorem mapping
RE1|instance_of|RE8
RE2|instance_of|RE8
RE4|instance_of|RE7
RE5|instance_of|RE7
RE6|instance_of|RE7
RE12|instance_of|RE8

# Distinction mappings
DI1|distinguishes|AL4,AL7
DI2|distinguishes|AL4,AL5
DI3|distinguishes|AL5,AL4
DI5|distinguishes|TE3,TE2
DI6|distinguishes|CO32,CO48
DI7|distinguishes|AL23,AL24
DI8|distinguishes|DS24,DS25
DI9|distinguishes|DS25,DS24
DI10|distinguishes|CX9,CX12
DI11|distinguishes|CO15,CO16
DI13|distinguishes|TE1,TE2
DI14|distinguishes|DS25,DS24
DI16|distinguishes|AL48,CX9

# Cross-domain links
AL26|prevents|AL27
CO23|constrains|AL1,AL2,AL3,AL4,AL5,AL6
CO28|characterizes|PC12
CO29|characterizes|CO19

# decode_legend
# id_prefixes: CO=concept, CX=complexity_class, AL=algorithm, DS=data_structure, TE=technique, PC=problem_class, RE=recurrence, DI=distinction
# rel_types: contains|specializes|generalizes|extends|implements|requires|enables|prevents|constrains|equivalent_to|instance_of|part_of|determines|solves|solved_in|lower_bound|characterizes|measured_by|distinguishes|anti_pattern_of
# notation: fk references use raw ID; comma-separated targets expand to individual Prolog rules; time/space use standard asymptotic notation (O, Θ, Ω)
# stable: yes=equal elements preserve input order; no=may reorder; —=not applicable
# in_place: yes=O(1) extra space; no=requires auxiliary space; —=not applicable
# confidence: synthetic domain knowledge — not extracted from a single source document

# relation_mapping(doc_rel|canonical_rel|notes)
contains|contains|exact match
specializes|specializes|exact match
generalizes|generalizes|exact match
extends|extends|exact match
implements|implements|exact match
requires|requires|exact match
enables|enables|exact match
prevents|prevents|exact match
equivalent_to|equivalent_to|exact match
instance_of|instance_of|exact match
part_of|part_of|exact match
distinguishes|distinguishes|exact match
constrains|constrains|exact match
measured_by|measured_by|no canon match — see below
determines|determined_by|reverse query direction; swap from/to
solves|solves|exact match
solved_in|solves|reverse query direction; "X solved_in Y" → "Y solves X"
lower_bound|bounded_by|"X lower_bound Y" → "Y bounded_by X"
characterizes|characterizes|no canon match — see below
anti_pattern_of|anti_pattern_of|exact match
