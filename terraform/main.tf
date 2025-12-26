# Oracle Database @ AWS - Infrastructure
#
# POC Notes:
# - Uses local state. Production: Use S3 backend with DynamoDB locking
# - Uses session tokens. Production: Use IAM roles or service principals
# - Creates sample VPC for peering. Production: Peer with existing VPCs

# Random suffix for unique resource naming
resource "random_id" "deploy_id" {
  byte_length = 1
}

locals {
  name_suffix = random_id.deploy_id.hex
  name_prefix = var.project_prefix
}

# Sanity check: Verify AWS credentials work
data "aws_caller_identity" "current" {}

# =============================================================================
# Common Infrastructure (ODB Network, Exadata, Peering, Sample VPC)
# =============================================================================

module "odb_common" {
  source = "github.com/vmleon/oracle-database-aws-exadata-infrastructure"

  name_prefix        = local.name_prefix
  name_suffix        = local.name_suffix
  aws_region         = var.aws_region
  availability_zone  = var.availability_zone
  client_subnet_cidr = var.client_subnet_cidr
  backup_subnet_cidr = var.backup_subnet_cidr
  exadata_shape      = var.exadata_shape
  compute_count      = var.compute_count
  storage_count      = var.storage_count
  contact_email      = var.contact_email

  # Enable VPC and peering (matches current local module behavior)
  create_vpc     = true
  vpc_cidr       = var.vpc_cidr
  create_peering = true

  tags = var.tags
}

# =============================================================================
# Exadata VM Cluster (optional - controlled by deploy_vm_cluster)
# =============================================================================

module "odb_vm_cluster" {
  source = "./modules/odb-vm-cluster"
  count  = var.deploy_vm_cluster ? 1 : 0

  name_prefix               = local.name_prefix
  name_suffix               = local.name_suffix
  aws_region                = var.aws_region
  exadata_infrastructure_id = module.odb_common.exadata_infrastructure_id
  odb_network_id            = module.odb_common.odb_network_id
  db_server_ids             = module.odb_common.db_server_ids

  # VM Cluster configuration (with defaults)
  ssh_public_keys             = [var.ssh_public_key]
  gi_version                  = var.gi_version
  license_model               = var.license_model
  timezone                    = var.timezone
  is_local_backup_enabled     = var.is_local_backup_enabled
  is_sparse_diskgroup_enabled = var.is_sparse_diskgroup_enabled

  tags = var.tags
}

# =============================================================================
# Autonomous VM Cluster (optional - controlled by deploy_autonomous)
# =============================================================================

module "odb_autonomous" {
  source = "./modules/odb-autonomous"
  count  = var.deploy_autonomous ? 1 : 0

  name_prefix               = local.name_prefix
  name_suffix               = local.name_suffix
  aws_region                = var.aws_region
  exadata_infrastructure_id = module.odb_common.exadata_infrastructure_id
  odb_network_id            = module.odb_common.odb_network_id
  db_server_ids             = module.odb_common.db_server_ids

  # Autonomous VM Cluster configuration (with defaults from plan)
  autonomous_data_storage_size_in_tbs   = var.autonomous_data_storage_size_in_tbs
  cpu_core_count_per_node               = var.cpu_core_count_per_node
  memory_per_oracle_compute_unit_in_gbs = var.memory_per_oracle_compute_unit_in_gbs
  total_container_databases             = var.total_container_databases
  license_model                         = var.license_model
  time_zone                             = var.timezone

  tags = var.tags
}
