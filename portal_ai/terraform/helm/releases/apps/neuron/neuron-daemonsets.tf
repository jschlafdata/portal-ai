

resource "helm_release" "neuron-plugins" {

  name       = "neuron-plugins"
  namespace  = "kube-system"
  repository = "${var.helm_chart_path}/local_custom/apps"
  chart      = "neuron-plugins"

  wait         = true
  reset_values = true
}

