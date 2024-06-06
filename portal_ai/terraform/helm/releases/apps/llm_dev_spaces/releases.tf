locals {
  module_namespace = "gpu"
  jupyter_accelerated_releases = var.release_configs["local_custom.apps.jupyter-lab-accelerated"] ? var.release_charts.jupyter-lab-accelerated.sub_charts : []
}

resource "helm_release" "accelerated-jupyter" {

  for_each = toset(local.jupyter_accelerated_releases)

  name       = "jupyter-${each.value}"
  namespace  = local.module_namespace
  repository = "${var.helm_chart_path}/local_custom/apps"
  chart      = "jupyter-lab-accelerated"
 
  values = [
    file("${var.helm_chart_path}/local_custom/apps/jupyter-lab-accelerated/sub_charts/${each.value}/values.yaml")
  ]
  set {
    name  = "replicas"
    value = "0"
  }
  wait         = false
  reset_values = true
}


