resource "azurerm_storage_account" "this" {
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  account_kind                    = var.account_kind
  public_network_access_enabled   = var.public_network_access_enabled
  min_tls_version                 = var.min_tls_version
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  shared_access_key_enabled       = var.shared_access_key_enabled
  tags                            = var.tags

  dynamic "network_rules" {
    for_each = var.network_rules != null ? { this = var.network_rules } : {}
    content {
      default_action             = network_rules.value.default_action
      bypass                     = network_rules.value.bypass
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }

  dynamic "blob_properties" {
    for_each = var.blob_properties != null ? { this = var.blob_properties } : {}
    content {
      versioning_enabled = blob_properties.value.versioning_enabled

      delete_retention_policy {
        days = blob_properties.value.delete_retention_days
      }

      container_delete_retention_policy {
        days = blob_properties.value.container_delete_retention_days
      }

      dynamic "cors_rule" {
        for_each = blob_properties.value.cors_rule
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }
    }
  }
}
