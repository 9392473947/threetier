provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}
# Public Subnets
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.availability_zones, count.index)
  tags = {
    Name = "Public Subnet"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name = "Private Subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "Internet Gateway"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Public Route Table"
  }
}

# Route Table Association for Public Subnets
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}


# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {

  tags = {
    Name = "NAT EIP"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  tags = {
    Name = "NAT Gateway"
  }
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = "Private Route Table"
  }
}

# Route Table Association for Private Subnets
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

# Security Group for Public Instances
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.myvpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Public Security Group"
  }
}

# Security Group for Private Instances
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.myvpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Private Security Group"
  }
}

# Load Balancer
resource "aws_lb" "my_lb" {
  name               = "my-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "My Load Balancer"
  }
}

# Target Group
resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "My Target Group"
  }
}

# Listener
resource "aws_lb_listener" "my_lb_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}



# Public Instance
resource "aws_instance" "public_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = element(aws_subnet.public.*.id, 0)
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  key_name               = var.my_key
  tags = {
    Name = "Public Instance"
  }
}
# Private Instance with Tomcat Installation and NAT Gateway Configuration
resource "aws_instance" "private_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = element(aws_subnet.private.*.id, 0)
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = var.my_key
  tags = {
    Name = "Private Instance"
  }
}

# Register Private Instance with Target Group
resource "aws_lb_target_group_attachment" "tg_attachment" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.private_instance.id
  port             = 8080
}


