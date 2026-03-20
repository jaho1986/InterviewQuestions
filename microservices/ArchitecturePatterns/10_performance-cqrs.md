# Performance Patterns – CQRS (Command Query Responsibility Segregation)

## Overview
**CQRS** takes the Materialized View concept a major step further: instead of optimizing one or a few specific queries, it **completely separates the write side from the read side** into dedicated services and databases — allowing each to be independently optimized, scaled, and evolved.

---

## The Two Operation Types

| Type | Definition | Examples |
|---|---|---|
| **Command** | Mutates data (insert, update, delete) | Add user, update review, delete comment |
| **Query** | Reads data without changing it | List products by category, load product reviews |

---

## CQRS vs. Materialized View

| | Materialized View | CQRS |
|---|---|---|
| **Scope** | Optimizes one or a few specific queries | Separates the entire write and read workloads |
| **Structure** | Extra table in the same or a different DB | Two fully separate services and databases |
| **Optimization** | Speeds up targeted reads | Optimizes both writes AND reads fully |

---

## How CQRS Works

```
User writes →  [ Command Service ]  →  Command DB (optimized for writes)
                        ↓
                 Publishes event
                        ↓
                  [ Message Broker ]
                        ↓
User reads  →  [ Query Service ]   ←  Query DB  (optimized for reads)
                                       (updated from events)
```

### Key benefits of the split

| Benefit | Detail |
|---|---|
| **Best DB technology per workload** | Command DB optimized for writes; Query DB optimized for reads (e.g. NoSQL, in-memory) |
| **Clean codebases** | Command service handles validation and business logic; Query service handles only data retrieval |
| **Independent evolution** | Change command business logic → no need to retest or redeploy the query service |
| **Independent scaling** | Scale command and query instances/databases based on their respective traffic |

---

## Synchronization: Keeping Both Sides in Sync

Every command that mutates data must also update the query database. Two approaches:

### 1. Message Broker + Transactional Outbox
- Command service writes to its DB and publishes an event (via Transactional Outbox to guarantee atomicity)
- Query service subscribes to the topic and updates its DB on each event
- Broker retains the event until the query service confirms processing → no data loss

### 2. Function as a Service (FaaS)
- A cloud function watches the command database for changes
- When data is modified, it runs and updates the query database
- Cost: **zero when idle** — runs only when changes happen

---

## Important Drawbacks

| Drawback | Detail |
|---|---|
| **Eventual consistency only** | There is always a time gap between the command DB update and the query DB update |
| **Added complexity** | Two codebases, two databases, plus synchronization infrastructure to build and maintain |

> Only use CQRS when the performance benefits clearly outweigh the added complexity. If your workload doesn't justify it, one database and one service is always simpler.

---

## Real-World Example: Online Store Reviews

### Command Side (writes)

- **Database:** Relational DB — `reviews` table with columns: `user_id`, `product_id`, `order_id`, `review`, `rating`
- **Business logic:** Verify user purchased the product, prevent duplicate reviews per order, check for inappropriate language
- **Operations:** INSERT (new review), UPDATE (edit), DELETE (remove)

### Query Side (reads)

- **Database:** NoSQL — `reviews` collection with pre-joined fields per document: `user_public_name`, `rating`, `purchase_location`, `product_id`
- **Zero business logic** — only query and filter by `product_id`
- **Separate `ratings` collection:** stores average rating per product, updated:
  - **Immediately** if the product has few reviews
  - **On a schedule** (e.g. hourly via FaaS) if the product has many reviews

### Sync Flow
```
User submits review
         ↓
Command Service → inserts into reviews table → publishes event
         ↓
Query Service → updates reviews collection
  → if review count < threshold → recalculate + update ratings collection now
  → if review count ≥ threshold → defer to scheduled FaaS job
```

---

## Summary

| Aspect | Key Point |
|---|---|
| **Core idea** | Separate write and read workloads into distinct services and databases |
| **Command side** | Business logic, validations, write-optimized DB |
| **Query side** | Simple read logic, read-optimized DB (NoSQL, in-memory) |
| **Sync mechanism** | Message broker + Transactional Outbox, or FaaS watching the command DB |
| **Consistency** | Eventual only — not suitable for strict consistency requirements |
| **When to use** | High read + write traffic where each workload needs independent optimization |
| **When NOT to use** | Simple systems where one DB is sufficient — complexity is not worth it |
