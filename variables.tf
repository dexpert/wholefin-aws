variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "Environment prefix (sand, dev, stage, prod)"
  type        = string
  default     = "sand"
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN in us-east-1 for CloudFront (wildcard *.wholefin.ai)"
  type        = string
  default     = "arn:aws:acm:us-east-1:844486820647:certificate/ab25ec34-e2b5-4fd4-a884-67f2591c525a"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (one per AZ: a, b)"
  type        = list(string)
  default     = ["10.20.0.0/24", "10.20.1.0/24"]
}

variable "app_subnet_cidrs" {
  description = "App tier private subnet CIDRs - used by ECS (one per AZ: a, b)"
  type        = list(string)
  default     = ["10.20.10.0/24", "10.20.11.0/24"]
}

variable "data_subnet_cidrs" {
  description = "Data tier private subnet CIDRs - used by RDS (one per AZ: a, b)"
  type        = list(string)
  default     = ["10.20.20.0/24", "10.20.21.0/24"]
}

variable "ecr_mgmt_account_id" {
  description = "Account ID of wholefin-mgmt ECR registry"
  type        = string
  default     = "934853894604"
}
