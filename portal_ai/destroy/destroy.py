import os
import sys
import shutil
from portal_ai.settings.logger import LoggerConfig
from portal_ai.settings.get_environment import get_project_env
from portal_ai.setup.tf_remote_states import RemoteS3Manager


class Cleaner:
    def __init__(self):
        self.environment = get_project_env()

    def remove_dir(self, path):
        """Remove a directory and handle exceptions."""
        try:
            shutil.rmtree(path)
            print(f"Removed {path} directory.")
        except Exception as e:
            print(f"Error: Failed to remove {path} directory. {e}")
            sys.exit(1)

    def remove_file(self, path):
        """Remove a file and handle exceptions."""
        try:
            os.remove(path)
            print(f"Removed {path} file.")
        except Exception as e:
            print(f"Error: Failed to remove {path} file. {e}")
            sys.exit(1)

    def clean_terraform(self, module):
        """Perform the Terraform cleanup process."""
        # Navigate to the specified environment and module directory
        try:
            os.chdir(os.path.join("portal_ai/terraform", module))
        except Exception as e:
            print(f"Error: Failed to change directory. Check the specified path. {e}")
            sys.exit(1)

        # Remove .terraform directory if it exists
        if os.path.isdir(".terraform"):
            print("Removing .terraform directory...")
            self.remove_dir(".terraform")
        else:
            print(".terraform directory does not exist or has already been removed.")

        # Remove .terraform.lock.hcl file if it exists
        if os.path.isfile(".terraform.lock.hcl"):
            print("Removing .terraform.lock.hcl file...")
            self.remove_file(".terraform.lock.hcl")
        else:
            print(".terraform.lock.hcl file does not exist or has already been removed.")

        print(f"Terraform cleanup complete for environment: {self.environment}")


def main():

    RemoteS3Manager().manage_s3_buckets(action='delete')
    
    cleaner = Cleaner()
    modules = ['aws_base']

    for module in modules:
        cleaner.clean_terraform(module)

if __name__ == "__main__":
    main()