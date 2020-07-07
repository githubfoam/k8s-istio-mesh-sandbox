IMAGE := alpine/fio
APP:="app/deploy-openesb.sh"

deploy-istio:
	bash app/deploy-istio.sh

deploy-istio-latest:
	bash app/deploy-istio-latest.sh

deploy-kind:
	bash kind/deploy-kind.sh

deploy-kind-latest:
		bash kind/deploy-kind-latest.sh

deploy-minikube:
	bash minikube/deploy-minikube.sh

deploy-minikube-latest:
	bash minikube/deploy-minikube-latest.sh

.PHONY: deploy-minikube deploy-istio push-image
