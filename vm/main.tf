provider "azurerm" {
  features {}
  skip_provider_registration = "true"
}

terraform {
  backend "azurerm" {
    resource_group_name  = "RG_BASE"
    storage_account_name = "strgbase7061"
    container_name       = "tfstate"
    key                  = "vm.terraform.tfstate"
  }
} 