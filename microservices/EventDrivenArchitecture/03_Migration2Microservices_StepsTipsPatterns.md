# Microservices – Migrating from a Monolith

## Overview
This lecture covers **how to execute a real migration** from a legacy monolithic application to microservices: where to start, how to prepare, and how to perform the migration safely.

---

## Step 1 – Choosing the Right Approach

### ❌ Big Bang Approach (avoid this)
Stop all feature development, gather the entire team, and migrate everything at once.

**Why it fails:**
- Too many developers on the same refactoring project creates friction (the same organizational issues you're trying to solve).
- Large, ambiguous projects are hard to estimate — missed deadlines put the migration at risk of being abandoned.
- Halting feature development for months harms the business: PMs have nothing to work on, salespeople have nothing to pitch, and users feel stagnation.

### ✅ Incremental & Continuous Approach (recommended)
Identify and migrate one component at a time, continuously, while the rest of the team keeps shipping features.

---

## Step 2 – Identifying the Best Candidates for Migration

Prioritize components in this order:

| Priority | Candidate | Why |
|---|---|---|
| 1st | **Most frequently changed code** | Constant changes = most merge conflicts and most frequent full-application redeploys. Migrating these gives immediate relief. |
| 2nd | **High scalability requirements** | Components that can't scale independently while inside the monolith. |
| 3rd | **Low technical debt + clean separation** | Easiest to extract with the least risk. |

> Code that nobody touches is not worth migrating — it's not the source of the problem.

---

## Step 3 – Preparing for Migration

Before touching any code, complete these steps in order:

1. **Add test coverage** — Critical. Good tests give confidence that no functionality was broken during refactoring. Without this, the migration risks breaking things and getting delayed.
2. **Define a clear API** — Design a well-thought-out interface for the component before extracting it.
3. **Isolate the component** — Remove interdependencies with the rest of the application so it can stand on its own.

---

## Step 4 – Executing the Migration (Strangler Fig Pattern)

The **Strangler Fig Pattern** (introduced by Martin Fowler) is inspired by a vine that slowly grows over and replaces an old tree without disturbing it.

### How it works:

```
1. Introduce a proxy (Strangler Facade) in front of the monolith
         ↓
2. All requests still pass through to the monolith (no disruption)
         ↓
3. Build and test the new microservice
         ↓
4. Redirect traffic for that specific API to the new microservice
         ↓
5. Monitor performance and functionality
         ↓
6. Remove the old component from the monolith
         ↓
7. Repeat with the next candidate
```

- The **Strangler Facade** is typically implemented as an **API Gateway** — an off-the-shelf component that routes requests based on the target API.
- The cutover is **transparent to users** and minimizes risk.
- The process repeats until the monolith is either empty or contains only stable, never-changing code not worth migrating.

---

## Step 5 – One Critical Tip: Resist the Urge to Refactor

When migrating, **keep the code and tech stack as unchanged as possible**.

- Every additional change is a potential new bug.
- The migration itself is already complex and risky enough.
- Once the microservice is stable and running, *then* you can safely refactor it to use newer technologies.

---

## Benefits of the Incremental Approach

- No hard deadlines — progress is always visible and measurable.
- Business is never disrupted.
- Overruns are measured in **days or weeks**, not months or years.
- Each extracted microservice immediately reduces friction for the teams working on it.

---

## Quick Reference – Full Migration Checklist

- [ ] Identify the best candidate (most changed, high scalability need, low debt)
- [ ] Add test coverage to the component
- [ ] Define a clear API for the component
- [ ] Isolate it from the rest of the monolith
- [ ] Set up the Strangler Facade (API Gateway)
- [ ] Build, test, and deploy the new microservice
- [ ] Redirect traffic to the new microservice
- [ ] Monitor, then remove the old component from the monolith
- [ ] Repeat