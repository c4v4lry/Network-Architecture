resource "proxmox_virtual_environment_vm" "opencti" {
  name        = "opencti"
  description = "OpenCTI — threat intelligence platform, feeds context to Automation VLAN"
  node_name   = var.proxmox_node
  tags        = ["opencti", "vlan70", "threat-intel", "security"]

  clone {
    vm_id = "9000"  # Update to your cloud-init template VM ID
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 100
  }

  network_device {
    bridge  = "vmbr0"
    vlan_id = var.vlan_vm_environment
  }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.70.x/24"  # Update with static IP
        gateway = "192.168.70.1"
      }
    }
  }
}
