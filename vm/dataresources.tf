data "azurerm_key_vault" "key" {
  name                = var.key_vault
  resource_group_name = var.base_rg
}

data "azurerm_key_vault_secret" "secret" {
  name         = var.secret_name
  key_vault_id = data.azurerm_key_vault.key.id
}