resource "aws_cloudwatch_log_group" "worker_logs" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = 7
}

resource "aws_secretsmanager_secret" "anthropic_api_key" {
  name = "${var.service_name}/ANTHROPIC_API_KEY"
}

resource "aws_iam_role_policy" "ecs_execution_secrets" {
  name = "ecs-execution-secrets"
  role = aws_iam_role.ecs_execution_role.id

  policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = [
        aws_secretsmanager_secret.anthropic_api_key.arn
      ]
    }
  ]
  })
}

resource "aws_ecs_task_definition" "image_worker" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = var.service_name
    image     = "${var.image_repo_url}:latest"
    essential = true

    secrets = [
      {
        name = "ANTHROPIC_API_KEY"
        valueFrom = aws_secretsmanager_secret.anthropic_api_key.arn
      }
    ]

    environment = [
    {
      name  = "MONGO_URI"
      value = "mongodb+srv://swapnil:root@cluster0.zh8lu.mongodb.net/notepad_minus_minus?retryWrites=true&w=majority&appName=Cluster0"
    },
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.worker_logs.name
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "worker"
      }
    }
  }])
}
