
locals {

}


resource "helm_release" "accelerated-jupyter" {

  name       = "accelerated-jupyter-lab"
  namespace  = "default"
  repository = var.helm_chart_path
  chart      = "jupyter-lab-accelerated"

  values = [
    file("${var.helm_chart_path}/jupyter-lab-accelerated/values.yaml")
  ]

  set {
    name  = "replicas"
    value = 0
  }
  wait         = true
  reset_values = true

}
