variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "app_name" {
  type        = string
  description = "Application Name"
}

variable "environment" {
  type        = string
  description = "Application Environment"
}

variable "database_user" {
  type = string
}

variable "cidr_block" {
}

variable "vpc_id" {
}

variable "private_subnet_cidrs" {
  type    = list(string)
}

variable "private_subnet_ids" {
  type    = list(string)
}
