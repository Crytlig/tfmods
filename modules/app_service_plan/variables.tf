variable "name" {
  type        = string
  description = "The name of the App Service Plan."
}

variable "location" {
  type        = string
  description = "The Azure region where the resource will be created."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "sku_name" {
  type        = string
  description = "The SKU for the App Service Plan (e.g., B1, S1, P1v3)."

  validation {
    condition     = can(regex("^(F1|D1|B[1-3]|S[1-3]|P[1-3]v[2-3]|I[1-6]v2|Y1|EP[1-3]|WS[1-3])$", var.sku_name))
    error_message = "The SKU name must be a valid App Service Plan SKU (e.g., F1, B1, S1, P1v2, P1v3, I1v2, Y1, EP1, WS1)."
  }
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
}

variable "os_type" {
  type        = string
  default     = "Linux"
  description = "The OS type for the App Service Plan. Must be `Linux` or `Windows`."

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "The os_type must be either Linux or Windows."
  }
}

variable "worker_count" {
  type        = number
  default     = null
  description = "The number of workers (instances) to allocate."

  validation {
    condition     = var.worker_count == null ? true : var.worker_count > 0
    error_message = "Worker count must be greater than 0 when set."
  }
}

variable "zone_balancing_enabled" {
  type        = bool
  default     = false
  description = "Should workers be distributed across availability zones. Requires a zone-redundant SKU."
}
