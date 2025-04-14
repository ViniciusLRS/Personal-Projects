#Teste para subir container nginx usando terraform
provider "docker" {}

resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_container" "nginx" {
  name  = "meu_nginx"
  image = docker_image.nginx.latest
  ports {
    internal = 80
    external = 8080
  }
}