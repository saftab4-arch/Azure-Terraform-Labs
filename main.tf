data "azurerm_resource_group" "lab" {
  name = "1-b339435d-playground-sandbox"
}

resource "azurerm_virtual_network" "lab_vnet" {
  name                = var.vnet_name
  address_space       = ["10.10.0.0/16"]
  location            = var.location
  resource_group_name = data.azurerm_resource_group.lab.name
}

resource "azurerm_subnet" "lab_subnet" {
  name                 = var.subnet_name
  resource_group_name  = data.azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab_vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_security_group" "lab_nsg" {
  name                = "nsg-lab01"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.lab.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_subnet_network_security_group_association" "lab_nsg_assoc" {
  subnet_id                 = azurerm_subnet.lab_subnet.id
  network_security_group_id = azurerm_network_security_group.lab_nsg.id
}

resource "azurerm_public_ip" "lab_public_ip" {
  name                = "pip-lab01"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "lab_nic" {
  name                = "nic-lab01"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lab_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lab_public_ip.id
  }
}


resource "azurerm_linux_virtual_machine" "lab_vm" {
  name                = "vm-lab01"
  resource_group_name = data.azurerm_resource_group.lab.name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.lab_nic.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}


resource "azurerm_storage_account" "tfstate" {
  name                = "sytflab01state12345"
  resource_group_name = data.azurerm_resource_group.lab.name

  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"



  tags = {
    environment = "Lab"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}


resource "azurerm_network_security_group" "imported_nsg" {
  name                = "nsg-import-lab"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.lab.name
}
