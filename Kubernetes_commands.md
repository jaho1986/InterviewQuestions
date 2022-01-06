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
If is a MySQL deployment, we need to modify te YAML file adding the following lines bellow "image":

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
