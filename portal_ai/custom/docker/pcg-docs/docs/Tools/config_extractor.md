# Extract configs for projects

The `config_extractor.py` script is designed to extract specific configurations from YAML files. It utilizes a class named `ExtractConfigKeys` to perform its operations. The functionality provided by this script is essential for applications that require configurations to be dynamically loaded and manipulated based on different environments or conditions.

## Dependencies

- **PyYAML**: This script depends on the PyYAML library for loading YAML files. You need to ensure this library is installed in your environment.
- **yaml_loader.py**: It imports `YmlLoader` from `tools.templates.yaml.yaml_loader`, which is another custom module for loading and handling YAML files. Ensure that this file is present and correctly placed in your project structure.

## How to Deploy and Use

### Setting Up Your Environment

1. **Install Python**: Ensure that Python 3.x is installed on your system.
2. **Install PyYAML**: You can install PyYAML by running the command:
   ```bash
   pip install pyyaml
   ```

### Placing Your Files

1. Ensure `config_extractor.py` and `yaml_loader.py` are placed in your project directory following the structure indicated by the import statement in `config_extractor.py`.
   - Your directory should look something like this:
     ```
     your_project/
     ├── tools/
     │   └── templates/
     │       └── yaml/
     │           └── yaml_loader.py
     └── config_extractor.py
     ```

### Using `config_extractor.py`

To use the functionality provided by `config_extractor.py`, follow these steps:

1. **Initialization**: Create an instance of `ExtractConfigKeys` by passing a dictionary that defines what configurations you intend to extract.
   ```python
   from config_extractor import ExtractConfigKeys

   config_items = {
       "example_key": "path.to.your.config"
   }
   extractor = ExtractConfigKeys(config_items)
   ```

2. **Extract Configuration**: Call the `extract` method to extract the configurations based on your initial setup.
   ```python
   extracted_config = extractor.extract()
   print(extracted_config)
   ```

## Core Features

- **Loading Source YAML**: Load source YAML file using `YmlLoader` to fetch configurations.
- **Extract Configurations**: Allows extracting specific configurations from the loaded YAML by specifying the path to each configuration.
- **Support for Nested Configurations**: It can extract configurations from deeply nested structures using a dot-separated path string.

## Function Descriptions

- `load_source(source_path)`: Loads the YAML file specified by the `source_path`.
- `get_value_by_path(path)`: Extracts a value from the loaded configuration using a dot-separated string path.
- `key_extract(extract_items)`: Extracts multiple configurations based on a dictionary of paths.
- `var_extract(input_dict)`: Extracts variables based on the `input_dict` which includes a source path and the items to extract.
- `extract()`: Initiates the extraction process for the input dictionary set during initialization.

## Conclusion

The `config_extractor.py` script is a powerful tool for extracting configurations from YAML files. With its ability to handle nested configurations and dependency on the `YmlLoader` for YAML handling, it simplifies the process of managing application configurations. Ensure that all dependencies are met and follow the guidelines to deploy and use it effectively in your projects.