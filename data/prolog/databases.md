%% ============================================================
%% DATABASES — DOMAIN PROLOG
%% Connects to core, data structures, algorithms, FSM, logic.
%% Facts from databases.compact
%% ============================================================


%% --- DATA MODEL TAXONOMY ---
implements(dm1, co3).   % relational implements data model
implements(dm2, co3).   % document implements data model
implements(dm3, co3).   % key-value implements data model
implements(dm4, co3).   % graph implements data model
implements(dm5, co3).   % columnar implements data model
implements(dm6, co3).   % time-series implements data model

%% Relational is foundational — most structured, most constrained.
foundation_for(co4, dm1).    % table is foundation for relational model
foundation_for(co15, co4).   % mathematical relation formalizes table


%% --- RELATIONAL STRUCTURE ---
%% Table composed of rows and columns.
part_of(co5, co4).    % row part of table
part_of(co6, co4).    % column part of table
constrains(co10, co6).  % data type constrains column
validates(co7, co13).   % primary key validates entity integrity
validates(co9, co13).   % constraint validates integrity
connects_to(co8, co4).  % foreign key connects tables
degrades(co11, co9).    % NULL complicates constraint checking

%% ACID composed of four properties.
part_of(tn1, co14).   % atomicity part of ACID
part_of(tn2, co14).   % consistency part of ACID
part_of(tn3, co14).   % isolation part of ACID
part_of(tn4, co14).   % durability part of ACID
enables(co14, co13).  % ACID enables integrity


%% --- NORMALIZATION CHAIN ---
%% Strict sequence: each level requires the previous.
precedes(nm1, nm2).   % 1NF before 2NF
precedes(nm2, nm3).   % 2NF before 3NF
precedes(nm3, nm4).   % 3NF before BCNF
precedes(nm4, nm5).   % BCNF before 4NF

%% Each form eliminates a class of anomaly.
prevents(nm1, repeating_groups).       % 1NF prevents repeating groups
prevents(nm2, partial_dependency).     % 2NF prevents partial dependency
prevents(nm3, transitive_dependency).  % 3NF prevents transitive dependency
prevents(nm4, non_key_determinant).    % BCNF prevents non-key determinants
prevents(nm5, multivalued_dependency). % 4NF prevents multivalued dependency

%% Denormalization intentionally relaxes normalization.
mitigated_by(nm3, nm6).  % 3NF constraints mitigated by denormalization
opposes(nm6, nm3).       % denormalization opposes 3NF (controlled)


%% --- SCHEMA DESIGN PATTERNS ---
%% Cardinality patterns.
specializes(sd2, co17).   % 1:1 specializes cardinality
specializes(sd3, co17).   % 1:N specializes cardinality
specializes(sd4, co17).   % M:N specializes cardinality
specializes(sd5, co17).   % self-referencing specializes cardinality

%% Key types.
simplifies(sd6, co7).    % surrogate key simplifies primary key
requires(sd7, co12).     % natural key requires valid domain
composed_of(sd8, co7).   % composite key composed of multiple columns

%% Schema patterns for analytics.
enables(sd12, qp2).    % star schema enables optimizer for OLAP
specializes(sd13, sd12).  % snowflake specializes star (normalized dims)

%% Temporal and soft delete extend basic row concept.
extends(sd11, co5).   % temporal table extends row with time
models(sd10, co5).    % soft delete models deletion on row


%% --- STORAGE MECHANISMS ---
%% Page is fundamental unit.
part_of(sr1, sr4).    % page part of buffer pool
part_of(sr1, sr9).    % page part of B-tree nodes

%% Storage strategies.
implements(sr2, co4).    % heap implements default table storage
organizes(sr3, co4).     % clustered index organizes table physically
maintains(sr4, sr1).     % buffer pool maintains pages in memory

%% Row vs column storage.
enables(sr6, oltp).    % row storage enables OLTP
enables(sr7, olap).    % column storage enables OLAP
alternative_to(sr6, sr7).  % row and column are alternatives

%% Write-optimized vs read-optimized.
alternative_to(sr8, sr9).  % LSM alternative to B-tree
enables(sr8, high_write_throughput).  % LSM enables fast writes
enables(sr9, fast_reads).            % B-tree enables fast reads

%% WAL and checkpoints.
enables(sr10, tn4).   % WAL enables durability
enables(sr10, jr1).   % WAL enables write-ahead logging
constrains(sr11, jr1).  % checkpoint constrains recovery time
simplifies(sr12, sr1).  % compression simplifies storage (reduces size)


%% --- INDEXING ---
%% B-tree is the default, others specialize.
depends_on(ix1, sr9).    % B-tree index depends on B-tree storage
specializes(ix2, ix1).   % hash index specializes (equality only)
specializes(ix3, ix1).   % bitmap index specializes (low cardinality)
specializes(ix4, ix1).   % spatial index specializes (multi-dimensional)
specializes(ix5, ix1).   % full-text index specializes (inverted index)
extends(ix6, ix1).       % covering index extends B-tree (includes extra cols)
constrains(ix7, ix1).    % partial index constrains scope
extends(ix8, ix1).       % composite index extends B-tree (multi-column)
validates(ix9, ix1).     % unique index validates uniqueness on B-tree
inspects(ix10, ix1).     % selectivity inspects index discrimination


%% --- QUERY PROCESSING PIPELINE ---
%% Sequential processing chain.
precedes(qp1, qp2).    % parser before optimizer
produces(qp2, qp3).    % optimizer produces execution plan
enables(qp9, qp2).     % statistics enable optimizer decisions
enables(qp10, qp3).    % predicate pushdown enables efficient plans

%% Execution plan contains operator types.
contains(qp3, qp4).    % plan contains table scan
contains(qp3, qp5).    % plan contains index seek
contains(qp3, qp6).    % plan contains nested loop join
contains(qp3, qp7).    % plan contains hash join
contains(qp3, qp8).    % plan contains merge join

%% Access methods are alternatives.
alternative_to(qp4, qp5).  % full scan vs index seek

%% Join methods are alternatives.
alternative_to(qp6, qp7).  % nested loop vs hash join
alternative_to(qp7, qp8).  % hash join vs merge join
alternative_to(qp6, qp8).  % nested loop vs merge join


%% --- TRANSACTION IMPLEMENTATION ---
implements(jr1, tn1).    % WAL implements atomicity (undo on rollback)
implements(cc1, tn3).    % locking implements isolation
implements(cc2, tn3).    % MVCC implements isolation
implements(sr10, tn4).   % WAL implements durability
alternative_to(cc1, cc2).  % locking vs MVCC are alternatives

%% Isolation levels regulate isolation property.
regulates(cc5, tn3).    % isolation levels regulate isolation

%% Concurrency hazards.
threatens(cc3, cc1).    % deadlock threatens locking
violates(cc6, cc5).     % phantom read violates repeatable read
violates(cc7, cc5).     % write skew violates snapshot isolation

%% Savepoint modifies atomicity granularity.
influences(tn5, tn1).   % savepoint influences atomicity
extends(tn6, tn1).      % two-phase commit extends atomicity (distributed)


%% --- JOURNALING (WAL/ARIES) ---
contains(jr1, jr2).       % WAL contains log records
determined_by(jr2, jr3).  % log record determined by LSN
organizes(jr3, jr2).      % LSN organizes log records in total order
constrains(jr4, jr1).     % checkpoint constrains WAL recovery scope
implements(jr5, jr1).     % ARIES implements WAL recovery
manages(jr6, jr1).        % WAL truncation manages WAL size

%% ARIES recovery phases form a pipeline.
follows(aries_analysis, aries_redo).
follows(aries_redo, aries_undo).
instance_of(aries_recovery, pipeline).


%% --- REPLICATION ---
%% Primary-replica is the base pattern.
specializes(rp2, rp1).   % synchronous specializes primary-replica
specializes(rp3, rp1).   % asynchronous specializes primary-replica
extends(rp6, rp1).       % multi-primary extends primary-replica
extends(rp7, rp1).       % consensus extends primary-replica (stronger)

%% Replication methods are alternatives.
alternative_to(rp4, rp5).  % logical vs physical replication

%% WAL enables replication.
enables(sr10, rp1).   % WAL enables primary-replica replication
enables(sr10, rp5).   % WAL enables physical (streaming) replication
enables(jr1, rp5).    % WAL enables streaming replication
derived_from(rp8, jr1).  % CDC derives from WAL

%% Replication → consistency guarantees.
enables(rp2, cn1).    % synchronous replication enables strong consistency
produces(rp3, cn2).   % asynchronous replication produces eventual consistency
enables(rp7, cn1).    % consensus replication enables strong consistency
requires(rp6, cn2).   % multi-primary requires eventual consistency (typically)


%% --- PARTITIONING ---
extends(pt1, co4).       % horizontal partitioning extends table (scales rows)
alternative_to(pt1, pt2).  % horizontal vs vertical are alternatives
specializes(pt3, pt1).   % range partitioning specializes horizontal
specializes(pt4, pt1).   % hash partitioning specializes horizontal
enables(pt5, pt1).       % partition pruning enables efficient partitioned queries


%% --- CONSISTENCY SPECTRUM ---
generalizes(cn1, cn3).   % strong generalizes causal (strongest)
generalizes(cn3, cn2).   % causal generalizes eventual
specializes(cn4, cn1).   % read-your-writes specializes strong (minimum viable)
constrains(cn5, cn1).    % CAP theorem constrains strong consistency
constrains(cn5, cn2).    % CAP theorem constrains availability
implements(cn6, cn1).    % quorum implements strong consistency


%% --- FAILURE MODE → PREVENTION ---
mitigated_by(fm1, sd1).    % wrong cardinality mitigated by ER modeling
mitigated_by(fm1, sd3).    % mitigated by 1:N pattern
mitigated_by(fm1, sd4).    % mitigated by M:N pattern
mitigated_by(fm2, nm3).    % premature denorm mitigated by 3NF first
mitigated_by(fm3, ix1).    % missing index mitigated by B-tree index
mitigated_by(fm3, qp9).    % mitigated by statistics
mitigated_by(fm4, ix10).   % too many indexes mitigated by selectivity analysis
mitigated_by(fm4, qp9).    % mitigated by usage statistics
mitigated_by(fm5, cc1).    % deadlock mitigated by lock ordering
mitigated_by(fm5, cc4).    % mitigated by lock granularity tuning
mitigated_by(fm6, tn5).    % long transaction mitigated by savepoints
mitigated_by(fm7, rp2).    % replication lag mitigated by sync replication
mitigated_by(fm7, cn4).    % mitigated by read-your-writes
mitigated_by(fm8, pt4).    % hot partition mitigated by hash partitioning
mitigated_by(fm9, sr10).   % data corruption mitigated by WAL
mitigated_by(fm9, jr1).    % mitigated by journaling
mitigated_by(fm10, co2).   % schema migration mitigated by schema management
mitigated_by(fm11, jr4).   % recovery failure mitigated by checkpoints
mitigated_by(fm11, jr6).   % mitigated by WAL management
mitigated_by(fm12, co11).  % NULL errors mitigated by understanding NULL
mitigated_by(fm12, co9).   % mitigated by NOT NULL constraints


%% --- JOIN METHOD SELECTION ---
%% Domain-specific: given join characteristics, select method. L3.

select_join(qp6, small_outer, indexed_inner).
%% Nested loop: small outer table, index on inner join column.

select_join(qp7, large_tables, equi_join, no_index).
%% Hash join: large tables, equality join, no index needed.

select_join(qp8, large_tables, presorted).
%% Merge join: both inputs already sorted (clustered index on join key).

select_join(qp4, _, small_table).
%% Full scan: table small enough that index overhead exceeds scan cost.


%% --- INDEX SELECTION ---
%% Given query pattern and data characteristics, select index type. L3.

select_index(ix1, _, _).
%% B-tree: default; handles equality, range, ordering.

select_index(ix2, equality_only, _) :-
    \+ requires(query, range),
    \+ requires(query, ordering).
%% Hash: equality only, no range or order.

select_index(ix3, low_cardinality, olap) :-
    instance_of(workload, olap).
%% Bitmap: low cardinality columns in OLAP.

select_index(ix4, spatial_data, _).
%% R-tree: spatial/geometric data.

select_index(ix5, text_search, _).
%% Inverted index: full-text search.

select_index(ix6, covering_query, high_frequency) :-
    all_columns_in_index(query, index).
%% Covering: all query columns in index, avoids table access.

select_index(ix7, skewed_data, _) :-
    has_filter_condition(query, condition).
%% Partial: index only matching rows (e.g., WHERE deleted_at IS NULL).

select_index(ix8, multi_column_filter, _).
%% Composite: queries filter on multiple columns together.


%% --- STORAGE SELECTION ---
%% Given workload, select storage engine strategy. L3.

select_storage(sr6, oltp).          % row storage for OLTP
select_storage(sr7, olap).          % column storage for OLAP
select_storage(sr9, read_heavy).    % B-tree for read-heavy
select_storage(sr8, write_heavy).   % LSM for write-heavy
select_storage(sr3, range_queries). % clustered for range queries on key
select_storage(sr2, append_only).   % heap for append-only/staging


%% --- REPLICATION SELECTION ---

select_replication(rp2, zero_data_loss).
%% Synchronous: when data loss is unacceptable.

select_replication(rp3, low_latency_writes).
%% Asynchronous: when write latency matters more than consistency.

select_replication(rp7, strong_consistency, distributed).
%% Consensus (Raft/Paxos): distributed strong consistency.

select_replication(rp6, write_availability).
%% Multi-primary: when writes must always succeed.

select_replication(rp4, cross_version).
%% Logical: when replicating between different versions/engines.

select_replication(rp5, fastest_failover).
%% Physical streaming: exact copy, fastest failover.


%% --- PARTITIONING SELECTION ---

select_partitioning(pt3, time_series).
%% Range: partition by time for time-series data.

select_partitioning(pt3, range_queries_common).
%% Range: when queries filter on partition key ranges.

select_partitioning(pt4, even_distribution).
%% Hash: when uniform distribution needed, no range queries.

select_partitioning(pt2, column_access_patterns).
%% Vertical: when different columns have different access frequency.


%% --- CONSISTENCY SELECTION ---

select_consistency(cn1, financial, critical).
%% Strong: financial transactions, inventory, anything where stale = wrong.

select_consistency(cn2, social_feed, high_availability).
%% Eventual: social media feeds, analytics, non-critical reads.

select_consistency(cn3, messaging, ordered).
%% Causal: messaging systems where order matters but global order doesn't.

select_consistency(cn4, interactive, user_facing).
%% Read-your-writes: minimum for interactive applications.


%% --- CROSS-DOMAIN BRIDGES ---

%% Databases × Data Structures.
%% B-tree index = data_structures.ST28 (B-tree).
equivalent_to(ix1, st28).       % database B-tree index ≡ DS B-tree
equivalent_to(sr9, st28).       % database B-tree storage ≡ DS B-tree
specializes(ix1, st29).         % database index often B+ tree variant

%% Hash index = data_structures.ST18 (hash table chaining) or ST19 (open).
equivalent_to(ix2, st18).       % hash index ≡ DS hash table

%% LSM tree = data_structures concept (not directly in DS compact but structurally:
%% memtable = ST23 (BST or skip list), SSTable = ST35 (sorted array on disk)).
composed_of(sr8, memtable).
composed_of(sr8, sstable).
instance_of(memtable, st23).    % memtable is balanced BST (often skip list)
instance_of(sstable, st35).     % SSTable is sorted array on disk

%% Buffer pool = data_structures.ST54 (LRU cache).
equivalent_to(sr4, st54).       % buffer pool ≡ LRU cache

%% Bitmap index = data_structures.ST49 variant (bit array, set membership).
instance_of(ix3, bit_array_structure).

%% Inverted index = data_structures.ST31 (trie) + posting lists.
composed_of(ix5, trie_structure).
composed_of(ix5, posting_list).
instance_of(trie_structure, st31).


%% Databases × Algorithms.
%% Query optimizer uses cost-based search = algorithms.TE5 (branch and bound).
instance_of(qp2, te5).    % optimizer is branch-and-bound over plan space

%% Nested loop join = algorithms concept: O(n×m) or O(n×log m) with index.
instance_of(qp6, nested_loop_pattern).

%% Hash join = algorithms.TE14 (hashing technique).
implements(qp7, te14).    % hash join implements hashing technique

%% Merge join = algorithms.AL4 concept (merge phase of merge sort).
instance_of(qp8, merge_pattern).

%% Sort in execution plan = algorithms.AL4 (merge sort) or AL6 (heapsort).
requires(qp8, sorting_algorithm).

%% Query parser = algorithms concept of parsing (FSM-related).
instance_of(qp1, parser).

%% Predicate pushdown = algorithms.QP10 = early filtering = optimization.
instance_of(qp10, optimization_technique).

%% B-tree search = algorithms.AL16 (binary search) at each node.
requires(ix1, al16).    % B-tree node search uses binary search

%% Statistics histograms enable cardinality estimation.
enables(qp9, cardinality_estimation).


%% Databases × FSM.
%% Transaction lifecycle IS an FSM.
instance_of(db_transaction_lifecycle, mt1).  % DFA
evolves_to(txn_begin, txn_active).
evolves_to(txn_active, txn_committed).
evolves_to(txn_active, txn_aborted).
evolves_to(txn_active, txn_savepoint).
evolves_to(txn_savepoint, txn_active).      % rollback to savepoint
evolves_to(txn_aborted, txn_begin).         % retry
instance_of(txn_committed, accept_state).
instance_of(txn_aborted, accept_state).

%% Two-phase commit IS an FSM.
instance_of(two_phase_commit, mt4).  % Moore machine
evolves_to(tpc_init, tpc_prepare).
evolves_to(tpc_prepare, tpc_vote_yes).
evolves_to(tpc_prepare, tpc_vote_no).
evolves_to(tpc_vote_yes, tpc_commit).
evolves_to(tpc_vote_no, tpc_abort).

%% Replication state IS an FSM.
instance_of(replication_lifecycle, mt4).
evolves_to(replica_init, replica_streaming).
evolves_to(replica_streaming, replica_caught_up).
evolves_to(replica_caught_up, replica_streaming).  % falls behind
evolves_to(replica_caught_up, replica_promoted).   % failover

%% Query processing IS a pipeline FSM.
instance_of(query_pipeline, pipeline).
follows(qp1, qp2).   % parse → optimize
follows(qp2, qp3).   % optimize → execute

%% ARIES recovery IS a sequential FSM.
instance_of(aries_recovery_fsm, mt4).
evolves_to(recovery_start, recovery_analysis).
evolves_to(recovery_analysis, recovery_redo).
evolves_to(recovery_redo, recovery_undo).
evolves_to(recovery_undo, recovery_complete).


%% Databases × Logic.
%% Relational algebra = math_logic.CO16 (relational algebra maps to set operations).
%% σ (select) = logical conjunction of predicates.
%% π (project) = existential quantification (∃ over eliminated columns).
%% ⋈ (join) = conjunction + existential.
instance_of(co16, logical_framework).

%% SQL WHERE clause IS a logical formula.
instance_of(sql_where, logical_formula).
%% WHERE a > 5 AND b = 'x' is PL3 (conjunction).
%% WHERE a > 5 OR b = 'x' is PL4 (disjunction).
%% WHERE NOT (a > 5) is PL2 (negation).

%% Constraints are logical invariants.
instance_of(co9, logical_invariant).    % constraint is invariant
instance_of(co7, logical_invariant).    % PK is invariant (uniqueness + not null)
instance_of(co8, logical_formula).      % FK is logical reference (∀ fk ∃ pk)

%% NULL = three-valued logic = math_logic.DM11 (many-valued logic).
instance_of(co11, three_valued_logic).

%% Normalization rules are logical dependencies.
%% Functional dependency X→Y is math_logic.PL5 (material conditional).
instance_of(functional_dependency, material_conditional).

%% Deadlock = circular wait = graph cycle.
%% Detection uses cycle detection = algorithms.AL24 (DFS) on wait-for graph.
requires(cc3, cycle_detection).
instance_of(wait_for_graph, directed_graph).

%% CAP theorem is logical constraint: ¬(C ∧ A ∧ P) during partition.
%% Equivalent to: P → (¬C ∨ ¬A).
instance_of(cn5, logical_constraint).


%% Databases × Connections.
%% Foreign key IS a connection (connections.CO1).
instance_of(co8, connection).
specializes(co8, reference_connection).  % FK specializes reference (IN1)

%% Replication IS a connection with latency (connections.CO7).
instance_of(rp1, connection).
composed_of(rp1, co7_latency).  % replication has latency property
composed_of(rp1, co8_capacity). % replication has capacity (throughput)

%% Network partition = connection failure (connections.FM4).
instance_of(network_partition, connection_failure).
causes(network_partition, cn5_tradeoff).  % partition triggers CAP choice

%% Data corruption = connection integrity failure (connections.IN18 checksum).
mitigated_by(fm9, checksum_validation).
instance_of(checksum_validation, in18).  % checksum is connections.IN18


%% Databases × Movement.
%% Transaction is state transition: database from state S1 to state S2.
instance_of(transaction, state_transition).
requires(transaction, co21_threshold).  % commit is threshold crossing

%% WAL is temporal sequence (movement.TM1).
instance_of(jr1, temporal_sequence).
instance_of(jr3, temporal_ordering).  % LSN provides total order

%% Recovery = reversal (movement.TR5) of uncommitted + replay of committed.
instance_of(aries_undo, movement_reversal).
instance_of(aries_redo, movement_replay).

%% Replication lag = movement.TM9 (lag/delayed connection).
instance_of(fm7, temporal_lag).

%% Checkpoint = movement.SA9 (suspended state) → snapshot.
instance_of(sr11, state_snapshot).


%% Databases × VDR-Prolog System.

%% VDR-Prolog KB store IS a database.
instance_of(vdr_kb_store, co1).    % KB store is a database
instance_of(vdr_fact_store, co4).  % fact store is a table (rows = facts)

%% VDR-Prolog uses arena memory, not buffer pool.
%% But the KB structure mirrors database concepts:
equivalent_to(vdr_kb, co4).        % KB ≡ table
equivalent_to(vdr_fact, co5).      % fact ≡ row
equivalent_to(vdr_fact_tag, co10). % fact tag ≡ data type
equivalent_to(vdr_vdrid, co7).     % VdrId ≡ primary key
equivalent_to(vdr_provenance, co18). % provenance ≡ metadata

%% Relation index = database index on typed relations.
equivalent_to(vdr_relation_index, ix1).  % relation index ≡ B-tree-like index

%% VDR-Prolog session snapshot = database checkpoint.
equivalent_to(vdr_snapshot, sr11).

%% VDR-Prolog lazy loading = database lazy materialization.
instance_of(vdr_lazy_loading, lazy_evaluation).

%% VDR-Prolog manifest = database catalog.
equivalent_to(vdr_manifest, co19).  % manifest ≡ data dictionary

%% VDR-Prolog grant system = database permissions.
instance_of(vdr_grant, access_control).

%% VDR-Prolog audit ring = database audit log.
instance_of(vdr_audit_ring, audit_log).
instance_of(vdr_audit_ring, circular_buffer).  % DS.ST5

%% Confidence table = data quality metadata.
instance_of(vdr_confidence, co18).  % confidence is metadata about data quality
