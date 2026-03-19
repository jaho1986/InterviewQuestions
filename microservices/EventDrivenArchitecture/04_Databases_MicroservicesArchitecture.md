# Microservices Best Practices – Database per Microservice

## Overview
Each microservice should **fully own its data** and never share its database directly with other services. This is one of the most important principles in microservices architecture.

---

## The Problem: Shared Database Anti-Pattern

Imagine an insurance company that migrated its monolith into microservices (Policy, Claims, Customer, Reporting) but kept a **single shared database**.

This creates tight coupling between teams:

| Service change | Impact on Reporting Service |
|---|---|
| Policy Service switches to a NoSQL database | Reporting team must update their code and release simultaneously |
| Claims Service renames/removes columns | Both teams must agree on a new schema and coordinate the release |
| Customer Service adds fine-grained security policies | Reporting team must understand and implement those policies in their own codebase |

> Despite the migration to microservices, teams still require constant coordination — the original problem was never solved.

---

## The Principle: Database per Microservice

Each microservice:
- **Owns its data exclusively** — no other service touches its database directly.
- **Exposes data only through its API** — even at the cost of some latency.
- **Abstracts its database technology** at the API level — consumers never depend on the underlying storage technology or schema.

### Key benefit: Independent evolution
If a service changes its database technology or schema, that change is **completely transparent** to other services. If an API change is required, the team can offer **two API versions in parallel**, giving other teams time to adapt — with no coordination needed.

---

## Benefits

- Teams can truly operate independently.
- Database technology choices are internal decisions (switch from SQL to NoSQL freely).
- Schema changes don't cascade to other teams.
- No need for simultaneous cross-team releases.

---

## Downsides & Trade-offs

### 1. Added latency
Direct DB queries are replaced by network calls → request parsing → DB query → response parsing. This overhead is real.

**Mitigation:** Cache or store a local copy of frequently needed data from other services.
> ⚠️ The source of truth always remains the owning service. Local copies introduce **eventual consistency** (data may be slightly stale).

### 2. Loss of JOIN operations
When data lived in one database, cross-table JOINs were easy. With separate databases (possibly different technologies), JOINs are no longer possible directly.

**Workaround:** Pull data from both services, normalize the format, and perform the join **programmatically** in application code.

### 3. Loss of transaction guarantees
A single database allows atomic transactions across multiple tables. Distributed transactions across services are extremely complex and almost never used in practice.

> Solutions to this challenge (patterns for distributed data consistency) will be covered later in the course.

---

## Summary

| Aspect | Shared DB | DB per Microservice |
|---|---|---|
| Team independence | ❌ Tight coupling | ✅ Fully independent |
| Schema changes | Requires coordination | Transparent to consumers |
| Performance | ✅ Fast direct queries | ⚠️ Added network latency |
| JOIN operations | ✅ Native SQL JOINs | ⚠️ Programmatic joins |
| Transactions | ✅ Native ACID | ⚠️ No easy distributed transactions |