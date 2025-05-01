data "aws_vpc" "existing_vpc" {
  id = "vpc-07dc691f9545da378"
}

data "aws_security_group" "existing_sg" {
  id = "sg-0217477fe759492e7"
}

module "alb" {
  source                     = "./module"
  name                       = "alb-test"
  alb_count                  = 1
  vpc_id                     = data.aws_vpc.existing_vpc.id
  security_group_id          = data.aws_security_group.existing_sg.id
  subnets                    = ["subnet-064354fcd6d2e09de", "subnet-09367abf14419c0d8"]
  internal                   = false
  enable_deletion_protection = false
  target_group_port          = 80
  tags                       = { env = "test" }
}
