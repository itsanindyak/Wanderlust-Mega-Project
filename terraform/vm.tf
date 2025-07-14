resource "azurerm_resource_group" "new" {
  location = "Central India"
  name = "project-rg"
}
resource "azurerm_virtual_network" "new" {
    name = "project-vn"
    resource_group_name = azurerm_resource_group.new.name # interpolation it is a way to inherit a vlaue from tf block
    location = azurerm_resource_group.new.location
    address_space = ["10.0.0.0/16"]
  
}

resource "azurerm_subnet" "new" {
  name = "project-subnet"
  virtual_network_name = azurerm_virtual_network.new.name
  resource_group_name = azurerm_resource_group.new.name
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "new" {
  name = "project-public-ip"
  location = azurerm_resource_group.new.location
  resource_group_name = azurerm_resource_group.new.name
  allocation_method = "Static"
  sku = "Basic"
}

resource "azurerm_network_security_group" "new" {
    resource_group_name = azurerm_resource_group.new.name
    name = "project-nsg"
    location = azurerm_resource_group.new.location

    security_rule {
        name = "ssh"
        direction = "Inbound"
        access = "Allow"
        priority = "300"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "*"
        destination_address_prefix = "*"

    }
  
}

resource "azurerm_network_interface" "new" {
    name = "project-nic"
    resource_group_name = azurerm_resource_group.new.name
    location = azurerm_resource_group.new.location
    

    ip_configuration {
      name = "project-pvt-ip"
      subnet_id = azurerm_subnet.new.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.new.id
    }
}

resource "azurerm_network_interface_security_group_association" "new" {
  network_interface_id = azurerm_network_interface.new.id
  network_security_group_id = azurerm_network_security_group.new.id
}

resource "azurerm_linux_virtual_machine" "new" {
    name = "project-vm"
    resource_group_name = azurerm_resource_group.new.name
    location = azurerm_resource_group.new.location
    size= var.instance_type
    admin_username = "projectadmin"
    network_interface_ids = [ azurerm_network_interface.new.id ]

    admin_ssh_key {
      username = "projectadmin"
      public_key = file("~/.ssh/id_ed25519.pub")
    }


    os_disk {
      caching = "ReadWrite"
      disk_size_gb = 30
      storage_account_type = "Premium_LRS"
    }

    source_image_reference {
      publisher = "Canonical"
      offer = "0001-com-ubuntu-server-jammy"
      sku = "22_04-lts"
      version = "latest"
    }
    
}

