
# DBT Setup for Databricks

- For dbt, local development in vs-code is absolutely the best. I am going to walk through how to set things up locally so you can develop, and how that translates to the setup necessary to execute the code from within a databricks workspace.


1. Make a folder called DBT. Inside that folder, you will want the following files:
    1. .gitignore
        1. bash_envs.sh
    2. profiles.yml
        1. this can be empty
    3. bash_envs.sh


## bash_envs.sh

All development for DBT locally should be for development purposes only, i.e. not stage or production. In this bash file, we are setting the environment variables for a few Catalogs

1. raw_ingestion_data__dev
2. clean_data__dev
3. aggregate_data__dev

```sh title="bash_envs.sh"
export raw_ingestion_data_elem_db='raw_ingestion_data__dev'
export clean_data_elem_db='clean_data__dev'
export aggregate_data_elem_db='aggregate_data__dev'

export dbt_env='__dev'
export ENV='dev'

export databricks_host=adb-6739836370169955.15.azuredatabricks.net
export sql_endpoint_http=</sql/1.0/warehouses/09d067f6b168b705>
export token=<personal access token for SQL endpoint.>
```


2. Create your first project folder. While in your teminal, in the dbt folder, you can run dbt init to create a new project.
    1. This is a really great blog: [how to structure your dbt project](https://medium.com/geekculture/how-to-structure-your-dbt-project-c62103deceb4)
        1. I have had the best success using the “layered dbt project structure” in that blog, where you separate projects out (by database / catalog / or business function)


![This is the best setup.](/img/dbt_setup_1.png)
![This one is actually horrifying, don’t do it.](/img/dbt_setup_2.png)


## github_repo_structure
```
    ├── dbx_code
    │   ├── dbt
    │       ├── raw_ingestion_data [project_name]
    │       │   ├── macros
    │       │   └── models
    │       │       ├── example_schema.sql
    │       │       │   <!-- sql files for models. -->
    │       │       └── example_schema.yaml 
    │       │           <!-- tests, documentation, parameters for sql file. -->
    │       │   ├── dbt_project.yml
    │       │   └── profiles.yml
    │       │   ├── packages.yml
    |       |
    ...........[ example project number 2 ].........
    |       |
    │       ├── clean_data [project_name]
    │       │   ├── macros
    │       │   └── models
    │       │       ├── example_schema.sql
    │       │       │   <!-- sql files for models. -->
    │       │       └── example_schema.yaml 
    │       │           <!-- tests, documentation, parameters for sql file. -->
    │       │   ├── dbt_project.yml
    │       │   └── profiles.yml
    │       │   ├── packages.yml
```

----------
## *The key understanding here is the relationship between*
    —  ***bash_envs.sh ←---→  profiles.yml ←--→ databricks_cluster env_vars***



1. Run source ./bash_envs from while in the dbt/ root directory you made.
    1. This exports all of those variables as env_vars in your terminal.
2. Now, when you run “dbt compile —profiles-dir .” what is actually happening is dbt is exporting those env vars from your terminal, into the projects configuration.


    ## target profile the models in the raw_ingestion project
```yaml title="profiles.yml"
    raw_ingestion:
      target: dev
      outputs:
        dev:
          type: databricks
          catalog: "{{ env_var('clean_data_elem_db') }}"
          schema: default
          host: "{{ env_var('databricks_host') }}"
          http_path:  "{{ env_var('sql_endpoint_http') }}"
          token: "{{ env_var('token') }}"
          threads: 4
```

----------

***This next configuration is only necessary if you want to use elementary to visualize tests and data quality metrics. Personally, I think it is one of the best tools out there.***

```yaml title="profiles.yml (for elementary)"
elementary:
  outputs:
    default:
      type: databricks
      host: "{{ env_var('databricks_host') }}"
      http_path: "{{ env_var('sql_endpoint_http') }}"
      schema: elementary
      token: "{{ env_var('token') }}"
      threads: 4
      catalog: "{{ env_var('clean_data_elem_db') }}"
```

----------
## Catalog & Schema Management in DBT


- You may have noticed two extra environment variables in the bash_envs.sh file:

```sh
export dbt_env='__dev'
export ENV='dev'
```

1. I like to call differentiate between dev/stage/prod databases by using this standard format
    - raw_ingestion_data__dev
    - raw_ingestion_data__stage
    - raw_ingestion_data  
            - (no alias is always production. I do this across all systems, not just database or catalog names.)
----------
## How dbt_env and ENV are used in the dbt project


1. In the macros folder inside the raw_ingestion_data project, you will see two files.
    1. custom_catalog.sql
    2. get_custom_schema.sql
2. These are custom macros necessary to keep dbt from writing things to a “default” schema, or even worse, aliasing everything with your username.

How they work isn’t important, this is just copied from DBT documentation/ forums.


```sql title="custom_catalog.sql"
{% macro current_catalog() -%}
  {{ return(adapter.dispatch('current_catalog', 'dbt')()) }}
{% endmacro %}
{% macro databricks__current_catalog() -%}
  {% call statement('current_catalog', fetch_result=True) %}
      select current_catalog()
  {% endcall %}
  {% do return(load_result('current_catalog').table) %}
{% endmacro %}
{% macro use_catalog(catalog) -%}
  {% set cust_catalog = catalog ~ env_var('dbt_env') %}
  {{ return(adapter.dispatch('use_catalog', 'dbt')(cust_catalog)) }}
{% endmacro %}
{% macro databricks__use_catalog(catalog) -%}
  {% call statement() %}s
    {% set cust_catalog = catalog ~ env_var('dbt_env') %}
    use catalog {{ adapter.quote(cust_catalog) }}
  {% endcall %}
{% endmacro %}
```

```sql title="get_custom_schema.sql"
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
```


1. Now, with all of this set up, you can actually control the Catalog, Schema & Table that dbt outputs and compiles SQL code for.

```yaml title="dbt_project.yml"
# Name your project! Project names should contain only lowercase characters
# and underscores. A good package name should reflect your organization's
# name or the intended use of these models
name: 'raw_ingestion'
version: '1.5.3'
config-version: 2
# This setting configures which "profile" dbt uses for this project.
profile: 'raw_ingestion'
# These configurations specify where dbt should look for different types of files.
# *********************************************************************** #
# REMOVING UNECESSARY ITEMS FOR THIS EXAMPLE, DON'T REMOVE IN ACTUAL FILE #
# ................ #
models:
  raw_ingestion:
    ticketfinder:
      dimensions:
        schema: ticketfinder
      facts:
        schema: ticketfinder
  elementary:
    +schema: "elementary"
```

***This is the last sort of pain in the ass, learn it the hard way kind of deal. Your dbt_project.yml MUST match this format precisely.***

```yaml
- name [raw_ingestion]
- profile [raw_ingestion]
- models:
    -  [raw_ingestion]
        - actual folder names you create inside models/
```

***And lastly, the profile in your profiles.yml must have the same name as well.***

```yaml
config:
send_anonymous_usage_stats: False
raw_ingestion:
  target: dev
  outputs:
    dev:
      type: databricks
      catalog: "{{ env_var('clean_data_elem_db') }}"
      schema: default
      host: "{{ env_var('databricks_host') }}"
      http_path:  "{{ env_var('sql_endpoint_http') }}"
      token: "{{ env_var('token') }}"
      threads: 4
``` 

Finally, make sure you have a .gitignore file in each of your sub-dbt project folders with these contents.

```text title=".gitignore"
# Default .gitignore content added by dbt Cloud
target/*
dbt_packages/*
logs/*
# end dbt Cloud content
# General
.DS_Store
*.log
# dbt artifacts
/dbt_modules/*  # Assuming you want to keep this pattern
dbt_packages/*  # Ignores contents, not the folder
target/*        # Ignores contents, not the folder
logs/*          # Ignores contents, not the folder
manifest.json
run_results.json
.dbt/*
edr_target/*    # Ignores contents, not the folder
# Optionally ignore the dbt_project.yml file if it contains sensitive or specific information
# dbt_project.yml
# User-specific files (e.g., editors or IDEs might generate these)
.vscode/
# System-specific cache files
__pycache__/
*.pyc
# Node modules for dbt projects that use packages requiring node.js (e.g., dbt Cloud IDE extensions)
/node_modules/
# macOS specific
.DS_Store
```

----------
## Creating a Workflow in databricks for a DBT job.

With all of the above steps done, you should be able to push this to a git repo or azure devops, and sync with your databricks workspace.

In the example I went through in the workspace, I have this folder structure

1. [Example workflow for databricks job](https://adb-6739836370169955.15.azuredatabricks.net/?o=6739836370169955#job/998785746161271/tasks/task/raw_ingestions_dbt__dev)
    1. one of the keys to getting this to work was having the path to the dbt project correct
        1. dbx_code/dbt/raw_ingestion_data
            1. here, dbx_code is the root of my git repository, which you can see I have linked to the workflow on the development branch.


1. **You will see that this workflow actually uses two cluster endpoints, one for running SQL commands, and the other for executing DBT CLI commands.**



2. The last thing you need to do is click the pencil icon next to the “dbt CLI cluster*”
    1. Scroll down, open advanced options, and add the environment variables from your bash_envs.sh file.
        1. Note that I had to remove all of the single quotes and the “export” statements.
        2. **export dbt_env='__dev’** --→ **dbt_env=__dev**




## Ok and that should do it!
----------

Thanks for coming to my Ted Talk.


## Entire DBT Folder Structure for Reference.

```
    │   ├── dbt
    │   │   └── raw_ingestion_data
    │   │       ├── assets
    │   │       ├── dbt_project.yml
    │   │       ├── macros
    │   │       │   ├── custom_catalog.sql
    │   │       │   ├── get_custom_schema.sql
    │   │       │   ├── standard_metrics
    │   │       │   └── tests
    │   │       │       ├── custom_macros
    │   │       │       │   └── date_spine_macro.sql
    │   │       │       └── generic_tests
    │   │       │           ├── date_spine_test.sql
    │   │       │           └── grouped_amount_within_range.sql
    │   │       ├── models
    │   │       │   ├── dimensional_models.md
    │   │       │   ├── sources.yaml
    │   │       │   └── ticketfinder
    │   │       ├── packages.yml
    │   │       ├── profiles.yml
    │   │       └── target
    │   │           ├── catalog.json
    │   │           ├── compiled
    │   │           │   ├── elementary
    │   │           │   │   ├── dbt_project.yml
    │   │           │   │   └── models
    │   │           │   │       └── edr
    │   │           │   │           ├── alerts
    │   │           │   │           ├── data_monitoring
    │   │           │   │           ├── dbt_artifacts
    │   │           │   │           ├── metadata_store
    │   │           │   │           ├── run_results
    │   │           │   │           └── system
    │   │           │   └── raw_ingestion
    │   │           │       └── models
    │   │           ├── index.html
    │   │           ├── manifest.json
    │   │           ├── run
    │   │           │   ├── elementary
    │   │           │   └── raw_ingestion
    │   │           ├── run_results.json
    │   │           └── semantic_manifest.json
```
