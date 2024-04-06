#!/bin/bash

#Title Header
print_title() {
    # Clear and move cursor to the top of the screen
    clear
    tput cup 0 0

    # Print title
    echo "=== Create Cloud-Init VM Script ==="
}

# Function to display usage instructions
usage() {
    echo "Usage: $0 [-h] [-d CLOUD_INIT_IMAGE_DIR]"
    echo "Options:"
    echo "  -h              Display this help message"
    echo "  -d              Cloud-init image directory (default: /root/cloud-init/)"
    exit 1
}

# Default values
CLOUD_INIT_IMAGE_DIR="./cloud-init/"
MEMORY=2048
CORE=2
NET="virtio,bridge=vmbr0"
STORAGE="local-lvm"

# Parse command line options
while getopts ":hd:" option; do
    case "${option}" in
        h)
            usage
            ;;
        d)
            CLOUD_INIT_IMAGE_DIR=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

# Prompt user for VM parameters
#Print Title
    print_title
#Gather parameters
read -p "Enter VMID: " VMID
echo
read -p "Enter Memory (default $MEMORY): " custom_memory
MEMORY=${custom_memory:-$MEMORY}
echo
read -p "Enter Core count (default $CORE): " custom_core
CORE=${custom_core:-$CORE}
echo
read -p "Enter Guest Name: " NAME
echo
read -p "Enter Network (default $NET): " custom_net
NET=${custom_net:-$NET}
# List available storage pools
echo
echo "Available storage pools:"
count=0
awk '/^dir:|^lvmthin:|^nfs:/ {name=$2} /content.*images/ {print name}' /etc/pve/storage.cfg | while read -r pool_name; do
    ((count++))
    echo "$count. $pool_name"
done

# Prompt user to select a storage pool by number
read -p "Enter the number corresponding to the Storage pool (default local-lvm): " pool_number
# Validate user input
if [[ "$pool_number" =~ ^[0-9]+$ ]]; then
    selected_pool=$(awk '/^dir:|^lvmthin:|^nfs:/ {name=$2} /content.*images/ {print name}' /etc/pve/storage.cfg | sed -n "${pool_number}p")
    if [ -z "$selected_pool" ]; then
        echo "Invalid selection. Using default storage pool (local-lvm)."
    else
        STORAGE=$selected_pool
    fi
else
    echo "Using default storage pool (local-lvm)."
fi




# List available cloud-init images
echo
echo "Available cloud-init images in $CLOUD_INIT_IMAGE_DIR:"
# Enumerate and list cloud-init images
count=0
for image in $CLOUD_INIT_IMAGE_DIR/*; do
    ((count++))
    echo "$count. $(basename "$image")"
done

# Prompt user to select an image by number
read -p "Enter the number corresponding to the Cloud-init image: " image_number
# Validate user input
if ! [[ "$image_number" =~ ^[0-9]+$ ]]; then
    echo "Invalid input. Please enter a number."
    exit 1
fi

# Find the corresponding image file
selected_image=$(ls -1 $CLOUD_INIT_IMAGE_DIR | sed -n "${image_number}p")

if [ -z "$selected_image" ]; then
    echo "Invalid selection. Please choose a number from the list."
    exit 1
fi

CLOUD_INIT_IMAGE_FILE=$selected_image

# Summary of VM to be created
clear
    print_title
echo
echo "--Summary of VM to be created--"
echo "VMID: $VMID"
echo "Memory: $MEMORY"
echo "Core: $CORE"
echo "Name: $NAME"
echo "Network: $NET"
echo "Storage: $STORAGE"
echo "Cloud-init Image: $CLOUD_INIT_IMAGE_FILE"

# Final confirmation
read -p "Create the VM with the above configuration? (y/n): " confirmation
if [ "$confirmation" != "y" ]; then
    echo "Aborted."
    exit 1
fi

# Create the VM with cloud-init
qm create $VMID --memory $MEMORY --cores $CORE --name "$NAME" --net0 $NET --storage $STORAGE --agent 1 --balloon 0
qm importdisk $VMID $CLOUD_INIT_IMAGE_DIR/$CLOUD_INIT_IMAGE_FILE local-lvm
qm set $VMID --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-$VMID-disk-0
qm set $VMID --ide2 local-lvm:cloudinit
qm set $VMID --boot c --bootdisk scsi0
qm set $VMID --serial0 socket --vga serial0

echo "VM $VMID created successfully with cloud-init!"
