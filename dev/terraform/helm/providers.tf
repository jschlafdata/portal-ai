terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.27.0" # Specify a version that is compatible with your Terraform and Kubernetes versions
    }
  }
}


provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"  # Path to your Kubernetes config file
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}