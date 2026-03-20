# Extensibility Patterns – Anti-Corruption Adapter (ACL)

## Overview
The **Anti-Corruption Adapter** (also called Anti-Corruption Layer) is a dedicated service that acts as a **translator between two systems with different APIs, data models, and technologies** — preventing the modern system from being "corrupted" by the legacy system's outdated conventions.

---

## Two Scenarios Where This Pattern Applies

### Scenario 1 – Migration in Progress

During a migration from a monolith to microservices, new services are built one at a time alongside the old system. The problem: **new services must still talk to the old monolith** — and if they integrate directly, they carry the old system's outdated APIs, protocols, and data models throughout their codebase.

**Solution:**

```
[ New Microservices ]
        ↓ (modern APIs & data models only)
[ Anti-Corruption Adapter Service ]
        ↓ (translates to legacy APIs & data models)
[ Old Monolithic Application ]
```

- New services only know about new models and APIs
- The adapter handles all translation in both directions
- Once the migration is complete → the adapter is decommissioned

### Scenario 2 – Permanent Legacy System

Sometimes a legacy system can't or won't be fully migrated (e.g. a proprietary banking infrastructure that is expensive to rebuild but still relied upon). The new system needs to use it, but shouldn't be polluted by its old conventions.

**Solution:** Keep the Anti-Corruption Adapter permanently as a stable boundary between the two systems. The legacy system stays untouched; the new system stays clean.

---

## How It Works

```
New System         ←→    Anti-Corruption Adapter    ←→    Old System
(modern APIs)             (translates both ways)           (legacy APIs)
```

- **New → Old:** New services send modern requests → adapter translates → legacy system receives requests in its own format
- **Old → New:** Legacy system sends requests → adapter translates → new microservices receive modern API calls

---

## Challenges and Trade-offs

| Challenge | Detail |
|---|---|
| **Development cost** | The adapter must be built, tested, and deployed like any other service |
| **Scalability** | Must be scaled to avoid becoming a performance bottleneck |
| **Added latency** | Translation between data models always introduces some overhead |
| **Ongoing cost** | In a cloud environment, running the adapter permanently costs money |

### Cost Mitigation
If the adapter is used infrequently → deploy it as **Function as a Service (FaaS)** — pay only when it runs. If it handles high traffic → accept the ongoing cost as the price of maintaining the clean boundary.

---

## Summary

| Aspect | Key Point |
|---|---|
| **Purpose** | Prevent legacy system's outdated conventions from polluting the new system |
| **Structure** | Dedicated translation service between old and new systems |
| **Scenario 1** | Temporary — used during migration; decommissioned when migration completes |
| **Scenario 2** | Permanent — legacy system stays in place alongside the new system indefinitely |
| **Overhead** | Dev effort, scalability, latency, and cloud cost |
| **Cost optimization** | Use FaaS if the adapter is called infrequently |
