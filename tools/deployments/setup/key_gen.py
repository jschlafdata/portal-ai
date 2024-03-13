import os
import sys
import subprocess
from tools.settings import BaseDir
from tools.common.make_dir import ensure_directory_exists
from tools.common.load_global_settings import load_global_configs

# Ensure that the base directory of your project is accessible
# Note: This line might need adjustment based on your actual project structure and how you're executing the script.

def ssh_key_gen( key_name, 
                 key_email,
                 project_name ):
    
    user_home = os.path.expanduser("~")

    project_ssh_folder=os.path.join(user_home, '.ssh', project_name)
    ensure_directory_exists(project_ssh_folder)

    fq_key = f"id_ed25519_{key_name}"
    ssh_key_file = os.path.join(project_ssh_folder, fq_key)

    # Check if the SSH key already exists
    if os.path.exists(ssh_key_file):
        print(f"SSH key {fq_key} already exists.")
    else:
        # Generate the SSH key with default settings
        ssh_key_gen_command = f'ssh-keygen -t ed25519 -C "{key_email}" -f "{ssh_key_file}" -N ""'
        print(ssh_key_gen_command)
        subprocess.run(ssh_key_gen_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        print(f"SSH key {fq_key} created.")

    # The following commands for ssh-agent and keychain might need adjustment based on your system and requirements
    # Consider commenting these out or adjusting them if they are not needed or if you encounter issues
    ssh_agent = 'eval "$(ssh-agent -s)"'
    subprocess.call(ssh_agent, shell=True)

    keychain_add = f'ssh-add --apple-use-keychain {ssh_key_file}'
    subprocess.call(keychain_add, shell=True)


if __name__ == "__main__":
    
    if BaseDir().set_dir() == True:
        print(f"current working directory: {os.getcwd()}")

        configs = load_global_configs(environment=None)

        ( key_email, ssh_key_names, project_name ) = ( configs.get('git_admin_email', []), 
                                                       configs.get('ssh_key_names', []), 
                                                       configs.get('project_name', []) )
                
        missing_conf = any([k for k in [key_email, ssh_key_names, project_name] if not k])

        if missing_conf:
            print("General settings YAML file missing key configuration.")
            sys.exit(1)

        for key_name in ssh_key_names:
            ssh_key_gen(key_name, key_email, project_name)

    else:
        print(f"Script not executed from root dir, exiting: {os.getcwd()}")
        sys.exit()