

variable "kube_state_metrics_requests" {
  description = "Map of resource request paths and values"
  type = map(string)
  default = {
    "replicas"                   = 1
    "resources.requests.memory"  = "10Mi"
    "resources.requests.cpu"     = "10m"
  }
}


variable "prometheus_node_exporter_requests" {
  description = "Map of resource request paths and values"
  type = map(string)
  default = {
    "resources.requests.memory"  = "10Mi"
    "resources.requests.cpu"     = "10m"
  }
}


variable "prometheus_requests" {
  description = "Map of resource request paths and values"
  type = map(string)
  default = {
    "server.replicaCount"                                   = 1
    "server.resources.requests.memory"                      = "10Mi"
    "server.resources.requests.cpu"                         = "10m"
    "configmapReload.prometheus.resources.requests.memory"  = "10Mi"
    "configmapReload.prometheus.resources.requests.cpu"     = "10m"
  }
}

variable "grafana_requests" {
  description = "Map of resource request paths and values"
  type = map(string)
  default = {
    "replicas"                                 = 1
    "resources.requests.memory"                = "10Mi"
    "resources.requests.cpu"                   = "10m"
    "sidecar.resources.requests.memory"        = "10Mi"
    "sidecar.resources.requests.cpu"           = "10m"
    "imageRenderer.resources.requests.memory"  = "10Mi"
    "imageRenderer.resources.requests.cpu"     = "10m"
  }
}


