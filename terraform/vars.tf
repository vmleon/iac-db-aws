# Oracle Database @ AWS - Input Variables
#
# POC Notes:
# - Minimal variables with sensible defaults per user requirements
# - Variable descriptions include alternative values
# - Production: Add validation, expand configuration options

# =============================================================================
# AWS Credentials
# =============================================================================

variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "aws_session_token" {
  description = "AWS Session Token (required for temporary credentials)"
  type        = string
  sensitive   = true
}

# =============================================================================
# AWS Configuration
# =============================================================================

variable "aws_region" {
  description = "AWS Region. Examples: us-west-2, us-east-1, eu-west-1"
  type        = string
  default     = "us-west-2"
}

variable "availability_zone" {
  description = "Availability zone for deployment"
  type        = string
  default     = "us-west-2d"
}

# =============================================================================
# Project Configuration
# =============================================================================

variable "project_prefix" {
  description = "Prefix for resource naming (e.g., 'dbaws' creates 'dbaws-vpc-a3')"
  type        = string
  default     = "dbaws"
}

variable "tags" {
  description = "Additional tags for all resources. Production: Add cost-center, owner, environment"
  type        = map(string)
  default     = {}
}

# =============================================================================
# Deployment Toggles
# =============================================================================

variable "deploy_vm_cluster" {
  description = "Deploy Exadata VM Cluster. Set false to skip"
  type        = bool
  default     = true
}

variable "deploy_autonomous" {
  description = "Deploy Autonomous VM Cluster. Set false to skip"
  type        = bool
  default     = true
}

# =============================================================================
# Network Configuration
# =============================================================================

variable "client_subnet_cidr" {
  description = "ODB client subnet CIDR. Must be /24 or larger. Example: 10.33.1.0/24"
  type        = string
  default     = "10.33.1.0/24"
}

variable "backup_subnet_cidr" {
  description = "ODB backup subnet CIDR. Must be /24 or larger. Example: 10.33.0.0/24"
  type        = string
  default     = "10.33.0.0/24"
}

variable "vpc_cidr" {
  description = "Sample VPC CIDR for peering demo. Example: 10.34.0.0/16"
  type        = string
  default     = "10.34.0.0/16"
}

# =============================================================================
# Exadata Infrastructure Configuration
# =============================================================================

variable "exadata_shape" {
  description = "Exadata shape. Valid values: Exadata.X11M, Exadata.X9M, Exadata.X8M"
  type        = string
  default     = "Exadata.X11M"
}

variable "compute_count" {
  description = "Number of DB servers (2-32). Default 2 = quarter rack"
  type        = number
  default     = 2
}

variable "storage_count" {
  description = "Number of storage servers (3-64). Default 3 = quarter rack"
  type        = number
  default     = 3
}

variable "contact_email" {
  description = "Email for OCI notifications (required by Oracle)"
  type        = string
}

# =============================================================================
# VM Cluster Configuration
# =============================================================================

variable "ssh_public_key" {
  description = "SSH public key content for VM Cluster access"
  type        = string
  sensitive   = true
}

variable "gi_version" {
  description = "Grid Infrastructure version. Valid values: 23.0.0.0, 21.0.0.0, 19.0.0.0"
  type        = string
  default     = "23.0.0.0"
}

variable "license_model" {
  description = "Oracle license model. Valid values: BRING_YOUR_OWN_LICENSE, LICENSE_INCLUDED"
  type        = string
  default     = "BRING_YOUR_OWN_LICENSE"
}

variable "timezone" {
  description = "Timezone. Examples: UTC, America/New_York, America/Los_Angeles, Europe/London"
  type        = string
  default     = "UTC"
}

variable "is_local_backup_enabled" {
  description = "Enable local Exadata backups. Production: Enable with retention policies"
  type        = bool
  default     = false
}

variable "is_sparse_diskgroup_enabled" {
  description = "Enable sparse snapshots for storage efficiency"
  type        = bool
  default     = true
}

# =============================================================================
# Autonomous VM Cluster Configuration
# =============================================================================

variable "autonomous_data_storage_size_in_tbs" {
  description = "Data storage in TB (minimum 2). User requested: 25TB"
  type        = number
  default     = 25
}

variable "cpu_core_count_per_node" {
  description = "ECPUs per node. User requested: 40 ECPU per node (80 total with 2 nodes)"
  type        = number
  default     = 40
}

variable "memory_per_oracle_compute_unit_in_gbs" {
  description = "Memory per ECPU in GB. Valid values: 2, 4, 8. User requested: 4GB"
  type        = number
  default     = 4
}

variable "total_container_databases" {
  description = "Maximum container databases. User requested: 4"
  type        = number
  default     = 4
}
