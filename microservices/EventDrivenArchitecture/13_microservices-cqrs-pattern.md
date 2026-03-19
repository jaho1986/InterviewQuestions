# Microservices Pattern – CQRS (Command Query Responsibility Segregation)

## Overview
CQRS is a pattern that separates the **write (command)** side of a system from the **read (query)** side into distinct services and databases. Combined with Event-Driven Architecture, it solves two major microservices challenges: conflicting workload requirements and cross-service data joins.

---

## Core Concepts

### Two Types of Operations

| Type | Definition | Examples |
|---|---|---|
| **Command** | Changes data (insert, update, delete) | Add a user, edit a review, delete a comment |
| **Query** | Reads data without changing it | List products by category, search for a restaurant |

### The CQRS Split

```
                    [ Message Broker ]
                          ↑ events
User → Command Service → Command DB
                          ↓ events
              Query Service → Query DB (read-optimized copy)
```

- All **writes** go through the **Command Service → Command DB**
- All **reads** go through the **Query Service → Query DB**
- The message broker keeps both databases **eventually consistent**

---

## Use Case 1 – Separation of Concerns & Performance

### Why it helps

**Command side:**
- Owns all business logic: write permissions, input validation, complex rules
- Can use a database technology optimized for **write-heavy** workloads
- Can evolve independently — no need to retest or redeploy the query side when only command logic changes

**Query side:**
- Clean and simple — focused only on presenting data to the user
- Can use a database technology optimized for **read-heavy** workloads (e.g. search engines, denormalized tables)
- Can evolve independently from the command side

**Scalability:** Each service and database can be scaled independently based on its own traffic pattern.

> Without CQRS, using a single database forces you to compromise — you can't optimize for both reads and writes simultaneously.

---

## Use Case 2 – Solving the Cross-Service JOIN Problem

When microservices each own their own database, joining data from two different services is painful:

```
Without CQRS:
Call Service A API → get data → Call Service B API → get data
→ Parse & normalize both → Programmatic join → Return to user
```
This is slow, error-prone, and unacceptable for user-facing queries.

**With CQRS:**
- Create a dedicated **Query Microservice** with a read-optimized database.
- Store a **pre-joined view** of the data from both services.
- Keep it updated via events: whenever Service A or B changes data, they publish an event → Query Service updates its view.

```
Service A changes data → publishes event → Query Service updates pre-joined view
Service B changes data → publishes event → Query Service updates pre-joined view

User search request → Query Service → instant, optimized response
```

---

## Important Caveat: Eventual Consistency

Because the query database is updated asynchronously, there is always a **time gap** between a write in the command database and the updated view in the query database. During this gap, reads will return **stale data**.

> CQRS can only guarantee **eventual consistency** between write and read operations.

---

## Real-Life Example: Business Review Platform (e.g. Yelp)

**Services:** Business Service (business info) + Review Service (user reviews) + Business Search Service (CQRS query service)

### Command Side
| Service | Business Rules | DB Optimization |
|---|---|---|
| Business Service | Only verified owners can update info | Write-optimized (infrequent changes) |
| Review Service | Auth check, duplicate review check, input validation | Write-optimized (many daily writes) |

### Query Side (CQRS)
**Business Search Service:**
- Uses a **text search engine** database optimized for keyword queries
- Contains a **pre-joined view** of business info + ratings
- Has **zero business logic** — only parses requests and returns results

**Flow:**
```
New business added/updated → Business Service publishes event
                           → Business Search Service indexes it

New review approved       → Review Service publishes event
                           → Business Search Service joins it with business,
                             recalculates average rating

User searches "sushi near me"
                           → Business Search Service
                           → returns sorted, pre-computed results instantly
```

---

## Summary of Benefits

| Benefit | How CQRS Provides It |
|---|---|
| **Separation of concerns** | Command = business logic; Query = data presentation |
| **Write performance** | Command DB optimized for writes |
| **Read performance** | Query DB optimized for reads |
| **Independent scalability** | Each service/DB scaled separately |
| **Independent deployment** | Command changes don't require redeploying query side |
| **Cross-service joins** | Pre-joined views in the query DB eliminate slow programmatic joins |
