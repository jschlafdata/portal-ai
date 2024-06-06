---
sidebar_position: 7
---

# Databricks Asset Bundles

```
if-insurance-databricks
    ├── README.md
    ├── db_asset_bundles
    │   └── custom_bundle
    │       ├── dab-container-template
    │       │   ├── databricks_template_schema.json
    │       │   └── template
    │       │       ├── databricks.yml.tmpl
    │       │       ├── resources
    │       │       │   └── concert_finder_job.yml.tmpl
    │       │       └── src
    │       ├── databricks.yml
    │       └── resources
    │           └── concert_finder_job.yml
```

----------

### CI/CD With Bundles (Example Flow)
![DAB CICD Diagram](/img/dab_diagram.png)
----------

Bundles provide a way to include metadata alongside your project’s source files to specify information including:

- Required cloud infrastructure and workspace configurations.


- Unit and integration tests.

  :::tip
  This is the real value DABs provide. It is a clean way to control which projects, pipelines, or team workspaces you push to production while making it easy to set tests that don’t allow the code to progress if they fail.
  :::


- Entry points and definitions for Databricks resources, for example Databricks jobs.

When you deploy a project using bundles, this metadata is used to provision infrastructure and other resources. Your project’s collection of source files and metadata is then deployed as a single bundle to your target environment.


## Data Science & Asset Bundles
- Develop data, analytics, and ML projects in a team-based environment. Bundles can help you organize and manage various source files efficiently. This ensures smooth collaboration and streamlined processes.
- Iterate on ML problems faster. Manage ML pipeline resources (such as training and batch inference jobs) by using ML projects that follow production best practices from the beginning.
- Set organizational standards for new projects by authoring custom bundle templates that include default permissions, service principals, and CI/CD configurations.


## Example Overview

[The Metadata Framework](./A_Metadata_Driven_ETL_Framework.md) used for managing and creating resources for ETL’s and pipelines has built in functionality to create catalogs, schemas, and tables if the needed resource does not exist.

It is also 100% configured using environment variables on the cluster which determine which catalogs to write to and which repo path to use for pipeline configurations.

Because of this, the following is an example of using databricks asset bundles to build the entire concert_finder schema & logging tables from scratch in the stage environment by only changing one parameter.


----------
## bundle configuration

----------
In databricks asset bundles there are three main components.
    1. databricks.yml
    2. resources/ [ project_level_configurations.yml ]
    3. src

Because the [The Metadata Framework](./A_Metadata_Driven_ETL_Framework.md) builds repo paths and determines resources
using cluster variables, we do not need to define root paths here or anything other than the target profiles the names of the target profiles.
* `development`
* `stage`
* `production`

In this example, the names of the target profiles are the same names of the git hub branches, as well as the WORKSPACE_ENVIRONMENT ENV_VAR on the clusters.

See https://docs.databricks.com/dev-tools/bundles/index.html for documentation.

## DAB Project Level Settings

```yaml title="databricks.yml"
bundle:
  name: concert_finder
include:
  - resources/*.yml
targets:
  # The 'dev' target, used for development purposes.
  # Whenever a developer deploys using 'dev', they get their own copy.
  development:
    # We use 'mode: dev' to make sure everything deployed to this target gets a prefix
    # like '[dev my_user_name]'. Setting this mode also disables any schedules and
    mode: development
    default: true
    workspace:
      host: https://adb-6739836370169955.15.azuredatabricks.net
      root_path: ~/
  stage:
    workspace:
      host: https://adb-6739836370169955.15.azuredatabricks.net
      root_path: ~/
  production:
    mode: production
    workspace:
      host: https://adb-6739836370169955.15.azuredatabricks.net
      root_path: ~/
```

----------
## DAB Workflow / Job Configurations

``` yaml title="concert_finder_job.yaml"
# The main job for concert_finder
resources:
  jobs:
    scrape_music_venues_daily:
      name: scrape_music_venues_daily
      tasks:
        - task_key: scrape_music_venues
          notebook_task:
            notebook_path: dbx_code/pipelines/concert_finder/jobs/scrape_music_venues
            source: GIT
          job_cluster_key: Job_cluster
          libraries:
            - pypi:
                package: PyYAML==6.0.1
            - pypi:
                package: requests_html
      job_clusters:
        - job_cluster_key: Job_cluster
          new_cluster:
            cluster_name: ""
            spark_version: 13.3.x-scala2.12
            azure_attributes:
              first_on_demand: 1
              availability: ON_DEMAND_AZURE
              spot_bid_max_price: -1
            node_type_id: Standard_DS3_v2
            custom_tags:
              environment: ${bundle.target}
              project_name: concert_finder
              transformation_layer: raw
              destination_catalog: raw_ingestion_data
            spark_env_vars:
              PYSPARK_PYTHON: /databricks/python3/bin/python3
              REPO_NAME: if-insurance-databricks
              WORKSPACE_ENVIRONMENT: ${bundle.target}
              WORKSPACE_NAME: dev-neu-ifpc-ins-workspace
            enable_elastic_disk: true
            data_security_mode: SINGLE_USER
            runtime_engine: PHOTON
            num_workers: 1
      git_source:
        git_url: https://github.com/jschlafdata/if-insurance-databricks.git
        git_provider: gitHub
        git_branch: ${bundle.target}
```

---------

## DAB Push to Development
#### Example commands for a deployment of the concert_finder project to development branch

``` sh
- note: I ran these commands using my DEFAULT databricks profile (this is the one with my user name)
- In the UI, “john@schlafdata.com” is the owner of all the resources created from this job.


databricks bundle validate --profile DEFAULT
databricks bundle run -t development scrape_music_venues_daily --profile DEFAULT
Run URL: https://adb-.../?o=6739836370169955#job/808733787552518/run/519962709832272

## databricks budles alias job names with DEV when running in development MODE.
2024-02-15 01:03:50 "[dev john] scrape_music_venues_daily" RUNNING 
2024-02-15 01:13:29 "[dev john] scrape_music_venues_daily" TERMINATED SUCCESS
```

---------
## Push from Dev to Stage

Example flow for a deployment of the concert_finder project to stage branch.

<details>
<summary>Schema before stage deployment (empty)</summary>
<p>

![CF Schema before Stage Deploy](/img/cf_pre_stage_deploy.jpeg)
</p>
</details>

---------
* example deployment of the concert_finder project to stage branch using a profile configured for an Azure-Databricks Service Principal.

  ```sh
  databricks bundle run -t stage scrape_music_venues_daily --profile SP

  2024-02-15 02:23:41 "scrape_music_venues_daily" RUNNING 
  2024-02-15 02:33:19 "scrape_music_venues_daily" TERMINATED SUCCESS
  ```
----------
That one command represents a 100% Automated CI/CD deployment leveraging Github, Databricks Asset Bundles, and python modules that decide environment paths.

### Execution Plan
* create schema in stage if (not exists)
* create logging table if (not exists)
* create destination table (with schema from .yaml file)
* run databricks workbook to `load data`
* create staging schema
* load staging table
* merge staging table to destination table
* log results from entire pipeline execution

### resources created in stage for job to run
------------
![dab stg results](/img/dab_stage_results.jpeg)

### sample query  results from the new stage table
------------
![stg final tbl](/img/stage_final_table.jpeg)
