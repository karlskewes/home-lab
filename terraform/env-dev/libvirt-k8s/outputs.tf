# Print the Boxes IP
# Note: you can use `virsh domifaddr <vm_name> <interface>` to get the ip later
output "guest_names" {
  value = libvirt_domain.domain_vm.*.name
}

#output "ip" {
#  value = "${libvirt_domain.domain_vm.network_interface.0.addresses.0}"
#}
#output "ip" {
#    value = "${join(",", aws_instance.web.*.public_ip)}"
#}
