# Microservices – Testing Strategies & Challenges

## Overview
Before deploying microservices to production, we need confidence through automated testing. This lecture revisits the traditional testing pyramid and examines how it applies to microservices — and where it breaks down.

---

## The Testing Pyramid (Monolith Recap)

```
        ▲
       /E2E\          Fewest tests, highest confidence, slowest & most complex
      /─────\
     / Integ.\        Moderate number, moderate confidence, moderate speed
    /─────────\
   /  Unit     \      Most tests, least confidence per test, fastest & cheapest
  /─────────────\
```

| Level | What it tests | Count | Speed | Confidence |
|---|---|---|---|---|
| **Unit tests** | Individual class or module in isolation | Most | Fastest | Lowest |
| **Integration tests** | Units + external systems (DB, message broker) working together | Moderate | Moderate | Moderate |
| **End-to-end (E2E) tests** | Full system from UI to DB, verifying user journeys | Fewest | Slowest | Highest |

---

## Applying the Pyramid to Microservices

The pyramid is applied at **two levels**:

### Level 1 – Within each microservice
Each team runs its own full testing pyramid (unit → integration → functional) for its own service and database.

### Level 2 – Across microservices (system-wide)
Microservices are treated as units within a larger pyramid:

```
        ▲
      /E2E\         All microservices + DBs + brokers + frontends in one test env
     /──────\
   / Inter-svc\     Pairwise integration tests between communicating services
  / Integration \
 /──────────────\
/  Per-service   \  Each microservice's own internal pyramid
/  Pyramid ×N    \
```

---

## Challenges of This Approach

### Challenge 1 – E2E Tests Are Extremely Costly
- Hard to set up and maintain — requires a duplicate of the production environment
- Unclear **team ownership** — who is responsible for the shared E2E environment?
- If one microservice team breaks their build, the **entire pipeline is blocked** for all teams
- Risk of teams ignoring the tests and releasing anyway → the tests become a liability with no benefit
- In practice: some teams over-invest in E2E tests; others skip them entirely

### Challenge 2 – Integration Tests Create Tight Coupling Between Teams
When Team A (consumer of Service B's API) wants to run integration tests:
- They must build, configure, and run Service B — which they may not know how to do
- Service B may have many dependencies (its own DB, other services) that must also be set up or mocked

When Team B (provider of an API) wants to verify no consumers are broken:
- They must build, configure, and run **all** consumer services to test their changes
- This grows unmanageable as the number of consumers increases

### Challenge 3 – Event-Driven Architecture Makes Integration Tests Even Harder
- A **producer** of events may not know which services consume them → can't run integration tests with unknown consumers
- A **consumer** of events must spin up the producing service AND a message broker just to test event consumption
- If the event format changes silently, consumers won't find out until runtime

---

## Summary

| Testing Level | Challenge in Microservices |
|---|---|
| Unit tests | No significant new challenges — each team owns these |
| Integration tests | Tight coupling between teams; complex setup of dependencies |
| E2E tests | Extremely costly, ownership unclear, blocks all teams on failure |
| Event-driven integration | Producers don't know consumers; consumers must spin up full infra |

> The next lecture will cover **alternative solutions** that companies use to address these challenges.
