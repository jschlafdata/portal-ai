---
sidebar_position: 4
---


# Virtual Private Gateway Routing

This Terraform module facilitates the creation of a Customer Gateway and a VPN Connection in AWS, along with the necessary routing configurations for integrating an on-premises network with the AWS cloud environment. This setup enables secure communication over IPsec VPN connections.

:::important

This module uses outputs from [vpc module](./vpc.md) and [openvpn module](./openvpn.md) to create a network path allowing traffic from the openVPN created to access private subnets created in the aws VPC module.

  * `vpn_gateway_id`       = module.[vpc_module](./vpc.md).vpn_gateway_id
  * `private_route_tables` = module.[vpc_module](./vpc.md).private_route_tables
  * `open_vpn_external_ip` = module.[openvpn_module](./openvpn.md).ec2_instance_ip
:::


## Resources Created

![customer gateway](/img/aws/customer_gateway.png)

* The end result of this module is routes that enable access from the openvpn created to private subnets.

### AWS Customer Gateway

- **aws_customer_gateway.main**
  - **Purpose**: Establishes a Customer Gateway to represent an external endpoint (such as an on-premises VPN device) in AWS.
  - **Configuration**: 
    - `bgp_asn`: The Border Gateway Protocol (BGP) Autonomous System Number (ASN) of the customer gateway. In this setup, it is statically set to `65000`.
    - `ip_address`: The external IP address of the customer's VPN device. This is provided via the `var.open_vpn_external_ip` variable.
    - `type`: Specifies the type of VPN connection that the customer gateway supports, which is `ipsec.1` in this case.
  - **Tags**: Includes a `Name` tag constructed from variables for prefix, portal, and environment identifiers, enhancing resource identification and management.

### AWS VPN Connection

- **aws_vpn_connection.main**
  - **Purpose**: Creates a VPN Connection between the AWS Virtual Private Gateway and the Customer Gateway, facilitating secure communication.
  - **Configuration**: 
    - `vpn_gateway_id`: The ID of the existing Virtual Private Gateway to which the VPN connection is to be attached.
    - `customer_gateway_id`: Dynamically references the ID of the Customer Gateway created earlier.
    - `type`: Indicates the type of VPN connection, aligned with the Customer Gateway to `ipsec.1`.
    - `static_routes_only`: Set to `true`, indicating that only static routes are used for this VPN connection, simplifying routing management.
    
### Routing for NAT

- **aws_route.private_nat_gateway**
  - **Purpose**: Configures routing to direct traffic destined for the specified CIDR block through the VPN Connection, typically for accessing internal network resources via the VPN.
  - **Configuration**:
    - `for_each`: Iterates over a map of private route table IDs provided via `var.private_route_tables`, applying the routing rule to each specified table.
    - `route_table_id`: The ID of the route table being configured, iterated for each entry in `var.private_route_tables`.
    - `destination_cidr_block`: The CIDR block for which traffic is to be routed through the VPN connection, specified by `var.open_vpn_static_route_ip`.
    - `gateway_id`: Specifies the Virtual Private Gateway ID as the target for the routed traffic, provided by `var.vpn_gateway_id`.

## Variables

- `open_vpn_external_ip`: The external IP address of the on-premises VPN device.
- `prefix_portal`: A prefix used for naming resources, aiding in organization and identification.
- `environment`: Specifies the deployment environment, assisting in resource segregation and management.
- `vpn_gateway_id`: The ID of the AWS Virtual Private Gateway to which the VPN connection will be attached.
- `private_route_tables`: A map of private route table IDs to which the VPN routing will be applied.
- `open_vpn_static_route_ip`: The CIDR block that defines the range of IP addresses accessible through the VPN connection.

## Purpose

This module is designed to streamline the integration of AWS cloud resources with an on-premises network via a secure VPN connection. It allows for seamless connectivity between cloud-based applications and internal network resources, ensuring secure data transmission and enhancing hybrid network architecture.

## Outputs

To enhance the usability of this module, consider defining outputs for:

- The Customer Gateway ID and IP address.
- VPN Connection ID.
- Applied route configurations, including the destination CIDR blocks and associated route table IDs.

These outputs will facilitate the management, troubleshooting, and integration of the VPN setup with other infrastructure components.
