---
sidebar_position: 1
---

# Networking Overview

Three terraform modules are deployed initially to create a secure networking foundation that all future resources & compute reside in.

* [vpc module](./vpc.md)
* [openvpn module](./openvpn.md)
* [customer gateway module](./customer_gateway.md)


## Private Subnets

A private subnet in AWS is a segment of a VPC that is not directly accessible from the internet. Resources in a private subnet can access the internet or be accessed from the internet only through intermediary services like NAT Gateways, VPN connections, or through a public subnet.

Private subnets are used for resources that should not be directly accessible from the internet. This typically includes databases, application servers, and backend services.

:::important
### Internet Access
Resources in private subnets cannot directly initiate outbound traffic to the internet or receive inbound traffic from the internet. However, they can access the internet using a NAT Gateway (for outbound access) placed in a public subnet.
:::

:::note
A key concept behind this setup is that all data applications and compute resources live inside private subnets. After creation of a VPC and public/private subnets, a VPN is created using openvpn, which is then "granted access" to the private subnets via a virtual private gateway and customer gateway.

* #### The resulting setup is such that you can only develop or access sensitive resources when you are logged into the vpn created.
:::

:::tip
Leveraging this, and future concepts involving hashicorp https://www.vaultproject.io/ setup and bash scripts, it is possible to set up a seamless development enviornment where secrets are never stored locally, and terminal sessions must be authenticated using 2 factor auth.
:::


![networking end to end](/img/aws/vpc_e2e.png)