terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

variable app_instances{}

resource "docker_image" "app_image" {
  name = "snahider/devopslab-pet-clinic:production-latest"
}

resource "docker_container" "app" {
  count = var.app_instances
  name = "petclinic-${count.index}"
  image = docker_image.app_image.latest
  networks_advanced {
    name = "petclinic-network"
  }
  labels{
    label = "traefik.frontend.rule"
    value = "PathPrefix:/"
  }
}

# resource "docker_container" "app" {
#   name = "petclinic"
#   image = docker_image.app_image.latest
#   ports {
#     internal = 8080
#     external = 9967
#   }
#   networks_advanced {
#     name = "petclinic-network"
#   }
# }

resource "docker_image" "loadbalancer" {
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