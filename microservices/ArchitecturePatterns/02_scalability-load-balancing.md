# Scalability Patterns – Load Balancing

## Overview
Load balancing is one of the most fundamental and widely used scalability patterns in cloud computing. It distributes incoming requests across multiple worker instances, allowing a system to scale horizontally to handle virtually unlimited traffic.

---

## The Problem

A single server has a finite amount of CPU, memory, and network capacity. When traffic exceeds that capacity, the server either crashes or degrades in performance. Upgrading to a more powerful VM only delays the problem.

**Solution:** Place a **dispatcher** between clients and workers that routes each request to only one available worker — enabling horizontal scaling.

---

## How Load Balancing Works

```
Clients (web/mobile)
         ↓
  [ Load Balancer / Dispatcher ]
         ↓
┌────────┬────────┬────────┐
│  App   │  App   │  App   │
│Instance│Instance│Instance│
│   1    │   2    │   3    │
└────────┴────────┴────────┘
```

- As traffic grows → add more workers behind the dispatcher
- Each service in a microservices architecture can be independently scaled with its own load balancer

---

## Two Ways to Implement Load Balancing

### 1. Cloud Load Balancing Service
A fully managed service that accepts incoming requests and routes them to backend servers.

- Runs as multiple instances (one per availability zone) for high availability
- Automatically scales itself to avoid becoming a bottleneck or single point of failure
- Used for **both external traffic** (from clients) **and internal traffic** (between services)

### 2. Message Broker / Distributed Queue
Publishers send messages to the broker; a pool of consumer workers reads and processes them.

- Scales consumers up or down based on message volume
- **Only suitable when:** communication is **one-directional and asynchronous** (publisher doesn't need a response)
- Used **internally only** between services — not for external client requests

| | Cloud Load Balancer | Message Broker |
|---|---|---|
| **Direction** | Request-Response | One-way (async) |
| **Use** | External + internal | Internal only |
| **Best for** | HTTP traffic, user-facing APIs | Event-driven, async workloads |

---

## Routing Algorithms

The algorithm choice depends on whether your application is **stateless** or **stateful**.

### 1. Round Robin (Default)
Routes each request sequentially to the next available server.

- ✅ Simple and effective
- ✅ Works well for **stateless** applications (any server can handle any request independently)
- ❌ Fails when session state is maintained on the server (e.g. user auth, large file uploads)

### 2. Sticky Session (Session Affinity)
Routes all requests from the same client to the same server.

- Implemented via a **cookie on the client device** or the client's **IP address**
- ✅ Works well for **short-lived sessions** where server-side state is needed
- ❌ Can create an uneven load if some clients have very long sessions

### 3. Least Connections
Routes new requests to the server with the fewest active connections.

- ✅ Best for **long-lived connections** (SQL, LDAP, file uploads)
- Prevents one server from getting stuck with a disproportionate share of heavy sessions

### Algorithm Selection Guide

| Scenario | Best Algorithm |
|---|---|
| Stateless application (REST APIs) | Round Robin |
| Short sessions with server-side state | Sticky Session |
| Long-lived or heavy connections | Least Connections |

---

## Load Balancing + Auto Scaling

Cloud agents on each server continuously collect metrics (CPU, memory, network traffic). These metrics drive **auto scaling policies** that dynamically adjust the number of server instances.

```
Traffic increases → metrics spike
        ↓
Auto scaling policy triggers
        ↓
New instances are added
        ↓
Load balancer automatically routes traffic to new instances
        ↓
Traffic decreases → instances are removed → costs decrease
```

> This combination enables the system to **scale up automatically during peak traffic** and **scale down during quiet periods to save costs** — with no manual intervention.

---

## Summary

| Concept | Key Point |
|---|---|
| Load balancer role | Dispatcher that routes each request to exactly one worker |
| Cloud load balancer | Managed, scalable, HA — for external and internal traffic |
| Message broker as LB | For async, one-directional internal communication only |
| Round Robin | Default — stateless apps only |
| Sticky Session | Short sessions with server-side state |
| Least Connections | Long-lived or resource-heavy connections |
| Auto Scaling + LB | Dynamic, cost-efficient horizontal scaling |
