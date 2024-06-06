import os
import subprocess
import sys

from portal_ai.tests.settings.dir_test import DirectoryManager
from portal_ai.settings.logger import LoggerConfig
from portal_ai.setup.aws_settings import FetchAWSSettings
from portal_ai.settings.get_environment import get_project_env

from portal_ai.templating.yaml.yaml_manager import (
    JinjaRender,
    YmlManager
)

from portal_ai.settings.load_settings import (
    ConfigReader,
    ConfigurationLoader
)


class AWSConfigGenerator:
    @classmethod
    def generate_configs(cls):
        logger = LoggerConfig.get_logger(__name__)

        loader = ConfigurationLoader(ConfigReader)
        constant_configs = loader.global_base_config_loader('constant_config')
        custom_configs = loader.global_base_config_loader('global_config_base')
        
        (efs_img, ubuntu_img_name, ubuntu_img_ami, k8s_node_machines,
         gpu_instance_groups) = FetchAWSSettings.fetch()
        
        region_settings = {
            'aws_efs_driver': efs_img, 
            'kops_node_settings': { 'image_name': ubuntu_img_name, 
                                    'image': ubuntu_img_ami, 
                                    'nodes': k8s_node_machines
            },
            'gpu_instance_groups': gpu_instance_groups 
        }

        global_settings_base = {**custom_configs, **constant_configs, **region_settings}

        render_tmpl_path = constant_configs.get('jinja_template_paths').get('global_settings_base').get('template_path')
        render_output_paths = constant_configs.get('generated_output_paths').get('global_settings_base')

        global_settings = JinjaRender(global_settings_base, 
                                      render_tmpl_path, 
                                      render_funcs=None).render_j2()   
        
        for path in render_output_paths:
            YmlManager(path).save(global_settings)
        logger.info("AWS Configurations generated successfully.")