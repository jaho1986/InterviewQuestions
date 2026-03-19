# Microservices – Observability & Monitoring

## Overview
In a distributed system with dozens or hundreds of microservices, bugs and performance issues are inevitable and hard to troubleshoot. **Observability** gives us the tools to not just detect problems, but understand and fix them.

---

## Monitoring vs. Observability

| Aspect | Monitoring | Observability |
|---|---|---|
| **What it does** | Collects and displays predefined metrics; triggers alerts | Enables active debugging, pattern discovery, and root cause analysis |
| **What it tells you** | *That* something is wrong | *What* is wrong and *why* |
| **Approach** | Passive — reacts to known failure modes | Active — investigate unknown issues |
| **Critical for** | Any system | Especially critical for microservices |

> Monitoring tells you the house is on fire. Observability tells you which room and what started it.

---

## Why Observability Is Critical for Microservices

In a monolith, debugging is relatively straightforward — everything happens within one application. You can SSH in, inspect logs, and profile the code directly.

In microservices, a single user request can:
- Span **multiple services and databases**
- Involve **asynchronous communication** through a message broker
- Run across **many instances on different machines**

**Most issues in microservices occur at the API boundaries** between services — not inside the service code itself. This makes tracing the flow of data across services essential.

---

## The Three Pillars of Observability

### 1. Logs
Append-only records of individual events happening within an application, container, database, or server.

- Represented as **structured or semi-structured strings**
- Include **metadata**: timestamp, triggering request, method/class/application where the event occurred
- Best for: understanding exactly what happened at a specific point in time

### 2. Metrics
Regularly sampled **numeric data points** that describe the state or behavior of the system over time.

| Metric Type | Examples |
|---|---|
| **Counters** | Requests per minute, errors per hour |
| **Distributions** | Request latency percentiles (p50, p99) |
| **Gauges** | Current CPU usage, memory usage, cache hit rate |

- Best for: detecting trends, triggering alerts, capacity planning

### 3. Distributed Tracing
Records the **full path of a request** as it travels across multiple microservices, and the time each service takes to process it.

- May include: request headers, response status codes, span durations
- Best for: identifying which service in the chain is the bottleneck or source of failure

---

## How the Three Pillars Work Together

When an issue is detected (via alert or dashboard), the three signals are used in combination:

```
Alert triggered (Metrics)
         ↓
Trace the affected request across services (Tracing)
         ↓
Isolate the problematic microservice or API
         ↓
Inspect detailed logs of that service
         ↓
Narrow down to the method or line of code causing the issue
         ↓
Remediation: rollback / hotfix / infrastructure change
            (e.g. add instances, reroute traffic to another region)
```

---

## Summary

| Pillar | Data Type | Best For |
|---|---|---|
| **Logs** | Structured text events | Detailed event-level debugging |
| **Metrics** | Numeric samples over time | Alerting, trends, capacity planning |
| **Distributed Tracing** | Request paths across services | Finding bottlenecks, cross-service failures |

> No single signal type is sufficient on its own. Effective observability in microservices requires all three working together.
