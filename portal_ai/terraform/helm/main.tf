locals {
  helm_chart_dir =  "${path.module}/configs/charts"
  abs_helm_chart_dir = "portal_ai/terraform/helm/${path.module}/configs/charts"
  script_dir =  "${path.module}/scripts"
  
  release_configs = yamldecode(file("${path.module}/configs/deployment_vars.yaml"))
  release_settings = yamldecode(file("${path.module}/configs/deployment_settings.yml"))
}


module "system-base-helm-releases" {

    source          = "./releases/system"
    helm_chart_path = local.helm_chart_dir
    script_dir      = local.script_dir
    release_settings = local.release_settings
    release_configs = local.release_configs

}


# module "monitoring-helm-releases" {

#     source          = "./releases/system/monitoring"
#     helm_chart_path = local.helm_chart_dir
#     script_dir      = local.script_dir

#     depends_on = [ module.system-base-helm-releases ]

# }

# module "website-apps-helm-releases" {

#     source                  = "./releases/apps/websites"
#     helm_chart_path         = local.helm_chart_dir
#     doc_sub_charts          = local.website_apps_configs.docs

#     depends_on = [ module.system-base-helm-releases ]

# }

# module "mageai-helm-releases" {

#     source                  = "./releases/apps/mageai"
#     helm_chart_path         = local.helm_chart_dir
#     mageai_workspace_charts = local.website_apps_configs.mageai-workspaces

#     depends_on = [ module.system-base-helm-releases ]

# }


module "llm-endpoints-helm-releases" {

    count                   = local.release_configs["local_custom.apps.llm-models"] ? 1 : 0

    source                  = "./releases/apps/llm_endpoints"
    helm_chart_path         = local.helm_chart_dir
    abs_helm_chart_dir      = local.abs_helm_chart_dir
    script_dir              = local.script_dir
    release_settings        = local.release_settings
    release_configs         = local.release_configs

    depends_on = [ 
      module.system-base-helm-releases 
    ]

}


module "llm-dev-spaces-helm-releases" {

    count                   = local.release_configs["local_custom.apps.jupyter-lab-accelerated"] ? 1 : 0

    source                  = "./releases/apps/llm_dev_spaces"
    helm_chart_path         = local.helm_chart_dir
    abs_helm_chart_dir      = local.abs_helm_chart_dir
    
    script_dir              = local.script_dir
    release_settings        = local.release_settings
    release_configs         = local.release_configs

    depends_on = [ 
      module.system-base-helm-releases 
    ]

}
