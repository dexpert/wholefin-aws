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

  # All keys mirrored from dev - values must be updated manually after first deploy
  secret_string = jsonencode({
    "PROFILE_SERVICE/MY_SECRET"     = "UPDATE_REQUIRED"
    "DB_CONNECTION_STRING_URI"      = "UPDATE_REQUIRED"
    "DB_USER"                       = "UPDATE_REQUIRED"
    "DB_PASS"                       = "UPDATE_REQUIRED"
    "DEVOPS_USER"                   = "UPDATE_REQUIRED"
    "DEVOPS_PASS"                   = "UPDATE_REQUIRED"
    "DB_DEVOPS_CONNECTION_STRING_URI" = "UPDATE_REQUIRED"
    "DB_CONNECTION_STRING"          = "UPDATE_REQUIRED"
    "SMTP_USERNAME"                 = "UPDATE_REQUIRED"
    "SMTP_PASSWORD"                 = "UPDATE_REQUIRED"
    "COGNITO_CLIENT_SECRET"         = "UPDATE_REQUIRED"
    "INVITE_JWT_SECRET_KEY"         = "UPDATE_REQUIRED"
    "APEX_PRIVATE_KEY_SNBX"         = "UPDATE_REQUIRED"
    "APEX_API_KEY_SNBX"             = "UPDATE_REQUIRED"
    "OPENAI_API_KEY"                = "UPDATE_REQUIRED"
    "ANTHROPIC_API_KEY"             = "UPDATE_REQUIRED"
    "APEX_PRIVATE_KEY"              = "UPDATE_REQUIRED"
    "APEX_API_KEY"                  = "UPDATE_REQUIRED"
    "TRUTHIFI_ORG_TOKEN"            = "UPDATE_REQUIRED"
    "TRUTHIFI_WEBHOOK_API_KEY"      = "UPDATE_REQUIRED"
    "TRUTHIFI_WEBHOOK_HMAC_SECRET"  = "UPDATE_REQUIRED"
    "FRED_API_KEY"                  = "UPDATE_REQUIRED"
    "SERVICE_ACCOUNT_ID"            = "UPDATE_REQUIRED"
  })

  lifecycle {
    # Never overwrite real values that were manually set after initial creation
    ignore_changes = [secret_string]
  }
}
