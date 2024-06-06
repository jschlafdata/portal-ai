# Aggregating Terraform Outputs

Phase 1 deployment creates tons of resources and outputs that we want to use for future steps, kubernetes & kops configurations, as well as database and data portal resources.

I have configured the main module from the terraform deployment to output all of the needed resource configurations and ids in a json file.

```hcl title="terraform_outputs"
resource "null_resource" "save_outputs_to_json" {
  # Depends on any resources that these outputs depend on
  depends_on = [
    module.networking,
    module.kubernetes_iam,
    module.efs
  ]

  triggers = {
    # A trigger to ensure this resource is updated if the output values change.
    # This can be a timestamp or any other value that changes when outputs might change.
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOT
    terraform output -json > generated/tf_outputs/module_outputs.json
EOT
  }
}
```


This is great and all, but the outputs are not very clean or useable, and considering my affinity for yaml files, I created a python script that grabs the relevent information and formats into a pretty yaml file that can be used down the line.

<details>
<summary>Aggregate Outputs, write to kops_base_config.yaml file</summary>
<p>

```python title="generate_kops_config.py"
import yaml
import json
from collections import defaultdict
from pathlib import Path
import sys
sys.path.append(str(Path(__file__).resolve().parents[2]))

from tools.settings import BASE_DIR
import os

print("----------------------------------------------------")
print(f"THE ROOT DIRECTORY FOR THIS PROJECT IS: {BASE_DIR}")
print("----------------------------------------------------")
os.chdir(BASE_DIR)
print(f"THE CURRENT WORKING DIRECTORY HAS BEEN SET TO: {BASE_DIR}")
print("----------------------------------------------------")


# Now `data` is a Python dictionary that contains the contents of your JSON file

extract_keys = ['availability_zone_private', 
                'availability_zone_public', 
                'iam_policy_arns', 
                'nat_gateway_id', 
                'private_subnet_cidrs', 
                'private_subnet_ids', 
                'public_subnet_cidrs',
                'public_subnet_ids',
                'vpc_cidr_block', 
                'vpc_id', 
                'vpc_name']

subnet_mapping = { 'public': ('availability_zone_public', 
                              'public_subnet_cidrs', 
                              'public_subnet_ids'),
                  
                   'private': ('availability_zone_private',
                               'private_subnet_cidrs', 
                               'private_subnet_ids') 
                 }

def get_subnet_values(tf_configs, 
                      is_private=False):
    
    endpoint = 'public' if is_private == False else 'private'
    
    (az_var, cidr_var, id_var) = subnet_mapping.get(endpoint)
    
    (azs, cidrs, ids) = ( tf_configs.get(az_var).get('value'), 
                          tf_configs.get(cidr_var).get('value'), 
                          tf_configs.get(id_var).get('value') )
    
    return list(zip(azs, cidrs, ids))

def group_subnets( tf_configs,
                   compacted_values,
                   is_private=False ):
    
    endpoint = 'public' if is_private == False else 'private'
    subnet_values = get_subnet_values(tf_configs, is_private)
    
    for item in subnet_values:
        az, cidr, id = item  # Unpack values directly
    
        # Dynamically set values using variables
        compacted_values['subnets'][az][endpoint]['cidr'] = cidr
        compacted_values['subnets'][az][endpoint]['id'] = id 
    
    return True

def defaultdict_to_dict(d):
    if isinstance(d, defaultdict):
        d = {k: defaultdict_to_dict(v) for k, v in d.items()}
    elif isinstance(d, dict):
        d = {k: defaultdict_to_dict(v) for k, v in d.items()}
    return d


def get_iam_policy_arns_dict(tf_configs):
    # Initialize the structure with the specific format you need
    policyARNs_dict = {
        'iam': {
            'allowContainerRegistry': True,
            'serviceAccountExternalPermissions': []
        }
    }
    policyARNs = []
    for item in tf_configs.get('iam_policy_arns').get('value'):
        name = item[0]
        arn = item[1]
        result = {'aws':{'policyARNs': [arn], 'name': name}}
        policyARNs.append(result)

    # Add the policyARNs list directly to the desired location
    policyARNs_dict['iam']['serviceAccountExternalPermissions'] = policyARNs

    return policyARNs_dict


def get_subnet_dict(tf_configs):

    compacted_values = defaultdict(lambda: defaultdict(lambda: defaultdict(dict)))
    group_subnets( tf_configs,
                   compacted_values, 
                   is_private=True )
    
    group_subnets( tf_configs,
                   compacted_values, 
                   is_private=False )

    return defaultdict_to_dict(compacted_values)

def get_tf_configs(environment):
    
    yml_path = f"./aws/terraform/{environment}/generated/tf_outputs/module_outputs.json"
    # Open the JSON file and load its content into a Python dictionary
    with open(yml_path, 'r') as file:
        tf_configs = json.load(file)
    return tf_configs

def get_standard_configs(tf_configs, 
                         environment):

    global_config_path = "./global_settings.yaml"
    
    with open(global_config_path, 'r') as file:
        global_configs = yaml.safe_load(file).get('deployment_metadata')  # Use yaml.safe_load to load the YAML file

    dns_zone = global_configs.get('dns_zone')
    dns_domain = global_configs.get('dns_domain').get(environment)
    dns_zone_id = global_configs.get('dns_zone_id').get(environment)
    vpn_internal_network_ip = global_configs.get('vpn_internal_network_ip')

    remote_storage_path = "./aws/terraform/deployment_configs/remote_s3_buckets.yaml"

    with open(remote_storage_path, 'r') as file:
        remote_storage = yaml.safe_load(file).get('s3_backends')

    env_mapping = { 'dev':'-dev', 
                    'stage':'-stage',
                    'prod':'' }
    
    clusterName = f"k8s{env_mapping.get('environment')}-{dns_domain}"
    configBase = f"s3://{remote_storage.get('kops').get(environment)}/{clusterName}"
    discoveryStore = remote_storage.get('kops_iam').get(environment)
    
    natGatewayId = tf_configs.get('nat_gateway_id').get('value')
    networkCIDR = tf_configs.get('vpc_cidr_block').get('value')
    networkID = tf_configs.get('vpc_id').get('value')

    return { 'natGatewayId': natGatewayId,
             'networkCIDR': networkCIDR,
             'networkID': networkID,
             'dns_zone': dns_zone,
             'dns_domain': dns_domain,
             'dns_zone_id': dns_zone_id,
             'vpn_internal_network_ip': vpn_internal_network_ip,
             'clusterName': clusterName,
             'configBase': configBase,
             'discoveryStore': discoveryStore }
    

def get_all_kops_configurations(environment):
    
    tf_configs = get_tf_configs(environment)
    
    iam_policy_dict = get_iam_policy_arns_dict( tf_configs )
    subnet_items_dict = get_subnet_dict(tf_configs)
    standard_items_dict = get_standard_configs(tf_configs, environment)

    return {**standard_items_dict, **iam_policy_dict, **subnet_items_dict}


def main(environment):
    # Gather all configurations for the specified environment
    all_configs = get_all_kops_configurations(environment)
    
    # Specify the output YAML file name
    output_file = f"./kops/{environment}/kops_base_config.yaml"
    
    # Write the configurations to a YAML file
    with open(output_file, 'w') as file:
        yaml.dump(all_configs, file, default_flow_style=False, sort_keys=False)
        
    print(f"Configuration written to {output_file}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python build_kops_config.py <environment>")
        sys.exit(1)
    
    environment = sys.argv[1]  # Get the environment from the command line
    main(environment)

```

</p>
</details>


### Command Execution

```
py tools/config_builders/generate_kops_config.py stage
```

### Command Output

```
THE CURRENT WORKING DIRECTORY HAS BEEN SET TO: /Users/johnschlafly/Documents/schlafdata-cloud
----------------------------------------------------
Configuration written to ./kops/stage/kops_base_config.yaml
```

### Example Output YAML

```yaml title="kops_base_config.yaml"
natGatewayId: nat-0116712f4c0c2f855
networkCIDR: 174.65.0.0/16
networkID: vpc-08109b719a65258aa
dns_zone: schlafdata
dns_domain: schlafdata.tools
dns_zone_id: Z0711371143C8LIXMFAPD
vpn_internal_network_ip: 10.8.0.0/24
clusterName: k8sNone-schlafdata.tools
configBase: s3://kops-stage.schlafdata.tools/k8sNone-schlafdata.tools
discoveryStore: iam-http-dir-stage.schlafdata.tools
iam:
  allowContainerRegistry: true
  serviceAccountExternalPermissions:
  - aws:
      policyARNs:
      - arn:aws:iam::775273630641:policy/k8s-efs-admin
      name: k8s-efs-admin
  - aws:
      policyARNs:
      - arn:aws:iam::775273630641:policy/aws_lb_controller
      name: aws_lb_controller
  - aws:
      policyARNs:
      - arn:aws:iam::775273630641:policy/ecr
      name: ecr
  - aws:
      policyARNs:
      - arn:aws:iam::775273630641:policy/kops
      name: kops
  - aws:
      policyARNs:
      - arn:aws:iam::775273630641:policy/external-dns-host
      name: external-dns-host
  - aws:
      policyARNs:
      - arn:aws:iam::775273630641:policy/external-dns
      name: external-dns
subnets:
  us-west-2a:
    private:
      cidr: 174.65.10.0/27
      id: subnet-09f4e5e1742281b51
    public:
      cidr: 174.65.1.0/27
      id: subnet-08fc042115c7222b1
  us-west-2b:
    private:
      cidr: 174.65.10.32/27
      id: subnet-04d052e3941978d53
    public:
      cidr: 174.65.1.32/27
      id: subnet-0032af99b71efbc40
  us-west-2c:
    private:
      cidr: 174.65.10.64/27
      id: subnet-009ce4aaa209ede5e
    public:
      cidr: 174.65.1.64/27
      id: subnet-018a1f9f4b8c44a73
  us-west-2d:
    private:
      cidr: 174.65.10.96/27
      id: subnet-0b98ee55bed5d7d3e
    public:
      cidr: 174.65.1.96/27
      id: subnet-04a4b6274953815b3
```

