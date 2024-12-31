#!/bin/bash

# This script sets up the Retina repo and installs required dependencies

print_notice() {
    echo ""
    echo "NOTE: "
    echo "- This script does NOT install Docker Desktop, which is a pre-requisite to building Retina."
    echo "- It DOES install Docker engine."
    echo "- To install Docker Desktop you can run 'winget install --id=Docker.DockerDesktop -e' in Powershell, or install through alternative means."
    echo ""
    read -p "Press ENTER to continue with execution or cancel with Ctrl+C"
}

setup_repo() {
    echo ""
    echo "##### Setting up ~/src and Retina repo"
    mkdir -p ~/src && cd ~/src
    # If retina exists as a directory, delete it
    [ -d "retina" ] && rm -rf retina

    red -p "Enter your GitHub username where your Retina fork exists: " GH_USER

    # Clone your fork of retina
    git clone https://github.com/$GH_USER/retina.git
    cd retina
    git remote add upstream https://github.com/microsoft/retina.git
    cd ../..
}

install_dependencies() {
    echo ""
    echo "##### Installing llvm / clang / jq ..."
    sudo apt-get install -y llvm clang jq

    install_docker
    install_helm
    install_go
    install_kubectl
    install_krew
    install_gh
    install_tofu
}

remove_conflicting_docker_packages() {
    echo "Removing conflicting packages..."
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
        sudo apt-get remove -y $pkg
    done
}

install_docker() {
    echo ""
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
    echo ""
    echo "##### Installing Helm..."
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    rm get_helm.sh
}

install_go() {
    echo ""
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

install_kubectl() {
    echo ""
    echo "##### Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
}

install_krew() {
    echo ""
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
    echo ""
    echo "##### Installing gh cli..."
    sudo apt install gh
}

install_tofu() {
    echo ""
    echo "##### Installing OpenTofu..."
    echo -e "[boot]\nsystemd=true" | sudo tee /etc/wsl.conf
    source ~/.bashrc
    sudo snap install --classic opentofu
}

test_installations() {
    echo ""
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
        ["tofu"]="which tofu"
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

main() {
    clear
    echo "##### Setting up Retina repo and dependencies..."  
    print_notice
    setup_repo
    install_dependencies
    test_installations
}

main