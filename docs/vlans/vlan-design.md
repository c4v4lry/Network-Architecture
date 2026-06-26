# VLAN Design

## Overview

VLAN segmentation enforces network isolation at Layer 2. All VLANs are trunked to the UniFi UCG Firewall and each U7 Lite AP. Wireless clients are separated using **Per-SSID Pre-Shared Keys (PPSK)** — each VLAN has a unique password, eliminating the need for multiple SSIDs.

---

## VLAN Table

| VLAN ID | Name | Purpose | Connection Type | Notes |
|---|---|---|---|---|
| 10 | MGMT | Network device management | Wired only | UCG, switches, APs |
| 20 | Secured | Trusted workstations, servers | Wired + Wireless | DNS server, Secured PCs |
| 30 | IoT | Smart home devices | Wireless (PPSK) | Managed via Home Assistant |
| 40 | Lights | Smart lighting | Wireless (PPSK) | Managed via Home Assistant |
| 50 | Cameras | IP cameras | Wireless (PPSK) | Managed via Home Assistant |
| 60 | Streaming | TVs, streaming sticks | Wireless (PPSK) | Internet-only access |
| 70 | VM Environment | Proxmox VM Servers + OpenTofu Server | Wired only | Security stack, HASS, Foundry |
| 80 | Automation | AI/N8n/ntfy pipeline server | Wired only | Privileged — narrow firewall rules |

---

## Physical Layer — UCG Firewall Ports (2nd Floor)

| Port | Connection | Notes |
|---|---|---|
| Port 1 | WAN | Internet uplink |
| Port 2 | U7 Lite AP — Floor 2 | Direct AP connection, trunk all VLANs |
| Port 3 | MoCA Adapter — 2F | Coax backhaul to Floor 1 and Basement |
| Port 4 | Secured PC 1 | VLAN 20 (Secured) |
| Port 5 | Secured PC 2 | VLAN 20 (Secured) |

---

## Physical Layer — Basement Managed Switch Ports

| Port | Connection | VLAN / Mode | Notes |
|---|---|---|---|
| Port 1 | MoCA Adapter — Basement | Trunk, All VLANs | Uplink to UCG via coax backhaul |
| Port 2 | U7 Lite AP — Basement | Trunk, All VLANs | Broadcasts all wireless VLANs |
| Port 3 | DNS Server miniPC | Secured VLAN (20) | Access port — VLAN 20 only |
| Port 4 | OpenTofu Server miniPC | VM VLAN (70) | Access port — VLAN 70 only |
| Port 5 | Automation AI/n8n/ntfy miniPC | Automation VLAN (80) | Access port — VLAN 80 only |
| Port 6 | Unused | — | — |
| Port 7 | VM Server | VM VLAN (70) | Access port — VLAN 70 only |
| Port 8 | 2nd VM Server | VM VLAN (70) | Access port — VLAN 70 only |

---

## MoCA Backhaul

The UCG Firewall (2nd floor, Port 3) connects to a MoCA adapter which distributes trunk traffic over existing coax cabling to:

- **1st Floor MoCA Adapter** → directly wired to the Floor 1 U7 Lite AP
- **Basement MoCA Adapter** → wired to the 8-port managed switch

This eliminates the need to run new Ethernet between floors.

---

## PPSK Design

Wireless VLANs (20, 30, 40, 50, 60) use PPSK — a single SSID with per-VLAN passwords, broadcast across all three U7 Lite APs. VLAN 70 and VLAN 80 are wired only and never broadcast wirelessly.

**Benefits of PPSK:**
- Single SSID — cleaner client experience
- Per-device credential assignment possible
- No cross-VLAN association even on a shared radio

---

## Access Point Connectivity

| Floor | AP | Uplink | VLANs Broadcast |
|---|---|---|---|
| 2nd Floor | U7 Lite | UCG Port 2 (direct) | VLAN 20, 30, 40, 50, 60 (PPSK) |
| 1st Floor | U7 Lite | MoCA Adapter — 1F | VLAN 20, 30, 40, 50, 60 (PPSK) |
| Basement | U7 Lite | Switch Port 2 (Trunk) | VLAN 20, 30, 40, 50, 60 (PPSK) |

VLAN 10 (MGMT), VLAN 70 (VM Environment), and VLAN 80 (Automation) are wired-only and never broadcast wirelessly.

---

## VLAN 80 — Automation (Special Notes)

VLAN 80 is the most restricted VLAN in the environment despite having privileged outbound access to the UCG Firewall API. Key design decisions:

- **No internet access** — all dependencies installed offline or via internal mirror
- **No inbound access** from anything except Security Onion (webhook) and OpenCTI (API context)
- **Outbound limited** to UCG Firewall API (port 443) and Security Onion (syslog/audit)
- **Static IP required** — the firewall source-locks this IP for all UCG API calls
- **Not on VLAN 70** — kept separate from the VM Environment to limit blast radius if compromised
