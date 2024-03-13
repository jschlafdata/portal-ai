import subprocess
from tools.common.load_global_settings import load_global_configs

class pySSO:
    def __init__(self, environment):
        self.environment = environment
        self.configs = load_global_configs(environment=environment)

    def py_aws_sso(self):
        aws_start_url = self.configs.get('aws_start_url')
        aws_region = self.configs.get('aws_region')

        print(f"aws_start_url: {aws_start_url} .. aws_region: {aws_region}")

        sso_auth_cmd = f'./tools/scripts/aws_sso/sso_profile_auth.sh {self.environment} {aws_region} {aws_start_url}'

        try:
            result = subprocess.run(
                sso_auth_cmd,
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                check=True  # Raises CalledProcessError for non-zero exit status
            )

            print("Output:", result.stdout)
            if result.stderr:
                print("Error:", result.stderr)

        except subprocess.CalledProcessError as e:
            print("An error occurred while attempting to execute the script.")
            print("Error:", e.stderr)