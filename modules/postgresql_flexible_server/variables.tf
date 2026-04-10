variable "name" {
  type        = string
  description = "The name of the PostgreSQL Flexible Server."

  validation {
    condition     = can(regex("^[a-z0-9-]{3,63}$", var.name))
    error_message = "The name must be between 3 and 63 characters long and can only contain lowercase letters, numbers and dashes."
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

variable "administrator_login" {
  type        = string
  description = "The administrator login for the PostgreSQL server."
}

variable "administrator_password" {
  type        = string
  description = "The administrator password for the PostgreSQL server."
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
}

variable "sku_name" {
  type        = string
  default     = "B_Standard_B1ms"
  description = "The SKU name for the PostgreSQL Flexible Server (e.g., B_Standard_B1ms, GP_Standard_D2s_v3, MO_Standard_E4s_v3)."
}

variable "postgresql_version" {
  type        = string
  default     = "16"
  description = "The version of PostgreSQL to use."

  validation {
    condition     = contains(["13", "14", "15", "16"], var.postgresql_version)
    error_message = "The PostgreSQL version must be one of: 13, 14, 15, 16."
  }
}

variable "storage_mb" {
  type        = number
  default     = 32768
  description = "The maximum storage allowed for the PostgreSQL Flexible Server in MB."
}

variable "storage_tier" {
  type        = string
  default     = null
  description = "The storage tier for the PostgreSQL Flexible Server. Auto-selected when null."
}

variable "delegated_subnet_id" {
  type        = string
  default     = null
  description = <<DESCRIPTION
The ID of the subnet to delegate to the PostgreSQL Flexible Server for private access.
When set, the server is deployed into the VNet with private networking.
Must be set together with `private_dns_zone_id`.
DESCRIPTION
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = <<DESCRIPTION
The ID of the Private DNS Zone for the PostgreSQL Flexible Server.
Required when `delegated_subnet_id` is set.
DESCRIPTION
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "Enable public network access. Defaults to false (secure by default)."
}

variable "zone" {
  type        = string
  default     = null
  description = "The availability zone for the PostgreSQL Flexible Server."
}

variable "backup_retention_days" {
  type        = number
  default     = 7
  description = "The number of days to retain backups. Valid range is 7 to 35."

  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "Backup retention must be between 7 and 35 days."
  }
}

variable "geo_redundant_backup_enabled" {
  type        = bool
  default     = false
  description = "Enable geo-redundant backups."
}

variable "high_availability" {
  type = object({
    mode                      = string
    standby_availability_zone = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
High availability configuration for the PostgreSQL Flexible Server.

- `mode` - The high availability mode. Possible values are `SameZone` and `ZoneRedundant`.
- `standby_availability_zone` - (Optional) The availability zone for the standby server.
DESCRIPTION

  validation {
    condition     = var.high_availability == null ? true : contains(["SameZone", "ZoneRedundant"], var.high_availability.mode)
    error_message = "The high availability mode must be either SameZone or ZoneRedundant."
  }
}

variable "maintenance_window" {
  type = object({
    day_of_week  = optional(number, 0)
    start_hour   = optional(number, 0)
    start_minute = optional(number, 0)
  })
  default     = null
  description = <<DESCRIPTION
The preferred maintenance window for the PostgreSQL Flexible Server.

- `day_of_week` - (Optional) The day of the week (0 = Sunday). Defaults to 0.
- `start_hour` - (Optional) The start hour for the maintenance window. Defaults to 0.
- `start_minute` - (Optional) The start minute for the maintenance window. Defaults to 0.
DESCRIPTION
}

variable "firewall_rules" {
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default     = {}
  description = <<DESCRIPTION
A map of firewall rules for the PostgreSQL Flexible Server. Only applicable when public network access is enabled.
The map key is used as the firewall rule name.

- `start_ip_address` - The start IP address for the firewall rule.
- `end_ip_address` - The end IP address for the firewall rule.
DESCRIPTION
}

variable "authentication" {
  type = object({
    active_directory_auth_enabled = optional(bool, true)
    password_auth_enabled         = optional(bool, true)
    tenant_id                     = optional(string, null)
  })
  default     = {}
  description = <<DESCRIPTION
Authentication configuration for the PostgreSQL Flexible Server.

- `active_directory_auth_enabled` - (Optional) Enable Azure Active Directory authentication. Defaults to true.
- `password_auth_enabled` - (Optional) Enable password authentication. Defaults to true.
- `tenant_id` - (Optional) The tenant ID for Azure Active Directory authentication.
DESCRIPTION
  nullable    = false
}
