resource "aws_s3_bucket" "zomboid" {
  bucket_prefix = local.name
  acl           = "private"
  tags          = local.tags
}

resource "aws_s3_bucket_public_access_block" "zomboid" {
  bucket                  = aws_s3_bucket.zomboid.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object" "zomboid_service" {
  bucket         = aws_s3_bucket.zomboid.id
  key            = "/zomboid.service"
  content_base64 = base64encode(templatefile("${path.module}/local/zomboid.service", { username = local.username }))
  etag           = filemd5("${path.module}/local/zomboid.service")
}

resource "aws_s3_bucket_object" "servertest" {
  bucket         = aws_s3_bucket.zomboid.id
  key            = "/servertest.ini"
  content_base64 = base64encode(templatefile("${path.module}/local/servertest.ini", { username = local.username }))
  etag           = filemd5("${path.module}/local/servertest.ini")
}
resource "aws_s3_bucket_object" "ProjectZomboid64" {
  bucket         = aws_s3_bucket.zomboid.id
  key            = "/ProjectZomboid64.json"
  content_base64 = base64encode(templatefile("${path.module}/local/ProjectZomboid64.json", { username = local.username }))
  etag           = filemd5("${path.module}/local/ProjectZomboid64.json")
}
