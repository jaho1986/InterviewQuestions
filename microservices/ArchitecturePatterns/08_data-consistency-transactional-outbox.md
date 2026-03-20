# Data Consistency Patterns – Transactional Outbox

## Overview
The **Transactional Outbox** pattern guarantees that a database update and the corresponding event publication to a message broker are **always both completed** — even if the service crashes between the two operations. It solves a critical atomicity problem in any event-driven architecture.

---

## The Problem: Non-Atomic DB Update + Event Publication

In any event-driven service, there are two operations that must happen together:
1. **Update the database** (e.g. insert a new user)
2. **Publish an event** to the message broker (e.g. notify other services of the new user)

These two operations are **not atomic** — there is no cross-system transaction between a database and a message broker.

### What can go wrong:

| Order of operations | Failure scenario | Result |
|---|---|---|
| DB first, then event | Crash after DB write, before event | User exists in DB, but no other service was notified |
| Event first, then DB | Crash after event, before DB write | Other services process a user that doesn't exist in the DB |

This problem affects any pattern that requires updating a DB and triggering an event — including the Saga pattern.

---

## The Solution: Transactional Outbox Pattern

### Core Idea
Add an **Outbox table** to the service's own database. Instead of publishing directly to the message broker, write the message to the Outbox table — **within the same database transaction** as the business data update.

```
Service receives request
         ↓
Begin DB transaction
  → Update business table (e.g. insert user)
  → Insert message into Outbox table
Commit transaction (atomic — both or neither)
         ↓
[Message Relay Service]
  → Monitors Outbox table
  → Sends message to message broker
  → Marks message as sent (or deletes it)
```

Since both the business update and the Outbox entry are part of the **same DB transaction**, they are guaranteed to either both succeed or both fail — no split state.

---

## Three Issues to Address

### Issue 1 – Duplicate Events (At-Least-Once Delivery)

If the message relay crashes after sending but before marking the message as sent, it will send the same message again on restart.

**Solution:**
- Assign each Outbox message a **unique ID**
- The relay attaches this ID to the published event
- Each consumer tracks already-processed message IDs and **discards duplicates**

> Note: If the consumer operation is **idempotent** (performing it twice has the same result as once), no deduplication logic is needed. Example: overwriting a user's preferences with the same data is safe.

---

### Issue 2 – No Transaction Support in the Database

Some NoSQL databases don't support multi-collection transactions. The pattern relies on atomic writes.

**Workaround:**
- Embed the outbox message as an **additional field on the same document** being written
- A single document write in NoSQL is typically atomic
- The message relay queries for documents that have the outbox field, publishes the event, then removes the field

---

### Issue 3 – Event Ordering

If a user signs up and then cancels within seconds, the relay must send the **registration event before the cancellation event**. Without care, messages could be published out of order.

**Solution:**
- Assign each Outbox message an **incrementing sequence ID**
- The message relay always sorts messages by sequence ID before publishing

---

## How It Works Together (Full Flow)

```
User Service receives "sign up" request
         ↓
DB Transaction:
  ├── INSERT into users table
  └── INSERT into outbox table (event: "user_signed_up", id: 42, seq: 1)
         ↓
Message Relay detects new outbox entry
  → Publishes event to message broker (with message_id: 42)
  → Deletes/marks entry as sent
         ↓
Consumers receive event
  ├── Scheduling Service: idempotent — processes safely
  └── Billing Service: checks message_id 42 — not seen before → processes; if duplicate → discards
```

---

## Summary

| Aspect | Key Point |
|---|---|
| **Problem** | DB update and event publication are not atomic — either can fail independently |
| **Solution** | Write to an Outbox table in the same DB transaction as the business data |
| **Message Relay** | Separate service that monitors Outbox and publishes events to the broker |
| **Duplicate events** | Assign unique IDs to messages; consumers deduplicate by ID |
| **No DB transactions** | Embed outbox message as a field on the same document (single atomic write) |
| **Event ordering** | Use a sequence ID; relay sorts by it before publishing |
