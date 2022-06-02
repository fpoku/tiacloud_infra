



#Corporate Naming Convention Prefix for Resources
variable "corp" {
  description = "corporate naming convention prefix"
  default     = "corp"

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