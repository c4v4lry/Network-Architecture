resource "proxmox_virtual_environment_vm" "foundry_vtt" {
  name        = "foundry-vtt"
  description = "Foundry VTT — game server, externally accessible via Cloudflare DDNS"
  node_name   = var.proxmox_node
  tags        = ["foundry", "vlan70", "external-access"]

  clone {
    vm_id = "9000"  # Update to your cloud-init template VM ID
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 40
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
