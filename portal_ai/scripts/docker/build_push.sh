#!/bin/bash

# Move to the script's directory to ensure relative paths work
cd "$(dirname "$0")" || exit

# Check for correct usage
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <aws_profile> <docker_path> <image_name>"
    exit 1
fi

AWS_PROFILE="$1"
DOCKER_PATH="$2"
IMAGE="$3"

cd "../../"
# Now, we're in the root directory of the project
PROJECT_ROOT=$(pwd)
echo "THE CURRENT WORKING DIRECTORY HAS BEEN SET TO: $(pwd)"
echo "----------------------------------------------------"

AWS_PLUS_BASE="configs/generated/aws+global_settings_base.yml"

AWS_REGION=$(yq eval '.aws_region' "$AWS_PLUS_BASE")
AWS_ACCOUNT_ID=$(yq eval '.aws_account_id' "$AWS_PLUS_BASE")
ENVIRONMENT=$(yq eval '.environment' "$AWS_PLUS_BASE")
PROJECT_NAME=$(yq eval '.project_name' "$AWS_PLUS_BASE")


export AWS_PROFILE="$AWS_PROFILE"
export AWS_REGION="$AWS_REGION"

# Log in to AWS SSO
aws sso login --profile "$AWS_PROFILE"

# Assume the AWS profile
eval "$(aws2-wrap --profile  "$AWS_PROFILE" --export)"

aws ecr get-login-password \
    --region $AWS_REGION | docker login --username AWS \
    --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"


cd $DOCKER_PATH

image_name="${ENVIRONMENT}.${IMAGE}"

CWD=$(pwd)
echo "THE CURRENT WORKING DIRECTORY IS: $(pwd)"
echo "----------------------------------------------------"


# Check if the environment is 'prod'
if [ "$ENVIRONMENT" = "prod" ]; then
    # If the environment is 'prod', set image_name to just IMAGE
    image_name="${IMAGE}"
else
    # For any other environment, prepend the environment to the image name
    image_name="${ENVIRONMENT}.${IMAGE}"
fi

# Check if ECR repository exists, if not create it
if ! aws ecr describe-repositories --repository-names $image_name >/dev/null 2>&1; then
    aws ecr create-repository --repository-name "${image_name}"
fi

docker build --platform=linux/amd64 -t $image_name .

LATEST_IMG="${image_name}:latest"
DEST_IMG_PATH="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${LATEST_IMG}"

docker tag $LATEST_IMG $DEST_IMG_PATH
docker push $DEST_IMG_PATH
