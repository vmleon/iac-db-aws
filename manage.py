#!/usr/bin/env python3
"""
manage.py - Setup and Terraform configuration manager for dbaws POC
"""

import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

from dotenv import dotenv_values
from jinja2 import Template


ROOT_DIR = Path(__file__).parent
TERRAFORM_DIR = ROOT_DIR / "terraform"
SSH_KEY_NAME = "dbaws_key"


def ensure_ssh_key() -> str:
    """
    Ensure SSH keypair exists for VM Cluster access.
    Auto-generates ed25519 keypair if not found.

    POC Note: Auto-generates keys. Production: Use existing keys from
    secrets manager or HSM.

    Returns:
        str: SSH public key content
    """
    ssh_dir = Path.home() / ".ssh"
    key_path = ssh_dir / SSH_KEY_NAME
    pub_key_path = key_path.with_suffix(".pub")

    if pub_key_path.exists():
        print(f"Using existing SSH key: {pub_key_path}")
        return pub_key_path.read_text().strip()

    print(f"Generating SSH keypair at: {key_path}")
    ssh_dir.mkdir(exist_ok=True, mode=0o700)

    try:
        subprocess.run(
            [
                "ssh-keygen",
                "-t", "ed25519",
                "-f", str(key_path),
                "-N", "",  # No passphrase for POC
                "-C", "dbaws-terraform",
            ],
            check=True,
            capture_output=True,
        )
        print(f"SSH keypair generated: {key_path}")
        return pub_key_path.read_text().strip()
    except subprocess.CalledProcessError as e:
        print(f"Error generating SSH key: {e}")
        sys.exit(1)
    except FileNotFoundError:
        print("Error: ssh-keygen not found. Please install OpenSSH.")
        sys.exit(1)


def validate_email(email: str) -> bool:
    """Validate email format"""
    pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    return bool(re.match(pattern, email))


def prompt_bool(name: str, default: bool = True) -> bool:
    """Prompt for yes/no input"""
    default_str = "Y/n" if default else "y/N"
    value = input(f"{name} [{default_str}]: ").strip().lower()

    if not value:
        return default
    return value in ("y", "yes", "true", "1")


def cmd_setup():
    """Interactive setup: prompt for values and create .env from .env.j2"""
    template_path = ROOT_DIR / ".env.j2"
    output_path = ROOT_DIR / ".env"

    if not template_path.exists():
        print(f"Error: Template not found: {template_path}")
        sys.exit(1)

    print("=" * 50)
    print("  dbaws Environment Setup")
    print("=" * 50)

    # AWS Credentials
    print("\n--- AWS Credentials ---")
    aws_access_key_id = prompt("AWS_ACCESS_KEY_ID")
    aws_secret_access_key = prompt("AWS_SECRET_ACCESS_KEY", secret=True)
    aws_session_token = prompt("AWS_SESSION_TOKEN", secret=True)

    # AWS Configuration
    print("\n--- AWS Configuration ---")
    aws_region = prompt("AWS_REGION", default="us-west-2")

    # Derive default AZ from region
    default_az = f"{aws_region}d"
    availability_zone = prompt("AVAILABILITY_ZONE", default=default_az)

    # Project Configuration
    print("\n--- Project Configuration ---")
    project_prefix = prompt("PROJECT_PREFIX", default="dbaws")

    # ODB Configuration
    print("\n--- Oracle Database Configuration ---")

    # Contact email (required by OCI)
    while True:
        contact_email = prompt("CONTACT_EMAIL (for OCI notifications)")
        if validate_email(contact_email):
            break
        print("Invalid email format. Please try again.")

    # SSH Key
    print("\n--- SSH Key Configuration ---")
    ssh_public_key = ensure_ssh_key()

    # Deployment toggles
    print("\n--- Deployment Options ---")
    deploy_vm_cluster = prompt_bool("Deploy VM Cluster?", default=True)
    deploy_autonomous = prompt_bool("Deploy Autonomous VM Cluster?", default=True)

    values = {
        "aws_access_key_id": aws_access_key_id,
        "aws_secret_access_key": aws_secret_access_key,
        "aws_session_token": aws_session_token,
        "aws_region": aws_region,
        "availability_zone": availability_zone,
        "project_prefix": project_prefix,
        "contact_email": contact_email,
        "ssh_public_key": ssh_public_key,
        "deploy_vm_cluster": str(deploy_vm_cluster),
        "deploy_autonomous": str(deploy_autonomous),
    }

    template = Template(template_path.read_text())
    output = template.render(**values)
    output_path.write_text(output)

    print(f"\n.env created at: {output_path}")
    print("\nNext: Run 'python manage.py tf' to generate terraform.tfvars")


def cmd_tf():
    """Generate terraform.tfvars from .env values"""
    env_path = ROOT_DIR / ".env"
    template_path = TERRAFORM_DIR / "terraform.tfvars.j2"
    output_path = TERRAFORM_DIR / "terraform.tfvars"

    if not env_path.exists():
        print("Error: .env not found. Run 'python manage.py setup' first.")
        sys.exit(1)

    if not template_path.exists():
        print(f"Error: Template not found: {template_path}")
        sys.exit(1)

    env = dotenv_values(env_path)

    template = Template(template_path.read_text())
    output = template.render(**env)
    output_path.write_text(output)

    print(f"terraform.tfvars created at: {output_path}")
    print("\nNext steps:")
    print("  cd terraform")
    print("  terraform init")
    print("  terraform plan -out tfplan")
    print('  terraform apply "tfplan"')
    print("\nNote: Exadata Infrastructure provisioning takes ~4-8 hours.")


def cmd_clean():
    """Clean generated files after terraform destroy"""
    tfstate_path = TERRAFORM_DIR / "terraform.tfstate"

    # Check if terraform state has resources
    if tfstate_path.exists():
        state = json.loads(tfstate_path.read_text())
        resources = state.get("resources", [])
        if resources:
            print("Error: Terraform state has active resources.")
            print("Run 'cd terraform && terraform destroy' first.")
            sys.exit(1)

    # Files/dirs to clean
    targets = [
        ROOT_DIR / ".env",
        TERRAFORM_DIR / "terraform.tfvars",
        TERRAFORM_DIR / "tfplan",
        TERRAFORM_DIR / ".terraform",
        TERRAFORM_DIR / ".terraform.lock.hcl",
    ]

    # Add tfstate files
    targets.extend(TERRAFORM_DIR.glob("*.tfstate*"))

    deleted = []
    for target in targets:
        if target.exists():
            if target.is_dir():
                shutil.rmtree(target)
            else:
                target.unlink()
            deleted.append(target)

    if deleted:
        print("Cleaned:")
        for f in deleted:
            print(f"  {f}")
    else:
        print("Nothing to clean.")

    # Note about SSH key
    ssh_key_path = Path.home() / ".ssh" / SSH_KEY_NAME
    if ssh_key_path.exists():
        print(f"\nNote: SSH keypair at ~/.ssh/{SSH_KEY_NAME} was NOT deleted.")
        print("Delete manually if no longer needed.")


def prompt(name: str, default: str = None, secret: bool = False) -> str:
    """Prompt user for input"""
    if default:
        display = f"{name} [{default}]: "
    else:
        display = f"{name}: "

    if secret:
        import getpass
        value = getpass.getpass(display)
    else:
        value = input(display)

    return value.strip() or default or ""


def main():
    if len(sys.argv) < 2:
        print("Usage: python manage.py <command>")
        print("\nCommands:")
        print("  setup  - Create .env from template (interactive)")
        print("  tf     - Generate terraform.tfvars from .env")
        print("  clean  - Remove generated files (requires terraform destroy first)")
        sys.exit(1)

    command = sys.argv[1]

    if command == "setup":
        cmd_setup()
    elif command == "tf":
        cmd_tf()
    elif command == "clean":
        cmd_clean()
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
