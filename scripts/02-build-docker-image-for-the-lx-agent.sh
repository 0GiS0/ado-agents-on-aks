az acr build \
--resource-group $RESOURCE_GROUP \
--registry $ACR_NAME \
--image linux-ado-agent:{{.Run.ID}} linux-ado-agent/.

IMAGE_ID=$(az acr repository show-tags \
--name $ACR_NAME \
--repository linux-ado-agent \
--orderby time_desc \
--top 1 --output tsv)