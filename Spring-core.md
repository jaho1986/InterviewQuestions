# Spring Core Study Guide

## What is Spring?

Spring is a framework used to build Java applications with the goal of achieving **low coupling** between components by implementing dependency injection.

---

## Spring Features

- Lightweight
- Uses dependency injection
- Manages the lifecycle of beans
- Supports transactions

---

## Advantages of Using Spring

- Reduces dependencies between application components
- Facilitates unit testing due to dependency injection
- Modular — no need to load unused dependencies in a project
- Compatible with most Java EE features

---

## What is Dependency Injection?

Dependency injection is the mechanism by which properties are injected into objects, handling the initialization of all objects within the system — including when objects depend on other objects (i.e., it assigns a reference from one object to another).

**Example:**  
If class `A` depends on class `B`, dependency injection initializes `A`, initializes `B`, and assigns a reference of `B` to `A` (meaning `B` has been injected into `A`).

---

## How is Dependency Injection Implemented in Spring?

You can use either **Spring XML** or **annotations**.

### Types of Dependency Injection

- Constructor injection
- Getter and setter injection
- Interface injection

---

## Important Spring Modules

| Module               | Purpose                              |
|----------------------|--------------------------------------|
| Spring Core          | Core container functionality         |
| Spring Beans         | Bean factory and lifecycle           |
| Spring Context       | Application context                  |
| Spring AOP           | Aspect-oriented programming          |
| Spring JDBC          | JDBC abstraction layer               |
| Spring ORM           | ORM integration (Hibernate, JPA)     |
| Spring JMS           | Java Message Service                 |
| Spring Transactions  | Transaction management               |
| Spring Web           | Web application support              |
| Spring Test          | Testing support                      |

---

## What is Aspect-Oriented Programming (AOP)?

AOP is a programming paradigm intended to remove dependencies on tasks that are common across different classes (cross-cutting concerns), facilitating decoupling.

**Examples of cross-cutting concerns:** verifying that a user is authenticated, checking system permissions, logging, etc.

---

## What is IoC (Inversion of Control)?

IoC is a mechanism that manages object instantiation instead of creating objects inside classes using the `new` operator.

---

## What is a Spring Bean?

A Spring Bean is any regular Java class that is initialized by the Spring IoC container, which also manages its lifecycle.

---

## Ways to Configure a Class as a Spring Bean

**XML-based configuration:**

```xml
<bean name="myBean" class="com.journaldev.spring.beans.MyBean" />
```

**Java-based configuration:**

```java
@Configuration
@ComponentScan(value = "com.journaldev.spring.main")
public class MyConfiguration {

    @Bean
    public MyService getService() {
        return new MyService();
    }
}
```

---

## Spring Bean Scopes

| Scope          | Description                                                                 |
|----------------|-----------------------------------------------------------------------------|
| `singleton`    | Only one instance of the bean per container (default)                       |
| `prototype`    | A new instance is created every time the bean is requested                  |
| `request`      | Same as prototype, but intended for web applications (per HTTP request)     |
| `session`      | A new bean is created for each HTTP session                                 |
| `global-session` | Used for global session beans in portlet applications                     |

---

## Spring Bean Lifecycle

Spring initializes all beans and injects their dependencies when the application context starts. When the context is destroyed, all initialized beans are also destroyed.

---

## Obtaining `ServletContext` and `ServletConfig` in a Spring Bean

```java
@Autowired
ServletContext servletContext;
```

---

## What is Bean Wiring?

Bean wiring is the process of injecting bean dependencies when the Spring context is initialized.

### Types of Autowiring

- `autowire by name`
- `autowire by type`
- `autowire by constructor`

---

## How Does Spring Provide Thread Safety?

By changing a bean's scope to `prototype` or `session`, thread safety is achieved at the cost of performance.  
Using `singleton`, all instance variables of a class can be modified by any thread, leading to inconsistent data.

---

## Spring MVC

### What is `@Controller`?

`@Controller` marks a class responsible for handling all client requests and sending back the configured resources.

---

### Differences Between `@Component`, `@Controller`, `@Repository`, and `@Service`

| Annotation    | Purpose                                                                                     |
|---------------|---------------------------------------------------------------------------------------------|
| `@Component`  | Generic component; enables auto-detection and registers the class as a Spring bean          |
| `@Repository` | Marks a class as a data repository (storage, retrieval, and search operations)              |
| `@Service`    | Marks a class as a business-layer service (business facade)                                 |
| `@Controller` | Marks a class as a web controller in Spring MVC                                             |

---

### What is `DispatcherServlet`?

The `DispatcherServlet` is the front controller in a Spring MVC application. It loads the bean configuration file and initializes all configured beans.

---

### What is `ContextLoaderListener`?

`ContextLoaderListener` is a listener class that starts and shuts down the `WebApplicationContext`. It binds the `ApplicationContext` lifecycle to the `ServletContext` lifecycle and automates the creation of `ApplicationContext`. It is configured in `web.xml`.

---

### What is `ViewResolver` in Spring?

A `ViewResolver` resolves view pages by name.

```xml
<beans:bean class="org.springframework.web.servlet.view.InternalResourceViewResolver">
    <beans:property name="prefix" value="/WEB-INF/views/" />
    <beans:property name="suffix" value=".jsp" />
</beans:bean>
```

---

### What is `MultipartResolver`?

`MultipartResolver` is an interface used to handle file uploads.

---

### How to Handle Exceptions in Spring MVC

1. **Controller-based:** Define exception handler methods in controller classes, annotated with `@ExceptionHandler`.
2. **Global Exception Handler:** Use `@ControllerAdvice` on any class to define a global exception handler.
3. **`HandlerExceptionResolver` implementation:** Used for generic exceptions.

---

## Creating ApplicationContext in a Java Application

| Class                            | When to Use                                                              |
|----------------------------------|--------------------------------------------------------------------------|
| `AnnotationConfigApplicationContext` | Standalone Java apps using annotation-based configuration            |
| `ClassPathXmlApplicationContext`     | When using an XML configuration file on the classpath                |
| `FileSystemXmlApplicationContext`    | When the XML configuration file can be loaded from anywhere in the filesystem |

---

## Can We Have Multiple Configuration Files in Spring?

Yes. For Spring MVC applications, multiple configuration files can be defined via `contextConfigLocation`:

```xml
<context-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>
        /WEB-INF/spring/root-context.xml
        /WEB-INF/spring/root-security.xml
    </param-value>
</context-param>
```

Or by importing inside a configuration file:

```xml
<beans:import resource="spring-jdbc.xml" />
```

---

## Minimum Configuration for a Spring MVC Application

1. Add `spring-context` dependency
2. Configure `DispatcherServlet`
3. Add a configuration file
4. Add a controller to handle requests

---

## Returning JSON from a RESTful Web Service

Use the **Jackson** dependency to automatically serialize Java objects to JSON.

---

## Important Spring Annotations

| Annotation          | Purpose                                                                          |
|---------------------|----------------------------------------------------------------------------------|
| `@Controller`       | Marks a class as a Spring MVC controller                                         |
| `@RequestMapping`   | Maps URI paths to controller methods                                             |
| `@ResponseBody`     | Sends an object as a response (XML or JSON)                                      |
| `@PathVariable`     | Maps dynamic URI values to method arguments                                      |
| `@Autowired`        | Auto-wires dependencies in Spring beans                                          |
| `@Qualifier`        | Used with `@Autowired` to avoid ambiguity when multiple beans of the same type exist |
| `@Service`          | Marks a class as a service component                                             |
| `@Scope`            | Configures the scope of a Spring bean                                            |
| `@Configuration`    | Marks a class as a source of bean definitions                                    |
| `@ComponentScan`    | Enables component scanning in a given package                                    |
| `@Bean`             | Declares a method as a bean producer                                             |

### AspectJ Annotations (for AOP)

| Annotation   | Purpose                        |
|--------------|--------------------------------|
| `@Aspect`    | Marks a class as an aspect     |
| `@Before`    | Runs advice before a method    |
| `@After`     | Runs advice after a method     |
| `@Around`    | Wraps advice around a method   |
| `@Pointcut`  | Defines a pointcut expression  |

---

## What is Spring Security?

The Spring Security framework focuses on providing **authentication** and **authorization** in Java applications.