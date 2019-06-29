output "vm_name_1" {
  value = "${vsphere_virtual_machine.vm.*.name[0]}.${var.vm_domain}"
}

output "vm_ip_1" {
  value = "${vsphere_virtual_machine.vm.*.default_ip_address[0]}"
}

#output "vm_name_2" {
#  value = "${vsphere_virtual_machine.vm.*.name[1]}.${var.vm_domain}"
#}

#output "vm_ip_2" {
#  value = "${vsphere_virtual_machine.vm.*.default_ip_address[1]}"
#}

#output "vm_name_3" {
#  value = "${vsphere_virtual_machine.vm.*.name[2]}.${var.vm_domain}"
#}

#output "vm_ip_3" {
#  value = "${vsphere_virtual_machine.vm.*.default_ip_address[2]}"
#}
