---
sidebar_position: 1
---

# Entire Repo Folder Structure

#### Use this as a reference to find concepts you want to learn more about or implement.
----------

```
if-insurance-databricks (shared git repository structure.)
    ├── README.md
    ├── db_asset_bundles
    │   └── custom_bundle
    │       ├── dab-container-template
    │       │   └── ... etc.
    │       ├── databricks.yml
    │       └── resources
    ├── dbx_code
    │   ├── __init__.py
    │   ├── code_from_demos
    │   │   └── optimizations_notebook.py
    │   ├── global_python_modules
    │   │   ├── __init__.py
    │   │   ├── catalog_utilites
    │   │   ├── cluster_init_scripts
    │   │   └── notebook_executors
    │   │       ├── __init__.py
    │   │       └── pipeline_modules.py
    │   ├── pipelines
    │   │   ├── __init__.py
    │   │   ├── concert_finder
    │   │   │   ├── __init__.py
    │   │   │   ├── jobs
    │   └── sql_ingestion_framework_demo
    │       ├── obs
    │       ├── sql_ingestion
    │       └── utilities
    ├── excel_demo_spreadsheets
    │   └── Interactive Cost Explorer.xlsx
    ├── if-insurance-tarraform-raw
    │   ├── configurations
    │   ├── main.tf
    │   ├── modules
    │   ├── ....etc (standard tf files needed.)
    │   └── versions.tf
    │   └── main.tf
    └── presentations
        ├── DE Hands On Content- Day_4-5.pdf
        ├── If_Insurance_Day_1_Presentation.pdf
        ├── If_Insurance_Day_2.pdf
        └── If_Insurance_Day_3_Presentation.pdf
```

----------
## Data Warehouse & Engineering Fundamentals
[Findamentals Documentation](./Data_Warehouse_Fundamentals.md)

- Concepts and principals for designing a data warehouse. These are the concepts we went over on Day 2.
- Useful links and information I used when learning or implementing these concepts.
    - These are referenced throughout all of the other documentation.


----------
## Data Quality Check and Data Loading Framework

#### Links
* [Demo Documentation](./Data_Quality_Check_and_Data_Loading_Framework.md)
* [Git Repo Location](https://github.com/jschlafdata/if-insurance-databricks/tree/main/dbx_code/sql_ingestion_framework_demo)

#### Overview
- sql_ingestion_framework_demo
- This is the live demo we went through where you created your own tables in databricks.
- We have documentation for two different examples of these concepts and implementations. This one is the most straight forward, and would be a better place to start learning than the **“A Metadata Driven ETL Framework”** document.
- Concepts covered:
    - Data Quality Assurance
    - Configuration Management
    - Incremental Load Support
    - Dynamic SQL Generation
    - Utility Functions


## A Metadata Driven ETL Framework
* [Demo Documentation](./A_Metadata_Driven_ETL_Framework.md)
* [Git Repo Location](https://github.com/jschlafdata/if-insurance-databricks/tree/main/dbx_code/pipelines)

- This one goes very deep and leverages advanced python knowledge, project structure and management to create a 100% automated way to deploy ETL pipelines or projects for databricks workbooks.
- Even if you don’t want to unpack this entire document and process, understanding the concepts at a high level is beneficial.
- This framework combines and covers almost every topic we covered during the week and has a running / working example in the repository. In theory, you could copy this project into your own workspace to leverage it.
- Concepts Covered:
    - Effective Project Structure
    - Enabling Collaboration Across Projects or Pipelines
    - Using Frameworks to Automate CI/CD Pipelines
    - Data Engineering Best Practices
    - Databricks Concepts for Storage and History Tracking
    - Managing Data Quality and Observability for the Raw Ingestion Layer
    - Advanced Python Concepts and Modules
    - Creating an Agile and Fault Tolerant Data Pipeline System


## Databricks Asset Bundles

#### Links
* [Demo Documentation](./Databricks_Asset_Bundles.md)
* [Git Repo Location](https://github.com/jschlafdata/if-insurance-databricks/tree/main/db_asset_bundles)

I think these will be very helpful for Data Science initiatives, projects and management of resources or python libraries across workflows and jobs.

#### Overview

- Repo includes solutions for using DAB’s, alongside documentation for how to use them to deploy jobs or projects from development → production.
- This leverages the data pipeline and framework used in “A Metadata Driven ETL Framework” to create a real CI/CD implementation in the current databricks workspace. 
- I would use asset bundles for all ETL’s, DBT projects, Tests & production grade ML pipelines.


## DBT Project Setup

#### Links
* [Demo Documentation](./DBT_Project_Setup.md)
* [Git Repo Location](https://github.com/jschlafdata/if-insurance-databricks/tree/main/dbx_code/dbt)

#### Overview
- Goes over example project located in the repo /dbt/
    - How to set up and configure a similar setup in your own environment
    - How to set up DBT jobs using databricks Workflows in the UI
    - How to set up DBT jobs using databricks Asset bundles. 
- Useful links for learning DBT and deciding on a project structure.


## Project & Folder Structures, CI/CD Fundamentals

#### Links
* [Demo Documentation](./Project_&_Folder_Structures,_CI_CD_Fundamentals.md)

#### Overview
- I redesigned the way that the workspace is configured to match the way the Nordic team will actually be setting up your DB workspaces. 
    - I believe the design will be ***one*** workspace for data storage & etl pipelines, and another workspace for querying data, testing, and running ad-hoc analysis, reports or data science projects.
    - This structure is live in the databricks “dev” workspace we used all last week.
- Goes deeper into version control management best practices, using branches, and how to set up your databricks workspace to use these concepts.


## Terraform Deployment

#### Links
* [TF Documentation](./Terraform/Module%20Overviews.md)

#### Overview

- I am splitting this into two concepts and ideas.
    - The first is provisioning users in Azure and how those users map to roles in workspaces and unity catalogs.
    - The other is using Terraform to manage clusters, libraries, and databricks infrastructure that do not require administrator privileges in Azure. 
            - This is likely what you will need to at least control a portion of your databricks workspace without relying on infrastructure requests to create new resources in your workspaces.
            - i.e. — Some things you can control if you simply have admin in databricks itself, this will be be required for at least one person who is responsible for creating jobs, pipelines, catalogs or ML workflows in your workspaces.


## Understanding Virtual Machines

#### Links
* [Documentation](./Understanding_Virtual_Machines.md)

#### Overview
- Diagrams and explanations of the cloud computing that we went over during one of the first 3 days. Its all a blur now haha.
- How these concepts relate to understanding and leveraging databricks more effectively.
