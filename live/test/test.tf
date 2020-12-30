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
  depends_on = [module.database]
}