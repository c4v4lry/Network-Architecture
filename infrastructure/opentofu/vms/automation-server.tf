resource "proxmox_virtual_environment_vm" "automation_server" {
  name        = "automation-server"
  description = "Automation VLAN server — Ollama (Llama3), N8n, ntfy.sh. Human-in-the-loop AI security response pipeline."
  node_name   = var.proxmox_node
  tags        = ["automation", "vlan80", "n8n", "ollama", "ntfy", "security"]

  clone {
    vm_id = "9000"  # Update to your cloud-init template VM ID
  }

  cpu {
    # Ollama/Llama3 benefits from more cores for inference
    cores = 8
    type  = "host"
  }

  memory {
    dedicated = 16384  # Llama3 needs headroom — 16GB recommended
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 100  # Llama3 model weights + N8n data
  }

  network_device {
    bridge  = "vmbr0"
    vlan_id = var.vlan_automation  # VLAN 80 — Automation, NOT VM Environment
  }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.80.x/24"  # Update with static IP — lock this in firewall rules
        gateway = "192.168.80.1"
      }
    }
  }
}
