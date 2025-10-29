# Lab 09 — Best Practices (Microsoft + Industry)

## Repository Strategy

- Protect `main`: PRs required, reviewers, build validation.

- Prefer **Squash** merges for clean history.

- Use **path filters** to avoid unnecessary pipeline runs.


## Pipeline Design

- Pin container images (avoid `latest`).

- Extract common steps to **templates**; keep YAML DRY.

- Use **variable groups** and **key vault** for secrets.

- Cache dependencies where it’s safe and deterministic.

- Publish artifacts with clear naming + retention.


## Security & Compliance

- PATs: least privilege, short expiry, rotate.

- Use **Service Connections** with clear ownership and approvals.

- Store secrets in **Azure Key Vault** + link via variable groups.

- Restrict agent capabilities and outbound internet for sensitive builds.

