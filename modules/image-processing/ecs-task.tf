resource "aws_cloudwatch_log_group" "worker_logs" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = 7
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
