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

# Deploy the sample application
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
# As each pod becomes ready, the Istio sidecar will deploy along with it
kubectl get services
kubectl get pods


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


# Linkerd stable-2.8.1 was successfully installed
# Add the linkerd CLI to your path with:
#   export PATH=$PATH:/home/travis/.linkerd2/bin
# Now run:
#     linkerd check --pre                     # validate that Linkerd can be installed
#     linkerd install | kubectl apply -f -    # install the control plane into the 'linkerd' namespace
#     linkerd check                           # validate everything worked!
#     linkerd dashboard                       # launch the dashboard

export PATH=$PATH:$HOME/.linkerd2/bin

# By default linkerd install will create a linkerd namespace.
# Prior to installation, that namespace should not exist
linkerd check --pre --linkerd-namespace linkerd

# 'linkerd-config' config map exists
# configmaps "linkerd-config" not found
# see https://linkerd.io/checks/#l5d-existence-linkerd-config for hints
linkerd check --pre
linkerd install | kubectl apply -f -
linkerd check
linkerd dashboard &

# Ensure the Linkerd ConfigMap exists
# kubectl -n linkerd get configmap/linkerd-config
 # ensure you have permission to create ConfigMaps
kubectl -n linkerd auth can-i create configmap

# linkerd check
# linkerd dashboard &
# linkerd version
# kubectl -n linkerd get deploy
# `linkerd install | kubectl apply -f -` #namespace/linkerd: No such file or directory


#https://docs.flagger.app/tutorials/linkerd-progressive-delivery#a-b-testing
# Prerequisites
# Flagger requires a Kubernetes cluster v1.11 or newer and Linkerd 2.4 or newer
echo "============================Linkerd Flagger Canary Deployments=============================================================="
# kubectl get pods --all-namespaces
# kubectl create ns linkerd #Create a namespace called Linkerd
# linkerd install | kubectl apply -f - #install Linkerd with the Cli tool
#Error from server (NotFound): error when creating "github.com/weaveworks/flagger//kustomize/linkerd": namespaces "linkerd" not found
# kubectl apply -k github.com/weaveworks/flagger//kustomize/linkerd #Install Flagger in the linkerd namespace
# kubectl get pods --all-namespaces

# kubectl -n linkerd rollout status deploy/flagger
#
# kubectl create ns test
# kubectl annotate namespace test linkerd.io/inject=enabled
# kubectl apply -k github.com/weaveworks/flagger//kustomize/tester
# kubectl apply -k github.com/weaveworks/flagger//kustomize/podinfo









# echo "=============================Inspection============================================================="
# - kubectl get pod -o wide #The IP column will contain the internal cluster IP address for each pod.
# - kubectl get service --all-namespaces # find a Service IP,list all services in all namespaces
# #linkerd
# - sudo sh -c "curl -sL https://run.linkerd.io/install | sh" #Install the CLI
# - export PATH=$PATH:$HOME/.linkerd2/bin
# - linkerd version
# - linkerd check --pre #Validate your Kubernetes cluster
# - sudo sh -c "linkerd install | kubectl apply -f -" #Install Linkerd onto the cluster
# - linkerd check
# - sudo kubectl -n linkerd get deploy
# - linkerd dashboard &
# # - linkerd -n linkerd top deploy/linkerd-web
# #Install the demo app
# - sudo sh -c "curl -sL https://run.linkerd.io/emojivoto.yml | kubectl apply -f -"
# - sudo kubectl -n emojivoto port-forward svc/web-svc 8080:80 #forward web-svc locally to port 8080
# #add Linkerd to emojivoto
# - sudo sh -c "kubectl get -n emojivoto deploy -o yaml | linkerd inject - | kubectl apply -f -"
# #Just as with the control plane, it is possible to verify that everything worked the way it should with the data plane
# - linkerd -n emojivoto check --proxy
# - linkerd -n emojivoto stat deploy #see live traffic metrics by running
# - linkerd -n emojivoto top deploy #get a real-time view of which paths are being called:
# - linkerd -n emojivoto tap deploy/web #use tap shows the stream of requests across a single pod, deployment, or even everything in the emojivoto namespace
# #Install Flagger in the linkerd namespace
# - sudo kubectl apply -k github.com/weaveworks/flagger//kustomize/linkerd
# #Create a test namespace and enable Linkerd proxy injection
# - sudo kubectl create ns test
# - sudo kubectl annotate namespace test linkerd.io/inject=enabled
# #Install the load testing service to generate traffic during the canary analysis
# - sudo kubectl apply -k github.com/weaveworks/flagger//kustomize/tester
# #Create a deployment and a horizontal pod autoscaler:
# - sudo kubectl apply -k github.com/weaveworks/flagger//kustomize/podinfo
# #Create a canary custom resource for the podinfo deploymen
# - sudo kubectl apply -f canary/podinfo-canary.yaml
# #Trigger a canary deployment by updating the container image
# - sudo kubectl -n test set image deployment/podinfo podinfod=stefanprodan/podinfo:3.1.1
# - sudo kubectl -n test describe canary/podinfo
# # monitor all canaries
# - watch kubectl get canaries --all-namespaces
# #Automated rollback
# #Trigger another canary deployment
# - sudo kubectl -n test set image deployment/podinfo podinfod=stefanprodan/podinfo:3.1.2
# #Exec into the load tester pod
# # - sudo kubectl -n test exec -it flagger-loadtester-xx-xx sh
# #Generate HTTP 500 errors
# # - watch -n 1 curl http://podinfo-canary.test:9898/status/500
# #Generate latency
# - watch -n 1 curl http://podinfo-canary.test:9898/delay/1
# - kubectl -n test describe canary/podinfo
# #Trigger a canary deployment by updating the container image
# - sudo kubectl -n test set image deployment/podinfo podinfod=stefanprodan/podinfo:3.1.3
# #Generate 404s
# - watch -n 1 curl http://podinfo-canary:9898/status/404
# #Watch Flagger logs
# - sudo kubectl -n linkerd logs deployment/flagger -f | jq .msg
# #There are two ingress controllers that are compatible with both Flagger and Linkerd: NGINX and Gloo
# #Install NGINX
# - sudo helm upgrade -i nginx-ingress stable/nginx-ingress --namespace ingress-nginx
