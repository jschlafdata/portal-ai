variable "helm_chart_path" {
    type = string
}

variable "doc_sub_charts" {
  type = list(object({
    sub_chart = string
  }))
  description = "A list of documentation sub-chart names"
}

