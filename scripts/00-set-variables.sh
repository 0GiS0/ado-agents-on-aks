# Variables
RESOURCE_GROUP="ado-agents-on-aks"
AKS_NAME="ado-agents-cluster"
LOCATION="uksouth"
ACR_NAME="adoimages"

LINUX_AGENT_POOL_NAME="linux-agents-on-aks"
WINDOWS_AGENT_POOL_NAME="win-agents-on-aks"
ORGANIZATION_NAME="returngisorg"
WIN_PASSWORD="P@ssw0rd1234#@"

LINUX_IMAGE_NAME="linux-ado-agent"
WINDOWS_IMAGE_NAME="windows-ado-agent"

# Check if .env file exists
if [ -f .env ]; then
  echo -e ".env file exists"
else
  echo -e ".env file does not exist"
  exit 1
fi

# Load the .env file
source .env

echo -e "Variables set"