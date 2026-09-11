# Azure Terraform Labs

Hands-on Azure infrastructure labs using Terraform.

This repository documents my practical Terraform learning on Microsoft Azure, starting with basic infrastructure and gradually progressing toward advanced Azure networking, modules, state management, brownfield imports, automation, troubleshooting, and CI/CD.

---

## Lab 01 — Azure Infrastructure with Terraform

Built a basic Azure network and Linux VM using Terraform.

### Resources

- Existing Azure Resource Group referenced using a Terraform `data` source
- Virtual Network (`10.10.0.0/16`)
- Subnet (`10.10.1.0/24`)
- Network Security Group
- SSH inbound rule
- NSG-to-Subnet association
- Static Public IP
- Network Interface
- Ubuntu Linux VM
- SSH key authentication

### Architecture

```text
Internet
   |
Public IP
   |
   v
Network Interface
   |
   v
Linux VM
   |
   v
Subnet 10.10.1.0/24
   |
   v
VNet 10.10.0.0/16

NSG → Subnet
```

### Terraform Workflow

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

After deployment, I successfully connected to the Azure VM using SSH.

---

## Lab 02 — Azure Remote Terraform State

The initial Terraform state was stored locally.

I then created:

- Azure Storage Account
- Private Blob Container
- AzureRM Terraform backend

The existing local state was migrated to Azure Blob Storage:

```bash
terraform init -migrate-state
```

### State Architecture

```text
Terraform
    |
    v
Azure Storage Account
    |
    v
Blob Container
    |
    v
Lab01.terraform.tfstate
```

This lab also demonstrated Terraform **remote state locking** during operations.

---

## Lab 03 — Terraform Drift Detection

To simulate a real-world configuration drift scenario, I manually added a tag to a Terraform-managed VNet through the Azure Portal.

Running:

```bash
terraform plan
```

detected the difference between the Terraform configuration and the actual Azure infrastructure.

Terraform showed:

```text
Plan: 0 to add, 1 to change, 0 to destroy
```

I then used:

```bash
terraform apply
```

to remove the manual change and return the Azure resource to the Terraform-defined configuration.

### Drift Workflow

```text
Manual Portal Change
        |
        v
Configuration Drift
        |
        v
terraform plan
        |
        v
Drift Detected
        |
        v
terraform apply
        |
        v
Infrastructure Restored
```

---

## Lab 04 — Brownfield Resource Import

To practice managing existing infrastructure, I manually created an Azure Network Security Group:

```text
nsg-import-lab
```

The resource already existed in Azure but was not managed by Terraform.

I retrieved its Azure Resource ID and imported it:

```bash
terraform import azurerm_network_security_group.imported_nsg "<AZURE-RESOURCE-ID>"
```

This mapped the existing Azure resource to a Terraform resource address in the remote state.

After the import:

```bash
terraform plan
```

returned:

```text
No changes. Your infrastructure matches the configuration.
```

This confirmed that the existing Azure resource was successfully brought under Terraform management.

---

## Key Concepts Practiced

- Azure CLI authentication
- AzureRM provider
- Terraform variables
- `terraform.tfvars`
- Terraform `resource` vs `data`
- Resource dependencies
- Azure networking
- Linux VM deployment
- SSH authentication
- Local Terraform state
- Azure Blob remote state
- State migration
- State locking
- Drift detection
- Drift remediation
- Brownfield infrastructure
- Terraform resource imports

---

## Terraform Mental Model

```text
Terraform Configuration
        |
        v
Terraform State
        |
        v
Actual Azure Infrastructure
```

The configuration defines the desired infrastructure.

The state tracks which real Azure resources Terraform manages.

Terraform compares the configuration, state, and actual Azure environment when creating a plan.

---

## Repository Files

```text
.
├── main.tf
├── providers.tf
├── variables.tf
├── version.tf
├── .terraform.lock.hcl
├── .gitignore
└── README.md
```

Terraform state, `.terraform/`, private SSH keys, and `terraform.tfvars` are excluded from Git.

---

## Next Steps

Future labs will progressively introduce:

- Larger Azure brownfield migrations
- Terraform import blocks
- `count`
- `for_each`
- Locals
- Functions
- Conditional expressions
- Custom modules
- Module inputs and outputs
- Advanced state management
- Azure networking
- Intentional break/fix troubleshooting
- Terraform CI/CD
- GitHub Actions
- Azure workload identity

The goal is to progressively move from basic Terraform deployments toward production-style Azure Infrastructure as Code.
