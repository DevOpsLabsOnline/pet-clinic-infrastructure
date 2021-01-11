terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

variable mysql_dump{}

resource "docker_volume" "mysql_data" {
  name = "mysql_data"
}

resource "docker_image" "mysql" {
  name = "mysql:8"
  keep_locally = "true"
}

resource "random_password" "mysql_root_password" {
  length = 16
}

resource "docker_container" "mysql" {
  name = "mysql"
  image = docker_image.mysql.latest
  env = [
    "MYSQL_ROOT_PASSWORD=${random_password.mysql_root_password.result}",
    "MYSQL_DATABASE=petclinic"
  ]
  volumes {
    volume_name = docker_volume.mysql_data.name
    container_path = "/var/lib/mysql"
  }
  # mounts {
  #   source = "/var/lib/mysql"
  #   target = "/var/lib/mysql"
  #   type = "bind"
  # }
  mounts {
    source = var.mysql_dump
    target = "/docker-entrypoint-initdb.d"
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

output "db_username" {
  value = "root"
}

output "db_password" {
  value = random_password.mysql_root_password.result
}