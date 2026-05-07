# ===================================================================
# Lambda: truthifi-endpoint
# PackageType: Image from mgmt ECR
# ===================================================================

# ---------- IAM Role ----------

resource "aws_iam_role" "lambda_role" {
  name = "Lambda-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "Lambda-Role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_ssm" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_eventbridge" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_secrets" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSSecretsManagerClientReadOnlyAccess"
}

# ECR cross-account pull permissions (for mgmt ECR)
resource "aws_iam_role_policy" "lambda_ecr" {
  name = "ECR-CrossAccount-Pull"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
}

# ---------- SSM Parameters (secrets) ----------

resource "aws_ssm_parameter" "api_key" {
  name  = "/lambda/truthifi-endpoint/API_KEY"
  type  = "SecureString"
  value = var.truthifi_api_key

  tags = {
    Name        = "truthifi-endpoint-api-key"
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "hmac_secret" {
  name  = "/lambda/truthifi-endpoint/HMAC_SECRET"
  type  = "SecureString"
  value = var.truthifi_hmac_secret

  tags = {
    Name        = "truthifi-endpoint-hmac-secret"
    Environment = var.environment
  }
}

# ---------- CloudWatch Log Group ----------

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/truthifi-endpoint"
  retention_in_days = 30

  tags = {
    Name        = "/aws/lambda/truthifi-endpoint"
    Environment = var.environment
  }
}

# ---------- Lambda Function ----------

resource "aws_lambda_function" "truthifi_endpoint" {
  function_name = "truthifi-endpoint"
  package_type  = "Image"
  image_uri     = "${var.ecr_mgmt_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/wholefin-platform-truthifi-endpoint:latest"
  role          = aws_iam_role.lambda_role.arn
  architectures = ["x86_64"]
  memory_size   = 128
  timeout       = 3

  environment {
    variables = {
      ENVIRONMENT = var.environment
      API_KEY     = aws_ssm_parameter.api_key.value
      HMAC_SECRET = aws_ssm_parameter.hmac_secret.value
    }
  }

  ephemeral_storage {
    size = 512
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy_attachment.lambda_basic
  ]

  tags = {
    Name        = "truthifi-endpoint"
    Environment = var.environment
  }
}

# ---------- Lambda Function URL ----------

resource "aws_lambda_function_url" "truthifi_endpoint" {
  function_name      = aws_lambda_function.truthifi_endpoint.function_name
  authorization_type = "NONE"
  invoke_mode        = "BUFFERED"
}
