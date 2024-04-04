variable "aws_region" {
}

variable "environment" {
  description = "Deployment Environment"
}

variable "project_name" {}

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

variable "instance_type" {}

variable "ovpn_ssh_key_name" {
  # Generate via 'ssh-keygen -f openvpn -t rsa'
  description = "The private SSH key used to connect to the EC2 instance"
  sensitive = true
}

variable "ovpn_ssh_private_key_file" {
  # Generate via 'ssh-keygen -f openvpn -t rsa'
  description = "The private SSH key used to connect to the EC2 instance"
  sensitive = true
}

variable "ovpn_users" {
}

variable "ovpn_config_directory" {
  description = "The name of the directory to eventually download the OVPN configuration files to"
}

variable "open_vpn_static_route_ip" {
  type = string
}