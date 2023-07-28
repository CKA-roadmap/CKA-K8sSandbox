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

variable "vm_name" {
  default = "my_vm"
}

variable "image_url" {
  default = "https://download.fedoraproject.org/pub/fedora/linux/releases/38/Cloud/x86_64/images/Fedora-Cloud-Base-38-1.6.x86_64.qcow2"
}

variable "ram" {
  description = "Amount of RAM for the VM"
  default = 1024
}

variable "cpus" {
  description = "Number of CPUs for the VM"
  default = 1
}

data "template_file" "user_data" {
  template = <<-EOF
    #cloud-config
    hostname: ${var.vm_name}
    users:
      - name: fedora
        ssh-authorized-keys:
          - ${file("~/.ssh/id_rsa.pub")}
    runcmd:
      - [ hostnamectl, set-hostname, ${var.vm_name} ]
  EOF
}

resource "libvirt_cloudinit_disk" "cloudinit_disk" {
  name           = "cloudinit_${var.vm_name}"
  user_data      = data.template_file.user_data.rendered
}

resource "libvirt_volume" "vm_disk" {
  name   = "${var.vm_name}_volume.qcow2"
  pool   = "default"
  format = "qcow2"
  source = var.image_url
}

resource "libvirt_domain" "vm" {
  name   = var.vm_name
  memory = var.ram
  vcpu   = var.cpus

  disk {
    volume_id = libvirt_volume.vm_disk.id
  }


  cloudinit = libvirt_cloudinit_disk.cloudinit_disk.id


  network_interface {
    network_name = "default"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

output "ssh_command" {
  value = length(libvirt_domain.vm.network_interface.0.addresses) > 0 ? "ssh fedora@${libvirt_domain.vm.network_interface.0.addresses[0]}" : "IP not assigned, run `terraform refresh` in a few seconds"
}
