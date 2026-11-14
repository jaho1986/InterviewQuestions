# Apache Spark Study Guide

A short and simple guide for English learners. Examples use **PySpark** (Spark with Python).

---

## Table of Contents

1. [What is Apache Spark?](#1-what-is-apache-spark)
2. [What is a DataFrame?](#2-what-is-a-dataframe)
3. [How is Spark fault tolerant?](#3-how-is-spark-fault-tolerant)
4. [What is an action?](#4-what-is-an-action)
5. [What is an accumulator?](#5-what-is-an-accumulator)
6. [What is a closure and why is it important?](#6-what-is-a-closure-and-why-is-it-important)
7. [How to avoid problems with closures](#7-how-to-avoid-problems-with-closures)
8. [Types of transformations](#8-types-of-transformations)
9. [What is a shuffle?](#9-what-is-a-shuffle)
10. [What is the physical plan?](#10-what-is-the-physical-plan)
11. [persist and storage levels](#11-persist-and-storage-levels)
12. [Commutative operations](#12-commutative-operations)
13. [What is the SparkContext?](#13-what-is-the-sparkcontext)
14. [Common transformations](#14-common-transformations-map-flatmap-reduce-filter-groupby)
15. [What is Catalyst?](#15-what-is-catalyst)
16. [3 reasons a Spark job can be slow](#16-three-common-reasons-a-spark-job-is-slow)
17. [What is coalesce?](#17-what-is-coalesce)
18. [What are partitions for?](#18-what-are-partitions-for)
19. [How to change the number of partitions when writing](#19-how-to-change-the-number-of-partitions-when-writing)
20. [Example: Word Count](#20-example-word-count)
21. [Quick Review](#21-quick-review)

---

## 1. What is Apache Spark?

**Apache Spark** is an open-source engine for processing **big data** quickly.

- It works on a **cluster** (many computers working together).
- It keeps data **in memory** when possible, so it is faster than older tools like Hadoop MapReduce.
- It supports Python, Scala, Java, R, and SQL.
- It includes modules for SQL, streaming, machine learning (MLlib), and graphs (GraphX).

**Basic architecture:**

| Part | Role |
|------|------|
| **Driver** | The main program. It reads the code, makes a plan and schedules work. |
| **Executors** | Worker processes. They run the tasks and store data. |
| **Cluster manager** | Gives resources (YARN, Kubernetes, Standalone). |

---

## 2. What is a DataFrame?

A **DataFrame** is a table of data with **rows and named columns**, like a table in SQL or a pandas DataFrame.

- It is **distributed**: the data is split across many machines.
- It is **immutable**: you cannot change it. Every change creates a new DataFrame.
- It has a **schema** (column names and types).
- It is **lazy**: Spark does not run anything until you call an action.

```python
df = spark.read.csv("people.csv", header=True, inferSchema=True)
df.filter(df.age > 30).select("name", "age").show()
```

> **Tip:** Prefer DataFrames over RDDs. Spark can optimize them (see [Catalyst](#15-what-is-catalyst)).

---

## 3. How is Spark fault tolerant?

**Fault tolerant** means Spark can continue working when something fails (for example, a machine crashes).

Main mechanisms:

1. **Lineage (DAG):** Spark remembers *how* each dataset was built (the chain of transformations). If a partition is lost, Spark **recomputes** only that partition.
2. **Immutability:** Data never changes, so it is safe to rebuild it.
3. **Task retries:** If a task fails, Spark runs it again on another executor.
4. **Persist with replication:** You can store copies on two nodes (`MEMORY_ONLY_2`).
5. **Checkpointing:** Save data to reliable storage (like HDFS or S3) to cut a long lineage.
6. **Speculative execution:** If a task is very slow, Spark can start a copy and use the first one that finishes.

---

## 4. What is an action?

An **action** is an operation that **starts the computation** and returns a result to the driver or writes data to storage.

Transformations are lazy. **Actions trigger them.**

| Action | What it does |
|--------|--------------|
| `show()` | Prints rows |
| `count()` | Counts rows |
| `collect()` | Returns all rows to the driver (**careful with big data!**) |
| `take(n)` / `first()` | Returns a few rows |
| `write.save()` / `saveAsTextFile()` | Writes data to storage |
| `reduce()` | Combines all elements into one value |

```python
df2 = df.filter(df.age > 30)   # transformation: nothing runs yet
df2.count()                    # action: Spark runs the job now
```

---

## 5. What is an accumulator?

An **accumulator** is a **shared variable** that executors can only **add to**. The driver can read the final value.

Use it for **counters and sums**, for example: count bad records.

```python
bad_rows = spark.sparkContext.accumulator(0)

def check(line):
    if line.strip() == "":
        bad_rows.add(1)

rdd.foreach(check)       # action
print(bad_rows.value)    # read on the driver
```

**Important rules:**

- Executors **cannot read** the value. Only the driver can.
- Updates inside **transformations** (like `map`) may be counted **more than once** if a task is retried.
- Updates inside **actions** (like `foreach`) are counted **exactly once**.

---

## 6. What is a closure and why is it important?

A **closure** is the code **and the variables** that an executor needs to run a task. Spark **serializes** (packs) the closure on the driver and **sends a copy** to each executor.

```python
counter = 0

def increment(x):
    global counter
    counter += x          # changes the executor's COPY

rdd.foreach(increment)
print(counter)            # still 0 on the driver!
```

**Why it is important:**

- Each executor gets its **own copy** of the variables. Changes do **not** come back to the driver.
- The closure must be **serializable**. If it has something that cannot be serialized (a file handle, a database connection), the job fails with `Task not serializable`.
- A **big closure** is sent to every task, which slows the job.

---

## 7. How to avoid problems with closures

How to keep things **out of the closure** (or use them safely):

| Problem | Solution |
|---------|----------|
| You need a global counter/sum | Use an **accumulator** |
| You need a big read-only value (lookup table) | Use a **broadcast variable** (sent once per executor) |
| The function uses `self` or a whole class | Move the function outside the class, or copy the needed value to a local variable |
| Non-serializable objects (DB connection) | Create them **inside** the task with `mapPartitions` or `foreachPartition` |
| You try to change a driver variable | Return the data with transformations instead |

```python
# Broadcast variable example
lookup = spark.sparkContext.broadcast({"a": 1, "b": 2})
rdd.map(lambda x: lookup.value.get(x, 0))

# Create a connection inside the partition
def save_partition(rows):
    conn = create_connection()      # created on the executor
    for r in rows:
        conn.write(r)
    conn.close()

rdd.foreachPartition(save_partition)
```

---

## 8. Types of transformations

There are two types:

### Narrow transformations
- Each output partition depends on **one input partition**.
- **No shuffle.** Fast.
- Examples: `map`, `filter`, `flatMap`, `select`, `union`, `coalesce`.

### Wide transformations
- An output partition needs data from **many input partitions**.
- **Causes a shuffle.** Slower.
- Examples: `groupBy`, `reduceByKey`, `join`, `distinct`, `repartition`, `orderBy`.

```
Narrow:  [P1] -> [P1']        Wide:  [P1] \
         [P2] -> [P2']               [P2] -- shuffle --> [P1'] [P2']
                                     [P3] /
```

---

## 9. What is a shuffle?

A **shuffle** is the process of **moving data between partitions and machines** so that related data ends up together (for example, all rows with the same key).

- It happens in **wide transformations**: `groupBy`, `join`, `distinct`, `repartition`.
- It is **expensive** because it uses **network, disk, and serialization**.
- It creates a **new stage** in the job.

**How to reduce shuffle:**

- Filter data **before** a join or group.
- Use `reduceByKey` instead of `groupByKey` (it combines data before sending).
- Use **broadcast joins** for small tables.

---

## 10. What is the physical plan?

When you write a query, Spark creates plans in steps:

1. **Logical plan:** *what* you want to do.
2. **Optimized logical plan:** a better version, made by Catalyst.
3. **Physical plan:** *how* Spark will really run it (which join type, which scan, how many shuffles).

Use `explain()` to see it:

```python
df.groupBy("country").count().explain()
```

What to look for:

- `Exchange` = a **shuffle**.
- `BroadcastHashJoin` vs `SortMergeJoin` = the type of join.
- `FileScan` with `PushedFilters` = filters applied while reading files (good!).

You can also use `df.explain("formatted")` for a cleaner output, or the **Spark UI** (SQL tab).

---

## 11. persist and storage levels

`persist()` tells Spark to **save a dataset** after it is computed, so Spark does not recompute it each time.

Use it when you **reuse the same DataFrame many times** (for example, in loops or machine learning).

```python
from pyspark import StorageLevel

df.persist(StorageLevel.MEMORY_AND_DISK)
df.count()        # first action: computes and stores
df.count()        # second action: reads from storage (fast)
df.unpersist()    # free the space when done
```

- `cache()` is a short version of `persist()` with the default level.

| Storage level | Where | When to use |
|---------------|-------|-------------|
| `MEMORY_ONLY` | RAM only | Data fits in memory. Fastest. Missing partitions are recomputed. |
| `MEMORY_AND_DISK` | RAM, then disk | Data may not fit in memory. **Default for DataFrames.** |
| `DISK_ONLY` | Disk only | Very big data, or recompute is very expensive. |
| `MEMORY_ONLY_SER` | RAM, serialized | Save memory (Scala/Java). Uses more CPU. |
| `MEMORY_AND_DISK_SER` | RAM + disk, serialized | Like above, with disk as backup (Scala/Java). |
| `*_2` (e.g. `MEMORY_ONLY_2`) | Same, with **2 copies** | Faster recovery after a failure. |
| `OFF_HEAP` | Memory outside the JVM | Reduce garbage collection problems. |

> **Note:** In PySpark, data is always stored serialized, so the `_SER` levels are mainly for Scala/Java.

---

## 12. Commutative operations

An operation is **commutative** when the order of the inputs does **not** change the result: `a ⊕ b = b ⊕ a`.

An operation is **associative** when the grouping does **not** change the result: `(a ⊕ b) ⊕ c = a ⊕ (b ⊕ c)`.

**Why it matters:** Spark processes data in **parallel**, in **any order**. Functions used in `reduce`, `reduceByKey`, and accumulators should be **commutative AND associative**. Otherwise, the result can be different on each run.

| Commutative and associative (safe) | Not safe |
|-----------------------------------|----------|
| Sum (`+`) | Subtraction (`-`) |
| Multiplication (`*`) | Division (`/`) |
| `min`, `max` | Average (as a direct reduce) |
| Logical `AND`, `OR` | String concatenation (order matters) |
| Set union | Taking the "first" or "last" element |

```python
rdd.reduce(lambda a, b: a + b)   # OK
rdd.reduce(lambda a, b: a - b)   # WRONG: result changes with partition order
```

> **Tip:** To compute an average safely, reduce `(sum, count)` pairs, then divide at the end.

---

## 13. What is the SparkContext?

The **SparkContext** (`sc`) is the **entry point** to Spark's core functions. It is the connection between your program (the driver) and the cluster.

What it does:

- Connects to the **cluster manager**.
- Creates **RDDs** (`sc.textFile`, `sc.parallelize`).
- Creates **accumulators** and **broadcast variables**.
- Controls the **application settings** and resources.

In modern Spark, use **SparkSession**. It includes the SparkContext:

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("MyApp").getOrCreate()
sc = spark.sparkContext     # the SparkContext
```

> There is only **one active SparkContext per JVM**. Stop it with `spark.stop()` when you finish.

---

## 14. Common transformations: map, flatMap, reduce, filter, groupBy

| Operation | Type | What it does |
|-----------|------|--------------|
| `map` | Transformation | Applies a function to **each element**. Output has the **same number** of elements. |
| `flatMap` | Transformation | Applies a function that returns **a list**, then **flattens** all lists into one. Output can have **more or fewer** elements. |
| `filter` | Transformation | **Keeps** only the elements where the function returns `True`. |
| `reduce` | **Action** | **Combines** all elements into **one value** using a function. |
| `groupBy` | Transformation (wide) | **Groups** rows by a key. Usually followed by an aggregation like `count` or `sum`. |

```python
nums = sc.parallelize([1, 2, 3, 4])

nums.map(lambda x: x * 2).collect()          # [2, 4, 6, 8]
nums.filter(lambda x: x % 2 == 0).collect()  # [2, 4]
nums.reduce(lambda a, b: a + b)              # 10

lines = sc.parallelize(["hello world", "hello spark"])
lines.map(lambda l: l.split(" ")).collect()      # [['hello','world'], ['hello','spark']]
lines.flatMap(lambda l: l.split(" ")).collect()  # ['hello','world','hello','spark']
```

```python
# groupBy with DataFrames
df.groupBy("country").agg({"sales": "sum"}).show()
```

> `map` = 1 input -> 1 output. `flatMap` = 1 input -> 0, 1, or many outputs.

---

## 15. What is Catalyst?

**Catalyst** is Spark SQL's **query optimizer**. It makes your DataFrame/SQL code run faster **automatically**.

Steps:

1. **Analysis:** checks that tables, columns, and types exist.
2. **Logical optimization:** applies rules, such as:
   - **Predicate pushdown:** apply filters as early as possible.
   - **Column pruning:** read only the columns you need.
   - **Constant folding:** calculate fixed values in advance.
3. **Physical planning:** creates several plans and picks the cheapest one (cost-based).
4. **Code generation:** creates efficient Java bytecode (Tungsten engine).

> You write *what* you want. Catalyst decides *how* to do it best.

---

## 16. Three common reasons a Spark job is slow

### 1. Too much shuffle
Wide operations (`join`, `groupBy`, `distinct`) move a lot of data over the network.
**Fix:** filter early, use broadcast joins, use `reduceByKey`, select only the needed columns.

### 2. Data skew
Some keys have **much more data** than others, so one task works much longer than the rest.
**Fix:** use **salting** (add a random value to the key), enable **Adaptive Query Execution (AQE)** skew handling, or filter the very common keys.

### 3. Bad partitioning
- **Too few** partitions: not enough parallelism, big tasks, memory problems.
- **Too many** partitions (or many tiny files): too much task overhead.
**Fix:** aim for roughly **100-200 MB per partition**; use `repartition` or `coalesce`.

**Other common causes:** `collect()` on big data, no caching of reused data, slow Python UDFs, not enough memory (spill to disk), reading from a slow source.

---

## 17. What is coalesce?

`coalesce(n)` **reduces** the number of partitions to `n`.

- It **combines** existing partitions.
- It tries to **avoid a shuffle** (narrow transformation), so it is **fast**.
- It can **only decrease** the number of partitions.
- Partitions may end up with **different sizes** (uneven).

```python
df_small = df.coalesce(5)
```

| | `coalesce(n)` | `repartition(n)` |
|---|---------------|------------------|
| Increase partitions | No | Yes |
| Decrease partitions | Yes | Yes |
| Shuffle | No (usually) | Yes (full shuffle) |
| Partition sizes | Can be uneven | Balanced |
| Best for | Reducing before writing | Balancing data or increasing parallelism |

---

## 18. What are partitions for?

A **partition** is a **small piece** of a dataset. Spark splits data into partitions and processes them **in parallel**.

- **1 partition = 1 task** (for one stage).
- More partitions = more parallelism (up to the number of CPU cores).
- Partitions are the basic unit for **parallelism**, **shuffle**, **caching**, and **fault recovery**.

Rules of thumb:

- Use **2-4 partitions per CPU core** in the cluster.
- Keep partitions around **100-200 MB**.

```python
df.rdd.getNumPartitions()   # see how many partitions you have
```

---

## 19. How to change the number of partitions when writing

The number of **output files** equals the number of **partitions** when you write.

### Option 1: `coalesce(n)` - reduce files (no shuffle)
```python
df.coalesce(1).write.mode("overwrite").parquet("output/")
```

### Option 2: `repartition(n)` - increase files or balance data (shuffle)
```python
df.repartition(20).write.mode("overwrite").parquet("output/")
```

### Option 3: `repartition` by a column - group data by key
```python
df.repartition("country").write.partitionBy("country").parquet("output/")
```
`partitionBy` creates **folders** on disk (one per value), which helps with fast queries later.

### Option 4: Change shuffle partitions for the whole session
```python
spark.conf.set("spark.sql.shuffle.partitions", 50)   # default is 200
```
This changes the number of partitions after `join`, `groupBy`, etc.

### Option 5: Limit rows per file
```python
df.write.option("maxRecordsPerFile", 100000).parquet("output/")
```

> **Warning:** `coalesce(1)` puts all data in **one task**. Use it only for small data.

---

## 20. Example: Word Count

Count how many times each word appears in a text file.

### Version A: RDD (classic)

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("WordCount").getOrCreate()
sc = spark.sparkContext

# 1. Read the file (each element is one line)
lines = sc.textFile("input.txt")

# 2. Split lines into words, clean them, and count
counts = (
    lines
    .flatMap(lambda line: line.lower().split())   # lines -> words
    .map(lambda word: (word, 1))                  # word -> (word, 1)
    .reduceByKey(lambda a, b: a + b)              # sum counts by word
)

# 3. Show the result (action)
for word, count in counts.collect():
    print(word, count)

# 4. Optionally save the result
counts.saveAsTextFile("output_wordcount")

spark.stop()
```

**How it works:**

| Step | Result example |
|------|----------------|
| `textFile` | `"hello world"`, `"hello spark"` |
| `flatMap` | `hello`, `world`, `hello`, `spark` |
| `map` | `(hello,1)`, `(world,1)`, `(hello,1)`, `(spark,1)` |
| `reduceByKey` | `(hello,2)`, `(world,1)`, `(spark,1)` |

### Version B: DataFrame (recommended)

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import explode, split, lower, col

spark = SparkSession.builder.appName("WordCountDF").getOrCreate()

lines = spark.read.text("input.txt")          # column name: "value"

words = lines.select(
    explode(split(lower(col("value")), r"\W+")).alias("word")
).filter(col("word") != "")

word_counts = words.groupBy("word").count().orderBy(col("count").desc())

word_counts.show()
spark.stop()
```

### Count only ONE specific word

```python
target = "spark"

count = (
    sc.textFile("input.txt")
    .flatMap(lambda line: line.lower().split())
    .filter(lambda word: word == target)
    .count()                                   # action
)
print(f"'{target}' appears {count} times")
```

> `reduceByKey` is better than `groupByKey` because it **combines values before the shuffle**, so it moves less data.

---

## 21. Quick Review

| Concept | One-line summary |
|---------|------------------|
| **Spark** | Fast, distributed engine for big data |
| **DataFrame** | Distributed table with a schema; immutable and lazy |
| **Fault tolerance** | Lineage + recompute lost partitions + retries |
| **Action** | Triggers the job (`count`, `show`, `collect`, `write`) |
| **Accumulator** | Write-only shared counter for the driver |
| **Closure** | Code + variables copied to each executor |
| **Avoid closure problems** | Accumulators, broadcast variables, create objects in the task |
| **Narrow / Wide** | No shuffle / needs shuffle |
| **Shuffle** | Moving data between partitions; expensive |
| **Physical plan** | The real execution plan (`explain()`) |
| **persist** | Save a dataset to avoid recomputing it |
| **Commutative** | Order does not matter; needed for `reduce` |
| **SparkContext** | Entry point to the cluster (inside SparkSession) |
| **map / flatMap** | One-to-one / one-to-many |
| **filter / reduce / groupBy** | Keep rows / combine to one value / group by key |
| **Catalyst** | Automatic query optimizer |
| **Slow jobs** | Shuffle, skew, bad partitioning |
| **coalesce** | Reduce partitions without a full shuffle |
| **Partitions** | Pieces of data processed in parallel |
| **Write partitions** | `coalesce`, `repartition`, `partitionBy`, config |

---

*Good luck with your studies!*
