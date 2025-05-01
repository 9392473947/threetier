output "ec2_instance_ids" {
  description = "Map of EC2 instance IDs by key"
  value = { for key, instance in aws_instance.main : key => instance.id }
}

# Output for private IPs from network interfaces
output "assigned_private_ips" {
  description = "Map of assigned private IPs by network interface key"
  value = { for key, ni in aws_network_interface.main : key => ni.private_ip }
}