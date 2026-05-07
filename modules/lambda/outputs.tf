output "function_arn" {
  value = aws_lambda_function.truthifi_endpoint.arn
}

output "function_url" {
  description = "Lambda Function URL (used as CloudFront origin)"
  value       = aws_lambda_function_url.truthifi_endpoint.function_url
}

output "function_url_hostname" {
  description = "Hostname only (without https://) for CloudFront origin domain"
  value       = replace(replace(aws_lambda_function_url.truthifi_endpoint.function_url, "https://", ""), "/", "")
}

output "test_edge_qualified_arn" {
  description = "Qualified ARN of test Lambda@Edge (includes version number)"
  value       = aws_lambda_function.test_edge.qualified_arn
}
