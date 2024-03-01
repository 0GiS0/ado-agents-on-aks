az acr build \
--resource-group $RESOURCE_GROUP \
--registry $ACR_NAME \
--image ado-agent:{{.Run.ID}} ado-agent/.

IMAGE_ID=$(az acr repository show-tags \
--name $ACR_NAME \
--repository ado-agent \
--orderby time_desc \
--top 1 --output tsv)