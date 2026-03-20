# Deployment Patterns – Blue-Green Deployment

## Overview
**Blue-Green Deployment** eliminates the two main risks of Rolling Deployment (cascading failures and two versions running simultaneously) by maintaining **two complete, isolated environments** — one running the old version, one running the new version — and switching traffic between them instantly.

---

## How It Works

```
                   [ Load Balancer ]
                         │
              ┌──────────┴──────────┐
         [ Blue ]              [ Green ]
       (old version)          (new version)
       ← traffic →              (standby)

Step 1: Deploy new version to Green environment
Step 2: Run tests on Green (no user traffic yet)
Step 3: Switch load balancer → all traffic goes to Green
Step 4: Monitor Green for issues
         ↓
    Issues detected? → Switch back to Blue instantly ✅
    All good?        → Decommission or keep Blue for next cycle
```

---

## Comparison to Rolling Deployment

| Aspect | Rolling Deployment | Blue-Green Deployment |
|---|---|---|
| **Two versions live at once** | ✅ Yes — during the entire rollout | ❌ No — only one version serves traffic at any moment |
| **Cascading failure risk** | ✅ High — failing new instances overload old ones | ❌ None — environments are fully isolated |
| **Rollback speed** | Slow — reverse the upgrade process | Instant — flip the load balancer back to Blue |
| **Extra hardware needed** | ❌ No | ✅ Yes — 2× servers during the release |
| **Cost** | Lower | Higher (temporarily) |

---

## Benefits

| Benefit | Detail |
|---|---|
| **Zero downtime** | Traffic is only switched after the new environment is verified and ready |
| **No cascading failures** | Blue and Green are fully isolated — if Green fails, Blue takes full load immediately |
| **Single version in production** | All users get the same experience at all times (except a brief unnoticeable transition) |
| **Instant rollback** | One load balancer switch → back to Blue → old version serves all traffic again |

---

## Downsides

| Drawback | Detail |
|---|---|
| **2× server cost during release** | Must provision a full duplicate environment for the duration of the deployment |
| **Startup time** | Must wait for all Green servers to start up and pass health checks before switching traffic |

> The additional cost is temporary — only incurred during the release window. For most companies, this trade-off is worth the safety guarantee, making Blue-Green one of the most popular production deployment patterns.

---

## Summary

| Aspect | Key Point |
|---|---|
| **Blue environment** | Old version — stays fully live throughout the entire release |
| **Green environment** | New version — deployed, tested, then receives traffic |
| **Traffic switch** | Instant — via load balancer configuration |
| **Rollback** | Instant — switch load balancer back to Blue |
| **Main advantage over Rolling** | Full isolation + instant rollback + single version in production |
| **Main disadvantage** | Temporary 2× infrastructure cost |
