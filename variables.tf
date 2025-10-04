variable "region" {
  type    = string
  default = "us-east-1"
}

variable "profile" {
  type    = string
  default = "default"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "availability_zone" {
  type    = string
  default = "us-east-1a"
}

variable "default_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "protocol" {
  type    = string
  default = "tcp"
}

variable "http_port" {
  type    = number
  default = 80
}

variable "https_port" {
  type    = number
  default = 443
}

variable "jenkins_egress_protocol" {
  type    = string
  default = "-1"
}

variable "jenkins_egress_from_port" {
  type    = number
  default = 0
}

variable "jenkins_egress_to_port" {
  type    = number
  default = 0
}

variable "jenkins_ami" {
  type    = string
  default = "ami-0ee46d1a595cd0b96"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "infra_zone" {
  type    = string
  default = "Z094675634YJEPV0TLIA3"
}

variable "infra_domain" {
  type    = string
  default = "jenkins.harshithkelkar.com"
}

variable "jenkins_dns_ttl" {
  type    = number
  default = 60
}
