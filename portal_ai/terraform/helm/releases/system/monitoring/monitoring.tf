locals {
  module_namespace = "monitoring"
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

  dynamic "set" {
    for_each = var.kube_state_metrics_requests
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
    for_each = var.kube_state_metrics_requests
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

  dynamic "set" {
    for_each = var.prometheus_requests
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

  dynamic "set" {
    for_each = var.grafana_requests
    content {
      name  = set.key
      value = set.value
    }
  }

  wait          = true
  reset_values  = true

  depends_on = [ kubernetes_manifest.service_monitor_crd ]

}

resource "helm_release" "k8s-dashboard" {

  count      = var.release_configs["external.apps.k8s-dashboard"] ? 1 : 0

  name       = "k8s-dashboard"
  namespace  = "default"
  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "kubernetes-dashboard"
  version    = "7.1.2"
  values = [
    "${file("${var.helm_chart_path}/monitoring/sub_charts/k8s-dashboard/values.yaml")}"
  ]

  wait          = true
  reset_values  = true

}


resource "kubernetes_cluster_role" "k8s_dashboard_clusterrole" {

  count      = var.release_configs["external.apps.k8s-dashboard"] ? 1 : 0

  metadata {
    name = "k8s-dashboard-clusterrole"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  depends_on = [ helm_release.k8s-dashboard ]

}

resource "kubernetes_cluster_role_binding" "k8s_dashboard_clusterrolebinding" {

  count      = var.release_configs["external.apps.k8s-dashboard"] ? 1 : 0

  metadata {
    name = "k8s-dashboard-clusterrolebinding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.k8s_dashboard_clusterrole[count.index].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "k8s-dashboard-kubernetes-dashboard-web"
    namespace = "default"
  }

  depends_on = [ helm_release.k8s-dashboard ]

}




# kub delete secret vault-token
# kub delete pvc data-vault-0


# data "external" "validate_gafana_endpoint" {
#   program = ["sh", "-c", "cd ../../../ && poetry run python -m portal_ai.terraform.helm.scripts.endpoint_test grafana"]

#   depends_on = [ helm_release.grafana ]
# }

# data "external" "validate_prometheus_endpoint" {
#   program = ["sh", "-c", "cd ../../../ && poetry run python -m portal_ai.terraform.helm.scripts.endpoint_test prometheus"]

#   depends_on = [ helm_release.prometheus ]
# }

# resource "time_sleep" "post_endpoint_validation" {
#   create_duration = "5s"
#   depends_on = [
#     data.external.validate_prometheus_endpoint,
#     helm_release.grafana,
#     helm_release.prometheus,
#     data.external.validate_gafana_endpoint
#   ]
# }


# resource "helm_release" "kubelet-monitor" {

#   name       = "kubelet-monitor"
#   namespace  = "default"
#   repository = "${var.helm_chart_path}"
#   chart      = "monitoring"

#   values = [
#     "${file("${var.helm_chart_path}/monitoring/kubelet.values.yaml")}"
#   ]

#   wait          = true
#   reset_values  = true

# }
