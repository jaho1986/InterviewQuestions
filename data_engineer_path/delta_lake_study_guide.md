# Delta Lake Study Guide

> Topics are ordered from **easiest to hardest**. Explanations are short and use simple English.

## Table of Contents

1. [What is Delta Lake?](#1-what-is-delta-lake)
2. [Data Lake vs Data Warehouse vs Lakehouse](#2-data-lake-vs-data-warehouse-vs-lakehouse)
3. [Typical Problems in Data Lakes](#3-typical-problems-in-data-lakes)
4. [Delta Lake Architecture](#4-delta-lake-architecture)
5. [Spark Integration](#5-spark-integration)
6. [Structure of a Delta Table](#6-structure-of-a-delta-table)
7. [The Transaction Log](#7-the-transaction-log)
8. [Actions: add, remove, metaData, protocol](#8-actions-add-remove-metadata-protocol)
9. [Append vs Overwrite](#9-append-vs-overwrite)
10. [UPDATE, DELETE, MERGE INTO (Upsert)](#10-update-delete-merge-into-upsert)
11. [Schema Enforcement](#11-schema-enforcement)
12. [mergeSchema](#12-mergeschema)
13. [overwriteSchema](#13-overwriteschema)
14. [Time Travel](#14-time-travel)
15. [ACID Transactions](#15-acid-transactions)
16. [Partitioning and File Pruning](#16-partitioning-and-file-pruning)
17. [Small Files Problem](#17-small-files-problem)
18. [What Happens When a Write Fails?](#18-what-happens-when-a-write-fails)
19. [Optimistic Concurrency Control (OCC)](#19-optimistic-concurrency-control-occ)
20. [Conflicts Between Concurrent Writes](#20-conflicts-between-concurrent-writes)
21. [Quick Review Questions](#21-quick-review-questions)
22. [Glossary](#22-glossary)

---

## 1. What is Delta Lake?

**Delta Lake** is an **open-source storage layer** that sits on top of your data lake (S3, ADLS, GCS, HDFS).

- It stores data as **Parquet files**.
- It adds a **transaction log** on top of the files.
- The log gives you **reliability**: ACID transactions, versioning, and schema control.

**Simple idea:**

```
Delta Lake = Parquet files + Transaction log
```

**Main benefits:**

| Benefit | Meaning |
|---|---|
| ACID transactions | Writes are safe and reliable |
| Schema enforcement | Bad data is rejected |
| Time travel | You can read old versions of data |
| Batch + streaming | One table works for both |
| Updates and deletes | You can change data, not only add it |

---

## 2. Data Lake vs Data Warehouse vs Lakehouse

| | **Data Lake** | **Data Warehouse** | **Lakehouse** |
|---|---|---|---|
| Data types | All (structured, semi-structured, unstructured) | Mostly structured | All |
| Storage cost | Low | High | Low |
| Schema | Schema-on-read | Schema-on-write | Both |
| ACID transactions | No | Yes | Yes |
| Best for | Data science, raw data | BI, reports | BI + data science + ML |
| Main problem | Poor reliability ("data swamp") | Expensive, less flexible | Newer approach |
| Example | Files on S3 | Snowflake, Redshift | Delta Lake + Spark |

**Key point:** A **Lakehouse** combines the **low cost and flexibility of a data lake** with the **reliability and performance of a data warehouse**. Delta Lake is one of the technologies that makes a lakehouse possible.

---

## 3. Typical Problems in Data Lakes

These are the problems that Delta Lake was created to solve.

| Problem | What happens | How Delta Lake helps |
|---|---|---|
| **No ACID transactions** | A failed job leaves half-written files | Atomic commits |
| **Readers see partial data** | A query reads while a write is running | Snapshot isolation |
| **No schema control** | Wrong or corrupt data enters the table | Schema enforcement |
| **Hard to update/delete** | Files are immutable; you must rewrite everything | `UPDATE`, `DELETE`, `MERGE` |
| **Concurrent writes** | Two jobs write at the same time and corrupt data | Optimistic concurrency control |
| **No history** | You cannot recover old data | Time travel |
| **Small files** | Thousands of tiny files make queries slow | `OPTIMIZE` (compaction) |
| **Slow metadata listing** | Listing millions of files in cloud storage is slow | Metadata in the transaction log |

> **Note:** Delta Lake also has its own challenges (small files, write conflicts). You will study them in sections 17 and 20.

---

## 4. Delta Lake Architecture

Delta Lake has **three main layers**:

```
┌─────────────────────────────────────┐
│   Compute Engines                   │  Spark, Flink, Trino, Presto, Hive
├─────────────────────────────────────┤
│   Delta Lake Layer                  │  Transaction log + protocol
├─────────────────────────────────────┤
│   Storage                           │  Parquet files on S3 / ADLS / GCS / HDFS
└─────────────────────────────────────┘
```

- **Storage layer:** holds the data files (Parquet).
- **Delta Lake layer:** the `_delta_log` folder. It tracks which files belong to the table.
- **Compute layer:** engines that read and write the table.

### Medallion Architecture (common design pattern)

| Layer | Name | Content |
|---|---|---|
| 🥉 Bronze | Raw | Data as it arrives, no changes |
| 🥈 Silver | Cleaned | Filtered, cleaned, joined data |
| 🥇 Gold | Business-ready | Aggregated data for reports and ML |

---

## 5. Spark Integration

Delta Lake works **natively** with Apache Spark. You use the same DataFrame and SQL APIs.

### Write a Delta table

```python
# Save a DataFrame as Delta (by path)
df.write.format("delta").save("/data/sales")

# Save as a managed table
df.write.format("delta").saveAsTable("sales")
```

### Read a Delta table

```python
df = spark.read.format("delta").load("/data/sales")
# or
df = spark.table("sales")
```

### SQL

```sql
CREATE TABLE sales (id INT, amount DOUBLE) USING DELTA;
SELECT * FROM sales;
```

### Python API (`DeltaTable`)

```python
from delta.tables import DeltaTable

delta_table = DeltaTable.forPath(spark, "/data/sales")
delta_table.history().show()
```

### Streaming

```python
# Read a Delta table as a stream
stream_df = spark.readStream.format("delta").load("/data/sales")

# Write a stream to a Delta table
(stream_df.writeStream
    .format("delta")
    .option("checkpointLocation", "/checkpoints/sales")
    .start("/data/sales_copy"))
```

**Key point:** One Delta table can be a **batch table and a streaming source/sink** at the same time.

---

## 6. Structure of a Delta Table

A Delta table is a **folder** with data files and a `_delta_log` folder.

```
/data/sales/
├── _delta_log/
│   ├── 00000000000000000000.json      ← version 0
│   ├── 00000000000000000001.json      ← version 1
│   ├── 00000000000000000002.json      ← version 2
│   ├── ...
│   ├── 00000000000000000010.checkpoint.parquet   ← checkpoint
│   └── _last_checkpoint
├── part-00000-abc.snappy.parquet
├── part-00001-def.snappy.parquet
└── country=Mexico/                    ← partition folder (if partitioned)
    └── part-00000-ghi.snappy.parquet
```

| Part | Purpose |
|---|---|
| **Parquet files** | The actual data |
| **`_delta_log/`** | The transaction log (the "brain" of the table) |
| **JSON files** | One file per commit (version) |
| **Checkpoint files** | A Parquet summary of the table state (saves time) |
| **`_last_checkpoint`** | Points to the latest checkpoint |
| **Partition folders** | Optional; used if the table is partitioned |

---

## 7. The Transaction Log

The **transaction log** (also called **DeltaLog**) is an **ordered record of every change** made to a Delta table.

- It is the **single source of truth**.
- Each commit creates **one new JSON file** with a version number.
- Files are **never edited**. Only new files are added (append-only log).

### How a query reads the table

1. Read the latest **checkpoint** (if there is one).
2. Read the **JSON files** after that checkpoint.
3. Combine them to know **which Parquet files are valid** right now.
4. Read only those Parquet files.

### Checkpoints

- By default, Delta creates a checkpoint **every 10 commits**.
- A checkpoint is a **Parquet file** with the full table state at that version.
- Benefit: Spark does not need to read all JSON files from version 0.

### Why is it important?

| Feature | How the log makes it possible |
|---|---|
| ACID | A commit is atomic: the new JSON file exists or it does not |
| Time travel | Each version is a snapshot of the log |
| Fast metadata | No need to list all files in cloud storage |
| Concurrency | Writers compete to create the next version file |

---

## 8. Actions: add, remove, metaData, protocol

Each JSON commit file contains a list of **actions**. An action is one change to the table.

### `add`

A new data file is **added** to the table.

```json
{"add": {
  "path": "part-00000-abc.snappy.parquet",
  "partitionValues": {"country": "Mexico"},
  "size": 1024,
  "modificationTime": 1700000000000,
  "dataChange": true,
  "stats": "{\"numRecords\": 100}"
}}
```

### `remove`

A data file is **logically removed** from the table. The file is **not deleted** from storage right away.

```json
{"remove": {
  "path": "part-00000-old.snappy.parquet",
  "deletionTimestamp": 1700000100000,
  "dataChange": true
}}
```

> The physical file is deleted later by `VACUUM`.

### `metaData`

Describes the table: **schema, partition columns, table ID, and configuration**.

```json
{"metaData": {
  "id": "table-uuid",
  "format": {"provider": "parquet"},
  "schemaString": "{...}",
  "partitionColumns": ["country"],
  "configuration": {}
}}
```

A new `metaData` action appears when the schema or table properties **change**.

### `protocol`

Defines the **minimum versions** needed to read and write the table.

```json
{"protocol": {"minReaderVersion": 1, "minWriterVersion": 2}}
```

If a client is too old, it **cannot** use the table.

### Summary table

| Action | Meaning |
|---|---|
| `add` | Add a data file to the table |
| `remove` | Remove a data file from the table (logically) |
| `metaData` | Schema, partitions, table settings |
| `protocol` | Required reader/writer versions |

> Other actions you may see: `commitInfo` (info about the operation) and `txn` (used by streaming for idempotent writes).

---

## 9. Append vs Overwrite

| | **Append** | **Overwrite** |
|---|---|---|
| What it does | Adds new data | Replaces existing data |
| Old files | Stay in the table | Marked as `remove` |
| New files | Marked as `add` | Marked as `add` |
| Risk | Duplicate data | Data loss if used by mistake |

### Append

```python
df.write.format("delta").mode("append").save("/data/sales")
```

Log: only `add` actions.

### Overwrite

```python
df.write.format("delta").mode("overwrite").save("/data/sales")
```

Log: `remove` actions (old files) + `add` actions (new files). This happens in **one atomic commit**.

### Overwrite only part of the table

```python
# Replace only rows that match a condition
(df.write.format("delta")
   .mode("overwrite")
   .option("replaceWhere", "date >= '2024-01-01' AND date < '2024-02-01'")
   .save("/data/sales"))
```

> Important: with Delta, `overwrite` is **safe**. The old data is still available with time travel (until `VACUUM`).

---

## 10. UPDATE, DELETE, MERGE INTO (Upsert)

Parquet files are **immutable**. Delta Lake changes data by **rewriting the affected files**.

> How it works: Delta finds the files with matching rows → writes new files with the changes → `remove` old files + `add` new files.

### UPDATE

```sql
UPDATE sales SET amount = amount * 1.1 WHERE country = 'Mexico';
```

### DELETE

```sql
DELETE FROM sales WHERE order_date < '2020-01-01';
```

### MERGE INTO (Upsert)

**Upsert = Update + Insert.** If the row exists → update it. If not → insert it.

```sql
MERGE INTO sales AS target
USING updates AS source
ON target.id = source.id
WHEN MATCHED THEN
  UPDATE SET target.amount = source.amount
WHEN NOT MATCHED THEN
  INSERT (id, amount) VALUES (source.id, source.amount);
```

You can also delete rows in a merge:

```sql
WHEN MATCHED AND source.is_deleted = true THEN DELETE
```

### Python version

```python
from delta.tables import DeltaTable

target = DeltaTable.forPath(spark, "/data/sales")

(target.alias("t")
   .merge(updates_df.alias("s"), "t.id = s.id")
   .whenMatchedUpdateAll()
   .whenNotMatchedInsertAll()
   .execute())
```

### Summary

| Operation | Use it when… |
|---|---|
| `UPDATE` | You need to change values in existing rows |
| `DELETE` | You need to remove rows (e.g., GDPR requests) |
| `MERGE` | You have a mix of new and changed rows (CDC, upserts) |

> Tip: In `MERGE`, the source must have **only one row per key**. Multiple matches cause an error.

---

## 11. Schema Enforcement

**Schema enforcement** (also called **schema validation**) means Delta Lake **rejects writes** that do not match the table schema.

### What is checked?

- Extra columns that are not in the table → ❌ rejected
- Different data types → ❌ rejected
- Different column names (case-only differences) → ❌ rejected
- Missing columns → ✅ allowed (they become `null`)

### Example

Table schema: `id INT, name STRING`

```python
# This DataFrame has an extra column "age"
df_new = spark.createDataFrame([(1, "Ana", 30)], ["id", "name", "age"])

df_new.write.format("delta").mode("append").save("/data/people")
# ❌ AnalysisException: A schema mismatch detected
```

**Why is it useful?**

- Protects data quality.
- Stops "bad data" early.
- Delta checks the schema **at write time** (**schema-on-write**).

> Also: Delta Lake supports **constraints** (`NOT NULL`, `CHECK`) for extra validation.

```sql
ALTER TABLE sales ADD CONSTRAINT positive_amount CHECK (amount > 0);
```

---

## 12. mergeSchema

**`mergeSchema`** lets you **add new columns** to a table automatically when you write.

```python
(df_new.write.format("delta")
   .mode("append")
   .option("mergeSchema", "true")
   .save("/data/people"))
```

Result: the table now has `id`, `name`, **and `age`**. Old rows get `null` in `age`.

### Enable it for the whole session

```python
spark.conf.set("spark.databricks.delta.schema.autoMerge.enabled", "true")
```

This is also used in `MERGE INTO` when the source has new columns.

### What `mergeSchema` can do

| Change | Allowed? |
|---|---|
| Add new columns | ✅ Yes |
| Some safe type upgrades (e.g., `INT` → `LONG`) | ✅ Yes (in some cases) |
| Change a column type (e.g., `STRING` → `INT`) | ❌ No |
| Delete or rename columns | ❌ No |

---

## 13. overwriteSchema

**`overwriteSchema`** lets you **completely replace** the schema of a table. It is used **only with `overwrite` mode**.

```python
(df_new.write.format("delta")
   .mode("overwrite")
   .option("overwriteSchema", "true")
   .save("/data/people"))
```

Use it when you need to:

- Change a column's **data type**.
- **Remove** or **rename** columns.
- Change the **partitioning** of the table.

### `mergeSchema` vs `overwriteSchema`

| | `mergeSchema` | `overwriteSchema` |
|---|---|---|
| Works with | `append` and `overwrite` | `overwrite` only |
| Effect | **Adds** new columns | **Replaces** the whole schema |
| Existing data | Kept | Replaced (all data is overwritten) |
| Risk | Low | High |

> Warning: `overwriteSchema` replaces the table data too. Use with care.

---

## 14. Time Travel

**Time travel** lets you **query an old version** of a Delta table. It works because the log keeps every version.

### By version number

```python
df = spark.read.format("delta").option("versionAsOf", 5).load("/data/sales")
```

```sql
SELECT * FROM sales VERSION AS OF 5;
```

### By timestamp

```python
df = (spark.read.format("delta")
        .option("timestampAsOf", "2024-01-15 10:00:00")
        .load("/data/sales"))
```

```sql
SELECT * FROM sales TIMESTAMP AS OF '2024-01-15';
```

### See the history

```sql
DESCRIBE HISTORY sales;
```

### Restore an old version

```sql
RESTORE TABLE sales TO VERSION AS OF 5;
```

### Use cases

- Fix mistakes (a bad `DELETE` or `OVERWRITE`).
- Audit changes.
- Reproduce ML experiments.
- Compare data between two dates.

### Retention (important!)

| Setting | Default | Meaning |
|---|---|---|
| `delta.logRetentionDuration` | 30 days | How long log history is kept |
| `delta.deletedFileRetentionDuration` | 7 days | How long removed files are kept before `VACUUM` can delete them |

> `VACUUM` deletes old files **permanently**. After that, you **cannot** time travel to those versions.

```sql
VACUUM sales RETAIN 168 HOURS;  -- 7 days
```

---

## 15. ACID Transactions

**ACID** is a set of 4 guarantees for reliable data operations.

| Letter | Property | Simple meaning | How Delta Lake does it |
|---|---|---|---|
| **A** | **Atomicity** | All or nothing | A commit = one JSON file in the log. It exists or it does not. |
| **C** | **Consistency** | Data is always valid | Schema enforcement and constraints |
| **I** | **Isolation** | Operations do not disturb each other | Snapshot isolation + optimistic concurrency control |
| **D** | **Durability** | Committed data is not lost | Data and log are stored in durable cloud storage |

### Isolation levels in Delta Lake

| Level | Description |
|---|---|
| `Serializable` | Strongest. Reads and writes act as if they ran one by one. |
| `WriteSerializable` | **Default for writes.** Fewer conflicts; only writes are serialized. |

> Readers always see a **consistent snapshot**. They never see data from a write that is still in progress.

---

## 16. Partitioning and File Pruning

### Partitioning

**Partitioning** splits a table into folders based on a column's values.

```python
(df.write.format("delta")
   .partitionBy("country")
   .save("/data/sales"))
```

```
/data/sales/
├── country=Mexico/
├── country=USA/
└── country=Brazil/
```

### Partition pruning (file pruning)

When you filter by the partition column, Spark **reads only the matching folders** and **skips the rest**.

```sql
SELECT * FROM sales WHERE country = 'Mexico';
-- Spark reads only the country=Mexico folder
```

Delta does this using the partition values stored in the `add` actions of the log, so it does not even need to list the folders.

### Data skipping (file-level statistics)

Delta also stores **min/max values** for the first columns of each file (in `stats`). Spark skips files that cannot match your filter.

To improve skipping on non-partition columns, use **Z-ORDER** or **Liquid Clustering**:

```sql
OPTIMIZE sales ZORDER BY (customer_id);
```

### Good partitioning rules

| ✅ Do | ❌ Don't |
|---|---|
| Use **low-cardinality** columns (e.g., `country`, `date`) | Use high-cardinality columns (e.g., `user_id`) |
| Make sure each partition has **at least ~1 GB** of data | Create many tiny partitions |
| Partition by columns used often in filters | Partition "just in case" |
| Do not partition tables smaller than ~1 TB | Over-partition small tables |

> Too many partitions → many small files → slow queries (see the next section).

---

## 17. Small Files Problem

### What is it?

A table with **many very small files** (KBs or a few MBs) instead of fewer, larger files (ideally ~128 MB–1 GB).

### Why is it a problem?

- Spark opens **each file**: too much overhead.
- More metadata in the log to read.
- Slower queries and higher cloud costs (more API requests).

### Common causes

| Cause | Example |
|---|---|
| Streaming with short triggers | A new file every few seconds |
| Frequent small appends | Many tiny batch jobs |
| Over-partitioning | Partitioning by a high-cardinality column |
| Too many shuffle partitions | Default `spark.sql.shuffle.partitions = 200` for small data |

### Solutions

**1. `OPTIMIZE` (compaction):** combine small files into larger ones.

```sql
OPTIMIZE sales;
OPTIMIZE sales WHERE date >= '2024-01-01';   -- only part of the table
```

**2. Optimized writes and auto compaction (table properties):**

```sql
ALTER TABLE sales SET TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact'  = 'true'
);
```

**3. `repartition` / `coalesce`** before writing.

**4. Better partition design** (fewer, bigger partitions).

**5. `VACUUM`** to delete the old small files after compaction.

### Important detail

`OPTIMIZE` creates **new big files** and marks the small ones as `remove`. The small files are physically deleted only after `VACUUM`.

---

## 18. What Happens When a Write Fails?

Delta Lake writes in **two steps**:

1. **Write data files** (Parquet) to storage.
2. **Commit**: write a new JSON file to `_delta_log` with the `add`/`remove` actions.

### Case 1: Failure *before* the commit

- Parquet files may exist in storage, but **no `add` action** points to them.
- The table **does not change**. Readers do not see these files.
- Those files are **orphan files**. They waste space.
- `VACUUM` can delete them later.

### Case 2: Failure *during* the commit

- The log file is written **atomically**. It either exists completely or does not exist.
- If it does not exist → the commit did not happen → table is unchanged.

### Case 3: Failure *after* the commit

- The data is safely committed. The table is in the **new** state.

### Result

| Moment of failure | Table state | Cleanup |
|---|---|---|
| Before commit | Unchanged (old version) | `VACUUM` removes orphan files |
| During commit | Unchanged (old version) | Nothing needed |
| After commit | New version | Nothing needed |

**Key point:** Thanks to **atomicity**, you never get a "half-written" table. You can safely **retry** the job.

> For streaming, the `checkpointLocation` and the `txn` action help avoid duplicate writes when a job restarts (**idempotent writes**).

---

## 19. Optimistic Concurrency Control (OCC)

**OCC** is how Delta Lake allows **many writers at the same time** without locks.

**Main idea:** "Assume there will be no conflict. Check at the end. If there is a conflict, handle it."

### The 3 stages of a write

1. **Read:** The writer reads the latest table version (e.g., version `N`) to know which files to change.
2. **Write:** The writer creates new data files (not visible yet).
3. **Validate and commit:** The writer tries to create the next log file (`N+1`).
   - If version `N+1` **does not exist** → commit succeeds ✅.
   - If version `N+1` **already exists** (another writer won) → Delta **checks for conflicts** with the new commits.
     - **No conflict** → Delta silently retries the commit as version `N+2` ✅.
     - **Conflict** → the write fails with an exception ❌.

### Visual example

```
Writer A: read v5 ───► write files ───► commit v6  ✅
Writer B: read v5 ───► write files ───► commit v6?  ✗ (taken)
                                         check conflicts
                                         ├─ no conflict → commit v7 ✅
                                         └─ conflict    → exception ❌
```

### Why "mutual exclusion"?

The storage system must guarantee that **only one writer can create a given log file name**. This is what makes commits atomic and ordered.

### OCC vs Pessimistic locking

| | OCC (Delta Lake) | Pessimistic locking |
|---|---|---|
| Locks | No locks | Locks the table |
| Concurrency | High | Low |
| Best when | Conflicts are rare | Conflicts are common |
| Cost of conflict | Work is lost and must be retried | Writers wait |

---

## 20. Conflicts Between Concurrent Writes

A conflict happens when two operations **touch the same data** in a way that cannot be merged safely.

### Which operations conflict? (simplified)

| | `INSERT` / append | `UPDATE` / `DELETE` / `MERGE` | `OPTIMIZE` |
|---|---|---|---|
| **INSERT / append** | ✅ No conflict | ⚠️ May conflict | ✅ No conflict |
| **UPDATE / DELETE / MERGE** | ⚠️ May conflict | ⚠️ Conflict if same files | ⚠️ May conflict |
| **OPTIMIZE** | ✅ No conflict | ⚠️ May conflict | ⚠️ Conflict if same files |

> Appending to a table while another job appends is usually safe. Two jobs changing the **same files** is **not** safe.

### Common exceptions

| Exception | Meaning |
|---|---|
| `ConcurrentAppendException` | Another job added files to the data you read or changed |
| `ConcurrentDeleteReadException` | Another job deleted a file that your job read |
| `ConcurrentDeleteDeleteException` | Two jobs deleted (or rewrote) the **same file** |
| `MetadataChangedException` | Another job changed the table schema or properties |
| `ProtocolChangedException` | The table protocol was upgraded by another job |
| `ConcurrentTransactionException` | Two streams use the same checkpoint / transaction ID |

### How to avoid conflicts

1. **Partition your table** and make each job work on **different partitions**.
2. Put the partition column **in the condition** of `MERGE`, `UPDATE`, and `DELETE`:

   ```sql
   MERGE INTO sales t
   USING updates s
   ON t.id = s.id AND t.country = 'Mexico'   -- explicit partition filter
   ```

3. Do not run `OPTIMIZE` at the same time as heavy updates on the same partitions.
4. Use the weaker isolation level `WriteSerializable` (the default).
5. **Retry** failed jobs. Because of atomicity, retry is safe.
6. Avoid running many jobs that update the same rows.

---

## 21. Quick Review Questions

1. What two things make a Delta table?
2. What is inside the `_delta_log` folder?
3. What is the difference between `add` and `remove`?
4. Why does Delta create checkpoint files?
5. What does `remove` do to the physical file?
6. What is the difference between `append` and `overwrite`?
7. What is an *upsert*? Which command does it?
8. What happens if you write a DataFrame with an extra column?
9. What is the difference between `mergeSchema` and `overwriteSchema`?
10. How can you read version 3 of a table?
11. What does `VACUUM` do? How does it affect time travel?
12. What does ACID mean?
13. What are the 3 stages of Optimistic Concurrency Control?
14. What happens if a job fails before the commit?
15. Name two causes of the small files problem and two solutions.
16. Why should you avoid partitioning by `user_id`?
17. How can you reduce write conflicts?

---

## 22. Glossary

| Term | Simple definition |
|---|---|
| **Delta Lake** | Storage layer that adds reliability to data lakes |
| **Parquet** | Columnar file format used to store the data |
| **Transaction log / DeltaLog** | Ordered record of all changes to the table |
| **Commit** | One atomic change recorded in the log (one JSON file) |
| **Version** | Number of a commit (0, 1, 2, …) |
| **Checkpoint** | Parquet summary of the table state at a version |
| **Action** | One entry in the log (`add`, `remove`, `metaData`, `protocol`) |
| **Snapshot** | State of the table at a specific version |
| **ACID** | Atomicity, Consistency, Isolation, Durability |
| **OCC** | Concurrency method without locks; checks conflicts at commit time |
| **Upsert** | Update existing rows + insert new rows |
| **Schema enforcement** | Rejecting writes that do not match the schema |
| **Schema evolution** | Changing the table schema (e.g., with `mergeSchema`) |
| **Time travel** | Reading older versions of a table |
| **Partition pruning** | Skipping partitions that do not match the filter |
| **Data skipping** | Skipping files using min/max statistics |
| **Z-ORDER** | Technique to group related data in the same files |
| **OPTIMIZE** | Command that compacts small files into bigger ones |
| **VACUUM** | Command that permanently deletes old, unused files |
| **Orphan file** | Data file that exists in storage but is not in the log |
| **Lakehouse** | Architecture that mixes data lake and data warehouse features |
| **Medallion architecture** | Bronze → Silver → Gold data layers |

---

*Good luck with your studies! 🚀*
