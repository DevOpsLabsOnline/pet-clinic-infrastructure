module "app" {
  source     = "../../modules/app"
  enviroment = "test"
  app_instances = 1
}

module "database" {
  source     = "../../modules/database"
}