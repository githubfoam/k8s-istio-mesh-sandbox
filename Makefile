IMAGE := alpine/fio
APP:="app/deploy-openesb.sh"

deploy-microk8s-istio:
	bash microk8s/deploy-microk8s-istio.sh

deploy-microk8s-latest:
	bash microk8s/deploy-microk8s-latest.sh

deploy-istio:
	bash app/deploy-istio.sh

deploy-istio-latest:
	bash app/deploy-istio-latest.sh

deploy-k3d-latest:
	bash platform/deploy-k3d-latest.sh

deploy-kind-kubectl-helm-latest:
	bash platform/deploy-kind-kubectl-helm-latest.sh

deploy-kind-kubectl-helm:
	bash platform/deploy-kind-kubectl-helm.sh

deploy-kind:
	bash platform/deploy-kind.sh

deploy-minikube:
	bash platform/deploy-minikube.sh

deploy-minikube-latest:
	bash platform/deploy-minikube-latest.sh

.PHONY: deploy-minikube deploy-istio push-image
