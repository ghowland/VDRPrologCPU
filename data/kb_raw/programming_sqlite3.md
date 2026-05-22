# SQLITE3 — COMPLETE QUERY SYNTAX AND USAGE — VDR-COMPACT
# Format: pipe-delimited tables, ID refs, Prolog-aligned.
# Read order: foundations → data_types → operators → ddl → dml → select_clauses → joins → subqueries → aggregation → window_functions → expressions → indexes → transactions → pragmas → json → fts → cte → upsert → views → triggers → constraints → functions → date_time → runbooks → anti_patterns → rules → relationships → section_index

# foundations(id|concept|definition|significance)
FD1|SQLite|self-contained, serverless, zero-configuration, transactional SQL database engine|single file = entire database; no daemon, no setup, no DBA; most deployed database in the world (~1 trillion databases)
FD2|file-based storage|entire database in one ordinary file on disk|portable (copy the file), atomic (journaling protects against corruption), zero-admin
FD3|type affinity|SQLite uses type affinity not strict typing — any column can hold any type (unless STRICT mode)|5 affinities: TEXT, NUMERIC, INTEGER, REAL, BLOB — value type determined at insertion, not column definition
FD4|manifest typing|the type is a property of the value, not the column|column declared INTEGER can hold TEXT — the declaration is a hint (affinity), not a constraint (unless STRICT)
FD5|rowid|every table (except WITHOUT ROWID) has implicit 64-bit signed integer primary key|INTEGER PRIMARY KEY is an alias for rowid — fastest access path; autoincrement is NOT the same as rowid alias
FD6|WAL mode|write-ahead logging — readers don't block writers, one writer at a time|default is journal (rollback); WAL = better concurrency for read-heavy workloads; set via PRAGMA journal_mode=WAL
FD7|single writer|only one connection can write at any time — readers can proceed concurrently (WAL mode)|not a limitation for most use cases — SQLite targets embedded/local, not high-concurrency server
FD8|ACID compliance|atomic, consistent, isolated, durable — even on power loss or crash|journaling (rollback or WAL) ensures no partial writes; fsync on commit
FD9|zero-configuration|no server process, no config file, no user management, no network setup|open the file, execute SQL — that's it
FD10|SQL dialect|mostly SQL-92 with extensions — some features absent (RIGHT/FULL OUTER JOIN added 3.39+, no stored procedures, no GRANT/REVOKE)|check version for feature availability; missing features usually have workarounds

# data_types(id|affinity|storage_classes|declaration_examples|notes)
DT1|TEXT|TEXT (UTF-8, UTF-16)|TEXT, VARCHAR(255), CHAR(10), CLOB|all text stored as UTF-8 internally; length in declaration is ignored (no truncation)
DT2|NUMERIC|INTEGER, REAL, or TEXT depending on value|NUMERIC, DECIMAL(10,2), BOOLEAN, DATE, DATETIME|BOOLEAN stored as 0/1 integer; DATE/DATETIME stored as TEXT (ISO 8601), REAL (Julian day), or INTEGER (Unix epoch)
DT3|INTEGER|INTEGER (1,2,3,4,6, or 8 bytes depending on magnitude)|INT, INTEGER, TINYINT, SMALLINT, MEDIUMINT, BIGINT, INT2, INT8|variable-length storage — small values use fewer bytes; INTEGER PRIMARY KEY = rowid alias
DT4|REAL|REAL (8-byte IEEE 754 float)|REAL, DOUBLE, FLOAT|standard double precision floating point
DT5|BLOB|BLOB (stored as-is)|BLOB, no affinity if no type name given|arbitrary binary data; length unlimited (up to SQLITE_MAX_LENGTH, default ~1GB)
DT6|NULL|NULL (absence of value)|—|NULL is not zero, not empty string, not false — NULL compared to anything is NULL (ternary logic)
DT7|STRICT mode|table declared with STRICT keyword enforces declared types|CREATE TABLE t(x INT, y TEXT) STRICT|added in 3.37.0 (2021-11-27); ANY type allows any value in STRICT tables

# operators(id|category|operators|precedence_notes)
OP1|arithmetic|+ - * / %|standard; integer division when both operands integer; % is modulo
OP2|comparison|= == != <> < > <= >= IS IS NOT|= and == are identical; IS handles NULL (NULL IS NULL = true); <> and != identical
OP3|logical|AND OR NOT|NOT highest, then AND, then OR; use parentheses for clarity
OP4|bitwise|& \| ~ << >>|bitwise AND, OR, NOT, left shift, right shift
OP5|string||| (concatenation)|'hello' \|\| ' ' \|\| 'world' → 'hello world'
OP6|BETWEEN|x BETWEEN a AND b|equivalent to x >= a AND x <= b (inclusive both ends)
OP7|IN|x IN (a, b, c) or x IN (subquery)|membership test; NULL handling: if x is NULL, result is NULL
OP8|LIKE|x LIKE pattern [ESCAPE char]|% = any sequence, _ = any single char; case-insensitive for ASCII by default
OP9|GLOB|x GLOB pattern|Unix-style: * = any sequence, ? = any char; case-sensitive always
OP10|IS NULL / IS NOT NULL|x IS NULL, x IS NOT NULL|the only correct NULL test — x = NULL is always NULL, never true
OP11|EXISTS|EXISTS (subquery)|true if subquery returns any rows
OP12|CASE|CASE WHEN cond THEN val [WHEN...] [ELSE val] END|inline conditional — also: CASE expr WHEN val THEN result
OP13|CAST|CAST(expr AS type)|explicit type conversion: CAST('123' AS INTEGER), CAST(456 AS TEXT)
OP14|COLLATE|expr COLLATE collation_name|BINARY (default, byte-comparison), NOCASE (case-insensitive ASCII), RTRIM (trailing spaces ignored)
OP15|unary|+ - ~ NOT|unary plus (no-op), unary minus (negate), bitwise NOT, logical NOT

# ddl(id|statement|syntax|description|notes)
DD1|CREATE TABLE|CREATE [TEMP] TABLE [IF NOT EXISTS] name (col_def [, col_def]* [, table_constraint]*) [STRICT] [WITHOUT ROWID]|define new table with columns and constraints|IF NOT EXISTS prevents error if table exists; TEMP tables exist only for connection lifetime
DD2|column definition|name [type_name] [column_constraint]*|type_name determines affinity; constraints: PRIMARY KEY, NOT NULL, UNIQUE, CHECK, DEFAULT, REFERENCES, COLLATE, GENERATED ALWAYS AS|DEFAULT accepts literal, expression, or (CURRENT_TIMESTAMP etc.)
DD3|ALTER TABLE|ALTER TABLE name RENAME TO new_name \| RENAME COLUMN old TO new \| ADD COLUMN col_def \| DROP COLUMN name|modify existing table|cannot change column type, cannot add PRIMARY KEY; DROP COLUMN added 3.35.0
DD4|DROP TABLE|DROP TABLE [IF EXISTS] name|remove table and all data|IF EXISTS prevents error; cascades to indexes and triggers on that table
DD5|CREATE INDEX|CREATE [UNIQUE] INDEX [IF NOT EXISTS] name ON table (col [ASC\|DESC] [, col]*) [WHERE expr]|create index for faster queries|partial index with WHERE clause — only indexes rows matching condition; UNIQUE enforces uniqueness
DD6|DROP INDEX|DROP INDEX [IF EXISTS] name|remove index|does not affect data
DD7|CREATE VIEW|CREATE [TEMP] VIEW [IF NOT EXISTS] name [(col_list)] AS select_stmt|named query — virtual table|views are re-executed each time queried; cannot INSERT into views (unless trigger-backed)
DD8|DROP VIEW|DROP VIEW [IF EXISTS] name|remove view definition|—
DD9|CREATE TRIGGER|CREATE [TEMP] TRIGGER [IF NOT EXISTS] name [BEFORE\|AFTER\|INSTEAD OF] [INSERT\|UPDATE [OF col]\|DELETE] ON table [FOR EACH ROW] [WHEN expr] BEGIN stmt; [stmt;]* END|automatic action on data change|INSTEAD OF only for views; NEW and OLD pseudo-tables reference new/old row values
DD10|DROP TRIGGER|DROP TRIGGER [IF EXISTS] name|remove trigger|—
DD11|CREATE VIRTUAL TABLE|CREATE VIRTUAL TABLE name USING module(args)|extend SQLite with custom table implementations|FTS5 (full-text), rtree (spatial), json_each (JSON), csv, etc.

# dml(id|statement|syntax|description|notes)
DM1|INSERT|INSERT [OR conflict] INTO table [(col_list)] VALUES (expr_list) [, (expr_list)]*|add rows|conflict: ABORT (default), ROLLBACK, FAIL, IGNORE, REPLACE
DM2|INSERT ... SELECT|INSERT [OR conflict] INTO table [(col_list)] SELECT ...|insert from query result|column count must match
DM3|UPDATE|UPDATE [OR conflict] table SET col=expr [, col=expr]* [FROM ...] [WHERE expr] [ORDER BY ... LIMIT ...]|modify existing rows|UPDATE FROM added 3.33.0; ORDER BY + LIMIT requires compile flag
DM4|DELETE|DELETE FROM table [WHERE expr] [ORDER BY ... LIMIT ...]|remove rows|without WHERE deletes all rows; ORDER BY + LIMIT requires compile flag
DM5|REPLACE|REPLACE INTO table [(col_list)] VALUES (expr_list)|insert or replace on PK/UNIQUE conflict|equivalent to INSERT OR REPLACE; deletes conflicting row then inserts — triggers DELETE + INSERT, not UPDATE
DM6|UPSERT|INSERT INTO table (...) VALUES (...) ON CONFLICT (col) DO UPDATE SET col=expr [WHERE expr] \| DO NOTHING|insert or update on conflict — added 3.24.0|DO UPDATE can reference excluded.col for the would-be-inserted values; WHERE on DO UPDATE filters which conflicts update

# select_clauses(id|clause|syntax|description|execution_order)
SL1|SELECT|SELECT [DISTINCT\|ALL] expr [AS alias] [, expr]*|column list and expressions|5th (after FROM, WHERE, GROUP BY, HAVING)
SL2|FROM|FROM table_or_subquery [join_clause]*|data source — tables, subqueries, CTEs, virtual tables|1st — determines working set
SL3|WHERE|WHERE expr|row-level filter before grouping|2nd — filters individual rows
SL4|GROUP BY|GROUP BY expr [, expr]* [HAVING expr]|partition rows into groups for aggregation|3rd — creates groups
SL5|HAVING|HAVING expr|group-level filter after aggregation|4th — filters groups (requires GROUP BY)
SL6|ORDER BY|ORDER BY expr [ASC\|DESC] [NULLS FIRST\|LAST] [, expr]*|sort result rows|6th — after SELECT; NULLS FIRST/LAST added 3.30.0
SL7|LIMIT|LIMIT count [OFFSET skip]|restrict number of returned rows|7th — after ORDER BY; OFFSET skips first N rows
SL8|UNION / UNION ALL|select UNION [ALL] select|combine results of two queries — UNION removes duplicates, UNION ALL keeps all|column count and affinity must match between queries
SL9|INTERSECT|select INTERSECT select|rows present in both queries|—
SL10|EXCEPT|select EXCEPT select|rows in first but not second query|—
SL11|VALUES|VALUES (expr_list) [, (expr_list)]*|row constructor — usable anywhere SELECT is expected|VALUES (1,'a'),(2,'b') returns two rows

# joins(id|type|syntax|description|notes)
JN1|INNER JOIN|FROM a INNER JOIN b ON a.x = b.y|rows matching in both tables|default join type — JOIN without qualifier = INNER JOIN
JN2|LEFT [OUTER] JOIN|FROM a LEFT JOIN b ON a.x = b.y|all rows from left, matching from right (NULL if no match)|most common outer join
JN3|RIGHT [OUTER] JOIN|FROM a RIGHT JOIN b ON a.x = b.y|all rows from right, matching from left|added SQLite 3.39.0 (2022-07-21)
JN4|FULL [OUTER] JOIN|FROM a FULL JOIN b ON a.x = b.y|all rows from both, NULL-filled where no match|added SQLite 3.39.0
JN5|CROSS JOIN|FROM a CROSS JOIN b|cartesian product — every row of a paired with every row of b|no ON clause; use with caution — N×M rows
JN6|NATURAL JOIN|FROM a NATURAL JOIN b|implicit join on all columns with same name in both tables|dangerous — column additions can silently change join conditions; prefer explicit ON
JN7|self-join|FROM t AS a JOIN t AS b ON a.parent_id = b.id|join table to itself|requires aliases; common for hierarchical data
JN8|USING|FROM a JOIN b USING (col)|shorthand for ON a.col = b.col — column must exist in both|result has one copy of the USING column, not two

# subqueries(id|type|syntax|description|notes)
SQ1|scalar subquery|(SELECT single_value) in SELECT or WHERE|returns exactly one value|error if subquery returns more than one row (unless used with IN/EXISTS)
SQ2|table subquery|FROM (SELECT ...) AS alias|subquery as virtual table in FROM clause|must have alias; columns accessible by alias.col
SQ3|correlated subquery|WHERE x > (SELECT avg(y) FROM t2 WHERE t2.id = t1.id)|subquery references outer query — re-executed per outer row|expensive — consider JOIN or CTE as alternative; optimizer may flatten
SQ4|EXISTS subquery|WHERE EXISTS (SELECT 1 FROM t2 WHERE t2.fk = t1.id)|true if inner query returns any rows|semi-join — optimizer can short-circuit after first match
SQ5|IN subquery|WHERE x IN (SELECT col FROM t2)|membership test against subquery result|equivalent to semi-join; for NOT IN, be aware of NULL semantics (one NULL makes entire NOT IN return NULL)

# aggregation(id|function|syntax|description|notes)
AG1|COUNT|COUNT(*) or COUNT(expr) or COUNT(DISTINCT expr)|count rows or non-NULL values|COUNT(*) counts all rows including NULLs; COUNT(col) excludes NULLs; COUNT(DISTINCT col) counts unique non-NULLs
AG2|SUM|SUM(expr) or SUM(DISTINCT expr)|sum of non-NULL values|returns NULL if all values NULL (not 0); use COALESCE(SUM(x),0) for zero default
AG3|AVG|AVG(expr)|arithmetic mean of non-NULL values|integer inputs may produce integer result — CAST to REAL if needed: AVG(CAST(x AS REAL))
AG4|MIN / MAX|MIN(expr), MAX(expr)|smallest / largest non-NULL value|works on TEXT (collation order), INTEGER, REAL; returns NULL if no non-NULL values
AG5|GROUP_CONCAT|GROUP_CONCAT(expr [, separator])|concatenate values from group into string|default separator is comma; ORDER within group not guaranteed (use window function + GROUP_CONCAT for ordered)
AG6|TOTAL|TOTAL(expr)|like SUM but returns 0.0 (REAL) instead of NULL for empty/all-NULL sets|always returns REAL; use when you need guaranteed numeric result
AG7|aggregate filter|agg_func(expr) FILTER (WHERE condition)|apply aggregate only to rows matching condition|added 3.30.0; equivalent to: agg_func(CASE WHEN condition THEN expr END) but cleaner

# window_functions(id|function|syntax|description|notes)
WF1|ROW_NUMBER|ROW_NUMBER() OVER (partition ORDER BY ...)|unique sequential integer per partition|no ties — arbitrary ordering for equal values
WF2|RANK|RANK() OVER (partition ORDER BY ...)|rank with gaps for ties|1,2,2,4 — tied rows get same rank, next rank skips
WF3|DENSE_RANK|DENSE_RANK() OVER (partition ORDER BY ...)|rank without gaps|1,2,2,3 — no gap after tie
WF4|NTILE|NTILE(n) OVER (partition ORDER BY ...)|divide partition into n roughly equal buckets|bucket sizes differ by at most 1 row
WF5|LAG|LAG(expr [, offset [, default]]) OVER (...)|value from previous row in partition|offset default = 1; default value used when no previous row exists
WF6|LEAD|LEAD(expr [, offset [, default]]) OVER (...)|value from next row in partition|—
WF7|FIRST_VALUE|FIRST_VALUE(expr) OVER (partition ORDER BY ... frame)|value from first row in frame|frame clause matters — ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW is default
WF8|LAST_VALUE|LAST_VALUE(expr) OVER (partition ORDER BY ... ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)|value from last row in frame|must override default frame to see actual last value
WF9|NTH_VALUE|NTH_VALUE(expr, n) OVER (...)|value from nth row in frame|1-indexed; returns NULL if fewer than n rows
WF10|SUM/AVG/COUNT/MIN/MAX|agg_func(expr) OVER (partition ORDER BY ... frame)|running or framed aggregate|default frame with ORDER BY is ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW (running total)
WF11|window frame|ROWS\|RANGE\|GROUPS BETWEEN start AND end|defines which rows within partition the function operates on|start/end: UNBOUNDED PRECEDING, N PRECEDING, CURRENT ROW, N FOLLOWING, UNBOUNDED FOLLOWING
WF12|PARTITION BY|OVER (PARTITION BY expr)|divide result into independent groups for window calculation|like GROUP BY but does not collapse rows — each row retains identity
WF13|named window|WINDOW w AS (PARTITION BY ... ORDER BY ...) ... OVER w|reusable window definition|defined in query's WINDOW clause, referenced in OVER

# cte(id|type|syntax|description|notes)
CT1|non-recursive CTE|WITH name [(cols)] AS (select) SELECT ... FROM name|named subquery — readable, reusable within statement|evaluated once (materialized) or inlined by optimizer; use MATERIALIZED / NOT MATERIALIZED hints (3.35.0+)
CT2|recursive CTE|WITH RECURSIVE name [(cols)] AS (base_case UNION ALL recursive_case) SELECT ... FROM name|iterative query — tree walking, graph traversal, series generation|recursive_case must reference name; add LIMIT or WHERE to prevent infinite recursion
CT3|multiple CTEs|WITH a AS (...), b AS (...) SELECT ... FROM a JOIN b|chain CTEs — each can reference prior ones|order matters — later CTEs can reference earlier ones
CT4|CTE in DML|WITH name AS (...) INSERT/UPDATE/DELETE ...|use CTE as source for data modification|useful for complex insert-from-select or conditional updates

# indexes(id|type|syntax|description|notes)
IX1|single-column|CREATE INDEX idx ON t(col)|index one column|most common; speeds equality and range queries on that column
IX2|multi-column (composite)|CREATE INDEX idx ON t(col1, col2)|index multiple columns — leftmost prefix principle|query must use leftmost column(s) to benefit; (a,b,c) helps WHERE a=1 AND b=2 but not WHERE b=2 alone
IX3|unique index|CREATE UNIQUE INDEX idx ON t(col)|enforce uniqueness + index|equivalent to UNIQUE constraint on column
IX4|partial index|CREATE INDEX idx ON t(col) WHERE condition|index only rows matching condition|smaller index, faster for queries matching the condition; e.g., WHERE status = 'active'
IX5|expression index|CREATE INDEX idx ON t(lower(name))|index on computed expression|query must use same expression to benefit: WHERE lower(name) = 'foo'
IX6|covering index|index contains all columns needed by query — no table lookup required|query answered entirely from index — very fast|CREATE INDEX idx ON t(a, b, c) covers SELECT b, c FROM t WHERE a = 1
IX7|ANALYZE|ANALYZE [table]|collect index statistics for query optimizer|run after significant data changes; stored in sqlite_stat1 table; helps optimizer choose best index

# transactions(id|concept|syntax|description|notes)
TR1|BEGIN|BEGIN [DEFERRED\|IMMEDIATE\|EXCLUSIVE]|start transaction|DEFERRED (default): locks on first read/write; IMMEDIATE: write lock immediately; EXCLUSIVE: exclusive lock immediately
TR2|COMMIT|COMMIT or END|finalize transaction — make changes permanent|synonymous; triggers fsync in WAL mode
TR3|ROLLBACK|ROLLBACK [TO savepoint]|undo all changes since BEGIN (or since savepoint)|without savepoint: rolls back entire transaction
TR4|SAVEPOINT|SAVEPOINT name|named point within transaction — can partially rollback|RELEASE name commits savepoint; ROLLBACK TO name undoes to that point but stays in transaction
TR5|autocommit|each statement is its own transaction if no explicit BEGIN|default behavior — every INSERT/UPDATE/DELETE is individually committed|wrapping multiple statements in BEGIN/COMMIT = massive performance improvement (1000 inserts: ~2s autocommit vs ~0.05s batched)
TR6|read transaction|BEGIN; SELECT ...; COMMIT;|consistent snapshot — all reads see same database state|in WAL mode: readers see snapshot at BEGIN time, not affected by concurrent writes

# pragmas(id|pragma|syntax|description|recommended_value)
PG1|journal_mode|PRAGMA journal_mode = WAL|write-ahead log for better read concurrency|WAL for most applications; DELETE for maximum compatibility
PG2|foreign_keys|PRAGMA foreign_keys = ON|enable foreign key enforcement|OFF by default! must enable per connection
PG3|busy_timeout|PRAGMA busy_timeout = 5000|wait N ms before returning SQLITE_BUSY on lock contention|5000 (5 seconds) is reasonable default; 0 = fail immediately
PG4|cache_size|PRAGMA cache_size = -8000|set page cache size (-N = N kibibytes, +N = N pages)|default -2000 (2MB); increase for read-heavy workloads
PG5|synchronous|PRAGMA synchronous = NORMAL|controls fsync behavior|NORMAL is safe with WAL; FULL is safest but slower; OFF risks corruption on crash
PG6|temp_store|PRAGMA temp_store = MEMORY|temporary tables and indexes in memory vs disk|MEMORY for speed if RAM available
PG7|mmap_size|PRAGMA mmap_size = 268435456|memory-map database file for faster reads|set to ~256MB or database size; 0 = disable mmap
PG8|page_size|PRAGMA page_size = 4096|database page size — set before creating database|4096 is default and usually optimal; 8192/16384 for large BLOB-heavy databases
PG9|auto_vacuum|PRAGMA auto_vacuum = INCREMENTAL|reclaim space after DELETE|INCREMENTAL allows manual PRAGMA incremental_vacuum(N); FULL does it automatically on every commit
PG10|wal_autocheckpoint|PRAGMA wal_autocheckpoint = 1000|auto-checkpoint WAL after N pages|default 1000; set higher for write-heavy bursts, lower for more predictable WAL size
PG11|integrity_check|PRAGMA integrity_check|verify database integrity|run periodically or after suspected corruption; returns 'ok' or list of errors
PG12|table_info|PRAGMA table_info(table_name)|list columns, types, nullability, defaults, primary key|diagnostic — not for production queries
PG13|optimize|PRAGMA optimize|run ANALYZE on tables that would benefit|call on connection close; added 3.18.0; lightweight, safe to call frequently
PG14|compile_options|PRAGMA compile_options|list compile-time options|check feature availability: ENABLE_FTS5, ENABLE_JSON1, ENABLE_RTREE, etc.

# json(id|function|syntax|description|notes)
JS1|json|json(value)|validate and minify JSON string|returns NULL if invalid JSON; use as validation
JS2|json_extract|json_extract(json, path [, path]*) or json->path or json->>path|extract value from JSON|-> returns JSON type; ->> returns SQL type (text/integer); path uses $.key.subkey[0] syntax
JS3|json_insert|json_insert(json, path, value [, path, value]*)|insert value only if path does not exist|does not overwrite existing values — use json_set for overwrite
JS4|json_replace|json_replace(json, path, value [, path, value]*)|replace value only if path exists|does not create new paths — use json_set for create-or-update
JS5|json_set|json_set(json, path, value [, path, value]*)|insert or replace value at path|most commonly needed — upsert semantics for JSON
JS6|json_remove|json_remove(json, path [, path]*)|remove values at specified paths|returns modified JSON
JS7|json_type|json_type(json [, path])|return type of JSON value: null, true, false, integer, real, text, array, object|useful for conditional processing
JS8|json_array|json_array(val1, val2, ...)|construct JSON array from SQL values|json_array(1, 'two', null) → '[1,"two",null]'
JS9|json_object|json_object(key1, val1, key2, val2, ...)|construct JSON object from key-value pairs|json_object('a', 1, 'b', 'two') → '{"a":1,"b":"two"}'
JS10|json_each|json_each(json [, path])|table-valued function — one row per array element or object member|SELECT value FROM json_each('[1,2,3]') → three rows; key column holds index or object key
JS11|json_tree|json_tree(json [, path])|table-valued function — recursive walk of JSON structure|returns key, value, type, path, atom for each node; useful for deep querying
JS12|json_group_array|json_group_array(value)|aggregate — collect values into JSON array|like GROUP_CONCAT but produces valid JSON array
JS13|json_group_object|json_group_object(key, value)|aggregate — collect key-value pairs into JSON object|key must be TEXT

# fts(id|concept|syntax|description|notes)
FT1|FTS5 table|CREATE VIRTUAL TABLE t USING fts5(col1, col2 [, tokenize='porter'])|full-text search — inverted index on text columns|content stored in shadow tables; tokenizers: unicode61 (default), porter (stemming), ascii, trigram
FT2|MATCH query|SELECT * FROM t WHERE t MATCH 'search terms'|full-text search query|implicit AND between terms; quotes for phrase: '"exact phrase"'
FT3|Boolean operators|col MATCH 'term1 AND term2', 'term1 OR term2', 'NOT term1', 'term1 NEAR term2'|combine search terms|NEAR defaults to within 10 tokens; NEAR(term1 term2, 5) = within 5 tokens
FT4|prefix search|col MATCH 'prefix*'|match terms starting with prefix|'data*' matches database, datatype, etc.
FT5|column filter|col MATCH 'col1:term'|restrict search to specific column|'title:sqlite body:performance'
FT6|rank / bm25|SELECT *, rank FROM t WHERE t MATCH 'term' ORDER BY rank|relevance ranking — built-in BM25 scoring|rank is negative (more negative = more relevant); bm25(t, weight1, weight2, ...) for per-column weights
FT7|highlight|highlight(t, col_idx, '<b>', '</b>')|return text with matches wrapped in tags|col_idx is 0-based column index in FTS table
FT8|snippet|snippet(t, col_idx, '<b>', '</b>', '...', max_tokens)|return relevant text excerpt around matches|max_tokens limits excerpt length
FT9|content table|CREATE VIRTUAL TABLE t USING fts5(col, content='source_table', content_rowid='id')|FTS index backed by external table — saves space by not duplicating content|must manually keep in sync via triggers; content='' for contentless (index-only, no original text)
FT10|rebuild|INSERT INTO t(t) VALUES('rebuild')|rebuild FTS index from content table|run after bulk data changes to content table

# expressions(id|expression|syntax|description|notes)
EX1|COALESCE|COALESCE(x, y, z, ...)|return first non-NULL argument|COALESCE(nullable_col, 'default') — essential for NULL handling
EX2|NULLIF|NULLIF(x, y)|return NULL if x = y, otherwise return x|NULLIF(count, 0) prevents division by zero: value / NULLIF(divisor, 0)
EX3|IIF|IIF(condition, true_val, false_val)|inline conditional — shorthand for CASE WHEN|added 3.32.0; IIF(x > 0, 'positive', 'non-positive')
EX4|typeof|typeof(expr)|return storage class as text: 'null', 'integer', 'real', 'text', 'blob'|runtime type inspection — useful for debugging manifest typing
EX5|CAST|CAST(expr AS type_name)|explicit type conversion|CAST('123' AS INTEGER), CAST(456 AS TEXT), CAST(x AS REAL)
EX6|printf|printf(format, args...)|formatted string output|printf('%.2f', 3.14159) → '3.14'; printf('%d items', count)
EX7|instr|instr(string, substring)|position of first occurrence (1-indexed), 0 if not found|case-sensitive; instr('Hello', 'ell') → 2
EX8|substr|substr(string, start [, length])|extract substring|1-indexed; negative start counts from end; substr('Hello', 2, 3) → 'ell'
EX9|replace|replace(string, from, to)|replace all occurrences|replace('aabaa', 'a', 'x') → 'xxbxx'
EX10|trim|trim(string), ltrim(string), rtrim(string)|remove whitespace (or specified chars) from ends|trim(string, chars) removes specified characters
EX11|length|length(string) or length(blob)|character count (text) or byte count (blob)|for UTF-8 strings, counts characters not bytes; use octet_length() for bytes (3.43.0+)
EX12|abs|abs(x)|absolute value|abs(-42) → 42; abs(NULL) → NULL
EX13|max/min (scalar)|max(a, b, c), min(a, b, c)|scalar multi-argument max/min (not aggregate)|max(1, 5, 3) → 5; different from aggregate MAX()
EX14|random|random()|pseudo-random integer in range [-9223372036854775808, +9223372036854775807]|for random 0.0-1.0: abs(random()) / 9223372036854775807.0; for random row: ORDER BY random() LIMIT 1
EX15|hex / unhex|hex(blob_or_text), unhex(hex_string)|convert to/from hexadecimal|hex(X'CAFE') → 'CAFE'; unhex('CAFE') → X'CAFE'
EX16|zeroblob|zeroblob(N)|create N-byte blob of all zeros|useful for pre-allocating BLOB space for incremental I/O
EX17|unicode / char|unicode(string), char(code1, code2, ...)|get Unicode code point of first char / construct string from code points|unicode('A') → 65; char(65) → 'A'
EX18|glob / like functions|glob(pattern, string), like(pattern, string)|function form of GLOB and LIKE operators|useful in CHECK constraints or computed columns
EX19|quote|quote(value)|return SQL literal representation of value|quote(NULL) → 'NULL'; quote('hello') → '''hello'''; useful for debugging

# date_time(id|function|syntax|description|notes)
TM1|date|date(timestring [, modifier]*)|return date as TEXT: YYYY-MM-DD|date('now'), date('2024-01-15', '+30 days')
TM2|time|time(timestring [, modifier]*)|return time as TEXT: HH:MM:SS|time('now'), time('12:00:00', '+2 hours')
TM3|datetime|datetime(timestring [, modifier]*)|return datetime as TEXT: YYYY-MM-DD HH:MM:SS|datetime('now'), datetime('2024-01-15 10:30:00', 'localtime')
TM4|julianday|julianday(timestring [, modifier]*)|return Julian day number as REAL|fractional days since noon November 24, 4714 BC
TM5|unixepoch|unixepoch(timestring [, modifier]*)|return Unix timestamp as INTEGER (seconds since 1970-01-01)|added 3.38.0; unixepoch('now') replaces strftime('%s', 'now')
TM6|strftime|strftime(format, timestring [, modifier]*)|format datetime string|%Y=year, %m=month, %d=day, %H=hour, %M=minute, %S=second, %s=unix epoch, %j=day-of-year, %w=day-of-week (0=Sunday)
TM7|modifiers|'+N days', '-N months', '+N hours', 'start of month', 'start of year', 'weekday N', 'localtime', 'utc'|modify time values|can chain: date('now', 'start of month', '+1 month', '-1 day') → last day of current month
TM8|time strings|'now', 'YYYY-MM-DD', 'YYYY-MM-DD HH:MM:SS', 'YYYY-MM-DDTHH:MM:SS', Unix epoch as integer, Julian day as real|acceptable input formats|'now' = current UTC time; integer interpreted as Unix epoch

# constraints(id|constraint|syntax|scope|description)
CS1|PRIMARY KEY|col INTEGER PRIMARY KEY or PRIMARY KEY (col [, col])|column or table|unique row identifier; INTEGER PRIMARY KEY = rowid alias; composite PK requires table-level syntax
CS2|NOT NULL|col TEXT NOT NULL|column|column cannot contain NULL — insert/update with NULL fails
CS3|UNIQUE|col TEXT UNIQUE or UNIQUE (col [, col])|column or table|no duplicate values (NULLs are considered distinct — multiple NULLs allowed)
CS4|CHECK|CHECK (expr)|column or table|expr must evaluate to true for every row; CHECK (age >= 0 AND age <= 150)
CS5|DEFAULT|col INTEGER DEFAULT 0 or DEFAULT (expression)|column|value when INSERT omits column; expression evaluated at insert time: DEFAULT (datetime('now'))
CS6|FOREIGN KEY|REFERENCES parent_table(col) [ON DELETE action] [ON UPDATE action]|column|actions: SET NULL, SET DEFAULT, CASCADE, RESTRICT, NO ACTION (default); requires PRAGMA foreign_keys = ON
CS7|COLLATE|col TEXT COLLATE NOCASE|column|determines string comparison order: BINARY (default), NOCASE, RTRIM
CS8|GENERATED|col GENERATED ALWAYS AS (expr) [STORED\|VIRTUAL]|column|computed column; VIRTUAL (default) = computed on read; STORED = computed on write, stored on disk; added 3.31.0
CS9|ON CONFLICT|... ON CONFLICT ABORT\|ROLLBACK\|FAIL\|IGNORE\|REPLACE|column or table|determines behavior when constraint is violated

# views(id|concept|description|syntax|notes)
VW1|simple view|named SELECT — virtual table recalculated on each query|CREATE VIEW v AS SELECT col1, col2 FROM t WHERE ...|no stored data; always reflects current table state
VW2|view with column names|explicit column names for the view|CREATE VIEW v(a, b) AS SELECT col1, col2 FROM t|overrides column names from underlying query
VW3|updatable views|views that support INSERT/UPDATE/DELETE via INSTEAD OF triggers|CREATE TRIGGER insert_v INSTEAD OF INSERT ON v BEGIN ... END|SQLite views are not inherently updatable — INSTEAD OF triggers implement the mutation logic
VW4|temp view|connection-scoped view|CREATE TEMP VIEW v AS ...|exists only for the life of the connection

# triggers(id|concept|description|timing|notes)
TG1|BEFORE trigger|fires before the triggering operation — can modify or prevent it|BEFORE INSERT/UPDATE/DELETE|raise(ABORT, 'message') to prevent the operation; can modify NEW values
TG2|AFTER trigger|fires after the triggering operation completes|AFTER INSERT/UPDATE/DELETE|commonly used for logging, cascading changes, maintaining denormalized data
TG3|INSTEAD OF trigger|replaces the triggering operation — only for views|INSTEAD OF INSERT/UPDATE/DELETE ON view|the only way to make views writable; implements the mutation logic
TG4|NEW / OLD|pseudo-tables referencing the new or old row|INSERT: NEW only; DELETE: OLD only; UPDATE: both|NEW.col and OLD.col access individual column values
TG5|WHEN clause|conditional trigger — only fires when WHEN expression is true|WHEN NEW.status != OLD.status|evaluated per row; if false, trigger does not fire for that row
TG6|RAISE|RAISE(ABORT, message) or RAISE(ROLLBACK/FAIL/IGNORE, message)|abort current statement or transaction from within trigger|ABORT: undo current statement; ROLLBACK: undo entire transaction; FAIL: stop but keep prior changes; IGNORE: skip this row

# functions(id|function|description|category)
FN1|abs, max, min, round|numeric functions|scalar math
FN2|length, substr, replace, trim, ltrim, rtrim, upper, lower, instr|string manipulation|scalar string
FN3|hex, unhex, zeroblob, typeof, quote|conversion and inspection|scalar utility
FN4|coalesce, nullif, iif, ifnull|NULL handling|scalar conditional
FN5|count, sum, avg, total, min, max, group_concat|aggregation|aggregate
FN6|row_number, rank, dense_rank, ntile, lag, lead, first_value, last_value, nth_value|window ranking and access|window
FN7|json_extract, json_set, json_insert, json_replace, json_remove, json_type, json_array, json_object|JSON manipulation|scalar JSON
FN8|json_each, json_tree|JSON table-valued|table-valued JSON
FN9|json_group_array, json_group_object|JSON aggregation|aggregate JSON
FN10|date, time, datetime, julianday, unixepoch, strftime|date/time|scalar date
FN11|highlight, snippet, bm25|FTS auxiliary|FTS5
FN12|printf, format|string formatting|scalar string
FN13|unicode, char|Unicode|scalar string
FN14|random, randomblob|random generation|scalar utility
FN15|changes, total_changes, last_insert_rowid|statement result info|scalar utility
FN16|sqlite_version|version information|scalar utility
FN17|likelihood, likely, unlikely|optimizer hints|query planning

# runbooks(id|task|sql|explanation|notes)
# — Schema design
RB1|create table with best practices|CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT NOT NULL, email TEXT UNIQUE NOT NULL, created_at INTEGER NOT NULL DEFAULT (unixepoch()), status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','suspended','deleted')), metadata TEXT DEFAULT '{}');|INTEGER PRIMARY KEY = rowid alias (fastest); NOT NULL on required fields; UNIQUE where needed; DEFAULT with expression; CHECK for enum-like constraints; timestamps as integers|always define constraints at creation — adding later is harder
RB2|create strict table|CREATE TABLE measurements (id INTEGER PRIMARY KEY, sensor_id INTEGER NOT NULL REFERENCES sensors(id), value REAL NOT NULL, recorded_at INTEGER NOT NULL) STRICT;|STRICT enforces declared types — no TEXT in INTEGER column; added 3.37.0|use for data integrity when type flexibility is unwanted
RB3|add column|ALTER TABLE users ADD COLUMN phone TEXT;|column added with NULL for existing rows|cannot add NOT NULL without DEFAULT; cannot add PRIMARY KEY
RB4|rename column|ALTER TABLE users RENAME COLUMN name TO full_name;|updates all references in indexes, triggers, views within same schema|added 3.25.0
RB5|create index for common query|CREATE INDEX idx_users_status_created ON users(status, created_at DESC);|composite index — leftmost prefix: queries on status alone benefit; queries on created_at alone do not|DESC in index matches DESC in ORDER BY — avoids reverse scan
RB6|partial index|CREATE INDEX idx_active_users ON users(email) WHERE status = 'active';|smaller index — only active users indexed; queries must include WHERE status = 'active' to use it|dramatic size and speed improvement when most rows don't match
# — Basic CRUD
RB7|insert single row|INSERT INTO users (name, email) VALUES ('Alice', 'alice@example.com');|id auto-assigned (rowid); created_at gets default; status gets default|returns: last_insert_rowid() for new row id
RB8|insert multiple rows|INSERT INTO users (name, email) VALUES ('Bob', 'bob@b.com'), ('Carol', 'carol@c.com'), ('Dave', 'dave@d.com');|multi-value insert — single statement, single transaction|much faster than three separate INSERTs
RB9|insert from select|INSERT INTO archive_users SELECT * FROM users WHERE status = 'deleted';|copy rows between tables|column count and types must be compatible
RB10|upsert|INSERT INTO users (id, name, email) VALUES (1, 'Alice Updated', 'alice@new.com') ON CONFLICT(id) DO UPDATE SET name = excluded.name, email = excluded.email;|insert if new, update if exists — excluded.col references the rejected row's values|DO NOTHING to silently skip conflicts
RB11|update with join|UPDATE orders SET status = 'cancelled' FROM users WHERE orders.user_id = users.id AND users.status = 'deleted';|UPDATE FROM syntax — join another table to determine which rows to update|added 3.33.0; alternative: UPDATE orders SET status = 'cancelled' WHERE user_id IN (SELECT id FROM users WHERE status = 'deleted')
RB12|delete with subquery|DELETE FROM logs WHERE created_at < unixepoch('now', '-90 days');|delete old rows using date calculation|add LIMIT for batched deletion to avoid long locks: DELETE FROM logs WHERE rowid IN (SELECT rowid FROM logs WHERE created_at < ... LIMIT 10000)
RB13|conditional update|UPDATE products SET price = CASE WHEN category = 'sale' THEN price * 0.9 WHEN category = 'clearance' THEN price * 0.5 ELSE price END WHERE category IN ('sale', 'clearance');|CASE expression in SET clause — different update logic per row|WHERE filters first, then CASE applies per matching row
# — Querying
RB14|pagination|SELECT * FROM users ORDER BY created_at DESC LIMIT 20 OFFSET 40;|page 3 (20 per page) — OFFSET 40 skips first 2 pages|OFFSET is slow for large values — keyset pagination is better: WHERE created_at < :last_seen ORDER BY created_at DESC LIMIT 20
RB15|keyset pagination|SELECT * FROM users WHERE created_at < :last_created_at OR (created_at = :last_created_at AND id < :last_id) ORDER BY created_at DESC, id DESC LIMIT 20;|cursor-based — uses last row's values as cursor; O(1) regardless of page number|requires stable, unique sort key; much faster than OFFSET for deep pages
RB16|exists check|SELECT EXISTS(SELECT 1 FROM users WHERE email = 'alice@example.com');|returns 0 or 1 — faster than counting because stops at first match|use EXISTS instead of COUNT(*) > 0 for existence checks
RB17|conditional aggregation|SELECT COUNT(*) FILTER (WHERE status = 'active') AS active, COUNT(*) FILTER (WHERE status = 'suspended') AS suspended, COUNT(*) AS total FROM users;|multiple aggregates with different filters in single pass|FILTER syntax added 3.30.0; alternative: SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END)
RB18|running total|SELECT date, amount, SUM(amount) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total FROM transactions;|window function running sum|ROWS vs RANGE: ROWS counts physical rows; RANGE groups equal values
RB19|find duplicates|SELECT email, COUNT(*) AS cnt FROM users GROUP BY email HAVING COUNT(*) > 1;|HAVING filters after aggregation — only groups with more than one row|to see the actual duplicate rows: join back to original table
RB20|top-N per group|SELECT * FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn FROM employees) WHERE rn <= 3;|window function to rank within group, then filter|subquery required because WHERE cannot reference window functions
RB21|pivot/crosstab|SELECT product, SUM(CASE WHEN month = 1 THEN revenue ELSE 0 END) AS jan, SUM(CASE WHEN month = 2 THEN revenue ELSE 0 END) AS feb, SUM(CASE WHEN month = 3 THEN revenue ELSE 0 END) AS mar FROM sales GROUP BY product;|manual pivot — no PIVOT keyword in SQLite|column list must be known at query-writing time; for dynamic columns, generate SQL in application code
RB22|recursive tree query|WITH RECURSIVE tree AS (SELECT id, name, parent_id, 0 AS depth FROM categories WHERE parent_id IS NULL UNION ALL SELECT c.id, c.name, c.parent_id, t.depth + 1 FROM categories c JOIN tree t ON c.parent_id = t.id) SELECT * FROM tree ORDER BY depth, name;|walk hierarchy from root — depth tracks level|add WHERE depth < 10 to prevent infinite recursion on circular references
RB23|generate date series|WITH RECURSIVE dates AS (SELECT date('2024-01-01') AS d UNION ALL SELECT date(d, '+1 day') FROM dates WHERE d < '2024-12-31') SELECT d FROM dates;|generate all dates in range — no generate_series() needed|use for LEFT JOIN to fill gaps in time-series data
RB24|find gaps in sequence|SELECT a.id + 1 AS gap_start, MIN(b.id) - 1 AS gap_end FROM t a JOIN t b ON b.id > a.id + 1 GROUP BY a.id HAVING gap_start <= gap_end;|find missing IDs in non-contiguous sequence|alternative with window: SELECT id + 1 AS gap_start FROM (SELECT id, LEAD(id) OVER (ORDER BY id) AS next_id FROM t) WHERE next_id > id + 1
# — JSON
RB25|store JSON|INSERT INTO events (data) VALUES ('{"type":"click","x":100,"y":200}');|store as TEXT with JSON affinity|validate on insert: CHECK (json_valid(data)) ensures only valid JSON stored
RB26|query JSON field|SELECT data->>'$.type' AS event_type, data->>'$.x' AS x FROM events WHERE data->>'$.type' = 'click';|->> extracts as SQL type (TEXT/INTEGER); -> extracts as JSON|index JSON fields: CREATE INDEX idx_event_type ON events(data->>'$.type')
RB27|update JSON field|UPDATE events SET data = json_set(data, '$.processed', 1, '$.processed_at', unixepoch()) WHERE id = 42;|json_set inserts or replaces at path|atomic — no read-modify-write race; single UPDATE statement
RB28|aggregate JSON|SELECT json_group_array(json_object('id', id, 'name', name)) AS users_json FROM users WHERE status = 'active';|produce JSON array of objects from query result|useful for API responses without ORM
RB29|query into JSON array|SELECT * FROM json_each('[1,2,3,4,5]');|table-valued function — one row per element|key=index, value=element, type=type; useful for IN-list from JSON parameter
# — Full-text search
RB30|FTS setup|CREATE VIRTUAL TABLE docs_fts USING fts5(title, body, content='docs', content_rowid='id', tokenize='porter unicode61');|FTS5 with porter stemming, backed by docs table|requires triggers to sync: AFTER INSERT/UPDATE/DELETE on docs → INSERT/DELETE on docs_fts
RB31|FTS search with ranking|SELECT docs.*, docs_fts.rank FROM docs_fts JOIN docs ON docs.id = docs_fts.rowid WHERE docs_fts MATCH 'sqlite performance' ORDER BY docs_fts.rank;|search with BM25 ranking — lower rank = more relevant|rank is negative; join to content table for full row data
RB32|FTS with highlight|SELECT highlight(docs_fts, 0, '<mark>', '</mark>') AS title, snippet(docs_fts, 1, '<mark>', '</mark>', '...', 64) AS body_excerpt FROM docs_fts WHERE docs_fts MATCH 'query terms';|highlighted matches + body excerpt|0 = title column index, 1 = body column index
# — Performance
RB33|connection setup|PRAGMA journal_mode = WAL; PRAGMA foreign_keys = ON; PRAGMA busy_timeout = 5000; PRAGMA synchronous = NORMAL; PRAGMA cache_size = -8000; PRAGMA temp_store = MEMORY;|execute on every new connection — pragmas are per-connection, not persistent (except journal_mode)|wrap in a connection-init function; journal_mode persists but re-setting is harmless
RB34|batch insert|BEGIN; INSERT INTO t VALUES (...); INSERT INTO t VALUES (...); ... COMMIT;|wrap multiple writes in explicit transaction — 10-100× faster than autocommit|use prepared statements with parameter binding for additional speed and SQL injection prevention
RB35|explain query plan|EXPLAIN QUERY PLAN SELECT ... FROM ... WHERE ...;|show how SQLite will execute the query — which indexes, scan type, join order|SCAN = full table scan (usually bad); SEARCH = index lookup (usually good); USING COVERING INDEX = best
RB36|analyze for optimizer|ANALYZE; PRAGMA optimize;|collect statistics for query planner|run after bulk data loads; PRAGMA optimize is safe to call on every connection close
RB37|vacuum|VACUUM;|rebuild database file — reclaim space, defragment|locks database during execution; for large databases use VACUUM INTO 'new.db' (3.27.0+)
RB38|monitor size|SELECT page_count * page_size AS db_size_bytes FROM pragma_page_count(), pragma_page_size();|check database file size without filesystem access|also: SELECT * FROM dbstat to see per-table/index space usage (requires DBSTAT virtual table)
# — Maintenance
RB39|backup|.backup main backup.db (CLI) or sqlite3_backup_init() API|hot backup — safe while database is in use|for scripting: cp the WAL file too, or use VACUUM INTO 'backup.db'
RB40|check integrity|PRAGMA integrity_check; PRAGMA foreign_key_check;|verify database and foreign key consistency|integrity_check is thorough but slow on large databases; quick_check is faster but less thorough
RB41|export to CSV|.mode csv; .headers on; .output data.csv; SELECT * FROM users; .output stdout;|CLI export|for programmatic export, use application code with CSV library
RB42|import from CSV|.mode csv; .import data.csv users;|CLI import — creates table if it doesn't exist|first row treated as headers if table doesn't exist; use .separator for non-comma delimiters

# anti_patterns(id|anti_pattern|description|correct_alternative|consequence)
AP1|SELECT *|selecting all columns when only some needed|SELECT only needed columns|wasted I/O, prevents covering index optimization, breaks if schema changes
AP2|no index on foreign key|foreign key column without index|CREATE INDEX on every FK column|slow JOINs, slow ON DELETE CASCADE, slow parent lookups
AP3|storing comma-separated values|multiple values in one text field: 'a,b,c'|normalize into separate table with foreign key|cannot index, cannot JOIN, cannot enforce referential integrity, parsing required
AP4|using OFFSET for deep pagination|OFFSET 10000 scans and discards 10000 rows|keyset/cursor pagination (RB15)|O(N) per page regardless of LIMIT; gets slower with every page
AP5|not using transactions for batch writes|individual autocommit per INSERT|wrap in BEGIN/COMMIT (RB34)|10-100× slower; each INSERT does fsync
AP6|EAV (entity-attribute-value)|generic schema: entity_id, attribute_name, attribute_value|proper normalized tables with typed columns|no type safety, no constraints, no indexes on values, complex queries, terrible performance
AP7|storing dates as ambiguous text|'01/02/2024' — is that Jan 2 or Feb 1?|ISO 8601 ('2024-01-02') or Unix epoch integer|sorting fails, date math fails, regional ambiguity
AP8|ignoring PRAGMA foreign_keys|foreign keys defined but not enforced (OFF by default)|PRAGMA foreign_keys = ON on every connection (RB33)|orphaned rows, referential integrity violations undetected
AP9|using REPLACE instead of UPSERT|REPLACE deletes then inserts — fires DELETE triggers, resets rowid|INSERT ... ON CONFLICT DO UPDATE (RB10)|unexpected trigger side effects, lost autoincrement continuity, cascading deletes if FK CASCADE
AP10|not using prepared statements|string-concatenating SQL with user input|use parameter binding: ?1, ?2, :name, @name|SQL injection vulnerability; also slower (re-parsing each execution)
AP11|over-indexing|index on every column|index only columns used in WHERE, JOIN ON, ORDER BY of actual queries|slower writes, wasted space, optimizer confusion
AP12|ignoring EXPLAIN QUERY PLAN|writing queries without checking execution plan|EXPLAIN QUERY PLAN on all non-trivial queries (RB35)|full table scans on large tables, missing indexes undiscovered

# rules(id|rule|domain|rationale|violation_consequence)
RL1|set WAL mode, foreign_keys ON, busy_timeout on every connection|connection setup|pragmas are per-connection defaults, not database-level; forgetting any one causes subtle bugs|no WAL = readers block writers; no FK = orphaned data; no timeout = SQLITE_BUSY errors
RL2|wrap batch writes in explicit transactions|write performance|autocommit does fsync per statement; explicit transaction does one fsync at COMMIT|10-100× slower writes; I/O bound on disk
RL3|use INTEGER PRIMARY KEY for rowid alias, not AUTOINCREMENT|schema|AUTOINCREMENT adds overhead (sqlite_sequence table) and prevents rowid reuse; rowid alias is sufficient for most cases|AUTOINCREMENT only needed when rowid reuse is absolutely unacceptable (audit logs)
RL4|index every foreign key column|schema|JOINs on un-indexed FK scan entire child table; ON DELETE CASCADE scans child table|slow joins, slow cascading operations, O(N) lookups that should be O(log N)
RL5|use keyset pagination, not OFFSET, for large datasets|query|OFFSET N scans and discards N rows; keyset uses index to start at the right place|O(N) per page with OFFSET; O(log N) with keyset
RL6|store dates as ISO 8601 text or Unix epoch integer|schema|SQLite date functions require ISO 8601 or Unix epoch; ambiguous formats fail silently|date comparisons wrong, date math broken, sorting broken
RL7|validate JSON with CHECK constraint if storing JSON|schema|invalid JSON in column causes json_extract to return NULL silently — data corruption is invisible|corrupt JSON discovered only when queried — may have propagated to other systems
RL8|use content= FTS tables with sync triggers, not standalone FTS|full-text|standalone FTS duplicates all text data; content= shares it|double storage for no benefit; sync issues between FTS and source table
RL9|run PRAGMA optimize on connection close|maintenance|allows SQLite to update statistics incrementally — lightweight and safe|query planner uses stale statistics — suboptimal index selection
RL10|never use SELECT * in application code|query|breaks when columns added/removed/reordered; prevents covering index; transfers unnecessary data|fragile code, performance waste, subtle bugs on schema change
RL11|use STRICT tables when type safety matters|schema|manifest typing allows any value in any column; STRICT enforces declared types|silent type coercion — '42' in INTEGER column; NULL in NOT NULL column (in non-strict)|
RL12|test with EXPLAIN QUERY PLAN before deploying queries on large tables|performance|full table scans invisible until data grows; index coverage only verifiable through EXPLAIN|fast in development (small data), catastrophically slow in production (large data)

# relationships(from|rel|to)
# foundations → features
FD1|enables|FD2,FD7,FD8,FD9
FD2|enables|FD8
FD3|constrains|DT1-DT7
FD5|enables|CS1,DT3
FD6|enables|FD7,TR6
FD7|constrains|TR1
FD8|requires|TR1-TR6
# DDL → DML
DD1|enables|DM1-DM6
DD5|enables|IX1-IX7
DD7|enables|VW1-VW4
DD9|enables|TG1-TG6
DD11|enables|FT1-FT10,JS10,JS11
# SELECT clause execution order
SL2|precedes|SL3
SL3|precedes|SL4
SL4|precedes|SL5
SL5|precedes|SL1
SL1|precedes|SL6
SL6|precedes|SL7
# joins → select
JN1-JN8|component_of|SL2
# aggregation → GROUP BY
AG1-AG7|requires|SL4
# window functions → OVER
WF1-WF13|requires|SL1
WF11|constrains|WF7-WF10
WF12|enables|WF1-WF10
# CTE → queries
CT1|enables|SL1,DM1-DM4
CT2|enables|RB22,RB23
# indexes → performance
IX1-IX6|enables|RB35
IX2|requires|RL4
IX4|enables|RB6
IX7|enables|PG13
# transactions → integrity
TR1|enables|TR2,TR3,TR4
TR5|opposes|TR1
# pragmas → configuration
PG1|enables|FD6
PG2|enables|CS6
PG3|enables|FD7
# JSON → expressions
JS1-JS13|requires|DD11
JS2|enables|RB26
JS5|enables|RB27
JS10|enables|RB29
# FTS → search
FT1|enables|FT2-FT10
FT2|requires|FT1
FT6|requires|FT2
FT9|enables|RB30
# constraints → data integrity
CS1|constrains|DM1-DM6
CS2|constrains|DM1,DM3
CS6|requires|PG2
# runbooks → rules
RB33|implements|RL1
RB34|implements|RL2
RB15|implements|RL5
RB10|implements|RL4
RB35|implements|RL12
RB36|implements|RL9
# anti-patterns → rules
AP1|violates|RL10
AP2|violates|RL4
AP4|violates|RL5
AP5|violates|RL2
AP8|violates|RL1
AP9|violates|RL4
AP10|violates|RL10
AP12|violates|RL12
# anti-patterns → correct alternatives
AP1|anti_pattern_of|RB35
AP4|anti_pattern_of|RB15
AP5|anti_pattern_of|RB34
AP9|anti_pattern_of|RB10
# cross-references
FD8|cross_ref|IN8
TR1|cross_ref|TR1
RL2|cross_ref|RU1
AP10|cross_ref|RU1

# section_index(section|title|ids)
1|Foundations|FD1-FD10
2|Data Types and Affinity|DT1-DT7
3|Operators|OP1-OP15
4|DDL|DD1-DD11
5|DML|DM1-DM6
6|SELECT Clauses|SL1-SL11
7|Joins|JN1-JN8
8|Subqueries|SQ1-SQ5
9|Aggregation|AG1-AG7
10|Window Functions|WF1-WF13
11|Common Table Expressions|CT1-CT4
12|Indexes|IX1-IX7
13|Transactions|TR1-TR6
14|PRAGMAs|PG1-PG14
15|JSON Functions|JS1-JS13
16|Full-Text Search (FTS5)|FT1-FT10
17|Expressions and Functions|EX1-EX19
18|Date/Time|TM1-TM8
19|Constraints|CS1-CS9
20|Views|VW1-VW4
21|Triggers|TG1-TG6
22|Function Reference|FN1-FN17
23|Runbooks|RB1-RB42
24|Anti-Patterns|AP1-AP12
25|Rules|RL1-RL12

# decode_legend
id_prefixes: FD=foundation, DT=data_type, OP=operator, DD=ddl, DM=dml, SL=select_clause, JN=join, SQ=subquery, AG=aggregation, WF=window_function, CT=cte, IX=index, TR=transaction, PG=pragma, JS=json, FT=fts, EX=expression, TM=date_time, CS=constraint, VW=view, TG=trigger, FN=function_ref, RB=runbook, AP=anti_pattern, RL=rule
rel_types: enables|requires|constrains|component_of|precedes|opposes|implements|violates|anti_pattern_of|cross_ref
cross_ref_prefixes: IN=invariant (VDR-PROLOG SPEC), RU=rule (MASONRY or generic)
sql_notation: | in syntax = OR/alternative (not pipe delimiter); [] = optional; * = zero or more; backslash before pipe in syntax cells is literal pipe
version_notes: RIGHT/FULL OUTER JOIN added 3.39.0 (2022-07-21); STRICT tables added 3.37.0 (2021-11-27); UPSERT added 3.24.0 (2018-06-04); UPDATE FROM added 3.33.0 (2020-08-14); window functions added 3.25.0 (2018-09-15); FILTER clause added 3.30.0 (2019-10-04); generated columns added 3.31.0 (2020-01-22); unixepoch() added 3.38.0 (2022-02-22); ->> operator added 3.38.0
sqlite_version_at_training: 3.45.x (approximate)
confidence: generated from LLM weights — reflects official SQLite documentation (sqlite.org), established SQL patterns, and production usage conventions

# relation_mapping(doc_rel|canonical_rel|notes)
enables|enables|exact match
requires|requires|exact match
constrains|constrains|exact match
component_of|part_of|exact semantic match
precedes|precedes|exact match
opposes|opposes|exact match; symmetric
implements|implements|exact match
violates|violates|exact match
anti_pattern_of|anti_pattern_of|exact match
cross_ref|references|cross-domain link = references
