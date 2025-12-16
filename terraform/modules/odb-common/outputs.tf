# odb-common module - Outputs

# ODB Network outputs
output "odb_network_id" {
  description = "ID of the ODB Network"
  value       = aws_odb_network.this.id
}

output "odb_network_arn" {
  description = "ARN of the ODB Network"
  value       = aws_odb_network.this.arn
}

# Exadata Infrastructure outputs
output "exadata_infrastructure_id" {
  description = "ID of the Exadata Infrastructure"
  value       = aws_odb_cloud_exadata_infrastructure.this.id
}

output "exadata_infrastructure_arn" {
  description = "ARN of the Exadata Infrastructure"
  value       = aws_odb_cloud_exadata_infrastructure.this.arn
}

output "exadata_infrastructure_ocid" {
  description = "OCI OCID of the Exadata Infrastructure"
  value       = aws_odb_cloud_exadata_infrastructure.this.ocid
}

output "db_server_ids" {
  description = "List of database server IDs (use for VM Cluster creation)"
  value       = data.aws_odb_db_servers.this.db_servers[*].id
}

output "db_server_version" {
  description = "Software version of database servers"
  value       = aws_odb_cloud_exadata_infrastructure.this.db_server_version
}

output "storage_server_version" {
  description = "Software version of storage servers"
  value       = aws_odb_cloud_exadata_infrastructure.this.storage_server_version
}

output "cpu_count" {
  description = "Total CPU cores allocated"
  value       = aws_odb_cloud_exadata_infrastructure.this.cpu_count
}

output "max_cpu_count" {
  description = "Maximum CPU cores available"
  value       = aws_odb_cloud_exadata_infrastructure.this.max_cpu_count
}

output "memory_size_in_gbs" {
  description = "Memory allocated in GB"
  value       = aws_odb_cloud_exadata_infrastructure.this.memory_size_in_gbs
}

output "data_storage_size_in_tbs" {
  description = "Data storage size in TB"
  value       = aws_odb_cloud_exadata_infrastructure.this.data_storage_size_in_tbs
}

# OCI Console link and metadata (extracted from oci_url)
output "oci_url" {
  description = "HTTPS link to the Exadata Infrastructure in OCI Console"
  value       = aws_odb_cloud_exadata_infrastructure.this.oci_url
}

output "oci_region" {
  description = "OCI region (extracted from OCI URL)"
  value       = try(regex("(?i:region=)([^?&/]+)", aws_odb_cloud_exadata_infrastructure.this.oci_url)[0], null)
}

output "oci_compartment_ocid" {
  description = "OCI compartment OCID (extracted from OCI URL)"
  value       = try(regex("(?i:compartmentId=)([^?&/]+)", aws_odb_cloud_exadata_infrastructure.this.oci_url)[0], null)
}

output "oci_tenant" {
  description = "OCI tenant (extracted from OCI URL)"
  value       = try(regex("(?i:tenant=)([^?&/]+)", aws_odb_cloud_exadata_infrastructure.this.oci_url)[0], null)
}

# Peering Connection outputs
output "peering_connection_id" {
  description = "ID of the ODB Peering Connection"
  value       = aws_odb_network_peering_connection.this.id
}

output "peering_connection_arn" {
  description = "ARN of the ODB Peering Connection"
  value       = aws_odb_network_peering_connection.this.arn
}

# Application VPC outputs
output "vpc_id" {
  description = "ID of the application VPC"
  value       = aws_vpc.application.id
}

output "vpc_cidr" {
  description = "CIDR of the application VPC"
  value       = aws_vpc.application.cidr_block
}

output "app_subnet_id" {
  description = "ID of the application subnet"
  value       = aws_subnet.app.id
}

# Availability zone info
output "availability_zone" {
  description = "Availability zone used for deployment"
  value       = var.availability_zone
}

output "availability_zone_id" {
  description = "Availability zone ID used for deployment"
  value       = data.aws_availability_zone.selected.zone_id
}
