
from portal_ai.aws.boto_s3.boto import BotoS3
import time
import json
import sys
from portal_ai.settings.logger import LoggerConfig
from portal_ai.settings.load_settings import (
    ConfigReader,
    ConfigurationLoader
)

def log_to_stderr(message):
    sys.stderr.write(message + "\n")

def update_target_group_attributes(client, target_group_arn, tag_value, logger):
    try:
        client.modify_target_group_attributes(
            TargetGroupArn=target_group_arn,
            Attributes=[{'Key': 'proxy_protocol_v2.enabled', 'Value': 'true'}]
        )
        logger.info(f"Successfully updated Target Group {target_group_arn} to enable Proxy Protocol v2 for {tag_value}")
        return True
    except Exception as e:
        logger.info(f"Failed to update Target Group {target_group_arn} for {tag_value}. Error: {e}")
        return False

def check_target_groups(tag_key, tag_values, client, logger):
    all_target_groups_updated = True  # Assume success until proven otherwise
    
    try:
        response = client.describe_target_groups()
        for tg in response['TargetGroups']:
            tg_arn = tg['TargetGroupArn']
            tags_response = client.describe_tags(ResourceArns=[tg_arn])
            for description in tags_response['TagDescriptions']:
                for tag_value in tag_values:
                    # Check if the target group has the tag we're interested in
                    if any(tag['Key'] == tag_key and tag['Value'] == tag_value for tag in description['Tags']):
                        if not update_target_group_attributes(client, tg_arn, tag_value, logger):
                            logger.info(f"Failed to update attributes for Target Group: {tg_arn} with tag value: {tag_value}")
                            all_target_groups_updated = False  # Mark as false but continue checking others
                        else:
                            logger.info(f"Successfully updated Target Group: {tg_arn} for tag value: {tag_value}")
                    # No else block needed, we simply skip target groups that don't match our criteria
        return all_target_groups_updated
    except NoCredentialsError:
        logger.info("No AWS credentials found. Please configure your credentials.")
        return False  # Return False if there are credential issues


def main():
    
    logger = LoggerConfig.get_logger(__name__)

    loader = ConfigurationLoader(ConfigReader)
    deploment_configs = loader.generated_config_loader('aws_plus_global_base')
    helm_configs = loader.generated_config_loader('helm_deployment_settings')

    project = deploment_configs.get('project_name')
    env = deploment_configs.get('environment')
    aws_profile = f"{project}-{env}"
    aws_region = deploment_configs.get('aws_region')

    taget_dict = {
        'nginx-internal': "default/nginx-internal-ingress-nginx-controller",
        'nginx-external': "default/nginx-external-ingress-nginx-controller"
    }

    tag_values = []
    for key in [ 'external.system.nginx-internal',
                 'external.system.nginx-external' ]:

        if helm_configs.get(key):
            item = key.split('.')[-1]
            tag_values.append(taget_dict.get(item))

    tag_key = "kubernetes.io/service-name"
    tag_values = [
        "default/nginx-internal-ingress-nginx-controller"
    ]

    elbv2_client = BotoS3(aws_profile, aws_region, action=None).get_boto_elbv2_client()
    all_target_groups_found = check_target_groups(tag_key, tag_values, elbv2_client, logger)

    if all_target_groups_found:
        output = {'status': '200', 'message': 'All target groups have been found'}
    else:
        sys.exit(1)

    print(json.dumps(output))  # Ensure this is the only print to stdout


if __name__ == "__main__":
    main()