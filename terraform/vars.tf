# AWS Credentials
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
  description = "AWS Session Token"
  type        = string
  sensitive   = true
}

# AWS Configuration
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

# Project Configuration
variable "project_prefix" {
  description = "Prefix for resource naming"
  type        = string
  default     = "dbaws"
}
