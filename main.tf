terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
      archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
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

module "auth_service_ecr" {
  source = "./modules/ecr"
  repository_name = "auth-service"
}

module "frontend_service_ecr" {
  source = "./modules/ecr"
  repository_name = "frontend-service"
}


module "image_processing" {
  source = "./modules/image-processing"

  service_name   = "image-processing"
  vpc_id         = module.network.vpc_id
  cluster_arn    = module.ecs_cluster.cluster_arn
  subnet_ids     = module.network.public_subnet_ids
  image_repo_url = module.image_processing_ecr.repository_url
}

module "backend_api" {
  source = "./modules/services/backend-api"
  container_port = 4001
  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }

  service_name = "backend-api"
  cluster_arn  = module.ecs_cluster.cluster_arn
  vpc_id       = module.network.vpc_id
  subnet_ids   = module.network.public_subnet_ids

  image_url = "${module.backend_api_ecr.repository_url}:latest"

  domain_name        = "api.notepad-minus-minus.harshithkelkar.com"
  route53_zone_name = "harshithkelkar.com."
}


module "auth_service" {
  source = "./modules/services/auth-service"

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }

  service_name = "auth-service"
  cluster_arn  = module.ecs_cluster.cluster_arn
  vpc_id       = module.network.vpc_id
  subnet_ids   = module.network.public_subnet_ids

  image_url = "${module.auth_service_ecr.repository_url}:latest"

  domain_name        = "auth.notepad-minus-minus.harshithkelkar.com"
  route53_zone_name = "harshithkelkar.com."
}


module "frontend_service" {
  source = "./modules/services/frontend-service"

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }

  service_name = "frontend-service"
  cluster_arn  = module.ecs_cluster.cluster_arn
  vpc_id       = module.network.vpc_id
  subnet_ids   = module.network.public_subnet_ids

  image_url = "${module.frontend_service_ecr.repository_url}:latest"

  domain_name        = "app.notepad-minus-minus.harshithkelkar.com"
  route53_zone_name = "harshithkelkar.com."
}




output "jenkins_public_ip" {
  value = module.jenkins.jenkins_public_ip
}

output "jenkins_dns_name" {
  value = module.jenkins.jenkins_dns_name
}


