terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

module "base" {
  source     = "../../modules/base"
}

module "database" {
  source     = "../../modules/database"
  depends_on = [module.base]
}

module "app" {
  source     = "../../modules/app"
  app_instances = 1
  db_username = module.database.output.db_username
  db_password = module.database.output.db_password
  depends_on = [module.database]
}