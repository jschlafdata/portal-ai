
variable "aws_region" {
}

variable "app_name" {
  type        = string
  description = "Application Name"
}

variable "environment" {
  type        = string
  description = "Application Environment"
}

variable "vpc_id" {
}

variable "private_subnet_cidrs" {
  type    = list(string)
}

variable "private_subnet_ids" {
  type    = list(string)
}
