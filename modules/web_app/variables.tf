variable "app_name" {
  type        = string
  description = "The name of the Linux web app"
}

variable "location" {
  type        = string
  description = "The Azure region where the resources will be created"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "app_service_plan_id" {
  type        = string
  description = "The ID of the App Service Plan"
}

variable "client_id" {
  type        = string
  description = "The client ID for Azure Active Directory authentication"
  default     = null
}

variable "tenant_id" {
  type        = string
  description = "The tenant ID for Azure Active Directory authentication"
}

variable "user_assigned_identity_id" {
  type        = string
  description = "The ID of the user-assigned managed identity"
  default     = null
}

variable "image_name" {
  type        = string
  description = "The name of the Docker image"
  default     = null
}

variable "image_tag" {
  type        = string
  description = "The tag of the Docker image"
  default     = null
}

variable "container_registry_login_server" {
  type        = string
  description = "The login server URL for the container registry"
  default     = null
}

variable "app_registration_password" {
  type        = string
  description = "The password for the app registration"
  sensitive   = true
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource"
}

variable "user_assigned_identity_client_id" {
  type        = string
  description = "The client ID of the user-assigned managed identity"
  default     = null
}

variable "port" {
  type        = number
  description = "The port number for the application"
}

variable "virtual_network_subnet_id" {
  type        = string
  description = "The ID of the subnet in the virtual network"
  default     = null
}
