# Lab 05 — DevOps Box (Docker Agent + SSH)

A single container that runs an **Azure Pipelines agent** plus **SSH**.

## Configure
```bash
cp .env.example .env
# set AZP_URL, AZP_TOKEN, AZP_POOL (Default), AZP_AGENT_NAME
```

## Launch
```bash
make up
make logs
make ssh   # devops@localhost -p 2222 (password from .env)
```

## Notes
- Uses `supervisord` to run `sshd` + agent.  
- Agent downloads on first boot and registers to your pool.  
- Security: keep PAT in `.env` (never commit); prefer SSH keys.
