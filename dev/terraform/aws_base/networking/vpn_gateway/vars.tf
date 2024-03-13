variable "environment" {
  description = "Deployment Environment"
}

variable "vpc_cidr" {
  description = "CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = string
  description = "CIDR block for Public Subnet"
}

variable "private_subnets_cidr" {
  type        = string
  description = "CIDR block for Private Subnet"
}

variable "open_vpn_external_ip" {
  type = string
}

variable "open_vpn_static_route_ip" {
  type = string
}

variable "aws_region" {}

variable "prefix_portal" {}

variable "vpn_gateway_id" {}

variable "private_route_tables" {}