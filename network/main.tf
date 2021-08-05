provider "azurerm" {
  version = "=2.0.0"
  features {}
}
 
 terraform {
  backend "azurerm" {
    resource_group_name   = "TerraformDemoResourceGroup"
    storage_account_name  = "terraformdemoaccount"
    container_name        = "democontainer"
    key                   = "mytfkey"
  }
}
resource "azurerm_resource_group" "rg" {
     name     = "${var.resourcegroup_name}"
    location = "centralus"
    
    tags = {
        Environment = "Terraform Getting Started"
        Team = "NeudesicTf"   
    }
}
 
# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
  name                = "${var.vnet_name}"
    address_space       = ["10.0.0.0/16"]
    location            = "centralus"
    resource_group_name = azurerm_resource_group.rg.name
 
     tags = {
        Environment = "Terraform Getting Started"
        Team = "NeudesicTf"   
    }
}
 
# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name           = "${var.subnet_name1}"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefix       = "10.0.1.0/24"
}
 
# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = azurerm_resource_group.rg.location
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Dynamic"
 
    tags = {
        environment = "Terraform Demo"
    }
}
 
# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "myNIC"
    location                  = azurerm_resource_group.rg.location
    resource_group_name       = azurerm_resource_group.rg.name
 
    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    }
 
    tags = {
        environment = "Terraform Demo"
    }
}
 
# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
    name                  = "myVM"
    location              = azurerm_resource_group.rg.location
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    size                  = "Standard_B1ls"
 
    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
 
    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }
 
    computer_name  = "myvm"
    admin_username = "azureuser"
    admin_password = "E_9895070723"
    disable_password_authentication = false
        
    # admin_ssh_key {
    #     username       = "azureuser"
    #     public_key     = file("/home/azureuser/.ssh/authorized_keys")
    # }
 
    # boot_diagnostics {
    #     storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    # }
 
    tags = {
        environment = "Terraform Demo"
    }
 
}
 
resource "azurerm_app_service_plan" "example" {
  name                = "example-appserviceplan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
 
  sku {
    tier = "Standard"
    size = "S1"
  }
  
}
 
resource "azurerm_app_service" "example" {
  name                = "prajeeshappservice"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.example.id
 
  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }
 
 connection_string {
   name  = "Database"
   type  = "SQLServer"
   value = "Server=tcp:${azurerm_sql_server.test.fully_qualified_domain_name} Database=${azurerm_sql_database.test.name};User ID=${azurerm_sql_server.test.administrator_login};Password=${azurerm_sql_server.test.administrator_login_password};Trusted_Connection=False;Encrypt=True;"
  }
}
 
resource "azurerm_sql_server" "test" {
  name                         = "terraform-sqlserverdemo"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "tsprajeesh"
  administrator_login_password = "mypassword-12345"
}
 
resource "azurerm_sql_database" "test" {
  name                = "terraform-sqldatabasedemo"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.test.name
 
  tags = {
    environment = "dev"
  }
}

