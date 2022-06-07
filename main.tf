

resource "azurerm_linux_virtual_machine" "corporate-production-vm01" {
  name                  = "${var.corp}-${var.prod}-${var.webres[0]}-01"
  location              = azurerm_resource_group.corp-resources-rg.location
  resource_group_name   = azurerm_resource_group.corp-resources-rg.name
  network_interface_ids = [azurerm_network_interface.corporate-production-vm01-nic.id]
  size                  = "Standard_B1s" #"Standard_D2d_v4" #"Standard_DC1ds_v3"


  #Create Operating System Disk
  os_disk {
    name                 = "corpprodvm01disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" #Consider Storage Type
  }


  #NFS Mount Resource

  #Reference Source Image from Publisher
  source_image_reference {
    publisher = "Canonical"                    #az vm image list -p "Canonical" --output table
    offer     = "0001-com-ubuntu-server-focal" # az vm image list -p "Canonical" --output table
    sku       = "20_04-lts-gen2"               #az vm image list -s "18.04-LTS" --output table
    version   = "latest"
  }

  #Create Computer Name and Specify Administrative User Credentials
  computer_name                   = "corporate-production-vm01"
  admin_username                  = "linuxsrvuser"
  disable_password_authentication = true


  #Create SSH Key for Secured Authentication - on Windows Management Server [Putty + PrivateKey]
  admin_ssh_key {
    username   = "linuxsrvuser"
    public_key = tls_private_key.linuxvmsshkey.public_key_openssh
  }

  #Prepare Environment for Cloud Initialised Packages
  custom_data = data.template_cloudinit_config.production-vm-config.rendered
}

#Custom Data Insertion Here

data "template_cloudinit_config" "production-vm-config" {
  gzip          = true
  base64_encode = true

  part {

    content_type = "text/cloud-config"
    content      = "packages: ['htop','pip','python3']" #specify package to be installed. [ansible, terraform, azurecli]
  }
}




# Create (and display) an SSH key
resource "tls_private_key" "linuxvmsshkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


#Find out how to install custom environments using terraform


#Create Public IPs
# resource "azurerm_public_ip" "corporate-production-vm01-pubip" {
#   name                = "corporate-production-vm01-pubip"
#   location            = azurerm_resource_group.corp-resources-rg.location
#   resource_group_name = azurerm_resource_group.corp-resources-rg.name #try "${var.corp}-rg"
#   allocation_method   = "Dynamic"
# }



# Create Private Network Interface - NIC
resource "azurerm_network_interface" "corporate-production-vm01-nic" {
  name                 = "corporate-production-vm01-nic"
  location             = azurerm_resource_group.corp-resources-rg.location
  resource_group_name  = azurerm_resource_group.corp-resources-rg.name
  enable_ip_forwarding = false

  #Assign IP Addressing to Network Interface
  ip_configuration {
    name                          = "corporate-production-vm01-nic-ip"
    subnet_id                     = azurerm_subnet.corp-production-subnet.id #Associate NIC to the Corporate Production Subnet
    private_ip_address_allocation = "Dynamic"                                #Azure's Dynamic Allocation of IP Addressing starting from .4 of that Subnet's CIDR.
    #public_ip_address_id          = azurerm_public_ip.corporate-production-vm01-pubip.id #Associate the Private NIC to the Public IP.
  }

}

#Create Load Balancing Resource
#Create FrontEnd IP and Backend Pools.

# Create Network Security Group and rule
# resource "azurerm_network_security_group" "corporate-production-nsg" {
#   name                = "corporate-production-nsg"
#   location            = azurerm_resource_group.corp-resources-rg.location
#   resource_group_name = azurerm_resource_group.corp-resources-rg.name

# Create Network Security Group and rule
resource "azurerm_network_security_group" "corporate-production-nsg" {
  name                = "${var.envs[1]}-${var.envs[0]}-nsg"
  location            = "${var.locations[0]}" 
  resource_group_name = "${var.corp}-resources-rg"

  #Add rule for Inbound Access
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.ssh_access_port # Referenced SSH Port 22 from vars.tf file.
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Connect the security group to the network interface or the subnet
# resource "azurerm_network_interface_security_group_association" "corporate-production-vm-01-nsg-link" {
# network_interface_id      = azurerm_network_interface.corporate-production-vm01-nic.id
# network_security_group_id = azurerm_network_security_group.corporate-production-nsg.id
# }


resource "azurerm_subnet_network_security_group_association" "corporate-production-vm-01-nsg-link" {
  subnet_id                 = azurerm_subnet.corp-production-subnet.id
  network_security_group_id = azurerm_network_security_group.corporate-production-nsg.id
}

#Lock Resource from Accidental Deletion
# resource "azurerm_management_lock" "corp-production-ip" {
#   name       = "resource-ip"
#   scope      = azurerm_public_ip.corporate-production-vm01-pubip.id
#   lock_level = "CanNotDelete"
#   notes      = "Locked - Production Server"
# }