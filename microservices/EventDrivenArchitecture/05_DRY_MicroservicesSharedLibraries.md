# Microservices Best Practices – The DRY Principle

## Overview
The DRY (Don't Repeat Yourself) principle is a cornerstone of software engineering, but it **does not always apply the same way in microservices** — especially when it comes to shared libraries and data.

---

## Quick Reminder: What is DRY?
Consolidate repeated logic into a single place — a shared method, class, variable, or library. This way, changes happen in one place and effort is reused across the team.

---

## Why Shared Libraries Are Problematic in Microservices

### 1. Tight Coupling
- Any change to a shared library forces all dependent teams to update, rebuild, retest, and redeploy their services simultaneously.
- A bug or vulnerability in the library can impact **all services that use it** — defeating the purpose of isolated microservices.

### 2. Dependency Hell
When a microservice depends on Library A, which depends on Library B — and the microservice also uses Library B directly — updating Library A can force an unnecessary update to Library B in the microservice's own code. Depending on the runtime, you either:
- Cannot load two versions of the same library → forced code change, or
- Load both versions → binary bloat, longer build/test times, and ironically **still breaks DRY**.

---

## Alternatives to Shared Libraries

### When business logic is duplicated across services
This often signals **incorrect service boundaries**. Possible fixes:
- **Adjust boundaries** so only one service owns that logic.
- **Extract a new microservice** if the logic is complex enough to stand on its own.

### When sharing communication/data models between two services
This is actually **a good case for shared libraries or files**. You *want* both teams to be co-dependent here — if the API changes and breaks communication, you want tests to catch it immediately. Alternatives:
- **Code generation tools** based on a shared schema or interface definition (e.g. Protobuf, OpenAPI). The generated code is produced during the build/test process, keeping both services in sync safely.

### When sharing utility methods that change frequently
**Duplicate the code** across services. Benefits:
- Each service can tailor the implementation to its own needs.
- Easier to migrate a service to a different programming language later.

### When you absolutely cannot duplicate: the Sidecar Pattern
Package the shared functionality as a **separate process running on the same host** as the microservice. The service communicates with it via standard network protocols. Performance overhead is lower than a remote service call, but higher than an in-process library.

### Last resort: Shared libraries for stable, generic code
Acceptable only for code that is **very stable and rarely changes** (e.g., logging, retry logic, pattern matching). These libraries must be self-contained and have no inter-dependencies on other shared libraries.

---

## Decision Guide

| Scenario | Recommended Approach |
|---|---|
| Complex business logic shared across services | Adjust boundaries or extract a new microservice |
| Communication data models / API contracts | Shared library or code generation from shared schema |
| Utility methods that change often | Duplicate across services |
| Generic, very stable logic (logging, retries) | Shared library (last resort) |
| Absolutely no duplication tolerated | Sidecar pattern |

> ⚠️ DRY still applies **within** each individual microservice. Code duplication inside a single service is never acceptable.

---

## Data Duplication Across Microservices

Duplicating data (storing a copy in another service's database) is **sometimes necessary for performance**, and it is acceptable under two conditions:

1. **One clear owner** — only one microservice can write, update, or delete that data. All others hold read-only copies.
2. **Eventual consistency is acceptable** — copied data may be slightly stale; strict consistency is not guaranteed.

### When to duplicate data (eventual consistency is fine)
- Storing a product's average rating in the Product Service to avoid calling the Review Service on every page load.
- Caching a few recent reviews alongside product data.

### When NOT to duplicate data (strict consistency required)
- Real-time inventory levels (e.g. stock count for a product).
- User account balances.

---

## Summary

| Topic | Key Rule |
|---|---|
| Shared libraries | Avoid — they create tight coupling and dependency hell |
| Business logic duplication | Fix boundaries or extract a new service |
| API/data model sharing | Use shared files or code generation |
| Utility code | Duplicate it — each service owns its version |
| Data duplication | OK for performance, but one owner + eventual consistency only |
| DRY inside a microservice | Always apply it — no exceptions |