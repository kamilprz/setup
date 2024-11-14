#!/bin/bash

echo "##### COPY THE SUBSCRIPTION ID THAT YOU WANT TO USE! #####"

az login

cd ~/src
# If azure-aks exists as a directory, delete it
[ -d "azure-aks" ] && rm -rf azure-aks
git clone https://github.com/SRodi/azure-aks
cd azure-aks
# Prompt the user for the subscription ID
read -p "Enter your subscription ID: " SUBSCRIPTION_ID

# Define the contents of the values.tfvars file
cat <<EOL > terraform.tfvars
subscription_id     = "$SUBSCRIPTION_ID"
tenant_id           = "72f988bf-86f1-41af-91ab-2d7cd011db47"
location            = "uksouth"
resource_group_name = "kamilp-rg"
prefix              = "kamilp"
labels = {
  environment = "test"
  team        = "devops"
}
EOL

sudo snap install --classic opentofu

tofu init

tofu plan

tofu apply