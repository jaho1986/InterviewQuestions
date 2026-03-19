# Event-Driven Architecture (EDA) in Microservices

## Overview
When microservices communicate through synchronous request-response chains, latency and tight coupling become serious problems. **Event-Driven Architecture (EDA)** solves this by enabling asynchronous, decoupled communication between services.

---

## The Problem: Synchronous Communication at Scale

Consider a video-on-demand subscription flow involving three services: **Subscription**, **Payment**, and **Recommendations**. Getting all three to process a request consistently is hard with synchronous models.

### Approach 1 – Sequential Chain
Each service calls the next one in sequence and waits for a response before continuing.

- ✅ Guarantees consistency — all services confirmed before responding to the user
- ❌ User waits for the sum of all service latencies
- ❌ A slow third-party payment provider blocks the entire chain
- ❌ Any failure in the chain affects the entire transaction

### Approach 2 – Orchestration (Parallel Calls)
An orchestration service broadcasts the request to all services simultaneously.

- ✅ Reduces latency to the slowest single service (instead of the sum)
- ❌ Latency can still be too high if any one service is slow
- ❌ Orchestrator is tightly coupled to all participating services — every API change or new step requires updating it
- ❌ A temporary failure in any one service blocks all subscriptions

> **Root cause of both problems:** synchronous communication forces the user to wait and keeps services tightly coupled.

---

## The Solution: Event-Driven Architecture

### Core Concept: The Event
An **event** represents a fact, action, or state change in the system.

| Property | Event | Request |
|---|---|---|
| Mutability | Immutable — cannot be changed | Ephemeral — gone after processing |
| Storage | Can be stored indefinitely | Not stored |
| Consumers | Can be consumed by multiple services | Consumed once by one server |

### Three Participants

```
[ Producer ]  →  [ Message Broker ]  →  [ Consumer(s) ]
```

- **Producer** — emits events when something happens
- **Message Broker** — stores and routes events to the right consumers; adds redundancy (events are not lost)
- **Consumer(s)** — receive and process events independently; multiple consumers can process the same event

---

## Two Fundamental Differences vs. Request-Response

### 1. Synchronous vs. Asynchronous
| Request-Response | Event-Driven |
|---|---|
| Sender waits for a response | Producer fires and moves on |
| Blocked until receiver responds | No waiting, no blocking |
| Slow receiver = slow sender | Slow consumer doesn't affect producer |

### 2. Control & Coupling
| Request-Response | Event-Driven |
|---|---|
| Sender must know the receiver's API | Producer doesn't need to know its consumers |
| Sender depends on all receivers | Producer is fully decoupled from consumers |
| Adding a new receiver = changing the sender | Adding a new consumer = zero changes to the producer |

> This inversion of control is why EDA pairs so naturally with microservices — **loose coupling** is one of microservices' core principles.

---

## Applied Example: User Subscription Flow (EDA)

```
User subscribes
      ↓
Subscription Service
  → saves to its DB
  → emits event to Message Broker
  → ✅ immediately responds to user ("subscription received")
      ↓
Payment Service (async)
  → consumes event
  → processes payment
  → saves result to its DB
  → emits new event
      ↓
Recommendations Service (async)
  → consumes event
  → builds user profile
  → emits new event
      ↓
Notification Service (async)
  → consumes event
  → sends confirmation email / push notification to user
```

**Key outcome:** The user gets an instant response. All other processing happens in the background, independently, without blocking anyone. A slow Payment Service doesn't impact the user experience at all.

---

## Summary

| Problem (Sync) | Solution (EDA) |
|---|---|
| User waits for entire chain | User gets immediate response |
| Services tightly coupled | Services fully decoupled via message broker |
| Slow service blocks all others | Each service processes independently |
| Adding a service = updating orchestrator | Adding a consumer = zero producer changes |
| Third-party slowness hurts UX | Third-party slowness is invisible to the user |