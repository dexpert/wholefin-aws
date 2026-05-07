# ===================================================================
# IAM Roles for ECS - mirrored from wholefin-dev
# ===================================================================

# ---------- S3-ECS custom policy ----------

resource "aws_iam_policy" "s3_ecs" {
  name        = "S3-ECS"
  description = "S3 access for ECS tasks"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::*wholefin*",
          "arn:aws:s3:::*wholefin*/*"
        ]
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# ---------- ECS Task Role ----------

resource "aws_iam_role" "ecs_task_role" {
  name = "ECS-Task-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Effect = "Allow"
        Principal = {
          Service = [
            "ecs-tasks.amazonaws.com",
            "lambda.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "ECS-Task-Role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_s3" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.s3_ecs.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_cognito" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}

resource "aws_iam_role_policy_attachment" "ecs_task_ssm_core" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecs_task_ssm_read" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_secrets" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "ecs_task_eventbridge" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
}

# ---------- ECS Task Execution Role ----------

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAccessToECSForTaskExecutionRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "ecsTaskExecutionRole"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "execution_s3" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.s3_ecs.arn
}

resource "aws_iam_role_policy_attachment" "execution_ecs" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "execution_ssm_read" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "execution_secrets" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# ---------- CloudWatch Log Group for Kong ----------

resource "aws_cloudwatch_log_group" "kong" {
  name              = "/ecs/kong"
  retention_in_days = 30

  tags = {
    Name        = "/ecs/kong"
    Environment = var.environment
  }
}
