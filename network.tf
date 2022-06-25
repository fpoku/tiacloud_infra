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

  custom_route {
           address_prefixes = ["192.168.1.0/24"]
        }


  vpn_client_configuration {
           address_space        = ["192.168.1.10/26"]
           vpn_auth_types       = ["AAD"]
           vpn_client_protocols = ["OpenVPN" ]
           aad_tenant   = "https://login.microsoftonline.com/${var.tenant_id}"
           aad_issuer   = "https://sts.windows.net/${var.tenant_id}/"
           aad_audience = "41b23e61-6c1e-4545-b367-cd054e0ed4b4"
        }
}


#https://www.tinfoilcipher.co.uk/2020/05/28/terraform-and-azure-automated-deployment-of-s2s-vpns/
#Import Infrastructure

#Create a Module to Support a non-azurerm resource

# module "vpn-gateway" {
#   source  = "https://registry.terraform.io/modules/kumarvna/"
#   version = "1.1.0"

#   # Resource Group, location, VNet and Subnet details
#   # IPSec Site-to-Site connection configuration requirements
#   resource_group_name  = azurerm_resource_group.corp-resources-rg.name
#   virtual_network_name = "${var.corp}-hub-vnet"
#   vpn_gateway_name     = "hub-virtual-network-gateway"
#   gateway_type         = "Vpn"

#   # local network gateway connection
#   local_networks = [
#     {
#       local_gw_name         = "londond-branch-to-azure"
#       local_gateway_address = "95.44.123.67"
#       local_address_space   = ["10.1.0.0/24"]
#       shared_key            = "xpCGkHTBQmDvZK9HnLr7DAvH"
#     },
#   ]
# }





#https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-point-to-site-resource-manager-portal - How to Setup Point-to-Site
#https://docs.microsoft.com/en-us/azure/vpn-gateway/point-to-site-about
#https://docs.microsoft.com/en-us/azure/vpn-gateway/openvpn-azure-ad-tenant - Enable Azure AD authentication on the VPN gateway
#https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-how-to-find-tenant - How to find your Azure Active Directory tenant ID