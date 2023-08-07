#!/usr/bin/env python3

import json
import subprocess

def get_tf_output():
    """
    Executes the 'terraform output -json' command to retrieve 
    Terraform outputs in JSON format.

    Returns:
        dict: Parsed JSON output from the Terraform command.
    """
    # Define the command to get Terraform output in JSON format
    cmd = 'terraform output -json'
    
    # Directory where Terraform files are located
    tf_directory = './terraform'

    # Execute the Terraform command and decode the output
    output = subprocess.check_output(cmd.split(), cwd=tf_directory).decode('utf-8')
    
    # Return the JSON parsed output
    return json.loads(output)

def generate_inventory(tf_output):
    """
    Generates an Ansible dynamic inventory based on Terraform output.

    Args:
        tf_output (dict): The Terraform output data.

    Returns:
        dict: A dictionary representing the Ansible inventory.
    """
    # Initialize the basic structure for Ansible inventory
    inventory = {
        '_meta': {
            'hostvars': {}
        },
        'all': {
            'children': []
        }
    }

    # Loop through the hosts_info from Terraform output
    for name, info in tf_output['hosts_info']['value'].items():
        # Ignore entries where IP is not assigned
        if info['ip'].startswith("IP not assigned"):
            continue
        
        # Determine the roles for the VM. If roles are not specified, default to 'all'
        roles = info.get('roles', ['all'])
        
        # Extract host details
        host = info['vm_fqdn']
        
        for role in roles:
            # If this role group doesn't exist yet, initialize it
            if role not in inventory:
                inventory[role] = {
                    'hosts': []
                }

            # If this role is not listed as a child of 'all', add it
            if role not in inventory['all']['children']:
                inventory['all']['children'].append(role)

            # Add host to the role group
            inventory[role]['hosts'].append(host)
        
        # Add host-specific variables (IP and user). No need to add roles as they are already represented as groups
        inventory['_meta']['hostvars'][host] = {
            'ansible_host': info['ip'],
            'ansible_user': info['cloud_user']
        }

    return inventory

def main():
    """
    Main execution function.
    """
    # Get Terraform outputs
    tf_output = get_tf_output()
    
    # Generate the Ansible dynamic inventory based on the Terraform outputs
    inventory = generate_inventory(tf_output)
    
    # Print the inventory in JSON format
    print(json.dumps(inventory, indent=2))

# Execute the main function when the script is run
if __name__ == "__main__":
    main()