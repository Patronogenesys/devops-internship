terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.135.0"
    }
  }
}

# Subnet 

resource "yandex_vpc_subnet" "private-subnet" {
  name = local.subnet_name
  zone = var.subnet_zone
  network_id = var.network_id
  v4_cidr_blocks = var.v4_cidr_blocks
  route_table_id = yandex_vpc_route_table.nat-instance-route.id
}

# Route table

resource "yandex_vpc_route_table" "nat-instance-route" {
  name       = "nat-instance-route"
  network_id = var.network_id
  
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address = var.nat_ip_address
  }
}

# Instances

resource "yandex_compute_image" "instance_image" {
  source_family = "ubuntu-2404-lts-oslogin"
}

resource "yandex_compute_disk" "instance_boot_disks" {
  count = var.count_instance
  name = "boot-disk-private-instance-${count.index}"
  type = "network-hdd"
  zone = var.subnet_zone
  size = 10
  image_id = yandex_compute_image.instance_image.id
}

resource "yandex_compute_instance" "private_instances" {
  count = var.count_instance

  name = "private-instance-${count.index}"
  zone = var.subnet_zone
  platform_id = "standard-v1"
  folder_id = var.folder_id

  resources {
    core_fraction = 5
    cores = 2
    memory = 1
  }

  boot_disk {
    disk_id = yandex_compute_disk.instance_boot_disks[count.index].id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet.id
    security_group_ids = []
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

