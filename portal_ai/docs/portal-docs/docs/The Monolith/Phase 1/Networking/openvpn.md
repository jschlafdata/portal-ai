---
sidebar_position: 3
---

# OpenVPN

This Terraform module provisions an OpenVPN server on AWS. It includes the necessary infrastructure components such as security groups, an EC2 instance for OpenVPN, and scripts for server configuration and user management. The module is designed to be flexible, allowing customization through variables.

* This module is extracted from this git repo
    [openvpn terraform github](https://github.com/dumrauf/openvpn-terraform-install)

* It uses a public subnet that is output from this [vpc module](./vpc.md) to create the openvpn ec2 instance.
    - `module.Networking.openvpn_public_subnet`

## Resources Created

### Security Groups

1. **aws_security_group.openvpn**
   - **Purpose**: Allows inbound UDP access on port 1194 for OpenVPN traffic and unrestricted egress.
   - **Ingress**: Port 1194 (UDP) open to all IP addresses (`0.0.0.0/0`).
   - **Egress**: Allows all outbound traffic on all ports to any destination.

2. **aws_security_group.ssh_from_local**
   - **Purpose**: Allows SSH access from any IP address, intended for initial server setup and maintenance.
   - **Ingress**: Port 22 (TCP) open to all IP addresses (`0.0.0.0/0`).

### Amazon Machine Image (AMI) Data Source

- **data.aws_ami.amazon_linux_2**
  - **Purpose**: Fetches the latest Amazon Linux 2 AMI ID for use in the EC2 instance creation. Filters ensure the selection of an HVM, x86_64 architecture AMI backed by GP2 (General Purpose SSD).

### SSH Key Pair

- **aws_key_pair.openvpn**
  - **Purpose**: Enables SSH access to the EC2 instance using a specified public key.

### EC2 Instance for OpenVPN

- **aws_instance.openvpn**
  - **Configuration**: Uses the Amazon Linux 2 AMI, with a public IP address and the specified instance type. It is associated with both the OpenVPN and SSH security groups and is placed within a specified public subnet.
  - **Root Block Device**: Configured with a GP2 volume of a specified size, set to delete on termination.

### Elastic IP (EIP) for OpenVPN EC2 Instance

- **aws_eip.openvpn_eip**
  - **Purpose**: Associates a static public IP address with the OpenVPN EC2 instance, ensuring a consistent endpoint for VPN users.

### OpenVPN Server Bootstrap

- **null_resource.openvpn_bootstrap**
  - **Purpose**: Performs initial server setup, including system updates and OpenVPN software installation, configured with the provided installation script and automatically assigned EIP.

### User Management Script Upload and Execution

- **null_resource.openvpn_update_users_script**
  - **Purpose**: Updates the OpenVPN server with user configurations. It uploads and executes a custom script to manage OpenVPN users based on provided variables.

### OpenVPN Configuration Download

- **null_resource.openvpn_download_configurations**
  - **Purpose**: Downloads OpenVPN client configuration files (.ovpn) for distribution to users. It securely copies files from the EC2 instance to a specified local directory for easy access.

## Variables

- `vpc_id`: The VPC ID where resources will be provisioned.
- `prefix_portal`: A prefix used for naming resources, aiding in organization and identification.
- `ssh_private_key_file`: The path to the private SSH key file for secure connections.
- `ssh_public_key_file`: The filename of the public SSH key to be used for the EC2 instance.
- `instance_type`: The type of EC2 instance to provision for OpenVPN.
- `openvpn_public_subnet`: The ID of the public subnet where the OpenVPN server will be placed.
- `instance_root_block_device_volume_size`: The size of the root volume of the EC2 instance.
- `ec2_username`: The default username for SSH access to the EC2 instance (e.g., `ec2-user` for Amazon Linux 2).
- `openvpn_install_script_location`: The URL to the OpenVPN installation script.
- `ovpn_users`: A list of usernames for whom to generate OpenVPN configurations.
- `ovpn_config_directory`: The local directory where OpenVPN configuration files will be downloaded.

## Outputs

This module should ideally be configured to output essential information such as the OpenVPN server's public IP address, the SSH connection command, and the location of downloaded OpenVPN configuration files for easy access by the system administrator or end-users.
