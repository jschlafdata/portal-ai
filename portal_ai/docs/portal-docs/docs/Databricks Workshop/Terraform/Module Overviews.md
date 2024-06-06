# Module Overviews

This documentation outlines the Terraform configuration for setting up an Azure Databricks environment. It includes details on workspace creation, service principal integration, networking, storage, and permissions setup.

## Initial Setup

### Variables and Prefixes

- **Environments**: Defines deployment targets, such as `dev`.
- **Location**: Specifies the Azure region for deploying resources.
- **Prefixes**: Maps environment names to prefix strings for resource naming.

### Deployment Note

Mentions the use of the latest Terraform versions and highlights potential incompatibilities with certain existing repositories.

## Azure Databricks Application Module

- **Module**: `azure-databricks-application`
- **Purpose**: Creates an Azure application (service principal) for Databricks workspace authentication.
- **Key Outputs**: Azure client ID and secret.

## Workspace Environment Configuration

Defines configurations for each environment, including resource naming and groupings for the Databricks workspace.

## Azure Databricks Lakehouse Module

- **Module**: `adb-lakehouse`
- **Purpose**: Deploys Databricks workspaces and associated storage accounts.
- **Dependencies**: Relies on the `azure-databricks-application` module.

## Azure Users Module

- **Module**: `azure-users`
- **Purpose**: Configures Azure users with access to Databricks workspaces.
- **Dependencies**: Depends on previous modules for setup.

## Unity Catalog Metastore Module

- **Module**: `adb-uc-metastore`
- **Purpose**: Sets up a Unity Catalog metastore for data governance.
- **Dependencies**: Requires user and workspace configurations from earlier steps.

## Account-Level Unity Permissions Module

- **Module**: `account-level-unity-permissions`
- **Purpose**: Assigns account-level permissions for Unity Catalog.
- **Dependencies**: Builds on configurations from `adb-uc-metastore`.

## Workspace-Level Permissions Module

- **Module**: `workspace-level-permissions-main`
- **Purpose**: Configures workspace-level permissions and access controls.
- **Dependencies**: Dependent on the Unity Catalog and permissions setup.

## MWS Assignments Module

- **Module**: `mws-assignments`
- **Purpose**: Manages workspace privileges based on Unity Catalog settings.
- **Dependencies**: Utilizes workspace and user IDs from previous configurations.

## Unity Catalogs and Clusters Modules

- **Modules**: `db-uc-catalogs-dev` and `db-clusters-dev`
- **Purpose**: Establishes Unity Catalogs and Databricks clusters in the development environment.

## Azure Blob Storage Module

- **Module**: `abd-abfs-storage-dev`
- **Purpose**: Provisions Azure Blob Storage for Databricks.
- **Dependencies**: Uses the service principal from `azure-databricks-application` for authentication.

## Conclusion

This Terraform configuration offers a modular and comprehensive approach to deploying a Databricks environment on Azure, covering all necessary aspects from infrastructure setup to permissions management.
