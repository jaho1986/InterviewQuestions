# Spring AOP Study Guide

## What are Cross-Cutting Concerns?

A cross-cutting concern is a task that can affect the entire application and should be centralized in one place in the code as much as possible — such as logging, authentication, registration, security, etc.

---

## What is Spring AOP Used For?

Spring AOP provides a way to dynamically add cross-cutting concerns **before**, **after**, or **around** the actual business logic using simple configurations. It also makes it easy to maintain code both now and in the future.

---

## Two Ways to Implement Aspects

- Using the **AspectJ annotation**
- Using **Spring XML configuration**

---

## Difference Between a Regular Concern and a Cross-Cutting Concern

| Concept                  | Description                                                                                         |
|--------------------------|-----------------------------------------------------------------------------------------------------|
| **Concern**              | The behavior we want in a specific module of an application; a functionality that solves a specific business problem |
| **Cross-Cutting Concern** | A concern that spans across multiple modules of an application, such as security or logging         |

---

## Available AOP Implementations

- **AspectJ**
- **Spring AOP**
- **JBoss AOP**

---

## What is an Advice?

An **advice** is the implementation of a cross-cutting concern that you want to apply across other modules of your application.

---

## The 5 Types of Advice

| Type                    | Annotation          | Description                                                                                      |
|-------------------------|---------------------|--------------------------------------------------------------------------------------------------|
| **Before**              | `@Before`           | Executes before a join point, but cannot prevent execution from proceeding (unless it throws an exception) |
| **After Returning**     | `@AfterReturning`   | Executes after a join point completes normally (e.g., a method returns without throwing an exception) |
| **After Throwing**      | `@AfterThrowing`    | Executes if a method exits by throwing an exception                                              |
| **After (Finally)**     | `@After`            | Executes regardless of whether the join point completes normally or throws an exception          |
| **Around**              | `@Around`           | Surrounds a join point (e.g., a method call); the most powerful type of advice                   |

---

## What is a Spring AOP Proxy?

A **proxy** is a widely used design pattern. A proxy looks like any other object but contains special functionality behind the scenes.

Spring AOP is **proxy-based**. An AOP proxy is an object created by the AOP framework to implement aspect contracts at runtime.

By default, Spring AOP uses **JDK dynamic proxies**, which allows any interface (or set of interfaces) to be proxied.

---

## What is an Introduction in Spring AOP?

**Introductions** give aspects the ability to implement interface functionality and choose the implementation class, by declaring which objects will trigger the execution of an aspect. They use the `@DeclareParents` annotation.

```java
@Aspect
public class UsageTracking {

    @DeclareParents(value = "com.xzy.myapp.service.*+", defaultImpl = DefaultUsageTracked.class)
    public static UsageTracked mixin;

    @Before("com.xyz.myapp.SystemArchitecture.businessService() && this(usageTracked)")
    public void recordUsage(UsageTracked usageTracked) {
        usageTracked.incrementUseCount();
    }
}
```

---

## What are Join Points and Pointcuts?

### Join Point
A **join point** is a specific point during program execution, such as the execution of a method or the handling of an exception.  
> In Spring AOP, a join point **always** represents the execution of a method.

### Pointcut
A **pointcut** is an expression that matches join points.

An advice is associated with a pointcut expression and executes at any join point that matches it.

**Example:**

```
execution(* EmployeeManager.getEmployeeById(..))
```

This expression matches the `getEmployeeById()` method in the `EmployeeManager` interface.

> The concept of how join points are matched by pointcut expressions is central to AOP. Spring uses the **AspectJ pointcut expression language** by default.

---

## What is Weaving?

Spring AOP only supports AspectJ pointcuts and allows aspects to use only beans declared in the Spring context.

If you want to use pointcuts **outside the IoC container**, you must use the **AspectJ framework** within your Spring application and apply **Weaving**.

---

## How to Enable `@AspectJ` Support

```xml
<aop:aspectj-autoproxy/>
```