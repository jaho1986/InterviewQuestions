
# Microservices

Microservices are a software develpment technique - a variant of the Service-Oriented Architecture (SOA) architectural style - that structures an application as a collection of loosely coupled services. 

In a microservices architecture, services are fine grained.

  
#### Principles of Microservices:
-   Microservices should not care code or data.
-   Avoid unnecesary coupling between services and software components.
-   Independence and autonomy are more important than code re-usability.
-   Each Microservice should be responsible for a single systgem function or process.
-   Microservices are not allowed to communicate directly with each other, they should make use of an event/message bus to communicate with one another.

  

#### Benefits of Microservices:

-   Improves modularity by making it easier to understand, develop and test the system.
-   Reduces complexity by having smaller code-base per microservice.
-   Allows you to update functionality with no or minimal affect on the rest of the system.
-   Greatly reduces the chande of braking something in an unrelated part of the system.
-   Allows for a more controlled collaboration in a team of developers that are working in the system at the same time.
-   Enables continous delivery and deployment of large, complex applications y applying the principle of “divide and conquer”.
-   Can be deployed independently without having to wait for the entire system to be published.
-   It creates an architecture that is highly scalable.
-   Allows for deployments to multiple cloud and on-premise infra-structure environments.
-   Take advantage of emerging technologies (frameworks, programming languages, etc) while envolving an existing system.
-   Allow new team members to become productive qicker since they can start developing new functionality without having to learn the entire system.

  

#### Anti-pattern:

An anti-pattern is an inefective solution to a common recurring problem that is usually very counterproductive.

#### Anti-patterns of Microservices:  

-   Everything should be micro except the database.
-   Microservices will magically solve poor development practices and development proccesses.
-   Since focus on resolving a single system function or process, there is no need for coordination between development teams.
-   Making the technologies behind the microservices your key focus.

  
## APIs
#### What is a RESTful API?

A RESTful API is a web API (Application Programming Interface) or service that is based on an architectural style known as REpresentational State Transfer. REST defines hw client applications can communicate with a RESTful API over HTTP. Client request generally consists of a URI (Uniform Resource Identifier), an HTTP verb, a request header and optional request body. The most commonly used HTTP verbes include POST, GET, PUT, PATCH and DELETE, wich corresponds to the CRUD (Create, Read, Update and Delete) Operations.

### GET vs POST:

#### POST is more secure than GET:

-   GET is less secure because request data is sent as part of the URI, wich makes it visible to everyone and it is stored in the browser’s history.
-   With a POST, request data is sent as part of the request body and it is not including it in the request URI. This is more secure since the request data is not stored in the browser history, nor is it catched.

#### Other considerations to use POST instead of GET

-   You can note use a complex object type as a parameter in a GET method.
-   GET methods only allow ASCII characters, whereas POST methods have no restriction and supports bynary data.
-   The maximum length of a request URL is 2048 characters.

#### Why RESTful APIs are ideal for Microservices?

-   Simplicity - t is easy to understand since HTTP verbs are based on CRUD.
-   REST is designed to be stateless and separates the concerns of the clientt and the server.
-   REST reads can be cached for better formance and scalability.
-   REST supports many data formats, but the predominant use of JSON allows for better support by browser clients.
-   Major companies such as Google, Amazon, and Microsoft prived ther APIs in the form of RESTful APIs.

#### JSON:

JSON is an abbreviation that stands for JavaScript Object Notation. JSON is lightweight test or data format the is easy for humans and computers to read. It is generally used for eschangeing data between applications and web APIs or services. Although it has it s origin in the JavaScript programming language, it is said to be language independent.

#### HTTP Status Codes:

-   **1xx**: Informational.
-   **2xx**: Succesful.
-   **4xx**: Client Error.
-   **5xx**: Server Error.

#### Examples:

-   100 - Request headers received and client may proceed to send the request body.
-   200 - Request was succesfully processed.
-   201 - Resource was successfully created.
-   204 - Request returned no content.
-   400 - Bad request.
-   401 - Unauthorised.
-   403 - Forbidden.
-   405 - Mehod not allowed.
-   500 - Internal server error.

#### What is an API Gateway?

An API gateway creates a unified entrypoint that client applications can use to access Microservices. It acts as a reverse proxy that routes the HTTP request that are made by clients to the desired backend microservices.

API gateways can also perform other important functions such as client authentication, load balancing and SSL termination.

#### Problem with direct client access:

-   Increases complexity of client integration if clients have to keep track of numerous microservice endpoints.
-   Consider that microservices might be removed or a new version might replace the service that a client used to call.
-   Clients have to implement their own load balancing and failure detection.
-   If clients want to acces multiple services publicly, then all these services have to handle their own security concenrs, including SSL termination and authentication.
-   Publicly exposed services face the risk of suffering attacks.
-   You can implement restrictions in API gateways.

  

#### What is an Event Bus?

An event bus can be classified as the backbone of a decoupled microservices architecure. It allows microservices to communicate with each other without to know about each other.

This type of communication is based on the Publish/Subscribe pattern, wich is similar to the Observer Pattern. However, with the Observer Pattern the publisher or observable broadcasts changes directly to its subscribers or observers. Whereas with the Publish/Subscribe pattern, the Event Bus takes up the role of the middleman and sits between the publisher and subscriber.

  

In this way, microservices that publish events to the event bus, does not have to know what other microservices want to do with the published events, it only need to make sure the it is available on the event bus for consumption.

### Securing Microservices

#### Ways to secure Microservices:

-   Using external authentication providers such as UAuth 2.0
-   Adding an authentication layer in the API gateway.
-   Creating your own authentication microservice.

  
#### JSON Web Tokens (JWT):

JWT (JSON Web Token) is based on the RFC 7519 standard that defines how access tokens can be generate and encoded as JSON objects, to enable the secure transmission of data

A JSON Web Token consists of a set of claims, wich refers to information in the form of key/value pairs (Claim Name/Value) that are generally used for authentication, authorisation and for exchanging sensitive information.

JSON Web Tokens are trusted since they are digitally signed using a HMAC (hash-based message authentication code) algorithm or a RSA (Rivest-Shamir-Adleman) signature with SHA-256 (RS256).

![Security Diagram using JWT](https://github.com/jaho1986/InterviewQuestions/blob/main/jwt.png)

## Microservices Data Management Patterns

  

### CQRS & Event-Sourcing

#### What is CQRS?
CQRS is a software design pattern that stands for Command Query Responsibility Segregation.

-   Commands: Operations that alters the state of an object or entity.
-   Queries: Operations that return the state of an object or entity.

![enter image description here](https://github.com/jaho1986/InterviewQuestions/blob/main/cqrs.png)

#### Why do we need CQRS?

-   Generally, data is more frequently queried than altered.
-   Separating commands and queries allows us to optimise each for high performance.
-   Executing command and query operaations on the same model could cause data contention.
-   Read and write representation of data generally differs substantially.
-   Separation provides the ability to manage command and query security and permissions differently.

#### What is Event Sourcing?

Defines an approach where all the changes that are made to an object or entity are stored as a sequence of immutable events to an event store, as opposed to storing just the current state.

![enter image description here](https://github.com/jaho1986/InterviewQuestions/blob/main/cqrs_event.png)

#### Benefits of Event-Sourcing?

-   The envet store provides a complete log of every state change, effectively creating an audit trail of the entire system.  
-   The state of any object can be recreated by replaying the event store.
-   It removes the need to map relational tables to Objects.
-   An event store can feed dato into multiple read databases.
-   In case of failure, the envet store can be used to restore read databases.

  

### Saga Pattern

#### What is a distributed transaction?

A distributed transaction can be defined as a database transaction that involves two or more network hosts (or microservices) as opposed to single system that executes a transaction directly to the database.

#### What is the Saga Pattern?

The saga pattern is a design pattern that provides a solution for implementing transactions in te form of sagas that span across two or more microservices.

A saga can be defined as a sequence of local transactions. Where each participating microservice executes one or more local transactions, and the publish an event than is used to trigger the next transaction in a saga that resides in another participating microservice.

When one of the transacitons in the sequence fails, the saga executes a series of compensating transactions to undo the changes that where made by the preceding transactions.

![enter image description here](https://github.com/jaho1986/InterviewQuestions/blob/main/saga_o1.png)
![enter image description here](https://github.com/jaho1986/InterviewQuestions/blob/main/saga_o2.png)
![enter image description here](https://github.com/jaho1986/InterviewQuestions/blob/main/saga_c1.png)
![enter image description here](https://github.com/jaho1986/InterviewQuestions/blob/main/saga_c2.png)


### Success factors

#### Loggin
-   Execeptions.
-   All request and responses that are made to a microservice including the HTTP code (200, 400, 401, 404, 500, etc).
-   Microservice response times.
-   Events that are published to the event bus.
-   All login / acces token (JWT) request that are made by client applications.

  
#### Monitoring & Alerting:
-   Uptime of microservices.
-   The average response time of each microservice.
-   Resource conssuption of each microservice.
-   The success/failure ration of each microservice.
-   Access frequency of client requests.
-   Infraestructure dependencies.

#### Documentation:

-   API Documentation
-   Design documentation.
-   Deployment view of the architecture.
-   Activity diagram to ilustrate the business login of each service.
-   Dependencies.
-   Network and port allocations.

## Deployment and Infrastructure

#### What is a container image?

A container image is an executable software package thet contains everything that is required to run a containerized application or service, including the code, libreries, configuration and runtime.

#### What is a container?

A container image becomes a container at runtime. Containers isolates applications from each other and makes them platform-agnostic. Containers are lightweight and unlike virtual machines, each container do not come with its own operating system.

#### What is container orchestration?

Container orchestration refers to the automation of tasks that relates to the scheduling and management of containers. More specifically, container orchestration is used to automate the following tasks:

-   Container deployment and provisioning.
-   Rescheduling of containers that have failed.
-   Scaling and load balancing of container instances.
-   Resource allocation between containers.
-   Container redundancy and availability.
-   External exposure services.
-   Health monitoring of containers and hosts.

## Tools and technologies

#### Frameworks

-   Spring boot.
-   Grails
-   Eclipse Vert.x
-   Helidon

#### Container Technologies:

-   Docker
-   CoreOS’ rkt

#### Orchestration Engines:

-   Kubernetes (k8s).
-   OpenShift
-   Amazon ECS
-   Azure Kubernetes Service (AKS).

#### Service Discovery:

-   Eureka
-   Apache Zookeeper

#### API Gateways

-   Amazon AWS API Gateway.
-   Azure Application Gateway.
-   Spring Cloud Gateway.

#### Event Bus Tools & Technologies:

-   Apache Kafka.
-   RabbitMQ.
-   Azure service Bus.
-   Amazon Somple Queue Service (SQS).
-   Google Cloud Pub/Sub

#### Logging Tools:

-   Fluentd
-   Kibana
-   Logstash

#### Monitoring Tools:

-   Grafana.
-   Prometheus

#### Documentation Tools:

-   Swagger UI
-   Gelato
-   Readme.io

#### Testing Tools:

-   Postman
-   REST Assured

  

## Step-By-Step Recommendations to convert Monolithic Applications Into Microservices:

-   Start by identifying all the features in your existing monolithic application.
-   With microservices principles in mind, use the feature list to define each microservice that will collectively replace the existing functionality.
-   Select a non-critical microservice for your first implementation that you can use as your prove of concept.
-   Focus on the RESTful API side of the microservices first before implementing an event-bus.
-   Implement an API gateway between your user interfaces and your RESTful APIs.
-   If you have a single database, you can keep using the single database until all the functions have been converted into small independent RESTful APIs.
-   Identify processes in your system that are now handled by two or more APIs.
-   Define events for each microservice that can be used as inputs that can trigger logic that reside in other microservices.
-   Implement an event-bus and start by setting up event-driven communication between two of your non-critical microservices.
-   Identify processes that are executed as part of database transactions, and select a design pattern for Introducing distributed transactions.
-   Decompose the single database into a database-per-service.
