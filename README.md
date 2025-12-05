# Oracle Database @ AWS - Infrastructure as Code

Terraform and Ansible POC for deploying Oracle Database @ AWS.

## Requirements

- Python 3.9+
- Terraform 1.14+
- AWS credentials (access key, secret key, session token)

## Setup

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Configure environment (interactive)
python manage.py setup

# Generate terraform.tfvars
python manage.py tf
```

## Deploy

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Outputs

On successful apply, Terraform displays:
- `deploy_id` - Unique 2-char suffix for resource naming
- `aws_account_id` - Confirms AWS connectivity
- `naming_example` - Resource naming convention (e.g., `dbaws-resource-a3`)
