# Performance Patterns – Materialized View

## Overview
The **Materialized View** pattern pre-computes and stores the result of a complex query in a separate read-only table. This trades a small amount of storage space for significantly faster and cheaper reads — especially for queries that are complex, repeated frequently, or both.

> Core trade-off: **space for performance** — a classic computer science trade-off.

---

## The Problem

The way data is stored (optimized for writes and normalization) is often **not** the way it needs to be queried (optimized for reads and aggregation).

| Issue | Detail |
|---|---|
| **Performance** | Complex queries across multiple tables or databases take a long time — unacceptable for user-facing features |
| **Cost** | Running the same expensive query thousands of times per day wastes CPU, memory, and network resources — directly translating to cloud bills |

---

## How It Works

1. Identify a **complex, frequently-run query** worth optimizing
2. Run the query once and **store its result in a dedicated read-only table** (the materialized view)
3. Serve future requests from the materialized view instead of re-running the full query
4. **Refresh** the materialized view when the underlying data changes — either immediately or on a schedule

```
Base Tables (raw data)
       ↓
   Complex Query
   (join + aggregate + sort)
       ↓
Materialized View Table  ←── Periodically refreshed
       ↓
Fast, cheap reads
```

---

## Real-World Example: Online Education Platform

**Schema:**
- `courses` table: course_id, title, subtitle, topic
- `reviews` table: review_id, course_id, student_id, rating, text

**Expensive query (run thousands of times/day):**
```sql
SELECT c.course_id, c.title, c.topic, AVG(r.rating) as avg_rating
FROM courses c
JOIN reviews r ON c.course_id = r.course_id
GROUP BY c.course_id
ORDER BY avg_rating DESC
```

**With Materialized View — two options:**

### Option A: One general view (filtered at query time)
Store all courses pre-ranked by average rating. When a student queries for "programming" courses, filter the materialized view — much faster than joining + aggregating every time.

### Option B: One view per topic (most optimized)
Create a separate materialized view per topic (`mv_programming`, `mv_art`, etc.), each pre-sorted by rating. Each query is a single scan of a small, pre-sorted table — the fastest possible read.

---

## Key Considerations

### 1. Storage Cost
Materialized views consume extra storage. In a cloud environment, this cost must be weighed against the performance and cost savings from fewer expensive queries. **Only apply this pattern where the benefit clearly outweighs the storage cost.**

### 2. Where to Store the Materialized View

| Location | Pros | Cons |
|---|---|---|
| **Same database (same DB as base tables)** | DB may support native materialized views with automatic, delta-based updates | Base DB may not be optimized for reads |
| **Separate read-optimized DB (e.g. in-memory cache)** | Very fast reads; no backup needed (can always rebuild from raw data) | Must manage updates programmatically; more complexity |

### 3. Update Frequency
- If the base data changes **frequently** but the view doesn't need to be real-time → **schedule updates** at fixed intervals
- If the base data changes **rarely** → **immediate updates** on every change are fine
- Most databases with native support apply only **deltas** (not full regeneration) for efficiency

---

## Summary

| Aspect | Key Point |
|---|---|
| **Problem solved** | Complex, repeated queries are slow and expensive |
| **Core mechanic** | Pre-compute query results into a read-only table |
| **Refresh strategy** | Immediately on data change, or on a fixed schedule |
| **Storage trade-off** | Extra space in exchange for faster, cheaper reads |
| **Best location** | Same DB if it supports native materialized views; separate read-optimized DB for maximum read performance |
| **Best use cases** | Complex joins, aggregations, sorts that run frequently on large, rarely-changing datasets |
