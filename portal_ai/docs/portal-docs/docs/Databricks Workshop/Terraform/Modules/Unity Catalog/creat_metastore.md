# Azure Databricks Unity Catalog Terraform Module

## Overview

This Terraform module automates the setup of Azure Databricks Unity Catalog resources, including necessary Azure infrastructure such as a resource group, storage accounts, and an access connector. It also configures role assignments, creates Databricks groups and users, and establishes a metastore for the Unity Catalog.

## Prerequisites

Before using this module, you must have:

- An Azure subscription.
- Terraform installed.
- The Azure CLI or PowerShell configured.
- Access to an Azure Databricks workspace.

## Resource Descriptions

- **`azurerm_resource_group`**: Creates an Azure Resource Group that will contain all the resources.

- **`azurerm_databricks_access_connector`**: Sets up an access connector in the specified resource group and location with a system-assigned identity. This connector facilitates secure access between Azure Databricks and other Azure services.

- **`azurerm_storage_account` and `azurerm_storage_container`**: Creates an Azure Storage Account and a container within it. The storage account is configured with hierarchical namespace enabled (HNS) to support Azure Data Lake Storage Gen2 features, which are necessary for Unity Catalog.

- **`azurerm_role_assignment`**: Assigns specific roles to the Databricks Access Connector managed identity for accessing the storage account. These roles include permissions for blob and queue data, as well as for managing event subscriptions.

- **`databricks_service_principal`**: Retrieves the service principal associated with Terraform, enabling automated access to Databricks resources.

- **`databricks_group` and `databricks_group_member`**: Creates user groups within Databricks, such as a group for Unity Catalog admins, and adds members to these groups. Permissions for cluster and instance pool creation, as well as workspace and SQL access, are configured here.

- **`databricks_user`**: Creates user accounts in Databricks based on a provided list of email addresses.

- **`databricks_metastore` and `databricks_metastore_data_access`**: Establishes a Databricks metastore for the Unity Catalog, setting up a storage root in Azure Data Lake Storage Gen2, and grants the access connector permissions to access the metastore data.

## Usage

To use this module, define the necessary variables (`var.shared_resource_group_name`, `var.location`, `var.tags`, etc.) in your Terraform configuration files. Include the resources as outlined in the provided Terraform script, ensuring all variables are properly set in a `terraform.tfvars` file or equivalent.

## Outputs

- **`workspace_privileges`**: Outputs the workspace privileges configured by the module, providing a mapping of workspace IDs to Databricks group IDs. This is useful for tracking permissions granted to user groups across different workspaces.

## Additional Notes

- Ensure your Terraform version is compatible with the AzureRM and Databricks providers used in this module.
- Review and adjust the role assignments and permissions as necessary for your organization's security policies.
- This module assumes you're using system-assigned managed identities for simplicity. If your organization uses user-assigned identities, modifications to the script will be required.
- Always plan and review Terraform changes (`terraform plan`) before applying them (`terraform apply`) to avoid unintended resource modifications.

