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

variable "image_cloud_user" {}

variable "ram" {}

variable "cpus" {}

variable "vm_count" {}

data "template_file" "user_data" {
  count    = var.vm_count
  template = <<-EOF
    #cloud-config
    hostname: ${var.vm_name}${count.index}
    users:
      - name: ${var.image_cloud_user}
        ssh_authorized_keys:
          - ${file("~/.ssh/id_rsa.pub")}
    runcmd:
      - [ hostnamectl, set-hostname, ${var.vm_name}${count.index} ]
  EOF
}

resource "libvirt_cloudinit_disk" "cloudinit_disk" {
  count       = var.vm_count
  name        = "cloudinit_${var.vm_name}${count.index}"
  user_data   = data.template_file.user_data[count.index].rendered
}

resource "libvirt_volume" "vm_disk" {
  count  = var.vm_count
  name   = "${var.vm_name}${count.index}_volume.qcow2"
  pool   = "default"
  format = "qcow2"
  source = var.image_url
}

resource "libvirt_domain" "vm" {
  count  = var.vm_count
  name   = "${var.vm_name}${count.index}"
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

output "output_info" {
  value = [for i in range(var.vm_count) : 
    {
      "name" = "${var.vm_name}${i}",
      "ip"   = length(libvirt_domain.vm[i].network_interface.0.addresses) > 0 ? "${libvirt_domain.vm[i].network_interface.0.addresses[0]}" : "IP not assigned",
      "cloud_user" = "${var.image_cloud_user}"
    }
  ]
}