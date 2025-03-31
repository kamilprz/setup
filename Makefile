.PHONY: help aks-cluster

DEFAULT_GOAL := help

help: ## Display help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

aks-cluster: ## Recreate an AKS Cluster
	clear; \
	echo "Creating AKS Cluster..."; \
	echo "First running tofu destroy..."; \
	cd ./scripts/az/aks && tofu destroy && bash create.sh && cd -

ghcr: ## Configure GHCR credentials
	bash ./scripts/ubuntu/configure_ghcr.sh;

gpg: ## Configure GPG signing key
	bash ./scripts/ubuntu/configure_gpg.sh

shell: ## Configure Oh-my-posh
	bash ./scripts/ubuntu/omp.sh ./themes/kamp.omp.yaml