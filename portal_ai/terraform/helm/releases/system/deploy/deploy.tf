locals {
  module_namespace = "default"
}

locals {
  efs_volumes = {
    efs-default-claim = {
      ns = "default"
      mount_path = "/python"
      data = {
        "vault.py" = "${file("${var.script_dir}/vault.py")}"
        "load_balancer.py" = "${file("${var.script_dir}/load_balancer.py")}"
        "helm_values_base" = "${file("${var.generated_dir}/helm_values_base.yml")}"
        "kops_cluster_base" = "${file("${var.generated_dir}/kops_cluster_base.yml")}"
        "kops_settings_base" = "${file("${var.generated_dir}/kops_settings_base.yml")}"
        "aws_plus_global_settings_base" = "${file("${var.generated_dir}/aws+global_settings_base.yml")}"
      }
    }
  }
}

resource "kubernetes_config_map" "python_script_config" {
  
  for_each = local.efs_volumes
  metadata {
    name = "python-script-config"
    namespace = each.value.ns
  }
  data = each.value.data
}


resource "kubernetes_job" "copy_python_scripts_to_efs" {

  for_each = local.efs_volumes
  metadata {
    name      = "cp-python-scripts-to-efs"
    namespace = each.value.ns
  }
  spec {
    completions = 1
    template {
      metadata {}
      spec {
        container {
          name    = "copy-files"
          image   = "busybox"
          command = ["/bin/sh", "-c", "cp /scripts/* ${each.value.mount_path}/"]
          volume_mount {
            name       = "script-volume"
            mount_path = "/scripts"
          }
          volume_mount {
            name       = "efs-volume"
            mount_path = each.value.mount_path
          }
        }
        restart_policy = "Never"
        volume {
          name = "script-volume"
          config_map {
            name = kubernetes_config_map.python_script_config[each.key].metadata[0].name
          }
        }
        volume {
          name = "efs-volume"
          persistent_volume_claim {
            claim_name = each.key
          }
        }
      }
    }
  }
  wait_for_completion = true
  timeouts {
    create = "40s"
  }
  depends_on = [ kubernetes_config_map.python_script_config ]
}


resource "kubernetes_job" "execute_python_scripts" {
  metadata {
    name      = "execute-python-scripts"
    namespace = local.module_namespace
  }

  spec {
    template {
      metadata {
        labels = {
          app = "execute-python-scripts"
        }
      }

      spec {
        service_account_name = "awssm"
        container {
          name  = "execute-scripts"
          image = "python:3.8-slim"  # Use an appropriate Python image

          command = ["/bin/sh", "-c"]

          args = [
            <<-EOT
            pip install hvac boto3 kubernetes psycopg2-binary && 
            python3 python/vault.py -p ${var.project_name}
            EOT
          ]

          volume_mount {
            name       = "efs-volume"
            mount_path = "/python"
          }
        }

        volume {
          name = "efs-volume"
          persistent_volume_claim {
            claim_name = "efs-default-claim"  # Ensure this matches the claim created earlier
          }
        }

        restart_policy = "Never"
      }
    }
  }
  wait_for_completion = true
  timeouts {
    create = "40s"
  }
  depends_on = [ kubernetes_job.copy_python_scripts_to_efs ]
}


resource "helm_release" "eso-secrets-operators" {

  name       = "eso-secrets-stores"
  namespace  = local.module_namespace
  repository = "${var.helm_chart_path}/local_custom/system"
  chart      = "external-secrets"
  version    = "0.3.0"

  values = [
    "${file("${var.helm_chart_path}/local_custom/system/external-secrets/values.yaml")}"
  ]
  wait          = true
  reset_values  = true

  set {
    name  = "jobRole"
    value = var.awssm_role
  }

  wait_for_jobs = true
  depends_on = [ kubernetes_job.execute_python_scripts ]  

}


resource "helm_release" "tls_reflections" {

  name       = "tls-reflections"
  namespace  = local.module_namespace
  repository = "${var.helm_chart_path}/local_custom/system"
  chart      = "tls-reflections"
  version    = "0.1.0"

  values = [
    "${file("${var.helm_chart_path}/local_custom/system/tls-reflections/values.yaml")}"
  ]

  wait          = true
  reset_values  = true

  depends_on = [ helm_release.eso-secrets-operators ]

}

