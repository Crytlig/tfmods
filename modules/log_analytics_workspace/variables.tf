variable "name" {
  type        = string
  description = "The name of the Log Analytics Workspace."
}

variable "location" {
  type        = string
  description = "The Azure region where the workspace will be created."
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
  default     = "PerGB2018"
  description = "The SKU (pricing tier) of the Log Analytics Workspace."

  validation {
    condition     = contains(["Free", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "CapacityReservation", "PerGB2018"], var.sku)
    error_message = "The SKU must be one of: Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, PerGB2018."
  }
}

variable "retention_in_days" {
  type        = number
  default     = 30
  description = "The number of days to retain data. Valid range is 30 to 730."

  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "Retention must be between 30 and 730 days."
  }
  validation {
    condition     = ceil(var.retention_in_days) == var.retention_in_days
    error_message = "Retention must be a whole number."
  }
}

variable "daily_quota_gb" {
  type        = number
  default     = null
  description = "The daily ingestion quota in GB. Null means unlimited."

  validation {
    condition     = var.daily_quota_gb == null ? true : var.daily_quota_gb > 0
    error_message = "Daily quota must be greater than 0 when set."
  }
}
