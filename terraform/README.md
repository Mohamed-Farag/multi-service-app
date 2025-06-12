# Infrastructure as Code for Multi-Service Application

This directory contains Terraform code to set up the infrastructure for the multi-service application.

## Infrastructure Components

1. **Virtual Machines**
   - Two Ubuntu 18.04 LTS VMs
   - Service A VM for user management
   - Service B VM for data processing
   - Standard_B1s size (1 vCPU, 1 GB RAM)

2. **Networking**
   - Virtual Network with subnet
   - Network Security Group with rules for:
     - SSH (port 22)
     - HTTP (port 80)
     - HTTPS (port 443)
   - Public IPs for both VMs

3. **Monitoring**
   - Azure Log Analytics Workspace
   - VM monitoring extensions
   - 30-day log retention

## Prerequisites

1. Azure CLI installed and configured
2. Terraform installed
3. SSH key pair generated

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Review the planned changes:
```bash
terraform plan
```

3. Apply the infrastructure:
```bash
terraform apply
```

4. To destroy the infrastructure:
```bash
terraform destroy
```

## Configuration

The infrastructure can be configured through variables in `variables.tf`:
- `location`: Azure region
- `resource_group_name`: Name of the resource group
- `vm_size`: Size of the virtual machines
- `admin_username`: VM admin username
- `vm_count`: Number of VMs to create
- `environment`: Environment name (dev/prod)

## Security Notes

1. The infrastructure uses SSH key authentication
2. Network Security Group rules are configured for basic access
3. Consider adding additional security measures for production:
   - More restrictive NSG rules
   - Azure Key Vault for secrets
   - Azure Private Link for private networking
   - Azure Firewall for additional protection 