# Microservices – Testing Solutions

## Overview
This lecture presents practical alternatives to the complex and costly traditional integration and E2E tests in microservices: **lightweight mocking**, **contract testing**, and **production testing with blue-green deployments**.

---

## Solution 1 – Lightweight Mocking (for Integration Tests)

Instead of building, configuring, and running the real dependency microservice, each team **mocks the other service's interface**.

- **Consumer side (Team A):** Mocks the API of Service B — sets it to return hardcoded responses to expected requests.
- **Provider side (Team B):** Creates mock consumers that send requests to the real Service B and verifies the responses.

**Benefits:**
- Teams are decoupled — one team's broken build doesn't block the other
- No need to spin up full instances of other services and their dependencies

**Critical problem:**
> The mock can go out of sync with the real service. Team B can update their API, update their mock, and all tests pass — but Team A's mock is still based on the old contract. Both test suites pass, but the services can't communicate in production → **outage**.

---

## Solution 2 – Contract Testing (fixes the sync problem)

Contract testing uses a dedicated tool to **keep the mock API consumer and mock API provider in sync** through a shared contract file.

### How it works (synchronous APIs)

```
Team A (Consumer)
  → runs tests against mock Service B
  → all requests + expected responses are recorded into a CONTRACT FILE
  → contract file is shared with Team B

Team B (Provider)
  → replays all recorded requests from the contract against the REAL Service B
  → verifies that real responses match what was recorded in the contract
  → if Service B has multiple consumers → runs all their contracts
```

**Result:** Both teams test independently, but the contract tool guarantees they are always testing against the same agreed interface.

### Extending Contract Testing to Event-Driven Architecture

The same principle applies when microservices communicate through a message broker:

```
Shipping Service (Consumer)
  → tests its ability to parse a payment event using a mock message broker
  → the event format is recorded into a CONTRACT FILE
  → contract file is shared with the Payment Service team

Payment Service (Producer)
  → triggers the function that produces the event
  → contract test verifies the event format & content match the recorded contract
```

**Result:** Neither team needs to run a real message broker or the other service. Yet both have high confidence they can communicate in production.

---

## Solution 3 – Production Testing (alternative to E2E tests)

When setting up a full E2E test environment is too expensive or complex, **test in production** using blue-green deployment + canary testing.

### Blue-Green Deployment

Two identical production environments run simultaneously:

| Environment | Version | Traffic |
|---|---|---|
| **Blue** | Old (current) | 100% of real users |
| **Green** | New (to be released) | 0% initially |

Once the new version is deployed to Green, run automated and even manual tests against it **without affecting real users**.

### Canary Testing

After initial tests on Green pass:

```
Shift a small % of real traffic → Green environment
         ↓
Monitor for performance and functional issues
         ↓
Issue detected?  → redirect all traffic back to Blue (minimal user impact)
No issues?       → gradually shift 100% of traffic to Green
                 → decommission Blue
```

---

## When to Use Each Approach

| Challenge | Recommended Solution |
|---|---|
| Integration tests are complex to set up | Lightweight mocking |
| Mocks go out of sync between teams | Contract testing |
| Event-driven integration is hard to test | Contract testing with mock message broker |
| E2E test environment is too costly | Blue-green deployment + canary testing |

> These alternatives should be used when setting up real microservices in a development/staging environment is too expensive or operationally complex — not as shortcuts when proper testing is feasible.

---

## Summary

```
Traditional E2E tests
   └─→ Too complex/costly → Production testing (Blue-Green + Canary)

Traditional integration tests
   └─→ Too coupled/complex → Lightweight Mocking
           └─→ Mocks go out of sync → Contract Testing
                    └─→ Works for both REST APIs and Event-Driven (async) communication
```
