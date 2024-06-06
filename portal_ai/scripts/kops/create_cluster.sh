#!/bin/bash

# Move to the script's directory to ensure relative paths work
cd "$(dirname "$0")" || exit

# Check for correct usage
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <aws_profile>"
    exit 1
fi

AWS_PROFILE="$1"

cd "../../"
# Now, we're in the root directory of the project
PROJECT_ROOT=$(pwd)
echo "THE CURRENT WORKING DIRECTORY HAS BEEN SET TO: $(pwd)"
echo "----------------------------------------------------"


CONFIG_FILE="configs/generated/kops_settings_base.yml"
CLUSTER_CONFIG="configs/generated/kops_cluster_base.yml"

AWS_REGION=$(yq eval '.awsRegion' "$CONFIG_FILE")
CLUSTER_NAME=$(yq eval '.clusterName' "$CONFIG_FILE")
KOPS_STATE_STORE=$(yq eval '.kopsStateStore' "$CONFIG_FILE")
PROJECT_NAME=$(yq eval '.projectName' "$CONFIG_FILE")

export KOPS_STATE_STORE=$KOPS_STATE_STORE
export AWS_PROFILE="$AWS_PROFILE"
export AWS_REGION="$AWS_REGION"

# Log in to AWS SSO
# aws sso login --profile "$AWS_PROFILE"

# Create cluster from file
kops create -f "${CLUSTER_CONFIG}"

KOPS_SECRET_NAME=$(yq eval '.kopsSshKeyName' "$CONFIG_FILE")
KOPS_SECRET_PATH="$HOME/.ssh/${PROJECT_NAME}/${KOPS_SECRET_NAME}.pub"

# Update cluster with --yes to apply changes and output Terraform files to the specific folder
kops update cluster --name "$CLUSTER_NAME" --yes

# Create SSH public key secret
kops create secret --name "$CLUSTER_NAME" sshpublickey admin -i "$KOPS_SECRET_PATH"

# Export kubecfg to interact with the cluster
kops export kubecfg --admin --name "$CLUSTER_NAME"

# Wait for cluster to become ready
echo "Waiting for cluster to become ready..."
while true; do
    if kops validate cluster --name "$CLUSTER_NAME" --state "$KOPS_STATE_STORE"; then
        echo "Cluster $CLUSTER_NAME is up and running."
        break
    else
        echo "Cluster $CLUSTER_NAME is not ready yet. Checking again in 30 seconds..."
        sleep 30
    fi
done