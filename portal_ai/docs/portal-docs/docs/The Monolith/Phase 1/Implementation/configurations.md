# Parameters and Configuarion Files

For a multi-account deployment of VPC's and subnets in AWS, you need to ensure that the VPC CIDR blocks do not overlap.

I have pre-defined the aws_region, and vpc/subnet CIDR ranges that are used for each environments deployment.

```yaml title="deployment_configs.yaml"

aws_region: us-west-2

dev:
  vpc_cidr: 174.64.0.0/16
  public_subnets_cidr: 174.64.1.0/24
  private_subnets_cidr: 174.64.10.0/24

stage:
  vpc_cidr: 174.65.0.0/16
  public_subnets_cidr: 174.65.1.0/24
  private_subnets_cidr: 174.65.10.0/24

prod:
  vpc_cidr: 174.66.0.0/16
  public_subnets_cidr: 174.66.1.0/24
  private_subnets_cidr: 174.66.10.0/24
```

Additionally, I am leveraging a terraform module that creates and builds a vpn within the same VPC that is initially created.

This module leverages & expects a private and public key to exist in your ~/.ssh folder.

```yaml title=deployment_configs.yaml"
ovpn_configs:
  ovpn_config_directory: generated/ovpn-config
  ssh_private_key_file: id_ed25519_openvpn
  ssh_public_key_file: id_ed25519_openvpn.pub
  open_vpn_static_route_ip: "10.8.0.0/24"
```

:::note
I am using code extracted from this github repository to create the open VPN.
* [openvpn-terraform-install](https://github.com/dumrauf/openvpn-terraform-install)

The internal network IP of the openVPN setup is predefined here [openvpn-network-ip](https://github.com/angristan/openvpn-install/blob/5a4b31bd0d711da5df5febc944167b3cdb0a28bf/openvpn-install.sh#L115C1-L116C1)

This is why I have statically coded `open_vpn_static_route_ip`: 10.8.0.0/24
in the deployment_configs.yaml file.
:::


### openvpn private key gen

<details>
<summary>Python script for generating ssh key</summary>
<p>

```python title="keygen.py"
import os
import subprocess
from pathlib import Path
import sys
import yaml

# Ensure that the base directory of your project is accessible
sys.path.append(str(Path(__file__).resolve().parents[2]))

from tools.settings import BASE_DIR

print("----------------------------------------------------")
print(f"THE ROOT DIRECTORY FOR THIS PROJECT IS: {BASE_DIR}")
print("----------------------------------------------------")
os.chdir(BASE_DIR)
print(f"THE CURRENT WORKING DIRECTORY HAS BEEN SET TO: {BASE_DIR}")
print("----------------------------------------------------")

def key_gen(key_name='openvpn'):
    # Load global configuration
    global_config_path = "./global_settings.yaml"

    with open(global_config_path, 'r') as file:
        global_configs = yaml.safe_load(file).get('deployment_metadata')

    key_email = global_configs.get('git_admin_email')
    user_home = os.path.expanduser("~")
    fq_key = f"id_ed25519_{key_name}"
    ssh_key_file = os.path.join(user_home, '.ssh', fq_key)

    # Check if the SSH key already exists
    if os.path.exists(ssh_key_file):
        print(f"SSH key {fq_key} already exists.")
    else:
        # Generate the SSH key with default settings
        ssh_key_gen_command = f'ssh-keygen -t ed25519 -C "{key_email}" -f "{ssh_key_file}" -N ""'
        print(ssh_key_gen_command)
        completed_process = subprocess.run(ssh_key_gen_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    # Add the SSH key to the ssh-agent
    ssh_agent = 'eval "$(ssh-agent -s)"'
    subprocess.call(["./tools/system_setup/exec_commands.sh", ssh_agent])

    keychain_add = f'ssh-add --apple-use-keychain ~/.ssh/{fq_key}'
    subprocess.call(["./tools/system_setup/exec_commands.sh", keychain_add])

if __name__ == "__main__":
    key_gen()
```

</p>
</details>


### Command Execution

```
py tools/system_setup/keygen.py
```

### Command Output

```
----------------------------------------------------
THE ROOT DIRECTORY FOR THIS PROJECT IS: /Users/johnschlafly/Documents/schlafdata-cloud
----------------------------------------------------
THE CURRENT WORKING DIRECTORY HAS BEEN SET TO: /Users/johnschlafly/Documents/schlafdata-cloud
----------------------------------------------------
SSH key id_ed25519_openvpn already exists.
Executing terminal commands...
Agent pid 49724
Script completed.
Executing terminal commands...
Identity added: /Users/johnschlafly/.ssh/id_ed25519_openvpn (john@schlafdata.com)
Script completed.
```


## Terraform Remote State
The previously created remote states need to be updated to have the correct backend bucket path. You cannot pass environment variables to terraform remote.tf or providers.tf configurations, so the following is a script that leverages the environment you are developing in to overwrite the remote storage location file.


<details>
<summary>Overwrite Terraform Remote State</summary>
<p>

```python title="update_remote_tf.py"
from collections import defaultdict
from pathlib import Path
import sys
import yaml
sys.path.append(str(Path(__file__).resolve().parents[2]))

from tools.settings import BASE_DIR
import os

print("----------------------------------------------------")
print(f"THE ROOT DIRECTORY FOR THIS PROJECT IS: {BASE_DIR}")
print("----------------------------------------------------")
os.chdir(BASE_DIR)
print(f"THE CURRENT WORKING DIRECTORY HAS BEEN SET TO: {BASE_DIR}")
print("----------------------------------------------------")

def update_remote_tf(environment):

    remote_s3_path = f"./aws/terraform/deployment_configs/remote_s3_buckets.yaml"
    with open(remote_s3_path, 'r') as file:
        remote_s3_paths = yaml.safe_load(file).get('s3_backends')  # Use yaml.safe_load to load the YAML file

    bucket_name = remote_s3_paths.get('terraform').get(environment)
    content = f"""terraform {{
    backend "s3" {{
        bucket = "{bucket_name}"
        key = "stage-aws-networking"
        region = "us-west-2"
        encrypt = true
        }}
    }}"""
    tf_remote_state_path = f"./aws/terraform/{environment}/remote.tf"
    with open(tf_remote_state_path, "w") as file:
        file.write(content)
    print(f"{tf_remote_state_path} has been updated with the new configuration.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python update_remote_tf.py <environment>")
        sys.exit(1)

    environment = sys.argv[1]
    update_remote_tf(environment)
```
</p>
</details>



### Command Execution

```
py tools/config_builders/update_remote_tf.py stage
```

### Command Output

```
----------------------------------------------------
./aws/terraform/stage/remote.tf has been updated with the new configuration.
```

