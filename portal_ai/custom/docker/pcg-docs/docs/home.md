---
sidebar_position: 1
slug: /
---

# Entire Repo Folder Structure

## docs for PCG databricks, dbt infrastructure deployment.
#### use this as a reference to find concepts you want to understand more.
----------

## terraform deployment folder structure.

``` title="terraform structure"
dev
    └── terraform
        ├── databricks
        │   ├── account
        │   │   ├── main.tf
        │   │   ├── outputs.tf
        │   │   ├── variables.tf
        │   │   └── versions.tf
        │   ├── configs
        │   │   ├── inputs.tmpl.yml
        │   │   └── vars.databricks.yml
        │   ├── main.tf
        │   ├── providers.tf
        │   ├── remote.tf
        │   ├── secret.auto.tfvars
        │   ├── variables.tf
        │   ├── workspace_create
        │   └── workspace_management
        └── networking
            ├── configs
            │   ├── inputs.tmpl.yml
            │   └── vars.networking.yml
            ├── main.tf
            ├── outputs
            ├── outputs.tf
            ├── providers.tf
            ├── remote.tf
            └── vpc
                ├── main.tf
                ├── outputs.tf
                └── vars.tf
```

## automation tools.

* These are used to automate the generation of yaml files used for configuration of terraform modules, databricks resources, role based access controle, etc. 
* They enforce and enable easy management of standardized naming conventions & tagging across projects and environments.

``` tite="python tools"
tools
    ├── settings.py
    └── templates
        ├── terraform
        │   ├── config_path.yml
        │   └── generate_configs.py
        ├── yaml
        │   ├── config_extractor.py
        │   ├── yaml_loader.py
        │   └── yaml_writer.py
        └── yaml_loader.py
```

