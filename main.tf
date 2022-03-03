# we assume that this Custom Image already exists
data "azurerm_image" "custom" {
  name                = "${var.custom_image_name}"
  resource_group_name = "${var.custom_image_resource_group_name}"
}

resource "azurerm_resource_group" "example" {
  name     = "${var.deploy_resource_group}"
  location = "${var.deploy_location}"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet31"
  address_space       = ["172.31.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "linuxvms" {
  name                      = "subnet100"
  resource_group_name       = azurerm_resource_group.example.name
  virtual_network_name      = azurerm_virtual_network.example.name
  address_prefixes          = ["172.31.100.0/24"]
}

resource "azurerm_network_security_group" "example" {
  name                = "linuxvms-subnet-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_network_security_rule" "example1" {
  name                        = "allow_TCP80"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.example.name
  priority                    = 500
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "example2" {
  name                        = "allow_TCP22"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.example.name
  priority                    = 501
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.tf_host_source_pip1}/32"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "example3" {
  name                        = "allow_TCP22_test"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.example.name
  priority                    = 502
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.tf_host_source_pip2}/32"
  destination_address_prefix  = "*"
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.linuxvms.id
  network_security_group_id = azurerm_network_security_group.example.id
}

### linux vm
# Create public IPs
resource "azurerm_public_ip" "linuxvm1" {
    name                         = "linuxvm1pip"
    location                     = azurerm_resource_group.example.location
    resource_group_name          = azurerm_resource_group.example.name
    allocation_method            = "Dynamic"
}

resource "azurerm_network_interface" "linuxvm1" {
  name                = "linuxvm1-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.linuxvms.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linuxvm1.id

  }
}

# You need to Base64 encode the value of custom_data.
locals {
  custom_data = <<CUSTOM_DATA
    #cloud-config
    package_upgrade: true
    runcmd:
      - echo "This is cloud-int test" > /tmp/test01_cloudinit.txt 
  CUSTOM_DATA
}

resource "azurerm_linux_virtual_machine" "linuxvm1" {
  name                            = "${var.custom_image_name}-vm"
  location                        = "${azurerm_resource_group.example.location}"
  resource_group_name             = "${azurerm_resource_group.example.name}"
  size                            = "Standard_B2s"
  admin_username                  = "azureuser"
  admin_password                  = "P@ssw0rd1234!"
  disable_password_authentication = false
  network_interface_ids           = ["${azurerm_network_interface.linuxvm1.id}"]
  source_image_id                 = "${data.azurerm_image.custom.id}" 
  allow_extension_operations      = true

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

# You need to Base64 encode the value of custom_data.
  custom_data = base64encode(local.custom_data)

#  You need to open port 22 because remote-exec requires an ssh connection to execute.
  provisioner "remote-exec" {
    inline = [
      "ls -la /tmp > /tmp/test02_remoteexec.txt",
    ]

    connection {
      host     = self.public_ip_address
      user     = self.admin_username
      password = self.admin_password
    }
  }
}

resource "azurerm_virtual_machine_extension" "example" {
  name                 = "hostname"
  virtual_machine_id   = azurerm_linux_virtual_machine.linuxvm1.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "hostname > /tmp/test03_extention.txt"
    }
SETTINGS

  tags = {
    environment = "Production"
  }
}
