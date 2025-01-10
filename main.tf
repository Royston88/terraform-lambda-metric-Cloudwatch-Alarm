# Configure the CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_alarm" {
  alarm_name          = "lambda-error-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "LambdaErrors"  
  namespace          = "CustomMetrics"  
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "This metric monitors lambda errors from logs"
  alarm_actions      = [
    aws_sns_topic.alarm_topic.arn,
    "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.target_lambda_function_name}"
    ]

  dimensions = {
    FunctionName = var.lambda_function_name
  }
}

#SNS Topic for notifications
resource "aws_sns_topic" "alarm_topic" {
  name = "lambda-alarm-topic"
}

# SNS Topic Subscription for email notifications
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

#SNS Topic Policy
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.alarm_topic.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchAlarmPublish"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.alarm_topic.arn
      }
    ]
  })
}

# Add permission for CloudWatch to invoke a Second Lambda in response to Alarm
resource "aws_lambda_permission" "cloudwatch_lambda" {
  statement_id  = "AllowCloudWatchInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.target_lambda_function_name
  principal     = "lambda.alarms.cloudwatch.amazonaws.com"
  source_arn    = aws_cloudwatch_metric_alarm.lambda_alarm.arn
}

# Variables
variable "lambda_function_name" {
  description = "Name of the Lambda function to monitor"
  type        = string
}

variable "target_lambda_function_name" {
  description = "Name of the Lambda function to trigger when alarm fires"
  type        = string
}

variable "alarm_email" {
  description = "Email address to receive alarm notifications"
  type        = string
}
