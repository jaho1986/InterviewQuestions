# Microservices

Microservices are small, loosely coupled applications of services that can fail independently from each other. Only a single function or process in the system should become unavailable, while the rest of the system remains unaffected.

 
**Principles of Microservices**
-   Microservices should not care code or data.
-   Avoid unnecessary coupling between services and software components.
-   Independence and autonomy are more important than code re-usability.
-   Each Microservice should be responsible for a single system function or process.
-   Microservices are not allowed to communicate directly with each other, they should make use of an event/message bus to communicate with one another.

  

**Benefits of Microservices**

-   Improves modularity by making it easier to understand, develop and test the system.
-   Reduces complexity by having smaller code-base per Microservice.
-   Allows you to update functionality with no or minimal affect on the rest of the system.
-   Greatly reduces the change of braking something in an unrelated part of the system.
-   Allows for a more controlled collaboration in a team of developers that are working in the system at the same time.
-   Enables continuous delivery and deployment of large, complex applications y applying the principle of “divide and conquer”.
-   Can be deployed independently without having to wait for the entire system to be published.
-   It creates an architecture that is highly scalable.
-   Allows for deployments to multiple cloud and on-premise infra-structure environments.
-   Take advantage of emerging technologies (frameworks, programming languages, etc) while evolving an existing system.
-   Allow new team members to become productive quicker since they can start developing new functionality without having to learn the entire system.

  

**Anti-pattern**
An anti-pattern is an ineffective solution to a common recurring problem that is usually very counterproductive.

**Anti-patterns of Microservices**
-   Everything should be micro except the database.
-   Microservices will magically solve poor development practices and development proccesses.
-   Since focus on resolving a single system function or process, there is no need for coordination between development teams.
-   Making the technologies behind the microservices your key focus.
