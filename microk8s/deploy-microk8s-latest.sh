#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

echo "=============================microk8s latest============================================================="
# snap install microk8s --classic --channel=1.18/stable
usermod -a -G microk8s $USER #add your current user to the group and gain access to the .kube caching directory
# chown -f -R $USER ~/.kube
# - su - $USER # re-enter the session for the group update to take place
microk8s status --wait-ready #Check the status

# echo "Waiting for Kubernetes to be ready ..."
# for i in {1..150}; do # Timeout after 5 minutes, 150x2=300 secs
#     watch -d sudo microk8s kubectl get all --all-namespaces
#     sleep 2
# done

microk8s kubectl get nodes
microk8s kubectl get services
# - alias kubectl='microk8s kubectl' #add an alias (append to ~/.bash_aliases)
# microk8s  kubectl create deployment my-dep --image=busybox
microk8s kubectl get pods #Check the status

# echo "=============================microk8s istio============================================================="
# - yes | sudo microk8s enable istio     #Enforce mutual TLS authentication (https://bit.ly/2KB4j04) between sidecars? If unsure, choose N. (y/N):
# #Istio needs to inject sidecars to the pods of your deployment
# #In microk8s auto-injection is supported  label the namespace you will be using with istion-injection=enabled
# microk8s kubectl label namespace default istio-injection=enabled
# - wget https://raw.githubusercontent.com/istio/istio/release-1.0/samples/bookinfo/platform/kube/bookinfo.yaml  #the bookinfo example from the v1.0 Istio release
# microk8s.kubectl create -f bookinfo.yaml
# #reach the services using the ClusterIP they have
# #for example get to the productpage in the above example by pointing our browser to 10.152.183.59:9080
# microk8s kubectl get svc
# - wget https://raw.githubusercontent.com/istio/istio/release-1.0/samples/bookinfo/networking/bookinfo-gateway.yaml #exposing the services via NodePort:
# microk8s kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}' 31380 #get to the productpage through ingress
# - curl http://localhost:31380/productpage
# # - nc http://localhost:31380/productpage
# microk8s kubectl -n istio-system get svc grafana
# microk8s kubectl -n istio-system get svc prometheus
# microk8s kubectl -n istio-system get service/jaeger-query
# microk8s kubectl -n istio-system get servicegraph
# # -  sudo microk8s enable dns cilium dashboard fluentd helm helm3 ingress istio jaeger knative kubeflow metallb metrics-server prometheus rbac registry storage #Use add-ons istio
# # - microk8s stop
# # - microk8s start
# # microk8s enable dns dashboard registry #Turn on standard services
# # - watch microk8s.kubectl get all --all-namespaces #check deployment progress
# - echo "=========================================================================================="
# microk8s kubectl version
# microk8s kubectl version --client #the version of the client
# microk8s kubectl cluster-info
# - echo "=========================================================================================="
# - |
#   echo "Waiting for Kubernetes to be ready ..."
#   for i in {1..150}; do # Timeout after 5 minutes, 150x2=300 secs
#     if sudo microk8s kubectl get pods --namespace=kube-system | grep Running ; then
#       break
#     fi
#     sleep 2
#   done
# microk8s kubectl get all --all-namespaces
# microk8s kubectl run nginx --image nginx --replicas 3
# microk8s kubectl get all --all-namespaces
