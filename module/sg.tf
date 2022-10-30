#tfsec:ignore:AWS018
resource "aws_security_group" "ingress" {
  #checkov:skip=CKV2_AWS_5:Broken - https://github.com/bridgecrewio/checkov/issues/1203
  name        = "${local.name}-ingress"
  description = "Security group allowing inbound traffic to the zomboid server"
  tags        = local.tags
}

resource "aws_security_group_rule" "zomboid_ingress" {
  type              = "ingress"
  from_port         = 16261
  to_port           = 16261
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sgr
  security_group_id = aws_security_group.ingress.id
  description       = "Allows traffic to the zomboid server"
}

resource "aws_security_group_rule" "zomboid_ingress_direct" {
  type              = "ingress"
  from_port         = 16262
  to_port           = 16262
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sgr
  security_group_id = aws_security_group.ingress.id
  description       = "Allows traffic to the zomboid dashboard"
}

resource "aws_security_group_rule" "netdata" {
  type              = "ingress"
  from_port         = 19999
  to_port           = 19999
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sgr
  security_group_id = aws_security_group.ingress.id
  description       = "Allows traffic to the Netdata dashboard"
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sgr
  security_group_id = aws_security_group.ingress.id
  description       = "Allow all egress rule for the zomboid server"
}