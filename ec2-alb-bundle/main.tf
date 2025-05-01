provider "aws" {
  region = "ap-south-1"
}

module "ec2" {
  source = "./modules"

  key_name       = var.key_name
  secret_name    = var.secret_name
  new_disk_count = var.new_disk_count
  new_disks      = var.new_disks
  instance_count = var.instance_count
  instances      = var.instances
  create_lb       = var.create_lb
  subnets         = var.subnets
  vpc_id          = var.vpc_id
  alb_ingress_rules = var.alb_ingress_rules
  alb_egress_rules   = var.alb_egress_rules
  alb_target_group_name     = var.alb_target_group_name
  alb_target_group_port     = var.alb_target_group_port
  alb_target_group_protocol = var.alb_target_group_protocol
  target_type               = var.target_type
  health_check_path         = var.health_check_path
  health_check_interval     = var.health_check_interval
  alb_attachment_port       = var.alb_attachment_port
  alb_name                  = var.alb_name
  alb_internal              = var.alb_internal
  alb_type                  = var.alb_type
  listener_port             = var.listener_port
  listener_protocol         = var.listener_protocol
  listener_default_action   = var.listener_default_action
}
