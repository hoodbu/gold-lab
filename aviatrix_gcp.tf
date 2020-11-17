resource "aviatrix_vpc" "vpcs" {
  for_each = var.vpcs

  cloud_type           = 1 # AWS
  account_name         = var.account_name
  region               = var.region
  name                 = each.value.name
  cidr                 = each.value.cidr
  aviatrix_transit_vpc = each.value.is_transit
  aviatrix_firenet_vpc = each.value.is_firenet
}

resource "aviatrix_vpc" "gcp_vpcs" {
  for_each = var.gcp_vpcs

  cloud_type   = 4 # GCP
  account_name = var.gcp_account_name
  name         = each.value.name

  subnets {
    name   = each.value.subnet_name
    region = var.gcp_region
    cidr   = each.value.subnet_cidr
  }
}

### Launch the Transit gateway in the Transit VPC.
resource "aviatrix_transit_gateway" "transit_gw" {
  cloud_type         = var.cloud_type
  account_name       = var.account_name
  gw_name            = var.transit_gateway.name
  vpc_id             = aviatrix_vpc.vpcs[var.transit_gateway.vpc].vpc_id
  vpc_reg            = var.region
  gw_size            = var.transit_gateway.size
  connected_transit  = true
  enable_active_mesh = var.transit_gateway.active_mesh
  single_az_ha       = var.transit_gateway.single_az_ha
  # subnets[4] is the first public subnet of a Transit VPC, i.e., AZ-a.
  subnet = aviatrix_vpc.vpcs[var.transit_gateway.vpc].subnets[4].cidr
}

### Launch the shared services Spoke gateway.
### Attach it to the Transit gateway.
resource "aviatrix_spoke_gateway" "services_spoke_gw" {
  cloud_type         = var.cloud_type
  account_name       = var.account_name
  gw_name            = var.services_spoke_gateway.name
  vpc_id             = aviatrix_vpc.vpcs[var.services_spoke_gateway.vpc].vpc_id
  vpc_reg            = var.region
  gw_size            = var.services_spoke_gateway.size
  enable_active_mesh = var.services_spoke_gateway.active_mesh
  single_az_ha       = var.services_spoke_gateway.single_az_ha
  # subnets[3] is the first public subnet of a Spoke VPC, i.e., AZ-a.
  subnet     = aviatrix_vpc.vpcs[var.services_spoke_gateway.vpc].subnets[3].cidr
  transit_gw = var.transit_gateway.name
}

### Launch GCP Transit gateway.
resource "aviatrix_transit_gateway" "gcp_transit_gw" {
  cloud_type         = 4
  account_name       = var.gcp_account_name
  gw_name            = var.gcp_transit_gateway.name
  vpc_id             = aviatrix_vpc.gcp_vpcs[var.gcp_transit_gateway.vpc].vpc_id
  vpc_reg            = var.gcp_transit_gateway.zone
  gw_size            = var.gcp_transit_gateway.size
  connected_transit  = true
  enable_active_mesh = var.transit_gateway.active_mesh
  single_az_ha       = var.transit_gateway.single_az_ha
  subnet             = var.gcp_vpcs[var.gcp_transit_gateway.vpc].subnet_cidr
}

### Launch GCP shared services Spoke gateway.
resource "aviatrix_spoke_gateway" "gcp_services_spoke_gw" {
  cloud_type         = 4
  account_name       = var.gcp_account_name
  gw_name            = var.gcp_services_spoke_gateway.name
  vpc_id             = aviatrix_vpc.gcp_vpcs[var.gcp_services_spoke_gateway.vpc].vpc_id
  vpc_reg            = var.gcp_services_spoke_gateway.zone
  gw_size            = var.gcp_services_spoke_gateway.size
  enable_active_mesh = var.gcp_services_spoke_gateway.active_mesh
  single_az_ha       = var.gcp_services_spoke_gateway.single_az_ha
  subnet             = var.gcp_vpcs[var.gcp_services_spoke_gateway.vpc].subnet_cidr
  transit_gw         = var.gcp_transit_gateway.name
}

### AWS <--> GCP transit peering.
resource "aviatrix_transit_gateway_peering" "aws_gcp" {
  transit_gateway_name1 = var.transit_gateway.name
  transit_gateway_name2 = var.gcp_transit_gateway.name
}
