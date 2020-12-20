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

resource "docker_image" "mysql" {
  name = "mysql:8"
}

resource "random_password" "mysql_root_password" {
  length = 16
}

output "my_password" {
  value = random_password.mysql_root_password.result
}

resource "docker_container" "mysql" {
  name = "mysql"
  image = docker_image.mysql.latest
  env = [
    "MYSQL_ROOT_PASSWORD=${random_password.mysql_root_password.result}",
    "MYSQL_DATABASE=petclinic"
  ]
  mounts {
    source = "/var/lib/mysql"
    target = "/var/lib/mysql"
    type = "bind"
  }
  ports {
    internal = 3306
    external = 3306
  }
  networks_advanced {
    name = "petclinic-network"
  }
}