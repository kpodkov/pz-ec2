output "instance_id" {
  value = aws_instance.zomboid.id
}

output "zomboid_user_passwords" {
  value = {for i in aws_iam_user_login_profile.zomboid_user : i.user => i.encrypted_password}
}

output "monitoring_url" {
  value = format("%s%s%s", "http://", var.domain != "" ? aws_route53_record.zomboid[0].fqdn : aws_instance.zomboid.public_dns, ":19999")
}

output "bucket_id" {
  value = data.aws_s3_bucket.zomboid.id
}

output "public_ip" {
  value = aws_instance.zomboid.public_ip
}
