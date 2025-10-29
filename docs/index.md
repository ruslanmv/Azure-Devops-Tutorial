# Complete Azure DevOps Tutorial: From Zero to Production

This site is a **fully hands‑on lab** that turns you into a practical Azure DevOps power user.  
You will:

- Create an **Azure DevOps Organization** and project.
- Spin up a **DevOps Box** (Docker container) that runs an *Azure Pipelines self‑hosted agent* + *SSH server*.
- Split a monolith repo into two Azure Repos while **preserving Git history**.
- Build modern **YAML pipelines** with **path filters** and **build validation**.
- Apply **branch policies, security and best practices**.

> **Tip:** Work through the labs in order. Each lab includes **step‑by‑step tasks** and a **Solution** section with exact commands.

---

## Quickstart

```bash
# Use with the full repo this docs set accompanies
cp .env.example .env             # Fill AZP_URL and AZP_TOKEN (PAT)
make up                          # Start the DevOps Box container
make logs                        # Watch it register to Azure DevOps
make ssh                         # devops@localhost -p 2222
```
