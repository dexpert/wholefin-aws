
resource "aws_ecs_cluster" "platform" {
  name = "${var.environment}-wholefin-platform-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


resource "aws_ecs_task_definition" "kong" {
  family                   = "kong"
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
      name      = "kong"
      image     = "${var.ecr_mgmt_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/wholefin-platform-kong:latest"
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
        {
          name      = "COGNITO_JWKS_URL"
          valueFrom = "arn:aws:ssm:${var.aws_region}:${var.account_id}:parameter/COGNITO_JWKS_URL"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/kong"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_service_discovery_private_dns_namespace" "internal" {
  name        = "${var.environment}.wholefin"
  description = "Internal DNS namespace for ${var.environment}"
  vpc         = var.vpc_id
}
/*

resource "aws_service_discovery_service" "email_service" {
  name = "email-service"
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
}

resource "aws_ecs_service" "email_service" {
  name            = "email-service"
  cluster         = aws_ecs_cluster.platform.id
  task_definition = aws_ecs_task_definition.kong.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.email_service.arn
  }
}
*/
/*

resource "aws_service_discovery_service" "account_service" {
  name = "account-service"
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
}

resource "aws_ecs_service" "account_service" {
  name            = "account-service"
  cluster         = aws_ecs_cluster.platform.id
  task_definition = aws_ecs_task_definition.kong.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.account_service.arn
  }
}
*/
/*

resource "aws_service_discovery_service" "truthifi_account_linking_service" {
  name = "truthifi-account-linking-service"
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
}

resource "aws_ecs_service" "truthifi_account_linking_service" {
  name            = "truthifi-account-linking-service"
  cluster         = aws_ecs_cluster.platform.id
  task_definition = aws_ecs_task_definition.kong.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.truthifi_account_linking_service.arn
  }
}
*/
/*

resource "aws_service_discovery_service" "ips_service" {
  name = "ips-service"
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
}

resource "aws_ecs_service" "ips_service" {
  name            = "ips-service"
  cluster         = aws_ecs_cluster.platform.id
  task_definition = aws_ecs_task_definition.kong.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.ips_service.arn
  }
}
*/
/*

resource "aws_service_discovery_service" "apex_service" {
  name = "apex-service"
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
}

resource "aws_ecs_service" "apex_service" {
  name            = "apex-service"
  cluster         = aws_ecs_cluster.platform.id
  task_definition = aws_ecs_task_definition.kong.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.apex_service.arn
  }
}
*/
/*

resource "aws_service_discovery_service" "users_service" {
  name = "users-service"
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
}

resource "aws_ecs_service" "users_service" {
  name            = "users-service"
  cluster         = aws_ecs_cluster.platform.id
  task_definition = aws_ecs_task_definition.kong.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.users_service.arn
  }
}
*/
/*

resource "aws_service_discovery_service" "data_service" {
  name = "data-service"
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
}

resource "aws_ecs_service" "data_service" {
  name            = "data-service"
  cluster         = aws_ecs_cluster.platform.id
  task_definition = aws_ecs_task_definition.kong.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.data_service.arn
  }
}
*/
/*

resource "aws_service_discovery_service" "analytics_service" {
  name = "analytics-service"
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
}

resource "aws_ecs_service" "analytics_service" {
  name            = "analytics-service"
  cluster         = aws_ecs_cluster.platform.id
  task_definition = aws_ecs_task_definition.kong.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.analytics_service.arn
  }
}
*/
/*

resource "aws_service_discovery_service" "agent_service" {
  name = "agent-service"
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
}

resource "aws_ecs_service" "agent_service" {
  name            = "agent-service"
  cluster         = aws_ecs_cluster.platform.id
  task_definition = aws_ecs_task_definition.kong.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.agent_service.arn
  }
}
*/

resource "aws_service_discovery_service" "kong" {
  name = "kong"
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
}

resource "aws_ecs_service" "kong" {
  name            = "kong"
  cluster         = aws_ecs_cluster.platform.id
  task_definition = aws_ecs_task_definition.kong.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    # AZ a preferred (first subnet); fall back to all app subnets if needed.
    subnets          = slice(var.private_subnets, 0, 1)
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.kong.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "kong"
    container_port   = 80
  }
}
/*

resource "aws_service_discovery_service" "file_service" {
  name = "file-service"
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
}

resource "aws_ecs_service" "file_service" {
  name            = "file-service"
  cluster         = aws_ecs_cluster.platform.id
  task_definition = aws_ecs_task_definition.kong.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.file_service.arn
  }
}
*/
