provider "aws" {
  region = var.region
}

resource "aws_sns_topic" "alerts" {
  name = var.alerts_name
}


resource "aws_cloudwatch_metric_alarm" "dynamic_alarm" {
for_each ={
    for id, metric in var.alarm_metrics : "${id}-${metric.instance_id}" => metric
}

  alarm_name          = "${each.key}-${each.value.metric_name}"
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = each.value.alarm_description

  dimensions = {
    InstanceId = each.value.instance_id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}



# Optionally, create an SNS subscription to receive notifications
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  =var.protocol
  endpoint  = "snehapugal2018@gmail.com"  # Replace with your email address
}


resource "aws_flow_log" "main" {
   count           = var.enable_flow_logs ? 1 : 0
  depends_on = [aws_iam_role_policy.main]

  log_destination = aws_cloudwatch_log_group.main.arn
  iam_role_arn    = aws_iam_role.main.arn
  vpc_id          = var.vpc_id
  traffic_type    = "ALL"
}



resource "aws_cloudwatch_log_group" "main" {
  name              = "vpc-flow-logs-${var.vpc_name}"
  retention_in_days = var.logs_retention

  tags = var.tags

}

#
# IAM
#

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "role_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "main" {
  name               = "vpc-flow-logs-role-${var.vpc_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy" "main" {
  name   = "vpc-flow-logs-role-policy-${var.vpc_name}"
  role   = aws_iam_role.main.id
  policy = data.aws_iam_policy_document.role_policy.json
}

# Application logs
resource "aws_cloudwatch_log_group" "application_log_group" {
  count = var.enable_app_log ? 1:0
  name = var.app_name  # Change to your desired log group name

  retention_in_days = 30  # Set retention policy (optional)
}

# Create a CloudWatch Log Stream within the log group
resource "aws_cloudwatch_log_stream" "application_log_stream" {
  name           ="app-flow-${var.vpc_name}"
  count = var.enable_app_log ? 1:0 # Change to your desired log stream name
 log_group_name = aws_cloudwatch_log_group.application_log_group[count.index].name
}

# Create an IAM role that allows your application to write logs to CloudWatch
resource "aws_iam_role" "application_logging_role" {
  name = "app-flow-${var.vpc_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"  # Change if using a different service
        }
      }
    ]
  })
}