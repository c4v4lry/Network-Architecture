# VM Environment Stack

All virtual machines reside on **VLAN 70 (VM Environment)** and connect via wired uplinks. This VLAN is accessible only from MGMT and Secured VLANs per firewall policy.

---

## Virtual Machines

### Home Assistant OS
- **Purpose:** Central smart home automation hub
- **Integration:** Ollama (local LLM) for natural language device control
- **Manages:** IoT (VLAN 30), Lights (VLAN 40), Cameras (VLAN 50)
- **Access:** Internal only

### Foundry VTT
- **Purpose:** Virtual tabletop game server
- **External Access:** Yes — domain name via Cloudflare
- **DDNS:** Cloudflare dynamic IP update handles residential IP changes
- **Port exposure:** Controlled via Cloudflare proxy / firewall pinhole

### Security Onion
- **Purpose:** SIEM and network security monitoring
- **Inputs:** Syslog, Netflow (UCG Firewall), DNS request logs (DNS server)
- **Access:** Internal only

### OpenCTI
- **Purpose:** Threat intelligence aggregation and analysis
- **Feeds:** Manual + connector-based CTI ingestion
- **Access:** Internal only

### Greenbone OpenVAS
- **Purpose:** Vulnerability scanning across internal network segments
- **Scan targets:** All internal VLAN subnets (scheduled)
- **Access:** Internal only
