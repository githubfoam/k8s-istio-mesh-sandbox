#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script


echo "===============================Deploy keycloak==========================================================="

# Error: no Kiali pods found
#X Exiting due to ENV_DRIVER_CONFLICT: 'none' driver does not support 'minikube docker-env' command
# eval $(minikube docker-env) 

kubectl create namespace fruits-catalog

kubectl create -f app/mongodb-deployment.yml -n fruits-catalog

# mvn: command not found
# mvn fabric8:deploy -Popenshift -Dfabric8.mode=kubernetes -Dfabric8.namespace=fruits-catalog

echo "===============================Deploy keycloak finished7==========================================================="