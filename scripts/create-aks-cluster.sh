#!/bin/bash

clear
echo "##### Creating an AKS Cluster #####"
echo "##### COPY THE SUBSCRIPTION ID THAT YOU WANT TO USE! #####"

az login

cd ~/src
# If azure-aks exists as a directory, delete it
[ -d "azure-aks" ] && rm -rf azure-aks
git clone https://github.com/SRodi/azure-aks
cd azure-aks

# Prompt the user for config details
read -p "Enter your subscription ID: " SUBSCRIPTION_ID
echo ""
echo "##### NOTE: It is important that your alias is the same as your Windows username!"
read -p "Enter your alias: " ALIAS
export RESOURCE_GROUP_NAME=$ALIAS-rg
export PREFIX=$ALIAS
echo ""
read -e -i "72f988bf-86f1-41af-91ab-2d7cd011db47" -p "Enter Tenant ID: " TENANT
TENANT="${TENANT:-default_tenant}"
echo ""
read -e -i "uksouth" -p "Enter Location: " LOCATION
LOCATION="${LOCATION:-default_location}"

# Define the contents of the values.tfvars file
cat <<EOL > terraform.tfvars
subscription_id     = "$SUBSCRIPTION_ID"
tenant_id           = "$TENANT"
location            = "$LOCATION"
resource_group_name = "$RESOURCE_GROUP_NAME"
prefix              = "$PREFIX"
labels = {
  environment = "test"
  team        = "devops"
}
EOL

echo ""
echo "##### Running tofu init..."
tofu init

echo ""
echo "##### Running tofu plan..."
tofu plan

echo ""
echo "##### Running tofu apply..."
tofu apply

az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $PREFIX-aks --admin

# Add kubectl path to .bashrc if not already added
if ! grep -q "export KUBECONFIG=/mnt/c/Users/$ALIAS/.kube/config" ~/.bashrc; then
    echo "export KUBECONFIG=/mnt/c/Users/$ALIAS/.kube/config" >> ~/.bashrc
    echo "Added kubectl path to .bashrc"
else
    echo "kubectl path already present in .bashrc"
fi
