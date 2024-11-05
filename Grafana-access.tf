locals {
  grafana_account_id = "008923505280"
}

variable "external_id" {
  type        = string
  description = "This is your Grafana Cloud identifier and is used for security purposes."
  validation {
    condition     = length(var.external_id) > 0
    error_message = "ExternalID is required."
  }
}

variable "iam_role_name" {
  type        = string
  default     = "GrafanaLabsCloudWatchIntegration"
  description = "Customize the name of the IAM role used by Grafana for the CloudWatch integration."
}

# Trust policy for Grafana integration
data "aws_iam_policy_document" "trust_grafana" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.grafana_account_id}:root"]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.external_id]
    }
  }
}

# IAM Role for Grafana CloudWatch Integration
resource "aws_iam_role" "grafana_role" {
  name               = var.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.trust_grafana.json
}

# Policy for CloudWatch permissions
resource "aws_iam_policy" "grafana_cloudwatch_policy" {
  name   = "GrafanaCloudWatchPolicy"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "tag:GetResources",
        "cloudwatch:GetMetricData",
        "cloudwatch:ListMetrics",
        "apigateway:GET",
        "aps:ListWorkspaces",
        "autoscaling:DescribeAutoScalingGroups",
        "dms:DescribeReplicationInstances",
        "dms:DescribeReplicationTasks",
        "ec2:DescribeTransitGatewayAttachments",
        "ec2:DescribeSpotFleetRequests",
        "shield:ListProtections",
        "storagegateway:ListGateways",
        "storagegateway:ListTagsForResource"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

# Attach policy to Grafana role
resource "aws_iam_role_policy_attachment" "grafana_cloudwatch_attachment" {
  role       = aws_iam_role.grafana_role.name
  policy_arn = aws_iam_policy.grafana_cloudwatch_policy.arn
}

# manager-specific policy attachment
resource "aws_iam_user_policy_attachment" "manager_cloudwatch_access" {
  user       = aws_iam_user.manager.name
  policy_arn = aws_iam_policy.grafana_cloudwatch_policy.arn
}