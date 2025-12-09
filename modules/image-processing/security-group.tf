resource "aws_security_group" "worker_sg" {
  name   = "${var.service_name}-worker-sg"
  vpc_id = var.vpc_id

  # Workers do NOT accept inbound traffic
  # (Lambda just starts them; no ALB, no ports)

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Service = var.service_name
    Role    = "worker"
  }
}
