provider "xenserver" {
  url      = "https://xcp-ng-server"
  username = "root"
  password = "password"
}

data "xenserver_template" "template" {
  template = "Ubuntu Xenial Xerus 16.04"
}

resource "xenserver_vdi" "vdi" {
  sr_uuid = "your-sr-uuid"
  name_label = "Ubuntu_VM_Disk"
  size = 10737418240 # 10 GiB
}

resource "xenserver_vm" "vm" {
  base_template_name = data.xenserver_template.template.name_label
  name_label = "Ubuntu_VM"
  static_mem_min = 1073741824 # 1 GiB
  static_mem_max = 2147483648 # 2 GiB
  dynamic_mem_min = 1073741824 # 1 GiB
  dynamic_mem_max = 2147483648 # 2 GiB
  boot_order = "cdn"
  vcpus = 2
  networks = ["your-network-uuid"]
  vdis = [xenserver_vdi.vdi.id]
}
