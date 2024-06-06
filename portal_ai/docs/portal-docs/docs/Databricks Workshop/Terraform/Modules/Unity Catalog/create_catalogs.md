# Databricks Unity Catalog Creation Terraform Module

## Overview

This Terraform module facilitates the creation of Unity Catalogs within Azure Databricks, tailored for multiple environments such as development, staging, and production. It ensures the correct setup of catalogs and manages permissions efficiently, allowing for a streamlined data governance process.

## Prerequisites

Before using this module, ensure you have:

- Terraform installed and configured.
- Access to an Azure Databricks workspace.
- An understanding of Databricks Unity Catalogs and their purpose within your data architecture.

## Resource Descriptions

### Unity Catalog Creation

- **`databricks_catalog`** `workshop`, `workshop_stage`, `workshop_prod`: Creates Unity Catalogs for development (`__dev`), staging (`__stage`), and production environments. Each catalog is associated with a specific metastore and is named according to the environment it represents. The owner of each catalog is set to "Unity Catalog Admins", and properties are defined to mark the catalog's purpose as "lab".

### Catalog Permissions Management

- **`databricks_grants`** `workshop`, `workshop_stage`, `workshop_prod`: Manages permissions for each catalog created. It dynamically assigns privileges to principals (users or groups) based on a variable (`var.catalog_level_grants`) that defines the permissions required for each catalog. This setup allows for granular control over who can access and manage the data within each catalog.

## Usage

1. **Define Catalogs Variable**: Create a `catalogs` variable in your Terraform configuration to list the names of the catalogs you wish to create. This variable should be a set of strings representing each catalog's base name.

2. **Specify Metastore ID**: Ensure the `metastore_id` variable is set with the ID of the metastore you want to associate with the created catalogs.

3. **Configure Catalog Level Grants**: Define the `catalog_level_grants` variable to specify the permissions to be granted for each catalog. This should be a structure that includes the principal (user or group) and the privileges they should have on the catalog.

4. **Apply the Configuration**: Run `terraform apply` to create the catalogs and assign the specified permissions. Terraform will create a catalog for each environment and manage the permissions according to your specifications.

## Outputs

This module does not explicitly define outputs, but you could add outputs for the catalog names or IDs as needed for your Terraform project.

## Additional Notes

- Regularly review and update the permissions assigned to each catalog to ensure they align with your organization's data governance policies and security requirements.
- Consider how the creation of catalogs in different environments (development, staging, production) impacts your data architecture and access controls. Ensure that data is managed and accessed appropriately across these environments.
- Keep your Terraform configurations version-controlled to facilitate tracking changes and maintaining consistency across your Databricks environment.
