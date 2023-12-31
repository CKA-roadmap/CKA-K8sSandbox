# Define the subdomain for VMs
vm_subdomain = "k3s.lab"     

# Specify the name of the KVM network
vm_network_name = "k8s_lab_network"

# Set the IPv4 network range for the VMs
vm_network = "192.168.123.0/24"

# bootable disk location. Can be overriden per host
image_url = "https://download.fedoraproject.org/pub/fedora/linux/releases/38/Cloud/x86_64/images/Fedora-Cloud-Base-38-1.6.x86_64.qcow2"

# cloud user in bootable disk. Can be overriden per host
image_cloud_user = "fedora"

# Define a map of instances to be created. You can expand this map as needed.
instances = {

  # Define a VM named 'master'. The name is arbitrary and can be changed.
  master = {                             
    # Amount of RAM for this VM, measured in GB
    vm_ram = 4,                            
    
    # Number of CPUs allocated for this VM
    vm_cpus = 2,                           
    
    # Define additional disks for the VM. Each value represents the size of the disk in GB.
    extra_disks = [10],                  
    
    # Assign roles to the VM. This is used for group classification in ansible inventory
    roles = ["master"]
  },

  # Define another VM named 'worker'. Again, this name is arbitrary.
  worker = {                                 
    # Define additional disks for the VM. Each value represents the size of the disk in GB.
    extra_disks = [10],                  
    
    # Assign roles to the VM.
    roles = ["worker"]
  }
}
