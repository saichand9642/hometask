#!/bin/bash

# Ensure we have sudo privileges
if [ "$(id -u)" != "0" ]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

# Update and Install necessary dependencies
echo "Updating and installing dependencies..."
apt-get update -y && apt-get install -y curl apt-transport-https virtualbox virtualbox-ext-pack

# Install Minikube
echo "Installing Minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/local/bin/minikube
sudo chmod +x /usr/local/bin/minikube

# Install kubectl
echo "Installing kubectl..."
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
sudo mv kubectl /usr/local/bin/
sudo chmod +x /usr/local/bin/kubectl

# Set up Minikube configurations
echo "Configuring Minikube..."
# Use VirtualBox as the driver; adjust memory and CPU if desired
minikube config set driver virtualbox
minikube config set memory 4096
minikube config set cpus 2

# Start Minikube
echo "Starting Minikube..."
minikube start --driver=virtualbox

# Enable default Minikube addons for Kubernetes dashboards and ingress
echo "Enabling useful Minikube addons..."
minikube addons enable dashboard
minikube addons enable ingress

# Optional: Setting up environment variables for kubectl context
echo "Setting up kubectl context for Minikube..."
export KUBECONFIG=~/.kube/config
kubectl config use-context minikube

# Verify the installation
echo "Verifying Kubernetes Setup..."
kubectl version --client
kubectl get nodes

echo "Minikube Kubernetes environment setup is complete!"

