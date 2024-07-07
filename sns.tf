resource "aws_sns_topic" "stepfunctions_notifications" {
  name = "stepfunctions-notifications"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.stepfunctions_notifications.arn
  protocol  = "email"
  endpoint  = "milestone0619@gmail.com"
}