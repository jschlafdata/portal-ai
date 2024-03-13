import os
import sys
import argparse
from tools.settings import BaseDir
from tools.common.load_global_settings import load_global_configs
from tools.auth.aws_auth import pySSO
from tools.common.boto import BotoS3


def main(environment):
    
    configs = load_global_configs(environment=environment)
    aws_region = configs.get('aws_region')
    tf_state_bucket = configs.get('remote_s3_bucket_configs').get('tfstate_prefix')
    
    env_tf_dir = f"./{environment}/terraform"
    os.chdir(env_tf_dir)

    dir_folders = next(os.walk('.'))[1]
    for dir in dir_folders:

        content = f"""terraform {{
        backend "s3" {{
            bucket = "{tf_state_bucket}"
            key = "{dir}"
            region = "{aws_region}"
            encrypt = true
            }}
        }}"""

        tf_remote_state_path = f"{dir}/remote.tf"
        
        with open(tf_remote_state_path, "w") as file:
            file.write(content)

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Create tf remote state files from S3 buckets.')
    parser.add_argument('environment', help='Environment for the S3 operation')
    args = parser.parse_args()

    if BaseDir().set_dir():
        print(f"current working directory: {os.getcwd()}")
    else:
        print(f"Script not executed from root dir, exiting: {os.getcwd()}")
        sys.exit()
    
    environment=args.environment
    main(environment)
