# Phase 1 Monolithic Deploy


```bash title="pahse_1_deploy.sh"
#!/bin/bash


# Execute Python script to configure S3 backend
if ! python3 tools/config_builders/generate_s3_backend_config.py; then
    echo "Failed to configure S3 backend. Exiting."
    exit 1
fi

# Create S3 backend buckets
if ! ./tools/config_builders/create_s3_backend_buckets.sh stage us-west-2; then
    echo "Failed to create S3 backend buckets. Exiting."
    exit 1
fi

# Generate SSH keys
if ! python3 tools/system_setup/keygen.py; then
    echo "Failed to generate SSH keys. Exiting."
    exit 1
fi

# Update remote.tf with new bucket name
if ! python3 tools/config_builders/update_remote_tf.py stage; then
    echo "Failed to update remote.tf. Exiting."
    exit 1
fi

# Initialize AWS deployment
if ! ./tools/terraform_executors/init_aws_deployment.sh stage init; then
    echo "Failed to initialize AWS deployment. Exiting."
    exit 1
fi

# Apply Terraform to the networking module
if ! ./tools/terraform_executors/init_aws_deployment.sh stage apply --target module.networking -auto-approve; then
    echo "Failed to apply Terraform to networking module. Exiting."
    exit 1
fi

# Apply Terraform to the entire configuration
if ! ./tools/terraform_executors/init_aws_deployment.sh stage apply -auto-approve; then
    echo "Failed to apply Terraform to the entire configuration. Exiting."
    exit 1
fi

# Generate Kops configuration
if ! python3 tools/config_builders/generate_kops_config.py stage; then
    echo "Failed to generate Kops configuration. Exiting."
    exit 1
fi

echo "All scripts executed successfully."
```
