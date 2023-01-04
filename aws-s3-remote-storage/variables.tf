variable "external_port" {
  type    = number
  default = 8081
  validation {
    condition     = can(regex("8081|80", var.external_port))
    error_message = "Port values can only be 8081 or 80."
  }
}
