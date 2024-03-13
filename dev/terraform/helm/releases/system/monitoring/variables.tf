
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

variable "tls_secret_name" {
  type = string 
  default = "wildcard-tls-cert-schlafdata-cloud"
}


variable "vault_url" {
  description = "The URL of the website to ping"
  type        = string
  default     = "https://vault.schlafdata.cloud" // Change this to your default URL or remove the default value to make it mandatory
}