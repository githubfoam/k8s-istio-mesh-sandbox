#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

https://github.com/kubernetes-sigs/kind
echo "=============================deploy kind============================================================="
docker version

curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/local/bin/ # Download kubectl
kubectl version --client
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && chmod 700 get_helm.sh && bash get_helm.sh
helm version

export KIND_VERSION="0.8.1"
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v$KIND_VERSION/kind-$(uname)-amd64
chmod +x ./kind

mv ./kind /usr/local/bin/kind
kind get clusters #see the list of kind clusters
kind get clusters
kubectl config get-contexts #kind is prefixed to the context and cluster names, for example: kind-istio-testing
echo "=============================deploy kind============================================================="
