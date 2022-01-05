# Kubernetes on GCP

This file, will help you to do some basic operations with kubernetes. This commands were run and tested on Google Cloud Platform.

## Increase and decrease the number of nodes in a cluster


    gcloud container clusters get-credentials [cluster_name] --zone [zone_name] --project [project_name] 
    gcloud container clusters resize --zone [zone_name] [cluster_name] --num-nodes=0

## Create a new deployment

Connect to Google Cloud:

    gcloud container clusters get-credentials cluster-1 --zone [zone_name] --project [project_name]
    
Create a deployment:

    kubectl create deployment [deployment_name] --image=[image_name]:[tagname]
Expose the deployment:

    kubectl expose deployment [deployment_name] --type=LoadBalancer --port=[number]

## Update a deployment

Connect to Google Cloud:

    gcloud container clusters get-credentials cluster-1 --zone [zone_name] --project [project_name]

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
    