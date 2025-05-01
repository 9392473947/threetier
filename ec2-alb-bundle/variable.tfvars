key_name       = "my-key-pair"
secret_name    = "key-pair-test11"
new_disk_count = 2 # Number of EBS volumes to create
new_disks = [
  {
    size              = 8
    availability_zone = "ap-south-1a"
    volume_type       = "gp3"
    iops              = 3000
    throughput        = 125
    encrypted         = true
    device_name       = "/dev/sdg"
  },
  {
    size              = 16
    availability_zone = "ap-south-1b"
    volume_type       = "gp3"
    iops              = 1000
    throughput        = 130
    encrypted         = false
    device_name       = "/dev/sdh"
  }
]

instance_count = 2 # Number of EC2 instances to create

instances = [
  {
    name            = "web-server-1"
    ami_id          = "ami-06791f9213cbb608b" # Replace with your AMI ID
    instance_type   = "t2.micro"
    subnet_id       = "subnet-01c782efdbe0e8693" # Replace with your subnet ID
    role            = "role1"                    # Optional
    security_groups = ["sg-077e8d2618e61877a"]   # Replace with your security group IDs (optional)
    user_data       = <<-EOF
                      #!/bin/bash
                      sudo yum update -y
                      sudo yum install -y nginx
                      sudo systemctl start nginx
                      sudo systemctl enable nginx
                      EOF
    # Ingress rules for first instance
    ingress_rules = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]

    # Egress rules for first instance
    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  },
  {
    name            = "web-server-2"
    ami_id          = "ami-06791f9213cbb608b"
    instance_type   = "t2.micro"
    subnet_id       = "subnet-064354fcd6d2e09de"
    role            = "role2"
    security_groups = ["sg-077e8d2618e61877a"]
    user_data       = <<-EOF
                      #!/bin/bash
                      sudo yum update -y
                      sudo yum install -y nginx
                      sudo systemctl start nginx
                      sudo systemctl enable nginx
                      EOF
    # Ingress rules for second instance
    ingress_rules = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
    # Egress rules for second instance
    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  },

]


# ALB Configuration
create_lb = true # Set to true if you want to create the load balancer, false otherwise

# List of subnets for the load balancer (replace with your actual subnet IDs)
subnets = [
  "subnet-01c782efdbe0e8693",
  "subnet-064354fcd6d2e09de"
]

# VPC Configuration
vpc_id = "vpc-07dc691f9545da378"

alb_ingress_rules = [
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

alb_egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

alb_target_group_name     = "alb-target-group"
alb_target_group_port     = 80
alb_target_group_protocol = "HTTP"
target_type               = "instance"
health_check_path         = "/"
health_check_interval     = 30

alb_attachment_port     = 80
alb_name                = "example-alb"
alb_internal            = false
alb_type                = "application"
listener_port           = 80
listener_protocol       = "HTTP"
listener_default_action = "forward"