output "instances_name_ip" {
  value = [for i in yandex_compute_instance.private_instances:
   "${i.name} - ${jsonencode(i.network_interface.*.ip_address)}"]
}

output "id" {
  value = yandex_vpc_subnet.private-subnet.id
}