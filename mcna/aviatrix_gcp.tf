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

### Launch GCP Transit gateway.
resource "aviatrix_transit_gateway" "gcp_transit_gw" {
  cloud_type         = 4
  account_name       = var.gcp_account_name
  gw_name            = var.gcp_transit_gateway.name
  vpc_id             = aviatrix_vpc.gcp_vpcs[var.gcp_transit_gateway.vpc].vpc_id
  vpc_reg            = var.gcp_transit_gateway.zone
  gw_size            = var.gcp_transit_gateway.size
  connected_transit  = true
  enable_active_mesh = var.aws_transit_gateway.active_mesh
  single_az_ha       = var.aws_transit_gateway.single_az_ha
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