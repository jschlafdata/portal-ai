locals {
  helm_chart_dir     = "${path.module}/configs/charts"
  abs_helm_chart_dir = "portal_ai/terraform/helm/${path.module}/configs/charts"
  script_dir         = "${path.module}/scripts"
  generated_dir      = "${path.module}/configs/generated"
  release_configs    = yamldecode(file("${path.module}/configs/generated/helm_deployment_settings.yml"))
  release_settings   = yamldecode(file("${path.module}/configs/generated/helm_values_base.yml"))
  project_settings   = yamldecode(file("${path.module}/configs/generated/kops_settings_base.yml"))
  custom_settings    = yamldecode(file("${path.module}/configs/static/custom_chart_settings.yml"))
}


module "system-base-helm-releases" {

  source           = "./releases/system"
  helm_chart_path  = local.helm_chart_dir
  script_dir       = local.script_dir
  release_settings = local.release_settings
  release_configs  = local.release_configs
  generated_dir    = local.generated_dir
  project_name     = local.project_settings.projectName

}


module "neuron-helm-releases" {

  count   = local.release_configs["local_custom.apps.hf-neuron-tgi"] ? 1 : 0
  source  = "./releases/apps/neuron"
  
  release_configs = local.release_configs
  helm_chart_path = local.helm_chart_dir
}


locals {
  de_enabled_apps = flatten([
    local.release_configs["external.apps.mageai"] ? ["external.apps.mageai"] : [],
    local.release_configs["local_custom.apps.mageai-workspaces"] ? ["local_custom.apps.mageai-workspaces"] : [],
    local.release_configs["local_custom.apps.jupyter-lab-base"] ? ["jupyter-lab-base"] : []
  ])
}


module "data-engineering-releases" {

  count  = length(local.de_enabled_apps) > 0 ? 1 : 0
  source = "./releases/apps/data_engineering"

  release_configs = local.release_configs
  helm_chart_path = local.helm_chart_dir
  release_charts = local.custom_settings.charts

  depends_on = [
    module.system-base-helm-releases
  ]
}


module "website-apps-helm-releases" {

  count = local.release_configs["local_custom.apps.websites"] ? 1 : 0

  source             = "./releases/apps/websites"
  helm_chart_path    = local.helm_chart_dir
  abs_helm_chart_dir = local.abs_helm_chart_dir
  release_settings   = local.release_settings
  release_configs    = local.release_configs

  release_charts = local.custom_settings.charts.websites.sub_charts

  depends_on = [
    module.system-base-helm-releases
  ]

}

locals {
  enabled_dashboards = flatten([
    local.release_configs["external.apps.metabase"] ? ["external.apps.metabase"] : [],
  ])
}


module "daashboard-releases" {

  count   = length(local.enabled_dashboards) > 0 ? 1 : 0
  source  = "./releases/apps/dashboards"

  helm_chart_path = local.helm_chart_dir
  release_configs = local.release_configs

  depends_on = [
    module.system-base-helm-releases
  ]
}


module "llm-dev-spaces-helm-releases" {

    count                   = local.release_configs["local_custom.apps.jupyter-lab-accelerated"] ? 1 : 0

    source                  = "./releases/apps/llm_dev_spaces"
    helm_chart_path         = local.helm_chart_dir
    release_charts          = local.custom_settings.charts
    release_configs         = local.release_configs
    
    depends_on = [ 
      module.system-base-helm-releases 
    ]
}


locals {
  enabled_llms = flatten([
    local.release_configs["local_custom.apps.ollama"] ? ["local_custom.apps.ollama"] : [],
    local.release_configs["local_custom.apps.llmsherpa"] ? ["local_custom.apps.llmsherpa"] : []
  ])
}


module "llm-endpoints-helm-releases" {

    count   = length(local.enabled_llms) > 0 ? 1 : 0
    source  = "./releases/apps/llm_endpoints"

    helm_chart_path  = local.helm_chart_dir
    release_configs  = local.release_configs

    depends_on = [ 
      module.system-base-helm-releases 
    ]
}

