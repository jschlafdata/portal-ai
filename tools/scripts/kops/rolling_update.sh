#!/bin/bash

# Move to the script's directory to ensure relative paths work
cd "$(dirname "$0")" || exit

# Check for correct usage
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <environment>"
    exit 1
fi

AWS_PROFILE="$1"
ENVIRONMENT="$AWS_PROFILE"

cd "../../../"
# Now, we're in the root directory of the project
PROJECT_ROOT=$(pwd)
echo "THE CURRENT WORKING DIRECTORY HAS BEEN SET TO: $(pwd)"
echo "----------------------------------------------------"


CONFIG_FILE="${ENVIRONMENT}/kops/input_configs/kops_base_configs.yml"

AWS_REGION=$(yq eval '.awsRegion' "$CONFIG_FILE")
CLUSTER_NAME=$(yq eval '.clusterName' "$CONFIG_FILE")
KOPS_STATE_STORE=$(yq eval '.kopsStateStore' "$CONFIG_FILE")


export KOPS_STATE_STORE=$KOPS_STATE_STORE
export AWS_PROFILE="$AWS_PROFILE"
export AWS_REGION="$AWS_REGION"

# Log in to AWS SSO
aws sso login --profile "$AWS_PROFILE"
# Assume the AWS profile
eval "$(aws2-wrap --profile  "$AWS_PROFILE" --export)"
# Update cluster with --yes to apply changes
kops update cluster --name "$CLUSTER_NAME" --yes
# Export kubecfg to interact with the cluster
aws2-wrap --profile "$ENVIRONMENT" kops export kubecfg --admin --name "$CLUSTER_NAME"
kops rolling-update cluster --name "$CLUSTER_NAME" --yes

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
