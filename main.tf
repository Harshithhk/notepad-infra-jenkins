terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

module "network" {
  source = "./modules/network"

  vpc_cidr                 = var.vpc_cidr
  subnet_cidr              = var.subnet_cidr
  availability_zone        = var.availability_zone
  default_cidr             = var.default_cidr
  protocol                 = var.protocol
  http_port                = var.http_port
  https_port               = var.https_port
  jenkins_egress_protocol  = var.jenkins_egress_protocol
  jenkins_egress_from_port = var.jenkins_egress_from_port
  jenkins_egress_to_port   = var.jenkins_egress_to_port
}

module "jenkins" {
  source = "./modules/jenkins"

  subnet_id         = module.network.subnet_id
  availability_zone = var.availability_zone
  jenkins_ami       = var.jenkins_ami
  instance_type     = var.instance_type
  infra_zone        = var.infra_zone
  infra_domain      = var.infra_domain
  jenkins_dns_ttl   = var.jenkins_dns_ttl
}

module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  cluster_name = "notepad-${var.region}"
}

module "backend_api_ecr" {
  source = "./modules/ecr"
  repository_name = "backend-api"
}

module "image_processing_ecr" {
  source = "./modules/ecr"
  repository_name = "image-processing"
}

module "backend_api" {
  source = "./modules/services/backend-api"

  service_name = "backend-api"
  cluster_arn  = module.ecs_cluster.cluster_arn
  vpc_id       = module.network.vpc_id
  subnet_ids = module.network.public_subnet_ids
  image_url = "${module.backend_api_ecr.repository_url}:latest"

  domain_name         = "api.notepad-minus-minus.harshithkelkar.com"
  route53_zone_name  = "harshithkelkar.com."
}


output "jenkins_public_ip" {
  value = module.jenkins.jenkins_public_ip
}

output "jenkins_dns_name" {
  value = module.jenkins.jenkins_dns_name
}


