---
sidebar_position: 4
---

# Project & Folder Structures, CI/CD Fundamentals
[Maxime Beauchemin, the author of Airflow, explains how data engineers should find common patterns (ways to build workflows dynamically) in their work and build frameworks and services around them.](https://medium.com/hackernoon/airflow-meta-data-engineering-and-a-data-platform-for-the-worlds-largest-democracy-3b49a3efd5e8)
[…](https://medium.com/hackernoon/airflow-meta-data-engineering-and-a-data-platform-for-the-worlds-largest-democracy-3b49a3efd5e8)
[Finding patterns involves identifying the building blocks of a workflow and chaining them based on a static configuration.](https://medium.com/hackernoon/airflow-meta-data-engineering-and-a-data-platform-for-the-worlds-largest-democracy-3b49a3efd5e8)

### This quote is a good explanation of the main idea behind this example project structure.

----------


- The following structure is currently setup in the `dev-neu-ifpc-ins-workspace` and is designed to help with the following concepts:
        - Standardized modules that eliminate redundant work across teammates.
            - Facilitate tests and enhanced logging of ETL jobs without having to write them into every notebook or job. 
        - Each workbook or script has a single responsibility: load data from a source, transform data, or export data. 
            - This helps pinpoint errors quickly, encourages re-usable code across teamates.
        - `Global Modules` and `get_current_notebook_paths` leverage cluster environment variables and yaml files with parameters for projects or notebooks.
            - Project level variables & parameters are things like:
                - destination catalog & schema
                - modules and python libaries needed
                - list of all workbooks and scripts in the project
            - Job level variables & parameters are variables that only make sense for that specific notebook or script.
                - destination table & the schema for that table
                - how data is loaded (incremental, full)
                - Timestamp parameters, flags for historical loads and refreshes.


----------


## Databricks example folder structure.

![DB example project structure](/img/db_example_project_structure.jpeg)


## `get_current_notebook_paths.py`

- Placed directly in the pipelines folder. This script is an example of using a standard python module across all pipelines and projects in Databricks.

----------

### GetCurrentEnviornmentPaths()
Inside the script is a  python class, `GetCurrentEnviornmentPaths` , which is designed to initialize and manage environment-specific paths within a Databricks workspace. It reads environment variables from the cluster and uses those to configure all paths needed for various jobs. 

```python
import os
from databricks.sdk.runtime import *
from pyspark.dbutils import DBUtils

class GetCurrentEnviornmentPaths:
    """
    A class to load and manage global variables and paths for 
    Databricks projects.
    Attributes:
        env (str): The workspace environment (e.g., 'dev', 'stage', 'production') 
                    from OS environment variables.
        repo_name (str): The name of the repository, fetched from OS 
                            environment variables.
        notebook_path (str): The path of the current notebook, 
                                derived from Databricks utilities.
        databricks_code_folder (str): The folder name where Databricks code is stored.
        etl_pipelines_folder (str): The folder name for ETL pipelines.
        global_modules_path (str): The folder name for global Python modules.
    """
    def __init__(self):
        """
        Initializes the LoadPipelineGlobalVars object, setting up 
        paths based on environment variables.
        """
        self.env = os.getenv("WORKSPACE_ENVIRONMENT")
        self.repo_name = os.getenv("REPO_NAME")
        self.notebook_path = dbutils.notebook.entry_point.getDbutils().notebook().getContext().notebookPath().get()

        """ rest of code follows... go to file in databricks to see entire script """
            ................... 
            ...................
```

---------
When you run the script it creates variables that you can use throughout the entire ETL process & workbook and  it will try to print out information like this:

```sh
You are currently developing in the 'development' environment.
------------------------------------------
The current Databricks repository is 'if-insurance-databricks'.
------------------------------------------
You are working within the project 'concert_finder'.
------------------------------------------
The current Databricks notebook you are using is 'scrape_music_venues'.
------------------------------------------
databricks_project_path: /Repos/development/if-insurance-databricks/dbx_code/
--------------------------------
databricks_dbt_path: /Repos/development/if-insurance-databricks/dbx_code/dbt
--------------------------------
databricks_global_modules_path: /Repos/development/if-insurance-databricks/dbx_code/global_python_modules
--------------------------------
databricks_etl_pipelines_path: /Repos/development/if-insurance-databricks/dbx_code/pipelines
--------------------------------
```

:::note
Please note, if you want to use this function in your real workspace, you will need two things:

1. Go to compute → click on the cluster for your workspace. 
    1. Add environment variables for the name of your repo and environment.
    2. Make sure the variables are named **REPO_NAME** and **WORKSPACE_ENVIRONMENT** *******(or, update the part of the script that looks for those variables)*
![](/img/cluster_envs.jpeg)

    1. In my example, I have created three clusters, one for “production”, “stage” & “development”. 
        1. Because the Nordic team is providing you with one workspace for all jobs & one for analysis or ad hoc work, the way I would facilitate CI/CD is by using specific clusters or jobs for each “environment.”
2. Make sure your folder structure is the same as the first outlined example, or change the variables in the function to match:
    1. root folder beneath version control repository == dbx_code
        1. dbx_code/
            1. dbt/
            2. global_python_modules/
            3. pipelines/
                1. [project_name]
                    1. jobs/
                        1. workbooks
:::

----------
# CI/CD in Databricks Part 1


- The following is designed to work for a one workspace Databricks setup. In this example, I created one folder each for:
    - development
    - stage
    - production

*Please note that the folders within the repo follow the structure outlined at the beginning of this page.*

----------

*The following example uses git hub instead of Azure Devops, but the concepts and structure should be extremely consistent and similar.*


1. In Databricks, when you are in the ***Repos/*** folder, you can link a version control repository to each folder you make.
    - After creating each folder, you individually link the folders to the same repo. In this example the repo name is ***if-insurance-databricks.***
            - Each folder is then set to its respective branch, *development*, *stage* or *production*.


2. Strategy for team development in the main workspace using features / branches.
    1. [databricks ci-cd techniques](https://docs.databricks.com/en/repos/ci-cd-techniques-with-repos.html)
    2. [databricks create feature branches](https://docs.databricks.com/en/repos/git-operations-with-repos.html#create-a-new-branch)


----------
## Flow Chart for Setting up a CI/CD workflow in a single workspace Databricks setup.
![](/img/git-ci-cd-branches.png)

----------
## Using features


1. `Branch Creation`: For every new feature or bug fix, you create a new branch off the main codebase. This branch should have a descriptive name that reflects the feature or issue it addresses.
2. `Development`: Work on your feature branch independently of the main codebase. This isolation allows for focused development without affecting the stability of the main branch.
3. ``Regular Commits`: Make regular commits to your feature branch with clear, descriptive commit messages. This practice helps in tracking changes and understanding the development history.
4. `Pull Requests (PRs)`: Once the feature is ready, you create a pull request to merge your branch back into the main branch. PRs allow for code review, discussion, and additional changes before the feature is integrated.
5. `Code Review`: Team members review the code changes in the PR. This is a crucial step for maintaining code quality, catching bugs, and ensuring consistency with the project's coding standards.
6. `Testing`: Automated tests (unit tests, integration tests) should be run against the feature branch before it's merged to ensure that the new changes don't break existing functionality.
7. `Merge`: After approval and passing tests, the feature branch is merged into the main branch. It's often best to use a strategy like "Squash and Merge" to keep the project's history clean and understandable.

**Things to Look Out For**

- `Branch Lifespan`: Keep the lifespan of feature branches short. Long-lived branches can lead to difficult merges and integration challenges due to divergence from the main branch.
- `Merge Conflicts`: Regularly sync your feature branch with the main branch to minimize merge conflicts. Address any conflicts promptly when merging back into the main branch.
- `Stale Branches`: Clean up feature branches after they've been merged to keep the repository tidy and manageable.
----------


