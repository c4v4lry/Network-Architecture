resource "proxmox_virtual_environment_vm" "security_onion" {
  name        = "security-onion"
  description = "Security Onion — SIEM receiving Syslog, Netflow, and DNS logs from UCG firewall"
  node_name   = var.proxmox_node
  tags        = ["security-onion", "vlan70", "siem", "security"]

  # Security Onion uses its own ISO installer — not a cloud-init clone
  cdrom {
    file_id = "local:iso/securityonion-2.x.iso"  # Update to current SO version
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 16384  # Security Onion recommends 16GB minimum
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 200  # SO needs significant storage for logs
  }

  network_device {
    bridge  = "vmbr0"
    vlan_id = var.vlan_vm_environment
  }

  operating_system {
    type = "l26"
  }
}
