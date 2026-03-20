# Scalability Patterns – MapReduce

## Overview
**MapReduce** is a programming model and software architecture pattern for processing massive data sets across hundreds or thousands of machines — in parallel, with automatic failure handling. Instead of building a custom distributed processing pipeline for each task, you follow one simple model and let the framework handle everything else.

> Originally published by Jeff Dean and Sanjay Ghemawat at Google in 2004.

---

## The Problem It Solves

Processing very large data sets requires distributing both the **data** and the **computation** across many machines. Without a framework, every new task requires solving the same hard problems from scratch:
- Parallelizing and distributing data
- Scheduling execution across workers
- Aggregating results
- Handling and recovering from failures

MapReduce solves all of this with a single reusable framework — developers only write the business logic.

---

## The Programming Model

Every computation is expressed as two functions: **Map** and **Reduce**.

### Step 1 – Input: Key-Value Pairs
Describe your input data as a set of `(key, value)` pairs.

### Step 2 – Map Function
Applied to every input key-value pair. Produces **intermediate key-value pairs**.

### Step 3 – Shuffle (done by the framework)
The framework groups all intermediate pairs **by key** and passes them to the reduce function.

### Step 4 – Reduce Function
Applied to each unique intermediate key and all its associated values. Produces a **final result** (zero or one value per key).

---

## Classic Example: Word Count

**Goal:** Count the number of occurrences of each word across a large set of text files.

**Input:** `(filename, file_content)` pairs

**Map function:**
```
for each word in file_content:
    emit(word, 1)
```

**Intermediate output (after shuffling by key):**
```
("car", [1, 1, 1])
("do",  [1, 1])
("the", [1, 1, 1, 1])
...
```

**Reduce function:**
```
for each (word, [1, 1, 1, ...]):
    emit(word, sum(values))
```

**Final output:**
```
("car", 3)
("do",  2)
("the", 4)
```

> If a computation can't be expressed in one Map+Reduce pass, break it into multiple chained MapReduce executions.

---

## Architecture

```
                  [ Master ]
                 /    |    \
            Map      Map      Map
           Worker   Worker   Worker
             ↓        ↓        ↓
          Partition intermediate results by key
             ↓        ↓        ↓
           Reduce   Reduce   Reduce
           Worker   Worker   Worker
                      ↓
               Final output (globally accessible)
```

### Master
- Schedules and orchestrates the entire computation
- Breaks input into **chunks** assigned to map workers
- Assigns reduce workers to partition regions
- Monitors worker health via periodic pings

### Map Workers
- Run the **map function** on their assigned chunk in parallel
- Store intermediate results partitioned into R regions (using a hash function)

### Reduce Workers
- Pull intermediate results from map workers (shuffling)
- Sort by key, then run the **reduce function**
- Start as soon as at least one map worker finishes — no need to wait for all

---

## Failure Handling

### Worker Failure
- Master pings workers periodically
- If a worker stops responding → marked as failed → task rescheduled to another worker
- If a **map worker** fails → reduce workers are notified of the new intermediate data location

### Master Failure
Three strategies (in order of recovery speed):

| Strategy | Trade-off |
|---|---|
| Abort and restart with a new master | Loss of all progress so far |
| Master takes frequent snapshots → new master replays the log | Some time lost, but not all |
| Backup master stays in sync at all times | Zero downtime, instant failover |

---

## Why Cloud Is a Perfect Fit

| Reason | Detail |
|---|---|
| **Elastic compute** | Instantly access hundreds or thousands of machines when needed |
| **Batch processing model** | Run on-demand or on a schedule — pay only for what you use during processing |
| **Cost efficiency** | Storage (for data) is much cheaper than constant compute — no idle worker costs |

---

## Common Use Cases

- Machine learning over large datasets
- Log file filtering and analysis
- Inverted index construction (search engines)
- Web link graph traversal
- Distributed sort or search over large datasets

---

## In Practice

You almost never implement MapReduce from scratch. Instead:
- Use an **open source implementation** (e.g. Apache Hadoop, Spark)
- Or use a **cloud-managed service** (e.g. AWS EMR, Google Dataflow)

Your job: model the data as key-value pairs, write the map and reduce functions, and tune the parameters for best throughput.

---

## Summary

| Concept | Key Point |
|---|---|
| **Programming model** | Every computation = Map function + Reduce function |
| **Map** | Transforms input KV pairs into intermediate KV pairs |
| **Shuffle** | Framework groups intermediate pairs by key |
| **Reduce** | Merges all values per key into a final result |
| **Master** | Schedules and monitors the entire computation |
| **Workers** | Run map/reduce in parallel — can be hundreds or thousands |
| **Failure recovery** | Reschedule failed tasks; snapshot or backup for master failure |
| **Cloud fit** | Elastic scale + batch pricing = ideal for big data on demand |
