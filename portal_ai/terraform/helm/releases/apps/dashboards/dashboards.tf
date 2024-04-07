


resource "helm_release" "metabase" {

  name       = "metabase"
  namespace  = "default"
  repository = "https://pmint93.github.io/helm-charts"
  chart      = "metabase"
  version    = "2.12.0"
  values = [
    file("${var.helm_chart_path}/external/appsmetabase/values.yaml")
  ]

  wait         = true
  reset_values = true
}
