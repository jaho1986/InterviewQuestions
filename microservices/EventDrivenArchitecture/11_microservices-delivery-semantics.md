# Event-Driven Architecture – Message Delivery Semantics

## Overview
In distributed systems, message delivery is inherently unreliable. Services and message brokers can crash, and network acknowledgements can get lost. Understanding **delivery semantics** allows us to design systems that handle these failures predictably.

---

## The Core Problem

In any communication between two services (or between publisher → broker → consumer), there are always two unknowns when no acknowledgement arrives:

1. Did the receiver **never get** the message?
2. Did the receiver **get and process** the message, but the acknowledgement was lost?

From the sender's perspective, these two cases are **indistinguishable**. The three delivery semantics define how to handle this ambiguity.

---

## The Three Delivery Semantics

### 1. At Most Once
> **"Maybe delivered. Never duplicated."**

**How it works:**
- **Publisher:** Does not resend if no acknowledgement is received.
- **Subscriber:** Sends acknowledgement *before* processing the event.

**Outcome:**
- ✅ No duplicate events
- ❌ Events can be lost (if broker never received it, or subscriber crashes before processing)

**Best for:**
- Scenarios where some data loss is acceptable and duplication wastes resources
- Real-time, high-throughput systems (logs, metrics, location tracking)
- Example: driver location updates in a ride-sharing app — losing one GPS ping is fine; processing the same location twice is wasteful

**Trade-off:** Lowest latency and overhead.

---

### 2. At Least Once
> **"Always delivered. Maybe duplicated."**

**How it works:**
- **Publisher:** Resends the event if no acknowledgement is received within a timeout.
- **Subscriber:** Sends acknowledgement *after* processing the event.

**Outcome:**
- ✅ Events are never lost
- ❌ Same event can be delivered and processed more than once

**Best for:**
- Scenarios where losing data is unacceptable but occasional duplication is tolerable
- Example: shipping notification to a user — duplicating a push notification is a minor annoyance, but never notifying the user is unacceptable
- Example: user review submission — a duplicate is simply overridden or ignored by existing business logic

**Trade-off:** Higher latency than at-most-once due to retry wait times. Not suitable for real-time or high-throughput systems.

---

### 3. Exactly Once
> **"Always delivered. Never duplicated."**

**How it works — Publisher side:**
- Publisher obtains a unique **idempotency ID** before sending (from the broker or a separate service).
- If no acknowledgement arrives, the event is resent *with the same ID*.
- The broker checks if an event with that ID already exists in the log — if yes, it is ignored; if no, it is stored.

**How it works — Subscriber side:**
- After processing and storing the event, the subscriber sends an acknowledgement.
- If the subscriber crashes *after processing but before acknowledging*, the broker will redeliver the event.
- To prevent double-processing, the subscriber must **manually store the idempotency ID** in the database and reject any event whose ID is already present.

> ⚠️ **Important:** When a subscriber updates external state (a database), the message broker alone **cannot guarantee exactly-once delivery** — even if it advertises this feature. The idempotency check on the subscriber side must be implemented manually.

**Best for:**
- Financial transactions (billing, money transfers) where duplicates and losses are both unacceptable

**Trade-off:** Highest latency and overhead. Not all message broker technologies support it, and those that do may have limitations — always read the documentation carefully.

---

## Comparison Table

| Delivery Semantic | Data Loss | Duplication | Latency | Best Use Case |
|---|---|---|---|---|
| **At most once** | ✅ Possible | ❌ Never | Lowest | Metrics, logs, real-time location data |
| **At least once** | ❌ Never | ✅ Possible | Medium | Notifications, reviews, non-financial events |
| **Exactly once** | ❌ Never | ❌ Never | Highest | Financial transactions, billing, money transfers |

---

## Key Takeaway

> These concepts are **universal** — not tied to any specific message broker technology. However, configurations and guarantees vary between technologies. Always verify what your chosen broker actually provides, especially for financially critical data.

The idempotency ID pattern on the subscriber side is something **you must implement yourself** — it cannot be delegated to the message broker.
