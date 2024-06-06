# Databricks Cluster Creation Terraform Module

## Overview

This Terraform module facilitates the creation of clusters in Databricks, including SQL Endpoints and Spark clusters. It sets up policies, configurations, and permissions tailored to specific environments within Databricks, making it suitable for a variety of computational tasks and workloads.

## Prerequisites

Before using this module, ensure you have:

- Terraform installed and configured.
- Access to an Azure Databricks workspace.
- Basic knowledge of Terraform syntax and Databricks configurations.

## Resource Descriptions

### Databricks Cluster Policy

- **`databricks_cluster_policy`**: Fetches a Databricks cluster policy named "Shared Compute" to enforce certain configurations and limitations on clusters.

### Databricks SQL Endpoint

- **`databricks_sql_endpoint`**: Creates a Databricks SQL Endpoint with specified characteristics such as cluster size, auto-stop settings, and warehouse type. This resource demonstrates the capability to enable serverless compute for SQL workloads.

### Databricks Permissions

- **`databricks_permissions`**: Configures permissions for using the SQL Endpoint and attaching to clusters. It grants the "DATA ENGINEERS" group the ability to use SQL Endpoints and attach to clusters, showcasing a method to control access at a granular level.

### Variables

- **`cluster_name`**, **`cluster_autotermination_minutes`**, **`cluster_num_workers`**: These variables allow customization of the cluster's name, auto-termination settings, and the number of worker nodes.

### Smallest Node Type and Latest LTS Spark Version

- **`databricks_node_type`** and **`databricks_spark_version`**: Determines the smallest node type available within the specified category and the latest Long Term Support (LTS) version of the Databricks Runtime, ensuring optimal cost and performance.

### Cluster Creation

- **`databricks_cluster`**: Creates a Spark cluster for each specified environment (e.g., development, stage, production), applying the shared cluster policy, node type, Spark version, and auto-termination settings. It also configures cluster logging, installs Python libraries, and sets environment variables.

### Cluster Permissions

- **`databricks_permissions`**: Assigns permissions for each created cluster to the "DATA ENGINEERS" group, allowing them to attach to the clusters.

## Usage

To use this module, define the necessary variables and configurations in your Terraform files. Adjust the cluster sizes, node types, Spark versions, and permission groups according to your organization's needs and policies.

## Outputs

This module does not explicitly define outputs, but you can easily add outputs for cluster IDs, SQL Endpoint IDs, or any other relevant information by defining output resources in your Terraform configuration.

## Additional Notes

- Review and adjust the permissions and access controls to fit your organization's security and governance policies.
- The SQL Endpoint and cluster configurations demonstrate a balance between performance and cost-efficiency. Monitor and adjust these settings based on actual usage and performance metrics.
- Consider leveraging Terraform modules for reusability and to enforce best practices across your Databricks workspaces.

