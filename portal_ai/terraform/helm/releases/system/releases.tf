
locals {

  namespaces = [ 
      "default", 
      "monitor",
      "ext", 
      "web",
      "gpu",
      "de"
  ]

  service_accounts = yamldecode(file("${var.helm_chart_path}/local_custom/system/default-roles/values.yaml"))
  service_accounts_list = [for sa in local.service_accounts["serviceAccounts"] : sa.serviceAccountName]

}


module "base-charts" {

  source = "./base"
  helm_chart_path = var.helm_chart_path
  script_dir      = var.script_dir
  release_settings = var.release_settings
  release_configs = var.release_configs
  generated_dir   = var.generated_dir

}


module "deploy" {

  source = "./deploy"

  helm_chart_path  = var.helm_chart_path
  script_dir       = var.script_dir
  release_settings = var.release_settings
  release_configs  = var.release_configs
  generated_dir    = var.generated_dir
  awssm_role       = module.base-charts.awssm_role
  project_name     = var.project_name

  depends_on = [ module.base-charts ]

}


module "monitoring" {

  source = "./monitoring"
  helm_chart_path = var.helm_chart_path
  script_dir      = var.script_dir
  release_settings = var.release_settings
  release_configs = var.release_configs

  depends_on = [ module.deploy ]

}

