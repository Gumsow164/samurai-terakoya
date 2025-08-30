#----------------------------------------------------------
# RDS parameter group
#----------------------------------------------------------
resource "aws_db_parameter_group" "mysql_pg" {
  name   = "${var.project_name}-${var.environment}-mysql-pg"
  family = "mysql8.0"

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

#----------------------------------------------------------
# RDS option group
#----------------------------------------------------------
resource "aws_db_option_group" "mysql_og" {
  name                 = "${var.project_name}-${var.environment}-mysql-og"
  engine_name          = "mysql"
  major_engine_version = "8.0"
}

#----------------------------------------------------------
# RDS subnet group
#----------------------------------------------------------
resource "aws_db_subnet_group" "mysql_sg" {
  name = "${var.project_name}-${var.environment}-mysql-sg-v2"
  subnet_ids = [
    aws_subnet.private_subnet_1a.id,
    aws_subnet.private_subnet_1c.id
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-mysql-sg-v2"
    project     = var.project_name
    environment = var.environment
  }
}

#----------------------------------------------------------
# Parameter Store for RDS credentials
#----------------------------------------------------------
resource "random_string" "db_password" {
  length  = 16
  special = false
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/${var.project_name}/${var.environment}/rds/password"
  description = "RDS MySQL password for ${var.environment} environment"
  type        = "SecureString"
  value       = random_string.db_password.result

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-password"
    project     = var.project_name
    environment = var.environment
  }
}

resource "aws_ssm_parameter" "db_username" {
  name        = "/${var.project_name}/${var.environment}/rds/username"
  description = "RDS MySQL username for ${var.environment} environment"
  type        = "String"
  value       = "admin"

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-username"
    project     = var.project_name
    environment = var.environment
  }
}

resource "aws_ssm_parameter" "db_endpoint" {
  name        = "/${var.project_name}/${var.environment}/rds/endpoint"
  description = "RDS MySQL endpoint for ${var.environment} environment"
  type        = "String"
  value       = aws_db_instance.mysql.endpoint

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-endpoint"
    project     = var.project_name
    environment = var.environment
  }
}

#----------------------------------------------------------
# RDS instance
#----------------------------------------------------------
resource "aws_db_instance" "mysql" {
  identifier = "${var.project_name}-${var.environment}-mysql"

  engine         = "mysql"
  engine_version = "8.0"

  username = aws_ssm_parameter.db_username.value
  password = aws_ssm_parameter.db_password.value

  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp2"
  storage_encrypted     = false

  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.mysql_sg.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false
  port                   = 3306

  db_name              = "nagoyameshi_db"
  parameter_group_name = aws_db_parameter_group.mysql_pg.name
  option_group_name    = aws_db_option_group.mysql_og.name

  backup_window              = "04:00-05:00"
  backup_retention_period    = 7
  maintenance_window         = "Mon:05:00-Mon:08:00"
  auto_minor_version_upgrade = false

  deletion_protection = false
  skip_final_snapshot = false
  final_snapshot_identifier = "${var.project_name}-${var.environment}-mysql-final-snapshot"

  apply_immediately = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-mysql"
    project     = var.project_name
    environment = var.environment
  }
}