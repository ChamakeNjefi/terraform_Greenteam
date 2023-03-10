# ---Root --- #
output "IP-Address" {
  value       = [for i in docker_container.nodered_container[*] : join(":", [i.ip_address], i.ports[*]["external"])]
  description = "ip address and external port of the container"
}

output "container-name" {
  value       = docker_container.nodered_container[*].name
  description = "name of the container"

}