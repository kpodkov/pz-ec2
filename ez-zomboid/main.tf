module "main" {
  source          = "../module"
  aws_region      = "eu-west-1"
  instance_type   = "t3a.large"
  sns_email       = "sobaka.wow@gmail.com"
  domain          = var.domain
  unique_id       = var.unique_id
  world_name      = var.world_name
  environment     = "prod"
  server_name     = "ez-zomboid"
  server_username = "pzuser"
  aws_admins      = { "default_zomboid_user" = "", }
}
