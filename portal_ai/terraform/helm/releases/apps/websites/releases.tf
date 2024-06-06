

resource "helm_release" "websites" {
  for_each = { for chart, values in var.release_charts : chart => values }

  name       = each.key
  namespace  = each.value.namespace
  repository = "${var.helm_chart_path}/local_custom/apps"
  chart      = "websites"

  values = [
    file("${var.helm_chart_path}/local_custom/apps/websites/sub_charts/${each.key}/values.yaml")
  ]

  set {
    name = "replicas"
    value = "1"
  }
  wait         = true
  reset_values = true
}

