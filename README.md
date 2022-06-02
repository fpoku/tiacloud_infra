# corporate
Corporate Network Infrastructure

#Terraform commands
#terraform init,plan,apply,destroy
#terraform plan -destroy --out=plan-file.pln
#terraform show plan-file.pln
#terraform validate                          # Check if the template is fine
#terraform fmt                               # Format template based on best practices
#terraform state list                        # Lists all resources in the state file
#terraform show                              # Print a complete state in human readable format
#terraform state show path_to_resource       # Print details of one resource
#terraform graph | dot -Tpng > graph.png     # Export dependency graph, needs GraphViz
#terraform graph -verbose | dot -Tpng > graph.png # Also show destroyed resources



# #Create Spoke Virtual Network - Staging
#  resource azurerm_virtual_network "corp-staging-vnet" {

#  name                = "${var.corp}-staging-vnet"
#   location            = azurerm_resource_group.corp-resources-rg.location
#   resource_group_name = azurerm_resource_group.corp-resources-rg.name
#   address_space       = ["10.20.0.0/16"]

#   tags = {
#     environment = "Staging"
#   }
# }



# #Create Spoke Virtual Network - Staging
#  resource azurerm_virtual_network "corp-development-vnet" {

#  name                = "${var.corp}-development-vnet"
#   location            = azurerm_resource_group.corp-resources-rg.location
#   resource_group_name = azurerm_resource_group.corp-resources-rg.name
#   address_space       = ["10.30.0.0/16"]

#   tags = {
#     environment = "Development"
#   }
# }



