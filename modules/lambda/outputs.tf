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
