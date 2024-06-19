resource "azurerm_resource_group" "example" {
  name     = var.resource_group
  location = var.location
}

resource "azurerm_public_ip" "example_pip" {
  name                = "example-publicip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
  domain_name_label   = "azcoops"
}



resource "azurerm_network_security_group" "vm_sg" {
  name                = "vm-sg"
  location            = var.location
  resource_group_name = var.resource_group

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "vm_sg" {
  network_interface_id      = azurerm_network_interface.example_nic.id
  network_security_group_id = azurerm_network_security_group.vm_sg.id
}

resource "azurerm_virtual_network" "example_vnet" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_network_interface" "example_nic" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example_pip.id # Omit this line if no public IP is needed
  }
}

resource "azurerm_subnet" "example_subnet" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-vm"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B1s" # Adjusted to a smaller size
  admin_username      = var.vm_user
  network_interface_ids = [
    azurerm_network_interface.example_nic.id,
  ]

  admin_ssh_key {
    username   = var.vm_user
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "24.04.202404230"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.vm_user
      private_key = file("~/.ssh/id_rsa")
      host        = azurerm_linux_virtual_machine.example.public_ip_address
    }

    inline = [
      "sudo apt update && sudo apt install -y ansible sshpass sshfs",
      "mkdir -p ./sshmount"
    ]
  }
}

output "vm_public_ip" {
  value = azurerm_linux_virtual_machine.example.public_ip_address
}

resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "mkdir -p ./sshmount"
  }

  provisioner "local-exec" {
    command = <<EOT
      sshfs adminuser@azcoops.westeurope.cloudapp.azure.com:/home/adminuser/ ./sshmount || true
    EOT
  }

  provisioner "local-exec" {
    command = "ansible-playbook install_terraform_kubectl_helm.yaml -i hosts"
  }

  provisioner "local-exec" {
    command = "ansible-playbook install_azure_cli.yaml -i hosts"
  }

  depends_on = [
    azurerm_linux_virtual_machine.example
  ]
}
