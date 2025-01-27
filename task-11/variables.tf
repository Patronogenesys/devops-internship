variable "secret_path" {
  description = "Path to `.secret` directory"
  type        = string
  default     = "../.secret"
}

variable "service_account_key_file_name" {
  description = "Name of file inside .secret directory"
  type        = string
  default     = "terraform-service-key.json"
}

variable "cloud_id" {
  description = "ID of cloud in YC"
  type        = string
  default     = "b1g5b020anchqspg6qul"
}

variable "folder_id" {
  description = "ID of folder in specified cloud"
  type        = string
  default     = "b1gtitn88s7l0epk3bb3"
}


locals {
  service_account_key_file = "${var.secret_path}/${var.service_account_key_file_name}"
  network_name             = "task-11"
  private_subnet_zone      = "ru-central1-b"
  public_subnet_zone       = "ru-central1-b"
  ssh_pub_key_path         = "/home/patronogen/.ssh/min-vm-18-12-2024.pub"
  ssh_private_key_path     = "/home/patronogen/.ssh/min-vm-18-12-2024"
}
