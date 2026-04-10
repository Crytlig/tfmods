variable "name" {
  type        = string
  description = "The name of the Application Insights instance."
}

variable "location" {
  type        = string
  description = "The Azure region where the resource will be created."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "workspace_id" {
  type        = string
  description = "The ID of the Log Analytics Workspace to link to. Required for workspace-based Application Insights."
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
}

variable "application_type" {
  type        = string
  default     = "web"
  description = "The type of Application Insights to create."

  validation {
    condition     = contains(["web", "ios", "java", "MobileCenter", "Node.JS", "other", "phone", "store"], var.application_type)
    error_message = "The application_type must be one of: web, ios, java, MobileCenter, Node.JS, other, phone, store."
  }
}

variable "retention_in_days" {
  type        = number
  default     = 90
  description = "The number of days to retain data."

  validation {
    condition     = contains([30, 60, 90, 120, 180, 270, 365, 550, 730], var.retention_in_days)
    error_message = "Retention must be one of: 30, 60, 90, 120, 180, 270, 365, 550, 730."
  }
}

variable "daily_data_cap_in_gb" {
  type        = number
  default     = null
  description = "The daily data volume cap in GB. Null means no cap."

  validation {
    condition     = var.daily_data_cap_in_gb == null ? true : var.daily_data_cap_in_gb > 0
    error_message = "Daily data cap must be greater than 0 when set."
  }
}

variable "sampling_percentage" {
  type        = number
  default     = 100
  description = "The percentage of telemetry items to sample (0-100)."

  validation {
    condition     = var.sampling_percentage >= 0 && var.sampling_percentage <= 100
    error_message = "Sampling percentage must be between 0 and 100."
  }
}

variable "disable_ip_masking" {
  type        = bool
  default     = false
  description = "Disable IP masking in logs. When false (default), client IPs are masked."
}
