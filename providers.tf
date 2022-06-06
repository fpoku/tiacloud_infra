#IaC on Azure Cloud Platform | Declare Azure as the Provider
# Configure the Microsoft Azure Provider
terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }

  #Configure Remote State - Backend - on Azure Storage Account in a separate location away from resources
  backend "azurerm" {
    resource_group_name  = "tf-backend-rg"
    storage_account_name = "tfbackendstorage2307"
    container_name       = "tfbackendcontainer"
    key                  = "terraform.tfstate"
  }

}


provider "azurerm" {
  features {}
}


#Create a Service Principal on Azure and use the following values
# provider "azurerm" {
#   subscription_id = "31e9c06e-6d3f-4485-836c-ff36c38135a3"
#   client_id       = "************************************"
#   client_secret   = "************************************"
#   tenant_id       = "36b6838b-d41b-4ef5-8c96-abd06907a34e"
# }
#https://archive.azurecitadel.com/automation/terraform/lab5/