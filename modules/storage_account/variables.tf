variable "name" {
  type        = string
  description = "The name of the storage account. Must be 3-24 characters, lowercase letters and numbers only."

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "The name must be between 3 and 24 characters long and can only contain lowercase letters and numbers."
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

variable "account_tier" {
  type        = string
  default     = "Standard"
  description = "The tier of the storage account."

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "The account_tier must be either Standard or Premium."
  }
}

variable "account_replication_type" {
  type        = string
  default     = "LRS"
  description = "The replication type of the storage account."

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "The account_replication_type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "account_kind" {
  type        = string
  default     = "StorageV2"
  description = "The kind of storage account."

  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "The account_kind must be one of: BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "Allow public network access to the storage account. Defaults to false (secure by default)."
}

variable "min_tls_version" {
  type        = string
  default     = "TLS1_2"
  description = "The minimum supported TLS version."

  validation {
    condition     = var.min_tls_version == "TLS1_2"
    error_message = "The minimum TLS version must be TLS1_2."
  }
}

variable "allow_nested_items_to_be_public" {
  type        = bool
  default     = false
  description = "Allow or disallow nested items within this account to opt into being public."
}

variable "shared_access_key_enabled" {
  type        = bool
  default     = false
  description = "Enable shared key authorization. Defaults to false - use Entra ID (RBAC) instead."
}

variable "network_rules" {
  type = object({
    default_action             = optional(string, "Deny")
    bypass                     = optional(set(string), ["AzureServices"])
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default     = null
  description = <<DESCRIPTION
Network ACL rules for the storage account. When null, no explicit network rules are set.

- `default_action` - (Optional) The default action when no rule matches. Defaults to `Deny`.
- `bypass` - (Optional) Services allowed to bypass the rules. Defaults to `["AzureServices"]`.
- `ip_rules` - (Optional) List of IP CIDR ranges to allow.
- `virtual_network_subnet_ids` - (Optional) List of subnet IDs to allow.
DESCRIPTION

  validation {
    condition     = var.network_rules == null ? true : contains(["Allow", "Deny"], var.network_rules.default_action)
    error_message = "The default_action must be either Allow or Deny."
  }
}

variable "blob_properties" {
  type = object({
    versioning_enabled              = optional(bool, false)
    delete_retention_days           = optional(number, 7)
    container_delete_retention_days = optional(number, 7)
    cors_rule = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })), [])
  })
  default     = null
  description = <<DESCRIPTION
Blob service properties for the storage account. When null, defaults are used.

- `versioning_enabled` - (Optional) Enable blob versioning. Defaults to false.
- `delete_retention_days` - (Optional) Days to retain deleted blobs. Defaults to 7.
- `container_delete_retention_days` - (Optional) Days to retain deleted containers. Defaults to 7.
- `cors_rule` - (Optional) CORS rules for blob service.
DESCRIPTION
}
