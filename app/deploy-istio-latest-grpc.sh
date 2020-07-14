#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

# Istio has several optional dashboards installed by the demo installation.
echo "============================Install istio=============================================================="

# mark the working directory
export BASEDIR=$PWD

# https://skaffold.dev/docs/install/
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
install skaffold /usr/local/bin/

kubectl get nodes

skaffold run

kubectl get pods

# curl http://localhost:80 

skaffold delete

