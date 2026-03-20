# Scalability Patterns – Execution Orchestrator

## Overview
The **Execution Orchestrator** pattern manages complex, multi-step business flows across multiple microservices. A dedicated orchestrator service acts as the "conductor" — it knows the full sequence of operations, calls each service in order (or in parallel when possible), handles errors and retries, and maintains the state of the flow.

---

## The Problem It Solves

In a microservices architecture, business operations span multiple independent services. Each service only knows its own domain — it's unaware of others by design. Without a coordinator, there's no clear place to manage:
- The **sequence** of operations across services
- **Error handling and retries** when a service fails
- The **overall state** of a multi-step transaction

---

## Pattern Structure

```
User / Client Request
         ↓
[ Execution Orchestrator ]
    ↙       ↓      ↘
Service A  Service B  Service C
    (sequential or parallel as needed)
         ↓
Aggregated result / Response to user
```

> The orchestrator is like a **symphony conductor** — it doesn't produce any music itself, but it directs every musician to play their part at the right time.

**Key characteristics:**
- The orchestrator contains **no business logic** — only flow management
- Each microservice remains **unaware of other microservices**
- The orchestrator can be deployed as **multiple instances behind a load balancer** — no scalability compromise

---

## Relationship to Other Patterns

| Pattern | How requests are sent to workers |
|---|---|
| **Load Balancing** | One request → one worker |
| **Scatter-Gather** | One request → all workers in parallel → aggregated |
| **Execution Orchestrator** | A **sequence** of requests → different services, some parallel, some sequential |

---

## Real-World Example: New User Registration (Video-on-Demand)

```
User submits registration form
         ↓
Orchestrator → User Service (validate username + password)
         ↓ (if OK)
Orchestrator → Payment Service (authorize credit card)
         ↓ (if OK)
Orchestrator → responds to user: "Check your email shortly"
         ↓ (async continuation)
Orchestrator → Location Service (register user's country → unlock/block movies)
         ↓
Orchestrator → Recommendation Service (create profile based on location/language/history)
         ↓
Orchestrator → Email Service (send confirmation email with invoice + trending movies)
```

**Adding a new step** (e.g. public profile creation): only the orchestrator needs to change — no other service is touched.

---

## Failure Handling & Recovery

### Service Failures
| Failure | Orchestrator response |
|---|---|
| Username already taken | Returns error to user, aborts flow |
| Payment declined | Returns error to user, waits for correction, resumes from the payment step |
| Service not responding | Retries the request (load balancer routes to a healthy instance) |

### Orchestrator Instance Failure
If the orchestrator crashes mid-flow, a new instance must be able to resume:

**Solution: Persist flow state in a database**
- The orchestrator stores the current progress of each user's registration
- If a new instance takes over, it reads the state from the database and resumes from the correct step — no duplicate work

---

## Critical Warning: Avoid Business Logic in the Orchestrator

> If the orchestrator starts accumulating business logic, it becomes a monolithic application that happens to call microservices — defeating the entire purpose of the architecture.

**Rule:** The orchestrator's scope must stay strictly within **flow coordination** only. Business logic always belongs in the individual services.

---

## Summary

| Aspect | Key Point |
|---|---|
| **Role of orchestrator** | Manages sequence and state — no business logic |
| **Workers (services)** | Each owns its domain; unaware of others |
| **Scalability** | Orchestrator runs behind a load balancer — fully scalable |
| **Error handling** | Centralized in the orchestrator — retries, abort, resume |
| **State persistence** | Orchestrator stores flow state in DB for crash recovery |
| **Extensibility** | Add new steps by modifying only the orchestrator |
| **Key pitfall** | Business logic creeping into the orchestrator → new monolith |
