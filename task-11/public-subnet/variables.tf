variable "folder_id" {
  type = string
}

variable "ssh_pub_key_path" {
  type = string
}

variable "ssh_private_key_path" {
  type = string
}

variable "network_id" {
  type = string
}

variable "v4_cidr_blocks" {
  type = list(string)
}

variable "subnet_zone" {
  type = string
}

variable "ssh_ingress_rules" {
  type = list(object({
    description    = string
    v4_cidr_blocks = list(string)
  }))
}

locals {
  subnet_name      = "public-subnet"
  vm_nat_name      = "nat-instance"
  vm_user          = "patronogen"
  sg_nat_name      = "nat-instance-sg"
  route_table_name = "nat-instance-route"
}

