# Lab 10 — Troubleshooting & FAQ

## DevOps Box / Agent
- **Offline** → check `make logs`; update `AZP_URL`/`AZP_TOKEN`; proxy/firewall.  
- **SSH auth** → password in `.env`; verbose: `ssh -v devops@localhost -p 2222`.  
- **Port in use** → change to `127.0.0.1:2223:22` in compose.

## Pipelines
- **No trigger** → branch/path filters.  
- **Agent not found** → wrong pool name or offline agent.  
- **Checkout failed** → PAT lacks Code (R&W) or repo perms.

## Git Split
- Install `git-filter-repo` (`pip install git-filter-repo`).  
- Use PAT for HTTPS pushes.

## Performance
- Cache dependencies; shallow clone; self‑host for persistent caches.

## FAQ
- **Need a company for an org?** → No, anyone can create one.  
- **Local only?** → Yes, the DevOps Box runs locally and registers to your org.  
- **Is `.env` safe?** → Safe if never committed. Use vaults in prod.
