# Applying Terraform Networking Modules

The following is a bash script designed to apply terraform configurations. It uses the `deployment_configs.yaml` file talked about previously, as well as a .env file used for passing secret variables to the tf modules.

:::note

## Project Deployment Environment Setup

Instead of scattering `.env` files throughout the project, I've opted for a centralized approach to manage environment variables for different deployment stages.

### Project Base Directory Structure

The project's base directory contains environment-specific files as follows:

- `tf.dev.env` - Contains environment variables for the development stage.
- `tf.stage.env` - Contains environment variables for the staging stage.
- `tf.prod.env` - Contains environment variables for the production stage.

### Execution Script Flexibility

By providing a specific flag to the Terraform execution script, you can source different environment variables tailored to each AWS account or deployment environment. 
:::


## Terraform Executor
### Init, Apply, Destroy with Environment Variables

<details>
<summary>init_aws_deployment.sh</summary>
<p>
## Script Documentation: Terraform Environment Setup and Execution

This script is designed to streamline the process of setting up and executing Terraform commands across different environments. It ensures that environment-specific variables are sourced and used within Terraform operations, enhancing the flexibility and adaptability of deployment workflows.

### Overview

Main script actions.
1. Checks for the minimum required arguments: the environment identifier and the Terraform command to be executed.
2. Sources environment-specific variables from a file named according to the environment (e.g., `tf.dev.env`).
3. Dynamically exports additional variables from the `deployment_configs.yaml` configuration file as Terraform variables (`TF_VAR_`).
4. Changes the working directory based on the environment.
5. Executes the specified Terraform command with any additional arguments passed to the script.

```sh title=""
#!/bin/bash

# Move to the script's directory to ensure relative paths work
cd "$(dirname "$0")"

# Check if at least two arguments are passed
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <environment> <tf command> [additional arguments]"
    exit 1
fi


ENVIRONMENT=$1

cd "../../"
env_file="tf.${ENVIRONMENT}.env"

# Source the environment file if it exists
if [ -f "$env_file" ]; then
    echo "Sourcing $env_file..."
    source "$env_file"
else
    echo "Error: Environment file $env_file not found."
    exit 1
fi

shift 1  # Remove the first argument which is the environment

# Navigate to the project's root directory
cd "./aws/terraform"

# Now, we're in the root directory of the project
PROJECT_ROOT=$(pwd)
# Optionally, change the working directory to the project root
echo "THE CURRENT WORKING DIRECTORY HAS BEEN SET TO: $(pwd)"
echo "----------------------------------------------------"


YAML_FILE="./deployment_configs.yaml"

# Define a list of keys to extract from the YAML file. Adjust according to your actual YAML structure.
KEYS=(
    "${ENVIRONMENT}.vpc_cidr"
    "${ENVIRONMENT}.public_subnets_cidr"
    "${ENVIRONMENT}.private_subnets_cidr"
    "aws_region"
    "app_name"
    "database_user"
    "ovpn_configs.ovpn_config_directory"
    "ovpn_configs.ssh_private_key_file"
    "ovpn_configs.ssh_public_key_file"
    "ovpn_configs.open_vpn_static_route_ip"
)

# Loop through each key and dynamically export it as a TF_VAR
for key in "${KEYS[@]}"; do
    # Extract the variable name from the key path
    var_name=$(echo "$key" | sed 's/.*\.//')  # This assumes the Terraform variable name is the last segment of the key path
    value=$(yq e ".$key" "$YAML_FILE")

    # Check if the variable was successfully extracted
    if [ -z "$value" ]; then
        echo "Failed to extract information for key: $key"
        exit 1
    fi

    # Dynamically construct the TF_VAR name and export it
    export TF_VAR_$var_name="$value"
    echo "Exported TF_VAR_$var_name=$value"
done

# Additionally, export the environment as a Terraform variable
export TF_VAR_environment="$ENVIRONMENT"
echo "Exported TF_VAR_environment=$ENVIRONMENT"

echo "Exported Terraform variables for the $ENVIRONMENT environment."

# Change directory based on environment
cd "$ENVIRONMENT" || exit

# Run Terraform with the remaining arguments
terraform "$@"
```
</p>
</details>


### Command Execution

```
./tools/terraform_executors/init_aws_deployment.sh stage apply --target module.networking
./tools/terraform_executors/init_aws_deployment.sh stage apply
```

### Command Output

```
Sourcing tf.stage.env...
THE CURRENT WORKING DIRECTORY HAS BEEN SET TO: /Users/johnschlafly/Documents/schlafdata-cloud/aws/terraform
----------------------------------------------------
Exported TF_VAR_vpc_cidr=174.65.0.0/16
Exported TF_VAR_public_subnets_cidr=174.65.1.0/24
Exported TF_VAR_private_subnets_cidr=174.65.10.0/24
Exported TF_VAR_aws_region=us-west-2
Exported TF_VAR_app_name=schlafdata-app
Exported TF_VAR_database_user=schlafdata_admin
Exported TF_VAR_ovpn_config_directory=generated/ovpn-config
Exported TF_VAR_ssh_private_key_file=id_ed25519_openvpn
Exported TF_VAR_ssh_public_key_file=id_ed25519_openvpn.pub
Exported TF_VAR_open_vpn_static_route_ip=10.8.0.0/24
Exported TF_VAR_environment=stage
Exported Terraform variables for the stage environment.
----------------------------------------------------

outputs:
availability_zone_private = [
  "us-west-2a",
  "us-west-2b",
  "us-west-2c",
  "us-west-2d",
]
availability_zone_public = [
  "us-west-2a",
  "us-west-2b",
  "us-west-2c",
  "us-west-2d",
]
efs_id = "fs-0e8cbc16ad20e4467"
iam_policy_arns = [
  [
    "k8s-efs-admin",
    "arn:aws:iam::775273630641:policy/k8s-efs-admin",
  ],
  [
    "aws_lb_controller",
    "arn:aws:iam::775273630641:policy/aws_lb_controller",
  ],
  [
    "ecr",
    "arn:aws:iam::775273630641:policy/ecr",
  ],
  [
    "kops",
    "arn:aws:iam::775273630641:policy/kops",
  ],
  [
    "external-dns-host",
    "arn:aws:iam::775273630641:policy/external-dns-host",
  ],
  [
    "external-dns",
    "arn:aws:iam::775273630641:policy/external-dns",
  ],
]
nat_gateway_id = "nat-0116712f4c0c2f855"
private_subnet_cidrs = [
  "174.65.10.0/27",
  "174.65.10.32/27",
  "174.65.10.64/27",
  "174.65.10.96/27",
]
private_subnet_ids = [
  "subnet-09f4e5e1742281b51",
  "subnet-04d052e3941978d53",
  "subnet-009ce4aaa209ede5e",
  "subnet-0b98ee55bed5d7d3e",
]
public_subnet_cidrs = [
  "174.65.1.0/27",
  "174.65.1.32/27",
  "174.65.1.64/27",
  "174.65.1.96/27",
]
public_subnet_ids = [
  "subnet-08fc042115c7222b1",
  "subnet-0032af99b71efbc40",
  "subnet-018a1f9f4b8c44a73",
  "subnet-04a4b6274953815b3",
]
rds_instance_hostname = "schlafdata-app-stage-db.c5ac2qgww3ng.us-west-2.rds.amazonaws.com:5432"
vpc_cidr_block = "174.65.0.0/16"
vpc_id = "vpc-08109b719a65258aa"
vpc_name = "schlafdata-stage-vpc"
```

