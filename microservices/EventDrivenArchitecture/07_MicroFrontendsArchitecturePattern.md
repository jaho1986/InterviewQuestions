# Microservices Best Practices – Micro-Frontends

## Overview
Even with a well-designed microservices backend, a **monolithic frontend** can become the new bottleneck. The **Micro-Frontends** pattern solves this by applying the same decomposition principles from microservices to the frontend.

---

## The Problem: Monolithic Frontend

Imagine an online learning platform with a fully microserviced backend (Course Discovery, Recommendations, Enrollment, User Profile, etc.), but a **single frontend team** maintaining one unified codebase.

### Organizational Problems
- Every backend team depends on the one frontend team to ship UI features → **the frontend team becomes a bottleneck**.
- The frontend team must constantly learn the business domain and APIs of every backend team.
- Backend teams lose their independence — they can't ship a full feature end-to-end without waiting on frontend.

### Technical Problems
- The frontend codebase grows large and hard to reason about.
- Tests take longer as the codebase grows.
- **Any new UI feature requires a full rebuild, retest, and redeployment** of the entire frontend.

> These are the exact same problems that motivated the migration to microservices on the backend — now appearing again on the frontend.

---

## The Solution: Micro-Frontends Pattern

Split the monolithic web app into **multiple independent frontend modules**, each acting as a standalone single-page application (SPA).

### Key Characteristics
- Split by **business capability or domain** (just like microservices).
- Usually **one page = one micro-frontend**, but multiple can coexist on the same page.
- Each micro-frontend is **fully decoupled** from the others.
- Each knows how to **load, mount, and unmount** itself in the browser's DOM.
- Each can be loaded **standalone in the browser** for testing purposes.
- Owned by a **full-stack team** with end-to-end domain knowledge.

### Important Clarifications
> **Micro-frontends ≠ a framework or library.** It is an architectural pattern that many frameworks support but none are required.

> **Micro-frontends ≠ shared UI components.** A button or search bar is a reusable component. A micro-frontend is a complete mini-application with its own business functionality.

---

## How It Works: The Container Application

All micro-frontends are **assembled at runtime** by a **container application**.

### Container Application responsibilities:
- Renders common elements: header, footer.
- Handles **authentication** and stores tokens.
- Manages **shared libraries**.
- Tells each micro-frontend **when and where to render** on the page.

### Example Flow (Online Learning Platform)

```
User requests home page
        ↓
Container app is sent to the browser
        ↓
Container handles authentication
        ↓
Container renders header + footer
        ↓
Container loads:
  ├── Course Discovery micro-frontend  →  calls Course Discovery Service
  └── Recommendations micro-frontend  →  calls Recommendations Service
        ↓
User navigates to Profile page
        ↓
Course Discovery + Recommendations unmount
        ↓
User Profile micro-frontend mounts  →  calls User Profile Service
```

Each micro-frontend fetches its own data from its own backend service and renders itself independently.

---

## Benefits

| Benefit | Detail |
|---|---|
| Smaller, manageable codebases | Each micro-frontend has its own focused scope |
| Full team end-to-end ownership | Backend + frontend of a domain owned by one team |
| Independent releases | Each micro-frontend has its own CI/CD pipeline and deploy schedule |
| Faster testing | Smaller scope = faster, more isolated tests |
| No frontend bottleneck | Teams ship features without waiting on a central frontend team |

---

## Best Practices

### 1. Load at runtime, not at build time
Micro-frontends must be **runtime dependencies** of the container app, not compile-time dependencies. If they are bundled together at build time, you still effectively have a monolithic frontend — just with separated source code.

> This mirrors the backend principle: splitting a monolith into modules/libraries is not the same as splitting it into microservices.

### 2. Never share state between micro-frontends
Shared browser state between micro-frontends is equivalent to microservices sharing a database — a known anti-pattern.

If micro-frontends need to communicate, use one of these approaches:
- **Custom browser events**
- **Callbacks**
- **The browser's address bar (URL)**

---

## Summary

| Monolithic Frontend | Micro-Frontends |
|---|---|
| One team owns all UI | Each team owns its UI domain end-to-end |
| All teams depend on frontend team | Teams ship independently |
| Full rebuild/retest/redeploy for any change | Independent CI/CD per micro-frontend |
| Large, hard-to-maintain codebase | Small, focused codebases |
| Frontend team must learn all domains | Each team is expert in its own domain |