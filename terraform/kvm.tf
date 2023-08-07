terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

variable "vm_subdomain" {
  description = "Subdomain for the KVM VMs"
  default = "k8s.lab"
}

variable "vm_network_name" {
  description = "Name of the KVM Network"
  default = "k8s_lab_network"
}

variable "vm_network" {
  description = "Network range for the KVM VMs"
  default = "192.168.123.0/24"
}

variable "image_url" {
  description = "Path to bootable disk"
  default = "https://download.fedoraproject.org/pub/fedora/linux/releases/38/Cloud/x86_64/images/Fedora-Cloud-Base-38-1.6.x86_64.qcow2"
}

variable "image_cloud_user" {
  description = "Image cloud user baked in the bootable disk"
  default = "fedora"
}

variable "instances" {
  description = "Map of KVM instances"
  type = map(object({
    vm_ram          = number
    vm_cpus         = number
    extra_disks     = optional(list(number))
    image_url       = optional(string)
    image_cloud_user= optional(string)
    roles          = optional(list(string))
  }))
  default = {}
}

data "template_file" "user_data" {
  for_each = var.instances
  template = <<-EOF
    #cloud-config
    hostname: ${each.key}
    users:
      - name: ${each.value.image_cloud_user != null ? each.value.image_cloud_user : var.image_cloud_user}
        sudo: ['ALL=(ALL) NOPASSWD:ALL']
        groups: sudo
        ssh_authorized_keys:
          - ${file("~/.ssh/id_rsa.pub")}
    runcmd:
      - [ hostnamectl, set-hostname, ${each.key}.${var.vm_subdomain} ]
  EOF
}


resource "libvirt_network" "private_network" {
  name       = "${var.vm_network_name}"
  mode       = "nat"
  domain     = "${var.vm_subdomain}"
  addresses  = ["${var.vm_network}"]

  dhcp {
    enabled = true
  }

  dns {
    enabled = true
  }
}

resource "libvirt_cloudinit_disk" "cloudinit_disk" {
  for_each  = var.instances
  name      = "cloudinit_${each.key}"
  user_data = data.template_file.user_data[each.key].rendered
}

resource "libvirt_volume" "vm_disk" {
  for_each = var.instances
  name     = "${each.key}_volume.qcow2"
  pool     = "default"
  format   = "qcow2"
  source   = each.value.image_url != null ? each.value.image_url : var.image_url
}


locals {
  disk_map = flatten([
    for vm_name, instance in var.instances : [
      for disk_index, disk_size in instance.extra_disks != null ? instance.extra_disks : [] : {
        vm_name    = vm_name
        disk_index = disk_index
        disk_size  = disk_size
      }
    ]
  ])
}

resource "libvirt_volume" "extra_disk" {
  for_each = {
    for disk in local.disk_map : "${disk.vm_name}-${disk.disk_index}" => disk
  }

  name   = "${each.value.vm_name}_extra_volume_${each.value.disk_index}.qcow2"
  pool   = "default"
  format = "qcow2"
  size   = each.value.disk_size * 1024 * 1024 * 1024  # convert GB to bytes
}

resource "libvirt_domain" "vm" {
  for_each = var.instances
  name     = each.key
  memory   = each.value.vm_ram * 1024 # memory value is in MB in Terraform Libvirt provider
  vcpu     = each.value.vm_cpus

  disk {
    volume_id = libvirt_volume.vm_disk[each.key].id
  }

  dynamic "disk" {
    for_each = [for d in local.disk_map : d if d.vm_name == each.key]
    content {
      volume_id = libvirt_volume.extra_disk["${disk.value.vm_name}-${disk.value.disk_index}"].id
    }
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit_disk[each.key].id

  network_interface {
    network_name =  libvirt_network.private_network.name
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}


output "hosts_info" {
  value = { for name, instance in var.instances :
    name => {
      "vm_fqdn"    = "${name}.${var.vm_subdomain}"
      "ip"         = length(libvirt_domain.vm[name].network_interface.0.addresses) > 0 ? "${libvirt_domain.vm[name].network_interface.0.addresses[0]}" : "IP not assigned"
      "cloud_user" = var.image_cloud_user
      "roles"      = instance.roles != null ? instance.roles : []
    }
  }
}