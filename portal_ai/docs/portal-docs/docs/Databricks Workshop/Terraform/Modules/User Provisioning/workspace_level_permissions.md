# Databricks Workspace Level Permissions Terraform Module

## Overview

This Terraform module facilitates the assignment of workspace-level permissions within Azure Databricks, including the association of a metastore with a specific workspace and the configuration of permissions for a Terraform service principal. It's designed to ensure that workspace configurations are properly secured and that automated processes have the necessary permissions to manage resources effectively.

## Prerequisites

Before using this module, ensure you have:

- Terraform installed and configured.
- Access to an Azure Databricks workspace and the Azure platform.
- The Azure CLI or PowerShell configured for Azure authentication.
- The necessary permissions to assign roles and manage metastores within your Azure Databricks environment.

## Resource Descriptions

### Metastore Assignment

- **`databricks_metastore_assignment`** `this`: Assigns a specified metastore to a given workspace, linking the two resources. This is essential for ensuring that the workspace has access to the correct metastore for data storage and management purposes.

### Azure Client Configuration

- **`data.azurerm_client_config`** `current`: Fetches the current Azure client configuration. This data source is used to obtain information about the authenticated Azure session, which can be necessary for certain operations that require Azure credentials.

### Grants for Terraform Service Principal

- **`databricks_grants`** `primary`: Assigns specific permissions to the Terraform service principal within the context of the assigned metastore. The permissions granted include "CREATE_CATALOG" and "CREATE_EXTERNAL_LOCATION," which are essential for managing data storage structures and external data sources in Databricks.

## Usage

1. **Metastore and Workspace IDs**: Define the `metastore_id` and `workspace_id` variables with the appropriate IDs for the metastore and workspace you wish to link.

2. **Service Principal Configuration**: Ensure the `aad_client_id` variable is set with the Application (client) ID of the Terraform service principal that will be granted permissions.

3. **Apply the Configuration**: Execute `terraform apply` to apply the configuration. Terraform will assign the specified metastore to the workspace and grant the necessary permissions to the service principal.

## Outputs

This module does not explicitly define outputs, but you could add outputs for the metastore assignment or the granted permissions as needed for your Terraform project.

## Additional Notes

- Regularly review the permissions granted to the Terraform service principal to ensure they align with your organization's security policies and the principle of least privilege.
- Consider the implications of granting "CREATE_CATALOG" and "CREATE_EXTERNAL_LOCATION" permissions, as these allow significant modifications to the data architecture within Databricks.
- Keep your Terraform configurations version-controlled to track changes to permissions and resource assignments over time.

