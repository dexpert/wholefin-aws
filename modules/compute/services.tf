# ===================================================================
# ECS Services - All platform services
# desired_count = 0 (defined but not running)
# Service Discovery enabled for all services
# ===================================================================

locals {
  services = {
    "email-service" = {
      image   = "wholefin-platform-email-service"
      secrets = ["SMTP_SERVER", "SMTP_PORT", "SMTP_USERNAME", "SMTP_PASSWORD", "SMTP_FROM_EMAIL", "SMTP_FROM_NAME", "SUPPORT_EMAIL", "DEV_ALERTS_EMAIL"]
    }
    "account-service" = {
      image   = "wholefin-platform-account-service"
      secrets = ["DOCUMENTS_VOLUME"]
    }
    "truthifi-account-linking-service" = {
      image   = "wholefin-platform-truthifi-account-linking-service"
      secrets = ["TRUTHIFI_BASE_URL", "TRUTHIFI_ORG_TOKEN"]
    }
    "ips-service" = {
      image   = "wholefin-platform-ips-service"
      secrets = ["OPENAI_API_KEY", "DEFAULT_MODEL"]
    }
    "apex-service" = {
      image   = "wholefin-platform-apex-service"
      secrets = ["APEX_SERVER_URI", "APEX_PRIVATE_KEY", "APEX_CORRESPONDENT_ID", "APEX_GROUP_ID", "APEX_PRINCIPAL_APPROVER_ID", "APEX_ACCOUNT_NAME", "APEX_ORGANIZATION", "APEX_ACCOUNT_TYPE", "APEX_API_KEY", "DOCUMENTS_VOLUME"]
    }
    "users-service" = {
      image   = "wholefin-platform-users-service"
      secrets = ["COGNITO_USER_POOL_ID", "COGNITO_CLIENT_ID", "COGNITO_REGION", "COGNITO_CLIENT_SECRET", "APP_LOGIN_URL", "APP_BASE_URL", "INVITE_JWT_SECRET_KEY"]
    }
    "data-service" = {
      image   = "wholefin-platform-data-service"
      secrets = ["ConnectionStrings__DefaultConnection", "ServiceAccount__Id"]
    }
    "analytics-service" = {
      image   = "wholefin-platform-analytics-service"
      secrets = ["SERVICE_ACCOUNT_ID"]
    }
    "agent-service" = {
      image   = "wholefin-platform-agent-service"
      secrets = ["OPENAI_API_KEY", "ANTHROPIC_API_KEY", "DEFAULT_MODEL_PROVIDER", "DEFAULT_MODEL_ID", "DEFAULT_AGENT_NAME", "DEFAULT_TEMPERATURE", "DEFAULT_MAX_TOKENS"]
    }
    "file-service" = {
      image   = "wholefin-platform-file-service"
      secrets = []
    }
  }
}

# ---------- Task Definitions ----------

resource "aws_ecs_task_definition" "services" {
  for_each = local.services

  family                   = each.key
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "2048"
  task_role_arn            = var.ecs_task_role_arn
  execution_role_arn       = var.ecs_execution_role_arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name      = each.key
      image     = "${var.ecr_mgmt_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${each.value.image}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
          name          = "main"
          appProtocol   = "http"
        }
      ]

      environment = [
        { name = "AWS_REGION",  value = var.aws_region },
        { name = "ENVIRONMENT", value = var.environment }
      ]

      secrets = [
        for s in each.value.secrets : {
          name      = s
          valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:secrets"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${each.key}"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = each.key
    Environment = var.environment
  }
}

# ---------- CloudWatch Log Groups ----------

resource "aws_cloudwatch_log_group" "services" {
  for_each = local.services

  name              = "/ecs/${each.key}"
  retention_in_days = 30

  tags = {
    Name        = "/ecs/${each.key}"
    Environment = var.environment
  }
}

# ---------- Service Discovery Services ----------

resource "aws_service_discovery_service" "services" {
  for_each = local.services

  name = each.key

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.internal.id
    dns_records {
      ttl  = 60
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = {
    Name        = each.key
    Environment = var.environment
  }
}

# ---------- ECS Services (desired_count = 0) ----------

resource "aws_ecs_service" "services" {
  for_each = local.services

  name            = each.key
  cluster         = aws_ecs_cluster.platform.id
  task_definition = aws_ecs_task_definition.services[each.key].arn
  desired_count   = 0
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = slice(var.private_subnets, 0, 1) # AZ-a preferred
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.services[each.key].arn
  }

  # Allow manual scaling without TF overriding desired_count
  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }

  tags = {
    Name        = each.key
    Environment = var.environment
  }
}
