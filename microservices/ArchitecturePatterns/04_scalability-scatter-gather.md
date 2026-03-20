# Scalability Patterns – Scatter-Gather

## Overview
The **Scatter-Gather** pattern dispatches a single request to **multiple workers simultaneously**, collects all their responses, aggregates them into one result, and returns it to the sender — all in parallel. This enables high scalability and rich results without the user experiencing any additional latency.

---

## Pattern Structure

```
           Sender (client)
                ↓
         [ Dispatcher ]
        /      |       \
   Worker1  Worker2  Worker3  ...  WorkerN
        \      |       /
         [ Aggregator ]
                ↓
           Single Response
```

---

## How It Differs from Load Balancing

| | Load Balancing | Scatter-Gather |
|---|---|---|
| **Request routing** | One request → **one** worker | One request → **all** workers |
| **Workers** | Identical copies of the same app | Can be different — different data, different services, or external services |
| **Result** | Single worker response | Aggregated response from all workers |
| **Use case** | High traffic distribution | Parallel search, aggregation, comparison |

---

## Three Types of Workers

| Type | Example |
|---|---|
| **Same service, different data** | Search workers each searching a different subset of documents |
| **Different internal services** | Different microservices providing different functionality |
| **External services** | Partner companies (hotels, suppliers) responding to a query |

> **Key principle:** Each request sent to a different worker is **completely independent** of the others — enabling true parallelism. No matter how many workers there are, the user experiences a constant response time.

---

## Real-World Use Cases

### 1. Search Engine
- User submits a search query
- Dispatcher fans the query out to multiple **internal search workers**, each responsible for a different subset of the data (documents, images, videos)
- Each worker searches its own subset and returns results
- Aggregator combines, ranks, and returns a single unified results page

### 2. Hotel/Travel Booking
- User searches for hotels in a city for given dates
- Dispatcher fans the request out to **dozens of external hotel systems**
- Each hotel responds with availability and pricing
- Aggregator sorts by price, rating, or any other criteria and returns the list

---

## Three Key Considerations

### 1. Timeout — Set an Upper Limit
Workers (especially external ones) can become unavailable at any moment due to network issues, outages, or rolling deployments.

**Solution:** The dispatcher sets a **maximum wait time**. When the timeout expires, it aggregates only the results already received and ignores the rest — the user is not blocked by slow or unavailable workers.

### 2. Decoupling the Dispatcher from Workers
In a tightly coupled design, the dispatcher must know the number and addresses of all available workers at all times.

**Solution:** Use a **message broker** between the dispatcher and workers:
```
Dispatcher → publishes query to broker topic
Workers (subscribed) → pick up and process independently
Workers → publish results to a results topic
Dispatcher → subscribes to results topic, aggregates on timeout
```
This makes the communication **asynchronous** and removes the need for the dispatcher to track workers directly.

### 3. Immediate vs. Long-Running Results
| Scenario | Approach |
|---|---|
| **Fast results** (ms to ~1 second) | Single dispatcher + aggregator service works fine |
| **Long-running reports** (minutes to hours) | Separate dispatcher from aggregator into two services |

**For long-running reports:**
1. Dispatcher generates a **unique report ID** and returns it to the user immediately
2. Workers receive the request + report ID and process their parts
3. Each worker publishes results with the same report ID to the aggregation service
4. Aggregation service stores the final result using the report ID as a key
5. User polls the aggregation service with the report ID to check status or retrieve the result

---

## Summary

| Aspect | Key Point |
|---|---|
| **Core mechanic** | One request → all workers in parallel → aggregated response |
| **Scalability** | More workers = more data processed; user latency stays constant |
| **Workers** | Can be internal (same or different services) or external |
| **Timeout** | Always set a max wait time — don't let slow workers block the user |
| **Decoupling** | Use a message broker to remove direct dependency on workers |
| **Long tasks** | Separate dispatcher and aggregator + use a unique ID for tracking |
