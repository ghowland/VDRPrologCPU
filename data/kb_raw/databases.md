# DATABASES — DESIGN, STRUCTURE, MECHANICS & OPERATIONS — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: concepts → data_model → normalization → schema_design → storage → indexing → query_processing → transactions → concurrency → journaling → replication → partitioning → consistency → failure_modes → distinctions → relationships → decode_legend

# concepts(id|name|definition|category)
CO1|Database|organized collection of structured data with defined schema, managed by software enforcing rules for storage, retrieval, and modification; persistent; shared; consistent|foundation
CO2|Schema|formal description of data structure; defines tables, columns, types, constraints, relationships; blueprint of database; logical structure independent of physical storage|foundation
CO3|Data Model|abstract framework describing how data is structured and related; relational (tables), document (JSON/BSON), key-value, graph (nodes/edges), columnar, time-series|foundation
CO4|Table (Relation)|named two-dimensional structure of rows and columns; each row is a tuple (record); each column is an attribute (field); fundamental unit of relational model|relational
CO5|Row (Tuple/Record)|single entry in table; represents one instance of entity; contains values for each column; uniquely identifiable by primary key|relational
CO6|Column (Attribute/Field)|named property of table; has data type, constraints, and domain; each column holds one category of data across all rows|relational
CO7|Primary Key (PK)|column or combination of columns uniquely identifying each row; must be unique and non-null; every table should have one; defines entity identity|constraint
CO8|Foreign Key (FK)|column(s) in one table referencing primary key of another table; enforces referential integrity; creates relationships between tables; may be null (optional relationship)|constraint
CO9|Constraint|rule enforced by database on data values; ensures data integrity; NOT NULL, UNIQUE, CHECK, DEFAULT, PRIMARY KEY, FOREIGN KEY|integrity
CO10|Data Type|classification of column values; integer, varchar, text, date, timestamp, boolean, decimal, blob, json, uuid; determines storage, operations, and validation|schema
CO11|NULL|absence of a value; not zero, not empty string; unknown or inapplicable; three-valued logic (TRUE, FALSE, NULL); NULL = NULL evaluates to NULL (not TRUE); source of subtle bugs|value
CO12|Domain|set of permitted values for a column; defined by data type + constraints + check conditions; business rules encoded in domain|integrity
CO13|Integrity|correctness and consistency of data; entity integrity (PK not null), referential integrity (FK references valid PK), domain integrity (values in valid range), user-defined integrity (business rules)|property
CO14|ACID|atomicity, consistency, isolation, durability; properties guaranteeing reliable transaction processing; foundation of transactional databases|property
CO15|Relation (Mathematical)|subset of Cartesian product of domains; formal basis of relational model (Codd 1970); table is physical representation of relation|theory
CO16|Relational Algebra|procedural query language; set of operations on relations producing new relations; select (σ), project (π), join (⋈), union (∪), difference (-), Cartesian product (×)|theory
CO17|Cardinality (Relationship)|number of entities on each side of a relationship; one-to-one (1:1), one-to-many (1:N), many-to-many (M:N); determines FK placement and junction table need|design
CO18|Metadata|data about data; schema definitions, statistics (row count, value distribution, index info), access permissions, creation dates; stored in system catalog / data dictionary|system
CO19|Catalog (Data Dictionary)|system tables storing metadata; table definitions, column types, index definitions, constraint definitions, user privileges; queried by optimizer and administrators|system
CO20|Cursor|pointer into result set enabling row-by-row processing; server-side or client-side; forward-only or scrollable; resource-intensive for large results|access
CO21|View|virtual table defined by query; no data storage (unless materialized); simplifies complex queries; provides security layer (expose subset of data); schema abstraction|abstraction
CO22|Materialized View|view with cached results; physically stored; must be refreshed (on demand, periodic, or on change); trades storage for query speed; stale between refreshes|abstraction
CO23|Stored Procedure|precompiled named program stored in database; executes server-side; accepts parameters; encapsulates business logic; reduces network roundtrips; may modify data|logic
CO24|Trigger|procedural code automatically executed in response to data modification event (INSERT, UPDATE, DELETE); BEFORE or AFTER; row-level or statement-level; enforces complex business rules|logic
CO25|Sequence / Auto-Increment|mechanism generating unique sequential values; used for surrogate primary keys; gap-free not guaranteed (rollbacks, crashes skip values); monotonically increasing|mechanism
CO26|Collation|rules governing string comparison and sorting; determines case sensitivity, accent sensitivity, character ordering; locale-specific; affects WHERE, ORDER BY, UNIQUE, indexes|configuration

# data_model(id|name|definition|structure|strengths|weaknesses)
DM1|Relational Model|data organized into tables (relations) with rows and columns; relationships via foreign keys; schema-first; Codd 1970|tables, rows, columns; primary keys, foreign keys; normalized; SQL interface; ACID transactions|strong consistency; mature tooling; powerful query language (SQL); well-understood theory (relational algebra); referential integrity enforced|rigid schema (changes require migration); impedance mismatch with object-oriented code; horizontal scaling challenging; joins expensive at scale
DM2|Document Model|data stored as self-contained documents (JSON, BSON, XML); schema-flexible; documents can have nested structures and arrays|collections of documents; each document contains all related data; no joins (data denormalized within document); schema-on-read|flexible schema (evolve without migration); natural mapping to application objects; horizontal scaling easier (documents are independent units); good for hierarchical data|data duplication (denormalization); no referential integrity enforcement; complex queries across documents harder; consistency trade-offs (often eventual)
DM3|Key-Value Model|simplest model; key maps to opaque value (blob, string, JSON); no query on value content (only by key); hash-table semantics|key → value pairs; no schema for values; partitioning by key; O(1) lookup by key|extreme simplicity; highest throughput; easy horizontal scaling (partition by key hash); perfect for session stores, caches, configuration|no queries on values (full scan required unless secondary index added); no relationships; no transactions across keys (typically); limited to lookup by exact key
DM4|Graph Model|entities as nodes, relationships as edges; both can have properties; optimized for traversing connections|nodes (entities), edges (relationships), properties on both; index-free adjacency (each node stores direct pointers to neighbors)|natural for highly connected data; efficient traversal (O(1) per hop via index-free adjacency); flexible schema; relationships are first-class citizens|less efficient for bulk aggregation; fewer mature tools than relational; less standardized (Cypher, Gremlin, SPARQL); scaling traversal across partitions is hard
DM5|Columnar (Column-Family)|data stored by column rather than by row; column families group related columns; optimized for analytical queries reading few columns from many rows|column families; each row can have different columns (sparse); columns physically co-located on disk; wide rows possible|excellent for analytics (read only needed columns); high compression (similar values in column); fast aggregation; horizontal scaling (column families partitioned independently)|poor for row-level operations (must reconstruct row from columns); write-amplification for single-row updates; not ideal for OLTP; schema design differs significantly from relational
DM6|Time-Series Model|data organized around timestamp; each record has time, source identifier, and measurement values; optimized for append-heavy, time-ordered writes and time-range queries|time + source + values; append-only (rarely update/delete); automatic data retention policies; time-bucketed storage|extremely high write throughput; efficient time-range queries; built-in downsampling and retention; compression optimized for time-ordered data|narrow use case (time-stamped measurements); not general-purpose; limited join/relationship support; querying across sources less efficient than within source

# normalization(id|name|definition|rule|violation_consequence|example)
NM1|First Normal Form (1NF)|every column contains atomic (indivisible) values; no repeating groups; each row uniquely identifiable|no multi-valued attributes; no arrays in cells; each cell holds single value; table has primary key|repeating groups → variable-length rows, complex queries, update anomalies; violation: phone1, phone2, phone3 columns|violation: customer(id, name, phone1, phone2, phone3); fix: customer(id, name) + customer_phone(customer_id, phone)
NM2|Second Normal Form (2NF)|in 1NF and every non-key column depends on entire primary key (not just part of it); relevant when PK is composite|no partial dependencies; non-key attribute must depend on whole composite PK, not subset|partial dependency → update anomaly (change in one place not reflected in another); redundant data storage|violation: order_item(order_id, product_id, quantity, product_name) — product_name depends on product_id only; fix: separate product table
NM3|Third Normal Form (3NF)|in 2NF and no non-key column depends on another non-key column; no transitive dependencies|every non-key attribute depends only on PK, not on other non-key attributes|transitive dependency → update anomaly; changing intermediate value requires updating dependent values|violation: employee(id, department_id, department_name) — department_name depends on department_id, not employee id; fix: separate department table
NM4|Boyce-Codd Normal Form (BCNF)|every determinant is a candidate key; stronger than 3NF; handles edge cases where 3NF allows certain anomalies|for every functional dependency X→Y, X must be a superkey; if X determines Y, X must be able to uniquely identify every row|anomalies in rare cases where 3NF allows non-key determinants|rare in practice; occurs when table has overlapping composite candidate keys; decompose so every determinant is key
NM5|Fourth Normal Form (4NF)|in BCNF and no multi-valued dependencies; independent multi-valued facts about entity stored separately|if A→→B and A→→C are independent, separate into two tables; no independent multi-valued facts in same table|combinatorial explosion of rows to represent independent multi-valued facts; spurious tuples on join|violation: person(name, language, skill) where languages and skills are independent → must store every combination; fix: person_language + person_skill
NM6|Denormalization (Intentional)|deliberately violating normal forms to improve read performance; adding redundant data to avoid joins; controlled redundancy|store derived or duplicated data; accept update anomaly risk for faster reads; maintain consistency via application logic or triggers|must maintain redundant data on every update (or accept staleness); storage increase; write complexity increases; application must handle consistency|storing customer_name in order table (avoid join for display); storing computed totals; caching aggregated counts; read-heavy workloads with infrequent updates

# schema_design(id|name|definition|pattern|when_used)
SD1|Entity-Relationship (ER) Model|conceptual data model using entities (nouns), attributes (properties), and relationships (connections); Chen notation or Crow's Foot notation|entities → tables; attributes → columns; relationships → foreign keys or junction tables; cardinality (1:1, 1:N, M:N) guides FK placement|initial design phase; communication between business and technical stakeholders; conceptual before physical
SD2|One-to-One (1:1)|each row in table A relates to exactly one row in table B and vice versa|FK in either table (or same PK shared); or combine into single table unless separation justified (optional data, security, performance)|optional extension data (profile details separate from login); sensitive data isolation (salary in separate table with restricted access); performance (rarely accessed large columns in separate table)
SD3|One-to-Many (1:N)|each row in parent table relates to zero or more rows in child table; each child relates to exactly one parent|FK in child table references PK of parent; parent has no FK; most common relationship type|customer → orders; department → employees; post → comments; category → products; the default relationship pattern
SD4|Many-to-Many (M:N)|rows in table A relate to multiple rows in table B and vice versa; cannot be directly represented with FK|junction (bridge/associative) table with two FKs: one to each related table; junction table PK = composite of both FKs (or surrogate); junction table may have own attributes|student ↔ course (enrollment date as junction attribute); product ↔ tag; author ↔ book; actor ↔ movie; user ↔ role
SD5|Self-Referencing (Recursive)|table has FK referencing its own PK; entity related to itself; hierarchical or network within single entity type|FK column in same table: employee.manager_id → employee.id; category.parent_id → category.id; represents tree or hierarchy|organizational hierarchy (manager); bill of materials (component contains sub-components); threaded comments (reply_to_id); category tree; file system (folder contains folders)
SD6|Surrogate Key|system-generated artificial primary key (auto-increment integer, UUID); no business meaning; stable (never changes); simplifies joins|integer sequence or UUID; no business logic dependency; change business data without affecting relationships; always unique|when natural key is composite, changeable, long, or sensitive; most modern designs use surrogate keys; natural key preserved as unique constraint for business use
SD7|Natural Key|primary key derived from business data (SSN, email, ISBN, country code); meaningful; may change; may be composite|use actual business identifier as PK; no additional surrogate column needed; immediately meaningful in queries|when business identifier is guaranteed unique, stable, and compact; country codes; currency codes; standards-based identifiers; risk: business rules change, key becomes invalid
SD8|Composite Key|primary key consisting of multiple columns; each column alone is not unique but combination is|PK = (column_A, column_B); common in junction tables; child entity may include parent's PK in its own composite PK|junction tables (student_course: PK = student_id + course_id); any entity where identity requires multiple attributes; order_line (PK = order_id + line_number)
SD9|Polymorphic Relationship|single FK references rows in multiple different tables; the "type" column indicates which table|type column discriminates target; application must manage (no database-enforced referential integrity typically); or use separate FK columns (one per possible target), only one populated|comment.target_id + comment.target_type ('post', 'photo', 'video'); activity log referencing multiple entity types; notification referencing multiple source types; generally anti-pattern in strict relational design (no FK constraint possible)
SD10|Soft Delete|marking rows as deleted (is_deleted flag or deleted_at timestamp) rather than physically removing; logically invisible but physically present|add deleted_at column; all queries filter WHERE deleted_at IS NULL; can restore (undelete); referential integrity preserved; audit trail|when deletion must be reversible; audit requirements; legal retention; referential integrity concerns (cascading delete too destructive); risk: queries must always remember to filter; accumulates data
SD11|Temporal Table (Slowly Changing Dimension)|tracking how data changes over time; storing current and historical versions of each row|Type 1: overwrite (no history); Type 2: new row with effective dates (valid_from, valid_to); Type 3: previous value columns; Type 6: hybrid|tracking price changes; customer address history; employee role changes; regulatory compliance (what was the value at time X?); Type 2 most common for full history
SD12|Star Schema (Dimensional)|fact table at center surrounded by dimension tables; optimized for analytical queries; denormalized dimensions|fact table: FK to each dimension + measures (numeric values for aggregation); dimension tables: descriptive attributes; grain: one row per measured event|data warehouse; OLAP; business intelligence; optimized for aggregation queries (sum, count, avg grouped by dimension attributes); denormalized dimensions for fast joins; Kimball methodology
SD13|Snowflake Schema|star schema where dimension tables are normalized (dimension has FKs to sub-dimensions); more tables, more joins, less redundancy|fact → dimension → sub-dimension; normalized dimensions; more storage-efficient than star but slower queries (more joins)|when dimension data is large and redundant (geographic hierarchy: city → state → country → region); storage-constrained environments; when dimension data is shared across multiple facts

# storage(id|name|definition|mechanism|trade_offs)
SR1|Page (Block)|fundamental unit of storage and I/O; fixed-size block (typically 4KB, 8KB, or 16KB); data read/written in full pages; rows stored within pages|page contains header (metadata, free space pointer) + row data + free space; rows cannot span pages in most systems (or use overflow); page is unit of caching (buffer pool) and I/O|larger pages: fewer I/O operations for sequential reads, more wasted space from partial fill; smaller pages: less waste, more I/O operations; page size affects all performance characteristics
SR2|Heap (Unordered Storage)|rows stored in insertion order with no particular organization; new rows appended to first page with space; no clustering|fast insert (append to any free page); full table scan for any query without index; deleted rows leave holes (fragmentation); no ordering guarantee|fast writes; poor read performance without indexes; suitable for small tables, staging tables, append-only logging; most databases default to heap unless clustered index specified
SR3|Clustered Index (Index-Organized)|rows physically stored in index order (typically PK order); table IS the index; only one per table (physical order is singular)|B-tree leaf nodes contain actual row data; inserts into middle require page splits; range queries on clustering key are very fast (physically contiguous data); secondary indexes store clustering key as pointer|excellent range query performance on clustering key; only one clustering order per table; inserts in non-sequential order cause page splits and fragmentation; reorganization (REBUILD) needed periodically
SR4|Buffer Pool (Cache)|in-memory cache of database pages; reads check buffer pool first (cache hit avoids disk I/O); dirty pages (modified) written back to disk asynchronously|LRU or clock-based eviction; pages marked dirty on modification; checkpoint flushes dirty pages; larger buffer pool = fewer disk reads; warm-up time after restart|larger buffer pool dramatically improves read performance (working set in memory); memory-limited; cold start penalty; trade-off with OS page cache (double buffering); most impactful single performance parameter
SR5|Tablespace / Filegroup|logical grouping of physical storage files; tables and indexes assigned to tablespaces; enables separate management (backup, placement on different disks)|one or more data files per tablespace; tables can span files within tablespace; system tablespace for catalog; temp tablespace for sort/join overflow; user tablespace for application data|separating frequently accessed data on fast storage; isolating temp operations; backup granularity; storage growth management; platform-specific implementation
SR6|Row Storage (Row-Oriented)|each page contains complete rows; all columns of a row stored together; optimized for OLTP (accessing full rows)|page contains row headers + row data packed sequentially; each row has all columns adjacent in memory; read any column requires reading entire row (from page)|fast for single-row lookups and full-row operations; poor for analytics reading few columns from many rows (reads unused columns); most OLTP databases (PostgreSQL, MySQL, Oracle, SQL Server)
SR7|Column Storage (Column-Oriented)|each column stored separately; values of same column packed together; optimized for analytical queries reading few columns from many rows|each column stored in separate file or segment; row reconstruction requires joining columns by position; run-length encoding and dictionary encoding extremely effective (similar adjacent values)|excellent compression (10:1 common); analytical queries read only needed columns (less I/O); vectorized processing; poor for single-row operations (must read from every column file); OLAP systems (ClickHouse, Redshift, BigQuery, Parquet files)
SR8|Log-Structured Merge Tree (LSM)|write-optimized storage; writes go to in-memory buffer (memtable), periodically flushed to sorted immutable files (SSTables) on disk; background compaction merges files|writes: always sequential (append to memtable → flush → sequential write); reads: check memtable → check recent SSTables → older SSTables (bloom filters skip non-matching); compaction: merge overlapping SSTables, discard obsolete versions|extremely fast writes (sequential I/O only); write amplification from compaction; read amplification (may check multiple levels); space amplification (multiple versions until compacted); used by: LevelDB, RocksDB, Cassandra, HBase, CockroachDB
SR9|B-Tree (On-Disk)|balanced tree optimized for disk I/O; high branching factor (hundreds of children per node) minimizes tree height; nodes = pages; most common index and storage structure|root → internal nodes → leaf nodes; each node is one page; branching factor ~100-500 → 3-4 levels covers millions of rows (3-4 disk reads); leaf nodes linked for range scans; balanced: all leaves at same depth|read-optimized; O(log_B n) lookups where B is branching factor (very small in practice: 3-4 levels); random writes (page splits, updates in place); concurrent access via latching; dominant index structure for RDBMS; in-place updates (unlike LSM which appends)
SR10|Write-Ahead Log (WAL)|append-only sequential log recording every modification before it is applied to data pages; enables crash recovery; sequential writes are fast|every transaction writes changes to WAL first (sequential I/O); then modifies data pages in buffer pool (may be random I/O, but deferred); on crash: replay WAL to recover committed but unflushed changes|guarantees durability without requiring every write to flush data pages to disk; sequential writes much faster than random; WAL can be replicated for standby; WAL is the journal in journaling systems; trade-off: recovery time proportional to WAL size since last checkpoint
SR11|Checkpoint|process of flushing all dirty pages from buffer pool to disk and recording WAL position; creates known-good recovery point; limits crash recovery time|periodic or threshold-triggered; writes all modified pages to data files; records WAL position (LSN) of checkpoint; crash recovery starts from last checkpoint (not beginning of WAL)|without checkpoints: recovery replays entire WAL history (could be hours); frequent checkpoints: shorter recovery but more I/O during normal operation; balance: checkpoint interval determines recovery time vs performance impact
SR12|Data Compression|reducing physical storage size of data; row-level, page-level, or column-level; dictionary encoding, run-length encoding, LZ-family, delta encoding|page compression: compress entire page (transparent to queries); column compression: exploit data patterns (dictionary: map repeated values to short codes; run-length: consecutive same values stored as value + count; delta: store differences)|reduces I/O (less data to read from disk); reduces storage cost; increases CPU usage (decompress on read); column stores benefit most (homogeneous data compresses well); 2-10× compression typical; trade-off: CPU for I/O

# indexing(id|name|definition|structure|performance|trade_offs)
IX1|B-Tree Index|balanced tree with high branching factor; most common index type; supports equality and range queries; ordered|root → internal → leaf; keys in sorted order; leaf nodes linked (range scan); O(log n) search; branching factor ~100-500 per node (each node = one page)|lookup: O(log_B n) ≈ 3-4 page reads for millions of rows; range scan: O(log_B n + k) where k = result rows; maintains sorted order|overhead on write (insert may split nodes, update may relocate); storage overhead (index pages); each index maintained independently; diminishing returns with too many indexes; most versatile general-purpose index
IX2|Hash Index|hash table mapping key to page/row location; O(1) average lookup for exact match; no range support|key → hash(key) → bucket → row pointer; collision handling (chaining or probing); must handle growth (rehashing)|exact match: O(1) average, O(n) worst (hash collision); cannot support range queries, ORDER BY, LIKE prefix|very fast exact match; useless for ranges, ordering, partial matches; less common than B-tree (B-tree handles both equality and range); hash join uses hash index temporarily
IX3|Bitmap Index|bit vector per distinct value; each bit represents one row; bit is 1 if row has that value; efficient for low-cardinality columns|one bitmap per value; row N corresponds to bit N; AND/OR/NOT operations between bitmaps answer complex queries; compressed bitmaps (roaring, WAH) reduce space|extremely fast for combinations of low-cardinality filters (status = 'active' AND region = 'west'); compact for low cardinality; boolean operations on bitmaps|poor for high-cardinality columns (one bitmap per value); write-heavy workloads: update requires modifying multiple bitmaps; primarily OLAP / data warehouse; Oracle, some analytics engines
IX4|GiST / R-Tree (Spatial)|generalized search tree for multi-dimensional data; R-tree variant for spatial indexing; bounding rectangles enclose child entries|hierarchical bounding rectangles; search descends to rectangles overlapping query region; insert expands bounding rectangles; rebalancing for optimal packing|spatial range queries (find all within rectangle); nearest-neighbor (with priority queue); point-in-polygon; intersection|higher overhead than B-tree; overlap between bounding rectangles reduces selectivity; periodic rebalancing; specialized use case (geographic, geometric data)
IX5|Full-Text Index (Inverted Index)|maps each word (token) to list of documents/rows containing it; enables text search; tokenization + stemming + stop words|term → posting list (document IDs + positions); query: intersect/union posting lists; ranking (TF-IDF, BM25); tokenization (splitting text into words)|text search: find documents containing word(s); phrase search (position-aware); fuzzy matching; relevance ranking|storage overhead (every word indexed); update overhead (re-tokenize on change); language-dependent (stemming, stop words); not a B-tree replacement; specialized for text
IX6|Covering Index|index containing all columns needed to answer query; query satisfied entirely from index without accessing table (heap/clustered) data|index includes non-key columns (INCLUDE clause) or all queried columns happen to be in index; index-only scan|eliminates table access I/O; significant speedup for specific queries; turning two lookups (index + table) into one (index only)|larger index (more columns stored); more write overhead (more data to maintain); useful for specific high-frequency queries; diminishing returns if too broad
IX7|Partial Index (Filtered Index)|index on subset of rows matching a condition; smaller than full index; more efficient for queries matching the filter|CREATE INDEX ... WHERE condition; only rows matching condition are indexed; queries with matching WHERE clause use partial index|smaller index = less storage, faster scans, less write overhead; very effective for skewed data (index only active orders, not 99% historical)|only useful for queries matching the filter condition; optimizer must recognize applicability; not all databases support; excellent for soft-delete patterns (WHERE deleted_at IS NULL)
IX8|Composite Index (Multi-Column)|index on two or more columns; order of columns matters; leftmost prefix can be used independently|index on (A, B, C): usable for queries on A, (A,B), or (A,B,C); NOT usable for B alone or C alone (leftmost prefix rule); sort order: sorted by A, then B within A, then C within B|multi-column lookups without multiple index intersection; covering more query patterns with single index; compound sort orders|column order critical (leftmost prefix); not useful for non-leftmost columns alone; wider index = more write overhead; selectivity of first column matters most; choose most selective or most commonly filtered column first
IX9|Unique Index|index enforcing uniqueness constraint; prevents duplicate values; used for primary keys and unique constraints|same structure as B-tree index but insertion checks for existing value and rejects duplicates; NULL handling varies (some allow multiple NULLs, some don't)|constraint enforcement + index benefits; no additional structure vs regular index; just adds uniqueness check on write|same trade-offs as regular index plus: slight additional write overhead from uniqueness check; essential for data integrity
IX10|Index Selectivity|measure of how well an index discriminates; selectivity = distinct values / total rows; high selectivity (close to 1.0) = good for index; low selectivity (close to 0) = poor|boolean column (2 values / million rows = 0.000002 selectivity): poor for B-tree index; UUID column (million values / million rows = 1.0): excellent; status column (5 values): poor for B-tree, good for bitmap|high selectivity indexes narrow search quickly; low selectivity indexes scan too many rows (optimizer may choose full scan instead); selectivity guides index creation decisions|statistics must be up-to-date for optimizer to estimate selectivity correctly; data distribution changes over time; ANALYZE / UPDATE STATISTICS refreshes

# query_processing(id|name|definition|mechanism|significance)
QP1|Query Parser|converts SQL text into internal parse tree; checks syntax; resolves names (tables, columns) against catalog|lexer → tokens; parser → abstract syntax tree (AST); semantic analysis: resolve names, check types, verify permissions; error reporting for invalid SQL|first stage of query processing; syntax errors caught here; catalog lookups resolve table/column references; output: validated logical query representation
QP2|Query Optimizer|determines most efficient execution plan for parsed query; evaluates alternative plans; estimates cost; selects cheapest|cost-based: estimate I/O, CPU, memory, network cost for each plan; statistics (row count, value distribution, index selectivity) guide estimates; search space: join order, access method, join method|most impactful component for query performance; difference between good and bad plan can be 1000×+; optimizer quality separates database engines; statistics accuracy critical; sometimes wrong (hints override)
QP3|Execution Plan|ordered sequence of physical operations implementing the query; tree of operators: scan, filter, join, sort, aggregate|operators: table scan, index scan, index seek, nested loop join, hash join, merge join, sort, aggregate, filter; each operator consumes input and produces output; pipeline (row-at-a-time) or batch (block-at-a-time)|EXPLAIN / EXPLAIN ANALYZE reveals plan; reading execution plans is essential diagnostic skill; plan changes with data distribution (plan may be optimal for 100 rows, terrible for 10 million)
QP4|Table Scan (Full / Sequential)|read every row in table; no index used; O(n)|read every page sequentially; check each row against filter; no seeking; sequential I/O (efficient if scanning large portion of table)|appropriate when: no suitable index exists; query reads large percentage of table (>5-15%); table is small enough to fit in memory; often misidentified as always bad — for analytics reading 80% of rows, scan beats index
QP5|Index Seek|use index to navigate directly to matching rows; O(log n) + O(k) for k matching rows|traverse B-tree from root to leaf matching search key; follow leaf chain for range conditions; access table data via row pointer (unless covering index)|most efficient access for selective queries; requires index on filtered column(s); selectivity determines benefit (high selectivity = few rows = big benefit; low selectivity = many rows = may be slower than scan due to random I/O)
QP6|Nested Loop Join|for each row in outer table, scan inner table for matches; O(n×m) naive; O(n×log m) with index on inner|outer loop: iterate rows of one table; inner loop: for each outer row, seek matching rows in other table; index on inner table's join column makes inner loop O(log m) instead of O(m)|good for: small outer table with indexed inner table; inequality joins; best when outer is small and inner is indexed; poor when both tables large and no index (O(n×m) catastrophic)
QP7|Hash Join|build hash table on smaller table; probe with each row of larger table; O(n+m) average|build phase: hash join key of smaller table into in-memory hash table; probe phase: for each row of larger table, hash join key, look up in hash table; matches are join results|O(n+m) time; O(min(n,m)) memory for hash table; best for large equi-joins without indexes; requires memory for hash table (spills to disk if too large); cannot handle inequality joins (only equality)|good for: medium to large equi-joins; no index needed; one-time cost to build hash table; poor when: hash table doesn't fit in memory; non-equi-join
QP8|Merge Join (Sort-Merge)|sort both tables on join key then merge in single pass; O(n log n + m log m) for sorts; O(n+m) for merge|sort both inputs by join key (skip if already sorted via index); advance pointer through each in parallel; when keys match → output join result; efficient merge because both sorted|O(n log n + m log m) total; O(n+m) if already sorted; excellent when both inputs already sorted (clustered index on join key); supports inequality joins; memory-efficient (only need current row from each side)|requires sorted input (sort phase can be expensive if not already sorted); excellent for large sorted datasets; used automatically when index provides sort order
QP9|Query Statistics|data distribution information used by optimizer; row counts, distinct values, histograms, null counts, average row size|gathered by ANALYZE / UPDATE STATISTICS; histograms: frequency distribution of column values; enables cardinality estimation (how many rows will pass this filter?)|stale statistics → bad estimates → bad plans → slow queries; most common optimizer failure cause; should be updated after bulk data changes; auto-analyze helps but may lag behind rapid changes
QP10|Predicate Pushdown|moving filter conditions as close to data source as possible; filter early to reduce data flowing through query pipeline|push WHERE conditions into scan operators (filter while reading instead of reading then filtering); push conditions through joins (filter before joining); reduces intermediate result sizes|dramatically reduces data processed; essential optimization; applied automatically by optimizer; particularly important for distributed queries (filter before network transfer) and partitioned tables (skip non-matching partitions)

# transactions(id|name|definition|property|mechanism)
TN1|Atomicity|transaction is all-or-nothing; either all operations commit or all are rolled back; no partial transactions|if any part fails, entire transaction is undone; undo log records pre-modification values; rollback reverts all changes|undo log: store old values before modification; on rollback: apply undo records in reverse; on commit: undo records can be discarded (eventually); ensures consistency after failure
TN2|Consistency|transaction transforms database from one valid state to another; all constraints satisfied after commit; invariants preserved|constraints checked at commit (or statement-level depending on configuration); deferred constraints checked at commit; triggers may enforce complex consistency rules|constraint checking: PK uniqueness, FK validity, CHECK conditions, NOT NULL; if any violated: transaction rejected; application-level consistency: business rules beyond what constraints enforce
TN3|Isolation|concurrent transactions don't interfere with each other; each transaction appears to execute in isolation; reality: various isolation levels trade correctness for performance|serializable: strongest, transactions appear serial; snapshot: each transaction sees consistent snapshot; read committed: sees only committed data; read uncommitted: weakest, sees uncommitted data|implemented by locks (pessimistic) or MVCC (optimistic); higher isolation = more correct but slower (more blocking or more overhead); most databases default to read committed; serializable safest but most expensive
TN4|Durability|once transaction commits, changes survive any subsequent failure (crash, power loss, disk failure); committed data is permanent|WAL (write-ahead log) ensures committed changes recorded before acknowledgment; fsync forces data to non-volatile storage; replication provides additional durability|WAL + fsync: committed WAL records survive crash; recovery replays WAL from last checkpoint; battery-backed write cache reduces fsync latency; replication: multiple copies survive single-node failure
TN5|Savepoint|named intermediate point within transaction; partial rollback to savepoint without aborting entire transaction|SAVEPOINT name; ROLLBACK TO name; releases changes after savepoint but preserves changes before; nested savepoints possible|error handling within complex transactions; try an operation, rollback if fails, continue with alternative approach; avoids restarting entire transaction on partial failure
TN6|Two-Phase Commit (2PC)|protocol ensuring atomic commit across multiple participating databases/nodes; coordinator asks all participants to prepare; if all vote yes: commit; if any votes no: abort|phase 1 (prepare): coordinator asks each participant "can you commit?"; each participant writes changes to durable log, responds yes/no; phase 2 (commit/abort): if all yes → coordinator sends commit; any no → coordinator sends abort|ensures atomicity across distributed systems; blocking protocol (coordinator failure blocks participants); expensive (multiple round-trips, forced writes); used in distributed transactions, XA transactions; 3PC reduces blocking but adds complexity

# concurrency(id|name|definition|mechanism|trade_offs)
CC1|Pessimistic Concurrency (Locking)|prevent conflicts by acquiring locks before accessing data; other transactions wait or are rejected; mutual exclusion|shared lock (read lock): multiple readers allowed; exclusive lock (write lock): one writer, no readers; lock granularity: row, page, table, database; lock escalation: many row locks → table lock (efficiency)|guarantees correctness; deadlock possible (two transactions each waiting for other's lock); lock contention reduces concurrency; coarse granularity = less overhead but more contention; fine granularity = more overhead but more concurrency
CC2|Optimistic Concurrency (MVCC)|allow concurrent access without locks; detect conflicts at commit time; multi-version concurrency control: each transaction sees consistent snapshot|MVCC: each write creates new version of row; readers see version from their snapshot (no blocking); writers create new version (old version retained for active readers); garbage collection removes obsolete versions|readers never block writers; writers never block readers; excellent read performance; write conflicts detected at commit (one must retry); storage overhead (multiple versions until garbage collected); dominant concurrency control in modern databases (PostgreSQL, MySQL InnoDB, Oracle, CockroachDB)
CC3|Deadlock|two or more transactions each waiting for lock held by another; circular wait; no progress possible without intervention|T1 holds lock A, waits for B; T2 holds lock B, waits for A; circular dependency; detection: wait-for graph cycle detection; resolution: abort one transaction (victim selection)|detection: periodic or immediate wait-for graph analysis; prevention: lock ordering (always acquire in same order); timeout: abort if waiting too long; victim selection: abort transaction with least work done; retry aborted transaction
CC4|Lock Granularity|size of data unit protected by lock; row (finest), page, table, database (coarsest)|fine-grained (row): maximum concurrency, most overhead (many locks tracked); coarse-grained (table): minimum overhead, minimum concurrency (blocks entire table)|row-level: high concurrency, high memory for lock management; table-level: low overhead, severe contention; most databases use row-level with escalation to table when lock count exceeds threshold; page-level: middle ground
CC5|Isolation Level|degree to which transactions are isolated from each other; trade-off between correctness and performance|read uncommitted: dirty reads possible; read committed: no dirty reads (sees only committed); repeatable read: no dirty or non-repeatable reads; serializable: no anomalies (appears serial); snapshot: consistent point-in-time view|lower isolation = more concurrency, more anomalies; higher = less concurrency, fewer anomalies; read committed: most common default (practical balance); serializable: safest but most expensive; snapshot: popular (MVCC-based, high concurrency, consistent view)
CC6|Phantom Read|transaction re-executes query returning different set of rows because another transaction inserted/deleted matching rows between executions|T1 reads WHERE salary > 50000 (10 rows); T2 inserts new employee with salary 60000 and commits; T1 re-reads (11 rows); new "phantom" row appeared|prevented by serializable isolation or predicate locking (lock the WHERE condition, not individual rows); not prevented by repeatable read (which only locks existing rows); range locks or gap locks address this
CC7|Write Skew|two transactions each read a value, make decision based on it, and write different rows; neither sees other's write; result violates constraint that spans both writes|T1 and T2 each check: "at least one doctor on call"; each sees the other is on call; each removes themselves; result: no one on call; constraint violated without either transaction seeing incorrect data|occurs under snapshot isolation (each sees consistent snapshot but snapshots are stale relative to each other); prevented by serializable isolation; requires explicit application-level locking under snapshot; subtle and dangerous

# journaling(id|name|definition|mechanism|recovery)
JR1|Write-Ahead Logging (WAL)|every data modification recorded sequentially in log before being applied to data pages; log records are force-flushed to disk on commit|modification sequence: 1) write undo/redo record to WAL buffer; 2) modify data page in buffer pool; 3) on commit: flush WAL to disk (fsync); 4) data pages written to disk later (checkpoint); on crash: committed but unwritten data pages recovered from WAL|crash recovery: 1) find last checkpoint; 2) scan WAL forward from checkpoint; 3) REDO: reapply all committed transactions' changes to data pages; 4) UNDO: reverse all uncommitted transactions' changes; recovery time proportional to WAL since last checkpoint
JR2|Log Record|individual entry in WAL describing one modification; contains: LSN (log sequence number), transaction ID, operation type, before-image (undo), after-image (redo), page ID|before-image: value before modification (enables UNDO); after-image: value after modification (enables REDO); LSN: monotonically increasing identifier ordering log records; each page header stores LSN of last modification applied|UNDO record types: INSERT → delete; UPDATE → restore old value; DELETE → re-insert; REDO: opposite; physiological logging (page ID + offset + change) more efficient than logical logging (SQL-level)
JR3|Log Sequence Number (LSN)|monotonically increasing identifier assigned to each log record; establishes total order of all modifications; page LSN tracks which modifications applied|LSN on page header: if page LSN < log record LSN, record has not been applied (needs REDO); if page LSN ≥ log record LSN, already applied (skip); enables idempotent recovery (safe to replay)|essential for recovery correctness; determines which REDO records to apply; determines which UNDO records to reverse; checkpoint records LSN, establishing recovery starting point
JR4|Checkpoint (Journaling)|operation that establishes consistent recovery point; all dirty pages flushed; WAL position recorded; limits recovery time|fuzzy checkpoint: record list of dirty pages and their LSNs + oldest active transaction LSN; gradually flush pages; doesn't require stopping all activity; sharp checkpoint: flush everything, pause writes (simpler but blocking)|more frequent checkpoints: faster recovery, more I/O during normal operation; less frequent: longer recovery, less overhead; automatic: triggered by WAL size or time interval; balance: recovery time SLA vs performance impact
JR5|ARIES (Algorithm for Recovery and Isolation Exploiting Semantics)|most widely implemented WAL recovery algorithm; IBM research 1992; steal/no-force policy; three-phase recovery|steal: dirty pages can be written to disk before commit (requires UNDO capability); no-force: pages not required to be written to disk at commit (requires REDO capability); recovery: 1) Analysis (determine dirty pages and active transactions); 2) Redo (reapply all changes from log); 3) Undo (reverse uncommitted transactions)|steal: enables large transactions (not limited by buffer pool); no-force: fast commits (no synchronous data page writes, only WAL); three-phase recovery: handles all crash scenarios; CLR (Compensation Log Record) prevents repeated undo during nested recovery; dominant recovery algorithm
JR6|WAL Truncation|removing old WAL segments no longer needed for recovery; prevents unbounded WAL growth|WAL segments before oldest of: last checkpoint LSN, oldest active transaction start LSN, oldest replication consumer position can be truncated/archived|retention policy must consider: recovery needs (checkpoint frequency); replication needs (standby must receive all WAL); backup needs (point-in-time recovery requires continuous WAL chain); premature truncation = data loss potential

# replication(id|name|definition|mechanism|consistency_guarantee)
RP1|Primary-Replica (Master-Slave)|one primary accepts writes; replicas receive copy of changes; replicas serve reads; automatic failover may promote replica to primary|primary processes writes → WAL records generated → shipped to replicas → replicas apply WAL (replay) → replicas eventually consistent with primary; synchronous or asynchronous shipping|asynchronous: primary doesn't wait for replica (fast writes, possible data loss on primary failure); synchronous: primary waits for at least one replica to confirm (slower writes, no data loss on primary failure); semi-sync: wait for one, ship to all
RP2|Synchronous Replication|primary waits for replica(s) to acknowledge receipt (and optionally application) of WAL records before confirming commit to client|write path: primary writes WAL → ships to replica(s) → replica acknowledges → primary confirms commit; every committed transaction guaranteed to exist on replica(s)|zero data loss on primary failure (replica has all committed data); higher write latency (network round-trip added to every commit); replica failure blocks primary writes (or degrades to async); quorum-based: wait for majority
RP3|Asynchronous Replication|primary ships WAL to replicas without waiting for acknowledgment; primary confirms commit independently of replica status|write path: primary writes WAL and confirms commit → ships WAL to replicas in background → replicas apply when they can; replication lag: time between primary commit and replica application|lowest write latency (no waiting for replica); data loss window on primary failure (committed transactions not yet shipped or applied); replication lag varies (seconds typically, minutes under load); most common default
RP4|Logical Replication|replicates at logical level (row changes: insert, update, delete) rather than physical level (WAL byte stream); enables cross-version, cross-engine, selective replication|decode WAL into logical change events (insert into table X values...); ship logical events; receiver applies logically; can filter (replicate subset of tables); can transform (different schema on replica)|cross-version compatibility (doesn't require identical binary format); selective replication (specific tables/rows); enables ETL, data integration; higher overhead than physical (decoding + re-execution); conflict resolution needed for multi-primary
RP5|Physical Replication (Streaming)|replicate raw WAL byte stream; replica applies identical binary changes; requires identical version and architecture|WAL segments streamed continuously from primary to replica; replica replays byte-for-byte; exact physical copy maintained; used for hot standby (read replicas) and failover|simplest; lowest overhead; exact copy; fastest failover (replica is already up-to-date); requires identical database version and platform; cannot selectively replicate; all-or-nothing
RP6|Multi-Primary (Multi-Master)|multiple nodes accept writes; changes propagated between all nodes; conflicts possible when same row modified on different nodes simultaneously|each node is primary for writes; changes replicated to all other nodes; conflict detection: same row modified on two nodes between replication cycles; conflict resolution: last-writer-wins, merge, application-defined|highest write availability (any node accepts writes); conflict handling is fundamental challenge; last-writer-wins loses data silently; merge resolution application-specific; eventual consistency typically; used when write availability > consistency priority; Galera, CockroachDB (serializable), Spanner (serializable)
RP7|Consensus Replication (Raft/Paxos)|distributed consensus protocol ensures majority of nodes agree on each write; leader accepts writes; followers confirm; tolerates minority node failure|Raft: leader election → leader receives writes → appends to own log → sends to followers → majority acknowledge → committed → applied; leader failure → re-election; linearizable reads from leader|strong consistency (linearizable); tolerates f failures from 2f+1 nodes; higher write latency (majority must acknowledge); used by: etcd, CockroachDB, TiDB, YugabyteDB; Paxos: more general, more complex; Raft: easier to understand and implement
RP8|Change Data Capture (CDC)|capturing row-level changes (insert, update, delete) from database log and streaming to external consumers; database as event source|read WAL / transaction log; decode into change events; stream to message queue (Kafka), data warehouse, search index, cache; Debezium, Maxwell, logical decoding|decouples downstream systems from direct database queries; real-time data integration; event sourcing; populating read replicas, search indexes, caches; doesn't impact source database performance (reads log, doesn't query tables)

# partitioning(id|name|definition|mechanism|trade_offs)
PT1|Horizontal Partitioning (Sharding)|splitting table rows across multiple physical locations (partitions, shards); each partition holds subset of rows|partition key determines which partition receives each row; range (key ranges), hash (hash of key modulo partitions), list (key value lists), composite; each partition is independent database or table segment|enables scaling beyond single node; each partition smaller (faster queries within partition); write throughput scales with partition count; cross-partition queries expensive (scatter-gather); rebalancing on partition addition is disruptive; partition key choice is critical and difficult to change
PT2|Vertical Partitioning|splitting table columns across physical locations; frequently accessed columns together; rarely accessed separately|group columns by access pattern; hot columns (frequently read) on fast storage; cold columns (rarely read) on slower/cheaper storage; wide tables split into narrow focused tables|reduces I/O for queries needing few columns (read less data per row); different storage tiers for different access patterns; joining split tables adds overhead; related columns must be co-located (or join required)
PT3|Range Partitioning|partition key ranges define partition boundaries; all rows with key in range go to same partition|key range [0-999] → partition 1; [1000-1999] → partition 2; etc.; date ranges: partition per month/year; natural for time-series and sequential keys|efficient range queries within single partition; hot spot risk (newest partition receives all current writes); rebalancing: split full partition; uniform data distribution not guaranteed|good for: time-series (partition by month); sequential data; range queries common; bad for: uniform random keys (all partitions equally active, no locality benefit)
PT4|Hash Partitioning|hash function applied to partition key; hash value modulo partition count determines target partition; distributes evenly|partition = hash(key) mod N; uniform distribution regardless of key distribution; adding partitions requires rehashing (consistent hashing minimizes movement)|even distribution; no hot spots (if hash is good); range queries inefficient (adjacent keys on different partitions); rebalancing on adding/removing partitions; consistent hashing: only 1/N keys move when adding Nth partition|good for: uniform distribution needed; point queries; bad for: range queries; ordered iteration; change in partition count
PT5|Partition Pruning|query optimizer skips partitions that cannot contain matching rows; evaluates partition key condition against partition definitions|WHERE date >= '2024-01-01' AND date < '2024-02-01' on monthly partitioned table: only January 2024 partition scanned; all other partitions skipped entirely|massive performance improvement when applicable; requires WHERE clause on partition key; query must be expressed in terms optimizer can evaluate against partition boundaries|only works when query filters include partition key; complex expressions may prevent pruning; critical for partitioned table query performance; without pruning, partition table performs like single large table

# consistency(id|name|definition|guarantee|trade_off)
CN1|Strong Consistency (Linearizability)|every read returns most recently written value; all operations appear to occur in a single total order; equivalent to operating on single copy|once write confirmed, all subsequent reads from any node return updated value; implemented by synchronous replication + consensus; serializable isolation in distributed systems|highest correctness; simplest mental model; highest latency (must coordinate across nodes); lowest availability (node failure may block operations until quorum restored); CAP theorem: cannot have strong consistency + availability during partition
CN2|Eventual Consistency|if no new writes, all replicas converge to same value; temporary inconsistency allowed during propagation; time-bounded or unbounded|replicas may return stale data; convergence guaranteed but timing not (or loosely bounded); conflict resolution needed for concurrent updates; suitable for many read-heavy workloads where staleness is acceptable|highest availability; lowest latency (write locally, propagate later); most scalable; data may be stale; conflicts possible; requires application to tolerate inconsistency; DNS, social media feeds, shopping cart (Amazon Dynamo) use eventual consistency
CN3|Causal Consistency|operations causally related appear in same order everywhere; concurrent (unrelated) operations may appear in different order on different nodes|if A happened before B (and B could have seen A), then all nodes see A before B; concurrent events: no ordering guarantee; implemented by vector clocks or Lamport timestamps|stronger than eventual but weaker than linearizable; preserves intuitive cause-effect ordering; allows concurrent operations to be reordered (more concurrency than linearizable); natural model for many applications (conversation ordering)
CN4|Read-Your-Own-Writes|after writing, the same client always sees their own write on subsequent reads; other clients may not see it yet|client maintains session affinity to node that received write; or read-after-write token routes read to sufficiently up-to-date replica; or always read from primary for own data|prevents confusing user experience (update profile, refresh, see old profile); doesn't guarantee other users see update; implemented by sticky sessions, read tokens, or read-from-primary; minimum acceptable consistency for interactive applications
CN5|CAP Theorem|distributed system can guarantee at most two of three: Consistency, Availability, Partition tolerance; during network partition, must choose C or A|partition tolerance is non-negotiable in distributed systems (networks fail); choice is between C (reject requests during partition) and A (serve potentially stale data during partition); when no partition: both C and A possible|CP systems: reject writes during partition (correct but unavailable); AP systems: accept writes during partition (available but potentially inconsistent); PACELC: during partition choose A or C; else (normal operation) choose latency or consistency; practical systems offer tunable consistency
CN6|Quorum|minimum number of nodes that must participate for operation to succeed; ensures overlap between write set and read set guaranteeing consistency|write quorum W + read quorum R > N (total nodes): guarantees at least one node in read set participated in most recent write; typical: W = R = (N+1)/2 (majority); N=3, W=R=2|majority quorum: tolerates minority failure; sloppy quorum: relax to nearest available nodes (higher availability, weaker consistency); read/write quorum trade-off: lower W = faster writes, higher R needed for consistency (and vice versa); N=3 is minimum for tolerating one failure with majority quorum

# failure_modes(id|topic|mode|cause|consequence|prevention)
FM1|design|wrong cardinality|modeling 1:N as 1:1 or M:N as 1:N; not asking "can entity A have multiple B?" rigorously|data loss (can't store second phone number); schema redesign required; application breaks when assumption violated|interview domain experts: "can this EVER have more than one?"; model M:N unless proven otherwise; junction tables are cheap; redesign is expensive
FM2|design|premature denormalization|denormalizing before proving normalization is too slow; skipping normalization entirely; duplicating data without maintenance strategy|update anomalies (customer name updated in one table but not another); data inconsistency; debugging nightmare; trust in data erodes|normalize first (3NF minimum); measure performance; denormalize specific queries that demonstrate need; document every denormalization with update strategy; triggers or application logic to maintain consistency
FM3|indexing|missing index|query performs full table scan on large table; no index on frequently filtered or joined columns; detected by slow query log|slow queries; degraded application performance; cascading timeouts; user-visible latency; database CPU and I/O saturation|monitor slow query log; EXPLAIN every significant query; create indexes on columns in WHERE, JOIN, ORDER BY; review execution plans; don't over-index (each index costs on write)
FM4|indexing|too many indexes|every column indexed; compound indexes with many columns; indexes never reviewed for utility|write performance degraded (every INSERT/UPDATE/DELETE modifies all indexes); storage bloat; optimizer confusion (too many choices); index maintenance overhead dominates|review index usage statistics; drop unused indexes; consolidate overlapping indexes; each index must justify its existence with measurable query improvement; wide composite indexes rarely justified
FM5|concurrency|deadlock|two transactions each hold lock the other needs; circular wait; no progress without intervention|one transaction aborted (victim); application must retry; potential data loss if retry logic absent; under high concurrency: frequent deadlocks degrade throughput|consistent lock ordering (always lock tables/rows in same order); short transactions (hold locks briefly); deadlock detection + automatic retry; reduce lock granularity; use optimistic concurrency (MVCC) where possible
FM6|transactions|long-running transaction|transaction open for minutes/hours; holds locks (pessimistic) or prevents MVCC cleanup (optimistic); may be unintended (forgotten COMMIT)|blocks other transactions (lock-based); prevents garbage collection of old row versions (MVCC: bloat); WAL cannot be truncated (replication lag); eventually causes resource exhaustion|monitor transaction duration; set statement_timeout and idle_in_transaction_session_timeout; break large operations into batches; explicit COMMIT after each logical unit; alert on long-running transactions
FM7|replication|replication lag|replica falling behind primary; causes: slow replica, network latency, write spike on primary, heavy queries on replica|stale reads from replica; application sees old data; read-after-write inconsistency (write to primary, read from lagging replica returns old value); monitoring shows growing lag|monitor replication lag continuously; route reads to primary for consistency-critical queries; use synchronous replication for zero-lag guarantee (at latency cost); scale replica hardware to match primary write rate; avoid heavy analytical queries on replica serving application reads
FM8|partitioning|hot partition|one partition receives disproportionate traffic; uneven distribution; temporal hot spot (current month partition); popular key hot spot|that partition becomes bottleneck; other partitions idle; overall throughput limited by single partition; latency spikes on hot partition|hash partitioning for even distribution; avoid monotonically increasing partition keys for hash (use UUID or random prefix); pre-split anticipated hot partitions; separate hot and cold data; adaptive partitioning (auto-split hot partitions)
FM9|storage|data corruption|hardware failure (bit rot, disk sector failure); software bug; incomplete write (power loss during write); cosmic ray bit flip|incorrect query results; crashes; cascading corruption if corrupted data propagated to replicas or backups; potentially silent (detected much later)|checksums on pages (verify on read); WAL ensures atomic writes (partial write detectable and recoverable); ECC memory; RAID for disk redundancy; replication (multiple copies); regular VERIFY / CHECKSUM operations; backups tested by restoration
FM10|schema|schema migration failure|ALTER TABLE on large table takes hours; blocks writes during migration; migration script has errors; rollback impossible|downtime during migration; data loss if migration error; application errors if schema and code out of sync; blocked writes cause timeouts throughout application|online schema migration tools (pt-online-schema-change, gh-ost, pg_repack); test migrations on production-size copy; backward-compatible changes (add column before code deploys, remove column after); feature flags; rollback plan for every migration
FM11|recovery|point-in-time recovery failure|WAL chain broken (gap in archived WAL segments); base backup corrupt; WAL archived incompletely; tested recovery procedure doesn't match production|cannot recover to arbitrary point; data loss up to last valid backup; recovery takes hours/days instead of minutes|continuous WAL archiving with monitoring (alert on gaps); regular base backups; test recovery procedure regularly (restore to standby and verify); document and automate recovery steps; monitor archive success
FM12|NULL|NULL handling errors|comparing with = instead of IS NULL; aggregate functions silently ignoring NULLs; unexpected NULL propagation through expressions (NULL + 5 = NULL)|incorrect query results; missing rows in joins; wrong counts and averages; subtle bugs that pass testing (test data rarely has NULLs in right places)|use IS NULL / IS NOT NULL for NULL comparison; understand three-valued logic; COALESCE(column, default) for NULL substitution; NOT NULL constraints where appropriate; COUNT(*) vs COUNT(column) — COUNT(column) excludes NULLs

# distinctions(id|side_a|side_b|key_asymmetry)
DI1|OLTP (Online Transaction Processing)|OLAP (Online Analytical Processing)|OLTP: many short transactions; read/write individual rows; normalized schema; low latency critical; row storage; B-tree indexes; OLAP: few complex queries; read many rows, few columns; star/snowflake schema; throughput critical; columnar storage; bitmap indexes; different optimization strategies
DI2|Row Storage|Column Storage|row: all columns of row stored together; fast for full-row access (OLTP); reads unused columns; poor compression (mixed types); column: each column stored separately; fast for few-column scans (OLAP); excellent compression (homogeneous data); slow for full-row reconstruction; fundamental storage decision
DI3|Normalized|Denormalized|normalized: no redundancy; data in one place; update anomalies eliminated; more joins required; write-optimized; denormalized: controlled redundancy; fewer joins; read-optimized; update anomalies possible; must maintain consistency of duplicated data; normalize first, denormalize for measured performance needs
DI4|Physical Schema|Logical Schema|logical: tables, columns, relationships, constraints; what the data means; independent of storage; physical: files, pages, indexes, partitions, tablespaces; how data is stored; dependent on engine; same logical schema can have many physical implementations
DI5|Pessimistic Concurrency|Optimistic Concurrency|pessimistic (locking): assume conflicts likely; lock before access; prevent conflict; wait or abort if locked; deadlock possible; optimistic (MVCC): assume conflicts rare; proceed without locking; detect conflict at commit; retry if conflict; no deadlocks; higher concurrency
DI6|Synchronous Replication|Asynchronous Replication|synchronous: primary waits for replica acknowledgment; zero data loss; higher latency; replica failure affects primary; asynchronous: primary doesn't wait; possible data loss on primary failure; lower latency; replica failure doesn't affect primary; most common default; trade-off: durability vs performance
DI7|Horizontal Partitioning|Vertical Partitioning|horizontal: split rows across partitions (different rows in different partitions); same columns everywhere; enables sharding; vertical: split columns across partitions (different columns in different locations); same rows everywhere; enables tiered storage; horizontal = sharding; vertical = column splitting
DI8|Primary Key|Foreign Key|PK: identifies this row uniquely within this table; one per table; never null; defines entity identity; FK: references PK of another table; many per table; may be null (optional relationship); defines relationship; PK is about identity; FK is about connection
DI9|B-Tree|LSM Tree|B-tree: read-optimized; in-place updates; O(log n) read and write; random I/O on write; dominant for OLTP; LSM: write-optimized; append-only writes; sequential I/O; read amplification (check multiple levels); compaction overhead; dominant for high-write workloads; each has trade-offs in read vs write performance
DI10|Strong Consistency|Eventual Consistency|strong: every read sees most recent write; single truth; coordination required; higher latency; lower availability during failures; eventual: reads may return stale data; convergence over time; no coordination needed; lower latency; higher availability; application must tolerate staleness; choose based on correctness vs performance requirements
DI11|Logical Replication|Physical Replication|logical: row-level changes decoded and replicated; cross-version compatible; selective; higher overhead; transformation possible; physical: raw WAL bytes streamed; same version/platform required; all-or-nothing; lower overhead; exact copy; faster failover; logical = flexibility; physical = simplicity and speed
DI12|Surrogate Key|Natural Key|surrogate: system-generated (auto-increment, UUID); meaningless; stable; compact (integer); natural: derived from business data; meaningful; may change; may be composite; surrogate = stability and simplicity; natural = meaning and uniqueness from business; most modern designs prefer surrogate with natural key as unique constraint
DI13|Heap Storage|Clustered Storage|heap: rows in insertion order; no physical sorting; fast inserts; slow range queries; no clustering benefit; clustered: rows physically sorted by index key; one clustering order per table; excellent range queries on clustering key; inserts into middle cause page splits; heap = write-fast; clustered = read-fast (for range on clustering key)
DI14|View|Materialized View|view: virtual table; query executed on access; always current; no storage cost; may be slow (complex underlying query); materialized: cached query result; stored on disk; fast reads; stale between refreshes; storage cost; must refresh; view = current but slow; materialized = fast but potentially stale

# relationships(from|rel|to)
# Foundation → structure
CO1|structured_by|CO2
CO2|describes|CO3
CO3|implemented_by|DM1,DM2,DM3,DM4,DM5,DM6
CO4|fundamental_to|DM1
CO5|instance_of|CO4
CO6|component_of|CO4
CO7|ensures|CO13
CO8|connects|CO4
CO9|enforces|CO13
CO10|constrains|CO6
CO11|complicates|CO9,CO16
CO14|guarantees|CO13
CO15|formalizes|CO4

# Schema design
SD1|models|CO2
SD2|specializes|CO17
SD3|specializes|CO17
SD4|specializes|CO17
SD5|specializes|CO17
SD6|simplifies|CO7
SD7|leverages|CO12
SD8|composes|CO7
SD9|relaxes|CO8
SD10|simulates|CO5
SD11|historicizes|CO5
SD12|optimizes|QP2
SD13|normalizes|SD12

# Normalization chain
NM1|precedes|NM2
NM2|precedes|NM3
NM3|precedes|NM4
NM4|precedes|NM5
NM6|relaxes|NM3

# Storage → performance
SR1|unit_of|SR4,SR9
SR2|default_for|CO4
SR3|orders|CO4
SR4|caches|SR1
SR6|optimizes|DI1
SR7|optimizes|DI1
SR8|optimizes|SR9
SR9|implements|IX1
SR10|enables|TN4,JR1
SR11|bounds|JR1
SR12|reduces|SR1

# Indexing
IX1|built_on|SR9
IX2|specializes|IX1
IX3|specializes|IX1
IX4|specializes|IX1
IX5|specializes|IX1
IX6|extends|IX1
IX7|restricts|IX1
IX8|extends|IX1
IX9|constrains|IX1
IX10|measures|IX1

# Query processing chain
QP1|precedes|QP2
QP2|produces|QP3
QP3|contains|QP4,QP5,QP6,QP7,QP8
QP4|alternative_to|QP5
QP6|type_of|QP3
QP7|type_of|QP3
QP8|type_of|QP3
QP9|informs|QP2
QP10|optimizes|QP3

# Transaction properties
TN1|component_of|CO14
TN2|component_of|CO14
TN3|component_of|CO14
TN4|component_of|CO14
TN1|implemented_by|JR1
TN3|implemented_by|CC1,CC2
TN4|implemented_by|SR10
TN5|modifies|TN1
TN6|extends|TN1

# Concurrency
CC1|alternative_to|CC2
CC2|enables|CC5
CC3|threatens|CC1
CC4|tunes|CC1
CC5|levels|TN3
CC6|violates|CC5
CC7|violates|CC5

# Journaling
JR1|records|JR2
JR2|identified_by|JR3
JR3|orders|JR2
JR4|bounds|JR1
JR5|implements|JR1
JR6|manages|JR1

# Replication
RP1|fundamental_to|CO1
RP2|specializes|RP1
RP3|specializes|RP1
RP4|alternative_to|RP5
RP5|alternative_to|RP4
RP6|extends|RP1
RP7|strengthens|RP1
RP8|derives_from|JR1

# Partitioning
PT1|scales|CO4
PT2|alternative_to|PT1
PT3|specializes|PT1
PT4|specializes|PT1
PT5|optimizes|PT1

# Consistency
CN1|strongest_of|CN1,CN2,CN3
CN2|weakest_of|CN1,CN2,CN3
CN3|intermediate|CN1,CN2
CN4|specializes|CN1
CN5|constrains|CN1,CN2
CN6|implements|CN1

# Replication → consistency
RP2|guarantees|CN1
RP3|provides|CN2
RP6|requires|CN2
RP7|guarantees|CN1

# Storage → replication
SR10|enables|RP1,RP5,RP8
JR1|enables|RP5

# Failure → prevention
FM1|prevented_by|SD1,SD3,SD4
FM2|prevented_by|NM3,NM6
FM3|prevented_by|IX1,QP9
FM4|prevented_by|IX10,QP9
FM5|prevented_by|CC1,CC4
FM6|prevented_by|TN5
FM7|prevented_by|RP2,CN4
FM8|prevented_by|PT4
FM9|prevented_by|SR10,JR1
FM10|prevented_by|CO2
FM11|prevented_by|JR4,JR6
FM12|prevented_by|CO11,CO9

# Distinction mappings
DI1|distinguishes|SR6,SR7
DI2|distinguishes|SR6,SR7
DI3|distinguishes|NM3,NM6
DI4|distinguishes|CO2
DI5|distinguishes|CC1,CC2
DI6|distinguishes|RP2,RP3
DI7|distinguishes|PT1,PT2
DI8|distinguishes|CO7,CO8
DI9|distinguishes|SR9,SR8
DI10|distinguishes|CN1,CN2
DI11|distinguishes|RP4,RP5
DI12|distinguishes|SD6,SD7
DI13|distinguishes|SR2,SR3
DI14|distinguishes|CO21,CO22

# decode_legend
# id_prefixes: CO=concept, DM=data_model, NM=normalization, SD=schema_design, SR=storage, IX=indexing, QP=query_processing, TN=transaction, CC=concurrency, JR=journaling, RP=replication, PT=partitioning, CN=consistency, FM=failure_mode, DI=distinction
# rel_types: structured_by|describes|implemented_by|fundamental_to|instance_of|component_of|ensures|connects|enforces|constrains|complicates|guarantees|formalizes|models|specializes|simplifies|leverages|composes|relaxes|simulates|historicizes|optimizes|normalizes|precedes|unit_of|default_for|orders|caches|enables|bounds|reduces|built_on|restricts|extends|measures|produces|contains|alternative_to|type_of|informs|modifies|levels|threatens|tunes|violates|records|identified_by|manages|scales|intermediate|strongest_of|weakest_of|implements|provides|requires|derives_from|prevented_by|distinguishes
# ACID: Atomicity (all or nothing), Consistency (valid states only), Isolation (concurrent transactions don't interfere), Durability (committed = permanent)
# CAP: Consistency (all nodes see same data), Availability (every request receives response), Partition tolerance (system operates despite network partitions); choose 2 of 3 during partition
# LSN: Log Sequence Number; monotonically increasing; enables idempotent recovery; every log record and every page has one
# MVCC: Multi-Version Concurrency Control; readers see snapshot; writers create new versions; garbage collection removes obsolete versions; dominant concurrency model
# confidence: synthetic domain knowledge — not extracted from a single source document

# relation_mapping(doc_rel|canonical_rel|notes)
structured_by|determined_by|database structured by schema = determined_by schema
describes|models|schema describes data model = models
implemented_by|implements|inverse; data model implemented by relational = relational implements data model
fundamental_to|foundation_for|table fundamental to relational model = foundation_for
instance_of|instance_of|exact match
component_of|part_of|column is component of table = part_of
ensures|validates|primary key ensures integrity = validates
connects|connects_to|foreign key connects tables; symmetric
enforces|validates|constraint enforces integrity = validates
constrains|constrains|exact match
complicates|degrades|NULL complicates constraints = degrades clarity
guarantees|enables|ACID guarantees integrity = enables
formalizes|models|relation formalizes table = models
models|models|exact match
specializes|specializes|exact match
simplifies|simplifies|exact match
leverages|requires|natural key leverages domain = requires domain validity
composes|composed_of|composite key composes primary key = composed_of parts
relaxes|mitigated_by|inverse; polymorphic relaxes FK = FK constraint mitigated_by polymorphic pattern
simulates|models|soft delete simulates deletion = models deletion
historicizes|extends|temporal table historicizes row = extends with time dimension
optimizes|enables|star schema optimizes optimizer = enables better plans
normalizes|specializes|snowflake normalizes star schema = specializes star
precedes|precedes|exact match
unit_of|part_of|page is unit of buffer pool = part_of
default_for|implements|heap is default for table = implements default storage
orders|organizes|clustered index orders table = organizes
caches|maintains|buffer pool caches pages = maintains in memory
enables|enables|exact match
bounds|constrains|checkpoint bounds WAL recovery = constrains
reduces|simplifies|compression reduces page size = simplifies storage
built_on|depends_on|B-tree index built on B-tree storage = depends_on
restricts|constrains|partial index restricts scope = constrains
extends|extends|exact match
measures|inspects|selectivity measures index = inspects discrimination
produces|produces|exact match
contains|contains|exact match
alternative_to|alternative_to|exact match; symmetric
type_of|specializes|nested loop is type of join = specializes
informs|enables|statistics informs optimizer = enables good plans
modifies|influences|savepoint modifies atomicity = influences behavior
levels|regulates|isolation levels regulate isolation = regulates
threatens|threatens|exact match
tunes|regulates|lock granularity tunes locking = regulates
violates|violates|exact match
records|contains|WAL records log entries = contains
identified_by|determined_by|log record identified by LSN = determined_by LSN
manages|manages|exact match
scales|extends|partitioning scales table = extends capacity
intermediate|connects_to|causal consistency intermediate between strong and eventual = connects_to
strongest_of|generalizes|strong consistency generalizes all weaker levels
weakest_of|specializes|eventual consistency specializes with fewest guarantees
implements|implements|exact match
provides|produces|async replication provides eventual consistency = produces
requires|requires|exact match
derives_from|derived_from|CDC derives from WAL = derived_from
prevented_by|mitigated_by|failure prevented by mechanism = mitigated_by
distinguishes|distinguishes|exact match
