---
sidebar_position: 5
---

# Data Quality Check and Data Loading Framework

----------
## Example from in person workshop walkthrough.

This framework is designed for ingesting and managing data within a Databricks and consists of several components that interact to ensure data quality, configuration management, and efficient data loading, including utility functions for common operations. Below is a breakdown of each component:


```
├── dbx_code
│   ├── sql_ingestion_framework_demo
│   │   ├── obs
│       │   ├── data_quality_check.py
│       │   ├── obs_tables_config_json.py
│   │   ├── sql_ingestion
│       │   ├── meta_sql_framework.py
│   │   ├── utilities
│       │   ├── utils_file.py
```

### Key Concepts and Practices Used

- `Data Quality Assurance`: Ensures the freshness and integrity of data through checks before processing.
- `Configuration Management`: Utilizes JSON for flexible and maintainable configuration of table mappings and data flow.
- `Incremental Load Support`: Facilitates efficient data ingestions by loading only new or changed data based on a configurable incremental column.
- `Dynamic SQL Generation`: Enhances flexibility and reduces hard coding by generating SQL statements based on configurations and data conditions.
- `Utility Functions`: Promotes code reuse and maintainability through common utility functions for data retrieval, SQL statement generation, and table management.


This documentation outlines the components and functionalities of the provided Python code, which is structured into different segments intended for use within a Databricks notebook environment. The codebase is divided into multiple logical sections, each addressing a specific aspect of data management, ranging from data quality checks to data loading and merging strategies.

----------
## Table of Contents
<!-- - [Data Quality Check]()
- [Table Configuration JSON]()
- [Meta SQL Framework]()
- [Utilities]()
    - [Get Source Data]()
    - [Dynamic Merge SQL]()
    - [Vacuum Table]()
    - [Generate Match Insert Columns]() -->
----------
## Data Quality Check

Filename: `data_quality_check.py` (part 1)

This segment focuses on ensuring the data ingested into a Databricks environment maintains a certain level of quality by verifying the most recent update timestamp against the current date.

```python
from datetime import date

sql = """
    SELECT cast(max(audit_update_ts) as date) as max_date
    FROM raw_ingestion_data__dev.lf_demo_target.customer_fact_target_leigh
"""

data_df = spark.sql(sql)
max_date = data_df.collect()\[0\][0]

print(max_date)

assert(max_date >= date.today())
```

- Key Components:
    - `spark.sql(sql)`: Executes a SQL query to retrieve the maximum `audit_update_ts` date from the specified table.
    - `assert(max_date >= date.today())`: Ensures the data is current by comparing the maximum date in the table to today's date.

----------
## Table Configuration JSON

Filename: `obs_tables_config_json.py`  (part 2)

Defines a JSON configuration for table mappings, including source and target details such as database, schema, table names, and columns for incremental updates and merges. This configuration facilitates dynamic data loading based on specified parameters.


- Key Components:
    - `table_json`: A dictionary containing configuration for each table, including source and target information necessary for data ingestion and ETL processes.

```json
table_json = {
     "customer_fact": {
       # Configuration details...
     },
     "source_table_1": {
       # Configuration details...
     }
    }
```

Key Features:

- `Flexible Configuration`: Allows for setting up different configurations for multiple tables, providing an easy way to manage data loading parameters.

----------
## Meta SQL Framework

Filename: `meta_sql_framework.py` (part 3)

A framework for loading data from source to target tables based on the configuration defined in `obs_tables_config_json.py`. It supports full and incremental loads, leveraging widgets for user input and utility functions for data retrieval and processing.


- Key Components:
    - Widgets for user input (`source_table`, `incremental`, `date_cutoff`).
    - Dynamic source and target determination based on the `table_json` configuration.
    - Incremental load logic, including data filtering based on a cutoff date or the most recent data in the target table.
    - Data merge operations using a dynamically constructed SQL `MERGE` statement.


# Databricks notebook source
```
# MAGIC %md
# MAGIC This notebook showcases a simple way to load all data from a SQL server database an efficient fashion

# COMMAND ----------

Job Widgets:
- date_cutoff: use if you need to manually replay data from some point forward
- incremental: whether it should be a full or partial load
- source_table: name of the table to load
```

The Meta SQL Framework enables efficient data loading from a SQL Server database into Databricks, supporting both full and incremental data loads based on configurable parameters.

```python
from datetime import date, timedelta, datetime
from pyspark.sql.functions import col

# Define variables for source and target based on widgets and the table JSON configuration

# Pull the source data and apply filtering based on the date or incremental flags

# Generate dynamic MERGE SQL statement for data loading

# Optimize and vacuum the target table to maintain performance and manage storage
```

### Key Features:

- `Configurable Data Load`: Leverages widgets for dynamic configuration of data load parameters.
- `Incremental Load Support`: Facilitates both full and incremental data loads based on specified conditions.
- `Dynamic SQL Generation`: Generates MERGE SQL statements dynamically for efficient data integration.
----------
## Utilities
### Get Source Data
Provides utility functions to fetch source data from a SQL Server database or simulate fetching data for demo purposes.

```py
def get_source_data(connection, catalog, database, table_name):
    """
    Returns a dataframe with the data from a given SQL server

    Args:
        connection (str): The name of the sql dbx secret where credentials are contained
        catalog (str): SQL catalog name
        database (str): SQL database name
        table_name (str): SQL table name

    Returns:
        Dataframe: A pyspark dataframe with the source data
    """

    #sql_credentials = 'temp_sqlserver_merp' 
    sql_credentials = connection.lower()
    jdbcDatabase = database.lower()
    jdbcHostname = dbutils.secrets.get(sql_credentials,'hostname')
    jdbcPort = dbutils.secrets.get(sql_credentials,'port')
    username = dbutils.secrets.get(sql_credentials,'username')
    password = dbutils.secrets.get(sql_credentials,'password')

    jdbcUrl = 'jdbc:sqlserver://{0}:{1};database={2};trustServerCertificate=true;'.format(jdbcHostname, jdbcPort, jdbcDatabase)
    connectionProperties = {
                            'user': username,
                            'password': password,
                            'driver': 'com.microsoft.sqlserver.jdbc.SQLServerDriver'
                            }
    df = spark.read.jdbc(url=jdbcUrl, table= table_name, properties=connectionProperties)

    return df 
```

### Dynamic Merge SQL
Generates a dynamic MERGE SQL statement for updating or inserting data into a target Delta Lake table based on specified match and update columns.


```py    
#this would go in a utilities notebook 
def dynamic_merge_sql(table_name, match_columns, update_columns, insert_columns):
    """
    Build dynamic merge statement for use when merging with any code 

    Args:
        table_name (str): The name of the Delta Lake table.
        match_columns (list): A list of the columns to match on 
                                aka the tables primary/composite key
        update_columns (list): Columns which will be updated when a record matches 
        insert_columns (list): All columns in the table for the insert 
                                part where records don't match

    Returns:
        str: A string with the merge statement for this table
    """

    # Create the "USING" clause for matching columns
    using_clause = "USING updates AS updates ON "
    using_clause += " AND ".join([f"target.{col} = updates.{col}" 
                                    for col in match_columns])

    # Create the "WHEN MATCHED" clause for updating columns
    update_clause = "WHEN MATCHED THEN UPDATE SET "
    update_clause += ", ".join([f"target.{col} = updates.{col}" 
                                for col in update_columns])

    # Create the "WHEN NOT MATCHED" clause for inserting all columns
    insert_clause = "WHEN NOT MATCHED THEN INSERT ("
    insert_clause += ", ".join(insert_columns) + ") VALUES ("
    insert_clause += ", ".join([f"updates.{col}" for col in insert_columns]) + ")"

    # Assemble the complete MERGE statement
    merge_sql = f"""
    MERGE INTO {table_name} AS target
    {using_clause}
    {update_clause}
    {insert_clause}
    """

    return merge_sql
```

### Vacuum Table()

Performs a VACUUM operation on a Delta Lake table to remove old data files and optimize storage.

```py
def vacuum_table(table_name, retain_hours):
    """
    Vacuum a Databricks Delta Lake table to remove old data files.

    Args:
        table_name (str): The name of the Delta Lake table.
        retain_hours (int): The number of hours to retain data files.

    Returns:
        str: A message indicating the result of the VACUUM operation.
    """
    try:
        # Construct the VACUUM SQL command
        vacuum_sql = f"VACUUM {table_name} RETAIN {retain_hours} HOURS"

        # Execute the VACUUM command
        spark.sql(vacuum_sql)

        # Return a success message
        return f"VACUUM operation on table '{table_name}' completed successfully."

    except Exception as e:
        # Handle any errors and return an error message
        return f"Error performing VACUUM operation on table '{table_name}': {str(e)}"
```

### Generate Match Insert Columns
Extracts lists of match, update, and insert columns for use in generating dynamic SQL statements.

```py
def generate_match_insert_columns(match_columns, dataframe):
    """
    Get a list of column names from a PySpark DataFrame.

    Args:
        match_columns(str): list of the columns to match on
        dataframe (DataFrame): The PySpark DataFrame.

    Returns:
        list: A list of column names.
    """
    

    match_columns_list = match_columns.split(", ")
    all_columns = dataframe.columns
    update_list = [x for x in all_columns if x not in match_columns_list]
    
    return match_columns_list, update_list, all_columns
```

----------

This framework offers an example solution for data ingestion, quality checks, and data management within a Databricks environment, promoting efficiency and maintainability in data operations.
