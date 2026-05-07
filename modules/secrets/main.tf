# ===================================================================
# Secrets Manager - application secrets
# TF creates the secret with placeholder values on first deploy.
# After creation, actual values should be updated manually.
# lifecycle ignore_changes ensures TF never overwrites real values.
# ===================================================================

resource "aws_secretsmanager_secret" "app" {
  name                    = "secrets"
  description             = "Application secrets for ${var.environment} environment"
  recovery_window_in_days = 0 # Allow immediate deletion/recreation in non-prod

  tags = {
    Name        = "secrets"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id

  # Placeholder - update manually after first deploy
  secret_string = jsonencode({
    PLACEHOLDER = "UPDATE_REQUIRED"
  })

  lifecycle {
    # Never overwrite real values that were manually set after initial creation
    ignore_changes = [secret_string]
  }
}
