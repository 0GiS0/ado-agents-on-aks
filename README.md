# Running Azure DevOps agents on Azure Kubernetes Service

This repository contains the necessary files to run Azure DevOps agents on Azure Kubernetes Service (AKS).

## Prerequisites

The first thing you need to do is create an Agent Pool in Azure DevOps. You can do this by navigating to the `Organization Settings` -> `Agent Pools` and clicking on `Add Pool`. Once you have created the pool, you will need to create a Personal Access Token (PAT) with the `Agent Pools (read, manage)` scope. You can do this by navigating to `User Settings` -> `Personal access tokens` and clicking on `New Token`. Make sure to save the token as you will not be able to see it again.

Make sure you save your PAT in a `.env` file in the root of the repository. The file should look like this:

```bash
PAT=<your-pat>
```

Then load the environment variables by running the following command:

```bash
source scripts/00-set-variables.sh
```

## Create Azure resources

The next step is to create the necessary Azure resources. You can do this by running the following command:

```bash
source scripts/01-create-rg-and-aks.sh
```

It will create a resource group and an AKS cluster. The AKS cluster will be created with a single node pool with a `Standard_B2s` VM size. This cluster will scale up to 3 nodes and down to 1 node.

## Build the Docker image for the agent

The next step is to build the Docker image for the agent. You can do this by running the following command:

```bash
source scripts/02-build-docker-image-for-the-agent.sh
```

You can test it locally by running the following commands:

```bash
az acr login --name $ACR_NAME

docker pull $ACR_NAME.azurecr.io/ado-agent:$IMAGE_ID
docker run --rm -e AZP_URL="https://dev.azure.com/$ORGANIZATION_NAME" -e AZP_POOL="$AGENT_POOL_NAME" -e AZP_TOKEN=$PAT $ACR_NAME.azurecr.io/ado-agent:$IMAGE_ID
```

## Deploy manifests to AKS

The next step is to deploy the manifests to AKS. You can do this by running the following command:

```bash
source scripts/03-apply-manifests.sh
```

Hurrah! You now have a running Azure DevOps agent on AKS. You can check the logs by running the following command:

```bash
kubectl logs -f $(kubectl get pods -l app=ado-agent -o jsonpath="{.items[0].metadata.name}")
```

And you can see how the pod scales by running the following command:

```bash
watch kubectl get pods -l app=ado-agent
```

Also It's good to see if the KEDA is working properly by running the following command:

```bash
kubectl describe scaledobject azure-pipelines-scaledobject
watch kubectl get scaledobject
```

## How to test it

I've created a couple of pipelines to test this new pool. You can find them in the `pipelines` folder. You can import them into your Azure DevOps organization and run them.

## Clean up

Don't forget to clean up the resources once you are done. You can do this by running the following command:

```bash
source scripts/04-clean-up.sh
```

Happy coding!
