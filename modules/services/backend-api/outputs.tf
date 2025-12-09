output "alb_dns" {
  value = aws_lb.alb.dns_name
}

output "service_name" {
  value = aws_ecs_service.service.name
}
