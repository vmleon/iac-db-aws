# odb-vm-cluster module - Outputs

# Identifiers
output "vm_cluster_id" {
  description = "ID of the VM Cluster"
  value       = aws_odb_cloud_vm_cluster.this.id
}

output "vm_cluster_arn" {
  description = "ARN of the VM Cluster"
  value       = aws_odb_cloud_vm_cluster.this.arn
}

output "vm_cluster_ocid" {
  description = "OCI OCID of the VM Cluster"
  value       = aws_odb_cloud_vm_cluster.this.ocid
}

# Connection information (critical for database access)
output "scan_dns_name" {
  description = "SCAN FQDN for database connections. Use this in connection strings"
  value       = aws_odb_cloud_vm_cluster.this.scan_dns_name
}

output "listener_port" {
  description = "Listener port for database connections"
  value       = aws_odb_cloud_vm_cluster.this.listener_port
}

output "scan_ip_ids" {
  description = "SCAN IP OCIDs (for RAC load balancing)"
  value       = aws_odb_cloud_vm_cluster.this.scan_ip_ids
}

output "vip_ids" {
  description = "VIP OCIDs for node failover"
  value       = aws_odb_cloud_vm_cluster.this.vip_ids
}

output "domain" {
  description = "VM Cluster domain name"
  value       = aws_odb_cloud_vm_cluster.this.domain
}

# Cluster information
output "node_count" {
  description = "Number of nodes in the cluster"
  value       = aws_odb_cloud_vm_cluster.this.node_count
}

output "hostname" {
  description = "Hostname prefix used"
  value       = var.hostname_prefix
}

output "cluster_name" {
  description = "Cluster name"
  value       = var.cluster_name
}

output "gi_version" {
  description = "Grid Infrastructure version"
  value       = aws_odb_cloud_vm_cluster.this.gi_version
}

# OCI Console link
output "oci_url" {
  description = "HTTPS link to the VM Cluster in OCI Console"
  value       = aws_odb_cloud_vm_cluster.this.oci_url
}

# Connection info map (convenience output for applications)
output "connection_info" {
  description = "Connection details map for database access"
  value = {
    scan_dns_name = aws_odb_cloud_vm_cluster.this.scan_dns_name
    listener_port = aws_odb_cloud_vm_cluster.this.listener_port
    domain        = aws_odb_cloud_vm_cluster.this.domain
    hostname      = var.hostname_prefix
    cluster_name  = var.cluster_name
    # Example connection string (replace <password> and <service_name>)
    sqlplus_example = "sqlplus sys/<password>@${aws_odb_cloud_vm_cluster.this.scan_dns_name}:${aws_odb_cloud_vm_cluster.this.listener_port}/<service_name> as sysdba"
    jdbc_example    = "jdbc:oracle:thin:@//${aws_odb_cloud_vm_cluster.this.scan_dns_name}:${aws_odb_cloud_vm_cluster.this.listener_port}/<service_name>"
  }
}
