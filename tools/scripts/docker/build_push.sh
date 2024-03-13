#!/bin/bash

# Move to the script's directory to ensure relative paths work
cd "$(dirname "$0")" || exit

# Check for correct usage
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <environment> <docker_path> <image_name>"
    exit 1
fi

AWS_PROFILE="$1"
ENVIRONMENT="$AWS_PROFILE"
DOCKER_PATH="$2"
IMAGE="$3"

cd "../../../"
# Now, we're in the root directory of the project
PROJECT_ROOT=$(pwd)
echo "THE CURRENT WORKING DIRECTORY HAS BEEN SET TO: $(pwd)"
echo "----------------------------------------------------"


AWS_BASE="${ENVIRONMENT}/aws_base_outputs.yml"
GLOBAL_SETTINGS="${ENVIRONMENT}/global_settings.yml"

AWS_REGION=$(yq eval '.aws_region' "$GLOBAL_SETTINGS")
AWS_ACCOUNT_ID=$(yq eval '.aws_account_id' "$AWS_BASE")

export AWS_PROFILE="$AWS_PROFILE"
export AWS_REGION="$AWS_REGION"

# Log in to AWS SSO
aws sso login --profile "$AWS_PROFILE"

# Assume the AWS profile
eval "$(aws2-wrap --profile  "$AWS_PROFILE" --export)"

aws ecr get-login-password \
    --region $AWS_REGION | docker login --username AWS \
    --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"


docker_image_path="./${ENVIRONMENT}/${DOCKER_PATH}"
cd $docker_image_path

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


docker build --platform=linux/amd64 -t $image_name .

LATEST_IMG="${image_name}:latest"
DEST_IMG_PATH="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${LATEST_IMG}"

docker tag $LATEST_IMG $DEST_IMG_PATH
docker push $DEST_IMG_PATH