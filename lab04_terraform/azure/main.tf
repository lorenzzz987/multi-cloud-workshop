provider "azurerm" {
}

resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "terraform-multicloud-ip-student${var.studentID}"
    location                     = "${var.location}"
    resource_group_name          = "multi-cloud-workshop-pxl-${var.studentID}"
    allocation_method            = "Static"
}

resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "terraform-multicloud-secgroup-student${var.studentID}"
    location            = "${var.location}"
    resource_group_name = "multi-cloud-workshop-pxl-${var.studentID}"
    
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
    
		security_rule {
        name                       = "HTTP"
        priority                   = 1011
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_network_interface" "myterraformnic" {
    name                = "terraform-multicloud-nic-student${var.studentID}"
    location            = "${var.location}"
    resource_group_name = "multi-cloud-workshop-pxl-${var.studentID}"
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

    ip_configuration {
        name                          = "terraform-multicloud-nicCfg-student${var.studentID}"
        subnet_id                     = "/subscriptions/138059db-9be5-43ba-979f-67dcc9ee5e3d/resourceGroups/multicloud-workshop/providers/Microsoft.Network/virtualNetworks/multicloud-workshop-vnet/subnets/default"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
    }
}

resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "terraform-instance-azure-student${var.studentID}"
    location              = "${var.location}"
    resource_group_name   = "multi-cloud-workshop-pxl-${var.studentID}"
    network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
    vm_size               = "${var.azure_machine_type}"

    storage_os_disk {
        name              = "myOsDisk-student${var.studentID}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }
    delete_os_disk_on_termination = true

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "terraform-instance-azure-student${var.studentID}"
        admin_username = "ubuntu"
        custom_data    = file("cloud-config.txt")
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/ubuntu/.ssh/authorized_keys"
            key_data = file("~/.ssh/workshop_key.pub")
        }
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = "https://multicloudworkshopdiag.blob.core.windows.net/"
    }
}

data "azurerm_public_ip" "test" {
  name                = "${azurerm_public_ip.myterraformpublicip.name}"
  resource_group_name = "multi-cloud-workshop-pxl-${var.studentID}"
}

resource "azurerm_dns_a_record" "myterraformdns" {
  name                = "${var.studentID}"
  zone_name           = "azure.gluo.cloud"
  resource_group_name = "multi-cloud-workshop"
  ttl                 = 60
  records             = ["${data.azurerm_public_ip.test.ip_address}"]
}

output "public_ip_address" {
  value = "${data.azurerm_public_ip.test.ip_address}"
}

