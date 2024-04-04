import json
import os
import subprocess
from pathlib import Path
import requests
from pathlib import Path
import sys
from portal_ai.settings.logger import LoggerConfig
from portal_ai.settings.get_environment import get_project_env

from portal_ai.settings.load_settings import (
    ConfigReader,
    ConfigurationLoader
)

from portal_ai.templating.yaml.yaml_manager import (
    JinjaRender,
    YmlManager,
    TemplateRenderer
)


def log_to_stderr(message):
    sys.stderr.write(message + "\n")


def vault_init():
    logger = LoggerConfig.get_logger(__name__)

    loader = ConfigurationLoader(ConfigReader)
    deploment_configs = loader.generated_config_loader('aws_plus_global_base')

    project_name = deploment_configs.get('project_name')
    user_home = os.path.expanduser("~")
    output_file_path = os.path.join(user_home, '.ssh', project_name, 'vault_init_output.json')

    command = "kubectl exec vault-0 -- vault operator init -key-shares=5 -key-threshold=3 -format=json"
    process = subprocess.run(command, shell=True, text=True, capture_output=True, check=False)

    if process.returncode == 0:
        logger.info("Vault initialized successfully.")
        try:
            vault_init_output = json.loads(process.stdout)
            with open(output_file_path, 'w') as file:
                json.dump(vault_init_output, file)
            logger.info(f"Initialization output saved to {output_file_path}")
            
            os.chmod(output_file_path, 0o600)
            return True
        except json.JSONDecodeError:
            logger.error("Failed to parse the initialization output as JSON.")
    else:
        error_message = process.stderr.strip()
        # Check if the failure is because Vault is already initialized
        if "* Vault is already initialized" in error_message:
            logger.info("Vault is already initialized.")
            return True
        else:
            output = {'status': 'error', 'message': f"Failed to initialize Vault: {error_message}"}
            sys.exit(1)

def unseal_vault():
    logger = LoggerConfig.get_logger(__name__)

    loader = ConfigurationLoader(ConfigReader)
    deploment_configs = loader.generated_config_loader('aws_plus_global_base')

    project_name = deploment_configs.get('project_name')
    user_home = os.path.expanduser("~")
    init_output_file = os.path.join(user_home, '.ssh', project_name, 'vault_init_output.json')

    if not os.path.isfile(init_output_file):
        logger.error(f"Vault initialization output file does not exist: {init_output_file}")
        sys.exit(1)

    with open(init_output_file, 'r') as file:
        init_data = json.load(file)
    unseal_keys = init_data.get('unseal_keys_b64', [])

    for i, unseal_key in enumerate(unseal_keys[:3]):
        logger.info(f"Unsealing Vault with key {i+1}...")
        command = f"kubectl exec vault-0 -- vault operator unseal {unseal_key}"
        process = subprocess.run(command, shell=True, text=True, capture_output=True)

        if process.returncode != 0:
            logger.error(f"Failed to unseal Vault with key {i+1}: {process.stderr}")
            sys.exit(1)
    
    vault_test = 'kubectl exec vault-0 -- vault status -format=json'
    process = subprocess.run(vault_test, shell=True, text=True, capture_output=True)

    if process.returncode == 0:
        vault_status = json.loads(process.stdout)
        is_sealed = vault_status.get('sealed', True)  # Default to True (considered sealed) if not found
        if is_sealed:
            logger.info("Vault is sealed:" if is_sealed else "Vault is unsealed.")
    else:
        logger.info(f"Error executing command: {process.stderr}")

def executor():

    initialized = vault_init()
    if initialized:
        unseal_vault()
    
    output = {'status': '200', 'message': 'Vault is all set up!!'}
    print(json.dumps(output))

if __name__ == "__main__":
    executor()
