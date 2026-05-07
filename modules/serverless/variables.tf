variable "environment" {
  type = string
}

variable "alb_dns_name" {
  description = "DNS name of the ALB used as /api/* origin"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN in us-east-1 for the CloudFront alias (wildcard *.wholefin.ai)"
  type        = string
}
