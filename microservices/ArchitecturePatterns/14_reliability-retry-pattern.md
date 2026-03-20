# Reliability Patterns – Retry Pattern

## Overview
The **Retry Pattern** hides transient internal errors from users by automatically resending a failed request to a remote service. Simple in concept, but dangerous if implemented carelessly — an incorrect retry implementation can turn a minor incident into a full system outage.

---

## The Problem

In cloud environments, hardware, software, and network errors are inevitable. Every remote call can result in:
- A **successful response** → no action needed
- An **explicit error** (with error code) or a **timeout** → must decide what to do

### Error Categorization (First Step)

| Error Type | Example | Action |
|---|---|---|
| **User error** | 403 Forbidden (unauthorized) | Return the error to the user with details — do NOT retry |
| **System error** | 503 Service Unavailable, timeout | Try to recover — potentially retry |

> Only retry **internal system errors** that are **short, temporary, and recoverable**.

---

## Six Key Considerations

### 1. Which Errors to Retry
Only retry errors that are **transient** — where there's a reasonable chance the service will recover shortly:
- `503 Service Unavailable` (server is busy or in maintenance)
- Request timeout (instance may have crashed or network packet was lost)

**Do NOT retry:** client errors (4xx), business logic failures, or anything clearly not transient.

---

### 2. Delay / Backoff Strategy (Critical — prevents retry storms)

A **retry storm** occurs when many callers retry simultaneously, overwhelming the remaining healthy instances — potentially causing a complete and unrecoverable outage.

**Three backoff strategies:**

| Strategy | How it works | Example |
|---|---|---|
| **Fixed delay** | Same wait time between every retry | 100ms → 100ms → 100ms |
| **Incremental delay** | Delay grows linearly with each attempt | 100ms → 200ms → 300ms |
| **Exponential backoff** | Delay doubles with each attempt | 100ms → 200ms → 400ms → 800ms |

> Exponential backoff gives the failing service the most time to recover. It is the most commonly recommended strategy.

---

### 3. Jitter (Randomization)

Even with backoff, if many instances of your service all retry at the exact same moment, you still create spiky traffic bursts on the healthy servers.

**Solution:** Add a small random offset (jitter) to each delay.

```
Instead of:  delay = attempt × 100ms
Use:         delay = attempt × (100ms + random(-15ms, +15ms))
```

This spreads retry traffic over time → smoother load on healthy instances.

---

### 4. Time-Boxing (Max Retries / Timeout)

Retrying forever is not a solution. Set a **maximum number of retries or a total retry duration**:
- If all retries fail → return an error to the user
- Immediately alert on-call engineers — this is no longer transient; it's a real incident

---

### 5. Idempotency (Critical for correctness)

**Only retry idempotent operations** — operations where performing them twice has the same result as once.

| Operation | Safe to retry? |
|---|---|
| GET request (read data) | ✅ Yes |
| Charging a payment | ❌ No — could charge the user twice |
| Inserting a unique record | ⚠️ Only with idempotency keys |

> If you retry a payment and the original request was actually processed (but the confirmation was lost), you'll charge the user twice.

---

### 6. Where to Implement the Retry Logic

| Option | Details |
|---|---|
| **Shared library / module** | Reusable across services; many open-source implementations available per language |
| **Ambassador / Sidecar pattern** | Retry logic runs as a separate process on the same host; service code is completely unaware of retries — only sees success or final failure |

---

## The Retry Storm Risk (Summary)

```
2 of 10 service instances fail
         ↓
Calling service starts retrying (no delay)
         ↓
All retries hit the 8 healthy instances
         ↓
Healthy instances get overwhelmed → more timeouts
         ↓
More retries → more overwhelm → all 10 instances go down
         ↓
New instances start → immediately bombarded → can't recover
```

**Prevention:** Backoff + jitter + max retries.

---

## Summary

| Consideration | Key Rule |
|---|---|
| **Which errors to retry** | Only transient, recoverable system errors (not user errors) |
| **Backoff strategy** | Use incremental or exponential backoff — never retry with no delay |
| **Jitter** | Add randomness to delays to avoid synchronized retry bursts |
| **Time-boxing** | Set a max retry count or total duration; alert engineers on final failure |
| **Idempotency** | Only retry operations that are safe to execute more than once |
| **Implementation** | Shared library or Ambassador/Sidecar pattern |
