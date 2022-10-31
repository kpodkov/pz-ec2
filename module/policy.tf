resource "aws_s3_bucket_policy" "zomboid" {
  bucket = data.aws_s3_bucket.zomboid.id
  policy = jsonencode({
    Version : "2012-10-17",
    Id : "PolicyForzomboidBackups",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          "AWS" : aws_iam_role.zomboid.arn
        },
        Action : [
          "s3:Put*",
          "s3:Get*",
          "s3:List*"
        ],
        Resource : "arn:aws:s3:::${data.aws_s3_bucket.zomboid.id}/*"
      }
    ]
  })

  // https://github.com/hashicorp/terraform-provider-aws/issues/7628
  depends_on = [aws_s3_bucket_public_access_block.zomboid]
}

resource "aws_iam_policy" "zomboid" {
  name        = "${local.name}-server"
  description = "Allows the zomboid server to interact with various AWS services"
  policy      = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "s3:Put*",
          "s3:Get*",
          "s3:List*"
        ],
        Resource : [
          "arn:aws:s3:::${data.aws_s3_bucket.zomboid.id}",
          "arn:aws:s3:::${data.aws_s3_bucket.zomboid.id}/"
        ]
      },
      {
        Effect : "Allow",
        Action : ["ec2:DescribeInstances"],
        Resource : ["*"]
      }
    ]
  })
}

resource "aws_iam_policy" "zomboid_cname" {
  count = var.domain != "" ? 1 : 0

  name        = "${local.name}-cname"
  description = "Allows the zomboid server to update its own CNAME when recreated"
  policy      = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : ["route53:ChangeResourceRecordSets"],
        Effect : "Allow",
        Resource : ["arn:aws:route53:::hostedzone/${data.aws_route53_zone.selected[0].zone_id}"]
      }
    ]
  })
}

resource "aws_iam_policy" "zomboid_users" {
  name        = "${local.name}-user"
  description = "Allows zomboid users to start the server"
  policy      = jsonencode({
    Version = "2012-10-17"
    "Statement" : [
      {
        Effect : "Allow",
        Action : ["ec2:StartInstances"],
        Resource : "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:instance/${aws_instance.zomboid.id}",
      },
      {
        Effect : "Allow",
        Action : [
          "cloudwatch:DescribeAlarms",
          "ec2:DescribeAddresses",
          "ec2:DescribeInstanceAttribute",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstances",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeNetworkInterfaces",
          "iam:ChangePassword"
        ]
        Resource : "*"
      }
    ]
  })
}