#!/bin/bash

# This script deletes Terraform state files and directories for a specified environment within a project.

# Move to the script's directory to ensure relative paths work correctly.
cd "$(dirname "$0")" || {
    echo "Error: Failed to change to script's directory."
    exit 1
}

# Check for correct usage
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <environment> <module>"
    exit 1
fi

ENVIRONMENT="$1"
MODULE="$2"

# Confirm the current working directory.
PROJECT_ROOT=$(pwd)
echo "THE CURRENT WORKING DIRECTORY HAS BEEN SET TO: $PROJECT_ROOT"
echo "----------------------------------------------------"

# Navigate to the environment's directory containing Terraform deployment configs.
cd "../../../${ENVIRONMENT}/terraform/${MODULE}" || {
    echo "Error: Failed to change directory. Check the specified path."
    exit 1
}

# Check and remove the .terraform directory if it exists.
if [ -d ".terraform" ]; then
    echo "Removing .terraform directory..."
    rm -r .terraform && echo "Removed .terraform directory." || {
        echo "Error: Failed to remove .terraform directory."
        exit 1
    }
else
    echo ".terraform directory does not exist or has already been removed."
fi

# Check and remove the .terraform.lock.hcl file if it exists.
if [ -f ".terraform.lock.hcl" ]; then
    echo "Removing .terraform.lock.hcl file..."
    rm -f .terraform.lock.hcl && echo "Removed .terraform.lock.hcl file." || {
        echo "Error: Failed to remove .terraform.lock.hcl file."
        exit 1
    }
else
    echo ".terraform.lock.hcl file does not exist or has already been removed."
fi

echo "Terraform cleanup complete for environment: $ENVIRONMENT"
