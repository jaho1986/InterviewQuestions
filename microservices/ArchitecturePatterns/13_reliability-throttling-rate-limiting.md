# Reliability Patterns – Throttling / Rate Limiting

## Overview
**Throttling** (also called Rate Limiting) sets a maximum on the number of requests or amount of data that can be sent or received per unit of time. It protects systems from overconsumption — whether caused by misbehaving clients, legitimate traffic spikes, or runaway internal batch jobs.

---

## Two Problems It Solves

### Problem 1: Overconsumption of Our System (Server-Side)
A client suddenly bombards our API with requests at a very high rate:
- **Scenario A:** System can't keep up → CPU/memory exhaustion → slowness affects all clients → SLA violations
- **Scenario B:** Auto-scaling kicks in → costs skyrocket far beyond budget

### Problem 2: Our System Overconsumes External Services (Client-Side)
A batch job we run internally calls third-party APIs or cloud services at a high rate:
- Example: social media trend analysis job that calls ML APIs charged per usage
- Risk: massive unexpected bill at the end of the month

| Type | Who is throttled | Who applies the limit |
|---|---|---|
| **Server-side throttling** | Our clients (external callers) | Us — to protect our system |
| **Client-side throttling** | Our own services (external API calls) | Us — to protect our budget |

---

## What Can Be Limited

- **Number of requests** per second / minute / day
- **Bandwidth** — max MB or GB sent/received per period

---

## Three Strategies When a Limit Is Exceeded

### 1. Drop the Request
Reject the request immediately and return an error.
- HTTP status code: **429 Too Many Requests**
- Best for: real-time data where stale is acceptable (e.g. stock price requests — client can retry later)

### 2. Queue the Request (Degrade, Don't Deny)
Accept the request but delay processing it until capacity is available (FIFO queue/message broker).
- Best for: operations where order matters and eventual processing is acceptable (e.g. trade execution)
- Combine with drop strategy: set a **queue size limit** — if the queue fills up, start dropping to prevent overload

### 3. Reduce Service Quality (Soft Degradation)
Continue serving the client but at a lower quality level.
- Example: streaming platform → reduce video resolution or audio bitrate instead of cutting off the stream

---

## Strategies Combined (Example: Stock Trading Platform)

```
Client sends stock price requests (read)
  → If rate exceeded → DROP (stale data is acceptable)

Client sends trade requests (write)
  → If rate exceeded → QUEUE (process at a controlled pace)
  → If daily limit exceeded → DROP (prevent queue overflow)

Client streams video/audio
  → If bandwidth exceeded → REDUCE QUALITY (soft degradation)
```

---

## Key Design Considerations

### 1. Global (API-level) vs. Per-Customer Throttling

| Approach | Benefit | Drawback |
|---|---|---|
| **Global (per API endpoint)** | Easy to guarantee system-wide limits | One greedy client can starve all others |
| **Per-customer** | Fair share per client; isolated service levels | Hard to control total traffic; complex with multiple subscription tiers |

### 2. External vs. Internal (Service-level) Throttling

| Approach | Benefit | Drawback |
|---|---|---|
| **External only (API gateway)** | Simple to implement | One request can trigger many internal calls — internal services may still be overwhelmed |
| **Per-service throttling** | Protects individual services independently | Complex to track consumption across services |

> Example: A single client request for 100 assets may trigger 50 calls to Service A, 20 to Service B, 30 to Service C — external throttling alone doesn't protect the internal services.

---

## Summary

| Aspect | Key Point |
|---|---|
| **Server-side throttling** | Protect your system from clients overconsuming resources |
| **Client-side throttling** | Protect your budget from overconsuming external APIs |
| **Drop** | Fastest response; use when data staleness is acceptable |
| **Queue** | Delayed processing; use when eventual execution is acceptable |
| **Degrade** | Reduce quality; use when denying service is not an option |
| **Global vs. per-customer** | Trade-off between system protection and fairness |
| **External vs. service-level** | Trade-off between simplicity and granular protection |

> There is no universally correct throttling strategy — the right approach depends on your use case, workload, and requirements.
