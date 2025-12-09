output "queue_url" {
  description = "URL of the SQS queue that backend should send messages to"
  value       = aws_sqs_queue.image_jobs.id
}

output "queue_arn" {
  description = "ARN of the SQS queue"
  value       = aws_sqs_queue.image_jobs.arn
}

output "task_definition_arn" {
  description = "ECS task definition ARN for the worker"
  value       = aws_ecs_task_definition.image_worker.arn
}
