terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.108.0"
    }
  }

  cloud {
    organization = "AzCoOps"

    workspaces {
      name = "AzCoOp"
    }
  }
}
provider "azurerm" {
  #  subscription_id = ""       
  features {}
}
