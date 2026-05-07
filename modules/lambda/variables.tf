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

variable "truthifi_api_key" {
  description = "API key for truthifi-endpoint Lambda (stored in SSM SecureString)"
  type        = string
  sensitive   = true
  default     = "PLACEHOLDER_UPDATE_REQUIRED"
}

variable "truthifi_hmac_secret" {
  description = "HMAC secret for truthifi-endpoint Lambda (stored in SSM SecureString)"
  type        = string
  sensitive   = true
  default     = "PLACEHOLDER_UPDATE_REQUIRED"
}
