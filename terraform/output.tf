# Oracle Database @ AWS - Outputs
#
# Provides all necessary information for:
# - Database connections (SCAN DNS, ports, hostnames)
# - Administration (OCI Console URLs)
# - Application deployment (VPC info for peering)

# =============================================================================
# Deployment Identifiers
# =============================================================================

output "deploy_id" {
  description = "Unique deployment identifier (2-char hex suffix)"
  value       = local.name_suffix
}

output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_caller_arn" {
  description = "ARN of the AWS caller"
  value       = data.aws_caller_identity.current.arn
}

output "naming_example" {
  description = "Example of resource naming convention"
  value       = "${local.name_prefix}resource-${local.name_suffix}"
}

# =============================================================================
# Common Infrastructure Outputs
# =============================================================================

output "odb_network_id" {
  description = "ID of the ODB Network"
  value       = module.odb_common.odb_network_id
}

output "exadata_infrastructure_id" {
  description = "ID of the Exadata Infrastructure"
  value       = module.odb_common.exadata_infrastructure_id
}

output "exadata_infrastructure_ocid" {
  description = "OCI OCID of the Exadata Infrastructure"
  value       = module.odb_common.exadata_infrastructure_ocid
}

output "peering_connection_id" {
  description = "ID of the ODB Peering Connection"
  value       = module.odb_common.peering_connection_id
}

# OCI Console access
output "oci_console_url" {
  description = "HTTPS link to Exadata Infrastructure in OCI Console"
  value       = module.odb_common.oci_url
}

output "oci_region" {
  description = "OCI region for the deployment"
  value       = module.odb_common.oci_region
}

output "oci_compartment_ocid" {
  description = "OCI compartment OCID"
  value       = module.odb_common.oci_compartment_ocid
}

# Infrastructure capacity
output "exadata_capacity" {
  description = "Exadata Infrastructure capacity details"
  value = {
    cpu_count              = module.odb_common.cpu_count
    max_cpu_count          = module.odb_common.max_cpu_count
    memory_size_in_gbs     = module.odb_common.memory_size_in_gbs
    data_storage_size_tbs  = module.odb_common.data_storage_size_in_tbs
    db_server_version      = module.odb_common.db_server_version
    storage_server_version = module.odb_common.storage_server_version
  }
}

# =============================================================================
# Sample VPC (for application deployment)
# =============================================================================

output "sample_vpc" {
  description = "Sample VPC details for application deployment"
  value = {
    vpc_id        = module.odb_common.vpc_id
    vpc_cidr      = module.odb_common.vpc_cidr_block
    app_subnet_id = module.odb_common.app_subnet_id
  }
}

# =============================================================================
# VM Cluster Connection Information
# =============================================================================

output "vm_cluster_connection" {
  description = "VM Cluster connection details for database access"
  value = var.deploy_vm_cluster ? {
    # Identifiers
    vm_cluster_id   = module.odb_vm_cluster[0].vm_cluster_id
    vm_cluster_ocid = module.odb_vm_cluster[0].vm_cluster_ocid

    # Connection details (use these for SQLcl, JDBC, etc.)
    scan_dns_name = module.odb_vm_cluster[0].scan_dns_name
    listener_port = module.odb_vm_cluster[0].listener_port
    domain        = module.odb_vm_cluster[0].domain

    # Cluster info
    node_count   = module.odb_vm_cluster[0].node_count
    cluster_name = module.odb_vm_cluster[0].cluster_name
    gi_version   = module.odb_vm_cluster[0].gi_version

    # OCI Console
    oci_url = module.odb_vm_cluster[0].oci_url

    # Connection examples
    sqlplus_example = "sqlplus sys/<password>@${module.odb_vm_cluster[0].scan_dns_name}:${module.odb_vm_cluster[0].listener_port}/<service_name> as sysdba"
    jdbc_example    = "jdbc:oracle:thin:@//${module.odb_vm_cluster[0].scan_dns_name}:${module.odb_vm_cluster[0].listener_port}/<service_name>"
    sqlcl_example   = "sql sys/<password>@${module.odb_vm_cluster[0].scan_dns_name}:${module.odb_vm_cluster[0].listener_port}/<service_name> as sysdba"
  } : null
}

# =============================================================================
# Autonomous VM Cluster Connection Information
# =============================================================================

output "autonomous_cluster_connection" {
  description = "Autonomous VM Cluster connection details"
  value = var.deploy_autonomous ? {
    # Identifiers
    autonomous_vm_cluster_id   = module.odb_autonomous[0].autonomous_vm_cluster_id
    autonomous_vm_cluster_ocid = module.odb_autonomous[0].autonomous_vm_cluster_ocid

    # Connection details
    hostname     = module.odb_autonomous[0].hostname
    domain       = module.odb_autonomous[0].domain
    port_tls     = 2484
    port_non_tls = 1521

    # Cluster info
    shape         = module.odb_autonomous[0].shape
    compute_model = module.odb_autonomous[0].compute_model
    node_count    = module.odb_autonomous[0].node_count

    # Capacity
    available_cpus                = module.odb_autonomous[0].available_cpus
    available_container_databases = module.odb_autonomous[0].available_container_databases

    # OCI Console
    oci_url = module.odb_autonomous[0].oci_url

    # Note about ADB connections
    note = "Create Autonomous Databases via OCI Console. Download wallet for connection credentials and connection strings."
  } : null
}

# =============================================================================
# Quick Reference Summary
# =============================================================================

output "connection_summary" {
  description = "Quick reference for database connections"
  value = {
    vm_cluster = var.deploy_vm_cluster ? {
      host = module.odb_vm_cluster[0].scan_dns_name
      port = module.odb_vm_cluster[0].listener_port
      note = "Create databases via OCI Console, then connect using SCAN DNS"
    } : null

    autonomous = var.deploy_autonomous ? {
      host      = module.odb_autonomous[0].hostname
      domain    = module.odb_autonomous[0].domain
      port_tls  = 2484
      available = "${module.odb_autonomous[0].available_cpus} CPUs, ${module.odb_autonomous[0].available_container_databases} CDBs available"
      note      = "Create ADBs via OCI Console, download wallet for credentials"
    } : null

    oci_console = module.odb_common.oci_url
  }
}
