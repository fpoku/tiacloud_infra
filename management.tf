#Dedicated Manifest for the Management Network Resource


resource "azurerm_windows_virtual_machine" "corporate-management-vm01" {
  name                  = "${var.corp}-${var.mgmt}-${var.webres[0]}-01"
  location              = azurerm_resource_group.corp-resources-rg.location
  resource_group_name   = azurerm_resource_group.corp-resources-rg.name
  network_interface_ids = [azurerm_network_interface.corporate-management-vm01-nic.id]
  size                  = "Standard_D2d_v4" #"Standard_D2s_v3"  #"Standard_DC1ds_v3"

#Specify Administrative Credentials - Use Managed Identities - has known issues - enable Virtual Machine User or Administrator
#Create Computer Name and Specify Administrative User Credentials
  computer_name       = "corp-mgmt-vm01" 
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"

  #Create Operating System Disk
  os_disk {
    name                 = "corpmgmtvm01disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" #Consider Storage Type
  }


  #NFS Mount Resource

  #Reference Source Image from Publisher
  source_image_reference {
    publisher = "MicrosoftWindowsServer"                    #az vm image list -p "Microsoft" --output table
    offer     = "WindowsServer"                  # az vm image list --offer "WindowsServer" --output table
    sku       = "2019-datacenter-gensecond"               # az vm image list -s "2019-Datacenter" --output table
    version   = "latest"
  }


  

}



#Find out how to install custom environments using terraform


#Create Public IPs
resource "azurerm_public_ip" "corporate-management-vm01-pubip" {
  name                = "corporate-management-vm01-pubip"
  location            = azurerm_resource_group.corp-resources-rg.location
  resource_group_name = azurerm_resource_group.corp-resources-rg.name #try "${var.corp}-rg"
  allocation_method   = "Dynamic"
}



# Create Private Network Interface - NIC
resource "azurerm_network_interface" "corporate-management-vm01-nic" {
  name                 = "corporate-management-vm01-nic"
  location             = azurerm_resource_group.corp-resources-rg.location
  resource_group_name  = azurerm_resource_group.corp-resources-rg.name
  enable_ip_forwarding = false

  #Associate Public IP Addressing to Network Interface
  ip_configuration {
    name                          = "corporate-management-vm01-nic-ip"
    subnet_id                     = azurerm_subnet.hub-management-subnet.id             #Associate NIC to the Corporate management Subnet
    private_ip_address_allocation = "Dynamic"                                            #Azure's Dynamic Allocation of IP Addressing starting from .4 of that Subnet's CIDR.
    public_ip_address_id          = azurerm_public_ip.corporate-management-vm01-pubip.id #Associate the Private NIC to the Public IP.
  }

}

#Create Load Balancing Resource
#Create FrontEnd IP and Backend Pools.

# Create Network Security Group and rule
resource "azurerm_network_security_group" "corporate-management-nsg" {
  name                = "corporate-management-nsg"
  location            = azurerm_resource_group.corp-resources-rg.location
  resource_group_name = azurerm_resource_group.corp-resources-rg.name


  #Add rule for Inbound Access
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.rdp_access_port # Referenced SSH Port 22 from vars.tf file.
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# #Connect the security group to the network interface or the subnet
# resource "azurerm_network_interface_security_group_association" "corporate-management-vm-01-nsg-link" {
# network_interface_id      = azurerm_network_interface.corporate-management-vm01-nic.id
# network_security_group_id = azurerm_network_security_group.corporate-management-nsg.id
# }


resource "azurerm_subnet_network_security_group_association" "corporate-management-vm-01-nsg-link" {
  subnet_id                 = azurerm_subnet.hub-management-subnet.id
  network_security_group_id = azurerm_network_security_group.corporate-management-nsg.id
}

#Lock Resource from Accidental Deletion
resource "azurerm_management_lock" "corp-management-ip" {
  name       = "resource-ip"
  scope      = azurerm_public_ip.corporate-management-vm01-pubip.id
  lock_level = "CanNotDelete"
  notes      = "Locked - management Server"
}