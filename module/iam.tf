resource "aws_iam_role" "zomboid" {
  name               = "${local.name}-server"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "ec2.amazonaws.com"
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
  tags = local.tags
}

resource "aws_iam_instance_profile" "zomboid" {
  role = aws_iam_role.zomboid.name
}

resource "aws_iam_role_policy_attachment" "zomboid" {
  role       = aws_iam_role.zomboid.name
  policy_arn = aws_iam_policy.zomboid.arn
}

resource "aws_iam_role_policy_attachment" "zomboid_cname" {
  count = var.domain != "" ? 1 : 0

  role       = aws_iam_role.zomboid.name
  policy_arn = aws_iam_policy.zomboid_cname[0].arn
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.zomboid.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#tfsec:ignore:aws-iam-enforce-mfa
resource "aws_iam_group" "zomboid_users" {
  name = "${local.name}-users"
  path = "/users/"
}


resource "aws_iam_group_policy_attachment" "zomboid_users" {
  group      = aws_iam_group.zomboid_users.name
  policy_arn = aws_iam_policy.zomboid_users.arn
}

resource "aws_iam_user" "zomboid_user" {
  #checkov:skip=CKV2_AWS_22:We want users to be able to access the console
  for_each = var.admins

  name          = each.key
  path          = "/"
  force_destroy = true
  tags          = local.tags
}

resource "aws_iam_user_login_profile" "zomboid_user" {
  for_each = aws_iam_user.zomboid_user

  user    = aws_iam_user.zomboid_user[each.key].name
  pgp_key = "keybase:${var.keybase_username}"
}

resource "aws_iam_user_group_membership" "zomboid_users" {
  for_each = aws_iam_user.zomboid_user

  user   = aws_iam_user.zomboid_user[each.key].name
  groups = [aws_iam_group.zomboid_users.name]
}

