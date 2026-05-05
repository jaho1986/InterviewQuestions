# Spring Boot Guide

## What is Spring Boot?
Sprint boot is a Java-based spring framework used for Rapid Application Development (to build stand-alone microservices).

## How does Spring Boot works?
Spring Boot automatically configures your application based on the dependencies you have added to the project by using annotation. 

## What are the Spring Boot key components?
 - Spring Boot auto-configuration.
 - Spring Boot CLI.
 - Spring Boot starter POMs.
 - Spring Boot Actuators.

## What are the advantages of using Spring Boot?
 - Easy to understand and develop spring applications.
 - Spring Boot is nothing but an existing framework with the addition of an embedded HTTP server and annotation configuration which makes it easier to understand and faster the process of development.
 - Increases productivity and reduces development time.
 - Minimum configuration.

## What are starter dependencies?
Spring boot starter is a maven template that contains a collection of all the relevant transitive dependencies that are needed to start a particular functionality.
Like we need to import spring-boot-starter-web dependency for creating a web application.

```
<dependency>
<groupId> org.springframework.boot</groupId>
<artifactId> spring-boot-starter-web </artifactId>
</dependency>
```
## Examples of starter dependencies in Spring Boot
 - Data JPA starter.
 - Test Starter.
 - Security starter.
 - Web starter.
 - Mail starter.
 - Thymeleaf starter.

## What does the @SpringBootApplication annotation do internally?
The @SpringBootApplication annotation is equivalent to using @Configuration, @EnableAutoConfiguration, and @ComponentScan with their default attributes. Spring Boot enables the developer to use a single annotation instead of using multiple.

## What is the purpose of using @ComponentScan in the class files?
Spring Boot application scans all the beans and package declarations when the application initializes. You need to add the @ComponentScan annotation for your class file to scan your components added to your project.

## What is Spring Initializer?
Spring Initializer is a web application that helps you to create an initial spring boot project structure and provides a maven or gradle file to build your code. It solves the problem of setting up a framework when you are starting a project from scratch.

## What is Spring Boot CLI and what are its benefits?
Spring Boot CLI is a command-line interface that allows you to create a spring-based java application using Groovy.


## What is an IoC container?
IoC Container is a framework for implementing automatic dependency injection. It manages object creation and its life-time and also injects dependencies into the class.

## What is dependency Injection?
The process of injecting dependent bean objects into target bean objects is called dependency injection.

 - **Setter Injection**: The IOC container will inject the dependent bean object into the target bean object by calling the setter method.
 - **Constructor Injection**: The IOC container will inject the dependent bean object into the target bean object by calling the target bean constructor.
 - **Field Injection**: The IOC container will inject the dependent bean object into the target bean object by Reflection API.


## Where do we define properties in the Spring Boot application?
We can define both application and Spring boot-related properties into a file called application.properties. 

## How to check the environment properties in your Spring boot application?
Spring Boot actuator “/env” returns the list of all the environment properties of running the spring boot application.

## What Are the Basic Annotations that Spring Boot Offers?

 - `@EnableAutoConfiguration` – to make Spring Boot look for auto-configuration beans on its classpath and automatically apply them.

 - `@SpringBootApplication` – used to denote the main class of a Boot Application. This annotation combines @Configuration, @EnableAutoConfiguration, and @ComponentScan annotations with their default attributes.

## Can we create a non-web application in Spring Boot?
Yes, we can create a non-web application by removing the web dependencies from the classpath along with changing the way Spring Boot creates the application context.

## Is it possible to change the port of the embedded Tomcat server in Spring Boot?
Yes, it is possible. By using the server.port in the application.properties.

## What is Spring Actuator? What are its advantages?
An actuator is an additional feature of Spring that helps you to monitor and manage your application when you push it to production. These actuators include auditing, health, CPU usage, HTTP hits, and metric gathering, and many more that are automatically applied to your application.

## What are stereotype annotations in Spring and how are they different?
 - `@Service` represents business logic
 - `@Repository` represents data access layer
 - `@Controller` represents web layer
 - `@Component` is a generic stereotype
 