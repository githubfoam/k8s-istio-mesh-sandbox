#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

#https://istio.io/docs/setup/platform-setup/kind/
#https://kind.sigs.k8s.io/docs/user/quick-start/
#https://istio.io/docs/setup/getting-started/
echo "=============================deploy kind============================================================="
docker version
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.8.1/kind-$(uname)-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind
kind get clusters #see the list of kind clusters
kind create cluster --name istio-testing #Create a cluster,By default, the cluster will be given the name kind
kind get clusters
snap install kubectl --classic
kubectl config get-contexts #list the local Kubernetes contexts
kubectl config use-context kind-istio-testing #run following command to set the current context for kubectl
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml #deploy Dashboard

echo "===============================Waiting for Dashboard to be ready==========================================================="
kubectl get service --all-namespaces #list all services in all namespace
|
            for i in {1..60}; do # Timeout after 5 minutes, 60x2=120 secs, 2 mins
              if kubectl get pods --namespace=kubernetes-dashboard |grep Running && \
                 kubectl get pods --namespace=dashboard-metrics-scraper |grep Running ; then
                break
              fi
              sleep 2
            done
kubectl get pod -n kubernetes-dashboard #Verify that Dashboard is deployed and running
kubectl create clusterrolebinding default-admin --clusterrole cluster-admin --serviceaccount=default:default #Create a ClusterRoleBinding to provide admin access to the newly created cluster
          #To login to Dashboard, you need a Bearer Token. Use the following command to store the token in a variable
token=$(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base64 --decode)
echo $token #Display the token using the echo command and copy it to use for logging into Dashboard.
apt-get install net-tools -qqy #Install netcat
kubectl proxy & # Access Dashboard using the kubectl command-line tool by running the following command, Starting to serve on 127.0.0.1:8001
|
            for i in {1..60}; do # Timeout after 1 mins, 60x1=60 secs
              if nc -z -v 127.0.0.1 8001 2>&1 | grep succeeded ; then
                break
              fi
              sleep 1
            done
echo "===============================Install istio==========================================================="
curl -L https://istio.io/downloadIstio | sh - #Download Istio

cd istio-* #Move to the Istio package directory. For example, if the package is istio-1.6.0
export PATH=$PWD/bin:$PATH #Add the istioctl client to your path, The istioctl client binary in the bin/ directory.
          #precheck inspects a Kubernetes cluster for Istio install requirements
istioctl experimental precheck #https://istio.io/docs/reference/commands/istioctl/#istioctl-experimental-precheck
          #Begin the Istio pre-installation verification check
          # - istioctl verify-install #Error: could not load IstioOperator from cluster: the server could not find the requested resource.  Use --filename
istioctl version
istioctl manifest apply --set profile=demo #Install Istio, use the demo configuration profile
kubectl label namespace default istio-injection=enabled #Add a namespace label to instruct Istio to automatically inject Envoy sidecar proxies when you deploy your application later
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml #Deploy the Bookinfo sample application:
kubectl get service --all-namespaces #list all services in all namespace
kubectl get services #The application will start. As each pod becomes ready, the Istio sidecar will deploy along with it.
kubectl get pods

for i in {1..60}; do # Timeout after 5 minutes, 60x2=120 secs, 2 mins
          if kubectl get pods --namespace=istio-system |grep Running ; then
                break
          fi
              sleep 2
done
kubectl get service --all-namespaces #list all services in all namespace


          # - |
          #   kubectl exec -it $(kubectl get pod \
          #                -l app=ratings \
          #                -o jsonpath='{.items[0].metadata.name}') \
          #                -c ratings \
          #                -- curl productpage:9080/productpage | grep -o "<title>.*</title>" <title>Simple Bookstore App</title>
          #Open the application to outside traffic
          #The Bookinfo application is deployed but not accessible from the outside. To make it accessible, you need to create an Istio Ingress Gateway, which maps a path to a route at the edge of your mesh.
          # - kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml #Associate this application with the Istio gateway
          # - istioctl analyze #Ensure that there are no issues with the configuration
          #Determining the ingress IP and ports
          #If the EXTERNAL-IP value is set, your environment has an external load balancer that you can use for the ingress gateway.
          # - kubectl get svc istio-ingressgateway -n istio-system #determine if your Kubernetes cluster is running in an environment that supports external load balancers
          # #Follow these instructions if you have determined that your environment has an external load balancer.
          # # If the EXTERNAL-IP value is <none> (or perpetually <pending>), your environment does not provide an external load balancer for the ingress gateway,access the gateway using the service’s node port.
          # - export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
          # - export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
          # - export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
          # #In certain environments, the load balancer may be exposed using a host name, instead of an IP address.
          # #the ingress gateway’s EXTERNAL-IP value will not be an IP address, but rather a host name
          # #failed to set the INGRESS_HOST environment variable, correct the INGRESS_HOST value
          # - export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
          # #Follow these instructions if your environment does not have an external load balancer and choose a node port instead
          # - export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}') #Set the ingress ports
          # - export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}') #Set the ingress ports
          # - export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT #Set GATEWAY_URL
          # - echo $GATEWAY_URL #Ensure an IP address and port were successfully assigned to the environment variable
          # # - echo http://$GATEWAY_URL/productpage #Verify external access,retrieve the external address of the Bookinfo application
          # - istioctl dashboard kiali #optional dashboards installed by the demo installation,Access the Kiali dashboard. The default user name is admin and default password is admin
          # #The Istio uninstall deletes the RBAC permissions and all resources hierarchically under the istio-system namespace
          # #It is safe to ignore errors for non-existent resources because they may have been deleted hierarchically.
          # - 'istioctl manifest generate --set profile=demo | kubectl delete -f -'
          # - kubectl delete namespace istio-system #The istio-system namespace is not removed by default. If no longer needed, use the following command to remove it
          # - kubectl get virtualservices   #-- there should be no virtual services
          # - kubectl get destinationrules  #-- there should be no destination rules
          # - kubectl get gateway           #-- there should be no gateway
          # - kubectl get pods              #-- the Bookinfo pods should be deleted
          # #Bookinfo cleanup starts
          # - |
          #   SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
          #   # only ask if in interactive mode
          #   if [[ -t 0 && -z ${NAMESPACE} ]];then
          #     echo -n "namespace ? [default] "
          #     read -r NAMESPACE
          #   fi
          #   if [[ -z ${NAMESPACE} ]];then
          #     NAMESPACE=default
          #   fi
          #   echo "using NAMESPACE=${NAMESPACE}"
          #   protos=( destinationrules virtualservices gateways )
          #   for proto in "${protos[@]}"; do
          #     for resource in $(kubectl get -n ${NAMESPACE} "$proto" -o name); do
          #       kubectl delete -n ${NAMESPACE} "$resource";
          #     done
          #   done
          #   OUTPUT=$(mktemp)
          #   export OUTPUT
          #   echo "Application cleanup may take up to one minute"
          #   kubectl delete -n ${NAMESPACE} -f "$SCRIPTDIR/bookinfo.yaml" > "${OUTPUT}" 2>&1
          #   ret=$?
          #   function cleanup() {
          #     rm -f "${OUTPUT}"
          #   }
          #   trap cleanup EXIT
          #   if [[ ${ret} -eq 0 ]];then
          #     cat "${OUTPUT}"
          #   else
          #     # ignore NotFound errors
          #     OUT2=$(grep -v NotFound "${OUTPUT}")
          #     if [[ -n ${OUT2} ]];then
          #       cat "${OUTPUT}"
          #       exit ${ret}
          #     fi
          #   fi
          #   echo "Application cleanup successful"
          # - kubectl get virtualservices   #-- there should be no virtual services
          # - kubectl get destinationrules  #-- there should be no destination rules
          # - kubectl get gateway           #-- there should be no gateway
          # - kubectl get pods              #-- the Bookinfo pods should be deleted
          #Bookinfo cleanup ends
          # - echo "===============================Adding Heapster Metrics to the Kubernetes Dashboard==========================================================="
          # - sudo snap install helm --classic && helm init
          # - kubectl create serviceaccount --namespace kube-system tiller #Create a service account
          # - kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller #Bind the new service account to the cluster-admin role. This will give tiller admin access to the entire cluster
          # - kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}' #Deploy tiller and add the line serviceAccount: tiller to spec.template.spec
          # - helm install --name heapster stable/heapster --namespace kube-system #install Heapster
kind delete cluster --name istio-testing #delete the existing cluster