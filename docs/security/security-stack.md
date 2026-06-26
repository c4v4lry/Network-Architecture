# Security Stack

## Monitoring Architecture

```
UniFi UCG Firewall
   ├── Syslog ──────────────┐
   ├── Netflow ─────────────┼──► Security Onion (VLAN 70)
   └── DNS Request Logs ────┘
```

## Defense Layers

| Layer | Technology | Scope |
|---|---|---|
| Perimeter | UniFi UCG Firewall | Inter-VLAN + WAN |
| Wireless isolation | PPSK per VLAN | Layer 2 separation |
| Detection | Security Onion | Syslog, Netflow, DNS |
| Threat Intel | OpenCTI | IOC enrichment |
| Vulnerability Mgmt | Greenbone OpenVAS | Internal scanning |
| Audit Logging | Firewall rule logs | Secured → MGMT access |

## Security Onion Data Sources

- **Syslog** — Rule hits, auth events, DHCP leases, admin actions from UCG
- **Netflow** — Flow records for all inter-VLAN and WAN traffic; used for lateral movement detection
- **DNS Request Logs** — All queries from all VLANs; used for DGA/C2 detection

## OpenCTI

- Aggregates threat feeds (MISP, TAXII, connectors)
- Enriches IOCs observed in Security Onion alerts
- Tracks threat actor TTPs relevant to home network exposure

## Greenbone OpenVAS

- Scheduled scans against all internal VLAN subnets
- Focus areas: IoT, Camera, and Streaming device exposure
- Findings tracked and remediated per severity
