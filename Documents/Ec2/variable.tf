variable "env" {
  type = string
}

variable "app_name" {
  type = string
}
/*variable "vpc_id" {
  description = "A map of security group configurations"
  type = string
  
}*/
variable "security_groups" {
  description = "Map of security groups to create."
  type = map(object({
    vpc_id = string
  }))
}

variable "network_interfaces" {
  description = "Map of network interfaces to create."
  type = map(object({
    subnet_id         = string
    security_group_key = string
    tags              = map(string)
  }))
}

variable "vpc_cidrs" {
  type = list(string)
}

variable "additional_tags" {
 type = map(string)
}

variable "additional_cidrs" {
  type = map(object({
    cidrs     = list(string),
    from_port = number,
    to_port   = number,
    protocol  = string
  }))
}
variable "additional_ebs_vol" {
  type = map(object({
    device_name = string,
    volume_size = number,
    volume_type = string
  }))
  default = {}
}
variable "name" {
  type=string
}



variable "assume_role_policy" {
  type=string
}
/*variable "subnet_id" {
  type=string
}*/


variable "instance_configs" {
  type = map(object({
    ami_id                  = string
    instance_type           = string
    key_name                = string
    iam_instance_profile    = string
    associate_public_ip_address = bool
    network_interface_key =string
    subnet_id               =string
    env                     = string
    app_name                = string
    additional_tags         = map(string)
    volume_size             =number
    volume_type             = string
  }))
}
/*variable "network_interface" {
  description = "Map of network interfaces to create"
  type = map(object({
    subnet_id         = string
   # security_group_key = string
    #tags              = map(string)
  }))
}*/
