resource "local_file" "json_output" {
  filename = "./generated/module_outputs.json"
  content = jsonencode({
    vpc_id                     = var.vpc_id
    vpc_cidr_block             = var.vpc_cidr_block
    private_subnet_ids         = var.private_subnet_ids
    private_subnet_cidrs       = var.private_subnet_cidrs
    public_subnet_ids          = var.public_subnet_ids
    public_subnet_cidrs        = var.public_subnet_cidrs
    nat_gateway_id             = var.nat_gateway_id
    vpc_name                   = var.vpc_name
    availability_zone_private  = var.availability_zone_private
    availability_zone_public   = var.availability_zone_public
    iam_policy_arns            = var.iam_policy_arns
    rds_instance_hostname      = var.rds_instance_hostname
    efs_id                     = var.efs_id
    efs_arn                    = var.efs_arn
    efs_access_point_arn       = var.efs_access_point_arn
    rds_username               = var.rds_username
    aws_account_id             = var.aws_account_id
    kops_ssh_key_name          = var.kops_ssh_key_name
  })
}