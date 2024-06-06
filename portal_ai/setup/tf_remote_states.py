import os
import sys
from portal_ai.settings.logger import LoggerConfig
from portal_ai.settings.get_environment import get_project_env
from portal_ai.aws.boto_s3.boto import BotoS3

from portal_ai.settings.load_settings import (
    ConfigReader,
    ConfigurationLoader
)


class RemoteS3Manager:
    def __init__(self):
        # Load global settings base upon initialization
        loader = ConfigurationLoader(ConfigReader)
        self.global_settings_base = loader.generated_config_loader('global_settings_base')
        self.aws_region = self.global_settings_base.get('aws_region')
        self.project_name = self.global_settings_base.get('project_name')
        self.environment = self.global_settings_base.get('environment')
        self.aws_profile = f"{self.project_name}-{self.environment}"

    def manage_s3_buckets(self, action='create'):
        """
        Manage S3 buckets based on the action provided.
        :param action: The action to perform ('create' or 'delete').
        """
        s3_handler = BotoS3(aws_profile=self.aws_profile, aws_region=self.aws_region, action=action)
        s3_backend_buckets = self.global_settings_base['remote_s3_bucket_configs']

        for section, bucket_name in s3_backend_buckets.items():
            if bucket_name:
                if action == "create":
                    s3_handler.create_s3_bucket(bucket_name)
                    if section == "kops_iam_prefix":
                        s3_handler.update_bucket_policies(bucket_name)
                elif action == "delete":
                    s3_handler.delete_all_objects(bucket_name)

    def setup_tf_backend(self):
        """
        Set up the Terraform backend configuration.
        """
        logger = LoggerConfig.get_logger(__name__)
        tf_state_bucket = self.global_settings_base.get('remote_s3_bucket_configs').get('tfstate_prefix')
        
        tf_dir = os.path.join(os.getcwd(), 'portal_ai/terraform')
        os.chdir(tf_dir)

        dir_folders = next(os.walk('.'))[1]
        for dir in dir_folders:
            content = f"""terraform {{
            backend "s3" {{
                bucket = "{tf_state_bucket}"
                key = "{dir}"
                region = "{self.aws_region}"
                encrypt = true
                }}
            }}"""

            tf_remote_state_path = f"{dir}/remote.tf"
            
            with open(tf_remote_state_path, "w") as file:
                file.write(content)