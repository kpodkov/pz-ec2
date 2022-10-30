#tfsec:ignore:AWS016
resource "aws_sns_topic" "zomboid" {
  #checkov:skip=CKV_AWS_26:CloudWatch can't publish messages to encrypted topics - https://aws.amazon.com/premiumsupport/knowledge-center/cloudwatch-receive-sns-for-alarm-trigger/
  name = "${local.name}-status"
  tags = local.tags
}

#resource "aws_sns_topic_subscription" "zomboid" {
#  topic_arn = aws_sns_topic.zomboid.arn
#  protocol  = "email"
#  endpoint  = var.sns_email
#}

data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_metric_alarm" "zomboid_stopped" {
  alarm_name          = "${local.name}-stopped"
  alarm_description   = "Will stop the zomboid server after a period of inactivity"
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = "3"
  evaluation_periods  = "3"
  metric_name         = "NetworkIn"
  period              = "300"
  statistic           = "Average"
  namespace           = "AWS/EC2"
  threshold           = "50000"
  alarm_actions = [
    aws_sns_topic.zomboid.arn,
    "arn:aws:swf:${var.aws_region}:${data.aws_caller_identity.current.account_id}:action/actions/AWS_EC2.InstanceId.Stop/1.0",
  ]
  dimensions = { "InstanceId" = aws_instance.zomboid.id }
  tags       = local.tags
}

resource "aws_cloudwatch_event_rule" "zomboid_started" {
  name        = "${local.name}-started"
  description = "Used to trigger notifications when the zomboid server starts"
  event_pattern = jsonencode({
    source : ["aws.ec2"],
    "detail-type" : ["EC2 Instance State-change Notification"],
    detail : {
      state : ["pending"],
      "instance-id" : [aws_instance.zomboid.id]
    }
  })
  tags = local.tags
}

resource "aws_cloudwatch_event_target" "zomboid_started" {
  rule      = aws_cloudwatch_event_rule.zomboid_started.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.zomboid.arn
  input_transformer {
    input_paths = {
      "account"     = "$.account"
      "instance-id" = "$.detail.instance-id"
      "region"      = "$.region"
      "state"       = "$.detail.state"
      "time"        = "$.time"
    }
    input_template = "\"At <time>, the status of your EC2 instance <instance-id> on account <account> in the AWS Region <region> has changed to <state>.\""
  }
}

data "aws_route53_zone" "selected" {
  count = var.domain != "" ? 1 : 0

  name = "${var.domain}."
}

resource "aws_route53_record" "zomboid" {
  #checkov:skip=CKV2_AWS_23:Broken - https://github.com/bridgecrewio/checkov/issues/1359
  count = var.domain != "" ? 1 : 0

  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = local.name
  type    = "CNAME"
  ttl     = "300"
  records = [aws_instance.zomboid.public_dns]
}

