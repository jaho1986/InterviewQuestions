# Reliability Patterns – Circuit Breaker

## Overview
The **Circuit Breaker** pattern handles **long-lasting, non-recoverable failures** in remote service calls. Unlike the Retry pattern (which assumes failures are short and temporary), the Circuit Breaker assumes that if multiple requests have already failed, the next one will too — so it stops trying and fails fast.

> Analogy: an electrical circuit breaker opens the circuit when there's a power surge — stopping electricity from flowing and preventing further damage.

---

## Retry vs. Circuit Breaker

| | Retry Pattern | Circuit Breaker |
|---|---|---|
| **Assumption** | Failure is short and temporary | Failure is severe and long-lasting |
| **Approach** | Optimistic — retry until success | Pessimistic — fail fast, don't waste resources |
| **Best for** | Transient errors (timeouts, crashes) | Extended outages (service down for minutes/hours) |

---

## The Three States

```
         [CLOSED] ──── failure rate exceeds threshold ────► [OPEN]
            ▲                                                   │
            │                                                   │
    success rate                                         after timeout
      high enough                                               │
            │                                                   ▼
         [HALF-OPEN] ◄──────────────────────────────────────────
```

| State | What happens |
|---|---|
| **Closed** (normal) | All requests go through; circuit breaker tracks success/failure rate |
| **Open** (tripped) | No requests go through; caller immediately receives an error or exception |
| **Half-Open** (probing) | A small % of requests are allowed through to probe if the service has recovered |

### State Transitions
- **Closed → Open:** Failure rate exceeds a configured threshold (e.g. 20 failures in the last minute)
- **Open → Half-Open:** After a configured timeout period
- **Half-Open → Closed:** Probe requests have a high enough success rate → service is healthy
- **Half-Open → Open:** Probe requests still failing → service still unhealthy → reopen the circuit

---

## Five Key Considerations

### 1. What to Do With Blocked Requests (Open State)

| Scenario | Action |
|---|---|
| Request is non-critical (e.g. loading a profile image) | **Drop silently** — log for later analysis |
| Request is critical and must not be lost (e.g. shipping an order) | **Log and Replay** — store the event for manual or automatic replay later |

### 2. What Response to Return to the Caller

| Option | Description |
|---|---|
| **Fail silently** | Return an empty response or a placeholder (e.g. blank image, default value) |
| **Best effort** | Return a cached or older version of the data if available |

### 3. One Circuit Breaker per External Service
Each downstream service must have its **own separate circuit breaker**. If the shipping service is down, the circuit breaker for shipping opens — but calls to inventory and billing must still go through normally.

### 4. Replacing Half-Open with Async Health Checks
Instead of letting real user requests probe the service in half-open state, send **lightweight asynchronous health check pings**:

**Benefits:**
- Users are not affected while probing
- Pings are small (no payload) → save bandwidth, CPU, and memory

**Tradeoff:**
- Too many pings → overwhelm an already struggling service
- Too few pings → users are blocked from a healthy service unnecessarily

### 5. Where to Implement
| Option | Details |
|---|---|
| **Shared library** | Off-the-shelf implementations available for most languages |
| **Ambassador / Sidecar** | Separate process on the same host; service code is completely unaware — sees only success or final failure |

---

## Real-World Example: Online Dating Service

- User requests a profile → backend calls **Image Service** + **Profile Service**
- Image Service goes down for 1 hour

**Without Circuit Breaker:**
Every request waits for the full timeout before failing → slow responses, wasted CPU/network resources for every user

**With Circuit Breaker:**
- After 20 failures in the last minute → circuit opens
- All subsequent requests to Image Service → immediate error (fail silent or return placeholder)
- After timeout → circuit goes half-open → probes the Image Service
- Once Image Service recovers → circuit closes → normal operation resumes

---

## Summary

| Aspect | Key Point |
|---|---|
| **Purpose** | Handle long-lasting failures without wasting resources on doomed requests |
| **Closed state** | All requests pass; failure rate is monitored |
| **Open state** | No requests pass; fail fast; save resources |
| **Half-open state** | Small % of requests probe for recovery |
| **Blocked requests** | Drop (non-critical) or Log & Replay (critical) |
| **Response to caller** | Fail silently or return best-effort cached data |
| **Per-service** | Always one circuit breaker per external dependency |
| **Implementation** | Shared library or Ambassador Sidecar pattern |
