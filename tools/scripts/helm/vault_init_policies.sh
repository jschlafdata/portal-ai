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
DNS_DOMAIN=$(yq eval '.dnsDomain' "$CONFIG_FILE")
VAULT_ADDR="https://vault.${DNS_DOMAIN}"


export KOPS_STATE_STORE=$KOPS_STATE_STORE
export AWS_PROFILE="$AWS_PROFILE"
export AWS_REGION="$AWS_REGION"

# Log in to AWS SSO
aws sso login --profile "$AWS_PROFILE"

# Assume the AWS profile
eval "$(aws2-wrap --profile  "$AWS_PROFILE" --export)"

# Path to the JSON file containing the root token
TOKEN_FILE="$HOME/.ssh/${PROJECT_NAME}/vault_init_output.json"

echo $VAULT_ADDR
export VAULT_ADDR="$VAULT_ADDR"

ROOT_TOKEN=$(jq -r '.root_token' "$TOKEN_FILE")

# Extract the root token from the file
ROOT_TOKEN=$(jq -r '.root_token' "$TOKEN_FILE")
echo $ROOT_TOKEN

# Check if the root token was successfully extracted
if [ -z "$ROOT_TOKEN" ]; then
    echo "Failed to extract the root token."
    exit 1
fi

# Use the root token for authentication
export VAULT_TOKEN="$ROOT_TOKEN"

curl --header "X-Vault-Token: $VAULT_TOKEN" \
     --request POST \
     --data '{"type": "kubernetes"}' \
     $VAULT_ADDR/v1/sys/auth/kubernetes


SERVICE_ACCOUNT_TOKEN=$(kubectl exec vault-0 -- cat /var/run/secrets/kubernetes.io/serviceaccount/token)
KUBERNETES_HOST=$(kubectl get service kubernetes -o jsonpath="{.spec.clusterIP}")
KUBERNETES_CA_CERT=$(kubectl exec vault-0 -- cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt | base64 | tr -d '\n')

curl --header "X-Vault-Token: $VAULT_TOKEN" \
     --request POST \
     --data "{
       \"token_reviewer_jwt\": \"${SERVICE_ACCOUNT_TOKEN}\",
       \"kubernetes_host\": \"https://${KUBERNETES_PORT_443_TCP_ADDR}:443\",
       \"kubernetes_ca_cert\": \"${KUBERNETES_CA_CERT}\"
     }" \
     $VAULT_ADDR/v1/auth/kubernetes/config

curl --header "X-Vault-Token: $VAULT_TOKEN" \
     --request POST \
     --data '{"type": "kv-v2"}' \
     $VAULT_ADDR/v1/sys/mounts/mageai

curl --header "X-Vault-Token: $VAULT_TOKEN" \
     --request POST \
     --data '{
       "bound_service_account_names": "mageai",
       "bound_service_account_namespaces": "default",
       "policies": "mageai",
       "ttl": "24h"
     }' \
     $VAULT_ADDR/v1/auth/kubernetes/role/mageai

curl --header "X-Vault-Token: $VAULT_TOKEN" \
     --request PUT \
     --data '{
       "policy": "path \"mageai/data/data_engineering\" { capabilities = [\"read\"] }"
     }' \
     $VAULT_ADDR/v1/sys/policies/acl/mageai


curl --header "X-Vault-Token: $VAULT_TOKEN" \
     --request POST \
     --data '{"type": "kv"}' \
     $VAULT_ADDR/v1/sys/mounts/eso


curl --header "X-Vault-Token: $VAULT_TOKEN" \
     --request PUT \
     --data '{
       "policy": "path \"eso/helm\" { capabilities = [\"read\"] }"
     }' \
     $VAULT_ADDR/v1/sys/policies/acl/eso-policy


OUTPUT=$(curl --header "X-Vault-Token: $VAULT_TOKEN" \
              --request POST \
              --data '{"policies":["eso-policy"]}' \
              $VAULT_ADDR/v1/auth/token/create | jq -r '.auth.client_token')

# # Execute the command and capture its output
# OUTPUT=$(kubectl exec -it vault-0 -- vault token create -policy="eso-policy" | grep 'token ' | awk '{print $2}')

# Check if we successfully captured the token
if [ -z "$OUTPUT" ]; then
    echo "Failed to extract the token."
    exit 1
else
    EXTRACTED_OUTPUT_TOKEN=$OUTPUT
fi

# Use the extracted token to create a Kubernetes secret
kubectl create secret generic vault-token --from-literal=token="${EXTRACTED_OUTPUT_TOKEN}"