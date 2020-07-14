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

kubectl create -f install/kubernetes/helm/helm-service-account.yaml
helm init --service-account tiller

kubectl create namespace istio-system

helm install \
--wait \
--name istio \
--namespace istio-system \
install/kubernetes/helm/istio

helm status istio

# verify  istio auto injection is running
kubectl get pods -n istio-system


kubectl apply -f namespace.yml
kubectl apply -f deployment-backend.yml
kubectl apply -f service-backend.yml
kubectl apply -f deployment-client.yml

kubectl get pods -n istio-grpc-example

kubectl logs -f client-0-79f8b95476-x784d -n istio-grpc-example -c python
