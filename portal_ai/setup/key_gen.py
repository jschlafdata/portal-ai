import os
import subprocess
import sys

from portal_ai.tests.settings.dir_test import DirectoryManager
from portal_ai.settings.logger import LoggerConfig

from portal_ai.settings.load_settings import (
    ConfigReader,
    ConfigurationLoader
)

class SSHKeyGenerator:
    def __init__(self, project_name, logger):
        self.logger = logger
        self.project_name = project_name
        self.project_ssh_folder = None

    @classmethod
    def generate_keys(cls):
        logger = LoggerConfig.get_logger(__name__)

        loader = ConfigurationLoader(ConfigReader)
        constant_configs = loader.global_base_config_loader('constant_config')
        custom_configs = loader.global_base_config_loader('global_config_base')

        key_email = custom_configs.get('git_admin_email')
        project_name = custom_configs.get('project_name')
        ssh_key_names = constant_configs.get('ssh_key_names')

        if not all([key_email, ssh_key_names, project_name]):
            logger.info("General settings YAML file missing key configuration.")
            sys.exit(1)

        key_generator = cls(project_name, logger)
        key_directory = key_generator.ssh_key_path()

        if key_directory:
            for key_name in ssh_key_names:
                key_generator.generate_ssh_key(key_name, key_email)
        else:
            logger.info("Portal-AI was unable to make a directory in your ~/.ssh folder. :(")
            sys.exit(1)

    def ssh_key_path(self):
        user_home = os.path.expanduser("~")
        self.project_ssh_folder = os.path.join(user_home, '.ssh', self.project_name)
        return DirectoryManager(self.project_ssh_folder).ensure_directory_exists()

    def generate_ssh_key(self, key_name, key_email):
        full_key_name = f"id_ed25519_{key_name}"
        ssh_key_path = os.path.join(self.project_ssh_folder, full_key_name)

        if os.path.exists(ssh_key_path):
            self.logger.info(f"SSH key {full_key_name} already exists.")
            return

        ssh_key_gen_command = f'ssh-keygen -t ed25519 -C "{key_email}" -f "{ssh_key_path}" -N ""'
        subprocess.run(ssh_key_gen_command, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        self.logger.info(f"SSH key {full_key_name} created.")
        self.add_key_to_ssh_agent(ssh_key_path)

    def add_key_to_ssh_agent(self, ssh_key_path):
        ssh_agent_command = 'eval "$(ssh-agent -s)"'
        subprocess.call(ssh_agent_command, shell=True)

        keychain_add_command = f'ssh-add --apple-use-keychain {ssh_key_path}'
        subprocess.call(keychain_add_command, shell=True)