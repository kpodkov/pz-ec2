variable "aws_region" { type = string }
variable "admins" { type = map(any) }
variable "domain" { type = string }
variable "keybase_username" { type = string }
variable "instance_type" { type = string }
variable "sns_email" { type = string }
variable "world_name" { type = string }
variable "server_name" { type = string }
#variable "server_password" { type = string }
variable "purpose" { type = string }
variable "unique_id" { type = string }

locals {
  username = "pzuser"
  tags = {
    "Purpose"   = var.purpose
    "Component" = "zomboid Server"
    "CreatedBy" = "Terraform"
  }
  ec2_tags = merge(local.tags,
    {
      "Name"        = "${local.name}-server"
      "Description" = "Instance running a zomboid server"
    }
  )
  name = var.purpose != "prod" ? "zomboid-${var.purpose}${var.unique_id}" : "zomboid"
}
