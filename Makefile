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
	bash k3d/deploy-k3d-latest.sh

deploy-kind:
	bash platform/deploy-kind.sh

deploy-minikube:
	bash minikube/deploy-minikube.sh

deploy-minikube-latest:
	bash minikube/deploy-minikube-latest.sh

.PHONY: deploy-minikube deploy-istio push-image
