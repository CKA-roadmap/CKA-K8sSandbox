# bootable disk image for the systems
image_url = "https://download.fedoraproject.org/pub/fedora/linux/releases/38/Cloud/x86_64/images/Fedora-Cloud-Base-38-1.6.x86_64.qcow2"

# cloud user set in the disk image
image_cloud_user = "fedora"

# subdmain for the vms
vm_subdomain = "k8s.lab"     

# name of the kvm vm
vm_network_name = "k8s_lab_network"

# ipv4 network for the vms
vm_network = "192.168.123.0/24"

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