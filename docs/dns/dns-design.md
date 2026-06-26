# DNS Design

## DNS Server

- **Location:** Secured VLAN (VLAN 20)
- **Accessibility:** All VLANs — permitted via firewall on port 53 TCP/UDP
- **Log forwarding:** DNS query logs forwarded to Security Onion

## Why DNS Lives on Secured VLAN

1. Server is protected by deny-to-Secured rules from untrusted VLANs
2. Only port 53 is punched through — no other Secured resources are exposed
3. Full DNS query visibility across all network segments

## Firewall DNS Rule

```
Source:      Any VLAN
Destination: DNS Server IP (Secured VLAN)
Port:        53 TCP/UDP
Action:      ALLOW
Priority:    Above blanket deny-to-Secured rule
```

## DNS Logging → Security Onion

All DNS request logs forwarded to Security Onion for:
- DNS-based C2 detection (DGA, beaconing patterns)
- Identification of devices querying malicious domains
- Correlation with Netflow and Syslog data

## Future Considerations

- DNS-over-TLS (DoT) or DNS-over-HTTPS (DoH) for upstream privacy
- Pi-hole layer for ad/tracker blocking across all VLANs
- DNSSEC validation for upstream queries
