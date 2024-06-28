region               = "us-west-2"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones   = ["us-west-2a", "us-west-2b"]
vpc_name             = "myvpc"
ami_id               = "ami-0b20a6f09484773af"
instance_type        = "t3.micro"

