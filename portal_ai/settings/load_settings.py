import os
from portal_ai.templating.yaml.yaml_manager import YmlManager
from portal_ai.settings.logger import LoggerConfig

class ConfigReader:
    """
    Handles reading from and writing to files.
    """
    @staticmethod
    def load_yaml_file(path):
        return YmlManager(path).load()

class ConfigurationLoader:
    def __init__(self, reader_class):
        """
        Initialize ConfigurationLoader with dependencies.
        """
        self.logger = LoggerConfig.get_logger(__name__)
        self.reader_class = reader_class
        self.constants_config_path = "portal_ai/configs/constants/portal-ai/constants.yml"

    def load_config(self, config_name):
        """
        Load configuration from a specified YAML file.
        """
        config_path = self.config_paths.get(config_name)
        if not config_path:
            self.logger.error(f"Configuration name '{config_name}' not recognized.")
            return None

        self.logger.info(f"Loading configuration from: {config_path}")
        return self.reader_class.load_yaml_file(config_path)

    def generated_config_loader(self, config_base_key):
        self.config_paths = self.reader_class.load_yaml_file(self.constants_config_path)['generated_load_paths']
        return self.load_config(config_base_key)
    

    def global_base_config_loader(self, config_base_key):
        self.config_paths = self.reader_class.load_yaml_file(self.constants_config_path)['config_paths']
        return self.load_config(config_base_key)