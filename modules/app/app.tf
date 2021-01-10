terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

variable app_instances{}
variable db_username{}
variable db_password{}

resource "docker_image" "app_image" {
  name = "snahider/devopslab-pet-clinic:production-latest"
}

resource "docker_container" "app" {
  count = var.app_instances
  name = "petclinic-${count.index}"
  image = docker_image.app_image.latest
  dynamic "expose_port" {
    for_each = var.app_instances > 1 ? [] : [1]
    content {
      ports {
        internal = 8080
        external = 9967
      }
    }
  }
  networks_advanced {
    name = "petclinic-network"
  }
  labels{
    label = "traefik.frontend.rule"
    value = "PathPrefix:/"
  }
  command = ["--spring.profiles.active=mysql",
             "--spring.datasource.username=${var.db_username}", 
             "--spring.datasource.password=${var.db_password}"]
}

# resource "docker_container" "app" {
#   count = var.app_instances
#   name = "petclinic-${count.index}"
#   image = docker_image.app_image.latest
#   ports {
#     internal = 8080
#     external = 9967
#   }
#   networks_advanced {
#     name = "petclinic-network"
#   }
#   command = ["--spring.profiles.active=mysql",
#              "--spring.datasource.username=${var.db_username}", 
#              "--spring.datasource.password=${var.db_password}"]
# }

resource "docker_image" "loadbalancer" {
  count = var.app_instances > 1 ? 1 : 0
  name = "traefik:v1.7"
}

resource "docker_container" "loadbalancer" {
  count = var.app_instances > 1 ? 1 : 0
  name = "loadbalancer"
  image = docker_image.loadbalancer.latest
  ports {
    internal = 80
    external = 80
  }
  volumes {
    host_path = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
  networks_advanced {
    name = "petclinic-network"
  }
  command = ["--docker","--logLevel=DEBUG"]
}