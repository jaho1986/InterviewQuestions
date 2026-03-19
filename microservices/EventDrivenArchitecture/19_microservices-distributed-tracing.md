# Microservices Observability – Distributed Tracing

## Overview
Even with metrics and logs, finding where a problem occurs across dozens of microservices can be nearly impossible. **Distributed tracing** tracks a request as it flows through the entire system, showing every component involved and how long each one took — narrowing the investigation before using logs and metrics to go deeper.

---

## Why Distributed Tracing Is Needed

Consider an e-commerce order flow spanning: API Gateway → Auth Service → Order Service → Message Broker → Payment → Shipping → Notification — plus multiple databases and third-party APIs.

**The problem:** If some users don't receive their order confirmation email (or receive it hours late), the issue could be anywhere in this chain. With metrics and logs alone:
- Which service's dashboard do you check first?
- Which of thousands of log lines do you read?
- Every service runs as multiple instances across different machines
- The architecture is constantly evolving — no human remembers every service involved in every flow

**Distributed tracing solves this** by giving engineers a visual map of the entire request journey with timing data for each component.

> Tracing narrows the search to a specific component or inter-service communication problem. Then logs and metrics finish the investigation.

---

## How It Works

### Step 1 – Generate a Trace ID
When the initial request arrives, a **unique trace ID** is generated and placed into a **trace context** object.

### Step 2 – Propagate the Context
The trace context is passed along with every subsequent request or event — typically via **HTTP headers** or **message headers**.

### Step 3 – Instrument Each Service
Each service uses a **tracing instrumentation library/SDK** (available for every programming language) to:
- Receive the trace context
- Collect timing and metadata
- Propagate the context to the next service

### Step 4 – Collect & Aggregate
```
Each service instance collects trace data
         ↓
Local agent (runs on same host) pulls the data
         ↓
Sends to a central message broker/queue
         ↓
Big data processor aggregates, indexes, stores traces
         ↓
Developer queries and visualizes via Tracing UI
```

---

## Key Terminology

| Term | Definition |
|---|---|
| **Trace** | The complete record of a single request flowing through all services |
| **Trace ID** | Unique identifier that ties all spans of one request together |
| **Trace Context** | Object carrying the trace ID and metadata, propagated between services |
| **Span** | A logical unit of work within the trace (e.g. processing a request, running a DB query) |
| **Parent/Child Spans** | Spans organized in a hierarchy for deeper granularity within a service |

### Spans in practice
- **Coarse-grained:** full request handling by a service, or a database query
- **Fine-grained:** manually created by developers for specific logical units within a service
- **Hierarchy:** expand a slow span → inspect its child spans → find the slow DB query → investigate with logs

---

## Challenges

### 1. Manual Code Instrumentation
- Every service must depend on and correctly use a tracing library
- Incorrect usage leads to spans that are too broad, missing data, or broken traces
- Must be done before you need it — not useful to add during an incident

### 2. High Cost
| Cost source | Detail |
|---|---|
| Agent per host | Extra CPU and memory on every service instance |
| Network bandwidth | Trace data sent from every service to the central pipeline |
| Big data pipeline | Infrastructure + maintenance to process all incoming traces |
| **Storage** (biggest cost) | Storing all traces for weeks so engineers can find them later |

**Mitigation:** Most companies use **sampling** — e.g. trace only 1 in 1,000 or 1 in 10,000 requests. This reduces cost but can make it hard to find a trace that reproduces a specific bug.

### 3. Trace Size and Complexity
In large microservices + EDA deployments, a single trace can involve so many components that:
- It's overwhelming for a human to interpret
- Some tracing UIs can't even load the largest traces

---

## Summary

| Aspect | Key Point |
|---|---|
| **Purpose** | Narrow down problems to a specific service or inter-service boundary |
| **How it propagates** | Via HTTP or message headers carrying a trace context |
| **Unit of measurement** | Spans (coarse or fine-grained, organized hierarchically) |
| **Data pipeline** | Agent → message broker → big data processor → tracing UI |
| **Main challenges** | Manual instrumentation, high storage costs, trace complexity |
| **Used together with** | Logs (deep debugging) and Metrics (alerting + trends) |

> Despite its challenges, distributed tracing is essential in microservices. It gives developers confidence that when production issues occur, they have the tools to find the root cause.
