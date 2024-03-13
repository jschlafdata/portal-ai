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

# Specify the tag key and the tag values you're looking for
TAG_KEY="kubernetes.io/service-name"
declare -a TAG_VALUES=("default/nginx-external-ingress-nginx-controller" "default/nginx-internal-ingress-nginx-controller")

# Function to check if all target groups are tagged correctly
check_target_groups() {
    local all_found=true

    for tag_value in "${TAG_VALUES[@]}"; do
        local found=false
        # List all target groups
        target_group_arns=$(aws elbv2 describe-target-groups --query 'TargetGroups[*].TargetGroupArn' --output text)

        # Check each target group for the tag
        for arn in $target_group_arns; do
            # Fetch tags for the target group
            tags=$(aws elbv2 describe-tags --resource-arns $arn --query "TagDescriptions[*].Tags[?Key=='$TAG_KEY'].Value" --output text)
            if [[ $tags == *"$tag_value"* ]]; then
                found=true
                break
            fi
        done

        if [ "$found" = false ]; then
            all_found=false
            break
        fi
    done

    echo $all_found
}

# Wait for all target groups to have the specified tags
while true; do
    if [ "$(check_target_groups)" = true ]; then
        echo "All target groups have been found with the specified tags."
        break
    else
        echo "Waiting for target groups to be tagged correctly..."
        sleep 30
    fi
done


# List all target groups
target_group_arns=$(aws elbv2 describe-target-groups --query 'TargetGroups[*].TargetGroupArn' --output text)

# Iterate over each Target Group ARN
for tg_arn in $target_group_arns; do
    echo "Checking Target Group: $tg_arn for tags"

    # Get tags for the Target Group
    tags=$(aws elbv2 describe-tags --resource-arns "$tg_arn")

    for TAG_VALUE in "${TAG_VALUES[@]}"; do
        # Check if the tags match the specified key and value
        match=$(echo "$tags" | jq -r ".TagDescriptions[] | select(.Tags[] | .Key == \"$TAG_KEY\" and .Value == \"$TAG_VALUE\")")

        if [[ -n $match ]]; then
            echo "Target Group $tg_arn matches the tags for $TAG_VALUE. Updating..."

            # Modify Target Group attributes to enable Proxy Protocol v2
            update_result=$(aws elbv2 modify-target-group-attributes --target-group-arn "$tg_arn" --attributes Key=proxy_protocol_v2.enabled,Value=true)

            if [[ $? -eq 0 ]]; then
                echo "Successfully updated Target Group $tg_arn to enable Proxy Protocol v2 for $TAG_VALUE"
            else
                echo "Failed to update Target Group $tg_arn for $TAG_VALUE"
            fi
            # If a match is found, no need to check the next tag value for this target group
            break
        fi
    done
done

