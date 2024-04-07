
data "external" "llm_endpoints" {
  program = ["sh", "-c", "cd ../../../ && poetry run python -m portal_ai.terraform.helm.scripts.list_sub_charts '${var.abs_helm_chart_dir}/local_custom/apps/llm-models/sub_charts'"]
}

data "external" "llm_devs" {
  program =  ["sh", "-c", "cd ../../../ && poetry run python -m portal_ai.terraform.helm.scripts.list_sub_charts '${var.abs_helm_chart_dir}/local_custom/apps/jupyter-lab-accelerated/sub_charts'"]
}

data "external" "mageai-workspaces" {
  program =  ["sh", "-c", "cd ../../../ && poetry run python -m portal_ai.terraform.helm.scripts.list_sub_charts '${var.abs_helm_chart_dir}/local_custom/apps/mageai-workspaces/sub_charts'"]
}

data "external" "websites" {
  program =  ["sh", "-c", "cd ../../../ && poetry run python -m portal_ai.terraform.helm.scripts.list_sub_charts '${var.abs_helm_chart_dir}/local_custom/apps/websites/sub_charts'"]
}



locals {
  llm_endpoint_subchart_names = split("*", data.external.llm_endpoints.result.sub_chart_names)
  llm_dev_subchart_names = split("*", data.external.llm_devs.result.sub_chart_names)
  mageai_subchart_names = split("*", data.external.mageai-workspaces.result.sub_chart_names)
  website_subchart_names = split("*", data.external.websites.result.sub_chart_names)
}

output "subchart_names" {
  value = {
    "llm_endpoints" = local.llm_endpoint_subchart_names
    "llm_devs" = local.llm_dev_subchart_names
    "mageai-workspaces" = local.mageai_subchart_names
    "websites" = local.website_subchart_names
  }
}

