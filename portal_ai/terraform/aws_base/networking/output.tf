output "vpc_id" {
  value = module.Networking.vpc_id
}

output "vpc_cidr_block" {
  value = module.Networking.vpc_cidr_block
  description = "The CIDR block of the VPC"
}

output "private_subnet_ids" {
  value = module.Networking.private_subnet_ids
  description = "List of IDs of private subnets"
}

output "private_subnet_cidrs" {
  value = module.Networking.private_subnet_cidrs
  description = "List of CIDR blocks of private subnets"
}

output "public_subnet_ids" {
  value = module.Networking.public_subnet_ids
  description = "List of IDs of public subnets"
}

output "public_subnet_cidrs" {
  value = module.Networking.public_subnet_cidrs
  description = "List of CIDR blocks of public subnets"
}


output "nat_gateway_id" {
  value = module.Networking.nat_gateway_id
}

output "vpc_name" {
  value = module.Networking.vpc_name
}

output "availability_zone_private" {
  value = module.Networking.availability_zone_private
}

output "availability_zone_public" {
  value = module.Networking.availability_zone_public
}
