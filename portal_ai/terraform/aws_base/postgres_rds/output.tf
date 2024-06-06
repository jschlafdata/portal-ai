output "rds_instance_hostname" {
  value = aws_db_instance.rds.endpoint
  description = "The hostname of the RDS instance"
}

output "rds_username" {
  value = var.database_user
  description = "The hostname of the RDS instance"
}