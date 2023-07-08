# XCP-ng Infrastructure

XCP-ng is an open-source hypervisor based on XenServer. It can be managed with its partner tool, Xen Orchestra (XO), providing a web interface for virtual machine management, backups, and more.

## Installation

Follow the [official guide](https://docs.xcp-ng.org/installation/install-xcp-ng/) to install XCP-ng.

After installing XCP-ng, you'll want to set up Xen Orchestra. You can install Xen Orchestra Appliance (XOA) using the following command:

```bash
bash -c "$(wget -qO- https://xoa.io/deploy)"
```

For more information, refer to the [XOA documentation](https://docs.xcp-ng.org/management/manage-at-scale/xo-web-ui/).

Alternatively, you can install Xen Orchestra from source following this [guide](https://ostechnix.com/install-xen-orchestra-appliance-xoa/).

## Create a Virtual Machine

Once you've set up Xen Orchestra, you can create a VM directly from the web interface.

1. Click on the `New` button in the VM section.
2. Select the template for your VM.
3. Fill in the VM details, such as name, description, CPUs, and memory.
4. Choose the storage repository and network settings.
5. Click on `Create`.

The VM will be created and will appear in the VM section.

## VM Backup

Xen Orchestra also provides a simple method for backing up your VMs.

1. Go to the `Backup` section.
2. Click on `New`.
3. Select the type of backup you want to create (disaster recovery, rolling snapshot, backup).
4. Choose the VM you want to backup.
5. Select the target storage repository for the backup.
6. Set a schedule for automatic backups (optional).
7. Click on `Create`.

Your backup will be scheduled according to the settings you've chosen.

Remember, these instructions are based on the web interface provided by Xen Orchestra, which could change over time. Always refer to the latest official documentation for the most accurate information.

Please note that managing an XCP-ng infrastructure requires proper knowledge and understanding of virtualization concepts. Always ensure you've backed up your data and understood the steps you're performing.

show the command in local console
For operating on XCP-ng via the local console, you'll primarily use the `xe` command line interface. Below are the simplified commands for creating a VM and managing backups:

## Create a Virtual Machine

The following is a basic example of creating a VM. First, get the UUID of the template you want to use:

```bash
xe template-list name-label=<template_name>
```

This will output a lot of information, including a UUID. Copy this UUID for the next step. You'll replace `<template_uuid>` with this UUID.

```bash
xe vm-install template=<template_uuid> new-name-label=<vm_name>
```

You'll need to replace `<template_uuid>` with the UUID from the previous step, and `<vm_name>` with the name you want for your VM.

## VM Backup

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

Finally, you can export the template to a file:

```bash
xe template-export template-uuid=<snapshot_uuid> filename=<backup_filename>
```

Replace `<snapshot_uuid>` with the UUID of the snapshot, and `<backup_filename>` with the desired name of your backup file. This will create a `.xva` file that serves as your backup.

Remember to check the XCP-ng documentation for details about managing your VMs and backups. Always test your backup procedure and ensure that you can restore from your backups before implementing it in a production environment.

make nice wiki and add step to create vm
