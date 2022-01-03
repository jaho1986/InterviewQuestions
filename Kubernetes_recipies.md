# Kubernetes commands

This file, will help you to do some basic operations with kubernetes. This commands were run and tested on Google Cloud Platform.

# Create a new deployment

Connect to Google Cloud:

    gcloud container clusters get-credentials cluster-1 --zone us-central1-c --project psyched-battery-322411
Create a deployment:

    kubectl create deployment [deployment_name] --image=[image]:[tagname]
Expose the deployment:

    kubectl expose deployment [deployment_name] --type=LoadBalancer  --port=[number]

