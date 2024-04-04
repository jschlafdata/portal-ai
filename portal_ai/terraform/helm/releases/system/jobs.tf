locals {
  vault_url = "https://vault.${var.release_settings.dnsDomain}"
  tls_secret_name = var.release_settings.tlsSecretName
}


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
                echo "Checking for secret $SECRET_NAME in namespace $NAMESPACE..."
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
            value = local.tls_secret_name
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

  depends_on = [ helm_release.wildcard-certificate ]

}

