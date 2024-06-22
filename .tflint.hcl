plugin "azurerm" {
    enabled = true
    version = "0.26.0"
    source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

rule "azurerm_resource_missing_tags" {
  enabled = true
}