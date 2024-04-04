output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
  description = "The CIDR block of the VPC"
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private_subnet : subnet.id]
  description = "List of IDs of private subnets"
}

output "private_subnet_cidrs" {
  value = [for subnet in aws_subnet.private_subnet : subnet.cidr_block]
  description = "List of CIDR blocks of private subnets"
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public_subnet : subnet.id]
  description = "List of IDs of public subnets"
}

output "public_subnet_cidrs" {
  value = [for subnet in aws_subnet.public_subnet : subnet.cidr_block]
  description = "List of CIDR blocks of public subnets"
}

output "vpc_name" {
  value = "${var.prefix_portal}-${var.environment}-vpc"
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
}

output "availability_zone_private" {
  value = [for subnet in aws_subnet.private_subnet : subnet.availability_zone]
}

output "availability_zone_public" {
  value = [for subnet in aws_subnet.public_subnet : subnet.availability_zone]
}

output "openvpn_public_subnet" {
  value = aws_subnet.public_subnet[1].id
}

output "private_subnets_id" {
  value = aws_subnet.private_subnet
}

output "default_sg_id" {
  value = aws_security_group.default.id
}

output "security_groups_ids" {
  value = ["${aws_security_group.default.id}"]
}

output "public_route_table" {
  value = aws_route_table.public.id
}


output "internet_gateway_id" {
  value = aws_internet_gateway.ig.id
}

output "vpn_gateway_id" {
  value = aws_vpn_gateway.vpn_gw.id
}

output "private_route_tables" {
  value = aws_route_table.private
}
