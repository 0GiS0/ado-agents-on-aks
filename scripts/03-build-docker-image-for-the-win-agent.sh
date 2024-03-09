az acr build \
--resource-group $RESOURCE_GROUP \
--registry $ACR_NAME \
--image windows-ado-agent:{{.Run.ID}} windows-ado-agent/. \
--platform windows

WINDOWS_IMAGE_ID=$(az acr repository show-tags \
--name $ACR_NAME \
--repository windows-ado-agent \
--orderby time_desc \
--top 1 --output tsv)