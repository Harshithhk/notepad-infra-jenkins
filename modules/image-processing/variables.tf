variable "service_name" {
  description = "Logical name for the image processing worker"
  type        = string
  default     = "image-processing"
}

variable "cluster_arn" {
  description = "ECS cluster ARN where the worker tasks will run"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for Fargate tasks"
  type        = list(string)
}

variable "image_repo_url" {
  description = "ECR repository URL for the worker image (without tag)"
  type        = string
}

variable "queue_visibility_timeout" {
  description = "SQS visibility timeout in seconds, must be > max job duration"
  type        = number
  default     = 300
}

variable "vpc_id" {
  description = "VPC ID where the worker tasks will run"
  type        = string
}

