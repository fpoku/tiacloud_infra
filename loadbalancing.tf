
resource "azurerm_lb" "production-loadbalancer" {
  name                = "prod-int-lb"
  location            = azurerm_resource_group.corp-resources-rg.location
  resource_group_name = azurerm_resource_group.corp-resources-rg.name
  sku                 = "Standard"
  sku_tier            = "Regional"
  tags = {

  }

  frontend_ip_configuration {
    availability_zone             = "Zone-Redundant"
    name                          = "ilbfeip"
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
    subnet_id                     = azurerm_subnet.corp-production-subnet.id
  }


}
resource "azurerm_lb_rule" "production-inbound-rules" {
  loadbalancer_id                = azurerm_lb.production-loadbalancer.id
  resource_group_name            = azurerm_resource_group.corp-resources-rg.name
  name                           = "Web_InBound_Rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "ilbfeip"

}


resource "azurerm_lb_probe" "Web_InBound_Probe" {
  resource_group_name            = azurerm_resource_group.corp-resources-rg.name
  loadbalancer_id                = azurerm_lb.production-loadbalancer.id
  name                = "web-running-probe"
  port                = 80
}


resource "azurerm_lb_backend_address_pool" "prod-be-pool" {
  loadbalancer_id = azurerm_lb.production-loadbalancer.id
  name            = "prod-be-pool"
}


# data "azurerm_lb" "ilb" {
#   name                = "prod-int-lb"
#   resource_group_name = azurerm_resource_group.corp-resources-rg.name
# }



# #Create LoadBalancer
# resource "azurerm_lb" "production-loadbalancer" {
#   name                = "TestLoadBalancer"
#   location            = azurerm_resource_group.corp-resources-rg.location
#   resource_group_name = azurerm_resource_group.corp-resources-rg.name

#   frontend_ip_configuration {
#     name                  = "frontend-private-ip"
#     private_ip_address_id = azurerm_private_ip.ilbfeip.id
#   }
# }

# resource "azurerm_lb_backend_address_pool" "production-be-pool" {
#   loadbalancer_id = azurerm_lb.prod-int-lb.id
#   name            = "BackEndAddressPool"
# }








