# Configure the Azure Provider
# This block tells Terraform to use the Azure Resource Manager provider
provider "azurerm" {
  features {}  # Required for provider configuration
}

# Create a resource group
# Resource groups are containers that hold related Azure resources
resource "azurerm_resource_group" "app_rg" {
  name     = "multi-service-app-rg"  # Name of the resource group
  location = "East US"               # Azure region where resources will be created
}

# Create a virtual network
# Virtual networks provide isolation and security for Azure resources
resource "azurerm_virtual_network" "app_vnet" {
  name                = "app-vnet"           # Name of the virtual network
  address_space       = ["10.0.0.0/16"]     # IP address range for the network (65,536 IPs)
  location            = azurerm_resource_group.app_rg.location  # Same location as resource group
  resource_group_name = azurerm_resource_group.app_rg.name      # Reference to resource group
}

# Create a subnet within the virtual network
# Subnets help organize and secure resources within a virtual network
resource "azurerm_subnet" "app_subnet" {
  name                 = "app-subnet"        # Name of the subnet
  resource_group_name  = azurerm_resource_group.app_rg.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name  # Reference to virtual network
  address_prefixes     = ["10.0.1.0/24"]    # IP range for subnet (256 IPs)
}

# Create Network Security Group (NSG)
# NSGs act as a firewall to control network traffic
resource "azurerm_network_security_group" "app_nsg" {
  name                = "app-nsg"           # Name of the security group
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name

  # Security rule for SSH access
  security_rule {
    name                       = "SSH"      # Name of the rule
    priority                   = 1001       # Rule priority (lower number = higher priority)
    direction                  = "Inbound"  # Direction of traffic
    access                     = "Allow"    # Allow or deny traffic
    protocol                   = "Tcp"      # Protocol type
    source_port_range          = "*"        # Any source port
    destination_port_range     = "22"       # SSH port
    source_address_prefix      = "*"        # Any source IP
    destination_address_prefix = "*"        # Any destination IP
  }

  # Security rule for HTTP access
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"       # HTTP port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Security rule for HTTPS access
  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"      # HTTPS port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create public IP for Service A VM
# Public IPs allow resources to be accessible from the internet
resource "azurerm_public_ip" "service_a_pip" {
  name                = "service-a-pip"     # Name of the public IP
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
  allocation_method   = "Dynamic"           # IP address is assigned dynamically
}

# Create public IP for Service B VM
resource "azurerm_public_ip" "service_b_pip" {
  name                = "service-b-pip"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
  allocation_method   = "Dynamic"
}

# Create network interface for Service A VM
# Network interfaces connect VMs to the virtual network
resource "azurerm_network_interface" "service_a_nic" {
  name                = "service-a-nic"     # Name of the network interface
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name

  # IP configuration for the network interface
  ip_configuration {
    name                          = "internal"                # Name of the IP configuration
    subnet_id                     = azurerm_subnet.app_subnet.id  # Reference to subnet
    private_ip_address_allocation = "Dynamic"                 # Dynamic IP assignment
    public_ip_address_id          = azurerm_public_ip.service_a_pip.id  # Reference to public IP
  }
}

# Create network interface for Service B VM
resource "azurerm_network_interface" "service_b_nic" {
  name                = "service-b-nic"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.service_b_pip.id
  }
}

# Create Service A Virtual Machine
# This VM will host the user management service
resource "azurerm_linux_virtual_machine" "service_a_vm" {
  name                = "service-a-vm"      # Name of the VM
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
  size                = "Standard_B1s"      # VM size (1 vCPU, 1 GB RAM)
  admin_username      = "adminuser"         # Admin username

  # Network interface configuration
  network_interface_ids = [
    azurerm_network_interface.service_a_nic.id,  # Reference to network interface
  ]

  # SSH key configuration for secure access
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")  # Path to public SSH key
  }

  # OS disk configuration
  os_disk {
    caching              = "ReadWrite"      # Disk caching mode
    storage_account_type = "Standard_LRS"   # Storage account type (Locally Redundant)
  }

  # VM image configuration
  source_image_reference {
    publisher = "Canonical"                 # Image publisher
    offer     = "UbuntuServer"              # Image offer
    sku       = "18.04-LTS"                 # Image SKU (version)
    version   = "latest"                    # Image version
  }
}

# Create Service B Virtual Machine
# This VM will host the data processing service
resource "azurerm_linux_virtual_machine" "service_b_vm" {
  name                = "service-b-vm"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
  size                = "Standard_B1s"
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.service_b_nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

# Create Log Analytics Workspace
# This workspace collects and analyzes monitoring data
resource "azurerm_log_analytics_workspace" "monitoring" {
  name                = "app-monitoring-workspace"  # Name of the workspace
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
  sku                 = "PerGB2018"                # Pricing tier
  retention_in_days   = 30                         # Log retention period
}

# Enable monitoring for Service A VM
# This extension installs the monitoring agent
resource "azurerm_virtual_machine_extension" "service_a_monitoring" {
  name                 = "service-a-monitoring"    # Name of the extension
  virtual_machine_id   = azurerm_linux_virtual_machine.service_a_vm.id  # Reference to VM
  publisher            = "Microsoft.EnterpriseCloud.Monitoring"  # Extension publisher
  type                 = "OmsAgentForLinux"        # Extension type
  type_handler_version = "1.13"                    # Extension version

  # Settings for the monitoring agent
  settings = jsonencode({
    workspaceId = azurerm_log_analytics_workspace.monitoring.workspace_id  # Workspace ID
  })

  # Protected settings (sensitive data)
  protected_settings = jsonencode({
    workspaceKey = azurerm_log_analytics_workspace.monitoring.primary_shared_key  # Workspace key
  })
}

# Enable monitoring for Service B VM
resource "azurerm_virtual_machine_extension" "service_b_monitoring" {
  name                 = "service-b-monitoring"
  virtual_machine_id   = azurerm_linux_virtual_machine.service_b_vm.id
  publisher            = "Microsoft.EnterpriseCloud.Monitoring"
  type                 = "OmsAgentForLinux"
  type_handler_version = "1.13"

  settings = jsonencode({
    workspaceId = azurerm_log_analytics_workspace.monitoring.workspace_id
  })

  protected_settings = jsonencode({
    workspaceKey = azurerm_log_analytics_workspace.monitoring.primary_shared_key
  })
} 