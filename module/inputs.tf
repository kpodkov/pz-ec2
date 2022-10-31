variable "aws_region" { type = string }
variable "aws_admins" { type = map(any) }
variable "domain" { type = string }
#variable "keybase_username" { type = string }
variable "instance_type" { type = string }
variable "sns_email" { type = string }
variable "world_name" { type = string }
variable "server_name" { type = string }
#variable "server_password" { type = string }
variable "environment" { type = string }
variable "unique_id" { type = string }
variable "server_username" { type = string }

locals {
  username = var.server_username
  tags = {
    "Environment"   = var.environment
    "Component" = "PZ Server"
    "CreatedBy" = "Terraform"
  }
  ec2_tags = merge(local.tags,
    {
      "Name"        = "${local.name}-server"
      "Description" = "Instance running a PZ server"
    }
  )
  name = var.server_name
}
