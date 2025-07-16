output "public_ip" {
  value = azurerm_public_ip.new.ip_address
}