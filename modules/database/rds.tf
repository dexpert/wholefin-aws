
resource "aws_db_subnet_group" "default" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnets
}

resource "aws_security_group" "db" {
  name        = "${var.environment}-rds-sg"
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


# Aurora cluster (required parent for Aurora instances)
resource "aws_rds_cluster" "main" {
  cluster_identifier      = "${var.environment}-aurora-cluster"
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
  engine_version          = "17.4"
  database_name           = "wholefin"
  master_username              = "dbadmin"
  manage_master_user_password  = true  # AWS creates + manages secret in Secrets Manager automatically
  storage_encrypted            = true   # Encrypt storage at rest using AWS managed key (aws/rds)
  skip_final_snapshot          = true

  vpc_security_group_ids  = [aws_security_group.db.id]
  db_subnet_group_name    = aws_db_subnet_group.default.name

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }

  tags = {
    Name        = "${var.environment}-aurora-cluster"
    Environment = var.environment
  }
}

resource "aws_rds_cluster_instance" "db_instance_1" {
  identifier         = "${var.environment}-db-instance-1"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version

  # Prefer AZ a when possible
  availability_zone = "${var.aws_region}a"

  tags = {
    Name        = "${var.environment}-db-instance-1"
    Environment = var.environment
  }
}

