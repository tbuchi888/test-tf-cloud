terraform {
  backend "azurerm" {
    resource_group_name  = "demo-terraform"
    storage_account_name = "tbuchi888tfstate"
    container_name       = "backendcontainer"
    key                  = "test-tf-cloud001.tfstate"
  }
}
