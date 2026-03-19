# Event-Driven Architecture – Use Cases & Delivery Patterns

## Overview
Event-Driven Architecture (EDA) is powerful but not a universal solution. This lecture covers **when to use EDA**, **when to stick with request-response**, and **two patterns for delivering events**.

---

## When to Use Event-Driven Architecture

### 1. Fire and Forget (Async by nature)
The sender does not need an immediate response.
- Generating a report that takes minutes/hours → result sent via email when ready
- A user leaving a product review → no data expected back, just an acknowledgment

### 2. Reliable Delivery
When losing a message in transit is unacceptable.
- An e-commerce order: if we promise delivery, we must guarantee the order is never lost even if a server crashes mid-process
- A bank transfer between accounts: requires guaranteed, auditable delivery

### 3. Infinite Streams of Data
A continuous, never-ending flow of data that needs real-time processing.
- GPS location data from mobile devices
- Sensor data from IoT devices (autonomous cars, smart appliances)

### 4. Anomaly Detection & Pattern Recognition
Individual events are not meaningful alone, but a sequence reveals insights.
- Requests-per-second rising → scale out proactively
- Requests-per-second dropping to zero → hardware/software failure detected

### 5. Broadcasting State Changes
A service wants to notify any interested party about something that happened, without knowing who those parties are.
- A user clicks a digital ad → Ad Service emits an event → multiple downstream services (billing, analytics, recommendations) each react independently

### 6. Buffering Traffic Spikes
Use the message broker to absorb sudden spikes and deliver events only as fast as consumers can handle them.
- A viral post triggers a massive burst of comments → events are buffered and processed at a safe rate

---

## When NOT to Use Event-Driven Architecture

| Scenario | Reason to avoid EDA |
|---|---|
| User needs an immediate data response | e.g. loading a product catalog page — the user won't wait |
| Simple interaction with no clear benefit | Running a message broker adds complexity and cost that isn't justified |

> **Practical tip:** Start with the simple request-response model. Upgrade specific, critical parts to EDA only where it provides clear value.

---

## Real-World Reality
A typical microservices system **combines both models**:
- Request-response for synchronous, data-fetching interactions
- EDA for async, decoupled, or high-reliability workflows

---

## Two Event Delivery Patterns

### Pattern 1 – Event Streaming
The message broker acts as a **persistent log** of events.

| Feature | Detail |
|---|---|
| Event retention | Stored temporarily or permanently |
| Consumer access | Can read all past events, even already-consumed ones |
| Replay | New consumers can replay events from any point in history |
| Best for | Reliable delivery, anomaly detection, pattern recognition |

### Pattern 2 – Publisher / Subscriber (Pub-Sub)
Consumers **subscribe to a topic** and receive only new events from that point forward.

| Feature | Detail |
|---|---|
| Event retention | Deleted once all current subscribers have consumed it |
| Consumer access | No access to past events |
| Late subscribers | Receive only new events after subscribing |
| Best for | Fire and forget, broadcasting, buffering, infinite streams |

---

## Summary

| Use Case | EDA or Request-Response? | Best Pattern |
|---|---|---|
| Fire and forget | ✅ EDA | Pub-Sub |
| Reliable delivery | ✅ EDA | Event Streaming |
| Infinite data streams | ✅ EDA | Pub-Sub |
| Anomaly / pattern detection | ✅ EDA | Event Streaming |
| Broadcasting state changes | ✅ EDA | Pub-Sub |
| Buffering traffic spikes | ✅ EDA | Pub-Sub |
| Immediate data response needed | ❌ Request-Response | — |
| Simple low-complexity interaction | ❌ Request-Response | — |