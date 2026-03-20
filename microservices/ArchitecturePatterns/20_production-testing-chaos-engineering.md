# Production Testing Patterns – Chaos Engineering

## Overview
**Chaos Engineering** is a production testing philosophy that deliberately injects controlled failures into a live system to discover vulnerabilities before real disasters do. The core insight: no amount of pre-production testing can fully predict how a distributed cloud system behaves under real failure conditions.

> *"Embrace the inherent chaos of distributed systems — find the failures yourself before they find you."*

---

## Why Normal Testing Isn't Enough

Unit tests, integration tests, and functional tests verify that the system works under expected conditions. But in production, things happen that cannot be tested beforehand:

| Failure type | Examples |
|---|---|
| **Infrastructure** | Server power loss, network switch failure, storage device failure |
| **Natural events** | Data center hit by natural disaster |
| **Traffic spikes** | Viral news event, major market event causing everyone to trade at once |
| **Third-party failures** | External API outages, rate limiting from stock price providers |
| **Unexpected load patterns** | All users suddenly buying the same stock → one DB instance overwhelmed |

> When these rare events occur and the system doesn't respond as expected, the consequences can be catastrophic — and by then it's too late to fix.

---

## The Chaos Engineering Strategy

**Deliberately and systematically inject random but controlled failures into production. Monitor the system's response. Fix the gaps. Repeat continuously.**

### Benefits
- Discovers **single points of failure** and **performance bottlenecks** before real incidents
- Forces engineers to think about failures **during daily development**
- Tests the team's ability to **monitor, detect, and resolve outages** quickly
- Over time: system becomes more resilient; team becomes more proficient

---

## Types of Failures to Inject

| Failure | Description |
|---|---|
| **Server termination** | Randomly kill VM instances (original Chaos Monkey approach, Netflix 2011) |
| **Latency injection** | Artificially slow down communication between services or between a service and its DB |
| **Database access restriction** | Block access to a DB instance → test failover to a replica in another zone/region |
| **Resource exhaustion** | Fill up disk space on a service or DB instance |
| **Zone/region disabling** | Cut off traffic to an entire availability zone → verify graceful failover |

> Use **automated tools** to randomly trigger failures — removing human bias from the selection of what to break and when.

---

## The Steps of Each Chaos Test

```
1. Measure baseline      → capture normal system behavior before injecting failure
        ↓
2. Form hypothesis       → define the expected correct behavior during the failure
        ↓
3. Inject the failure    → apply the controlled failure for a predefined period
        ↓
4. Monitor & document    → observe system behavior; record all findings
        ↓
5. Restore the system    → return to the original state
        ↓
6. Act on findings       → fix identified issues; improve resilience
        ↓
7. Repeat continuously   → keep testing to ensure new changes don't introduce new failures
```

---

## Key Considerations

### Minimize the Blast Radius
Always stay within your **error budget** — the amount of downtime or degradation acceptable to your users. Never promise 100% availability — this leaves room for both unexpected and deliberate failures.

### Continuous Testing
A one-time chaos test is not enough. **Continuous, periodic testing** ensures that:
- New code changes don't introduce regressions
- The team always has adequate monitoring, dashboards, and logging to detect issues fast

---

## Summary

| Aspect | Key Point |
|---|---|
| **Purpose** | Proactively find failures before they cause real incidents |
| **Method** | Controlled, automated injection of failures into production |
| **What to inject** | Server kills, latency, DB restrictions, resource exhaustion, zone disabling |
| **Process** | Baseline → Hypothesis → Inject → Monitor → Restore → Fix → Repeat |
| **Blast radius** | Keep failures controlled and within the error budget |
| **Frequency** | Continuous — not a one-time activity |
| **Team benefit** | Builds monitoring skills and incident response proficiency |
