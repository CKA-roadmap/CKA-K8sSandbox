# Terraform Libvirt Provider Example

This repository contains a Terraform script for creating a virtual machine (VM) on KVM using the Libvirt provider.

The provider is available on [Github](https://github.com/dmacvicar/terraform-provider-libvirt). You can find more detailed information in their [official documentation](https://github.com/dmacvicar/terraform-provider-libvirt).

The script creates a VM, downloads a cloud image of Fedora, creates a cloud-init configuration with your SSH public key, and applies it to the VM.

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

1. Initialize Terraform:

    ```bash
    terraform init
    ```

    This command initializes various local settings and data that will be used by subsequent commands.

2. Verify the plan:

    ```bash
    terraform plan
    ```

    This command creates an execution plan. It determines what actions are necessary to achieve the desired state specified in the configuration files.

3. Apply the changes:

    ```bash
    terraform apply -auto-approve
    ```

    This command applies the changes required to reach the desired state of the configuration.

To check the IP address of the created VM, you can run the following command:

```bash
terraform refresh
```

This command will print the IP address of your VM. Caveat, it takes few seconds for the VM to get an IP assigned, so please, wait a moment and be patient.

## Cleaning Up

When you are done with the VM, you can remove it with the following command:

```bash
terraform destroy -auto-approve
```

This command destroys the Terraform-managed infrastructure.