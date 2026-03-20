# Deployment Patterns – Canary Release & A/B Deployment

## Overview
**Canary Release** and **A/B Deployment** are closely related patterns that both route a small subset of traffic to a different software version. They borrow elements from Rolling and Blue-Green deployments — but serve **different purposes**: one is about safe releases, the other is about product experimentation.

---

## Canary Release

### How It Works

```
[ Load Balancer ]
      ↙         ↘
[ v1 servers ]  [ Canary: v2 ]  ← small subset (~5-10%)
 (most traffic)   (limited traffic: internal users / beta testers)
      ↓
Monitor & compare performance for hours or days
      ↓
  No issues? → Roll out v2 to all servers (e.g. via Rolling Deployment)
  Issues?    → Roll back the Canary servers to v1
```

### Key Characteristics
- Deploy new version to a **small subset of existing servers**
- Direct **specific users** (internal or beta testers) to Canary — or just a small % of normal traffic
- **Monitor and compare** Canary vs. old version in real time for hours or days
- Only proceed with full rollout once confident there are no degradations

### Why It's the Safest Deployment Pattern
- Long observation period before full rollout → maximum confidence before risk exposure
- If something goes wrong → only internal/beta users are affected (higher tolerance, better bug reporting)
- No cascading failures: only a small portion of servers run the new version initially

### Main Challenge
Setting **clear, automated success criteria** for the monitoring phase. Without automation, engineers must manually watch dozens of dashboards for hours — which is not scalable.

---

## A/B Deployment (A/B Testing)

### How It Works

```
[ Load Balancer ]
      ↙           ↘
[ Version A ]   [ Version B ]   ← experimental version
 (control group)  (test group: real users, unaware of experiment)
      ↓
Collect metrics for the experiment duration
      ↓
Conclude experiment → remove Version B → analyze results → inform product roadmap
```

### Key Characteristics
- Same mechanics as Canary, but **different goal**: test a feature on real users in production
- Users in the experiment group are **unaware they are being tested** → genuine behavior data
- After the experiment ends, the **experimental version is removed** (not promoted)
- Results are analyzed by engineers, analysts, or data scientists to inform future decisions

---

## Canary Release vs. A/B Deployment

| Aspect | Canary Release | A/B Deployment |
|---|---|---|
| **Purpose** | Safely release a new version to all servers | Test a new feature on a subset of users in production |
| **Target users** | Internal users / beta testers (preferred) | Real users — unaware of the experiment |
| **End result** | New version rolled out to all servers | Experimental version rolled back; data analyzed |
| **Duration** | Hours to days of monitoring | Defined experiment window (use case dependent) |
| **Decision** | Proceed or roll back the release | Adopt, iterate, or discard the feature |

---

## How Both Compare to Other Deployment Patterns

| Pattern | Key Trade-off | Best For |
|---|---|---|
| **Rolling** | Fast, cheap — but cascading failure risk + two versions live | Standard releases with low risk tolerance for cost |
| **Blue-Green** | Safe, instant rollback — but 2× hardware cost | High-stakes releases requiring instant rollback |
| **Canary** | Safest — but requires monitoring automation + longer rollout | Any release where safety is the top priority |
| **A/B** | Real user data — but experimental feature is temporary | Product/feature experimentation in production |

---

## Summary

| Aspect | Canary Release | A/B Deployment |
|---|---|---|
| **Traffic routing** | Small % to new version | Small % to experimental version |
| **User awareness** | Not required | Must be unaware (for genuine data) |
| **Monitoring** | Performance & reliability metrics | Business / product metrics |
| **Outcome** | Full rollout or rollback | Feature adoption decision |
| **Version after experiment** | v2 becomes the standard | Experimental version removed |
