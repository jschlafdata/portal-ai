---
sidebar_position: 2
---

# Data Warehouse Fundamentals
## Key Principals.

----------

### Correctness
- Data Warehouse does not allow modifying data without correctness warranty.
    - e.g. — Only “service principals” or “system users” can create / modify tables in production. This ensures that the state of data and assets in prod reflect all code versioned in the main branch of your repository.
- Semantically mirrors source while maintaining trust and consistency.
- Tests and data governance policies implemented.

----------
### Completeness
- History of objects maintained sufficiently long to satisfy analyst needs.
    - The Data Warehouse is an opportunity to store more history and information then source data systems. Using things like table versions, or [slowly changing dimensions](https://medium.com/@atriadplt/slowly-changing-dimension-whats-that-8ebf7cfef113) give the ability to understand how source data changes over time. 
- No erroneous gaps in history allowed.
    - Including the ability to restore data or jobs historically by using parameters in all jobs and data ingestion's.
    - Using standard tests on all tables to validate data meets completeness checks:
        - python examples
        - dbt examples

----------
### Traceability & Observability
- For any column in the data warehouse, we can figure out from which source columns, corresponding tables, databases, and sources the data came from. (Data Lineage.)
- Tools that facilitate Lineage:
    - Unity Catalog
    - dbt
- Monitoring dashboards created for:
    - Cost (across both Azure and Databricks)
    - Cluster performance
    - Test results
    - Options: 
        - Grafana
        - Overwatch
        - Databricks Dashboards
        - Azure Dashboards

----------
### Availability, Performance, Safety
- Quick analytical reports -- from queries run in any location (i.e., queries work for remote workers across continents).
- Safe against any instances or failures.
    - Backup versions of storage
    - Multi Availability zone for compute and network security
    - [e.g. — Using multiple availability zones in azure.](https://learn.microsoft.com/en-us/azure/databricks/scenarios/howto-regional-disaster-recovery)
- Compute (virtual machines) run in private networks.
- Secrets stored in Azure Key Vault, and read on an as-need basis for Databricks jobs or notebooks.
- Access to data warehouse organized and controlled.
    - Role based access control managed by Infrastructure as Code (IaC)

----------
### Infrastructure
- All infrastructure should be managed using infrastructure as code. (terraform.)
    - This includes:
        - Roles, Storage (how roles access storage)
        - Clusters (how roles access clusters)
        - Users (mapped from azure directory roles and groups)
            - What permissions users & groups have in each workspace
        - Secret management and Azure Key Vault.
        - Any resource that requires updates to both Databricks Account and Azure
            - examples:

----------

### Structure
- High-quality documentation. (Markdown most common and supported in many tools.)
- [Getting started with Markdown](https://www.markdownguide.org/getting-started/)
- Documentation visible and searchable by all business users.
    - Leveraging Unity Catalog and DBT to organize documentation.
- Code, Repos & Databricks workspaces easy to understand and stable.
    - Creating standardized naming conventions for catalogs, tables & resources.
    - Creating agreed upon folder structure for both dbt and Databricks jobs & workflows.

### Agility
- Data warehouse can be constructed quickly, scaled easily, migrated to new technologies easily.
    - Reducing the risk of vendor lock.
        - Building system and language agnostic procedures when possible.
    - Leveraging metadata-driven python frameworks to facilitate reproducible code.
    - Leveraging dbt to facilitate reproducible code, standardized metrics or definitions, and create environment where analysts can contribute to tables or databases while maintaining software and data engineering best practices.
- Setting up an effective CI/CD workflow that is test-driven.


### Collaboration
- Easily and securely exchange data across business units, suppliers, and partners.
- Sharing workbooks, dashboards, SQL code.
- Developing and sharing standardized definitions and scripts for metrics.

