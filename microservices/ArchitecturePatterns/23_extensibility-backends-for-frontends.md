# Extensibility Patterns – Backends for Frontends (BFF)

## Overview
The **Backends for Frontends (BFF)** pattern splits a monolithic backend into **separate backend services — one per frontend type**. Each backend is optimized for the specific needs of its frontend, keeping codebases small, teams autonomous, and user experiences optimal.

---

## The Problem: One Backend for All Frontends

As a system grows, a single backend must serve increasingly different frontend clients:

| Frontend | Unique needs |
|---|---|
| **Desktop browser** | Larger screens → more data per request; no battery concerns |
| **Mobile (iOS/Android)** | Smaller screens → less data; battery-sensitive; camera, GPS, barcode scanning |
| **Smart TV, console, watch** | Platform-specific interactions and constraints |

### Organizational Problem
Two separate teams — frontend and backend — must coordinate for every feature:
- Frontend team proposes a feature
- Backend team reviews, approves, designs the API
- Both teams must release simultaneously
- Backend engineers tend to build shared/reusable APIs → forces compromises that give every client a suboptimal experience

### Technical Problem
The backend becomes a large, complex service handling features for all device types — some shared, many unique — making it hard to maintain and evolve.

---

## The Solution: Backends for Frontends

Split the backend into **separate services**, each dedicated to one frontend type.

```
[ Desktop Browser ] ←→ [ Backend for Desktop ]
[ Mobile App ]      ←→ [ Backend for Mobile  ]   →  [ Core Microservices ]
[ Smart TV ]        ←→ [ Backend for Smart TV]
```

### Benefits

| Benefit | Detail |
|---|---|
| **Optimized UX per device** | Each backend is fully tailored to its frontend's capabilities and constraints |
| **Smaller, simpler codebases** | No shared device-specific code — each backend only contains what it needs |
| **Full-stack team ownership** | One team owns both the frontend and its backend — no cross-team coordination needed |
| **Independent deployment** | Changes to one frontend/backend pair don't affect others |
| **Right-sized cloud hardware** | Each backend can use hardware optimized for its specific workload |

---

## Two Challenges to Address

### 1. Shared Logic Across Backends
Some functionality (e.g. login, checkout) is needed by all frontends. Options:

| Approach | When to use |
|---|---|
| **Shared library** | Small, rarely-changing logic only — carries coupling and ownership risks |
| **Separate shared service** | Preferred for significant shared logic — clear scope, defined API, explicit team ownership |

### 2. Right Granularity
How many backends do you actually need?

**Rule:** Separate backends are only worth it if the features and code paths are **significantly different** between clients.

| Example | Decision |
|---|---|
| Android vs. iOS with very different UX | ✅ Separate backends |
| Android vs. iOS with nearly identical UX | ❌ One shared mobile backend |
| Desktop app vs. desktop browser with similar needs | ❌ One shared desktop backend |

---

## Cloud Implementation Tips

- Replace one large VM with **multiple smaller, cheaper VMs** per backend
- Use the **cloud load balancer** to route requests to the right backend based on:
  - URL path or query parameters
  - **`User-Agent` HTTP header** (identifies device/platform)

---

## Summary

| Aspect | Key Point |
|---|---|
| **Problem** | One monolithic backend can't optimally serve all frontend types without compromise |
| **Solution** | One dedicated backend per frontend type |
| **Team model** | Full-stack team owns each frontend + backend pair |
| **Shared logic** | Extract into a separate shared service (preferred) or shared library (simple cases) |
| **Granularity** | Split only when frontends have meaningfully different features or code paths |
| **Cloud routing** | Use load balancer + User-Agent header or URL rules to route to the right backend |
