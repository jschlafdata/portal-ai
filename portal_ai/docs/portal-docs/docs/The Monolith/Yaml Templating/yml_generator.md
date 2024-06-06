# Documentation for `build_yml_configs`

The `build_yml_configs.py` script is part of a larger application that interfaces with various cloud services and frameworks such as AWS, Kubernetes (k8s), Helm, and Kops. Its primary function is to dynamically generate YAML configuration files based on templates and custom logic. This document outlines the components, functionalities, and flow of the script.

## Overview

This script is designed to automate the creation of YAML configuration files that are used to create AWS resources via Terraform, deploy Kubernetes Cluster vis Kops, or deploy k8s resources using helm. Every process as a config map that defines the variables that need to be templated, the location of the source metadata configurations, and a location of where to output the final configuation yaml files.

This is designed to facilitate multi cloud environments and deployments to dev, stage, and production in any aws region or account.

```yaml 

```

## Components

The script is composed of several classes, each responsible for a specific part of the process:

| Class            | Description                                                                                                                                                                                                                                                                                                                |
|------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `YmlLoader`      | Loads and formats YAML files. It can replace placeholders with environment-specific values.                                                                                                                                                                                                                               |
| `ExtractConfigKeys` | Extracts specific keys from a configuration dictionary based on provided paths.                                                                                                                                                                                                                                           |
| `CustomFuncs`    | Applies custom functions to extracted configuration values, allowing for dynamic modification of the data.                                                                                                                                                                                                                 |
| `OutputVars`     | Collects and formats the final output variables into a structured dictionary that can be written back to a YAML file.                                                                                                                                                                                                      |
| `LoadYmlConfigs` | Handles the loading of input YAML configurations, using `YmlLoader` to process each specified file.                                                                                                                                                                                                                        |
| `BuildYmlConfigs`| Coordinates the entire process: loading input configurations, extracting keys, applying custom functions, and creating the final output.                                                                                                                                                                                    |

## Workflow

The script follows a structured workflow, detailed below:

1. **Load Input Configurations**: The `LoadYmlConfigs` class initiates the process by loading and formatting input YAML files based on the environment.
2. **Extract Configuration Keys**: For each input configuration, `ExtractConfigKeys` extracts specified keys and values, making them available for further processing.
3. **Apply Custom Functions**: The `CustomFuncs` class is used to apply custom logic to the extracted values, such as modifying strings or calculating new values based on the inputs.
4. **Generate Output Variables**: `OutputVars` collects all the processed information and organizes it according to the output mappings defined in the input configurations.
5. **Write Final Configurations**: Finally, the processed configurations are written back to YAML files, ready to be used in deploying or configuring cloud resources.

## Usage

To use the script, an instance of the `BuildYmlConfigs` class must be created with the path to the main input configuration file and the target environment. The `write_vars` method can then be called to generate and write the output configurations.

```python
config_builder = BuildYmlConfigs(file_path="path/to/main_config.yml", environment="dev")
config_builder.write_vars()
```

## Custom Functions

The script is designed to be extensible, with the capability to integrate custom functions that can operate on the extracted configuration values. These functions are defined in separate modules and are dynamically imported and executed based on the input configuration mappings.

## Conclusion

The `build_yml_configs.py` script is a powerful tool for automating the generation of environment-specific YAML configurations for cloud infrastructure and services. Its modular design and extensibility make it suitable for a wide range of applications, from simple configuration file generation to complex cloud infrastructure setup and management.