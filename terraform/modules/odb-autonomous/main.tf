# odb-autonomous module - Autonomous VM Cluster
#
# POC Notes:
# - Creates Autonomous VM Cluster infrastructure
# - Actual Autonomous Databases (ADBs) are provisioned via OCI Console or additional Terraform
# - Production: Configure backup policies and security settings per compliance requirements
# - mTLS is enabled by default for secure connections

locals {
  resource_name = "${var.name_prefix}${var.name_suffix}"

  default_tags = merge(var.tags, {
    managed_by = "terraform"
    module     = "odb-autonomous"
  })
}

resource "aws_odb_cloud_autonomous_vm_cluster" "this" {
  # Required arguments
  cloud_exadata_infrastructure_id       = var.exadata_infrastructure_id
  odb_network_id                        = var.odb_network_id
  db_servers                            = var.db_server_ids
  display_name                          = "${local.resource_name}-avmc"
  autonomous_data_storage_size_in_tbs   = var.autonomous_data_storage_size_in_tbs
  cpu_core_count_per_node               = var.cpu_core_count_per_node
  memory_per_oracle_compute_unit_in_gbs = var.memory_per_oracle_compute_unit_in_gbs
  total_container_databases             = var.total_container_databases

  # Network configuration
  scan_listener_port_non_tls = var.scan_listener_port_non_tls
  scan_listener_port_tls     = var.scan_listener_port_tls

  # Cluster configuration
  license_model              = var.license_model
  time_zone                  = var.time_zone
  is_mtls_enabled_vm_cluster = var.is_mtls_enabled
  description                = var.description

  # Maintenance window
  maintenance_window {
    preference = "NO_PREFERENCE"
  }

  tags = merge(local.default_tags, {
    Name = "${local.resource_name}-avmc"
  })

  timeouts {
    create = "24h"
    update = "2h"
    delete = "8h"
  }
}
