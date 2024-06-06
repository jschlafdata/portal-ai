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
