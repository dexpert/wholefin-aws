variable "vpc_id" {}
variable "private_subnets" { type = list(string) }

variable "vpc_cidr" { type = string }

variable "environment" { type = string }

variable "aws_region" {
  description = "AWS region (used for AZ preference, e.g. us-east-2)"
  type        = string
}
