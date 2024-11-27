#!/bin/bash

echo "##### Creating an AKS Cluster #####"
echo "##### COPY THE SUBSCRIPTION ID THAT YOU WANT TO USE! #####"

az login

cd ~/src
# If azure-aks exists as a directory, delete it
[ -d "azure-aks" ] && rm -rf azure-aks
git clone https://github.com/SRodi/azure-aks
cd azure-aks
# Prompt the user for the subscription ID
read -p "Enter your subscription ID: " SUBSCRIPTION_ID

export RESOURCE_GROUP_NAME=kamilp-rg
export PREFIX=kamilp

# Define the contents of the values.tfvars file
cat <<EOL > terraform.tfvars
subscription_id     = "$SUBSCRIPTION_ID"
tenant_id           = "72f988bf-86f1-41af-91ab-2d7cd011db47"
location            = "uksouth"
resource_group_name = "$RESOURCE_GROUP_NAME"
prefix              = "$PREFIX"
labels = {
  environment = "test"
  team        = "devops"
}
EOL

sudo snap install --classic opentofu

tofu init

tofu plan

tofu apply

az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $PREFIX-aks --admin

export KUBECONFIG=/mnt/c/Users/kamilp/.kube/config

# Add kubectl path to .bashrc if not already added
if ! grep -q 'export KUBECONFIG=/mnt/c/Users/kamilp/.kube/config' ~/.bashrc; then
    echo 'export KUBECONFIG=/mnt/c/Users/kamilp/.kube/config' >> ~/.bashrc
    echo "Added kubectl path to .bashrc"
else
    echo "kubectl path already present in .bashrc"
fi
