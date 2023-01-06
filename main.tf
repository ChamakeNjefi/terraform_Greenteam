terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.24.0"
    }
  }
}

provider "docker" {}

variable "ext_port" {
    type    = number
    default = 1880
    
    validation {
      condition = var.ext_port <= 65535 && var.ext_port > 0 
      error_message = "The external port must be in the valid port range."
      }
}

variable "int_port" {
    type    = number
    default = 1880

    validation {
      condition = var.int_port == 1880
      error_message = "The internal port must be 1880."
      }
}

variable "container_count" {
    type    = number
    default = 1
}

resource "docker_image" "nodered_image" {
  name = "nodered/node-red:latest"
}

resource "random_string" "random" {
    count = var.container_count
    length = 4
    special = false
    upper = false 
}

 resource "docker_container" "nodered_container" {
  count = var.container_count
  name  = join("-", ["nodered", random_string.random[count.index].result])
  image = docker_image.nodered_image.latest
  ports {
    internal = var.int_port
    external = var.ext_port
  }
}

output "IP-Address" {
 value       = [for i in docker_container.nodered_container[*]: join(":", [i.ip_address], i.ports[*]["external"])]
 description = "ip address and external port of the container"
}

output "container-name" {
 value       = docker_container.nodered_container[*].name
 description = "name of the container"

}





