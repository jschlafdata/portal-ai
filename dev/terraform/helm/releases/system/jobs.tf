
resource "kubernetes_role" "pod_reader" {
  metadata {
    name      = "pod-reader"
    namespace = "default"
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "watch", "list"]
  }
}

resource "kubernetes_role_binding" "pod_reader_binding" {
  metadata {
    name      = "pod-reader-binding"
    namespace = "default"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.pod_reader.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "default"
  }
}


resource "kubernetes_job" "wait_for_certificate" {
  metadata {
    name      = "wait-for-certificate"
    namespace = "default"
  }
  spec {
    template {
      metadata {
        // Specify labels or annotations if needed; it can be left empty but must be present
        labels = {
          job = "wait-for-certificate"
        }
      }
      spec {
        container {
          name    = "wait"
          image   = "bitnami/kubectl"
          command = ["/bin/sh", "-c", <<-EOF
            while true; do
              # Check if the secret exists
              if kubectl get secret "$SECRET_NAME" --namespace "$NAMESPACE" &> /dev/null; then
                echo "Secret $SECRET_NAME found. Proceeding with the next steps."
                break
              else
                echo "Secret $SECRET_NAME not found. Checking again in 10 seconds..."
                sleep 10
              fi
            done
            EOF
          ]
          env {
            name  = "SECRET_NAME"
            value = var.tls_secret_name
          }
          env {
            name  = "NAMESPACE"
            value = "default"
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }

  depends_on = [helm_release.wildcard-certificate]
}


resource "kubernetes_job" "wait_for_vault" {
  metadata {
    name = "wait-for-vault"
    namespace = "default"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "wait"
          image   = "bitnami/kubectl" // Using a kubectl image for simplicity
          command = ["/bin/sh", "-c", <<EOF
echo "Waiting for Vault pod to be in Running state..."
until [ "$(kubectl get pod vault-0 -n default -o jsonpath='{.status.phase}')" = "Running" ]; do
    echo "Waiting for vault-0 pod to be in Running state..."
    sleep 5
done
EOF
          ]
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }

  depends_on = [ helm_release.vault ]
}


# resource "kubernetes_job" "ping_vault" {
#   metadata {
#     name      = "ping-vault"
#     namespace = "default"
#   }

#   spec {
#     template {
#       metadata {}
#       spec {
#         container {
#           name    = "curl"
#           image   = "curlimages/curl:latest" // Using a curl image
#           command = ["/bin/sh", "-c"]
#           args    = [
#             <<-EOT
#             while true; do
#               if curl --output /dev/null --silent --head --fail "$WEBSITE_URL"; then
#                 echo "Website is up!"
#                 exit 0
#               else
#                 echo "Waiting for website to be ready..."
#                 sleep 10
#               fi
#             done
#             EOT
#           ]
#           env {
#             name  = "WEBSITE_URL"
#             value = var.vault_url
#           }
#         }
#         restart_policy = "Never"
#       }
#     }
#     backoff_limit = 4
#   }
# }

