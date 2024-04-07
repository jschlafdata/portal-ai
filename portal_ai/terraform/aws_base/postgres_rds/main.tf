resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%-"
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.app_name}-${var.environment}-rds-subnet-group"
  description = "${var.app_name} RDS subnet group"
  subnet_ids  =  var.private_subnet_ids
  tags = {
    Environment = var.environment
  }
}

resource "aws_security_group" "rds_sg" {
  name = "${var.app_name}-${var.environment}-rds-sg"
  description = "${var.app_name} RDS Security Group"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.app_name}-${var.environment}-rds-sg"
    Environment =  var.environment
  }

  // allows traffic from the SG itself
  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      self = true
  }

  //allow traffic for TCP 5432
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block}"]
  }

  ingress {
    from_port   = 5423
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block}"]
  }

  // outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "rds" {
  identifier             = "${var.app_name}-${var.environment}-db"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "13.10"
  instance_class         = var.instance_type
  multi_az               = false
  db_name                = "default_backend_db"
  username               = "${var.database_user}"
  password               = random_password.password.result
  db_subnet_group_name   = "${aws_db_subnet_group.rds_subnet_group.id}"
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Environment = var.environment
  }
  lifecycle {
    ignore_changes = [
      engine_version,
    ]
  }
}

locals {

  ssm_map = {
    "${var.project_name}-rds-password" = random_password.password.result
    "${var.project_name}-rds-user" = var.database_user
    "${var.project_name}-rds-endpoint-port" = aws_db_instance.rds.endpoint
    "${var.project_name}-rds-endpoint" = split(":", aws_db_instance.rds.endpoint)[0]
  }

}

resource "aws_secretsmanager_secret" "db_secrets" {
  for_each = local.ssm_map

  name = each.key
  tags = {
    Environment = var.environment
    App = var.app_name
  }
}

resource "aws_secretsmanager_secret_version" "db_secrets_version" {
  for_each = local.ssm_map

  secret_id     = aws_secretsmanager_secret.db_secrets[each.key].id
  secret_string = jsonencode({
    value = each.value
  })
}