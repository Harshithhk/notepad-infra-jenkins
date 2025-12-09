resource "aws_vpc" "infra_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "infra_vpc"
  }
}

resource "aws_internet_gateway" "infra_gw" {
  vpc_id = aws_vpc.infra_vpc.id

  tags = {
    Name = "infra_gw"
  }

  depends_on = [aws_vpc.infra_vpc]
}

resource "aws_subnet" "infra_subnet" {
  vpc_id            = aws_vpc.infra_vpc.id
  cidr_block        = var.subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "infra_subnet"
  }

  depends_on = [aws_vpc.infra_vpc]
}
resource "aws_subnet" "infra_subnet_b" {
  vpc_id            = aws_vpc.infra_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "infra_subnet_b"
  }
}

resource "aws_route_table" "infra_rt" {
  vpc_id = aws_vpc.infra_vpc.id

  route {
    cidr_block = var.default_cidr
    gateway_id = aws_internet_gateway.infra_gw.id
  }

  route {
    cidr_block = aws_vpc.infra_vpc.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "tf_route_table"
  }

  depends_on = [aws_vpc.infra_vpc, aws_internet_gateway.infra_gw]
}

resource "aws_route_table_association" "infra_rta" {
  subnet_id      = aws_subnet.infra_subnet.id
  route_table_id = aws_route_table.infra_rt.id

  depends_on = [aws_subnet.infra_subnet, aws_route_table.infra_rt]
}
resource "aws_route_table_association" "infra_rta_b" {
  subnet_id      = aws_subnet.infra_subnet_b.id
  route_table_id = aws_route_table.infra_rt.id
}


resource "aws_main_route_table_association" "infra_vpc_rta" {
  vpc_id         = aws_vpc.infra_vpc.id
  route_table_id = aws_route_table.infra_rt.id

  depends_on = [aws_vpc.infra_vpc, aws_route_table.infra_rt]
}

resource "aws_default_security_group" "infra_dsg" {
  vpc_id = aws_vpc.infra_vpc.id

  ingress {
    protocol    = var.protocol
    self        = true
    from_port   = var.https_port
    to_port     = var.https_port
    cidr_blocks = [var.default_cidr]
  }

  ingress {
    protocol    = var.protocol
    self        = true
    from_port   = var.http_port
    to_port     = var.http_port
    cidr_blocks = [var.default_cidr]
  }

  # TODO TEMP ACCESS
  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH ports
  ingress {
    protocol    = "tcp"
    self        = true
    from_port   = 0
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = var.jenkins_egress_from_port
    to_port     = var.jenkins_egress_to_port
    protocol    = var.jenkins_egress_protocol
    cidr_blocks = [var.default_cidr]
  }

  depends_on = [aws_vpc.infra_vpc]
}
