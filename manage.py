#!/usr/bin/env python3
"""
manage.py - Setup and Terraform configuration manager for dbaws POC
"""

import sys
from pathlib import Path

from dotenv import dotenv_values
from jinja2 import Template


ROOT_DIR = Path(__file__).parent
TERRAFORM_DIR = ROOT_DIR / "terraform"


def cmd_setup():
    """Interactive setup: prompt for values and create .env from .env.j2"""
    template_path = ROOT_DIR / ".env.j2"
    output_path = ROOT_DIR / ".env"

    if not template_path.exists():
        print(f"Error: Template not found: {template_path}")
        sys.exit(1)

    print("=== dbaws Environment Setup ===\n")

    values = {
        "aws_access_key_id": prompt("AWS_ACCESS_KEY_ID"),
        "aws_secret_access_key": prompt("AWS_SECRET_ACCESS_KEY", secret=True),
        "aws_session_token": prompt("AWS_SESSION_TOKEN", secret=True),
        "aws_region": prompt("AWS_REGION", default="us-east-1"),
        "project_prefix": prompt("PROJECT_PREFIX", default="dbaws"),
    }

    template = Template(template_path.read_text())
    output = template.render(**values)
    output_path.write_text(output)

    print(f"\n.env created at: {output_path}")


def cmd_tf():
    """Generate terraform.tfvars from .env values"""
    env_path = ROOT_DIR / ".env"
    template_path = TERRAFORM_DIR / "terraform.tfvars.j2"
    output_path = TERRAFORM_DIR / "terraform.tfvars"

    if not env_path.exists():
        print(f"Error: .env not found. Run 'python manage.py setup' first.")
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
        sys.exit(1)

    command = sys.argv[1]

    if command == "setup":
        cmd_setup()
    elif command == "tf":
        cmd_tf()
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
