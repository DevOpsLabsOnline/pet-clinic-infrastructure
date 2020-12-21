variable app_instances{}

resource "docker_image" "app_image" {
  name = "snahider/devopslab-pet-clinic:production-latest"
}

resource "docker_container" "app" {
  name = "petclinic"
  image = docker_image.app_image.latest
  ports {
    internal = 8080
    external = 9967
  }
  networks_advanced {
    name = "petclinic-network"
  }
}

# resource "docker_container" "nginx-server" {
#   count = "${var.container_count}"
#   name = "nginx-server-${count.index+1}"
#   image = "${docker_image.nginx.latest}"
#   ports {
#     internal = 80
#   }
#   volumes {
#     container_path  = "/usr/share/nginx/html"
#     host_path = "/home/scrapbook/tutorial/www"
#     read_only = true
#   }
# }