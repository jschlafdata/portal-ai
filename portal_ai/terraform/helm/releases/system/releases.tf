
locals {

  namespaces = [ 
      "default", 
      "mageai", 
      "monitoring",
      "internal-apps", 
      "external-apps", 
      "gpu-apps"
  ]

  service_accounts = yamldecode(file("${var.helm_chart_path}/local_custom/system/default-roles/values.yaml"))

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
  helm_chart_path = var.helm_chart_path
  script_dir      = var.script_dir
  release_settings = var.release_settings
  release_configs = var.release_configs
  generated_dir   = var.generated_dir
  awssm_role      = module.base-charts.awssm_role
  project_name    = var.project_name

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







# data "external" "validate_vault" {
#   program = ["sh", "-c", "cd ../../../ && poetry run python -m portal_ai.terraform.helm.scripts.validate_vault"]
#   depends_on = [ helm_release.vault ]
# }

# data "external" "initialize_unseal_vault" {
#   program = ["sh", "-c", "cd ../../../ && poetry run python -m portal_ai.terraform.helm.scripts.vault_init_unseal"]
#   depends_on = [ helm_release.vault,
#                  data.external.validate_vault ]
# }


# data "external" "validate_vault_endpoint" {
#   program = ["sh", "-c", "cd ../../../ && poetry run python -m portal_ai.terraform.helm.scripts.endpoint_test vault"]

#   depends_on = [ helm_release.vault,
#                  data.external.initialize_unseal_vault ]
# }


# resource "time_sleep" "post_vault_validation" {
#   create_duration = "30s"
#   depends_on = [
#     data.external.validate_vault_endpoint,
#     helm_release.vault,
#     data.external.initialize_unseal_vault
#   ]
# }


# resource "null_resource" "create_vault_policies" {

#   depends_on = [
#     helm_release.vault,
#     data.external.validate_vault_endpoint,
#     time_sleep.post_vault_validation
#   ]

#   provisioner "local-exec" {
#     command = "sh -c 'cd ../../../ && poetry run python -m portal_ai.terraform.helm.scripts.init_secret_backends'"
#   }
# }


# resource "time_sleep" "wait_for_some_token_to_percolate" {
#   # Specifies the duration of the sleep, in RFC 3339 duration format.
#   # For example, "10m" waits for 10 minutes, "30s" for 30 seconds.
#   create_duration = "15s"
#   depends_on = [ null_resource.create_vault_policies ]

# }


  # depends_on = [ 
  #   time_sleep.wait_for_some_token_to_percolate
  # ]

