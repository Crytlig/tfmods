variable "location" {
  type        = string
  description = "A datacenter location in Azure."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "name" {
  type        = string
  description = "Name of the virtual network."
}

variable "address_space" {
  type        = list(string)
  description = "Address space of the virtual network."
}

variable "tags" {
  type        = map(any)
  description = "Optional tags for the resource group."
  default     = null
}