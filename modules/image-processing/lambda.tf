data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "image_launcher" {
  function_name = "${var.service_name}-launcher"
  role = aws_iam_role.lambda_role.arn
  runtime = "nodejs20.x"
  handler = "index.handler"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
  variables = {
    CLUSTER_ARN           = var.cluster_arn
    TASK_DEF_ARN          = aws_ecs_task_definition.image_worker.arn
    SUBNETS               = join(",", var.subnet_ids)
    WORKER_SECURITY_GROUP = aws_security_group.worker_sg.id
    SERVICE_NAME          = var.service_name
  }
}


  timeout = 30
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.image_jobs.arn
  function_name    = aws_lambda_function.image_launcher.arn
  batch_size       = 1
  enabled          = true
}
