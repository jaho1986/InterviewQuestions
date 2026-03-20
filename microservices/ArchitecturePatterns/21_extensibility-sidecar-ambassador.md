# Extensibility Patterns – Sidecar & Ambassador

## Overview
The **Sidecar** pattern extends a service's functionality by running additional logic as a **separate process on the same host** — without modifying the core service code and without requiring reimplementation per programming language.

---

## The Problem

Every service has a core function, but also needs auxiliary capabilities shared across many services:

| Auxiliary capability | Examples |
|---|---|
| Metrics collection | Send performance data to a monitoring service |
| Logging | Forward log events to a distributed logging service |
| Service discovery | Query a registry for up-to-date addresses of other services |
| Configuration | Pull and parse config files dynamically without restarting |

### Why a Shared Library Doesn't Scale
In a polyglot microservices environment (Java, Python, Go, etc.):
- The same library must be **reimplemented for every language**
- Different implementations can be **inconsistent or buggy**
- Updates require changes across **every codebase**

### Why a Separate Service Is Overkill
Provisioning and managing a fully independent service for auxiliary functions introduces unnecessary infrastructure overhead and latency.

---

## The Sidecar Pattern

Run the auxiliary functionality as a **separate process or container on the same host** as the main service.

```
┌──────────────────────────────────┐
│           Same Host              │
│  ┌──────────────┐  ┌───────────┐ │
│  │  Core Service│  │  Sidecar  │ │
│  │  (business   │  │  (metrics,│ │
│  │   logic)     │  │  logging, │ │
│  └──────────────┘  │  config)  │ │
│                    └───────────┘ │
│    Shared: file system, CPU, memory, network  │
└──────────────────────────────────┘
```

### Key Benefits

| Benefit | Detail |
|---|---|
| **Language agnostic** | Sidecar is implemented once and reused by any service regardless of language |
| **Isolation** | Sidecar runs as a separate process — bugs in the sidecar don't crash the core service |
| **Shared resources** | Same host → direct access to file system, CPU, memory — no network overhead |
| **Fast communication** | Inter-process communication on the same host is much faster than network calls |
| **Independent updates** | Update the sidecar across all services without touching core business logic |
| **Focused testing** | Core service teams only test business logic changes — sidecar is tested separately |

---

## The Ambassador Pattern (Special Sidecar)

The **Ambassador** is a sidecar specifically responsible for **all outbound network communication** on behalf of the core service — acting as a co-located proxy.

```
Core Service  →  Ambassador Sidecar  →  Other Services / External APIs
```

### What the Ambassador Handles
- **Retries and disconnections**
- **Authentication**
- **Request routing**
- **Protocol-specific logic** (different API versions, communication protocols)

### Additional Benefit: Distributed Tracing
Since all outbound communication passes through the Ambassador, every service's network traffic can be **instrumented in one place**. This makes it straightforward to collect distributed tracing data across multiple services and trace a complete transaction end to end.

---

## Sidecar vs. Ambassador

| | Sidecar | Ambassador |
|---|---|---|
| **Purpose** | Extend the service with auxiliary capabilities | Handle all outbound network communication |
| **Typical functions** | Metrics, logging, config, discovery | Retries, auth, routing, protocol handling |
| **Analogy** | Extra passenger/luggage on a motorcycle sidecar | A proxy diplomat handling all external communications |

---

## Summary

| Aspect | Key Point |
|---|---|
| **Core idea** | Run auxiliary functionality as a separate co-located process |
| **Why not a library** | Libraries require reimplementation per language; updates are fragmented |
| **Why not a separate service** | Too much overhead; network latency for simple auxiliary tasks |
| **Sidecar advantages** | Language agnostic, isolated, shares resources, independently updatable |
| **Ambassador** | Special sidecar that offloads all network complexity from the core service |
| **Distributed tracing** | Ambassador enables easy instrumentation of all inter-service communication |
