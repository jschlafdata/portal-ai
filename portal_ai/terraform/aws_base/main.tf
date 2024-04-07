

locals {
  global_settings     = yamldecode(file("./configs/generated/global_settings_base.yml"))
  module_name         = basename(abspath(path.module))
  networking_vars     = local.global_settings.networking
  aws_base_vars       = local.global_settings.terraform.aws_base
}


module "aws-key-pairs" {
  source                    = "./aws_key_pairs"
  ovpn_ssh_key_name = local.aws_base_vars.openvpn_key_name
  ovpn_ssh_public_key_file = local.aws_base_vars.openvpn_public_key_file
  kops_ssh_key_name = local.aws_base_vars.kops_key_name
  kops_ssh_public_key_file = local.aws_base_vars.kops_public_key_file
  aws_region                = local.global_settings.aws_region
}

module "networking" {
  source                    = "./networking"
  aws_region                = local.global_settings.aws_region
  project_name              = local.global_settings.project_name
  environment               = local.global_settings.environment
  vpc_cidr                  = local.networking_vars.vpc_cidr
  public_subnets_cidr       = local.networking_vars.public_subnet_cidr
  private_subnets_cidr      = local.networking_vars.private_subnet_cidr
  open_vpn_static_route_ip  = local.networking_vars.open_vpn_static_route_ip
  ovpn_ssh_key_name         = local.aws_base_vars.openvpn_key_name
  ovpn_ssh_private_key_file = local.aws_base_vars.openvpn_private_key_file
  ovpn_config_directory     = local.aws_base_vars.openvpn_config_directory
  ovpn_users                = local.aws_base_vars.openvpn_configs.users
  instance_type             = local.aws_base_vars.openvpn_configs.instance_type
}


module "efs" {
  source               = "./efs"
  aws_region           = local.global_settings.aws_region
  vpc_id               = module.networking.vpc_id
  private_subnet_ids   = module.networking.private_subnet_ids
  private_subnet_cidrs = module.networking.private_subnet_cidrs
  environment          = local.global_settings.environment
  app_name             = local.aws_base_vars.app_name

}


module "postgres_rds" {

  source               = "./postgres_rds"
  aws_region           = local.global_settings.aws_region
  vpc_id               = module.networking.vpc_id
  cidr_block           = module.networking.vpc_cidr_block
  private_subnet_ids   = module.networking.private_subnet_ids
  private_subnet_cidrs = module.networking.private_subnet_cidrs
  environment          = local.global_settings.environment
  project_name         = local.global_settings.project_name
  app_name             = local.aws_base_vars.app_name
  database_user        = local.aws_base_vars.database_user
  instance_type        = local.global_settings.postgres_rds.instance_type

}


module "kubernetes_iam" {
  source                   = "./kubernetes"
  aws_region               = local.global_settings.aws_region
  efs_arn                  = module.efs.efs_arn
  aws_efs_access_point_arn = module.efs.efs_access_point_arn
}

data "aws_caller_identity" "current" {}


module "outputs" {
  source                      = "./outputs"
  vpc_id                      = module.networking.vpc_id
  vpc_cidr_block              = module.networking.vpc_cidr_block
  private_subnet_ids          = module.networking.private_subnet_ids
  private_subnet_cidrs        = module.networking.private_subnet_cidrs
  public_subnet_ids           = module.networking.public_subnet_ids
  public_subnet_cidrs         = module.networking.public_subnet_cidrs
  nat_gateway_id              = module.networking.nat_gateway_id
  vpc_name                    = module.networking.vpc_name
  availability_zone_private   = module.networking.availability_zone_private
  availability_zone_public    = module.networking.availability_zone_public
  iam_policy_arns             = module.kubernetes_iam.iam_policy_arns
  rds_instance_hostname       = module.postgres_rds.rds_instance_hostname
  efs_id                      = module.efs.efs_id
  efs_arn                     = module.efs.efs_arn
  efs_access_point_arn        = module.efs.efs_access_point_arn
  rds_username                = module.postgres_rds.rds_username
  aws_account_id              = data.aws_caller_identity.current.account_id
  kops_ssh_key_name           = module.aws-key-pairs.kops_ssh_key_name
}


