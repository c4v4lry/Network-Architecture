# OpenTofu — Infrastructure as Code

## Overview

OpenTofu manages all Proxmox VMs on VLAN 70 as infrastructure-as-code. The OpenTofu server is a **dedicated physical device** wired onto VLAN 70, intentionally separate from the Proxmox hypervisor nodes it manages. This separation means the IaC tooling is never running on the infrastructure it controls.

---

## OpenTofu Server

- **Type:** Physical device (not a VM)
- **VLAN:** 70 — VM Environment (wired)
- **Access:** Proxmox API on port 8006 only
- **Internet:** Denied — provider plugins installed manually or via internal mirror
- **Tool:** OpenTofu (open source Terraform fork) with `bpg/proxmox` provider

---

## Why a Physical Device on VLAN 70

Running OpenTofu inside a Proxmox VM creates a circular dependency — if you need OpenTofu to rebuild the VM environment, you need Proxmox running first. A physical device on the same VLAN avoids this and means:

- OpenTofu can reach Proxmox API regardless of VM state
- The device can be used for disaster recovery rebuilds
- No risk of accidentally managing the host running the tool

---

## Proxmox Provider

Using the `bpg/proxmox` provider — currently the most actively maintained community provider with the broadest resource support.

```hcl
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.46"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint   # https://proxmox-ip:8006
  api_token = var.proxmox_api_token
  insecure  = false                 # Use proper TLS cert
}
```

---

## Managed Resources

| Resource | File | VLAN |
|---|---|---|
| Home Assistant OS VM | `vms/home-assistant.tf` | 70 |
| Foundry VTT VM | `vms/foundry-vtt.tf` | 70 |
| Security Onion VM | `vms/security-onion.tf` | 70 |
| OpenCTI VM | `vms/opencti.tf` | 70 |
| Greenbone OpenVAS VM | `vms/openvas.tf` | 70 |
| Automation Server VM | `vms/automation-server.tf` | 80 |

---

## API Security

- Dedicated Proxmox API token scoped to VM management only
- Token stored in a local `.tfvars` file excluded from version control via `.gitignore`
- OpenTofu server firewall rule: outbound to Proxmox API port 8006 only
- No SSH keys or admin credentials stored on the OpenTofu server

---

## Workflow

```bash
# Plan — preview changes before applying
tofu plan

# Apply — provision or update VMs
tofu apply

# Destroy — tear down a specific VM
tofu destroy -target proxmox_vm_qemu.security_onion
```

State file is stored locally on the OpenTofu server. Consider backing up `terraform.tfstate` to an encrypted location after significant changes.
