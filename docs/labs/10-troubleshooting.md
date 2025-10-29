# Lab 10 — Troubleshooting

## Agent offline

- Wrong `AZP_URL` or expired PAT.

- Corporate proxy blocking GitHub/Azure endpoints.

- Check logs: `make logs`.


## SSH fails

- If `SSH_DISABLE_PASSWORD=true`, you must set `SSH_PUBLIC_KEY`.

- Permissions: `~/.ssh` (700), `authorized_keys` (600).


## Duplicate agents after restart

- Clear volumes and agent cache: `make fresh`.


## Push denied / 401

- Use **PAT** as password for Git over HTTPS.

- Confirm repo permissions and branch policies.

