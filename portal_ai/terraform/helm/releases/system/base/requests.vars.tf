variable "efs_csi_requests" {
  description = "Map of resource request paths and values"
  type = map(string)
  default = {
    "replicaCount"                                           = 1
    "sidecars.nodeDriverRegistrar.resources.requests.memory" = "10Mi"
    "sidecars.nodeDriverRegistrar.resources.requests.cpu"    = "10m"
    "sidecars.livenessProbe.resources.requests.memory"       = "10Mi"
    "sidecars.livenessProbe.resources.requests.cpu"          = "10m"
    "sidecars.csiProvisioner.resources.requests.memory"      = "10Mi"
    "sidecars.csiProvisioner.resources.requests.cpu"         = "10m"
    "controller.resources.requests.memory"                   = "10Mi"
    "controller.resources.requests.cpu"                      = "10m"
    "node.resources.requests.memory"                         = "10Mi"
    "node.resources.requests.cpu"                            = "10m"
  }
}


variable "external_secrets_requests" {
  description = "Map of resource request paths and values"
  type = map(string)
  default = {
    "replicaCount"                             = 1
    "resources.requests.memory"                = "10Mi"
    "resources.requests.cpu"                   = "10m"
    "webhook.resources.requests.memory"        = "10Mi"
    "webhook.resources.requests.cpu"           = "10m"
    "certController.resources.requests.memory" = "10Mi"
    "certController.resources.requests.cpu"    = "10m"
  }
}



variable "vault_requests" {
  description = "Map of resource request paths and values"
  type = map(string)
  default = {
    "injector.enabled"  = false
    "injector.resources.requests.cpu"     = "10m"
    "server.resources.requests.memory"    = "10Mi"
    "server.resources.requests.cpu"       = "10m"
    "csi.resources.requests.memory"       = "10Mi"
    "csi.resources.requests.cpu"          = "10m"
    "csi.agent.resources.requests.memory" = "10Mi"
    "csi.agent.resources.requests.cpu"    = "10m"
  }
}


variable "external_dns_requests" {
  description = "Map of resource request paths and values"
  type = map(string)
  default = {
    "resources.requests.memory"                   = "10Mi"
    "resources.requests.cpu"                      = "10m"
  }
}


variable "nginx_internal_requests" {
  description = "Map of resource request paths and values"
  type = map(string)
  default = {
    "controller.replicaCount"                                = 1
    "controller.resources.requests.memory"                   = "10Mi"
    "controller.resources.requests.cpu"                      = "10m"
    "controller.admissionWebhooks.resources.requests.memory" = "10Mi" 
    "controller.admissionWebhooks.resources.requests.cpu"    = "10m" 
    "controller.patchWebhookJob.resources.requests.memory"   = "10Mi"
    "controller.patchWebhookJob.resources.requests.cpu"      = "10m"
  }
}

variable "nginx_external_requests" {
  description = "Map of resource request paths and values"
  type = map(string)
  default = {
    "controller.replicaCount"                                = 1
    "controller.resources.requests.memory"                   = "10Mi"
    "controller.resources.requests.cpu"                      = "10m"
    "controller.admissionWebhooks.resources.requests.memory" = "10Mi" 
    "controller.admissionWebhooks.resources.requests.cpu"    = "10m" 
    "controller.patchWebhookJob.resources.requests.memory"   = "10Mi"
    "controller.patchWebhookJob.resources.requests.cpu"      = "10m"
  }
}

