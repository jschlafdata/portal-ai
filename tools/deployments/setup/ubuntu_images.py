import boto3
import os
import sys
from tools.settings import BaseDir
from tools.templating.yaml.yaml_manager import YmlManager

# # Amazon Web Services (AWS)
# aws ec2 describe-images --region us-west-2 --output table \
#   --owners 099720109477 \
#   --query "sort_by(Images, &CreationDate)[*].[CreationDate,Name,ImageId]" \
#   --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"


def get_regions():
    """Get a list of all AWS regions."""
    ec2 = boto3.client('ec2', region_name='us-east-1')  # 'us-east-1' can query all regions
    response = ec2.describe_regions()
    return [region['RegionName'] for region in response['Regions']]

def get_recent_ubuntu_ami(region):
    """Get the most recent Ubuntu AMI in the specified region."""
    ec2 = boto3.client('ec2', region_name=region)
    response = ec2.describe_images(
        Owners=['099720109477'],  # Ubuntu's owner ID
        Filters=[{'Name': 'name', 'Values': ['ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*']}],
        # Add any other necessary filters here
    )
    images = sorted(response['Images'], key=lambda x: x['CreationDate'], reverse=True)
    if images:
        return images[0]  # Return the most recent image
    else:
        return None


def main():

    ubuntu_images_info = {'ubuntu_latest_jammy': {}}

    for region in get_regions():
        recent_ami = get_recent_ubuntu_ami(region)
        if recent_ami:
            ubuntu_images_info['ubuntu_latest_jammy'][region] = {
                'image_name': recent_ami['Name'],
                'image_ami': recent_ami['ImageId'],
            }
    
    # Write to YAML file
    output_file='./mapping_files/aws/ubuntu_images.yml'
    YmlManager(output_file).save(ubuntu_images_info)

if __name__ == "__main__":
    if BaseDir().set_dir() == True:
        print(f"current working directory: {os.getcwd()}")
        main()
    else:
        print(f"script not executed from root dir, exiting.. cwd is: {os.getcwd()}")
        sys.exit()