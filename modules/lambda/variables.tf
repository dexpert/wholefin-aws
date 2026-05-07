variable "environment" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "ecr_mgmt_account_id" {
  description = "Account ID of wholefin-mgmt ECR registry"
  type        = string
  default     = "934853894604"
}

# API_KEY and HMAC_SECRET are read from Secrets Manager at runtime
# (TRUTHIFI_WEBHOOK_API_KEY and TRUTHIFI_WEBHOOK_HMAC_SECRET keys in 'secrets' SM secret)
