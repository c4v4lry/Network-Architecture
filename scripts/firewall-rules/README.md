# Firewall Rule Scripts

This directory is reserved for exported UniFi firewall configurations and any automation scripts for rule management.

## Planned Contents

- `unifi-backup/` — Exported UniFi controller backups (JSON/config format)
- `rule-audit.sh` — Script to diff current rules against last known-good state
- `cloudflare-ddns-update.sh` — DDNS updater for Foundry VTT domain

## Exporting UniFi Rules

From the UniFi Network console:
1. Settings → Backup → Download Backup
2. Store backup in `unifi-backup/` with date-stamped filename
3. Commit to version control for change tracking
