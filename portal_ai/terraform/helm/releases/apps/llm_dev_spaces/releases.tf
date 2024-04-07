
data "external" "sub_chart_dirs" {
  program = ["sh", "-c", "cd ../../../ && poetry run python -m portal_ai.terraform.helm.scripts.list_sub_charts '${var.abs_helm_chart_dir}/local_custom/apps/jupyter-lab-accelerated/sub_charts'"]

}

locals {
  sub_chart_names = split("*", data.external.sub_chart_dirs.result.sub_chart_names)
}

resource "helm_release" "accelerated-jupyter" {

  for_each = { for idx, name in local.sub_chart_names : name => name }

  name       = "accelerated-jupyter-lab-${each.value}"
  namespace  = "default"
  repository = "${var.helm_chart_path}/local_custom/apps"
  chart      = "jupyter-lab-accelerated"

  values = [
    file("${var.helm_chart_path}/local_custom/apps/jupyter-lab-accelerated/sub_charts/${each.value}/values.yaml")
  ]
  set {
    name  = "replicas"
    value = "0"
  }

  wait         = true
  reset_values = true
}
