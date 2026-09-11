terraform {
  required_version = ">= 1.5.0"



  backend "azurerm" {
    resource_group_name  = "1-b339435d-playground-sandbox"
    storage_account_name = "sytflab01state12345"
    container_name       = "tfstate"
    key                  = "Lab01.terraform.tfstate"
  }


  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
