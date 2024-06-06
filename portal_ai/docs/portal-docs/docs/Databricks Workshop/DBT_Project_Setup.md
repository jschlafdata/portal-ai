---
sidebar_position: 8
---

# DBT Project Setup

![Dbt Folder Structure](/img/dbt/folder_structure.png)

## Main Concepts

* Projects should follow the [raw] - [clean] - [aggregate] flow.
* There should be a  `global modules` project, this contains common macros and modules to be used across all company projects.
* There should be a `metrics` project that defines and creates standardized metrics across the company.
* All raw data should flow through a `raw ingestions project`, which applies tests and ensures data integrity on all tables and sources before use across any team dbt project.
* Every project is then imported into one global dbt project, to be used for documentation and lineage for all projects, metrics, tests, and macros.


## Raw Clean Agg

### Separation of Concerns

![raw clean agg](/img/dbt/raw_clean_agg.png)


### Incremental Complexity
Starting with raw data and moving towards aggregated data allows teams to manage complexity in incremental steps. Each layer builds on the previous one, simplifying the debugging process and making the data transformation pipeline more manageable.

### Reusability and Modularity
By structuring data transformation in these layers, organizations can create modular, reusable components. For instance, cleaning operations that are common across multiple data sources can be standardized and applied uniformly, improving efficiency and consistency.


### Collaboration and Clarity
This structured approach helps in defining clear roles and responsibilities within data teams. Analysts, data engineers, and data scientists can collaborate more effectively when there is a clear understanding of the data flow and transformation process.

### Supporting Data Governance
By clearly separating data into different layers, organizations can implement data governance policies more effectively. For example, access controls can be more granular, with sensitive raw data being tightly controlled while providing broader access to aggregated data for analysis.


----------

## Global Modules Examples

* Commonly used date calendars.
* Commonly used tests
  * Date Spine Macro
  * Grouped Amount Within Range
  * Source Data Latency / Freshness Requirments

<details>
<summary>Date Spine Macro</summary>
<p>

A concept used to generate a series of dates that span a defined interval, ensuring there is a record for every day within that range.

```sql title="date_spine_macro.sql"
{% macro date_spine_macro(fq_table,
                          column_name,
                          start_date_,
                          end_date_lag_,
                          quote_values=True,
                          row_condition=None        
                          ) %}

with all_values as (

    select
        to_date({{ column_name }}) as value_field

    from {{ fq_table }}
    {% if row_condition %}
    where {{ row_condition }}
    {% endif %}

),
set_values1 as (
        {{ dbt_utils.date_spine(
            datepart= 'day',
            start_date= "'" + start_date_ + "'",
            end_date="date_add(current_date(), -" + end_date_lag_ + ")"
        )}}
)
,
set_values as (
    select to_date(DATE_DAY) as value_field from set_values1
)
,
validation_errors as (
    -- values from the model that are not in the set
    select
        v.value_field
    from
        set_values s
    left join
        all_values v on s.value_field = v.value_field
    where
        v.value_field is null
)

select *
from validation_errors

{% endmacro %}
```

```yaml title="date_spine_macro( usage )"
version: 2

models:
  - name: missing_sale_dates
    description: >
      This model identifies missing sale dates in the sales_data table within the specified date range.
      It utilizes the `date_spine_macro` to generate a complete list of dates between 2023-01-01 and
      10 days ago from the current date, then identifies any dates not present in the sale_date column
      of the your_schema.sales_data table.
    meta:
      macro_usage:
        date_spine_macro:
          fq_table: 'your_schema.sales_data'
          column_name: 'sale_date'
          start_date_: '2023-01-01'
          end_date_lag_: '10'
          quote_values: true
    columns:
      - name: sale_date
        description: The date of sale. This model highlights missing dates in this column.
```
</p>
</details>

<details>
<summary>Grouped Amount Within Range</summary>
<p>

It selects groups where the total amount is either below a minimum value or above a maximum value. This can be useful for identifying outliers or segments within your data that do not meet certain aggregate criteria.

How the Macro Works
* `model` parameter: The name of the dataset or table you want to apply the macro to.
* `value_col` parameter: The name of the column whose values you want to sum up.
* `group_by_columns` parameter: A list of column names by which you want to group your data.
* `min_value` parameter: The minimum threshold for the sum of the value_col for each group.
* `max_value` parameter: The maximum threshold for the sum of the value_col for each group.

```sql title="grouped_amount_within_range.sql"
{% macro test_grouped_amount_within_range(model, value_col, group_by_columns, min_value, max_value) %}

{% set group_by = group_by_columns|join(', ') %}

WITH grouped_data AS (
    SELECT
        {{ group_by }},
        SUM( {{ value_col }} ) as total_amount
    FROM
        {{ model }}
    GROUP BY
        {{ group_by }}
)

SELECT
    {{ group_by }}
FROM
    grouped_data
WHERE
    total_amount < {{ min_value }} OR total_amount > {{ max_value }}

{% endmacro %}
```

```yaml title="grouped_amount_within_range ( usage )"
version: 2

models:
  - name: outlier_sales
    description: >
      This model uses the `test_grouped_amount_within_range` macro to identify sales records
      where the total sales amount by region and product_id is either below $1,000 or above $10,000.
    columns:
      - name: region
        description: The sales region.
      - name: product_id
        description: The ID of the product.
      - name: total_amount
        description: The total sales amount for the group.
    meta:
      macro_usage:
        name: test_grouped_amount_within_range
        parameters:
          model: sales_data
          value_col: amount_sold
          group_by_columns: ['region', 'product_id']
          min_value: 1000
          max_value: 10000
```
</p>
</details>


![module usage](/img/dbt/modules_granular.png)

### Global Modules Usage

In this example, standard macros are defined in the global modules project.

```yaml title="example import"
## The global modules project is then imported into each business 
## unit project, and these macros can be used across teams, 
## while ensuring standardized tests and data quality assurances are met.

packages:
  - package: elementary-data/elementary
    version: 0.10.3

  - package: calogica/dbt_expectations
    version: 0.9.0
  
  - local: ./dbt_global_modules
  - local: ./global_metrics_macros
```

---------

## Global Metrics

![raw clean agg](/img/dbt/metrics_granular.png)

### Central Metric Repository
A dbt project dedicated to metrics can act as a central repository where all company-wide metrics are defined, calculated, and documented.

* Cross-Departmental Reporting: By referencing the standardized metrics and calculations, different departments can create their reports and analyses, ensuring that everyone bases their insights on the same data foundation.
* Data Product Development: The standardized metrics can be incorporated into data products, tools, and services provided to internal users or external customers, ensuring that these offerings are both reliable and consistent.

#### WHY IS THIS VALUABLE
* `Consistency Across Reports and Dashboards`
    * Unified Definitions: Having a single source of truth for metric definitions ensures that all teams within the company use the same logic and calculations. This consistency is vital for maintaining trust in data reports and dashboards across different departments.
    Standardization: Standardized macros for calculations prevent discrepancies in how metrics are calculated from one report to another, reducing confusion and increasing the reliability of data-driven decisions.
2. `Efficiency and Time Savings`
    * Reusable Code: Standardized macros can be reused across multiple models and projects, saving time that would otherwise be spent on rewriting or verifying the logic for common calculations.
    Agility: Changes to metric definitions or calculation logic need to be made in one place, allowing companies to quickly adapt to new business requirements or data strategies.
3. `Improved Data Governance`
    * Auditability: A dedicated project for metrics and calculations makes it easier to audit metric definitions and ensure they comply with regulatory requirements and internal policies.
    Access Control: Centralizing metric calculations allows for more controlled access to sensitive business logic and data transformations, which is crucial for protecting proprietary information and ensuring data privacy.
4. `Enhanced Collaboration`
    * Cross-functional Alignment: A unified approach to metrics fosters better collaboration between departments by aligning everyone on the same definitions and business logic.
    Documentation and Knowledge Sharing: Centralized metric definitions and macros encourage better documentation practices, making it easier for new team members to understand the data architecture and for the entire organization to benefit from shared knowledge.

<details>
<summary>sum_MoM_YoY_CYTD_single_dimension</summary>
<p>

This macro is designed to calculate several metrics for a given metric, dimension, and model: 
* the current month's metric
* the previous month's metric
* Month-over-Month (MoM) percentage change
* Year-over-Year (YoY) percentage change
* Calendar Year-To-Date (CYTD) percentage change

```sql title="metric macro definition"
{% macro sum_MoM_YoY_CYTD_single_dimension(model_reference, id, dimension, metric) %}

 with lags as ( select month_date,
                       {{ dimension }},
                       sum({{ metric }}) as  metric,
                         
                      lag(sum({{ metric }}), 1) over (partition by {{ dimension }}  order by month_date) as metric_lag1,
                      100*(((sum({{ metric }}) - lag(sum({{ metric }}), 1) over (partition by {{ dimension }}  order by month_date))) / lag(sum({{ metric }}), 1) over (partition by  {{ dimension }} order by month_date)) MoM,
                      100*(((sum({{ metric }}) - lag(sum({{ metric }}), 12) over (partition by {{ dimension }}  order by month_date))) / lag(sum({{ metric }}), 12) over (partition by  {{ dimension }} order by month_date)) YoY
     
                   from {{ model_reference }}
                   group by 1,2 
                ),
  rolling_year as 
    ( 
    select *,
            sum(metric) over (partition by year(month_date), {{ dimension }}  order by month_date) as rolling_year_sum
    from lags 
    )
    ,
  stage_metrics as ( 
        select month_date,
               {{ dimension }},
                metric,
                metric_lag1,
                MoM,
                YoY,
                rolling_year_sum
      from rolling_year 
    )
                   
select month_date,
      '{{ id }}' AS id,
      {{ dimension }},

      sum( metric ) as current_month_metric,
      sum( metric_lag1 ) as previous_month_metric,

      sum( MoM ) as MoM,
      sum( YoY ) as YoY,
      100*((sum(rolling_year_sum) - lag(sum(rolling_year_sum), 12) over (partition by {{ dimension }}  order by month_date))/lag(sum(rolling_year_sum), 12) over (partition by {{ dimension }}  order by month_date)) as CYTD
      
from stage_metrics 
group by 1,2,3

{% endmacro %}
```

```yaml title="MoM, YoY, CYTD Calculation ( usage )"
version: 2

models:
  - name: financial_metrics_analysis
    description: >
      This model calculates financial metrics including current month metric, previous month metric,
      Month-over-Month (MoM) change, Year-over-Year (YoY) change, and Calendar Year-To-Date (CYTD)
      change for a given dimension within the financial_data table. It leverages the
      `sum_MoM_YoY_CYTD_single_dimension` macro to perform these calculations efficiently.
    meta:
      macro_usage:
        sum_MoM_YoY_CYTD_single_dimension:
          model_reference: 'your_schema.financial_data'
          id: 'financial_metrics_id'
          dimension: 'region'
          metric: 'sales_amount'
```
</p>
</details>

---------

## Bringing it all together

![global project](/img/dbt/dbt_parent_diagram.png)

:::note
Every project is imported into one "parent" project. This parent project does not create models, build tables, define or create any macros.

It's sole purpose is to aggregate all projects metadata into one central repository.

This is the project where you run the commands to serve the DBT documentation portal with docs and lineage across all company projects.
:::

```bash title="teminal commands"
dbt docs generate
dbt docs serve
```

```yaml title="global_parent_project packages.yaml"
packages:
  - package: elementary-data/elementary
    version: 0.10.3

  - package: calogica/dbt_expectations
    version: 0.9.0
  
  - local: ./dbt_global_modules
  - local: ./global_metrics_macros
  - local: ./accounting_team_models
  - local: ./finance_team_models
  - local: ./accounting_dashboards
  - local: ./finance_dashboards

```

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
