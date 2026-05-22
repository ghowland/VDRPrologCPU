%% ============================================================
%% PROGRAMMING DATA STRUCTURES — DOMAIN PROLOG
%% Connects to core prolog via canonical relation types.
%% Facts from programming_data_structures.compact
%% ============================================================


%% --- ADT → IMPLEMENTATION BINDING ---
%% Abstract data type answered by concrete structures.
implements(st12, st11).   % binary heap implements priority queue
implements(st13, st11).   % max heap implements priority queue
implements(st14, st11).   % d-ary heap implements priority queue
implements(st15, st11).   % fibonacci heap implements priority queue
implements(st16, st11).   % binomial heap implements priority queue
implements(st17, st11).   % pairing heap implements priority queue

%% Graph representations implement graph ADT.
implements(st42, graph_adt). % adjacency list
implements(st43, graph_adt). % adjacency matrix
implements(st44, graph_adt). % edge list
specializes(st45, st42).    % CSR specializes adjacency list


%% --- STRUCTURE TAXONOMY ---
%% Linear structures.
generalizes(st1, st2).    % static array generalizes dynamic array
generalizes(st3, st4).    % singly linked generalizes doubly linked
specializes(st5, st1).    % circular buffer specializes static array
specializes(st6, st2).    % array stack specializes dynamic array
specializes(st7, st3).    % linked stack specializes singly linked list
specializes(st8, st5).    % array queue specializes circular buffer
specializes(st9, st3).    % linked queue specializes singly linked list
specializes(st10, st5).   % deque specializes circular buffer

%% Tree taxonomy.
generalizes(st23, st24).  % BST generalizes AVL
generalizes(st23, st25).  % BST generalizes red-black
generalizes(st23, st26).  % BST generalizes splay
generalizes(st23, st27).  % BST generalizes treap
specializes(st24, st23).  % AVL specializes BST
specializes(st25, st23).  % red-black specializes BST
specializes(st26, st23).  % splay specializes BST
specializes(st27, st23).  % treap specializes BST

%% B-tree family.
generalizes(st28, st29).  % B-tree generalizes B+ tree
generalizes(st28, st30).  % B-tree generalizes 2-3-4 tree
specializes(st29, st28).  % B+ tree specializes B-tree
specializes(st30, st28).  % 2-3-4 tree specializes B-tree
equivalent_to(st30, st25). % 2-3-4 tree equivalent to red-black tree

%% Trie family.
generalizes(st31, st32).  % trie generalizes radix tree
generalizes(st31, st33).  % trie generalizes ternary search tree
generalizes(st31, st34).  % trie generalizes suffix tree
specializes(st32, st31).
specializes(st33, st31).
specializes(st34, st31).
specializes(st34, st32).  % suffix tree specializes compressed trie

%% Suffix structures.
equivalent_to(st35, st34). % suffix array equivalent to suffix tree (expressiveness)

%% Hash table family.
generalizes(st18, st19).  % chaining generalizes open addressing (both are hash)
generalizes(st19, st20).  % open addressing generalizes robin hood
specializes(st20, st19).  % robin hood specializes open addressing
specializes(st21, st19).  % cuckoo specializes open addressing
specializes(st22, st19).  % swiss table specializes open addressing


%% --- EXTENSION AND AUGMENTATION ---
%% Structures that extend base structures with added capability.
extends(st46, st23).    % interval tree extends BST
extends(st47, st23).    % KD-tree extends BST
extends(st48, st28).    % R-tree extends B-tree
extends(st36, st1).     % segment tree extends static array
extends(st38, st1).     % fenwick tree extends static array
extends(st39, st1).     % sparse table extends static array
extends(st37, st36).    % lazy segment tree extends segment tree

%% Probabilistic extensions.
extends(st50, st49).    % counting bloom extends bloom filter
extends(st51, st49).    % cuckoo filter extends bloom filter

%% Persistent structures.
specializes(st59, st23).   % persistent BST specializes BST
implements(st59, co41).    % persistent BST implements persistence
implements(st59, co44).    % persistent BST implements path copying
implements(st60, co41).    % persistent vector trie implements persistence
implements(st60, co44).    % persistent vector trie implements path copying


%% --- CACHE STRUCTURES ---
%% Composed of simpler structures.
requires(st54, st18).   % LRU cache requires hash table
requires(st54, st4).    % LRU cache requires doubly linked list
requires(st55, st18).   % LFU cache requires hash table
requires(st55, st4).    % LFU cache requires doubly linked list


%% --- CONCEPT → STRUCTURE ENABLEMENT ---
%% What makes structures work.
enables(co7, st18).    % hash function enables chaining hash table
enables(co7, st19).    % hash function enables open addressing
enables(co7, st20).    % hash function enables robin hood
enables(co7, st21).    % hash function enables cuckoo
enables(co7, st22).    % hash function enables swiss table
enables(co7, st49).    % hash function enables bloom filter
enables(co7, st51).    % hash function enables cuckoo filter
enables(co7, st52).    % hash function enables count-min sketch
enables(co7, st53).    % hash function enables hyperloglog

enables(co11, co12).   % rotation enables balancing
enables(co12, st24).   % balancing enables AVL
enables(co12, st25).   % balancing enables red-black
enables(co12, st28).   % balancing enables B-tree

enables(co20, st18).   % perfect hashing enables zero-collision hash table


%% --- CONCEPT CONSTRAINTS ---
%% What governs and limits structures.
constrains(co6, st18).   % load factor constrains chaining
constrains(co6, st19).   % load factor constrains open addressing
constrains(co6, st20).   % load factor constrains robin hood
constrains(co6, st21).   % load factor constrains cuckoo
constrains(co6, st22).   % load factor constrains swiss table


%% --- INVARIANT VALIDATION ---
%% Invariants that must hold for correctness.
validates(co4, st12).  % invariant validates binary heap (heap order)
validates(co4, st23).  % invariant validates BST (BST property)
validates(co4, st24).  % invariant validates AVL (balance factor)
validates(co4, st25).  % invariant validates red-black (5 properties)
validates(co4, st28).  % invariant validates B-tree (fill + depth)


%% --- PERFORMANCE PROPERTIES ---
%% What structures favor and what degrades them.
favors(co15, st1).    % cache locality favors static array
favors(co15, st2).    % cache locality favors dynamic array
favors(co15, st5).    % cache locality favors circular buffer
favors(co15, st12).   % cache locality favors binary heap (array)
favors(co15, st19).   % cache locality favors open addressing
favors(co15, st22).   % cache locality favors swiss table
favors(co15, st38).   % cache locality favors fenwick tree
favors(co15, st45).   % cache locality favors CSR

degrades(co17, st3).   % pointer chasing degrades singly linked list
degrades(co17, st4).   % pointer chasing degrades doubly linked list
degrades(co17, st31).  % pointer chasing degrades trie
degrades(co17, st41).  % pointer chasing degrades skip list


%% --- QUERY CAPABILITY ---
%% What operations structures enable.
enables(st36, co38).   % segment tree enables range query
enables(st36, co39).   % segment tree enables point update
enables(st37, co40).   % lazy segment tree enables lazy propagation
enables(st38, co38).   % fenwick tree enables range query
enables(st38, co39).   % fenwick tree enables point update
enables(st39, co38).   % sparse table enables range query
enables(st46, co38).   % interval tree enables range query (overlap)
enables(st52, co38).   % count-min sketch enables frequency query

enables(co13, st23).   % augmentation extends BST
enables(co13, st46).   % augmentation extends interval tree


%% --- VARIANT RELATIONSHIPS ---
%% Variants modify or extend base structures.
specializes(va6, st19).   % linear probing specializes open addressing
specializes(va7, st19).   % quadratic probing specializes open addressing
specializes(va8, st19).   % double hashing specializes open addressing
specializes(va9, st19).   % robin hood hashing specializes open addressing
specializes(va10, st18).  % cuckoo hashing specializes chaining (conceptually)

extends(va3, st12).    % min-max heap extends binary heap
extends(va4, st12).    % leftist heap extends binary heap
extends(va5, va4).     % skew heap extends leftist heap
extends(va13, st28).   % B* tree extends B-tree
extends(va14, st29).   % bulk-loaded B+ extends B+ tree
extends(va18, st36).   % persistent segment tree extends segment tree
extends(va19, st36).   % dynamic segment tree extends segment tree
extends(va20, st38).   % 2D fenwick extends fenwick tree
extends(va22, st40).   % weighted union-find extends union-find

specializes(va15, st31).  % array trie specializes trie
specializes(va16, st31).  % hash map trie specializes trie
specializes(va17, st31).  % DAWG specializes trie


%% --- FAILURE → CAUSE → MITIGATION ---
%% Failure modes, what causes them, what mitigates them.

%% Dynamic array failures.
causes(co18, fm1).           % fragmentation causes reallocation stall
causes(co18, fm2).           % fragmentation causes memory waste
mitigated_by(fm1, co5).      % amortized doubling mitigates stall
mitigated_by(fm2, co10).     % rehashing/shrink mitigates waste

%% Hash table failures.
causes(co8, fm3).            % collision causes hash flooding
causes(co8, fm4).            % collision causes excessive chaining
causes(co8, fm5).            % collision causes clustering
causes(co19, fm6).           % tombstone causes probe lengthening
mitigated_by(fm3, va9).      % robin hood mitigates flooding
mitigated_by(fm3, va10).     % cuckoo mitigates flooding
mitigated_by(fm4, st25).     % tree-per-bucket mitigates chaining
mitigated_by(fm5, va9).      % robin hood mitigates clustering
mitigated_by(fm5, va7).      % quadratic probing mitigates clustering
mitigated_by(fm5, va8).      % double hashing mitigates clustering
mitigated_by(fm6, va9).      % robin hood eliminates tombstones

%% Tree failures.
causes(co34, fm7).           % degenerate tree causes O(n) degradation
mitigated_by(fm7, st24).     % AVL mitigates degenerate tree
mitigated_by(fm7, st25).     % red-black mitigates degenerate tree
mitigated_by(fm7, st27).     % treap mitigates degenerate tree
mitigated_by(fm8, st24).     % AVL mitigates splay sequential pattern
mitigated_by(fm8, st25).     % red-black mitigates splay sequential pattern

%% Trie failure.
causes(co16, fm10).          % memory overhead causes trie explosion
mitigated_by(fm10, va16).    % hash map trie mitigates explosion
mitigated_by(fm10, va17).    % DAWG mitigates explosion
mitigated_by(fm10, st32).    % radix tree mitigates explosion

%% Spatial failure.
mitigated_by(fm14, st49).    % bloom filter mitigates dimensionality
mitigated_by(fm14, co21).    % consistent hashing mitigates dimensionality

%% Cache failure.
mitigated_by(fm16, st55).    % LFU mitigates LRU thrashing

%% Rope failure.
mitigated_by(fm17, st24).    % AVL rebalance mitigates rope imbalance


%% --- COMPLEXITY BOUNDS ---
%% Lower bounds and achievable bounds for structure/operation pairs.
bounded_by(st12, cb1).   % heap insert bounded
bounded_by(st12, cb2).   % heap extract_min bounded
bounded_by(st15, cb3).   % fibonacci decrease_key bounded
bounded_by(st15, cb4).   % fibonacci merge bounded
bounded_by(st18, cb5).   % hash search bounded
bounded_by(st21, cb6).   % cuckoo search bounded (worst-case O(1))
bounded_by(st24, cb7).   % AVL search bounded
bounded_by(st25, cb7).   % red-black search bounded
bounded_by(st23, cb8).   % unbalanced BST search bounded
bounded_by(st28, cb9).   % B-tree search bounded
bounded_by(st36, cb10).  % segment tree range query bounded
bounded_by(st38, cb11).  % fenwick prefix query bounded
bounded_by(st39, cb12).  % sparse table RMQ bounded
bounded_by(st40, cb13).  % union-find bounded
bounded_by(st42, cb14).  % adjacency list neighbor enumeration bounded
bounded_by(st43, cb15).  % adjacency matrix edge check bounded


%% --- DISTINCTION RULES ---
%% Domain-specific selection guidance. Fires at L3.

%% Array vs pointer: use core distinction pattern.
%% distinguishes(di1, st1, st3) → array vs linked
%% Selector: if random access needed → array-based.
prefer(st1, st3, random_access) :-
    requires(query, random_access),
    favors(co15, st1).

%% Balanced vs unbalanced: if worst-case matters → balanced.
prefer(st24, st23, worst_case_guarantee) :-
    requires(query, guaranteed_log_n).

%% Chaining vs open addressing.
prefer(st19, st18, cache_performance) :-
    favors(co15, st19).
prefer(st18, st19, high_load_factor) :-
    constrains(co6, st19).  % open addressing degrades near α=1

%% Static vs dynamic: if no updates → sparse table.
prefer(st39, st36, static_data) :-
    \+ requires(query, point_update),
    \+ requires(query, range_update).

%% Exact vs probabilistic: if false positives acceptable → bloom.
prefer(st49, st18, space_constrained) :-
    accepts(query, false_positive),
    \+ requires(query, enumeration).

%% Persistent vs ephemeral.
prefer(st59, st23, version_history) :-
    requires(query, historical_access).


%% --- OPERATION COMPLEXITY QUERIES ---
%% What complexity does operation X have on structure Y?

complexity(ST, Op, Avg, Worst, Amortized) :-
    operation(ST, Op, Avg, Worst, Amortized).

%% Can structure support operation in target complexity?
supports_in(ST, Op, Target) :-
    complexity(ST, Op, Avg, _, _),
    leq_complexity(Avg, Target).
supports_in(ST, Op, Target) :-
    complexity(ST, Op, _, _, Amortized),
    Amortized \= none,
    leq_complexity(Amortized, Target).


%% --- STRUCTURE SELECTION ---
%% Given requirements, find matching structures. L3.

%% Find structure supporting all required operations within bounds.
candidate_structure(ST, Requirements) :-
    forall(
        member(req(Op, MaxComplexity), Requirements),
        supports_in(ST, Op, MaxComplexity)
    ).

%% Rank candidates by cache locality preference.
preferred_structure(ST, Requirements) :-
    candidate_structure(ST, Requirements),
    favors(co15, ST).

%% Fallback: any candidate.
preferred_structure(ST, Requirements) :-
    candidate_structure(ST, Requirements).


%% --- CROSS-DOMAIN BRIDGES ---

%% Data structures ↔ Connections
%% Graph structures ARE connection networks.
instance_of(st42, network).     % adjacency list is a network
instance_of(st43, network).     % adjacency matrix is a network
specializes(co24, edge).        % DS edge specializes connection edge
specializes(co23, node).        % DS node specializes connection node

%% Tree topology from connections.
instance_of(st23, tree_topology).  % BST is tree topology
instance_of(st28, tree_topology).  % B-tree is tree topology

%% Hash table ↔ Connections informational.
implements(st18, lookup_table).    % hash table implements IN2 (index)
implements(st19, lookup_table).
specializes(co7, hash_function).   % hash function specializes mapping (FN12)

%% Data structures ↔ Movement
%% Queue is temporal sequence. Stack is temporal reversal.
instance_of(st8, temporal_sequence).   % queue models FIFO = sequence
instance_of(st6, temporal_reversal).   % stack models LIFO = reversal

%% LRU cache is state machine: access → promote, overflow → evict.
evolves_to(lru_idle, lru_access).
evolves_to(lru_access, lru_promote).
evolves_to(lru_promote, lru_idle).
evolves_to(lru_overflow, lru_evict).
evolves_to(lru_evict, lru_idle).

%% Data structures ↔ Logic
%% BST invariant IS a logical formula.
%% ∀node: left.key < node.key < right.key
%% This is FO6 (universal quantifier) + RL10 (strict partial order).
instance_of(bst_invariant, logical_formula).
requires(bst_invariant, strict_total_order).

%% Heap invariant: ∀node: parent.key ≤ node.key
instance_of(heap_invariant, logical_formula).
requires(heap_invariant, partial_order).

%% Red-black tree 5 properties: conjunction of constraints.
composed_of(rb_invariant, rb_prop_1).  % every node red or black
composed_of(rb_invariant, rb_prop_2).  % root is black
composed_of(rb_invariant, rb_prop_3).  % leaves black
composed_of(rb_invariant, rb_prop_4).  % red has black children
composed_of(rb_invariant, rb_prop_5).  % equal black-height

%% Bloom filter false positive = probabilistic (CU12 stochastic causation).
instance_of(co22, stochastic_property).

%% Resolution (IR18) is what Prolog uses; Prolog is in computing tree.
%% Data structures serve the Prolog engine: binding stack = ST6 (stack),
%% term store = ST1 (static array), KB tree = ST23 (BST variant).
enables(st6, prolog_backtracking).    % stack enables backtracking
enables(st1, term_storage).           % array enables term store
enables(st23, kb_tree).               % BST enables KB tree structure
enables(st18, path_index).            % hash table enables path→ID lookup
enables(st5, work_queue).             % circular buffer enables work queue


%% --- VDR-PROLOG SYSTEM BRIDGES ---
%% Map data structures to actual VDR-Prolog system components.

%% Arena = ST1 (static array) with bump pointer. No free. No reuse.
instance_of(vdr_arena, st1).
prevents(vdr_arena, co18).   % arena prevents fragmentation

%% KB store = tree of KB structs. ST23 variant.
instance_of(vdr_kb_tree, st23).
validates(co4, vdr_kb_tree).  % BST invariant holds on KB tree

%% Relation index = ST18 (hash table) grouped by type.
instance_of(vdr_relation_index, st18).
enables(co7, vdr_relation_index).  % hash function enables index

%% KV cache = ST1 (static array) in per-core arena.
instance_of(vdr_kv_cache, st1).
favors(co15, vdr_kv_cache).  % cache locality favors array layout

%% Work queue = ST5 (circular buffer) with atomic head/tail.
instance_of(vdr_work_queue, st5).

%% Session LRU = ST54 (LRU cache) for session management.
instance_of(vdr_session_lru, st54).
requires(vdr_session_lru, st18).  % needs hash map
requires(vdr_session_lru, st4).   % needs doubly linked list

%% Audit ring = ST5 (circular buffer) for audit entries.
instance_of(vdr_audit_ring, st5).

%% Fact store = ST1 (static array) at 48-byte stride.
instance_of(vdr_fact_store, st1).
favors(co15, vdr_fact_store).
