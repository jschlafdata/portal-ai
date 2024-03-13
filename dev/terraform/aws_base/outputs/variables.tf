variable "vpc_id" {}
variable "vpc_cidr_block" {}
variable "public_subnet_ids" {}
variable "private_subnet_ids" {}
variable "public_subnet_cidrs" {}
variable "private_subnet_cidrs" {}
variable "nat_gateway_id" {}
variable "vpc_name" {}
variable "availability_zone_private" {}
variable "availability_zone_public" {}
variable "iam_policy_arns" {}
variable "rds_instance_hostname" {}
variable "efs_id" {}
variable "rds_username" { }
variable "aws_account_id" {}
variable "efs_arn" {}
variable "efs_access_point_arn" {}
variable "kops_ssh_key_name" {}