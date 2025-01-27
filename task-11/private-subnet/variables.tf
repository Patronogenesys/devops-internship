variable "network_id" {
  type = string
}

variable "v4_cidr_blocks" {
  type = list(string)
}

variable "subnet_zone"{
  type = string
}

variable "count_instance" {
  type = number
  default = 1
}

variable "nat_ip_address" {
  type = string
}

variable "ssh_pub_key_path" {
  type = string
}

variable "folder_id" {
  type = string
}

locals {
  subnet_name = "private-subnet"
  vm_user = "patronogen"
}