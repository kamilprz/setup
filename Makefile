DEFAULT_GOAL := help

.PHONY: help
help: ## Display help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Local Setup

.PHONY: shell
shell: ## Configure Oh-my-posh
	bash ./scripts/ubuntu/omp.sh ./themes/kamp.omp.yaml

.PHONY: dotfiles
dotfiles: ## Create symlinks for dotfiles
	ln -s $(realpath ./dotfiles/.bashrc)           	~/.bashrc; \
	ln -s $(realpath ./dotfiles/.bash_aliases)     	~/.bash_aliases; \
	ln -s $(realpath ./dotfiles/.gitconfig)        	~/.gitconfig; \
	ln -s $(realpath ./dotfiles/.config)        	~/.config;

# For Testing
remove-dotfiles: ## Remove symlinks for dotfiles
	rm ~/.bashrc; \
	rm ~/.bash_aliases; \
	rm ~/.gitconfig; \
	rm -rf ~/.config;

.PHONY: ghcr
ghcr: ## Configure GHCR credentials
	bash ./scripts/ubuntu/configure_ghcr.sh;

.PHONY: gpg
gpg: ## Configure GPG signing key
	bash ./scripts/ubuntu/configure_gpg.sh

##@ AKS

.PHONY: aks-cluster
aks-cluster: ## Recreate an AKS Cluster
	clear; \
	echo "Creating AKS Cluster..."; \
	echo "First running tofu destroy..."; \
	cd ./scripts/az/aks && tofu destroy && bash create.sh && cd -

store-demo: ## Deploy Store Demo - https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-cli
	kubectl create ns pets; \
	kubectl apply -f ./scripts/az/aks/store-demo/aks-store.yaml -n pets; \
	bash ./scripts/az/aks/store-demo/get-ip.sh;
	
delete-store-demo:
	kubectl delete -f ./scripts/az/aks/store-demo/aks-store.yaml -n pets

get-retina-capture:
	@echo "Starting retina capture retrieval..."
	@if [ -z "$(FILE)" ]; then \
		echo "Error: Capture tarball name is required."; \
		exit 1; \
	fi
	kubectl apply -f ./scripts/az/aks/middleware/retrieve.yaml && kubectl cp default/retriever:/mnt/data/retina/captures/$(FILE) ~/src/output/$(FILE); \
	cd ~/src/output && tar -xvf $(FILE);

