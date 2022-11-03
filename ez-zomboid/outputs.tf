output "monitoring_url" {
  value       = module.main.monitoring_url
  description = "URL to monitor the zomboid Server"
}

output "bucket_id" {
  value       = module.main.bucket_id
  description = "The S3 bucket name"
}

output "instance_id" {
  value       = module.main.instance_id
  description = "The EC2 instance ID"
}

output "ec2_public_ip" {
  value       = module.main.public_ip
  description = "Instance Public IP Address"
}
