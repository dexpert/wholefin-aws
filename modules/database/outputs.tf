output "cluster_endpoint" {
  description = "Aurora cluster writer endpoint"
  value       = aws_rds_cluster.main.endpoint
}

output "cluster_reader_endpoint" {
  description = "Aurora cluster reader endpoint"
  value       = aws_rds_cluster.main.reader_endpoint
}

output "cluster_identifier" {
  value = aws_rds_cluster.main.cluster_identifier
}

output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the RDS master password (managed by AWS)"
  value       = aws_rds_cluster.main.master_user_secret[0].secret_arn
}

output "database_name" {
  value = aws_rds_cluster.main.database_name
}
