# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
      
    }
  }
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "fa03a648-62e4-4894-adbf-245eecce4f4f"
  features {}
}

resource "azurerm_resource_group" "rg0x" {
  name     = "rg0x"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "Vnet01"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg0x.location
  resource_group_name = azurerm_resource_group.rg0x.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet01"
  resource_group_name  = azurerm_resource_group.rg0x.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_public_ip" "createpip" {
  name                = "PIP01"
  resource_group_name = azurerm_resource_group.rg0x.name
  location            = azurerm_resource_group.rg0x.location
  allocation_method   = "Static"
  sku = "Standard"
  ip_version = "IPv4"
}



resource "azurerm_network_interface" "example" {
  name                = "server01-nic"
  location            = azurerm_resource_group.rg0x.location
  resource_group_name = azurerm_resource_group.rg0x.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.createpip.id
  }
}

resource "azurerm_windows_virtual_machine" "vm01" {
  name                = "server01"
  resource_group_name = azurerm_resource_group.rg0x.name
  location            = azurerm_resource_group.rg0x.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}