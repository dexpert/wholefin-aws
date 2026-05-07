variable "environment" {
  type = string
}

variable "rds_master_secret_arn" {
  description = "ARN of the RDS master user secret (managed by AWS)"
  type        = string
  default     = ""
}
