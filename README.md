# KVM Virtual Machine Provisioning via Terraform and Configuration with Ansible

The aim of this project is to streamline the process of provisioning and configuring a variable quantity of virtual machines on a Kernel-based Virtual Machine (KVM) host using the Terraform libvirt provider and Ansible. Some of the main features:

1. **Automated disk image downloading**: Terraform will download a bootable disk image for each VM being provisioned.

2. **Unique VM naming**: Each VM created as part of the project is assigned a unique name, helping to simplify identification and management.

3. **Cloud-init configuration**: A cloud-init configuration is prepared for each VM. This configuration includes the user's SSH public key, facilitating secure access to the VMs.

4. **Ansible dynamic inventory**: The project sets up Ansible for configuration management by relying on a custom Ansible dynamic inventory. This allows Ansible to manage the newly-provisioned hosts as soon as they are up and running.

## Prerequisites

Before you begin, ensure your system meets the following requirements:

- Terraform v0.13 or later
- [Terraform Libvirt Provider](https://github.com/dmacvicar/terraform-provider-libvirt)
- libvirt
- KVM

If using Ubuntu, you may need to disable AppArmor on your system:

```bash
sudo systemctl disable --now apparmor
sudo systemctl reboot
```

## How to Use

Start by creating a `variables.tfvars` file with the following content:

```hcl
vm_name = "my_vm"
image_url = "https://download.fedoraproject.org/pub/fedora/linux/releases/38/Cloud/x86_64/images/Fedora-Cloud-Base-38-1.6.x86_64.qcow2"
image_cloud_user = "fedora"
ram = 2048
cpus = 1
vm_count = 2
```

You can modify these values as per your requirements.

The following steps will guide you to deploy the VMs:

1. Initialize Terraform:

```bash
terraform init
```

This command configures various local settings and data necessary for subsequent Terraform operations.

2. Preview the execution plan:

```bash
terraform plan -var-file="variables.tfvars"
```

This command generates an execution plan that outlines the steps needed to achieve the state defined in the configuration files.

3. Apply the changes:

```bash
terraform apply -auto-approve -var-file="variables.tfvars"
```

This command implements the changes required to match the desired configuration state. Upon completion, it outputs the IP addresses of the created VMs. Note: There may be a delay before the VMs are assigned IP addresses. If they are not immediately available, you can update the state by running `terraform refresh -var-file=variables.tfvars`.

4. Verify the connectivity with Ansible:

```bash
ansible all -m ping
```
This command checks if Ansible can reach the newly provisioned VMs. It will work once the VMs have completed booting and the network configuration is set.

## Cleaning Up

When you no longer require the VMs, you can remove them with:

```bash
terraform destroy -auto-approve -var-file="variables.tfvars"
```

This command destroys all the infrastructure elements managed by Terraform.

## Resources

[Libvirt terraform provider docs](https://github.com/dmacvicar/terraform-provider-libvirt) 