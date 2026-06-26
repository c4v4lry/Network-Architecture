output "vm_ips" {
  description = "IP addresses of all managed VMs"
  value = {
    home_assistant   = proxmox_virtual_environment_vm.home_assistant.ipv4_addresses
    foundry_vtt      = proxmox_virtual_environment_vm.foundry_vtt.ipv4_addresses
    security_onion   = proxmox_virtual_environment_vm.security_onion.ipv4_addresses
    opencti          = proxmox_virtual_environment_vm.opencti.ipv4_addresses
    openvas          = proxmox_virtual_environment_vm.openvas.ipv4_addresses
    automation_server = proxmox_virtual_environment_vm.automation_server.ipv4_addresses
  }
}
