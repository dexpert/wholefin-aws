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

variable "truthifi_lambda_url_hostname" {
  description = "Hostname of the truthifi-endpoint Lambda Function URL (without https:// and trailing slash)"
  type        = string
}

variable "test_edge_lambda_arn" {
  description = "Qualified ARN of the test Lambda@Edge function (includes version)"
  type        = string
}
