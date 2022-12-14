data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.*-amd64-server-*"]
  }
}

resource "aws_instance" "zomboid" {
  ami               = data.aws_ami.ubuntu.id
  availability_zone = "eu-west-1a"
  instance_type     = var.instance_type
  root_block_device {
    volume_size = 16
  }
  ebs_optimized = true
  user_data     = templatefile("${path.module}/config/userdata.sh", {
    username    = local.username
    bucket      = data.aws_s3_bucket.zomboid.id
    server_name = var.server_name
  })
  iam_instance_profile   = aws_iam_instance_profile.zomboid.name
  vpc_security_group_ids = [aws_security_group.ingress.id]
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  tags       = local.ec2_tags
  depends_on = [
    aws_s3_bucket_object.zomboid_service,
    aws_s3_bucket_object.ProjectZomboid64,
    aws_s3_bucket_object.SandboxVars,
    aws_s3_bucket_object.servertest,
  ]
}

resource "aws_ec2_tag" "zomboid" {
  for_each = local.ec2_tags

  resource_id = aws_instance.zomboid.id
  key         = each.key
  value       = each.value
}

