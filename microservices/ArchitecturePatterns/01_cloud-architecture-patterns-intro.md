# Introduction – Cloud Computing & Software Architecture Patterns

## Overview
Software architecture patterns solve **common non-functional problems** (performance, scalability, availability, reliability) that virtually any system faces — regardless of its business domain. This course focuses on those universal patterns, applied specifically to cloud-based systems.

---

## Types of System Requirements

| Type | Definition | Examples |
|---|---|---|
| **Functional requirements** | What the system does — its features and business logic | Search, checkout, recommendations |
| **Non-functional requirements** | How well the system performs its functions (quality attributes) | Performance, scalability, availability, reliability |
| **System constraints** | Limits on technology or API choices | *(Not covered in this course)* |

### Key insight
Functional requirements are **unique** to each product — they differentiate it from competitors. Non-functional requirements are **shared** across virtually all systems, meaning the same architecture patterns apply regardless of the business domain.

> An online store, an education platform, and a dating app have nothing in common functionally — but all three face the same performance, scalability, and data challenges.

---

## Software Architecture Patterns vs. Design Patterns

| | Design Patterns (OOP) | Software Architecture Patterns |
|---|---|---|
| **Origin** | *Design Patterns* book (1994) | Years of industry experience at scale |
| **Scope** | Single application or library | Multiple independently deployed services |
| **Language** | Object-oriented languages only | Language and implementation agnostic |
| **Solves** | Code organization, reusability, extensibility | Performance, scalability, reliability, data processing, error handling |
| **Example** | Factory, Singleton, Strategy | CQRS, Saga, Event Sourcing, Circuit Breaker |

---

## Cloud Computing as a Foundation Pattern

Cloud computing itself is a general solution to a universal infrastructure problem.

### Benefits

**1. Infrastructure as a Service (IaaS)**
- Instant access to virtually infinite compute, storage, and network capacity
- Pay-as-you-go model removes upfront investment barriers — especially for startups

**2. Multi-Region Deployment**
- Run the system in multiple geographical regions → physically closer to users
- Direct result: lower latency, higher performance, better user experience

**3. Multi-Zone (Availability Zones)**
- Spread instances across isolated zones within a region
- If one zone loses power or connectivity, the system keeps running unaffected

**4. Managed Platform Services**
- Databases, message brokers, load balancers, monitoring, logging, FaaS — available in minutes
- No need to build or maintain this infrastructure from scratch

---

## Cloud Limitations to Address

### 1. Cost Grows with Scale
- Pay-as-you-go is great early on, but monthly bills grow as traffic and data increase
- Architects must now also manage **cost efficiency and profitability** as a quality attribute

### 2. Infrastructure Is Not Under Your Control
- You never own the hardware; it may be old, shared, and running 24/7
- Any server, router, or database instance **can fail at any moment**
- The larger the system, the higher the statistical probability of some component failing

> **Core challenge of cloud architecture:**
> *Building reliable systems using unreliable components.*

This is why failure handling and reliability patterns are a major focus throughout the course.

---

## Summary

| Topic | Key Takeaway |
|---|---|
| Non-functional requirements | Shared across all systems — solved by universal architecture patterns |
| Design patterns vs. architecture patterns | Different scope, different problems — architecture patterns target scale and quality |
| Cloud as a pattern | Solves the universal infrastructure problem — enables IaaS, multi-region, managed services |
| Cloud benefit: multi-region/zone | Higher performance and availability out of the box |
| Cloud limitation: cost | Scale → cost; architects must design for cost efficiency |
| Cloud limitation: unreliable hardware | Systems must be architected to handle failures gracefully |
