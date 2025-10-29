# Lab 05 — Self‑Hosted Agent in Docker (DevOps Box)

This is our **single‑container** agent + SSH box.

## 1) Configure
```bash
cp .env.example .env
# edit .env with your AZP_URL, AZP_TOKEN (PAT), AZP_POOL, etc.
```

## 2) Start & verify
```bash
make up
make logs    # watch supervisor + agent + sshd logs
make ssh     # connect as devops@localhost -p 2222
```
Azure DevOps → Org settings → **Agent pools** → your pool → agent is **Online**.

## 3) Security notes
- Prefer **SSH keys** (`SSH_PUBLIC_KEY`) and set `SSH_DISABLE_PASSWORD=true`.

- SSH bound to `127.0.0.1:2222` to avoid remote exposure.

- Treat PAT like a password; rotate frequently.

