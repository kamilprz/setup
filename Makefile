SHELL := bash
DEFAULT_GOAL := help

.PHONY: help
help: ## Display help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Azure

.PHONY: aks-cluster
aks-cluster: ## Recreate an AKS Cluster
	clear; \
	echo "Creating AKS Cluster..."; \
	echo "First running tofu destroy..."; \
	cd ./scripts/az/aks && tofu destroy && bash create.sh && cd -

##@ Git

.PHONY: ghcr
ghcr: ## Configure GHCR credentials
	bash ./scripts/linux/ghcr.sh

.PHONY: gpg
gpg: ## Configure GPG signing key
	bash ./scripts/linux/gpg.sh

##@ Setup

.PHONY: deps
deps: ## Install dependencies
	echo "##### Installing llvm / clang / jq ..."; \
	sudo apt-get install -y llvm clang jq; \
	echo ""; \
	echo "#### Installing Golang ..."; \
	sudo snap install go --classic; \

.PHONY: dotfiles
dotfiles: ## Create symlinks for dotfiles
	bash ./scripts/linux/dotfiles.sh

.PHONY: new
new: ## Configure a new setup environment from scratch
	clear; \
	echo "##### NOTE #####"; \
	echo "If you decide to change your shell, open a new terminal instance and come back to this script from there."; \
	echo "Bash: chbash"; \
	echo "Zsh:  chzsh  (To install: sudo apt install zsh)"; \
	echo ""; \
	read -p "Your SHELL is $$(which $$SHELL). Do you want to proceed? (Y/n) " -n 1 -r; \
    echo; \
    if [[ ! $$REPLY =~ ^[Yy]$$ ]]; then \
        echo "Aborting."; \
        exit 1; \
    fi; \
	echo ""; \
	echo "##### Running apt-get update and upgrade... #####"; \
	sudo apt-get -y update; \
	sudo apt-get -y upgrade; \
	make dotfiles; \
	make tools; \
	make deps; \
	make omp; \

.PHONY: tools
tools: ## Install tools
	echo "##### Setting up tools... #####"; \
	echo "##### Installing bat (batcat) / fzf / lsd ... #####"; \
	sudo apt-get -y install bat fzf lsd; \

##@ Shell

.PHONY: omp
omp: ## Set up Oh-my-posh theme
	bash ./scripts/linux/omp.sh ./dotfiles/.config/oh-my-posh/kamp.omp.yaml
	
##@ Test

remove-dotfiles: ## Remove symlinks for dotfiles
	rm ~/.bashrc; \
	rm ~/.zshrc; \
	rm ~/.shell_aliases; \
	rm -rf ~/.config; \
	rm ~/.gitconfig; \