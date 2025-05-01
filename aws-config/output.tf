output "s3_bucket_arn" {
  description = "The ARN of the AWS Config S3 bucket."
  value       = aws_s3_bucket.new_config_bucket.arn
}

output "config_role_arn" {
  description = "The ARN of the IAM role for AWS Config."
  value       = aws_iam_role.config_role.arn
}
