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

resource "docker_image" "app_image" {
  name = "snahider/devopslab-pet-clinic:production-latest"
}

resource "docker_container" "app" {
  name = "petclinic-dev"
  image = docker_image.app_image.latest
  ports {
    internal = 8080
    external = 9966
  }
}

resource "local_file" "mysql_data" {
    filename = "/mysql/data"
}

resource "docker_image" "mysql" {
  name = "mysql:8"
}

resource "random_password" "mysql_root_password" {
  length = 16
}

output "my_password" {
  value = random_password.mysql_root_password.result
}

#  lifecycle {
#    ignore_changes = ["plaintext_password"]
#  }

resource "docker_container" "mysql" {
  name = "mysql"
  image = "${docker_image.mysql.latest}"
  env = [
    "MYSQL_ROOT_PASSWORD=${random_password.mysql_root_password.result}"
  ]
  mounts {
    source = local_file.mysql_data.filename
    target = "/var/lib/mysql/data"
    type = "bind"
  }
  ports {
    internal = 3306
    external = 3306
  }
}

provider "mysql" {
  endpoint = "127.0.0.1:3306"
  username = "root"
  password = "${random_password.mysql_root_password.result}"
}

resource "mysql_database" "db" {
  name = "petclinic"
}
