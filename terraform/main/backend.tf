terraform {
  backend "azurerm" {
    resource_group_name  = "test-rg1"
    storage_account_name = "pankajmathpal99001122"
    container_name       = "mycon1212"
    key                  = "terraform.tfstate"
  }
}
