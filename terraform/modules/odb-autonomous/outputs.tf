# odb-autonomous module - Outputs

# Identifiers
output "autonomous_vm_cluster_id" {
  description = "ID of the Autonomous VM Cluster"
  value       = aws_odb_cloud_autonomous_vm_cluster.this.id
}

output "autonomous_vm_cluster_arn" {
  description = "ARN of the Autonomous VM Cluster"
  value       = aws_odb_cloud_autonomous_vm_cluster.this.arn
}

output "autonomous_vm_cluster_ocid" {
  description = "OCI OCID of the Autonomous VM Cluster"
  value       = aws_odb_cloud_autonomous_vm_cluster.this.ocid
}

# Network and connection information
output "hostname" {
  description = "Hostname of the Autonomous VM Cluster"
  value       = aws_odb_cloud_autonomous_vm_cluster.this.hostname
}

output "domain" {
  description = "Domain name of the Autonomous VM Cluster"
  value       = aws_odb_cloud_autonomous_vm_cluster.this.domain
}

# Cluster shape and capacity
output "shape" {
  description = "Infrastructure shape (e.g., Exadata.X11M)"
  value       = aws_odb_cloud_autonomous_vm_cluster.this.shape
}

output "compute_model" {
  description = "Compute model (ECPU or OCPU)"
  value       = aws_odb_cloud_autonomous_vm_cluster.this.compute_model
}

output "node_count" {
  description = "Number of database server nodes"
  value       = aws_odb_cloud_autonomous_vm_cluster.this.node_count
}

# Resource availability
output "available_cpus" {
  description = "Available CPUs for Autonomous Databases"
  value       = aws_odb_cloud_autonomous_vm_cluster.this.available_cpus
}

output "available_container_databases" {
  description = "Available container database slots"
  value       = aws_odb_cloud_autonomous_vm_cluster.this.available_container_databases
}

output "provisionable_autonomous_container_databases" {
  description = "Number of Autonomous CDBs that can be provisioned"
  value       = aws_odb_cloud_autonomous_vm_cluster.this.provisionable_autonomous_container_databases
}

output "provisioned_autonomous_container_databases" {
  description = "Number of Autonomous CDBs currently provisioned"
  value       = aws_odb_cloud_autonomous_vm_cluster.this.provisioned_autonomous_container_databases
}

# OCI Console link
output "oci_url" {
  description = "HTTPS link to the Autonomous VM Cluster in OCI Console"
  value       = aws_odb_cloud_autonomous_vm_cluster.this.oci_url
}

# Connection info map (convenience output)
output "connection_info" {
  description = "Connection details for Autonomous Databases"
  value = {
    hostname       = aws_odb_cloud_autonomous_vm_cluster.this.hostname
    domain         = aws_odb_cloud_autonomous_vm_cluster.this.domain
    port_tls       = var.scan_listener_port_tls
    port_non_tls   = var.scan_listener_port_non_tls
    mtls_enabled   = var.is_mtls_enabled
    available_cpus = aws_odb_cloud_autonomous_vm_cluster.this.available_cpus
    # Note: Actual ADB connection strings are generated per-database in OCI Console
    # After creating an ADB, download the wallet and use the provided connection strings
    note = "Create Autonomous Databases via OCI Console. Download wallet for connection credentials."
  }
}
