# KVM Virtual Machine Provisioning via Terraform and Configuration with Ansible

This Terraform configuration allows you to create multiple KVM instances with customizable configurations, including additional disks, memory, and CPU settings. It uses the `dmacvicar/libvirt` provider to manage the KVM resources.

## Prerequisites

Before using this Terraform configuration, ensure you have the following installed:

- Terraform (version 0.13 or later)
- Libvirt (and QEMU/KVM) installed on the machine where Terraform is running
- An existing base image (e.g., QEMU image in qcow2 format) accessible via a URL or local path
- SSH public key configured for your local user in your workstation

If using Ubuntu, you may need to disable AppArmor on your system:

```bash
sudo systemctl disable --now apparmor
sudo systemctl reboot
```

## Configuration

Before running the Terraform scripts, you need to set the following variables in a `terraform.tfvars` file:

- `image_url`: The URL or local path to the base image in qcow2 format.
- `image_cloud_user`: The username used in the cloud-init user data.
- `vm_subdomain`: The subdomain to be appended to the instance hostname.
- `instances`: A map of KVM instances you want to create, with the following attributes:
  - `vm_ram`: The amount of RAM (in MB) to allocate to the instance.
  - `vm_cpus`: The number of virtual CPUs to allocate to the instance.
  - `extra_disks` (optional): A list of additional disk sizes (in GB) to attach to the instance.

Example `terraform.tfvars`:

```hcl
# map of instances to be created. Expand the map as needed 
instances = {
  master01 = {                             # name of the vm in the instances map, it can be arbitrary
    vm_ram = 4,                            # ram for the system, value is in GB
    vm_cpus = 1                            # cpus for the system 
  },
  worker01 = {
    vm_ram = 2,
    vm_cpus = 1,
    extra_disks = [10,10]                  # array of extra disks, each element is the size of the extra disk in GB
  }
}
```
The variables in this file will be dynamically included by Terraform.

## Usage

1. Initialize Terraform:

```bash
terraform -chdir=terraform init 
```

This command configures various local settings and data necessary for subsequent Terraform operations.

2. Preview the execution plan:

```bash
terraform -chdir=terraform plan
```

This command generates an execution plan that outlines the steps needed to achieve the state defined in the configuration files.

3. Apply the changes:

```bash
terraform -chdir=terraform apply -auto-approve
```

This command implements the changes required to match the desired configuration state. Upon completion, it outputs the IP addresses of the created VMs. Note: There may be a delay before the VMs are assigned IP addresses. If they are not immediately available, you can update the state by running `terraform -chdir=terraform refresh`.

4. Verify the connectivity with Ansible:

```bash
ansible all -m ping
```
This command checks if Ansible can reach the newly provisioned VMs. It will work once the VMs have completed booting and the network configuration is set.

You can now for example check the disks attached to the VM by running the following ansible ad-hoc command:
```bash
ansible all -m command -a "lsblk"
```

## Cleaning Up

When you no longer require the VMs, you can remove them with:

```bash
terraform -chdir=terraform destroy -auto-approve
```

This command destroys all the infrastructure elements managed by Terraform.

## Resources

[Libvirt terraform provider docs](https://github.com/dmacvicar/terraform-provider-libvirt) 