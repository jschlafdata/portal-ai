
locals {
  workspace_map = { for wkspc in var.mageai_workspace_charts : wkspc.sub_chart => wkspc }
}


resource "helm_release" "mageai" {

  name       = "mageai"
  namespace  = "default"
  repository = "https://mage-ai.github.io/helm-charts"
  chart      = "mageai"
  version    = "0.2.1"

  values = [
    file("${var.helm_chart_path}/mageai/values.yaml")
  ]

  wait         = true
  reset_values = true
}


resource "helm_release" "mage-workspaces" {
  for_each   = local.workspace_map
  name       = each.key
  namespace  = "default"
  repository = var.helm_chart_path
  chart      = "mageai-workspaces"

  values = [
    file("${var.helm_chart_path}/mageai-workspaces/sub_charts/${each.key}/values.yaml")
  ]

  wait         = true
  reset_values = true
}


# resource "kubernetes_env" "mageai-env-patch" {

#   for_each   = local.workspace_map
#   api_version = "apps/v1"
#   kind        = "StatefulSet"
#   force      = true
#   field_manager = "TerraformEnvs"

#   container = "development-container"  // Adjust as necessary
#   metadata {
#     name = "development"  // Adjust as necessary
#     namespace = "default"
#   }

#   env {
#     name  = "HIDE_ENV_VAR_VALUES"
#     value = "0"
#   }

#   env {
#     name = "GIT_SSH_PUBLIC_KEY"
#     value_from {
#       secret_key_ref {
#         name = "eso-backend"
#         key  = "git_public_key"
#       }
#     }
#   }

#   env {
#     name = "GIT_SSH_PRIVATE_KEY"
#     value_from {
#       secret_key_ref {
#         name = "eso-backend"
#         key  = "git_private_key"
#       }
#     }
#   }

#   env {
#     name = "DB_USER"
#     value_from {
#       secret_key_ref {
#         name = "eso-backend"
#         key  = "rds_username"
#       }
#     }
#   }

#   env {
#     name = "DB_PASS"
#     value_from {
#       secret_key_ref {
#         name = "eso-backend"
#         key  = "rds_password"
#       }
#     }
#   }
# }

# resource "kubernetes_annotations" "mageai-annotation-patch" {

#   depends_on = [ kubernetes_env.mageai-env-patch ]
#   for_each   = local.workspace_map
#   force      = true
#   field_manager = "TerraformAnnotations"

#   api_version = "apps/v1"
#   kind        = "StatefulSet"

#   metadata {
#     name      = "development"
#     namespace = "default"
#   }
#   # These annotations will be applied to the Pods created by the Deployment
#   template_annotations = {
#             "vault.hashicorp.com/agent-inject"                   = "true"
#             "vault.hashicorp.com/agent-inject-file-envvars"      = "envvars"
#             "vault.hashicorp.com/agent-inject-secret-envvars"    = "internal/data/data_engineering"
#             "vault.hashicorp.com/agent-inject-template-envvars"  = <<-EOT
#               {{- with secret "internal/data/data_engineering" -}}
#               {{ .Data | toUnescapedJSON }}
#               {{- end }}
#             EOT
#             "vault.hashicorp.com/agent-limits-ephemeral"         = ""
#             "vault.hashicorp.com/role"                           = "mageai"
#     }
# }


# resource "kubernetes_manifest" "add_gpu_toleration" {
#   manifest = {
#     apiVersion = "api.kubemod.io/v1beta1"
#     kind       = "ModRule"
#     metadata = {
#       name = "add-gpu-toleration-to-all-gpu-pods"
#       namespace = "default"
#     }
#     spec = {
#       type = "Patch"

#       match = [
#         {
#           select     = "$.kind"
#           matchValue = "Pod"
#         },
#         {
#           select      = "$.metadata.name"
#           matchRegex  = ".*gpus$"
#         },
#       ]

#       patch = [
#         {
#           op    = "add"
#           path  = "/spec/tolerations/-"
#           value = {
#             effect   = "NoSchedule"
#             key      = "nvidia.com/gpu"
#             operator = "Exists"
#           }
#         },
#       ]
#     }
#   }
# }