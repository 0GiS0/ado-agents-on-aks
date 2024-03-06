# Create a resource group
az group create \
--name $RESOURCE_GROUP \
--location $LOCATION

# Create Azure Container Registry
az acr create \
--resource-group $RESOURCE_GROUP \
--name $ACR_NAME \
--sku Basic

# Create AKS cluster with KEDA enabled
az aks create \
--resource-group $RESOURCE_GROUP \
--name $AKS_NAME \
--enable-keda \
--generate-ssh-keys \
--attach-acr $ACR_NAME \
--node-vm-size Standard_B2ms \
--node-count 1 \
--enable-cluster-autoscaler \
--min-count 1 --max-count 3 \
--enable-vpa

# Get the credentials for the AKS cluster
az aks get-credentials \
--resource-group $RESOURCE_GROUP \
--name $AKS_NAME \
--overwrite-existing