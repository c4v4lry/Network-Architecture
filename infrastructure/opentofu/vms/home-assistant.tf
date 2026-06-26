resource "proxmox_virtual_environment_vm" "home_assistant" {
  name        = "home-assistant"
  description = "Home Assistant OS — smart home automation hub with Ollama integration"
  node_name   = var.proxmox_node
  tags        = ["home-assistant", "vlan70", "automation"]

  # Home Assistant OS uses a dedicated disk image, not a cloud-init clone
  # Update the datastore_id and file_id to match your Proxmox storage
  disk {
    datastore_id = "local-lvm"
    file_id      = "local:iso/haos_ova-12.x.qcow2"  # Update to current HAOS version
    interface    = "scsi0"
    size         = 64
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  network_device {
    bridge  = "vmbr0"
    vlan_id = var.vlan_vm_environment
  }

  operating_system {
    type = "l26"
  }
}
