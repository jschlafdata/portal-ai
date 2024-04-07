locals {
  helm_chart_dir =  "${path.module}/configs/charts"
  abs_helm_chart_dir = "portal_ai/terraform/helm/${path.module}/configs/charts"
  script_dir =  "${path.module}/scripts"
  generated_dir =  "${path.module}/configs/generated"
  release_configs = yamldecode(file("${path.module}/configs/generated/helm_deployment_settings.yml"))
  release_settings = yamldecode(file("${path.module}/configs/generated/helm_values_base.yml"))
  project_settings = yamldecode(file("${path.module}/configs/generated/kops_settings_base.yml"))

}


module "system-base-helm-releases" {

    source          = "./releases/system"
    helm_chart_path = local.helm_chart_dir
    script_dir      = local.script_dir
    release_settings = local.release_settings
    release_configs = local.release_configs
    generated_dir   = local.generated_dir
    project_name    = local.project_settings.projectName

}

module "get-settings" {
    source     = "./releases/apps/get_settings"
    abs_helm_chart_dir      = local.abs_helm_chart_dir
    depends_on = [ module.system-base-helm-releases ]
}

# module "website-apps-helm-releases" {

#     count                   = local.release_configs["local_custom.apps.websites"] ? 1 : 0

#     source                  = "./releases/apps/websites"
#     helm_chart_path         = local.helm_chart_dir
#     abs_helm_chart_dir      = local.abs_helm_chart_dir
#     release_settings        = local.release_settings
#     release_configs         = local.release_configs

    # release_charts          = module.get-settings.subchart_names.websites

#     depends_on = [ 
#         module.system-base-helm-releases,
#         module.get-settings
#     ]

# }



module "mageai-helm-releases" {

    source                  = "./releases/apps/mageai"
    helm_chart_path         = local.helm_chart_dir
    abs_helm_chart_dir      = local.abs_helm_chart_dir
    script_dir              = local.script_dir
    release_settings        = local.release_settings
    release_configs         = local.release_configs

    release_charts          = module.get-settings.subchart_names.mageai-workspaces

    depends_on = [ module.system-base-helm-releases ]

}


# module "llm-endpoints-helm-releases" {

#     count                   = local.release_configs["local_custom.apps.llm-models"] ? 1 : 0

#     source                  = "./releases/apps/llm_endpoints"
#     helm_chart_path         = local.helm_chart_dir
#     abs_helm_chart_dir      = local.abs_helm_chart_dir
#     script_dir              = local.script_dir
#     release_settings        = local.release_settings
#     release_configs         = local.release_configs

#     depends_on = [ 
#       module.system-base-helm-releases 
#     ]

# }


# module "llm-dev-spaces-helm-releases" {

#     count                   = local.release_configs["local_custom.apps.jupyter-lab-accelerated"] ? 1 : 0

#     source                  = "./releases/apps/llm_dev_spaces"
#     helm_chart_path         = local.helm_chart_dir
#     abs_helm_chart_dir      = local.abs_helm_chart_dir
    
#     script_dir              = local.script_dir
#     release_settings        = local.release_settings
#     release_configs         = local.release_configs

#     depends_on = [ 
#       module.system-base-helm-releases 
#     ]

# }
