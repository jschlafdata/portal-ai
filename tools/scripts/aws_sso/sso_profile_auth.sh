#!/bin/bash

# Move to the script's directory to ensure relative paths work
cd "$(dirname "$0")"

# Check for correct usage
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <environment> <aws_region> <aws_start_url>"
    exit 1
fi

AWS_PROFILE="$1"
ENVIRONMENT="$AWS_PROFILE"
AWS_REGION="$2"
AWS_START_URL="$3"

export AWS_PROFILE="$AWS_PROFILE"
export AWS_REGION="$AWS_REGION"
export AWS_START_URL="$AWS_START_URL"

# Log in to AWS SSO
aws sso login --profile "$AWS_PROFILE"

# Assume the AWS profile
eval "$(aws2-wrap --profile  "$AWS_PROFILE" --export)"
