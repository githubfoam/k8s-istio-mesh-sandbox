#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

# Istio has several optional dashboards installed by the demo installation.
echo "============================Install istio=============================================================="

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

# Deploy the sample application
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
# As each pod becomes ready, the Istio sidecar will deploy along with it
kubectl get services
kubectl get pods

kubectl get pods --all-namespaces

# interactive shell
# see if the app is running inside the cluster and serving HTML pages by checking for the page title in the response
# kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>"


# Open the application to outside traffic
# The Bookinfo application is deployed but not accessible from the outside
# make it accessible,create an Istio Ingress Gateway, which maps a path to a route at the edge of the mesh


# Associate this application with the Istio gateway
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

# Ensure that there are no issues with the configuration
istioctl analyze


# Determining the ingress IP and ports
# MINIKUBE specific
# set the INGRESS_HOST and INGRESS_PORT variables for accessing the gateway
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')


# Ensure a port was successfully assigned to each environment variable
echo $INGRESS_PORT
echo $SECURE_INGRESS_PORT

# Set the ingress IP
export INGRESS_HOST=$(minikube ip)
# Ensure an IP address was successfully assigned to the environment variable
echo $INGRESS_HOST

# Run this command in a new terminal window to start a Minikube tunnel that sends traffic to your Istio Ingress Gateway:
minikube tunnel &

# Set GATEWAY_URL
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
# Ensure an IP address and port were successfully assigned to the environment variable
echo $GATEWAY_URL


# Verify external access
echo http://$GATEWAY_URL/productpage


# View the dashboard

# Access the Kiali dashboard.
# Istio has several optional dashboards installed by the demo installation.
# The default user name is admin and default password is admin
istioctl dashboard kiali &
