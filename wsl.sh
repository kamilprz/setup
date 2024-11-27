#!/bin/bash

update_system() {
    echo "##### Running apt-get update and upgrade..."
    sudo apt-get update -y
    sudo apt-get upgrade -y
}

setup_repos() {
    echo "##### Setting up ~/src and repos"
    mkdir -p ~/src && cd ~/src
    # If retina exists as a directory, delete it
    [ -d "retina" ] && rm -rf retina
    # Clone my fork of retina
    git clone https://github.com/kamilprz/retina.git
    cd retina
    git remote add upstream https://github.com/microsoft/retina.git
    cd ../..
}

remove_conflicting_docker_packages() {
    echo "Removing conflicting packages..."
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
        sudo apt-get remove -y $pkg
    done
}

install_docker() {
    echo "##### Installing Docker..."
    remove_conflicting_docker_packages
    # Set up Docker through apt - https://docs.docker.com/engine/install/ubuntu/
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    # Test on Hello World image
    sudo docker run hello-world
}

install_helm() {
    echo "##### Installing Helm..."
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    rm get_helm.sh
}

install_go() {
    echo "##### Installing Golang..."
    local go_file="go1.23.1.linux-amd64.tar.gz"
    local download_dir="/tmp/go_install"
    local go_url="https://dl.google.com/go/$go_file"

    mkdir -p "$download_dir"
    cd "$download_dir"

    if [ ! -f "$go_file" ]; then
        echo "Downloading $go_file to $download_dir..."
        wget "$go_url"
    else
        echo "$go_file already exists in $download_dir"
    fi

    # Remove any existing Go installation and extract the new one
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "$go_file"
    export PATH=$PATH:/usr/local/go/bin

    # Add Go binary path to .bashrc if not already added
    if ! grep -q 'export PATH=$PATH:/usr/local/go/bin' ~/.bashrc; then
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
        echo "Added Go binary path to .bashrc"
    else
        echo "Go binary path already present in .bashrc"
    fi

    # Return to the original directory
    cd -
}

install_dependencies() {
    echo "##### Installing llvm / clang / jq ..."
    sudo apt-get install -y llvm clang jq
    install_helm
    install_go
    install_kubectl
    install_krew
    install_gh
}

install_kubectl() {
    echo "##### Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
}

install_krew() {
    echo "##### Installing krew..."
    (
        set -x
        cd "$(mktemp -d)"
        OS="$(uname | tr '[:upper:]' '[:lower:]')"
        ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
        KREW="krew-${OS}_${ARCH}"
        curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"
        tar zxvf "${KREW}.tar.gz"
        ./"${KREW}" install krew
    )
    
    # Add Krew binary path to .bashrc if not already added
    if ! grep -q 'export PATH="\${KREW_ROOT:-\$HOME/.krew}/bin:\$PATH"' ~/.bashrc; then
        echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.bashrc
        echo "Added Krew binary path to .bashrc"
    else
        echo "Krew binary path already present in .bashrc"
    fi
}

install_gh() {
    # https://github.com/cli/cli/blob/trunk/docs/install_linux.md
    sudo apt install gh
}

install_yarn() {
    curl -o- -L https://yarnpkg.com/install.sh | bash
}

test_installations() {
    echo "##### Testing Installations #####"
    declare -A commands=( 
        ["Go"]="which go"
        ["llvm-strip"]="which llvm-strip"
        ["clang"]="which clang"
        ["jq"]="which jq"
        ["helm"]="which helm"
        ["Docker"]="which docker"
        ["kubectl"]="which kubectl"
        ["gh"]="which gh"
    )
    printf "%-15s\t%-30s\n" "Dependency" "Path"
    echo "-----------------------------------------------------------"
    for dependency in "${!commands[@]}"; do
        path=$(${commands[$dependency]} 2>/dev/null)
        if [ -z "$path" ]; then
            path="Missing..."
        fi
        printf "%-15s\t%-30s\n" "$dependency" "$path"
    done
}

configure_ghcr() {
    echo ""
    echo "##### Configuring GHCR Credentials #####"
    echo "Go to https://github.com/settings/tokens/new and create a token with the following scopes:"
    echo "- repo"
    echo "- workflows"
    echo "- write:packages"
    echo "- delete:packages"
    echo ""
    read -p "Enter your GHCR token: " USER_INPUT
    export CR_PAT=$USER_INPUT
    echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
}

configure_git(){
    echo ""
    echo "##### Setting up Git #####"

    echo "##### Use same email on GPG as on Git #####"

    read -p "Enter your GH email: " USER_EMAIL
    git config --global user.email "$USER_EMAIL"
    read -p "Enter your GH name: " USER_NAME
    git config --global user.name "$USER_NAME"

    git config --global --unset gpg.format

    sudo apt-get -y install gnupg
    gpg --full-generate-key

    echo ""
    echo "##### Setting up GPG key to sign commits #####"
    echo "From the list of GPG keys, copy the long form of the GPG key ID you'd like to use - e.g. sec   4096R/***3AA5C34371567BD2 ***"
    gpg --list-secret-keys --keyid-format=long

    read -p "Enter the long form of the GPG key ID: " GPG_KEY
    gpg --armor --export $GPG_KEY

    echo ""
    echo "##### Copy your GPG key, beginning with -----BEGIN PGP PUBLIC KEY BLOCK----- and ending with -----END PGP PUBLIC KEY BLOCK-----. #####"
    echo "##### Add the key to your GitHub account. https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-gpg-key-to-your-github-account #####"

    cd ~/src/retina
    git config user.signingkey $GPG_KEY
    git config --add commit.gpgsign true

    [ -f ~/.bashrc ] && echo -e '\nexport GPG_TTY=$(tty)' >> ~/.bashrc

    echo ""
    echo "##### Logging into GitHub CLI #####"
    gh auth login
}

main() {
    update_system
    setup_repos
    install_docker
    install_dependencies
    test_installations
    configure_ghcr
    configure_git
    source ~/.bashrc
}

main

### Install zsh