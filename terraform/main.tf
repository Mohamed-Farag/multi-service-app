terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" # The official AWS plugin
      version = "~> 3.0"        # Use version 3.x
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1" # Deploy resources to Frankfurt
}
