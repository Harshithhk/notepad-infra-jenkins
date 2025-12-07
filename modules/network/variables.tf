variable "vpc_cidr" {
  type = string
}

variable "subnet_cidr" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "default_cidr" {
  type = string
}

variable "protocol" {
  type = string
}

variable "http_port" {
  type = number
}

variable "https_port" {
  type = number
}

variable "jenkins_egress_protocol" {
  type = string
}

variable "jenkins_egress_from_port" {
  type = number
}

variable "jenkins_egress_to_port" {
  type = number
}
