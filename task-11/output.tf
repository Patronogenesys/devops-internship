output "jumphost_public_ip" {
  value = module.public-subnet.jumphost_public_ip
}

output "instances_name_ip" {
  value = module.private-subnet.instances_name_ip
}