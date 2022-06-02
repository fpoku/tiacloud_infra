



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