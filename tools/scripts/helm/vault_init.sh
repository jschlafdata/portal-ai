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
OUTPUT_FILE="$HOME/.ssh/${PROJECT_NAME}/vault_init_output.json"

# Attempt to initialize Vault and capture the output
VAULT_INIT_OUTPUT=$(kubectl exec -it vault-0 -- vault operator init -key-shares=5 -key-threshold=3 -format=json)

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "Vault initialized successfully."
    # Save the output to a file
    echo "$VAULT_INIT_OUTPUT" > "$OUTPUT_FILE"
    echo "Initialization output saved to $OUTPUT_FILE"

    # Set file permissions to read/write for the file owner only
    chmod 600 "$OUTPUT_FILE"
else
    echo "Failed to initialize Vault."
fi
