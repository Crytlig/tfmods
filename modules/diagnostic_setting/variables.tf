variable "name" {
  type        = string
  description = "The name of the diagnostic setting."
}

variable "target_resource_id" {
  type        = string
  description = "The ID of the resource to attach the diagnostic setting to."
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "The ID of the Log Analytics Workspace to send diagnostics to."
}

variable "storage_account_id" {
  type        = string
  default     = null
  description = "The ID of the Storage Account to send diagnostics to (for archival)."
}

variable "enabled_log_categories" {
  type        = set(string)
  default     = null
  description = "A set of log categories to enable. When null, all available log categories are enabled."
}

variable "metric_categories" {
  type        = set(string)
  default     = null
  description = "A set of metric categories to enable. When null, all available metric categories are enabled."
}

variable "log_analytics_destination_type" {
  type        = string
  default     = null
  description = "The destination type for Log Analytics. Possible values are `Dedicated` and `AzureDiagnostics`."

  validation {
    condition     = var.log_analytics_destination_type == null ? true : contains(["Dedicated", "AzureDiagnostics"], var.log_analytics_destination_type)
    error_message = "The log_analytics_destination_type must be either Dedicated or AzureDiagnostics."
  }
}
