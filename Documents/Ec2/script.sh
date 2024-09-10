#!/bin/bash
# Update the package repository
yum update -y
# Install the SSM Agent
yum install -y amazon-ssm-agent
# Start the SSM Agent service
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent