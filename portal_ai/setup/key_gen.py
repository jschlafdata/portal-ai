import os
import subprocess
import sys

from test.settings.dir_test import ensure_directory_exists
from settings.load_global_settings import load_global_configs



class SSHKeyGenerator:
    def __init__(self, key_name, key_email, project_name):
        self.key_name = key_name
        self.key_email = key_email
        self.project_name = project_name

    def generate_ssh_key(self):
        user_home = os.path.expanduser("~")
        project_ssh_folder = os.path.join(user_home, '.ssh', self.project_name)
        ensure_directory_exists(project_ssh_folder)

        full_key_name = f"id_ed25519_{self.key_name}"
        ssh_key_path = os.path.join(project_ssh_folder, full_key_name)

        if os.path.exists(ssh_key_path):
            print(f"SSH key {full_key_name} already exists.")
            return

        ssh_key_gen_command = f'ssh-keygen -t ed25519 -C "{self.key_email}" -f "{ssh_key_path}" -N ""'
        print(ssh_key_gen_command)
        subprocess.run(ssh_key_gen_command, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        print(f"SSH key {full_key_name} created.")
        self.add_key_to_ssh_agent(ssh_key_path)

    def add_key_to_ssh_agent(self, ssh_key_path):
        ssh_agent_command = 'eval "$(ssh-agent -s)"'
        subprocess.call(ssh_agent_command, shell=True)

        keychain_add_command = f'ssh-add --apple-use-keychain {ssh_key_path}'
        subprocess.call(keychain_add_command, shell=True)

def main():

    print(f"Current working directory: {os.getcwd()}")
    configs = load_global_configs(environment=None)

    key_email = configs.get('git_admin_email')
    ssh_key_names = configs.get('ssh_key_names')
    project_name = configs.get('project_name')

    if not all([key_email, ssh_key_names, project_name]):
        print("General settings YAML file missing key configuration.")
        sys.exit(1)

    for key_name in ssh_key_names:
        ssh_key_generator = SSHKeyGenerator(key_name, key_email, project_name)
        ssh_key_generator.generate_ssh_key()

if __name__ == "__main__":
    main()