#!/bin/bash

# Prompt user to enter username, domain names or IPs of remote hosts
echo "Enter username and domain names or IPs of the remote hosts in the format user@domain (separated by spaces):"
read -p "> " -a remote_hosts

# Function to setup passwordless SSH for each remote host
setup_passwordless_ssh() {
    local user_host=$1

    echo "Setting up passwordless SSH for $user_host..."

    # Copy public key to the remote host
    ssh-copy-id -i ~/.ssh/id_rsa.pub "$user_host" > /dev/null 2>&1

    # Check if SSH key exchange was successful
    if [ $? -eq 0 ]; then
        echo "Passwordless SSH setup for $user_host successful."
    else
        echo "Failed to setup passwordless SSH for $user_host."
    fi
}

# Iterate over each remote host and setup passwordless SSH
for host in "${remote_hosts[@]}"; do
    setup_passwordless_ssh "$host"
done

echo "Script execution completed."
