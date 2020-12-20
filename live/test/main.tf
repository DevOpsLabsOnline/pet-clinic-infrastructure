module "app_and_db" {
  source     = "../../modules/app_and_db"
  enviroment = "test"
  app_instances = 1
}