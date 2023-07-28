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

data "template_file" "user_data" {
  template = <<-EOF
    #cloud-config
    users:
      - name: fedora
        ssh-authorized-keys:
          - ${file("~/.ssh/id_rsa.pub")}
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
  memory = "1024"
  vcpu   = 1

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

output "vm_ip_address" {
  value = length(libvirt_domain.vm.network_interface.0.addresses) > 0 ? libvirt_domain.vm.network_interface.0.addresses[0] : "IP not assigned"
}