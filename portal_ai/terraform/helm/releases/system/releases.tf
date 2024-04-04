resource "helm_release" "wildcard-certificate" {
  count      = var.release_configs["local_custom.system.wildcard-certificate"] ? 1 : 0
  name       = "wildcard-certificate"
  namespace  = "default"
  repository = "${var.helm_chart_path}/local_custom/system"
  chart      = "wildcard-certificate"

  values = [
    "${file("${var.helm_chart_path}/local_custom/system/wildcard-certificate/values.yaml")}"
  ]

  wait          = true
  reset_values  = true

}


resource "helm_release" "nginx-internal" {

  count      = var.release_configs["external.system.nginx-internal"] ? 1 : 0

  name       = "nginx-internal"
  namespace  = "default"
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

  depends_on = [ kubernetes_job.wait_for_certificate ]

}

resource "helm_release" "nginx-external" {

  count      = var.release_configs["external.system.nginx-external"] ? 1 : 0

  name       = "nginx-external"
  namespace  = "default"
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
  wait   = true
  depends_on = [ kubernetes_job.wait_for_certificate ]

}


data "external" "update_alb_load_balancer" {
  program = ["sh", "-c", "cd ../../../ && poetry run python -m portal_ai.terraform.helm.scripts.load_balancer"]
  depends_on = [ helm_release.nginx-internal ]
}

# query = {
#   # Pass the current timestamp as a query parameter.
#   # The script doesn't need to use it; its purpose is solely to ensure the data source is considered changed.
#   timestamp = timestamp()
# }


resource "helm_release" "external-dns" {
  name       = "external-dns"
  namespace  = "default"
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
  
  depends_on = [ data.external.update_alb_load_balancer ]

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

  depends_on = [ 
    kubernetes_storage_class.vault_sc,
    kubernetes_job.wait_for_certificate,
    data.external.update_alb_load_balancer
  ]

}


data "external" "validate_vault" {
  program = ["sh", "-c", "cd ../../../ && poetry run python -m portal_ai.terraform.helm.scripts.validate_vault"]
  depends_on = [ helm_release.vault ]
}

data "external" "initialize_unseal_vault" {
  program = ["sh", "-c", "cd ../../../ && poetry run python -m portal_ai.terraform.helm.scripts.vault_init_unseal"]
  depends_on = [ helm_release.vault,
                 data.external.validate_vault ]
}


data "external" "validate_vault_endpoint" {
  program = ["sh", "-c", "cd ../../../ && poetry run python -m portal_ai.terraform.helm.scripts.endpoint_test vault"]

  depends_on = [ helm_release.vault,
                 data.external.initialize_unseal_vault ]
}


resource "time_sleep" "post_vault_validation" {
  create_duration = "30s"
  depends_on = [
    data.external.validate_vault_endpoint,
    helm_release.vault,
    data.external.initialize_unseal_vault
  ]
}


resource "null_resource" "create_vault_policies" {

  depends_on = [
    helm_release.vault,
    data.external.validate_vault_endpoint,
    time_sleep.post_vault_validation
  ]

  provisioner "local-exec" {
    command = "sh -c 'cd ../../../ && poetry run python -m portal_ai.terraform.helm.scripts.init_secret_backends'"
  }
}


resource "time_sleep" "wait_for_some_token_to_percolate" {
  # Specifies the duration of the sleep, in RFC 3339 duration format.
  # For example, "10m" waits for 10 minutes, "30s" for 30 seconds.
  create_duration = "15s"
  depends_on = [ null_resource.create_vault_policies ]

}


resource "helm_release" "external-secrets" {
  name       = "external-secrets"
  namespace  = "default"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.9.14"

  wait          = true
  reset_values  = true

}


# dynamic "set" {
#   for_each = var.external_secrets_requests
#   content {
#     name  = set.key
#     value = set.value
#   }
# }


resource "helm_release" "eso-secrets-operators" {
  name       = "eso-secrets-stores"
  namespace  = "default"
  repository = "${var.helm_chart_path}/local_custom/system"
  chart      = "external-secrets"
  version    = "0.2.0"

  values = [
    "${file("${var.helm_chart_path}/local_custom/system/external-secrets/values.yaml")}"
  ]
  wait          = true
  reset_values  = true
  
  depends_on = [ 
    time_sleep.wait_for_some_token_to_percolate
  ]

}


resource "helm_release" "aws-efs-csi-driver" {
  name       = "aws-efs-csi-driver"
  namespace  = "default"
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
  depends_on = [ helm_release.aws-efs-csi-driver ]

}

