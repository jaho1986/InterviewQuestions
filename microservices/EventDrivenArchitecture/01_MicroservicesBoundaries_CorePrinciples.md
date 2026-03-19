# Microservices Architecture – Core Boundary Principles

When defining **boundaries between microservices**, three key design principles help ensure that each service is maintainable, scalable, and independent.

- Cohesion  
- Single Responsibility Principle  
- Loose Coupling  

---

## 1. Cohesion

**Cohesion** means that all the responsibilities inside a microservice are **closely related and focused on the same domain or business capability**.

A highly cohesive microservice groups together functionality that belongs to the same business concept.

### Example

Imagine an e-commerce system.

A **User Service** should include things like:

- User registration  
- User profile management  
- Authentication data  

But it **should not include**:

- Payment processing  
- Order management  

Those belong to different domains.

### Why Cohesion Matters

- Makes services easier to understand  
- Reduces complexity  
- Improves maintainability  

High cohesion means the service **does one type of work very well**.

---

## 2. Single Responsibility Principle (SRP)

The **Single Responsibility Principle (SRP)** states:

> A component should have only one reason to change.

In microservices, this means that **each service should represent one business responsibility**.

This principle is widely known from the work of **Robert C. Martin (Uncle Bob)**.

### Example

#### Bad Design

An `OrderService` that manages:

- Orders  
- Payments  
- Shipping  
- Invoices  

#### Good Design

Separate services:

- **Order Service** → manages orders  
- **Payment Service** → processes payments  
- **Shipping Service** → handles shipment logistics  
- **Invoice Service** → generates invoices  

### Why SRP Matters

- Changes in one business rule affect only one service  
- Redces deployment risk  
- Makes teams work independently  

---

## 3. Loose Coupling

**Loose coupling** means that microservices **depend on each other as little as possible**.

A service should work **independently** and communicate through **well-defined interfaces**, usually APIs or events.

### Common Communication Patterns

- REST APIs  
- Messaging (Kafka, RabbitMQ)  
- Event-driven architecture  

### Example

#### Bad Coupling

Service A directly accesses **Service B’s database**.

#### Good Coupling

Service A communicates with Service B through:

- an API
- an event/message

### Benefits

- Services can be **deployed independently**
- Easier to scale
- Failures are isolated

---

## How the Three Principles Work Together

| Principle | Focus | Result |
|---|---|---|
| Cohesion | Group related functionality | Clear domain boundaries |
| Single Responsibility | One business capability per service | Easier changes |
| Loose Coupling | Minimize dependencies | Independent deployment |

When these principles are applied correctly, microservices become:

- Independent  
- Easier to maintain  
- Scalable  
- Aligned with business domains  

---

## Key Rule for Microservices

> A microservice should represent **one business capability**, contain **related functionality**, and interact with other services **only through well-defined interfaces**.