locals {
  module_namespace = "de"
}


resource "helm_release" "metabase" {

  count      = var.release_configs["external.apps.metabase"] ? 1 : 0
  name       = "metabase"
  namespace  = local.module_namespace
  repository = "https://pmint93.github.io/helm-charts"
  chart      = "metabase"
  version    = "2.12.0"
  
  values = [
    file("${var.helm_chart_path}/external/apps/metabase/values.yaml")
  ]
  set {
    name = "replicaCount"
    value = "0"
  }
  wait         = true
  reset_values = true
}