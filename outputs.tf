output "ipv4_vm_address" {
  value = proxmox_virtual_environment_vm.proxmox_vm
  depends_on = [ proxmox_virtual_environment_vm.proxmox_vm ]
}