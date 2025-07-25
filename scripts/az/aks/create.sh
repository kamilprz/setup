#!/bin/bash

# Create an AKS cluster using the tofu CLI

echo "##### Creating an AKS Cluster #####"
echo "##### COPY THE SUBSCRIPTION ID THAT YOU WANT TO USE! #####"

az login

TFVARS_FILE="terraform.tfvars"

if [[ -f "$TFVARS_FILE" ]]; then
    echo "##### $TFVARS_FILE found. Using values from it."

    SUBSCRIPTION_ID=$(grep -oP 'subscription_id\s*=\s*"\K[^"]+' "$TFVARS_FILE")
    TENANT=$(grep -oP 'tenant_id\s*=\s*"\K[^"]+' "$TFVARS_FILE")
    LOCATION=$(grep -oP 'location\s*=\s*"\K[^"]+' "$TFVARS_FILE")
    RESOURCE_GROUP_NAME=$(grep -oP 'resource_group_name\s*=\s*"\K[^"]+' "$TFVARS_FILE")
    PREFIX=$(grep -oP 'prefix\s*=\s*"\K[^"]+' "$TFVARS_FILE")

    echo ""
    echo "Subscription ID: $SUBSCRIPTION_ID"
    echo "Tenant ID: $TENANT"
    echo "Location: $LOCATION"
    echo "Resource Group Name: $RESOURCE_GROUP_NAME"
    echo "Prefix: $PREFIX"
else
  # Prompt the user for config details
  read -p "Enter your subscription ID: " SUBSCRIPTION_ID
  echo ""
  read -p "Enter your alias: " ALIAS
  export RESOURCE_GROUP_NAME=$ALIAS-dev-rg
  export PREFIX=$ALIAS
  echo ""
  read -e -i "72f988bf-86f1-41af-91ab-2d7cd011db47" -p "Enter Tenant ID: " TENANT
  TENANT="${TENANT:-default_tenant}"
  echo ""
  read -e -i "uksouth" -p "Enter Location: " LOCATION
  LOCATION="${LOCATION:-default_location}"
fi

# Define the contents of the values.tfvars file
cat <<EOL > $TFVARS_FILE
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
if ! tofu init; then
    echo "Error: tofu init failed."
    exit 1
fi

echo ""
echo "##### Running tofu plan..."
tofu plan

echo ""
echo "##### Running tofu apply..."
tofu apply --auto-approve

az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $PREFIX-aks --admin

read -e -i "$PREFIX" -p "Enter Username (for exporting kubeconfig): " USERNAME
USERNAME="${USERNAME:-default_username}"

# Bash by default
SHRC_FILE="$HOME/.bashrc"
# If current shell is ZSH, use .zshrc
if [[ "$(which $SHELL)" == *"zsh"* ]]; then
    SHRC_FILE="$HOME/.zshrc"
fi

# Add kubectl path to .*shrc if not already added
if ! grep -q "export KUBECONFIG=/mnt/c/Users/.*/.kube/config" $SHRC_FILE; then
    echo "export KUBECONFIG=/mnt/c/Users/$USERNAME/.kube/config" >> $SHRC_FILE
    echo "Added kubectl path to $SHRC_FILE"
else
    echo "kubectl path already present in .$SHRC_FILE"
fi
