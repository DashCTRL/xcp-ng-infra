provider "xenorchestra" {
  url      = "https://xen-orchestra.mycompany.com"
  username = "admin@admin.net"
  password = "admin"
}

data "xenorchestra_template" "template" {
  name_label = "Ubuntu Focal Fossa 20.04"
}

resource "xenorchestra_vm" "vm" {
  memory_max = 1073741824
  cpus       = 1
  cloud_config = <<EOF
#cloud-config
password: mypassword
chpasswd: { expire: False }
ssh_pwauth: True
runcmd:
  - curl -fsSL https://get.docker.com -o get-docker.sh
  - sh get-docker.sh
  - rm get-docker.sh
  - curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  - chmod +x /usr/local/bin/docker-compose
EOF
  name_label = "myvm"
  template   = data.xenorchestra_template.template.id
}
