# Kubernetes Lab Provisioner

This repository aims to provide a detailed guide and the necessary tools to provision Kubernetes cluster labs. By leveraging Terraform (Libvirt KVM provisoner) and Ansible, you'll be able to set up and experiment with a Kubernetes cluster, deepening your understanding of its internals and workings.

## Purpose

The primary purpose of this project is to aid in preparing for the **Certified Kubernetes Administrator (CKA)** exam. While there are many resources available, hands-on experience is crucial. This repo allows you to get that hands-on practice, giving you a sandbox environment to hone your skills, troubleshoot issues, and get a feel for real-world Kubernetes administration tasks.

## Components

- **Terraform**: Used for provisioning the virtual infrastructure on KVM.
- **KVM (Kernel-based Virtual Machine)**: The virtualization platform on which our Kubernetes nodes will run.
- **Ansible**: Used for configuration management to set up and configure Kubernetes on the provisioned virtual machines.

## Project Structure

- **ansible/**: This directory contains all Ansible-related files. The main components include:
  - `ansible_dynamic_inventory.py`: A script for generating a dynamic inventory based on the state of provisioned VMs.
  - `roles/`: Various roles for different configurations, like `master`, `worker`, `networking`, etc. Each role has its own set of tasks, defaults, and metadata.
  - `kubernetes.yml`: The primary playbook for setting up Kubernetes.
  - `vars.yml`: The file where global variables will be included. Settings set in this file will override defaults.
  
- **docs/**: A directory with documentation explaining different aspects of the project and any additional resources.
  
- **terraform/**: Contains Terraform scripts for provisioning VMs on KVM. 
  - `kvm.tf`: The main Terraform script for provisioning.
  - `terraform.tfvars`: Contains specific variables used during the provisioning process.

## How to Use

1. **Documentation**: Begin by navigating to the `docs/` folder. This contains in-depth documentation about the lab provisioner project, its components, and the structure. Additionally, you'll find valuable insights and resources for CKA exam preparation.

2. **Infrastructure Setup**: Once you're familiar with the project's structure and intent, head to the `terraform/` directory. Here, follow the instructions to provision your KVM virtual machines.
   
3. **Kubernetes Cluster Setup**: With your VMs up and running, proceed to the `ansible/` directory. Use the provided playbooks to set up and configure your Kubernetes cluster.
   
4. **Experiment and Learn**: Now, with your cluster set up, delve into practical Kubernetes administration. Practice various administrative tasks, simulate troubleshooting scenarios, and cover other vital topics for the CKA exam.

## Conclusion

Practical experience is invaluable when preparing for the CKA exam. This repo aims to provide an easy and straightforward way to get hands-on with Kubernetes. Dive in, break things, fix them, and get a deeper understanding of Kubernetes along the way.