locals {
  ssh_key = var.public_key != null ? var.public_key : tls_private_key.this[0].public_key_openssh
  gen_key = var.generate_ssh_key.name != null && var.generate_ssh_key.key_vault_id != null
}

resource "azurerm_network_interface" "this" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "ip_configuration" {
    for_each = var.enable_public_ip ? [] : [1]
    content {
      name                          = "internal"
      private_ip_address_allocation = "Dynamic"
      subnet_id                     = var.subnet_id
      primary                       = true
    }
  }

  dynamic "ip_configuration" {
    for_each = var.enable_public_ip ? [1] : []
    content {
      name                          = "public"
      public_ip_address_id          = azurerm_public_ip.this[0].id
      subnet_id                     = var.subnet_id
      primary                       = true
      private_ip_address_allocation = "Dynamic"
    }
  }

  tags = var.tags
}

resource "azurerm_public_ip" "this" {
  count               = var.enable_public_ip ? 1 : 0
  name                = "pip-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"

  lifecycle {
    ignore_changes = [
      tags,
      ip_tags,
    ]
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  name                  = var.name
  location              = var.location
  resource_group_name   = var.resource_group_name
  admin_username        = var.admin_username
  size                  = var.sku_size
  network_interface_ids = [azurerm_network_interface.this.id]

  admin_ssh_key {
    public_key = local.ssh_key
    username   = var.admin_username
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk.storage_account_type
    disk_size_gb         = var.os_disk.disk_size_gb
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "tls_private_key" "this" {
  count = local.gen_key ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}


#--------------------------------------
# Private SSH key, key vault secret
#--------------------------------------
locals {
  generated_secret_expiration_date_utc = (local.gen_key ?
    formatdate("YYYY-MM-DD'T'hh:mm:ssZ", (timeadd(timestamp(), "${var.generate_ssh_key.expiration_date_length_in_days * 24}h"))) :
    null
  )
}

resource "azurerm_key_vault_secret" "ssh_key" {
  count = local.gen_key ? 1 : 0

  key_vault_id    = var.generate_ssh_key.key_vault_id
  name            = "${var.name}-${var.admin_username}-ssh-private-key"
  value           = tls_private_key.this[0].private_key_pem
  content_type    = "SSH key"
  expiration_date = local.generated_secret_expiration_date_utc
  not_before_date = var.generate_ssh_key.not_before_date

  lifecycle {
    ignore_changes = [expiration_date]
  }
}

#--------------------------------------------------------
# Assign system assigned identity to read from key vault 
#--------------------------------------------------------
resource "azurerm_role_assignment" "system_managed_identity" {
  count = local.gen_key ? 1 : 0

  principal_id         = azurerm_linux_virtual_machine.this.identity[0].principal_id
  scope                = var.generate_ssh_key.key_vault_id
  role_definition_name = "Key Vault Secrets User"
}
