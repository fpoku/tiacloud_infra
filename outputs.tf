#Output the SSH Key
output "tls-private-key" {

  value     = tls_private_key.linuxvmsshkey
  sensitive = true
}