#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

echo "=============================deploy kubectl============================================================="

export KUBECTL_VERSION="1.18.3"
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/ # Download kubectl
kubectl version --client

echo "=============================deploy helm============================================================="


export HELM_VERSION="2.16.9"
wget -nv https://get.helm.sh/helm-v$HELM_VERSION-linux-amd64.tar.gz && tar xvzf helm-v$HELM_VERSION-linux-amd64.tar.gz && mv linux-amd64/helm linux-amd64/tiller /usr/local/bin
helm version
# Error: Get "http://localhost:8080/api/v1/namespaces/kube-system/pods?labelSelector=app%3Dhelm%2Cname%3Dtiller": dial tcp 127.0.1.1:8080: connect: connection refused

echo "=============================deploy kind ============================================================="

docker version
export KIND_VERSION="0.8.1"
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v$KIND_VERSION/kind-$(uname)-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind

kind get clusters #see the list of kind clusters
kind get clusters
kubectl config get-contexts #kind is prefixed to the context and cluster names, for example: kind-istio-testing

