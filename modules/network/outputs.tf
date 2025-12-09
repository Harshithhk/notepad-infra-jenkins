output "subnet_id" {
  value = aws_subnet.infra_subnet.id
}

output "default_security_group_id" {
  value = aws_default_security_group.infra_dsg.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.infra_subnet.id,
    aws_subnet.infra_subnet_b.id
  ]
}

output "vpc_id" {
  value = aws_vpc.infra_vpc.id
}
