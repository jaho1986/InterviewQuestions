# Microservices Pattern – The Saga Pattern

## Overview
When migrating to microservices, we lose the ability to perform **ACID transactions** across multiple services. The **Saga pattern** solves this by breaking a distributed transaction into a sequence of local transactions, with compensating operations to undo changes if anything fails.

---

## The Problem: No Cross-Service Transactions

In a monolith with a single database, ACID transactions guarantee that a sequence of operations across multiple tables is **atomic** — either all succeed or all are rolled back.

With microservices, each service owns its own database. There is no single transaction that can span multiple services. A multi-step workflow (pay → book flight → book hotel → rent car) may partially succeed, leaving the system in an **inconsistent state**.

---

## The Saga Pattern

**Core idea:** Break the transaction into a sequence of **local transactions**, one per service.

- Each successful step **triggers the next** step in the sequence.
- If a step **fails**, the saga triggers **compensating operations** in reverse order to undo all previous steps.

### Compensating Operations
Every operation in the saga must have a defined compensating operation (its "undo"):

| Operation | Compensating Operation |
|---|---|
| Charge user's credit card | Refund the full amount |
| Book flights | Cancel both flights |
| Reserve hotel room | Cancel hotel booking |
| Reserve rental car | Cancel car reservation |
| Create order entry | Update order status to "cancelled" |

---

## Two Implementation Approaches

### Approach 1 – Orchestration (Workflow Management Service)

A **dedicated orchestration service** controls the entire transaction step by step.

```
User Request
     ↓
API Gateway
     ↓
Workflow Orchestration Service
     ├─→ Payment Service       (charge user)
     ├─→ Flight Service        (book flights)
     ├─→ Hotel Service         (reserve room)
     ├─→ Car Rental Service    (reserve car)
     └─→ Order Service         (record booking)
```

**On failure (e.g. car rental unavailable):**
```
Orchestration Service detects failure
     ↓
→ Hotel Service:    cancel reservation (compensating)
→ Flight Service:   cancel flights     (compensating)
→ Payment Service:  refund user        (compensating)
→ Return error to user
```

**Pros:** Centralized control, easy to reason about the full flow.
**Cons:** The orchestration service is tightly coupled to all participating services — any new step or API change requires updating it.

---

### Approach 2 – Choreography (Event-Driven Saga)

No central orchestrator. Each microservice **knows its own role** in the workflow and communicates through events via a message broker.

**Each service must know:**
- Which topic to publish to on **success** (to trigger the next service)
- Which topic to publish to on **failure** (to trigger the previous service's compensating operation)

```
User Request → Payment Service
                  ↓ (event: payment_completed)
              Flight Service
                  ↓ (event: flights_booked)
              Hotel Service
                  ↓ (event: hotel_booked)
              Car Rental Service
                  ↓ (event: all_completed)
              Order Service → updates DB
                  ↓ (event: booking_confirmed)
              Notification Service → notifies user ✅
```

**On failure (e.g. car rental fails):**
```
Car Rental Service → publishes (event: car_reservation_failed)
                  ↓
Hotel Service subscribes → cancels hotel → publishes (event: hotel_cancelled)
                  ↓
Flight Service subscribes → cancels flights → publishes (event: flights_cancelled)
                  ↓
Payment Service subscribes → refunds user → publishes (event: transaction_failed)
                  ↓
Notification Service → notifies user of failure ❌
```

> Since the entire flow is asynchronous, the success or failure response to the user is also asynchronous — delivered via email or push notification.

**Pros:** Fully decoupled — adding a new service requires no changes to existing services.
**Cons:** Harder to reason about the full flow; each service must manage its own failure routing logic.

---

## Side-by-Side Comparison

| Aspect | Orchestration | Choreography (EDA) |
|---|---|---|
| Control | Centralized (orchestrator) | Distributed (each service) |
| Coupling | Orchestrator coupled to all services | Services fully decoupled |
| Visibility | Easy to trace the full workflow | Harder to follow the full flow |
| Adding new steps | Update the orchestrator | Add a new subscriber |
| Response to user | Synchronous | Asynchronous (notification) |

---

## Key Takeaway

The Saga pattern does **not** provide ACID guarantees — it provides **eventual consistency**. It trades the simplicity of a single transaction for the independence and scalability of microservices. Choosing between orchestration and choreography depends on how much coupling you are willing to accept vs. how much complexity you can manage in each individual service.
