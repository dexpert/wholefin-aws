
resource "aws_db_subnet_group" "default" {
  name       = "main-db-subnet-group"
  subnet_ids = var.private_subnets
}

resource "aws_security_group" "db" {
  name        = "rds-sg"
  description = "Allow inbound database traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_db_instance" "dev_db_instance_1" {
  identifier           = "dev-db-instance-1"
  engine               = "aurora-postgresql"
  engine_version       = "17.4"
  instance_class       = "db.serverless"
  allocated_storage    = 1
  username             = "admin"
  password             = "TempPassword123!"
  skip_final_snapshot  = true

  # Assuming standard VPC security group and subnet groups
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name

  tags = {
    Name = "dev-db-instance-1"
    Environment = "Dev"
  }
}

resource "aws_db_instance" "eyal_db_instance_1" {
  identifier           = "eyal-db-instance-1"
  engine               = "aurora-postgresql"
  engine_version       = "17.4"
  instance_class       = "db.serverless"
  allocated_storage    = 1
  username             = "admin"
  password             = "TempPassword123!"
  skip_final_snapshot  = true

  # Assuming standard VPC security group and subnet groups
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name

  tags = {
    Name = "eyal-db-instance-1"
    Environment = "Dev"
  }
}
