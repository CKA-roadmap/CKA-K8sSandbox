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

variable "vm_name" {}

variable "image_url" {}

variable "ram" {}

variable "cpus" {}

variable "vm_count" {}

data "template_file" "user_data" {
  count    = var.vm_count
  template = <<-EOF
    #cloud-config
    hostname: ${var.vm_name}_${count.index}
    users:
      - name: fedora
        ssh-authorized-keys:
          - ${file("~/.ssh/id_rsa.pub")}
    runcmd:
      - [ hostnamectl, set-hostname, ${var.vm_name}_${count.index} ]
  EOF
}

resource "libvirt_cloudinit_disk" "cloudinit_disk" {
  count       = var.vm_count
  name        = "cloudinit_${var.vm_name}_${count.index}"
  user_data   = data.template_file.user_data[count.index].rendered
}

resource "libvirt_volume" "vm_disk" {
  count  = var.vm_count
  name   = "${var.vm_name}_${count.index}_volume.qcow2"
  pool   = "default"
  format = "qcow2"
  source = var.image_url
}

resource "libvirt_domain" "vm" {
  count  = var.vm_count
  name   = "${var.vm_name}_${count.index}"
  memory = var.ram
  vcpu   = var.cpus

  disk {
    volume_id = libvirt_volume.vm_disk[count.index].id
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit_disk[count.index].id

  network_interface {
    network_name = "default"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

output "ssh_commands" {
  value = [for i in range(var.vm_count) : length(libvirt_domain.vm[i].network_interface.0.addresses) > 0 ? "ssh fedora@${libvirt_domain.vm[i].network_interface.0.addresses[0]}" : "IP not assigned, run `terraform refresh` in a few seconds"]
}
