# Performance Patterns – Event Sourcing

## Overview
**Event Sourcing** replaces storing the current state of data with storing every **change or fact** as an immutable event. The current state is derived by replaying those events. Think of it as **version control for data**.

> Use this pattern when the **history of how you arrived at the current state** is as important as the current state itself.

---

## Traditional Approach vs. Event Sourcing

| Aspect | Traditional (CRUD) | Event Sourcing |
|---|---|---|
| What is stored | Current state only | All events (changes/facts) |
| History | Lost on update | Fully preserved |
| Writes | Overwrite existing records | Append-only |
| Reconstruct state | Already stored | Replay events from the beginning |
| Mutability | Records can be changed | Events are immutable |

---

## When Is Event Sourcing Needed?

Most apps only need current state — that's fine. But some domains require the full history:

### Example 1 – Bank Account
Showing only the current balance is unacceptable. History is needed for:
- **Auditing** — verify each deposit, withdrawal, and fee
- **Error correction** — detect duplicate or erroneous transactions
- **Fraud detection** — identify suspicious patterns
- **Insights** — spending advice, product recommendations

### Example 2 – Inventory Management
Seeing 100 units now tells you nothing about *how you got there*:
- 100 sales? Or 200 sales + 100 returns?
- A single bulk purchase?

Without the event history, these questions cannot be answered.

---

## How It Works

Events are **immutable** — only new events are appended. Existing events never change.

```
Account opened      → Event: balance = $0
Deposit $500        → Event: +$500
Withdrawal $200     → Event: -$200
Fee $10             → Event: -$10
                      ──────────────
Replay all events   → Current balance = $290
```

---

## Two Ways to Store Events

| Storage | Pros | Cons |
|---|---|---|
| **Database** | Supports complex queries and analytics across all events | Slower for high-volume event streams |
| **Message Broker** | Optimized for high throughput; naturally maintains event order | Complex queries harder to perform |

---

## Added Benefit: Write Performance

In write-heavy systems, multiple concurrent updates to the same record create **database contention** and locking.

With Event Sourcing, every write is an **append-only operation** — no locking required, much more efficient.

```
Traditional:   UPDATE inventory SET count = count - 1 WHERE product_id = X
               → contention with concurrent updates

Event Sourcing: INSERT event (product_sold, qty=1)
               → no locking, always fast
```

---

## Efficient Reads: Two Strategies

Replaying thousands of events every time you need the current state is impractical.

### 1. Snapshots
Take a periodic snapshot of the current state (e.g. monthly account balance). To get current state: replay only events **since the last snapshot**.

### 2. CQRS + Event Sourcing (Best Combination)

```
New event arrives
      ↓
Command side → appends event to log / message broker
      ↓
Query service subscribes → maintains current state in read-optimized DB
      ↓
Read requests → Query service → instant response
```

**This combination gives you:**
- ✅ Full event history for auditing
- ✅ Fast, efficient writes (append-only, no locking)
- ✅ Fast, efficient reads (optimized read DB)
- ⚠️ Eventual consistency between write and read sides only

---

## Summary

| Feature | Benefit |
|---|---|
| Immutable event log | Full history, auditing, fraud detection |
| Append-only writes | No contention, high write performance |
| Replay events | Reconstruct any past or current state |
| Snapshots | Efficient state reconstruction without full replay |
| CQRS + Event Sourcing | Best of all worlds: history + fast writes + fast reads |
| Trade-off | Eventual consistency when combined with CQRS |
