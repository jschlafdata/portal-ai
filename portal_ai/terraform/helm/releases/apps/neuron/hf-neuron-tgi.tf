
locals {
  module_namespace = "gpu"

  inf2_charts   = ["mistral-8xl", "mistral-xl"]
}


resource "helm_release" "hf-neuronx-tgi" {

  for_each   = toset(local.inf2_charts)
  name       = "hf-neuronx-tgi-${each.value}"
  namespace  = local.module_namespace
  repository = "${var.helm_chart_path}/local_custom/apps"
  chart      = "hf-neuron-tgi"

  values = [
    file("${var.helm_chart_path}/local_custom/apps/hf-neuron-tgi/sub_charts/${each.value}/values.yaml")
  ]
  set {
    name  = "release_suffix"
    value = each.value
  }
  set {
    name  = "replicas"
    value = "0"
  }
  wait         = true
  reset_values = true
}
