# PROGRAMMING DATA STRUCTURES — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: concepts → structures → fields → operations → variants → failure_modes → complexity_bounds → distinctions → relationships → decode_legend

# concepts(id|name|definition|category)
CO1|Data Structure|organized collection of data supporting specific operations with defined complexity guarantees|foundation
CO2|Abstract Data Type (ADT)|mathematical model defining operations and behavior independent of implementation|foundation
CO3|Concrete Data Structure|specific implementation of an ADT with defined memory layout and complexity|foundation
CO4|Invariant|property that must hold before and after every operation on the structure|correctness
CO5|Amortized Cost|average cost per operation over worst-case sequence; expensive operations paid for by cheap ones|analysis
CO6|Load Factor|ratio of occupied slots to total capacity; α = n/m; governs hash table performance|hashing
CO7|Hash Function|maps keys to integers in range [0,m); must be deterministic; good distribution minimizes collisions|hashing
CO8|Collision|two distinct keys map to same hash bucket or slot|hashing
CO9|Probe Sequence|ordered sequence of slots examined during open addressing collision resolution|hashing
CO10|Rehashing|allocating larger table and reinserting all elements when load factor exceeds threshold|hashing
CO11|Rotation (tree)|local restructuring operation preserving BST invariant; left or right; O(1)|trees
CO12|Balancing|maintaining tree height within O(log n) bound via rotations, splits, or merges|trees
CO13|Augmentation|storing additional data in tree nodes to support extended queries (rank, interval, sum)|trees
CO14|Sentinel Node|dummy node simplifying boundary conditions; e.g., NIL in red-black trees, head/tail in linked lists|implementation
CO15|Cache Locality|property of accessing memory in patterns that exploit CPU cache lines; contiguous > pointer-chasing|performance
CO16|Memory Overhead|extra bytes per element beyond payload; pointers, metadata, padding, alignment|performance
CO17|Pointer Chasing|following chain of memory-indirect references; cache-unfriendly access pattern|performance
CO18|Fragmentation|wasted memory from non-contiguous allocation or internal padding|performance
CO19|Tombstone|marker in open-addressing hash table indicating deleted slot; allows probe continuation|hashing
CO20|Perfect Hashing|hash function with zero collisions for a known static key set; O(1) worst-case lookup|hashing
CO21|Consistent Hashing|hash ring minimizing key remapping when nodes added/removed; used in distributed systems|hashing
CO22|Bloom Filter False Positive Rate|≈(1 - e^(-kn/m))^k where k=hash functions, n=elements, m=bits|probabilistic
CO23|Node|atomic unit of pointer-based structures; contains payload + link(s) to other nodes|foundation
CO24|Edge|connection between nodes in a graph; may be directed, weighted, or labeled|foundation
CO25|Degree|number of edges incident to a node; in-degree and out-degree for directed graphs|graph
CO26|Root|designated entry node of a tree; no parent|trees
CO27|Leaf|tree node with no children|trees
CO28|Height|longest path from node to a leaf; tree height = root height|trees
CO29|Depth|path length from root to node; root depth = 0|trees
CO30|Subtree|tree rooted at any node, containing all descendants|trees
CO31|Complete Binary Tree|all levels full except possibly last, which is filled left to right|trees
CO32|Full Binary Tree|every node has 0 or 2 children|trees
CO33|Perfect Binary Tree|all internal nodes have 2 children; all leaves at same depth; n = 2^(h+1) - 1|trees
CO34|Degenerate Tree|tree where each node has at most one child; equivalent to linked list; height = n-1|trees
CO35|Self-Balancing|tree automatically maintains O(log n) height after insert/delete via rebalancing operations|trees
CO36|Order Statistic|kth smallest element in a collection; rank queries|trees
CO37|Predecessor/Successor|next smaller/larger element in ordered structure|trees
CO38|Range Query|query returning all elements or aggregate over interval [lo, hi]|query
CO39|Point Update|modify single element; propagate changes through structure|query
CO40|Lazy Propagation|defer range updates in segment tree; apply on access; amortizes update cost|query
CO41|Persistence|preserving all previous versions of structure after modification; path copying|property
CO42|Functional Update|create new version sharing unchanged nodes with old version; O(log n) per update typically|property
CO43|Fat Node|persistence method: each node stores all versions of its fields|property
CO44|Path Copying|persistence method: copy only nodes on root-to-modified-node path; share rest|property
CO45|Adjacency|two vertices connected by an edge; stored as neighbor list or matrix entry|graph
CO46|Weight|numeric value associated with an edge; represents cost, distance, capacity|graph
CO47|Capacity|maximum flow through an edge in a flow network|graph
CO48|Bipartite|graph with vertices partitionable into two independent sets|graph
CO49|Planarity|graph embeddable in plane without edge crossings; testable in O(V+E)|graph
CO50|DAG (Directed Acyclic Graph)|directed graph with no cycles; admits topological ordering|graph
CO51|Tree (graph)|connected acyclic undirected graph; V-1 edges; unique path between any two vertices|graph
CO52|Forest|disjoint union of trees; acyclic undirected graph|graph
CO53|Sparse|graph where E = O(V) or E << V²|graph
CO54|Dense|graph where E = Θ(V²)|graph
CO55|Strongly Connected|directed graph where every vertex reachable from every other|graph
CO56|Weakly Connected|directed graph connected when edge directions ignored|graph
CO57|Cycle|path from vertex back to itself with no repeated edges|graph
CO58|Back Edge|edge to ancestor in DFS tree; existence implies cycle|graph
CO59|Topological Order|linear ordering where u before v for every directed edge (u,v); exists iff DAG|graph
CO60|Minimum Cut|partition of vertices minimizing total crossing edge weight; equals max flow (MFMC theorem)|graph
CO61|Residual Capacity|remaining capacity on edge after current flow assignment|graph

# structures(id|name|definition|category|invariants|memory_layout)
ST1|Static Array|fixed-size contiguous block of same-type elements; size known at compile time|linear|length fixed; elements same type; indices [0,n)|contiguous; element at base + i×sizeof(T); no overhead per element
ST2|Dynamic Array|resizable contiguous array; grows by factor (typically 2×) on overflow|linear|size ≤ capacity; elements contiguous; capacity ≥ size|contiguous buffer + size + capacity fields; wasted space = capacity - size
ST3|Singly Linked List|chain of nodes; each node has value + pointer to next; last points to null|linear|each node has exactly one next pointer; last.next = null|nodes heap-allocated; non-contiguous; overhead = 1 pointer per node
ST4|Doubly Linked List|chain of nodes; each node has value + prev + next pointers|linear|head.prev = null; tail.next = null; node.next.prev = node|nodes heap-allocated; non-contiguous; overhead = 2 pointers per node
ST5|Circular Buffer|fixed-size array with wrap-around read/write indices|linear|head and tail indices mod capacity; size = (tail - head) mod capacity|contiguous array + head + tail + capacity; no per-element overhead
ST6|Stack (Array-backed)|LIFO via dynamic array; push/pop at end|linear|top index tracks next empty slot; 0 ≤ top ≤ capacity|contiguous array + top index
ST7|Stack (Linked)|LIFO via singly linked list; push/pop at head|linear|top pointer = head of list; empty when top = null|nodes heap-allocated; overhead = 1 pointer per node
ST8|Queue (Array-backed)|FIFO via circular buffer|linear|head = front; tail = back; empty when head = tail|contiguous array + head + tail indices
ST9|Queue (Linked)|FIFO via singly linked list with tail pointer|linear|enqueue at tail; dequeue at head|nodes heap-allocated; head + tail pointers
ST10|Deque (Array-backed)|double-ended queue via circular buffer|linear|push/pop at both ends; head and tail wrap around|contiguous array + head + tail + capacity
ST11|Priority Queue|ADT: insert element, extract min (or max)|abstract|min/max accessible in O(1) or O(log n); maintains partial order|implementation-dependent (heap, BST, etc.)
ST12|Binary Heap (min)|complete binary tree stored as array; parent ≤ both children|heap|A[parent(i)] ≤ A[i] for all i; complete: filled left to right|array; parent(i) = (i-1)/2; left(i) = 2i+1; right(i) = 2i+2; no pointer overhead
ST13|Binary Heap (max)|complete binary tree stored as array; parent ≥ both children|heap|A[parent(i)] ≥ A[i] for all i; complete|same as min-heap with reversed comparison
ST14|d-ary Heap|generalized heap with d children per node|heap|parent ≥ (or ≤) all d children; complete d-ary tree|array; parent(i) = (i-1)/d; child_k(i) = d×i+k+1; decreases height to log_d(n)
ST15|Fibonacci Heap|collection of heap-ordered trees with lazy consolidation|heap|min pointer to root with minimum key; no two roots of same degree after consolidation; mark bit for cascading cuts|circular doubly-linked root list + child lists; nodes store degree, mark, parent, child, left, right
ST16|Binomial Heap|collection of binomial trees with distinct orders|heap|each binomial tree Bk has 2^k nodes, height k; at most one tree of each order|linked list of roots; each node stores degree, parent, child, sibling
ST17|Pairing Heap|self-adjusting heap; simple multi-way tree|heap|root is minimum; no structural constraint beyond heap order|multi-way tree; child pointer + sibling pointer; very simple; amortized bounds
ST18|Hash Table (Chaining)|array of buckets; each bucket is a linked list of entries|hash|every key hashes to one bucket; all entries with same hash in same chain|array of m bucket pointers + linked list nodes; overhead = pointer per node + bucket array
ST19|Hash Table (Open Addressing)|single array; collisions resolved by probing|hash|every key occupies one slot; probe sequence deterministic from key; load factor α < 1|contiguous array of m slots; each slot holds key+value or empty/tombstone marker
ST20|Hash Table (Robin Hood)|open addressing variant; on collision, steal slot from richer (closer to home) entry|hash|probe distance variance minimized; entries cluster by probe distance|same as open addressing; each entry also stores probe distance
ST21|Hash Table (Cuckoo)|two (or more) tables with independent hash functions; each key in one of its hash positions|hash|every key stored at h₁(key) or h₂(key); lookup is 2 probes; insert may trigger chain of evictions|two arrays of m/2 slots each; worst-case O(1) lookup
ST22|Hash Table (Swiss Table)|open addressing with SIMD-accelerated metadata; groups of 16 slots with control bytes|hash|control byte per slot: empty/deleted/H2(hash); group probing via SIMD compare|array + control byte array (1 byte per slot overhead); cache-line aligned groups
ST23|Binary Search Tree (BST)|binary tree; left.key < node.key < right.key for all nodes|tree|BST property: in-order traversal yields sorted sequence|nodes with key + left + right + parent pointers; overhead = 3 pointers per node
ST24|AVL Tree|self-balancing BST; height of left and right subtrees differ by at most 1|tree|balance factor bf(n) = height(left) - height(right) ∈ {-1, 0, 1} for all nodes|BST node + balance factor (or height) field; 1 extra byte/int per node
ST25|Red-Black Tree|self-balancing BST with node coloring satisfying 5 properties|tree|1: every node red or black; 2: root is black; 3: leaves (NIL) are black; 4: red node has black children; 5: all root-to-leaf paths have same black-node count|BST node + color bit + NIL sentinel; height ≤ 2 log₂(n+1)
ST26|Splay Tree|self-adjusting BST; accessed node splayed to root via zig/zig-zig/zig-zag rotations|tree|no explicit balance invariant; amortized O(log n) per operation; recently accessed elements near root|standard BST node; no extra fields; no balance metadata
ST27|Treap|BST by key, max-heap by random priority; unique structure for given key-priority pairs|tree|BST invariant on keys; heap invariant on priorities; expected height O(log n)|BST node + random priority field
ST28|B-Tree|balanced multi-way search tree; all leaves at same depth|tree|node holds between ⌈t/2⌉-1 and t-1 keys (root may have fewer); children between ⌈t/2⌉ and t; all leaves same depth; order t (minimum degree)|node holds array of keys + array of child pointers; high branching factor; disk-block-aligned
ST29|B+ Tree|B-tree variant; all data in leaves; internal nodes hold only keys as separators; leaves linked|tree|same as B-tree for internal nodes; leaves form sorted doubly-linked list; all keys appear in leaves|internal: keys + child pointers; leaves: keys + values + next/prev leaf pointers
ST30|Red-Black B-Tree (2-3-4 Tree)|B-tree with order 4; isomorphic to red-black tree|tree|each node has 2, 3, or 4 children; all leaves same depth|equivalent to red-black tree with red nodes merged into parent
ST31|Trie (Prefix Tree)|tree where edges represent characters; path from root = key prefix|tree|no two edges from same node share same character; keys stored implicitly as paths|node per character; children as array (dense) or hash map (sparse); potentially large space
ST32|Compressed Trie (Radix Tree)|trie with single-child chains compressed into single edges with multi-character labels|tree|no node has exactly one child (except possibly root); edges labeled with substrings|fewer nodes than trie; edge labels stored as pointer+length into original strings
ST33|Ternary Search Tree|trie variant; each node has less/equal/greater children; one character per node|tree|left < node.char; middle = node.char (continue to next char); right > node.char|3 pointers per node; more space-efficient than array-based trie
ST34|Suffix Tree|compressed trie of all suffixes of a string; edges labeled with substrings|tree|every internal node (except root) has ≥2 children; leaves represent suffix positions; n leaves for string of length n|O(n) nodes; edges store start+end indices into source string; Ukkonen's builds in O(n)
ST35|Suffix Array|sorted array of all suffix starting indices of a string|array|SA[i] = starting index of ith lexicographically smallest suffix; used with LCP array for substring queries|array of n integers; O(n) space; constructed in O(n) via SA-IS or O(n log n) via prefix doubling
ST36|Segment Tree|binary tree over array; node stores aggregate of range|tree|leaf = single element; internal node = merge of children; height = ⌈log₂ n⌉; supports range query + point/range update|array of 2n or 4n nodes; node stores aggregate value + optional lazy tag
ST37|Segment Tree (Lazy)|segment tree with deferred range updates|tree|lazy tag propagated on query/update; pending updates stored in internal nodes|same as segment tree + lazy tag field per node
ST38|Fenwick Tree (Binary Indexed Tree)|implicit tree for prefix operations; stored as flat array|tree|BIT[i] stores aggregate of elements in range determined by lowest set bit of i; parent(i) = i - (i & -i)|array of n+1 elements; 1-indexed; no explicit tree structure; bit tricks for traversal
ST39|Sparse Table|precomputed table for idempotent range queries on static arrays|table|table[k][i] = aggregate of A[i..i+2^k-1]; query merges two overlapping blocks|O(n log n) space; table[log₂ n + 1][n]; no updates supported
ST40|Disjoint Set (Union-Find)|forest of trees representing disjoint sets; supports union and find|forest|each element points to parent; root is representative; path compression flattens tree; union by rank/size keeps height low|array of n parent pointers + rank/size array; no dynamic allocation
ST41|Skip List|layered sorted linked list; probabilistic balancing; each element promoted with probability p (typically 1/2)|list|level 0 contains all elements; level k contains each element independently with probability p^k; expected O(log n) height|each node has array of forward pointers (one per level); space O(n) expected
ST42|Graph (Adjacency List)|array of linked lists (or dynamic arrays); list[v] contains neighbors of v|graph|undirected: edge (u,v) appears in both list[u] and list[v]; directed: only in list[u]|array of V lists; total space O(V+E); each edge stored once (directed) or twice (undirected)
ST43|Graph (Adjacency Matrix)|V×V matrix; M[u][v] = weight or 1/0|graph|undirected: M symmetric; directed: not necessarily; M[u][v] = 0 or ∞ means no edge|contiguous V×V array; O(V²) space regardless of edge count
ST44|Graph (Edge List)|array of (u,v,w) triples|graph|each edge stored once; no fast neighbor lookup; compact|array of E edge structs; O(E) space; O(E) to find neighbors of v
ST45|Graph (Compressed Sparse Row)|two arrays: offsets[V+1] and edges[E]; offsets[v]..offsets[v+1]-1 indexes neighbors|graph|immutable after construction; extremely cache-friendly iteration; no fast edge insertion|offsets array (V+1 entries) + edges array (E entries) + optional weights array (E entries)
ST46|Interval Tree|BST augmented with max endpoint per subtree; stores intervals [lo, hi]|tree|BST ordered by lo; each node stores max hi in subtree; enables overlap queries|BST node + interval endpoints + max field; typically built on balanced BST
ST47|KD-Tree|binary tree partitioning k-dimensional space by alternating axis splits|tree|depth d splits on axis d mod k; left subtree < split value on axis; right ≥|node stores point + split axis; left/right children; balanced if median split
ST48|R-Tree|balanced tree for spatial indexing; each node holds bounding rectangle covering children|tree|leaf nodes hold spatial objects with MBR; internal nodes hold MBR covering all children; B-tree-like balance|node stores array of (MBR, pointer) entries; disk-oriented; min/max fill constraints
ST49|Bloom Filter|bit array of m bits with k hash functions; probabilistic set membership|probabilistic|insert: set bits h₁(x)..hₖ(x); query: check all k bits; no false negatives; false positive rate ≈ (1-e^(-kn/m))^k|bit array of m bits + k hash functions; no per-element storage; cannot enumerate or delete
ST50|Counting Bloom Filter|Bloom filter with counters instead of bits; supports deletion|probabilistic|each slot is counter (typically 4 bits); increment on insert, decrement on delete; overflow possible|array of m counters; 4m bits typical; supports delete unlike standard Bloom
ST51|Cuckoo Filter|array of buckets with fingerprints; supports insert, lookup, delete|probabilistic|each key stored as fingerprint in one of two candidate buckets; false positive from fingerprint collision|array of buckets; each bucket holds b fingerprints; typically 4 entries per bucket; ~12 bits per element
ST52|Count-Min Sketch|matrix of d×w counters with d hash functions; approximate frequency estimation|probabilistic|increment row[i][h_i(x)] on insert; query = min over rows; overestimates by at most ε with probability 1-δ; w = ⌈e/ε⌉, d = ⌈ln(1/δ)⌉|d×w counter matrix; O(d×w) space independent of n
ST53|HyperLogLog|probabilistic cardinality estimator using m registers storing max leading zeros|probabilistic|register[h(x) mod m] = max(register[j], leading_zeros(h(x)/m)); cardinality ≈ α_m × m² / Σ2^(-register[j]); standard error ≈ 1.04/√m|m registers of ~5-6 bits each; 1.5KB for m=2048 (~2% error)
ST54|LRU Cache|hash map + doubly linked list; most recently accessed at front; evict from tail|cache|capacity fixed; get promotes to front; put evicts LRU if full; O(1) get/put|hash map (key → node pointer) + doubly linked list of (key, value) nodes
ST55|LFU Cache|track access frequency; evict least frequently used; break ties by recency|cache|maintain frequency buckets; increment frequency on access; evict minimum frequency, oldest|hash map + frequency → doubly linked list mapping; O(1) with careful bookkeeping
ST56|Rope|balanced binary tree of strings; leaves hold substrings|text|concat and split in O(log n); index in O(log n); leaves store short strings; rebalance on depth threshold|binary tree nodes with length fields; leaves hold character arrays; concatenation = new root
ST57|Piece Table|original buffer + append-only add buffer + table of (buffer, start, length) pieces|text|all edits are appends to add buffer + piece table updates; original buffer never modified|two buffers (read-only original + append-only add) + array/tree of piece descriptors
ST58|Gap Buffer|array with gap at cursor position; insertions fill gap; gap moves on cursor movement|text|insertions at cursor O(1) amortized; cursor movement copies elements across gap|single array with gap_start + gap_end indices; gap size = capacity - size
ST59|Persistent BST|BST with path copying on modification; all versions accessible|persistent|each update creates O(log n) new nodes; shares O(n - log n) nodes with previous version|nodes immutable; new root per version; versions form a DAG
ST60|Persistent Array (Bitmapped Vector Trie)|tree with branching factor 32; each leaf holds 32-element array; path copying on update|persistent|branching factor 32 (5-bit chunks of index); depth ≤ 7 for 32-bit indices; O(log₃₂ n) access|internal nodes: 32-element pointer arrays; leaves: 32-element value arrays; Clojure/Scala immutable vectors
ST61|Monotone Stack|stack maintaining elements in monotonic (increasing or decreasing) order|specialized|push: pop all elements violating monotonicity before inserting; total work across n operations = O(n)|array-backed stack; no extra metadata
ST62|Monotone Queue (Deque)|deque maintaining elements in monotonic order; supports sliding window min/max|specialized|elements popped from back when new element violates monotonicity; front holds current min/max; each element enqueued/dequeued at most once|deque of (value, index) pairs

# fields(id|structure_fk|name|type|role)
FL1|ST2|buffer|pointer to T|contiguous storage for elements
FL2|ST2|size|integer|current number of elements
FL3|ST2|capacity|integer|allocated slots; size ≤ capacity
FL4|ST5|data|array of T|circular storage
FL5|ST5|head|integer|read index
FL6|ST5|tail|integer|write index
FL7|ST5|capacity|integer|maximum elements + 1
FL8|ST12|array|array of T|implicit complete binary tree
FL9|ST12|size|integer|number of elements
FL10|ST18|buckets|array of pointers|array of m bucket list heads
FL11|ST18|count|integer|number of stored elements
FL12|ST18|load_factor|float|n/m; rehash threshold typically 0.75
FL13|ST19|slots|array of (key,value,state)|contiguous probing array
FL14|ST19|count|integer|stored elements
FL15|ST19|tombstone_count|integer|deleted slots; affects probe length
FL16|ST23|key|T|stored value for comparison
FL17|ST23|left|pointer|left child (keys < this)
FL18|ST23|right|pointer|right child (keys > this)
FL19|ST23|parent|pointer|parent node (optional; simplifies some operations)
FL20|ST24|balance_factor|integer (-1,0,1)|height(left) - height(right)
FL21|ST25|color|bit (red/black)|red-black balance invariant
FL22|ST25|nil_sentinel|node|shared black leaf node replacing all null children
FL23|ST27|priority|integer|random value; heap ordered
FL24|ST28|keys|array of T|sorted keys within node; ⌈t/2⌉-1 to t-1 keys
FL25|ST28|children|array of pointers|child pointers; one more than keys count
FL26|ST28|n|integer|current number of keys
FL27|ST28|leaf|boolean|true if leaf node
FL28|ST29|next_leaf|pointer|link to next leaf in sequence
FL29|ST29|prev_leaf|pointer|link to previous leaf
FL30|ST36|value|aggregate type|stored aggregate for this node's range
FL31|ST36|lazy|aggregate type|pending update not yet propagated
FL32|ST36|left_bound|integer|left endpoint of range
FL33|ST36|right_bound|integer|right endpoint of range
FL34|ST38|tree|array of integer|BIT[i] stores partial aggregate; indexed from 1
FL35|ST40|parent|array of integer|parent[i] = parent of i; root has parent[i] = i
FL36|ST40|rank|array of integer|upper bound on height of subtree
FL37|ST41|forward|array of pointers|forward[level] = next node at that level
FL38|ST41|level|integer|number of levels this node participates in
FL39|ST46|interval|pair (lo, hi)|stored interval endpoints
FL40|ST46|max|value|maximum hi in entire subtree
FL41|ST49|bits|bit array|m-bit array; 1 = possibly present
FL42|ST49|hash_functions|array of functions|k independent hash functions
FL43|ST52|counters|2D array of integers|d rows × w columns of counters
FL44|ST54|map|hash map|key → node pointer for O(1) lookup
FL45|ST54|list|doubly linked list|ordered by access recency
FL46|ST54|capacity|integer|maximum entries before eviction
FL47|ST56|left|pointer|left subtree
FL48|ST56|right|pointer|right subtree
FL49|ST56|weight|integer|total character count in subtree
FL50|ST57|original|buffer|immutable original text
FL51|ST57|add|buffer|append-only new text
FL52|ST57|pieces|table/tree|ordered descriptors (which_buffer, start, length)
FL53|ST58|buffer|array of char|text storage with gap
FL54|ST58|gap_start|integer|beginning of gap
FL55|ST58|gap_end|integer|end of gap
FL56|ST15|min|pointer|pointer to root with minimum key
FL57|ST15|roots|circular doubly-linked list|list of heap-ordered trees
FL58|ST15|n|integer|total number of nodes
FL59|ST15|degree|integer per node|number of children
FL60|ST15|mark|boolean per node|whether node has lost a child since becoming a child itself

# operations(id|structure_fk|name|time_avg|time_worst|time_amortized|notes)
# Static Array
OP1|ST1|access|Θ(1)|Θ(1)|—|base + i × sizeof(T)
OP2|ST1|search|O(n)|O(n)|—|linear scan; O(log n) if sorted via binary search
OP3|ST1|update|Θ(1)|Θ(1)|—|direct index write

# Dynamic Array
OP4|ST2|access|Θ(1)|Θ(1)|—|same as static array
OP5|ST2|append|Θ(1)|Θ(n)|Θ(1)|worst case triggers reallocation and copy; amortized via doubling
OP6|ST2|insert_at(i)|O(n)|O(n)|—|shift elements right from index i
OP7|ST2|delete_at(i)|O(n)|O(n)|—|shift elements left to fill gap
OP8|ST2|search|O(n)|O(n)|—|linear scan
OP9|ST2|pop_back|Θ(1)|Θ(1)|—|decrement size; may shrink if size << capacity

# Singly Linked List
OP10|ST3|insert_front|Θ(1)|Θ(1)|—|allocate node; point to old head
OP11|ST3|delete_front|Θ(1)|Θ(1)|—|advance head; free old node
OP12|ST3|insert_after(node)|Θ(1)|Θ(1)|—|requires pointer to predecessor
OP13|ST3|search|O(n)|O(n)|—|traverse from head
OP14|ST3|access(i)|O(n)|O(n)|—|traverse i nodes from head

# Doubly Linked List
OP15|ST4|insert_front|Θ(1)|Θ(1)|—|update head + old head's prev
OP16|ST4|insert_back|Θ(1)|Θ(1)|—|update tail + old tail's next
OP17|ST4|delete(node)|Θ(1)|Θ(1)|—|unlink node via prev/next; requires pointer to node
OP18|ST4|search|O(n)|O(n)|—|traverse from head or tail

# Stack
OP19|ST6|push|Θ(1)|Θ(n)|Θ(1)|array-backed; worst triggers resize
OP20|ST6|pop|Θ(1)|Θ(1)|—|decrement top
OP21|ST6|peek|Θ(1)|Θ(1)|—|read top element

# Queue
OP22|ST8|enqueue|Θ(1)|Θ(1)|—|circular buffer; advance tail mod capacity
OP23|ST8|dequeue|Θ(1)|Θ(1)|—|advance head mod capacity
OP24|ST8|peek|Θ(1)|Θ(1)|—|read head element

# Binary Heap (min)
OP25|ST12|insert|O(log n)|O(log n)|—|append to end; sift up (swim)
OP26|ST12|extract_min|O(log n)|O(log n)|—|swap root with last; remove last; sift down (sink)
OP27|ST12|peek_min|Θ(1)|Θ(1)|—|read root
OP28|ST12|decrease_key|O(log n)|O(log n)|—|decrease value; sift up
OP29|ST12|build_heap|Θ(n)|Θ(n)|—|Floyd's algorithm: sift down from n/2 to 0; tighter than n × O(log n)
OP30|ST12|delete|O(log n)|O(log n)|—|decrease to -∞; extract_min

# Fibonacci Heap
OP31|ST15|insert|Θ(1)|Θ(1)|—|add new tree to root list; update min if needed
OP32|ST15|find_min|Θ(1)|Θ(1)|—|return min pointer
OP33|ST15|extract_min|O(log n)|O(n)|O(log n)|remove min; merge children into root list; consolidate trees by degree
OP34|ST15|decrease_key|Θ(1)|O(log n)|Θ(1)|cut node from parent; add to root list; cascading cut if parent marked
OP35|ST15|merge|Θ(1)|Θ(1)|—|concatenate root lists; update min
OP36|ST15|delete|O(log n)|O(n)|O(log n)|decrease_key to -∞; extract_min

# Hash Table (Chaining)
OP37|ST18|insert|Θ(1)|O(n)|—|hash key; prepend to bucket; O(n) if all keys in one bucket
OP38|ST18|search|Θ(1)|O(n)|—|hash key; traverse chain; expected chain length = α = n/m
OP39|ST18|delete|Θ(1)|O(n)|—|search + unlink from chain
OP40|ST18|rehash|Θ(n)|Θ(n)|—|allocate new table; reinsert all elements; triggered when α exceeds threshold

# Hash Table (Open Addressing)
OP41|ST19|insert|Θ(1/(1-α))|O(n)|—|probe until empty slot; performance degrades as α → 1
OP42|ST19|search|Θ(1/(1-α))|O(n)|—|probe until found or empty (not tombstone)
OP43|ST19|delete|Θ(1/(1-α))|O(n)|—|mark as tombstone; or shift elements (Robin Hood)

# Binary Search Tree
OP44|ST23|insert|O(log n)|O(n)|—|worst case on degenerate tree (sorted input)
OP45|ST23|search|O(log n)|O(n)|—|follow left/right based on comparison
OP46|ST23|delete|O(log n)|O(n)|—|3 cases: leaf, one child, two children (swap with successor)
OP47|ST23|min|O(log n)|O(n)|—|follow left pointers to leftmost node
OP48|ST23|max|O(log n)|O(n)|—|follow right pointers to rightmost node
OP49|ST23|in_order|Θ(n)|Θ(n)|—|yields elements in sorted order
OP50|ST23|successor|O(log n)|O(n)|—|right subtree min; or first left-ancestor

# AVL Tree
OP51|ST24|insert|O(log n)|O(log n)|—|BST insert + retrace upward; at most 2 rotations
OP52|ST24|delete|O(log n)|O(log n)|—|BST delete + retrace upward; up to O(log n) rotations
OP53|ST24|search|O(log n)|O(log n)|—|guaranteed balanced; height ≤ 1.44 log₂(n+2)

# Red-Black Tree
OP54|ST25|insert|O(log n)|O(log n)|—|BST insert as red; fix violations upward; at most 2 rotations + recoloring
OP55|ST25|delete|O(log n)|O(log n)|—|BST delete + fix; at most 3 rotations + recoloring
OP56|ST25|search|O(log n)|O(log n)|—|height ≤ 2 log₂(n+1)

# Splay Tree
OP57|ST26|splay|—|O(n)|O(log n)|zig, zig-zig, zig-zag rotations; moves target to root
OP58|ST26|search|—|O(n)|O(log n)|splay accessed node to root
OP59|ST26|insert|—|O(n)|O(log n)|BST insert then splay
OP60|ST26|delete|—|O(n)|O(log n)|splay target; join left and right subtrees

# B-Tree
OP61|ST28|search|O(log_t n)|O(log_t n)|—|at each node: binary search among keys; descend to child; O(log_t n) disk reads
OP62|ST28|insert|O(t × log_t n)|O(t × log_t n)|—|find leaf; insert key; split if overflow (proactive split on way down = single pass)
OP63|ST28|delete|O(t × log_t n)|O(t × log_t n)|—|find key; if leaf, remove; if internal, replace with predecessor/successor; merge/redistribute if underflow

# Trie
OP64|ST31|insert|O(m)|O(m)|—|m = key length; create nodes for each character
OP65|ST31|search|O(m)|O(m)|—|follow character edges; m = key length
OP66|ST31|prefix_search|O(p + k)|O(p + k)|—|p = prefix length; k = number of results; traverse to prefix node then enumerate subtree
OP67|ST31|delete|O(m)|O(m)|—|remove end marker; clean up single-child nodes

# Segment Tree
OP68|ST36|build|Θ(n)|Θ(n)|—|bottom-up aggregate construction
OP69|ST36|point_query|O(log n)|O(log n)|—|traverse root to leaf
OP70|ST36|range_query|O(log n)|O(log n)|—|decompose range into O(log n) nodes
OP71|ST36|point_update|O(log n)|O(log n)|—|update leaf; propagate aggregates upward
OP72|ST37|range_update|O(log n)|O(log n)|—|lazy: tag internal nodes; propagate on access
OP73|ST37|range_query|O(log n)|O(log n)|—|push down lazy tags before reading

# Fenwick Tree
OP74|ST38|point_update|O(log n)|O(log n)|—|add delta at index; propagate via i += (i & -i)
OP75|ST38|prefix_query|O(log n)|O(log n)|—|accumulate from index down via i -= (i & -i)
OP76|ST38|range_query|O(log n)|O(log n)|—|prefix(r) - prefix(l-1)
OP77|ST38|build|Θ(n)|Θ(n)|—|sequential update or in-place O(n) construction

# Sparse Table
OP78|ST39|build|O(n log n)|O(n log n)|—|fill table[k][i] = merge(table[k-1][i], table[k-1][i+2^(k-1)])
OP79|ST39|query|Θ(1)|Θ(1)|—|merge(table[k][l], table[k][r-2^k+1]) where k = ⌊log₂(r-l+1)⌋; requires idempotent operation

# Disjoint Set Union-Find
OP80|ST40|find|α(n)|α(n)|α(n)|path compression: point all traversed nodes directly to root; α = inverse Ackermann ≈ constant
OP81|ST40|union|α(n)|α(n)|α(n)|union by rank: attach shorter tree under taller; keeps height O(log n) without compression
OP82|ST40|make_set|Θ(1)|Θ(1)|—|initialize parent[x] = x; rank[x] = 0

# Skip List
OP83|ST41|search|O(log n)|O(n)|—|expected O(log n) with p = 1/2; traverse from top level down
OP84|ST41|insert|O(log n)|O(n)|—|search for position; flip coins for level; insert at each level
OP85|ST41|delete|O(log n)|O(n)|—|search; unlink at each level

# Graph (Adjacency List)
OP86|ST42|add_edge|Θ(1)|Θ(1)|—|append to neighbor list
OP87|ST42|has_edge|O(degree(u))|O(V)|—|scan neighbor list of u
OP88|ST42|neighbors|Θ(degree(u))|Θ(degree(u))|—|iterate list
OP89|ST42|remove_edge|O(degree(u))|O(V)|—|scan + remove from list

# Graph (Adjacency Matrix)
OP90|ST43|add_edge|Θ(1)|Θ(1)|—|set M[u][v] = weight
OP91|ST43|has_edge|Θ(1)|Θ(1)|—|read M[u][v]
OP92|ST43|neighbors|Θ(V)|Θ(V)|—|scan row u
OP93|ST43|remove_edge|Θ(1)|Θ(1)|—|set M[u][v] = 0/∞

# Interval Tree
OP94|ST46|insert|O(log n)|O(log n)|—|BST insert by lo; update max on path
OP95|ST46|overlap_query|O(log n + k)|O(log n + k)|—|k = number of overlapping intervals returned
OP96|ST46|delete|O(log n)|O(log n)|—|BST delete; update max on path

# KD-Tree
OP97|ST47|insert|O(log n)|O(n)|—|balanced if median split; O(n) if degenerate
OP98|ST47|nearest_neighbor|O(log n)|O(n)|—|prune branches farther than current best; effective in low dimensions
OP99|ST47|range_search|O(√n + k)|O(n)|—|k = results; √n for 2D balanced; degrades in high dimensions
OP100|ST47|build|O(n log n)|O(n log n)|—|median split at each level; presort per axis

# Bloom Filter
OP101|ST49|insert|Θ(k)|Θ(k)|—|set k bits; k = number of hash functions
OP102|ST49|query|Θ(k)|Θ(k)|—|check k bits; false positive if all set by chance
OP103|ST49|delete|—|—|—|not supported in standard Bloom filter

# LRU Cache
OP104|ST54|get|Θ(1)|Θ(1)|—|hash lookup + move to front of list
OP105|ST54|put|Θ(1)|Θ(1)|—|insert or update; evict tail if over capacity
OP106|ST54|evict|Θ(1)|Θ(1)|—|remove tail of doubly linked list + delete from hash map

# Rope
OP107|ST56|concat|O(log n)|O(log n)|—|create new root; left = rope1; right = rope2; rebalance if needed
OP108|ST56|split|O(log n)|O(log n)|—|split at index; traverse to leaf; split path
OP109|ST56|index|O(log n)|O(log n)|—|traverse using weight fields; left if index < left.weight
OP110|ST56|insert|O(log n)|O(log n)|—|split at position; concat three parts

# variants(id|base_fk|name|modification|trade_off)
VA1|ST2|Growth Factor 1.5×|grow by 1.5× instead of 2×|less wasted space; more frequent reallocations; 1.5× allows reuse of freed blocks on some allocators
VA2|ST2|Growth Factor 2×|grow by 2×|simpler; proven O(1) amortized; never reuses freed memory block
VA3|ST12|Min-Max Heap|alternating min and max levels; root is min; level 1 is max|supports both extract_min and extract_max in O(log n); single structure
VA4|ST12|Leftist Heap|min-heap with shortest right spine; merge in O(log n)|mergeable in O(log n); not array-backed; pointer-based
VA5|ST12|Skew Heap|self-adjusting leftist heap; swap children on every merge step|O(log n) amortized merge; simpler than leftist; no rank maintenance
VA6|ST18|Linear Probing|probe sequence: h(k)+1, h(k)+2, ...|cache-friendly; clustering degrades at high load; fastest at low α
VA7|ST18|Quadratic Probing|probe sequence: h(k)+1², h(k)+2², ...|reduces primary clustering; may not visit all slots unless m is prime or power of 2 with triangular numbers
VA8|ST18|Double Hashing|probe sequence: h₁(k)+i×h₂(k)|minimal clustering; h₂ must never be 0; two hash function evaluations per probe
VA9|ST18|Robin Hood Hashing|on collision, compare probe distances; swap if new element is poorer (farther from home)|minimizes variance of probe distances; expected O(1) with high load factors; simplifies deletion
VA10|ST18|Cuckoo Hashing|two tables, two hash functions; insert displaces existing; chain terminates or rehash|O(1) worst-case lookup; insert amortized O(1); may need rehash with new hash functions
VA11|ST23|Threaded BST|null child pointers replaced with in-order predecessor/successor pointers|in-order traversal without stack or recursion; saves space; complicates insert/delete
VA12|ST24|Weight-Balanced Tree (BB[α])|balance by subtree size ratio instead of height; rebalance when size ratio exceeds threshold|supports O(1) split/join; used in set libraries (Adams trees)|
VA13|ST28|B* Tree|node must be 2/3 full (not 1/2); redistribute between siblings before splitting|higher space utilization (~81% vs ~69%); fewer splits; more complex redistribution logic
VA14|ST28|B+ Tree with Bulk Loading|bottom-up construction from sorted data; fill leaves sequentially|O(n/B) I/Os for construction; optimal for initial bulk load
VA15|ST31|Array Trie|children stored as fixed-size array of ALPHABET_SIZE pointers|O(1) child access; wastes space for sparse alphabets; ALPHABET_SIZE pointers per node
VA16|ST31|Hash Map Trie|children stored as hash map|space-efficient for sparse alphabets; O(1) expected child access; hash overhead
VA17|ST31|DAWG (Directed Acyclic Word Graph)|trie with shared suffixes; minimize via suffix merging|O(n) space for dictionary; shared structure; read-only after construction
VA18|ST36|Persistent Segment Tree|path copying on update; old roots preserved|O(log n) per version; supports historical range queries; O(n + q log n) total space for q updates
VA19|ST36|Dynamic Segment Tree|nodes created on demand; covers large coordinate range sparsely|O(q log C) space for q updates over coordinate range [0,C); avoids allocating unused nodes
VA20|ST38|2D Fenwick Tree|nested BIT: BIT of BITs; update/query in O(log² n)|2D prefix sums with point updates; simple extension
VA21|ST40|Union by Size|attach smaller set under larger (instead of by rank)|equivalent asymptotic bounds; size useful for weighted union-find
VA22|ST40|Weighted Union-Find|edges store weight/distance; find returns accumulated weight to root|supports relative-distance queries between elements; used in physics simulations
VA23|ST41|Deterministic Skip List|1-2-3 skip list; deterministic promotion rules instead of coin flips|O(log n) worst case guaranteed; removes randomization; equivalent to 2-3 trees
VA24|ST42|Adjacency List (sorted)|neighbor lists stored sorted|binary search for edge check O(log degree); slower insert|useful when edge-check frequency exceeds insert frequency
VA25|ST49|Partitioned Bloom Filter|bit array split into k partitions; each hash maps to its own partition|better false positive rate at same space; simpler analysis; easier to parallelize
VA26|ST52|Conservative Count-Min Sketch|only increment counter if it equals the current minimum estimate|reduces overcount bias; tighter estimates; slightly slower insert

# failure_modes(id|structure_fk|mode|cause|consequence|mitigation)
FM1|ST2|reallocation stall|append when size = capacity|O(n) copy; latency spike|preallocate; use amortized doubling; arena allocation
FM2|ST2|memory waste|capacity >> size after many deletions|up to 2× wasted memory|shrink policy when size < capacity/4; or explicit shrink_to_fit
FM3|ST18|hash flooding|adversarial keys all hash to same bucket|O(n) per operation; DoS vulnerability|use cryptographic or randomized hash (SipHash); resize to prime; use Robin Hood or cuckoo
FM4|ST18|excessive chaining|poor hash function; many collisions|degraded O(n) lookup in affected bucket|improve hash function; rehash; switch to balanced tree per bucket (Java HashMap)
FM5|ST19|clustering|linear probing with high load factor|long probe sequences; O(n) degradation|keep α < 0.7; use Robin Hood; use quadratic or double hashing
FM6|ST19|tombstone accumulation|many deletes without rehash|probe sequences lengthened by dead slots|periodic rehash; Robin Hood shifts eliminate tombstones
FM7|ST23|degenerate tree|sorted or reverse-sorted insertion|height = n; all operations O(n)|use self-balancing variant (AVL, red-black, treap)
FM8|ST26|sequential access pattern|accessing elements in sorted order repeatedly|each splay takes O(n); no amortized benefit|splay trees unsuitable for sequential scan workloads; use balanced BST
FM9|ST28|excessive splits|many inserts causing cascading splits to root|tree grows taller; more disk I/Os|B* redistribution; bulk loading; proper degree selection
FM10|ST31|memory explosion|large alphabet with sparse keys|most child pointers null; memory dominated by pointer arrays|use hash map children; compressed trie; DAWG
FM11|ST36|lazy tag corruption|incorrect push_down implementation|stale or wrong aggregates; silent data corruption|test with brute-force oracle; push_down before every read/write to children
FM12|ST40|no path compression|find without path compression|O(log n) per find instead of α(n)|always implement path compression; performance degrades measurably on large sets
FM13|ST41|worst-case degeneration|all elements at same level (probability (1/2)^n)|O(n) operations; effectively a linked list|extremely unlikely; can cap max level at ⌈log₂ n⌉ + 1
FM14|ST47|curse of dimensionality|k >> log n; high-dimensional data|pruning ineffective; degrades to O(n) scan|use approximate methods (LSH, random projection) for k > ~20
FM15|ST49|false positive saturation|too many elements relative to bit array size (n >> m/k)|false positive rate approaches 1.0|resize with larger m; use scalable Bloom filter variant
FM16|ST54|thrashing|working set exceeds cache capacity; constant eviction and re-fetch|every access is a cache miss; O(1) time but no benefit|increase capacity; use frequency-aware policy (LFU, W-TinyLFU)
FM17|ST56|imbalanced rope|repeated concatenation without rebalancing|height grows linearly; O(n) index|rebalance when height exceeds c × log n; use weight-balanced merge
FM18|ST15|cascading cuts deferred too long|decrease_key followed by many extract_min without consolidation|root list grows unboundedly between consolidations|extract_min consolidation handles this; cost charged amortized to prior decrease_key
FM19|ST19|infinite probe loop (cuckoo)|cycle in displacement chain during cuckoo insert|insertion fails; must rehash with new hash functions|detect cycle via counter; rehash with new hash seeds; expand table
FM20|ST35|LCP array missing|suffix array without LCP for substring queries|cannot compute longest repeated substring or LCS in linear time|always compute LCP array alongside suffix array; Kasai's algorithm O(n)

# complexity_bounds(id|structure_fk|operation|lower_bound|achievable)
CB1|ST12|insert|Ω(1) amortized|O(log n) binary heap
CB2|ST12|extract_min|Ω(log n)|O(log n) binary heap
CB3|ST15|decrease_key|Ω(1)|Θ(1) amortized Fibonacci heap
CB4|ST15|merge|Ω(1)|Θ(1) Fibonacci heap
CB5|ST18|search|Ω(1) expected|Θ(1) expected with good hash function and α < 1
CB6|ST21|search|Ω(1)|Θ(1) worst-case cuckoo hashing (2 probes)
CB7|ST23|search (balanced)|Ω(log n)|O(log n) AVL/red-black
CB8|ST23|search (unbalanced)|Ω(1)|O(n) worst-case degenerate
CB9|ST28|search (B-tree)|Ω(log_t n) disk reads|O(log_t n) disk reads
CB10|ST36|range_query|Ω(log n)|O(log n) segment tree
CB11|ST38|prefix_query|Ω(log n)|O(log n) Fenwick tree
CB12|ST39|range_min_query (static)|Ω(1) after O(n log n) preprocessing|Θ(1) sparse table
CB13|ST40|union+find|Ω(α(n)) amortized per operation (Fredman-Saks)|Θ(α(n)) amortized with path compression + union by rank
CB14|ST42|enumerate_neighbors|Ω(degree)|Θ(degree) adjacency list
CB15|ST43|has_edge|Ω(1)|Θ(1) adjacency matrix

# distinctions(id|side_a|side_b|key_asymmetry)
DI1|Array-Based|Pointer-Based|array: contiguous memory, cache-friendly, O(1) random access, rigid size; pointer: non-contiguous, flexible size, per-node overhead, cache-unfriendly
DI2|Balanced Tree|Unbalanced Tree|balanced: O(log n) guaranteed height via invariants and rotations; unbalanced: O(n) worst case; simpler insert
DI3|Chaining|Open Addressing|chaining: unlimited load factor, pointer overhead, stable under deletion; open addressing: cache-friendly, no extra allocation, degraded by tombstones, α < 1 required
DI4|Static Structure|Dynamic Structure|static: built once, no updates, can optimize for query (sparse table); dynamic: supports insert/delete, more complex, often extra log factor
DI5|Exact Membership|Probabilistic Membership|exact: hash set, BST, trie; Θ(n) space; no errors; probabilistic: Bloom filter, cuckoo filter; sublinear space; false positives possible
DI6|Implicit (array-backed)|Explicit (pointer-backed)|implicit: parent/child by arithmetic (heap, Fenwick); no pointer overhead; explicit: parent/child by pointer; flexible topology; pointer overhead
DI7|Intrusive|Non-Intrusive|intrusive: link fields embedded in data node; no separate allocation; data type must include links; non-intrusive: container owns separate nodes wrapping data; data type unmodified
DI8|Persistent|Ephemeral|persistent: preserves all versions; path copying O(log n) overhead; persistent queries; ephemeral: single mutable version; lower overhead; simpler
DI9|Dense Representation|Sparse Representation|dense: allocate for full range (adjacency matrix, array trie); fast access; wasteful on sparse data; sparse: allocate per-element (adjacency list, hash trie); space-proportional
DI10|Min-Heap|Max-Heap|min-heap: root is minimum; extract_min O(log n); max-heap: root is maximum; extract_max O(log n); identical structure, reversed comparison
DI11|Internal Node Storage|Leaf-Only Storage|internal: data in all nodes (BST, B-tree); leaf: data only in leaves, internal nodes are separators (B+ tree, segment tree leaves)|
DI12|Lazy Evaluation|Eager Evaluation|lazy: defer computation/propagation until needed (lazy segment tree, Fibonacci heap consolidation); eager: compute immediately; trades latency spikes for consistent per-operation cost
DI13|Comparison-Based|Hash-Based|comparison: O(log n) ops; ordered iteration; no hash function needed; hash: O(1) expected ops; no ordering; requires good hash function
DI14|Space-Optimal|Time-Optimal|space-optimal: minimum memory at cost of slower operations (bit arrays, compressed structures); time-optimal: faster operations at cost of more memory (hash tables, augmented trees)
DI15|Online Construction|Offline Construction|online: handle insertions/queries interleaved (BST, hash table); offline: process all data then answer queries (suffix array, sparse table); offline often faster
DI16|Deterministic|Randomized|deterministic: guaranteed bounds (AVL, red-black); randomized: expected bounds, simpler implementation (skip list, treap); worst case possible but unlikely
DI17|Mergeable|Non-Mergeable|mergeable: combine two instances efficiently (Fibonacci heap Θ(1), leftist heap O(log n)); non-mergeable: binary heap merge requires O(n) rebuild

# relationships(from|rel|to)
# ADT → implementation
CO2|implemented_by|ST11,ST18,ST23,ST42,ST43
CO3|specializes|CO1

# Structure category taxonomy
ST1|generalizes|ST2
ST3|generalizes|ST4
ST5|specializes|ST1
ST6|specializes|ST2
ST7|specializes|ST3
ST8|specializes|ST5
ST9|specializes|ST3
ST10|specializes|ST5
ST12|implements|ST11
ST13|implements|ST11
ST14|implements|ST11
ST15|implements|ST11
ST16|implements|ST11
ST17|implements|ST11

# Tree hierarchy
ST23|generalizes|ST24,ST25,ST26,ST27
ST24|specializes|ST23
ST25|specializes|ST23
ST26|specializes|ST23
ST27|specializes|ST23
ST28|generalizes|ST29,ST30
ST29|specializes|ST28
ST30|equivalent_to|ST25
ST31|generalizes|ST32,ST33,ST34
ST32|specializes|ST31
ST33|specializes|ST31
ST34|specializes|ST31

# Hash table hierarchy
ST18|generalizes|ST19,ST20,ST21,ST22
ST19|generalizes|ST20
ST20|specializes|ST19
ST21|specializes|ST19
ST22|specializes|ST19

# Graph representations
ST42|implements|CO45
ST43|implements|CO45
ST44|implements|CO45
ST45|specializes|ST42

# Augmented/extended trees
ST46|extends|ST23
ST36|extends|ST1
ST38|extends|ST1
ST39|extends|ST1

# Query structure relationships
ST36|enables|CO38,CO39,CO40
ST37|extends|ST36
ST37|enables|CO40
ST38|enables|CO38,CO39
ST39|enables|CO38
DS52_placeholder|—|—

# String structures
ST34|specializes|ST32
ST35|equivalent_to|ST34

# Spatial structures
ST47|extends|ST23
ST48|extends|ST28

# Probabilistic structures
ST49|implements|CO8
ST50|extends|ST49
ST51|extends|ST49
ST52|enables|CO38
ST53|enables|CO9

# Cache structures
ST54|requires|ST18,ST4
ST55|requires|ST18,ST4

# Text structures
ST56|implements|CO38
ST57|implements|CO38
ST58|implements|CO38

# Persistent structures
ST59|specializes|ST23
ST59|implements|CO41,CO44
ST60|implements|CO41,CO44

# Concept relationships
CO4|validates|ST12,ST23,ST24,ST25,ST28
CO5|characterizes|ST2,ST15,ST17,ST26
CO6|constrains|ST18,ST19,ST20,ST21,ST22
CO7|enables|ST18,ST19,ST20,ST21,ST22,ST49,ST51,ST52,ST53
CO8|affects|ST18,ST19
CO9|part_of|ST19,ST20,ST21
CO10|part_of|ST18,ST19
CO11|enables|CO12
CO12|enables|ST24,ST25,ST28
CO13|extends|ST23,ST46
CO14|simplifies|ST4,ST25,ST28
CO15|favors|ST1,ST2,ST5,ST12,ST19,ST22,ST38,ST45
CO16|affects|ST3,ST4,ST7,ST9,ST31,ST41
CO17|degrades|ST3,ST4,ST31,ST41
CO18|affects|ST2,ST19
CO19|part_of|ST19
CO20|enables|ST18
CO21|extends|CO7
CO22|characterizes|ST49

# Field → invariant support
FL20|maintains|CO4
FL21|maintains|CO4
FL22|simplifies|OP54,OP55
FL23|maintains|CO4
FL40|enables|OP95
FL31|enables|CO40
FL36|enables|OP81
FL60|enables|OP34

# Variant relationships
VA1|modifies|ST2
VA2|modifies|ST2
VA3|extends|ST12
VA4|extends|ST12
VA5|extends|VA4
VA6|specializes|ST19
VA7|specializes|ST19
VA8|specializes|ST19
VA9|specializes|ST19
VA10|specializes|ST18
VA11|modifies|ST23
VA12|modifies|ST24
VA13|extends|ST28
VA14|extends|ST29
VA15|specializes|ST31
VA16|specializes|ST31
VA17|specializes|ST31
VA18|extends|ST36
VA19|extends|ST36
VA20|extends|ST38
VA21|modifies|ST40
VA22|extends|ST40
VA23|modifies|ST41
VA24|modifies|ST42
VA25|modifies|ST49
VA26|modifies|ST52

# Failure mode → mitigation structure
FM3|mitigated_by|VA9,VA10
FM4|mitigated_by|ST25
FM5|mitigated_by|VA9,VA7,VA8
FM6|mitigated_by|VA9
FM7|mitigated_by|ST24,ST25,ST27
FM8|mitigated_by|ST24,ST25
FM10|mitigated_by|VA16,VA17,ST32
FM14|mitigated_by|ST49,CO21
FM15|mitigated_by|VA25
FM16|mitigated_by|ST55
FM17|mitigated_by|ST24

# Complexity bound → structure
CB1|bounds|ST12
CB2|bounds|ST12
CB3|bounds|ST15
CB4|bounds|ST15
CB5|bounds|ST18
CB6|bounds|ST21
CB7|bounds|ST24,ST25
CB8|bounds|ST23
CB9|bounds|ST28
CB10|bounds|ST36
CB11|bounds|ST38
CB12|bounds|ST39
CB13|bounds|ST40
CB14|bounds|ST42
CB15|bounds|ST43

# Distinction mappings
DI1|distinguishes|ST1,ST3
DI2|distinguishes|ST24,ST23
DI3|distinguishes|ST18,ST19
DI4|distinguishes|ST39,ST36
DI5|distinguishes|ST18,ST49
DI6|distinguishes|ST12,ST23
DI7|distinguishes|ST3,ST2
DI8|distinguishes|ST59,ST23
DI9|distinguishes|ST43,ST42
DI10|distinguishes|ST12,ST13
DI11|distinguishes|ST28,ST29
DI12|distinguishes|ST37,ST36
DI13|distinguishes|ST23,ST18
DI14|distinguishes|ST49,ST18
DI15|distinguishes|ST39,ST36
DI16|distinguishes|ST24,ST41
DI17|distinguishes|ST15,ST12

# decode_legend
# id_prefixes: CO=concept, ST=structure, OP=operation, VA=variant, FL=field, FM=failure_mode, CB=complexity_bound, DI=distinction
# rel_types: implemented_by|specializes|generalizes|extends|implements|equivalent_to|requires|enables|constrains|characterizes|affects|degrades|favors|simplifies|validates|maintains|modifies|part_of|bounds|mitigated_by|distinguishes
# notation: fk references use raw ID; comma-separated targets expand to individual Prolog rules
# time notation: Θ=tight bound, O=upper bound, Ω=lower bound; α(n)=inverse Ackermann function
# structure categories: linear, heap, hash, tree, graph, probabilistic, cache, text, persistent, specialized, abstract, array, table, forest, list
# stable/in_place: from algorithms compaction; not repeated here; cross-reference AL* IDs
# confidence: synthetic domain knowledge — not extracted from a single source document
