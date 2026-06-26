# Changelog

## [Unreleased]

### Planned
- Complete Home Assistant device onboarding
- Deploy Automation VLAN server and configure N8n workflows
- Implement ntfy action buttons for Approve/Deny flow
- Configure approval timeout (15 min auto-deny)
- Populate OpenTofu static IPs in .tf files
- Export and version UniFi firewall rule backups
- Document OpenCTI connector integrations
- Add IDS/IPS tuning notes from Security Onion
- Automate Cloudflare DDNS update script
- Document Greenbone scan schedules

## [1.2.0] — Physical Topology Documentation

### Added
- UCG Firewall port assignments (Ports 1–5) in README and VLAN design
- 8-port basement managed switch port mapping (Ports 1–8, VLANs, access/trunk modes)
- MoCA coax backhaul documentation — UCG Port 3 → Floor 1 AP and Basement switch
- Secured PC 1 and Secured PC 2 documented as direct UCG connections (Ports 4 & 5)
- Access Point uplink method per floor (direct, MoCA, switch trunk)
- Updated network topology Mermaid diagram with full physical layer (floors, ports, MoCA, switch)
- Updated README architecture ASCII diagram to reflect actual physical layout
- Updated VLAN design with UCG port table and switch port table

### Changed
- Topology diagram now groups devices by physical floor
- Floor 2 AP correctly shown as direct UCG connection (not switch-connected)
- Basement AP correctly shown as connected to managed switch (Port 2)
- DNS Server, OpenTofu, and Automation miniPCs now documented with specific switch ports

## [1.1.0] — Automation VLAN + OpenTofu

### Added
- VLAN 80 — Automation VLAN design and documentation
- Automation pipeline architecture: Security Onion → N8n → Ollama (Llama3) → ntfy → UCG API
- Security controls for Automation VLAN (prompt injection mitigation, approval timeouts, rate limiting)
- OpenTofu server design (physical device on VLAN 70)
- OpenTofu provider and variable configuration (`providers.tf`, `variables.tf`, `outputs.tf`)
- OpenTofu VM stubs for all 6 managed VMs
- `.gitignore` for OpenTofu secrets and state files
- Updated VLAN table (8 VLANs)
- Updated firewall rules with Automation and OpenTofu rules

## [1.0.0] — Initial Documentation

### Added
- README with full architecture overview and firewall policy summary
- VLAN design documentation (7 VLANs, PPSK segmentation)
- Firewall rule documentation with priority table
- VM environment stack documentation
- Security stack documentation
- DNS design documentation
- Mermaid network topology diagram
