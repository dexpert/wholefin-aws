# ===================================================================
# Cognito User Pool - mirrored from wholefin-dev (us-east-2_HXatcgxzq)
# ===================================================================

resource "aws_cognito_user_pool" "main" {
  name                     = "User pool - ${var.environment}"
  deletion_protection      = "ACTIVE"
  username_attributes      = []
  auto_verified_attributes = ["email"]
  mfa_configuration        = "OFF"

  username_configuration {
    case_sensitive = false
  }

  password_policy {
    minimum_length                   = 8
    require_uppercase                = true
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  sign_in_policy {
    allowed_first_auth_factors = ["PASSWORD"]
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
    invite_message_template {
      email_subject = "Your temporary password"
      email_message = "Your username is {username} and temporary password is {####}."
      sms_message   = "Your username is {username} and temporary password is {####}."
    }
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  user_attribute_update_settings {
    attributes_require_verification_before_update = []
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = true
    required            = true
    string_attribute_constraints {
      min_length = "0"
      max_length = "2048"
    }
  }

  tags = {
    Name        = "User pool - ${var.environment}"
    Environment = var.environment
  }
}

# ---------- User Pool Client ----------

resource "aws_cognito_user_pool_client" "main" {
  name         = "wholefin ${var.environment}"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret               = true
  prevent_user_existence_errors = "ENABLED"
  enable_token_revocation       = true

  refresh_token_validity = 5
  access_token_validity  = 60
  id_token_validity      = 60

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]

  callback_urls                        = ["https://${var.cloudfront_domain}"]
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "phone"]
  allowed_oauth_flows_user_pool_client = true
  supported_identity_providers         = ["COGNITO"]
}

# ---------- User Pool Domain ----------

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.environment}wholefincognito"
  user_pool_id = aws_cognito_user_pool.main.id
}

# ---------- SSM Parameter: COGNITO_JWKS_URL ----------

resource "aws_ssm_parameter" "cognito_jwks_url" {
  name  = "COGNITO_JWKS_URL"
  type  = "String"
  value = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.main.id}/.well-known/jwks.json"

  tags = {
    Name        = "COGNITO_JWKS_URL"
    Environment = var.environment
  }
}
