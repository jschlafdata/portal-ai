
locals {
  docs_map = { for doc in var.doc_sub_charts : doc.sub_chart => doc }
}


resource "helm_release" "documentation-websites" {
  for_each   = local.docs_map
  name       = each.key
  namespace  = "default"
  repository = var.helm_chart_path
  chart      = "docs"

  values = [
    file("${var.helm_chart_path}/docs/sub_charts/${each.key}/values.yaml")
  ]

  wait         = true
  reset_values = true
}



resource "helm_release" "metabase" {

  name       = "metabase"
  namespace  = "default"
  repository = "https://pmint93.github.io/helm-charts"
  chart      = "metabase"
  version    = "2.12.0"
  values = [
    file("${var.helm_chart_path}/metabase/values.yaml")
  ]

  wait         = true
  reset_values = true
}
