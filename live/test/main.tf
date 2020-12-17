provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "app_image" {
  name = "snahider/devopslab-pet-clinic:production-latest"
}

resource "docker_container" "app" {
  count = "${var.container_count}"
  name = "nginx-server-${count.index+1}"
  image = "${docker_image.app_image.latest}"
  ports {
    internal = 80
  }
  env {

  }
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

resource "local_file" "mysql_data" {
    filename = "/mysql/data"
}

#  lifecycle {
#    ignore_changes = ["plaintext_password"]
#  }

resource "docker_container" "mysql" {
  name = "mysql"
  image = "${docker_image.mysql.latest}"
  env {
    MYSQL_ROOT_PASSWORD = "${random_password.mysql_root_password.result}"
  }
  mounts {
    source = "${local_file.mysql_data}"
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
