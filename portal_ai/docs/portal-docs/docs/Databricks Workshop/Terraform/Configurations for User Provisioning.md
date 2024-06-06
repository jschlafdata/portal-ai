# Terraform TFVARS Generation Script Documentation

This Python script is used to automate the conversion of YAML configuration files into Terraform `.tfvars` files. These files are specifically tailored for managing Azure Databricks workspaces. The script includes functionalities for processing different types of data structures found in YAML files, and formats them into Terraform-compatible syntax.

### example users yaml file

* users in this yaml file are turned into terraform variables, which drive the reosources that create Azure Users, Databricks Users and access to workspaces.

```yaml title="account_users.yaml"
workspace_users_list:
  - john.data-scientist@schlafdata.com
  - john.data-engineer@schlafdata.com
  - slr5kr@virginia.edu
  - kadi.kitsing@if.ee
  - aleksandra.kakstiene@if.lt
  - egle.buckiene@if.lt
  - ignas.oertelis@if.lt
  - paulius.brandisauskas@if.lt
```

```yaml title="user_groups.yaml"
user_groups:
  uc_data_engineers:
    display_name: "DATA_ENGINEERS"
    workspace_access: true
    databricks_sql_access: false
    allow_cluster_create: false
    allow_instance_pool_create: false
    allow_sql_analytics_access: false
```

```yaml title="role_mappings.yaml"
role_mapping:
  DATA_ENGINEERS:
    - john.data-engineer
    - slr5kr
    - kadi.kitsing
    - aleksandra.kakstiene
    - egle.buckiene
    - ignas.oertelis
```

## build_tfvars.py

#### This python script reads in each of the above yaml files, and builds/ generates terraform variables which actually provision user access to resources.

#### Links
* [github script link](https://github.com/jschlafdata/if-insurance-databricks/blob/main/if-insurance-tarraform-raw/python_executors/build_tfvars.py)

###

```py
read_yaml_write_tfvars(yaml_file, 
                       tfvars_file, 
                       yaml_key, 
                       format_func, 
                       env_prefix=None)
```

Reads a specified YAML configuration file, extracts content using a specified key, formats the content using a provided formatting function, and writes the formatted content to a `.tfvars` file.

- `yaml_file`: Path to the input YAML file.
- `tfvars_file`: Path to the output `.tfvars` file.
- `yaml_key`: The key in the YAML file whose value will be processed.
- `format_func`: A function used to format the YAML file's content.
- `env_prefix`: An optional prefix for the environment, added before the `yaml_key` in the output file.

### 
```py
read_yaml_write_combined_tfvars(yaml_files, 
                                output_file, 
                                yaml_key)
```

This function is used to make it easy to change user permissions and access for multiple different envioronments.

Reads multiple YAML configuration files, combines their contents under a specified key, and writes the combined formatted content to a single `.tfvars` file.

- `yaml_files`: A list of paths to input YAML files.
- `output_file`: Path to the output `.tfvars` file.
- `yaml_key`: The key in the YAML files whose values will be processed and combined.

## Usage Examples

The script includes specific examples demonstrating how to use the `read_yaml_write_tfvars` and `read_yaml_write_combined_tfvars` functions to generate `.tfvars` files for account users, unity catalogs, account admins, user groups, catalog level grants, and role mapping from corresponding YAML configuration files.

## How the script is actually used

Instad of running `terraform apply` from the command line, I run the bash script `tf-exec.sh`

* This runs the python script described above, and applies all of the variable files created to the terraform plan.
* This is an example of how you can pass environment flags, export environment variables to control the output and plan for your infrastructure deployments.

```sh title="tf-exec.sh"
#!/bin/bash

set -a # automatically export all variables

# Default to .env if no argument is provided
env_file=".env"

# Source the environment file if it exists
if [ -f "$env_file" ]; then
    echo "Sourcing $env_file..."
    source "$env_file"
else
    echo "Error: Environment file $env_file not found."
    exit 1
fi

python3 python_executors/build_tfvars.py

set +a # stop automatically exporting variables

# Run terraform with remaining arguments
terraform "$@" \
    -var-file="tfvar_configs/terraform.account_users.tfvars" \
    -var-file="tfvar_configs/terraform.user_groups.tfvars" \
    -var-file="tfvar_configs/terraform.admins.tfvars" \
    -var-file="tfvar_configs/terraform.catalogs.tfvars" \
    -var-file="tfvar_configs/environment_specific/terraform.catalog_level_grants.tfvars" \
    -var-file="tfvar_configs/environment_specific/terraform.role_mapping.tfvars"
```


These examples show the flexibility of the script in handling various types of data structures in YAML files and the ability to generate environment-specific Terraform configurations.