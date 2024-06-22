variable "location" {
  type        = string
  description = "Location of Azure Datacenter"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "name" {
  type        = string
  description = "The name of the subnet."
}

variable "virtual_network_name" {
  type        = string
  description = "Name of the virtual network."
}

variable "address_prefixes" {
  type        = list(string)
  description = "The address prefix to use for the subnet."
}

variable "route_table_id" {
  type        = string
  description = "The ID of the route table which should be associated with the subnet."
  default     = null
}

variable "service_delegation" {
  type        = string
  description = "The name of service to delegate to."
  default     = null
}

variable "service_endpoints" {
  type        = set(string)
  description = "The list of Service endpoints to associate with the subnet."
  default     = []
}

variable "network_security_group_id" {
  type        = string
  description = "The ID of the network security group which should be associated with the subnet."
  default     = null
}

variable "tags" {
  type        = map(any)
  description = "Optional tags for the resource group."
  default     = null
}