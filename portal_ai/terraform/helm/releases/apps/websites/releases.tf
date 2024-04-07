
locals {
  module_namespace = "internal-apps"
}


resource "helm_release" "documentation-websites" {

  for_each = { for idx, name in var.release_charts : name => name }

  name       = each.key
  namespace  = local.module_namespace
  repository = "${var.helm_chart_path}/local_custom/apps"
  chart      = "websites"

  values = [
    file("${var.helm_chart_path}/local_custom/apps/websites/sub_charts/${each.key}/values.yaml")
  ]

  wait         = true
  reset_values = true
}
