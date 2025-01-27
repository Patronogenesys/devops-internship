terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.135.0"
    }
  }
}

provider "yandex" {
  service_account_key_file = local.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = "ru-central1-b"
}

resource "yandex_vpc_network" "vpc" {
  name = local.network_name
}

module "public-subnet" {
  source               = "./public-subnet"
  folder_id            = var.folder_id
  ssh_pub_key_path     = local.ssh_pub_key_path
  ssh_private_key_path = local.ssh_private_key_path
  subnet_zone          = local.public_subnet_zone
  network_id           = yandex_vpc_network.vpc.id
  v4_cidr_blocks       = ["10.1.0.0/24"]
  ssh_ingress_rules = [{
    description    = "vpn amsterdam allow"
    v4_cidr_blocks = ["194.0.194.139/32"]
  }]
}

module "private-subnet" {
  source           = "./private-subnet"
  folder_id        = var.folder_id
  ssh_pub_key_path = local.ssh_pub_key_path
  subnet_zone      = local.private_subnet_zone
  network_id       = yandex_vpc_network.vpc.id
  v4_cidr_blocks   = ["10.1.1.0/24"]
  nat_ip_address   = module.public-subnet.nat-ip-address
  count_instance   = 3
}

resource "yandex_mdb_postgresql_cluster" "pg_cluster" {
  name        = "test"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.vpc.id

  config {

    version = 15
    resources {
      resource_preset_id = "b1.medium"
      disk_type_id       = "network-hdd"
      disk_size          = 10
    }
    postgresql_config = {
      max_connections                = 200
      enable_parallel_hash           = true
      autovacuum_vacuum_scale_factor = 0.34
      default_transaction_isolation  = "TRANSACTION_ISOLATION_READ_COMMITTED"
      shared_preload_libraries       = "SHARED_PRELOAD_LIBRARIES_AUTO_EXPLAIN,SHARED_PRELOAD_LIBRARIES_PG_HINT_PLAN"
    }
  }

  maintenance_window {
    type = "WEEKLY"
    day  = "SAT"
    hour = 12
  }

  host {
    name             = "pg-host"
    zone             = local.public_subnet_zone
    subnet_id        = module.public-subnet.id
    assign_public_ip = true
  }
}

resource "yandex_mdb_postgresql_database" "pg_db1" {
  cluster_id = yandex_mdb_postgresql_cluster.pg_cluster.id
  name       = "db1"
  owner      = yandex_mdb_postgresql_user.user1.name
  lc_collate = "en_US.UTF-8"
  lc_type    = "en_US.UTF-8"
}

resource "yandex_mdb_postgresql_user" "user1" {
  cluster_id = yandex_mdb_postgresql_cluster.pg_cluster.id
  name       = "user1"
  password   = "password"
}

