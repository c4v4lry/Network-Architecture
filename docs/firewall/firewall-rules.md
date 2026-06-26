# Firewall Rules

All rules are implemented on the **UniFi UCG Firewall**. Rules are evaluated top-down; first match wins.

---

## Rule Philosophy

- **Default deny** between all VLANs unless explicitly permitted
- **MGMT and Secured** are privileged — they can reach anything
- **Nothing reaches MGMT or Secured** from untrusted VLANs
- **Secured → MGMT** is allowed but **fully logged** for audit purposes
- **DNS (port 53)** is universally accessible to all VLANs
- **Automation VLAN** has narrow, specific outbound rights only — treated as privileged but untrusted

---

## Rule Table (Ordered)

| Priority | Source | Destination | Port | Action | Log |
|---|---|---|---|---|---|
| 1 | Secured | MGMT | Any | Allow | ✅ Yes |
| 2 | MGMT | Any | Any | Allow | No |
| 3 | Secured | Any | Any | Allow | No |
| 4 | Any | DNS Server (Secured) | 53 TCP/UDP | Allow | No |
| 5 | Security Onion | Automation VLAN | N8n webhook port | Allow | No |
| 6 | OpenCTI | Automation VLAN | CTI API port | Allow | No |
| 7 | Automation server (static IP) | UCG Firewall | 443 | Allow | ✅ Yes |
| 8 | Automation server | Security Onion | Syslog port | Allow | No |
| 9 | OpenTofu server (static IP) | Proxmox nodes | 8006 | Allow | ✅ Yes |
| 10 | Any | MGMT | Any | Deny | No |
| 11 | Any | Secured | Any | Deny | No |
| 12 | Automation VLAN | Any | Any | Deny | No |
| 13 | IoT | Lights/Cameras/Streaming | Any | Deny | No |
| 14 | Lights | IoT/Cameras/Streaming | Any | Deny | No |
| 15 | Cameras | IoT/Lights/Streaming | Any | Deny | No |
| 16 | Streaming | IoT/Lights/Cameras | Any | Deny | No |
| 17 | Any | VM Environment | Any | Deny | No |
| 18 | Any | Any | Any | Deny (implicit) | No |

---

## Automation VLAN Rules — Detail

The Automation VLAN (80) has the most deliberately constructed ruleset. Despite having write access to the UCG Firewall API, it is treated as a restricted zone:

- Rules 5 and 6 allow only two specific sources to push data in
- Rule 7 allows outbound to the UCG API only — and only from the automation server's **static IP** (source-locked)
- Rule 12 catches any other outbound Automation traffic and denies it — no internet, no lateral movement

### Why Source-IP Locking Matters
Even if the API credentials were stolen, they cannot be used from any device other than the automation server's specific IP address. This is enforced at the firewall level, not in software.

---

## OpenTofu Firewall Rules — Detail

The OpenTofu physical server (VLAN 70) is allowed outbound to Proxmox API port 8006 only (Rule 9). All other outbound from the OpenTofu server is covered by the implicit deny. The server has no internet access — provider plugins are installed manually.

---

## Audit Logging

The following rules generate Security Onion-forwarded log entries:
- Rule 1: Secured → MGMT (every connection)
- Rule 7: Automation server → UCG Firewall API (every API call)
- Rule 9: OpenTofu server → Proxmox API (every IaC operation)
