#----------------------------------------------------------
# Security Group
#----------------------------------------------------------
# web
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-${var.environment}-web-sg"
  description = "web front role security group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-web-sg"
    project     = var.project_name
    environment = var.environment
  }
}

resource "aws_security_group_rule" "web_sg_inbound_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
}

resource "aws_security_group_rule" "web_sg_inbound_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
}

resource "aws_security_group_rule" "web_out_tcp3000" {
  type                     = "egress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_sg.id
  security_group_id        = aws_security_group.web_sg.id
}

resource "aws_security_group_rule" "web_out_tcp80" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_sg.id
  security_group_id        = aws_security_group.web_sg.id
}





# app security group
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-${var.environment}-app-sg"
  description = "application server role security group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-app-sg"
    project     = var.project_name
    environment = var.environment
  }
}

resource "aws_security_group_rule" "app_in_tcp3000" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app_sg.id
  source_security_group_id = aws_security_group.web_sg.id
}



# opmng security group
resource "aws_security_group" "opmng_sg" {
  name        = "${var.project_name}-${var.environment}-opmng-sg"
  description = "operation and management role security group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-opmng-sg"
    project     = var.project_name
    environment = var.environment
  }
}

resource "aws_security_group_rule" "opmng_sg_in_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.opmng_sg.id
}

resource "aws_security_group_rule" "opmng_sg_in_tcp3000" {
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.opmng_sg.id
}



# db security group
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-${var.environment}-db-sg"
  description = "database role security group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-sg"
    project     = var.project_name
    environment = var.environment
  }
}

resource "aws_security_group_rule" "db_sg_tcp3306" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_sg.id
  security_group_id        = aws_security_group.db_sg.id
}

# 踏み台サーバーからRDSへのアクセスを許可
resource "aws_security_group_rule" "db_sg_tcp3306_from_opmng" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.opmng_sg.id
  security_group_id        = aws_security_group.db_sg.id
}

resource "aws_security_group_rule" "db_sg_tcp3306_from_ecs" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_service_security_group.id
  security_group_id        = aws_security_group.db_sg.id
}


#----------------------------------------------------------
# ECS service security group
#----------------------------------------------------------
resource "aws_security_group" "ecs_service_security_group" {
  name        = "${var.project_name}-${var.environment}-ecs-service-sg"
  description = "Security group for ECS service"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }





  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-service-sg"
    project     = var.project_name
    environment = var.environment
  }
}