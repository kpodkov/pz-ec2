data "aws_s3_bucket" "zomboid" {
  bucket = "project-zomboid-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_public_access_block" "zomboid" {
  bucket                  = data.aws_s3_bucket.zomboid.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object" "zomboid_service" {
  bucket         = data.aws_s3_bucket.zomboid.id
  key            = "/${var.server_name}/zomboid.service"
  content_base64 = base64encode(templatefile("${path.module}/config/zomboid.service", {
    username = local.username, bucket = data.aws_s3_bucket.zomboid.id, server_name = var.server_name
  }))
  etag = filemd5("${path.module}/config/zomboid.service")
}

resource "aws_s3_bucket_object" "servertest" {
  bucket         = data.aws_s3_bucket.zomboid.id
  key            = "/${var.server_name}/${var.server_name}.ini"
  content_base64 = base64encode(templatefile("${path.module}/config/servertest.ini", { username = local.username }))
  etag           = filemd5("${path.module}/config/servertest.ini")
}
resource "aws_s3_bucket_object" "ProjectZomboid64" {
  bucket         = data.aws_s3_bucket.zomboid.id
  key            = "/${var.server_name}/ProjectZomboid64.json"
  content_base64 = base64encode(templatefile("${path.module}/config/ProjectZomboid64.json", {
    username = local.username
  }))
  etag = filemd5("${path.module}/config/ProjectZomboid64.json")
}


resource "aws_s3_bucket_object" "SandboxVars" {
  bucket         = data.aws_s3_bucket.zomboid.id
  key            = "/${var.server_name}/${var.server_name}_SandboxVars.lua"
  content_base64 = base64encode(templatefile("${path.module}/config/servertest_SandboxVars.lua", {
    username = local.username
  }))
  etag = filemd5("${path.module}/config/servertest_SandboxVars.lua")
}
