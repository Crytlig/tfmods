variable "resource_group_name" {
  type        = string
  description = "Name of the Azure resource group where resources will be deployed"
}

variable "name" {
  type        = string
  description = "Name to be used for the resources that will be created"
}

variable "sku_size" {
  type        = string
  description = "The SKU size/tier for Azure resources"
}

variable "managed_identity_id" {
  type        = string
  description = "The ID of the managed identity to be used with Azure resources"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet where resources will be deployed"
}

variable "network_security_group_name" {
  type        = string
  description = "Name of the network security group to be associated with resources"
}

variable "coolify_manager_ip" {
  type        = string
  description = "IP address of the Coolify manager instance"
}

variable "ssh_public_key" {
  type        = string
  sensitive   = true
  description = "SSH public key for secure access to resources"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}

variable "create_public_ip" {
  type        = bool
  default     = true
  description = "Whether to create and associate a public IP address"
}

variable "admin_username" {
  type        = string
  description = "admin username used for ssh"
}
