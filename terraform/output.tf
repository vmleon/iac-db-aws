output "deploy_id" {
  description = "Unique deployment identifier"
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

output "aws_user_id" {
  description = "AWS User ID"
  value       = data.aws_caller_identity.current.user_id
}

output "naming_example" {
  description = "Example of resource naming convention"
  value       = "${local.name_prefix}resource-${local.name_suffix}"
}
