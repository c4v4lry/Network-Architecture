resource "proxmox_virtual_environment_vm" "openvas" {
  name        = "greenbone-openvas"
  description = "Greenbone OpenVAS — vulnerability scanning across all internal VLAN subnets"
  node_name   = var.proxmox_node
  tags        = ["openvas", "greenbone", "vlan70", "vuln-mgmt", "security"]

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
    size         = 80
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
