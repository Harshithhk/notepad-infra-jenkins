variable "subnet_id" {}
variable "availability_zone" {}
variable "jenkins_ami" {}
variable "instance_type" {}
variable "infra_zone" {}
variable "infra_domain" {}
variable "jenkins_dns_ttl" {
  type = number
}

resource "aws_iam_role" "tf_jenkins_role" {
  name = "tf_jenkins_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "tf_jenkins_admin_policy" {
  role       = aws_iam_role.tf_jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "tf_jenkins_instance_profile" {
  name = "tf_jenkins_instance_profile"
  role = aws_iam_role.tf_jenkins_role.name
}

resource "aws_instance" "tf_jenkins" {
  ami                  = var.jenkins_ami
  availability_zone    = var.availability_zone
  instance_type        = var.instance_type
  subnet_id            = var.subnet_id
  iam_instance_profile = aws_iam_instance_profile.tf_jenkins_instance_profile.name

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "tf-jenkins"
  }

  depends_on = [aws_iam_instance_profile.tf_jenkins_instance_profile]
}

resource "aws_eip" "jenkins_eip" {
  domain = "vpc"
}

data "aws_route53_zone" "infra_zone" {
  zone_id = var.infra_zone
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.tf_jenkins.id
  allocation_id = aws_eip.jenkins_eip.id

  depends_on = [aws_instance.tf_jenkins]
}

resource "aws_route53_record" "jenkins_dns_rec" {
  zone_id = data.aws_route53_zone.infra_zone.zone_id
  name    = var.infra_domain
  type    = "A"
  ttl     = var.jenkins_dns_ttl
  records = [aws_eip.jenkins_eip.public_ip]
}

output "jenkins_public_ip" {
  value = aws_eip.jenkins_eip.public_ip
}

output "jenkins_dns_name" {
  value = aws_route53_record.jenkins_dns_rec.fqdn
}
