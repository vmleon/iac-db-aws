# Random suffix for unique resource naming
resource "random_id" "deploy_id" {
  byte_length = 1
}

locals {
  name_suffix = random_id.deploy_id.hex
  name_prefix = "${var.project_prefix}-"
}

# Sanity check: Verify AWS credentials work
data "aws_caller_identity" "current" {}
