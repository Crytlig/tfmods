variable "location" {
  type        = string
  description = "A datacenter location in Azure."
}

variable "name" {
  type        = string
  description = "Name of the resource group."
}

variable "tags" {
  type        = map(any)
  description = "Tags for the resource group."
}
