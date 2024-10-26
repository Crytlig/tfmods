module "vm" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.15.0"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  admin_username                     = var.admin_username
  enable_telemetry                   = false
  encryption_at_host_enabled         = false
  generate_admin_password_or_ssh_key = false
  os_type                            = "Linux"
  sku_size                           = var.sku_size
  zone                               = null

  admin_ssh_keys = [
    {
      public_key = var.ssh_public_key
      username   = var.admin_username
    }
  ]

  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = var.managed_identity_id != null ? [var.managed_identity_id] : []
  }

  network_interfaces = {
    network_interface = {
      name                  = "nic-${var.name}"
      ip_forwarding_enabled = true
      ip_configurations = {
        ip_configuration_avs_facing = {
          create_public_ip_address      = var.create_public_ip
          public_ip_address_name        = "pip-${var.name}"
          name                          = var.name
          private_ip_subnet_resource_id = var.subnet_id
        }
      }
    }
  }

  public_ip_configuration_details = {
    allocation_method = "Dynamic"
    sku               = "Basic"
    sku_tier          = "Regional"
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  tags = var.tags
}

resource "azurerm_network_security_group" "this" {
  name                = var.network_security_group_name
  resource_group_name = var.resource_group_name
  location            = var.location

  security_rule {
    name                       = "allow_http"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_https"
    priority                   = 160
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  dynamic "security_rule" {
    for_each = var.coolify_manager_ip == "" ? [] : [1]
    content {
      name                       = "allow_ssh"
      priority                   = 170
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = var.coolify_manager_ip
      destination_address_prefix = "*"
    }
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.this.id
}
