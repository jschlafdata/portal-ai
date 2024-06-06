locals {
  module_namespace = "monitor"
  requests_settings = yamldecode(file("${path.module}/requests.yml"))
}

resource "kubernetes_manifest" "service_monitor_crd" {
  manifest = yamldecode(file("${var.helm_chart_path}/external/monitoring/servicemonitor/service_monitor_crd.yaml"))
}


resource "helm_release" "kube-state-metrics" {

  count      = var.release_configs["external.monitoring.kube-state-metrics"] ? 1 : 0

  name       = "kube-state-metrics"
  namespace  = local.module_namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  version    = "5.16.4"

  values = [
    "${file("${var.helm_chart_path}/external/monitoring/kube-state-metrics/values.yaml")}"
  ]

  set {
    name = "replicas"
    value = local.requests_settings.kube_state_metrics.replicas
  }

  dynamic "set" {
    for_each = local.requests_settings.kube_state_metrics.requests.memory
    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set" {
    for_each = local.requests_settings.kube_state_metrics.requests.cpu
    content {
      name  = set.key
      value = set.value
    }
  }

  wait          = true
  reset_values  = true
}

resource "helm_release" "prometheus-node-exporter" {

  count      = var.release_configs["external.monitoring.prometheus-node-exporter"] ? 1 : 0

  name       = "prometheus-node-exporter"
  namespace  = local.module_namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-node-exporter"
  version    = "4.31.0"

  values = [
    "${file("${var.helm_chart_path}/external/monitoring/prometheus-node-exporter/values.yaml")}"
  ]

  dynamic "set" {
    for_each = local.requests_settings.prometheus_node_exporter.requests.memory
    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set" {
    for_each = local.requests_settings.prometheus_node_exporter.requests.cpu
    content {
      name  = set.key
      value = set.value
    }
  }
  wait          = true
  reset_values  = true

  depends_on = [ kubernetes_manifest.service_monitor_crd ]

}


resource "helm_release" "prometheus" {

  count      = var.release_configs["external.monitoring.prometheus"] ? 1 : 0

  name       = "prometheus"
  namespace  = local.module_namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "25.17.0"

  values = [
    "${file("${var.helm_chart_path}/external/monitoring/prometheus/values.yaml")}"
  ]

  set {
    name = "replicaCount"
    value = local.requests_settings.prometheus.replicaCount
  }

  dynamic "set" {
    for_each = local.requests_settings.prometheus.requests.memory
    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set" {
    for_each = local.requests_settings.prometheus.requests.cpu
    content {
      name  = set.key
      value = set.value
    }
  }

  wait          = true
  reset_values  = true

}


resource "helm_release" "grafana" {

  count      = var.release_configs["external.monitoring.grafana"] ? 1 : 0

  name       = "grafana"
  namespace  = local.module_namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "7.3.6"

  values = [
    "${file("${var.helm_chart_path}/external/monitoring/grafana/values.yaml")}"
  ]
  set {
    name = "replicas"
    value = local.requests_settings.grafana.replicas
  }
  dynamic "set" {
    for_each = local.requests_settings.grafana.requests.memory
    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set" {
    for_each = local.requests_settings.grafana.requests.cpu
    content {
      name  = set.key
      value = set.value
    }
  }
  wait          = true
  reset_values  = true

  depends_on = [ kubernetes_manifest.service_monitor_crd ]

}


resource "helm_release" "headlamp" {

  count      = var.release_configs["external.monitoring.headlamp"] ? 1 : 0

  name       = "headlamp"
  namespace  = local.module_namespace
  repository = "${var.helm_chart_path}/external/monitoring"
  chart      = "headlamp"

  wait          = true
  reset_values  = true
  depends_on = [ kubernetes_manifest.service_monitor_crd ]

}


resource "helm_release" "headlamp_roles" {

  count      = var.release_configs["external.monitoring.headlamp"] ? 1 : 0

  name       = "headlamp-custom-roles"
  namespace  = local.module_namespace
  repository = "${var.helm_chart_path}/local_custom/apps"
  chart      = "headlamp_roles"

  wait          = true
  reset_values  = true
  depends_on = [ kubernetes_manifest.service_monitor_crd ]

}

