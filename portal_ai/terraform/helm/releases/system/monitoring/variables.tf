
variable "helm_chart_path" {
    type = string
}

variable "script_dir" {
  type = string
}

variable "environment" {
    type = string
    default = "dev"
}

variable "release_settings" {}
variable "release_configs" {}

