
# Remote Storage

## Using S3 Buckets for Remote Storage in Kops and Terraform

These buckets store state information, configurations, and other essential data needed for reliable and scalable infrastructure management.

### Pre-requisites
:::important
Before leveraging S3 buckets for Kops and Terraform, it's essential to ensure these buckets are correctly set up and accessible. 
:::

As this deployment leverages many remote storage paths, the first step of this deployment is to create those resources in aws.


### Generating Bucket Metadata

#### generate_s3_backend_config

* script: `generate_s3_backend_config.py`

<details>
<summary>Generate YAML Config for all backend requirements</summary>
<p>

Configurations from the global_settings.yaml file are used to generate a yaml file declaring all of the remote s3 buckets needed for the rest of this deployment.

```yaml title="global_settings.yaml"
deployment_metadata:
  #.... removed unrelated configs.
  dns_domain:
    dev: schlafdata.cloud
    stage: schlafdata.tools
    prod: schlafdata.io

  kops_state_prefix: kops
  tfstate_prefix: tfstate
  k8s_prefix: k8s
  kops_iam_prefix: iam-http-dir
  k8s_terraform_prefix: k8s-tfstate
```


```python title="generate_s3_backends"
import yaml
from pathlib import Path
import sys
sys.path.append(str(Path(__file__).resolve().parents[2]))

from tools.settings import BASE_DIR
import os

print("----------------------------------------------------")
print(f"THE ROOT DIRECTORY FOR THIS PROJECT IS: {BASE_DIR}")
print("----------------------------------------------------")
os.chdir(BASE_DIR)
print(f"THE CURRENT WORKING DIRECTORY HAS BEEN SET TO: {BASE_DIR}")
print("----------------------------------------------------")

# Path to a hypothetical data file within the module
data_file_path = os.path.join(BASE_DIR, 'my_project', 'module1', 'data', 'my_data_file.txt')

def generate_s3_backends(input_file, output_file):
    with open(input_file, 'r') as infile:
        data = yaml.safe_load(infile)

    dns_domain = data['deployment_metadata']['dns_domain']

    (dev_domain, stage_domain, prod_domain) = ( dns_domain.get('dev'), 
                                                dns_domain.get('stage'), 
                                                dns_domain.get('prod') )
    
    kops_prefix = data['deployment_metadata']['kops_state_prefix']
    tfstate_prefix = data['deployment_metadata']['tfstate_prefix']
    kops_iam_prefix = data['deployment_metadata']['kops_iam_prefix']
    k8s_terraform_prefix = data['deployment_metadata']['k8s_terraform_prefix']

    s3_backends = {
        'kops': {
            'dev': f"{kops_prefix}-dev.{dev_domain}",
            'stage': f"{kops_prefix}-stage.{stage_domain}",
            'prod': f"{kops_prefix}.{prod_domain}",
        },
        'terraform': {
            'dev': f"{tfstate_prefix}-dev.{dev_domain}",
            'stage': f"{tfstate_prefix}-stage.{stage_domain}",
            'prod': f"{tfstate_prefix}.{prod_domain}",
        },
        'kops_iam': {
            'dev': f"{kops_iam_prefix}-dev.{dev_domain}",
            'stage': f"{kops_iam_prefix}-stage.{stage_domain}",
            'prod': f"{kops_iam_prefix}.{prod_domain}",
        },
        'k8s_terraform': {
            'dev': f"{k8s_terraform_prefix}-dev.{dev_domain}",
            'stage': f"{k8s_terraform_prefix}-stage.{stage_domain}",
            'prod': f"{k8s_terraform_prefix}.{prod_domain}",
        }
    }

    output_data = {'s3_backends': s3_backends}

    with open(output_file, 'w') as outfile:
        yaml.dump(output_data, outfile, default_flow_style=False, sort_keys=False)
    print(f"""bucket names to be used for remote storage written to \n path: {output_file}""")
    print("----------------------------------------------------")
# Replace 'input.yaml' and 'output.yaml' with your actual file paths
input_yaml = './global_settings.yaml'
output_yaml = './aws/terraform/deployment_configs/remote_s3_buckets.yaml'
generate_s3_backends(input_yaml, output_yaml)
```
</p>
</details>

```yaml title="example_output.yaml"
s3_backends:
  kops:
    dev: kops-dev.schlafdata.cloud
    stage: kops-stage.schlafdata.tools
    prod: kops.schlafdata.io
  terraform:
    dev: tfstate-dev.schlafdata.cloud
    stage: tfstate-stage.schlafdata.tools
    prod: tfstate.schlafdata.io
  kops_iam:
    dev: iam-http-dir-dev.schlafdata.cloud
    stage: iam-http-dir-stage.schlafdata.tools
    prod: iam-http-dir.schlafdata.io
  k8s_terraform:
    dev: k8s-tfstate-dev.schlafdata.cloud
    stage: k8s-tfstate-stage.schlafdata.tools
    prod: k8s-tfstate.schlafdata.io
```

:::note
Throughout this process, please note that I use an alias for python3 in my terminal: `py`
:::

### Command Execution
```sh
py tools/config_builders/generate_s3_backend_config.py
```
### Command Output

```text
----------------------------------------------------
THE ROOT DIRECTORY FOR THIS PROJECT IS: /Users/johnschlafly/Documents/schlafdata-cloud
----------------------------------------------------
THE CURRENT WORKING DIRECTORY HAS BEEN SET TO: /Users/johnschlafly/Documents/schlafdata-cloud
----------------------------------------------------
bucket names to be used for remote storage written to 
 path: ./aws/terraform/deployment_configs/remote_s3_buckets.yaml
----------------------------------------------------
```

After the executing the `generate_s3_backends` function, a yaml file is written to the folder `./aws/terraform/deployment_configs` directory with a file named `remote_s3_buckets.yaml`

### Creating the Buckets

This next script leverages the output yaml file to actually create the buckets if they do not exist, in the environment that you specify.

#### Prerequisites
* AWS CLI installed and configured
* yq command-line tool (version 4 or above) for parsing YAML files
* aws2-wrap tool for assuming AWS IAM roles
Properly configured AWS SSO and IAM permissions

#### Usage

```sh
./script_name.sh <environment> <aws_region>
```


<details>
<summary>build remote buckets</summary>
<p>
* The script reads from a remote_s3_buckets.yaml configuration file to get the list of bucket names for each section (kops, terraform, kops_iam, etc.) based on the environment.
* Attempts to create each bucket using the aws s3 mb command.
Handles creation errors, specifically checking if the bucket already exists and is owned by the user.
* For kops_iam buckets, it modifies the bucket's "Block all public access" settings using aws s3api put-public-access-block.

```sh
#!/bin/bash

# Move to the script's directory to ensure relative paths work
cd "$(dirname "$0")"

# Check for correct usage
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <environment> <aws_region>"
    exit 1
fi

AWS_PROFILE="$1"
ENVIRONMENT="$AWS_PROFILE"
AWS_REGION="$2"

# Navigate to the project's root directory
cd "../../aws/terraform/deployment_configs"

# Now, we're in the root directory of the project
PROJECT_ROOT=$(pwd)
echo "THE CURRENT WORKING DIRECTORY HAS BEEN SET TO: $(pwd)"
echo "----------------------------------------------------"


# Log in to AWS SSO
aws sso login --profile "$AWS_PROFILE"

# Assume the AWS profile
eval "$(aws2-wrap --profile  "$AWS_PROFILE" --export)"

# Export AWS_PROFILE
export AWS_PROFILE="$AWS_PROFILE"

# Define the path to your YAML configuration
CONFIG_FILE="./remote_s3_buckets.yaml"

# Iterate over the sections (kops, terraform, kops_iam, etc.)
for section in $(yq e '.s3_backends | keys | .[]' $CONFIG_FILE); do
  # Get the bucket name for the current environment and section
  bucket_name=$(yq e ".s3_backends.${section}.${ENVIRONMENT}" $CONFIG_FILE)

  if [ -n "$bucket_name" ]; then
    # Attempt to create the bucket
    creation_output=$(aws s3 mb "s3://$bucket_name" --region $AWS_REGION 2>&1)
    creation_status=$?
    if [ $creation_status -eq 0 ]; then
      echo "Successfully created bucket: $bucket_name"
      echo "---------------------------------------------------------"
    else
      # Check if the error is because the bucket already exists
      if echo "$creation_output" | grep -q "BucketAlreadyOwnedByYou"; then
        echo "Bucket already exists: $bucket_name"
        echo "S3 URL: https://$bucket_name.s3.$AWS_REGION.amazonaws.com"
        echo "---------------------------------------------------------"
      else
        # Print the actual error
        echo "Error creating bucket: $creation_output"
        echo "---------------------------------------------------------"
        continue
      fi
    fi

    # If the bucket is for kops_iam, uncheck "Block all public access"
    if [[ "$section" == "kops_iam" ]]; then
      echo "Unchecking 'Block all public access' for bucket $bucket_name..."
      aws s3api put-public-access-block \
        --bucket "$bucket_name" \
        --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
    fi
  fi
done

echo "Bucket creation and configuration complete."
```

</p>
</details>


:::important
As of 1/1/2024, all aws EC2 instances created require IMDSv2 method of authentication for applications.

The bucket created for `kops_iam` `iam-http-dir-dev.schlafdata.cloud` 
is intentionally created as public, as that is a requirment for kops implementation of 
IRSA authentication.
:::


### Command Execution
```sh
./tools/config_builders/create_s3_backend_buckets.sh stage us-west-2
```

### Command Output

```text
Successfully logged into Start URL: https://d-9267b09ec7.awsapps.com/start
Successfully created bucket: kops-stage.schlafdata.tools
---------------------------------------------------------
Successfully created bucket: tfstate-stage.schlafdata.tools
---------------------------------------------------------
Successfully created bucket: iam-http-dir-stage.schlafdata.tools
---------------------------------------------------------
Unchecking 'Block all public access' for bucket iam-http-dir-stage.schlafdata.tools...
Successfully created bucket: k8s-tfstate-stage.schlafdata.tools
---------------------------------------------------------
Bucket creation and configuration complete.
```
