# Microservices Deployment – Function as a Service (FaaS / Serverless)

## Overview
Function as a Service (FaaS) is a **serverless cloud offering** that eliminates infrastructure management for microservices that handle rare or highly irregular traffic. You provide only the trigger and the logic — the cloud provider handles everything else.

---

## The Problem It Solves

Traditional VM-based deployments charge for running time regardless of traffic. This is wasteful for:

### Scenario 1 – Infrequent but Spiky Traffic
A live event ticket reservation service:
- Gets **zero traffic** most of the month
- Receives a **massive spike** within 30–60 minutes of opening reservations
- Then returns to near-zero traffic until the next event

Running a VM + load balancer + autoscaling policies for a service that is idle 99% of the time is expensive and operationally costly.

### Scenario 2 – Extremely Rare Events
A monthly/quarterly report generation service for an ad company:
- Handles ~1,000 requests *per quarter* (one per customer)
- Requires a full microservice runtime, build/deploy pipeline, and boilerplate request-handling code just to process these rare events

---

## How FaaS Works

You provide the cloud provider with only two things:
1. The **trigger** — the type of request or event to listen for
2. The **logic** — the code to execute when triggered

The cloud provider handles:
- Packaging and deploying your code on demand
- Executing it only when the trigger fires
- **Horizontal scaling automatically** during traffic spikes
- No need to configure load balancers or autoscaling policies

**Pricing model:** Based on number of requests + execution time + memory used per request. **You pay nothing when idle.**

---

## Benefits

| Benefit | Detail |
|---|---|
| **Cost efficiency (right workloads)** | No cost during idle time — perfect for rare or seasonal traffic |
| **Automatic scaling** | Cloud provider handles traffic spikes with no manual configuration |
| **Reduced development overhead** | No build/package/deploy pipeline to maintain; no boilerplate HTTP/event handling code |

---

## Drawbacks

| Drawback | Detail |
|---|---|
| **Cost can explode** | If traffic grows significantly or business logic becomes more complex, FaaS can become more expensive than a VM |
| **Unpredictable performance** | Cold starts and multi-tenant execution make latency inconsistent — not suitable for latency-sensitive workloads |
| **Lowest security** | Runs in a multi-tenant environment AND exposes your source code to the cloud provider |

---

## When to Use FaaS vs. Cloud VMs

| Scenario | Best Option |
|---|---|
| Rare events, low traffic (monthly reports, infrequent triggers) | ✅ FaaS |
| Highly seasonal spikes with long idle periods | ✅ FaaS |
| Steady, high-volume, or growing traffic | ✅ Cloud VM (multi-tenant or dedicated) |
| Latency-sensitive workloads | ✅ Dedicated VM or host |
| Regulated industries requiring strict security | ✅ Dedicated instances or hosts |

---

## Full Deployment Options Summary

| Option | Cost | Security | Performance | Best For |
|---|---|---|---|---|
| **Multi-tenant VMs** | Low | ⚠️ Shared | ⚠️ Noisy neighbor risk | Most standard workloads |
| **Dedicated instances** | Medium | ✅ Org-only | ✅ Better | Regulated industries |
| **Dedicated hosts** | High | ✅ Full isolation | ✅ Maximum | Latency-critical systems |
| **FaaS (Serverless)** | Lowest* / Highest** | ❌ Least secure | ❌ Unpredictable | Rare/seasonal events only |

> \* If used correctly (rare/seasonal workloads)
> \*\* If used incorrectly (high or growing traffic)
