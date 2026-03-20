# Deployment Patterns – Rolling Deployment

## Overview
**Rolling Deployment** upgrades production servers to a new software version **one at a time** — with no downtime and no additional hardware cost. Instead of replacing all instances at once, the load balancer gradually shifts traffic away from old instances, upgrades them, and brings them back.

---

## The Problem

Traditional deployments require a **maintenance window** — taking all servers offline, upgrading them, and bringing them back up. This approach has critical limitations:
- Services must be unavailable during the upgrade
- If the new version has issues → rollback takes time → prolonged downtime
- **Not viable** for systems with constant high traffic or emergency releases

---

## How Rolling Deployment Works

```
[ Load Balancer ]
  ↙    ↓    ↘
v1   v1   v1   (all servers running old version)

Step 1: Stop traffic to Server 1 → deploy v2 → run tests → add back
[ Load Balancer ]
  ↙    ↓    ↘
v2   v1   v1

Step 2: Repeat for Server 2
[ Load Balancer ]
  ↙    ↓    ↘
v2   v2   v1

Step 3: Repeat until all servers are upgraded
[ Load Balancer ]
  ↙    ↓    ↘
v2   v2   v2
```

**Rollback:** If issues are detected, reverse the same process — deploy the old version back one server at a time.

---

## Benefits

| Benefit | Detail |
|---|---|
| **Zero downtime** | Users are never without service — traffic is always being served by healthy instances |
| **Cost-effective** | No additional hardware needed — upgrades happen in place |
| **Gradual rollout** | New version deployed incrementally → safer than big-bang releases |
| **Fast rollback** | If problems appear, reverse the process quickly and transparently |

---

## Downsides

### 1. Risk of Cascading Failures
If the newly deployed instances (e.g. 20% of servers) start failing, the load balancer redirects all traffic to the remaining old-version instances. This puts **extra load on already healthy servers** → they may also fail → entire service goes down.

```
20% servers on v2 fail
         ↓
Load balancer sends their traffic to remaining v1 servers
         ↓
v1 servers now overloaded → start failing too
         ↓
No healthy servers left → full outage ❌
```

### 2. Two Versions Running Simultaneously
During the rollout, **v1 and v2 run side by side**. This is acceptable if:
- ✅ The new version is **backward-compatible** with the old one

But it's problematic if:
- ❌ The **API has changed drastically** between versions — mixed-version traffic can cause unexpected behavior

---

## Summary

| Aspect | Key Point |
|---|---|
| **Core mechanic** | Upgrade servers one at a time via the load balancer |
| **Downtime** | None |
| **Extra hardware** | None required |
| **Rollback** | Reverse the same process — fast and user-transparent |
| **Risk 1** | Cascading failures if new instances fail under load |
| **Risk 2** | Two versions running simultaneously may cause compatibility issues |
| **Popularity** | Very widely used due to its simplicity and cost-effectiveness |

> The next lecture covers **Blue-Green Deployment** — an alternative that addresses the cascading failure risk and the two-versions problem.
