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

variable "domain_name" {
  type = string
}

variable "route53_zone_name" {
  type = string
}

variable "container_port" {
  type    = number
  default = 4000
}
