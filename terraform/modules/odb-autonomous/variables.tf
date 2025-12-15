# odb-autonomous module - Input variables

variable "name_prefix" {
  description = "Resource naming prefix (e.g., 'dbaws-')"
  type        = string
}

variable "name_suffix" {
  description = "Random suffix for unique resource names (e.g., 'a3')"
  type        = string
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
}

# Dependencies from odb-common module
variable "exadata_infrastructure_id" {
  description = "ID of the Exadata Infrastructure (from odb-common module)"
  type        = string
}

variable "odb_network_id" {
  description = "ID of the ODB Network (from odb-common module)"
  type        = string
}

variable "db_server_ids" {
  description = "List of database server IDs (from odb-common module)"
  type        = list(string)
}

# Autonomous VM Cluster Configuration
variable "autonomous_data_storage_size_in_tbs" {
  description = "Data storage size in TB (minimum 2). Determines available storage for ADBs"
  type        = number
  default     = 25
}

variable "cpu_core_count_per_node" {
  description = "ECPUs per node. Depends on infrastructure capacity. Max ~760 ECPUs per X11M node"
  type        = number
  default     = 40
}

variable "memory_per_oracle_compute_unit_in_gbs" {
  description = "Memory per ECPU in GB. Valid values: 2, 4, 8"
  type        = number
  default     = 4

  validation {
    condition     = contains([2, 4, 8], var.memory_per_oracle_compute_unit_in_gbs)
    error_message = "memory_per_oracle_compute_unit_in_gbs must be 2, 4, or 8"
  }
}

variable "total_container_databases" {
  description = "Maximum container databases. Affects storage allocation per ADB"
  type        = number
  default     = 4
}

variable "license_model" {
  description = "Oracle license model. Valid values: BRING_YOUR_OWN_LICENSE, LICENSE_INCLUDED"
  type        = string
  default     = "BRING_YOUR_OWN_LICENSE"

  validation {
    condition     = contains(["BRING_YOUR_OWN_LICENSE", "LICENSE_INCLUDED"], var.license_model)
    error_message = "license_model must be BRING_YOUR_OWN_LICENSE or LICENSE_INCLUDED"
  }
}

variable "time_zone" {
  description = "Timezone. Examples: UTC, America/New_York, America/Los_Angeles, Europe/London"
  type        = string
  default     = "UTC"
}

variable "scan_listener_port_non_tls" {
  description = "SCAN listener non-TLS port (default 1521)"
  type        = number
  default     = 1521
}

variable "scan_listener_port_tls" {
  description = "SCAN listener TLS port (default 2484). Recommended for production"
  type        = number
  default     = 2484
}

variable "is_mtls_enabled" {
  description = "Enable mutual TLS for ADB connections. Production: Ensure certificates are managed"
  type        = bool
  default     = true
}

variable "description" {
  description = "Description of the Autonomous VM Cluster"
  type        = string
  default     = "Autonomous VM Cluster for Oracle Database @ AWS"
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
