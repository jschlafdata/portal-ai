# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.prefix_portal}-${var.environment}-vpc"
    Environment = var.environment
  }
}

data "aws_availability_zones" "available" {}


# Subnets
# Internet Gateway for Public Subnet
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.prefix_portal}-${var.environment}-igw"
    Environment = var.environment
  }
}


resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix_portal}-${var.environment}-vpg"
  }
}

# Elastic-IP (eip) for NAT
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.ig]
}

# Public subnets
resource "aws_subnet" "public_subnet" {
  for_each = { for idx, az in data.aws_availability_zones.available.names : idx => az }

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.public_subnets_cidr, 3, each.key)
  availability_zone       = each.value
  map_public_ip_on_launch = true

  tags = {
    Name             = "${var.environment}-${each.value}-public-subnet"
    Endpoint         = "public"
    Environment      = var.environment
    vpc_name         = "${var.prefix_portal}-${var.environment}-vpc"
  }

  lifecycle {
    ignore_changes = [
      tags, # Ignore any changes to the tags attribute
      tags_all, # Ignore any changes to the tags_all attribute
    ]
  }
}

# Private subnets
resource "aws_subnet" "private_subnet" {
  for_each = { for idx, az in data.aws_availability_zones.available.names : idx => az }

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.private_subnets_cidr, 3, each.key)
  availability_zone       = each.value
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}-${each.value}-private-subnet"
    Endpoint    = "private"
    Environment = var.environment
    vpc_name    = "${var.prefix_portal}-${var.environment}-vpc"
  }

  lifecycle {
    ignore_changes = [
      tags, # Ignore any changes to the tags attribute
      tags_all, # Ignore any changes to the tags_all attribute
    ]
  }
}

# NAT
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id

  # You can specify the index of the public subnet you want to use for the NAT gateway here
  subnet_id = aws_subnet.public_subnet[0].id  # Use the first public subnet

  tags = {
    Name        = "${var.prefix_portal}-${var.environment}-nat"
    Environment = var.environment
  }
}

# Routing tables to route traffic for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = "${var.environment}"
  }
}


# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

# Route table associations for Public Subnets
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Route tables for Private Subnets
resource "aws_route_table" "private" {
  for_each = aws_subnet.private_subnet

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${each.value.tags.Name}-private-route-table"
    Environment = var.environment
  }
}


# Route for NAT
resource "aws_route" "private_nat_gateway" {
  for_each = aws_route_table.private
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Create a map for private route table IDs
locals {
  private_route_tables = {
    for idx, subnet in aws_subnet.private_subnet :
    idx => aws_route_table.private[idx].id
  }
}

# Route table associations for Private Subnets
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private_subnet

  subnet_id      = each.value.id
  route_table_id = local.private_route_tables[each.key]
}


# Default Security Group of VPC
resource "aws_security_group" "default" {
  name        = "${var.environment}-default-sg"
  description = "Default SG to alllow traffic from the VPC"
  vpc_id      = aws_vpc.vpc.id
  depends_on = [
    aws_vpc.vpc
  ]

    ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }

  tags = {
    Environment = "${var.environment}"
  }
}