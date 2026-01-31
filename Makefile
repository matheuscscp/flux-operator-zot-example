##@ General

CLUSTER_NAME := "staging"
CLUSTER_CONTEXT := "kind-$(CLUSTER_NAME)"

.PHONY: bootstrap
bootstrap: ## Bootstrap cluster.
	kind create cluster \
		--name=$(CLUSTER_NAME)
	helm install flux-operator oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator \
		--kube-context=$(CLUSTER_CONTEXT) \
		--namespace=flux-system \
		--create-namespace
	kubectl config set-context $(CLUSTER_CONTEXT) \
		--namespace=flux-system
	yq 'del(.spec.kustomize.patches[-1])' \
		clusters/$(CLUSTER_NAME)/flux-system/flux-instance.yaml | \
		kubectl apply \
			--context=$(CLUSTER_CONTEXT) \
			--filename=-

.PHONY: delete
delete: ## Delete cluster.
	kind delete cluster \
		--name=$(CLUSTER_NAME)

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
