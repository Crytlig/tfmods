resource "azurerm_application_insights" "this" {
  name                 = var.name
  location             = var.location
  resource_group_name  = var.resource_group_name
  workspace_id         = var.workspace_id
  application_type     = var.application_type
  retention_in_days    = var.retention_in_days
  daily_data_cap_in_gb = var.daily_data_cap_in_gb
  sampling_percentage  = var.sampling_percentage
  disable_ip_masking   = var.disable_ip_masking
  tags                 = var.tags
}
