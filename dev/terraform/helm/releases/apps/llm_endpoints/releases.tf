
locals {

}


resource "helm_release" "llama2-7b-cuda" {

  name       = "llama2-7b-cuda"
  namespace  = "default"
  repository = var.helm_chart_path
  chart      = "llm-models"

  values = [
    file("${var.helm_chart_path}/llm-models/sub_charts/llama2-7b-cuda/values.yaml")
  ]

  set {
    name  = "replicas"
    value = 0
  }

  wait         = true
  reset_values = true
}