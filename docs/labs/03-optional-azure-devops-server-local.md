# Lab 03 — Optional: Azure DevOps Server (On‑prem) for Air‑gapped Labs

> **Skip** if you are using Azure DevOps Services (cloud).

## 1) Prereqs
- **Windows Server** VM
- **SQL Server Express** (or Standard/Enterprise)
- Service accounts (domain or local), SSL cert (recommended)

## 2) Install
1. Install SQL Server; enable Mixed Mode; create `tfs` DB user (optional)

2. Install **Azure DevOps Server Express**

3. Run **Configuration Wizard** → **New Deployment** → point to SQL instance

4. Configure service account, URLs, and reporting (optional)


## 3) Create a project
Open the Azure DevOps web portal → New project → mirror Lab 02 steps.


> **Production**: plan backups, SSL, TLS hardening, identity provider integration, and monitoring.
