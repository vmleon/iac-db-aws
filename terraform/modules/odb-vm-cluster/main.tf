# odb-vm-cluster module - Exadata VM Cluster
#
# POC Notes:
# - Uses generous timeouts for provisioning
# - Production: Tune timeouts based on observed deployment times
# - Production: Configure backup retention policies if is_local_backup_enabled=true
# - gi_version lifecycle is ignored due to AWS provider behavior (see GitHub #44499)

locals {
  resource_name = "${var.name_prefix}${var.name_suffix}"

  default_tags = merge(var.tags, {
    managed_by = "terraform"
    module     = "odb-vm-cluster"
  })
}

resource "aws_odb_cloud_vm_cluster" "this" {
  # Required arguments
  cloud_exadata_infrastructure_id = var.exadata_infrastructure_id
  odb_network_id                  = var.odb_network_id
  db_servers                      = var.db_server_ids
  display_name                    = "${local.resource_name}-vmc"
  hostname_prefix                 = var.hostname_prefix
  ssh_public_keys                 = var.ssh_public_keys
  gi_version                      = var.gi_version

  # Compute and storage configuration
  cpu_core_count              = var.cpu_core_count
  memory_size_in_gbs          = var.memory_size_in_gbs
  data_storage_size_in_tbs    = var.data_storage_size_in_tbs
  db_node_storage_size_in_gbs = var.db_node_storage_size_in_gbs

  # Cluster configuration
  cluster_name                = var.cluster_name
  license_model               = var.license_model
  timezone                    = var.timezone
  is_local_backup_enabled     = var.is_local_backup_enabled
  is_sparse_diskgroup_enabled = var.is_sparse_diskgroup_enabled
  scan_listener_port_tcp      = var.scan_listener_port_tcp

  # Data collection options
  data_collection_options {
    is_diagnostics_events_enabled = var.is_diagnostics_events_enabled
    is_health_monitoring_enabled  = var.is_health_monitoring_enabled
    is_incident_logs_enabled      = var.is_incident_logs_enabled
  }

  tags = merge(local.default_tags, {
    Name = "${local.resource_name}-vmc"
  })

  timeouts {
    create = "24h"
    update = "2h"
    delete = "8h"
  }

  # Ignore gi_version changes after creation (AWS provider behavior)
  lifecycle {
    ignore_changes = [gi_version]
  }
}
