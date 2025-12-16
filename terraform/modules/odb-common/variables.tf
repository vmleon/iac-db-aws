# odb-common module - Input variables

variable "name_prefix" {
  description = "Resource naming prefix (e.g., 'dbaws-')"
  type        = string
}

variable "name_suffix" {
  description = "Random suffix for unique resource names (e.g., 'a3')"
  type        = string
}

variable "aws_region" {
  description = "AWS region for deployment. Examples: us-west-2, us-east-1, eu-west-1"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for deployment"
  type        = string
  default     = "us-west-2d"
}

# ODB Network Configuration
variable "client_subnet_cidr" {
  description = "CIDR for ODB client subnet. Must be /24 or larger. Example: 10.33.1.0/24"
  type        = string
  default     = "10.33.1.0/24"
}

variable "backup_subnet_cidr" {
  description = "CIDR for ODB backup subnet. Must be /24 or larger. Example: 10.33.0.0/24"
  type        = string
  default     = "10.33.0.0/24"
}

variable "s3_access" {
  description = "S3 access from ODB network. Valid values: ENABLED, DISABLED"
  type        = string
  default     = "DISABLED"
}

variable "zero_etl_access" {
  description = "Zero-ETL access from ODB network. Valid values: ENABLED, DISABLED"
  type        = string
  default     = "DISABLED"
}

# Sample VPC for Peering Demo
variable "vpc_cidr" {
  description = "CIDR for sample VPC (peering demo). Example: 10.34.0.0/16"
  type        = string
  default     = "10.34.0.0/16"
}

variable "app_subnet_cidr" {
  description = "CIDR for application subnet in sample VPC. Example: 10.34.1.0/24"
  type        = string
  default     = "10.34.1.0/24"
}

# Exadata Infrastructure Configuration
variable "exadata_shape" {
  description = "Exadata infrastructure shape. Valid values: Exadata.X11M, Exadata.X9M, Exadata.X8M"
  type        = string
  default     = "Exadata.X11M"
}

variable "compute_count" {
  description = "Number of database servers (2-32). Default 2 = quarter rack equivalent"
  type        = number
  default     = 2

  validation {
    condition     = var.compute_count >= 2 && var.compute_count <= 32
    error_message = "compute_count must be between 2 and 32"
  }
}

variable "storage_count" {
  description = "Number of storage servers (3-64). Default 3 = quarter rack equivalent"
  type        = number
  default     = 3

  validation {
    condition     = var.storage_count >= 3 && var.storage_count <= 64
    error_message = "storage_count must be between 3 and 64"
  }
}

variable "database_server_type" {
  description = "Database server model type. Must match shape: X11M for Exadata.X11M, X9M for Exadata.X9M"
  type        = string
  default     = "X11M"
}

variable "storage_server_type" {
  description = "Storage server model type. Valid values: X11M-HC (high capacity), X11M, X9M-HC, X9M"
  type        = string
  default     = "X11M-HC"
}

variable "contact_email" {
  description = "Email address for OCI notifications (required by Oracle)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.contact_email))
    error_message = "contact_email must be a valid email address"
  }
}

variable "tags" {
  description = "Additional tags for all resources. Production: Add cost-center, owner, environment tags"
  type        = map(string)
  default     = {}
}
