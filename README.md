# 🏠 Home Network Architecture

A documented, version-controlled home network built around **UniFi hardware**, **VLAN segmentation**, **PPSK-based wireless isolation**, a hardened **VM security stack**, and a **human-in-the-loop AI security automation pipeline**.

---

## 📐 Architecture Overview

```
Internet
   │
   ▼
┌──────────────────────────────────────────────────────┐
│   UniFi UCG Firewall (2nd Floor)                     │
│   Port 1 — WAN                                       │
│   Port 2 — U7 Lite AP (2nd Floor, direct)            │
│   Port 3 — MoCA Adapter → 1st Floor & Basement       │
│   Port 4 — Secured PC 1                              │
│   Port 5 — Secured PC 2                              │
└────────────┬─────────────────────────────────────────┘
             │ (Coax via MoCA)
     ┌───────┴──────────────────────────────┐
     │                                      │
     ▼                                      ▼
MoCA Adapter — 1st Floor            MoCA Adapter — Basement
     │                                      │
     ▼                                      ▼
U7 Lite AP — Floor 1        8-Port Managed Switch (Basement)
                                Port 1 — MoCA (Trunk, All VLANs)
                                Port 2 — U7 Lite AP (Trunk, All VLANs)
                                Port 3 — DNS Server miniPC (Secured VLAN)
                                Port 4 — OpenTofu Server miniPC (VM VLAN)
                                Port 5 — Automation AI/n8n/ntfy miniPC (Automation VLAN)
                                Port 6 — Unused
                                Port 7 — VM Server (VM VLAN)
                                Port 8 — 2nd VM Server (VM VLAN)
```

---

## 🗂️ VLAN Structure

| VLAN | Name | Type | Access Method | Notes |
|------|------|------|--------------|-------|
| 10 | MGMT | Wired | Admin only | UCG, switches, APs |
| 20 | Secured | Wired + Wireless | PPSK | DNS server, trusted workstations |
| 30 | IoT | Wireless | PPSK | Managed via Home Assistant |
| 40 | Lights | Wireless | PPSK | Managed via Home Assistant |
| 50 | Cameras | Wireless | PPSK | Managed via Home Assistant |
| 60 | Streaming | Wireless | PPSK | Internet-only access |
| 70 | VM Environment | Wired | Isolated | Proxmox VMs + OpenTofu server |
| 80 | Automation | Wired | Isolated | AI/N8n/ntfy — privileged, narrow rules |

> Wireless VLANs are broadcast across all three U7 Lite APs and segmented using **per-VLAN PPSK passwords**.

---

## 🔒 Firewall Policy Summary

| Source → Destination | Action | Notes |
|---|---|---|
| MGMT → Any | ✅ Allow | Full management access |
| Secured → Any | ✅ Allow | Full access + **logged** |
| Any → MGMT | 🚫 Deny | Hard block |
| Any → Secured | 🚫 Deny | Hard block |
| VLAN → VLAN | 🚫 Deny | No lateral movement |
| Any → DNS :53 | ✅ Allow | All VLANs reach DNS server |
| Secured → MGMT | ✅ Allow + Log | Audited access |
| Security Onion → Automation :webhook | ✅ Allow | Alert triggers only |
| OpenCTI → Automation :api | ✅ Allow | CTI context feed only |
| Automation → UCG API :443 | ✅ Allow | Firewall rule writes — source IP locked |
| Automation → Internet | 🚫 Deny | No outbound internet |
| OpenTofu → Proxmox API :8006 | ✅ Allow | IaC management only |
| OpenTofu → Internet | 🚫 Deny | No outbound internet |

See [`docs/firewall/`](docs/firewall/) for full rule sets.

---

## 🖥️ VM Environment Stack (VLAN 70)

Proxmox VMs run on two wired VM servers on **VLAN 70**. The OpenTofu server is a **separate physical miniPC** also wired onto VLAN 70 via the basement switch, keeping the IaC engine outside the infrastructure it manages.

| Service | Type | Purpose | Access |
|---|---|---|---|
| **Home Assistant OS** | VM | IoT/Lights/Camera automation + Ollama AI | Internal |
| **Foundry VTT** | VM | Game server | External via Cloudflare DDNS |
| **Security Onion** | VM | SIEM — Syslog, Netflow, DNS logs | Internal |
| **OpenCTI** | VM | Threat intelligence platform | Internal |
| **Greenbone OpenVAS** | VM | Vulnerability scanning | Internal |
| **OpenTofu Server** | Physical miniPC | Infrastructure-as-Code (Proxmox mgmt) | Internal — VLAN 70, Switch Port 4 |

---

## 🤖 Automation VLAN Stack (VLAN 80)

A dedicated, heavily restricted VLAN hosting the AI-driven security automation pipeline. This server has privileged firewall API write access and is isolated accordingly. Hosted on a single physical miniPC (Switch Port 5).

| Service | Purpose |
|---|---|
| **Ollama (Llama3)** | LLM — summarizes Security Onion alerts, generates fix recommendations |
| **N8n** | Workflow automation — orchestrates the full alert → approval → remediation flow |
| **ntfy.sh** | Push notification delivery — sends Approve/Deny prompts to administrator |

### Automation Flow

```
Security Onion (alert)
   └─► N8n webhook
         └─► Ollama (Llama3)
               ├── Input: alert data + OpenCTI threat context
               └── Output: incident summary + suggested firewall fix
                     └─► ntfy.sh → Admin phone (Approve / Deny)
                           ├── Approve → N8n → UCG Firewall API (rule applied)
                           └── Deny   → N8n → Log decision, no action
```

### Security Controls

- Inbound: Security Onion and OpenCTI only — specific ports, no other sources
- Outbound: UCG Firewall API on port 443 only — source IP locked at firewall
- No internet access
- Approval timeout: auto-deny if no response within 15 minutes
- All approvals and denials logged to Security Onion
- N8n webhook requires secret token authentication
- LLM output validated before touching firewall API

See [`docs/automation/`](docs/automation/) for full design.

---

## 🌐 DNS

- DNS server hosted on the **Secured VLAN** (basement switch Port 3)
- All VLANs are permitted to reach it on **port 53**
- DNS request logs are forwarded to **Security Onion**

---

## 📡 Wireless — Floor Layout

| Floor | AP Model | Connection | VLANs Broadcast |
|---|---|---|---|
| Basement | UniFi U7 Lite | Switch Port 2 (Trunk) | All (PPSK segmented) |
| Floor 1 | UniFi U7 Lite | MoCA Adapter (1F) | All (PPSK segmented) |
| Floor 2 | UniFi U7 Lite | UCG Port 2 (direct) | All (PPSK segmented) |

---

## 🗃️ Repository Structure

```
home-network-architecture/
├── README.md
├── docs/
│   ├── vlans/
│   │   └── vlan-design.md
│   ├── firewall/
│   │   └── firewall-rules.md
│   ├── vm-environment/
│   │   └── vm-stack.md
│   ├── automation/
│   │   └── automation-vlan.md
│   ├── opentofu/
│   │   └── opentofu-design.md
│   ├── security/
│   │   └── security-stack.md
│   └── dns/
│       └── dns-design.md
├── diagrams/
│   └── network-topology.md
├── infrastructure/
│   └── opentofu/
│       ├── providers.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── vms/
│           ├── home-assistant.tf
│           ├── foundry-vtt.tf
│           ├── security-onion.tf
│           ├── opencti.tf
│           ├── openvas.tf
│           └── automation-server.tf
├── scripts/
│   └── firewall-rules/
│       └── README.md
└── .github/
    └── CHANGELOG.md
```

---

## 🔗 External Services

- **Cloudflare** — Dynamic DNS for Foundry VTT (domain + DDNS updates)
- **Ollama / Llama3** — Local LLM for Home Assistant device control and security automation

---

## 🚧 Roadmap

- [ ] Complete Home Assistant device onboarding
- [ ] Deploy Automation VLAN server and configure N8n workflows
- [ ] Populate OpenTofu `.tf` files for all VMs
- [ ] Export and version-control UniFi firewall rule backups
- [ ] Document OpenCTI connector integrations
- [ ] Add IDS/IPS tuning notes from Security Onion
- [ ] Automate DDNS update script for Cloudflare
- [ ] Document Greenbone scan schedules and targets
- [ ] Implement ntfy action buttons for Approve/Deny flow
- [ ] Configure approval timeout (15 min auto-deny)

---

## 📄 License

MIT — personal documentation repository.
