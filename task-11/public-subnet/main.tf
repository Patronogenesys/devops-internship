terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.135.0"
    }
  }
}

# Subnet

resource "yandex_vpc_subnet" "public-subnet" {
  name           = local.subnet_name
  zone           = var.subnet_zone
  network_id     = var.network_id
  v4_cidr_blocks = var.v4_cidr_blocks
}

# Security group for NAT

resource "yandex_vpc_security_group" "nat-instance-sg" {
  name       = local.sg_nat_name
  network_id = var.network_id

  egress {
    protocol       = "ANY"
    description    = "Permit out any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow http in"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow https in"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
}

resource "yandex_vpc_security_group_rule" "ssh-allow" {
  count = length(var.ssh_ingress_rules)

  security_group_binding = yandex_vpc_security_group.nat-instance-sg.id
  direction              = "ingress"
  description            = var.ssh_ingress_rules[count.index].description
  v4_cidr_blocks         = var.ssh_ingress_rules[count.index].v4_cidr_blocks
  protocol               = "TCP"
  port                   = 22 
}

# NAT instance

resource "yandex_compute_image" "nat-instance-ubuntu" {
  source_image = "fd8n7m00bvgqtqnoef85"
}

resource "yandex_compute_disk" "boot-disk-nat" {
  name     = "boot-disk-nat"
  type     = "network-hdd"
  zone     = var.subnet_zone
  size     = "3"
  image_id = yandex_compute_image.nat-instance-ubuntu.id
}

resource "yandex_compute_instance" "nat-instance" {

  name        = local.vm_nat_name
  platform_id = "standard-v1"
  zone        = var.subnet_zone

  resources {
    core_fraction = 5
    cores         = 2
    memory        = 1
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-nat.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
    nat                = true
  }

  metadata = {
    user-data = <<-EOT
      #cloud-config
      users:
        - name: ${local.vm_user}
          groups: sudo
          shell: /bin/bash
          sudo: 'ALL=(ALL) NOPASSWD:ALL'
          ssh-authorized-keys:
            - ${file("${var.ssh_pub_key_path}")}
    EOT
  }
}



