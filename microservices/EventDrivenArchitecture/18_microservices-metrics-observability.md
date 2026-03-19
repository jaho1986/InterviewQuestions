# Microservices Observability – Metrics

## Overview
Metrics are **numerical, regularly sampled signals** that help monitor system health and performance. They are the easiest of the three observability pillars to collect, visualize, and alert on — making them the first thing to check during a production incident.

---

## Why Not Collect Everything?

Collecting every possible metric is a major **anti-pattern**:
- Extremely **expensive** at scale (storage + processing across hundreds of microservices)
- Causes **information overload** — during an incident, too many graphs make it impossible to find the anomaly or distinguish cause from symptom

**Solution:** Focus on the **five categories of signals** derived from two industry-proven frameworks:
- **Google's Four Golden Signals** — focuses on user-facing metrics
- **USE Method (Brendan Gregg)** — focuses on system resources

---

## The Five Signal Categories

### 1. Traffic
> How much demand is the system handling per unit of time?

| System | Metric example |
|---|---|
| Microservice (HTTP) | Requests per second/minute |
| Database | Queries or transactions per second |
| Message broker | Events received / events delivered to consumers |

> Also measure **outgoing requests separately** from incoming ones — open connections to other services consume resources and can directly impact performance.

---

### 2. Errors
> What is the rate and type of failures?

- **Error rate** is one of the best signals for alerting — a sudden spike almost certainly means users are impacted
- HTTP non-200 status codes from dependencies → useful as a numeric metric
- In latency-sensitive systems → count responses that exceed a latency threshold as errors
- Message broker: failed event deliveries
- Database: aborted transactions, disk failures

> Note: detailed exception types are better logged than metricated — defer to logging for that level of detail.

---

### 3. Latency
> How long does it take to process a request?

**Two critical considerations:**

**① Never rely on average latency alone — use percentiles**

| Scenario | What you see |
|---|---|
| 95% of requests complete in 50ms, 5% take 5000ms | Average ≈ 300ms (looks fine) |
| 95th percentile latency | 5000ms (reveals the real problem) |

> With 1M daily users, 5% means 50,000 users experiencing 5-second load times — likely switching to a competitor. Average latency hides this completely.

**② Measure successful and failed requests separately**
- Mixing them can artificially skew the data in either direction
- Collect and monitor both independently to understand the real user experience in each scenario

---

### 4. Saturation
> How full or overloaded is a service or resource?

Measures the size of queues — both external (message brokers) and internal (in-service queues, CPU queue).

| Signal | What it indicates |
|---|---|
| Message broker topic keeps growing | Consuming service can't keep up → scalability issue |
| Database network queue growing | Storage too slow → upgrade hardware or shard the DB |
| In-service work queue growing | Logic too slow → instance may crash with out-of-memory error |

> High saturation often **explains** sudden increases in latency or request timeouts before you've even looked at those metrics.

---

### 5. Utilization
> How busy is a limited resource over time?

Applies to: **CPU, memory, disk space**, and other capacity-constrained resources.

**Key points:**
- Performance usually degrades **before** reaching 100% utilization — set alerts early (e.g. at 80% CPU)
- Measure with **high granularity** — averages over several minutes hide short bursts of high utilization that indicate bottlenecks
- Example: CPU approaching 80% → scale out immediately; crossing that threshold causes higher latency and instability

---

## Quick Reference: The Five Signals

| Signal | Question it answers | Alert when... |
|---|---|---|
| **Traffic** | How much demand? | Unusual spike or drop |
| **Errors** | How many failures? | Error rate increases |
| **Latency** | How slow? (use p95/p99) | Percentile exceeds threshold |
| **Saturation** | How full are the queues? | Queue keeps growing |
| **Utilization** | How busy are the resources? | Approaching capacity limits |

> These five are the baseline for any system. Depending on specific business logic, additional domain-specific metrics can be added on top.
