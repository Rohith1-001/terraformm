# Terraform – Create an AWS EC2 Instance

This guide demonstrates how to create an **AWS EC2 instance using Terraform**, configure a Security Group for SSH access, and manage the infrastructure using Terraform commands.

---

## 📌 Architecture

```text
Terraform
    │
    ├── AWS Provider
    │
    ├── Security Group
    │      └── SSH – Port 22
    │
    └── EC2 Instance
           ├── AMI
           ├── Instance Type: t3.micro
           └── Security Group
```

---

## 🛠️ Prerequisites

Before starting, make sure the following are installed and configured:

* AWS Account
* AWS CLI
* Terraform
* Git
* GitHub account
* Git Bash

AWS credentials should be configured securely using the AWS CLI or another supported authentication method.

Example:

```bash
aws configure
```

Verify the AWS configuration:

```bash
aws sts get-caller-identity
```

---

# 📁 Project Structure

```text
terraform-ec2/
│
├── ec2.tf
├── provider.tf
├── .gitignore
└── README.md
```

### File Description

| File          | Purpose                                                             |
| ------------- | ------------------------------------------------------------------- |
| `provider.tf` | Configures the Terraform AWS provider and region                    |
| `ec2.tf`      | Creates the Security Group and EC2 instance                         |
| `.gitignore`  | Prevents unnecessary/sensitive Terraform files from being committed |
| `README.md`   | Project documentation                                               |

---

# 1. Configure the AWS Provider

Create a file named:

```text
provider.tf
```

Add the following configuration:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.62.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

### Explanation

#### `required_providers`

```hcl
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "6.62.0"
  }
}
```

Defines the AWS provider required by Terraform.

* `source` → Specifies the provider source.
* `version` → Specifies the provider version.

#### AWS Region

```hcl
provider "aws" {
  region = "us-east-1"
}
```

Specifies the AWS region where the resources will be created.

In this example:

```text
us-east-1 → US East (N. Virginia)
```

---

# 2. Create the Security Group

Create:

```text
ec2.tf
```

Add:

```hcl
resource "aws_security_group" "allow_ssh_terraform" {

  name        = "allow_ssh"
  description = "Allow port number 22 for SSH access"

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}
```

---

## 🔐 Security Group Rules

### Inbound – SSH

```hcl
ingress {
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}
```

This allows SSH traffic on:

```text
Port:     22
Protocol: TCP
```

### CIDR

```text
0.0.0.0/0
```

means the resource accepts IPv4 traffic from any IP address.

```text
::/0
```

allows IPv6 traffic from any IPv6 address.

> ⚠️ For production environments, SSH access should not normally be opened to the entire internet. Restrict port 22 to trusted IP addresses or use a more secure access mechanism.

---

## 🌐 Outbound Traffic

```hcl
egress {
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}
```

The configuration allows outbound traffic to any IPv4 and IPv6 destination.

```text
protocol = "-1"
```

represents all protocols.

---

# 3. Create the EC2 Instance

Add the following to `ec2.tf`:

```hcl
resource "aws_instance" "terraform" {

  ami                    = "ami-081b0a6eac00b4f53"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh_terraform.id]

  tags = {
    Name = "terraform-ec2"
  }
}
```

---

## EC2 Configuration

### AMI

```hcl
ami = "ami-081b0a6eac00b4f53"
```

An **AMI (Amazon Machine Image)** defines the operating system and initial configuration used to launch the EC2 instance.

> ⚠️ AMI IDs are region-specific. An AMI ID available in `us-east-1` may not be available in another AWS region.

---

### Instance Type

```hcl
instance_type = "t3.micro"
```

Defines the compute capacity of the EC2 instance.

---

### Security Group Association

```hcl
vpc_security_group_ids = [
  aws_security_group.allow_ssh_terraform.id
]
```

This associates the EC2 instance with the Security Group created earlier.

The reference:

```text
aws_security_group.allow_ssh_terraform.id
```

follows the Terraform resource reference format:

```text
resource_type.resource_name.attribute
```

Terraform automatically understands the dependency between the Security Group and EC2 instance.

---

# 4. Initialize Terraform

Open Git Bash in the project directory:

```bash
cd /path/to/terraform-ec2
```

Initialize Terraform:

```bash
terraform init
```

### What happens?

Terraform downloads the required provider and initializes the working directory.

For this configuration, Terraform downloads the AWS provider.

---

# 5. Validate the Configuration

Run:

```bash
terraform validate
```

This checks whether the Terraform configuration is syntactically valid and internally consistent.

---

# 6. Format Terraform Files

Run:

```bash
terraform fmt
```

This automatically formats Terraform configuration files according to Terraform's standard formatting conventions.

---

# 7. Review the Execution Plan

Run:

```bash
terraform plan
```

Terraform creates an execution plan showing what resources it intends to create, modify, or destroy.

For this configuration, the plan should include:

```text
aws_security_group.allow_ssh_terraform
aws_instance.terraform
```

---

# 8. Create the Infrastructure

Run:

```bash
terraform apply
```

Terraform displays the execution plan and asks for confirmation.

Enter:

```text
yes
```

Terraform then creates the Security Group and EC2 instance.

Alternatively:

```bash
terraform apply -auto-approve
```

can be used to automatically approve the execution plan.

---

# 9. Verify the EC2 Instance

After `terraform apply` completes:

1. Open the AWS Management Console.
2. Navigate to **EC2**.
3. Select **Instances**.
4. Find the instance with the tag:

```text
Name = terraform-ec2
```

Verify that the associated Security Group allows SSH on port `22`.

---

# 10. Check Terraform State

Terraform maintains a state file to keep track of infrastructure.

Typical state files include:

```text
terraform.tfstate
terraform.tfstate.backup
```

Check the Terraform-managed resources using:

```bash
terraform state list
```

Example:

```text
aws_security_group.allow_ssh_terraform
aws_instance.terraform
```

---

# 11. Destroy the Infrastructure

When the resources are no longer required:

```bash
terraform destroy
```

Terraform displays the resources that will be removed.

Enter:

```text
yes
```

This deletes the infrastructure managed by the Terraform configuration.

Alternatively:

```bash
terraform destroy -auto-approve
```

can be used.

> Remember to destroy unused EC2 resources to avoid unnecessary AWS charges.

---

# 🔐 `.gitignore` for Terraform

Terraform projects generate several files that should generally not be committed to Git.

A `.gitignore` file can be created in the project root:

```text
.gitignore
```

Example:

```gitignore
# Local .terraform directories
.terraform/

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Terraform variable files
*.tfvars
*.tfvars.json

# Override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Terraform state lock file
.terraform.tfstate.lock.info

# Terraform CLI configuration files
.terraformrc
terraform.rc
```

---

## Why use `.gitignore`?

### `.terraform/`

```text
.terraform/
```

Terraform creates this directory during `terraform init`.

It contains downloaded provider files and other local Terraform data.

These files do not need to be stored in Git.

---

### Terraform State

```text
*.tfstate
*.tfstate.*
```

Terraform state files contain information about infrastructure managed by Terraform.

Depending on the configuration, state can contain sensitive information.

Therefore, state files should not normally be pushed to a public GitHub repository.

For production environments, Terraform state is commonly stored remotely using a secure backend.

---

### Variable Files

```text
*.tfvars
*.tfvars.json
```

Variable files may contain environment-specific or sensitive information such as:

```text
Passwords
API keys
Secrets
Environment-specific configuration
```

Therefore, they are commonly excluded from Git.

---

# 📚 Where Does the Terraform `.gitignore` Come From?

The `.gitignore` template used for Terraform projects can be obtained from GitHub's official **gitignore templates repository**.

GitHub maintains templates for different programming languages and tools, including Terraform.

[GitHub gitignore repository](https://github.com/github/gitignore?utm_source=chatgpt.com)

The Terraform template is:

[Terraform.gitignore template](https://github.com/github/gitignore/blob/main/Terraform.gitignore?utm_source=chatgpt.com)

This is useful when creating a new Terraform repository because it provides commonly ignored Terraform-generated files and local configuration files.

---

# 🔄 Git & GitHub Workflow

After creating the Terraform project, initialize Git:

```bash
git init
```

Check the files:

```bash
git status
```

Add the files:

```bash
git add .
```

Create a commit:

```bash
git commit -m "Create EC2 instance using Terraform"
```

Rename the branch to `main`:

```bash
git branch -M main
```

Connect the local repository to GitHub:

```bash
git remote add origin <GITHUB-REPOSITORY-URL>
```

Push the code:

```bash
git push -u origin main
```

---

# 🔄 Complete Terraform Command Reference

| Command                | Purpose                             |
| ---------------------- | ----------------------------------- |
| `terraform init`       | Initialize the Terraform project    |
| `terraform validate`   | Validate Terraform configuration    |
| `terraform fmt`        | Format Terraform files              |
| `terraform plan`       | Preview infrastructure changes      |
| `terraform apply`      | Create/update infrastructure        |
| `terraform destroy`    | Delete infrastructure               |
| `terraform show`       | Display Terraform state information |
| `terraform state list` | List Terraform-managed resources    |

---

# 🔐 Security Considerations

* Do not hardcode AWS access keys or secret keys in Terraform files.
* Do not commit `terraform.tfstate` to a public repository.
* Do not commit `.tfvars` files containing secrets.
* Do not expose SSH port `22` to `0.0.0.0/0` in production.
* Use appropriate IAM permissions instead of excessive AWS permissions.
* Use a remote and secure Terraform backend for production workloads.
* Review `terraform plan` before running `terraform apply`.

---

# 📌 Final Terraform Configuration

### `provider.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.62.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

### `ec2.tf`

```hcl
resource "aws_security_group" "allow_ssh_terraform" {

  name        = "allow_ssh"
  description = "Allow port number 22 for SSH access"

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_instance" "terraform" {

  ami                    = "ami-081b0a6eac00b4f53"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh_terraform.id]

  tags = {
    Name = "terraform-ec2"
  }
}
```

---

## 📖 Quick Reference

```text
1. Create Terraform files
       ↓
2. terraform init
       ↓
3. terraform fmt
       ↓
4. terraform validate
       ↓
5. terraform plan
       ↓
6. terraform apply
       ↓
7. Verify resources in AWS
       ↓
8. terraform destroy
```

This repository can be used as a quick reference for creating a basic **AWS EC2 instance with Terraform** and managing the configuration through **Git and GitHub**.
