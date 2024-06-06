---
sidebar_position: 6
---

# 📂 A Metadata Driven ETL Framework
**The main notebook executed can be found here:** [concert_finder_notebook_job](https://adb-6739836370169955.15.azuredatabricks.net/?o=6739836370169955#notebook/3580129547584263/command/3580129547584320)

----------
## Topics and Concepts ##

* Effective Project Structure.
* Enabling Collaboration Across Projects or Pipelines.
* Using Frameworks to Automate CI/CD Pipelines.
* Data Engineering Best Practices.
* Databricks Concepts for Storage and History Tracking.
* Managing Data Quality and Observability for the Raw Ingestion Layer.
* Advanced Python Concepts and Modules.
* Creating an Agile and Fault Tolerant Data Pipeline System.
 


----------
:::important
This is an outline for a structured approach for managing ETL (Extract, Transform, Load) pipelines within a Databricks environment, using a project named `concert_finder` as an example project.

This documentation will walk you through the folder structure, the purpose of each component, and how YAML files are employed to configure and provide variables for the ETL pipelines executed in Databricks notebooks.
:::

----------
## Folder Structure Overview

The structure is designed to organize code, configuration files, and Databricks notebooks in a way that facilitates easy management and scalability of ETL processes. 

Below is an outline of the folder structure which is ***crucial*** to make use of the framework described in this paper:

```md
├── dbx_code
│   ├── global_python_modules
│   │   ├── catalog_utilities
│   │   └── notebook_executors
│   └── pipelines
│       ├── concert_finder [project_name]
│       │   ├── get_current_notebook_paths.py
│       │   └── jobs
│       │       ├── scrape_music_venues.yaml 
│       │       └── scrape_music_venues.dbc  
│       ├── pipeline_settings.yaml
│       └── scrape_music_venues.params.yaml 
```
##
----------
## Main Components ##

| Component                         | Description                                                                                                                                                     |
| --------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `get_current_notebook_paths.py`   | A Python script to retrieve and manage paths relevant to the current Databricks project, facilitating the dynamic loading of configurations and modules.        |
| `jobs/`                           | A folder containing job configurations (`*.yaml`) and Databricks notebooks (`.dbc`) `notebooks` for specific ETL tasks.                                         |
| `scrape_music_venues.yaml`        | A YAML configuration file specifying job parameters for scraping music venues, such as URLs, headers, and regex patterns for data cleaning.                     |
| `pipeline_settings.yaml`          | A YAML file containing global settings for the ETL pipeline, including schema names, data layers, and a list of Python modules to be used across the project.   |
| `scrape_music_venues.params.yaml` | A YAML file defining parameters for the `scrape_music_venues` job, including load frequency, strategy, schema definitions, and third-party libraries to import. |

----------
# YAML Configuration Files

<details>
<summary>pipeline_settings.yaml</summary>
<p>

### Common parameters for all jobs in the project.
This file serves as the central configuration for all jobs withing the [project_name], defining project-wide settings such as the schema name, data catalog and layer, and global Python modules for use in the pipeline.
- **Project Details:** Specifies the name of the project (`concert_finder`) and settings for data ingestion.
- **Global Modules:** Lists Python modules that are globally available for the pipeline, enhancing modularity and reusability of code.
- **Notebooks:** Defines the Databricks notebooks that are part of the ETL processes.
</p>
</details>


<details>
<summary>scrape_music_venues.params.yaml</summary>
<p>

### Job level parameters related to schemas.
Contains specific parameters for the `scrape_music_venues` job, such as how often the data load should occur, the loading strategy, and the schema definition for the ingested data.

- **Load Configuration:** Details on how data should be loaded (e.g., daily, incrementally) and how to handle merging with existing data.
- **Schema Definition:** Outlines the data structure of the scraped content, including dimensions and primary keys.
</p>
</details>

<details>
<summary>scrape_music_venues.yaml</summary>
<p>

### Job specific variables
Configures the job for scraping music venues, including the base URLs, HTTP headers for requests, and regex patterns for data cleaning.

- **Job Blocks:** Defines various settings for scraping different venues, such as URLs and headers.
- **Variables:** Specifies regex patterns for cleaning scraped data from different venues.
</p>
</details>


----------
## Notebook Execution and Path Management ##
### GetCurrentEnviornmentPaths ###
* Located in the script `get_current_notebook_paths.py`
* Plays a crucial role in dynamically managing paths and global variables within the Databricks environment.
# 

:::note

The idea is to enable easy navigation and access to project components, facilitating efficient development and execution of ETL tasks.

After this framework is used and digested, the idea is that data engineers no longer have to think about monotonous work that is the same across all projects and workflows. As such, engineers can focus more on the technical challenges of the process.

:::
\
**Environment and Paths:** Dynamically generates paths based on the current environment (e.g., dev, stage, production) and the project structure, aiding in the proper loading of configurations and modules.


```sh
You are currently developing in the 'development' environment.
------------------------------------------
The current Databricks repository is 'if-insurance-databricks'.
------------------------------------------
You are working within the project 'concert_finder'.
------------------------------------------
The current Databricks notebook you are using is 'scrape_music_venues'.
------------------------------------------

databricks_project_path: 
----------| /Repos/development/if-insurance-databricks/dbx_code/

databricks_dbt_path: 
----------| /Repos/development/if-insurance-databricks/dbx_code/dbt

databricks_global_modules_path: 
----------| /Repos/development/if-insurance-databricks/dbx_code/global_python_modules

databricks_etl_pipelines_path: 
----------| /Repos/development/if-insurance-databricks/dbx_code/pipelines
```



- **Contextual Information:** Provides developers with information about the current workspace, repository, and notebook paths, enhancing the development experience and eliminating the need to go looking for job parameters or variable definitions.


* This also facilitates the first step of the framework***
    - Test to see if these resources exist for the current job, if they do not, they are created.
            - `[ catalog ]` 
            - `[ schema ]`
            - `[ logging_table ]`
            - `[ destination_table ]`


----------
### `ValidateCatalogs()`

The `ValidateCatalogs` class is designed to validate the existence of catalogs, schemas, and tables within a Databricks environment.

### Parameters:

- `catalog` (str, optional): The name of the catalog to validate. Default is `None`.
- `schema` (str, optional): The name of the schema to validate. Default is `None`.
- `table` (str, optional): The name of the table to validate. Default is `None`.

```py
class ValidateCatalogs:
    def __init__(self, 
                 catalog=None, 
                 schema=None, 
                 table=None):
        
        self.catalog = catalog
        self.schema = schema
        self.table = table

        self.fq_schema = f"{catalog}.{schema}".lower() if schema is not None else None
        self.fq_table = f"{table}".lower() if table is not None else None

        self.result_dict = {}

    def catalog_exists(self, spark):
        if self.fq_table is not None:
            test_query = f"describe table {self.fq_table};"
            self.result_dict[self.fq_table] = TryExceptFuncWrapper(lambda: spark.sql(test_query)).__call__()

        if self.fq_schema is not None:
            test_query = f"describe schema {self.fq_schema};"
            self.result_dict[self.fq_schema] = TryExceptFuncWrapper(lambda: spark.sql(test_query)).__call__()

        if self.catalog is not None:
            test_query = f"describe catalog {self.catalog};"
            self.result_dict[self.catalog] = TryExceptFuncWrapper(lambda: spark.sql(test_query)).__call__()

        return self.result_dict
```


### Behavior

- Initializes instance variables to store the provided catalog, schema, and table names.
- Constructs fully qualified (FQ) names for the schema and table, if applicable, by concatenating the catalog name with the schema or table name, respectively, and converting them to lowercase. This is done to standardize the format for SQL queries and Unity Catalog names.
- Initializes an empty dictionary, `result_dict`, to store the results of the `existence checks`.


### `catalog_exists()`

Performs validation checks to determine the existence of the specified catalog, schema, and table in the Databricks environment.

### Returns

* A dictionary (`result_dict`) containing the results of the existence checks for the catalog, schema, and table.
* The results of these checks (success or failure) are stored in the `result_dict` dictionary, with the fully qualified names of the table and schema, or the catalog name, serving as keys.
* The method ultimately returns the `result_dict` containing the outcomes of all validation checks. 


### Example Usage


```py
from pyspark.sql import SparkSession

catalog_validator = ValidateCatalogs(catalog='my_catalog', 
                                     schema='my_schema', 
                                     table='my_table')

validation_results = catalog_validator.catalog_exists()
print(validation_results)
```

----------
## Standardized Logging Tables for all Pipelines

The `log_tables.py` script is designed to facilitate the creation of logging tables within a data warehousing environment. These tables are crucial for monitoring and auditing data pipeline operations, such as data ingestion, transformation, and loading (ETL) processes. Below, we'll dive into the purpose, structure, and usage of the code within this file.

## **Overview**

The primary function in this script, `CreateLogTables`, dynamically creates a logging table in a Delta Lake format if it doesn't already exist. This is used to track all outcomes within data pipelines, including but not limited to, the number of records inserted, updated, or deleted, as well as the execution status of specific tests.

**Function Description**

- **Function Name**: `CreateLogTables`
- **Purpose**: To create a Delta Lake logging table if it does not already exist.
- **Parameters**:
    - `table`: The name of the table to be created or validated for existence.

**Table Schema**
The table schema defined within the `CreateLogTables` function is as follows:


| **Column Name**        | **Data Type** | **Description**                                                           |
| ---------------------- | ------------- | ------------------------------------------------------------------------- |
| `PIPELINE_NAME`        | STRING        | The name of the data pipeline.                                            |
| `FQ_DESTINATION_TABLE` | STRING        | The fully-qualified name of the destination table.                        |
| `UNIQUE_RUN_UUID`      | STRING        | A unique identifier for a specific pipeline run.                          |
| `UNIQUE_TABLE_RUN_ID`  | BIGINT        | A unique identifier for a specific table within a pipeline run.           |
| `TEST_EXECUTED`        | STRING        | The name of the test executed during the pipeline run.                    |
| `TEST_RESULT`          | BOOLEAN       | The result of the test (True for passed, False for failed).               |
| `DATES_PROCESSED`      | STRING        | The dates that were processed during the pipeline run.                    |
| `RECORDS_INSERTED`     | BIGINT        | The number of records inserted during the pipeline run.                   |
| `RECORDS_UPDATED`      | BIGINT        | The number of records updated during the pipeline run.                    |
| `RECORDS_DELETED`      | BIGINT        | The number of records deleted during the pipeline run.                    |
| `LOAD_TYPE`            | STRING        | The type of load operation performed (e.g., full load, incremental load). |
| `LOG_MESSAGE`          | STRING        | A message providing additional context or details about the pipeline run. |
| `DW_INGEST_TS`         | STRING        | The timestamp when the data was ingested into the data warehouse.         |

----------
## Example of Logging Results

```sql
// Logs for every pipeline in a Catalog are stored in
// one table to simplify alerts and monitoring.

select PIPELINE_NAME,
        UNIQUE_RUN_UUID,
        UNIQUE_TABLE_RUN_ID,
        LOG_MESSAGE,
        DW_INGEST_TS
from raw_ingestion_data__dev.pipeline_metadata.task_logging
order by UNIQUE_TABLE_RUN_ID desc;
```

| # | PIPELINE_NAME         | UNIQUE_RUN_UUID                       | UNIQUE_TABLE_RUN_ID | LOG_MESSAGE                                          | DW_INGEST_TS         |
|---|-----------------------|---------------------------------------|---------------------|------------------------------------------------------|----------------------|
| 1 | scrape_music_venues   | a3b76b29-a3df-45...  | 4                   | Success                                              | 2024-02-14 23:12:02  |
| 2 | scrape_music_venues   | 9ffa9ff5-1516-40...  | 3                   | Success                                              | 2024-02-14 19:48:28  |
| 3 | scrape_music_venues   | cbfd36fd-a35a-48...  | 2                   | Success                                              | 2024-02-14 11:31:21  |
| 4 | scrape_music_venues   | 442b15af-6a4d-45...  | 1                   | Success                                              | 2024-02-14 09:24:09  |
| 5 | scrape_music_venues   | 1725a238-0973-4f...  | 0                   | Pipeline failure: name 'regex_mappings' is not defined | 2024-02-14 08:22:22  |

---------

<details>
<summary>Create Log Tables DDL</summary>
<p>
1. **Table Creation Statement**: The function constructs an SQL statement to create a Delta Lake table with the standardized logging schema.

2. **Table Existence Check**: Before attempting to create the table, the script checks whether the table already exists by using a placeholder function `ValidateCatalogs`.
3. **Conditional Execution**: If the table does not exist (`tbl_exists` is `False`), the SQL statement to create the table is executed using `spark.sql(log_table_create)`. Otherwise, the function returns without performing any action.

```py
def CreateLogTables(table):
    log_table_create = f"""
        CREATE TABLE IF NOT EXISTS 
          {table} (
                    `PIPELINE_NAME` STRING,
                    `FQ_DESTINATION_TABLE` STRING,
                    `UNIQUE_RUN_UUID` STRING,
                    `UNIQUE_TABLE_RUN_ID` BIGINT,
                    `TEST_EXECUTED` STRING,
                    `TEST_RESULT` BOOLEAN,
                    `DATES_PROCESSED` STRING,
                    `RECORDS_INSERTED` BIGINT,
                    `RECORDS_UPDATED` BIGINT,
                    `RECORDS_DELETED` BIGINT,
                    `LOAD_TYPE` STRING,
                    `LOG_MESSAGE` STRING,
                    `DW_INGEST_TS` STRING
        ) USING DELTA;"""
    
    tbl_exists = ValidateCatalogs(catalog=None, 
                                    schema=None, 
                                    table=table).catalog_exists(spark).get(table)
    print(tbl_exists)
    print('table name')
    
    if tbl_exists is False:
        spark.sql(log_table_create)
    return
```

#### The `log_tables.py` script is a utility for ensuring that your data pipelines have the necessary logging infrastructure in place for effective monitoring and auditing.

</p>
</details>

### How it works

1. Every time a job runs it increments the `UNIQUE_TABLE_RUN_ID` by 1
    * If it is the first time it has ever run, it starts at 0.

2. Each run generates a new random `UNIQUE_RUN_UUID`
3. Each step of the pipeline trys a given block, and if it fails logs the error here.

:::note    
`UNIQUE_TABLE_RUN_ID` also maps to the [`Delta Change Data Feed`](https://docs.databricks.com/en/delta/delta-change-data-feed.html) which gives additional metadata on table activity like inserts & deletes. This mapping is used later in the framework.
:::

:::note
#### Some ways to make use of these logs down stream...
1. Setting up [`Databricks SQL Alerts`](https://docs.databricks.com/en/sql/user/alerts/index.html)
2. Ingesting logs into DBT as views, and creating DBT tests on top of log messages and test results.
:::

----------


# Automate any pipeline that is Pandas DF → Staging Table → Destination Table 📦🤖

The `warehouse_automation_framework.py` is a Python script designed to streamline the data processing and management process, emphasizing best practices such as modular design, data staging, and the use of parameterized scripts. This document outlines the functionalities provided by the script and highlights why certain practices are pivotal in data engineering.

## Table of Contents
- [Function Documentation](#)
- [Pipeline Example](#)
- [Best Practices](#)
    - [Staging Tables](#)
    - [Parameterized & Modular Python Scripts](#)
- [Pipeline Execution](#)
## Function Documentation
| Function Name               | Purpose                                                                               | Best Practice                                                             |
| --------------------------- | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| `create_table_if_not_exist` | Checks if a table exists in Delta Lake and creates it with a specified schema if not. | Ensures idempotency in data pipelines.                                    |
| `add_columns`               | Adds specific columns to a DataFrame for tracking data lineage and versioning.        | Enhances data traceability and auditability.                              |
| `dataframe_to_stage`        | Stages DataFrame data into a Delta Lake table for transformation or loading.          | Allows for data validation and transformation in an isolated environment. |
| `merge_stage_to_dest`       | Merges data from a staging table to a destination table based on a primary key.       | Minimizes data duplication and maintains data integrity.                  |

These transformation functions are crucial for ensuring data quality and reliability for downstream analysis.

**Making Use of Variables from** **[ scrape_music_venues.yaml ]**

```py
def make_headers(json_headers):
    # Static or required headers with default values
    headers = {
        'Connection': 'keep-alive',
        'Sec-Fetch-Site': 'same-origin',
    }
    # Optional keys that are expected to be in the json_headers
    optional_keys = ['authority', 'referer', 'origin']

    # Add provided headers if they have a non-None value
    for key in optional_keys:
        value = json_headers.get(key)
        if value is not None:
            headers[key.capitalize()] = value  # Capitalize the key as needed
    return headers

# example of reading variables in and using throughout the job.
def co_clubs(notebook_variables):

    variables_from_yml = notebook_variables\['blocks'\]['co_clubs']
    venue_name = variables_from_yml.get('clean_name')

    request = requests.get('https://www.coclubs.com/event-calendar', 
                            headers=make_headers(variables_from_yml['headers']),
                            verify=False)
```

- It extracts variables related to co_clubs from a YAML file (`notebook_variables\['blocks'\]['co_clubs']`).
- It attempts to get the value of `'clean_name'` from the extracted variables.
- It then makes an HTTP GET request to `'https://www.coclubs.com/event-calendar'` with custom headers.
    - The custom headers are generated using the `make_headers()` function, passing `variables_from_yml['headers']` as the argument.



## Staging Tables (Tips for Using)
----------
:::tip Why use Staging Tables
* They provide an isolated environment for data validation, transformation, and cleansing before merging into production datasets.
* This isolation helps prevent data corruption and ensures only verified, high-quality data is merged into destination tables.
:::

#### *When using staging tables in ETL processes, consider the following:*

- `Separation`: Keep ETL staging tables separate from durable tables, either logically or physically, to enhance performance and maintain clarity.


- `Permanent Tables`: Prefer permanent staging tables over temporary ones to ensure data availability for debugging and metadata validation.


- `Indexing`: Strategically index staging tables to improve performance in subsequent ETL steps.


- `Emptying Staging Tables`: Empty staging tables before and after the load to optimize storage space and backup time.


- `Data Lineage`: Configure staging tables to support data lineage tracking if necessary, by adding relevant columns for tracking source-to-destination evidence.

----------
## Metadata Driven ETL Framework in Action

### Parameterized & Modular Python Scripts
* **Parameterization** makes scripts flexible and reusable, allowing easy adaptation for new data sources or schema changes without significant code modifications.
* **Modular** design enhances readability, simplifies debugging, and supports unit testing for individual components.

* Pipeline Execution Functions:
The script executes the data pipeline through several functions:


1. `load_data`: Aggregates data from multiple sources and loads it into DataFrames.


    ```py
    ## Initialize logging module to track all success's or failures.
    pipeline_logging = DeltaPipelineLogging(global_pipeline_variables)

    def load_data(blocks, notebook_variables):
        final_dataframes = []
        # Loop through each function and call it with notebook_variables
        for func in blocks:
            try:
                result_df = func(notebook_variables)
                final_dataframes.append(result_df)
            except Exception as e:
                print(f"An error occurred while executing {func.__name__}: {e}")
        combined_venues_scrapes = pd.concat(final_dataframes)
        return combined_venues_scrapes
    ```

2. `transform_data`: Applies transformations to the loaded data.

    ```py
    def transform_data(df, notebook_variables):
        df.date = df.date.map(normalize_ts)
        df['filtered_artist'] = df.apply(artistSplit, axis=1)
        return df
    ```

3. `prepare_destination`: Prepares the destination environment for data merge.
    * ### Make sure the destination table exists, if it does not, create it using the schema defined in the yaml file:

        ```yaml
        load_frequency: daily
        load_type: incremental
        load_strategy: merge_pk
        schema_definition:
            dimensions:
            - artist: string
            - date: string
            - link: string
            - venue: string
            - img_url: string
            - filtered_artist: ARRAY<STRING>
            primary_key:
            - hash(artist, date, link, venue)
        ```

        ```py
        ## creating the destination table if it does not exist
        def prepare_destination(global_pipeline_variables):
                notebook_params = global_pipeline_variables.get('notebook_parameters')
                notebook_schema = gnotebook_params.get('schema_definition')

                destination_table = global_pipeline_variables.get('fq_destination_table')

                create_table_if_not_exist( table_name=destination_table, 
                                            schema=notebook_schema )
                return True
        ```


4. `stage_data`: Stages the transformed data.

    ```py
        def stage_data(df, global_pipeline_variables):
            dataframe_to_stage( df, global_pipeline_variables )
            return True
    ```


5. `merge_df_to_table`: Merges the staged data into the final destination table.

    ```py
    def merge_df_to_table(df, global_pipeline_variables):

        notebook_params   = global_pipeline_variables.get( 'notebook_parameters' )
        notebook_schema   = notebook_params.get( 'schema_definition' )

        destination_table = global_pipeline_variables.get('fq_destination_table')
        stage_table       = global_pipeline_variables.get('fq_staging_destination')

        merge_stage_to_dest( destination_table=destination_table,
                                stage_table=stage_table,
                                notebook_schema=notebook_schema )
        return True
    ```


6. `main_executor`: Orchestrates the execution of the entire pipeline.


* #### For the final step, each step in the process is tried individually so that any failure will be caught and logged immediately at the point of failure 
    - For example, if the job failed at the transform_data function, the error that is thrown from that function could log specific enough details so that an engineer can immediately find the root issue and attempt to remedy.


        ```py
        def main_executor( blocks, 
                           notebook_variables, 
                           global_pipeline_variables ):
            try:
                df = load_data(blocks, notebook_variables)
                df = transform_data(df, notebook_variables)
                prepare_destination(global_pipeline_variables)
                stage_data(df, global_pipeline_variables)
                merge_df_to_table(df, global_pipeline_variables)
                return True
            except Exception as e:
                pipeline_logging.log_error(f"Pipeline failure: {e}")
                return False
        ```


----------
## Effective Error Handling, Logging, and Data Quality **📘.**

### DeltaPipelineLogging()

The `DeltaPipelineLogging` class plays a crucial role in automating logging for data pipelines. It is designed to capture and log various aspects of the pipeline's execution, such as successes, failures, and custom test outcomes, providing a structured and comprehensive overview of the pipeline's performance.

***This is extremely useful for quickly identifying why a job is failing, and making data engineers lives much more fun. Trust me lol.***



```py title="Pipeline Delta Logging Class Overview"
class DeltaPipelineLogging:

    # initializes the logging class with essential
    # pipeline parameters and sets up default values
    # for various logging attributes.

    def __init__(self, 
                 global_pipeline_variables): ...

    def write_log_to_delta(self): ...

    def log_error(self, 
                  error_message, 
                  test_executed=None): ...
    
    def log_pipeline_success(self, 
                             records_inserted, 
                             records_updated, 
                             records_deleted, 
                             dates_processed=''): ...
                             
    def log_custom_test(self, 
                        test_executed, 
                        test_result, 
                        dates_processed=''): ...
```    


## Parameters:

- `global_pipeline_variables`: A dictionary containing key pipeline parameters such as the notebook name, destination table fully qualified name, unique run UUID, unique table run ID, and load type.

## Attributes:

- `pipeline_name`, `fq_destination_table`, `unique_run_uuid`, `unique_table_run_id`, `load_type`: Store basic information about the pipeline run.
- `test_executed`, `test_result`, `dates_processed`, `records_inserted`, `records_updated`, `records_deleted`, `log_message`, `dw_ingest_ts`: Initialized to hold details about tests executed, the outcome of those tests, dates processed, counts of records inserted/updated/deleted, a log message, and the timestamp of log creation.


```py title="write_log_to_delta"
# Creates a DataFrame for the log entry and writes it to the Delta log table.

logging_instance = DeltaPipelineLogging(global_pipeline_variables)
logged = logging_instance.write_log_to_delta()
```

<details>
<summary>logging_instance.log_error()</summary>
<p>
* #### Logs an error that occurred during the pipelines execution, capturing the error message and the current timestamp, and indicating a failure state by resetting processing records and tests.

```py title=""
logging_instance = DeltaPipelineLogging(global_pipeline_variables)

logged = logging_instance.log_error(error_message,  
                                    test_executed='type of test run')
```

</p>
</details>


```py title="log_error"

logging_instance = DeltaPipelineLogging(global_pipeline_variables)

logged = logging_instance.log_error(error_message,  
                                    test_executed='type of test run')
```


### Method: `log_error(self, error_message, test_executed=None)`
Logs an error that occurred during the pipeline's execution, capturing the error message and the current timestamp, and indicating a failure state by resetting processing records and tests.

## Parameters:

- `error_message`: Describes what went wrong during the pipeline execution.
- `test_executed`: Optionally specifies a particular test executed at the time of the error.

### Method: `log_pipeline_success(self, records_inserted, records_updated, records_deleted, dates_processed='')`

Logs the successful completion of the pipeline, including the number of records processed and the dates those records pertain to.
## Parameters:

- `records_inserted`, `records_updated`, `records_deleted`: Count of records that were inserted, updated, and deleted.
- `dates_processed`: The dates processed in the current run.


Logs the execution and result of custom tests performed at the end of the pipeline script, separately from other pipeline logs.

## Parameters:

- `test_executed`: A description or identifier of the test.
- `test_result`: The result of the test execution, typically a boolean indicating success or failure.


## Summary
The `DeltaPipelineLogging` class offers a structured approach to capture detailed logs of a data pipeline's execution. This includes handling errors, recording the success of data processing, and logging the results of custom tests. Implementing and extending this class to integrate with your organization's logging and monitoring systems can significantly enhance operational visibility and error handling in data pipelines, particularly those involving Delta Lake tables.


----------
## Vacuum Tables Documentation 🧹✨

The `vacuum_tables.py` script contains a function critical for the health and efficiency of Delta Lake tables within Databricks environments. This document outlines the purpose, usage, and importance of the `vacuum_table` function contained within this script.

:::warning
#### This should always be executed at the end of every job or pipeline. Using this framework, you do not actually need to execute these functions, since the job parameters can automate vacuum execution at the end of every pipeline.
:::

## Function Overview
- Purpose: To automate the cleanup of old data files from a Delta Lake table, thus maintaining the table's efficiency.
- Function Name: `vacuum_table`

## Parameters

| Parameter      | Type | Description                                                                                    |
| -------------- | ---- | ---------------------------------------------------------------------------------------------- |
| `table_name`   | str  | The name of the Delta Lake table to be vacuumed.                                               |
| `retain_hours` | int  | The retention period in hours. Data files older than this period will be eligible for removal. |

    ## example usage. This vacuums the destination table and the logging table.
    
    vacuum_table(global_pipeline_variables.get('fq_destination_table'), 168)
    vacuum_table(global_pipeline_variables.get('fq_log_table'), 168)


----------
## How to Use `vacuum_table` Function

Below is a simple example demonstrating how to call the `vacuum_table` function:
#
--------

```python
# Define the Delta Lake table name and retention period
table_name = "your_delta_lake_table_name"
retain_hours = 48  # Example retention period

# Perform the VACUUM operation
result_message = vacuum_table(table_name, retain_hours)
print(result_message)
``` 

### Example Output:
```
VACUUM operation on table 'your_delta_lake_table_name' completed successfully.
```

### Example Error:
```
Error performing VACUUM operation on table 'your_delta_lake_table_name': 
    [Error details]
```

## Importance of Vacuuming Tables in Databricks

Vacuuming tables, especially in the context of Delta Lake, plays a vital role in maintaining table health for several reasons, such as reclaiming storage space by removing obsolete data files, thus preserving cost efficiency and performance.


----------

***This approach not only simplifies execution and monitoring but also ensures consistency and efficiency throughout the data pipeline, making it easier to manage complex data workflows while ensuring data integrity and quality in data-driven applications.***