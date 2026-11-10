# AWS Athena Study Guide

## Table of Contents

1. [What is a Data Lake?](#1-what-is-a-data-lake)
2. [What is Athena and how does it work?](#2-what-is-athena-and-how-does-it-work)
3. [When to use Athena](#3-when-to-use-athena)
4. [Serverless architecture](#4-serverless-architecture)
5. [Athena, S3, and Glue Data Catalog](#5-athena-s3-and-glue-data-catalog)
6. [What are Parquet files?](#6-what-are-parquet-files)
7. [Compression: Snappy vs GZIP](#7-compression-snappy-vs-gzip)
8. [Partitioning](#8-partitioning)
9. [Predicate pushdown](#9-predicate-pushdown)
10. [Bucketing and small files](#10-bucketing-and-small-files)
11. [Cost reduction practices](#11-cost-reduction-practices)
12. [Performance tuning (slow queries)](#12-performance-tuning-slow-queries)
13. [Quick glossary](#13-quick-glossary)
14. [Self-check questions](#14-self-check-questions)

---

## 1. What is a Data Lake?

A **data lake** is a central place where you store **all your data** in its **original format**: structured, semi-structured, or unstructured.

| Type | Examples |
|------|----------|
| Structured | CSV, database tables |
| Semi-structured | JSON, XML, logs |
| Unstructured | Images, PDFs, audio |

**Key points**

- You store data **first** and decide how to use it **later** (this is called *schema-on-read*).
- Storage is cheap and can grow without limits.
- On AWS, the data lake is usually built on **Amazon S3**.
- Different tools (Athena, Glue, EMR, Redshift) can read the same data.

**Data lake vs. data warehouse**

| | Data Lake | Data Warehouse |
|---|-----------|----------------|
| Data | Raw, any format | Clean, structured |
| Schema | Applied when reading | Defined before loading |
| Cost | Lower | Higher |
| Example | S3 | Redshift |

---

## 2. What is Athena and how does it work?

**Amazon Athena** is a service that lets you run **SQL queries directly on files in S3**. You do not need to load the data into a database first.

**How it works (step by step)**

1. Your data is stored as files in **S3**.
2. You define a **table** that describes the files (columns, types, location).
3. You write a **SQL query** in the Athena console, API, or a BI tool.
4. Athena reads only the needed files from S3 and runs the query.
5. Results are shown to you and saved in an **S3 results bucket**.

**Key points**

- Based on **Trino/Presto** (SQL engine).
- Uses standard SQL (ANSI SQL).
- Supports CSV, JSON, **Parquet**, ORC, Avro, and more.
- You pay **per data scanned** (about **$5 per TB**, check current pricing).

**Example**

```sql
SELECT country, COUNT(*) AS total_orders
FROM sales_db.orders
WHERE order_date >= DATE '2025-01-01'
GROUP BY country;
```

---

## 3. When to use Athena

### Good use cases ✅

- **Ad hoc queries**: quick questions on data in S3.
- **Log analysis**: CloudTrail, VPC Flow Logs, ALB logs, application logs.
- **Data exploration** before building a bigger pipeline.
- **Occasional reports** (not running all day).
- **Querying a data lake** without managing servers.

### Not ideal ❌

| Situation | Better option |
|-----------|---------------|
| Millisecond response (apps, APIs) | DynamoDB, RDS, Aurora |
| Many users running heavy queries all day | Redshift |
| Frequent row updates/transactions (OLTP) | RDS, Aurora |
| Very complex ETL with big transformations | Glue, EMR, Spark |

**Rule of thumb:** Athena is great for **analytics on S3** when you want **no infrastructure** and **pay-per-query**.

---

## 4. Serverless architecture

**Serverless** does not mean "no servers." It means **you do not manage the servers**. AWS does it for you.

**What AWS manages**

- Provisioning and scaling compute
- Patching and updates
- High availability

**What you manage**

- Your data in S3
- Your table definitions
- Your SQL queries

**Benefits for Athena**

| Benefit | Meaning |
|---------|---------|
| No setup | Start querying in minutes |
| Auto scaling | Athena adds compute when needed |
| Pay per use | No cost when you do not run queries |
| Low maintenance | No clusters to tune or patch |

**Important idea: separation of storage and compute**

```
   [ S3 ]  <---- reads ----  [ Athena compute ]
 (storage)                    (temporary, managed by AWS)
```

Data stays in S3. Compute appears only when you run a query.

---

## 5. Athena, S3, and Glue Data Catalog

These three services work together:

| Service | Role | Simple analogy |
|---------|------|----------------|
| **S3** | Stores the data files | The books in a library |
| **Glue Data Catalog** | Stores metadata (table names, columns, types, locations, partitions) | The library catalog |
| **Athena** | Runs SQL queries | The librarian who finds the answer |

**Flow**

```
You (SQL) --> Athena --> Glue Data Catalog (Where is the data? What columns?)
                 |
                 +-----> S3 (reads the files)
                 |
                 +-----> S3 results bucket (saves output)
```

**Key points**

- The Glue Data Catalog does **not** store your data. It stores **information about your data**.
- A **database** in Athena = a database in the Glue Catalog.
- A **table** points to an **S3 path**.
- A **Glue Crawler** can scan S3 and **create tables automatically**.
- Other services (EMR, Redshift Spectrum, Glue ETL) can use the **same catalog**.

**Example: create a table**

```sql
CREATE EXTERNAL TABLE sales_db.orders (
  order_id   bigint,
  customer   string,
  amount     double
)
PARTITIONED BY (order_date string)
STORED AS PARQUET
LOCATION 's3://my-bucket/orders/';
```

> `EXTERNAL` means: if you drop the table, the **S3 data is not deleted**. Only the metadata is removed.

---

## 6. What are Parquet files?

**Apache Parquet** is a **columnar** file format designed for analytics.

**Row format vs. column format**

```
Row format (CSV):          Column format (Parquet):
id,name,country,amount     id:      1, 2, 3
1,Ana,MX,100               name:    Ana, Luis, Eva
2,Luis,US,200              country: MX, US, ES
3,Eva,ES,300               amount:  100, 200, 300
```

**Why Parquet is great for Athena**

| Feature | Benefit |
|---------|---------|
| Reads only needed columns | Less data scanned = lower cost |
| Compressed by default | Smaller files in S3 |
| Stores data types and schema | Fewer errors |
| Stores min/max statistics | Allows skipping data (see [Predicate pushdown](#9-predicate-pushdown)) |
| Splittable | Many workers can read in parallel |

**Example**

```sql
SELECT amount FROM orders;
```

- **CSV:** Athena reads the **whole file**.
- **Parquet:** Athena reads **only the `amount` column**.

**Tip:** Converting CSV/JSON to Parquet often reduces cost and query time by a large amount (commonly **30–90%**).

**Convert with CTAS**

```sql
CREATE TABLE orders_parquet
WITH (
  format = 'PARQUET',
  parquet_compression = 'SNAPPY',
  external_location = 's3://my-bucket/orders_parquet/'
) AS
SELECT * FROM orders_csv;
```

---

## 7. Compression: Snappy vs GZIP

**Compression** makes files smaller. Smaller files mean less storage, less network transfer, and less data scanned.

| | **Snappy** | **GZIP** |
|---|-----------|----------|
| Goal | **Speed** | **Smaller size** |
| Compression ratio | Medium | High |
| Compress/decompress speed | Fast | Slower |
| CPU use | Low | Higher |
| Default in Parquet? | Yes (common default) | No |

**When to use Snappy**

- Data is **queried often**.
- You want **fast queries**.
- You use **Parquet** (the usual best choice).

**When to use GZIP**

- Data is **rarely queried** (archive, cold data).
- **Storage cost** is the main concern.
- You want the **smallest possible files**.

**Important: splittability**

- A **splittable** file can be read by many workers in parallel (faster).
- **Plain GZIP text files (CSV.gz) are NOT splittable**: one worker reads the whole file. This can be slow for big files.
- **Parquet with Snappy or GZIP is fine**: Parquet compresses inside its internal blocks, so the file stays splittable.

**Quick decision**

```
Frequently queried?  → Snappy
Rarely queried / archive?  → GZIP
Not sure?  → Parquet + Snappy
```

> Note: Athena also supports other codecs like **ZSTD**, which offers a good balance between size and speed.

---

## 8. Partitioning

**Partitioning** splits a table into **folders** based on column values. Athena can then read **only the folders it needs**.

**S3 structure**

```
s3://my-bucket/orders/
   year=2025/month=01/part-0001.parquet
   year=2025/month=02/part-0001.parquet
   year=2025/month=03/part-0001.parquet
```

**Create a partitioned table**

```sql
CREATE EXTERNAL TABLE orders (
  order_id bigint,
  amount   double
)
PARTITIONED BY (year string, month string)
STORED AS PARQUET
LOCATION 's3://my-bucket/orders/';
```

**Query with a partition filter**

```sql
SELECT SUM(amount)
FROM orders
WHERE year = '2025' AND month = '02';   -- Athena reads only 1 folder
```

This is called **partition pruning**.

**Registering partitions**

| Method | Description |
|--------|-------------|
| `MSCK REPAIR TABLE orders;` | Finds new folders in Hive format (`key=value`) |
| `ALTER TABLE ... ADD PARTITION` | Adds one partition manually |
| Glue Crawler | Detects partitions automatically |
| **Partition projection** | Athena calculates partitions from rules (no catalog lookups; faster for many partitions) |

**Best practices**

- Partition by columns used often in `WHERE` (usually **date**).
- Choose columns with **low to medium cardinality** (few distinct values).
- ❌ Avoid partitioning by `user_id` or `order_id`: too many tiny folders.
- Do not over-partition: aim for partitions that hold **at least ~128 MB** of data.
- Always **include the partition column in your filter**.

---

## 9. Predicate pushdown

A **predicate** is a filter condition, like `WHERE amount > 100`.

**Predicate pushdown** means the filter is applied **as early as possible**, close to the storage, instead of after loading all data. This way, less data is read and processed.

**Without pushdown**

```
Read ALL data → Load into memory → Filter → Result
```

**With pushdown**

```
Check file metadata → Skip data that cannot match → Read only needed data → Result
```

**How it works with Parquet**

Parquet stores **min/max statistics** for each **row group** (a block of rows).

| Row group | Min amount | Max amount |
|-----------|-----------:|-----------:|
| 1 | 10 | 90 |
| 2 | 150 | 500 |
| 3 | 20 | 80 |

Query: `WHERE amount > 100`

- Row groups 1 and 3: max is below 100 → **skipped**.
- Row group 2: **read**.

**Tips to get better pushdown**

- Use **Parquet or ORC** (CSV and JSON do not have these statistics).
- **Sort data** by the columns you filter often. This makes min/max ranges tighter and more useful.
- Use **simple filters** on raw columns:

```sql
-- ✅ Good (pushdown works)
WHERE order_date = DATE '2025-01-15'

-- ❌ Worse (function on the column can block pushdown)
WHERE year(order_date) = 2025
```

> Partition pruning and predicate pushdown are related, but different: **pruning** skips **folders**; **pushdown** skips **data inside files**.

---

## 10. Bucketing and small files

### The small files problem

Athena is slow when a table has **many tiny files** (for example, thousands of files of 100 KB).

**Why it is a problem**

- Each file needs a separate S3 request (**overhead**).
- Workers spend more time **opening files** than **reading data**.
- Parquet gets less benefit from compression and statistics.

**Recommended file size:** about **128 MB to 1 GB** per file.

**How to fix small files**

| Solution | How |
|----------|-----|
| **Compaction with CTAS / INSERT INTO** | Rewrite many small files into fewer big ones |
| **Glue ETL job** | Merge files on a schedule |
| **Kinesis Firehose buffering** | Increase buffer size/interval to write larger files |
| **Fewer partitions** | Avoid over-partitioning (e.g., hourly if daily is enough) |

**Example: compact files with CTAS**

```sql
CREATE TABLE orders_compacted
WITH (
  format = 'PARQUET',
  parquet_compression = 'SNAPPY',
  external_location = 's3://my-bucket/orders_compacted/'
) AS
SELECT * FROM orders_small_files;
```

### Bucketing

**Bucketing** groups rows into a **fixed number of files (buckets)** using a **hash** of a column. Rows with the same value always go to the same bucket.

```sql
CREATE TABLE orders_bucketed
WITH (
  format = 'PARQUET',
  bucketed_by = ARRAY['customer_id'],
  bucket_count = 10,
  external_location = 's3://my-bucket/orders_bucketed/'
) AS
SELECT * FROM orders;
```

**When bucketing helps**

- Column has **high cardinality** (many distinct values), like `customer_id`.
- You often **filter by equality** on that column (`WHERE customer_id = 123`).
- You do **joins** on that column.
- It controls the **number of output files** (avoids tiny files).

**Partitioning vs. bucketing**

| | Partitioning | Bucketing |
|---|--------------|-----------|
| Splits data by | Column **value** (folders) | **Hash** of value (files) |
| Best for | Low cardinality (date, country) | High cardinality (customer_id) |
| Number of splits | Grows with distinct values | **Fixed** |

> Use them **together**: partition by date, bucket by customer ID.

---

## 11. Cost reduction practices

**Remember:** Athena charges mainly by **data scanned**. The goal is to **scan less data**.

| # | Practice | Why it helps |
|---|----------|--------------|
| 1 | **Use Parquet or ORC** | Columnar format reads fewer bytes |
| 2 | **Compress data** (Snappy, ZSTD, GZIP) | Fewer bytes scanned |
| 3 | **Partition your data** | Skips whole folders |
| 4 | **Always filter on partition columns** | Enables partition pruning |
| 5 | **Avoid `SELECT *`** | Select only needed columns |
| 6 | **Use `LIMIT` carefully** | Can reduce output, but may still scan a lot; it is not a guaranteed saving |
| 7 | **Compact small files** | Fewer requests and less overhead |
| 8 | **Use Workgroups with data scan limits** | Prevents expensive queries and tracks costs per team |
| 9 | **Use tags and cost allocation** | Know who spends what |
| 10 | **Use CTAS to create smaller, filtered tables** | Run later queries on less data |
| 11 | **Set S3 lifecycle rules** for query results | Delete old result files |
| 12 | **Consider Provisioned Capacity** for steady, heavy workloads | Predictable cost instead of per-TB |

**Good vs. bad example**

```sql
-- ❌ Expensive
SELECT * FROM logs;

-- ✅ Cheaper
SELECT request_id, status
FROM logs
WHERE year = '2025' AND month = '06' AND day = '15';
```

**Good to know**

- **Failed queries** are not charged. **DDL** statements (`CREATE`, `ALTER`, `DROP`) are free.
- There is a **minimum charge** per query (10 MB scanned), so many tiny queries cost more than expected.
- **S3 request costs** and **Glue Catalog costs** may also add up.

---

## 12. Performance tuning (slow queries)

**Quick diagnosis checklist**

1. Is the data in **Parquet/ORC**?
2. Is the table **partitioned**, and does the query **filter by partition**?
3. Are there **too many small files**?
4. Are you scanning **too many columns**?
5. Is the query doing a **heavy join, sort, or `DISTINCT`**?

**Common practices**

| Problem | Solution |
|---------|----------|
| Slow scans on CSV/JSON | Convert to **Parquet** |
| Reading too much data | **Partition** and filter on partitions |
| Thousands of tiny files | **Compact** to 128 MB–1 GB files |
| Too many partitions (slow planning) | Use **partition projection** |
| Reading unneeded columns | **Avoid `SELECT *`** |
| Slow joins | Put the **larger table on the left** and the **smaller on the right** |
| Slow `ORDER BY` on large data | Use `ORDER BY ... LIMIT` or remove sorting |
| Slow `COUNT(DISTINCT x)` | Use **`approx_distinct(x)`** if exact numbers are not needed |
| Many `LIKE` filters | Use `regexp_like` with a single pattern, or filter on partitions first |
| Filters not skipping data | Avoid **functions on filter columns**; sort data by filter columns |
| Skewed data (one value is huge) | Choose better partition/bucket columns |
| Repeated heavy queries | Save results with **CTAS** or a **view/materialized table** |
| Hitting concurrency limits | Use **Workgroups**, spread out queries, or **Provisioned Capacity** |

**Example: approximate distinct count**

```sql
SELECT approx_distinct(user_id) FROM events;   -- faster than COUNT(DISTINCT user_id)
```

**Example: join order**

```sql
-- ✅ Large table on the LEFT, small table on the RIGHT
SELECT *
FROM big_events e
JOIN small_users u ON e.user_id = u.user_id;
```

**Use `EXPLAIN` and query stats**

- Run `EXPLAIN SELECT ...` to see the query plan.
- Check **"Data scanned"** and **"Run time"** in the Athena console.
- If data scanned is huge for a small result, review your **partitions and file format**.

**Golden rule**

> **Read less data, in fewer and bigger files, in a columnar format.**

---

## 13. Quick glossary

| Term | Simple definition |
|------|-------------------|
| **Athena** | Serverless SQL service for data in S3 |
| **S3** | AWS object storage |
| **Glue Data Catalog** | Metadata store (tables, columns, partitions) |
| **Data Lake** | Central storage for raw data of any type |
| **Parquet** | Columnar file format for analytics |
| **Snappy** | Fast compression |
| **GZIP** | High compression, slower |
| **Partition** | Folder split of data by column value |
| **Bucket** | Group of rows by hash, stored in a fixed number of files |
| **Predicate** | A filter condition (`WHERE ...`) |
| **Predicate pushdown** | Applying filters early to read less data |
| **CTAS** | `CREATE TABLE AS SELECT` |
| **Workgroup** | Athena feature to separate users, limits, and costs |
| **Schema-on-read** | Applying the structure when reading, not when storing |
| **Cardinality** | Number of distinct values in a column |

---

## 14. Self-check questions

1. What is the difference between a data lake and a data warehouse?
2. Where does Athena store the **data**, and where does it store the **table definitions**?
3. Why does Athena run faster on Parquet than on CSV?
4. When would you choose GZIP over Snappy?
5. What is the difference between **partition pruning** and **predicate pushdown**?
6. Why are many small files a problem? What is a good file size?
7. When is bucketing better than partitioning?
8. Name **five** ways to reduce Athena costs.
9. A query is slow. What are the first three things you check?
10. Why can `WHERE year(order_date) = 2025` be worse than a direct date filter?

---

*Good luck with your studies! 🚀*
