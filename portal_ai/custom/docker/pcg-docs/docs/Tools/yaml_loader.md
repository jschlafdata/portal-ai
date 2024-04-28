# YAML Loader Module Documentation

The `yaml_loader.py` module provides functionality to load and process YAML files with support for environment-specific formatting. This document outlines the module's capabilities, including its classes and methods, as well as instructions for deploying software that utilizes this module.

## Features 🚀

- **Load YAML Files**: Safely load YAML files into Python data structures.
- **Environment-Specific Formatting**: Supports dynamic content based on the specified environment, allowing for flexible configuration management across different deployment environments (e.g., development, testing, production).

## Dependencies 📦

- **PyYAML**: This module relies on the PyYAML library to parse YAML files. Ensure PyYAML is installed in your environment.

  ```bash
  pip install PyYAML
  ```

## Environment Setup 🌱

1. **Install Python**: Make sure Python is installed on your system. This module is compatible with Python 3.x versions.

2. **Install Dependencies**: Install the required Python package (PyYAML) as mentioned in the Dependencies section.

3. **Prepare YAML Files**: Create or have the YAML files ready that you wish to load and process with this module.

## Usage 🛠️

### **Class**: `YmlLoader`

#### **Initialization Parameters**

- `file_path` (str): Path to the YAML file.
- `environment` (str, optional): The environment name to format the YAML file accordingly. Defaults to `None`.

#### **Methods**

- **`load_yml()`**: Loads the YAML file specified by `file_path` without applying any environment-specific formatting.

  ```python
  loader = YmlLoader('config.yml')
  data = loader.load_yml()
  ```

- **`format_with_environment(data)`**: Recursively formats the given data (from a YAML file) by replacing any `{environment}` placeholders with the specified environment name.

  ```python
  formatted_data = loader.format_with_environment(data)
  ```

- **`load()`**: Combines both loading and formatting steps, providing a convenient way to load and process the YAML file in one go.

  ```python
  loader = YmlLoader('config.yml', 'development')
  data = loader.load()
  ```

## Example 📝

Suppose you have a YAML file `config.yml` that contains environment-specific placeholders:

```yaml
database:
  host: localhost
  port: '{env_port}'
```

You can use the `YmlLoader` class to load and format this file for a specific environment:

```python
from yaml_loader import YmlLoader

loader = YmlLoader('config.yml', environment='development')
config = loader.load()

print(config)
```

This loads the YAML file, replacing `{env_port}` with the port number defined for the development environment, assuming such a mapping is defined elsewhere or passed appropriately.

## Conclusion 🏁

The `yaml_loader.py` module offers a flexible and secure way to manage configurations across different environments by loading and formatting YAML files. By following the setup and usage instructions, you can easily integrate this module into your Python projects to enhance configuration management.