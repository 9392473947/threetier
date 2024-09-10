locals {
  # Define local variables for application name and environment
  app_name = var.app_name
  env      = var.env
}
resource "aws_security_group" "main" {
  for_each = var.security_groups
  name     = "${var.env}-${local.app_name}-ec2-sg-${each.key}"
  vpc_id   = each.value.vpc_id
  tags     = merge(var.additional_tags, { Name = "${var.env}-${local.app_name}-ec2-sg-${each.key}" })

  
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound traffic to the world"
  }

    dynamic "ingress" {
    for_each = var.additional_cidrs
    content {
      description = "Traffic from ${ingress.key} CIDRs"
      protocol    = ingress.value.protocol
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      cidr_blocks = ingress.value.cidrs
    }
  }
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = var.vpc_cidrs
  }
}

resource "aws_network_interface" "main" {
  for_each = var.network_interfaces
  subnet_id       = each.value.subnet_id
  security_groups = [aws_security_group.main[each.value.security_group_key].id]
  tags            = each.value.tags
}

resource "aws_iam_role" "test_role" {
  name = var.name
  assume_role_policy = var.assume_role_policy
  }

resource "aws_iam_instance_profile" "test_profile" {
  name = var.name
  role = "${aws_iam_role.test_role.name}"
}
#EC2 Instance
  resource "aws_instance" "main" {
  for_each = var.instance_configs

  ami                 = each.value.ami_id
  instance_type        = each.value.instance_type
  key_name             = each.value.key_name != "" ? each.value.key_name : null
  iam_instance_profile = each.value.iam_instance_profile
  user_data            = file("${path.module}/script.sh")
   
 # associate_public_ip_address = each.value.associate_public_ip_address
   network_interface {
    network_interface_id = aws_network_interface.main[each.value.network_interface_key].id
    device_index         = 0
  }
  tags                 = merge(each.value.additional_tags, { Name = "${local.env}-${local.app_name}-root-ebs-vol" })
  root_block_device {
    volume_size = each.value.volume_size
    encrypted   = true
    volume_type = each.value.volume_type
    #kms_key_id  = var.kms_key_arn
    tags        = merge(var.additional_tags, { Name = "${local.env}-${local.app_name}-root-ebs-vol" })
  }

 dynamic "ebs_block_device" {
    for_each = var.additional_ebs_vol
    content {
      device_name = ebs_block_device.value.device_name
      encrypted   = true
      #kms_key_id  = var.kms_key_arn
      volume_size = lookup(ebs_block_device.value, "volume_size", null)
      volume_type = lookup(ebs_block_device.value, "volume_type", null)
      tags        = merge(var.additional_tags, { Name = "${local.env}-${local.app_name}-${ebs_block_device.key}-ebs-vol" })
    }
  }
  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 3
    http_endpoint               = "enabled"
   
  }
   
}

