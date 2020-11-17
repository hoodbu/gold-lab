variable "aws_profile" { default = "default" }
variable "aws_account_name" { default = "aws-uhoodbhoy" }
variable "aws_region" { default = "us-east-2" }
# Only needed if you want to launch test EC2 instances.
variable "aws_ec2_key_name" { default = "acelab-pro" }

variable "azure_account_name" { default = "azure-uhoodbhoy" }
variable "azure_region" { default = "West US" }
variable "azure_subscription_id" { default = "" }
variable "azure_directory_id" { default = "" }
variable "azure_application_id" { default = "" }
variable "azure_application_key" { default = "" }

variable "gcp_account_name" { default = "gcp-uhoodbhoy" }
variable "gcp_region" { default = "europe-west1" }

### AWS VPCs
variable "aws_transit_vpcs" {
  default = {
    aws_transit_vpc = {
      name       = "AWS-UE2-Transit-VPC"
      cidr       = "10.60.0.0/16"
      is_transit = true
      is_firenet = false
    }
  }
}

variable "aws_spoke_vpcs" {
  default = {
    aws_spoke1_vpc = {
      name = "AWS-UE2-Spoke1-VPC"
      cidr = "10.61.0.0/16"
      is_transit = false
      is_firenet = false
    }
    aws_spoke2_vpc = {
      name = "AWS-UE2-Spoke2-VPC"
      cidr = "10.62.0.0/16"
      is_transit = false
      is_firenet = false
    }
  }
}

### AWS Aviatrix Transit gateway.
variable "aws_transit_gateway" {
  default = {
    name         = "AWS-UE2-Transit-GW"
    size         = "t3.small"
    active_mesh  = true
    single_az_ha = true
    vpc          = "aws_transit_vpc"
  }
}

variable "aws_spoke_gateways" {
  default = {
    spoke1 = {
      name         = "AWS-UE2-Spoke1-GW"
      size         = "t3.small"
      active_mesh  = true
      single_az_ha = true
      vpc          = "aws_spoke1_vpc"
    },
    spoke2 = {
      name         = "AWS-UE2-Spoke2-GW"
      size         = "t3.small"
      active_mesh  = true
      single_az_ha = true
      vpc          = "aws_spoke2_vpc"
    }
  }
}

### Test EC2 instances.
variable "test_ec2_instances" {
  default = {
    spoke1_vm = {
      name                        = "Spoke1-VM"
      vpc                         = "aws_spoke1_vpc"
      size                        = "t2.micro"
      associate_public_ip_address = true
    }
    spoke2_vm = {
      name                        = "Spoke2-VM"
      vpc                         = "aws_spoke2_vpc"
      size                        = "t2.micro"
      associate_public_ip_address = true
    }
  }
}

### Azure VNets
variable "azure_vnets" {
  default = {
    azure_transit_vnet = {
      name       = "AZ-UW-Transit-VNet"
      cidr       = "10.100.0.0/16"
      is_transit = false # Not a typo, is_transit = true only applies to AWS.
      is_firenet = false
    }
    azure_spoke1_vnet = {
      name       = "AZ-UW-Spoke1-VNet"
      cidr       = "10.101.0.0/16"
      is_transit = false
      is_firenet = false
    }
    azure_spoke2_vnet = {
      name       = "AZ-UW-Spoke2-VNet"
      cidr       = "10.102.0.0/16"
      is_transit = false
      is_firenet = false
    }
  }
}

### Azure Transit gateway.
variable "azure_transit_gateway" {
  default = {
    name         = "AZ-UW-Transit-GW"
    size         = "Standard_B1ms"
    active_mesh  = true
    single_az_ha = true
    vpc          = "azure_transit_vnet"
    subnet       = "10.100.0.0/20"
  }
}

variable "azure_spoke_gateways" {
  default = {
    spoke1 = {
      name         = "AZ-UW-Spoke1-GW"
      size         = "Standard_B1ms"
      active_mesh  = true
      single_az_ha = true
      vpc          = "azure_spoke1_vnet"
    },
    spoke2 = {
      name         = "AZ-UW-Spoke2-GW"
      size         = "Standard_B1ms"
      active_mesh  = true
      single_az_ha = true
      vpc          = "azure_spoke2_vnet"
    }
  }
}


### AWS = 1, GCP = 4, Azure = 8, OCI = 16.
variable "cloud_type" { default = 1 }

### GCP VPC
variable "gcp_vpcs" {
  default = {
    gcp_saas_transit = {
      name        = "gcp-ew1-saas-transit-vpc"
      subnet_name = "gcp-ew1-saas-transit-subnet"
      subnet_cidr = "10.140.0.0/16"
    }
    gcp_saas_services = {
      name        = "gcp-ew1-saas-services-vpc"
      subnet_name = "gcp-ew1-saas-services-subnet"
      subnet_cidr = "10.141.0.0/16"
    }
  }
}

### GCP Transit gateway.
variable "gcp_transit_gateway" {
  default = {
    name         = "gcp-ew1-saas-transit-gw"
    size         = "n1-standard-1"
    active_mesh  = true
    single_az_ha = true
    vpc          = "gcp_saas_transit"
    zone         = "europe-west1-b"
  }
}

### GCP shared services Spoke gateway.
variable "gcp_services_spoke_gateway" {
  default = {
    name         = "gcp-ew1-saas-shared-services-gw"
    size         = "n1-standard-1"
    active_mesh  = true
    single_az_ha = true
    vpc          = "gcp_saas_services"
    zone         = "europe-west1-b"
  }
}