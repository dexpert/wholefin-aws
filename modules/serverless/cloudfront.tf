
/* resource "aws_cloudfront_distribution" "dist_E2ZM4DKR4HO3UC" {
  enabled = true

  # Origin configuration would map to the actual origins defined in AWS
  # origin {
  #   domain_name = "example.s3.amazonaws.com"
  #   origin_id   = "exampleS3Origin"
  # }

  # default_cache_behavior {
  #   target_origin_id       = "exampleS3Origin"
  #   viewer_protocol_policy = "redirect-to-https"
  #   allowed_methods        = ["GET", "HEAD", "OPTIONS"]
  #   cached_methods         = ["GET", "HEAD"]
  # }

    viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:844486820647:certificate/ab25ec34-e2b5-4fd4-a884-67f2591c525a"
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Id = "E2ZM4DKR4HO3UC"
    Domain = "d15hde004kk9fp.cloudfront.net"
  }
}

/* resource "aws_cloudfront_distribution" "dist_E30WYSA5VMIHY5" {
  enabled = true

  # Origin configuration would map to the actual origins defined in AWS
  # origin {
  #   domain_name = "example.s3.amazonaws.com"
  #   origin_id   = "exampleS3Origin"
  # }

  # default_cache_behavior {
  #   target_origin_id       = "exampleS3Origin"
  #   viewer_protocol_policy = "redirect-to-https"
  #   allowed_methods        = ["GET", "HEAD", "OPTIONS"]
  #   cached_methods         = ["GET", "HEAD"]
  # }

    viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:844486820647:certificate/ab25ec34-e2b5-4fd4-a884-67f2591c525a"
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Id = "E30WYSA5VMIHY5"
    Domain = "d9zlqdnghhxjw.cloudfront.net"
  }
}

*/
