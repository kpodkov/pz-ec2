variable "aws_region" {
  type        = string
  description = "The AWS region to create the zomboid server"
}

variable "admins" {
  type        = map(any)
  default     = { "default_zomboid_user" = "", }
  description = "List of AWS users/zomboid server admins (use their SteamID)"
}

variable "domain" {
  type        = string
  default     = ""
  description = "Domain name used to create a static monitoring URL"
}

variable "keybase_username" {
  type        = string
  default     = "marypoppins"
  description = "The Keybase username to encrypt AWS user passwords with"
}

variable "instance_type" {
  type        = string
  default     = "t3a.large"
  description = "AWS EC2 instance type to run the server on (t3a.medium is the minimum size)"
}

variable "sns_email" {
  type        = string
  description = "The email address to send alerts to"
}

variable "world_name" {
  type        = string
  description = "The zomboid world name"
}

variable "server_name" {
  type        = string
  description = "The server name"
}

variable "environment" {
  type        = string
  default     = "prod"
  description = "The purpose of the deployment"
}

variable "unique_id" {
  type        = string
  default     = ""
  description = "The ID of the deployment (used for tests)"
}
