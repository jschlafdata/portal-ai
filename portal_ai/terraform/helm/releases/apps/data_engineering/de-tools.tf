locals {
  module_namespace = "de"
  mageai_workspaces_releases = var.release_configs["local_custom.apps.mageai-workspaces"] ? var.release_charts.mageai-workspaces.sub_charts : []
  jupyter_workspaces_releases = var.release_configs["local_custom.apps.jupyter-lab-memory-base"] ? var.release_charts.jupyter-memory-workspaces.sub_charts : []
}


resource "helm_release" "mageai" {

  count      = var.release_configs["external.apps.mageai"] ? 1 : 0
  name       = "mageai"
  namespace  = local.module_namespace
  repository = "https://mage-ai.github.io/helm-charts"
  chart      = "mageai"
  version    = "0.2.1"

  values = [
    file("${var.helm_chart_path}/external/apps/mageai/values.yaml")
  ]
  set {
    name = "replicaCount"
    value = "0"
  }
  wait         = true
  reset_values = true
}


resource "helm_release" "mage-workspaces" {

  for_each   = { for idx, name in local.mageai_workspaces_releases : name => name }
  name       = each.value
  namespace  = local.module_namespace
  repository = "${var.helm_chart_path}/local_custom/apps"
  chart      = "mageai-workspaces"

  values = [
    file("${var.helm_chart_path}/local_custom/apps/mageai-workspaces/sub_charts/${each.value}/values.yaml")
  ]

  wait         = true
  reset_values = true
}


resource "helm_release" "jupyter-memory-base" {
  count       = length(local.jupyter_workspaces_releases)
  name        = "jupyter-${local.jupyter_workspaces_releases[count.index]}"
  namespace   = local.module_namespace
  repository  = "${var.helm_chart_path}/local_custom/apps"
  chart       = "jupyter-lab-memory-base"

  values = [
    file("${var.helm_chart_path}/local_custom/apps/jupyter-lab-memory-base/sub_charts/${local.jupyter_workspaces_releases[count.index]}/values.yaml")
  ]

  set {
    name  = "replicas"
    value = "0"
  }
  set {
    name  = "createServiceAccount"
    value = count.index == 0 ? "true" : "false"
  }
  set {
    name  = "pvc.createPVC"
    value = count.index == 0 ? "true" : "false"
  }

  wait         = true
  reset_values = true
}


resource "helm_release" "medusa" {

  name       = "medusa"
  namespace  = local.module_namespace
  repository = "${var.helm_chart_path}/local_custom/apps"
  chart      = "medusa"

  values = [
    file("${var.helm_chart_path}/local_custom/apps/medusa/values.yaml")
  ]

  set {
    name  = "deployment.replicas"
    value = "0"
  }
  wait         = true
  reset_values = true
}


