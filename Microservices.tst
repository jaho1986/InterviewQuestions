Monolithic Architecture:
A monolithic architecture is like a big container wherein all the software components of an application are assembled together and tightly packaged.

Monolithic Arquitecture - Challenges.
 - Large & complex applications: Are difficult to understand and difficult to mantain.
 - Slow development: You can not make frequent deployments because of the high dependencies of the code. 
 - Blocks continous develpment
 - Unscalable: High applications consumes high resources.
 - Unreliable.
 - Inflexible: Difficult to adopt new Frameworks and languages.
 
What is a Microservice Architecture?
Is an architectural style that structures an application as a collection of small autonomous services, modeled arround a Businness Domain.
In Microservice Architecture, each service s self-contained and implements a single Business Capability.
 
Features of Microservices Architecture:
 - Small Focused: Because they are modeled arround a Businness Domain.
 - Loosely Coupled: Because each microservice is independent of each other.
 - Language Neutral:
 - Bounded Context:

Advantages of Microservice Architecture:
 - Independent Develpment.
 - Independent Deployment
 - Fault Isolation.
 - Mixed Technology Stack.
 - Granular Scaling.

Microservices Architecture Challenges:
 - Perceptibility.
 - Configuration management. Manage the configuration of all the small pieces of software.
 - Debugging. It's difficult to debug errors because there are multiple components inside.
 - Consistency. There is a need to have governance of the Languages, technologies and tools to implement.
 - Automating the concepts.
 
Advantages of Spring Boot:
 - Spring boot has embedded server wich are ease to deploy with the containers.
 - It helps monitoring multiples components.
 - It helps in the configuration of the components externally.

Docker:
Docker is a tool designed to make easier to create, deploy and run applications by using containers.
Docker containers are lightweight alternatives to Virtual Machines and it uses the host OS.

Docker Images:
 - A docker image is a Read Only Template used to create Containers.
 - Is build by Docker users.
 - Is stored in Ducker Hub or your local registry.

Docker Containers:
 - A Docker Container is created by a Docker Image.
 - It's an Isolated Application Platform.
 - Contains everything needed to run the application..
 - It's build from one or more images.

Docker registry:
 - Is a storage componentn for Docker Images.
 - We can store the images in either Public / Private repositories.
 - Docker Hub is Docker's Cloud Repository.

Why we use Docker Registries?
 - To control where your images are being stored.
 - TO integrate image storage with your in-house development workflow.

Docker Compose:
It makes it easier to configure and run applications made up of multiple containers. 
For the example: an image is being able to define three containers:
 - One for running a web app.
 - Another running postgres.
 - And a third running Redis.
All in one YAML files and then running those three connected containers with a single command.

Advantages of Docker in Microservices:
 - Packaging.
 - Distribution.
 - Runtime Isolation.
 - Installation process.

What are APIs?
API is an abbreviation for Application Programming Interface which is a collection of communication protocols and subroutines used by various programs to communicate between them. Thus in simpler terms, an API helps two programs or applications to communicate with each other by providing them with necessary tools and functions. It takes the request from the user and sends it to the service provider and then again sends the result generated from the service provider to the desired user.

API Types:
 - WEB APIs.
 - LOCAL APIs.
 - PROGRAM APIs.

WEB APIs:
A Web API also called as Web Services is an extensively used API over the web and can be easily accessed using the HTTP protocols. A Web API is an open source interface and can be used by a large number of clients through their phones, tablets. or PC’s.

LOCAL APIs:
In this types of API, the programmers get the local middleware services. TAPI (Telephony Application Programming Interface), .NET are common examples of Local API’s.

PROGRAM APIs:
It makes a remote program appears to be local by making use of RPC’s (Remote Procedural Calls). SOAP is a well-known example of this type of API.


Few other types of APIs:

 - SOAP (SIMPLE OBJECT ACCESS PROTOCOL): 
It defines messages in XML format used by web applications to communicate with each other.
 - REST (Representational State Transfer): 
It makes use of HTTP to GET, POST, PUT, or DELETE data. It is basically used to take advantage of the existing data.
 - JSON-RPC: 
It use JSON for data transfer and is a light-weight remote procedural call defining few data structure types.
 - XML-RPC: 
It is based on XML and uses HTTP for data transfer. This API is widely used to exchange information between two or more networks.

Advantages of APIs:
 - Efficiency: 
API produces efficient, quicker and more reliable results than the outputs produced by human beings in an organization.
 - Flexible delivery of services: 
API provides fast and flexible delivery of services according to developers requirements.
 - Integration: 
The best feature of API is that it allows movement of data between various sites and thus enhances integrated user experience.
 - Automation: 
As API makes use of robotic computers rather than humans, it produces better and automated results.
 - New functionality: 
While using API the developers find new tools and functionality for API exchanges.


Disadvantages of APIs:
 - Cost: 
Developing and implementing API is costly at times and requires high maintenance and support from developers.

 - Security issues: 
Using API adds another layer of surface which is then prone to attacks, and hence the security risk problem is common in API’s.


Principles Used to Design Microservice Architecture:
 - Independent & Autonomous Services
 - Scalability
 - Decentralization
 - Resilient Services
 - Real-Time Load Balancing
 - Availability
 - Continuous delivery through DevOps Integration
 - Seamless API Integration and Continuous Monitoring
 - Isolation from Failures
 - Auto -Provisioning

Design Patterns of Microservices:
 - Aggregator
 - API Gateway
 - Chained or Chain of Responsibility
 - Asynchronous Messaging
 - Database or Shared Data
 - Event Sourcing
 - Branch
 - Command Query Responsibility Segregator
 - Circuit Breaker
 - Decomposition

Tools for managing microservices:
 - Postman:
   - Provides features to design APIs.
   - Works for small to big applications.
   - Supports work collaboration.
 
 - API Fortress:
   - Simplifies API testing creation and execution.
   - Simplifies end to end testing.

Toos for messaging:
 - Apache Kafka.
 - Rabbit MQ.

Tools for orchestation:
 - Kubernetes:
   - Deploy and update application configurations.
   - Manages your batch workloads.
   - Can scale up or scale down the containers.
   - You can mount the storage system of your choice.
 - Istio:
   - Performs automatic tracing and monitoring.
   - Secure services trough encyption.
   - Controls the flow of traffic and API calls between services.
   - Aplies policies and snsures that they're enforced.
   
Tools form Monitoring:
 - Prometheus:
   - Provides a flexible query language.
   - Distributed storage and single server nodes.
   - Discovers targets via service discovery.
   - Provides dashboarding and graphic support.

 - Logstash:
   - Supports a variety of inputs.
   - Transforms and prepares data.
   - You can choose your own stash and transport data.
   - A plugglable framework consisting over 200 plugins.

Microservices security:
 - 
