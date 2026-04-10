data "azurerm_monitor_diagnostic_categories" "this" {
  resource_id = var.target_resource_id
}

locals {
  log_categories    = var.enabled_log_categories != null ? var.enabled_log_categories : data.azurerm_monitor_diagnostic_categories.this.log_category_types
  metric_categories = var.metric_categories != null ? var.metric_categories : data.azurerm_monitor_diagnostic_categories.this.metrics
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                           = var.name
  target_resource_id             = var.target_resource_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  storage_account_id             = var.storage_account_id
  log_analytics_destination_type = var.log_analytics_destination_type

  dynamic "enabled_log" {
    for_each = local.log_categories
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = local.metric_categories
    content {
      category = metric.value
    }
  }
}
