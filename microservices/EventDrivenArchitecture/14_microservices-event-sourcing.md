# Microservices Pattern – Event Sourcing

## Overview
Instead of storing only the **current state** of data, Event Sourcing stores every **change or fact** as an immutable event. The current state is derived by replaying those events. This is essentially **version control for data**.

---

## Traditional Approach vs. Event Sourcing

| Aspect | Traditional (CRUD) | Event Sourcing |
|---|---|---|
| What is stored | Current state only | All events (changes/facts) |
| History | Lost on update | Fully preserved |
| Modification | Update/overwrite | Append only |
| Reconstruct state | Already there | Replay events from the beginning |

---

## When is Event Sourcing Needed?

Most applications only need the current state — and that's fine. But some domains **require the full history**:

### Example 1 – Bank Account
Showing a user only their current balance with no transaction history is unacceptable. The history is essential for:
- **Auditing** — verify every deposit, withdrawal, and fee
- **Error correction** — detect duplicate or erroneous transactions
- **Fraud detection** — identify suspicious patterns
- **Insights** — spending advice, product recommendations

### Example 2 – Inventory Management
Knowing you have 100 units now tells you nothing about *how you got there*:
- Did you sell 100 items? Or sell 200 and receive 100 returns?
- Was it a bulk purchase from a single company?

Without the event history, these questions can't be answered.

---

## How It Works

Events are **immutable** — once stored, they never change. New events are only **appended** to the log.

```
Account opened   → Event: balance = $0
Deposit $500     → Event: +$500
Withdrawal $200  → Event: -$200
Fee $10          → Event: -$10
                    ─────────────────
Replay all events → Current balance = $290
```

---

## Two Ways to Store Events

### 1. Database
- Store each event as a separate row with entity ID, state, and timestamp.
- Enables **complex queries and analytics** across entire datasets.
- Example: track a single order's lifecycle OR analyze all orders on a given date to correlate with a sale or delivery problem.

### 2. Message Broker
- Events are published to topics for other services to consume.
- Optimized for **high event throughput** and maintaining event order.
- Harder to perform complex ad-hoc queries compared to a database.

---

## Added Benefit: Write Performance

In write-heavy systems, multiple concurrent updates to the same record cause **database contention** and slow performance.

With Event Sourcing, every write becomes an **append-only operation** — no locking required, much more efficient.

```
Traditional:  UPDATE inventory SET count = count - 1 WHERE product_id = X
              → contention with other concurrent updates

Event Sourcing: INSERT event (product_X_sold, qty=1)
              → no locking, always fast
```

---

## Efficient Reads: Two Strategies

Replaying thousands of events every time you need the current state is impractical. Use these strategies:

### 1. Snapshots
Take a periodic snapshot of the current state (e.g. monthly account balance). To get the current state, only replay events **since the last snapshot** — not from the beginning of time.

### 2. CQRS + Event Sourcing (Recommended Combination)
Separate the write side (event log) from the read side (current state in a read-optimized DB):

```
New event arrives
      ↓
Command side → appends event to log / message broker
      ↓
Query service subscribes → updates read-optimized DB (even in-memory)
      ↓
Read requests → Query service → instant response from current-state DB
```

This combination is **very popular in the industry** and provides:
- ✅ Full event history for auditing
- ✅ Fast, efficient writes (append-only)
- ✅ Fast, efficient reads (optimized read DB)
- ⚠️ Only **eventual consistency** between write and read sides

---

## Summary

| Feature | Benefit |
|---|---|
| Immutable event log | Full history, auditing, and error correction |
| Append-only writes | No contention, high write performance |
| Replay events | Reconstruct any past or current state |
| Snapshots | Efficient state reconstruction without full replay |
| CQRS + Event Sourcing | Best of both worlds — fast writes AND fast reads |

> Use Event Sourcing when the **history of how you got to the current state** is as important as the current state itself.
