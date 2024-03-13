resource "helm_release" "wildcard-certificate" {
  name       = "wildcard-certificate"
  namespace  = "default"
  repository = "${var.helm_chart_path}"
  chart      = "wildcard-certificate"

  values = [
    "${file("${var.helm_chart_path}/wildcard-certificate/values.yaml")}"
  ]

  wait          = true
  reset_values  = true

}


resource "helm_release" "nginx-internal" {
  name       = "nginx-internal"
  namespace  = "default"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.9.1"

  values = [
    "${file("${var.helm_chart_path}/nginx-internal/values.yaml")}"
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

  depends_on = [ kubernetes_job.wait_for_certificate ]

}

resource "helm_release" "nginx-external" {
  name       = "nginx-external"
  namespace  = "default"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.9.1"

  values = [
    "${file("${var.helm_chart_path}/nginx-external/values.yaml")}"
  ]

  dynamic "set" {
    for_each = var.nginx_external_requests
    content {
      name  = set.key
      value = set.value
    }
  }

  reset_values  = true
  wait   = true
  depends_on = [ kubernetes_job.wait_for_certificate ]

}


resource "null_resource" "enable_proxy_v2" {

  depends_on = [ helm_release.nginx-external, 
                 helm_release.nginx-internal ]

  provisioner "local-exec" {
    command = <<EOT
    ${var.script_dir}/nginx_proxyv2.sh ${var.environment}
EOT

  }
}


resource "helm_release" "external-dns" {
  name       = "external-dns"
  namespace  = "default"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = "6.36.1"

  values = [
    "${file("${var.helm_chart_path}/external-dns/values.yaml")}"
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
  namespace  = "default"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.27.0"

  values = [
    "${file("${var.helm_chart_path}/vault/values.yaml")}"
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

  depends_on = [ kubernetes_storage_class.vault_sc, 
                 kubernetes_job.wait_for_certificate ]

}


resource "null_resource" "vault_init_script" {
  depends_on = [kubernetes_job.wait_for_vault]

  provisioner "local-exec" {
    command = <<EOT
    ${var.script_dir}/vault_init.sh ${var.environment}
EOT

  }
}


resource "null_resource" "vault_unseal_script" {
  depends_on = [null_resource.vault_init_script]

  provisioner "local-exec" {
    command = <<EOT
    ${var.script_dir}/vault_unseal.sh ${var.environment}
EOT

  }
}


# resource "null_resource" "vault_create_policies_script" {
#   depends_on = [ null_resource.vault_unseal_script ]

#   provisioner "local-exec" {
#     command = <<EOT
#     ${var.script_dir}/vault_init_policies.sh ${var.environment}
# EOT

#   }
# }


resource "helm_release" "external-secrets" {
  name       = "external-secrets"
  namespace  = "default"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.9.13"

  wait          = true
  reset_values  = true

  dynamic "set" {
    for_each = var.external_secrets_requests
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [ null_resource.vault_unseal_script ]

}


resource "helm_release" "eso-secrets-operators" {
  name       = "eso-secrets-operators"
  namespace  = "default"
  repository = "${var.helm_chart_path}"
  chart      = "external_secrets"

  values = [
    "${file("${var.helm_chart_path}/external_secrets/values.yaml")}"
  ]

  wait          = true
  reset_values  = true
  depends_on = [ helm_release.external-secrets ]

}


resource "helm_release" "aws-efs-csi-driver" {
  name       = "aws-efs-csi-driver"
  namespace  = "default"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart      = "aws-efs-csi-driver"
  version    = "2.5.6"

  values = [
    "${file("${var.helm_chart_path}/efs-csi/values.yaml")}"
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


resource "kubernetes_persistent_volume_claim" "efs_claim" {
  metadata {
    name = "efs-default-claim"
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
}
