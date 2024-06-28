variable "region" {
  description = "The AWS region to deploy resources."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for the public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for the private subnets."
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones."
  type        = list(string)
}

variable "vpc_name" {
  description = "The name of the VPC."
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances."
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instances."
  type        = string
}




variable "my_key" {
  description = "The name of the existing AWS key pair."
  type        = string
  default = "my_key"
}



