variable "name" {
  type        = string
  description = "The name of the Container Registry. Must be 5-50 characters, alphanumeric only."

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.name))
    error_message = "The name must be between 5 and 50 characters long and can only contain alphanumeric characters."
  }
}

variable "location" {
  type        = string
  description = "The Azure region where the resource will be created."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
}

variable "sku" {
  type        = string
  default     = "Standard"
  description = "The SKU tier of the Container Registry. Must be `Standard` or `Premium`."

  validation {
    condition     = contains(["Standard", "Premium"], var.sku)
    error_message = "The SKU must be either Standard or Premium. Basic is not supported."
  }
}

variable "admin_enabled" {
  type        = bool
  default     = false
  description = "Enable admin user. Defaults to false - use managed identity for authentication."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Allow public network access. Set to false with Premium SKU and private endpoints."
}

variable "network_rule_bypass_option" {
  type        = string
  default     = "AzureServices"
  description = "Allow trusted Azure services to bypass network rules."

  validation {
    condition     = contains(["AzureServices", "None"], var.network_rule_bypass_option)
    error_message = "The network_rule_bypass_option must be either AzureServices or None."
  }
}

variable "georeplications" {
  type = list(object({
    location                = string
    zone_redundancy_enabled = optional(bool, false)
  }))
  default     = []
  description = <<DESCRIPTION
A list of geo-replication locations for the Container Registry. Requires Premium SKU.

- `location` - The Azure region for the replica.
- `zone_redundancy_enabled` - (Optional) Enable zone redundancy for the replica. Defaults to false.
DESCRIPTION
}

variable "retention_policy_days" {
  type        = number
  default     = 7
  description = "The number of days to retain untagged manifests. Requires Premium SKU."

  validation {
    condition     = var.retention_policy_days >= 0
    error_message = "Retention policy days must be 0 or greater."
  }
}
