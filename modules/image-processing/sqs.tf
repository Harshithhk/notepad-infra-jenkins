resource "aws_sqs_queue" "image_jobs" {
  name                       = "${var.service_name}-queue"
  visibility_timeout_seconds = var.queue_visibility_timeout

  tags = {
    Service = var.service_name
  }
}
