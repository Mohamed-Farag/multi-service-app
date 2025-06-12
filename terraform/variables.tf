# Location variable
# Specifies the Azure region where all resources will be created
# Default is set to "East US" but can be changed to any Azure region
variable "location" {
  description = "The location/region where resources will be created"
  type        = string
  default     = "East US"
}

# Resource group name variable
# Defines the name of the Azure resource group that will contain all resources
# Resource groups are used to organize and manage Azure resources
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "multi-service-app-rg"
}

# VM size variable
# Specifies the size of the virtual machines to be created
# Standard_B1s provides 1 vCPU and 1 GB RAM, suitable for development/testing
# Can be changed to other sizes for production workloads
variable "vm_size" {
  description = "Size of the virtual machines"
  type        = string
  default     = "Standard_B1s"
}

# Admin username variable
# Defines the username for the virtual machines
# This user will have sudo privileges on the VMs
variable "admin_username" {
  description = "Username for the virtual machines"
  type        = string
  default     = "adminuser"
}

# VM count variable
# Specifies the number of virtual machines to create
# Currently set to 2 for Service A and Service B
# Can be adjusted if more VMs are needed
variable "vm_count" {
  description = "Number of virtual machines to create"
  type        = number
  default     = 2
}

# Environment variable
# Used to distinguish between different environments (dev, staging, prod)
# Can be used to apply different configurations based on the environment
variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
} 