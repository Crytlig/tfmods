variable "name" {
  type        = string
  description = "The name of the User Assigned Managed Identity."
}

variable "location" {
  type        = string
  description = "The Azure region where the resource will be created."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
}

variable "federated_identity_credentials" {
  type = map(object({
    audience = optional(list(string), ["api://AzureADTokenExchange"])
    issuer   = string
    subject  = string
  }))
  default     = {}
  description = <<DESCRIPTION
A map of federated identity credentials to create on the managed identity.
The map key is used as the credential name.

- `audience` - (Optional) The audience for the credential. Defaults to `["api://AzureADTokenExchange"]`.
- `issuer` - The OpenID Connect issuer URL (e.g., `https://token.actions.githubusercontent.com` for GitHub Actions).
- `subject` - The subject identifier (e.g., `repo:org/repo:ref:refs/heads/main` for GitHub Actions).
DESCRIPTION
}
