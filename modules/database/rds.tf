
resource "aws_db_instance" "dev_db_instance_1" {
  identifier           = "dev-db-instance-1"
  engine               = "aurora-postgresql"
  engine_version       = "17.4"
  instance_class       = "db.serverless"
  allocated_storage    = 1
  skip_final_snapshot  = true

  # Assuming standard VPC security group and subnet groups
  # vpc_security_group_ids = [aws_security_group.db.id]
  # db_subnet_group_name   = aws_db_subnet_group.default.name

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
  skip_final_snapshot  = true

  # Assuming standard VPC security group and subnet groups
  # vpc_security_group_ids = [aws_security_group.db.id]
  # db_subnet_group_name   = aws_db_subnet_group.default.name

  tags = {
    Name = "eyal-db-instance-1"
    Environment = "Dev"
  }
}
