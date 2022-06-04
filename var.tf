



#Corporate Naming Convention Prefix for Resources 
variable "corp" {
  description = "corporate naming convention prefix"
  default     = "corp"

}

#Corporate Naming Convention Prefix for Virtual Machine Environments -"${var.corp}-${var.mgmt}-vm01"
variable "mgmt" {
  description = "corporate naming convention prefix"
  default     = "management"

}


#Corporate Naming Convention Prefix for Virtual Machine Environments - "${var.corp}-${var.prod}-vm01"
variable "prod" {
  description = "corporate naming convention prefix"
  default     = "production"

}


#Specify type of resource being deployed here - "${var.corp}-${var.mgmt}-${var.webres[0]}-01"
variable "webres" {
    default = [ "vm", "webapp", "slb", "appgw" ]
}



#Location Of Resources
variable "location" {
  description = "availability zone that is a string type variable"
  type        = string
  default     = "eastus2"
}


#Specify Ports for NSG Rules
variable "ssh_access_port" {
  description = "dedicated ssh port for webserver shell access"
  default     = 22

}


variable "rdp_access_port" {
  description = "dedicated ssh port for webserver shell access"
  default     = 3389

}

variable "tags" {
    type = map
    default = {
        environment = "training"
        source      = "citadel"
    }
}

variable "webAppLocations" {
    default = [ "francecentral", "canadaeast", "brazilsouth", "japanwest" ]
}

#"${var.webAppLocations[2]}"
#"${length(var.webAppLocations[2])}"  - count the number of characters that spells brazilsouth