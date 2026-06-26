variable "proxmox_endpoint" {
  description = "Proxmox API endpoint (e.g. https://192.168.70.x:8006)"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token — store in terraform.tfvars, never commit"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node name to deploy VMs on"
  type        = string
  default     = "pve"
}

variable "vm_template" {
  description = "Cloud-init base template to clone VMs from"
  type        = string
  default     = "ubuntu-24-04-template"
}

variable "vlan_vm_environment" {
  description = "VLAN tag for VM Environment"
  type        = number
  default     = 70
}

variable "vlan_automation" {
  description = "VLAN tag for Automation VLAN"
  type        = number
  default     = 80
}
