
locals {
    module_namespace = "gpu"
    ollamas = ["coder-xl","dolphin-mixtral","standard-2xl"]
}


locals {
  ollama_enabled_endpoints = var.release_configs["local_custom.apps.ollama"] ? local.ollamas : []
}


resource "helm_release" "llmsherpa" {

  count      = var.release_configs["local_custom.apps.llmsherpa"] ? 1 : 0

  name       = "llmsherpa"
  namespace  = local.module_namespace
  repository = "${var.helm_chart_path}/local_custom/apps"
  chart      = "llmsherpa"

  values = [
    file("${var.helm_chart_path}/local_custom/apps/llmsherpa/values.yaml")
  ]

  set {
    name  = "replicas"
    value = "0"
  }
  wait         = true
  reset_values = true
}


resource "helm_release" "ollama" {
  for_each   = toset(local.ollama_enabled_endpoints)
  name       = each.value
  namespace  = local.module_namespace
  repository = "https://otwld.github.io/ollama-helm"
  chart      = "ollama"

  values = [
    file("${var.helm_chart_path}/local_custom/apps/ollama/sub_charts/${each.value}/values.yaml")
  ]

  set {
    name  = "replicaCount"
    value = 0
  }
  wait         = true
  reset_values = true
}

