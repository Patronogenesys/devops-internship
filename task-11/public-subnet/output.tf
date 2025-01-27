output "jumphost_public_ip" {
  value = yandex_compute_instance.nat-instance.network_interface.*.nat_ip_address
}

output "id" {
  value = yandex_vpc_subnet.public-subnet.id
}

output "nat-instance-sg-id" {
  value = yandex_vpc_security_group.nat-instance-sg.id
}

output "nat-ip-address" {
  value = yandex_compute_instance.nat-instance.network_interface.0.ip_address
}