variable "service_name" {
  type = string
}

variable "cluster_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "image_url" {
  type = string
}

variable "container_port" {
  type    = number
  default = 3000
}
variable "domain_name" {
  type        = string
  description = "Custom domain for backend API"
}

variable "route53_zone_name" {
  type        = string
  description = "Route53 hosted zone (example: harshithkelkar.com.)"
}
