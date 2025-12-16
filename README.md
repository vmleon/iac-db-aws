# Oracle Database @ AWS - Infrastructure as Code

Terraform POC for deploying Oracle Database @ AWS with Exadata Infrastructure, VM Clusters, and Autonomous VM Clusters.

## Overview

This project provisions Oracle Database @ AWS infrastructure following patterns from the [OCI Multicloud Landing Zone for AWS](https://github.com/oci-landing-zones/terraform-oci-multicloud-aws). It creates:

- **ODB Network** with client and backup subnets
- **Exadata Infrastructure** (X11M shape, 2 DB servers, 3 storage servers)
- **VM Cluster** for traditional Oracle RAC workloads
- **Autonomous VM Cluster** for Autonomous Database workloads
- **VPC Peering** between ODB Network and a sample VPC

### Technical Decisions

| Decision         | Choice   | Rationale                               |
| ---------------- | -------- | --------------------------------------- |
| Exadata Shape    | X11M     | Latest generation, ECPU-based compute   |
| DB Servers       | 2        | Quarter-rack equivalent, minimum for HA |
| Storage Servers  | 3        | Quarter-rack equivalent, minimum config |
| License Model    | BYOL     | Most common enterprise scenario         |
| GI Version       | 23.0.0.0 | Latest Grid Infrastructure              |
| Local Backup     | Disabled | POC simplicity; enable for production   |
| Sparse Snapshots | Enabled  | Storage efficiency for clones           |
| mTLS             | Enabled  | Security best practice for ADB          |

### Module Architecture

```
terraform/modules/
├── odb-common/       # ODB Network, Exadata Infra, Peering, Sample VPC
├── odb-vm-cluster/   # Exadata VM Cluster (optional)
└── odb-autonomous/   # Autonomous VM Cluster (optional)
```

## Requirements

- Python 3.9+
- Terraform 1.14+
- AWS Provider 6.25+
- AWS credentials (access key, secret key, session token)
- AWS account linked with OCI for Oracle Database @ AWS

## Quick Start

### First Time Setup

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate
```

```bash
# Install dependencies
pip install -r requirements.txt
```

### Configure and Deploy

```bash
# Activate virtual environment
source venv/bin/activate
```

```bash
# Configure environment (interactive)
# Prompts for: AWS credentials, region, AZ, contact email
# Auto-generates SSH keypair at ~/.ssh/dbaws_key
python manage.py setup
```

```bash
# Generate terraform.tfvars
python manage.py tf
```

```bash
# Deploy infrastructure
cd terraform
terraform init
```

```bash
terraform plan -out tfplan
```

```bash
terraform apply "tfplan"
```

**Note:** Exadata Infrastructure provisioning takes approximately **4-8 hours**.

## Configuration

The setup wizard prompts for required values. Defaults can be overridden in `terraform.tfvars`:

| Variable            | Default                | Description                  |
| ------------------- | ---------------------- | ---------------------------- |
| `availability_zone` | us-west-2a             | Deployment AZ                |
| `exadata_shape`     | Exadata.X11M           | Also: X9M, X8M               |
| `compute_count`     | 2                      | DB servers (2-32)            |
| `storage_count`     | 3                      | Storage servers (3-64)       |
| `license_model`     | BRING_YOUR_OWN_LICENSE | Also: LICENSE_INCLUDED       |
| `deploy_vm_cluster` | true                   | Deploy VM Cluster            |
| `deploy_autonomous` | true                   | Deploy Autonomous VM Cluster |

### Autonomous VM Cluster Defaults

| Setting         | Default                    |
| --------------- | -------------------------- |
| Storage         | 25 TB                      |
| ECPUs per Node  | 40 (80 total with 2 nodes) |
| Memory per ECPU | 4 GB                       |
| Container DBs   | 4                          |

## Outputs

After deployment, Terraform outputs connection information:

```bash
# View all outputs
terraform output

# Get VM Cluster connection details
terraform output vm_cluster_connection

# Get Autonomous VM Cluster details
terraform output autonomous_cluster_connection
```

Key outputs include:

- **SCAN DNS Name** - Database connection endpoint
- **Listener Port** - Default 1521 (non-TLS), 2484 (TLS)
- **OCI Console URL** - Direct link to manage resources in OCI
- **Connection Examples** - SQLPlus, JDBC, SQLcl formats

## Cleanup

```bash
# Destroy infrastructure (takes ~1-2 hours)
cd terraform
terraform destroy
cd ..

# Remove generated files
python manage.py clean
```

## POC to Production

This is a Proof of Concept. When moving to production, address these items:

| Area                  | POC Approach                         | Production Recommendation                       |
| --------------------- | ------------------------------------ | ----------------------------------------------- |
| **State Management**  | Local `terraform.tfstate`            | S3 backend with DynamoDB locking                |
| **SSH Keys**          | Auto-generated in `~/.ssh/dbaws_key` | Secrets Manager or HSM                          |
| **VPC Peering**       | Creates sample VPC for demo          | Peer with existing application VPCs             |
| **CIDR Allocation**   | Hardcoded `10.33.x.x`, `10.34.x.x`   | Coordinate with network team                    |
| **Credentials**       | Session tokens in `.env`             | IAM roles or service principals                 |
| **Tags**              | Minimal (`managed_by`, `module`)     | Add cost-center, owner, environment, compliance |
| **Backups**           | Local backup disabled                | Enable with retention policies                  |
| **mTLS Certificates** | Default OCI-managed                  | Proper certificate lifecycle management         |
| **Timeouts**          | Generous defaults (24h create)       | Tune based on observed deployment times         |
| **Monitoring**        | Basic data collection enabled        | Integrate with CloudWatch/OCI Monitoring        |

## Project Structure

```
/
├── manage.py                # Setup and config generator
├── requirements.txt         # Python dependencies
├── .env.j2                  # Environment template
├── .env                     # Generated (gitignored)
├── terraform/
│   ├── modules/             # Reusable modules
│   ├── main.tf              # Root module
│   ├── vars.tf              # Variables
│   ├── output.tf            # Outputs
│   ├── provider.tf          # AWS provider
│   ├── version.tf           # Version constraints
│   ├── terraform.tfvars.j2  # Variables template
│   └── terraform.tfvars     # Generated (gitignored)
└── ansible/                 # Planned (WIP)
```

## References

- [Oracle Database @ AWS Documentation](https://docs.aws.amazon.com/odb/)
- [OCI Multicloud Landing Zone for AWS](https://github.com/oci-landing-zones/terraform-oci-multicloud-aws)
- [Terraform AWS Provider - ODB Resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Oracle Terraform Examples](https://docs.oracle.com/en-us/iaas/Content/database-at-aws-exadata-awscs/awscs-code-samples-terraform.html)
