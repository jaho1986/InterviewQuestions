# Reliability Patterns – Dead Letter Queue (DLQ)

## Overview
The **Dead Letter Queue (DLQ)** pattern provides a safe landing place for messages that cannot be delivered to their intended destination or cannot be processed by a consumer. It prevents problematic messages from clogging the main queue while ensuring they are never lost.

---

## The Problem: Failures in Event-Driven Pipelines

In a typical event-driven architecture (Publisher → Message Broker → Consumers), there are many new failure points:

### Publisher-Side Failures
| Failure | Example |
|---|---|
| Unknown destination | Order service doesn't know which topic to publish to |
| Queue is full | Target queue has reached its size limit |
| Message too large | Message exceeds the broker's size limit |

### Consumer-Side Failures
| Failure | Example |
|---|---|
| Cannot parse the message | Data corruption or mismatched message protocols |
| Cannot process the message | Payment service doesn't support that country or card type |
| Consumer keeps crashing | A bad message causes an exception every time it's consumed |

> **The danger of retrying consumer failures:** If a consumer keeps retrying a broken message, it **clogs the queue** — delaying all other messages, potentially causing queue overflow and cascading failures across all consumers.

---

## The Solution: Dead Letter Queue

A **special queue or topic** in the message broker where problematic messages are moved to — keeping the main pipeline healthy while preserving the failed messages for later inspection and processing.

```
Publisher → [ Main Queue ] → Consumer
                 │
         (message fails)
                 ↓
          [ Dead Letter Queue ]
                 ↓
         Alert engineers → Inspect → Fix → Replay
```

---

## Two Ways to Move Messages to the DLQ

### 1. Programmatic Publishing
The service itself decides to send the message to the DLQ:
- **Publisher:** Can't determine the correct topic → publishes directly to DLQ
- **Consumer:** Can't parse or handle the message → republishes it to DLQ and removes it from the original queue

### 2. Automatic (Broker-Configured)
Configure the message broker to detect and move problematic messages automatically:
- **Delivery to non-existing topic** → broker moves it to DLQ on the publisher's behalf
- **Message consumed too many times without success** (consumer keeps crashing) → broker automatically moves it to DLQ

> Most modern open-source and cloud-based pub/sub and message broker solutions support automatic DLQ configuration.

---

## Always Attach Error Metadata

When moving a message to the DLQ, always include additional context:
- **Error code**
- **Stack trace**
- **Error message / reason for failure**

This enables engineers to quickly understand what went wrong and how to fix it.

---

## What to Do with Messages in the DLQ

### Step 1: Monitor and Alert Aggressively
Set up **monitoring and alerting** on the DLQ. Messages arriving there indicate a real bug or issue — they must not be ignored or forgotten.

### Step 2: Fix the Root Cause
Use the attached error metadata to identify and fix the underlying problem.

### Step 3: Process the Messages
Two options once the issue is resolved:

| Option | When to use |
|---|---|
| **Replay to original queue** | Automated tooling moves messages back to the main queue for normal processing |
| **Manual processing** | A support engineer handles them case by case (e.g. rare edge case orders, discontinued products) |

---

## Real-World Example: Online Store

**Architecture:** Order Service → Message Broker → Inventory, Payment, Fulfillment Services

**Scenario:** A user purchases a product that was removed from the catalog weeks after they added it to their cart (cached in browser).

- The Inventory Service and Fulfillment Service can't handle this edge case → message goes to DLQ
- Options:
  - **Reject the purchase** (automated)
  - **Manually process it** — if it's a digital product, a support engineer can fulfill it manually to keep the customer happy

---

## Summary

| Aspect | Key Point |
|---|---|
| **Purpose** | Isolate unprocessable messages to keep the main pipeline healthy |
| **Data safety** | Messages are preserved in the DLQ — never lost |
| **Programmatic publishing** | Service explicitly sends to DLQ when it can't handle the message |
| **Automatic configuration** | Broker detects delivery failures and moves messages automatically |
| **Error metadata** | Always attach error code, stack trace, and reason for diagnosis |
| **Monitoring** | Aggressive alerting on DLQ is mandatory — messages there signal real bugs |
| **Processing options** | Fix + replay to main queue, or manual case-by-case handling |
