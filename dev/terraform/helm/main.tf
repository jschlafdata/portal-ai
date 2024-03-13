locals {
  helm_chart_dir =  "${path.module}/../../k8s/helm/charts"
  script_dir =  "${path.module}/../../../tools/scripts/helm"
  
  release_configs = yamldecode(file("${path.module}/configs/release_configs.yml"))
  website_apps_configs = local.release_configs.aplications.websites.charts
}


module "system-base-helm-releases" {

    source          = "./releases/system"
    helm_chart_path = local.helm_chart_dir
    script_dir      = local.script_dir

}

module "monitoring-helm-releases" {

    source          = "./releases/system/monitoring"
    helm_chart_path = local.helm_chart_dir
    script_dir      = local.script_dir

    depends_on = [ module.system-base-helm-releases ]

}

module "website-apps-helm-releases" {

    source                  = "./releases/apps/websites"
    helm_chart_path         = local.helm_chart_dir
    doc_sub_charts          = local.website_apps_configs.docs

    depends_on = [ module.system-base-helm-releases ]

}

module "mageai-helm-releases" {

    source                  = "./releases/apps/mageai"
    helm_chart_path         = local.helm_chart_dir
    mageai_workspace_charts = local.website_apps_configs.mageai-workspaces

    depends_on = [ module.system-base-helm-releases ]

}


module "llm-endpoints-helm-releases" {

    source                  = "./releases/apps/llm_endpoints"
    helm_chart_path         = local.helm_chart_dir

    depends_on = [ module.system-base-helm-releases ]

}


module "llm-dev-spaces-helm-releases" {

    source                  = "./releases/apps/llm_dev_spaces"
    helm_chart_path         = local.helm_chart_dir

    depends_on = [ module.system-base-helm-releases ]

}

