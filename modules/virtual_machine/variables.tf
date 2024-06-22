# Requires variables
variable "name" {
  type        = string
  description = "The name to use when creating the virtual machine."
  nullable    = false

  validation {
    condition     = can(regex("^.{1,64}$", var.name))
    error_message = "virtual machine names for linux must be between 1 and 64 characters in length. Virtual machine name for windows must be between 1 and 20 characters in length."
  }
}

variable "location" {
  type        = string
  description = "The Azure region where this and supporting resources should be deployed."
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = "The resource group name of the resource group where the vm resources will be deployed."
  nullable    = false
}

variable "subnet_id" {
  type        = string
  description = "Subnet id to attach network interface to"
  nullable    = false
}

# Optional variables
variable "sku" {
  type        = string
  description = "The sku value to use for this virtual machine"
  nullable    = false
  default     = "Standard_B1ms"
}

variable "enable_public_ip" {
  type        = bool
  description = "(Optional) Enable public IP resource creation. Defaults to true"
  nullable    = false
  default     = true
}

variable "admin_username" {
  type        = string
  description = "(Optional) Admin username. Defaults to adminjensen"
  default     = "adminjensen"
}

variable "generate_ssh_key" {
  type = object({
    name                           = optional(string, null)
    expiration_date_length_in_days = optional(number, 45)
    content_type                   = optional(string, "text/plain")
    not_before_date                = optional(string, null)
    key_vault_id                   = optional(string, null)
    tags                           = optional(map(string), {})
  })
  default     = {}
  description = <<DESCRIPTION
For simplicity this module provides the option to use an auto-generated SSH key. That password or key is then stored in a key vault. 

- `name` - (Optional) - The name to use for the key vault secret that stores the auto-generated ssh key or password
- `expiration_date_length_in_days` - (Optional) - This value sets the number of days from the installation date to set the key vault expiration value. It defaults to `45` days.  This value will not be overridden in subsequent runs. If you need to maintain this virtual machine resource for a long period, generate and/or use your own password or ssh key.
- `content_type` - (Optional) - This value sets the secret content type.  Defaults to `text/plain`
- `not_before_date` - (Optional) - The UTC datetime (Y-m-d'T'H:M:S'Z) date before which this key is not valid.  Defaults to null.
- `key_vault_id` - (Optional) - key vault ID to store the generated SSH key in
- `tags` - (Optional) - Specific tags to assign to this secret resource
DESCRIPTION
}

variable "public_key" {
  type        = string
  default     = null
  description = <<DESCRIPTION
The Public Key which should be used for authentication, which needs to be at least 2048-bit and in ssh-rsa format. Changing this forces a new resource to be created.
Public key takes precedence over generate_ssh_key
DESCRIPTION
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "Map of tags to be assigned to this resource"
}