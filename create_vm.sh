#!/bin/bash

# Variables
ISO_DIR="/var/opt/ISO_IMAGES"
TEMPLATE_NAME="Ubuntu Xenial Xerus 16.04"
VM_NAME="Ubuntu_VM"
MAC="4a:4d:42:ac:b3:7b"
RAM_MAX="4000MiB"
RAM_MIN="512MiB"
DISK_SIZE="15GiB"

# Ubuntu versions
declare -A ISO_URLS
ISO_URLS["ubuntu-20.04.3-live-server-amd64.iso"]="http://releases.ubuntu.com/20.04/ubuntu-20.04.3-live-server-amd64.iso"
ISO_URLS["ubuntu-18.04.5-live-server-amd64.iso"]="http://releases.ubuntu.com/18.04/ubuntu-18.04.5-live-server-amd64.iso"
ISO_URLS["ubuntu-16.04.7-live-server-amd64.iso"]="http://releases.ubuntu.com/16.04/ubuntu-16.04.7-live-server-amd64.iso"

# Create ISO directory if it doesn't exist
mkdir -p $ISO_DIR

# Download ISOs
for ISO_NAME in "${!ISO_URLS[@]}"; do
    wget -O $ISO_DIR/$ISO_NAME ${ISO_URLS[$ISO_NAME]}
done

# Create ISO repository
xe sr-create name-label=ISO_REPO type=iso device-config:location=$ISO_DIR device-config:legacy_mode=true content-type=iso

# Get template UUID
TEMPLATE_UUID=$(xe template-list name-label="$TEMPLATE_NAME" --minimal)

# Create VM
VM_UUID=$(xe vm-install template=$TEMPLATE_UUID new-name-label=$VM_NAME)

# Attach ISO to VM
xe vm-cd-add vm=$VM_UUID cd-name=$ISO_NAME device=1

# Set VM to boot from ISO
xe vm-param-set uuid=$VM_UUID HVM-boot-policy="BIOS order"
xe vm-param-set uuid=$VM_UUID HVM-boot-params:order=d

# Get network UUID
NETWORK=$(xe network-list | grep "uuid ( RO)" | awk '{print $5}')

# Create a network interface
xe vif-create vm-uuid=$VM_UUID network-uuid=$NETWORK mac=$MAC device=0

# Specify RAM amount
xe vm-memory-limits-set dynamic-max=$RAM_MAX dynamic-min=$RAM_MIN static-max=$RAM_MAX static-min=$RAM_MIN uuid=$VM_UUID

# Get VDI UUID
VDI=$(xe vm-disk-list vm="$VM_NAME" | grep "uuid ( RO)" | head -1 | awk '{print $5}')

# Update the size of virtual disk
xe vdi-resize uuid=$VDI disk-size=$DISK_SIZE

# Start VM
xe vm-start uuid=$VM_UUID
