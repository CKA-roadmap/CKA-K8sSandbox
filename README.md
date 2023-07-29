# Terraform Libvirt Provider Example

This repository contains a Terraform script for creating multiple virtual machines (VMs) on KVM using the Libvirt provider.

The provider is available on [Github](https://github.com/dmacvicar/terraform-provider-libvirt). You can find more detailed information in their [official documentation](https://github.com/dmacvicar/terraform-provider-libvirt).

The script creates a configurable number of VMs, each with its own unique name, downloads a cloud image of Fedora, creates a cloud-init configuration with your SSH public key, and applies it to each VM.

## Requirements

- Terraform v0.13 or newer
- [Terraform Libvirt Provider](https://github.com/dmacvicar/terraform-provider-libvirt)
- libvirt
- KVM

## Initial Setup

To prevent issues related to security permissions, you may need to disable AppArmor on your system:

```bash
sudo systemctl disable --now apparmor
sudo systemctl reboot
```

## Usage

First, create a `variables.tfvars` file with the following content:

```hcl
vm_name = "my_vm"
image_url = "https://download.fedoraproject.org/pub/fedora/linux/releases/38/Cloud/x86_64/images/Fedora-Cloud-Base-38-1.6.x86_64.qcow2"
ram = 2048
cpus = 1
vm_count = 4
```

You can adjust the values to fit your needs.

1. Initialize Terraform:

```bash
terraform init
```

   This command initializes various local settings and data that will be used by subsequent commands.

2. Verify the plan:

```bash
terraform plan -var-file="variables.tfvars"
```

   This command creates an execution plan. It determines what actions are necessary to achieve the desired state specified in the configuration files.

3. Apply the changes:

```bash
terraform apply -auto-approve -var-file="variables.tfvars"
```

   This command applies the changes required to reach the desired state of the configuration.

After the command completes, it will print the SSH commands to connect to each VM. Please note that it might take a few seconds for the VMs to get an IP assigned, so please be patient.

## Cleaning Up

When you are done with the VMs, you can remove them with the following command:

```bash
terraform destroy -auto-approve -var-file="variables.tfvars"
```

This command destroys the Terraform-managed infrastructure.

## The `count` parameter

The `count` parameter in the Terraform configuration allows you to create multiple instances of a resource. In this example, it is used to create a configurable number of VMs, each with its own unique name, disk volume, and cloud-init configuration. The number of VMs is controlled by the `vm_count` variable in the `variables.tfvars` file.