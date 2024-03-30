from portal_ai.templating.yaml.yaml_manager import YmlManager

# Ensure that the base directory of your project is accessible
# Note: This line might need adjustment based on your actual project structure and how you're executing the script.

def load_global_configs( global_config_file="global_settings.yml",
                         environment="dev" ):
    
    if environment is not None:
        global_config_path = f"./{environment}/{global_config_file}"
    else:
        global_config_path="./global_settings.yml"
    
    print(global_config_path)
    # Load global configuration from a YAML file
    return YmlManager(global_config_path).load()