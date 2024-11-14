#!/bin/bash

# Set the path for kubectl
KUBECTL="/usr/local/bin/kubectl"

# Ensure Minikube or any Kubernetes cluster is running
echo "Checking if Minikube or Kubernetes is running..."
kubectl cluster-info || { echo "Kubernetes is not running. Please start your cluster."; exit 1; }

# Docker images to push
APP_A_IMAGE="saichandtcs/app_a:latest"
APP_B_IMAGE="saichandtcs/app_b:latest"

# Build Docker images
echo "Building Docker image for app_a..."
docker build -f app_a/Dockerfile -t $APP_A_IMAGE . || { echo "Docker build for app_a failed"; exit 1; }

echo "Building Docker image for app_b..."
docker build -f app_b/Dockerfile -t $APP_B_IMAGE . || { echo "Docker build for app_b failed"; exit 1; }

# Push Docker images to Docker Hub
echo "Pushing Docker image for app_a to Docker Hub..."
docker push $APP_A_IMAGE || { echo "Docker push for app_a failed"; exit 1; }

echo "Pushing Docker image for app_b to Docker Hub..."
docker push $APP_B_IMAGE || { echo "Docker push for app_b failed"; exit 1; }

# Create namespace if it does not exist
kubectl get namespace my-apps || kubectl create namespace my-apps

# Clean up old deployments and services
echo "Deleting old deployments and services for app_a and app_b..."
$KUBECTL delete deployment app-a-deployment -n my-apps --ignore-not-found || echo "No old deployment for app_a to delete"
$KUBECTL delete service app-a-service -n my-apps --ignore-not-found || echo "No old service for app_a to delete"
$KUBECTL delete deployment app-b-deployment -n my-apps --ignore-not-found || echo "No old deployment for app_b to delete"
$KUBECTL delete service app-b-service -n my-apps --ignore-not-found || echo "No old service for app_b to delete"

# Create namespace
echo "Creating namespace"
$KUBECTL apply -f k8s-manifests/namespace.yaml --validate=false 

# Apply the Kubernetes manifests for app_a and app_b (including services and deployments)
echo "Applying Kubernetes manifests for app_a..."
$KUBECTL apply -f k8s-manifests/app_a-deployment.yaml -n my-apps --validate=false  
$KUBECTL apply -f k8s-manifests/app_a-service.yaml -n my-apps --validate=false 

echo "Applying Kubernetes manifests for app_b..."
$KUBECTL apply -f k8s-manifests/app_b-deployment.yaml -n my-apps --validate=false 
$KUBECTL apply -f k8s-manifests/app_b-service.yaml -n my-apps --validate=false 

echo "Deployment completed for app_a and app_b!"

# Verify the deployment
echo "Verifying the deployment..."
$KUBECTL get pods -n my-apps  
$KUBECTL get services -n my-apps 

echo "Deployment process completed successfully!"

