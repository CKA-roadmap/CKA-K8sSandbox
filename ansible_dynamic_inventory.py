#!/usr/bin/env python3

import json
import os
import subprocess

def get_tf_output():
    cmd = 'terraform output -json'
    output = subprocess.check_output(cmd.split()).decode('utf-8')
    return json.loads(output)

def generate_inventory(tf_output):
    inventory = {
        '_meta': {
            'hostvars': {}
        },
        'all': {
            'children': ['kvm']
        },
        'kvm': {
            'hosts': [],
            'vars': {}
        }
    }

    for info in tf_output['output_info']['value']:
        if info['ip'].startswith("IP not assigned"):
            continue
        host = info['name']
        inventory['kvm']['hosts'].append(host)
        inventory['_meta']['hostvars'][host] = {
            'ansible_host': info['ip'],
            'ansible_user': info['cloud_user']
        }

    return inventory

def main():
    tf_output = get_tf_output()
    inventory = generate_inventory(tf_output)
    print(json.dumps(inventory, indent=2))

if __name__ == "__main__":
    main()