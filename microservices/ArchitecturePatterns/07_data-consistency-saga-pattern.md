# Data Consistency Patterns – Saga Pattern

## Overview
The **Saga pattern** solves the problem of maintaining data consistency across multiple microservices when each owns its own database — replacing the ACID transactions that a shared database would have provided.

---

## The Problem: Distributed Transactions Without a Shared Database

The **one database per microservice** principle is essential to avoid coupling between teams. However, it eliminates the ability to perform atomic transactions across multiple services.

| Monolith (single DB) | Microservices (separate DBs) |
|---|---|
| Group multiple operations into one transaction | No shared DB — no native cross-service transaction |
| Automatic rollback on failure | Must manually undo completed steps |
| One team manages changes | Schema changes are internal to each service |

**Goal:** Execute a sequence of operations across multiple services that either **all succeed** or are **all rolled back** — without a shared database.

---

## How the Saga Pattern Works

1. Break the transaction into a **sequence of local transactions**, one per service
2. Each **successful step triggers the next** step
3. If a step **fails**, the saga triggers **compensating operations** in reverse order to undo previous steps
4. After rollback: either **abort** the transaction or **retry** (context-dependent)

---

## Two Implementation Approaches

### 1. Execution Orchestrator
A central orchestrator service manages the entire flow — calling each service in order, deciding to proceed or roll back based on responses.

### 2. Choreography (Event-Driven)
No central coordinator. Services communicate via a message broker. Each service:
- On **success**: publishes an event to trigger the next service
- On **failure**: publishes a compensating event to trigger the previous service's rollback

---

## Real-World Example: Ticket Reservation System

**Services:** Order, Security, Billing, Reservation, Email, Orchestrator

### Happy Path (all steps succeed)

```
User requests ticket purchase
         ↓
Orchestrator → Order Service
  → Creates order with status: PENDING (blocks other buyers for same seat)
         ↓ (success)
Orchestrator → Security Service
  → Validates user is not a bot or blacklisted agent
         ↓ (success)
Orchestrator → Billing Service
  → Places a PENDING transaction on user's credit card
         ↓ (success)
Orchestrator → Reservation Service  ← PIVOT POINT
  → Confirms seat is available, reserves it with venue
         ↓ (success — no going back from here)
Orchestrator → Billing Service
  → Converts pending transaction to CHARGED
         ↓
Orchestrator → Order Service
  → Updates order status to: PURCHASED
         ↓
Orchestrator → Email Service
  → Sends confirmation email to user ✅
```

> The **pivot operation** (reservation confirmed) is the point of no return — after this step, the remaining steps complete the transaction rather than potentially rolling it back.

### Failure Scenarios & Compensating Operations

| Failure Point | Compensating Operations |
|---|---|
| Security check fails | Remove pending order from Order Service |
| Billing fails (no funds/invalid card) | Remove pending order from Order Service |
| Reservation fails (seat already taken) | Remove pending credit card transaction (Billing) + Remove order (Order Service) |

---

## Choreography Variant (No Orchestrator)

Same flow, but:
- Remove the orchestration service entirely
- Each service communicates via **events through a message broker**
- Each service is responsible for publishing **both success events** (to trigger the next) and **compensating events** (to trigger the previous service's rollback on failure)

---

## Summary

| Aspect | Key Point |
|---|---|
| **Problem solved** | Distributed transactions across services with separate databases |
| **Core mechanic** | Sequence of local transactions + compensating operations for rollback |
| **Orchestrator impl.** | Central service manages flow, decisions, and rollbacks |
| **Choreography impl.** | Services coordinate via message broker events |
| **Pivot operation** | The step after which rollback is no longer needed — transaction will complete |
| **Retry vs. abort** | Decision depends on the specific failure and business context |
