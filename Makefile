IMAGE := alpine/fio
APP:="app/deploy-openesb.sh"

deploy-istio:
	bash app/deploy-istio.sh

deploy-istio-latest:
	bash app/deploy-istio-latest.sh

deploy-kind:
	bash platform/deploy-kind.sh

deploy-kind-latest:
	bash platform/deploy-kind-latest.sh

deploy-minikube:
	bash platform/deploy-minikube.sh

deploy-minikube-latest:
	bash platform/deploy-minikube-latest.sh

.PHONY: deploy-minikube deploy-istio push-image
