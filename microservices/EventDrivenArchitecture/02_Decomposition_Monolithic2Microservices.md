# Microservices – Decomposition Methods

## Overview
This lecture covers **two main techniques** for splitting a monolithic application into microservices that follow the three core principles (Cohesion, SRP, Loose Coupling).

---

## Method 1 – Decomposition by Business Capabilities

**What it is:** Analyze the system from a purely **business perspective**. A business capability is any core capability that provides value to the business or its customers (revenue, marketing, customer experience, etc.).

**How to identify them:** Run a thought experiment — describe the system to a non-technical person and explain what value each capability provides.

**Example – Online Store:**

| Business Capability | Microservice |
|---|---|
| Browse and view products | Product Service |
| Read customer reviews | Review Service |
| Place and manage orders | Order Service |
| Manage stock levels | Inventory Service |
| Ship products to customers | Shipping Service |
| Serve the web interface | Web App Service |

**Why it satisfies the 3 principles:**
- **SRP** → Each service owns exactly one business capability by design.
- **Cohesion** → Changes to a capability only affect its own service (e.g. adding product attributes only touches the Product Service).
- **Loose Coupling** → Most user journeys involve only 1–2 services at a time.

---

## Method 2 – Decomposition by Domain / Subdomain

**What it is:** Take the **developer's perspective** of the system. Decompose it into subdomains — each defined as a *sphere of knowledge, influence, or activity*. More intuitive for engineers.

### Three Types of Subdomains

| Type | Description | Investment Level |
|---|---|---|
| **Core subdomain** | Key differentiator from competitors. Cannot be bought off-the-shelf. Unique to your business. | Highest — best engineers |
| **Supporting subdomain** | Essential to operations and supports core domains, but not a competitive differentiator. | Medium |
| **Generic subdomain** | Not specific to your business. Used by many companies. Often replaceable with off-the-shelf solutions. | Lower — reuse existing tools |

**Example – Online Store:**

- **Core** → Product Catalog *(unique products and experience)*
- **Supporting** → Orders, Inventory, Shipping *(needed to sell, but similar to competitors)*
- **Generic** → Reviews, Payments, Search, Image Compression, Security, Web UI

### Flexibility in Grouping
Once subdomains are identified, you can:
- Assign **one microservice per subdomain**, or
- **Group tightly coupled subdomains** into a single microservice (e.g., Image Service + Image Compression, or Payments + Orders if logic is insufficient to justify separation).

> These groupings are not permanent — as the system evolves, splitting or merging services is straightforward.

---

## Side-by-Side Comparison

| Aspect | By Business Capabilities | By Subdomain |
|---|---|---|
| **Perspective** | Business | Engineering |
| **Granularity** | Coarser (larger services) | Finer (smaller services) |
| **Cohesion & coupling** | Generally better | Generally more coupling risk |
| **Stability** | More stable (business changes slowly) | Less stable (tech evolves faster) |
| **Intuitiveness for engineers** | Less intuitive | More intuitive |

---

## Key Takeaways

- There is **no single right way** to set microservice boundaries — the architecture evolves over time.
- **No decomposition is perfect** — some friction and coupling is inevitable. The goal is to *minimize* it, not eliminate it.
- These techniques are **guidelines, not rules** — good engineering judgment is always required to make the final call.
- Other methods exist (by action, by entity), but business capabilities and subdomain are the most popular and practical.