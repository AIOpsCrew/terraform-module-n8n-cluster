# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-cluster"
      Environment = var.environment
    }
  )
}

# ECS Task Definition
resource "aws_ecs_task_definition" "n8n" {
  family                   = "${var.project_name}-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.n8n_cpu
  memory                   = var.n8n_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "n8n"
      image     = var.n8n_image
      essential = true

      portMappings = [
        {
          containerPort = 5678
          protocol      = "tcp"
        }
      ]

      environment = concat([
        {
          name  = "N8N_PORT"
          value = "5678"
        },
        {
          name  = "N8N_PROTOCOL"
          value = "https"
        },
        {
          name  = "N8N_HOST"
          value = var.enable_custom_domain ? var.domain_name : aws_lb.main.dns_name
        },
        {
          name  = "WEBHOOK_URL"
          value = var.enable_custom_domain ? "https://${var.domain_name}/" : "https://${aws_lb.main.dns_name}/"
        },
        {
          name  = "DB_TYPE"
          value = "postgresdb"
        },
        {
          name  = "DB_POSTGRESDB_HOST"
          value = aws_rds_cluster.main.endpoint
        },
        {
          name  = "DB_POSTGRESDB_PORT"
          value = "5432"
        },
        {
          name  = "DB_POSTGRESDB_DATABASE"
          value = var.db_name
        },
        {
          name  = "DB_POSTGRESDB_USER"
          value = var.db_username
        },
        {
          name  = "EXECUTIONS_MODE"
          value = "regular"
        },
        {
          name  = "N8N_BASIC_AUTH_ACTIVE"
          value = var.n8n_basic_auth_active ? "true" : "false"
        }
        ],
        var.n8n_basic_auth_active ? [
          {
            name  = "N8N_BASIC_AUTH_USER"
            value = var.n8n_basic_auth_user
          }
        ] : []
      )

      secrets = concat([
        {
          name      = "N8N_ENCRYPTION_KEY"
          valueFrom = aws_secretsmanager_secret.n8n_encryption_key.arn
        },
        {
          name      = "DB_POSTGRESDB_PASSWORD"
          valueFrom = aws_secretsmanager_secret.db_password.arn
        }
        ],
        var.n8n_basic_auth_active ? [
          {
            name      = "N8N_BASIC_AUTH_PASSWORD"
            valueFrom = aws_secretsmanager_secret.n8n_basic_auth_password[0].arn
          }
        ] : []
      )

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.n8n.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "n8n"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:5678/healthz || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-task"
      Environment = var.environment
    }
  )
}

# ECS Service
resource "aws_ecs_service" "n8n" {
  name            = "${var.project_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.n8n.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.n8n.arn
    container_name   = "n8n"
    container_port   = 5678
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  health_check_grace_period_seconds = 60

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-service"
      Environment = var.environment
    }
  )

  depends_on = [
    aws_lb_listener.https,
    aws_lb_listener.http
  ]
}

# Data source for current AWS region
data "aws_region" "current" {}
