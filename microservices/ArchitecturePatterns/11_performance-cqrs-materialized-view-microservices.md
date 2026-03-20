# Performance Patterns – CQRS + Materialized View in Microservices

## Overview
This lecture covers the **second use case of CQRS**: combining it with the Materialized View pattern to solve a critical problem in microservices — efficiently querying and joining data that is spread across multiple services with separate databases.

---

## The Problem: Cross-Service JOINs in Microservices

| Monolith (single DB) | Microservices (separate DBs) |
|---|---|
| JOIN across tables in one DB — slow but manageable | Can't JOIN directly — data is in different databases |
| Built materialized views to speed up slow JOINs | Must make API calls to each service + programmatic join |

**The overhead of cross-service aggregation without this pattern:**
```
Client needs combined data
         ↓
API call → Service A → DB query → returns partial data
API call → Service B → DB query → returns partial data
         ↓
Caller aggregates both results programmatically
         ↓
(3 network hops + 2 DB queries + custom code = very slow)
```

This is unacceptable for user-facing queries.

---

## The Solution: CQRS + Materialized View Combined

Create a **dedicated query microservice** with its own **read-optimized database** that holds a **pre-joined materialized view** of data from multiple source services.

```
[ Service A ]  →  publishes events on data change
[ Service B ]  →  publishes events on data change
                      ↓
               [ Message Broker ]
               or [ Cloud FaaS ]
                      ↓
         [ Query Microservice ]
         (read-only, no business logic)
                      ↓
         Read-Optimized DB
         (pre-joined materialized view)
                      ↓
         Fast, single-query response to client
```

### Sync Options
| Mechanism | How it works |
|---|---|
| **Message Broker** | Service A/B publish events on change → Query service subscribes and updates materialized view |
| **Cloud FaaS** | Function watches source databases → runs on change → updates materialized view |

> Both approaches guarantee **eventual consistency** — the materialized view may be slightly stale, but never permanently out of sync.

---

## Real-World Example: Online Education Platform (Microservices)

**Services:**
- **Course Service** — stores course name, description, price (relational DB)
- **Review Service** — stores reviews, ratings, student info (separate DB)
- **Course Search Service** ← new CQRS query service

**What the search page needs** (requires data from both services):
- From Course Service: course name, price, subtitle
- From Review Service: average rating, number of reviews

**Without this pattern:** Two API calls + programmatic join on every search request.

**With CQRS + Materialized View:**

```
User searches for courses
         ↓
API Gateway → Course Search Service
         ↓
Single query on pre-joined materialized view
         ↓
Instant result containing all fields from both services ✅
```

### Keeping the Materialized View in Sync
```
Course price/title changes → Course Service publishes event
                           → Course Search Service updates its view

New review arrives        → Review Service publishes event
                           → Course Search Service:
                             - Updates immediately (if few reviews)
                             - Defers to periodic update (if many reviews)
```

---

## Summary: What This Pattern Combination Solves

| Problem | Solution |
|---|---|
| Cross-service JOINs are slow and expensive | Pre-join data in a materialized view at the query service |
| Each API call adds network latency | All data available in one query to one service |
| Query logic pollutes service codebases | Query service has zero business logic — only reads |
| Source data changes need to propagate | Event-driven sync via message broker or FaaS |
| Consistency | Eventual — acceptable for most read workloads |

---

## The Three-Pattern Stack

```
Materialized View  →  Pre-compute and store query results
        +
     CQRS          →  Separate read/write into dedicated services and DBs
        +
Event-Driven Arch  →  Keep materialized view in sync with source services
        ↓
Efficient cross-service data queries in microservices architecture
```
