#!/bin/bash

# Variables
RESOURCE_GROUP="ado-agents-on-aks"
AKS_NAME="ado-agents-cluster"
LOCATION="uksouth"
ACR_NAME="adoimages"

# Stop on error
set -e

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
--attach-acr $ACR_NAME

# Get the credentials for the AKS cluster
az aks get-credentials \
--resource-group $RESOURCE_GROUP \
--name $AKS_NAME \
--overwrite-existing

# Create an agent pool
# Organization Settings > Agent Pools > Add Pool > Self Hosted > Name: agents-on-aks
AGENT_POOL_NAME="agents-on-aks"
ORGANIZATION_NAME="returngisorg"

AGENT_POOL_ID=$(az pipelines pool list \
--organization https://dev.azure.com/$ORGANIZATION_NAME \
--query "[?name=='$AGENT_POOL_NAME'].id" --output tsv)

echo "Agent Pool ID: $AGENT_POOL_ID"

# Generate a PAT in Azure DevOps
# It is necessary to have an Azure Devops token to be able to register our agents in the agent pool.
# https://dev.azure.com/returngisorg/_usersSettings/tokens
source .env

# Save the PAT in a Kubernetes secret
# kubectl create secret generic ado-pat --from-literal=pat=$PAT

# Generate docker image with ACR
# The Dockerfile is in the same directory as this script
az acr build \
--resource-group $RESOURCE_GROUP \
--registry $ACR_NAME \
--image ado-agent:{{.Run.ID}} ado-pipeline/.

# Get the latest image id
IMAGE_ID=$(az acr repository show-tags \
--name $ACR_NAME \
--repository ado-agent \
--orderby time_desc \
--top 1 --output tsv)

kubectl create secret generic azdevops-pat --from-literal=personalAccessToken=$PAT

cat <<EOF | kubectl apply -f -
# cat <<EOF > azdevops-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azdevops-deployment
  labels:
    app: azdevops-agent
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azdevops-agent
  template:
    metadata:
      labels:
        app: azdevops-agent
    spec:
      containers:
      - name: azdevops-agent
        image: $ACR_NAME.azurecr.io/ado-agent:$IMAGE_ID
        env:
          - name: AZP_URL
            value: "https://dev.azure.com/$ORGANIZATION_NAME"
          - name: AZP_POOL
            value: "$AGENT_POOL_NAME"
          - name: AZP_TOKEN
            valueFrom:
              secretKeyRef:
                name: azdevops-pat
                key: personalAccessToken
        volumeMounts:
        - mountPath: /var/run/docker.sock
          name: docker-volume
      volumes:
      - name: docker-volume
        hostPath:
          path: /var/run/docker.sock
EOF



# Check the status of the deployment
watch kubectl get pods
kubectl logs -f $(kubectl get pods -l app=azdevops-agent -o jsonpath="{.items[0].metadata.name}")


# Let create KEDA configuration to scale the agents
# cat <<EOF > keda-config.yaml
cat <<EOF | kubectl apply -f -
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: pipeline-trigger-auth
spec:
  secretTargetRef:
    - parameter: personalAccessToken
      name: azdevops-pat
      key: personalAccessToken
---
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: azure-pipelines-scaledobject
spec:
  scaleTargetRef:
    name: azdevops-deployment
  minReplicaCount: 1
  maxReplicaCount: 5 
  triggers:
  - type: azure-pipelines
    metadata:
      poolName: "$AGENT_POOL_NAME"
      organizationURLFromEnv: "AZP_URL"
    authenticationRef:
     name: pipeline-trigger-auth
EOF

kubectl describe scaledobject azure-pipelines-scaledobject
watch kubectl get scaledobject

kubectl delete scaledobject azure-pipelines-scaledobject
kubectl delete triggerauthentication pipeline-trigger-auth

# Clean up
# az group delete --name $RESOURCE_GROUP --yes --no-wait
