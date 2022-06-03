#Output the SSH Key
output "tls-private-key" {

  value     = tls_private_key.linuxvmsshkey
  sensitive = true
}


# output "network_interface_ids" {
#   description = "ids of the vm nics provisoned."
#   value       = "${azurerm_network_interface.vm.*.id}"
# }



# output "azurerm_virtual_network_peering" {
# description = "Get IDs of Peering"
# value = "prod-spoke-to-hub-peering"

# }