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

# mark the working directory
export BASEDIR=$PWD

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

kubectl get service --all-namespaces #list all services in all namespace
echo echo "Waiting for istio-system to be ready ..."
for i in {1..60}; do # Timeout after 5 minutes, 60x5=300 secs
      # if kubectl get pods --namespace=kubeflow -l openebs.io/component-name=centraldashboard | grep Running ; then
      if kubectl get pods --namespace=istio-system  | grep ContainerCreating ; then
        sleep 10
      else
        break
      fi
done

kubectl get service --all-namespaces #list all services in all namespace

# verify  istio auto injection is running
kubectl get pods -n istio-system



cd $BASEDIR/app
kubectl apply -f namespace.yml
kubectl apply -f deployment-backend.yml
kubectl apply -f service-backend.yml
kubectl apply -f deployment-client.yml

kubectl get pods -n istio-grpc-example
echo echo "Waiting for istio-grpc-example to be ready ..."
for i in {1..60}; do # Timeout after 5 minutes, 60x5=300 secs
      # if kubectl get pods --namespace=kubeflow -l openebs.io/component-name=centraldashboard | grep Running ; then
      if kubectl get pods --namespace=istio-grpc-example  | grep ContainerCreating ; then
        sleep 10
      else
        break
      fi
done
kubectl get pods -n istio-grpc-example

kubectl get pods
kubectl get service --all-namespaces #list all services in all namespace

# kubectl logs -f client-0-79f8b95476-x784d -n istio-grpc-example -c python
