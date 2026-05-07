variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "Environment prefix"
  type        = string
  default     = "sand"
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN in us-east-1 for CloudFront (wildcard *.wholefin.ai)"
  type        = string
  default     = "arn:aws:acm:us-east-1:844486820647:certificate/ab25ec34-e2b5-4fd4-a884-67f2591c525a"
}
