# Create (and display) an SSH key
resource "tls_private_key" "linuxvm02sshkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


#Create Public IPs
resource "azurerm_public_ip" "corporate-production-vm02-pubip" {
  name                = "${var.corp}-${var.prod}-vm02-pubip"
  location            = "${var.locations[0]}"
  resource_group_name = "${var.corp}-resources-rg"
  allocation_method   = "Dynamic"
}



#Create Linux Instance
resource "azurerm_linux_virtual_machine" "corporate-production-vm02" {
  name                  = "${var.corp}-${var.prod}-${var.webres[0]}02"
  location              = "${var.locations[0]}"
  resource_group_name   = "${var.corp}-resources-rg"
  network_interface_ids = [azurerm_network_interface.corporate-production-vm02-nic.id]
  size                  = "Standard_B1s" # "Standard_D2ads_v5" # "Standard_DC1ds_v3"



  #Create Operating System Disk
  os_disk {
    name                 = "${var.corp}prodvm02disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" #Consider Storage Type
  }

  #Reference Source Image from Publisher
  source_image_reference {
    publisher = "Canonical"                    #az vm image list -p "Canonical" --output table
    offer     = "0001-com-ubuntu-server-focal" # az vm image list -p "Canonical" --output table
    sku       = "20_04-lts-gen2"               #az vm image list -s "18.04-LTS" --output table
    version   = "latest"
  }


  #Create Computer Name and Specify Administrative User Credentials
  computer_name                   = "${var.corp}-${var.prod}-vm02"
  admin_username                  = "linuxsvruser"
  disable_password_authentication = true


  #Create SSH Key for Secured Authentication - on Windows Management Server [Putty + PrivateKey]
  admin_ssh_key {
    username   = "linuxsvruser"
    public_key = tls_private_key.linuxvm02sshkey.public_key_openssh
  }

  #Prepare Environment for Cloud Initialised Packages
  custom_data = data.template_cloudinit_config.corporate-vm02-config.rendered
}

#Custom Data Insertion Here

data "template_cloudinit_config" "corporate-vm02-config" {
  gzip          = true
  base64_encode = true

  part {

    content_type = "text/cloud-config"
    content      = "packages: ['htop','pip','python3']" #specify package to be installed. [ansible, terraform, azurecli]
  }

}





# Create Private Network Interface - NIC
resource "azurerm_network_interface" "corporate-production-vm02-nic" {
  name                 = "${var.corp}-${var.prod}-vm02-nic"
  location             = "${var.locations[0]}" 
  resource_group_name  = "${var.corp}-resources-rg"
  enable_ip_forwarding = false


  #Assign IP Addressing to Network Interface
  ip_configuration {
    name                          = "corporate-production-vm02-nic-ip"
    subnet_id                     = azurerm_subnet.corp-production-subnet.id                     #Associate NIC to the Corporate Production Subnet
    private_ip_address_allocation = "Dynamic"                                            #Azure's Dynamic Allocation of IP Addressing starting from .4 of that Subnet's CIDR.
    #Associate the Private NIC to the Public IP.
  }

}

#terraform taint tls_private_key


