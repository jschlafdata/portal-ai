


resource "helm_release" "kube-state-metrics" {
  name       = "kube-state-metrics"
  namespace  = "default"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  version    = "5.16.4"

  values = [
    "${file("${var.helm_chart_path}/monitoring/sub_charts/kube-state-metrics/values.yaml")}"
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
  name       = "prometheus-node-exporter"
  namespace  = "default"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-node-exporter"
  version    = "4.31.0"

  values = [
    "${file("${var.helm_chart_path}/monitoring/sub_charts/prometheus-node-exporter/values.yaml")}"
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


resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = "default"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "25.17.0"

  values = [
    "${file("${var.helm_chart_path}/monitoring/sub_charts/prometheus/values.yaml")}"
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
  name       = "grafana"
  namespace  = "default"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "7.3.6"

  values = [
    "${file("${var.helm_chart_path}/monitoring/sub_charts/grafana/values.yaml")}"
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

}


resource "helm_release" "kubelet-monitor" {

  name       = "kubelet-monitor"
  namespace  = "default"
  repository = "${var.helm_chart_path}"
  chart      = "monitoring"

  values = [
    "${file("${var.helm_chart_path}/monitoring/kubelet.values.yaml")}"
  ]

  wait          = true
  reset_values  = true

}

resource "helm_release" "k8s-dashboard" {

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
  metadata {
    name = "k8s-dashboard-clusterrolebinding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.k8s_dashboard_clusterrole.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "k8s-dashboard-kubernetes-dashboard-web"
    namespace = "default"
  }

  depends_on = [ helm_release.k8s-dashboard ]

}
