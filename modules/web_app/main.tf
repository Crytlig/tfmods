resource "azurerm_linux_web_app" "this" {
  name                      = var.app_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  service_plan_id           = var.app_service_plan_id
  virtual_network_subnet_id = var.virtual_network_subnet_id

  auth_settings_v2 {
    default_provider       = "azureactivedirectory"
    require_authentication = true
    active_directory_v2 {
      allowed_applications       = []
      allowed_audiences          = ["api://${var.client_id}"]
      client_id                  = var.client_id
      client_secret_setting_name = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
      tenant_auth_endpoint       = "https://sts.windows.net/${var.tenant_id}/v2.0"
    }

    auth_enabled = true

    login {
      token_store_enabled = true
      logout_endpoint     = "/.auth/logout"
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  site_config {
    application_stack {
      docker_image_name   = "${var.image_name}:${var.image_tag}"
      docker_registry_url = "https://${var.container_registry_login_server}"
    }

    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = var.user_assigned_identity_client_id
  }

  app_settings = {
    "publicNetworkAccess"                      = "Enabled"
    "WEBSITES_PORT"                            = var.port
    "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET" = var.app_registration_password
    "FTP_STATE"                                = "Disabled"
    "SCM_STATE"                                = "Disabled"
  }

  logs {
    detailed_error_messages = false
    failed_request_tracing  = false

    http_logs {
      file_system {
        retention_in_mb   = 35
        retention_in_days = 7
      }
    }
  }

  tags = var.tags
}
