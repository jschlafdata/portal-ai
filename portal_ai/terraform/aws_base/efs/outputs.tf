output "efs_id" {
  value = aws_efs_file_system.file_system.id
  description = "The ID of the EFS file system"
}

output "efs_arn" {
  value = aws_efs_file_system.file_system.arn
  description = "The ID of the EFS file system"
}

output "efs_access_point_arn" {
  description = "The ARN of the EFS Access Point"
  value       = aws_efs_access_point.access_point.arn
}

