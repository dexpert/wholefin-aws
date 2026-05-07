# ===================================================================
# CloudFront Distribution: ${var.environment}.wholefin.ai
# - Default origin: S3 bucket wholefin-platform-${env}
# - /api/* origin: ALB
# - ACM wildcard cert in us-east-1
# - WAFv2 (free-tier managed rule)
# ===================================================================

# WAFv2 + CloudFront resources must use the us-east-1 provider (passed by caller).

terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.us_east_1]
    }
  }
}

# ---------- WAFv2 (free-tier AWS managed rule) ----------

resource "aws_wafv2_web_acl" "cloudfront" {
  provider = aws.us_east_1

  name  = "${var.environment}-cloudfront-waf"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # Free-tier managed rule (Common Rule Set) - included in WAF free quota
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.environment}-cf-common-rules"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.environment}-cloudfront-waf"
    sampled_requests_enabled   = true
  }

  tags = {
    Name        = "${var.environment}-cloudfront-waf"
    Environment = var.environment
  }
}

# ---------- Origin Access Control (modern S3 origin auth) ----------

resource "aws_cloudfront_origin_access_control" "platform" {
  name                              = "${var.environment}-platform-oac"
  description                       = "OAC for ${var.environment} platform bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ---------- CloudFront Distribution ----------

locals {
  s3_origin_id  = "${var.environment}-platform-s3"
  alb_origin_id = "${var.environment}-alb"
}

resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.environment}.wholefin.ai"
  default_root_object = "index.html"
  http_version        = "http2"
  price_class         = "PriceClass_All"
  web_acl_id          = aws_wafv2_web_acl.cloudfront.arn
  aliases             = ["${var.environment}.wholefin.ai"]

  # ---- S3 origin (default) ----
  origin {
    origin_id                = local.s3_origin_id
    domain_name              = aws_s3_bucket.wholefin_platform.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.platform.id
  }

  # ---- ALB origin (/api/*) ----
  origin {
    origin_id   = local.alb_origin_id
    domain_name = var.alb_dns_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # ---- Default behavior: S3 ----
  default_cache_behavior {
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    # AWS managed: CachingOptimized
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  # ---- /api/* behavior: ALB (no caching, forward everything) ----
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = local.alb_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    # AWS managed: CachingDisabled
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    # AWS managed: AllViewer (forward all headers/cookies/query)
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  tags = {
    Name        = "${var.environment}-cloudfront"
    Environment = var.environment
  }
}

# ---------- S3 bucket policy: only CloudFront via OAC can read ----------

data "aws_iam_policy_document" "platform_oac" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.wholefin_platform.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.main.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "platform_oac" {
  bucket = aws_s3_bucket.wholefin_platform.id
  policy = data.aws_iam_policy_document.platform_oac.json
}

# ===================================================================
# CloudFront Distribution 2: truthifi-${env}.wholefin.ai
# Origin: Lambda Function URL (truthifi-endpoint)
# ===================================================================

resource "aws_wafv2_web_acl" "truthifi" {
  provider = aws.us_east_1

  name  = "${var.environment}-truthifi-waf"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.environment}-truthifi-common-rules"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.environment}-truthifi-waf"
    sampled_requests_enabled   = true
  }

  tags = {
    Name        = "${var.environment}-truthifi-waf"
    Environment = var.environment
  }
}

locals {
  truthifi_origin_id = "${var.environment}-truthifi-endpoint-lambda"
}

resource "aws_cloudfront_distribution" "truthifi" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "truthifi-${var.environment}.wholefin.ai"
  http_version    = "http2"
  price_class     = "PriceClass_All"
  web_acl_id      = aws_wafv2_web_acl.truthifi.arn
  aliases         = ["truthifi-${var.environment}.wholefin.ai"]

  # ---- Lambda Function URL origin ----
  origin {
    origin_id   = local.truthifi_origin_id
    domain_name = var.truthifi_lambda_url_hostname

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # ---- Default behavior: all methods, no caching ----
  default_cache_behavior {
    target_origin_id       = local.truthifi_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    # AWS managed: CachingDisabled
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    # AWS managed: AllViewerExceptHostHeader
    origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac"

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = var.test_edge_lambda_arn
      include_body = true
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  tags = {
    Name        = "${var.environment}-truthifi-cloudfront"
    Environment = var.environment
  }
}
