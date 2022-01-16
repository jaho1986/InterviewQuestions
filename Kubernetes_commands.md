# Kubernetes on GCP

This file, will help you to do some basic operations with kubernetes. This commands were run and tested on Google Cloud Platform.

## Increase and decrease the number of nodes in a cluster


    gcloud container clusters get-credentials [cluster_name] --zone [zone_name] --project [project_name] 
    gcloud container clusters resize --zone [zone_name] [cluster_name] --num-nodes=0

## Create a new deployment

Connect to Google Cloud:

    gcloud container clusters get-credentials [cluster_name] --zone [zone_name] --project [project_name]
    
Create a deployment:

    kubectl create deployment [deployment_name] --image=[image_name]:[tagname]
Expose the deployment:

    kubectl expose deployment [deployment_name] --type=LoadBalancer --port=[number]

## Update a deployment

Connect to Google Cloud:

    gcloud container clusters get-credentials [cluster_name] --zone [zone_name] --project [project_name]

Update the image of a deployment:

    kubectl set image deployment [deployment_name] [container_name]=[image_name]:[tagname] —record=true

Check the status of the deployment:

    kubectl rollout status deployment [deployment_name]

Check the history of the deployment (if necesary):

    kubectl rollout history deployment [deployment_name]

## Update a deployment (using a YAML file)
We can start by exporting the configuration of the deployment and exporting the configuration of the service and the deployment with the following commands:

    kubectl get deployment [deployment_name] -o yaml > deployment_filename.yaml
    kubectl get service [service_name] -o yaml > service_filename.yaml

But we need to remove the unnecessary properties of the YAML files:
 - annotations 
 - creationTimestamp 
 - generation 
 - resourceVersion 
 - selfLink 
 - uid
 - clusterIp 
 - progressDeadlineSeconds 
 - revisionhistroyLimit 
 - resources
 - terminationMessagePath 
 - terminationMessagePolicy 
 - dnsPolicy
 - schedulerName 
 - securityContext 
 - status (general property)
 - externalTrafficPolicy

Verify if there are differences between the new deplyment and the actual deployment:

    kubectl diff -f deployment.yaml
And then, apply all changes by using the following command:

    kubectl apply -f filename.yaml

## Get information about a deployment

How to see the logs:

    Kubectl logs [pod_name] -f

Get info about deployment:

    kubect get deployment [deployment_name] -o wide

Get YAML configuration about deployment and save it:

    kubect get deployment [deployment_name] -o yaml > deployment_filename.yaml  

Geet YAML configuration of a service:

    kubectl get service [service_name] -o yaml > service_filename.yaml

## Delete everything related to a deployment

    kubectl delte all -l app=[app_name]

Get all resources:

    kubectl get all

## Aditional commands to get information

    kubectl get pods -o wide
    kubectl get pods --all-namespaces
    kubectl get pods -l app=[app_name]
    kubectl get services
    kubectl get services --sort-by=.spec.type
    kubectl cluster-info
    kubectl top node
    kubectl top pod
    kubectl get rs
    kubectl get namespaces
    kubectl get nodes
    kubectl get pv
    kubectl get pvc
    kubectl logs [pod_name] -f

## Create a new deployment using Docker-Compose files
Verify if yur docker-compos config is working:

    docker-compose up
Create deployments and services by docker-compose YAML:

    kompose convert
All YAML files related to services need to be modified to be of type LoadBalancer:

    spec:
      type: LoadBalancer   
If is a MySQL deployment, we need to modify the YAML file adding the following lines bellow "image":

    args: 
    - "--ignore-db-dir=lost+found" #CHANGE

And then, apply all changes by using the following command:

    kubectl apply -f file1.yaml,file2.yaml,file3.yaml,....
Verify changes:

    kubectl get all

## Centralized configuration with Kubernetes
Create a configmap:

    kubectl create configmap [configmap_name] --from-literal=[var1]=[value1]
Get the information of a configmap:

    kubectl describe configmap/[configmap_name]
Get the configuration from a configmap in YAML file:

    *** Instead of having this:
    value: value1
    *** We need to change it by this:
    valueFrom:
      configMapKeyRef:
        key: [configmap_name]
        value: [var1]
 Scale deployment to zero and to the original number of replicas to update changes:

    kubectl scale deployment [app_name] --replicas=[number_replicas]
 Edit configuration of a configmap:

     kubectl edit configmap/[configmap_name]

## Store passwords with Kubernetes
Create a secret:

    kubectl create secret generic [secret_name] --from-literal=[secret_name]=[value1]
Get secret: 

    kubectl get secret/[secret_name]
Describe configuration of a secret:

    kubect describe secret/[secret_name]
Get the configuration from a configmap in YAML file:

    *** Instead of having this:
    value: value1
    *** We need to change it by this:
    valueFrom:
      secretKeyRef:
        key: [secret_name]
        value: [var1]

## Service Discovery in Kubernetes
It is used in Feign Clients and we have to add a environment variable in the deployment file like follows:
```
spec:  
  ...
  template:  
    ...
    spec:  
      containers:  
      ...
        env:  
          - name: [ENV_VAR_NAME]  
            value: http://[service_name]

```
And modify the Feign Class like this:

    @FeignClient(name = "service_name", url = "${ENV_VAR_NAME:http://localhost}:PORT")
## Using Ingress to create services

Add the following dependencies in our project:
```
<dependency>
  <groupId>org.springframework.cloud</groupId>  
   <artifactId>spring-cloud-starter-netflix-ribbon</artifactId>  
</dependency>  
  
<dependency>
  <groupId>org.springframework.cloud</groupId>  
   <artifactId>spring-cloud-starter-kubernetes-all</artifactId>  
</dependency>
```
Modify REST clients using RIbbon:

    @FeignClient(name = "[service_name]") //Kubernetes Service Name  
    @RibbonClient(name = "[service_name]")

Create a YAML configuration file to create the Ingress service:
``` 
apiVersion: extensions/v1beta1  
kind: Ingress  
metadata:  
  name: gateway-ingress  
  annotations:  
    nginx.ingress.kubernetes.io/rewrite-target: /  
spec:  
  rules:  
  - http:  
      paths:  
      - path: /[path1]/*  
        backend:  
          serviceName: [name_service1]  
          servicePort: [port1]            
      - path: /[path2]/*  
        backend:  
          serviceName: [name_service2]  
          servicePort: [port2] 
```
Modify the Deployment Configuration of the application in the Service Definition (instead of `LoadBalancer`) like follows:

    spec:  
      type: NodePort

Apply changes:

    kubectl apply -f file1.yaml,file2.yaml,file3.yaml,....

## Use ARBC to allow Ribbon to access Service Discovery APIs:
Validate the actual service account:

    kubectl get serviceaccount
Create a YAML file with the ARBC definition:
```
apiVersion: rbac.authorization.k8s.io/v1beta1  
kind: ClusterRoleBinding  
metadata:  
  name: fabric8-rbac  
subjects:  
  - kind: ServiceAccount  
    # Reference to upper's `metadata.name`  
  name: default  
    # Reference to upper's `metadata.namespace`  
  namespace: default  
roleRef:  
  kind: ClusterRole  
  name: view  
  apiGroup: rbac.authorization.k8s.io
```
Apply changes:

    kubectl apply -f file1.yaml,file2.yaml,file3.yaml,....

## Using Spring Cloud Kubernetes Config to load Configmaps
Config a configmap:

    kubectl create configmap [configmap_name] --from-literal=[PROPERTY_NAME1]=[value1] --from-literal=[PROPERTY_NAME2]=[value2]

Verify information:

    kubectl describe configmap/[configmap_name]

## Auto Scaling  
  
Cluster Auto Scaling :
```  
gcloud container clusters create [cluster_name] \  
--zone us-central1-a \  
--node-locations [zone_name] \  
--num-nodes 2 --enable-autoscaling --min-nodes 1 --max-nodes 4  
```
  
Enable on Cluster :
```  
gcloud container clusters create [CLUSTER_NAME] --enable-vertical-pod-autoscaling 
gcloud container clusters update [CLUSTER_NAME] --enable-vertical-pod-autoscaling  
```  
  
Configure VPA (Vertical Pod Autoscaler) :
  
```  
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: [vpa_name]
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind:       Deployment
    name:       [deployment_name]
  updatePolicy:
    updateMode: "Off"
 ```
  
Get VPA reccommendations:

    kubectl get vpa [vpa_name] --output yaml  

  
Configure Horizontal Pod Auto Scaling:

    kubectl autoscale deployment [deployment_name] --max=3 --min=1 --cpu-percent=50 
Get Horizontal Pod Autoscaler:

    kubectl get hpa [service_name] -o yaml > hpa.yaml
