IMAGE := alpine/fio
APP:="app/deploy-openesb.sh"

deploy-istio:
	bash app/deploy-istio.sh

deploy-istio-latest:
	bash app/deploy-istio-latest.sh

deploy-minikube:
	bash app/deploy-minikube.sh

deploy-minikube-latest:
	bash app/deploy-minikube-latest.sh

.PHONY: deploy-minikube deploy-istio push-image
