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
CLUSTER_CONFIG="${ENVIRONMENT}/kops/cluster_build.yml"

AWS_REGION=$(yq eval '.awsRegion' "$CONFIG_FILE")
CLUSTER_NAME=$(yq eval '.clusterName' "$CONFIG_FILE")
KOPS_STATE_STORE=$(yq eval '.kopsStateStore' "$CONFIG_FILE")
PROJECT_NAME=$(yq eval '.projectName' "$CONFIG_FILE")

export KOPS_STATE_STORE=$KOPS_STATE_STORE
export AWS_PROFILE="$AWS_PROFILE"
export AWS_REGION="$AWS_REGION"

# Log in to AWS SSO
aws sso login --profile "$AWS_PROFILE"

# Assume the AWS profile
eval "$(aws2-wrap --profile  "$AWS_PROFILE" --export)"

# Define the output file path
INIT_OUTPUT_FILE="$HOME/.ssh/${PROJECT_NAME}/vault_init_output.json"

# Check if the init output file exists
if [ ! -f "$INIT_OUTPUT_FILE" ]; then
    echo "Vault initialization output file does not exist: $INIT_OUTPUT_FILE"
    exit 1
fi

# Extract the unseal keys from the file
UNSEAL_KEYS=($(jq -r '.unseal_keys_b64[]' "$INIT_OUTPUT_FILE"))

# Unseal Vault using the first 3 unseal keys
for i in {0..2}; do
    UNSEAL_KEY="${UNSEAL_KEYS[$i]}"
    echo "Unsealing Vault with key $((i+1))..."

    # Use kubectl exec to unseal Vault with the current unseal key
    kubectl exec -it vault-0 -- vault operator unseal "$UNSEAL_KEY"
done