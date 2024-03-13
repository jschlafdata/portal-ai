
locals {
  prefix_portal = "schlafdata"
}

module "Networking" {
  source               = "./data_portal_vpc"
  aws_region           = var.aws_region
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  prefix_portal        = local.prefix_portal

}

module "openvpn_ec2" {
  source                     = "./openvpn_ec2"
  openvpn_public_subnet      = module.Networking.openvpn_public_subnet
  prefix_portal              = local.prefix_portal
  aws_region                 = var.aws_region
  vpc_id                     = module.Networking.vpc_id
  ovpn_users                 = var.ovpn_users
  ovpn_config_directory      = var.ovpn_config_directory
  ovpn_ssh_key_name          = var.ovpn_ssh_key_name
  ovpn_ssh_private_key_file  = var.ovpn_ssh_private_key_file
}


module "vpn_gateway" {
  source                   = "./vpn_gateway"
  aws_region               = var.aws_region
  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  public_subnets_cidr      = var.public_subnets_cidr
  private_subnets_cidr     = var.private_subnets_cidr
  prefix_portal            = local.prefix_portal
  vpn_gateway_id           = module.Networking.vpn_gateway_id
  private_route_tables     = module.Networking.private_route_tables
  open_vpn_external_ip     = module.openvpn_ec2.ec2_instance_ip
  open_vpn_static_route_ip = var.open_vpn_static_route_ip
}
