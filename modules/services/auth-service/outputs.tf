output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "ecs_service_name" {
  value = aws_ecs_service.service.name
}