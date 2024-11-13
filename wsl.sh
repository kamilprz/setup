#!/bin/bash

### Update and Upgrade apt-get
echo "##### Running apt-get update and upgrade..."
sudo apt-get update
sudo apt-get upgrade


### Set up source code and repos
echo "##### Setting up ~/src and repos"
# Go to /src, creating it if needed
mkdir -p ~/src && cd ~/src
# If retina exists as a directory, delete it
[ -d "retina" ] && rm -rf retina
# Clone my fork of retina
git clone https://github.com/kamilprz/retina.git
cd /retina
git config --add commit.gpgsign true

cd ../..

### Install Docker
# Delete existing/conflicting packages
echo "Removing conflicting packages"
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
# Set up Docker through apt - https://docs.docker.com/engine/install/ubuntu/
# Add Docker's official GPG key:
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
# Install Docker package
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# Test
sudo docker run hello-world


### Install helm
echo "##### Installing helm"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh


### Install Retina dependencies
# Install Go
echo "##### Installing Golang"
if [ ! -f "go1.23.1.linux-amd64.tar.gz" ]; then
    sudo wget https://dl.google.com/go/go1.23.1.linux-amd64.tar.gz
fi
sudo rm -rf /usr/local/go 
sudo tar -C /usr/local -xzf /home/kamilp/go1.23.1.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
# Install llvm
echo "##### Installing llvm"
sudo apt-get install llvm
# Install clang
echo "##### Installing clang"
sudo apt-get install clang
# Install jq
echo "##### Installing jq"
sudo apt install jq

echo ""

### Test Installations
echo "##### Testing Installations #####"
declare -A commands=( 
    ["Go"]="which go"
    ["llvm-strip"]="which llvm-strip"
    ["clang"]="which clang"
    ["jq"]="which jq"
    ["helm"]="which helm"
    ["Docker"]="which docker"
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

echo ""
echo "##### GHCR Credentials Config #####"
echo "To create a new GHCR token and use it, go to https://github.com/settings/tokens/new 
Set the following: 
- repo 
- write:packages 
- delete:packages"
 
echo ""

read -p "Enter your GHCR token: " USER_INPUT
export CR_PAT=$USER_INPUT 
echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin



### Set up GPG key

### Set up AKS cluster & kubectl

### Install zsh