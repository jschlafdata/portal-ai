variable "helm_chart_path" {
    type = string
}


variable "mageai_workspace_charts" {
  type = list(object({
    sub_chart = string
  }))
  description = "A list of documentation sub-chart names"
}
