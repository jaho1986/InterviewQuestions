# Kubernetes commands

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

    kubectl expose deployment [deployment_name] --type=LoadBalancer  --port=[number]

## Update a deployment

Connect to Google Cloud:

    gcloud container clusters get-credentials cluster-1 --zone [zone_name] --project [project_name]
Update the image of a deployment:

    kubectl set image deployment [deployment_name] [container_name]=[image_name]:[tagname] —record=true

Check the status of the deployment:

    kubectl rollout status deployment [deployment_name]
