#Specify type of resource being deployed here - "${var.corp}-${var.mgmt}-${var.webres[0]}-01"
variable "locations" {
  default = ["uksouth", "ukwest", "eastus", "westeurope"]
}


#Specify environments
#Specify type of resource being deployed here - "${var.corp}-${var.mgmt}-${var.webres[0]}-01"
variable "envs" {
  default = ["production", "corporate", "management", "staging", "development"]
}


#Specify network segments
variable "env" {
  default = ["vnet", "subnet"]
}




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
  default = ["vm", "webapp", "slb", "appgw"]
}



#Location Of Resources
variable "location" {
  description = "availability zone that is a string type variable"
  type        = string
  default     = "uksouth"
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
  type = map(any)
  default = {
    environment = "training"
    source      = "citadel"
  }
}

variable "webAppLocations" {
  default = ["francecentral", "canadaeast", "brazilsouth", "japanwest"]
}


variable "tenant_id" {
  type = string
  default = "d2fd36de-02f3-45f2-9f60-1b88e49ec467"
}

#"${var.webAppLocations[2]}"
#"${length(var.webAppLocations[2])}"  - count the number of characters that spells brazilsouth