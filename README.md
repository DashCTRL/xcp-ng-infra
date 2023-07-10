# XCP-ng Infrastructure: A Comprehensive Guide

XCP-ng is an open-source hypervisor based on XenServer. It can be managed with its partner tool, Xen Orchestra (XO), providing a web interface for virtual machine management, backups, and more. This guide will walk you through the process of setting up XCP-ng, adding an ISO image storage repository, creating a new virtual machine, and managing your infrastructure.

## Installation

Follow the [official guide](https://docs.xcp-ng.org/installation/install-xcp-ng/) to install XCP-ng.

After installing XCP-ng, you'll want to set up Xen Orchestra. You can install Xen Orchestra Appliance (XOA) using the following command:

```bash
bash -c "$(wget -qO- https://xoa.io/deploy)"
```

For more information, refer to the [XOA documentation](https://docs.xcp-ng.org/management/manage-at-scale/xo-web-ui/).

## Adding ISO Image Storage Repository

1. **Access XCP-ng via SSH**

   ```bash
   ssh root@xcp-ng-server
   ```

2. **Create a Store Directory**

   ```bash
   mkdir /var/opt/ISO_IMAGES
   ```

   You can then copy your ISO images to `/var/opt/ISO_IMAGES` or download them directly with the `wget` command.

   ```bash
   cd /var/opt/ISO_IMAGES
   wget http://path-to-your-iso-image.iso
   ```

3. **Create Storage Repository**

   ```bash
   xe sr-create name-label=ISO_IMAGES_LOCAL type=iso device-config:location=/var/opt/ISO_IMAGES device-config:legacy_mode=true content-type=iso
   ```

   You can list your XCP-ng storage repositories by running:

   ```bash
   xe sr-list
   ```

## Creating a New Virtual Machine

1. **Deploy VM Template and Gather Information**

   Search XCP-ng's database for a template name. In this case, we are looking for Ubuntu 16.04:

   ```bash
   xe template-list | grep name-label | grep -i 16.04
   ```

   Install a new virtual machine using the above template name:

   ```bash
   xe vm-install template="Ubuntu Xenial Xerus 16.04" new-name-label="Ubuntu 16.04.1 Desktop amd64"
   ```

   Save the output UUID and new VM name into a shell variable for later use.

   ```bash
   UUID=your-vm-uuid
   NAME="Ubuntu 16.04.1 Desktop amd64"
   ```

2. **Configure Virtual Machine**

   Attach an ISO image to the new VM device and make the VM boot from the ISO:

   ```bash
   xe vm-cd-add uuid=$UUID  cd-name=your-iso-image.iso device=1
   xe vm-param-set HVM-boot-policy="BIOS order" uuid=$UUID
   ```

   Create a network interface:

   ```bash
   xe vif-create vm-uuid=$UUID network-uuid=your-network-uuid device=0
   ```

   Specify the amount of RAM to be used by this VM:

   ```bash
   xe vm-memory-limits-set dynamic-max=4000MiB dynamic-min=512MiB static-max=4000MiB static-min=512MiB uuid=$UUID
   ```

   Update the size of your virtual disk:

   ```bash
   xe vdi-resize uuid=your-vdi-uuid disk-size=15GiB
   ```

3. **Start Virtual Machine**

   Now you are ready to start your new VM:

   ```bash
   xe vm-start uuid=$UUID
   ```

   At this stage, you can use a VNC client to connect to your new VM and perform the actual OS installation.

## Local Console Commands

For operating on XCP-ng via the local console, you'll primarily use the `xe` command line interface. Below are the simplified commands for creating a VM and managing backups:

### Create a Virtual Machine

The following is a basic example of creating a VM. First, get the UUID of the template you want to use:

```bash
xe template-list name-label=<template_name>
```

This will output a lot of information, including a UUID. Copy this UUID for the next step. You'll replace `<template_uuid>` with this UUID.

```bash
xe vm-install template=<template_uuid> new-name-label=<vm_name>
```

You'll need to replace `<template_uuid>` with the UUID from the previous step, and `<vm_name>` with the name you want for your VM.

### VM Backup

For backing up a VM, there isn't a single `xe` command. However, you can use snapshot functionality as a basic form of backup. Below is an example of how to create and export a snapshot, which serves as a simple backup:

First, create a snapshot:

```bash
xe vm-snapshot vm=<vm_name> new-name-label=<snapshot_name>
```

This will create a snapshot of the VM `<vm_name>` and give it the name `<snapshot_name>`. It outputs a UUID for the snapshot, which you should copy.

Next, you'll convert the snapshot into a template:

```bash
xe template-param-set is-a-template=true ha-always-run=false uuid=<snapshot_uuid>
```

Replace `<snapshot_uuid>` with the UUID you received from the snapshot creation command.

Finally,

you can export the template to a file:

```bash
xe template-export template-uuid=<snapshot_uuid> filename=<backup_filename>
```

Replace `<snapshot_uuid>` with the UUID of the snapshot, and `<backup_filename>` with the desired name of your backup file. This will create a `.xva` file that serves as your backup.

## Getting VM IP Address

To get the IP address of a VM running on your XenServer, execute the following command:

```bash
xe vm-list params=name-label,networks | grep -v "^$"
```
