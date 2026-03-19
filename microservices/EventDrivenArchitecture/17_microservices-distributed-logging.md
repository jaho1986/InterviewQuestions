# Microservices Observability – Distributed Logging

## Overview
Logging is the simplest way to get insights into an application's state. In microservices, thousands of instances can produce millions of log lines per day — making **distributed logging best practices** essential for effective debugging.

---

## What is a Log Line?
A log line records:
- **Events**: receiving a request, executing a DB query, starting a complex operation
- **Errors and exceptions**: accompanied by parameters that led to the issue
- **State snapshots**: anything useful for understanding what the system was doing at a point in time

---

## Best Practice 1 – Centralized Logging System

With hundreds of microservice instances each producing logs, searching files one by one is not practical.

**Solution:** Collect all logs into a **centralized, scalable logging system** that:
- Parses and **indexes** logs for fast search
- Supports filtering and grouping by: host, microservice, time range, region, severity
- Is searchable by text patterns or structured attributes

---

## Best Practice 2 – Common Log Structure

All microservices should follow the **same log format and terminology**, readable by both humans and machines for efficient parsing and analysis.

Common formats:
- `logfmt` — key-value pairs
- `JSON`
- `XML`

> Consistency across services is critical when debugging time-sensitive production issues quickly.

---

## Best Practice 3 – Log Levels (Severity)

Assign a **severity level** to every log line to reduce noise and enable targeted filtering.

| Level | When to use |
|---|---|
| `FATAL` | Unrecoverable errors with direct user impact |
| `ERROR` | Exceptions and errors that need immediate attention |
| `WARN` | Potential problems: slow outgoing requests, unexpected input values |
| `INFO` | Normal application events and milestones |
| `DEBUG` | Detailed diagnostic information for deep investigation |
| `TRACE` | Most fine-grained events, every step of a process |

**Use cases:**
- **On-call engineer at 2am**: filter by `ERROR` and `FATAL` → find the problem fast
- **Automated tools**: scan periodically for `ERROR`/`WARN` → create and assign tickets automatically
- **Deep investigation**: use all levels including `DEBUG`/`TRACE` to follow every event on a specific instance

---

## Best Practice 4 – Correlation ID

Assign a **unique ID to every user request or transaction** and include it in every log line related to that request.

**Why it matters:**
- Each microservice instance processes many requests **concurrently** — without a correlation ID, it's impossible to isolate the logs for one specific request
- Enables tracing the **sequence of events** for a single request **across multiple microservices**

---

## Best Practice 5 – Rich Contextual Information

Every log line should include as much relevant context as possible:

| Field | Purpose |
|---|---|
| **Service name** | Identifies which microservice emitted the log |
| **Host name** | Identifies which instance produced it |
| **User ID** | Adds context on who initiated the operation |
| **Timestamp** | When the event occurred |
| **Stack trace** (on errors) | Shows how execution reached that error |
| **Request parameters** | Helps reproduce and understand the root cause |

---

## Two Critical Considerations

### 1. Log only what you need
Storage and processing are expensive at scale. Only log information that is genuinely useful for debugging.

### 2. Never log sensitive or personal data
Do **not** log: usernames, passwords, emails, social security numbers, credit card numbers, or any personally identifiable information (PII).

- Creates serious **legal risk** in the event of a security breach
- Adds complexity to security, data retention, and compliance
- Gives engineers access to personal data they don't need to do their job

---

## Summary

| Best Practice | Key Point |
|---|---|
| Centralized logging | One searchable system for all microservice logs |
| Common structure | Consistent format across all services (logfmt, JSON, XML) |
| Log levels | Filter by severity to reduce noise and speed up debugging |
| Correlation ID | Trace a single request across all microservices |
| Rich context | Include service, host, user ID, timestamp, stack trace, and parameters |
| Data hygiene | Log only what's needed; never log PII |
