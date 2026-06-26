# Automation VLAN (VLAN 80)

## Overview

The Automation VLAN hosts a human-in-the-loop AI security automation pipeline. It provides a **reactive** complement to the proactive threat intelligence provided by OpenCTI. When Security Onion fires an alert, this stack summarizes the incident, recommends a fix, and delivers an Approve/Deny prompt to the administrator. Approved actions are executed automatically via the UniFi firewall API.

This VLAN is treated as a **privileged but untrusted** zone — it has narrow, specific outbound rights and no inbound access from untrusted sources.

---

## Services

| Service | Role |
|---|---|
| Ollama (Llama3) | Local LLM — alert summarization and fix generation |
| N8n | Workflow orchestration — routes data between all components |
| ntfy.sh | Push notification — delivers Approve/Deny prompt to administrator |

---

## Automation Flow

```
Security Onion
   └─► N8n (webhook, token-authenticated)
         └─► Ollama / Llama3
               ├── Input 1: Security Onion alert payload (sanitized)
               ├── Input 2: OpenCTI threat context (structured IOC data)
               └── Output: JSON { summary, severity, suggested_rule }
                     └─► ntfy.sh → Admin device
                           [Approve]──► N8n validates LLM output
                           │              └─► UCG Firewall API (rule applied)
                           │                    └─► Security Onion (audit log)
                           [Deny]──► Security Onion (audit log, no action)
                           [Timeout: 15min]──► Auto-deny + alert
```

---

## Firewall Rules — Automation VLAN

| Direction | Source | Destination | Port | Action | Notes |
|---|---|---|---|---|---|
| Inbound | Security Onion | Automation server | N8n webhook port | Allow | Alert triggers |
| Inbound | OpenCTI | Automation server | API port | Allow | CTI context only |
| Outbound | Automation server | UCG Firewall | 443 | Allow | Source IP locked |
| Outbound | Automation server | Security Onion | Syslog port | Allow | Audit log writes |
| Any | Automation VLAN | Internet | Any | Deny | No external access |
| Any | Automation VLAN | Other VLANs | Any | Deny | No lateral movement |

---

## Security Controls

### Authentication
- N8n webhook endpoint requires a **secret token** in the request header
- UCG Firewall API credentials stored in N8n encrypted credential vault
- Dedicated scoped API account on UCG — firewall rule modification only

### Network
- Firewall source-IP locks the automation server's IP as the only allowed caller to the UCG API
- No internet access on the Automation VLAN
- One-way push from Security Onion and OpenCTI — automation server cannot initiate connections back

### LLM Output Validation
- Ollama prompted to return **structured JSON only** — no freeform text in the API payload section
- N8n validates the JSON schema before passing to the firewall API
- Prompt injection mitigation: alert data is sanitized before entering the Ollama prompt

### Approval Controls
- **15-minute timeout** — unanswered prompts are auto-denied and logged
- **Rate limiting** — more than 3 approval requests in 10 minutes triggers auto-deny and a separate high-priority alert
- Every Approve and Deny decision is written to Security Onion as an audit event

---

## Ollama / Llama3 Prompt Design

Two-stage prompting approach:

**Stage 1 — Human summary (sent via ntfy)**
```
System: You are a network security analyst. Summarize the following 
        Security Onion alert in plain language for a home network 
        administrator. Include severity, affected device, and what 
        the threat likely is. Be concise — 3 sentences maximum.

Input:  [sanitized alert JSON] + [OpenCTI IOC context]
Output: Plain text summary
```

**Stage 2 — Firewall rule (only generated after Approve)**
```
System: You are a firewall rule generator. Return ONLY valid JSON 
        matching this schema: { action, protocol, src_ip, dst_ip, 
        dst_port, description }. No other text.

Input:  [alert data] + [approved summary]
Output: JSON firewall rule payload
```

---

## ntfy.sh Configuration

ntfy supports native action buttons. The notification structure:

```
Title:    [SEVERITY] Security Onion Alert
Body:     <Ollama-generated summary>
Actions:  [✅ Approve] [❌ Deny]
Tags:     security, network
Priority: high (for critical alerts), default (for informational)
```

The action buttons POST back to an N8n webhook with the decision, which gates the remediation workflow.

---

## Audit Trail

Every event in the pipeline is logged:
- Alert received → Security Onion
- LLM summary generated → N8n execution log
- ntfy prompt sent → N8n execution log  
- Admin decision (Approve/Deny/Timeout) → Security Onion
- Firewall rule applied (if approved) → Security Onion + UCG Firewall logs
