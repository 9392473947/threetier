variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
}

variable "instances" {
  description = "List of EC2 instance configurations"
  type = list(object({
    name            = string
    ami_id          = string
    instance_type   = string
    subnet_id       = string
    security_groups = list(string)
    role            = string
    security_groups = list(string) # Optional if attaching additional SGs
    ingress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
    egress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
    user_data = string
  }))
}
variable "new_disk_count" {
  description = "Number of EBS volumes to create"
  type        = number
}

variable "new_disks" {
  description = "List of EBS volumes with size, availability zone, volume type, IOPS, throughput, encryption, and device name"
  type = list(object({
    size              = number
    availability_zone = string
    volume_type       = string
    iops              = number
    throughput        = number
    encrypted         = bool
    device_name       = string
  }))
}

variable "key_name" {
  description = "The name of the AWS key pair"
  type        = string
}

variable "rsa_bits" {
  description = "Number of bits for the RSA key"
  type        = number
  default     = 4096
}

variable "algorithm" {
  description = "The algorithm to use for key generation"
  type        = string
  default     = "RSA"
}

variable "secret_name" {
  description = "The name of the secret in Secrets Manager"
  type        = string
}

variable "create_lb" {
  description = "Whether to create the load balancer"
  type        = bool
  default     = false
}

variable "subnets" {
  description = "List of subnets for the load balancer"
  type        = list(string)
  default     = []
}


variable "vpc_id" {
  description = "VPC Id"
}

variable "alb_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "List of ingress rules for ALB"
}

variable "alb_egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "List of egress rules for ALB"
}

variable "alb_target_group_name" {
  type        = string
  description = "Name of the target group"
}

variable "alb_target_group_port" {
  type        = number
  description = "Port for the target group"
}

variable "alb_target_group_protocol" {
  type        = string
  description = "Protocol for the target group"
}

variable "target_type" {
  type        = string
  description = "Target type for the target group"
}

variable "health_check_path" {
  type        = string
  description = "Health check path"
}

variable "health_check_interval" {
  type        = number
  description = "Health check interval"
}

variable "alb_attachment_port" {
  type        = number
  description = "Port for the target group attachment"
}

variable "alb_name" {
  type        = string
  description = "Name of the ALB"
}

variable "alb_internal" {
  type        = bool
  description = "Whether the ALB is internal"
}

variable "alb_type" {
  type        = string
  description = "Type of the load balancer"
}

variable "listener_port" {
  type        = number
  description = "Port for the listener"
}

variable "listener_protocol" {
  type        = string
  description = "Protocol for the listener"
}

variable "listener_default_action" {
  type        = string
  description = "Default action for the listener"
}

variable "custom_tags" {
  type = string
  description = "Custom tags from the tfvars"
}