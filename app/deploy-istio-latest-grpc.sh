#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

# Istio has several optional dashboards installed by the demo installation.
echo "============================Install istio=============================================================="

#Download Istio
#/bin/sh -c 'curl -L https://istio.io/downloadIstio | sh -' #download and extract the latest release automatically (Linux or macOS)

# Download Istio
curl -L https://istio.io/downloadIstio | sh -
# cd istio-1.6.4
cd istio-* #Move to the Istio package directory.

# Add the istioctl client to your path (Linux or macOS)
export PATH=$PWD/bin:$PATH

# Install Istio
# use the demo configuration profile
istioctl install --set profile=demo

# Add a namespace label to instruct Istio to automatically inject Envoy sidecar proxies when you deploy your application
kubectl label namespace default istio-injection=enabled

kubectl get pods --all-namespaces
for i in {1..60}; do # Timeout after 5 minutes, 60x2=120 secs, 2 mins
    if kubectl get pods --namespace=istio-system |grep Running ; then
      break
    fi
    sleep 2
done
kubectl get service --all-namespaces #list all services in all namespace

for i in {1..60}; do # Timeout after 5 minutes, 60x2=120 secs, 2 mins
    if kubectl get pods --namespace=default |grep Running ; then
      break
    fi
    sleep 2
done
kubectl get service --all-namespaces #list all services in all namespace

# verify  istio auto injection is running
kubectl get pods -n istio-system


kubectl apply -f namespace.yml
kubectl apply -f deployment-backend.yml
kubectl apply -f service-backend.yml
kubectl apply -f deployment-client.yml

kubectl get pods -n istio-grpc-example

kubectl logs -f client-0-79f8b95476-x784d -n istio-grpc-example -c python
