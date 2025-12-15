# odb-vm-cluster module - Input variables

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

# VM Cluster Configuration
variable "gi_version" {
  description = "Grid Infrastructure version. Valid values: 23.0.0.0, 21.0.0.0, 19.0.0.0"
  type        = string
  default     = "23.0.0.0"
}

variable "cpu_core_count" {
  description = "Number of CPU cores (4-400 per node). Depends on infrastructure capacity"
  type        = number
  default     = 16
}

variable "memory_size_in_gbs" {
  description = "Memory per node in GB. Must be compatible with CPU allocation"
  type        = number
  default     = 60
}

variable "data_storage_size_in_tbs" {
  description = "DATA disk group size in TB (minimum 2)"
  type        = number
  default     = 2
}

variable "db_node_storage_size_in_gbs" {
  description = "Local storage per node in GB"
  type        = number
  default     = 120
}

variable "hostname_prefix" {
  description = "Hostname prefix (max 12 chars, alphanumeric). Example: vm, prod, dev"
  type        = string
  default     = "vm"

  validation {
    condition     = length(var.hostname_prefix) <= 12 && can(regex("^[a-zA-Z][a-zA-Z0-9]*$", var.hostname_prefix))
    error_message = "hostname_prefix must be max 12 alphanumeric chars starting with a letter"
  }
}

variable "cluster_name" {
  description = "Cluster name (max 11 chars). Examples: orcl, prod, dev, test"
  type        = string
  default     = "orcl"

  validation {
    condition     = length(var.cluster_name) <= 11 && can(regex("^[a-zA-Z][a-zA-Z0-9]*$", var.cluster_name))
    error_message = "cluster_name must be max 11 alphanumeric chars starting with a letter"
  }
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

variable "timezone" {
  description = "Timezone. Examples: UTC, America/New_York, America/Los_Angeles, Europe/London"
  type        = string
  default     = "UTC"
}

variable "is_local_backup_enabled" {
  description = "Enable local Exadata backups. Production: Consider enabling with retention policies"
  type        = bool
  default     = false
}

variable "is_sparse_diskgroup_enabled" {
  description = "Enable sparse snapshots for storage efficiency"
  type        = bool
  default     = true
}

variable "scan_listener_port_tcp" {
  description = "SCAN listener TCP port (1024-8999, excluding 2484,6100,6200,7060,7070,7085,7879)"
  type        = number
  default     = 1521
}

variable "ssh_public_keys" {
  description = "List of SSH public key contents for VM access"
  type        = list(string)
  sensitive   = true
}

variable "is_diagnostics_events_enabled" {
  description = "Enable diagnostics events collection"
  type        = bool
  default     = true
}

variable "is_health_monitoring_enabled" {
  description = "Enable health monitoring"
  type        = bool
  default     = true
}

variable "is_incident_logs_enabled" {
  description = "Enable incident logs collection"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
