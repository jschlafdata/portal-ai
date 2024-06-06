---
sidebar_position: 2
---


# VPC, Subnets, Gateways

This Terraform module provisions a Virtual Private Cloud (VPC) in AWS, along with associated resources such as subnets, Internet Gateway (IG), VPN Gateway, NAT Gateway, Elastic IPs, route tables, and a default security group. It's designed to be highly configurable through the use of variables, making it suitable for different environments and deployment needs.

![vpc diagram](/img/aws/vpc_subnets.png)

:::important
Please note that for the private subnets, each subnet uses its OWN route table. While it is possible to create private nets using the same route table, it is not recommended.

If you ever want to set up VPC peering to allow other AWS accounts to access resources in a private subnet, it must be set up this way. If you do not have a defined route for each private subnet, VPC peering will not work. There is not alot of information out there on this, and it was really hard to debug in a production enviornment. Lots of tears.
:::


## Resources Created

### VPC

- **aws_vpc.vpc**: Creates a VPC with DNS support and hostnames enabled. The CIDR block is configurable through the `var.vpc_cidr` variable. Tags include the name, which is a combination of a prefix, portal identifier, and environment name, and the environment type.

### Availability Zones Data Source

- **data.aws_availability_zones.available**: Fetches a list of availability zones in the region for subnet distribution.

### Internet Gateway

- **aws_internet_gateway.ig**: Provisions an Internet Gateway associated with the VPC for public internet access. Tags include the name, which combines prefix, portal identifier, and environment, and the environment type.

### VPN Gateway

- **aws_vpn_gateway.vpn_gw**: Creates a VPN Gateway associated with the VPC. The name tag includes a combination of prefix, portal identifier, and environment.

### Elastic IP

- **aws_eip.nat_eip**: Allocates an Elastic IP (EIP) for the NAT Gateway, ensuring it's within the VPC domain. This resource depends on the Internet Gateway.

### Public Subnets

- **aws_subnet.public_subnet**: Defines public subnets across available AZs with CIDR blocks calculated dynamically. These subnets enable public IP address mapping on launch. Tags include the environment and the specific AZ for easier identification.

### Private Subnets

- **aws_subnet.private_subnet**: Similar to public subnets, these are defined across available AZs but are intended for private use, with no public IP mapping on launch. Tags are similar to those for public subnets, aiding in identification.

### NAT Gateway

- **aws_nat_gateway.nat**: Deploys a NAT Gateway using the allocated EIP. It's placed within the first public subnet by default. Tags include name and environment.

### Public Route Table

- **aws_route_table.public**: Establishes a routing table for public subnet traffic, directing to the Internet Gateway. Tagged with environment and designated as public.

### Public Route

- **aws_route.public_internet_gateway**: Creates a route in the public route table for directing traffic to the Internet Gateway.

### Public Route Table Associations

- **aws_route_table_association.public**: Associates public subnets with the public route table to enable internet access.

### Private Route Tables

- **aws_route_table.private**: For each private subnet, creates a corresponding route table. These are tagged similarly to the subnets for identification.

### Private Route for NAT

- **aws_route.private_nat_gateway**: Sets up a route in each private route table to direct internet-bound traffic through the NAT Gateway.

### Private Route Table Associations

- **aws_route_table_association.private**: Associates each private subnet with its corresponding private route table, utilizing a local map for ID mapping.

### Default Security Group

- **aws_security_group.default**: Configures the default security group for the VPC to allow all traffic within the VPC. Tags the group with the environment.

## Variables

This module uses several variables to allow customization:

- `vpc_cidr`: CIDR block for the VPC.
- `prefix_portal`: Prefix used in naming resources, typically to indicate the portal or project.
- `environment`: Environment type, e.g., `dev`, `test`, `prod`.
- `public_subnets_cidr`: Base CIDR block for calculating public subnet CIDRs.
- `private_subnets_cidr`: Base CIDR block for calculating private subnet CIDRs.

## Outputs

This module should be configured to output key information about the created resources, such as IDs and names, for use in other parts of your Terraform configuration or for informational purposes.
