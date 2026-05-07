variable "vpc_id" {}
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "vpc_cidr" { type = string }
variable "environment" { type = string }

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "account_id" {
  description = "AWS account ID (used to build SSM parameter ARN)"
  type        = string
}

variable "ecr_mgmt_account_id" {
  description = "Account ID of wholefin-mgmt ECR registry"
  type        = string
  default     = "934853894604"
}

variable "ecs_task_role_arn" {
  description = "ARN of the ECS Task Role"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "ARN of the ECS Task Execution Role"
  type        = string
}
