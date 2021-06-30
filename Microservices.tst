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




