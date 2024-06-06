import os
import subprocess
import sys

from portal_ai.tests.settings.dir_test import DirectoryManager
from portal_ai.settings.logger import LoggerConfig
from portal_ai.settings.get_environment import get_project_env

from portal_ai.settings.load_settings import (
    ConfigReader,
    ConfigurationLoader
)


class FetchAWSSettings:
    def __init__( self, 
                  aws_region, 
                  k8s_deployment_size, 
                  k8s_included_gpu_instances, 
                  loader,
                  logger ):
        
        self.aws_region = aws_region
        self.loader = loader
        self.k8s_deployment_size = k8s_deployment_size
        self.k8s_included_gpu_instances = k8s_included_gpu_instances
        self.logger = logger

    def get_efs_image(self):
        efs = self.loader.global_base_config_loader('aws_efs')
        efs_img = f"{efs.get('regions').get(self.aws_region)}/eks/aws-efs-csi-driver"
        self.logger.info(f"Sweet, you'll be using this EFS driver: {efs_img}")
        return efs_img

    def get_ubuntu_image(self):
        ubuntu_configs = self.loader.global_base_config_loader('aws_ubuntu')
        ubuntu_img_name = ubuntu_configs.get('ubuntu_latest_jammy').get(self.aws_region).get('image_name')
        ubuntu_img_ami = ubuntu_configs.get('ubuntu_latest_jammy').get(self.aws_region).get('image_ami')
        self.logger.info(f"Swagoo, you'll be using this Ubuntu image for k8s: {ubuntu_img_name}")
        self.logger.info(f"Which is this Ubuntu AMI: {ubuntu_img_ami}")
        return ubuntu_img_name, ubuntu_img_ami
    
    def get_k8s_machine_configs(self):
        for key, value in self.k8s_deployment_size.items():
            if value:
                k8s_size = key
                break

        k8s_machine_configs = self.loader.global_base_config_loader('constant_config')
        k8s_machine_settings = k8s_machine_configs.get('k8s_deployment_settings').get(k8s_size)
        return k8s_machine_settings

    def get_accelerated_instances(self):

        k8s_accelerated_instances = self.loader.global_base_config_loader('accelerated_instances')
        accelerated_igs = []
        for gpu_grp in self.k8s_included_gpu_instances:
            grp_settings = k8s_accelerated_instances.get(gpu_grp).get('instances')
            for inst in grp_settings:
                inst_conf = { 'machineType': inst.get('name'),
                              'igName': inst.get('name').replace('.','-'),
                              'maxNodeSize': 1,
                              'gpus': inst.get('GPUs') }
                accelerated_igs.append(inst_conf)

        return accelerated_igs

    @classmethod
    def fetch(cls):
        logger = LoggerConfig.get_logger(__name__)

        loader = ConfigurationLoader(ConfigReader)
        custom_configs = loader.global_base_config_loader('global_config_base')
        environment =  get_project_env()

        aws_region = custom_configs.get('aws_environments').get(environment).get('aws_region')
        k8s_deployment_size = custom_configs.get('k8s_deployment_size')
        k8s_included_gpu_instances = custom_configs.get('included_gpu_node_groups')

        aws_fetcher = cls(aws_region, k8s_deployment_size, k8s_included_gpu_instances, loader, logger)
        efs_img = aws_fetcher.get_efs_image()
        ubuntu_img_name, ubuntu_img_ami = aws_fetcher.get_ubuntu_image()
        k8s_node_machines = aws_fetcher.get_k8s_machine_configs()
        gpu_instance_groups = aws_fetcher.get_accelerated_instances()

        return ( efs_img, 
                 ubuntu_img_name, 
                 ubuntu_img_ami, 
                 k8s_node_machines, 
                 gpu_instance_groups )
