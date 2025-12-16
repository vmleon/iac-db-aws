# odb-common module - ODB Network, Exadata Infrastructure, Peering, and Sample VPC
#
# POC Notes:
# - This module creates a sample VPC for peering demonstration
# - Production: Peer with existing application VPCs instead
# - Production: Coordinate CIDR ranges with network team
# - Production: Use S3 backend with DynamoDB locking for state

locals {
  resource_name = "${var.name_prefix}${var.name_suffix}"

  default_tags = merge(var.tags, {
    managed_by = "terraform"
    module     = "odb-common"
  })
}

# Get availability zone details
data "aws_availability_zone" "selected" {
  name = var.availability_zone
}

# =============================================================================
# Application VPC for Peering Demo
# POC: Creates a simple VPC. Production: Use existing VPCs
# =============================================================================

resource "aws_vpc" "application" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.default_tags, {
    Name = "${local.resource_name}-vpc"
  })
}

resource "aws_subnet" "app" {
  vpc_id                  = aws_vpc.application.id
  cidr_block              = var.app_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = merge(local.default_tags, {
    Name = "${local.resource_name}-app-subnet"
  })
}

resource "aws_internet_gateway" "application" {
  vpc_id = aws_vpc.application.id

  tags = merge(local.default_tags, {
    Name = "${local.resource_name}-igw"
  })
}

resource "aws_route_table" "application" {
  vpc_id = aws_vpc.application.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.application.id
  }

  tags = merge(local.default_tags, {
    Name = "${local.resource_name}-rt"
  })
}

resource "aws_route_table_association" "app" {
  subnet_id      = aws_subnet.app.id
  route_table_id = aws_route_table.application.id
}

# =============================================================================
# ODB Network
# =============================================================================

resource "aws_odb_network" "this" {
  display_name         = "${local.resource_name}-odb-network"
  availability_zone    = var.availability_zone
  availability_zone_id = data.aws_availability_zone.selected.zone_id
  client_subnet_cidr   = var.client_subnet_cidr
  backup_subnet_cidr   = var.backup_subnet_cidr
  s3_access            = var.s3_access
  zero_etl_access      = var.zero_etl_access
  region               = var.aws_region

  tags = merge(local.default_tags, {
    Name = "${local.resource_name}-odb-network"
  })
}

# =============================================================================
# Exadata Infrastructure
# POC: Uses generous timeouts. Production: Tune based on observed times
# =============================================================================

resource "aws_odb_cloud_exadata_infrastructure" "this" {
  display_name         = "${local.resource_name}-exadata"
  shape                = var.exadata_shape
  compute_count        = var.compute_count
  storage_count        = var.storage_count
  availability_zone    = var.availability_zone
  availability_zone_id = data.aws_availability_zone.selected.zone_id
  database_server_type = var.database_server_type
  storage_server_type  = var.storage_server_type
  region               = var.aws_region

  customer_contacts_to_send_to_oci = [
    { email = var.contact_email }
  ]

  maintenance_window {
    preference                       = "NO_PREFERENCE"
    patching_mode                    = "ROLLING"
    is_custom_action_timeout_enabled = false
    custom_action_timeout_in_mins    = 15
  }

  tags = merge(local.default_tags, {
    Name = "${local.resource_name}-exadata"
  })

  timeouts {
    create = "24h"
    update = "2h"
    delete = "8h"
  }
}

# Get DB server IDs from Exadata Infrastructure
data "aws_odb_db_servers" "this" {
  cloud_exadata_infrastructure_id = aws_odb_cloud_exadata_infrastructure.this.id
}

# =============================================================================
# ODB Network Peering Connection
# POC: Peers with application VPC. Production: Peer with existing VPCs
# =============================================================================

resource "aws_odb_network_peering_connection" "this" {
  depends_on = [
    aws_odb_network.this,
    aws_vpc.application
  ]

  display_name    = "${local.resource_name}-peering"
  odb_network_id  = aws_odb_network.this.id
  peer_network_id = aws_vpc.application.id
  region          = var.aws_region

  tags = merge(local.default_tags, {
    Name = "${local.resource_name}-peering"
  })
}
