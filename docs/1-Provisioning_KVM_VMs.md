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

Several variables allow you to customize the VM instances by editing the file `terraform.tfvars`:

- `vm_subdomain`: Sets the subdomain for the VMs.
- `vm_network_name`: Defines the name of the KVM network.
- `vm_network`: Specifies the network range for the VMs.
- `image_url`: The URL for the bootable VM image.
- `image_cloud_user`: The default user baked into the bootable image.
- `instances`: A map that details the VMs to be created, their specifications, and roles.

For the `instances` map, each VM configuration can have:

- `vm_ram`: RAM size in GB (defaults to 2GB if not provided).
- `vm_cpus`: Number of vCPUs (defaults to 2 if not provided).
- `extra_disks`: List of additional disk sizes in GB.
- `image_url`: URL for the bootable VM image specific to that instance.
- `image_cloud_user`: User baked into the bootable image specific to that instance.
- `roles`: List of roles assigned to the VM.


The variables in this file will be dynamically included by Terraform.


## Usage

Always locate yourself at the root of the project. 

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
ansible master --list-hosts
ansible worker --list-hosts
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

## Further Customization

Feel free to modify the script or add additional configurations to suit your specific use-case.