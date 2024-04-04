output "iam_policy_arns" {
  value = [
    [aws_iam_policy.efs_admin.name, aws_iam_policy.efs_admin.arn],
    [aws_iam_policy.aws_lb_policy.name, aws_iam_policy.aws_lb_policy.arn],
    [aws_iam_policy.ecr_policy.name, aws_iam_policy.ecr_policy.arn],
    [aws_iam_policy.kops_policy.name, aws_iam_policy.kops_policy.arn],
    [aws_iam_policy.external_dns_cert_policy.name, aws_iam_policy.external_dns_cert_policy.arn]
  ]
  description = "List of ARNs and names for IAM policies"
}
