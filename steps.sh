# Variables
RESOURCE_GROUP="ado-agents-on-aks"
AKS_NAME="ado-agents-cluster"
LOCATION="uksouth"

# Create a resource group
az group create \
--name $RESOURCE_GROUP \
--location $LOCATION

# Create AKS cluster with KEDA enabled
az aks create \
--resource-group $RESOURCE_GROUP \
--name $AKS_NAME \
--enable-keda \
--generate-ssh-keys

# Get the credentials for the AKS cluster
az aks get-credentials \
--resource-group $RESOURCE_GROUP \
--name $AKS_NAME

# Install Azure DevOps extension for Azure CLI
az extension add --name azure-devops

# Create an agent pool for the AKS cluster
az pipelines pool -h
