
AGENT_POOL_ID=$(az pipelines pool list \
--organization https://dev.azure.com/$ORGANIZATION_NAME \
--query "[?name=='$AGENT_POOL_NAME'].id" --output tsv)

echo "Agent Pool ID: $AGENT_POOL_ID"



# Check the status of the deployment

kubectl logs -f $(kubectl get pods -l app=azdevops-agent -o jsonpath="{.items[0].metadata.name}")






kubectl delete scaledobject azure-pipelines-scaledobject
kubectl delete triggerauthentication pipeline-trigger-auth

