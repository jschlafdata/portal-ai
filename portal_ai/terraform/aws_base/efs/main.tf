resource "aws_efs_file_system" "file_system" {
  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"
  tags = {
    Name        = "${var.app_name}-efs"
    Environment = var.environment
  }
}

resource "aws_security_group" "mount_target_security_group" {
  name        = "${var.app_name}-efs-sg"
  description = "Security group for EFS mount target 1"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.private_subnet_cidrs
    content {
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  tags = {
    Name        = "${var.app_name}-efs-sg"
    Environment = var.environment
  }
}

resource "aws_efs_mount_target" "mount_target" {
  for_each         = toset(var.private_subnet_ids)
  file_system_id   = aws_efs_file_system.file_system.id
  subnet_id        = each.value
  security_groups  = [aws_security_group.mount_target_security_group.id]
}


resource "aws_efs_access_point" "access_point" {
  file_system_id = aws_efs_file_system.file_system.id

  posix_user {
    gid = 1001
    uid = 1001
  }

  root_directory {
    path = "/"
    creation_info {
      owner_gid   = 1001
      owner_uid   = 1001
      permissions = "755"
    }
  }

  tags = {
    Name        = "${var.app_name}-efs-ap"
    Environment = var.environment
  }
}