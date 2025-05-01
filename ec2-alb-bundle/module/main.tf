# Generate the private key using variable inputs
resource "tls_private_key" "my_key_pair" {
  algorithm = var.algorithm
  rsa_bits  = var.rsa_bits
}

# Create the AWS key pair using the public key generated above
resource "aws_key_pair" "my_key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.my_key_pair.public_key_openssh
}

# Create a secret in AWS Secrets Manager to store the private key
resource "aws_secretsmanager_secret" "private_key_secret" {
  name        = var.secret_name
  description = "Private key for AWS Key Pair"

  tags = local.final_tags
}

# Store the private key in the Secrets Manager secret
resource "aws_secretsmanager_secret_version" "private_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.private_key_secret.id
  secret_string = tls_private_key.my_key_pair.private_key_pem
}

# Create EC2 instances dynamically
resource "aws_instance" "web_server" {
  count                  = var.instance_count
  ami                    = var.instances[count.index].ami_id
  instance_type          = var.instances[count.index].instance_type
  subnet_id              = var.instances[count.index].subnet_id
  key_name               = aws_key_pair.my_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.dynamic_sg[count.index].id]
  iam_instance_profile   = aws_iam_instance_profile.dynamic_instance_profiles.name

  # Enable auto-assign public IP
  associate_public_ip_address = false

  tags = local.final_tags
  
  # User data script (example to install Nginx using yum)
  user_data = var.instances[count.index].user_data

  dynamic "root_block_device" {
    for_each = [for disk in var.new_disks : disk if disk.device_name == "/dev/xvda"]

    content {
      delete_on_termination = true
      encrypted             = root_block_device.value.encrypted
      iops                  = root_block_device.value.iops
      volume_size           = root_block_device.value.size
      volume_type           = root_block_device.value.volume_type
      throughput            = root_block_device.value.throughput
    }
  }

  dynamic "ebs_block_device" {
    for_each = [for disk in var.new_disks : disk if disk.device_name != "/dev/xvda"]

    content {
      delete_on_termination = true
      device_name           = ebs_block_device.value.device_name
      encrypted             = ebs_block_device.value.encrypted
      iops                  = ebs_block_device.value.iops
      volume_size           = ebs_block_device.value.size
      volume_type           = ebs_block_device.value.volume_type
      throughput            = ebs_block_device.value.throughput
    }
  }
}

# Dynamically create security groups for each instance with unique rules
resource "aws_security_group" "dynamic_sg" {
  count = var.instance_count

  name        = "${var.instances[count.index].name}-security-group"
  description = "Security group for instance ${count.index + 1}"
  vpc_id      = var.vpc_id

  # Ingress rules (different for each instance)
  dynamic "ingress" {
    for_each = var.instances[count.index].ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  # Egress rules (different for each instance)
  dynamic "egress" {
    for_each = var.instances[count.index].egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}


# Create IAM roles and attach policies dynamically
resource "aws_iam_role" "dynamic_roles" {
  name = "ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_instance_profile" "dynamic_instance_profiles" {
  name = "ec2-instance-profile"
  role = aws_iam_role.dynamic_roles.name
}

# Security group for the ALB (optional, created only if the ALB is created)
resource "aws_security_group" "alb_sg" {
  count = var.create_lb ? 1 : 0 # Create only if create_lb is true

  name        = "${var.instances[count.index].name}-alb-security-group"
  description = "Security group for the ALB"

  dynamic "ingress" {
    for_each = var.alb_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.alb_egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}

# Create Target Group
resource "aws_lb_target_group" "tg" {
  count = var.create_lb ? 1 : 0 # Create only if create_lb is true

  name     = var.alb_target_group_name
  port     = var.alb_target_group_port
  protocol = var.alb_target_group_protocol
  vpc_id   = var.vpc_id

  target_type = var.target_type

  health_check {
    path     = var.health_check_path
    interval = var.health_check_interval
  }
}

# Attach EC2 instance to the target group
resource "aws_lb_target_group_attachment" "tg_attachment" {
  count = var.create_lb ? 1 : 0 # Create only if create_lb is true

  target_group_arn = aws_lb_target_group.tg[0].arn
  target_id        = aws_instance.web_server[count.index].id
  port             = var.alb_attachment_port
}

# Create Load Balancer
resource "aws_lb" "app_lb" {
  count = var.create_lb ? 1 : 0 # Create only if create_lb is true

  name               = var.alb_name
  internal           = var.alb_internal
  load_balancer_type = var.alb_type
  security_groups    = [aws_security_group.alb_sg[0].id]
  subnets            = var.subnets
}

# Create Listener for ALB
resource "aws_lb_listener" "app_lb_listener" {
  count = var.create_lb ? 1 : 0 # Create only if create_lb is true

  load_balancer_arn = aws_lb.app_lb[0].arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    type             = var.listener_default_action
    target_group_arn = aws_lb_target_group.tg[0].arn
  }
}