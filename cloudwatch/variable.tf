variable "vpc_id" {
  description = "VPC ID to attach to."
  type        = string
}
variable "region" {
  description = "region."
  type        = string
}
variable "alerts_name" {
  description = "VPC ID to attach to."
  type        = string
}
variable "protocol" {
  description = "The protocol type to contact"
  type        = string
}

variable "vpc_name" {
  description = "The VPC name is used to name the flow log resources."
  type        = string
}

variable "logs_retention" {
  description = "Number of days you want to retain log events in the log group."
  default     = 90
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}


variable "alarm_metrics" {
  type = map(object({
    metric_name         = string
    namespace           = string
    comparison_operator = string
    threshold           = number
    statistic           = string
    period              = number
    evaluation_periods  = number
    alarm_description   = string
    instance_id         = string
  }))
}

variable "enable_flow_logs" {
  description = "Enable flow logs or not"
  type        = bool
}
variable "enable_app_log" {
  description = "Enable app flow logs or not"
  type        = bool
}
variable "app_name" {
  description = "log name for application"
  type        = string
}