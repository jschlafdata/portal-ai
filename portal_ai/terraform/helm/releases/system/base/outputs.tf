output "awssm_role" {
  value = data.kubernetes_service_account.default-roles["awssm"].metadata[0].name
}