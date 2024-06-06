# Databricks Account Level Permissions Terraform Module

## Overview

This Terraform module is designed to manage account-level permissions in Databricks by dynamically adding users to groups based on predefined mappings. It supports the configuration of permissions for various roles within the organization, including the setup of Unity Catalog admin permissions.

## Prerequisites

Before using this module, ensure you have:

- Terraform installed and configured.
- Access to an Azure Databricks workspace.
- A clear understanding of your organization's role and permissions structure.

## Resource Descriptions

### Group Memberships

- **`databricks_group_member`** `group_member`: Dynamically adds users to Databricks groups based on a `role_mapping` variable, which maps group names to user names. This flexible approach allows for easy management of user roles and permissions across different groups.

### Fetching User Data

- **`data.databricks_user`** `admins`: Retrieves data for users specified in the `admins_list` variable. This data source is used to gather information about users who are designated as administrators.

### Local Variables

- **`locals.user_ids`**: A local variable that compiles a list of user IDs from the fetched Databricks user data. This list is used to add users to specific groups in subsequent steps.

### Unity Catalog Admins

- **`databricks_group_member`** `unity_admins`: Adds users to the Unity Catalog admins group based on their user IDs. This is crucial for managing access to Unity Catalog resources and ensuring that only authorized users can perform administrative actions.

## Usage

1. **Define Role Mappings**: Create a `role_mapping` variable in your Terraform configuration to map Databricks group names to user names. This mapping should reflect your organization's role and permissions structure.

2. **Specify Admins List**: Populate the `admins_list` variable with the usernames of users who should have administrative permissions. This list is used to fetch user data and manage group memberships.

3. **Configure Group and User IDs**: Ensure that the `group_ids` and `user_ids` variables are correctly set up to reference the appropriate Databricks groups and users.

4. **Apply the Configuration**: Run `terraform apply` to apply the configuration. Terraform will dynamically add the specified users to their respective groups based on the role mappings and admin list.

## Outputs

This module does not explicitly define outputs, but you can add outputs for group memberships, user IDs, or any other relevant information as needed.

## Additional Notes

- Review and update the role mappings and admin list regularly to reflect changes in your organization's roles and permissions structure.
- Monitor the impact of these permissions changes in Databricks to ensure they meet your organization's security and governance requirements.
- Consider using Terraform modules to encapsulate permissions logic, making it reusable and easier to manage across multiple Databricks workspaces or environments.
