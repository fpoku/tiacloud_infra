#Create resource group
resource "azurerm_resource_group" "corp-resources-rg" {
  name     = "${var.corp}-resources-rg"
  location = var.location
}


#Create virtual network and subnets
#Create Hub Virtual Network
resource "azurerm_virtual_network" "corp-hub-vnet" {
  name                = "${var.corp}-hub-vnet"
  location            = azurerm_resource_group.corp-resources-rg.location
  resource_group_name = azurerm_resource_group.corp-resources-rg.name
  address_space       = ["172.20.0.0/16"]

  tags = {
    environment = "Hub"
  }
}

#Create Hub Azure Gateway Subnet
resource "azurerm_subnet" "hub-gateway-subnet" {

  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.corp-resources-rg.name
  virtual_network_name = azurerm_virtual_network.corp-hub-vnet.name
  #name                = "azure-${var.service_name}-${var.environment}-vnet"
  address_prefixes = ["172.20.0.0/24"]
}


resource "azurerm_subnet" "hub-management-subnet" {

  name                 = "${var.corp}-management-subnet"
  resource_group_name  = azurerm_resource_group.corp-resources-rg.name
  virtual_network_name = azurerm_virtual_network.corp-hub-vnet.name
  address_prefixes     = ["172.20.1.0/24"]
}


#Create Azure Virtual Network Gateway Resource
#Point to Site VPN Resource



#Create Spoke Virtual Network - Production
resource "azurerm_virtual_network" "corp-production-vnet" {

  name                = "${var.corp}-production-vnet"
  location            = azurerm_resource_group.corp-resources-rg.location
  resource_group_name = azurerm_resource_group.corp-resources-rg.name
  address_space       = ["10.10.0.0/16"]

  tags = {
    environment = "Production."
  }
}


#Create Subnets
#Create Production Subnet for Linux Workloads
resource "azurerm_subnet" "corp-production-subnet" {

  name                 = "${var.corp}-production-subnet"
  resource_group_name  = azurerm_resource_group.corp-resources-rg.name
  virtual_network_name = azurerm_virtual_network.corp-production-vnet.name
  address_prefixes     = ["10.10.10.0/24"]
}


#Create Peering between Hub and Spokes
#Hub to Production Spoke

resource "azurerm_virtual_network_peering" "hub-to-prod-spoke-peering" {
  name                      = "hub-to-prod-spoke-peering"
  resource_group_name       = azurerm_resource_group.corp-resources-rg.name
  virtual_network_name      = azurerm_virtual_network.corp-hub-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.corp-production-vnet.id
}

resource "azurerm_virtual_network_peering" "prod-spoke-to-hub-peering" {
  name                      = "prod-spoke-to-hub-peering"
  resource_group_name       = azurerm_resource_group.corp-resources-rg.name
  virtual_network_name      = azurerm_virtual_network.corp-production-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.corp-hub-vnet.id
}


#Create Virtual Network Gateway Public IP

resource "azurerm_public_ip" "corp-vngw-pip" {
  name                = "corp-vngw-pip"
  location            = azurerm_resource_group.corp-resources-rg.location
  resource_group_name = azurerm_resource_group.corp-resources-rg.name

  allocation_method = "Dynamic"
}


#Create the Virtual Network Gateway Resource
resource "azurerm_virtual_network_gateway" "hub-virtual-network-gateway" {
  name                = "hub-virtual-network-gateway"
  location            = azurerm_resource_group.corp-resources-rg.location
  resource_group_name = azurerm_resource_group.corp-resources-rg.name

  #Specify VPN Type
  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic" #Standard


  #Construct the Virtual Network Gateway Integration with Public IP
  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.corp-vngw-pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hub-gateway-subnet.id
  }
}