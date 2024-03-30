from portal_ai.templating.yaml.yaml_manager import YmlManager
import os
from portal_ai.settings.logger import LoggerConfig

class GlobalConfigLoader:
    def __init__(self):
        """
        Initialize the GlobalConfigLoader with default configuration file and environment.
        """

        self.logger = LoggerConfig.get_logger(__name__)

        self.global_config_path = "./global_settings.yml"
        self.constant_config_path = "./portal_ai/constant_configs/portal-ai/constants.yml"

    def custom_configs(self):
        
        self.logger.info(f"Loading configuration from: {self.global_config_path}")
        # Load global configuration from a YAML file
        return YmlManager(self.global_config_path).load()


    def constant_configs(self):

        self.logger.info(f"Loading configuration from: {self.constant_config_path}")
        # Load global configuration from a YAML file
        return YmlManager(self.constant_config_path).load()



    
