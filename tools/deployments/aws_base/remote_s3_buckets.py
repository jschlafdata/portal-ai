import os
import sys
import argparse
from tools.settings import BaseDir
from tools.common.load_global_settings import load_global_configs
from tools.auth.aws_auth import pySSO
from tools.common.boto import BotoS3


def main(action, environment):
    
    pySSO(environment).py_aws_sso()

    configs = load_global_configs(environment=environment)
    aws_region = configs.get('aws_region')

    s3_handler = BotoS3(aws_profile=environment, aws_region=aws_region, action=action)

    s3_backend_buckets = configs['remote_s3_bucket_configs']
    for section, bucket_name in s3_backend_buckets.items():
        if bucket_name:
            if action == "create":
                s3_handler.create_s3_bucket(bucket_name)
                if section == "kops_iam_prefix":
                    s3_handler.update_bucket_policies(bucket_name)
            elif action == "delete":
                s3_handler.delete_all_objects(bucket_name)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Manage S3 buckets.')
    parser.add_argument('environment', help='Environment for the S3 operation')
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('-c', '--create', action='store_true', help='Create S3 buckets')
    group.add_argument('-d', '--delete', action='store_true', help='Delete S3 buckets')

    args = parser.parse_args()

    if args.create:
        action = "create"
    elif args.delete:
        action = "delete"

    if BaseDir().set_dir():
        print(f"current working directory: {os.getcwd()}")
    else:
        print(f"Script not executed from root dir, exiting: {os.getcwd()}")
        sys.exit()
    
    environment=args.environment
    main(action, environment)
