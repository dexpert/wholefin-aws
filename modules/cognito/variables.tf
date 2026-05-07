variable "environment" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "cloudfront_domain" {
  description = "CloudFront domain name for Cognito callback URL"
  type        = string
}
