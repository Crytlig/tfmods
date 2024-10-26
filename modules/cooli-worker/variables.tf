variable "resource_group_name" {
  type = string
}

variable "name" {
  type = string
}

variable "sku_size" {
  type = string
}

variable "managed_identity_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "network_security_group_name" {
  type = string
}

variable "coolify_manager_ip" {
  type = string
}

variable "ssh_public_key" {
  type      = string
  sensitive = true
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}

variable "create_public_ip" {
  type    = bool
  default = true
}
