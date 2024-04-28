
locals {

  namespaces = [ 
      "default", 
      "mageai", 
      "monitoring",
      "internal-apps", 
      "external-apps", 
      "gpu-apps"
  ]

  service_accounts = yamldecode(file("${var.helm_chart_path}/local_custom/system/default-roles/values.yaml"))
  module_namespace = "default"

}

resource "kubernetes_namespace" "namespaces" {
  for_each = toset([for ns in local.namespaces: ns if ns != "default"])
  metadata {
    name = each.value
  }
}


resource "helm_release" "default-roles" {

  name       = "default-roles"
  namespace  = local.module_namespace
  repository = "${var.helm_chart_path}/local_custom/system"
  chart      = "default-roles"
  version    = "0.3.0"

  values = [
    "${file("${var.helm_chart_path}/local_custom/system/default-roles/values.yaml")}"
  ]

  wait = true

}


data "kubernetes_service_account" "default-roles" {

  for_each    = toset(local.service_accounts.serviceAccounts)

  metadata {
    name      = each.value
    namespace = local.module_namespace
  }

  depends_on = [ helm_release.default-roles ]

}


resource "helm_release" "wildcard-certificate" {

  name       = "wildcard-certificate"
  namespace  = local.module_namespace
  repository = "${var.helm_chart_path}/local_custom/system"
  chart      = "wildcard-certificate"
  version    = "0.3.0"

  values = [
    "${file("${var.helm_chart_path}/local_custom/system/wildcard-certificate/values.yaml")}"
  ]

  set {
    name  = "jobRole"
    value = data.kubernetes_service_account.default-roles["awssm"].metadata[0].name
  }

  wait          = true
  reset_values  = true
  wait_for_jobs = true
  timeout       = 600

}



resource "helm_release" "aws-efs-csi-driver" {
  name       = "aws-efs-csi-driver"
  namespace  = local.module_namespace
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart      = "aws-efs-csi-driver"
  version    = "2.5.6"

  values = [
    "${file("${var.helm_chart_path}/external/system/efs-csi/values.yaml")}"
  ]

  dynamic "set" {
    for_each = var.efs_csi_requests
    content {
      name  = set.key
      value = set.value
    }
  }

  wait          = true
  reset_values  = true

}


resource "kubernetes_storage_class" "vault_sc" {

  metadata {
    name = "vault-sc"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  parameters = {
    type   = "gp2"
    fsType = "ext4"
  }
  reclaim_policy        = "Retain"
  allow_volume_expansion = true

}


resource "helm_release" "vault" {
  name       = "vault"
  namespace  = local.module_namespace
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.27.0"

  values = [
    "${file("${var.helm_chart_path}/external/system/vault/values.yaml")}"
  ]

  dynamic "set" {
    for_each = var.vault_requests
    content {
      name  = set.key
      value = set.value
    }
  }

  wait          = true
  reset_values  = true

  depends_on = [ kubernetes_storage_class.vault_sc ]

}


resource "helm_release" "reflector" {

  name       = "reflector"
  namespace  = local.module_namespace
  repository = "https://emberstack.github.io/helm-charts"
  chart      = "reflector"  
  wait       = true

}

resource "kubernetes_persistent_volume_claim" "efs_claim" {
  for_each = toset(local.namespaces)

  metadata {
    name      = "efs-${each.key}-claim"
    namespace = each.key
  }

  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = "efs-dynamic-sc"

    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
  depends_on = [ 
      helm_release.aws-efs-csi-driver,
      kubernetes_namespace.namespaces
  ]
}

resource "helm_release" "external-dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = "6.36.1"

  values = [
    "${file("${var.helm_chart_path}/external/system/external-dns/values.yaml")}"
  ]

  dynamic "set" {
    for_each = var.external_dns_requests
    content {
      name  = set.key
      value = set.value
    }
  }

  reset_values  = true
  wait          = true

}


resource "helm_release" "nginx-internal" {

  count      = var.release_configs["external.system.nginx-internal"] ? 1 : 0

  name       = "nginx-internal"
  namespace  = local.module_namespace
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.9.1"

  values = [
    "${file("${var.helm_chart_path}/external/system/nginx-internal/values.yaml")}"
  ]

  dynamic "set" {
    for_each = var.nginx_internal_requests
    content {
      name  = set.key
      value = set.value
    }
  }

  wait          = true
  reset_values  = true

}

resource "helm_release" "nginx-external" {

  count      = var.release_configs["external.system.nginx-external"] ? 1 : 0

  name       = "nginx-external"
  namespace  = local.module_namespace
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.9.1"

  values = [
    "${file("${var.helm_chart_path}/external/system/nginx-external/values.yaml")}"
  ]

  dynamic "set" {
    for_each = var.nginx_external_requests
    content {
      name  = set.key
      value = set.value
    }
  }

  reset_values  = true
  wait          = true

}


resource "helm_release" "external-secrets" {
  name       = "external-secrets"
  namespace  = local.module_namespace
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.9.14"

  wait          = true
  reset_values  = true

}
